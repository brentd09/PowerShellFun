Class TTTBoardCell {
  [int]$Pos
  [int]$Col
  [int]$Row
  [Int]$Diag # Diag = 0 => 0-5-8 , Diag = 1 => 2,5,6
  [string]$Content
  [bool]$Threat

  TTTBoardCell($Position) {
    $ColNum = $Position % 3
    $RowNum = [math]::Truncate($Position / 3)
    $this.Pos = $Position
    $this.Col = $ColNum
    $this.Row = $RowNum
    $this.Content = '-'
    if ($Position -in @(0,5,8) ) {$this.Diag = 0}
    if ($Position -in @(2,5,6) ) {$this.Diag  = 1}
    $this.Threat = $false
  }
   
  [bool]PlaceChoice([string]$Char) {
    if ($this.Content -eq '-') {
      $this.Content = $Char
      $this.Threat = $false
      return $true
    }
    else {return $false}
  }
  
  [psobject[]]Threats([TTTBoardCell[]]$Board,[string]$TurnLetter) {
    foreach ($Direction in @(0..7)) {
      switch ($Direction) {
        0 {$DirectionObjects = $Board | Where-Object {$_.Row -eq 0}}
        1 {$DirectionObjects = $Board | Where-Object {$_.Row -eq 1}}
        2 {$DirectionObjects = $Board | Where-Object {$_.Row -eq 2}}
        3 {$DirectionObjects = $Board | Where-Object {$_.Col -eq 0}}
        4 {$DirectionObjects = $Board | Where-Object {$_.Col -eq 1}}
        5 {$DirectionObjects = $Board | Where-Object {$_.Col -eq 2}}
        6 {$DirectionObjects = $Board | Where-Object {$_.Diag -eq 0}}
        7 {$DirectionObjects = $Board | Where-Object {$_.Diag -eq 1}}
      } #END Switch
    } #END Foreach
  } #END Threats Method
  
  

    [psobject[]]$Result = @()
    $OppositeLetter = @('X','O') | Where-Object {$_ -ne $TurnLetter}
    $DirectionNames = @('Row','Col','Diag')
    foreach ($Direction in (0..2)) {
      if ($Direction -in (0..1)) {$IndexArray = @(0..2)}
      else {$IndexArray = @(0..1)}
      foreach ($Index in $IndexArray) {
        $DirectionObjects = $Board | Where-Object {$_.Row -eq $Index}
        $NumberOfBlanks = ($DirectionObjects | Group-Object | Where-Object {$_.Content -eq '-'}).count
        $ThreatProperties = @{
          ThreatReal = $false
          RowIndex = $Index
          EmptyPos = ($DirectionObjects | Where-Object {$_.Content -eq '-' }).Pos
        } 
        if ($NumberOfBlanks -eq 1) {
          $NumberOfOpposite = ($DirectionObjects | Group-Object | Where-Object {$_.Content -eq $OppositeLetter[0]}).count
          if ($NumberOfOpposite -eq 2) {
            [hashtable]$ThreatProperties = @{
              ThreatDirection = $DirectionNames[$Direction]
              ThreatStatus = $true
              ThreatIndex = $Index
              EmptyPos = ($DirectionObjects | Where-Object {$_.Content -eq '-' }).Pos
            }
            $Result += (New-Object -TypeName psobject -Property $ThreatProperties)
          }
        } #end if
        else {
          [hashtable]$ThreatProperties = @{
            ThreatReal = $false
            RowIndex = $Index
            EmptyPos = ($DirectionObjects | Where-Object {$_.Content -eq '-' }).Pos
          }         
          $Result += (New-Object -TypeName psobject -Property $ThreatProperties)
        }
      } #end foreach
    } #End foreach
    return $Result
  } #end Method
} #END Class

#Functions
function Show-Board {
  Param ([TTTBoardCell[]]$Board,[string]$Padding='  ')

  Clear-Host
  $EntryColors = @('White','White','White','White','White','White','White','White','White')
  $ShowSqr = @(' ',' ',' ',' ',' ',' ',' ',' ',' ')
  $GridColor = "Yellow"
  $XColor = "Red"
  $OColor = "white"
  foreach ($Pos in (0..8)){
    if ($Board[$Pos].Content -eq "X") { $EntryColors[$Pos] = $XColor}
    if ($Board[$Pos].Content -eq "O") { $EntryColors[$Pos] = $OColor}
    if ($Board[$Pos].Content -eq "-") { $EntryColors[$Pos] = "darkgray"}
    if ($Board[$Pos].Content -match "[XO]") {$ShowSqr[$Pos] = $Board[$Pos].Content}
    else {$ShowSqr[$Pos] = $Pos + 1}
  }
  Write-Host -ForegroundColor 'Yellow' "`n${Padding}Tic Tac Toe`n"
  Write-Host -NoNewline "$Padding "
  Write-Host -ForegroundColor $EntryColors[0] -NoNewline $ShowSqr[0]
  Write-Host -ForegroundColor $GridColor -NoNewline " | "  
  write-host -ForegroundColor $EntryColors[1] -NoNewline $ShowSqr[1]
  write-host -ForegroundColor $GridColor -NoNewline " | "
  Write-Host -ForegroundColor $EntryColors[2] $ShowSqr[2]
  Write-Host -ForegroundColor $GridColor "${Padding}---+---+---"
  Write-Host -NoNewline "$Padding "
  Write-Host -ForegroundColor $EntryColors[3] -NoNewline $ShowSqr[3]
  Write-Host -ForegroundColor $GridColor -NoNewline " | "  
  write-host -ForegroundColor $EntryColors[4] -NoNewline $ShowSqr[4]
  write-host -ForegroundColor $GridColor -NoNewline " | "
  Write-Host -ForegroundColor $EntryColors[5] $ShowSqr[5]
  Write-Host -ForegroundColor $GridColor "${Padding}---+---+---"
  Write-Host -NoNewline "$Padding "
  Write-Host -ForegroundColor $EntryColors[6] -NoNewline $ShowSqr[6]
  Write-Host -ForegroundColor $GridColor -NoNewline " | "  
  write-host -ForegroundColor $EntryColors[7] -NoNewline $ShowSqr[7]
  write-host -ForegroundColor $GridColor -NoNewline " | "
  Write-Host -ForegroundColor $EntryColors[8] $ShowSqr[8]
  Write-Host 
}

#Main code
Clear-Host
[TTTBoardCell[]]$TTTBoard = foreach ($Pos in (0..8)) {[TTTBoardCell]::New($Pos)}
Show-Board -Board $TTTBoard
$Turn = 'X'
do {
  do {
    $BadChoice = $false
    $BoardChoice = Read-Host 'Enter the choice'
    $ErrorActionPreference = 'stop'
    try {[int]$ChoiceIndex = $BoardChoice - 1}
    catch {$BadChoice = $true}
    finally {$ErrorActionPreference = 'Continue'}
  } until ($TTTBoard[$ChoiceIndex].PlaceChoice($Turn) -and $BadChoice -eq $false)
  Show-Board -Board $TTTBoard
  $Turn = @('X','O') | Where-Object {$_ -ne $Turn}
} until ($TTTBoard.Content -notcontains '-')