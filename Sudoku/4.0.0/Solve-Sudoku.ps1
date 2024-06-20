<#
  .SYNOPSIS
    Solve Sudoku puzzle
  .DESCRIPTION
    A longer description of the function, its purpose, common use cases, etc.
  .NOTES
    Information or caveats about the function e.g. 'This function is not supported in Linux'
    $StartingValues = '7-542--6-68-1--24--4-76--18-91--2-7482--576--3---1482-158--6--9--25-91-6--684-7-2' # Easy
    $StartingValues = '4-----38--6-58-49-------5-6----12---------8--284--71696--1--9----194-275-------3-' # Medium
    $StartingValues = '---85--7-7---92---5-----1------69345-4-----2---6-3----------9-3-1---3687--39--25-' # Hard
  .LINK
    Specify a URI to a help page, this will show when Get-Help -Online is used.
  .EXAMPLE
    Test-MyTestFunction -Verbose
    Explanation of the function or its result. You can include multiple examples with additional .EXAMPLE lines

#>

[CmdletBinding()]
Param (
  [string]$StartingValues = '---85--7-7---92---5-----1------69345-4-----2---6-3----------9-3-1---3687--39--25-'
)

# Classes  ########################

Class ArrayTools {
  [string[]]$AllNumbers

  ArrayTools () {
    $this.AllNumbers = '1','2','3','4','5','6','7','8','9'
  }

  ArrayTools ([string[]]$MasterArray) {
    $this.AllNumbers = $MasterArray
  }

  [string[]]SubtractArray ([string[]]$NumbersToRemove) {
    $ValuesRemaining = $this.AllNumbers | Where-Object {$_ -notin $NumbersToRemove} | Sort-Object -Unique
    return $ValuesRemaining
  }



} # Arraytools
Class SudokuCell {
  [string]$Ref
  [int]$Pos 
  [int]$Col
  [int]$Row
  [int]$Box
  [string]$Val
  [System.Collections.ArrayList]$Possibles
  [int[]]$RelatedIndexes
  [int[]]$RelatedRowIndexes
  [int[]]$RelatedColIndexes
  [int[]]$RelatedBoxIndexes
  [bool]$CellSolved

  SudokuCell ($Position, $Value) {
    if ($Position -in 0..80) {
      $AsciiRef = ([math]::Truncate($Position / 9) + 65 ) -as [int]
      $NumRef = $Position % 9 + 1
      $this.Ref = [string]([char]$AsciiRef + $NumRef) 
      $NumRange = @('1','2','3','4','5','6','7','8','9')
      $this.Pos = $Position
      $this.Col = $Position % 9
      $this.Row = [math]::Truncate($Position / 9)
      [int]$RowStartIndex = ([math]::Truncate($Position / 9)) * 9
      [int[]]$RowIndexes = $RowStartIndex..($RowStartIndex + 8) 
      $this.RelatedRowIndexes = $RowIndexes | Sort-Object -Unique               
      $ColStartIndex = $Position % 9
      $ColIndexes = @($ColStartIndex, 
                      ($ColStartIndex + 9), 
                      ($ColStartIndex + 18), 
                      ($ColStartIndex + 27), 
                      ($ColStartIndex + 36), 
                      ($ColStartIndex + 45), 
                      ($ColStartIndex + 54), 
                      ($ColStartIndex + 63), 
                      ($ColStartIndex + 72)
      )
      $this.RelatedColIndexes = $ColIndexes | Sort-Object -Unique                               
      # Determine which "box" the cell is in
      if      ($Position -in  0, 1, 2, 9,10,11,18,19,20) {$BoxIndex = 0; $BoxStartIndex =  0}
      elseif  ($Position -in  3, 4, 5,12,13,14,21,22,23) {$BoxIndex = 1; $BoxStartIndex =  3}
      elseif  ($Position -in  6, 7, 8,15,16,17,24,25,26) {$BoxIndex = 2; $BoxStartIndex =  6}
      elseif  ($Position -in 27,28,29,36,37,38,45,46,47) {$BoxIndex = 3; $BoxStartIndex = 27}
      elseif  ($Position -in 30,31,32,39,40,41,48,49,50) {$BoxIndex = 4; $BoxStartIndex = 30}
      elseif  ($Position -in 33,34,35,42,43,44,51,52,53) {$BoxIndex = 5; $BoxStartIndex = 33}
      elseif  ($Position -in 54,55,56,63,64,65,72,73,74) {$BoxIndex = 6; $BoxStartIndex = 54}
      elseif  ($Position -in 57,58,59,66,67,68,75,76,77) {$BoxIndex = 7; $BoxStartIndex = 57}
      elseif  ($Position -in 60,61,62,69,70,71,78,79,80) {$BoxIndex = 8; $BoxStartIndex = 60}
      else {Write-warning "The index is out of scope";break }
      $BoxIndexes = @($BoxStartIndex, 
                      ($BoxStartIndex + 1), 
                      ($BoxStartIndex + 2), 
                      ($BoxStartIndex + 9), 
                      ($BoxStartIndex + 10), 
                      ($BoxStartIndex + 11), 
                      ($BoxStartIndex + 18), 
                      ($BoxStartIndex + 19), 
                      ($BoxStartIndex + 20)
      )
      $this.RelatedBoxIndexes = $BoxIndexes | Sort-Object -Unique
      $this.RelatedIndexes = $RowIndexes + $ColIndexes + $BoxIndexes | Sort-Object -Unique
      $this.Val = $Value      
      if ($Value -in $NumRange) {
        $this.CellSolved = $true
        $this.Possibles = @()
      }
      else {
        $this.Possibles = $NumRange
        $this.CellSolved = $false
      }
      $this.Box = $BoxIndex
    }
  }
  
  [void]RemoveValuesFromPossibles ([string[]]$NumbersToRemove) {
    foreach ($NumberToRemove in $NumbersToRemove) {
      $this.Possibles.Remove($NumberToRemove)
    }
  }  

  [void]SetValueAsOnlyPossible ([string]$Value) {
    if ($this.Possibles -contains $Value) {
      $this.Possibles = @($Value)
    }
  }

  [void]SolveCell () {
    if ($this.CellSolved -eq $false -and $this.Possibles.Count -eq 1 ) {
      $this.Val = $this.Possibles[0]
      $this.CellSolved = $true
      $this.Possibles = @()
    }
  }
}

