<#
.Synopsis
   Sudoku solver
.DESCRIPTION
   This solver currently only solves puzzles that can be solved by 
   finding unique positive solutions, I am yet to write the logic 
   for the negative solutions (where a cell cannot contain a value
   based on other ROWS and COLS around it that are not related to 
   the cell), This also does "Naked Set" recognition and solving 
   and if all else fails it will start to use very educated guesses
   to solve the puzzle.
.EXAMPLE
   Solve-Sudoku

   This will get the contents from a sudoku.txt file in the $env:TEMP directory
.EXAMPLE
   $env:TEMP\sudoku.txt contents example

   -1786----
   ---7-4185
   5--------
   1-84-37-6
   39-----54
   2-46-98-3
   --------8
   7625-8---
   ----7164-

   or 

   73--28---8----1--9--9--6--------78----1---2----65--------4--9--693-----4---19--56

   or

   73..28...8....1..9..9..6........78....1...2....65........4..9..693.....4...19..56

   As long as the empty spaces are filled with a non number character 
   this script will work as expected.
.NOTES
   General notes
   Created by: Brent Denny
   Created date: 26 Dec 2016
#>
[CmdletBinding()]
Param (
  [string]$SudokuFileLocation = "$env:temp\Sudoku.txt"
)

function Get-Sudoku { # Get the data for the sudoku puzzle from a text file
  param($FilePath)
  # Get Sudoku board from file
  $RawSudokuData =  Get-Content $FilePath 
  # Create 81 character length string from the raw data, if needed
  if ($RawSudokuData.Length -ne 81) {
    $RawSudokuData = $RawSudokuData  -join '' -split '' -join ''
  }
  if ($RawSudokuData.Length -eq 81) {
    $RawSudokuData -replace "\D",'-'
  }
  else {
    Throw "The Sudoku text file is not in the correct format, see help for assistance"
  }
}

function Get-BlankPos { # Locate which positions still are empty place them in an aray
  param ($StringSudoku) 
  # Find Blank positions
  $count = 0
  $BlankPos = @()
  ForEach ($Char in ($StringSudoku -as [char[]])) {
    if ( $Char -eq '-' ) { $BlankPos += $count}
    $count++
  }
  $BlankPos
}

function Get-Row { # Get each Row and place it in an array
  param ($StringSudoku)
  $Row = @()
  foreach ($RowNumber in 0..8) {
    $Start = ($RowNumber * 9)
    $End = ($RowNumber * 9) + 8
    $Row += $StringSudoku[$Start..$End] -join ''
  }
  $Row
}

function Get-Col { # Get each Column and place it in an array
  param ($StringSudoku)
  $Col = @()
  foreach ($ColNumber in 0..8) {
    foreach ($Element in 0..8) { Set-Variable -Name ColElement$Element -Value ((9 * $Element) + $ColNumber) }
    $Col += $StringSudoku[$ColElement0,$ColElement1,$ColElement2,$ColElement3,$ColElement4,$ColElement5,$ColElement6,$ColElement7,$ColElement8] -join ''
  }
  $Col
}

function Get-Block { # Get each Block of 9 characters and place them in an array
  param($Row)
  $Block = @()
  foreach ($BlockNumber in 0..8) {
    $StartPos = ($BlockNumber % 3 ) * 3
    $EndPos = $StartPos + 2
    $StartRow = ([Math]::Truncate($BlockNumber / 3)) * 3 
    $Block += $Row[$StartRow][$StartPos..$EndPos]+$Row[$StartRow+1][$StartPos..$EndPos]+$Row[$StartRow+2][$StartPos..$EndPos] -join ''
  }
  $Block
}

