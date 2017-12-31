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

function Get-SurrColor {
  Param (
    $BoardObj,
    $Move
  )
  # these are the positions to check when the position is either in the 
  # or middle or left edge etc or corner top right etc.
  $mid = @(-9,-8,-7,1,9,8,7,-1)
  $le = @(-8,-7,1,9,8)
  $te = @(-9,-8,-7,1,9)
  $re = @(8,7,-1,-9,-8)
  $be = @(-1,-9,-8,-7,1)
  $ctl = @(1,9,8)
  $ctr = @(8,7,-1)
  $cbl = @(-8,-7,1)
  $cbr = @(-1,-9,-8)

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
      Col = $col
      Row = $row
      FwDiag = $row + $col
      RvDiag = 7 + $col - $row
    }
    new-object -TypeName psobject -Property $objProp
    $count++
  }
}   

function Check-MoveIsLegal {
  Param (
    $BoardObj,
    $Move
  )
  if ($Move.color -eq 'W') {$OpColor = 'R'}
  elseif ($Move.color -eq 'R') {$OpColor = 'W'}
  else {$OpColor = '-'}
  $MoveLegal = $true
  if ($Move.Color -ne '-') {$MoveLegal = $false; return $MoveLegal}
  if ($OpColor ) {}

}

function Get-NextMove {
  Param (
    $Color
  )
  do {
    if ($Color -eq "R") {$PromptColor = "Red"}
    if ($Color -eq "W") {$PromptColor = "White"}
    Write-Host -NoNewline -ForegroundColor $PromptColor "`n$PromptColor, Please enter your next move: "
    $RaWMove = Read-Host
    $Letter = ($RaWMove -replace '[^abcdefgh]','').Tolower()
    $Number = $RaWMove -replace '[^12345678]',''
    $Row = [byte][char]$Letter[0] - 97
    $Col = [int]$Number[0] - 49
  } until ($row -in 0..7 -and $Col -in 0..7)
  $Pos = $Row * 8 + $Col
  $objProp = [ordered]@{
    Row = $Row
    Col = $Col
    Index  = $Pos
    Color = $Color
  }
  $Move = New-Object -TypeName psobject -Property $objProp
  return $Move
}