Class SudokuGrid {
  [SudokuCell[]]$Cells

  SudokuGrid ([string]$StringValues) {
    $this.Cells = foreach ($Index in 0..80) {
      [SudokuCell]::New($Index, $StringValues[$Index])
    }
  }

  [void]RationaliseAllPossibles () {
    foreach ($Index in 0..80) {
      $CurrentCell = $this.Cells[$Index]
      $RelatedSolvedCells = $this.Cells[$CurrentCell.RelatedIndexes] | Where-Object {$_.CellSolved -eq $true}
      $RelatedSolvedValues = $RelatedSolvedCells.Val | Sort-Object -Unique
      if ($this.Cells[$Index].CellSolved -eq $false) {$this.Cells[$Index].RemoveValuesFromPossibles($RelatedSolvedValues)}
    }
  }

  [void]FindHiddenSingles () {
    foreach ($Index in 0..80) {
      $CurrentCell = $this.Cells[$Index]

      $RelRowIndexes = $CurrentCell.RelatedRowIndexes
      $RelColIndexes = $CurrentCell.RelatedColIndexes
      $RelBoxIndexes = $CurrentCell.RelatedBoxIndexes

      $RelRowCells = $this.Cells[$RelRowIndexes]
      $RelColCells = $this.Cells[$RelColIndexes]
      $RelBoxCells = $this.Cells[$RelBoxIndexes]

      $SinglePossiblesRow = (($RelRowCells | Where-Object {$_.CellSolved -eq $false}).Possibles | Group-Object | Where-Object {$_.Count -eq 1}).Name
      $SinglePossiblesCol = (($RelColCells | Where-Object {$_.CellSolved -eq $false}).Possibles | Group-Object | Where-Object {$_.Count -eq 1}).Name
      $SinglePossiblesBox = (($RelBoxCells | Where-Object {$_.CellSolved -eq $false}).Possibles | Group-Object | Where-Object {$_.Count -eq 1}).Name

      if ($SinglePossiblesRow) {
        foreach ($SinglePossVal in $SinglePossiblesRow) {
          $CellOnePossibleVal = $RelRowCells | Where-Object {$_.Possibles -contains $SinglePossVal}
          $CellOnePossibleVal.SetValueAsOnlyPossible($SinglePossVal)
        }
      }
      if ($SinglePossiblesCol) {
        foreach ($SinglePossVal in $SinglePossiblesCol) {
          $CellOnePossibleVal = $RelColCells | Where-Object {$_.Possibles -contains $SinglePossVal}
          $CellOnePossibleVal.SetValueAsOnlyPossible($SinglePossVal)
        }
      }
      
      if ($SinglePossiblesBox) {
        foreach ($SinglePossVal in $SinglePossiblesBox) {
          $CellOnePossibleVal = $RelBoxCells | Where-Object {$_.Possibles -contains $SinglePossVal}
          $CellOnePossibleVal.SetValueAsOnlyPossible($SinglePossVal)
        }
      }
    } # foreach
  } # FindHiddenSingles

  [string[]]NumbersToSolve () {
    $NumbersStillUnsolved = ($this.Cells | Where-Object {$_.CellSolved -eq $false}).Possibles | Sort-Object -Unique
    return $NumbersStillUnsolved
  }
  
  [void]FindPointingPairs () {


  } # FindPointingPairs

  [string[]]ValuesSolved () {
    $SolvedCells = $this.Cells | Where-Object {$_.CellSolved -eq $true}
    $SolvedNumbers = ($SolvedCells.Val | Sort-Object | Group-Object | Where-Object {$_.Count -eq 9}).Name
    return $SolvedNumbers
  } # ValuesSolved
} # Class Sudoku Grid 


