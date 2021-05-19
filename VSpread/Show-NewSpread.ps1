
Class Location {
  [int]$LocationNumber
  [int]$LocationRow
  [int]$LocationCol
  [int]$HostID
  [int[]]$Neighbours

  Location ($LocNum,$BoardSize) {
    $this.LocationNumber = $LocNum
    $this.LocationRow = [math]::Truncate($LocNum/$BoardSize)
    $this.LocationCol = $LocNum % $BoardSize
    $this.HostID = -1
    if ($LocNum -eq 0) {$this.Neighbours = 1,$BoardSize}
    elseif ($LocNum -eq ($BoardSize-1)) {$this.Neighbours = ($BoardSize - 2),($BoardSize - 1 + $BoardSize)}
    elseif ($LocNum -eq ($BoardSize*($BoardSize-1))) {$this.Neighbours = ($BoardSize*($BoardSize-1)-$BoardSize),($BoardSize*($BoardSize-1)+1)}
    elseif ($LocNum -eq ($BoardSize*$BoardSize-1)) {$this.Neighbours = ($BoardSize*$BoardSize-2),($BoardSize*$BoardSize-2-$BoardSize)}
    elseif (($LocNum % $BoardSize) -eq 0) {$this.Neighbours = ($LocNum-$BoardSize),($LocNum+$BoardSize),($LocNum+1)}
    elseif (($LocNum % $BoardSize) -eq ($BoardSize-1)) {$this.Neighbours = ($LocNum-$BoardSize),($LocNum+$BoardSize),($LocNum-1)}
    elseif ([math]::Truncate($LocNum / $BoardSize) -eq 0) {$this.Neighbours = ($LocNum+$BoardSize),($LocNum-1),($LocNum+1)}
    elseif ([math]::Truncate($LocNum / $BoardSize) -eq ($BoardSize-1)) {$this.Neighbours = ($LocNum-$BoardSize),($LocNum-1),($LocNum+1)}
    else {$this.Neighbours = ($LocNum-$BoardSize),($LocNum+$BoardSize),($LocNum-1),($LocNum+1)}
  }

  [void]PlaceHost ($ID) {
    if ($this.HostID -eq -1) {$this.HostID = $ID}
  }

  [void]RemoveHost () {
    $this.HostID = -1
  }
}

Class HumanHost {
  [int]$HostID
  [bool]$Alive
  [bool]$Infected
  [int]$DaysInfected
  [bool]$Recovered
  [String]$DisplayChar # D-dead I-Infected U-Unifected R-Recovered
  [int]$Age
  [int]$Health # 0 Dead...9 SuperFit
  [bool]$AntiRules

  HumanHost ($ID,$Infected,$Age,$Anti) {
    $this.HostID = $ID
    $this.Alive = $true
    $this.Infected = $Infected
    $this.DaysInfected = 0
    $this.Recovered = $false
    $this.DisplayChar = if ($Infected -eq $true) {'I'} else {'U'}
    $this.Age = $Age
    if ($Age -le 25) {$this.Health = 5..9 | Get-Random}
    elseif ($Age -le 50) {$this.Health  = 2..8 | Get-Random}
    else {$this.Health  = 1..8 | Get-Random}
    $Randomness = 1..100 | Get-Random
    $RandomShift = 1..3 | Get-Random
    if ($Randomness -le 50 -and $this.Health  -ge 4) {$this.Health  = $this.Health  - $RandomShift}
    if ($Randomness -le 50 -and $this.Health  -le 4) {$this.Health  = $this.Health  + $RandomShift}
    $this.AntiRules = $Anti
  }

  [void]Infect () {
    $this.Infected = $true
    $this.DisplayChar = 'I'
    if ($this.Age -ge 70) {$Jump = 4}
    else {$Jump = 1}
    $this.Health -= $Jump
    if ($this.Health -le 0) {
      $this.Alive = $false
      $this.Infected = $false
      $this.DisplayChar = 'D'
      $this.DaysInfected = 0
      $this.Recovered = $false
      $this.Health = 0
      $this.AntiRules = $false
    }
  }

  [void]Died () {
    $this.Alive = $false
    $this.Infected = $false
    $this.DaysInfected = 0
    $this.DisplayChar = 'D'
    $this.Recovered = $false
    $this.Health = 0
    $this.AntiRules = $false
  }

  [void]Recover () {
    if ($this.Infected -eq $true) {
      $this.Infected = $false
      $this.DisplayChar = 'R'
      $this.DaysInfected = 0
      $this.Recovered = $true
      $this.Health += 1
    }
  }
}

# Funtions
function Show-World {
  Param (
    $World,
    $HumanHosts,
    $WorldSideSize,
    $DayNumber
  )
  Clear-Host
  $LastWorldPos = [math]::Pow($WorldSideSize,2) - 1 
  0..$LastWorldPos | ForEach-Object {
    if (($_ % $WorldSideSize) -eq 0) {Write-Host}
    $ID = $World[$_].HostID
    $Color = 'White'
    if ($ID -eq -1) {$Display = '.'}
    else {
      $Display = $HumanHosts[$ID].DisplayChar
      if ($Display -eq 'U') {$Color = 'Green'}
      elseif ($Display -eq 'I') {$Color = 'Red'}
      elseif ($Display -eq 'R') {$Color = 'Cyan'}
      elseif ($Display -eq 'D') {$Color = 'Gray'}    
    }
    Write-Host $Display -NoNewline -ForegroundColor $Color
    Write-Host ' ' -NoNewline
  }
  Write-Host -ForegroundColor Yellow -NoNewline "`n`nDay: " 
  Write-Host $DayNumber
}

Function Test-InfectedNeighbours {
  Param (
    $World,
    $HumanHosts
  )
  
}
### Main CODE ###
# Setup the world size

$WorldSideSize = 10
$WorldSize = $WorldSideSize * $WorldSideSize
$LastPos = $WorldSize - 1
$World = foreach ($Pos in (0..$LastPos)) {[Location]::New($Pos, $WorldSideSize)}
# Setup the hosts
$MostHosts = [math]::Truncate($WorldSize / 2)
$LeastHosts = [math]::Truncate($WorldSize / 5)
$TotalHosts = $LeastHosts..$MostHosts | Get-Random
$TotalHostsIndex = $TotalHosts - 1
$InitialHostPositions = 0..$LastPos | Get-Random -Count $TotalHosts
# Configure HumanHosts
$HumanHosts = 0..$TotalHostsIndex | ForEach-Object {
  if ((0..3 | Get-Random) -eq 2) {$Infected = $true} else {$Infected = $false}
  $Age = (1..50 | Get-Random ) + (1..50 | Get-Random )
  $Anti =  if ((1..100 | Get-Random) -le 5) {$true} else {$false}
  [HumanHost]::New($_,$Infected,$Age,$Anti) 
}
# Place the human hosts at random in the world
0..$TotalHostsIndex | ForEach-Object {
  $HostPos = $InitialHostPositions[$_]
  $World[$HostPos].PlaceHost($HumanHosts[$_].HostID)
}

Show-World -World $World -HumanHosts $HumanHosts -WorldSideSize $WorldSideSize -DayNumber 0
<#
do {
  foreach ($Position in $World) {
    if ($Position.HostID -eq -1 ) {continue}

  }
  # Check if neighbours are infected
  
  # Spread Virus and check for death

  # Show World
  
  # Move Hosts

  # Show World
  
} Until ($false)
#>