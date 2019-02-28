<#
.SYNOPSIS
  Short description
.DESCRIPTION
  Long description
.EXAMPLE
  PS C:\> <example usage>
  Explanation of what the example does
.INPUTS
  Inputs (if any)
.OUTPUTS
  Output (if any)
.NOTES
  General notes
#>
[CmdletBinding()]
Param()
function Flip-CoinOrNot {
  $initCoin = 'T'
  $currentFace = $initCoin
  $firstComputerFlip = @($true,$false) | Get-Random
  $secondPersonFlip  = @($true,$false) | Get-Random
  $thirdComputerFlip  = @($true,$false) | Get-Random
  if ($firstComputerFlip) {
    if ($currentFace -eq 'H') {$currentFace = 'T'}
    else {$currentFace = 'H'}
  }
  if ($secondPersonFlip) {
    if ($currentFace -eq 'H') {$currentFace = 'T'}
    else {$currentFace = 'H'}
  }
  if ($thirdComputerFlip) {
    if ($currentFace -eq 'H') {$currentFace = 'T'}
    else {$currentFace = 'H'}
  }
  $ObjProps = [ordered]@{
    FirstFlip  = $firstComputerFlip
    SecondFlip = $secondPersonFlip
    ThirdFlip  = $thirdComputerFlip
    CoinFace   = $currentFace
  }
  New-Object -TypeName psobject -Property $ObjProps
}
$allHeads = 0
$allTails = 0
1..20 |  ForEach-Object {
  $numberOfHeads = 0
  $numberOfTails = 0
  1..1000 |ForEach-Object {
    $coinFlipResult = Flip-CoinOrNot
    $numberOfHeads = $numberOfHeads + (($coinFlipResult | Where-Object {$_.CoinFace -eq 'H'} | Measure-Object).count)
    $numberOfTails = $numberOfTails + (($coinFlipResult | Where-Object {$_.CoinFace -eq 'T'} | Measure-Object).count)
  }
  Write-Host "Heads: $numberOfHeads   Tails: $numberOfTails" 
  $allHeads = $allHeads + $numberOfHeads; $allTails = $allTails + $numberOfTails
}
'HeadsTotal '+ $allHeads;'TailsTotal '+$allTails