<#
.SYNOPSIS
  Tries to simulate the spread of a disease
.DESCRIPTION
  This will attempt to show the spread of a disease with a 10 cycle life span (10 day)
  This will show that disease hosts that get too close to each other for too long will 
  transmit the disease and if the hosts stay away from each other the disease will die out
.EXAMPLE
  Show-Spread 
  this will show a grid of infected and un-infected hosts and how the disease interacts
.NOTES
  General notes
#>
[CmdletBinding()]
Param(
  [int]$InfectedPercent = 2,
  [int]$PopulationPercent = 30,
  [int]$InfectionCycle = 15
)
# Classes
class WorldCell {
  [int]$Index
  [int]$Row
  [int]$Col
  [string]$Value
  [bool]$BeenInfected
  [int]$InfectionCycles

  WorldCell ([int]$Position,[int]$InfectPercent,[int]$PopPercent,[int]$InfectCycle) {
    $this.Index = $Position
    $this.Col = $Position % 20
    $this.Row = [math]::Truncate($Position / 20)
    $RandomNum = 1..100 | Get-Random
    if ($RandomNum -le $InfectPercent) {
      $this.Value = 'I'
      $this.BeenInfected = $true
      $this.InfectionCycles = $InfectCycle
    }
    elseif ($RandomNum -le $PopPercent) {
      $this.Value = 'U'
      $this.BeenInfected = $false
      $this.InfectionCycles = 0
    }
    else {$this.Value = '.'}
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
  foreach ($RowNum in (0..19)) {
    $WorldRow = $World | Where-Object {$_.Row -eq $RowNum}
    $WorldRow.Value -join " "
  } 
  $Infected = $World | Where-Object {$_.Value -eq 'I'}
  $Uninfected = $World | Where-Object {$_.Value -eq 'U' -and $_.BeenInfected -eq $false}
  $Recovered = $World | Where-Object {$_.Value -eq 'U' -and $_.BeenInfected -eq $true}
  Write-Host -ForegroundColor Green "Uninfected $($Uninfected.Count)   " 
  Write-Host -ForegroundColor Cyan "Recovered $($Recovered.Count)   " 
  Write-Host -ForegroundColor Red "Infected $($Infected.Count)  "
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
  }
}

function Move-CurrentHost {
  param ([WorldBoard]$World)
  $UpDown = @(-20,20)
  $LeftRight = @(-1,1)
  $CurrentHosts =  $World.WorldCells | Where-Object {$_.Value -ne '.'}
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
Clear-Host
$Spots = 0..399 | ForEach-Object {[WorldCell]::New($_,$InfectedPercent,$PopulationPercent,$InfectionCycle)}
$WorldBoard = [WorldBoard]::New($Spots) 
Show-World -World $WorldBoard.WorldCells
$DiseaseCycleCount = 0
do {
  $DiseaseCycleCount++
  Move-CurrentHost -World $WorldBoard.WorldCells
  Test-DiseaseNeighbour -World $WorldBoard.WorldCells -InfectCycle $InfectionCycle
  Test-Infected -World $WorldBoard.WorldCells
  Show-World -World $WorldBoard.WorldCells -Count $DiseaseCycleCount
  Start-Sleep -Milliseconds 200
} until ($WorldBoard.WorldCells.Value -notcontains 'I') 