function Resolve-PosibleValues { # Check aginst the ROW and COL and CURRENT BLOCK to see what numbers are possible in the empty cells
  Param( $StringSudoku, $Block , $BlankPos, $Row, $Col, $MissingObj )
  foreach ($Pos in $BlankPos) {
    switch ($Pos) {
      {$_ -in 0,1,2,9,10,11,18,19,20} {$PosInBlock = 0;break}  #Block 0
      {$_ -in 3,4,5,12,13,14,21,22,23} {$PosInBlock = 1;break}  #Block 1
      {$_ -in 6,7,8,15,16,17,24,25,26} {$PosInBlock = 2;break}  #Block 2
      {$_ -in 27,28,29,36,37,38,45,46,47} {$PosInBlock = 3;break}  #Block 3
      {$_ -in 30,31,32,39,40,41,48,49,50} {$PosInBlock = 4;break}  #Block 4
      {$_ -in 33,34,35,42,43,44,51,52,53} {$PosInBlock = 5;break}  #Block 5
      {$_ -in 54,55,56,63,64,65,72,73,74} {$PosInBlock = 6;break}  #Block 6
      {$_ -in 57,58,59,66,67,68,75,76,77} {$PosInBlock = 7;break}  #Block 7
      {$_ -in 60,61,62,69,70,71,78,79,80} {$PosInBlock = 8;break}  #Block 8
      Default {}
    } # Switch $pos
    if ($MissingObj.modified -ne 1) {
      $AllPossibleNum = '123456789' -as [char[]]
      $PosRow = [math]::Truncate($Pos / 9)
      $PosCol = $Pos % 9
      $CombinedNum = ($Row[$PosRow]+$Col[$PosCol]+$Block[$PosInBlock] -join '' -replace '-','' ) -as [char[]]| Select-Object -Unique | Sort-Object
      $WhatsMissing = ((Compare-Object $AllPossibleNum $CombinedNum).inputobject ) -join ''
      $MissingVals = [ordered]@{ 
        Position = $Pos
        Numbers = $WhatsMissing
        Row = $PosRow
        Col = $PosCol
        Count = $WhatsMissing.length
        Block = $PosInBlock
        Array = $WhatsMissing -as [Char[]]
        Modified = 0
      }
      $MissingObject = New-Object -TypeName psobject -Property $MissingVals
      $MissingObject
    }
  }  
}

function Find-NakedColSet {
  Param ($MissingObj)
  # Nude Column Set 
  # the problem with this is that the [] number does not match the the position number 
  # I need to identify how to assign the [] value from the reference of the position property??
  $NudeColSet =  $MissingObj | Where-Object {$_.count -eq 2} | Group-Object col,numbers | Where-Object count -eq 2
  foreach ($NudeCol in $NudeColSet ) {
    $NudeColNumber = $NudeCol.Name[0] -as [string] -as [int]
    $NudeColString = (($NudeCol.name -as [string]) -split ',\s*')[1]
    $NudeColRegEx = [regex]::Escape($NudeColString)
    $MissColArray = $MissingObj | Where-Object {$_.Col -eq $NudeColNumber -and $_.numbers -ne $NudeColString } 
    foreach ($MissCol in $MissColArray) {
      $IndexOfPosition = [array]::IndexOf($MissingObj.Position,$MissCol.Position)
      $MissingObj[$IndexOfPosition].numbers = $MissCol.numbers -replace "[$NudeColRegEx]",''
      $MissingObj[$IndexOfPosition].count = $MissingObj[$IndexOfPosition].numbers.length
      $MissingObj[$IndexOfPosition].array = $MissingObj[$IndexOfPosition].numbers -as [char[]]
      $MissingObj[$IndexOfPosition].modified = 1
    }
  }
  # Nude Row Set 

  $MissingObj
}

function Find-NakedRowSet {
  Param ($MissingObj)
  # Nude Rowumn Set 
  # the problem with this is that the [] number does not match the the position number 
  # I need to identify how to assign the [] value from the reference of the position property??
  $NudeRowSet =  $MissingObj | Where-Object {$_.count -eq 2} | Group-Object Row,numbers | Where-Object count -eq 2
  foreach ($NudeRow in $NudeRowSet ) {
    $NudeRowNumber = $NudeRow.Name[0] -as [string] -as [int]
    $NudeRowString = (($NudeRow.name -as [string]) -split ',\s*')[1]
    $NudeRowRegEx = [regex]::Escape($NudeRowString)
    $MissRowArray = $MissingObj | Where-Object {$_.Row -eq $NudeRowNumber -and $_.numbers -ne $NudeRowString } 
    foreach ($MissRow in $MissRowArray) {
      $IndexOfPosition = [array]::IndexOf($MissingObj.Position,$MissRow.Position)
      $MissingObj[$IndexOfPosition].numbers = $MissRow.numbers -replace "[$NudeRowRegEx]",''
      $MissingObj[$IndexOfPosition].count = $MissingObj[$IndexOfPosition].numbers.length
      $MissingObj[$IndexOfPosition].array = $MissingObj[$IndexOfPosition].numbers -as [char[]]
      $MissingObj[$IndexOfPosition].modified = 1
    }
  }
  # Nude Row Set 

  $MissingObj
}


