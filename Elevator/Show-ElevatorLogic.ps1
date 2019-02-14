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
  [Parameter(Mandatory=$true)]
  [int]$Floors,
  [Parameter(Mandatory=$true)]
  [int]$NumberOfLifts,
  [ValidateSet("Light","Medium","Heavy")]
  [string]$PeopleFrequency = "Medium"
)
Class Lift {
  [int]$LiftNumber
  [string]$CurrentDirection
  [int]$CurrentLoad 
  [int]$MaxLoad
  [int]$CurrentFloor 
  [int[]]$LiftButtonsLit
  [int]$RespondingToFloor

  Lift ($LiftIndex,$MaxLoad) {
    $this.LiftNumber = $LiftIndex
    $this.MaxLoad = $MaxLoad
    $this.CurrentFloor = 0
    $this.CurrentDirection = "UP"
    $this.LiftButtonsLit = [int]@()
    $this.RespondingToFloor = 9999
    $this.CurrentLoad = 0
  }
}

Class LiftPatron {
  [int]$PersonId
  [int]$InitialFloor
  [int]$DestinationDirection
  [int]$DestinationFLoor
  [bool]$TroubleMaker

  LiftPatron ($PersonNum,$InitFloor,$DestinationDir) {
    $this.PersonId = $PersonNum
    $this.InitialFloor = $InitFloor
    $this.DestinationDirection = $DestinationDir
    $this.DestinationFLoor = if ($DestinationDir = "UP") {Get-Random -Maximum ($Script:Floors + 1) -Minimum ($InitFloor + 1)}
    $this.TroubleMaker = ((Get-Random -Maximum 51 -Minimum 1) -eq 42)
  }
}

[LiftPatron]::New(1,0,"up")