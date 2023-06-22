$Grid = @(
  @(' ',' ',' ',' ',' ',' ',' ',' '),
  @(' ',' ',' ',' ',' ',' ',' ',' '),
  @(' ',' ',' ',' ',' ',' ',' ',' '),
  @(' ',' ',' ','X','O',' ',' ',' '),
  @(' ',' ',' ','O','X',' ',' ',' '),
  @(' ',' ',' ',' ',' ',' ',' ',' '),
  @(' ',' ',' ',' ',' ',' ',' ',' '),
  @(' ',' ',' ',' ',' ',' ',' ',' ')
)

# Functions
function Show-Grid {
  Param ($Grid)

  Write-Host "   A B C D E F G H"
  foreach ($Row in @(0..7)) {
    Write-Host "$($Row+1)  " -NoNewline
    foreach ($Col in @(0..7)) {
      if ($Grid[$Row][$Col] -in @('X','O')) {Write-Host "$($Grid[$Row][$Col]) " -NoNewline}
      else {Write-Host ". " -NoNewline}
    }
    Write-Host
  }
  Write-Host
}

function Find-Neighbours {
  Param (
    $Grid,
    [int]$Row,
    [int]$Col
  )
  [System.Collections.ArrayList]$Neighbours = @()
  if (($Row - 1) -ge 0) { 
    foreach ($c in @(-1,0,1)){
      if (($Col + $c) -ge 0 -and ($Col + $c) -le 7) {
        $Neighbours.add(@(($Row - 1), ($Col + $c))) | Out-Null
      }
    }
  }
  foreach ($c in @(-1,1)){
    if (($Col + $c) -ge 0 -and ($Col + $c) -le 7) {
      $Neighbours.add(@(($Row), ($Col + $c))) | Out-Null
    }
  }
  if (($Row + 1) -ge 0) { 
    foreach ($c in @(-1,0,1)){
      if (($Col + $c) -ge 0 -and ($Col + $c) -le 7) {
        $Neighbours.add(@(($Row + 1), ($Col + $c))) | Out-Null
      }
    }
  }  
  return $Neighbours
}

function Find-LegalMoves {
  Param (
    $Grid,
    $Player
  )
  foreach ($Row in @(0..7)) {
    foreach ($Col in @(0..7)) {
      if ($Grid[$Row][$Col] -in @('X','O')) {continue}
      $LegalNeighbours = Find-Neighbours -Grid $Grid -Row $Row -Col $Col
      foreach ($Neighbour in $LegalNeighbours) {
        if ($Grid[$Neighbour])
      }
    }
  }
}

# Main code
Clear-Host
$Player = 'X'
do {
  Show-Grid -Grid $Grid
  do {
    $Choice = Read-Host -Prompt "Player $Player, enter a coordinate to move"
    $ChoiceNumber = $Choice -replace '[^1-8]',''
    $ChoiceLetter = ($Choice -replace '[^a-z]','').ToUpper()

  } until ($ChoiceNumber -match '\d' -and $ChoiceLetter -match '[a-h]')
  [int]$RowIndex = $ChoiceNumber - 1
  [string]$ColIndex = ([int][char]$ChoiceLetter) - 65 
  Find-Neighbours -Grid $Grid -Row $RowIndex -Col $ColIndex
  

  
} until ($false)
