<#
.SYNOPSIS
  Short description
.DESCRIPTION
  Long description
.EXAMPLE
  PS C:\> <example usage>
  Explanation of what the example does
.INPUTS
  Inputs (if any)
.OUTPUTS
  Output (if any)
.NOTES
  General notes
#>
[CmdletBinding()]
Param()

### functions

function New-TTTBoard {
  Param()
  $BoardArray = @('1','2','3','4','5','6','7','8','9')
  return $BoardArray
}
function Show-Board {
  Param ([string[]]$Board,[string]$Border='  ')

  Clear-Host
  $EntryColors = @('White','White','White','White','White','White','White','White','White')
  $ShowSqr = @(' ',' ',' ',' ',' ',' ',' ',' ',' ')
  $GridColor = "white"
  $XColor = "Red"
  $OColor = "Yellow"
  $TitleCol = "Green"
  foreach ($Pos in (0..8)){
    if ($Board[$Pos] -eq "X") { $EntryColors[$Pos] = $XColor}
    if ($Board[$Pos] -eq "O") { $EntryColors[$Pos] = $OColor}
    if ($Board[$Pos] -notmatch "[XO]") { $EntryColors[$Pos] = "darkgray"}
    if ($Board[$Pos] -match "[XO]") {$ShowSqr[$Pos] = $Board[$Pos]}
    else {$ShowSqr[$Pos] = $Pos + 1}
  }
  Write-Host -ForegroundColor $TitleCol "`n${Border}Tic Tac Toe`n"
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
} # END function showboard
function MiniMiniMax {
  Param ([string[]]$Board,[string]$Player)
  $TempBoard = $Board.psobject.copy()
  $Empties = Find-BlankCells $TempBoard
  foreach ($Index in $Empties.BlankIndexes) {
    Submit-Move -Board $TempBoard -MoveIndex $Index -Player $Player
    $WinFound = Find-Winner -Board $TempBoard -Player $Player
    if ($WinFound.Winner -eq $Player) {return $Index}
    else {}
  }
}
##function Find-BestMoveMiniMax {
##  Param ([string[]]$Board,[string]$Player,[int]$Level=1)
##  $BoardTemp = $Board.psobject.copy()
##  $WinX = Find-Winner -Board $BoardTemp -Player 'X'
##  $WinO = Find-Winner -Board $BoardTemp -Player 'O'
##  $CheckDraw = Find-Draw -Board $BoardTemp
##  if ($WinX.Winner -eq 'X' -and $Player -eq 'X') {return 10}
##  if ($WinO.Winner -eq 'O' -and $Player -eq 'X') {return -10}
##  if ($CheckDraw -eq $true) {return 0}
##  $EmptyIndexes =  (Find-BlankCells -Board $BoardTemp).BlankIndexes 
##  if ($Level % 2) {
##    $MaxEval = -999
##    foreach ($EmptyIndex in $EmptyIndexes) {
##      $BoardTemp = Submit-Move -Board $BoardTemp -Player 'X' -MoveIndex $EmptyIndex
##      $Eval = Find-BestMoveMiniMax -Board $BoardTemp -Player 'X' -Level ($Level + 1)
##      $MaxEval = if ($MaxEval -gt $Eval) {$MaxEval} else {$Eval}
##    }
##    return $MaxEval
##  }
##  else {
##    $MinEval = 999
##    foreach ($EmptyIndex in $EmptyIndexes) {
##      $BoardTemp = Submit-Move -Board $BoardTemp -Player 'O' -MoveIndex $EmptyIndex
##      $Eval = Find-BestMoveMiniMax -Board $BoardTemp -Player 'O' -Level ($Level + 1) 
##      $MinEval = if ($MinEval -lt $Eval) {$MinEval} else {$Eval}
##    }
##    return $MinEval
##  }
##} # END function Find-BestMoveMiniMax
function Get-NextMove {
  Param ([string[]]$Board, [string]$Player, [switch]$ComputersTurn)
  if ($ComputersTurn) {
    $Blanks = Find-BlankCells -Board $Board
    if ($Blanks.NumberOfBlanks -eq 9) {
      $FirstMove =  (0,2,6,8) | Get-Random 
      return $FirstMove
    }
    else {return $Blanks.BlankIndexes[0] # This should be the minimax logic}
  }
  else {
    do {
      $GoodChoice = $true
      $TurnChoice = Read-Host -Prompt "Please enter a number position to place your `'$Player`'"
      try {
        $ErrorActionPreference = 'stop'
        $TurnIndex = ($TurnChoice -as [int]) - 1
        if ($TurnChoice -notmatch '[1-9]' -or $Board[$TurnIndex] -match '[XO]') {throw}
      }
      catch {$GoodChoice = $false}
    } until ($GoodChoice)
  }
  return $TurnIndex
} # END function Get-NextMove
function Submit-Move {
  Param ([string[]]$Board,[string]$Player,[int]$MoveIndex)
  if ($Board[$MoveIndex] -notmatch '[XO]') {
    $Board[$MoveIndex] = $Player
    return $Board
  }
} # END function Submit-Move
function Revoke-Move {
  Param ([string[]]$Board,[int]$MoveIndex)
  if ($Board[$MoveIndex] -match '[XO]') {
    $Board[$MoveIndex] = $Player
    return $Board
  }
} # END function Submit-Move

function Find-BlankCells {
  Param ([string[]]$Board)
  $BlankIndexes = @()
  $BlankCount = 0
  foreach ($Pos in (0..8)) {
    if ($Board[$Pos] -notmatch '[XO]')  {
      $BlankCount = $BlankCount + 1
      $BlankIndexes += $Pos
    }
  }
  return [PSCustomObject]@{NumberOfBlanks=$BlankCount;BlankIndexes=$BlankIndexes}
} # END function findblankcells
function Find-Winner {
  Param ([string[]]$Board,[string]$Player)
  $WinLines = @(
    @(0,1,2,0),@(3,4,5,1),@(6,7,8,2),
    @(0,3,6,3),@(1,4,7,4),@(2,5,8,5),
    @(0,4,8,6),@(2,4,6,7)
  )
  $FoundWinner = $false
  foreach ($WinLine in $WinLines) {
    if ($Board[$WinLine[0]] -eq $Player -and $Board[$WinLine[1]] -eq $Player -and $Board[$WinLine[2]] -eq $Player) {
      return [PSCustomObject]@{
        Winner = $Player
        WinningLine = $WinLine[3]
      }
      $FoundWinner = $true
      break
    }
  }
  if ($FoundWinner -eq $false) {
    return [PSCustomObject]@{
      Winner = 'NoWinner'
      WinningLine = 99
    }
  }
} # END function FindWinner
function Find-Draw {
  Param ([string[]]$Board)
  $WinX = Find-Winner -Board $Board -Player 'X'
  $WinO = Find-Winner -Board $Board -Player 'O'
  $Blanks = Find-BlankCells -Board $Board
  if ($WinX.Winner -eq 'NoWinner' -and $WinO.Winner -eq 'NoWinner' -and $Blanks.NumberOfBlanks -eq 0) {return $true  }
  else {return $false}
} # END function FindDraw

### MainCode
$MainBoard = New-TTTBoard
$PlayerToken = ('O','X') | Get-Random
$Opponent = 'X'
Show-Board -Board $MainBoard
do {
  $Opponent = $PlayerToken
  $PlayerToken = ('X','O') | Where-Object {$_ -notcontains $PlayerToken}
  if ($PlayerToken -eq 'X') {$MoveIndex = Get-NextMove -Board $MainBoard -Player $PlayerToken -ComputersTurn}
  else {$MoveIndex = Get-NextMove -Board $MainBoard -Player $PlayerToken} 
  $MainBoard = Submit-Move -Board $MainBoard -Player $PlayerToken -MoveIndex $MoveIndex
  $WinStatusPlayer = Find-Winner -Board $MainBoard -Player $PlayerToken
  $WinStatusOpponent = Find-Winner -Board $MainBoard -Player $Opponent
  $DrawStatus =  Find-Draw -Board $MainBoard
  Show-Board -Board $MainBoard
  if ($PlayerToken -eq 'X') {Find-BestMoveMiniMax -Board $MainBoard -Player $PlayerToken}
} until ($DrawStatus -eq $true -or $WinStatusPlayer.Winner -eq $PlayerToken -or $WinStatusOpponent.Winner -eq $Opponent)
if ($WinStatusPlayer.Winner -ne 'NoWinner') {'Winner = ' + $WinStatusPlayer.Winner}
if ($WinStatusOpponent.Winner -ne 'NoWinner') {'Winner = ' + $WinStatusOpponent.Winner}
if ($DrawStatus) {'Game Drawn = ' + $DrawStatus}