﻿<#
.SYNOPSIS
   Tic Tac Toe game
.DESCRIPTION
   This is a standard Tic Tac Toe game, it is currently 
   run with two players hoever there are plans to add 
   some AI to this game so that you could play the 
   computer
.EXAMPLE
   Play-TTT 

   This launches the TTT game as a two player game 
.EXAMPLE
   Play-TTT  -Computer

   This launches the TTT game as a computer opponent
.Parameter Computer
   Computer is a switch parameter that tells the game 
   the computer should be the opponent.
.Notes
   Created
     By: Brent Denny
     On: 5 Jan 2018
#>
[CmdLetBinding()]
Param (
  [switch]$Computer 
)

function Draw-Board {
  Param ($Board)

  Clear-Host
  $EntryColors = @('White','White','White','White','White','White','White','White','White')
  $GridColor = "Yellow"
  $XColor = "Red"
  $OColor = "white"
  $TitleCol = "Yellow"
  foreach ($Pos in (0..8)){
    if ($Board[$pos] -eq "X"){ $EntryColors[$Pos] = $XColor}
    if ($Board[$pos] -eq "O"){ $EntryColors[$Pos] = $OColor}
  }
  $Bdr = "  "
  Write-Host -ForegroundColor $GridColor "${Bdr}Tic Tac Toe`n"
  Write-Host -NoNewline "$Bdr "
  Write-Host -ForegroundColor $EntryColors[0] -NoNewline $Board[0]
  Write-Host -ForegroundColor $GridColor -NoNewline " | "  
  write-host -ForegroundColor $EntryColors[1] -NoNewline $Board[1]
  write-host -ForegroundColor $GridColor -NoNewline " | "
  Write-Host -ForegroundColor $EntryColors[2] $Board[2]
  Write-Host -ForegroundColor $GridColor "${Bdr}---+---+---"
  Write-Host -NoNewline "$Bdr "
  Write-Host -ForegroundColor $EntryColors[3] -NoNewline $Board[3]
  Write-Host -ForegroundColor $GridColor -NoNewline " | "  
  write-host -ForegroundColor $EntryColors[4] -NoNewline $Board[4]
  write-host -ForegroundColor $GridColor -NoNewline " | "
  Write-Host -ForegroundColor $EntryColors[5] $Board[5]
  Write-Host -ForegroundColor $GridColor "${Bdr}---+---+---"
  Write-Host -NoNewline "$Bdr "
  Write-Host -ForegroundColor $EntryColors[6] -NoNewline $Board[6]
  Write-Host -ForegroundColor $GridColor -NoNewline " | "  
  write-host -ForegroundColor $EntryColors[7] -NoNewline $Board[7]
  write-host -ForegroundColor $GridColor -NoNewline " | "
  Write-Host -ForegroundColor $EntryColors[8] $Board[8]
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
  if ($Pos -in 0..8) {
    $arrayLoc = $Pos
  }
  else {
    do {
      Write-Host -ForegroundColor Yellow -NoNewline "Choose location to play $WhichTurn (1,2,3 top, 4,5,6 Middle, 7,8,9 bottom) "
      $Location = Read-Host 
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
    $WinProp = @{
      Winner = $Winner
      WhichWin = $WhichWin
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


<#
   NEED TO RETHINK
   1. move to win
   2. move to counter
   3. move to grow line
   4. move to start
#>  


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
  if ($RCD.Diag[0] -match "XX\s") {$Threat=$true; $ThreatPos += 8}
  if ($RCD.Diag[0] -match "X\sX") {$Threat=$true; $ThreatPos += 4}
  if ($RCD.Diag[0] -match "\sXX") {$Threat=$true; $ThreatPos += 0}

  if ($RCD.Diag[1] -match "XX\s") {$Threat=$true; $ThreatPos += 6}
  if ($RCD.Diag[1] -match "X\sX") {$Threat=$true; $ThreatPos += 4}
  if ($RCD.Diag[1] -match "\sXX") {$Threat=$true; $ThreatPos += 2}

  if ($Threat -eq $true) {$ThreatPos = $ThreatPos | Select-Object -Unique | Get-Random}
  else {
    $RowCount = 0; $ColCount = 0; $DiagCount = 0; $SqrCount = 0
    foreach ($Row in $RCD.Row) {
      if ($Row -match "OO\s") {$Offence = $true; $ThreatPos += ($RowCount*3)+2}
      if ($Row -match "O\sO") {$Offence = $true; $ThreatPos += ($RowCount*3)+1}
      if ($Row -match "\sOO") {$Offence = $true; $ThreatPos += ($RowCount*3)}
      $RowCount++
    }
    foreach ($Col in $RCD.Col) {
      if ($Col -match "OO\s") {$Offence = $true; $ThreatPos += $ColCount+6}
      if ($Col -match "O\sO") {$Offence = $true; $ThreatPos += $ColCount+3}
      if ($Col -match "\sOO") {$Offence = $true; $ThreatPos += $ColCount}
      $ColCount++
    }
    if ($RCD.Diag[0] -match "OO\s") {$Offence = $true; $ThreatPos += 8}
    if ($RCD.Diag[0] -match "O\sO") {$Offence = $true; $ThreatPos += 4}
    if ($RCD.Diag[0] -match "\sOO") {$Offence = $true; $ThreatPos += 0}
    
    if ($RCD.Diag[1] -match "OO\s") {$Offence = $true; $ThreatPos += 6}
    if ($RCD.Diag[1] -match "O\sO") {$Offence = $true; $ThreatPos += 4}
    if ($RCD.Diag[1] -match "\sOO") {$Offence = $true; $ThreatPos += 2}
  }
  foreach ($Sqr in $Board) {
    if ($Sqr -eq " ") {$BlankPos += $SqrCount}
    $SqrCount++
  }
  If ($Offence -eq $false) { $Offence = $true; $ThreatPos = $BlankPos | Get-Random } 
  $ThreatProp = @{
    Threat = $Threat
    Pos = $ThreatPos
    Blanks = $BlankPos
    Offence = $Offence
  }
  $PlacementObj = New-Object -TypeName psobject -Property $ThreatProp
  return $PlacementObj

}

##################################
#  MAIN CODE


$MainBoard = @(' ',' ',' ',' ',' ',' ',' ',' ',' ')
Draw-Board -Board $MainBoard
$Turn = @("X","O") | Get-Random
do {
  if ($Computer -eq $true -and $Turn -eq 'O') {
    $RowColDiag = Get-RowColDiag -Board $MainBoard
    $Move = Get-BestOPos -Board $MainBoard -RCD $RowColDiag
    if ($Move.Threat -eq $true) {
      $Pos = $Move.Pos | Get-Random
      $MainBoard = Pick-Location -Board $MainBoard -WhichTurn $Turn -Pos $Pos
    }
    else {
      #temp fix
      $MovePos = $Move.Pos
      Start-Sleep -Seconds 1
      $MainBoard = Pick-Location -Board $MainBoard -WhichTurn $Turn -Pos $MovePos
    }
  }
  else {
    $MainBoard = Pick-Location -Board $MainBoard -WhichTurn $Turn
  }
  Draw-Board -Board $MainBoard
  $PossWin = Check-Winner -Board $MainBoard
  if ($Turn -eq "X" ) {$Turn = "O"}
  elseif ($Turn -eq "O" ) {$Turn = "X"} 
} until ($MainBoard -notcontains " " -or $PossWin.Winner -eq $true)
if ($PossWin.Winner -eq $true) {
  Write-Host -ForegroundColor Green "The Winner is $($PossWin.WhichWin)"
}