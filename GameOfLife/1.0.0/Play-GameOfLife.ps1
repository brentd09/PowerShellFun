
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

function Show-Grid {
  Param (
    [Element[,]]$FGrid
  )
  
  foreach ($Row in @(0..$MaxIndex)){
    foreach ($Col in @(0..$MaxIndex)) {
      if ($FGrid[$Row,$Col].Value -eq '#') {$Color = 'Yellow'} else {$Color = 'White'}
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

$MaxSize  = 20
$MaxIndex = $MaxSize - 1 


$Grid = [Element[,]]::New($MaxSize,$MaxSize)
foreach ($Row in @(0..$MaxIndex)){
  foreach ($Col in @(0..$MaxIndex)) {
    $CellValue = '.','.','.','.','#','#','#' | Get-Random
    $Grid[$Row,$Col] = [element]::New($CellValue,'*')
  }
}

do {
  Clear-Host
  [string]$GridPattern = $Grid.Value
  Show-Grid -FGrid $Grid
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
  Start-Sleep -Seconds 1
  [string]$PostGridPattern = $Grid.Value
} until ($GridPattern -eq $PostGridPattern)
