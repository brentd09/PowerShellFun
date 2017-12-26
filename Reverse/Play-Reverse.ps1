<#
.SYNOPSIS
  This is the OTHELLO game 
.DESCRIPTION
  The moves are made only if you can swap some of the opponents
  pieces to your color, to do this you place your color on a space 
  that is unoccupied but is next to your opponents color but only
  if your color is also other side of the opponents color pieces 
.NOTES

  Created By: Brent Denny
  Created On: 20 Dec 2017

  Board Numbers
  -------------

  00 01 02 03 04 05 06 07  starts with 27 = W 28 = B 
  08 09 10 11 12 13 14 15              35 = B 36 = W
  16 17 18 19 20 21 22 23  All others = -
  24 25 26 27 28 29 30 31 
  32 33 34 35 36 37 38 39
  40 41 42 43 44 45 46 47
  48 49 50 51 52 53 54 55
  56 57 58 59 60 61 62 63
#>
function Draw-Board {
  Param (
    $BoardObj
  )  
  $numOfWhite = ($BoardObj | where {$_.color -eq "W"}).count
  $numOfRed = ($BoardObj | where {$_.color -eq "R"}).count
  $LeftSpc = '  '
  Clear-Host
  Write-Host  -ForegroundColor Cyan "`n$LeftSpc                         --SCORE--"
  Write-Host  -NoNewline -ForegroundColor Cyan  "$LeftSpc  --  REVERSE  --"
  Write-Host -ForegroundColor White   "        White: $numOfWhite"
  Write-Host -NoNewline -ForegroundColor Yellow "$LeftSpc  1 2 3 4 5 6 7 8"
  Write-Host -ForegroundColor Red "        Red:   $numOfRed"
  foreach ($start in (0,8,16,24,32,40,48,56)) {
    $num = ($start / 8) + 65
    $letter = [char]$num # Build the A B C... on the left of the board
    Write-Host -ForegroundColor Yellow -NoNewline $LeftSpc$letter
    Write-Host -NoNewline " "
    $start..($Start+7) | foreach {
      if ($BoardObj[$_].color -eq "W") {$fgColor = "White"; $Piece = "O "}
      if ($BoardObj[$_].color -eq "R") {$fgColor = "Red"; $Piece = "O "}
      if ($BoardObj[$_].color -eq "-") {$fgColor = "darkgray"; $Piece = "- "}
      Write-Host -NoNewline -ForegroundColor $FGColor $Piece 
    }
    write-host
  }


}

function Convert-ArrayToObject {
  Param ($fnBoard)

  $count = 0
  foreach ($val in $fnBoard) {
    $col = $count % 8
    $row = [math]::Truncate($count/8)
    $objProp = [ordered]@{
      index = $count
      Color = $val
      Column = $col
      Row = $row
      FwDiag = $row + $col
      RvDiag = 7 + $col - $row
    }
    new-object -TypeName psobject -Property $objProp
    $count++
  }
}   

function Find-LegalMoves {
  Param (
    $BoardObj,
    $Color
  )
  $CurrentPos = $BoardObj | Where-Object {$_.color -eq $Color}
  $CurrentPos
}

function Get-NextMove {
  Param (
    $Color
  )
  do {
    $RaWMove = Read-Host -Prompt "Please enter your next move"
    $Letter = ($RaWMove -replace '[^abcdefgh]','').Tolower()
    $Number = $RaWMove -replace '[^01234567]',''
    $Row = [byte][char]$Letter[0] - 97
    $Col = [int]$Number[0] - 48 
  } until ($row -in 0..7 -and $Col -in 0..7)
  $Pos = $Row * 8 + $Col
  $objProp = [ordered]@{
    Row = $Row
    Col = $Col
    Pos  = $Pos
    Color = $Color
  }
  $Move = New-Object -TypeName psobject -Property $objProp
  return $Move
}


##########################################
##   MAIN CODE

# Init Board
$MainBoard = @()
0..63 | ForEach-Object {
  if ($_ -in  @(27,36))     {$MainBoard += "W"}
  elseif ($_ -in  @(28,35)) {$MainBoard += "R"}
  else {$MainBoard += "-"}
}
$MainBoardObj = Convert-ArrayToObject -fnBoard $MainBoard


Draw-Board -BoardObj $MainBoardObj.psobject.Copy()