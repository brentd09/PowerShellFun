<#
.SYNOPSIS
  Shows the uncontrolledspread of disease in a community
.DESCRIPTION
  This simulates the spread of disease where no precautions are taken
.EXAMPLE
  Show-VSpread -PercentInitiallyInfected 55 -PercentAntiEstablishment 2 -PercentFailingHealth 10 -NumberOfEntities 60 -World 400 -ShowStatsInTable
  This sets up a 
    world size of 400 size with 
    60 hosts of which 10% are in poor health
    55% are initially infected and 
    2% have a bad attitude regarding law and order
.PARAMETER PercentInitiallyInfected 
  Percent of hosts already infected
.PARAMETER PercentAntiEstablishment
  Percent of hosts that disregard law and order
.PARAMETER PercentFailingHealth 
  Percent of hosts that have poor health 
.PARAMETER NumberOfEntities 
  The number pf hosts in the world
.PARAMETER World 
  The size of the world, so that we can achieve a square the world sizes are restricted to these values:
  100,121,144,169,196,225,256,289,324,361,400,441,484,529,576,625,676,729,784,841,900
  meaning that the square-root of any of these values gives an integer result
.PARAMETER ShowStatsInTable
  This shows a statistics table insead of a pictorial one
.NOTES
  General notes
    Created By:  Brent Denny
    Created On:  18 Mar 2021
    Inspired by: the COVID-19 pandemic
    Still to be completed: 
      behaviour of AntiEstablishment hosts
      movement has some issues still
#>
[CmdletBinding()]
Param (
  [int]$PercentInitiallyInfected = 55,
  [int]$PercentAntiEstablishment = 2,
  [int]$PercentFailingHealth = 90,
  [int]$NumberOfEntities = 60,
  [ValidateSet(100,121,144,169,196,225,256,289,324,361,400,441,484,529,576,625,676,729,784,841,900)]
  [int]$World = 400,
  [switch]$ShowStatsInTable
)

Class Entity {
  [int]$EntityID
  [string]$DisplayChar
  [int]$ExposurestoAgent
  [bool]$AntiEstablishment
  [bool]$Infected
  [int]$Contagious
  [bool]$Recovered
  [bool]$Dead
  [bool]$FailingHealth
  [int]$Position
  [int]$Row
  [int]$Col

  Entity ($ID,$ChanceInfected,$ChanceAnti,$ChanceBadHealth,$Pos,$Row,$Col) {
    $this.EntityID = $ID
    if ((1..100 | Get-Random) -le $ChanceInfected) {$Sick = $true} 
    else {$Sick = $false}
    $Anti = if ((1..100 | Get-Random) -le $ChanceAnti) {$true} else {$false}
    $Infirm = if ((1..100 | Get-Random) -le $ChanceBadHealth) {$true} else {$false}
    $this.Infected = $Sick
    $this.AntiEstablishment = $Anti
    $this.FailingHealth = $Infirm
    if ($Sick -eq $true) {
      $this.DisplayChar = 'U'
      $this.ExposurestoAgent = 1
      $this.Contagious = 14
    } 
    else {
      $this.DisplayChar = 'U'
      $this.ExposurestoAgent = 0
      $this.Contagious = 0
    }
    $this.Recovered = $false
    $this.Dead = $false
    $this.Position = $Pos
    $this.Row = $Row
    $this.Col = $Col
  }

  [void]Infect () {
    if ($this.Recovered -ne $true -and $this.Dead -ne $true) {
      if ($this.Contagious -gt 0) {
        $this.ExposurestoAgent = $this.ExposurestoAgent + 1
        if ($this.ExposurestoAgent -gt 3) {$this.FailingHealth -eq $true}
      }
      else {
        $this.Contagious = 14
        $this.Infected = $true
        $this.ExposurestoAgent = $this.ExposurestoAgent + 1
        $this.DisplayChar = 'U'
      }
    }
  }

  [void]NaturalProcess () {
    if ($this.Recovered -ne $true -and $this.Dead -ne $true) {
      if ($this.infected -eq $true -and $this.Contagious -lt 5 -and ($this.FailingHealth -eq $true -or $this.ExposurestoAgent -gt 10)) {
        $this.Dead = $true
        $this.Recovered = $false
        $this.Infected = $false
        $this.DisplayChar = 'D'
        $this.Contagious = $false
        $this.AntiEstablishment = $false
        $this.FailingHealth = $false
      }
      if ($this.Contagious -eq 1) {
        $this.Contagious = $this.Contagious - 1
        $this.DisplayChar = 'R'
        $this.Infected = $false
        $this.Recovered = $true
      }
      elseif ($this.Contagious -gt 1 -and $this.Contagious -le 11) {
        $this.Contagious =  $this.Contagious - 1
        $this.DisplayChar = 'I'
        $this.Infected = $true
        $this.Recovered = $false
      }
      elseif ($this.Contagious -gt 11) {
        $this.Contagious =  $this.Contagious - 1
        $this.DisplayChar = 'U'
        $this.Infected = $true
        $this.Recovered = $false

      }
    }
  }
}

