<#
.SYNOPSIS
  Play Tic Tac Toe against the computer 
.DESCRIPTION
  This Tic Tac Toe game employs the minimax game play code, which
  goes through each play and determines what is the best move to make 
  as an AI player. I am not 100% sure the minimax code had been 
  implemented correctly, but for now it works sufficiently in that I
  do not believe it can be beaten.. 
.EXAMPLE
  Play-TTTAI
.NOTES
  General notes
    Created by:   Brent Denny
    Created on:   01 Oct 2020
    Last Modified 13 Oct 2020
#>
# Class definitions
Class ThreatList {
  [int[]]$XThreats
  [int[]]$OThreats

  ThreatList () {
    $this.XThreats = @()
    $this.OThreats = @()
  }
}

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
      $NumberOfMovesPlayed = ($this.Cells | Where-Object {$_.Played -eq $true}).Count
      if ($Win -ne 'N' -and $NumberOfMovesPlayed -eq 9) {
        $Win = 'D'
        break
      }
      elseif ($Win -ne 'N') {break}
    }
    return $Win
  }

  [ThreatList]TestThreat () {
    [System.Collections.ArrayList]$WinningLines = @(
      @(0,1,2),@(3,4,5),@(6,7,8),
      @(0,3,6),@(1,4,7),@(2,5,8),
      @(0,4,8),@(2,4,6)
    )
    $Threats = [ThreatList]::new()
    foreach ($Line in $WinningLines) {
      [string[]]$XsInLine = ($this.Cells[$Line].Value) -eq 'X'
      [string[]]$OsInLine = ($this.Cells[$Line].Value) -eq 'O'
      if ($XsInLine.count -eq 2 -and $OsInLine.Count -eq 0) {
        $ThreatPosString = ($this.Cells[$Line].Value) -ne 'X'
        $ThreatPos = ($ThreatPosString[0] -as [int]) -1
        $Threats.XThreats += $ThreatPos
      }
      if ($OsInLine.Count -eq 2 -and $XsInLine.Count -eq 0) {
        $ThreatPosString = ($this.Cells[$Line].Value) -ne 'O'
        $ThreatPos = ($ThreatPosString[0] -as [int]) -1
        $Threats.OThreats += $ThreatPos
      }
    }
    return $Threats
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
    $TermState,
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
      'N' {Write-Host -ForegroundColor Gray -NoNewline 'Game: '; Write-Host -ForegroundColor Gray   'Draw'}
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

function Get-MaxValue {
  Param (
    [TTTBoard]$FnBoard,
    [int]$Alpha,
    [int]$Beta
  )
  $CheckGameState = $FnBoard.TestWin()
  if ($CheckGameState -in @('X','O','D')) {return 1}
  else {
    $BestVal = -100
    $UnplayedCells = $FnBoard.Cells | Where-Object {$_.Played -eq $false}
    $CopyBoard = $FnBoard.Clone()
    foreach ($UnPlayedCell in $UnplayedCells) {
      $CopyBoard.Cells[$UnPlayedCell.Position].PlayCell('X')
      $BestVal = [math]::Max($BestVal,(Get-MinValue -FnBoard $CopyBoard -Alpha $Alpha -Beta $Beta))
      if ($BestVal -ge $Beta) {return $BestVal}
      $Alpha = [math]::Max($Alpha,$BestVal)
    }
    return $BestVal
  }
}

function Get-MinValue {
  Param (
    [TTTBoard]$FnBoard,
    [int]$Alpha,
    [int]$Beta
  )
  $CheckGameState = $FnBoard.TestWin()
  if ($CheckGameState -in @('X','O','D')) {return -1}
  else {
    $BestVal = 100
    $UnplayedCells = $FnBoard.Cells | Where-Object {$_.Played -eq $false}
    $CopyBoard = $FnBoard.Clone()
    foreach ($UnPlayedCell in $UnplayedCells) {
      $CopyBoard.Cells[$UnPlayedCell.Position].PlayCell('O')
      $BestVal = [math]::Min($BestVal,(Get-MaxValue -FnBoard $CopyBoard -Alpha $Alpha -Beta $Beta))
      if ($BestVal -le $Alpha) {return $BestVal}
      $Beta = [math]::Max($Beta,$BestVal)
    }
    return $BestVal
  }
}

function Get-MiniMax {
  Param (
    [TTTBoard]$fnBoard,
    [int]$Depth,
    [bool]$Max
  )
  $ScoreHashTable = @{
    X = 1
    O = -1
    D = 0
  }
  $Winner = $fnBoard.TestWin()
  if ($Winner -ne 'n') {
    $Score = $ScoreHashTable[$Winner]
    return $Score
  }
  if ($Max -eq $true) {
    $BestScore = -100
    $UnplayedCells = $fnBoard.Cells | Where-Object {$_.Played -eq $false }
    foreach ($UnplayedCell in $UnplayedCells) {
      $CopyBoard = $fnBoard.Clone()
      $CopyBoard.Cells[$UnplayedCell.Position].PlayCell('X')
      $ResultingVal = Get-MaxValue -FnBoard $CopyBoard -Alpha -100 -Beta 100
      if ($ResultingVal -eq 1) {
        $PlayCell = $UnplayedCell
        break
      }
    }
    return $PlayCell.Position
  }
}

#Main code
$Board = [TTTBoard]::New()
Show-Board -GameBoard $Board
[string]$Turn = 'O'
do  {
  if ($Turn -eq 'X') {
    $UnplayedCells = $Board.Cells | Where-Object { $_.Played -eq $false}
    foreach ($UnplayedCell in $UnplayedCells) {
      $ResultingPos = Get-MiniMax -FnBoard $Board -Depth 0 -Max $true
    }
    $Board.Cells[$ResultingPos].PlayCell('X')
    Show-Board -GameBoard $Board
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
Show-Board -GameBoard $Board -Termstate $Winner -Final
