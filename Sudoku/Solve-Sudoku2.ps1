<#
.SYNOPSIS
  Solve Sudoku
.DESCRIPTION
  This Script solves Sudoku Puzzles, you will need to input the puzzle as one string of characters
  use - for blank squares
.EXAMPLE
  Solve-Sudoku -Puzzle '1----3-----6--5----291--6-361-5-23---3--6--9---84-1-267-5--943----7--8-----3----9'
  This represents the Puzzle as a string to the script
.Notes  
  General notes
  Created By: Brent Denny
          On: 28-Nov-2018
  Puzzles        
    $Puzzle = '7-542--6-68-1--24--4-76--18-91--2-7482--576--3---1482-158--6--9--25-91-6--684-7-2' Easy
    $Puzzle = '-9--2-5----4--5-1--6-----93--18---6----9----2-8--72---5----1-7----3--9-1-13------' Medium
    $Puzzle = '-9--2-5----4--5-1--6-----93--18---6----9----2-8--72---5----1-7----3--9-1--3------' Difficult
    $Puzzle = '--97486--7---------2-1-987---7---24--64-1-59--98---3-----8-3-2---------6---2759--' Difficult
    $Puzzle = '-714---------17--59------4-5-8-6341--3--------9-----28-----4-6--6--89--1----3--5-' Difficult
    $Puzzle = '-2-6------562-----1------28----2-4-9-914-873-2-8-9----71------3-----217------5-6-' Difficult
    $Puzzle = '89-2-3-------------3658---41-8-3--6-----------2--7-3-57---9412-------------8-2-59' Extreme
    $Puzzle = '--9748---7---------2-1-9-----7---24--64-1-59--98---3-----8-3-2---------6---2759--' Impossible
    $Puzzle = '-714---------17--59------4-5-8-634---3--------9-----28-----4-6--6--89--1----3--5-' Impossible
    $Puzzle = '----15-74----3-8---87---5-1-23--4----1--7--2----2--79-8-6---24---1-2----23-64----' impossible
#>
[CmdletBinding()]
Param (
  $Puzzle = '7-542--6-68-1--24--4-76--18-91--2-7482--576--3---1482-158--6--9--25-91-6--684-7-2'
)
class BoardPosition {
  [string]$Val
  [int]$Pos
  [int]$Col
  [int]$Row
  [int]$Box
  [string[]]$PossibleValues
  [string]$PossValString
  [int]$PossCount

  BoardPosition([string]$Val,[int]$Pos) {
    $this.Val = $Val
    $this.Pos = $Pos
    $this.Row = [math]::Truncate($Pos / 9)
    $this.Col = $Pos % 9
    if     ($Pos -in @(0,1,2,9,10,11,18,19,20))     {$this.Box = 0}
    elseif ($Pos -in @(3,4,5,12,13,14,21,22,23))    {$this.Box = 1}
    elseif ($Pos -in @(6,7,8,15,16,17,24,25,26))    {$this.Box = 2}
    elseif ($Pos -in @(27,28,29,36,37,38,45,46,47)) {$this.Box = 3}
    elseif ($Pos -in @(30,31,32,39,40,41,48,49,50)) {$this.Box = 4}
    elseif ($Pos -in @(33,34,35,42,43,44,51,52,53)) {$this.Box = 5}
    elseif ($Pos -in @(54,55,56,63,64,65,72,73,74)) {$this.Box = 6}
    elseif ($Pos -in @(57,58,59,66,67,68,75,76,77)) {$this.Box = 7}
    elseif ($Pos -in @(60,61,62,69,70,71,78,79,80)) {$this.Box = 8}
    $this.PossibleValues = 1..9
    $this.PossValString = 1..9 -join ''
    $this.PossCount = (1..9).Count
  }
}

function Create-Board {
  Param (
    $fnPuzzle
  )
  $Board = @()
  foreach ($Pos in (0..80)){
    $BoardVal = $fnPuzzle.Substring($Pos,1)
    $Board += [BoardPosition]::New($BoardVal,$Pos)
  }
  $Board
}

# Functions
Function Get-SoleCandidate {
  Param (
    $fnPuzzle
  )
  foreach ($Pos in (0..80)) {
    if ($fnPuzzle[$Pos].PossCount -eq 1) {
      $fnPuzzle[$Pos].Val = $fnPuzzle[$Pos].PossibleValues[0]
    }
  }
}

