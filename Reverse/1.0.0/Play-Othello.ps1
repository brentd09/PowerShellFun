Class OthelloPosition {
  [string]$Value
  [int]$Index
  [int]$Row
  [int]$Col
  [int[]]$Neighbours

  OthelloPosition ($Index,$Val) {
    [int[]]$RelativeNeighbours = @()
    $this.Value = $Val
    $this.Row = [math]::Truncate($Index / 8)
    $this.Col = $Index % 8
    foreach ($pos in (0..7)) {
      $PossibleNeighbours = @(-9,-8,-7,-1,+1,+7,+8,+9)
      if ($Index -eq 0) {$RelativeNeighbours = $PossibleNeighbours[4,6,7]}
      elseif ($Index -eq 7) {$RelativeNeighbours = $PossibleNeighbours[3,5,6]}
      elseif ($Index -eq 56) {$RelativeNeighbours = $PossibleNeighbours[1,2,4]}
      elseif ($Index -eq 63) {$RelativeNeighbours = $PossibleNeighbours[0,1,3]}
      elseif ($Index -in @(8,16,24,32,40,48)) {$RelativeNeighbours = $PossibleNeighbours[1,2,4,6,7]}
      elseif ($Index -in @(15,23,31,39,47,55)) {$RelativeNeighbours = $PossibleNeighbours[0,1,3,5,6]}
      elseif ($Index -in @(1,2,3,4,5,6)) {$RelativeNeighbours = $PossibleNeighbours[3..7]}
      elseif ($Index -in @(57,58,59,60,61,62)) {$RelativeNeighbours = $PossibleNeighbours[0..4]}
      else {$RelativeNeighbours = $PossibleNeighbours} 
    }
    $this.Neighbours = foreach ($RelativeNeighbour in $RelativeNeighbours) {$Index + $RelativeNeighbour}
  }
}

Class OthelloBoard {
  [OthelloPosition[]]$Positions 

  OthelloBoard () {
    $this.Positions = foreach ($Indx in 0..63) {
      if ($Indx -in @(27,36)) {[OthelloPosition]::New($Indx,'X')}
      elseif ($Indx -in @(28,35)) {[OthelloPosition]::New($Indx,'O')}
      else  {[OthelloPosition]::New($Indx,'.')}
    }
  }

  ShowBoard () {
    $RowLabels = @('A','B','C','D','E','F','G','H')
    $RowNum = 0
    Write-Host -NoNewline -ForegroundColor Cyan "  1  2  3  4  5  6  7  8"
    foreach ($Pos in @(0..63)) {
      if (($Pos % 8) -eq 0) {
        Write-Host
        Write-Host -NoNewline -ForegroundColor Cyan "$($RowLabels[$RowNum])"
        $RowNum++
      }
      Write-Host -NoNewline " $($this.Positions[$Pos].Value) "
    }
    Write-Host
    Write-Host
  }
}

# Main Code

$Board = [OthelloBoard]::New()
do {
  $Board.ShowBoard()
  break
} Until ($true) #game over
