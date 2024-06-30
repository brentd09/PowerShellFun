<#
Here are some puzzle strings to try:
'7-542--6-68-1--24--4-76--18-91--2-7482--576--3---1482-158--6--9--25-91-6--684-7-2' - EASY
'-9--2-5----4--5-1--6-----93--18---6----9----2-8--72---5----1-7----3--9-1-13------' - Medium
'-9--2-5----4--5-1--6-----93--18---6----9----2-8--72---5----1-7----3--9-1--3------' - Difficult
'--97486--7---------2-1-987---7---24--64-1-59--98---3-----8-3-2---------6---2759--' - Difficult
'-714---------17--59------4-5-8-6341--3--------9-----28-----4-6--6--89--1----3--5-' - Difficult
'-2-6------562-----1------28----2-4-9-914-873-2-8-9----71------3-----217------5-6-' - Difficult
'---4----------8-96----53-8--48------2---49--16-----5-94--1--7---8-9--4---1--7--2-' - Difficult
'89-2-3-------------3658---41-8-3--6-----------2--7-3-57---9412-------------8-2-59' - Extreme
'-2-7---15------6--5--9-----8---------------2---6--4-73--78-1-6---4-7--5---3-49---' = Expert
'--9748---7---------2-1-9-----7---24--64-1-59--98---3-----8-3-2---------6---2759--' - Impossible
'-714---------17--59------4-5-8-634---3--------9-----28-----4-6--6--89--1----3--5-' - Impossible
'----15-74----3-8---87---5-1-23--4----1--7--2----2--79-8-6---24---1-2----23-64----' - impossible
'--7---28---4-25---28---46---9---6---3-------2---1---9---62---75---57-4---78---3--' - impossible 
'1-----569492-561-8-561-924---964-8-1-64-1----218-356-4-4-5---1-9-5-614-2621-----5' - impossible (xwing)
'-----2-----8-6---1-49---7-------58--56-----4---3-----77-46---8----5-1--3-9-3---6-' - impossible
'--72-41-----169---5-------263---2-89-7-----3-12-5---467-------4---931-----36-79--' - Evil
#>
[CmdletBinding()]
Param (
  $SudokuNumbers = '--72-41-----169---5-------263---2-89-7-----3-12-5---467-------4---931-----36-79--'
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

  [bool]FindHiddenSingles () {
    [bool]$FoundOne = $false
    foreach ($Row in @(0..8)) {
      $RowCells = $this.Cells | Where-Object {$_.Row -eq $Row -and $_.Solved -eq $false}
      $SingleVals = ($RowCells.PosVal | Group-Object | Where-Object {$_.Count -eq 1}).Name
      foreach ($Val in $SingleVals) {
        $IntVal = $Val -as [int]
        $SingleCell = $RowCells | Where-Object {$_.PosVal -contains $IntVal}
        $SingleCell.SetValue($IntVal)
        $FoundOne = $true
        break
      }
      if ($FoundOne -eq $true) {break}
    }

    if ($FoundOne -eq $false) {
      $FoundOne = $false
      foreach ($Col in @(0..8)) {
        $ColCells = $this.Cells | Where-Object {$_.Col -eq $Col -and $_.Solved -eq $false}
        $SingleVals = ($ColCells.PosVal | Group-Object | Where-Object {$_.Count -eq 1}).Name
        foreach ($Val in $SingleVals) {
          $IntVal = $Val -as [int]
          $SingleCell = $ColCells | Where-Object {$_.PosVal -contains $IntVal}
          $SingleCell.SetValue($IntVal)
          $FoundOne = $true
          break
        }
        if ($FoundOne -eq $true) {break}
      }
    }

    if ($FoundOne -eq $false) {
      $FoundOne = $false
      foreach ($Blk in @(0..8)) {
        $BlkCells = $this.Cells | Where-Object {$_.Blk -eq $Blk -and $_.Solved -eq $false}
        $SingleVals = ($BlkCells.PosVal | Group-Object | Where-Object {$_.Count -eq 1}).Name
        foreach ($Val in $SingleVals) {
          $IntVal = $Val -as [int]
          $SingleCell = $BlkCells | Where-Object {$_.PosVal -contains $IntVal}
          $SingleCell.SetValue($IntVal)
          $FoundOne = $true
          break
        }
        if ($FoundOne -eq $true) {break}
      }
    }
    return $FoundOne
  }

  [bool]FindNakedSingles () {
    $NakedCells = $this.Cells | Where-Object {$_.Solved -eq $false -and $_.PosVal.Count -eq 1}
    if ($NakedCells.count -gt 0) {
      $RandomNakedCell = $NakedCells | Get-Random
      $RandomNakedCell.SetValue($RandomNakedCell.PosVal[0])
      return $true
    }
    else {return $false}
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

do {
  $ResultHS = $Grid.FindHiddenSingles()
  $Grid.RemoveSolvedFromPossibles()
  Show-Grid -FnGrid $Grid

  $ResultNS = $Grid.FindNakedSingles()
  $Grid.RemoveSolvedFromPossibles()
  Show-Grid -FnGrid $Grid
} until ($ResultHS -eq $false -and $ResultNS -eq $false )