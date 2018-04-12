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


function InitialiseBoard {
  Param ()

  foreach ( $Pos in (0..63)) {}

}

function Draw-Board {
  Param (
    $BoardObj
  )  
  $numOfWhite = ($BoardObj | where {$_.color -eq "W"}).count
  $numOfRed = ($BoardObj | where {$_.color -eq "R"}).count
  $LeftSpc = '  '
  Clear-Host
  Write-Host  -ForegroundColor Cyan "`n$LeftSpc  --  REVERSE  --        --SCORE--"
  Write-Host -ForegroundColor White   "$LeftSpc                         White: $numOfWhite"
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


######   MainCode
$BackDiagList = @(
  @(56),
  @(48,57),
  @(40,49,58),
  @(32,41,50,59),
  @(24,33,42,51,60),
  @(16,25,34,43,52,61),
  @(8,17,26,35,44,53,62),
  @(0,9,18,27,36,45,54,63),
  @(1,10,19,28,37,46,55),
  @(2,11,20,29,38,47),
  @(3,12,21,30,39),
  @(4,13,22,31),
  @(5,14,23),
  @(6,15),
  @(7)
)
$FwdDiagList = @(
  @(0),
  @(8,1),
  @(16,9,2),
  @(24,17,10,3),
  @(32,25,18,11,4),
  @(40,33,26,19,12,5),
  @(48,41,34,27,20,13,6),
  @(56,49,42,35,28,21,14,7),
  @(57,50,43,36,29,22,15),
  @(58,51,44,37,30,23),
  @(59,52,45,38,31),
  @(60,53,46,39),
  @(61,54,47),
  @(62,55),
  @(63)
)