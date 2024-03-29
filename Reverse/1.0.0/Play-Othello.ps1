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

  [bool]PlayMove ($Pos,$Player) {
    if ($Player -eq 'X') {$Opponent = 'O'} else {$Opponent = 'X'}
    if ($this.Positions[$Pos].Value -in @('X','O') ) {
      return $false
    }
    foreach ($Neighbour in $this.Positions[$Pos].Neighbours){
      if ($this.Positions[$Neighbour].Value -eq $Opponent) { 
        # Possible legal move because opponent is a neighbour
        # check to see if the next neighbour in the same direction is the opponent or is players token
        # if another opponent token then do the previous step again for this position until we find a player token or not
        # if opponent are direct neighbour and then player token eventually - change all opponents to player tokens - legal move
        return $true
      }
    }
    return $false
  }
}

# Functions

function Get-NextMove {
  Param ($Player)
  do {
    $Choice = Read-Host -Prompt "Enter the coordinates of the next play for $Player"
    $Choice = $Choice.ToLower() -replace '[^a-h1-8]',''
    if ($Choice.Length -ne 2) {continue}
  } until ($Choice -match '[a-h][1-8]' -or $Choice -match '[1-8][a-h]')
  [int]$ChoiceCol = [byte][char]($Choice -replace '[0-9]','') - 97
  [int]$ChoiceRow = [int]($Choice -replace '[a-h]','') - 1
  $Pos = 8 * $ChoiceRow + $ChoiceCol
  Return $Pos
}

# Main Code
$Player = 'X'

$Board = [OthelloBoard]::New()
do {
  $Board.ShowBoard()
  do {
    $Pos = Get-NextMove -Player $Player
    $TestResult = $Board.PlayMove($Pos,$Player)
  } until ($TestResult -eq $true)
  break
  if ($Player -eq 'X') {$Player = 'O'} else {$Player = 'X'}
} Until ($true) #game over
