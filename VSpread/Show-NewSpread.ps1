[CmdletBinding()]
Param(
  [int]$WorldSideSize = 10
)

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
    elseif ($LocNum -eq ($BoardSize*$BoardSize-1)) {$this.Neighbours = ($BoardSize*$BoardSize-2),($BoardSize*$BoardSize-1-$BoardSize)}
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
    if ($this.Age -ge 70) {$Jump = 2}
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

  [void]Incubate () {
    If ($this.Infected -eq $true) {
      $this.DaysInfected++
      $Chance = (1..100 | Get-Random)
      if ($Chance -le 30) {$this.Health--}
      if ($this.Health -eq 0) {$this.Died()}
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
  Write-Host
  $Stats = @{
    UninfectedCount = ($HumanHosts | Where-Object {$_.Infected -eq $false -and $_.Alive -eq $true -and $_.Recovered -eq $false}).Count
    InfectedCount = ($HumanHosts | Where-Object {$_.Infected -eq $true}).Count
    RecoveredCount = ($HumanHosts | Where-Object {$_.Recovered -eq $true}).Count
    DeathToll = ($HumanHosts | Where-Object {$_.Alive -eq $false}).Count
  }
  Write-Host -ForegroundColor Yellow -NoNewline  "Uninfected % :"
  "{0,3}" -f "$([math]::Round($Stats.UninfectedCount/$HumanHosts.count * 100,0))"
  Write-Host -ForegroundColor Yellow -NoNewline  "Infected % :"
  "{0,5}" -f "$([math]::Round($Stats.InfectedCount/$HumanHosts.count * 100,0))"
  Write-Host -ForegroundColor Yellow -NoNewline  "Recovered % :"
  "{0,4}" -f "$([math]::Round($Stats.RecoveredCount/$HumanHosts.count * 100,0))"
  Write-Host -ForegroundColor Yellow -NoNewline  "Dead % :"
  "{0,9}" -f "$([math]::Round($Stats.DeathToll/$HumanHosts.count * 100,0))"
}

function Test-HostHealth {
  Param (
    $HumanHosts,
    $VirusLife
  )
  foreach ($Human in $HumanHosts) {
    $Human.Incubate()
    if ($Human.DaysInfected -gt $VirusLife) {$Human.Recover()}
  }
}

function Test-InfectedNeighbours {
  Param (
    $World,
    $HumanHosts
  )
  [int[]]$HostIDToInfect = @()
  foreach ($WorldPos in $World) {
    if ($WorldPos.HostID -eq -1) {continue}
    [int[]]$Neighbours = foreach ($Neighbour in $WorldPos.Neighbours) {if ($World[$Neighbour].HostID -ne -1) {$Neighbour}}
    if ($Neighbours.Count -gt 0 -and $HumanHosts[$World[$Neighbours].HostID].Infected -contains $true) {$HostIDToInfect += $WorldPos.HostID}
  }
  foreach ($HostID in $HostIDToInfect) {
    $HumanHosts[$HostID].Infect()
  }
}
function Move-Host {
  Param (
    $World,
    $HumanHost
  )
  if ($HumanHost.Alive -eq $false) {return}
  $HostPosition = $World | Where-Object {$_.HostID -eq $HumanHost.hostID}
  $ValidNeighbours = $HostPosition.Neighbours | ForEach-Object {if ($World[$_].HostID -eq -1) {$_}}
  if ($ValidNeighbours.Count -gt 0) {
    $RandomValNeibr = $ValidNeighbours | Get-Random
    $World[$RandomValNeibr].PlaceHost($HumanHost.HostID)
    $World[$HostPosition.LocationNumber].RemoveHost()
  }  
}
### Main CODE ###
# Setup the world size


$WorldSize = [math]::Pow($WorldSideSize,2)
$LastPos = $WorldSize - 1
$World = foreach ($Pos in (0..$LastPos)) {[Location]::New($Pos, $WorldSideSize)}
# Setup the hosts
$MostHosts = [math]::Truncate($WorldSize / 4)
$LeastHosts = [math]::Truncate($WorldSize / 10)
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
$Day = 0  
Show-World -World $World -HumanHosts $HumanHosts -WorldSideSize $WorldSideSize -DayNumber $Day
do {
  Test-InfectedNeighbours -World $World -HumanHosts $HumanHosts
  Test-HostHealth -HumanHosts $HumanHosts -VirusLife 14
  # Show-World -World $World -HumanHosts $HumanHosts -WorldSideSize $WorldSideSize -DayNumber $Day
  foreach ($Human in $HumanHosts) {
    Move-Host -World $World -HumanHost $Human
  }
  Show-World -World $World -HumanHosts $HumanHosts -WorldSideSize $WorldSideSize -DayNumber $Day
  Start-Sleep -Milliseconds 30
  $Day++
} until ($HumanHosts.Infected -notcontains $true )
