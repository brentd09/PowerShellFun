<#
.SYNOPSIS
  This is a better version of ConnectFour
.DESCRIPTION
  This script uses a Class object to allow for the use of a 
  constructor to build the board object array
.EXAMPLE
  Play-ConnectFourV2
.NOTES
  General notes
    Created By: Brent Denny
    Created On: 8 Apr 2019
#>
[CmdletBinding()]
Param()
#Class Definitions
Class ConnectFourCell {
  [int]$Pos
  [int]$Col
  [int]$Row
  [int]$FDiag
  [int]$BDiag
  [string]$Val

  ConnectFourCell ([int]$Position,[string]$Value) {
    $this.Pos = $Position
    $this.Col = $Position % 7
    $this.Row = [System.Math]::Truncate($Position/7)
    if     ($Position -in @(21,15,9,3))        {$this.FDiag = 0}
    elseif ($Position -in @(28,22,16,10,4))    {$this.FDiag = 1}
    elseif ($Position -in @(35,29,23,17,11,5)) {$this.FDiag = 2}
    elseif ($Position -in @(36,30,24,18,12,6)) {$this.FDiag = 3}
    elseif ($Position -in @(37,31,25,19,13))   {$this.FDiag = 4}
    elseif ($Position -in @(38,32,26,20))      {$this.FDiag = 5}
    else   {$this.FDiag = 99} # 99 Indicates that the position is in a diagonal that we are not interested in
    if     ($Position -in @(14,22,30,38))      {$this.BDiag = 0}
    elseif ($Position -in @(7,15,23,31,39))    {$this.BDiag = 1}
    elseif ($Position -in @(0,8,16,24,32,40))  {$this.BDiag = 2}
    elseif ($Position -in @(1,9,17,25,33))     {$this.BDiag = 3}
    elseif ($Position -in @(2,10,18,26,34))    {$this.BDiag = 4}
    elseif ($Position -in @(3,11,19,27))       {$this.BDiag = 5}
    else   {$this.BDiag = 99} # 99 Indicates that the position is in a diagonal that we are not interested in
    $this.Val = $Value
  }
}
# Function Definitions
function New-GameBoard {
  [ConnectFourCell[]]$Board = 0..41 | ForEach-Object {
    [ConnectFourCell]::New($_,'.')
  }
  $Board
}
function Select-GameCol {
  Param (
    [ConnectFourCell[]]$Board,
    [String]$TurnColor
  )
  do {
    If ($TurnColor -eq "R") {$Color = 'Red'}
    else {$Color = 'Yellow'}

    if ($Host.Name -eq 'ConsoleHost') {
      Write-Host -ForegroundColor $Color "$Color turn, please enter a number between 1 and 7: "
      $GameColStr = ($Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')).Character -as [string]
    } 
    else {
      Write-Host -NoNewline -ForegroundColor $Color "$Color turn, please enter a number between 1 and 7: "
      $GameColStr = Read-Host
      if ($GameColStr -eq '') {$GameColStr = '9'}
      else {$GameColStr = $GameColStr.Substring(0,1)}
    }
    if ($GameColStr -match "^[1-7]$") {[int]$GameCol = ($GameColStr -as [int]) - 1}
    $ColChosen = $Board | Where-Object {$_.Col -eq $GameCol}
    $HowFullIsCol = $ColChosen | Where-Object {$_.Val -notmatch "[YR]"}
  } until ($GameColStr -in @('1','2','3','4','5','6','7') -and $HowFullIsCol.Count -gt 0)
  $RowToSet = $HowFullIsCol.Count - 1
  $Pos = ($ColChosen | Where-Object {$_.Row -eq $RowToSet}).Pos
  $Board[$Pos].Val = $TurnColor
}
function Show-GameBoard {
  param (
    [ConnectFourCell[]]$Board
  ) 
  Clear-Host
  Write-Host
  $Count = 0
  Write-Host -ForegroundColor Green "    C O N N E C T   F O U R`n"
  Write-Host -ForegroundColor Yellow "   1   2   3   4   5   6   7`n   -------------------------"
  foreach ($Cell in $Board) {
    $Count++
    if ($cell.Val -eq '.') {$FColor = 'Darkgray'; $DisplayChar = '+'}
    if ($cell.Val -eq 'R') {$FColor = 'Red'; $DisplayChar = [char]9787}
    if ($cell.Val -eq 'Y') {$FColor = 'Yellow'; $DisplayChar = [char]9787}
    Write-Host -NoNewline -ForegroundColor $FColor "   $DisplayChar"
    if ($Count%7 -eq 0) {Write-Host "`n"}
  }
  Write-Host
}
function Get-Winner {
  Param (
    [ConnectFourCell[]]$Board
  )
  $YellowCount = 0; $RedCount = 0
  ForEach ($RowNum in (0..5)) {
    $RowVals = ($Board | Where-Object {$_.Row -eq $RowNum}).Val
    $Yellows = $Board | Where-Object {$_.Row -eq $RowNum -and $_.Val -eq 'Y'}
    $Reds    = $Board | Where-Object {$_.Row -eq $RowNum -and $_.Val -eq 'R'}
    if ($Yellows.Count -ge 4) {
      $YellowCount = 0
      foreach ($Val in $RowVals) {
        if ($Val -eq 'Y' -and $YellowCount -eq 3) {return 'Yellow'}
        if ($Val -eq 'Y' -and $RedCount -eq 0)    {$YellowCount++}
        if ($Val -eq 'R' -and $YellowCount -gt 0) {$YellowCount = 0; $RedCount = 1}
        if ($Val -eq 'Y' -and $RedCount -gt 0)    {$RedCount = 0; $YellowCount = 1}
      }
    }
    if ($Reds.Count -ge 4) {
      $RedCount = 0
      foreach ($Val in $RowVals) {
        if ($Val -eq 'R' -and $RedCount -eq 3)    {return 'Red'}
        if ($Val -eq 'R' -and $YellowCount -eq 0) {$RedCount++}
        if ($Val -eq 'Y' -and $RedCount -gt 0)    {$RedCount = 0; $YellowCount = 1}
        if ($Val -eq 'R' -and $YellowCount -gt 0) {$YellowCount = 0; $RedCount = 1}
      }
    }
  }
  $YellowCount = 0; $RedCount = 0
  ForEach ($ColNum in (0..5)) {
    $ColVals = ($Board | Where-Object {$_.Col -eq $ColNum}).Val
    $Yellows = $Board | Where-Object {$_.Col -eq $ColNum -and $_.Val -eq 'Y'}
    $Reds    = $Board | Where-Object {$_.Col -eq $ColNum -and $_.Val -eq 'R'}
    if ($Yellows.Count -ge 4) {
      $YellowCount = 0
      foreach ($Val in $ColVals) {
        if ($Val -eq 'Y' -and $YellowCount -eq 3) {return 'Yellow'}
        if ($Val -eq 'Y' -and $RedCount -eq 0)    {$YellowCount++}
        if ($Val -eq 'R' -and $YellowCount -gt 0) {$YellowCount = 0; $RedCount = 1}
        if ($Val -eq 'Y' -and $RedCount -gt 0)    {$RedCount = 0; $YellowCount = 1}
      }
    }
    if ($Reds.Count -ge 4) {
      $RedCount = 0
      foreach ($Val in $ColVals) {
        if ($Val -eq 'R' -and $RedCount -eq 3)    {return 'Red'}
        if ($Val -eq 'R' -and $YellowCount -eq 0) {$RedCount++}
        if ($Val -eq 'Y' -and $RedCount -gt 0)    {$RedCount = 0; $YellowCount = 1}
        if ($Val -eq 'R' -and $YellowCount -gt 0) {$YellowCount = 0; $RedCount = 1}
      }
    }
  }
  $YellowCount = 0; $RedCount = 0
  ForEach ($FDiagNum in (0..5)) {
    $FDiagVals = ($Board | Where-Object {$_.FDiag -eq $FDiagNum}).Val
    $Yellows = $Board | Where-Object {$_.FDiag -eq $FDiagNum -and $_.Val -eq 'Y'}
    $Reds    = $Board | Where-Object {$_.FDiag -eq $FDiagNum -and $_.Val -eq 'R'}
    if ($Yellows.Count -ge 4) {
      $YellowCount = 0
      foreach ($Val in $FDiagVals) {
        if ($Val -eq 'Y' -and $YellowCount -eq 3) {return 'Yellow'}
        if ($Val -eq 'Y' -and $RedCount -eq 0)    {$YellowCount++}
        if ($Val -eq 'R' -and $YellowCount -gt 0) {$YellowCount = 0; $RedCount = 1}
        if ($Val -eq 'Y' -and $RedCount -gt 0)    {$RedCount = 0; $YellowCount = 1}
      }
    }
    if ($Reds.Count -ge 4) {
      $RedCount = 0
      foreach ($Val in $FDiagVals) {
        if ($Val -eq 'R' -and $RedCount -eq 3)     {return 'Red'}
        if ($Val -eq 'R' -and $YellowCount -eq 0) {$RedCount++}
        if ($Val -eq 'Y' -and $RedCount -gt 0)    {$RedCount = 0; $YellowCount = 1}
        if ($Val -eq 'R' -and $YellowCount -gt 0) {$YellowCount = 0; $RedCount = 1}
      }
    }
  }
  $YellowCount = 0; $RedCount = 0
  ForEach ($BDiagNum in (0..5)) {
    $BDiagVals = ($Board | Where-Object {$_.BDiag -eq $BDiagNum}).Val
    $Yellows = $Board | Where-Object {$_.BDiag -eq $BDiagNum -and $_.Val -eq 'Y'}
    $Reds    = $Board | Where-Object {$_.BDiag -eq $BDiagNum -and $_.Val -eq 'R'}
    if ($Yellows.Count -ge 4) {
      $YellowCount = 0
      foreach ($Val in $BDiagVals) {
        if ($Val -eq 'Y' -and $YellowCount -eq 3)  {return 'Yellow'}
        if ($Val -eq 'Y' -and $RedCount -eq 0)     {$YellowCount++}
        if ($Val -eq 'R' -and $YellowCount -gt 0)  {$YellowCount = 0; $RedCount = 1}
        if ($Val -eq 'Y' -and $RedCount -gt 0)     {$RedCount = 0; $YellowCount = 1}
      }
    }
    if ($Reds.Count -ge 4) {
      $RedCount = 0
      foreach ($Val in $BDiagVals) {
        if ($Val -eq 'R' -and $RedCount -eq 3)    {return 'Red'}
        if ($Val -eq 'R' -and $YellowCount -eq 0) {$RedCount++}
        if ($Val -eq 'Y' -and $RedCount -gt 0)    {$RedCount = 0; $YellowCount = 1}
        if ($Val -eq 'R' -and $YellowCount -gt 0) {$YellowCount = 0; $RedCount = 1}
      }
    }
  }
  return 'None'
}
# ###################################################
# MAIN CODE
[int]$TurnNumber = 0
[ConnectFourCell[]]$GameBoard = New-GameBoard
[string[]]$TurnArray = @('R','Y')
[string]$Even = $TurnArray | Get-Random
[string]$Odd  = $TurnArray | Where-Object {$_ -ne $Even}
do {
  if ($TurnNumber % 2 -eq 0) {$Turn = $Even}
  else {$Turn = $Odd}
  Show-GameBoard -Board $GameBoard
  Select-GameCol -Board $GameBoard -TurnColor $Turn
  $Winner = Get-Winner -Board $GameBoard
  $NumberEmpty = 42 - ($GameBoard | Where-Object {$_.Val -in $TurnArray}).Count
  $TurnNumber++
} until ($NumberEmpty -eq 0 -or $Winner -ne 'None')
Show-GameBoard -Board $GameBoard
if ($Winner -ne 'None') {
  Write-Host -ForegroundColor Green -NoNewline "   The Winner is"
  Write-Host -ForegroundColor $Winner " $($Winner.ToUpper())`n`n"
}
else {
  write-Host -ForegroundColor Red "   The game is a DRAW`n`n"
}