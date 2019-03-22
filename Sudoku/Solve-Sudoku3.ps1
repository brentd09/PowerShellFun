<#
.SYNOPSIS
  Solve Sudoku puzzles
.DESCRIPTION
  This Script solves Sudoku Puzzles, you will need to input the puzzle as one string of characters
  use - for blank squares.
  This program solves the puzzle using known elimination techniques such as:
  Unique candidate, sole candidate, hidden candidate, hidden pair, naked pair
  Soon it will be able to solve for X-Wing and SwordFish as well.
.EXAMPLE
  Solve-Sudoku -Puzzle '1----3-----6--5----291--6-361-5-23---3--6--9---84-1-267-5--943----7--8-----3----9'
  This represents the Puzzle as a string to the script
.Notes  
  General notes
  Created By: Brent Denny
          On: 05-Mar-2019
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
    $Puzzle = '--7---28---4-25---28---46---9---6---3-------2---1---9---62---75---57-4---78---3--' impossible 
    $Puzzle = '1-----569492-561-8-561-924---964-8-1-64-1----218-356-4-4-5---1-9-5-614-2621-----5' impossible (xwing)
#>
[CmdletBinding()]
Param (
  $Puzzle = '7-542--6-68-1--24--4-76--18-91--2-7482--576--3---1482-158--6--9--25-91-6--684-7-2'
)
class SudokuCell {
  [string]$Val
  [int]$Pos
  [int]$Col
  [int]$Row
  [int]$Box
  [System.Collections.Generic.List[string]]$PossibleValues
  [System.Collections.Generic.List[string]]$NotPossibleValues

  SudokuCell([string]$Val,[int]$Pos) {
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
    if ($Val -match '\d') {
      $this.PossibleValues = [string[]]@($Val)
      $this.NotPossibleValues = [string[]]@('1','2','3','4','5','6','7','8','9') | Where-Object {$_ -ne $Val}
    }
    elseif ($Val -notmatch '\d') {
      $this.PossibleValues = [string[]]@('1','2','3','4','5','6','7','8','9')
      $this.NotPossibleValues = [string[]]@()
    }
  } # New Object method

  [void]AssignValue ([string]$Value) {
    $this.Val = $Value
    $this.PossibleValues = $Value
    $this.NotPossibleValues = $this.NotPossibleValues.Remove($Value)
  }

  [void]AssignNotPossible ([string[]]$Value) {
    $this.NotPossibleValues += $Value
    $this.PossibleValues.Remove($Value)
  }
}
function New-Board {
  Param ([string]$BoardString) 
  foreach ($Pos in (0..80)) {
    [SudokuCell]::New($Boardstring.Substring($Pos,1),$Pos)
  }
}

Function Find-SoleCandidate {
  Param ([SudokuCell[]]$SudokuBoard)
  foreach ($Pos in (0..80)) {
    if ($SudokuBoard[$Pos].PossibleValues.Count -eq 1) {
      $SudokuBoard[$Pos].AssignValue($SudokuBoard[$Pos].PossibleValues[0])
    }
  }
}

function Find-NotPossible {
  Param([SudokuCell[]]$SudokuBoard)
  foreach ($Pos in (0..80)) {
    if ($SudokuBoard[$Pos].val -eq '-') {
      $Row = $SudokuBoard[$Pos].Row
      $Col = $SudokuBoard[$Pos].Col
      $Box = $SudokuBoard[$Pos].Box
      $RelatedValues = ($SudokuBoard | Where-Object {$_.Box -eq $Box -or $_.Col -eq $Col -or $_.Row -eq $Row}).val | 
                        Where-Object {$_ -match \d} | Select-Object -Unique | Sort-Object
      $SudokuBoard[$Pos].AssignNotPossible($RelatedValues)


    }
  }
}
function Show-Board {
  Param ([SudokuCell[]]$SudokuBoard)
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
      Write-Host -NoNewline $SudokuBoard[($PosRow+($PosCol*9))].Val
      Write-Host -NoNewline -ForegroundColor $FGColor "$Bdr"
    }
    Write-Host -ForegroundColor $FGColor $HBdr
  }
  Write-Host
}

###MainCode

$BoardObj = New-Board -BoardString $Puzzle
Clear-Host
do {

Find-SoleCandidate -SudokuBoard $BoardObj

Show-Board -SudokuBoard $BoardObj
Start-Sleep -Seconds 1
} while ($BoardObj.Val -contains '-')