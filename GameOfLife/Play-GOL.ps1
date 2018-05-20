<#
  .SYNOPSIS
  This is another Game of life (Conway)
  .DESCRIPTION
    By adding live cells to the grid the rules dictate whether those cells live, die, or 
    reproduce.
    Rules
    -----
    Any living cell with fewer that two neighbours  - DIES
    Any living cell with two or three neighbours    - LIVES 
    Any living cell with more than three neighbours - DIES
    Any   dead cell with exactly tree neighbours    - LIVES
  .EXAMPLE
    Play-GOL -GridSize 10
    This creates a grid sized 10 x 10 to start the Game of Life
  .NOTES
    Created by Brent Denny on 18 May 2018
#>
[CmdletBinding()]
Param (
  [int]$GridSize = 10,
  [switch]$RandomLifeEvents 
)

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
  $Host.UI.RawUI.CursorPosition = @{ X = 0; Y = 0 }
  $LiteralSize = (($GridSize - 1) * 3 ) + 1
  $HeaderSpaces = ($LiteralSize / 2) - (20 / 2)
  Write-Host -NoNewline (" " * $HeaderSpaces)
  Write-Host -ForegroundColor Yellow "--THE GAME OF LIFE--`n"
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
    $RandomEvent = Get-Random -Minimum 0 -Maximum 10000
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
    if ($Skip) {$NeighbourPos = (Compare-Object (0..7) $Skip).InputObject}
    else {$NeighbourPos = 0..7}
    foreach ($Pos in $NeighbourPos) {
      $RealNeighbours += $NeighbourArray[$Pos]
    }
    $DirectLiveNeighbourCount =($Grid[$RealNeighbours] | Where-Object value -eq '@' | Measure-Object ).count
    if ($GridPos.value -ne '@') {
      if (($DirectLiveNeighbourCount -eq 3 -and $RandomLifeEvents -eq $false) -or ($DirectLiveNeighbourCount -eq 3 -and $RandomLifeEvents -eq $true -and $RandomEvent -gt 100) ) {
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
      if (($DirectLiveNeighbourCount -notin @(2,3) -and $RandomLifeEvents -eq $false) -or ($DirectLiveNeighbourCount -notin @(2,3) -and $RandomLifeEvents -eq $true -and $RandomEvent -gt 100)) {
        $NextGridProp = @{
          Value = '+'
          Pos = $GridPos.Pos
          Row = $GridPos.Row
          Col = $GridPos.Col
        }
      }
      elseif ($DirectLiveNeighbourCount -in @(2,3)) {
        $NextGridProp = @{
          Value = '@'
          Pos = $GridPos.Pos
          Row = $GridPos.Row
          Col = $GridPos.Col
        }
      }
      else {
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
$LastGridPos = ($GridSize * $GridSize) - 1
$GridObj = New-GridObject -GridSize $GridSize -LastGridPos $LastGridPos
foreach ($startPos in (11,31,42,43,44,45,35,25,14)) {$GridObj[$startPos].Value = '@'}
Clear-Host
Show-Grid -GridSize $GridSize -LastGridPos $LastGridPos -Grid $GridObj
do {
  $PrevLive = ($GridObj | Where-Object {$_.value -eq '@'}).Pos -join ''
  $GridObj = Next-LifeCycle -Grid $GridObj -GridSize $GridSize
  Show-Grid -GridSize $GridSize -LastGridPos $LastGridPos -Grid $GridObj
  $CurrentLive =  ($GridObj | Where-Object {$_.value -eq '@'}).Pos -join ''
  if ($PrevLive -eq $CurrentLive) {
    $SameGrid++
  }
  else {
    $SameGrid = 0
  }
} Until (($RandomLifeEvents -eq $false -and $SameGrid -eq 1) -or ($RandomLifeEvents -eq $true -and $SameGrid -eq 3))
Write-Host
if ($GridObj.Value -contains '@') {Write-Host -ForegroundColor Cyan "Stopped as the organisms in the grid are stable"}
if ($GridObj.Value -notcontains '@') {Write-Host -ForegroundColor Red "Stopped as the organisms in the grid all died"}
