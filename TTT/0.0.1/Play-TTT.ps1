﻿<#
.SYNOPSIS
   Tic Tac Toe game
.DESCRIPTION
   This is a standard Tic Tac Toe game, it is currently 
   run with two players unless you issue the -Computer
   Parameter which instructs the script to turn on the 
   Computer opponent logic.
   Logic Process:
   1. Seek to win with this turn
   2. Block opponent with this turn
   3. Build a line with this turn
   4. Block future attacks by going to the centre
   5. Randomly select a blank position (With a little intelligence avoiding double win lines by opponent)
.EXAMPLE
   Play-TTT 

   This launches the TTT game as a two player game 
.EXAMPLE
   Play-TTT  -People

   This launches the TTT game as a person opponent
.Parameter Person
   Person is a switch parameter that tells the game 
   a real person should be the opponent.
.Notes
   Created
     By: Brent Denny
     On: 5 Jan 2018
#>
[CmdLetBinding()]
Param (
  [switch]$Person 
)

function Draw-Board {
  Param ($Board,$Border)

  Clear-Host
  $EntryColors = @('White','White','White','White','White','White','White','White','White')
  $ShowSqr = @(' ',' ',' ',' ',' ',' ',' ',' ',' ')
  $GridColor = "Yellow"
  $XColor = "Red"
  $OColor = "white"
  $TitleCol = "Yellow"
  foreach ($Pos in (0..8)){
    if ($Board[$Pos] -eq "X") { $EntryColors[$Pos] = $XColor}
    if ($Board[$Pos] -eq "O") { $EntryColors[$Pos] = $OColor}
    if ($Board[$Pos] -eq " ") { $EntryColors[$Pos] = "darkgray"}
    if ($Board[$Pos] -match "[XO]") {$ShowSqr[$Pos] = $Board[$Pos]}
    else {$ShowSqr[$Pos] = $Pos + 1}
  }
  Write-Host -ForegroundColor $GridColor "`n${Border}Tic Tac Toe`n"
  Write-Host -NoNewline "$Border "
  Write-Host -ForegroundColor $EntryColors[0] -NoNewline $ShowSqr[0]
  Write-Host -ForegroundColor $GridColor -NoNewline " | "  
  write-host -ForegroundColor $EntryColors[1] -NoNewline $ShowSqr[1]
  write-host -ForegroundColor $GridColor -NoNewline " | "
  Write-Host -ForegroundColor $EntryColors[2] $ShowSqr[2]
  Write-Host -ForegroundColor $GridColor "${Border}---+---+---"
  Write-Host -NoNewline "$Border "
  Write-Host -ForegroundColor $EntryColors[3] -NoNewline $ShowSqr[3]
  Write-Host -ForegroundColor $GridColor -NoNewline " | "  
  write-host -ForegroundColor $EntryColors[4] -NoNewline $ShowSqr[4]
  write-host -ForegroundColor $GridColor -NoNewline " | "
  Write-Host -ForegroundColor $EntryColors[5] $ShowSqr[5]
  Write-Host -ForegroundColor $GridColor "${Border}---+---+---"
  Write-Host -NoNewline "$Border "
  Write-Host -ForegroundColor $EntryColors[6] -NoNewline $ShowSqr[6]
  Write-Host -ForegroundColor $GridColor -NoNewline " | "  
  write-host -ForegroundColor $EntryColors[7] -NoNewline $ShowSqr[7]
  write-host -ForegroundColor $GridColor -NoNewline " | "
  Write-Host -ForegroundColor $EntryColors[8] $ShowSqr[8]
  Write-Host 
}

function Get-RowColDiag {
  Param (
    $Board
  )
  $Col = @(); $Row = @(); $Diag = @()
  foreach ($Num in (0..2)) {
    $Col += $Board[(0+$Num),(3+$Num),(6+$Num)] -join ''
    $Row += $Board[(0+(3*$Num)),(1+(3*$Num)),(2+(3*$Num))] -join ''
  }
  $Diag += $Board[0,4,8] -join ''
  $Diag += $Board[2,4,6] -join ''
  $props = @{
    Row = $Row
    Col = $Col
    Diag = $Diag
  }
  $RCDObj = new-object -TypeName psobject -Property $props
  return $RCDObj
  # row -match "XX\s|X\sX|\sXX" this is to test the danger lines
}

