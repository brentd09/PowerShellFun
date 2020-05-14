<#
.SYNOPSIS
  Clasic Battleship board game
.DESCRIPTION
  This simulates the clasic board game however you play against the computer.
  Before the game starts you are asked whether you like the placement of your 
  ships, if not the ships will be placed again, until you accept the placement.
  Each turn you choose a coordinate to hit on the computers board to see if
  you can sink all of the computers ships before the computer sinks yours.
  Grey X means your attempt was a miss, a red X means you hit a ship.
  The sizes of the different ships are:
  Type                 Size
  -----                ----   
  Aircraft Carrier       5
  Battleship             4
  Cruiser                3
  Destroyer              3
  Submarine              2
.EXAMPLE
  Play-BattleShip.ps1
  This starts the game
.NOTES
  General notes
    Created By: Brent Deny
    Created On: 11 May 2020
#>
[CmdletBinding()]
param ()

# CLASSES
Class Ship {
  [string]$ShipName
  [string]$ShipCode
  [int]$ShipLength

  Ship ([string]$ShipName,[int]$Size) {
    $this.ShipName = $ShipName
    $this.ShipCode = $ShipName.Substring(0,1)
    $this.ShipLength = $Size 
  }
}

Class BattleShipElement {
  [int]$Position
  [int]$Row 
  [int]$Col
  [string]$ShipType
  [bool]$Attacked
  [string]$AttackResult
  [int[]]$NeighbourValues

  BattleShipElement ([int]$Pos) {
    $this.Position = $Pos
    $this.Row = [math]::Truncate($Pos / 10)
    $this.Col = $Pos % 10
    $this.ShipType = '.'
    $this.Attacked = $false
    $this.AttackResult = 'Unattacked' # Unattacked, Hit, Miss (possible values here)
    if ([math]::Truncate($Pos / 10) -eq 0) { #Row is 0
      if ($Pos % 10 -eq 0) {$this.NeighbourValues = @(1,10)} #Col is 0
      elseif ($Pos % 10 -eq 9) {$this.NeighbourValues = @(-1,10)} #Col is 9
      else {$this.NeighbourValues = @(-1,1,10)} #Col is in the middle 
    }
    elseif ([math]::Truncate($Pos / 10) -eq 9) { #Row is 9
      if ($Pos % 10 -eq 0) {$this.NeighbourValues = @(1,-10)} #Col is 0
      elseif ($Pos % 10 -eq 9) {$this.NeighbourValues = @(-1,-10)} #Col is 9
      else {$this.NeighbourValues = @(-1,1,-10)} #Col is in the middle       
    }
    else {
      if ($Pos % 10 -eq 0) {$this.NeighbourValues = @(1,10,-10)} #Col is 0
      elseif ($Pos % 10 -eq 9) {$this.NeighbourValues = @(-1,10,-10)} #Col is 9
      else {$this.NeighbourValues = @(-1,1,10,-10)} #Col is in the middle 
    }
  } # contructor

  [bool]Attack (){
    if ($this.Attacked -eq $false) {
      $this.Attacked = $true
      if ($this.ShipType -in 'A','B','C','D','S') {
        $this.AttackResult = 'Hit'
      }
      else {
        $this.AttackResult = 'Miss'
      }
      return $true
    }
    else {return $false}
  }
}

Class BattleShipBoard {
  [BattleShipElement[]]$Layout

  BattleShipBoard ([BattleShipElement[]]$BSElements) {
    $this.Layout = $BSElements
  }

  [void]PlaceShips () {
    [Ship[]]$Ships = [ship]::New('AircraftCarrier',5)
    [Ship[]]$Ships += [ship]::New('Battleship',4)
    [Ship[]]$Ships += [ship]::New('Cruiser',3)
    [Ship[]]$Ships += [ship]::New('Destroyer',3)
    [Ship[]]$Ships += [ship]::New('Submarine',2)
    foreach ($Ship in $Ships) {
      $Direction = "horizontal","vertical" | Get-Random
      do {
        $Conflict = $false
        if ($Direction -eq 'horizontal'){
          $Incr = 1 
          $PlacementRow = 0..9 | Get-Random
          $PlacementCol = 0..(9-$Ship.ShipLength) | Get-Random
          $Pos = (10 * $PlacementRow) + $PlacementCol
          for ($count = 0;$count -lt $Ship.ShipLength;$count = $count + $incr) {
            if ($this.Layout[$Pos+$count].ShipType -ne '.') {$Conflict = $true}
          }
          if ($Conflict -eq $false) {
            for ($count = 0;$count -lt $Ship.ShipLength;$count = $count + $incr) {
              $this.Layout[$Pos+$count].ShipType = $Ship.ShipCode
            }
          }            
        }  
        else {
          $Incr = 10
          $PlacementCol = 0..9 | Get-Random
          $PlacementRow = 0..(9-$Ship.ShipLength) | Get-Random
          $Pos = (10 * $PlacementRow) + $PlacementCol
          for ($count = 0;$count -lt $Ship.ShipLength;$count = $count + 1) {
            $Incr = 10 * $count
            if ($this.Layout[$Pos+$Incr].ShipType -ne '.') {$Conflict = $true}
          }
          if ($Conflict -eq $false) {
            for ($count = 0;$count -lt $Ship.ShipLength;$count = $count + 1) {
              $Incr = 10 * $count
              $this.Layout[$Pos+$Incr].ShipType = $Ship.ShipCode
            }
          }         
        } # else - vertical placement
     } while ($Conflict -eq $true)
    } # foreach ship
  } # Method PlaceShips
} # Class BattleShipBoard