function Find-SinglesInBlock {
  Param($MissingObj)
  foreach ($BlockNum in (0..8)) {
    $SingleVals =  (($MissingObj | where block -eq $BlockNum ).array | group | where count -eq 1).Name
    foreach ($SingleVal in $SingleVals) {
      $SingleCell = $MissingObj | where {$_.array -Contains $SingleVal -and $_.block -eq $BlockNum}
      $IndexOfPosition = [array]::IndexOf($MissingObj.Position,$SingleCell.Position)
      $MissingObj[$IndexOfPosition].numbers = $SingleVal
      $MissingObj[$IndexOfPosition].count = $MissingObj[$IndexOfPosition].numbers.length
      $MissingObj[$IndexOfPosition].array = $MissingObj[$IndexOfPosition].numbers -as [char[]]
      $MissingObj[$IndexOfPosition].modified = 1
    }
  }
  $MissingObj
}

function Check-Duplicates { # This will return $true if there are duplicates *CAREFUL*
  Param ($NumberGroup)
  $result = $false
  $Numbers = $NumberGroup -replace '-',''
  $UniqueNumbers =  ($Numbers -as [char[]] | Select-Object -Unique) -join ''
  if ($Numbers -ne $UniqueNumbers) {$result = $true}
  $result
}

function Add-NumbersToSudoku { # Add the numbers we are sure about to the puzzle
  Param($SingleNumbers,$StringSudoku)
  $SudokuArray = $StringSudoku -as [char[]]
  foreach ($Number in $SingleNumbers) {
    $SudokuArray[$Number.Position] = $Number.Numbers
  }
  $SudokuArray -join ''
}

function Clear-ValInRow {
  param ($MissingObj)
  foreach ($BlockNum in (0..8)) {
    foreach ($CellValue in (1..9)) {
      $CellValueStr = $CellValue -as [string]
      $MissNumLocations = $MissingObj | Where-Object {$_.block -eq $BlockNum} | Where-Object array -Contains $CellValueStr | Select-Object row | Group-Object row
      if ($MissNumLocations.length -eq 1) {
        $RowToModify = $MissNumLocations.name -as [int]
        $RowToModRegEx = [regex]::Escape($CellValueStr)
        $CellsToModify = $MissingObj | Where-Object {$_.array -contains $CellValueStr -and $_.row -eq $RowToModify -and $_.block -ne $BlockNum}
        foreach ($Cell in $CellsToModify) {
          $IndexOfPosition = [array]::IndexOf($MissingObj.Position,$Cell.Position)
          $MissingObj[$IndexOfPosition].numbers = $MissingObj[$IndexOfPosition].numbers -replace "$RowToModRegEx",''
          $MissingObj[$IndexOfPosition].count = $MissingObj[$IndexOfPosition].numbers.length
          $MissingObj[$IndexOfPosition].array = $MissingObj[$IndexOfPosition].numbers -as [char[]]
          $MissingObj[$IndexOfPosition].modified = 1

        }
      }
    }
  }
  $MissingObj
}

function Check-MissingIssues {
  Param ($MissingObj)
  $Problems = $false
  foreach ($Miss in $MissingObj) {
    if ($miss.count =0) {$Problems = $true}
  }
  $Problems
}

function Clear-ValInCol {
  param ($MissingObj)
  foreach ($BlockNum in (0..8)) {
    foreach ($CellValue in (1..9)) {
      $CellValueStr = $CellValue -as [string]
      $MissNumLocations = $MissingObj | Where-Object {$_.block -eq $BlockNum} | Where-Object array -Contains $CellValueStr | Select-Object Col | Group-Object Col
      if ($MissNumLocations.length -eq 1 ) {
        $ColToModify = $MissNumLocations.name -as [int]
        $ColToModRegEx = [regex]::Escape($CellValueStr)
        $CellsToModify = $MissingObj | Where-Object {$_.array -contains $CellValueStr -and $_.Col -eq $ColToModify -and $_.block -ne $BlockNum}
        foreach ($Cell in $CellsToModify) {
          $IndexOfPosition = [array]::IndexOf($MissingObj.Position,$Cell.Position)
          $MissingObj[$IndexOfPosition].numbers = $MissingObj[$IndexOfPosition].numbers -replace "$ColToModRegEx",''
          $MissingObj[$IndexOfPosition].count = $MissingObj[$IndexOfPosition].numbers.length
          $MissingObj[$IndexOfPosition].array = $MissingObj[$IndexOfPosition].numbers -as [char[]]
          $MissingObj[$IndexOfPosition].modified = 1

        }
      }
    }
  }
  $MissingObj
}
 
