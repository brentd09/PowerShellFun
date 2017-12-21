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
    $BoardObj
  )  
  $numOfWhite = ($BoardObj | where {$_.color -eq "W"}).count
  $numOfBlack = ($BoardObj | where {$_.color -eq "B"}).count

  Write-Host -ForegroundColor Yellow  "  --  REVERSE  --"
  Write-Host -ForegroundColor Yellow "  1 2 3 4 5 6 7 8"
  foreach ($start in (0,8,16,24,32,40,48,56)) {
    $num = ($start / 8) + 65
    $letter = [char]$num
    Write-Host -ForegroundColor Yellow -NoNewline $letter
    Write-Host -NoNewline " "
    Write-Host $BoardObj[$start..($Start+7)].color
  }
  Write-Host
  Write-Host "Black: $numOfBlack"
  Write-Host "White: $numOfWhite"
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


##########################################
##   MAIN CODE

# Init Board
$MainBoard = @()
0..63 | ForEach-Object {
  if ($_ -in  @(27,36))     {$MainBoard += "W"}
  elseif ($_ -in  @(28,35)) {$MainBoard += "B"}
  else {$MainBoard += "-"}
}
$MainBoardObj = Convert-ArrayToObject -fnBoard $MainBoard


Draw-Board -BoardObj $MainBoardObj.psobject.Copy()