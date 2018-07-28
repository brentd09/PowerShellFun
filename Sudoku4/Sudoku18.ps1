<#
.SYNOPSIS
  Solves SUDOKU puzzles
.DESCRIPTION
  The script takes in a puzzle in the form of a flat 81 char string of
  numbers and -'s for blanks. It will then attempt to solve the puzzle
  using SoleCandidate, UniqueCandidate, Hidden Pair, NakedSet techniques.
  Examples of puzzles:
    Easy       '-6-3--8-4537-9-----4---63-7-9--51238---------71362--4-3-64---1-----6-5231-2--9-8-'
    Medium     '-1--584-9--------1953---2--2---1--8-6--425--3-3--7---4--5---3973--------1-463--5-'
    Difficult  '-2-------17---9--4---1367--431---2------8------8---163--3624---2--8---49-------3-'
    Extreme    '89-2-3-------------3658---41-8-3--6-----------2--7-3-57---9412-------------8-2-59'
    Extreme    '--9748---7---------2-1-9-----7---24--64-1-59--98---3-----8-3-2---------6---2759--'
    Extreme    '--5--7--4-6--5--9-4--9--2--2--5--1---7--2--4---8--3--2--7--1--3-5--6--1-6--8--4--'
.EXAMPLE
  Sudoku -Puzzle '-6-3--8-4537-9-----4---63-7-9--51238---------71362--4-3-64---1-----6-5231-2--9-8-'
.NOTES
  General notes
    Created by: Brent Denny
    Created on: 17 Jul 2018
  Improved the old code by using a class and a class constructor
