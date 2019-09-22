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

function Find-MiniMiniMax {
  Param ([string[]]$Board,[string]$Player,[switch]$Min)
  $Opponent = ('O','X') | Where-Object {$_ -ne $Player}
  $Empties = Find-BlankCells $Board
  if ($Min -eq $false) {
    foreach ($Index in $Empties.BlankIndexes) {
      $Board[$Index] = $Player
      $WinFound = Find-Winner -Board $Board -Player $Player
      if ($WinFound.Winner -eq $Player) {return $Index}
      else {$Board[$Index] = (($Index + 1) -as [string])}
    }
    foreach ($Index in $Empties.BlankIndexes) {
      $Board[$Index] = $Opponent
      $WinFound = Find-Winner -Board $Board -Player $Opponent
      if ($WinFound.Winner -eq $Opponent) {return $Index}
      else {$Board[$Index] = (($Index + 1) -as [string])}
    }
  }
  else {  }
  if ($Empties.BlankIndexes -contains 4) {return 4}
  elseif (Find-BuildPosition -Board $Board -Player $Player) {
    $Index = Find-BuildPosition -Board $Board -Player $Player
    return $Index
  }
  else {$RandomIndex = $Empties.BlankIndexes | Get-Random}
  return $RandomIndex
}

function Find-DualWin {
  Param ($Board,$Player)
  $WinningLines = @(
    @(0,1,2),@(3,4,5),@(6,7,8),
    @(0,3,6),@(1,4,7),@(2,5,8),
    @(0,4,8),@(2,4,6)
  )
  $NextPlayWins = 0
  foreach ($Line in $WinningLines) {
    $PotentialWin = ($Board[$line] | Sort-Object ) -join ''
    $Regex = '^[1-9]'+$Player+$Player+'$'
    if ($PotentialWin -match $Regex) {$NextPlayWins = $NextPlayWins + 1}
  }
  if ($NextPlayWins -ge 2) {return $true}
  else {return $false}
}

function Find-DiagWin {
  Param ($Board,$Player)
  $WinningLines = @(
    @(0,1,2),@(3,4,5),@(6,7,8),
    @(0,3,6),@(1,4,7),@(2,5,8),
    @(0,4,8),@(2,4,6)
  )
  $Opponent = ('O','X') | Where-Object {$_ -ne $Player}
  $NextPlayWins = 0
  foreach ($Line in $WinningLines) {
    $PotentialWin = ($Board[$line] | Sort-Object ) -join ''
    $Regex = '^'+$Player+$Opponent+$Player+'$'
    if ($PotentialWin -match $Regex) {$NextPlayWins = $NextPlayWins + 1}
  }
  if ($NextPlayWins -eq 1) {return $true}
  else {return $false}
}

function Find-BuildPosition {
  Param ($Board, $Player)
  $WinningLines = @(
    @(0,1,2),@(3,4,5),@(6,7,8),
    @(0,3,6),@(1,4,7),@(2,5,8),
    @(0,4,8),@(2,4,6)
  )
  $BuildPos = @()
  foreach ($Line in $WinningLines) {
    $PotentialBuild = ($Board[$line] | Sort-Object ) -join ''
    $Regex = '^[1-9]{2}'+$Player+'$'
    if ($PotentialBuild -match $Regex) {
      foreach ($Pos in $Line) {
        if ($Board[$Pos] -match '[1-9]') {$BuildPos += $Pos}
      }
      $RandomBuildIndex = $BuildPos | Get-Random
      return $RandomBuildIndex
    }
  }
}

function Get-NextMove {
  Param ([string[]]$Board, [string]$Player, [switch]$ComputersTurn)
  [int]$MMIndex = 0
  $Opponent = ('O','X') | Where-Object {$_ -ne $Player}
  if ($ComputersTurn) {
    $Blanks = Find-BlankCells -Board $Board
    if ($Blanks.NumberOfBlanks -eq 9) {
      $FirstMove =  (0,2,6,8) | Get-Random 
      return $FirstMove
    }
    elseif ($Blanks.NumberOfBlanks -eq 8 -and $Board[4] -eq $Opponent) {
      $RandomCounterAttack = (1,3,5,7) | Get-Random
      return $RandomCounterAttack
    }
    else {
      $MMIndex = Find-MiniMiniMax -Board $Board -Player $Player
      return $MMIndex
    } # This should be the minimax logic
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
$XMoves = @() ;$OMoves = @()
do {
  $Opponent = $PlayerToken
  $PlayerToken = ('X','O') | Where-Object {$_ -notcontains $PlayerToken}
  if ($PlayerToken -eq 'X') {$MoveIndex = Get-NextMove -Board $MainBoard -Player $PlayerToken -ComputersTurn}
  else {$MoveIndex = Get-NextMove -Board $MainBoard -Player $PlayerToken } 
  if ($PlayerToken -eq 'X') {$XMoves += $MoveIndex}
  if ($PlayerToken -eq 'O') {$OMoves += $MoveIndex}
  $MainBoard[$MoveIndex] = $PlayerToken
  $WinStatusPlayer = Find-Winner -Board $MainBoard -Player $PlayerToken
  $WinStatusOpponent = Find-Winner -Board $MainBoard -Player $Opponent
  $DrawStatus =  Find-Draw -Board $MainBoard
  Show-Board -Board $MainBoard
  #if ($PlayerToken -eq 'X') {Find-BestMoveMiniMax -Board $MainBoard -Player $PlayerToken}
} until ($DrawStatus -eq $true -or $WinStatusPlayer.Winner -eq $PlayerToken -or $WinStatusOpponent.Winner -eq $Opponent)
if ($WinStatusPlayer.Winner -eq 'O') {$Color = 'Yellow'} else {$Color = 'Red'}
if ($WinStatusPlayer.Winner -ne 'NoWinner') {Write-Host -ForegroundColor $Color "Winner = $($WinStatusPlayer.Winner)"}
if ($WinStatusOpponent.Winner -ne 'NoWinner') {Write-Host -ForegroundColor $Color "Winner = $(WinStatusOpponent.Winner)"}
if ($DrawStatus) {'Game Drawn = ' + $DrawStatus}
$XMoves -join ','
$OMoves -join ','