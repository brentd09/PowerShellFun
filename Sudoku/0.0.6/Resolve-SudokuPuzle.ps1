
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
}

$test = [SudokuBoard]::New('7-542--6-68-1--24--4-76--18-91--2-7482--576--3---1482-158--6--9--25-91-6--684-7-2')
$test