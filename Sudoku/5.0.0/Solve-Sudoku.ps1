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
'-2-7---15------6--5--9-----8---------------2---6--4-73--78-1-6---4-7--5---3-49---' = Expert (pointing pairs, hidden pairs)
'--9748---7---------2-1-9-----7---24--64-1-59--98---3-----8-3-2---------6---2759--' - Impossible (swordfish)
'-714---------17--59------4-5-8-634---3--------9-----28-----4-6--6--89--1----3--5-' - Impossible
'----15-74----3-8---87---5-1-23--4----1--7--2----2--79-8-6---24---1-2----23-64----' - impossible (swordfish)
'--7---28---4-25---28---46---9---6---3-------2---1---9---62---75---57-4---78---3--' - impossible 
'1-----569492-561-8-561-924---964-8-1-64-1----218-356-4-4-5---1-9-5-614-2621-----5' - impossible (xwing)
'-----2-----8-6---1-49---7-------58--56-----4---3-----77-46---8----5-1--3-9-3---6-' - impossible
'--72-41-----169---5-------263---2-89-7-----3-12-5---467-------4---931-----36-79--' - Difficult
#>
[CmdletBinding()]
Param (
  [string]$SudokuNumbers = '4-3-8-2-6----6----1--5-7--4--1---3--85-----17--9---6--6--9-8--2----4----3-5-1-7-9',
  [switch]$SketchMarks
)

if ($SudokuNumbers.Length -ne 81) {
  Write-Warning "The number of positions in the Sudoku Numbers does not equal 81"
  break
} 

