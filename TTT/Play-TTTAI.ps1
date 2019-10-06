<#
.SYNOPSIS
  TicTacToe Game with AI logic
.DESCRIPTION
  This version of TTT will (eventually) have the MiniMax AI code added, to the logic, to have 
  the computer choose the best possible move and therefore the result should always be a 
  draw if bost players are player the best move possible.
  The MiniMax code has not yet been added and so currently this game is played by two human
  players.
.EXAMPLE
  Play-TTTAI.ps1
  This runs the game 
.NOTES
  General notes
    Created By: Brent Denny
    Created On: 20-Sep-2019
#>
[CmdletBinding()]
Param()

#Classes

Class TTTCell {
  [int]$Position
  [string]$Content
  [bool]$Empty

  TTTCell ($Pos) {
    $this.Position = $Pos
    $this.Content = ($Pos+1) -as [string]
    $this.Empty = $true
  }

  TTTCell ($Pos,$Content,$Empty) {
    $this.Position = $Pos
    $this.Content = $Content
    $this.Empty = $Empty
  }#END Constructors

  [bool]PlayMove ($XorO) {
    if ($this.Content -match '^[1-9]$') {
      $this.Content = $XorO
      $this.Empty = $false
      return $true
    }
    else {
      return $false
    }
  }#end playmove
}#end TTTCell

class TTTBoard {
  [TTTCell[]]$Cells

  TTTBoard () {
    $this.Cells = 0..8 | ForEach-Object {
      [TTTCell]::New($_)
    }
  }
  
  TTTBoard ([TTTCell[]]$Cells) {
      $this.Cells = $Cells
  }  #End Contructors

  [TTTBoard]Clone () {
    $CloneCells = 0..8 | ForEach-Object {[TTTCell]::New($this.Cells[$_].Position,$this.Cells[$_].Content,$this.Cells[$_].Empty)}
    $CloneBoard = [TTTBoard]::New($CloneCells)
    return $CloneBoard
  }
}#End TTTBoard

#Functions
function Show-Board {
  Param (
    [TTTBoard]$Board,
    [string]$Padding = "  ",
    [string]$GridColor = "Cyan",
    [string]$XColor    = "Red",
    [string]$OColor    = "Yellow",
    [string]$TitleCol  = "Green",
    $TermState
  )
  Clear-Host
  $EntryColors = @('White','White','White','White','White','White','White','White','White')
  $ShowSqr = @(' ',' ',' ',' ',' ',' ',' ',' ',' ')

  foreach ($Pos in (0..8)){
    if ($Board.Cells[$Pos].Content -eq "X") { $EntryColors[$Pos] = $XColor}
    if ($Board.Cells[$Pos].Content -eq "O") { $EntryColors[$Pos] = $OColor}
    if ($Board.Cells[$Pos].Content -eq " ") { $EntryColors[$Pos] = "darkgray"}
    if ($Board.Cells[$Pos].Content -match "[XO]") {$ShowSqr[$Pos] = $Board.Cells[$Pos].Content}
    elseif ($TermState.Winner -in @('X','O')) {$ShowSqr[$Pos] = ' '}
    else {$ShowSqr[$Pos] = $Pos + 1}
  }
  Write-Host -ForegroundColor $TitleCol "`n${Padding}Tic Tac Toe`n"
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
}#END ShowBoard

function Test-TerminalState {
  Param (
    [TTTBoard]$Board
  )
  [System.Collections.ArrayList]$WinningLines = @(
    @(0,1,2),@(3,4,5),@(6,7,8),
    @(0,3,6),@(1,4,7),@(2,5,8),
    @(0,4,8),@(2,4,6)
  )
  $Winner = 'N'
  $TermState = $false
  foreach ($Line in $WinningLines) {
    if ($Board.Cells[$line[0]].Content -eq 'X' -and $Board.Cells[$line[1]].Content -eq 'X' -and $Board.Cells[$line[2]].Content -eq 'X' ) {
      $Winner = 'X'
      $TermState = $true
      break
    }
    elseif ($Board.Cells[$line[0]].Content -eq 'O' -and $Board.Cells[$line[1]].Content -eq 'O' -and $Board.Cells[$line[2]].Content -eq 'O' ) {
      $Winner = 'O'
      $TermState = $true
      break
    }
    elseif ($Board.Cells.Empty -notcontains $true) {
      $Winner = 'D'
      $TermState = $true
    }
  }#END foreach
  return [PSCustomObject]@{ # Termstate => N - No winner yet, D = Draw, X - X wins, O - O wins 
    Winner   = $Winner
    Terminal = $TermState
  }
}#END Terminal State

