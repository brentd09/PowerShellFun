<#
.SYNOPSIS
  Play Tic Tac Toe against the computer 
.DESCRIPTION
  This Tic Tac Toe game employs the minimax game play code, which
  goes through each play and determines what is the best move to make 
  as an AI player. I am not 100% sure the minimax code had been 
  implemented correctly, but for now it works sufficiently.. 
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

  [bool]PlayCell ([string]$XorO) {
    if ($this.Played -eq $true -or $XorO -notin @('X','O')) {return $false}
    else {
      $this.Played = $true
      $this.Value = $XorO.ToUpper()
      return $true
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
      if ($Win -ne 'N') {break}
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

function Find-MiniMax {
  Param (
    [TTTBoard]$Board,
    [int]$Depth,
    [bool]$Max
  )
  $ScoreHashTable = @{
    X = 1
    O = -1
    N = 0
  }
  $Winner = $Board.TestWin()
  if ($Winner -ne 'n') {
    $Score = $ScoreHashTable[$Winner]
    return $Score
  }
  if ($Max -eq $true) {
    $BestScore = -10
    $UnplayedCells = $Board.Cells | Where-Object {$_.Played -eq $false }
    foreach ($UnplayedCell in $UnplayedCells) {
      $CopyBoard = $Board.Clone()
      $TryCell = $CopyBoard.Cells | Where-Object { $_.Position -eq $UnplayedCell.Position}
      $PlayResult = $TryCell.PlayCell('X')
      $Score = Find-Minimax -Board $CopyBoard -Depth ($Depth + 1) -Max $false
      $BestScore = [math]::Max($Score, $BestScore)
    }
    return $BestScore  
  }
  else {
    $BestScore = 10
    $UnplayedCells = $Board.Cells | Where-Object {$_.Played -eq $false }
    foreach ($UnplayedCell in $UnplayedCells) {
      $CopyBoard = $Board.Clone()
      $TryCell = $CopyBoard.Cells | Where-Object { $_.Position -eq $UnplayedCell.Position}
      $PlayResult = $TryCell.PlayCell('O')
      $Score = Find-Minimax -Board $CopyBoard -Depth ($Depth + 1) -Max $true
      $BestScore = [math]::Min($Score, $BestScore)
    }
    return $BestScore  
  }
}

#Main code
$Board = [TTTBoard]::New()
[string]$Turn = 'X'
do  {
  if ($Turn -eq 'X') {
    $TurnCounter = 10 - ($Board.Cells | Where-Object {$_.Played -eq $false}).Count
    if ($TurnCounter -eq 1) {$PlayCell = $Board.Cells | Where-Object {$_.Played -eq $False -and $_.Position -in @(0,2,6,8) } | Get-Random}
    #    else {$PlayCell = $Board.Cells | Where-Object {$_.Played -eq $False } | Get-Random <#replace with minimax type function call#>}
    else {
      $BestScore = -10
      $BestMoveIndex = 0
      $UnplayedCells = $Board.Cells | Where-Object {$_.Played -eq $False }
      $XThreats = ($Board.TestThreat()).XThreats
      if ($XThreats.Count -ge 1) {
        $PlayCell = $Board.Cells[($XThreats|Get-Random)]
      }
      else {
        foreach ($UnplayedCell in $UnplayedCells) {
          $CopyBoard = $Board.Clone()
          $TryCell = $CopyBoard.Cells | Where-Object { $_.Position -eq $UnplayedCell.Position}
          $PlayResult = $TryCell.PlayCell('X')
          $Score = Find-Minimax -Board $CopyBoard -Depth 0 -Max $false
          if ($score -gt $BestScore) {
            $BestScore = $Score
            $BestMoveIndex = $TryCell.Position
          } 
        } 
        $PlayCell = $Board.Cells[$BestMoveIndex]
      }  
    }
    $PlayCell.PlayCell($Turn)
    $Winner = $Board.TestWin()  
    if ($Winner -ne 'N') {Break}
    Show-Board -GameBoard $Board
  }
  else {
    do {
      do {
        $ChoseLocation = Read-Host -Prompt 'Enter a position'
      } until ($ChoseLocation -match '^[1-9]$')
      $ChosenIndex = ($ChoseLocation -as [int]) - 1
    } until ($Board.Cells[$ChosenIndex].Played -eq $false)  
    $Board.Cells[$ChosenIndex].PlayCell('O')
    $Winner = $Board.TestWin()
    if ($Winner -ne 'N') {Break}
    Show-Board -GameBoard $Board
  }
  $Turn = @('X','O') | Where-Object {$_ -ne $Turn} 
} until  ($Board.Cells.Played -notcontains $false -or $Winner -ne 'N')   
Show-Board -GameBoard $Board -Termstate $Winner -Final