# Functions ########################
function Show-Grid {
  Param ([SudokuGrid]$Grid)

  Clear-Host
  foreach ($Cell in $Grid.Cells) {
    if ($Cell.Col -eq 0) {Write-Host}
    if ($Cell.Val -match '\d') {Write-Host -ForegroundColor Yellow "$($Cell.Val) " -NoNewline}
    else {Write-Host -ForegroundColor Cyan "$($Cell.Val) " -NoNewline}
    if ($Cell.Col -in 2,5) {Write-Host -ForegroundColor DarkGray '| ' -NoNewline}
    if ($Cell.Row -in 2,5 -and $Cell.Col -eq 8) {Write-Host -ForegroundColor DarkGray "`n------+-------+-------" -NoNewline}
  }
  Write-Host
  # Start-Sleep -Milliseconds 200
}



# Main Code ########################
# Board Setup ########################

$Grid = [SudokuGrid]::New($StartingValues)
$Grid.RationaliseAllPossibles()
Show-Grid -Grid $Grid
# Solution 
do {
  $PreSolvedCount = ($Grid.Cells | Where-Object {$_.CellSolved -eq $true}).Count
  $CellToSolve = $Grid.Cells | Where-Object {$_.CellSolved -eq $false -and $_.Possibles.Count -eq 1} | Get-Random
  if ($CellToSolve) {$CellToSolve.SolveCell()}
  $Grid.RationaliseAllPossibles()
  $PostSolvedCount = ($Grid.Cells | Where-Object {$_.CellSolved -eq $true}).Count
  if ($PreSolvedCount -eq $PostSolvedCount) {
    $Grid.FindHiddenSingles()
    $Grid.FindPointingPairs()
  }
  Show-Grid -Grid $Grid

  Start-Sleep -Milliseconds  100
} while ($Grid.Cells.CellSolved -contains $false)
