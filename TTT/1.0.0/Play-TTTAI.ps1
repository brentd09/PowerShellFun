<#
.SYNOPSIS
  Play Tic Tac Toe against the computer 
.DESCRIPTION
  This Tic Tac Toe game employs the minimax game play code, which
  goes through each play and determines what is the best move to make 
  as an AI player. It also has Alpha Beta pruning which disregards 
  potential plays have no effect on the minimax outcome. The best 
  you can hope for is a draw if each player plays optimally.
.EXAMPLE
  Play-TTTAI
.NOTES
  General notes
    Created by:   Brent Denny
    Created on:   01 Oct 2020
    Last Modified 16 Oct 2020
#>
# Class definitions

Class TTTBoardCell {
  [int]$Position
  [string]$Value 
  [bool]$Played

  TTTBoardCell ([int]$ArrayPos) {
    $this.Position = $ArrayPos
    $this.Value = ($ArrayPos + 1) -as [string]
    $this.Played = $false
  }

  [void]PlayCell ([string]$XorO) {
    if ($this.Played -eq $false -and $XorO -in @('X','O')) {
      $this.Played = $true
      $this.Value = $XorO.ToUpper()
    }
  }
}

class TTTBoard {
  [TTTBoardCell[]]$Cells

  TTTBoard () {
    $this.Cells = foreach ($Pos in (0..8)) { [TTTBoardCell]::New($Pos)}
  }

  TTTBoard ([int]$Pos) {
    $this.Cells = foreach ($Pos in (0..$Pos)) { [TTTBoardCell]::New($Pos)}
  } 

  [string]TestWin () {
    [System.Collections.ArrayList]$WinningLines = @(
      @(0,1,2),@(3,4,5),@(6,7,8),
      @(0,3,6),@(1,4,7),@(2,5,8),
      @(0,4,8),@(2,4,6)
    )
    [string]$Win = 'N'
    foreach ($Line in $WinningLines) {
      [string[]]$XsInLine = ($this.Cells[$Line].Value) -eq 'X'
      [string[]]$OsInLine = ($this.Cells[$Line].Value) -eq 'O'
      if ($XsInLine.Count -eq 3) {$Win = 'X'}
      if ($OsInLine.Count -eq 3) {$Win = 'O'}
      if ($Win -in @('X','O')) {break}
    }
    $NumberOfMovesPlayed = ($this.Cells | Where-Object {$_.Played -eq $true}).Count
    if ($Win -eq 'N' -and $NumberOfMovesPlayed -eq 9) {$Win = 'D'}
    return $Win
  }

  [TTTBoard]Clone () {
    $BackupBoard = [TTTBoard]::New()
    0..8 | ForEach-Object {
      $BackupBoard.Cells[$_].Position = $this.Cells[$_].Position
      $BackupBoard.Cells[$_].Value = $this.Cells[$_].Value
      $BackupBoard.Cells[$_].Played = $this.Cells[$_].Played
    }
    return $BackupBoard
  }
}

