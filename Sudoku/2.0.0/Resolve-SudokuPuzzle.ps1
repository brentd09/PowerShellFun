<#
.SYNOPSIS
  Sudoku Solver
.DESCRIPTION
  This uses the following techniques to solve sudoku puzzles
  RatingSolution      Techniques
    Simple              Naked Single, Hidden Single
    Easy                Naked Pair, Hidden Pair, Pointing Pairs
    Medium              Naked Triple, Naked Quad, Pointing Triples, Hidden Triple, Hidden Quad
    Hard                XWing, Swordfish, Jellyfish, XYWing, XYZWing
  These are examples of the different dificulty grids
    Simple: '7-542--6-68-1--24--4-76--18-91--2-7482--576--3---1482-158--6--9--25-91-6--684-7-2'
    Easy:   '9-53--8-2---2-6-------1----7--4-3--8--6---7--1--6-8--9----6-------7-9---2-7--14-5'
.EXAMPLE
  Resolve-SudokuPuzzle -GameBoard '7-542--6-68-1--24--4-76--18-91--2-7482--576--3---1482-158--6--9--25-91-6--684-7-2'
  This solves the following Sudoku puzzle:
  +-------+-------+-------+ 
  | 7 - 5 | 4 2 - | - 6 - | 
  | 6 8 - | 1 - - | 2 4 - |
  | - 4 - | 7 6 - | - 1 8 |
  +-------+-------+-------+
  | - 9 1 | - - 2 | - 7 4 |
  | 8 2 - | - 5 7 | 6 - - |
  | 3 - - | - 1 4 | 8 2 - |
  +-------+-------+-------+
  | 1 5 8 | - - 6 | - - 9 |
  | - - 2 | 5 - 9 | 1 - 6 |
  | - - 6 | 8 4 - | 7 - 2 |
  +-------+-------+-------+
  When issuing the command unwrap the grid into a single string of characters where - means a blank spot and use this 
  string as the GameBoard parameter value. 
.NOTES
  General notes
       Created By: Brent Denny
       Created On: 16 Aug 2021
    Last Modified: 17 Aug 2021
#>
[CmdletBinding()]
Param(
  [String]$GameBoard = '9-53--8-2---2-6-------1----7--4-3--8--6---7--1--6-8--9----6-------7-9---2-7--1495'
)
Class SudokuElement {
  [int]$Pos 
  [string]$Value
  [int]$Row 
  [int]$Col 
  [int]$Sqr
  [string[]]$PossibleValues
  [string]$PosValStr
  [bool]$Solved

  SudokuElement ([int]$Position,[string]$Value) {
    $this.Pos = $Position
    $this.Value = $Value
    $this.Row = [math]::Truncate($Position/9)
    $this.Col = $Position % 9
    if ($Position -in @( 0, 1, 2, 9,10,11,18,19,20)) {$this.Sqr = 0}
    if ($Position -in @( 3, 4, 5,12,13,14,21,22,23)) {$this.Sqr = 1}
    if ($Position -in @( 6, 7, 8,15,16,17,24,25,26)) {$this.Sqr = 2}
    if ($Position -in @(27,28,29,36,37,38,45,46,47)) {$this.Sqr = 3}
    if ($Position -in @(30,31,32,39,40,41,48,49,50)) {$this.Sqr = 4}
    if ($Position -in @(33,34,35,42,43,44,51,52,53)) {$this.Sqr = 5}
    if ($Position -in @(54,55,56,63,64,65,72,73,74)) {$this.Sqr = 6}
    if ($Position -in @(57,58,59,66,67,68,75,76,77)) {$this.Sqr = 7}
    if ($Position -in @(60,61,62,69,70,71,78,79,80)) {$this.Sqr = 8}
    if ($Value -notmatch '\d') {
      $this.PossibleValues = @(1,2,3,4,5,6,7,8,9)
      $this.PosValStr = $this.PossibleValues -join ','
      $this.Solved = $false
    }
    else {
      $this.PossibleValues = @($Value)
      $this.PosValStr = $this.PossibleValues -as [string]
      $this.Solved = $true
    }
  } # Constructor
} # Class 

