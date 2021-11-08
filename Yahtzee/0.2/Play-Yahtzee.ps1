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
Param (
  [int]$NumberOfPlayers = 2
)

function Get-DiceRoll {
  Param (
    [int[]]$WhichDiceReroll,
    [int[]]$Dice
  )
  if ($WhichDiceReroll.Count -eq 0) {
    $Dice = 0..4 | ForEach-Object {1..6 | Get-Random}
  }
  else {
    foreach ($Index in $WhichDiceReroll) {$Dice[$Index] = 1..6 | Get-Random}
  }
  return $Dice
}

function Show-ScoreCard {
  Param 
}

# Main code
$InitRoll = Get-DiceRoll 
$NextRoll = Get-DiceRoll -Dice $InitRoll -WhichDiceReroll 0,4,2
$InitRoll -join ','
$NextRoll -join ','