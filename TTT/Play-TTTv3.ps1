<#
.SYNOPSIS
  Tic Tac Toe
.DESCRIPTION
  This game incorporates the minimax functions that makes the game logic very difficult to beat
.EXAMPLE
  Play-TTT
  Starts the game as a two human player game
.EXAMPLE
  Play-TTT -ComputerPlaysX
  Starts the game as a human against computer where computer plays X
.EXAMPLE
  Play-TTT -ComputerPlaysO
  Starts the game as a human against computer where computer plays O
.EXAMPLE
  Play-TTT -ComputerPlaysX -ComputerPlaysO
  Starts the game where the computer plays both X and O
.PARAMETER ComputerPlaysX
  This is a switch parameter that tells the computer to play the game as X
.PARAMETER ComputerPlaysO
  This is a switch parameter that tells the computer to play the game as O
.NOTES
  General notes
    Created By: Brent Denny
    Created On: 9 Sep 2019
#>
[CmdletBinding()]
Param(
  [switch]$ComputerPlaysX = $true,
  [switch]$ComputerPlaysO
)

## Class 
Class TTTBoard {
  [String[]]$BoardValues
  [string]$Winner
  [int[]]$BlankCells

  TTTBoard() {
    $this.BoardValues = @('1','2','3','4','5','6','7','8','9')
    $this.Winner = 'N'
    $this.BlankCells = @()
  }

  [void]CheckBlankCells() {
    $EmptyCells = @()
    foreach ($Index in (0..8)) {
      if ($this.BoardValues[$Index] -notin ('X','O')) {$EmptyCells += $Index}
    }
    $this.BlankCells = $EmptyCells
  } 

  [bool]CheckWinner() { #Values set in $this.Winner are: X - X wins, O - O wins, N - no clear winner yet, D - The game is a draw
    [int[]]$WinArray = @(0,1,2,3,4,5,6,7,8,0,3,6,1,4,7,2,5,8,0,4,8,2,4,6)
    0..7 | Where-Object {
      $StartPos = $WinArray[$_ * 3] 
      $MidPos = $WinArray[($_ * 3) + 1]
      $EndPos = $WinArray[($_ * 3) + 2]
      if ($this.BoardValues[$StartPos] -eq $this.BoardValues[$MidPos] -and $this.BoardValues[$StartPos] -eq $this.BoardValues[$EndPos]) {
        $this.Winner = $this.BoardValues[$StartPos] 
        $true
        break
      }
      else {
        $this.Winner = 'N'
      }
    }
    if ($this.BlankCells.Count -eq 0 -and $this.Winner -eq 'N') {
      $this.Winner = 'D'
    }
    return $false
  }

  [bool]MakeMove([string]$CurrentTurnLetter,[int]$MoveIndex) {
    if ($this.BoardValues[$MoveIndex] -in ('X','O') -or $MoveIndex -gt 8 -or $MoveIndex -lt 0 -or $CurrentTurnLetter -notin ('X','O')) {
      return $false
    }
    else {
      $this.BoardValues[$MoveIndex] = $CurrentTurnLetter
      $this.CheckBlankCells()
      return $true
    }
  }
} #END Class

##functions
function Show-Board {
  Param ([TTTBoard]$Board,[string]$Padding='  ')

  Clear-Host
  $EntryColors = @('White','White','White','White','White','White','White','White','White')
  $ShowSqr = @(' ',' ',' ',' ',' ',' ',' ',' ',' ')
  $GridColor = "Yellow"
  $XColor = "Red"
  $OColor = "Green"
  $EmptyColor = 'DarkGray'
  foreach ($Pos in (0..8)){
    if ($Board.BoardValues[$Pos] -eq "X") { $EntryColors[$Pos] = $XColor}
    if ($Board.BoardValues[$Pos] -eq "O") { $EntryColors[$Pos] = $OColor}
    if ($Board.BoardValues[$Pos] -notin ('X','O')) { $EntryColors[$Pos] = $EmptyColor}
    if ($Board.BoardValues[$Pos] -in ('X','O')) {$ShowSqr[$Pos] = $Board.BoardValues[$Pos]}
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

function Find-BestMoveIndex {
  Param(
    [TTTBoard]$Board,
    [string]$TurnLetter
  )
  $OtherPlayer = @('X','O') | Where-Object {$_ -notcontains $TurnLetter} 
  $EmptyCellsIndexes = $Board.BlankCells
  if ($TurnLetter -eq 'X') {return Get-Minimax 
  }
}

function Get-Minimax {
  Param ([TTTBoard]$Board, [string]$PlayerLetter)
  $OtherPlayer = $('X','O') | Where-Object {$_ -notcontains $PlayerLetter}
  $AvailableCellIndex = $Board.BlankCells
  if ($Board.CheckWinner() -eq $true) {
    if ($Board.Winner -eq $OtherPlayer) {Return -10}
    elseif ($Board.Winner -eq $PlayerLetter) {return 10}
  }
  elseif ($AvailableCellIndex.Count -eq 0 ) {return 0}
  $Moves = @()
  foreach ($Counter in (0..$AvailableCellIndex.Count)) {
    if ($PlayerLetter = 'X') {
      $Move = [PSCustomObject]@{
        Index = $AvailableCellIndex[$Counter]
        Score = Get-Minimax -Board $Board -PlayerLetter 'O'
      }
    }
    else {

    }
  }
}

## MAIN CODE

$TTT = [TTTBoard]::New()
$MoveLetter = 'X'
$TurnCount = 0
Do {
  $TurnCount++
  Show-Board($TTT)
  if (($MoveLetter -eq 'X' -and $ComputerPlaysX) -or ($MoveLetter -eq 'O' -and $ComputerPlaysO)) {
    $BestMoveIndex = Find-BestMoveIndex -Board $TTT -TurnLetter $MoveLetter 
    $TTT.MakeMove($MoveLetter,$BestMoveIndex)
  }
  else {
    do {
      $Choice = ((Read-Host -Prompt "Choose an empty square") -as [int] ) - 1
      $GoodMove = $TTT.MakeMove($MoveLetter,$Choice)
    } until ($GoodMove -and $Choice -le 8 -and $Choice -ge 0)
  } 
  $TTT.CheckWinner()
  $MoveLetter = @('X','O') | Where-Object {$_ -notcontains $MoveLetter}
} until ($TTT.Winner -eq $true -or $TurnCount -eq 9)
Show-Board($TTT)
'winner ' + $TTT.Winner