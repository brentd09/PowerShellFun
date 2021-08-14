[CmdletBinding()]
Param(
  [String]$GameBoard = '7-542--6-68-1--24--4-76--18-91--2-7482--576--3---1482-158--6--9--25-91-6--684-7-2'
)

Class SudokuElement {
  [int]$Pos 
  [string]$Value
  [int]$Row 
  [int]$Col 
  [int]$Sqr
  [string[]]$PossibleValues
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
      $this.Solved = $false
    }
    else {
      $this.PossibleValues = @($Value)
      $this.Solved = $true
    }
  } # Constructor
  [void]Solve($Value) {
    $this.Value = $Value
    $this.Solved = $true
    $this.PossibleValues = @($Value)
  } # Method Solved
  [void]RemoveFromPossibles([int[]]$Values) {
    $NewPoss = @()
    $NewPoss = foreach ($Poss in $this.PossibleValues) {
      if ($Poss -notin $Values) {$Poss}
    }
    $this.PossibleValues = $NewPoss
  } # method RemoveFromPossibles
  [void]CheckForSinglePossible() {
    if ($this.PossibleValues.Count -eq 1) {
      $this.Solved($this.PossibleValues[0])
    }
  }
} # Class 

class SudokuGrid {
  [SudokuElement[]]$GameBoard
  [int]$SolvedElements

  SudokuGrid ($BoardArray) {
    $this.GameBoard = $BoardArray
    $this.SolvedElements = ($BoardArray| Where-Object {$_.Solved -eq $true}).Count
  }
  [string[]]SolvedRowNumbers ($RowNumber) {
    return ($this.GameBoard | 
      Where-Object {$_.Row -eq $RowNumber -and $_.Solved -eq $true}).Value | 
      Sort-Object | 
      Select-Object -Unique
  }
  [string[]]SolvedColNumbers ($ColNumber) {
    return ($this.GameBoard | 
      Where-Object {$_.Col -eq $ColNumber -and $_.Solved -eq $true}).Value | 
      Sort-Object | 
      Select-Object -Unique
  }
  [SudokuElement[]]NotSolvedInRow ($RowNumber) {
    return $this.GameBoard | Where-Object {$_.Row -eq $RowNumber -and $_.Solved -eq $false}
  }
  [SudokuElement[]]NotSolvedInCol ($ColNumber) {
    return $this.GameBoard | Where-Object {$_.Col -eq $ColNumber -and $_.Solved -eq $false}
  }
}
# Functions
function Show-GameBoard {
  Param ($GameArray)
  foreach ($Row in (0..8)) {
    foreach ($Col in (0..8)) {
      Write-Host (($GameArray | Where-Object {$_.Row -eq $Row -and $_.Col -eq $Col}).Value + " ") -NoNewline
    }
    Write-Host
  }
}
<#
Methods for solving puzzle - from https://www.sudoku-solutions.com/
  RatingSolution    Techniques
  --------------    ----------
  Simple            Naked Single - A cell that only has one value possible
                    Hidden Single - A row or col that contains one cell with the possible value
  Easy              Naked Pair - two cells in a row/col that only contain the same two possible values
                    Hidden Pair - two cells contains two values not in other cells - remove other values from two cells
                    Pointing Pairs - remove possible value from sqr, one r/c contains a value not found in other sqrs
  Medium            Naked Triple -
                    Naked Quad -
                    Pointing Triples -
                    Hidden Triple -
                    Hidden Quad -
  Hard              XWing -
                    Swordfish -
                    Jellyfish -
                    XYWing -
                    XYZWing -
#>
# Main code

$Position = 0 
$GameArray =   foreach ($SudokuCell in $GameBoard.ToCharArray()) {
  [SudokuElement]::New($Position,$SudokuCell)
  $Position++
} 
$Game = [SudokuGrid]::New($GameArray)

Show-GameBoard -GameArray $Game.GameBoard