# #########################################################################################
# Classes
Class SudokuCell {
  [int]$Pos 
  [int]$Row
  [int]$Col
  [int]$Blk
  [string]$Coords
  [System.Collections.ArrayList]$PosVal
  [string]$PosValStr
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
    $RowCoord = [char](([math]::Truncate($Position / 9) + 65) -as [int] )
    $ColCoord = ($Position % 9) + 1
    $this.Coords = $RowCoord + $ColCoord
    $this.PosVal = @(1,2,3,4,5,6,7,8,9)
    $this.PosValStr = (@(1,2,3,4,5,6,7,8,9) | Sort-Object) -join ''
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
      if ($this.PosVal -contains $ValueToRemove) {$this.PosVal.Remove($ValueToRemove)}
    }
    $this.PosValStr = ($this.PosVal | Sort-Object) -join ''
  }

  [void]RemoveAllOthersFromPossible ([int[]]$ValuesToRemain) {
    $ValuesToRemove = 1..9 | Where-Object {($_ -notin $ValuesToRemain)}
    foreach ($ValueToRemove in $ValuesToRemove) {
      if ($this.PosVal -contains $ValueToRemove) {$this.PosVal.Remove($ValueToRemove)}
    }
    $this.PosValStr = ($this.PosVal | Sort-Object) -join ''
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
    $this.PosValStr = $Value -as [string] 
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

  [void]FindHiddenSingles () {
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
  }

  [void]FindNakedSingles () {
    $NakedCells = $this.Cells | Where-Object {$_.Solved -eq $false -and $_.PosVal.Count -eq 1}
    if ($NakedCells.count -gt 0) {
      $RandomNakedCell = $NakedCells | Get-Random
      $RandomNakedCell.SetValue($RandomNakedCell.PosVal[0])
    }
  }
  [void]FindNakedPairs () {
    [bool]$FoundOne = $false
    foreach ($Row in @(0..8)) {
      $RowCells = $this.Cells | Where-Object {$_.Solved -eq $false -and $_.Row -eq $Row}
      $NPRowCells = $RowCells | Where-Object {$_.PosVal.count -eq 2}
      $NakedPairStrs = ($NPRowCells.PosValStr | Group-Object | Where-Object {$_.Count -eq 2}).Name
      foreach ($NakedPairStr in $NakedPairStrs) {
        $NakedPairCells = $NPRowCells | Where-Object {$_.PosValStr -eq $NakedPairStr}
        if ($NakedPairCells.count -eq 2) {
          $NakedCellsPos = $NakedPairCells.Pos
          $NakedCellVals = $NakedPairCells[0].PosVal
          $RemainingNPRowCells = $RowCells | Where-Object {$_.Pos -notin $NakedCellsPos}
          foreach ($RemainingRowCell in $RemainingNPRowCells) {
            $RemainingRowCell.RemoveFromPossible($NakedCellVals)
          }
        }
      }
    }    

    [bool]$FoundOne = $false
    foreach ($Col in @(0..8)) {
      $ColCells = $this.Cells | Where-Object {$_.Solved -eq $false -and $_.Col -eq $Col}
      $NPColCells = $ColCells | Where-Object {$_.PosVal.count -eq 2}
      $NakedPairStrs = ($NPColCells.PosValStr | Group-Object | Where-Object {$_.Count -eq 2}).Name
      foreach ($NakedPairStr in $NakedPairStrs) {
        $NakedPairCells = $NPColCells | Where-Object {$_.PosValStr -eq $NakedPairStr}
        if ($NakedPairCells.count -eq 2) {
          $NakedCellsPos = $NakedPairCells.Pos
          $NakedCellVals = $NakedPairCells[0].PosVal
          $RemainingNPColCells = $ColCells | Where-Object {$_.Pos -notin $NakedCellsPos}
          foreach ($RemainingColCell in $RemainingNPColCells) {
            $RemainingColCell.RemoveFromPossible($NakedCellVals)
          }
        }
      }
    }     
    
    [bool]$FoundOne = $false
    foreach ($Blk in @(0..8)) {
      $BlkCells = $this.Cells | Where-Object {$_.Solved -eq $false -and $_.Blk -eq $Blk}
      $NPBlkCells = $BlkCells | Where-Object {$_.PosVal.count -eq 2}
      $NakedPairStrs = ($NPBlkCells.PosValStr | Group-Object | Where-Object {$_.Count -eq 2}).Name
      foreach ($NakedPairStr in $NakedPairStrs) {
        $NakedPairCells = $NPBlkCells | Where-Object {$_.PosValStr -eq $NakedPairStr}
        if ($NakedPairCells.count -eq 2) {
          $NakedCellsPos = $NakedPairCells.Pos
          $NakedCellVals = $NakedPairCells[0].PosVal
          $RemainingNPBlkCells = $BlkCells | Where-Object {$_.Pos -notin $NakedCellsPos}
          foreach ($RemainingBlkCell in $RemainingNPBlkCells) {
            $RemainingBlkCell.RemoveFromPossible($NakedCellVals)
          }
        }
      }
    } 
  }

  [void]FindPointingPair () {
    $UnsolvedCells = $this.Cells | Where-Object {$_.Solved -eq $false}
    $Cols = 0..8
    $Vals = 1..9
    foreach ($Col in $Cols) {
      $UnsolvedInCol = $UnsolvedCells | Where-Object {$_.Col -eq $Col}
      foreach ($Val in $Vals) {
        $MatchCells = $UnsolvedInCol | Where-Object {$_.PosVal -contains $Val}
        $BlksMatched = $MatchCells.Blk | Select-Object -Unique
        if ($BlksMatched.Count -eq 1) {
          $OtherCellsInBlk = $UnsolvedCells | Where-Object {$_.Blk -eq $BlksMatched[0] -and $_.Col -ne $Col }
          foreach ($OtherCells in $OtherCellsInBlk) {
            $OtherCells.RemoveFromPossible($Val)
          }
        }  
      }
    }

    $UnsolvedCells = $this.Cells | Where-Object {$_.Solved -eq $false}
    $Rows = 0..8
    $Vals = 1..9
    foreach ($Row in $Rows) {
      $UnsolvedInRow = $UnsolvedCells | Where-Object {$_.Row -eq $Row}
      foreach ($Val in $Vals) {
        $MatchCells = $UnsolvedInRow | Where-Object {$_.PosVal -contains $Val}
        $BlksMatched = $MatchCells.Blk | Select-Object -Unique
        if ($BlksMatched.Count -eq 1) {
          $OtherCellsInBlk = $UnsolvedCells | Where-Object {$_.Blk -eq $BlksMatched[0] -and $_.Row -ne $Row }
          foreach ($OtherCells in $OtherCellsInBlk) {
            $OtherCells.RemoveFromPossible($Val)
          }
        }  
      }
    }
  }

  [void]FindHiddenPair () {
    $UnsolvedCells = $this.Cells | Where-Object {$_.Solved -eq $false}
    $Rows = 0..8  
    foreach ($Row in $Rows) {
      $UnsolvedCellsInRow = $UnsolvedCells | Where-Object {$_.Row -eq $Row}
      [int[]]$UnsolvedDualNumbers = ($UnsolvedCellsInRow.PosVal | Group-Object | Where-Object {$_.Count -eq 2}).Name
      foreach ($Num1 in $UnsolvedDualNumbers) {
        foreach ($Num2 in ($UnsolvedDualNumbers | Where-Object {$_ -ne $Num1})) {
          $PossibleHiddenPair = $UnsolvedCellsInRow | Where-Object {$_.PosVal -contains $Num1 -and $_.PosVal -contains $Num2}
          $HPPositions = $PossibleHiddenPair.Pos | Select-Object -Unique
          if ($HPPositions.Count -eq 2) {
            $PossibleHiddenPair[0].RemoveAllOthersFromPossible(@($Num1,$Num2))
            $PossibleHiddenPair[0].RemoveAllOthersFromPossible(@($Num1,$Num2))
          }
        }
      }
    }

    
    $UnsolvedCells = $this.Cells | Where-Object {$_.Solved -eq $false}
    $Cols = 0..8  
    foreach ($Col in $Cols) {
      $UnsolvedCellsInCol = $UnsolvedCells | Where-Object {$_.Col -eq $Col}
      [int[]]$UnsolvedDualNumbers = ($UnsolvedCellsInCol.PosVal | Group-Object | Where-Object {$_.Count -eq 2}).Name
      foreach ($Num1 in $UnsolvedDualNumbers) {
        foreach ($Num2 in ($UnsolvedDualNumbers | Where-Object {$_ -ne $Num1})) {
          $PossibleHiddenPair = $UnsolvedCellsInCol | Where-Object {$_.PosVal -contains $Num1 -and $_.PosVal -contains $Num2}
          $HPPositions = $PossibleHiddenPair.Pos | Select-Object -Unique
          if ($HPPositions.Count -eq 2) {
            $PossibleHiddenPair[0].RemoveAllOthersFromPossible(@($Num1,$Num2))
            $PossibleHiddenPair[1].RemoveAllOthersFromPossible(@($Num1,$Num2))
          }
        }
      }
    }

    $UnsolvedCells = $this.Cells | Where-Object {$_.Solved -eq $false}
    $Blks = 0..8  
    foreach ($Blk in $Blks) {
      $UnsolvedCellsInBlk = $UnsolvedCells | Where-Object {$_.Blk -eq $Blk}
      [int[]]$UnsolvedDualNumbers = ($UnsolvedCellsInBlk.PosVal | Group-Object | Where-Object {$_.Count -eq 2}).Name
      foreach ($Num1 in $UnsolvedDualNumbers) {
        foreach ($Num2 in ($UnsolvedDualNumbers | Where-Object {$_ -ne $Num1})) {
          $PossibleHiddenPair = $UnsolvedCellsInBlk | Where-Object {$_.PosVal -contains $Num1 -and $_.PosVal -contains $Num2}
          $HPPositions = $PossibleHiddenPair.Pos | Select-Object -Unique
          if ($HPPositions.Count -eq 2) {
            $PossibleHiddenPair[0].RemoveAllOthersFromPossible(@($Num1,$Num2))
            $PossibleHiddenPair[1].RemoveAllOthersFromPossible(@($Num1,$Num2))
          }
        }
      }
    }
  }

  [void]FindXWing () {
    $UnsolvedCells = $this.Cells | Where-Object {$_.Solved -eq $false}
    foreach ($Row in (0..8)) {
      $UnsolvedCellsInRow = $UnsolvedCells | Where-Object {$_.Row -eq $Row}
      if ($UnsolvedCellsInRow -lt 2) {continue}
      $AllPossibleValsInRow = $UnsolvedCellsInRow.PosVal
      $GroupedPossibleVals = $AllPossibleValsInRow | Group-Object
      [int[]]$PairedPossibleVals = ($GroupedPossibleVals | Where-Object {$_.Count -eq 2}).Name
      if ($PairedPossibleVals.Count -eq 0) {continue}
      foreach ($PairedPossibleVal in $PairedPossibleVals) {
        $LocatedPairCells = $UnsolvedCellsInRow | Where-Object {$_.PosVal -contains $PairedPossibleVal}
        $OtherRows = $UnsolvedCells | Where-Object {$_.Row -ne $LocatedPairCells[0].Row}
        foreach ($RowNumber in $OtherRows.Row) {
          $RowContainingPairedVal = $OtherRows | Where-Object {$_.PosVal -contains $PairedPossibleVal -and $_.Row -eq $RowNumber}
          if ($RowContainingPairedVal.count -ne 2)  {continue}
          $ValsOfOtherPairedVals = ($RowContainingPairedVal | Where-Object {$_.PosVal -contains $PairedPossibleVal}).PosVal
          $ValsOfPossiblePairedVals = ($LocatedPairCells | Where-Object {$_.PosVal -contains $PairedPossibleVal}).PosVal
          if ($ValsOfOtherPairedVals[0] -in $ValsOfPossiblePairedVals -and $ValsOfOtherPairedVals[1] -in $ValsOfPossiblePairedVals) {

          }
        }
      }
    }
    # Row First
    # Find a value that exists only twice only in a row
    # Locate the cols for these values
    # look for another row that has the same value in the same columns as the first row
    # if found the same value in other col positions other than the 4 located can be removed from possible

    # Do the opposite for Col
  }

}




