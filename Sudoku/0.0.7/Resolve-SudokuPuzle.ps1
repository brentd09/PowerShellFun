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
  [string]$PuzzleString = '-------1-5-----9----96-2--51-8--573---67-4---2-5--689---18-7--33-----2---------4-',
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
  [bool]$Solved

  SudokuElement ($Pos,$Val) {
    $this.Position = $Pos
    $this.Value = $Val
    if ($Val -match '\D') {
      $this.PossibleValues = 1..9
      $this.Solved = $false
    }
    else {
      $this.PossibleValues = @($Val)
      $this.Solved = $true
    } 
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
    $this.PossibleValues = @($SolvedValue)
    $this.Solved = $true
  } 

  [void]RemoveValuesFromPossible ([string[]]$ValuesToRemove){
    $NewPossibles = $this.PossibleValues | Where-Object {$_ -notin $ValuesToRemove}
    if ($NewPossibles.Count -lt $this.PossibleValues.Count) {$this.PossibleValues = $NewPossibles}
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
    $this.NumberOfUnsolvedElements = ($this.Board | Where-Object {$_.Solved -eq $false}).count
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
function Find-InitialPossible {
  Param (
    [SudokuBoard]$fnSudoku
  )
  foreach ($Pos in (0..80)) {
    if ($fnSudoku.Board[$Pos].Solved -eq $false) {
      $CurrentCell = $fnSudoku.Board[$Pos]
      $Row = $CurrentCell.Row
      $Col = $CurrentCell.Col
      $Sqr = $CurrentCell.Sqr
      $RelatedSolvedCells = $fnSudoku.Board | Where-Object {($_.Col -eq $Col -or $_.Row -eq $Row -or $_.Sqr -eq $sqr) -and $_.Solved -eq $true}
      $RelatedSortedUnique = $RelatedSolvedCells.Value  | Select-Object -Unique | Sort-Object
      $AllPossibleNumbers = 1..9
      $MissingNumbers = foreach ($EachPossibleNumber in $AllPossibleNumbers) {
        if ($EachPossibleNumber -notin $RelatedSortedUnique) {$EachPossibleNumber}
      }
      $CurrentCell.PossibleValues = $MissingNumbers
    }
  }
}

function Clear-RelatedPossibleValues {
  Param (
    [SudokuElement]$ReferenceElement,
    [SudokuBoard]$fnSudoku
  )
  $UnsolvedRelatedElements = $fnSudoku.Board | Where-Object {($_.Row -eq $ReferenceElement.Row -or 
                                                              $_.Col -eq $ReferenceElement.Col -or 
                                                              $_.Sqr -eq $ReferenceElement.Sqr) -and 
                                                              $_.Solved -eq $false}
  foreach ($UnsolvedRelatedElement in $UnsolvedRelatedElements) {
    $NewPossibleValues = $UnsolvedRelatedElement.PossibleValues | Where-Object {$_ -notin $ReferenceElement.PossibleValues}
    $UnsolvedRelatedElement.PossibleValues = $NewPossibleValues
  }
}



function Resolve-NakedSingle {
  Param (
    [SudokuBoard]$fnSudoku
  )
  $UniqueValueElements = $fnSudoku.board | Where-Object {$_.PossibleValues.Count -eq 1 -and $_.Solved -eq $false}
  if ($UniqueValueElements.Count -ge 1) {
    $UniqueValueElement =  $UniqueValueElements | Get-Random
    $UniqueValueElement.SolveElement($UniqueValueElement.PossibleValues[0])
    Clear-RelatedPossibleValues -ReferenceElement $UniqueValueElement -fnSudoku $fnSudoku
    return $true
  }
  else {return $false}
}

function Resolve-HiddenSingle {
  Param (
    [SudokuBoard]$fnSudoku
  )
  $RowFlag = $false
  $ColFlag = $false
  foreach ($Row in @(0..8)) {
    $ElementGroup = $fnSudoku.Board  | Where-Object {$_.Row -eq $Row -and $_.Solved -eq $false}
    if ($ElementGroup.Count -ge 1) { 
      $HiddenSingleValues = ($ElementGroup.PossibleValues | Group-Object | Where-Object {$_.Count -eq 1}).Name
      if ($HiddenSingleValues.Count -ge 1) {
        $HiddenSingleValue = $HiddenSingleValues | Get-Random
        $HiddenSingleElement = $ElementGroup | Where-Object {$_.PossibleValues -contains $HiddenSingleValue}
        $HiddenSingleElement.SolveElement($HiddenSingleValue)
        Clear-RelatedPossibleValues -ReferenceElement $HiddenSingleElement -fnSudoku $fnSudoku
        $RowFlag = $true
        return $true
      }
    }
  }
  if ($RowFlag -eq $false) {
    foreach ($Col in @(0..8)) {
      $ElementGroup = $fnSudoku.Board  | Where-Object {$_.Col -eq $Col -and $_.Solved -eq $false}
      if ($ElementGroup.Count -ge 1) { 
        $HiddenSingleValues = ($ElementGroup.PossibleValues | Group-Object | Where-Object {$_.Count -eq 1}).Name
        if ($HiddenSingleValues.Count -ge 1) {
          $HiddenSingleValue = $HiddenSingleValues | Get-Random
          $HiddenSingleElement = $ElementGroup | Where-Object {$_.PossibleValues -contains $HiddenSingleValue}
          $HiddenSingleElement.SolveElement($HiddenSingleValue)
          Clear-RelatedPossibleValues -ReferenceElement $HiddenSingleElement -fnSudoku $fnSudoku
          $ColFlag = $true
          return $true
        }
      }
    }
  }
  elseif ($RowFlag -eq $false -and $ColFlag -eq $false) {    
    foreach ($Sqr in @(0..8)) {
      $ElementGroup = $fnSudoku.Board  | Where-Object {$_.Sqr -eq $Sqr -and $_.Solved -eq $false}
      if ($ElementGroup.Count -ge 1) { 
        $HiddenSingleValues = ($ElementGroup.PossibleValues | Group-Object | Where-Object {$_.Count -eq 1}).Name
        if ($HiddenSingleValues.Count -ge 1) {
          $HiddenSingleValue = $HiddenSingleValues | Get-Random
          $HiddenSingleElement = $ElementGroup | Where-Object {$_.PossibleValues -contains $HiddenSingleValue}
          $HiddenSingleElement.SolveElement($HiddenSingleValue)
          Clear-RelatedPossibleValues -ReferenceElement $HiddenSingleElement -fnSudoku $fnSudoku
          return $true
        }
      }
    }
  }
  else {
    return $false
  }
}

function Resolve-NakedPair {
  Param (
    [SudokuBoard]$fnSudoku
  )
  $RowFlag = $false
  $ColFlag = $false
  foreach ($Row in @(0..8)) {
    $ElementGroup = $fnSudoku.Board  | Where-Object {$_.Row -eq $Row -and $_.Solved -eq $false}
    $PairedValueElements = $ElementGroup | Where-Object {$_.PossibleValues.Count -eq 2}
    if ($PairedValueElements.Count -ge 2) {
      $GroupedPairValues = $PairedValueElements.Value | Group-Object 
      $NakedPairValueGroups = $GroupedPairValues | Where-Object {$_.Count -eq 2}
      foreach ($NakedPairValueGroup in $NakedPairValueGroups) {
        $ElementsToChange = $ElementGroup | Where-Object {(Compare-Arrays -Array1 $_.PossibleValues -Array2 $NakedPairValueGroup.Name).ArraysEqual -ne $true}
        foreach ($ElementToChange in $ElementsToChange) {
          $ElementToChange.RemoveValuesFromPossible($NakedPairValueGroup.Name)
          $RowFlag = $true
        }
      }
    }
  }
  if ($RowFlag -eq $false) {
    foreach ($Col in @(0..8)) {
      $ElementGroup = $fnSudoku.Board  | Where-Object {$_.Col -eq $Col -and $_.Solved -eq $false}
      $PairedValueElements = $ElementGroup | Where-Object {$_.PossibleValues.Count -eq 2}
      if ($PairedValueElements.Count -ge 2) {
        $GroupedPairValues = $PairedValueElements.Value | Group-Object 
        $NakedPairValueGroups = $GroupedPairValues | Where-Object {$_.Count -eq 2}
        foreach ($NakedPairValueGroup in $NakedPairValueGroups) {
          $ElementsToChange = $ElementGroup | Where-Object {(Compare-Arrays -Array1 $_.PossibleValues -Array2 $NakedPairValueGroup.Name).ArraysEqual -ne $true}
          foreach ($ElementToChange in $ElementsToChange) {
            $ElementToChange.RemoveValuesFromPossible($NakedPairValueGroup.Name)
            $ColFlag = $true
          }
        }
      }
    }
  }
  elseif ($RowFlag -eq $false -and $ColFlag -eq $false) {
    foreach ($Sqr in @(0..8)) {
      $ElementGroup = $fnSudoku.Board  | Where-Object {$_.Sqr -eq $Sqr -and $_.Solved -eq $false}
      $PairedValueElements = $ElementGroup | Where-Object {$_.PossibleValues.Count -eq 2}
      if ($PairedValueElements.Count -ge 2) {
        $GroupedPairValues = $PairedValueElements.Value | Group-Object 
        $NakedPairValueGroups = $GroupedPairValues | Where-Object {$_.Count -eq 2}
        foreach ($NakedPairValueGroup in $NakedPairValueGroups) {
          $ElementsToChange = $ElementGroup | Where-Object {(Compare-Arrays -Array1 $_.PossibleValues -Array2 $NakedPairValueGroup.Name).ArraysEqual -ne $true}
          foreach ($ElementToChange in $ElementsToChange) {
            $ElementToChange.RemoveValuesFromPossible($NakedPairValueGroup.Name)
          }
        }
      }
    }
  }   
  else {
    return $false
  } 
}

# Main Code
Clear-Host
$Puzzle = [SudokuBoard]::New($PuzzleString)
Show-Sudoku -fnSudoku $Puzzle  -RawData:$ShowRawData

Find-InitialPossible -fnSudoku $Puzzle
do { 
  do {
    $NSResult = Resolve-NakedSingle -fnSudoku $Puzzle
    Show-Sudoku -fnSudoku $Puzzle
  } until ($NSResult -eq $false)
do {
  $HSResult = Resolve-HiddenSingle -fnSudoku $Puzzle
  Show-Sudoku -fnSudoku $Puzzle
} until ($HSResult -eq $false)
Resolve-NakedPair -fnSudoku $Puzzle  
} while ($Puzzle.Board.Solved -contains $false )

