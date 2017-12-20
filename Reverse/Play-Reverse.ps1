<#
.SYNOPSIS
   
.DESCRIPTION
   
.EXAMPLE
   
.EXAMPLE
   
.INPUTS
   
.OUTPUTS
   
.NOTES
  00 01 02 03 04 05 06 07  starts with 27 = W 28 = B 
  08 09 10 11 12 13 14 15              35 = B 36 = W
  16 17 18 19 20 21 22 23  All others = -
  24 25 26 27 28 29 30 31 
  32 33 34 35 36 37 38 39
  40 41 42 43 44 45 46 47
  48 49 50 51 52 53 54 55
  56 57 58 59 60 61 62 63  
         
.FUNCTIONALITY
   
#>
function Draw-Board {
  Param (
    $fnBoard
  )  
  Write-Host -ForegroundColor Yellow  "  --  REVERSE  --"
  Write-Host -ForegroundColor Yellow "  1 2 3 4 5 6 7 8"
  foreach ($start in (0,8,16,24,32,40,48,56)) {
    $num = ($start / 8) + 65
    $letter = [char]$num
    Write-Host -ForegroundColor Yellow -NoNewline $letter
    Write-Host -NoNewline " "
    Write-Host $fnBoard[$start..($Start+7)]
  }
}

function Get-Row {
  Param (
    $fnBoard,
    $fnRowNum
  )
  $Row = @()
  $start = $fnRowNum * 8
  $end = $start + 7
  $Row = $fnBoard[$start..$end]
  return $Row
}

function Get-Col {
  Param (
    $fnBoard,
    $fnColNum
  )
  $Col = @()
  $cn = $fnColNum
  $Col = $fnBoard[(0+$cn),(8+$cn),(16+$cn),(24+$cn),(32+$cn),(40+$cn),(48+$cn),(56+$cn)]
  return $Col
}

function Get-FDiag {
  Param (
    $fnBoard,
    [int]$fnFDNum
  )
  $FDiag = @()
  $Length = @(3,4,5,6,7,8,7,6,5,4,3)
  $start = @(2,3,4,5,6,7,15,23,31,39,47)
  $jump = 7
  $count = 0
  1..($Length[$fnFDNum]) |  ForEach-Object {
    $pos = $start[$fnFDNum] + $count
    $FDiag += $fnBoard[$pos]
    $count = $count + $jump
  }
  return $FDiag
}

function Get-RDiag {
  Param (
    $fnBoard,
    $fnRDNum
  )
  $RDiag = @()
  $Length = @(3,4,5,6,7,8,7,6,5,4,3)
  $start = @(40,32,24,16,8,0,1,2,3,4,5)
  $jump = 9
  $count = 0
  1..($Length[$fnRDNum]) |  ForEach-Object {
    $pos = $start[$fnRDNum] + $count
    $RDiag += $fnBoard[$pos]
    $count = $count + $jump
  }
  return $RDiag

}

function Choose-Location {

}

function Find-PossibleMoves {

}



##########################################
##   MAIN CODE

# Init Board
$MainBoard = @()
0..63 | ForEach-Object {
  if ($_ -in  @(27,36))     {$MainBoard += "W"}
  elseif ($_ -in  @(28,35)) {$MainBoard += "B"}
  else {$MainBoard += "-"}
}

Draw-Board -fnBoard $MainBoard.psobject.Copy()