function Pick-Location {
  Param (
    $Board,
    $WhichTurn,
    $Pos = 99
  )
  if ($WhichTurn -eq "X") {$Color = "Red"}
  else {$Color = "White"}
  $NumberOfBlanks = ($Board | Where-Object {$_ -eq ' '} | Measure-Object).Count
  if ($NumberOfBlanks -eq 1 -and $WhichTurn -eq "X") {$arrayLoc = $Board.indexof(' '); Start-Sleep -Seconds 1 }
  elseif ($Pos -in 0..8) {$arrayLoc = $Pos}
  else {
    do {
      Write-Host -ForegroundColor Yellow -NoNewline "Choose location to play "
      Write-Host -ForegroundColor $Color -NoNewline $WhichTurn
      Write-Host -ForegroundColor Yellow -NoNewline ": "
      if ($Host.Name -eq 'ConsoleHost') {$Location = ($Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')).Character -as [string]} 
      else {$Location = Read-Host}
      $Location = $Location -replace "[^1-9]",''
      if ($Location -match '[^1-9]') {continue}
      $arrayLoc = $Location - 1
    } until (1..9 -contains $Location -and $Board[$arrayLoc] -eq " ") 
  }
  $Board[$arrayLoc] = $WhichTurn
  return $Board
}

function Check-Winner {
  Param (
    $Board
  )
  $Winner = $false
  $WhichWin = ' '
  foreach ($Col in (0..2)) {
    if ($Board[($col*3) + 0] -eq $Board[($col*3) + 1] -and $Board[($col*3) + 0] -eq $Board[($col*3) + 2] -and $Board[($col*3) + 0] -match "[XO]") {
      $Winner = $true
      $WhichWin = $Board[($col*3) + 0]
    }
    if ($Board[$col + 0] -eq $Board[$col + 3] -and $Board[$col + 0] -eq $Board[$col + 6] -and $Board[$col + 0] -match "[XO]" ) {
      $Winner = $true
      $WhichWin = $Board[$col + 0]
    }
  }
  if ($Board[0] -eq $Board[4] -and $Board[0] -eq $Board[8]  -and $Board[0] -match "[XO]" ) {
    $Winner = $true
    $WhichWin = $Board[0]
  }
  if ($Board[2] -eq $Board[4] -and $Board[2] -eq $Board[6] -and $Board[2] -match "[XO]" ) {
    $Winner = $true
    $WhichWin = $Board[2]
  }
  If ($Winner -eq $true) {
    if ($WhichWin -eq "X") {$WinnerColor = "Red"}
    if ($WhichWin -eq "O") {$WinnerColor = "White"}
    $WinProp = @{
      Winner = $Winner
      WhichWin = $WhichWin
      WinnerCol = $WinnerColor 
    }
    $WinObj = New-Object -TypeName psobject -Property $WinProp
    return $WinObj
  }
  else {
    $WinProp = @{
      Winner = $Winner
      WhichWin = $WhichWin
    }
    $WinObj = New-Object -TypeName psobject -Property $WinProp
    return $WinObj  
  }
}

function Get-BestOPos {
  param ( 
    $Board,
    $RCD
  )
  $Threat = $false; $ThreatPos = @(); $RowCount = 0; $ColCount = 0
  $DiagCount = 0; $SqrCount = 0; $BlankPos = @(); $Offence = $false
  foreach ($Row in $RCD.Row) {
    if ($Row -match "XX\s") {$Threat=$true; $ThreatPos += ($RowCount*3)+2}
    if ($Row -match "X\sX") {$Threat=$true; $ThreatPos += ($RowCount*3)+1}
    if ($Row -match "\sXX") {$Threat=$true; $ThreatPos += ($RowCount*3)}
    $RowCount++
  }
  foreach ($Col in $RCD.Col) {
    if ($Col -match "XX\s") {$Threat=$true; $ThreatPos += $ColCount+6}
    if ($Col -match "X\sX") {$Threat=$true; $ThreatPos += $ColCount+3}
    if ($Col -match "\sXX") {$Threat=$true; $ThreatPos += $ColCount}
    $ColCount++
  }
  foreach ($Diag in $RCD.Diag) {
    if ($Diag -match "XX\s") {$Offence = $true; $ThreatPos += 8 - (2 * $DiagCount)}
    if ($Diag -match "X\sX") {$Offence = $true; $ThreatPos += 4}
    if ($Diag -match "\sXX") {$Offence = $true; $ThreatPos += 0 + (2 * $DiagCount)}
    $DiagCount++
  }



  if ($RCD.Diag[0] -match "XX\s") {$Threat=$true; $ThreatPos += 8}
  if ($RCD.Diag[0] -match "X\sX") {$Threat=$true; $ThreatPos += 4}
  if ($RCD.Diag[0] -match "\sXX") {$Threat=$true; $ThreatPos += 0}

  if ($RCD.Diag[1] -match "XX\s") {$Threat=$true; $ThreatPos += 6}
  if ($RCD.Diag[1] -match "X\sX") {$Threat=$true; $ThreatPos += 4}
  if ($RCD.Diag[1] -match "\sXX") {$Threat=$true; $ThreatPos += 2}


  $RowCount = 0; $ColCount = 0; $DiagCount = 0; $SqrCount = 0; 
  $OffencePos = @(); $Offence =$false;$BuildPos = @();$build = $false
  foreach ($Row in $RCD.Row) {
    if ($Row -match "OO\s") {$Offence = $true; $OffencePos += ($RowCount*3)+2}
    if ($Row -match "O\s\s") {$Build = $true; $BuildPos += ($RowCount*3)+2; $BuildPos += ($RowCount*3)+1}
    if ($Row -match "O\sO") {$Offence = $true; $OffencePos += ($RowCount*3)+1}
    if ($Row -match "\s\sO") {$Build = $true; $BuildPos += ($RowCount*3)+1; $BuildPos += ($RowCount*3)}
    if ($Row -match "\sOO") {$Offence = $true; $OffencePos += ($RowCount*3)}
    if ($Row -match "\sO\s") {$Build = $true; $BuildPos += ($RowCount*3); $BuildPos += ($RowCount*3)+2}
    $RowCount++
  }
  foreach ($Col in $RCD.Col) {
    if ($Col -match "OO\s") {$Offence = $true; $OffencePos += $ColCount+6}
    if ($Col -match "O\s\s") {$Build = $true; $BuildPos += $ColCount+6; $BuildPos += $ColCount+3}
    if ($Col -match "O\sO") {$Offence = $true; $OffencePos += $ColCount+3}
    if ($Col -match "\s\sO") {$Build = $true; $BuildPos += $ColCount+3; $BuildPos += $ColCount}
    if ($Col -match "\sOO") {$Offence = $true; $OffencePos += $ColCount}
    if ($Col -match "\sO\s") {$Build = $true; $BuildPos += $ColCount; $BuildPos += $ColCount+6}
    $ColCount++
  }
  foreach ($Diag in $RCD.Diag) {
    if ($Diag -match "OO\s") {$Offence = $true; $OffencePos += 8 - (2 * $DiagCount)}
    if ($Diag -match "O\s\s") {$Build = $true; $BuildPos += 8 - (2 * $DiagCount); $BuildPos += $BuildPos += 4}
    if ($Diag -match "O\sO") {$Offence = $true; $OffencePos += 4}
    if ($Diag -match "\s\sO") {$Build = $true; $BuildPos += 4; $BuildPos += 0 + (2 * $DiagCount)}
    if ($Diag -match "\sOO") {$Offence = $true; $OffencePos += 0 + (2 * $DiagCount)}
    if ($Diag -match "\sO\s") {$Build = $true; $BuildPos += 0 + (2 * $DiagCount); $BuildPos += 8 - (2 * $DiagCount)}
    $DiagCount++
  }
  
  foreach ($Sqr in $Board) {
    if ($Sqr -eq " ") {$BlankPos += $SqrCount}
    $SqrCount++
  }
  if ($Threat -eq $true) {$ThreatPos = $ThreatPos | Select-Object -Unique | Get-Random}
  if ($Offence -eq $true) {$ThreatPos = $OffencePos | Select-Object -Unique | Get-Random}
  if ($Offence -eq $false -and $Threat -eq $false -and $Build -eq $true) {
    if ($BuildPos -contains 4) {$ThreatPos = 4}
    elseif ($BlankPos.count -eq 7 -and (($Board[0] -eq "X" -and $board[8] -eq "O" ) -or ($Board[8] -eq "X" -and $board[0] -eq "O" ) -or 
           ($Board[2] -eq "X" -and $board[6] -eq "O" ) -or ($Board[6] -eq "X" -and $board[2] -eq "O" ))) {$ThreatPos = 4}
    elseif ($BlankPos.count -eq 7 -and (($Board[1] -eq "X" -and $board[7] -eq "O" ) -or ($Board[7] -eq "X" -and $board[1] -eq "O" ) -or 
           ($Board[3] -eq "X" -and $board[5] -eq "O" ) -or ($Board[5] -eq "X" -and $board[3] -eq "O" ))){$ThreatPos = 4}
    elseif ($BlankPos.count -eq 6 -and ($Board[0] -eq "X" -and $Board[8] -eq "X") -or ($Board[2] -eq "X" -and $Board[6] -eq "X" )) {
      $ThreatPos = @(1,3,5,7) | get-random
    }
    elseif ($BlankPos.count -eq 6 -and ($Board[0] -eq "X" -and $Board[4] -eq "X")) {$ThreatPos = @(2,6) | get-random}
    elseif ($BlankPos.count -eq 6 -and ($Board[2] -eq "X" -and $Board[4] -eq "X")) {$ThreatPos = @(0,8) | get-random}
    elseif ($BlankPos.count -eq 6 -and ($Board[6] -eq "X" -and $Board[4] -eq "X")) {$ThreatPos = @(0,8) | get-random}
    elseif ($BlankPos.count -eq 6 -and ($Board[8] -eq "X" -and $Board[4] -eq "X")) {$ThreatPos = @(2,6) | get-random}
    else {$ThreatPos = $BuildPos | Get-Random}
  } 
  if ($Offence -eq $false -and $Threat -eq $false -and $Build -eq $false) { 
    if ($BlankPos.Count -eq 8 -and $Board[4] -eq "X"){
      $Offence = $true
      $ThreatPos = @(0,2,6,8) | get-random
    }
    elseif ($BlankPos.Count -eq 8 -and ($Board[0] -eq "X" -or $Board[2] -eq "X" -or $Board[6] -eq "X" -or $Board[8] -eq "X" )) {
      $Offence = $true
      if ($Board[4] -eq ' ') {$ThreatPos = 4}
    }
    elseif ($BlankPos.Count -eq 8 -and ($Board[1] -eq "X" -or $Board[3] -eq "X" -or $Board[5] -eq "X" -or $Board[7] -eq "X" )) {
      $Offence = $true
      if ($Board[4] -eq ' ') {$ThreatPos = 4}
    }
    else {
      $Offence = $true
      $ThreatPos = $BlankPos | Get-Random 
    }
  } 
  $ThreatProp = @{
    Threat = $Threat
    Offence = $Offence
    Build = $Build
    Pos = $ThreatPos
    Blanks = $BlankPos
  }
  $PlacementObj = New-Object -TypeName psobject -Property $ThreatProp
  return $PlacementObj
}

##################################
#  MAIN CODE
do {
  $MainBoard = @(' ',' ',' ',' ',' ',' ',' ',' ',' ')
  $Border = "  "
  Draw-Board -Board $MainBoard.psobject.Copy() -Border $Border
  $Turn = @("X","O") | Get-Random
  do {
    if ($Person -eq $false -and $Turn -eq 'O') {
      $RowColDiag = Get-RowColDiag -Board $MainBoard
      $Move = Get-BestOPos -Board $MainBoard -RCD $RowColDiag
      if ($Move.Threat -eq $true) {
        $Pos = $Move.Pos | Get-Random
        $MainBoard = Pick-Location -Board $MainBoard -WhichTurn $Turn -Pos $Pos
      }
      else {
        $MovePos = $Move.Pos
        Start-Sleep -Milliseconds 300
        $MainBoard = Pick-Location -Board $MainBoard -WhichTurn $Turn -Pos $MovePos
      }
    }
    else {
      $MainBoard = Pick-Location -Board $MainBoard -WhichTurn $Turn
    }
    Draw-Board -Board $MainBoard.psobject.Copy() -Border $Border
    $PossWin = Check-Winner -Board $MainBoard
    if ($Turn -eq "X" ) {$Turn = "O"}
    elseif ($Turn -eq "O" ) {$Turn = "X"} 
  } until ($MainBoard -notcontains " " -or $PossWin.Winner -eq $true)
  if ($PossWin.Winner -eq $true) {
    Write-Host -NoNewline -ForegroundColor Green "${Border}The Winner is "
    Write-Host -ForegroundColor $PossWin.WinnerCol $($PossWin.WhichWin)
  }
  else {
    Write-Host -ForegroundColor Yellow "${Border}This game is a TIED GAME"
  }
  Write-Host "`n`n"
  Write-Host -ForegroundColor Green -NoNewline "Would you like to play again "
  $Again = Read-Host
} While ($Again -Like "y*")