function Show-World {
  Param (
    [int[]]$Array,
    [Entity[]]$WorldElements
  )
  $coord = [System.Management.Automation.Host.Coordinates]::New(0,0)
  $host.UI.RawUI.CursorPosition = $coord
  $Count = 0
  $SideLength = [math]::Sqrt($Array.Count) 
  foreach ($ArrayLoc in $Array) {
    $Count++
    if ($ArrayLoc -in $WorldElements.Position) {
      $ShowChar = ($WorldElements | Where-Object {$_.Position -eq $ArrayLoc}).DisplayChar
      switch ($ShowChar) {
        'U' {$Color = 'Green' }
        'I' {$Color = 'Red'}
        'R' {$Color = 'Cyan'}
        'D' {$Color = 'Yellow'}
        Default {$Color = 'Gray'}
      }
      Write-Host -NoNewline -ForegroundColor $Color "$ShowChar "
    }
    else {
      Write-Host -NoNewline -ForegroundColor Gray '- '
    }
    if ($Count -eq $SideLength) {
      $Count = 0
      Write-Host
    }
  } 
  <#
  $NumUninfected = ($WorldElements | Where-Object {$_.Infected -eq $false -and $_.Dead -eq $false -and $_.Recovered -eq $false}).Count
  $NumInfected = ($WorldElements | Where-Object {$_.Infected -eq $true }).Count
  $NumRecovered = ($WorldElements | Where-Object {$_.Recovered -eq $true }).Count
  $NumDead = ($WorldElements | Where-Object {$_.Dead -eq $true }).Count
  Write-Host
  Write-Host -ForegroundColor Green  "Uninfected: $NumUninfected"
  Write-Host -ForegroundColor Red    "Infected:   $NumInfected"
  Write-Host -ForegroundColor Cyan   "Recovered   $NumRecovered"
  Write-Host -ForegroundColor Yellow "Dead        $NumDead"
  #>
}

function Find-NeighbourIndex {
  Param (
    [int]$Pos,
    [int]$Dimension
  )
  [int[]]$NeighbourIndexArray = @()
  $NeighbourArray = @(-1,1,-$Dimension,$Dimension)
  foreach ($Direction in $NeighbourArray) {
    $PotentialNeighbour = $Pos + $Direction
    if (([math]::Truncate($Pos/$Dimension)) -eq ([math]::Truncate($Pos/$Dimension)) -and ([math]::abs($Direction) -eq 1)) {$NeighbourIndexArray += $PotentialNeighbour}
    if (($Pos%$Dimension) -eq  ($PotentialNeighbour%$Dimension) -and ([math]::abs($Direction) -gt 1)) {$NeighbourIndexArray += $PotentialNeighbour}
  }
  return $NeighbourIndexArray
}


