<# 
  New version of game of life
  Rules
  -----
  Any living cell with fewer that two neighbours  - DIES
  Any living cell with two or three neighbours    - LIVES 
  Any living cell with more than three neighbours - DIES
  Any   dead cell with exactly tree neighbours    - LIVES
#>  

function New-GridObject {
  Param(
    $GridSize,
    $LastGridPos
  )
  foreach ($Pos in (0..$LastGridPos)) {
    $GridProperties = @{
      Value = '+'
      Pos = $Pos
      Row = [math]::Truncate($Pos/$GridSize)
      Col = $Pos%$GridSize
    }
    New-Object -TypeName psobject -Property $GridProperties
  }
}
function Show-Grid {
  Param (
    [int]$GridSize,
    [int]$LastGridPos,
    $Grid
  )
  Clear-Host
  $LastGridCol = $GridSize - 1
  Foreach ($Pos in (0..$LastGridPos)) {
    if ($Grid[$Pos].Value -eq '+') {$FColor = "DarkGray"}
    else {$FColor = 'Cyan'}
    Write-Host -NoNewline -ForegroundColor $FColor $Grid[$Pos].Value
    if (($Pos % $GridSize) -eq $LastGridCol) {
      Write-Host
    }
    else {
      Write-Host -NoNewline '  '
    }
  }
}

function Next-LifeCycle {
  Param(
    $Grid,
    $GridSize
  )
  
  $LastColOrRow = $GridSize - 1
  foreach ($GridPos in $Grid) {
    $Skip = @()
    $NeighbourArray = @()
    $RealNeighbours = @()
    $ColBefore = $GridPos.Col - 1
    $RowBefore = $GridPos.Row - 1
    $ColAfter  = $GridPos.Col + 1
    $RowAfter  = $GridPos.Row + 1
    $NeighbourArray += (($GridPos.Pos)-($GridSize + 1)),($GridPos.pos - $GridSize),(($GridPos.Pos)-($GridSize - 1))
    $NeighbourArray += ($GridPos.Pos - 1),($GridPos.Pos + 1)
    $NeighbourArray += (($GridPos.Pos)+($GridSize - 1)),($GridPos.pos + $GridSize),(($GridPos.Pos)+($GridSize + 1))
    $NeighbourArray = $NeighbourArray | Sort-Object | Select-Object -Unique
    if ($ColBefore -lt 0) {$Skip += @(0,3,5)}
    if ($RowBefore -lt 0) {$Skip += @(0,1,2)}
    if ($ColAfter -gt $LastColOrRow) {$Skip += @(2,4,7)}
    if ($RowAfter -gt $LastColOrRow) {$Skip += @(5,6,7)}
    $Skip = $Skip | Sort-Object | Select-Object -Unique
    if ($Skip.count -gt 1) {$NeighbourPos = (Compare-Object (0..7) $Skip).InputObject}
    else {$NeighbourPos = $Skip}
    foreach ($Pos in $NeighbourPos) {
      $RealNeighbours += $NeighbourArray[$Pos]
    }
    $DirectLiveNeighbourCount =($Grid[$RealNeighbours] | Where-Object value -eq '@' | Measure-Object ).count
    if ($GridPos.value -ne '@') {
      if ($DirectLiveNeighbourCount -eq 3) {
        $NextGridProp = @{
          Value = '@'
          Pos = $GridPos.Pos
          Row = $GridPos.Row
          Col = $GridPos.Col
        }
      }
      else {
        $NextGridProp = @{
          Value = '+'
          Pos = $GridPos.Pos
          Row = $GridPos.Row
          Col = $GridPos.Col
        }
      }
    }
    else {
      if ($DirectLiveNeighbourCount -lt 2 -or $DirectLiveNeighbourCount -gt 3) {
        $NextGridProp = @{
          Value = '+'
          Pos = $GridPos.Pos
          Row = $GridPos.Row
          Col = $GridPos.Col
        }
      }
      elseif ($DirectLiveNeighbourCount -eq 2 -or $DirectLiveNeighbourCount -eq 3) {
        $NextGridProp = @{
          Value = '@'
          Pos = $GridPos.Pos
          Row = $GridPos.Row
          Col = $GridPos.Col
        }
      }
    }
    New-Object -TypeName psobject -Property $NextGridProp
  }#foreach $gridpos
}

# MAIN CODE
[string[]]$GridArray = @()
$GridSize = 10
$LastGridPos = ($GridSize * $GridSize) - 1
$GridObj = New-GridObject -GridSize $GridSize -LastGridPos $LastGridPos
foreach ($startPos in (1,10,11,18,19,29,35,36,44,46,54,55,56,95,99)) {$GridObj[$startPos].Value = '@'}
Show-Grid -GridSize $GridSize -LastGridPos $LastGridPos -Grid $GridObj
do {
  $GridObj = (Next-LifeCycle -Grid $GridObj -GridSize $GridSize).psobject.copy()
  Show-Grid -GridSize $GridSize -LastGridPos $LastGridPos -Grid $GridObj
} While ($true)
