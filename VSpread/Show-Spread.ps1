<#
.SYNOPSIS
  Tries to simulate the spread of a disease
.DESCRIPTION
  This will attempt to show the spread of a disease with a 14 cycle life span (14 day)
  This will show that disease hosts that get too close to each will transmit the disease 
  and if the hosts stay away from each other the disease will die out. Some hosts may die 
  if they have comprimised health.
.PARAMETER InfectedPercent
  This declares how much of the population is infected
.PARAMETER PopulationPercent
  This tells the simulation how many hosts are walking around
.PARAMETER InfectionCycle
  This is how long does the infection last
.PARAMETER BadHealthPrecent  
  This is the percent of the population that are in poor health, if these get the infection
  they will die after 5 cycles
.EXAMPLE
  Show-Spread 
  this will show a grid of infected and un-infected hosts and how the disease interacts
.EXAMPLE
  Show-Spread -InfectedPercent 3 -PopulationPercent 30 -InfectionCycle 14 -BadHealthPrecent 4 
  This will show a grid of infected and un-infected hosts and how the disease interacts . 
  The simulation will have 30% probability of hosts with about 3% infected which will take 14 
  cycles to recover unless you are the 4% that have bad health because these will die.
.NOTES
  General notes
  Created By: Brent Denny
  Created On: 22 Apr 2020
  Modified:   24 Apr 2020 
#>
[CmdletBinding()]
Param(
  [int]$InfectedPercent = 2,
  [int]$PopulationPercent = 60,
  [int]$InfectionCycle = 14,
  [int]$BadHealthPrecent = 3
)
# Classes
class WorldCell {
  [int]$Index
  [int]$Row
  [int]$Col
  [string]$Value
  [bool]$BeenInfected
  [int]$InfectionCycles
  [bool]$ComprimisedHealth
  [int]$EndOfHostCycles

  WorldCell ([int]$Position,[int]$InfectPercent,[int]$PopPercent,[int]$InfectCycle,[int]$BadHealthPrecent) {
    $this.Index = $Position
    $this.Col = $Position % 40
    $this.Row = [math]::Truncate($Position / 40)
    $RandomNum = 1..100 | Get-Random
    $HealthNum = 1..100 | Get-Random
    if ($RandomNum -le $InfectPercent) {
      $this.Value = 'I'
      $this.BeenInfected = $true
      $this.InfectionCycles = $InfectCycle
      if ($HealthNum -le $BadHealthPrecent) {$this.ComprimisedHealth = $true}
      else {$this.ComprimisedHealth = $false}
    }
    elseif ($RandomNum -le $PopPercent) {
      $this.Value = 'U'
      $this.BeenInfected = $false
      $this.InfectionCycles = 0
      if ($HealthNum -le $BadHealthPrecent) {$this.ComprimisedHealth = $true}
      else {$this.ComprimisedHealth = $false}
    }
    else {$this.Value = '.'}
    if ($this.ComprimisedHealth -eq $true) {$this.EndOfHostCycles = 5}
  }
}

class WorldBoard {
  [WorldCell[]]$WorldCells

  WorldBoard ([WorldCell[]]$Cells) {
    $this.WorldCells = $Cells
  }

  [void]Swap ($PosFrom,$PosTo) {
    $FromValue = $this.WorldCells[$PosFrom].Value
    $FromBeenInfected = $this.WorldCells[$PosFrom].BeenInfected
    $FromInfectionCycles = $this.WorldCells[$PosFrom].InfectionCycles

    $ToValue = $this.WorldCells[$PosTo].Value
    $ToBeenInfected = $this.WorldCells[$PosTo].BeenInfected
    $ToInfectionCycles = $this.WorldCells[$PosTo].InfectionCycles
    $this.WorldCells[$PosTo].Value
    $this.WorldCells[$PosTo].Value = $FromValue
    $this.WorldCells[$PosTo].BeenInfected = $FromBeenInfected
    $this.WorldCells[$PosTo].InfectionCycles = $FromInfectionCycles
    $this.WorldCells[$PosFrom].Value = $ToValue
    $this.WorldCells[$PosFrom].BeenInfected = $ToBeenInfected
    $this.WorldCells[$PosFrom].InfectionCycles = $ToInfectionCycles
  }
}

