Class PlayingCard {
  [int]$RankValue
  [string]$Rank
  [string]$Suit
  [string]$Color

  PlayingCard ([string]$FaceRank, [int]$FaceValue, [string]$FaceSuit, [string]$FaceColor) {
    $this.Rank      = $FaceRank
    $this.RankValue = $FaceValue
    $this.Suit      = $FaceSuit
    $this.Color     = $FaceColor 
  }
}

function New-CardPack {
  [int[]]$SuitASCIINumbers = @(9824,9827,9829,9830)
  $RankNumbers = 1..13
  foreach ($SuitASCIINumber in $SuitASCIINumbers) {
    if ($SuitASCIINumber -in  @(9824,9827) ) {$Color = 'Black'}
    else {$Color = 'Red'}
    $Suit = [char]$SuitASCIINumber
    foreach ($Rank in $RankNumbers) {
      switch ($Rank) {
         1 { $RankString = 'A' }
        11 { $RankString = 'J' }
        12 { $RankString = 'Q' }
        13 { $RankString = 'K' }
        Default {$RankString = $Rank -as [string]}
      }
      [PlayingCard]::New($RankString,$Rank,$Suit,$Color)
    }
  }
}
function Show-Card {
  Param ([PlayingCard]$Card)
  if ($Card.Rank -eq 10) {$Spc = ' '}
  else {$Spc = '  '}
  Write-Host -ForegroundColor $Card.Color -BackgroundColor white "$Spc$($Card.Rank + ' ' + $Card.Suit)  "
}

function Show-PlayerHand {
  Param (
    $PlayerName,
    $PlayerCards
  )
}

function Invoke-DealCard {
  Param (
    $Cards,
    $CardIndex = 0
  )
  $DealtCard = $Cards[$CardIndex]
  $Cards.RemoveAt($CardIndex)
  return $DealtCard
}

### Main Code

[System.Collections.ArrayList]$PlayingCards = New-CardPack
[System.Collections.ArrayList]$ShuffledCards = $PlayingCards | Sort-Object {Get-Random} | Sort-Object {Get-Random}
$ShuffledCards | ForEach-Object {Show-Card -Card $_}
[PlayingCard[]]$Player1 = @()
$Player1 += Invoke-DealCard -Cards $ShuffledCards
$Player1
