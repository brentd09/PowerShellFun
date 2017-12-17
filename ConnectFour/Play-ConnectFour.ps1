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

function Get-Row {

}

function Get-EmptyPosInCol {
  Param(
    $fnFrame,
    $fnColNum
  )

  $Contents = ''
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
      if ($fnFrame[$fnFramePos] = "R") {$FGcolor = 'Red'}
      if ($fnFrame[$fnFramePos] = "Y") {$FGcolor = 'Yellow'}
      if ($fnFrame[$fnFramePos] = "-") {$FGcolor = 'White'}
      Write-Host -NoNewline -ForegroundColor $FGcolor $fnFrame[$fnFramePos]; Write-Host -NoNewline " "
    }
    write-host
  }
  Write-Host
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
  Write-Host -NoNewline -ForegroundColor Red  "Red Turn`nType column number "
  [int]$kbdRead = Read-Host 
  $TurnPos = Get-EmptyPosInCol -fnFrame $GameFrame.psobject.Copy() -fnColNum $kbdRead
  $GameFrame[$TurnPos] = "R" 

  Draw-Frame -fnFrame $GameFrame.psobject.Copy()

  Write-Host -NoNewline -ForegroundColor Yellow "Yellow Turn`nType column number "
  [int]$kbdRead = Read-Host 
  $TurnPos = Get-EmptyPosInCol -fnFrame $GameFrame.psobject.Copy() -fnColNum $kbdRead
  $GameFrame[$TurnPos] = "Y" 

  Draw-Frame -fnFrame $GameFrame.psobject.Copy()
} while ($true)