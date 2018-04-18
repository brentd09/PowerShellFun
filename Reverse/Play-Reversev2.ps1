<#
.SYNOPSIS
  This is the OTHELLO game 
.DESCRIPTION
  The moves are made only if you can swap some of the opponents
  pieces to your color, to do this you place your color on a space 
  that is unoccupied but is next to your opponents color but only
  if your color is also other side of the opponents color pieces 
.NOTES

  Created By: Brent Denny
  Created On: 20 Dec 2017

  Board Numbers
  -------------

  00 01 02 03 04 05 06 07  starts with 27 = W 28 = B 
  08 09 10 11 12 13 14 15              35 = B 36 = W
  16 17 18 19 20 21 22 23  All others = -
  24 25 26 27 28 29 30 31 
  32 33 34 35 36 37 38 39
  40 41 42 43 44 45 46 47
  48 49 50 51 52 53 54 55
  56 57 58 59 60 61 62 63
#>

function Draw-Board {
  Param (
    $Board
  )  
  Clear-Host
  $numOfWhite = ($Board | Where-Object {$_.color -eq "White"}).count
  $numOfRed = ($Board | Where-Object {$_.color -eq "Red"}).count
  $LeftSpc = '   '
  Write-Host  -ForegroundColor Cyan "`n$LeftSpc      --  REVERSE  --         --SCORE--"
  Write-Host -ForegroundColor White   "$LeftSpc                              White: $numOfWhite"
  Write-Host -NoNewline -ForegroundColor Yellow "$LeftSpc   1  2  3  4  5  6  7  8"
  Write-Host -ForegroundColor Red "     Red:   $numOfRed"
  foreach ($start in (0,8,16,24,32,40,48,56)) {
    $num = ($start / 8) + 65
    $letter = [char]$num # Build the A B C... on the left of the board
    Write-Host -ForegroundColor Yellow -NoNewline $LeftSpc$letter' '
    Write-Host -NoNewline " "
    foreach ($Pos in ($start..($Start+7))) {
      Write-Host -NoNewline -ForegroundColor $Board[$Pos].Color $Board[$Pos].Value' ' 
    }
    write-host
  }
  write-host
  write-host
}

function New-Board {
  Param (  )
  foreach ($BoardPos in (0..63)) {
    $Row = [System.Math]::Truncate($BoardPos / 8)
    $Col = $BoardPos % 8
    if ($BoardPos -eq 27 -or $BoardPos -eq 36 ) {$Color = 'White';$Value = 'O'}
    elseif ($BoardPos -eq 28 -or $BoardPos -eq 35 ) {$Color = 'Red';$Value = 'O'}
    else {$Color = 'DarkGray';$Value = '-'}
    $BoardProp = [ordered]@{
      Position = $BoardPos
      Row      = $Row
      Col      = $Col
      FDiag    = $row + $col
      RDiag    = 7 + $col - $row
      Color    = $Color
      Value    = $Value
    }
    New-Object -TypeName psobject -Property $BoardProp
  }
}  

