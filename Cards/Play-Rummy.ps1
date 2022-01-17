Class PlayingCard {
  [int]$RankValue
  [string]$Rank
  [string]$Suit
  [string]$Color
  [int]$ScoreValue

  PlayingCard ([string]$FaceRank, [int]$FaceValue, [string]$FaceSuit, [string]$FaceColor, [int]$ScoreVal) {
    $this.Rank       = $FaceRank
    $this.RankValue  = $FaceValue
    $this.Suit       = $FaceSuit
    $this.Color      = $FaceColor
    $this.ScoreValue = $ScoreVal
  }

  [void]SetScoreVal ([int]$Value) {
    $this.ScoreValue = $Value
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
         1 { $RankString = 'A'; $ScoreVal = 15 }
        11 { $RankString = 'J'; $ScoreVal = 10 }
        12 { $RankString = 'Q'; $ScoreVal = 10 }
        13 { $RankString = 'K'; $ScoreVal = 10 }
        Default {$RankString = $Rank -as [string]; $ScoreVal = 5}
      }
      $Card = [PlayingCard]::New($RankString,$Rank,$Suit,$Color,$ScoreVal)
      $Card
    }
  }
}

Class PlayingDeck {
  [System.Collections.ArrayList]$Cards

  PlayingDeck () {
    function New-CardPack {
      [int[]]$SuitASCIINumbers = @(9824,9827,9829,9830)
      $RankNumbers = 1..13
      foreach ($SuitASCIINumber in $SuitASCIINumbers) {
        if ($SuitASCIINumber -in  @(9824,9827) ) {$Color = 'Black'}
        else {$Color = 'Red'}
        $Suit = [char]$SuitASCIINumber
        foreach ($Rank in $RankNumbers) {
          switch ($Rank) {
             1 { $RankString = 'A'; $ScoreVal = 15 }
            11 { $RankString = 'J'; $ScoreVal = 10 }
            12 { $RankString = 'Q'; $ScoreVal = 10 }
            13 { $RankString = 'K'; $ScoreVal = 10 }
            Default {$RankString = $Rank -as [string]; $ScoreVal = 5}
          }
          $Card = [PlayingCard]::New($RankString,$Rank,$Suit,$Color)
          $Card.SetScoreVal($ScoreVal)
          $Card
        }
      }
    }
    $this.Cards = New-CardPack
  }

  [void]ShuffleDeck () {
    $this.Cards = $this.Cards | Sort-Object {Get-Random}
  }

  [PlayingCard]DealFromDeck () {
    $Dealt = $this.Cards[0]
    $this.Cards.RemoveAt(0)
    return $Dealt
  }
}


### Main Code

$Deck = [PlayingDeck]::New()
$Deck.ShuffleDeck()
$Deck.DealFromDeck()
$Deck.Cards