# ######################################################################################################
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
  Param (
    [SudokuGrid]$FnGrid,
    [switch]$NoClearScreen
  )
  
  if ($NoClearScreen -eq $false) {Clear-Host}
  # Boundary box characters and color
  $V = [char]9475 ;    $H = [char]9473;    $C = [char]9547
  $LTC = [char]9487; $RTC = [char]9491;  $LBC = [char]9495; $RBC = [char]9499
  $LT = [char]9507;   $RT = [char]9515;   $TT = [char]9523;  $BT = [char]9531
  $Color = 'Green'
  $SubColor = 'DarkGray'
  

Write-Host -ForegroundColor $Color "   ----                    Sudoku Pencil Marks                    ----"  
Write-Host -ForegroundColor $Color $LTC$H$H$H$H$H$H$H$H$H$H$H$H$H$H$H$H$H$H$H$H$H$H$H$TT$H$H$H$H$H$H$H$H$H$H$H$H$H$H$H$H$H$H$H$H$H$H$H$TT$H$H$H$H$H$H$H$H$H$H$H$H$H$H$H$H$H$H$H$H$H$H$H$RTC
  foreach ($Row in (0..8)) {
    foreach ($StartNum in (1,4,7)) {
      foreach ($Col in (0..8)) {
        $CellToDisplay = $FnGrid.Cells | Where-Object {$_.Row -eq $Row -and $_.Col -eq $Col}
        if ($CellToDisplay.Solved -eq $true) {$SolvedColor = 'Cyan'}
        else {$SolvedColor = 'White'}
        $PosValsToDisplay = $CellToDisplay.PosVal
        $MatchValues = $StartNum, ($StartNum+1), ($StartNum+2)
        $DisplayNums  = foreach ($MatchValue in $MatchValues) { 
          if ( $MatchValue -in $PosValsToDisplay ) {$MatchValue}
          else {'.'}
        }
        if ($Col -eq 0) {
          Write-Host -NoNewline -ForegroundColor $Color "$V "
          Write-Host -NoNewline -ForegroundColor $SolvedColor "$DisplayNums"
          Write-Host -NoNewline -ForegroundColor $SubColor " $V "
        }
        elseif ($Col -in 2,5,8) {
          Write-Host -NoNewline -ForegroundColor $SolvedColor "$DisplayNums"
          Write-Host -NoNewline -ForegroundColor $Color " $V "          
        }
        else {
          Write-Host -NoNewline -ForegroundColor $SolvedColor "$DisplayNums"
          Write-Host -NoNewline -ForegroundColor $SubColor " $V "
        }
      }
      Write-Host
    }
    if ($Row -in 2,5) {
      Write-Host -ForegroundColor $Color "$LT$H$H$H$H$H$H$H$H$H$H$H$H$H$H$H$H$H$H$H$H$H$H$H$C$H$H$H$H$H$H$H$H$H$H$H$H$H$H$H$H$H$H$H$H$H$H$H$C$H$H$H$H$H$H$H$H$H$H$H$H$H$H$H$H$H$H$H$H$H$H$H$RT"
    }
    elseif ($Row -ne 8) {
      Write-Host  -ForegroundColor $Color -NoNewline "$V"
      Write-Host -ForegroundColor $SubColor  -NoNewline "$H$H$H$H$H$H$H$C$H$H$H$H$H$H$H$C$H$H$H$H$H$H$H"
      Write-Host -ForegroundColor $Color -NoNewline "$V"
      Write-Host -ForegroundColor $SubColor -NoNewline "$H$H$H$H$H$H$H$C$H$H$H$H$H$H$H$C$H$H$H$H$H$H$H"
      Write-Host -ForegroundColor $Color -NoNewline "$V"
      Write-Host -ForegroundColor $SubColor -NoNewline "$H$H$H$H$H$H$H$C$H$H$H$H$H$H$H$C$H$H$H$H$H$H$H"
      Write-Host -ForegroundColor $Color "$V"
    }
  }  
  Write-Host -ForegroundColor $Color $LBC$H$H$H$H$H$H$H$H$H$H$H$H$H$H$H$H$H$H$H$H$H$H$H$BT$H$H$H$H$H$H$H$H$H$H$H$H$H$H$H$H$H$H$H$H$H$H$H$BT$H$H$H$H$H$H$H$H$H$H$H$H$H$H$H$H$H$H$H$H$H$H$H$RBC
}