function Select-BestMove {
  Param (
    [TTTBoard]$Board,
    [string]$Player
  )
  $ScoreObj = @()
  $OtherPlayer = @('X','O') | Where-Object {$_ -ne $Player}
  $EmptyCells = $Board.Cells | Where-Object {$_.Empty -eq $true}
  foreach ($EmptyCell in $EmptyCells) {
    $NewBoard = $Board.Clone()
    $NewBoard.Cells[$EmptyCell.Position].PlayMove($Player) | Out-Null
    $TestTermState = Test-TerminalState -Board $NewBoard
    if ($TestTermState.winner -in @($Player,'D')) {return $EmptyCell.Position}
  }
  foreach ($EmptyCell in $EmptyCells) {
    $NewBoard = $Board.Clone()
    $NewBoard.Cells[$EmptyCell.Position].PlayMove($Player) | Out-Null
    $TestTermState = Test-TerminalState -Board $NewBoard
    $ScoreObj += [PSCustomObject]@{
      Score = Get-MiniMaxIndex -Board $NewBoard -MaxPlayer $Player $CurrentPlayer $OtherPlayer
      Position = $EmptyCell.Position
    }
  }
  $BestScore = ($ScoreObj | Sort-Object -Property Score -Descending)[0]
  return $BestScore.Position
}#END SelectBestMove

function Get-MiniMaxIndex {
  Param (
    [TTTBoard]$Board,
    [string]$MaxPlayer,
    [string]$CurrentPlayer
  )
  $CloneBoard = $Board.Clone()
  $OtherPlayer = @('X','O') | Where-Object {$_ -ne $MaxPlayer}
  if ($MaxPlayer -eq $CurrentPlayer) {
    $EmptyCells = $CloneBoard.Cells | Where-Object {$_.Empty -eq $true}
    foreach ($EmptyCell in $EmptyCells) {
      $NewBoard = $CloneBoard.Clone()
      $NewBoard.Cells[$EmptyCell.Position].PlayMove($Player) | Out-Null
      $TestTermState = Test-TerminalState -Board $NewBoard
      if ($TestTermState.Winner -eq $MaxPlayer) {return 10}
      if ($TestTermState.Winner -eq 'D') {return 0}
    }
  }
  else {
    $EmptyCells = $CloneBoard.Cells | Where-Object {$_.Empty -eq $true}
    foreach ($EmptyCell in $EmptyCells) {
      $NewBoard = $CloneBoard.Clone()
      $NewBoard.Cells[$EmptyCell.Position].PlayMove($Player) | Out-Null
      $TestTermState = Test-TerminalState -Board $NewBoard
      if ($TestTermState.Winner -in @($CurrentPlayer)) {return -10}
      if ($TestTermState.Winner -eq 'D') {return 0}      
    }
  }
  Get-MiniMaxIndex -Board $CloneBoard -MaxPlayer $MaxPlayer -CurrentPlayer $OtherPlayer
}#END MiniMax


#Main Code
[string]$GridColor = "Cyan"
[string]$XColor    = "Red"
[string]$OColor    = "Yellow"
[string]$TitleCol  = "Green"
[TTTBoard]$Board = [TTTBoard]::New()
Show-Board -Board $Board
$Turn = @('X','O') | Get-Random
do {
  if ($Turn -eq 'X') {
    $AutoTurnIndex = Select-BestMove -Board $Board -Player $Turn
    $Board.Cells[$AutoTurnIndex].PlayMove($Turn)
  }
  else {
    do {
      try {
        $ErrorActionPreference = 'Stop'
        Write-Host -NoNewline "Player $Turn, Choose a number as your next choice: "
        if ($Host.Name -eq 'ConsoleHost') {[int]$Choice = ($Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')).Character -as [string]} 
        else {[int]$Choice = Read-Host}
      } 
      catch {if ($Host.Name -eq 'ConsoleHost') {Write-Host}} #to stop [int] coversion errors from showing on screen
      finally {$ErrorActionPreference = 'Continue'}
      if ($Choice -in 1..9) {$TurnResult = $Board.Cells[($Choice-1)].PlayMove($Turn)}
      else {$TurnResult = $false}
    } until ($TurnResult -eq $true)
  }
  $GameState = Test-TerminalState -Board $Board
  Show-Board -Board $Board -GridColor $GridColor -XColor $XColor -OColor $OColor -TitleColor $TitleCol -TermState $GameState
  $Turn =  @('X','O') | Where-Object {$_ -ne $Turn}
} until ($Board.Cells.Empty -notcontains $true -or $GameState.Terminal -eq $true)
if ($GameState.Winner -eq 'X' ) {Write-Host -ForegroundColor $XColor "`nWinner is $($GameState.Winner)"}
elseif ($GameState.Winner -eq 'O' ) {Write-Host -ForegroundColor $OColor "`nWinner is $($GameState.Winner)"}
else {Write-Host -ForegroundColor $TitleCol "Game is a Draw"}