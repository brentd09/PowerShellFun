[CmdletBinding()]
Param (
  $SudokuNumbers = '-9--2-5----4--5-1--6-----93--18---6----9----2-8--72---5----1-7----3--9-1-13------'
)


Class SudokuCell {
  [int]$Pos 
  [int]$Row
  [int]$Col
  [int]$Blk
  [System.Collections.ArrayList]$PosVal
  [int]$Val  
  [string]$DisplayVal
  [bool]$Solved
  
  SudokuCell ([int]$Position,[string]$StrValue) {
    $Value = 0
    if ($StrValue -in '1','2','3','4','5','6','7','8','9') {$Value = $StrValue -as [int]}
    $this.Pos = $Position
    $this.Row = [math]::Truncate($Position / 9)
    $this.Col = $Position % 9
    if     ($Position -in  0, 1, 2, 9,10,11,18,19,20) {$this.Blk = 0}
    elseif ($Position -in  3, 4, 5,12,13,14,21,22,23) {$this.Blk = 1}
    elseif ($Position -in  6, 7, 8,15,16,17,24,25,26) {$this.Blk = 2}
    elseif ($Position -in 27,28,29,36,37,38,45,46,47) {$this.Blk = 3}
    elseif ($Position -in 30,31,32,39,40,41,48,49,50) {$this.Blk = 4}
    elseif ($Position -in 33,34,35,42,43,44,51,52,53) {$this.Blk = 5}
    elseif ($Position -in 54,55,56,63,64,65,72,73,74) {$this.Blk = 6}
    elseif ($Position -in 57,58,59,66,67,68,75,76,77) {$this.Blk = 7}
    elseif ($Position -in 60,61,62,69,70,71,78,79,80) {$this.Blk = 8}
    $this.PosVal = @(1,2,3,4,5,6,7,8,9)
    if ($Value -in 1,2,3,4,5,6,7,8,9) {
      $this.SetValue($Value)
    }
    else {
      $this.Val = 0
      $this.DisplayVal = "-"
      $this.Solved = $false
    }

  }

  [void]RemoveFromPossible ([int[]]$ValuesToRemove) {
    foreach ($ValueToRemove in $ValuesToRemove) {
      $this.PosVal.Remove($ValueToRemove)
    }
  }

  [void]CheckSinglePossible() {
    if ($this.PosVal.Count -eq 1) {
      $Value = $this.PosVal[0]
      $this.SetValue($Value)
    }
  }

  [void]SetValue ([int]$Value) {
    $this.Val = $Value
    $this.PosVal = @($Value)
    $this.DisplayVal = $Value -as [string]
    $this.Solved = $true
  }
}

class SudokuGrid {
  [SudokuCell[]]$Cells

  SudokuGrid ($SudokuCells) {
    $this.Cells = $SudokuCells
  }

  [void]RemoveSolvedFromPossibles () {
    foreach ($Cell in $this.Cells) {
      if ($Cell.Solved -eq $true) {Continue}
      $RelatedCells = $this.Cells | Where-Object {$_.Blk -eq $Cell.Blk -or $_.Col -eq $Cell.Col -or $_.Row -eq $Cell.Row} | Where-Object {$_.Pos -ne $Cell.Pos}
      $SolvedRelatedCells = $RelatedCells | Where-Object {$_.Solved -eq $true}
      $SolvedValues = $SolvedRelatedCells.Val | Select-Object -Unique | Sort-Object
      $Cell.RemoveFromPossible($SolvedValues)
    }
  }
}


