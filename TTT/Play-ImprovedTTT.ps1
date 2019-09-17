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
Param ()

# Classes

Class TTTCell {
  [string]$CellValue
  [int]$CellIndex
  [bool]$CellBlank
  [int]$CellRow
  [int]$CellCol
  [int[]]$CellDiag

  TTTCell ($Index) {
    $this.CellValue = ($Index + 1) -as [string]
    $this.CellBlank = $true
    $this.CellIndex = $Index
    $this.CellRow = $Index % 3
    $this.CellCol = [math]::Truncate($Index/3)
    if ($Index -in (0,8)) {$this.CellDiag = @(0)}
    elseif ($Index -in (2,6)) {$this.CellDiag = @(1)}
    elseif ($Index -eq 4) {$this.CellDiag = @(0,1)}
  } # END Constructor

  [bool]PlayCell ($Player) {
    If ($Player -in ('X','O') -and $this.CellValue -notin ('X','O')) {
      $this.CellBlank = $false
      $this.CellValue = $Player
      return $true
    }
    else {return $false}
  } # END Method PlayCell
} # END Class TTTCell

Class TTTBoard {
  [TTTCell[]]$TTTCells
  [bool]$GameEnded
  [string]$GameWinner
  [string]$GameResultColor

  TTTBoard () {
    $this.TTTCells = 0..8 | Where-Object {[TTTCell]::New($_)}
    $this.GameWinner = $null
    $this.GameEnded = $false
    $this.GameResultColor = 'Blue'
  } #END Constructor

  [TTTCell[]]FindEmptyCells () {
    $Emptys = $this.TTTCells | Where-Object {$_.Empty -eq $true}
    return $Emptys
  } #END Method FindEmptyCells

  [void]FindWinner () {
    $WinningCells = @(
      @(0,1,2),@(3,4,5),@(6,7,8),
      @(0,3,6),@(1,4,7),@(2,5,8),
      @(0,4,8),@(2,4,6)
    )
    foreach ($WinningCell in $WinningCells) {
      if ($this.TTTCells[$WinningCell[0]].CellValue -eq 'X' -and 
          $this.TTTCells[$WinningCell[1]].CellValue -eq 'X' -and 
          $this.TTTCells[$WinningCell[2]].CellValue -eq 'X' ) {
        $this.GameWinner = 'X'
        $this.GameEnded = $true
        $this.GameResultColor = 'Red'

        break
      }
      elseif ($this.TTTCells[$WinningCell[0]].CellValue -eq 'O' -and 
              $this.TTTCells[$WinningCell[1]].CellValue -eq 'O' -and 
              $this.TTTCells[$WinningCell[2]].CellValue -eq 'O' ) {
        $this.GameWinner = 'O'
        $this.GameEnded = $true
        $this.GameResultColor = 'Yellow'
        break
      }
      elseif ($this.TTTCells.CellBlank -notcontains $true) {
        $this.GameEnded = $true
        $this.GameWinner = 'N' # Game drawn: N - No winner
      }
    }
  } #END method FindWinner

  [int]FindBestMove ($Player) {
    $WinningCells = @(
      @(0,1,2),@(3,4,5),@(6,7,8),
      @(0,3,6),@(1,4,7),@(2,5,8),
      @(0,4,8),@(2,4,6)
    )
    if ($Player -eq 'X') {$Opponent = 'O'} else {$Opponent = 'X'}
    $BestMove = 99
    $EmptyCells = $this.TTTCells | Where-Object {$_.CellBlank -eq $true}
    foreach ($WinningCell in $WinningCells) {
      $CellArray = @($this.TTTCells[$WinningCell[0]], $this.TTTCells[$WinningCell[1]],  $this.TTTCells[$WinningCell[2]])
      $CellValues = $CellArray.CellValue
      $HumanMoves = $CellValues | Where-Object {$_ -eq $Opponent}
      $PlayerMoves = $CellValues | Where-Object {$_ -eq $Player}
      if ($PlayerMoves.Count -eq 2 -and $HumanMoves.Count -eq 0) {
        0..2 | ForEach-Object {if ($CellValues[$_] -ne $Player) {$BestMove = $CellArray[$_].CellIndex ; break}}
      }
      if ($HumanMoves.Count -eq 2 -and $PlayerMoves.Count -eq 0) {
        0..2 | ForEach-Object {if ($CellValues[$_] -ne $Opponent) {$BestMove = $CellArray[$_].CellIndex ; break}}
      }
    }
    if ($BestMove -eq 99) {
      if ($EmptyCells.Count -eq 9) {$BestMove = 2,0,8,6 | Get-Random}
      #elseif ($EmptyCells.Count -eq 7 -and $this.TTTCells[4].CellBlank -eq $true -and $this.TTTCells[8].CellBlank -eq $true) {$BestMove = 4}
      else {
        $EmptyCells = $this.TTTCells | Where-Object {$_.CellBlank -eq $true}
        $BestMove = $EmptyCells.CellIndex | Get-Random
      }
    }
    return $BestMove
  }

} #END Class TTTBoard

# Functions

function Show-Board {
  Param ([TTTBoard]$Board,$Border='  ')

  Clear-Host
  $EntryColors = @('White','White','White','White','White','White','White','White','White')
  $ShowSqr = @(' ',' ',' ',' ',' ',' ',' ',' ',' ')
  $GridColor = "white"
  $XColor = "Red"
  $OColor = "Yellow"
  $TitleCol = "White"
  foreach ($Pos in (0..8)){
    if ($Board.TTTCells[$Pos].CellValue -eq "X") { $EntryColors[$Pos] = $XColor}
    if ($Board.TTTCells[$Pos].CellValue -eq "O") { $EntryColors[$Pos] = $OColor}
    if ($Board.TTTCells[$Pos].CellBlank -eq $true) { $EntryColors[$Pos] = "darkgray"}
    if ($Board.TTTCells[$Pos].CellValue -match "[XO]") {$ShowSqr[$Pos] = $Board.TTTCells[$Pos].CellValue}
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

# Main Code
$MainBoard = [TTTBoard]::New()
Show-Board -Board $MainBoard
$Letter = 'X'
do {
  if ($Letter -eq 'O') {
    do {
      try {
        $ErrorActionPreference = 'Stop'
        $Choice = Read-Host -Prompt 'Enter a number'
        if ($Choice -notin 1..9) {throw} else {$Choice = $Choice - 1}
      }
      catch {$PlayValid = $false; continue}
      finally {$ErrorActionPreference = 'Continue'}
      $PlayValid = $MainBoard.TTTCells[$Choice].PlayCell($Letter)
    } until ($PlayValid)  
  }
  else { 
    $Choice = $MainBoard.FindBestMove($Letter)
    $MainBoard.TTTCells[$Choice].PlayCell($Letter)
  }
  $MainBoard.FindWinner()
  Show-Board -Board $MainBoard
  $Letter = ('X','O') | Where-Object {$_ -ne $Letter}
} until ($MainBoard.GameEnded -eq $true)
if ($MainBoard.GameWinner -eq 'N') {Write-Host -ForegroundColor $MainBoard.GameResultColor "No Winner - Game is a draw"}
else {Write-Host -ForegroundColor $MainBoard.GameResultColor "Winner = " $MainBoard.GameWinner} 