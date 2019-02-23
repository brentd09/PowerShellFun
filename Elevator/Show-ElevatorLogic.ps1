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
  [string]$PeopleFrequency = "light"
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
    $this.CurrentDirection = "STATIC" # UP DOWN STATIC
    $this.LiftButtonsLit = @()
    $this.RespondingToFloor = 9999
    $this.CurrentLoad = 0
  }
}

Class LiftPatron {
  [int]$PersonId
  [int]$InitialFloor
  [string]$DestinationDirection
  [int]$DestinationFLoor
  [bool]$TroubleMaker
  [bool]$Status

  LiftPatron ($PersonNum,$InitFloor,$DestinationDir,$DestinationFlr) {
    $this.PersonId = $PersonNum
    $this.InitialFloor = $InitFloor
    $this.DestinationDirection = $DestinationDir
    $this.DestinationFloor = $DestinationFlr
    $this.TroubleMaker = ((Get-Random -Maximum 51 -Minimum 1) -eq 42)
    $this.Status = "STATIC" # UP DOWN STATIC
  }
}

function Request-Lift {
  Param (
    $NewFloor,
    $Direction,
    [lift[]]$AllLifts
  )
  $NoLiftsBelow = $false
  $NoLiftsAbove = $false
  If ($Direction -eq "UP") {
    $LiftsBelow = $AllLifts | Where-Object {$_.CurrentFloor -le $NewFloor -and ($_.CurrentDirection -eq "UP" -or 
                                                                                $_.CurrentDirection -eq "STATIC")}
    if ($LiftsBelow.Count -ge 1) {                                                                             
      $ClosestLift = $LiftsBelow | Sort-Object -Property CurrentFloor | Select-Object -First 1
      $ClosestLift
    } 
    else {$NoLiftsBelow = $true}
  }
  If ($Direction -eq "DOWN") {
    $LiftsAbove = $AllLifts | Where-Object {$_.CurrentFloor -ge $NewFloor -and ($_.CurrentDirection -eq "DOWN" -or 
                                                                                $_.CurrentDirection -eq "STATIC")}
    if ($Lift.Count -ge 1) {
      $ClosestLift = $LiftsAbove | Sort-Object -Property CurrentFloor | Select-Object -First 1
      $ClosestLift
    }
    else {$NoLiftsAbove = $true}
  }
  if ($NoLiftsBelow -eq $true -or $NoLiftsAbove -eq $true) {
    $StaticLifts = $Lifts | Where-Object {$_.Status -eq "STATIC"}
    $LiftsDistanceAway = $StaticLifts | Select-Object -Property *,@{n=Distance;e={[math]::Abs($_.CurrentFloor - $NewFloor)}}
    $ClosestLift = $LiftsDistanceAway | Sort-Object -Property Distance | Select-Object -First 1
  }
}

function Set-LiftResponding {
  Param (
    $RespondingLift,
    $NewFlr
  )
}
function New-Lift {
  Param (
    $LiftID,
    $LiftLoad
  )
  [lift]::New($LiftID,$LiftLoad)
}
# # # # MAIN CODE # # # #

$Lifts = foreach ($Index in (1..$NumberOfLifts)) {New-Lift -LiftID $Index -LiftLoad 16}

$Seconds = 1..3600
foreach ($Second in $Seconds) {
  $RandomInitFloor = Get-Random -Minimum 0 -Maximum $Floors
  do {
    $RandomDestFloor = Get-Random -Minimum 0 -Maximum $Floors
  } while ($RandomInitFloor -eq $RandomDestFloor )
  if ($RandomInitFloor -gt $RandomDestFloor) {$DirectionOfRandom = 'DOWN'}
  if ($RandomInitFloor -lt $RandomDestFloor) {$DirectionOfRandom = 'UP'}
  $Patron = [LiftPatron]::New($Second,$RandomInitFloor,$DirectionOfRandom,$RandomDestFloor)
  $LiftResponding = Request-Lift -NewFloor $Patron.InitialFloor -Direction $Patron.DestinationDirection -AllLifts $Lifts
  $LiftResponding
}