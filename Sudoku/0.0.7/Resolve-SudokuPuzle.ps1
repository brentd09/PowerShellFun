<#
.SYNOPSIS
  Solve Sudoku puzzles
.DESCRIPTION
  This will attempt to solve sudoku puzzles by the offical methods: sole candidate, hidden candidate, etc.
  Here are some puzzle strings to try:
  '7-542--6-68-1--24--4-76--18-91--2-7482--576--3---1482-158--6--9--25-91-6--684-7-2' - EASY
  '-9--2-5----4--5-1--6-----93--18---6----9----2-8--72---5----1-7----3--9-1-13------' - Medium
  '-9--2-5----4--5-1--6-----93--18---6----9----2-8--72---5----1-7----3--9-1--3------' - Difficult
  '--97486--7---------2-1-987---7---24--64-1-59--98---3-----8-3-2---------6---2759--' - Difficult
  '-714---------17--59------4-5-8-6341--3--------9-----28-----4-6--6--89--1----3--5-' - Difficult
  '-2-6------562-----1------28----2-4-9-914-873-2-8-9----71------3-----217------5-6-' - Difficult
  '89-2-3-------------3658---41-8-3--6-----------2--7-3-57---9412-------------8-2-59' - Extreme
  '--9748---7---------2-1-9-----7---24--64-1-59--98---3-----8-3-2---------6---2759--' - Impossible
  '-714---------17--59------4-5-8-634---3--------9-----28-----4-6--6--89--1----3--5-' - Impossible
  '----15-74----3-8---87---5-1-23--4----1--7--2----2--79-8-6---24---1-2----23-64----' - impossible
  '--7---28---4-25---28---46---9---6---3-------2---1---9---62---75---57-4---78---3--' - impossible 
  '1-----569492-561-8-561-924---964-8-1-64-1----218-356-4-4-5---1-9-5-614-2621-----5' - impossible (xwing)
.EXAMPLE
  PS C:\> <example usage>
  Explanation of what the example does
.INPUTS
  Inputs (if any)
.OUTPUTS
  Output (if any)
.NOTES
  General notes

    Grid Position numbers
 0  1  2 |  3  4  5 |  6  7  8 
 9 10 11 | 12 13 14 | 15 16 17 
18 19 20 | 21 22 23 | 24 25 26 
---------+----------+---------
27 28 29 | 30 31 32 | 33 34 35 
36 37 38 | 39 40 41 | 42 43 44 
45 46 47 | 48 49 50 | 51 52 53 
---------+----------+---------
54 55 56 | 57 58 59 | 60 61 62 
63 64 65 | 66 67 68 | 69 70 71 
72 73 74 | 75 76 77 | 78 79 80 

#>
[CmdletBinding()]
Param (
  [string]$PuzzleString = '7-542--6-68-1--24--4-76--18-91--2-7482--576--3---1482-158--6--9--25-91-6--684-7-2',
  [switch]$ShowRawData
)
# Class Definitions
class SudokuElement {
  [int]$Position 
  [string]$Value
  [string[]]$PossibleValues
  [int]$Row
  [int]$Col
  [int]$Sqr

  SudokuElement ($Pos,$Val) {
    $this.Position = $Pos
    $this.Value = $Val
    if ($Val -match '\D') {$this.PossibleValues = 1..9}
    else {$this.PossibleValues = 0} # Zero means it has been solved for this element
    $PosCol = $Pos % 9
    $PosRow = [math]::Truncate($Pos/9)
    $this.Col = $PosCol
    $this.Row = $PosRow
    $SqrCol = [math]::Truncate($PosCol/3)    
    $SqrRow = [math]::Truncate($PosRow/3)
    $this.Sqr = (3 * $SqrRow) + $SqrCol
  }

  [void]SolveElement ($SolvedValue) {
    $this.Value = $SolvedValue
    $this.PossibleValues = @(0)
  } 
}

class SudokuBoard {
  [SudokuElement[]]$Board
  [int]$NumberOfUnsolvedElements

  SudokuBoard ($BoardString) {
    $Elements = foreach ($Index in (0..80)) {
      [SudokuElement]::New($Index,$BoardString[$Index])
    }
    $this.Board = $Elements
    $this.NumberOfUnsolvedElements = ($Elements | Where-Object {$_.Value -match '\D'}).count
  }
  
  [void]ResolveNumberOfUnsolvedElements () {
    $this.NumberOfUnsolvedElements = ($this.Board | Where-Object {$_.Value -match '\D'}).count
  }
}

