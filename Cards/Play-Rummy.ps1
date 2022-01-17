Class PlayingCard {
  [int]$RankValue
  [string]$Rank
  [string]$Suit
  [string]$SuitName
  [string]$Color
  [int]$ScoreValue

  PlayingCard ([string]$FaceRank, [int]$FaceValue, [string]$FaceSuit, [string]$SuitName, [string]$FaceColor, [int]$ScoreVal) {
    $this.Rank       = $FaceRank
    $this.RankValue  = $FaceValue
    $this.Suit       = $FaceSuit
    $this.SuitName   = $SuitName
    $this.Color      = $FaceColor
    $this.ScoreValue = $ScoreVal
  }

  [void]SetScoreVal ([int]$Value) {
    $this.ScoreValue = $Value
  }

}

Class PlayingDeck {
  [System.Collections.ArrayList]$Cards

  PlayingDeck () {
    function New-CardPack {
      [int[]]$SuitASCIINumbers = @(9824,9827,9829,9830)
      $RankNumbers = 1..13
      foreach ($SuitASCIINumber in $SuitASCIINumbers) {
        if ($SuitASCIINumber -eq  9824) {$Color = 'Black';$SuitName = 'Spades'}
        elseif ($SuitASCIINumber -eq  9827) {$Color = 'Black';$SuitName = 'Clubs'}
        elseif ($SuitASCIINumber -eq  9829) {$Color = 'Red';$SuitName = 'Hearts'}
        elseif ($SuitASCIINumber -eq  9830) {$Color = 'Red';$SuitName='Diamonds'}
        $Suit = [char]$SuitASCIINumber
        foreach ($Rank in $RankNumbers) {
          switch ($Rank) {
             1 { $RankString = 'A'; $ScoreVal = 15 }
            11 { $RankString = 'J'; $ScoreVal = 10 }
            12 { $RankString = 'Q'; $ScoreVal = 10 }
            13 { $RankString = 'K'; $ScoreVal = 10 }
            Default {$RankString = $Rank -as [string]; $ScoreVal = 5}
          }
          $Card = [PlayingCard]::New($RankString,$Rank,$Suit,$SuitName,$Color,$ScoreVal)
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
[System.Collections.ArrayList]$Player1 = @()
[System.Collections.ArrayList]$Player2 = @()
$Deck = [PlayingDeck]::New()
$Deck.ShuffleDeck()

#Initial Deal
0..6 | ForEach-Object {
  $Player1 += $Deck.DealFromDeck()
  $Player2 += $Deck.DealFromDeck()
}
$Player1 | ft
Write-Output '---------------------'
$Player2 | ft
$Deck.Cards