function Get-UniqueCandidate {
  Param (
    $fnPuzzle
  )
  foreach ($BoxPos in 0..8) {
    $BoxFocus = $fnPuzzle | Where-Object {$_.Box -eq $BoxPos}
    [array]$Uniques = (($BoxFocus | Where-Object {$_.val -match '-'}).possiblevalues | Group-Object | Where-Object {$_.count -eq 1}).Name
    if ($Uniques.Count -ge 1) {
      foreach ($Unique in $Uniques) {
        $Index = ($BoxFocus | Where-Object {$_.PossibleValues -contains $Unique}).Pos
        $fnPuzzle[$Index].Val = $Unique
      }
    }
  }
}

function Show-Board {
  Param (
    $fnPuzzle
  )
  $Coords = New-Object -TypeName System.Management.Automation.Host.Coordinates
  $host.UI.RawUI.CursorPosition = $Coords
  $FGColor = 'Yellow'
  Write-Host -ForegroundColor Green "     Solve Sudoku`n"
  foreach ($PosCol in (0..8)) {
    if ($PosCol -eq 2 -or $PosCol -eq 5) {$HBdr = "`n------+-------+------"}
    else {$HBdr = ''}
    foreach ($PosRow in (0..8)) {
      if ($PosRow -eq 2 -or $PosRow -eq 5) {$Bdr = ' | '}
      else {$Bdr = ' '}
      Write-Host -NoNewline $fnPuzzle[($PosRow+($PosCol*9))].Val
      Write-Host -NoNewline -ForegroundColor $FGColor "$Bdr"
    }
    Write-Host -ForegroundColor $FGColor $HBdr
  }
  Write-Host
}

function Remove-Possibles  {
  Param ($fnPuzzle)

  foreach ($Pos in (0..80)) {
    if ($fnPuzzle[$Pos].Val -match '\d') {
      $fnPuzzle[$Pos].PossibleValues = $fnPuzzle[$Pos].Val
      $fnPuzzle[$Pos].PossValString = $fnPuzzle[$Pos].PossibleValues -join ''
      $fnPuzzle[$Pos].PossCount = ($fnPuzzle[$Pos].PossibleValues).Count
    }
    else {
      [array]$FocusRowVals = ($fnPuzzle | Where-Object {$_.Row -eq $fnPuzzle[$Pos].Row}).Val | Where-Object {$_ -match '\d'}
      [array]$FocusColVals = ($fnPuzzle | Where-Object {$_.Col -eq $fnPuzzle[$Pos].Col}).Val | Where-Object {$_ -match '\d'}
      [array]$FocusBoxVals = ($fnPuzzle | Where-Object {$_.Box -eq $fnPuzzle[$Pos].Box}).Val | Where-Object {$_ -match '\d'}
      $focusArray = ($FocusRowVals + $FocusColVals + $FocusBoxVals) | Select-Object -Unique
      $fnPuzzle[$Pos].PossibleValues = $fnPuzzle[$Pos].PossibleValues | Where-Object {$_ -notin $focusArray}
      $fnPuzzle[$Pos].PossValString = $fnPuzzle[$Pos].PossibleValues -join ''
      $fnPuzzle[$Pos].PossCount = ($fnPuzzle[$Pos].PossibleValues).Count
    }  
  }
}

function Remove-HiddenPairCol {
  Param (
    $fnPuzzle
  )
  foreach ($Col in (0..8)) {
    $Numbers = (($fnPuzzle | Where-Object {$_.Col -eq $Col -and $_.PossCount -gt 1}).possiblevalues | Group-Object | Where-Object {$_.Count -eq 2} ).name
    If ($Numbers.Count -eq 2) {
      $NumberCells = $fnPuzzle | Where-Object {$_.Col -eq $Col -and $_.PossibleValues -Contains $Numbers[0] -and $_.PossibleValues -Contains $Numbers[1] }
    }
    If ($Numbers.Count -eq 2 -and $NumberCells.Count -eq 2) {
      $HiddenCells = $fnPuzzle | Where-Object {$_.Col -eq $Col} | Where-Object {$_.PossibleValues -contains $Numbers[0] -and $_.Possiblevalues -contains $Numbers[1]}
      foreach ($Cell in $HiddenCells){$fnPuzzle[$Cell.Pos].PossibleValues = $fnPuzzle[$Cell.Pos].PossibleValues = $Numbers}
    }
  }
}

function Remove-HiddenPairRow {
  Param (
    $fnPuzzle
  )
  foreach ($Row in (0..8)) {
    $Numbers = (($fnPuzzle | Where-Object {$_.Row -eq $Row -and $_.PossCount -gt 1}).possiblevalues | Group-Object | Where-Object {$_.Count -eq 2} ).name
    If ($Numbers.Count -eq 2) {
      $NumberCells = $fnPuzzle | Where-Object {$_.Row -eq $Row -and $_.PossibleValues -Contains $Numbers[0] -and $_.PossibleValues -Contains $Numbers[1] }
    }
    If ($Numbers.Count -eq 2 -and $NumberCells.Count -eq 2) {
      $HiddenCells = $fnPuzzle | Where-Object {$_.Row -eq $Row} | Where-Object {$_.PossibleValues -contains $Numbers[0] -and $_.Possiblevalues -contains $Numbers[1]}
      foreach ($Cell in $HiddenCells){$fnPuzzle[$Cell.Pos].PossibleValues = $fnPuzzle[$Cell.Pos].PossibleValues = $Numbers}
    }
  }
}