# ###################################################################################################
# Main Code
$CellArray =foreach ($PosInGrid in (0..80)) {
   [SudokuCell]::New($PosInGrid,$SudokuNumbers[$PosInGrid]) 
} 
$Grid = [SudokuGrid]::New($CellArray)
$Grid.RemoveSolvedFromPossibles()
if ($SketchMarks -eq $true) {Show-SketchGrid -FnGrid $Grid}
else {Show-Grid -FnGrid $Grid}

do {
  $GridStart = $Grid.Cells.PosValStr -join ''
  $Grid.FindHiddenSingles()
  $Grid.RemoveSolvedFromPossibles()
  if ($SketchMarks -eq $true) {Show-SketchGrid -FnGrid $Grid}
  else {Show-Grid -FnGrid $Grid}

  $Grid.FindNakedSingles()
  $Grid.RemoveSolvedFromPossibles()
  if ($SketchMarks -eq $true) {Show-SketchGrid -FnGrid $Grid}
  else {Show-Grid -FnGrid $Grid}

  $Grid.FindNakedPairs()
  $Grid.RemoveSolvedFromPossibles()
  if ($SketchMarks -eq $true) {Show-SketchGrid -FnGrid $Grid}
  else {Show-Grid -FnGrid $Grid}

  $Grid.FindPointingPair()
  $Grid.RemoveSolvedFromPossibles()
  if ($SketchMarks -eq $true) {Show-SketchGrid -FnGrid $Grid}
  else {Show-Grid -FnGrid $Grid}

  $Grid.FindHiddenPair()
  #$Grid.RemoveSolvedFromPossibles()
  if ($SketchMarks -eq $true) {Show-SketchGrid -FnGrid $Grid}
  else {Show-Grid -FnGrid $Grid}

  $GridEnd = $Grid.Cells.PosValStr -join ''
  # if the solutions are not changing the sudoku puzzle end in 15 stalled attempts to solve something
  if ($GridStart -eq $GridEnd) {$Stuck = $Stuck + 1}
  else {$Stuck = 0}
} until ($Grid.Cells.Solved -notcontains $false -or $Stuck -gt 15 )
if ($Grid.Cells.Solved -contains $false) {
  Write-Host
  Write-Host
  Show-SketchGrid -FnGrid $Grid -NoClearScreen}