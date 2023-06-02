<#
.SYNOPSIS
  Game of Life
.DESCRIPTION
  This simulates the game of life: Conway's GOL
  There are three rules:
  - A live position will remain living if it has two or three neighbours
  - An empty position will come to life if it has three neighbours
  - All other positions wil either die or remain empty if none of the previous rules apply 
.NOTES
  Created By:   Brent Denny
  Created On:   01-Jun-2023
  Last Edited:  02-Jun-2023
  
  Change History:
  Date         Details
  01-Jun-2023  Created the basics regarding the multi-dimentional array
  02-Jun-2023  Added the logic to test for neighbours and check next cycle states
               Added the method to change values based on NextState directives

.EXAMPLE
  Play-GameOfLife -MaxSize 15
  This will play out a game of life on a 15 x 15 size grid the game will continue 
  for six times the grid size or if it reaches a stable state where nothing changes
  
#>
[CmdletBinding()]
Param (
  [int]$MaxSize = 20
)


#Classes
class Element {
  [string]$Value
  [string]$NextState  

  Element($Value, $NextState) {
    $this.Value = $Value
    $this.NextState = $NextState
  }

  [void]CalcNextCycle () {
    if ($this.NextState -eq 'L') {$this.Value = '#'}
    else {$this.Value = '.'}
  }
}

# Functions
function Show-Grid {
  Param (
    [Element[,]]$FGrid
  )
  
  foreach ($Row in @(0..$MaxIndex)){
    foreach ($Col in @(0..$MaxIndex)) {
      if ($FGrid[$Row,$Col].Value -eq '#') {$Color = 'Cyan'} else {$Color = 'White'}
      Write-Host -ForegroundColor $Color -NoNewline $FGrid[$Row,$Col].Value
      Write-Host -NoNewline '  '
    }
    Write-Host
  }
}

function Find-Neighbour {
  Param (
    [Element[,]]$FGrid,
    [int]$Row,
    [int]$Col
  )
  [System.Collections.ArrayList]$RowColNeighbours = @()
  if ($Row - 1 -ge 0) {$RowColNeighbours.Add(@(($Row-1),$Col)) | Out-Null}
  if ($Col - 1 -ge 0) {$RowColNeighbours.Add(@($Row,($Col-1))) | Out-Null}
  if ($Row + 1 -le $Script:MaxIndex) {$RowColNeighbours.Add(@(($Row+1),$Col)) | Out-Null}
  if ($Col + 1 -le $Script:MaxIndex) {$RowColNeighbours.Add(@($Row,($Col+1))) | Out-Null}
  if ($Row - 1 -ge 0 -and $Col - 1 -ge 0) {$RowColNeighbours.Add(@(($Row-1),($Col-1))) | Out-Null}
  if ($Row - 1 -ge 0 -and $Col + 1 -le $Script:MaxIndex) {$RowColNeighbours.Add(@(($Row-1),($Col+1))) | Out-Null}
  if ($Row + 1 -le $Script:MaxIndex -and $Col - 1 -ge 0) {$RowColNeighbours.Add(@(($Row+1),($Col-1))) | Out-Null}
  if ($Row + 1 -le $Script:MaxIndex -and $Col + 1 -le $Script:MaxIndex) {$RowColNeighbours.Add(@(($Row+1),($Col+1))) | Out-Null}
  return $RowColNeighbours
}


## Main Code
$MaxIndex = $MaxSize - 1 
$TurnCount = 0
$MaxTurns = 6 * $MaxSize


$Grid = [Element[,]]::New($MaxSize,$MaxSize)
foreach ($Row in @(0..$MaxIndex)){
  foreach ($Col in @(0..$MaxIndex)) {
    $CellValue = '.','.','.','.','#','#','#' | Get-Random
    $Grid[$Row,$Col] = [element]::New($CellValue,'*')
  }
}
$TopOfScreen = [System.Management.Automation.Host.Coordinates]::New(0,0)
Clear-Host
do {
  $Host.UI.RawUI.CursorPosition = $TopOfScreen
  [string]$GridPattern = $Grid.Value
  Show-Grid -FGrid $Grid
  Write-Host 
  Write-Host "Count: $TurnCount"
  foreach ($Row in @(0..$MaxIndex)){
    foreach ($Col in @(0..$MaxIndex)) {
      $Nbours = Find-Neighbour -FGrid $Grid -Row $Row -Col $Col
      $NumberNeighbours = ($Grid[$Nbours] | Where-Object {$_.Value -eq '#'} ).Count
      if ($Grid[$Row,$Col].Value -eq '#' -and $NumberNeighbours -in @(2,3)) {$Grid[$Row,$Col].NextState = 'L'}
      elseif ($Grid[$Row,$Col].Value -eq '.' -and $NumberNeighbours -eq 3) {$Grid[$Row,$Col].NextState = 'L'}
      else {$Grid[$Row,$Col].NextState = 'D'}
    }
  }
  
  foreach ($Row in @(0..$MaxIndex)){
    foreach ($Col in @(0..$MaxIndex)) {
      $Grid[$Row,$Col].CalcNextCycle()
    }
  }
  #Start-Sleep -Milliseconds 100
  [string]$PostGridPattern = $Grid.Value
  $TurnCount++
} until ($GridPattern -eq $PostGridPattern -or $TurnCount -gt $MaxTurns)