function Remove-HiddenPairBox {
  Param (
    $fnPuzzle
  )
  foreach ($Box in (0..8)) {
    $Numbers = (($fnPuzzle | Where-Object {$_.Box -eq $Box -and $_.PossCount -gt 1}).possiblevalues | Group-Object | Where-Object {$_.Count -eq 2} ).name
    If ($Numbers.Count -eq 2) {
      $NumberCells = $fnPuzzle | Where-Object {$_.Box -eq $Box -and $_.PossibleValues -Contains $Numbers[0] -and $_.PossibleValues -Contains $Numbers[1] }
    }
    If ($Numbers.Count -eq 2 -and $NumberCells.Count -eq 2) {
      $HiddenCells = $fnPuzzle | Where-Object {$_.Box -eq $Box} | Where-Object {$_.PossibleValues -contains $Numbers[0] -and $_.Possiblevalues -contains $Numbers[1]}
      foreach ($Cell in $HiddenCells){$fnPuzzle[$Cell.Pos].PossibleValues = $fnPuzzle[$Cell.Pos].PossibleValues = $Numbers}
    }
  }
}

function Remove-NakedPairCol {
  Param (
    $fnPuzzle
  )
  foreach ($Col in (0..8)) {
    $PuzzlePairs = $fnPuzzle | Where-Object {$_.Col -eq $Col -and $_.PossCount -eq 2}
    $GroupPairs = $PuzzlePairs.PossValString | Group-Object
    $TwoPairs = $GroupPairs | Where-Object {$_.Count -eq 2}
    foreach ($Pair in $TwoPairs) {
      $WhichArePairs = $PuzzlePairs | Where-Object {$_.PossValString -eq $Pair.Name}
      if ($WhichArePairs.Count -eq 2) {
        $RemoveNumbers = $WhichArePairs[0].PossibleValues
        $SkipPositions = $WhichArePairs.Pos
        $CellsToConsider = $fnPuzzle | Where-Object {$_.Col -eq $Col -and $_.Pos -notin $SkipPositions -and $_.Val -notmatch '\d'}
        foreach ($Cell in $CellsToConsider) {
          $fnPuzzle[($Cell.Pos)].possiblevalues = $fnPuzzle[($Cell.Pos)].possiblevalues | Where-Object {$_ -notin $RemoveNumbers}
        }
      }
    }
  }
}

function Remove-NakedPairRow {
  Param (
    $fnPuzzle
  )
  foreach ($Row in (0..8)) {
    $PuzzlePairs = $fnPuzzle | Where-Object {$_.Row -eq $Row -and $_.PossCount -eq 2}
    $GroupPairs = $PuzzlePairs.PossValString | Group-Object
    $TwoPairs = $GroupPairs | Where-Object {$_.Count -eq 2}
    foreach ($Pair in $TwoPairs) {
      $WhichArePairs = $PuzzlePairs | Where-Object {$_.PossValString -eq $Pair.Name}
      if ($WhichArePairs.Count -eq 2) {
        $RemoveNumbers = $WhichArePairs[0].PossibleValues
        $SkipPositions = $WhichArePairs.Pos
        $CellsToConsider = $fnPuzzle | Where-Object {$_.Row -eq $Row -and $_.Pos -notin $SkipPositions -and $_.Val -notmatch '\d'}
        foreach ($Cell in $CellsToConsider) {
          $fnPuzzle[($Cell.Pos)].possiblevalues = $fnPuzzle[($Cell.Pos)].possiblevalues | Where-Object {$_ -notin $RemoveNumbers}
        }
      }
    }
  }
}

function Remove-NakedPairBox {
  Param (
    $fnPuzzle
  )
  foreach ($Box in (0..8)) {
    $PuzzlePairs = $fnPuzzle | Where-Object {$_.Box -eq $Box -and $_.PossCount -eq 2}
    $GroupPairs = $PuzzlePairs.PossValString | Group-Object
    $TwoPairs = $GroupPairs | Where-Object {$_.Count -eq 2}
    foreach ($Pair in $TwoPairs) {
      $WhichArePairs = $PuzzlePairs | Where-Object {$_.PossValString -eq $Pair.Name}
      if ($WhichArePairs.Count -eq 2) {
        $RemoveNumbers = $WhichArePairs[0].PossibleValues
        $SkipPositions = $WhichArePairs.Pos
        $CellsToConsider = $fnPuzzle | Where-Object {$_.Box -eq $Box -and $_.Pos -notin $SkipPositions -and $_.Val -notmatch '\d'}
        foreach ($Cell in $CellsToConsider) {
          $fnPuzzle[($Cell.Pos)].possiblevalues = $fnPuzzle[($Cell.Pos)].possiblevalues | Where-Object {$_ -notin $RemoveNumbers}
        }
      }
    }
  }
}