# FUNCTIONS
function ShowBoard {
  Param (
    [BattleShipBoard]$Board,
    [string]$Title,
    [switch]$ShowShips
  )
  if ($Title -eq 'user') {
    Clear-Host
    Write-Host -ForegroundColor Cyan "              B  A  T  T  L  E  S  H  I  P"
    Write-Host -ForegroundColor Cyan "              ----------------------------"
  }
  Write-Host -ForegroundColor Red "$($Title.ToUpper()) BOARD"
  Write-Host -Foreground Yellow "   A  B  C  D  E  F  G  H  I  J"
  0..9 | ForEach-Object {
    $LeftPos = $_ * 10 
    $RightPos = $_ * 10 + 9
    Write-Host -NoNewline -ForegroundColor Yellow "$_  "
    $LeftPos..$RightPos | ForEach-Object {
      if ($Board.Layout[$_].ShipType -notin 'A','B','C','D','S') {
        if ($Board.Layout[$_].Attacked -eq $true) {
          $Color = 'darkgray'
          $IconToDisplay = 'X'
        }
        else { # Not attacked
          $Color = 'DarkGray'
          $IconToDisplay = '.'
        }
      }
      else { # Located a ship
        if ($Board.Layout[$_].Attacked -eq $true) {
          $Color = 'Red'
          $IconToDisplay = 'X'
        }
        else { # Not attacked
          if ($ShowShips -eq $true) {
            $Color = 'Cyan'
            $IconToDisplay = $Board.Layout[$_].ShipType
          }
          else {
            $Color = 'DarkGray'
            $IconToDisplay = '.'
          }
        }
      }
      Write-Host -ForegroundColor $Color -NoNewline "$IconToDisplay  " 
    }
    Write-Host
  }
  Write-Host
}

# MAIN CODE

Clear-Host
Write-Host -ForegroundColor Cyan "              B  A  T  T  L  E  S  H  I  P"
Write-Host -ForegroundColor Cyan "              ----------------------------`n"

# Setup Game Boards
do {
  [BattleShipElement[]]$UserBoardElements = 0..99 | ForEach-Object {[BattleShipElement]::New($_)}
  [BattleShipElement[]]$ComputerBoardElements = 0..99 | ForEach-Object {[BattleShipElement]::New($_)}
  $PlayerBoard = [BattleShipBoard]::new($UserBoardElements)
  $ComputerBoard = [BattleShipBoard]::new($ComputerBoardElements)
  $PlayerBoard.PlaceShips()
  $ComputerBoard.PlaceShips() 
  ShowBoard -Board $PlayerBoard -Title 'user' -ShowShips 
  ShowBoard -Board $ComputerBoard -Title 'Computer'  
  $HappyWithShips = Read-Host -Prompt 'Are you happy with the ship placement'
} Until ($HappyWithShips -like 'y*' -and $HappyWithShips -ne '')

#Play game
do {
  ShowBoard -Board $PlayerBoard -Title 'user' -ShowShips 
  ShowBoard -Board $ComputerBoard -Title 'Computer' 
  do {
    $Coords = Read-Host -Prompt 'Enter Coordinates'
    if ($Coords -notmatch '^[a-j][0-9]$' -and $Coords -notmatch '^[0-9][a-j]$' ) {continue}
    $Coords = $Coords -replace '[^0-9a-j]','' -replace '([0-9])([a-j])','$2$1'
    [int]$ColChosen = [byte][char]($Coords.substring(0,1)) - 97
    [int]$RowChosen = $Coords.substring(1,1)
    $Pos = $RowChosen * 10 + $ColChosen
    $AttackResult = $ComputerBoard.Layout[$Pos].Attack()
  } until ($Coords -match '^[a-j][0-9]$' -and $AttackResult -eq $true)
  $NumberOfHits = ($ComputerBoard.Layout | Where-Object {$_.AttackResult -eq 'Hit'}).count
} until ($NumberOfHits -eq 17)
ShowBoard -Board $PlayerBoard -Title 'user' -ShowShips 
ShowBoard -Board $ComputerBoard -Title 'Computer' 