function Show-World {
  param (
    [WorldCell[]]$World,
    [int]$Count
  )
  $coord = [System.Management.Automation.Host.Coordinates]::New(0,0)
  $host.UI.RawUI.CursorPosition = $coord
  foreach ($RowNum in (0..39)) {
    $WorldRow = $World | Where-Object {$_.Row -eq $RowNum}
    $WorldRow.Value -join " "
  } 
  $Infected = $World | Where-Object {$_.Value -eq 'I'}
  $Uninfected = $World | Where-Object {$_.Value -eq 'U' -and $_.BeenInfected -eq $false}
  $Recovered = $World | Where-Object {$_.Value -eq 'U' -and $_.BeenInfected -eq $true}
  $Dead = $World | Where-Object {$_.Value -eq 'D' -and $_.BeenInfected -eq $true}
  $CompHealth = $World | Where-Object {$_.ComprimisedHealth -eq $true}
  Write-Host -ForegroundColor Green "Never Infected $($Uninfected.Count)   " 
  Write-Host -ForegroundColor Cyan "Recovered $($Recovered.Count)   " 
  Write-Host -ForegroundColor Yellow "Infected $($Infected.Count)  "
  Write-Host -ForegroundColor Red "Dead $($Dead.Count) (from $($CompHealth.Count) in danger)"  
  Write-Host "Count $Count  "
}

function Test-DiseaseNeighbour {
  param ([WorldCell[]]$World,[int]$InfectCycle)
  $UnInfectedHosts =  $World | Where-Object {$_.Value -eq 'U'}
  [System.Collections.ArrayList]$Directions = @(-20,20,-1,1)
  foreach ($UnInfectedHost in $UnInfectedHosts) {
    if ($UnInfectedHost.Row -eq 0)  {$Directions.Remove(-20)}
    elseif ($UnInfectedHost.Row -eq 19) {$Directions.Remove(20)}
    if ($UnInfectedHost.Col -eq 0)  {$Directions.Remove(-1)}
    elseif ($UnInfectedHost.Col -eq 19) {$Directions.Remove(1)}
    foreach ($Direction in $Directions) {
      $CheckIndex = $UnInfectedHost.Index + $Direction
      if ($World[$CheckIndex].Value -eq 'I' -and $UnInfectedHost.BeenInfected -eq $false) {
        $UnInfectedHost.Value = 'I'
        $UnInfectedHost.BeenInfected = $true
        $UnInfectedHost.InfectionCycles = $InfectCycle
        break
      }
    }
  }
}
function Test-Infected {
  param ([WorldCell[]]$World)
  $InfectedHosts =  $World | Where-Object {$_.Value -eq 'I'}
  foreach ($InfectedHost in $InfectedHosts) {
    if ($InfectedHost.InfectionCycles -eq 0) {$InfectedHost.Value = 'U'}
    else {$InfectedHost.InfectionCycles = $InfectedHost.InfectionCycles - 1}
    if ($InfectedHost.ComprimisedHealth -eq $true) {
      if ($InfectedHost.EndOfHostCycles -eq 0 -and $InfectedHost.BeenInfected -eq $true) {$InfectedHost.Value = 'D'}
      else {$InfectedHost.EndOfHostCycles = $InfectedHost.EndOfHostCycles - 1}
    }
  }
}

function Move-CurrentHost {
  param ([WorldBoard]$World)
  $UpDown = @(-20,20)
  $LeftRight = @(-1,1)
  $CurrentHosts =  $World.WorldCells | Where-Object {$_.Value -in @('I','U')}
  foreach ($CurrentHost in $CurrentHosts) {
    $TryForNewIndex = 0
    do {
      $WhichDirection = @('UD','LR') | Get-Random
      if ($WhichDirection -eq 'UD') {
        if ($CurrentHost.Row -eq 0) {$Move = 20 }
        elseif ($CurrentHost.Row -eq 19) {$Move = -20}
        else {$Move = $UpDown | Get-Random}
      }
      else { #LeftRight move
        if ($CurrentHost.Col -eq 0) {$Move = 1 }
        elseif ($CurrentHost.Col -eq 19) {$Move = -1}
        else {$Move = $LeftRight | Get-Random}
      }
      $NewIndex = $CurrentHost.Index + $Move
      $TryForNewIndex++
    } until ($World.WorldCells[$NewIndex].Value -eq '.' -or $TryForNewIndex -eq 4)
    if ($TryForNewIndex -eq 4) {$NewIndex = $CurrentHost.Index}
    else {
      $World.Swap($CurrentHost.Index,$NewIndex)
    } 
  }
}

# MAIN CODE 

Clear-Host
$Spots = 0..1599 | ForEach-Object {[WorldCell]::New($_,$InfectedPercent,$PopulationPercent,$InfectionCycle,$BadHealthPrecent)}
$WorldBoard = [WorldBoard]::New($Spots) 
Show-World -World $WorldBoard.WorldCells
$DiseaseCycleCount = 0
do {
  $DiseaseCycleCount++
  Move-CurrentHost -World $WorldBoard.WorldCells
  Test-DiseaseNeighbour -World $WorldBoard.WorldCells -InfectCycle $InfectionCycle
  Test-Infected -World $WorldBoard.WorldCells
  Show-World -World $WorldBoard.WorldCells -Count $DiseaseCycleCount

} until ($WorldBoard.WorldCells.Value -notcontains 'I') 