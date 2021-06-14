<#
.SYNOPSIS
  Game of life - using John Conways original rules
.DESCRIPTION
  RIP John Conway, born 26 Dec 1937 and died 11 April 2020 from COVID-19
  This is the original zero player game as created by the mathematician John Conway
  The rules:
    Any live cell with two or three live neighbours survives.
    Any dead cell with three live neighbours becomes a live cell.
    All other live cells die in the next generation. Similarly, all other dead cells stay dead.
.EXAMPLE
  Play-GameOfLife.ps1
  Runs the game starting with random alive and dead cells and then runs until the same alive count is 
  maintained for 5 turns
.EXAMPLE
  Play-GameOfLife.ps1 -GameSize 20
  Runs the game starting with random alive and dead cells and will be played on a 20x20 game board it then 
  runs until the same alive count is maintained for 5 turns
.PARAMETER GameSize
  This is the size of both the height and width of the board that is used for the game of life game
.NOTES
  General notes
    Created by: Brent Denny
    Created on: 9 Jun 2021
      Modified: 14 Jun 2021
#>
[CmdletBinding()]
Param (
  [int]$GameSize = 40
)

Class GOLCell {
  [int]$Position
  [int]$Col 
  [int]$Row 
  [bool]$CurrentState
  [bool]$NextGenState
  [string]$DisplayChar
  [int[]]$Neighbours

  GOLCell ($Location,$GameSquareLength) {
    $this.Position = $Location
    $this.Col = $Location%$GameSquareLength
    $this.Row = [math]::Truncate($Location/$GameSquareLength)
    $this.CurrentState = ($true,$false) | Get-Random
#     if ($this.Col -eq 4 -and $this.Row -eq 3) {$this.CurrentState = $true}
#     elseif ($this.Col -eq 3 -and $this.Row -eq 3) {$this.CurrentState = $true}
#     elseif ($this.Col -eq 2 -and $this.Row -eq 3) {$this.CurrentState = $true}
#     elseif ($this.Col -eq 4 -and $this.Row -eq 2) {$this.CurrentState = $true}
#     elseif ($this.Col -eq 3 -and $this.Row -eq 1) {$this.CurrentState = $true}
#     else {$this.CurrentState = $false}
    $this.NextGenState = $false
    if ($this.CurrentState -eq $true) {$this.DisplayChar = '#'}
    else {$this.DisplayChar = '.'}
    if ($Location -eq 0) {$this.Neighbours = ($Location+1),($Location+$GameSquareLength),($Location+$GameSquareLength+1)}
    elseif ($Location -eq ($GameSquareLength-1)) {$this.Neighbours = ($Location-1),($Location+$GameSquareLength),($Location+$GameSquareLength-1)}
    elseif ($Location -eq ($GameSquareLength*($GameSquareLength-1))) {$this.Neighbours = ($Location+1),($Location-$GameSquareLength),($Location-$GameSquareLength+1)}
    elseif ($Location -eq ($GameSquareLength*$GameSquareLength-1)){$this.Neighbours = ($Location-1),($Location-$GameSquareLength),($Location-$GameSquareLength-1)}
    elseif ($this.Row -eq 0) {$this.Neighbours = ($Location-1),($Location+1),($Location+$GameSquareLength),($Location+$GameSquareLength-1),($Location+$GameSquareLength+1)}
    elseif ($this.Col -eq 0) {$this.Neighbours = ($Location-$GameSquareLength),($Location+$GameSquareLength),($Location+1),($Location-$GameSquareLength+1),($Location+$GameSquareLength+1)}
    elseif ($this.Row -eq $GameSquareLength-1) {$this.Neighbours = ($Location-1),($Location+1),($Location-$GameSquareLength),($Location-$GameSquareLength-1),($Location-$GameSquareLength+1)}
    elseif ($this.Col -eq $GameSquareLength-1) {$this.Neighbours = ($Location-$GameSquareLength),($Location+$GameSquareLength),($Location-1),($Location-$GameSquareLength-1),($Location+$GameSquareLength-1)}
    else {$this.Neighbours = ($Location+1),($Location-1),($Location-$GameSquareLength),($Location+$GameSquareLength),($Location-$GameSquareLength-1),($Location-$GameSquareLength+1),($Location+$GameSquareLength-1),($Location+$GameSquareLength+1)}
  }
}
function Test-NextLifeState {
  Param ([GOLCell[]]$Cells)
  foreach ($Cell in $Cells) {
    $NeighbourCells = $Cells[$Cell.Neighbours]
    $AliveNeighbourCount = ($NeighbourCells | Where-Object {$_.CurrentState -eq $true}).Count
    if ($Cell.CurrentState -eq $true) {
      $Cell.DisplayChar = '#'
      if ($AliveNeighbourCount -lt 2) {$Cell.NextGenState = $false}
      elseif ($AliveNeighbourCount -in (2,3) ) {$Cell.NextGenState = $true} 
      elseif ($AliveNeighbourCount -gt 3) {$Cell.NextGenState = $false}
    }
    if ($Cell.CurrentState -eq $false) {
      $Cell.DisplayChar = '.'
      if ($AliveNeighbourCount -eq 3) {$Cell.NextGenState = $true}
    }
  }
}

function Set-NewCurrentState {
  Param ([GOLCell[]]$Cells)
  foreach ($Cell in $Cells) {
    if ($Cell.NextGenState -eq $true) {
      $Cell.CurrentState = $true
      $Cell.DisplayChar = '#'
    }
    else {
      $Cell.CurrentState = $false
      $Cell.DisplayChar = '.'
    }
  }

}
function Show-Game {
  Param (
    [GOLCell[]]$Cells,$Length
  )
  $Host.UI.RawUI.CursorPosition = @{ X = 0; Y = 0 }
  foreach ($Row in (0..($Length-1))) {
    foreach ($Col in (0..($Length-1)))  {
      if ($Cells[($Col+($Row*$Length))].CurrentState -eq $false) {$Color = 'DarkGray'}
      else {$Color = 'Yellow'}
      Write-Host -NoNewline -ForegroundColor $Color $Cells[($Col+($Row*$Length))].DisplayChar' '
    }
    Write-Host
  }  
  $AliveCount = ($Cells|Where-Object {$_.CurrentState -eq $true}).count
  Write-Host -ForegroundColor Cyan "Alive -"$AliveCount"    "
}

# Setup Game
Clear-Host
$Game = foreach ($Pos in 0..($GameSize*$GameSize-1)) {
  [GOLCell]::New($Pos,$GameSize)
}
# Play game
do {
  $BeforeTurnCount = ($Game | Where-Object {$_.CurrentState -eq $true}).Count 
  Show-Game -Cells $Game -Length $GameSize 
  Test-NextLifeState -Cells $Game
  Set-NewCurrentState -Cells $Game
  Start-Sleep -Milliseconds 100
  $AfterTurnCount = ($Game | Where-Object {$_.CurrentState -eq $true}).Count 
  if ($AfterTurnCount -eq $BeforeTurnCount) {$Same++}
  else {$Same=0}
} until ($Same -eq 5)