function Send-VirusToNeighbours {
  Param (
    [Entity[]]$WholeWorld,
    [int]$WorldDimension
  )
  $InfectedElements = $WholeWorld | Where-Object {$_.Infected -eq $true}
  foreach ($InfectedElement in $InfectedElements) {
    $Pos = $InfectedElement.Position
    $NeighbourIndexes = Find-NeighbourIndex -Pos $Pos -Dimension $WorldDimension
    foreach ($Index in $NeighbourIndexes) {
      $NeighbourElement = $WholeWorld | Where-Object {$_.Position -contains $Index}
      if ($NeighbourElement) {$NeighbourElement.Infect()}
    }
  }
}

function Move-Position {
  Param (
    [Entity[]]$WholeWorld,
    [int]$Pos,
    [int]$Dimension
  )
  $EmptySpots = @()
  $MoveNeighbourIndexes = Find-NeighbourIndex -Pos $Pos -Dimension $Dimension
  [int[]]$EmptySpots = foreach ($MoveNeighbourIndex in $MoveNeighbourIndexes) {
    if ($WholeWorld.Position -notcontains $MoveNeighbourIndex) {$MoveNeighbourIndex}
  }
  $EmptySpots += $Pos
  $NewLocation = $EmptySpots | Get-Random
  $ElementToMove = $WholeWorld | Where-Object {$_.Position -eq $Pos}
  $ElementToMove.Position = $NewLocation
}

# MAIN CODE
Clear-Host
$WorldArraySize = 0..($World-1)
$SqrRoot = [math]::Sqrt($WorldArraySize.Count)
if ($SqrRoot  -ne ([math]::Truncate($SqrRoot))) {break}
if ($NumberOfEntities -ge $World) {break}
[System.Collections.ArrayList]$WorldArray = $WorldArraySize.Clone()
$EntitiesMaxIndex = $NumberOfEntities - 1
if ($NumberOfEntities -lt ($WorldArray[-1]+1)) {
  [entity[]]$AllElements = 0..$EntitiesMaxIndex | ForEach-Object {
    $EntityPos = $WorldArray | Get-Random
    $WorldArray.Remove($EntityPos)
    $PCInfected = [math]::Truncate($PercentInitiallyInfected/$NumberOfEntities*100)
    $PCAnti = [math]::Truncate($PercentAntiEstablishment/$NumberOfEntities*100)
    $PCBadHealth = [math]::Truncate($PercentFailingHealth/$NumberOfEntities*100)
    $ElementRow = [math]::Truncate($EntityPos/$SqrRoot)
    $ElementCol = $EntityPos % $SqrRoot
    [Entity]::New($_,$PCInfected,$PCAnti,$PCBadHealth,$EntityPos,$ElementRow,$ElementCol)

  }
}
if ($ShowStatsInTable -eq $true) {
  $coord = [System.Management.Automation.Host.Coordinates]::New(0,0)  
  $host.UI.RawUI.CursorPosition = $coord    
  $AllElements  | format-Table -Property *
}
else {Show-World -Array $WorldArraySize -WorldElements $AllElements}
Start-Sleep -Milliseconds 10
$ViralCount = 0
do {
  $ViralCount++
  $AllElements.NaturalProcess()
  Send-VirusToNeighbours -WholeWorld $AllElements -WorldDimension $SqrRoot
  foreach ($Element in $AllElements) {
  if ($Element.Dead -ne $true) {Move-Position -WholeWorld $AllElements -Pos $Element.Position -Dimension $SqrRoot}
  }
  if ($ShowStatsInTable -eq $true) {
    $coord = [System.Management.Automation.Host.Coordinates]::New(0,0)  
    $host.UI.RawUI.CursorPosition = $coord  
    $AllElements  | format-Table -Property *
  }
  else {Show-World -Array $WorldArraySize -WorldElements $AllElements}
  Start-Sleep -Milliseconds 10
} until ($AllElements.Infected -notcontains $true)