# Functions
function Show-Grid {
  Param ([SudokuGrid]$FnGrid)
  
  Clear-Host
  # Boundary box characters and color
  $V = [char]9475 ;    $H = [char]9473;    $C = [char]9547
  $LTC = [char]9487; $RTC = [char]9491;  $LBC = [char]9495; $RBC = [char]9499
  $LT = [char]9507;   $RT = [char]9515;   $TT = [char]9523;  $BT = [char]9531
  $Color = 'Green'
  
  Write-Host -ForegroundColor $Color "   ---- Solve  Sudoku ----"
  Write-Host -ForegroundColor $Color "    1 2 3   4 5 6   7 8 9"
  Write-Host -ForegroundColor $Color "  $LTC$H$H$H$H$H$H$H$TT$H$H$H$H$H$H$H$TT$H$H$H$H$H$H$H$RTC"
  0,9,18,27,36,45,54,63,72 | ForEach-Object {
    $RowRef = @('A','B','C','D','E','F','G','H','I')[($_ / 9)]
    Write-Host -NoNewline -ForegroundColor $Color "$RowRef $V "   
    Write-Host -NoNewline $FnGrid.Cells.DisplayVal[$_..($_ + 2)]
    Write-Host -NoNewline -ForegroundColor $Color " $V "
    Write-Host -NoNewline $FnGrid.Cells.DisplayVal[($_ + 3)..($_ + 5)]
    Write-Host -NoNewline -ForegroundColor $Color " $V "
    Write-Host -NoNewline $FnGrid.Cells.DisplayVal[($_ + 6)..($_ + 8)]
    Write-Host -ForegroundColor $Color " $V "  
    if ($_ -in 18,45){Write-Host -ForegroundColor $Color "  $LT$H$H$H$H$H$H$H$C$H$H$H$H$H$H$H$C$H$H$H$H$H$H$H$RT"}
  }
    Write-Host -ForegroundColor $Color "  $LBC$H$H$H$H$H$H$H$BT$H$H$H$H$H$H$H$BT$H$H$H$H$H$H$H$RBC"
}


function Show-SketchGrid {
  Param ([SudokuGrid]$FnGrid)
  
  Clear-Host
  # Boundary box characters and color
  $V = [char]9475 ;    $H = [char]9473;    $C = [char]9547
  $LTC = [char]9487; $RTC = [char]9491;  $LBC = [char]9495; $RBC = [char]9499
  $LT = [char]9507;   $RT = [char]9515;   $TT = [char]9523;  $BT = [char]9531
  $Color = 'Green'

  
  
  Write-Host -ForegroundColor $Color "   ---- Solve  Sudoku ----"
  Write-Host -ForegroundColor $Color "    1 2 3   4 5 6   7 8 9"
  Write-Host -ForegroundColor $Color "  $LTC$H$H$H$H$H$H$H$TT$H$H$H$H$H$H$H$TT$H$H$H$H$H$H$H$RTC"
  0,9,18,27,36,45,54,63,72 | ForEach-Object {
    $RowRef = @('A','B','C','D','E','F','G','H','I')[($_ / 9)]
    Write-Host -NoNewline -ForegroundColor $Color "$RowRef $V "   
    Write-Host -NoNewline $FnGrid.Cells.DisplayVal[$_..($_ + 2)]
    Write-Host -NoNewline -ForegroundColor $Color " $V "
    Write-Host -NoNewline $FnGrid.Cells.DisplayVal[($_ + 3)..($_ + 5)]
    Write-Host -NoNewline -ForegroundColor $Color " $V "
    Write-Host -NoNewline $FnGrid.Cells.DisplayVal[($_ + 6)..($_ + 8)]
    Write-Host -ForegroundColor $Color " $V "  
    if ($_ -in 18,45){Write-Host -ForegroundColor $Color "  $LT$H$H$H$H$H$H$H$C$H$H$H$H$H$H$H$C$H$H$H$H$H$H$H$RT"}
  }
    Write-Host -ForegroundColor $Color "  $LBC$H$H$H$H$H$H$H$BT$H$H$H$H$H$H$H$BT$H$H$H$H$H$H$H$RBC"
}





# Main Code
$CellArray =foreach ($PosInGrid in (0..80)) {
   [SudokuCell]::New($PosInGrid,$SudokuNumbers[$PosInGrid]) 
} 
$Grid = [SudokuGrid]::New($CellArray)
$Grid.RemoveSolvedFromPossibles()
Show-Grid -FnGrid $Grid