#>
[CmdletBinding()]
Param(
  $Puzzle = '--9748---7---------2-1-9-----7---24--64-1-59--98---3-----8-3-2---------6---2759--'
)
# Class - Create BoardPosition Obj
Class SudokuBoardPos {
  [int]$BoardPosition
  [String]$SudokuNumber
  [int]$BoardRow
  [int]$BoardCol
  [int]$BoardSqr
  [string[]]$WhatIsPossible
  [string[]]$RuledOut
  [string[]]$WhatRemains
  [string]$WhatRemainsStr
  # Class Constructor
  SudokuBoardPos ([String]$SudokuNumber,[int]$BoardPosition) {
    $this.SudokuNumber = $SudokuNumber
    $this.BoardPosition = $BoardPosition
    $this.BoardRow = [math]::Truncate($BoardPosition / 9)
    $this.BoardCol = $BoardPosition % 9
    if ($BoardPosition -in @(0,1,2,9,10,11,18,19,20)) {$this.BoardSqr = 0}
    elseif ($BoardPosition -in @(3,4,5,12,13,14,21,22,23)) {$this.BoardSqr = 1}
    elseif ($BoardPosition -in @(6,7,8,15,16,17,24,25,26)) {$this.BoardSqr = 2}
    elseif ($BoardPosition -in @(27,28,29,36,37,38,45,46,47)) {$this.BoardSqr = 3}
    elseif ($BoardPosition -in @(30,31,32,39,40,41,48,49,50)) {$this.BoardSqr = 4}
    elseif ($BoardPosition -in @(33,34,35,42,43,44,51,52,53)) {$this.BoardSqr = 5}
    elseif ($BoardPosition -in @(54,55,56,63,64,65,72,73,74)) {$this.BoardSqr = 6}
    elseif ($BoardPosition -in @(57,58,59,66,67,68,75,76,77)) {$this.BoardSqr = 7}
    elseif ($BoardPosition -in @(60,61,62,69,70,71,78,79,80)) {$this.BoardSqr = 8}
    $this.WhatRemains = $null
    $this.WhatRemainsStr = $this.WhatRemains -join ''
  }
}
# Logic to remove one array from another # $Obj.WhatIsPossible | Where-Object {$_ -notin $Obj.RuledOut}
# Functions
function New-BoardObj {
  Param(
    [string]$RawBrd
  )
  [string[]]$SplitBoard = $RawBrd.ToCharArray()
  $count = 0
  foreach ($element in $SplitBoard) {
    [SudokuBoardPos]::New($element,$count)
    $count++
  }
}
function Show-SudokuBoard {
  param (
    $BoardObj
  )
  $Coords = New-Object -TypeName System.Management.Automation.Host.Coordinates
  $host.UI.RawUI.CursorPosition = $Coords
  Write-Host
  $Margin = '   '
  $LineColor = "DarkCyan"
  $NumberColor = "Cyan"
  $NumberComplete = "Yellow"
  $BlankColor = "Red"
  Write-Host -ForegroundColor $LineColor "$Margin -----------------------"
  foreach ($ShowRow in (0..8)) {
    Write-Host -NoNewline $Margin
    foreach ($ShowCol in (0..8)) {
      if ($ShowCol -eq 0) {Write-Host -NoNewline -ForegroundColor $LineColor "| "}
      $BoardPosObj = $BoardObj | Where-Object {$_.BoardRow -eq $ShowRow -and $_.BoardCol -eq $ShowCol}
      $HowMany = ($BoardObj | Where-Object {$_.SudokuNumber -eq $BoardPosObj.SudokuNumber}).count
      if ($BoardPosObj.SudokuNumber -match '\d' -and $HowMany -eq 9 ){Write-Host -NoNewline -ForegroundColor $NumberComplete $BoardPosObj.SudokuNumber}
      if ($BoardPosObj.SudokuNumber -match '\d' -and $HowMany -lt 9 ){Write-Host -NoNewline -ForegroundColor $NumberColor $BoardPosObj.SudokuNumber}
      if ($BoardPosObj.SudokuNumber -eq '-') {Write-Host -NoNewline -ForegroundColor $BlankColor $BoardPosObj.SudokuNumber}
      Write-Host -NoNewline " "
      if ($ShowCol -eq 2 -or $ShowCol -eq 5 -or $ShowCol -eq 8) {Write-Host -NoNewline -ForegroundColor $LineColor "| "}
    } # foreach showcol
    Write-Host # This is to seperate the rows
    if ($ShowRow -eq 2 -or $ShowRow -eq 5) {Write-Host -ForegroundColor $LineColor "$Margin|-----------------------|"}

  } #foreach showrow
  Write-Host -ForegroundColor $LineColor "$Margin -----------------------"
} # fn Showboard
function Complete-SoleCandidate {
  Param(
    $BoardObj
  )
  $AllNumbers = @('1','2','3','4','5','6','7','8','9')
  foreach ($Pos in (0..80)){
    if ($BoardObj[$Pos].SudokuNumber -eq '-') {
      $AllRelatedObj = $BoardObj | Where-Object {
        $_.BoardCol -eq $BoardObj[$Pos].BoardCol -or
        $_.BoardRow -eq $BoardObj[$Pos].BoardRow -or
        $_.BoardSqr -eq $BoardObj[$Pos].BoardSqr
      }
      $AllRelatedNums = $AllRelatedObj.SudokuNumber |
        Where-Object {$_ -ne '-'} |
        Select-Object -Unique |
        Sort-Object
      $WhatsMissing = (Compare-Object -ReferenceObject $AllRelatedNums -DifferenceObject $AllNumbers).InputObject
      if (($WhatsMissing | Measure-Object).Count -eq 1) {
        $BoardObj[$Pos].SudokuNumber = $WhatsMissing
        $BoardObj[$Pos].WhatIsPossible = $null
        $BoardObj[$Pos].WhatRemains = $null
        $BoardObj[$Pos].WhatRemainsStr = $null
      }#found unique solution
      else {
        $BoardObj[$Pos].WhatIsPossible = $WhatsMissing
        $BoardObj[$Pos].WhatRemains = $BoardObj[$Pos].WhatIsPossible | Where-Object {$_ -notin $BoardObj[$Pos].RuledOut}
        $BoardObj[$Pos].WhatRemainsStr = ($BoardObj[$Pos].WhatIsPossible | Where-Object {$_ -notin $BoardObj[$Pos].RuledOut} | Sort-Object) -join ''
      }
    }
  }
  return $BoardObj
}
function Complete-UniqueCandidate {
  Param (
    $BoardObj
  )
  foreach ($Sqr in (0..8)){
    $PosNumInSqr = ($BoardObj | Where-Object {$_.BoardSqr -eq $Sqr -and $_.SudokuNumber -eq '-'}).WhatRemains
    $UniqueNums = $PosNumInSqr | Sort-Object | Group-Object | Where-Object {$_.Count -eq 1}
    foreach ($UniqueNum in $UniqueNums) {
      $WhichPos = ($BoardObj | Where-Object {$_.WhatIsPossible -contains $UniqueNum.Group -and $_.BoardSqr -eq $sqr}).BoardPosition
      $BoardObj[$WhichPos].SudokuNumber = $UniqueNum.Group
      $BoardObj[$WhichPos].WhatIsPossible = $null
      $BoardObj[$WhichPos].WhatRemains = $null
      $BoardObj[$WhichPos].WhatRemainsStr = $null
    }
  }
}
function Complete-HiddenPair {
  param (
    $BoardObj
  )


    $PairObj = $BoardObj | Where-Object {$_.whatremains.count -eq 2}
    $DuplicatedStrings = ($PairObj | Group-Object -Property whatremainsstr | Where-Object {$_.count -ge 2}).name
    $DuplicatObjects = $PairObj | Where-Object {$_.whatremainsstr -in $DuplicatedStrings}
    Write-Verbose $DuplicatObjects
    ## Locate which rows col and sqr these appear in 
    ## if found then add pair array to ruledout property fr all other candidates in the group- r c s


#  if (-not ($b | foreach {$_ -in $a}) -eq $false) {"subset yes"} # this will test if an array is a subset of another array
# this tests if $b array is a subset of $a array
  #Sqrs
  ##  foreach ($SqrNum in (0..8)) {
  ##    $HiddenPairValues = ($boardobj | Where-Object {$_.boardsqr -eq $SqrNum} | Select-Object -ExpandProperty WhatRemains | Group-Object -NoElement | Where-Object count -eq 2).Name
  ##    $HiddenPairPos = $BoardObj | Where-Object {$_.boardsqr -eq $SqrNum -and $_.WhatRemains -contains $HiddenPairValues}
  ##  }

  <#
    This will determine if a value only appears twice in a sqr.
    we then need to determine if there are more than one of these
    and then figured out if they are the same positions. If they
    are then the Ruled out can be all but theses values in these
    positions.
    $HiddenPairValues = ($boardobj |
                           where {$_.boardsqr -eq 0} |
                           Select-Object -ExpandProperty whatremains |
                           Group-Object -NoElement |
                           where count -eq 2).Name
  #>
  # this seeks for a pair of numbers that appear in a sqr, col, row and all other values in that list
  # can be removed from this pair as they have to be one of the two values
}
function Complete-NakedPair {
  Param(
    $BoardObj
  )


}
function Complete-Xwing {
  # This is how we can scan for an xwing, the results would need to come back as the same number
  # appearing twice in two places where the row -eq col and col -eq row of each
  # $BoardObj | Where-Object {$_.whatremains -contains 1 } | ft
}

