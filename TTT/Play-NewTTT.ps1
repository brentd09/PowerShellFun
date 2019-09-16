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

#Functions
function Show-Board {
  Param ([string[]]$Board,[string]$Padding='  ')

  #Clear-Host
  $EntryColors = @('White','White','White','White','White','White','White','White','White')
  $ShowSqr = @(' ',' ',' ',' ',' ',' ',' ',' ',' ')
  $GridColor = "Yellow"
  $XColor = "Red"
  $OColor = "Green"
  $EmptyColor = 'DarkGray'
  foreach ($Pos in (0..8)){
    if ($Board[$Pos] -eq "X") { $EntryColors[$Pos] = $XColor}
    if ($Board[$Pos] -eq "O") { $EntryColors[$Pos] = $OColor}
    if ($Board[$Pos] -notin ('X','O')) { $EntryColors[$Pos] = $EmptyColor}
    if ($Board[$Pos] -in ('X','O')) {$ShowSqr[$Pos] = $Board[$Pos]}
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
} # END function ShowBoard
function Select-Turn {
  Param($Board,[int]$BoardIndex,$Player)
  if ($Player -eq 'X') {$OtherPlayer = 'O'} else {$OtherPlayer = 'X'}
  $PlayerWin = Resolve-Win -Board $Board -Player $Player
  $OtherPlayerWin = Resolve-Win -Board $Board -Player $OtherPlayer
  $Draw = Resolve-DrawnGame -Board $Board
  if ($PlayerWin.Count -eq 0 -and $OtherPlayerWin.Count -eq 0 -and $Draw -eq $false -and $Board[$BoardIndex] -notin @('X','O')) {
    $Board[$BoardIndex] = $Player
  }
}
function Resolve-Win {
  Param([string[]]$Board,[string]$Player)
  $WinningLines = @(@(0,1,2),@(3,4,5),@(6,7,8),@(0,3,6),@(1,4,7),@(2,5,6),@(0,4,8),@(2,4,6))
  ForEach ($WinLineIndex in (0..7)) {
    $BoardLine = $Board[$WinningLines[$WinLineIndex]]
    If ($BoardLine[0] -eq $Player -and $BoardLine[1] -eq $Player -and $BoardLine[2] -eq $Player) {
      $GameWon = @{WinIndex=$WinLineIndex;Winner=$Player}
      break
    }
  }
  return $GameWon
}
function Resolve-DrawnGame {
  Param($Board)
  $Xwin = Resolve-Win($Board,'X')
  $Owin = Resolve-Win($Board,'O')
  if ($Xwin.Count -eq 0 -and $Owin.Count -eq 0) {$Result = $false}
  else {$Result = $true}
  return $Result
}
function Find-EmptyCells {
  Param($Board)
  $EmptyIndexes = 0..8 | ForEach-Object {
    if ($Board[$_] -match '\d') {$_}
  }
  return $EmptyIndexes
}
function Find-BestMove {
  Param($EmptyCells)
  if ($EmptyCells.Count -ge 1) {return $EmptyCells[0]}
}


#Maincode
$HumanPlayer = 'O' ;  $ComputerPlayer = 'X'
$TTTBoard = [System.Collections.ArrayList]$('1','2','3','4','5','6','7','8','9')
$CurrentPlayer = $ComputerPlayer
Show-Board -Board $TTTBoard
do {
  [int]$Selection = Read-Host -Prompt "Enter number"
  $Selection--
  Select-Turn -Board $TTTBoard -BoardIndex $Selection -Player $CurrentPlayer
  Show-Board -Board $TTTBoard
  if ($CurrentPlayer -eq 'X') {$CurrentPlayer = 'O'} 
  else {$CurrentPlayer = 'X'}
} Until ($false)