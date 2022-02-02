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
             1 { $RankString = 'A'; $ScoreVal = 11 }
            11 { $RankString = 'J'; $ScoreVal = 10 }
            12 { $RankString = 'Q'; $ScoreVal = 10 }
            13 { $RankString = 'K'; $ScoreVal = 10 }
            Default {$RankString = $Rank -as [string]; $ScoreVal = $Rank}
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

Class Hand {
  [PlayingCard[]]$Cards
  [int]$HandScore

  Hand () {
    $this.Cards = @()
    $this.HandScore = 0
  }

  [void]AddCard ([PlayingCard]$Card) {
    $this.Cards += $Card
    $Score = ($this.Cards.ScoreValue | Measure-Object -Sum).Sum
    while ($Score -gt 21) {
      if ($Score -gt 21) {
        foreach ($CardInHand in $this.Cards) {
          if ($CardInHand.RankValue -eq 1 -and $CardInHand.ScoreValue -eq 11) {
            $CardInHand.ScoreValue = 1
            $this.HandScore = $this.HandScore - 10
            $Score = ($this.Cards.ScoreValue | Measure-Object -Sum).Sum
            break
          } 
        }
      }
      break
    }
    $this.HandScore = $Score
  }
}

### Functions

function ShowCard {
  Param ([PlayingCard[]]$CardFn)
  foreach ($Card in $CardFn) {
    if ($Card.RankValue -eq 10 ) {$Spc = ''}
    else {$Spc = ' '}
    Write-Host -BackgroundColor White -ForegroundColor $Card.Color -NoNewline " $Spc$($Card.Rank) $($Card.Suit) "
    Write-Host ' ' -NoNewline
  }
}


### Main Code

$Deck = [PlayingDeck]::New()
$Deck.ShuffleDeck()
$PlayerHand = [Hand]::New()
$PlayerHand.AddCard($Deck.DealFromDeck())
do {
  $PlayerHand.AddCard($Deck.DealFromDeck())
  $PlayerHand.Cards | Format-Table -Property *,@{n='HandScore';e={$PlayerHand.HandScore}}
  if ($PlayerHand.HandScore -lt 21) {$Choice = Read-Host -Prompt "[ENTER] to hit, S to stand"}
} until ($PlayerHand.HandScore -ge 21 -or $Choice -like 's*')