function Complete-SwordFish {
  # need to look for candidate values and where they exist on the board
  # to be a swordfish they need to be in a configuration where the number
  # is found only 3 times in a row or col and then the same situation happens
  # three times only in the board, for example:
  <#
  Below is a result from $BoardObj | Where-Object {$_.whatremains -contains 5 }| ft
  and this shows a swordfish pattern by looking at the rows that are listed 3 times
  and then seeing the pattern repeated with the cols 0,1,7 or 0,1 as swordfish can have one
  row with 2 only

  BoardPosition SudokuNumber BoardRow BoardCol BoardSqr WhatIsPossible RuledOut WhatRemains
------------- ------------ -------- -------- -------- -------------- -------- -----------
            0 -                   0        0        0 {3, 5, 6}               {3, 5, 6}    !
            1 -                   0        1        0 {1, 3, 5}               {1, 3, 5}    !
            7 -                   0        7        2 {1, 3, 5}               {1, 3, 5}    !
           11 -                   1        2        0 {1, 3, 5}               {1, 3, 5}
           13 -                   1        4        1 {3, 5}                  {3, 5}
           16 -                   1        7        2 {1, 3, 5, 8}            {1, 3, 5, 8}
           20 -                   2        2        0 {3, 5, 6}               {3, 5, 6}
           22 -                   2        4        1 {3, 5}                  {3, 5}
           25 -                   2        7        2 {3, 5, 7, 8}            {3, 5, 7, 8}
           26 -                   2        8        2 {3, 4, 5}               {3, 4, 5}
           27 -                   3        0        3 {3, 5}                  {3, 5}       !
           28 -                   3        1        3 {3, 5}                  {3, 5}       !
           55 -                   6        1        6 {1, 4, 5, 7}            {1, 4, 5, 7}
           56 -                   6        2        6 {1, 5}                  {1, 5}
           62 -                   6        8        8 {4, 5}                  {4, 5}
           63 -                   7        0        6 {3, 5, 8}               {3, 5, 8}    !
           64 -                   7        1        6 {3, 5, 7, 8}            {3, 5, 7, 8} !
           70 -                   7        7        8 {3, 5, 7, 8}            {3, 5, 7, 8} !
  #>
}


########### MAIN CODE ############
Clear-Host
$RawBoard = $Puzzle -replace "[^1-9]",'-'
$BoardObj = New-BoardObj -RawBrd $RawBoard
Show-SudokuBoard -BoardObj $BoardObj
do {
  $InitBlankCount = ($BoardObj | Where-Object {$_.SudokuNumber -eq '-'} | Measure-Object ).Count
  $BoardObj = Complete-SoleCandidate -BoardObj $BoardObj
  $FinalBlankCount = ($BoardObj | Where-Object {$_.SudokuNumber -eq '-'} | Measure-Object ).Count
  if ($FinalBlankCount -eq $InitBlankCount) {
    Complete-UniqueCandidate -BoardObj $BoardObj
    $FinalBlankCount = ($BoardObj | Where-Object {$_.SudokuNumber -eq '-'} | Measure-Object ).Count
    if ($FinalBlankCount -eq $InitBlankCount) {
      Complete-HiddenPair -BoardObj $BoardObj
      $FinalBlankCount = ($BoardObj | Where-Object {$_.SudokuNumber -eq '-'} | Measure-Object ).Count
      if ($FinalBlankCount -eq $InitBlankCount) {

      }

    }
  }
  Show-SudokuBoard -BoardObj $BoardObj
  if ($BoardObj.SudokuNumber -contains '-'){
    Start-Sleep -Milliseconds 500
  }
} while ($BoardObj.SudokuNumber -contains '-')


# if ( -not ($a|Where-Object{$_ -notin $b}) -and  -not ($b|Where-Object{$_ -notin $a})){$true}else{false}
# Tests to see if two arrays have the same values

# code to check for pairs
###########################
# $pairs = $BoardObj | where {$_.whatremains.count -eq 2} | Group-Object -Property whatremainsstr | where {$_.count -eq 2}
# $BoardObj | where whatremainsstr -eq $Pairs.Name