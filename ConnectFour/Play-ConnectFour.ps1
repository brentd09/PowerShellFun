<#
.Synopsis
   This Script simulates the CONNECT FOUR board game
.DESCRIPTION
   This Script simulates the CONNECT FOUR board game
.NOTES
   General notes
   Created by Brent Denny
           on 16 Dec 2017   
#>
[CmdletBinding()]
Param()

function Convert-ArrayToObj {
  Param (
    $FnArray,
    $StringMatch
  )
  for ($count = 0; $count -lt $FnArray.count;$count++){
    $props = [ordered]@{
      Position = $count 
      Content = $FnArray[$count]
    }
    if ($FnArray[$count] -eq $StringMatch) {new-object -TypeName psobject -Property $props}
  }
}  

function Get-EmptyPosInCol {
  Param(
    $fnFrame,
    $fnColNum
  )

  $Contents = ''
  $EmptyPos = 99 # This is an internal code that signals the col is full if 99 returned
  $realCol = $fnColNum - 1
  foreach ($val in (0,7,14,21,28,35)) {
    $Contents = $fnFrame[$realCol+$val]
    if ($Contents -eq '-') {$EmptyPos = $realCol+$val}
    else {break}
  }
  
  return $EmptyPos
}

function Get-Row {
  param(
    $fnFrame,
    $WhichRow
  )
  $Row = @()
  $Start = $WhichRow * 7
  $End = $Start + 6
  $Row = $fnFrame[$Start..$End]
  return $Row
}

function Get-Col {
  param(
    $fnFrame,
    $WhichCol
  )
  $Col = @()
  
  $S = $WhichCol 
  $Inc = 7
  $Col = $fnFrame[$S,$S+($Inc*1),$S+($Inc*2),$S+($Inc*3),$S+($Inc*4),$S+($Inc*5)]
  return $Col
}

function Get-FDiag {
  param(
    $fnFrame,
    $WhichDiag
  )
  $Diag = @()
  $StartPos = @(3,4,5,6,13,20)
  $CurrPos = $StartPos[$WhichDiag]
  $Number =@(4,5,6,6,5,4)
  1..$Number[$WhichDiag] | foreach {
    $Diag += $fnFrame[$CurrPos]
    $CurrPos = $CurrPos + 6
  }
  Return $Diag
}

function Get-RDiag {
  param(
    $fnFrame,
    $WhichDiag
  )
  $Diag = @()
  $StartPos = @(14,7,0,1,2,3)
  $CurrPos = $StartPos[$WhichDiag]
  $Number =@(4,5,6,6,5,4)
  1..$Number[$WhichDiag] | foreach {
    $Diag += $fnFrame[$CurrPos]
    $CurrPos = $CurrPos + 8
  }
  Return $Diag
}

function Draw-Frame {
  Param ( 
    $fnFrame 
  )
  $spc = '  '
  Clear-Host

  Write-Host -ForegroundColor Magenta "$spc-- Connect Four --`n"
  Write-Host -ForegroundColor Magenta "$spc  1 2 3 4 5 6 7"
  foreach ( $fnRow in (0,7,14,21,28,35)){
    Write-Host -NoNewline $spc"  "
    $EndOfRow = $fnRow + 6
    foreach ($fnFramePos in ($fnRow..$EndOfRow)) {
      if ($fnFrame[$fnFramePos] -eq "R") {$FGcolor = 'Red'}
      elseif ($fnFrame[$fnFramePos] -eq "Y") {$FGcolor = 'Yellow'}
      else {$FGcolor = 'darkgray'}
      Write-Host -NoNewline -ForegroundColor $FGcolor $fnFrame[$fnFramePos]; Write-Host -NoNewline " "
    }
    write-host
  }
  Write-Host
}

function Select-Col {
  param (
    $fnFrame,
    $fnColor
  )
  [string]$kbdRead = ''
  If ($fnColor -like "Y*") {$Col = "Yellow";$ColLetter = "Y"}
  else {$Col = "Red";$ColLetter = "R"}
  do { 
    Write-Host -NoNewline -ForegroundColor $Col  "$Col Turn`nType column number "
    $kbdRead = Read-Host 
    if ( $kbdRead -match "[1234567]") {
      $kbdReadInt = $kbdRead -as [int]
      $TurnPos = Get-EmptyPosInCol -fnFrame $fnFrame.psobject.Copy() -fnColNum $kbdRead
    }
  } until ($TurnPos -ne 99 -and $kbdReadint -in @(1..7)) 
  $fnFrame[$TurnPos] = $ColLetter 
  return $fnFrame
}

function Check-Winner {
  param (
    $fnFrame,
    $fnColor
  )
  $winner = $false
  foreach ($num in (0..5)) {
    $CheckCol = Get-Col -fnFrame $fnFrame -WhichCol $num
    $checkRow = Get-Row -fnFrame $fnFrame -WhichRow $num
    $checkFDiag = Get-FDiag -fnFrame $fnFrame -WhichDiag $num
    $checkRDiag = Get-RDiag -fnFrame $fnFrame -WhichDiag $num
    # check for winner
  } 
  $CheckCol = Get-Col -fnFrame $fnFrame -WhichCol 6
  #check for winner
}

##########################################################
## MAIN CODE

#Init frame
$GameFrame = @()
for ($count = 0;$count -le 41;$count++) {
  $GameFrame += "-"
}
Draw-Frame -fnFrame $GameFrame.psobject.Copy()
do {
  $GameFrame = Select-Col -fnFrame $GameFrame.psobject.Copy() -fnColor "R"
  Draw-Frame -fnFrame $GameFrame.psobject.Copy()
  $Winner = Check-Winner -fnFrame $GameFrame.psobject.Copy() -fnColor "R"
  $GameFrame = Select-Col -fnFrame $GameFrame.psobject.Copy() -fnColor "Y"
  Draw-Frame -fnFrame $GameFrame.psobject.Copy()
  $Winner = Check-Winner -fnFrame $GameFrame.psobject.Copy() -fnColor "Y"
} while ($true)