function Complete-Move {
  Param (
    $BoardObj,
    $MoveObj
  )
  $MoveValid = $false
  $Moveindex = $MoveObj.Index
  # Adding the movecolor to the object so that it now has the current value on board as .col and
  # the color of the move as .movecol
  $MoveLoc = $BoardObj[$Moveindex] | Select-Object -Property *,@{n='MoveCol';e={$MoveObj.Color}}
  if ($MoveLoc.Color -ne '-') {$MoveValid = $false; return $MoveLoc}

  If ($MoveLoc.MoveCol -eq "R") {$OppMoveCol = "W"}
  If ($MoveLoc.MoveCol -eq "W") {$OppMoveCol = "R"}

  $RowObj = $BoardObj | Where-Object {$_.row -eq $MoveLoc.Row}
  $ColObj = $BoardObj | Where-Object {$_.col -eq $MoveLoc.Col}
  $FwDiagObj = $BoardObj | Where-Object {$_.fwdiag -eq $MoveLoc.FwDiag}
  $RvDiagObj = $BoardObj | Where-Object {$_.rvdiag -eq $MoveLoc.RvDiag}

  $PosInRow = $RowObj.index.IndexOf($MoveLoc.index)
  $RowCount = $RowObj.count - 1
  $PosInCol = $ColObj.index.IndexOf($MoveLoc.index)
  $ColCount = $ColObj.count - 1
  $PosInFwDiag = $FwDiagObj.index.IndexOf($MoveLoc.index)
  $FwDiagCount = $FwDiagObj.count - 1
  $PosInRvDiag = $RvDiagObj.index.IndexOf($MoveLoc.index)
  $RvDiagCount = $RvDiagObj.count - 1
  $MasterChangeList = @()

  #check Row --> larger index
  if ($PosInRow -le ($RowCount - 2)) {
    $ChangeList = @()
    $OppInLine = $false
    $StartPos = $PosInRow + 1 
    $EndPos   = $RowCount 
    foreach ($Pos in ($StartPos..$EndPos)) {
      if ($RowObj[$Pos].Color -eq '-') {
        $OppInLine = $false
        break
      }
      if ($RowObj[$Pos].Color -eq $OppMoveCol) {
        $ChangeList += $RowObj[$Pos].index
        $OppInLine = $true
      }
      if ($RowObj[$Pos].Color -eq $MoveLoc.MoveCol -and $OppInLine -eq $true) {
        $MasterChangeList += $ChangeList
        $MoveValid = $true
        break
      }
    }
  }

  #check row <-- smaller index
  if ($PosInRow -ge 2) {
    # Complete the move if valid
    $ChangeList = @()
    $OppInLine = $false
    $StartPos = $PosInRow - 1 
    $EndPos   = 0
    foreach ($Pos in ($StartPos..$EndPos)) {
      if ($RowObj[$Pos].Color -eq '-') {
        $OppInLine = $false
        break
      }
      if ($RowObj[$Pos].Color -eq $OppMoveCol) {
        $ChangeList += $RowObj[$Pos].index
        $OppInLine = $true
      }
      if ($RowObj[$Pos].Color -eq $MoveLoc.MoveCol -and $OppInLine -eq $true) {
        $MasterChangeList += $ChangeList
        $MoveValid = $true
        break
      }
    }
  }

  #check col --> larger index
  if ($PosInCol -le ($ColCount - 2)) {
    $ChangeList = @()
    $OppInLine = $false
    $StartPos = $PosInCol + 1 
    $EndPos   = $ColCount 
    foreach ($Pos in ($StartPos..$EndPos)) {
      if ($ColObj[$Pos].Color -eq '-') {
        $OppInLine = $false
        break
      }
      if ($ColObj[$Pos].Color -eq $OppMoveCol) {
        $ChangeList += $ColObj[$Pos].index
        $OppInLine = $true
      }
      if ($ColObj[$Pos].Color -eq $MoveLoc.MoveCol -and $OppInLine -eq $true) {
        $MasterChangeList += $ChangeList
        $MoveValid = $true
        break
      }
    }
  }

  #check col <-- smaller index
  if ($PosInCol -ge 2) {
    $ChangeList = @()
    $OppInLine = $false
    $StartPos = $PosInCol - 1 
    $EndPos   = 0
    foreach ($Pos in ($StartPos..$EndPos)) {
      if ($ColObj[$Pos].Color -eq '-') {
        $OppInLine = $false
        break
      }
      if ($ColObj[$Pos].Color -eq $OppMoveCol) {
        $ChangeList += $ColObj[$Pos].index
        $OppInLine = $true
      }
      if ($ColObj[$Pos].Color -eq $MoveLoc.MoveCol -and $OppInLine -eq $true) {
        $MasterChangeList += $ChangeList
        $MoveValid = $true
        break
      }
    }

  }

  #Check Fw Diag / --> larger index
  if ($PosInFwDiag -le ($FwDiagCount - 2)) {
    $ChangeList = @()
    $OppInLine = $false
    $StartPos = $PosInFwDiag + 1 
    $EndPos   = $FwDiagCount 
    foreach ($Pos in ($StartPos..$EndPos)) {
      if ($FwDiagObj[$Pos].Color -eq '-') {
        $OppInLine = $false
        break
      }
      if ($FwDiagObj[$Pos].Color -eq $OppMoveCol) {
        $ChangeList += $FwDiagObj[$Pos].index
        $OppInLine = $true
      }
      if ($FwDiagObj[$Pos].Color -eq $MoveLoc.MoveCol -and $OppInLine -eq $true) {
        $MasterChangeList += $ChangeList
        $MoveValid = $true
        break
      }
    }
  }

  #Check Fw Diag / --> smaller index
  if ($PosInFwDiag -ge 2) {
    $ChangeList = @()
    $OppInLine = $false
    $StartPos = $PosInFwDiag - 1 
    $EndPos   = 0 
    foreach ($Pos in ($StartPos..$EndPos)) {
      if ($FwDiagObj[$Pos].Color -eq '-') {
        $OppInLine = $false
        break
      }
      if ($FwDiagObj[$Pos].Color -eq $OppMoveCol) {
        $ChangeList += $FwDiagObj[$Pos].index
        $OppInLine = $true
      }
      if ($FwDiagObj[$Pos].Color -eq $MoveLoc.MoveCol -and $OppInLine -eq $true) {
        $MasterChangeList += $ChangeList
        $MoveValid = $true
        break
      }
    }
  }

  #Check Rv Diag \ --> larger index
  if ($PosInRvDiag -le ($RvDiagCount - 2)) {
    $ChangeList = @()
    $OppInLine = $false
    $StartPos = $PosInRvDiag + 1 
    $EndPos   = $RvDiagCount 
    foreach ($Pos in ($StartPos..$EndPos)) {
      if ($RvDiagObj[$Pos].Color -eq '-') {
        $OppInLine = $false
        break
      }
      if ($RvDiagObj[$Pos].Color -eq $OppMoveCol) {
        $ChangeList += $RvDiagObj[$Pos].index
        $OppInLine = $true
      }
      if ($RvDiagObj[$Pos].Color -eq $MoveLoc.MoveCol -and $OppInLine -eq $true) {
        $MasterChangeList += $ChangeList
        $MoveValid = $true
        break
      }
    }
  }

  #Check Rv Diag \ --> smaller index
  if ($PosInRvDiag -ge 2) {
    $ChangeList = @()
    $OppInLine = $false
    $StartPos = $PosInRvDiag - 1 
    $EndPos   = 0
    foreach ($Pos in ($StartPos..$EndPos)) {
      if ($RvDiagObj[$Pos].Color -eq '-') {
        $OppInLine = $false
        break
      }
      if ($RvDiagObj[$Pos].Color -eq $OppMoveCol) {
        $ChangeList += $RvDiagObj[$Pos].index
        $OppInLine = $true
      }
      if ($RvDiagObj[$Pos].Color -eq $MoveLoc.MoveCol -and $OppInLine -eq $true) {
        $MasterChangeList += $ChangeList
        $MoveValid = $true
        break
      }
    }
  }
  if ($MoveValid -eq $true) {
    $MasterChangeList += $Moveindex
  }
  $objProp = @{
    MasterChangeList = $MasterChangeList
    MoveValid = $MoveValid
    MoveColor = $MoveLoc.MoveCol
  }
  $RetObj = New-Object -TypeName psobject -Property $objProp
  return $RetObj
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
$Turn = "-"
Do {
  #red turn
  if ($Turn -eq '-' ) {$Turn = 'R'}
  elseif ($Turn -eq 'R' ) {$Turn = 'W'}
  elseif ($Turn -eq 'W' ) {$Turn = 'R'}
  do {
    $NextMove = Get-NextMove -Color $Turn
    $MoveInfo = Complete-Move -BoardObj $MainBoardObj -MoveObj $NextMove
  } until ($MoveInfo.MoveValid -eq $true)
  foreach ($Pos in $MoveInfo.MasterChangeList) {
    $MainBoardObj[$Pos].Color = $MoveInfo.MoveColor
  }
  Draw-Board -BoardObj $MainBoardObj.psobject.Copy()
} while ($true)