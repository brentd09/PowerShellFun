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
    $Puzzle = '--7---28---4-25---28---46---9---6---3-------2---1---9---62---75---57-4---78---3--' impossible 
    $Puzzle = '1-----569492-561-8-561-924---964-8-1-64-1----218-356-4-4-5---1-9-5-614-2621-----5' impossible (xwing)
#>
[CmdletBinding()]
Param (
  $Puzzle =   '--9748---7---------2-1-9-----7---24--64-1-59--98---3-----8-3-2---------6---2759--' 
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

function Get-HiddenCandidate {
  Param (
    $fnPuzzle
  )
  foreach ($Index in (0..8)) {
    #Check Row
    $CurrentRow = $fnPuzzle | Where-Object {$_.Row -eq $Index -and $_.Val -notmatch '/d'}
    $GroupInfo = $CurrentRow.PossibleValues | Group-Object | Where-Object {$_.Count -eq 1}
    if (($GroupInfo | Measure-Object).Count -ge 1){
      foreach ($Single in $GroupInfo) {
        $Found = $CurrentRow | Where-Object {$_.PossibleValues -contains $Single.Name}
        $fnPuzzle[$Found.Pos].Val = $Single.Name
        $fnPuzzle[$Found.Pos].PossibleValues = $Single.Name
      }
    }
    #Check Col
    $CurrentCol = $fnPuzzle | Where-Object {$_.Col -eq $Index -and $_.Val -notmatch '/d'}
    $GroupInfo = $CurrentCol.PossibleValues | Group-Object | Where-Object {$_.Count -eq 1}
    if (($GroupInfo | Measure-Object).Count -ge 1){
      foreach ($Single in $GroupInfo) {
        $Found = $CurrentCol | Where-Object {$_.PossibleValues -contains $Single.Name}
        $fnPuzzle[$Found.Pos].Val = $Single.Name
        $fnPuzzle[$Found.Pos].PossibleValues = $Single.Name
      }
    }
    #check Box
    $CurrentBox = $fnPuzzle | Where-Object {$_.Box -eq $Index -and $_.Val -notmatch '/d'}
    $GroupInfo = $CurrentBox.PossibleValues | Group-Object | Where-Object {$_.Count -eq 1}
    if (($GroupInfo | Measure-Object).Count -ge 1){
      foreach ($Single in $GroupInfo) {
        $Found = $CurrentBox | Where-Object {$_.PossibleValues -contains $Single.Name}
        $fnPuzzle[$Found.Pos].Val = $Single.Name
        $fnPuzzle[$Found.Pos].PossibleValues = $Single.Name
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
function Show-Possibles {
  Param (
    $fnPuzzle
  )
  Write-Host
  $ConsoleBGColor = [console]::BackgroundColor
  foreach ($Row in (0..8)) {
    foreach ($SubRow in (1,4,7)) {
      foreach ($SubCol in (0..26)) {
        $Col = [math]::Truncate($SubCol / 3)
        $Num = ($SubCol % 3) + $SubRow
        $Numstr = $Num -as [string]
        $Pos = $Row * 9 + $Col 
        $BoxObj = $fnPuzzle[$Pos]
        if ($BoxObj.PossCount -eq 1) {$fg = $ConsoleBGColor}
        else {$fg = 'White'}
        If ($Num -in (3,6,9) -and $SubCol -ne 26){$Divider = ' |'; $DivFg = "DarkGray"}
        else {$Divider = ' '; $DivFg = 'Gray'}
        if ($SubCol -in (8,17))  {$Divider = ' |';$DivFg = 'Yellow' }
        If ($BoxObj.PossibleValues -contains $NumStr) {
          $Output = $Numstr
        }
        else {$Output = '-'; $fg = $ConsoleBGColor}
        Write-Host -NoNewline -ForegroundColor $fg "$Output"
        Write-Host -NoNewline -ForegroundColor $DivFg $Divider
      }
     Write-Host
    }
    if ($Row -ne 8) {
      if ($Row -in (2,5)) {      
        Write-Host -ForegroundColor Yellow '------+------+------+------+------+------+------+------+-----'
      }
      else {
        Write-Host -NoNewline -ForegroundColor 'DarkGray' '------+------+------'
        Write-Host -NoNewline -ForegroundColor 'Yellow' '+'
        Write-Host -NoNewline -ForegroundColor 'DarkGray' '------+------+------'
        Write-Host -NoNewline -ForegroundColor 'Yellow' '+'
        Write-Host -ForegroundColor 'DarkGray' '------+------+-----'
      }
    }
  }
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
      foreach ($Cell in $HiddenCells){$fnPuzzle[$Cell.Pos].PossibleValues = $Numbers}
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
      foreach ($Cell in $HiddenCells){$fnPuzzle[$Cell.Pos].PossibleValues = $Numbers}
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
      foreach ($Cell in $HiddenCells){$fnPuzzle[$Cell.Pos].PossibleValues = $Numbers}
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
  $PairsArray = @()
  foreach ($Col in (0..8)){
    $GroupCol = $fnPuzzle | Where-Object {$_.Col -eq $Col -and $_.PossCount -gt 1} | Group-Object -Property PossibleValues
    [array]$TwoOnly = $GroupCol | Where-Object {$_.Count -eq 2}
    if ($TwoOnly.Count -gt 0) {$PairsArray += $TwoOnly.Name}
  }
  
  # Need to find a val that appear only twice in two columns that form a rectangle
  # $fnPuzzle | Where-Object {$_.Col -eq $Col -and $_.PossCount -gt 1} | select-object -ExpandProperty possiblevalues | group-object
}

function Remove-XWingRow {
  Param (
    $fnPuzzle
  )
  $PairsArray = @()
  foreach ($Row in (0..8)){
    $GroupRow = $fnPuzzle | Where-Object {$_.Row -eq $Row} | Group-Object -Property PossibleValues
    [array]$TwoOnly = $GroupRow | Where-Object {$_.Count -eq 2}
    if ($TwoOnly.Count -gt 0) {$PairsArray += $TwoOnly.Name}
  }

  # Need to find a val that appear only twice in two rows that form a rectangle
}

function Remove-SwordFishCol {
  Param (
    $fnPuzzle
  )
  foreach ($TestNum in @(1..9)) {
    foreach ($RowNum in @(0..8)) { 
      $ObjPosMatching = $Board | Where-Object {$_.row -eq $RowNum -and $_.PossibleValues -contains $TestNum}
      $ColsWhereNumExists = $ObjPosMatching.col
      $NumOf = $ColsWhereNumExists.Count
      if ($NumOf -notin @(2,3)) {continue}
      else {
        
      }

    }
  }
}

function Remove-SwordFishRow {
  Param (
    $fnPuzzle
  )
  # 
}



##  Main Code ##
Clear-Host
$BeforeSolve = Get-Date
$Stumped = $false
$Brute1 = $false
$Brute2 = $false
$Board = Create-Board $Puzzle
Show-Board -fnPuzzle $Board
do {
  $BoardStrBefore = $Board.Val -join ''
  Remove-Possibles -fnPuzzle $Board

  Get-SoleCandidate -fnPuzzle $Board
  Remove-Possibles -fnPuzzle $Board

  Get-UniqueCandidate -fnPuzzle $Board
  Remove-Possibles -fnPuzzle $Board

  Remove-NakedPairCol -fnPuzzle $Board
  Remove-Possibles -fnPuzzle $Board

  Remove-NakedPairRow -fnPuzzle $Board
  Remove-Possibles -fnPuzzle $Board

  Remove-NakedPairBox -fnPuzzle $Board
  Remove-Possibles -fnPuzzle $Board
  Show-Board -fnPuzzle $Board

  Remove-XWingCol -fnPuzzle $Board
  Remove-Possibles -fnPuzzle $Board
 
  Remove-XWingRow -fnPuzzle $Board
  Remove-Possibles -fnPuzzle $Board


  Get-HiddenCandidate -fnPuzzle $Board
  Remove-Possibles -fnPuzzle $Board
 
  Remove-HiddenPossibles -fnPuzzle $Board
  Remove-Possibles -fnPuzzle $Board
  Show-Board -fnPuzzle $Board

  Remove-HiddenPairCol -fnPuzzle $Board
  Remove-Possibles -fnPuzzle $Board

  Remove-HiddenPairRow -fnPuzzle $Board
  Remove-Possibles -fnPuzzle $Board
 
  Remove-HiddenPairBox -fnPuzzle $Board
  Remove-Possibles -fnPuzzle $Board

  $BoardStrAfter = $Board.Val -join ''
  if ($BoardStrBefore -eq $BoardStrAfter -and $BoardStrAfter -match '\D') {
    Show-Possibles -fnPuzzle $Board
    Write-Host 'Stumped, add more code to solve the impossible ones'
    $Stumped = $true
    break
  }
  #$BadSolve = $false
  #foreach ($BoardPos in $Board) {
  #  if ($BoardPos.val -match '\D' -and $BoardPos.PossibleValues.Count -eq 0){
  #    $BadSolve = $true
  #  }
  #}
  #$BoardStrAfter = $Board.Val -join ''
  #if ($BoardStrBefore -eq $BoardStrAfter -and $BoardStrAfter -match '\D') {
  #  if ($Brute1 -eq $false -and $Brute2 -eq $false) {
  #    $Brute1 = $true
  #    $TwosPos = ($Board | Where-Object {$_.PossCount -eq 2} | Get-Random).Pos
  #    $Brute1Pick = $Board[$TwosPos].PossibleValues | Get-Random
  #    $Brute2Pick = $Board[$TwosPos].PossibleValues | Where-Object {$_ -ne $Brute1Pick}
  #    $BoardBackup = $Board.psobject.Copy()
  #    $Board[$TwosPos].PossibleValues = @($Brute1Pick)
  #    $Board[$TwosPos].PossValString = @($Brute1Pick)
  #    Remove-Possibles -fnPuzzle $Board
  #  }
  #  elseif ($BadSolve -eq $true -and $Brute2 -eq $false){
  #    $Board = $BoardBackup.psobject.Copy()
  #    $Brute2 = $true
# #     $BoardBackup = $Board.psobject.Copy()
  #    $Board[$TwosPos].PossibleValues = @($Brute2Pick)
  #    $Board[$TwosPos].PossValString = @($Brute2Pick)
  #    Remove-Possibles -fnPuzzle $Board
  #  }
  #  elseif (($Brute1 -eq $true -and $Brute2 -eq 2) -or $TwosPos.count -eq 0 ) {
  #    $Board = $BoardBackup.psobject.Copy()
  #    Show-Possibles -fnPuzzle $Board
  #    Write-Host 'Stumped, add more code to solve the impossible ones'
  #    $Stumped = $true
  #    break
  #  }
  #}
} until ($Board.Val -notcontains '-')
If ($Stumped -eq $false) {
  $AfterSolve = Get-Date
  $TotalSec = ($AfterSolve - $BeforeSolve).totalseconds
  Write-Host -ForegroundColor Yellow "`nIt took $TotalSec seconds to solve that one"
}

<#
function Compare-Array {
  Param (
    [Parameter(Mandatory=$true)]
    $RefArray,
    [Parameter(Mandatory=$true)]
    $DifArray
  )
  $RDEqual = $true
  $RDSubset = $true
  $DRSubset = $true
  $RDNonCom = $true
  # subsets
  foreach ($element in $RefArray) {
    if ($element -notin $DifArray) {$RDSubset = $false}
  }
  foreach ($element in $DifArray) {
    if ($element -notin $RefArray) {$DRSubset = $false}
  }
  # equal
  if ($RDSubset -eq $true -and $DRSubset -eq $true){$RDEqual = $true}
  else {$RDEqual = $false}

  # Do Dif and ref have non common elements
  if ($RDSubset -eq $false -and $DRSubset -eq $false){$RDNonCom = $true}
  else {$RDNonCom = $false}
  $Prop = [ordered]@{
    Ref = $RefArray
    Dif = $DifArray
    Equal = $RDEqual
    SubsetRD = $RDSubset
    SubSetDR = $DRSubset
    NonCommon = $RDNonCom
  }
  New-Object -TypeName psobject -Property $Prop
}

need a function that will compare these arrays to determine which are the same and subsets
0-1 1-2 2-3 3-4 4-5 5-6 6-7 7-8
0-2 1-3 2-4 3-5 4-6 5-7 6-8
0-3 1-4 2-5 3-6 4-7 5-8
0-4 1-5 2-6 3-7 4-8
0-5 1-6 2-7 3-8
0-6 1-7 2-8
0-7 1-8
0-8

##################
Some code to help identify xwing and swordfish
$Cols = ($Board | where {$_.row -eq 0 -and $_.possiblevalues -contains 3}).col
$NumOf = $Cols.Count 
# The $Cols help show us where the 3 is in this row 
# and $NumOf show us how many in this row (2) means xwing or swordfish (3) means swordfish only option
# Then we would need to search all other rows and compare cols to see if it is xwing 
# or swordfish or nothing at all
################
#>