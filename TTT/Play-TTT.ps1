<#
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
   4. Randomly select a blank Position
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
  Param ($Board,$Border)

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
  Write-Host -ForegroundColor $GridColor "`n${Border}Tic Tac Toe`n"
  Write-Host -NoNewline "$Border "
  Write-Host -ForegroundColor $EntryColors[0] -NoNewline $Board[0]
  Write-Host -ForegroundColor $GridColor -NoNewline " | "  
  write-host -ForegroundColor $EntryColors[1] -NoNewline $Board[1]
  write-host -ForegroundColor $GridColor -NoNewline " | "
  Write-Host -ForegroundColor $EntryColors[2] $Board[2]
  Write-Host -ForegroundColor $GridColor "${Border}---+---+---"
  Write-Host -NoNewline "$Border "
  Write-Host -ForegroundColor $EntryColors[3] -NoNewline $Board[3]
  Write-Host -ForegroundColor $GridColor -NoNewline " | "  
  write-host -ForegroundColor $EntryColors[4] -NoNewline $Board[4]
  write-host -ForegroundColor $GridColor -NoNewline " | "
  Write-Host -ForegroundColor $EntryColors[5] $Board[5]
  Write-Host -ForegroundColor $GridColor "${Border}---+---+---"
  Write-Host -NoNewline "$Border "
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
  $OffencePos = @(); $Offence =$false
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
  if ($Offence -eq $false -and $Threat -eq $false -and $Build -eq $true) {$BuildPos | Get-Random} 
  if ($Offence -eq $false -and $Threat -eq $false) { $Offence = $true; $ThreatPos = $BlankPos | Get-Random } 
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
$MainBoard = @(' ',' ',' ',' ',' ',' ',' ',' ',' ')
$Border = "  "
Draw-Board -Board $MainBoard -Border $Border
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
      $MovePos = $Move.Pos
      Start-Sleep -Milliseconds 300
      $MainBoard = Pick-Location -Board $MainBoard -WhichTurn $Turn -Pos $MovePos
    }
  }
  else {
    $MainBoard = Pick-Location -Board $MainBoard -WhichTurn $Turn
  }
  Draw-Board -Board $MainBoard -Border $Border
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
Write-Host "`n`n`n"