# Function Definitions
function Compare-Arrays {  
  [CmdletBinding()]
  Param (
    [Parameter(Mandatory=$true)]
    [string[]]$Array1,
    [Parameter(Mandatory=$true)]
    [string[]]$Array2
  )
  $A1inA2    = @()
  $A1notinA2 = @()
  $A2inA1    = @()
  $A2notinA1 = @()
  
  foreach ($Array1Element in $Array1) {
    if ($Array1Element -in $Array2) {$A1inA2 += $Array1Element}
    else {$A1notinA2 += $Array1Element}
  }
  foreach ($Array2Element in $Array2) {
    if ($Array2Element -in $Array1) {$A2inA1 += $Array2Element}
    else {$A2notinA1 += $Array2Element}
  }
  if ($A1notinA2.count -eq 0 -and $A2notinA1.count -eq 0 ) {$ArraysSame = $true}
  else {$ArraysSame=$false}
  $ObjHash = [ordered]@{
    Array1 = $Array1
    Array2 = $Array2
    ElementsCommon = $A1inA2
    UniqueToArray1 = $A1notinA2
    UniqueToArray2 = $A2notinA1
    ArraysEqual = $ArraysSame
  }
  New-Object -TypeName psobject -Property $ObjHash
}
function Show-Sudoku {
  Param (
    [SudokuBoard]$fnSudoku,
    [Switch]$RawData
  )
  if ($RawData -eq $true) {$fnSudoku.Board | format-table}
  else {
    $Coords = New-Object -TypeName System.Management.Automation.Host.Coordinates
    $host.UI.RawUI.CursorPosition = $Coords
    $FGColor = 'Yellow'
    Write-Host -ForegroundColor Green "    Solve  Sudoku`n"
    foreach ($PosCol in (0..8)) {
      if ($PosCol -eq 2 -or $PosCol -eq 5) {$HBdr = "`n------+-------+------"}
      else {$HBdr = ''}
      foreach ($PosRow in (0..8)) {
        if ($PosRow -eq 2 -or $PosRow -eq 5) {$Bdr = ' | '}
        else {$Bdr = ' '}
        Write-Host -NoNewline $fnSudoku.Board[($PosRow+($PosCol*9))].Value
        Write-Host -NoNewline -ForegroundColor $FGColor "$Bdr"
      }
      Write-Host -ForegroundColor $FGColor $HBdr
    }
    Write-Host
    Start-Sleep -Seconds 1
  }
}
function Find-Possible {
  Param (
    [SudokuBoard]$fnSudoku
  )
  foreach ($Pos in (0..80)) {
    if ($fnSudoku.Board[$Pos].Value -match '\D') {
      $CurrentCell = $fnSudoku.Board[$Pos]
      $Row = $CurrentCell.Row
      $Col = $CurrentCell.Col
      $Sqr = $CurrentCell.Sqr
      $RelatedSolvedCells = $fnSudoku.Board | Where-Object {($_.Col -eq $Col -or $_.Row -eq $Row -or $_.Sqr -eq $sqr) -and $_.Value -match '\d'}
      $RelatedSortedUnique = $RelatedSolvedCells.Value  | Select-Object -Unique | Sort-Object
      $AllPossibleNumbers = 1..9
      $MissingNumbers = foreach ($EachPossibleNumber in $AllPossibleNumbers) {
        if ($EachPossibleNumber -notin $RelatedSortedUnique) {$EachPossibleNumber}
      }
      $CurrentCell.PossibleValues = $MissingNumbers
    }
  }
}


function Find-Unique {
  Param (
    [SudokuBoard]$fnSudoku
  )
  foreach ($Pos in (0..80)) {
    if ($fnSudoku.Board[$Pos].PossibleValues.Count -eq 1 -and $fnSudoku.Board[$Pos].PossibleValues -ne 0) {
      $CurrentCell = $fnSudoku.Board[$Pos]
      $CurrentCell.SolveElement($CurrentCell.PossibleValues[0])
    }
  }
}

function Find-HiddenPair {
  Param (
    [SudokuBoard]$fnSudoku
  )
  $Rows = 0..8
  $Cols = 0..8
  $Sqrs = 0..8
  foreach ($Row in $Rows) {
    $HiddenPairs = $fnSudoku.Board | Where-Object {$_.Row -eq $Row -and $_.Value -match '\D' -and $_.PossibleValues.Count -eq 2}
    $PairsJoined = foreach ($Pair in $HiddenPairs) {$Pair -join ','}
    $HiddenPairsValues = $PairsJoined | Group-Object | Where-Object {$_.Count -eq 2}
    foreach ($HiddenPairValues in $HiddenPairsValues) {
      [int[]]$Values = $HiddenPairValues.Name -split ','
    }
  }
}

function Find-SinglePossible {
  Param (
    [SudokuBoard]$fnSudoku
  )
}
# Main Code
Clear-Host
$Puzzle = [SudokuBoard]::New($PuzzleString)
Show-Sudoku -fnSudoku $Puzzle  -RawData:$ShowRawData


do { 
  Find-Possible -fnSudoku $Puzzle
  Find-Unique -fnSudoku $Puzzle
  Show-Sudoku -fnSudoku $Puzzle
} until (($Puzzle.Board | Where-Object {$_.PossibleValues -contains 0}).count -eq 81 )  

