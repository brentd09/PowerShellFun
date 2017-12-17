<#
.Synopsis
   Short description
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

function Get-Col {
  Param(
    $fnFrame,
    $fnColNum
  )
  $colVals = @()
  $realCol = $fnColNum - 1
  foreach ($val in (0,7,14,21,28,35)) {
    $colVals += $fnFrame[$realCol+$val]
  }
  return $colVals
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

  Write-Host -ForegroundColor Yellow "$spc-- Connect Four --`n"
  Write-Host -ForegroundColor Yellow "$spc  1 2 3 4 5 6 7"
  foreach ( $fnRow in (0,7,14,21,28,35)){
    Write-Host -NoNewline $spc"  "
    Write-Host $fnFrame[$fnRow..($fnRow+6)]
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
  "Red Turn"
  [int]$kbdRead = Read-Host -Prompt "Select column number"
  Get-Col -fnFrame $GameFrame.psobject.Copy() -fnColNum $kbdRead

} while ($true)