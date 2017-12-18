<#
.Synopsis
   This Script simulates the CONNECT FOUR board game
.DESCRIPTION
   Long description
.EXAMPLE
   Example of how to use this cmdlet
.EXAMPLE
   Another example of how to use this cmdlet
.INPUTS
   Inputs to this cmdlet (if any)
.OUTPUTS
   Output from this cmdlet (if any)
.NOTES
   General notes
.COMPONENT
   The component this cmdlet belongs to
.ROLE
   The role this cmdlet belongs to
.FUNCTIONALITY
   The functionality that best describes this cmdlet
#>
[CmdletBinding()]
Param()

function convert-ArrayToObj {
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

function Get-Row {

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

function Get-FDiag {

}

function Get-RDiag {

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
  $GameFrame = Select-Col -fnFrame $GameFrame.psobject.Copy() -fnColor "Y"
  Draw-Frame -fnFrame $GameFrame.psobject.Copy()
} while ($true)
