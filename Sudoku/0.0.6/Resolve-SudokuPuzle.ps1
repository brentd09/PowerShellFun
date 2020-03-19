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
#>
[CmdletBinding()]
Param (
  [string]$PuzzleString = '-9--2-5----4--5-1--6-----93--18---6----9----2-8--72---5----1-7----3--9-1-13------',
  [switch]$ShowRawData
)
# Class Definitions
class SudokuElement {
  [int]$Position 
  [string]$Value
  [string[]]$PossibleValues
  [string[]]$ImpossibleValues
  [int]$Row
  [int]$Col
  [int]$Sqr

  SudokuElement ($Pos,$Val) {
    $this.Position = $Pos
    $this.Value = $Val
    if ($Val -match '\D') {$this.PossibleValues = 1..9}
    else {$this.PossibleValues = $Val}
    $this.ImpossibleValues = @()
    $PosCol = $Pos % 9
    $PosRow = [math]::Truncate($Pos/9)
    $this.Col = $PosCol
    $this.Row = $PosRow
    $SqrCol = [math]::Truncate($PosCol/3)    
    $SqrRow = [math]::Truncate($PosRow/3)
    $this.Sqr = (3 * $SqrRow) + $SqrCol
  }
}

class SudokuBoard {
  [SudokuElement[]]$Board
  [int]$UnsolvedElements

  SudokuBoard ($BoardString) {
    $Elements = foreach ($Index in (0..80)) {
      [SudokuElement]::New($Index,$BoardString[$Index])
    }
    $this.Board = $Elements
    $this.UnsolvedElements = ($Elements | Where-Object {$_.Value -match '\D'}).count
  }
  
  [void]ResolveUnsolved () {
    $this.UnsolvedElements = ($this.Board | Where-Object {$_.Value -match '\D'}).count
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
function Resolve-NumbersMissing {
  Param (
    [SudokuBoard]$FnSudoku
  )
  foreach ($Index in (0..80)) {
    if ($FnSudoku.Board[$index].Value -match '\D') {
      $RelatedCol = $FnSudoku.Board[$index].Col
      $RelatedRow = $FnSudoku.Board[$index].Row
      $RelatedSqr = $FnSudoku.Board[$index].Sqr
      $AllRelatedValues = $FnSudoku.board | 
       Where-Object {$_.Value -match '\d' -and ($_.Row -eq $RelatedRow -or $_.Col -eq $RelatedCol -or $_.Sqr -eq $RelatedSqr)}
      $UniqueRelatedValues = $AllRelatedValues.Value | Select-Object -Unique | Sort-Object 
      $NumbersMissing = (Compare-Arrays -Array1 (1..9) -Array2 $UniqueRelatedValues).UniqueToArray1
      if ($NumbersMissing.count -eq 1) {$FnSudoku.Board[$Index].Value = $NumbersMissing[0]} # Sole Candidate
      $FnSudoku.Board[$index].PossibleValues = $NumbersMissing
    }
    $FnSudoku.ResolveUnsolved()
  }
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
    #Start-Sleep -Seconds 1
  }
}

function Resolve-Unique {
  param (
    [SudokuBoard]$fnSudoku
  )
  foreach ($Index in (0..8)) {
    $SqrCells = $fnSudoku.Board | Where-Object {$_.Sqr -eq $Index -and $_.Value -eq '-'}
    $SqrCellsValues =  $SqrCells.PossibleValues 
    $UniqueValues = ($SqrCellsValues | Sort-Object | Group-Object | Where-Object {$_.count -eq 1}).Name
    foreach ($UniqueValue in $UniqueValues) {
      $WhichCell = $SqrCells | Where-Object {$_.PossibleValues -contains $UniqueValue}
      $fnSudoku.Board[$WhichCell.Position].Value = $UniqueValue
    } # Unique Candidate
  }
}

function Find-NakedPair {
  Param (
    [SudokuBoard]$fnSudoku
  )
  $TwoPossible = $fnSudoku.Board | Where-Object {$_.PossibleValues.count -eq 2}
  foreach ($TwoPoss in $TwoPossible) {
    $TwosLeft = $TwoPossible | Where-Object {$_.Position -ne $TwoPoss.Position}
    foreach ($EachTwosLeft in $TwosLeft) {
      $ArrayCompare = Compare-Arrays $TwoPoss.PossibleValues $EachTwosLeft.PossibleValues
      if ($ArrayCompare.ArraysEqual) {
        # Check if they have any Col,Row,Sqr in common
      }
      # compare possible for a match and then check if the are in the same row or col or sqr
    }
  }
}

function Find-PointingPair {
  Param ([SudokuBoard]$fnSudoku)
  # find same number (2-3 instances) on a row or col that is restricted to a sqr and 
  # eliminate the number from all other cells in the sqr
  foreach ($RowNum in 0..8) {
    $RowCells = $fnSudoku.Board | Where-Object {$_.Row -eq $RowNum}
    $RowCells | Where-Object {$_.possiblevalues.count -gt 1} | Select-Object *,@{n='PV';e={$_.possiblevalues -join ''}} | ft
    $RowCells.PossibleValues | Group-Object | Where-Object {$_.count -ge 2 -and $_.count -le 3}
    Start-Sleep -Milliseconds 10
  } 
}

function Find-Impossible {
  Param (
    [SudokuBoard]$fnSudoku
  )

}
# Main Code
Clear-Host
$Puzzle = [SudokuBoard]::New($PuzzleString)
Show-Sudoku -fnSudoku $Puzzle -RawData:$ShowRawData


do { 
  $UnsolvedBefore = $Puzzle.UnsolvedElements
  Resolve-NumbersMissing -fnSudoku $Puzzle
  $UnsolvedAfter = $Puzzle.UnsolvedElements
  Show-Sudoku -fnSudoku $Puzzle -RawData:$ShowRawData
  if ($UnsolvedBefore -eq $UnsolvedAfter) {
    Resolve-Unique -fnSudoku $Puzzle
    Find-PointingPair -fnSudoku $Puzzle
  } 
  Show-Sudoku -fnSudoku $Puzzle -RawData:$ShowRawData
} until ($Puzzle.UnsolvedElements -eq 0 )  