# Functions
function Show-Board {
  Param (
    [TTTBoard]$GameBoard,
    [string]$Padding = "  ",
    [string]$GridColor = "Cyan",
    [string]$XColor    = "Red",
    [string]$OColor    = "Yellow",
    [string]$TitleCol  = "Green",
    [string]$TermState,
    [switch]$Final
  )
  Clear-Host
  $EntryColors = @('White','White','White','White','White','White','White','White','White')
  $ShowSqr = @(' ',' ',' ',' ',' ',' ',' ',' ',' ')

  foreach ($Pos in (0..8)){
    if ($GameBoard.Cells[$Pos].Value -eq "X") { $EntryColors[$Pos] = $XColor}
    if ($GameBoard.Cells[$Pos].Value -eq "O") { $EntryColors[$Pos] = $OColor}
    if ($GameBoard.Cells[$Pos].Value -eq " ") { $EntryColors[$Pos] = "darkgray"}
    if ($GameBoard.Cells[$Pos].Value -match "[XO]") {$ShowSqr[$Pos] = $GameBoard.Cells[$Pos].Value}
    elseif ($TermState -in @('X','O')) {$ShowSqr[$Pos] = ' '}
    else {$ShowSqr[$Pos] = $Pos + 1}
  }
  if ($Final -eq $false) {Write-Host -ForegroundColor $TitleCol "`n${Padding}Tic Tac Toe`n"}
  else {
    Write-Host -NoNewline -ForegroundColor $TitleCol "`n${Padding}Tic Tac Toe    "
    switch ($Winner) {
      'D' {Write-Host -ForegroundColor Gray -NoNewline 'Game: '; Write-Host -ForegroundColor Gray   'Draw'}
      'O' {Write-Host -ForegroundColor Gray -NoNewline 'Game: '; Write-Host -ForegroundColor Yellow 'O'}
      'X' {Write-Host -ForegroundColor Gray -NoNewline 'Game: '; Write-Host -ForegroundColor Red    'X'}
      Default {}
    }
    Write-Host ""
  }
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

function Get-MiniMax {
  Param (
    [TTTBoard]$fnBoard,
    [int]$Depth,
    [bool]$Max,
    [int]$Alpha,
    [int]$Beta
  )

  $ReturnCodes = @{
    X = 1
    O = -1
    D = 0
  }
  $CheckForWin = $fnBoard.TestWin()
  if ($CheckForWin -ne 'N') {return $ReturnCodes[$CheckForWin]}

  if ($Max -eq $true) {
    $XBestScore = -100
    $UnplayedCells = $fnBoard.Cells | Where-Object {$_.Played -eq $false}
    foreach ($UnplayedCell in $UnplayedCells) {
      $CopyBoard = $fnBoard.Clone()
      $CopyBoard.Cells[$UnplayedCell.Position].PlayCell('X')
      $Score = Get-MiniMax -FnBoard $CopyBoard -Depth ($Depth + 1) -Max $false -Alpha $Alpha -Beta $Beta
      $XBestScore = [math]::max($Score,$XBestScore)
      if ($XBestScore -ge $Beta) {return $XBestScore}
      $Alpha = [math]::Max($Alpha,$XBestScore)
    }
    return $XBestScore
  }
  else {
    $OBestScore = 100
    $UnplayedCells = $fnBoard.Cells | Where-Object {$_.Played -eq $false}
    foreach ($UnplayedCell in $UnplayedCells) {
      $CopyBoard = $fnBoard.Clone()
      $CopyBoard.Cells[$UnplayedCell.Position].PlayCell('O')
      $Score = Get-MiniMax -FnBoard $CopyBoard -Depth ($Depth + 1) -Max $true -Alpha $Alpha -Beta $Beta
      $OBestScore = [math]::min($Score,$OBestScore)
      if ($OBestScore -le $Alpha) {return $OBestScore}
      $Beta = [math]::Max($Beta,$OBestScore)
    }
    return $OBestScore
  }
  
}

#Main code
$Board = [TTTBoard]::New()
Show-Board -GameBoard $Board
[string]$Turn = 'O','X' | Get-Random
do  {
  $TurnCount = 10 - ($Board.Cells | Where-Object {$_.Played -eq $false}).Count
  if ($Turn -eq 'X') {  
    if ($TurnCount -eq 1) {
      $BestMoveIndex = @(0,2,6,8) | Get-Random
      $Winner = $Board.TestWin()
    }
    else {
      $BestScore = -100
      $UnplayedCells = $Board.Cells | Where-Object {$_.Played -eq $false}
      foreach ($UnplayedCell in $UnplayedCells) {
        $CopyBoard = $Board.Clone()
        $CopyBoard.Cells[$UnplayedCell.Position].PlayCell('X')
        $Score = Get-MiniMax -FnBoard $CopyBoard -Depth 0 -Max $false -Alpha -100 -Beta 100
        if ($Score -gt $BestScore) {
          $BestScore = $Score
          $BestMoveIndex = $UnplayedCell.Position
        }
      }
    }
    $Board.Cells[$BestMoveIndex].PlayCell('X')
    $Winner = $Board.TestWin()
    Show-Board -GameBoard $Board
    if ($Winner -eq 'X') {break}
  }
  else {
    do {
      $ChoseLocation = Read-Host -Prompt 'Enter a position'
      $LegalChoice = $false
      if ($ChoseLocation -match '^[1-9]$') {
        $ChosenIndex = ($ChoseLocation -as [int]) - 1
        if ($Board.Cells[$ChosenIndex].Played -eq $false) {$LegalChoice = $true}
      }
    } until ($LegalChoice -eq $true)
    $Board.Cells[$ChosenIndex].PlayCell('O')
    $Winner = $Board.TestWin()
    if ($Winner -ne 'N') {Break}
    Show-Board -GameBoard $Board
  }
  $Turn = @('X','O') | Where-Object {$_ -ne $Turn} 
} until  ($Board.Cells.Played -notcontains $false -or $Winner -ne 'N')
$Winner = $Board.TestWin()
Show-Board -GameBoard $Board -Termstate $Winner -Final