function Display-Puzzle {
  Param($RowOrig,$RowData)
  Clear-Host
  $OCount = 0; $RCount = 0
  Write-Host -ForegroundColor Cyan "Original Puzzle"
  foreach ($ORow in $RowOrig) { 
    $OCount++
    $RowChars = $ORow -as [char[]] -as [string]
    Write-Host $RowChars.substring(0,6) -NoNewline 
    Write-Host -ForegroundColor Yellow "| " -NoNewline 
    Write-Host $RowChars.substring(6,6) -NoNewline 
    Write-Host -ForegroundColor Yellow "| " -NoNewline 
    Write-Host $RowChars.substring(12,5)
    if ($OCount -eq 3 -or $OCount -eq 6) {Write-Host -ForegroundColor Yellow "------+-------+------"}
  }
  Write-Host -ForegroundColor Cyan "`nSolving Puzzle"
  foreach ($Row in $RowData) { 
    $RCount++
    $RowChars = $Row -as [char[]] -as [string]
    Write-Host $RowChars.substring(0,6) -NoNewline 
    Write-Host -ForegroundColor Yellow "| " -NoNewline 
    Write-Host $RowChars.substring(6,6) -NoNewline 
    Write-Host -ForegroundColor Yellow "| " -NoNewline 
    Write-Host $RowChars.substring(12,5)
    if ($RCount -eq 3 -or $RCount -eq 6) {Write-Host -ForegroundColor Yellow "------+-------+------"}
  }
}

  
#-------------------#
#     Main Code     #
#-------------------#
#$ErrorActionPreference = "silentlycontinue"
Clear-Host
$Guessing = $false; $Wait = 300; $Turns = 0; $GuessTurns = 0
$SudokuPuz = @(); $Row = @(); $Col = @(); $Block = @(); $Blank = @(); $Missing = @()
$SudokuPuz = Get-Sudoku -FilePath $SudokuFileLocation
$OrigPuzzle = $SudokuPuz
$OrigRow  = Get-Row -StringSudoku $OrigPuzzle
$Backup = $false