class SudokuGrid {
  [SudokuElement[]]$GameBoard
  [int]$SolvedElements

  SudokuGrid ([string]$BoardString) {
    $this.GameBoard = 0..80 | ForEach-Object {
      [SudokuElement]::New($_,$BoardString[$_])
    }
  }
  [string[]]ShowRelatedValues ($CellIndex) {
    $Cell = $this.GameBoard[$CellIndex]
    [SudokuElement[]]$RelatedCells = $this.GameBoard | 
      Where-Object {$_.Row -eq $Cell.Row -or $_.Col -eq $Cell.Col -or $_.Sqr -eq $Cell.Sqr -and $_.Solved -eq $true} | 
      Sort-Object -Property Value
    return $RelatedCells.Value | Select-Object -Unique
  }
  [void]RemoveRelatedValues () {
    $UnsolvedCells = $this.GameBoard | Where-Object {$_.Solved -eq $false}
    foreach ($CellIndex in $UnsolvedCells.Pos) {
      if ($this.GameBoard[$CellIndex].Solved -eq $false) {
        $RelatedValues = $this.ShowRelatedValues($CellIndex)
        $this.GameBoard[$CellIndex].PossibleValues = $this.GameBoard[$CellIndex].PossibleValues | Where-Object {$_ -notin $RelatedValues}
        $this.GameBoard[$CellIndex].PosValStr = $this.GameBoard[$CellIndex].PossibleValues -as [string]
      }
    }
  }
  [void]SolveNakedSingles() {
    $UnsolvedCells = $this.GameBoard | Where-Object {$_.Solved -eq $false}
    foreach ($CellIndex in $UnsolvedCells.Pos) {
      if ($this.GameBoard[$CellIndex].PossibleValues.Count -eq 1 -and $this.GameBoard[$CellIndex].Solved -eq $false) {
        $this.GameBoard[$CellIndex].Value = $this.GameBoard[$CellIndex].PossibleValues[0]
        $this.GameBoard[$CellIndex].PosValStr = $this.GameBoard[$CellIndex].PossibleValues[0] -as [string]
        $this.GameBoard[$CellIndex].Solved = $true
      }
    }
  }
}
# Functions
function Show-GameBoard {
  Param ($GameArray)
  $Host.UI.RawUI.CursorPosition = @{ X = 0; Y = 0 }
  $RowCount = 0
  $BorderColor = 'Cyan'
  $BorderTopBot = "+-------+-------+-------+"
  Write-Host $BorderTopBot -ForegroundColor $BorderColor
  foreach ($Row in (0..8)) {
    $RowCount++
    Write-Host "| " -NoNewline -ForegroundColor $BorderColor
    $ColCount = 0
    foreach ($Col in (0..8)) {
      $ColCount++
      $CellValue = ($GameArray | Where-Object {$_.Row -eq $Row -and $_.Col -eq $Col}).Value
      If ($CellValue -match '\d') {$ValueColor = 'White'}
      else {$ValueColor = 'Red'}
      Write-Host "$CellValue " -NoNewline -ForegroundColor $ValueColor 
      if ($ColCount -in @(3,6,9)) {Write-Host "| " -NoNewline -ForegroundColor $BorderColor}
    }
    if ($RowCount -in @(3,6)) {Write-Host "`n$BorderTopBot" -NoNewline -ForegroundColor $BorderColor}
    Write-Host
  }
  Write-Host "$BorderTopBot`n" -ForegroundColor $BorderColor
  Start-Sleep -Milliseconds 500
}

$Game = [SudokuGrid]::New($GameBoard)
$Game
Show-GameBoard -GameArray $Game.GameBoard