function Get-BoardChanges {
  Param (
    $Turn,
    $Board,
    $Color
  )
  if ($Color -eq 'Red') {$OpColor = 'White'}
  if ($Color -eq 'White') {$OpColor = 'Red'}
  $LinesProp = [ordered]@{
    N  = $Board | Where-Object {$_.Col -eq $Turn.Col -and $_.Position -lt $Turn.Position} | Sort-Object -Property Position -Descending
    NE = $Board | Where-Object {$_.FDiag -eq $Turn.FDiag -and $_.Position -lt $Turn.Position} | Sort-Object -Property Position -Descending
    E  = $Board | Where-Object {$_.Row -eq $Turn.Row -and $_.Position -gt $Turn.Position} | Sort-Object -Property Position 
    SE = $Board | Where-Object {$_.RDiag -eq $Turn.RDiag -and $_.Position -gt $Turn.Position} | Sort-Object -Property Position 
    S  = $Board | Where-Object {$_.Col -eq $Turn.Col -and $_.Position -gt $Turn.Position} | Sort-Object -Property Position 
    SW = $Board | Where-Object {$_.FDiag -eq $Turn.FDiag -and $_.Position -gt $Turn.Position} | Sort-Object -Property Position 
    W  = $Board | Where-Object {$_.Row -eq $Turn.Row -and $_.Position -lt $Turn.Position} | Sort-Object -Property Position -Descending
    NW = $Board | Where-Object {$_.RDiag -eq $Turn.RDiag -and $_.Position -lt $Turn.Position} | Sort-Object -Property Position -Descending
  }
  $AllGameLines = New-Object -TypeName psobject -Property $LinesProp
  $Changes = @()
  foreach ($GameLines in $AllGameLines.N, $AllGameLines.NE, $AllGameLines.E, $AllGameLines.SE,
                         $AllGameLines.S, $AllGameLines.SW, $AllGameLines.W,$AllGameLines.NW) {
    if ($GameLines -and $GameLines[0].Color -eq $OpColor) {
      $EndOfChange = $GameLines.Color.IndexOf($Color)
      if ($EndOfChange -gt 0) {
        $LastIndex = $EndOfChange - 1
        $ValidLine = $true
        foreach ($Index in (0..$LastIndex)) {
          if ($GameLines[$Index].Color -ne $OpColor) {$ValidLine = $false;break } 
        }       
        if ($ValidLine -eq $true) {$Changes = $Changes + $GameLines[0..$LastIndex].Position + $Turn.Position}
      }
    }
  }
  $ChangeProp = @{
    ChangePositions = $Changes
    Color = $Color
  }
  New-Object -TypeName psobject -Property $ChangeProp
} #function


function Read-Turn {
  Param ( 
    $Board,
    $Color
  )
  $BoardChanges = @()
  do {
    do {
      Write-Host -ForegroundColor $Color -NoNewline 'Enter the Coordindates of your next move: '
      $NextMove = (Read-Host).ToUpper()
      $NextMove = $NextMove -replace '[ ,./\-]','' 
    } until ($NextMove -cmatch '^[A-H][1-8]$' -or $NextMove -cmatch '^[1-8][A-H]$') 
    # 65 - 72 are A - H (Ascii)
    $MoveCol = (($NextMove -replace '[A-Z]','') -as [int]) -1
    $MoveRow = (([byte][char]($NextMove -replace '[0-9]','')) -as [int]) -65
    $MoveProps = [ordered]@{
      Position   = ($MoveRow * 8) + $MoveCol
      Col   = $MoveCol
      Row   = $MoveRow
      FDiag    = $MoveRow + $MoveCol
      RDiag    = 7 + $MoveCol - $MoveRow
      Color = $Color
    }
    $MoveObj = New-Object -TypeName psobject -Property $MoveProps
    if ($Board[$MoveObj.Position].Value -eq '-') {
      $BoardChanges = Get-BoardChanges -Turn $MoveObj -Board $Board -Color $Color
    }
    if ($BoardChanges.ChangePositions -eq $null) {Write-Warning "The move is not possible";start-sleep -Seconds 2}
    else {
      foreach ($ChangePosition in $BoardChanges.ChangePositions) {
        $Board[$ChangePosition].Value = 'O'
        $Board[$ChangePosition].Color = $BoardChanges.Color
      }
    }
  } until ($BoardChanges.ChangePositions -ne $null) 
  return $MoveObj
}



######   MainCode
$BoardObj = New-Board

$Color = 'Red'
do {
  Draw-Board -Board $BoardObj
  $TurnInfo = Read-Turn -Board $BoardObj -Color $Color
  if ($Color -eq 'Red') {$Color = 'White'}
  elseif ($Color -eq 'White') {$Color = 'Red'  }
} Until ($GameState.finised -eq $true)