function Remove-HiddenPossibles {
  Param (
    $fnPuzzle
  )
  foreach ($Box in (0..8)) {
    $BoxCells = $fnPuzzle | Where-Object {$_.Box -eq $Box}
    $Solved = $BoxCells | Where-Object {$_.Val -match '\d'}
    $WhatsLeft = 1..9 | Where-Object {$_ -notin $Solved.val}
    foreach ($Num in $whatsLeft) {
      $Found = $BoxCells | Where-Object { $_.possiblevalues -Contains $num} 
      if ($Found.Count -eq 2 -or $Found.Count -eq 3) {
        $GroupFoundCol = $Found | Group-Object -Property Col
        $GroupFoundRow = $Found | Group-Object -Property Row
        if ($GroupFoundCol.Count -eq $Found.count) {
          # start the removal process on col
          $Col = $GroupFoundCol.Name -as [int]
          $ModCells = $fnPuzzle | Where-Object {$_.Col -eq $Col -and $_.Box -ne $Box}
          foreach ($Cell in $ModCells) {
            $fnPuzzle[$Cell.Pos].PossibleValues =  $fnPuzzle[$Cell.Pos].PossibleValues | Where-Object {$_ -notin $Num}
          }
        }
        if ($GroupFoundRow.Count -eq $Found.Count) {
          # Start the removal process on row
          $Row = $GroupFoundRow.Name -as [int]
          $ModCells = $fnPuzzle | Where-Object {$_.Row -eq $Row -and $_.Box -ne $Box}
          foreach ($Cell in $ModCells) {
            $fnPuzzle[$Cell.Pos].PossibleValues =  $fnPuzzle[$Cell.Pos].PossibleValues | Where-Object {$_ -notin $Num}
          }

        }
      }
    }
  }
}

function Remove-XWingCol {
  Param (
    $fnPuzzle
  )
  # Need to find a val that appear only twice in two columns that form a rectangle
}

function Remove-XWingRow {
  Param (
    $fnPuzzle
  )
  # Need to find a val that appear only twice in two rows that form a rectangle
}



##  Main Code ##
Clear-Host
$BruteForce = $false
$BruteAttempt = 0
$Board = Create-Board $Puzzle
Show-Board -fnPuzzle $Board
do {
  $BoardStrBefore = $Board.Val -join '' 
  Remove-Possibles -fnPuzzle $Board
  Show-Board -fnPuzzle $Board
  Get-SoleCandidate -fnPuzzle $Board
  Remove-Possibles -fnPuzzle $Board
  Show-Board -fnPuzzle $Board
  Get-UniqueCandidate -fnPuzzle $Board
  Remove-Possibles -fnPuzzle $Board
  Show-Board -fnPuzzle $Board
  Remove-NakedPairCol -fnPuzzle $Board
  Remove-Possibles -fnPuzzle $Board
  Show-Board -fnPuzzle $Board
  Remove-NakedPairRow -fnPuzzle $Board
  Remove-Possibles -fnPuzzle $Board
  Show-Board -fnPuzzle $Board
  Remove-NakedPairBox -fnPuzzle $Board
  Remove-Possibles -fnPuzzle $Board
  Show-Board -fnPuzzle $Board
  Remove-HiddenPossibles -fnPuzzle $Board
  Remove-Possibles -fnPuzzle $Board
  Show-Board -fnPuzzle $Board
<# 
  Remove-HiddenPairCol -fnPuzzle $Board
  Remove-Possibles -fnPuzzle $Board
  Show-Board -fnPuzzle $Board 

  Remove-HiddenPairRow -fnPuzzle $Board
  Remove-Possibles -fnPuzzle $Board
  Show-Board -fnPuzzle $Board
  Remove-HiddenPairBox -fnPuzzle $Board
  Remove-Possibles -fnPuzzle $Board
  Show-Board -fnPuzzle $Board
#>

  $BoardStrAfter = $Board.Val -join ''
  if ($BoardStrBefore -eq $BoardStrAfter ) {}
  elseif ($BoardStrBefore -eq $BoardStrAfter ) {}
} until ($Board.Val -notcontains '-')