do {
  # Get sudoku info ROWs, COLs, BLOCKs, MISSING, POSSIBLES, SINGLES
  $Turns++ 
  $Row  = Get-Row -StringSudoku $SudokuPuz
  $Col = Get-Col -StringSudoku $SudokuPuz
  $Block = Get-Block -Row $Row
  $Blank = Get-BlankPos -StringSudoku $SudokuPuz
  $Missing = Resolve-PosibleValues -StringSudoku $SudokuPuz -Block $Block -BlankPos $Blank -Row $Row -Col $Col -MissingObj $Missing
    $SingleNums = $Missing | Where-Object {$_.count -eq 1}    
  $SudokuPuz = Add-NumbersToSudoku -SingleNumbers $SingleNums -StringSudoku $SudokuPuz
  $Row  = Get-Row -StringSudoku $SudokuPuz
  $Col = Get-Col -StringSudoku $SudokuPuz
  $Block = Get-Block -Row $Row
  # Show Sudoku information with new numbers added
  Display-Puzzle -RowOrig $OrigRow -RowData $Row
  Start-Sleep -Milliseconds $Wait
  $Missing = Clear-ValInRow -MissingObj $Missing
  $SingleNums = $Missing | Where-Object {$_.count -eq 1}    
  $SudokuPuz = Add-NumbersToSudoku -SingleNumbers $SingleNums -StringSudoku $SudokuPuz
  $Row  = Get-Row -StringSudoku $SudokuPuz
  $Col = Get-Col -StringSudoku $SudokuPuz
  $Block = Get-Block -Row $Row
  # Show Sudoku information with new numbers added
  Display-Puzzle -RowOrig $OrigRow -RowData $Row
  Start-Sleep -Milliseconds $Wait
  $Missing = Clear-ValInCol -MissingObj $Missing
  $SingleNums = $Missing | Where-Object {$_.count -eq 1}    
  $SudokuPuz = Add-NumbersToSudoku -SingleNumbers $SingleNums -StringSudoku $SudokuPuz
  $Row  = Get-Row -StringSudoku $SudokuPuz
  $Col = Get-Col -StringSudoku $SudokuPuz
  $Block = Get-Block -Row $Row
  # Show Sudoku information with new numbers added
  Display-Puzzle -RowOrig $OrigRow -RowData $Row
  Start-Sleep -Milliseconds $Wait
  $Missing = Find-SinglesInBlock -MissingObj $Missing
  $SingleNums = $Missing | Where-Object {$_.count -eq 1}    
  $SudokuPuz = Add-NumbersToSudoku -SingleNumbers $SingleNums -StringSudoku $SudokuPuz
  $Row  = Get-Row -StringSudoku $SudokuPuz
  $Col = Get-Col -StringSudoku $SudokuPuz
  $Block = Get-Block -Row $Row
  # Show Sudoku information with new numbers added
  Display-Puzzle -RowOrig $OrigRow -RowData $Row
  Start-Sleep -Milliseconds $Wait
  $Missing = Find-NakedColSet -MissingObj $Missing
  $SingleNums = $Missing | Where-Object {$_.count -eq 1}    
  $SudokuPuz = Add-NumbersToSudoku -SingleNumbers $SingleNums -StringSudoku $SudokuPuz
  $Row  = Get-Row -StringSudoku $SudokuPuz
  $Col = Get-Col -StringSudoku $SudokuPuz
  $Block = Get-Block -Row $Row
  # Show Sudoku information with new numbers added
  Display-Puzzle -RowOrig $OrigRow -RowData $Row
  Start-Sleep -Milliseconds $Wait 
  $Missing = Find-NakedRowSet -MissingObj $Missing
  $dup = $false

  
  #start guessing if no clear values exist but still have missing values
  if (($Missing | Where-Object {$_.count -eq 1}).count -eq 0 -and ($SudokuPuz -as [char[]] -contains "-" -and $GuessTurns -eq 0)) {
    if ($Backup -eq $false) {
      $BackupTurns = $Turns
      $BackupPuz = $SudokuPuz
      $BackupMis = $Missing
      $BackupRow = $Row
      $BackupCol = $Col
      $BackupBlock = $Block
      $BackupBlank = $Blank
    }
 
 
    if ($Missing.count -contains 2 -and $GuessTurns -eq 0) {
      $RandomCell = $Missing | Where-Object {$_.count -eq 2} | Get-Random 
    }
    elseif ($GuessTurns -eq 0 -and $Missing -ne $null) {
      $RandomCell = $Missing | Get-Random 
    }
    if ($Missing -ne $null) {
      $GuessNumber = (($RandomCell.Numbers -as [char[]]) | Get-Random ) -as [string]
      $GuessPosition = $RandomCell.Position
      $IndexGuessPos = [array]::IndexOf($Missing.Position,$RandomCell.Position)
      $Missing[$IndexGuessPos].numbers = $GuessNumber
      $Missing[$IndexGuessPos].count  = 1
      $Missing[$IndexGuessPos].array = $GuessNumber -as [char[]]
      $Missing[$IndexGuessPos].Modified = 1
      $GuessTurns++
    }
  }
  $Missing = Clear-ValInRow -MissingObj $Missing
  $Missing = Clear-ValInCol -MissingObj $Missing
  $Missing = Find-SinglesInBlock -MissingObj $Missing
  $Missing = Find-NakedColSet -MissingObj $Missing 
  $Missing = Find-NakedRowSet -MissingObj $Missing
  if ($SudokuPuz -eq $OldPuz) {$dup = $true}
  foreach ($BNum in (0..8)){ 
    if (Check-Duplicates -NumberGroup Block[$Bnum]) {$dup = $true}  
  }
    foreach ($RNum in (0..8)){ 
    if (Check-Duplicates -NumberGroup Row[$RNum]) {$dup = $true}  
  }
  foreach ($CNum in (0..8)){ 
    if (Check-Duplicates -NumberGroup Col[$CNum]) {$dup = $true}  
  }
  $OldPuz = $SudokuPuz
  if (($missing.numbers) -contains "" -or $dup ) {
    $Turns = $BackupTurns
    $SudokuPuz = $BackupPuz 
    $Missing = $BackupMis
    $Row = $BackupRow
    $Col = $BackupCol
    $Block = $BackupBlock
    $Blank = $BackupBlank
    $GuessTurns = 0
    continue
  }
  if ($Missing -eq "") {
    $SingleNums = $Missing | Where-Object {$_.count -eq 1}    
    $SudokuPuz = Add-NumbersToSudoku -SingleNumbers $SingleNums -StringSudoku $SudokuPuz
  }
  $Row  = Get-Row -StringSudoku $SudokuPuz
  $Col = Get-Col -StringSudoku $SudokuPuz
  $Block = Get-Block -Row $Row
  # Show Sudoku information with new numbers added
  Display-Puzzle -RowOrig $OrigRow -RowData $Row
  #Start-Sleep -Milliseconds $Wait
} while (($SudokuPuz -as [char[]]) -contains "-") # Repeat the process until there is no numbers missing
Write-Host -ForegroundColor Yellow "   SOLVED    "