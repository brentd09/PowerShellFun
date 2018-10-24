<#
.SYNOPSIS
  Demonstrate Classes and Constructors
.DESCRIPTION
  This script has a class definition with a class constructor so that when ever the class is used to create a 
  new object and an index is injected. The playingcard constructor will build the values in the other properties
  listed in the constructor code.
.EXAMPLE
  Play-TexasHoldem
.NOTES
  General notes
    Created by: Brent Denny
    Created on: 31-Aug-2018
#>
[CmdletBinding()]
Param (
  [parameter(Mandatory=$true)]
  [int]$NumberOfPlayers 
)

Class PlayingCard {
  # NOTE: the original order will be (Clubs, Diamonds, Hearts, Spades) going on the Alphabetic sort that seems standard
  # Class: This is the properties of the PlayingCard Class
  [int]$CardIndex
  [int]$CardValue
  [string]$CardFace
  [string]$CardSuitName
  [string]$CardSuitColor
  [string]$CardSuitIcon
  #Class Constructor: This is the code that runs every time the script creates a new PlayingCard object
  PlayingCard ([int]$CardIndex) {
    [string[]]$SuitNames = @('Clubs','Diamonds','Hearts','Spades')
    [int[]]$SuitIconChar = @(9827,9830,9829,9824)
    [string[]]$SuitColors = @('Black','DarkRed','DarkRed','Black')
    [int]$SuitIndex = [math]::Truncate($CardIndex/13)
    [int]$Value = ($CardIndex % 13) + 1
    # Construct the object based on the card index 0..51
    $this.CardIndex = $CardIndex
    $this.CardValue = $Value
    if ($Value -eq 1 ) {
      $this.CardFace = "A"
    }
    elseif ($Value -lt 11 ) {
      $this.CardFace = "$Value"
    }
    elseif ($Value -eq 11) {
      $this.CardFace = "J"
    }
    elseif ($Value -eq 12) {
      $this.CardFace = "Q"
    }
    elseif ($Value -eq 13) {
      $this.CardFace = "K"
    }
    $this.CardSuitName = $SuitNames[$SuitIndex]
    $this.CardSuitColor = $SuitColors[$SuitIndex]
    $this.CardSuitIcon = [char]($SuitIconChar[$SuitIndex])
  } # Playingcard constructor
} # Class PlayingCard


Class Player {
  [int]$PlayerNumber
  [int]$Kitty
  [playingcard[]]$CardsInHand
  [string]$Result
  [string]$Reason

  Player ([int]$Number,[playingcard[]]$Card) {
    $this.PlayerNumber = $Number
    $this.CardsInHand = $Card
    $this.Kitty = 1000
    $this.Result = ''
    $this.Reason = ''
  }
}

<#
Classes allow the main code to be much smaller and more effiecient as a lot of
the code is stored in the class, this means when we instantiate a new object
based on this class, the class constructor code will run, and in this case it
takes an index value and from that derives the card face, card suit, card value
and card color... So all we have to do is call the New() method to create a new
object using this class and constructor
#>



# Functions #
function Check-PokerHand {
  Param (
    [parameter(Mandatory=$true)]
    [PlayingCard[]]$PokerHand
  )
  # check for straight
  [int[]]$Found = @()
  foreach ($EndVal in (13..5)) {
    if ($EndVal -eq 13 -and $PokerHand.Value -contains 1) {
      $Range = 1,10,11,12,13
      $Found = $Range | Where-Object {$_ -in ($PokerHand.Value | Select-Object -Unique | Sort-Object)}
    }
    if ($Found.count -ne 5) {
      $Range = ($EndVal-4)..$EndVal
      $Found = $Range | Where-Object {$_ -in ($PokerHand.Value | Select-Object -Unique | Sort-Object)}
    }
    else {
      $Range
      break
    }
  }
}
function New-Card {
  Param (
    $Index
  )
  [PlayingCard]::New($Index)
} # fn New Card
function New-Player {
  Param ([int]$PlayerNumber,[PlayingCard[]]$Card)
  [Player]::New($PlayerNumber,$Card)
} #fn New Player
function Show-PlayersHands {
  Param (
    [Player[]]$PlayersHands
  )
  Write-Host -ForegroundColor Green -BackgroundColor Black "   TEXAS HOLD'EM   `n"
  foreach ($EachPlayer in $PlayersHands) {
    if (($EachPlayer.PlayerNumber + 1) -lt 10) {$Gap = ' '}
    else {$Gap = ''}
    Write-Host -NoNewline -ForegroundColor Black -BackgroundColor Yellow "Player $Gap$($EachPlayer.PlayerNumber + 1)"
    if ($EachPlayer.Result -ne '') {Write-Host -NoNewline -ForegroundColor Yellow "  $($EachPlayer.Result)  $($EachPlayer.Reason)"}
    else {}
    foreach ($Card in $EachPlayer.CardsInHand) {
      if ($Card.CardValue -eq 10) {$Spc = ''}
      else {$Spc = ' '}
      Write-Host -NoNewline '  '
      Write-Host -NoNewline -BackgroundColor White -ForegroundColor $Card.CardSuitColor "$Spc$($Card.CardFace)$($Card.CardSuitIcon) "
    }
    Write-Host
    Write-Host
  }
}
function Show-CommunityCards {
  Param (
    [int]$EndIndex,
    [PlayingCard[]]$CommCards
  )
  write-host -ForegroundColor Yellow '-------------------------------------------------'
  Write-Host -NoNewline -BackgroundColor Red -ForegroundColor White "Community Cards"
  foreach ($CommCardPos in (0..$EndIndex)) {
    if ($CommCards[$CommCardPos].CardValue -eq 10) {$Spc = ''}
    else {$Spc = ' '}
    if ($CommCardPos -eq 3) {
      Start-Sleep 3
      #Write-Host -NoNewline -BackgroundColor Red -ForegroundColor White "The Turn"
    }
    if ($CommCardPos -eq 4) {
      Start-Sleep 3
      #Write-Host -NoNewline -BackgroundColor Red -ForegroundColor White "The River"
    }
    Write-Host -NoNewline '  '
    Write-Host -NoNewline -BackgroundColor White -ForegroundColor $CommCards[$CommCardPos].CardSuitColor "$Spc$($CommCards[$CommCardPos].CardFace)$($CommCards[$CommCardPos].CardSuitIcon) "
    Write-Host -NoNewline ' '
  }
}
function Get-ShuffledDeck {
  [PlayingCard[]]$Deck = @()
  foreach ($CardSpot in (0..51)) {
    $deck += New-Card -Index $CardSpot
  }
  # Sorts in a random order or in other words, shuffles the objects
  $Deck | Sort-Object {Get-Random}
}

# # # # # Main Code # # # # # #
[Player[]]$Players=@()
[PlayingCard[]]$ShuffleDeck = Get-ShuffledDeck
$NumberOfPlayersIndex = $NumberOfPlayers - 1
foreach ($PlayerNum in (0..$NumberOfPlayersIndex)) {
  $Players += New-Player -PlayerNumber $PlayerNum -Card @($ShuffleDeck[$PlayerNum],$ShuffleDeck[$PlayerNum+$NumberOfPlayers] )
}
$DeadCard = ($NumberOfPlayers * 2 )
[PlayingCard[]]$CommunityCards = $ShuffleDeck[$DeadCard+1],
                                 $ShuffleDeck[$DeadCard+2],
                                 $ShuffleDeck[$DeadCard+3],
                                 $ShuffleDeck[$DeadCard+5],
                                 $ShuffleDeck[$DeadCard+7]

foreach ($WhatToDisplay in (2,3,4)) {
  Clear-Host
  Show-PlayersHands -PlayersHands $Players
  if ($WhatToDisplay -eq 2) {Start-Sleep 3}
  Show-CommunityCards -EndIndex $WhatToDisplay -CommCards $CommunityCards
}
<#
 $Players[0].CardsInHand + $CommunityCards (this combines the hole cards and community cards)

Poker Hands in order
--------------------
Royal Flush
Straight Flush
Four of a Kind
Full House
Flush
Straight
Three of a Kind
Two Pairs
Single Pair
High Card

Tie Breaker Rules of Poker Cash Game - Poker Rules
-------------------------------------------------- 
Know the detailed Tie Breaker Rules of Poker Cash Game.
------------------------------------------------------
RANKING	RANK-CARD(S)	KICKER-CARD(S)	TIE BREAKERS
ROYAL FLUSH	Royal Flush Cards	NA	
  An ace-high Straight flush is called Royal flush. 
  A Royal Flush is the highest hand in poker. 
  Between two Royal flushes, there can be no tie breaker. If two players have Royal Flushes, they split the pot. 
  The odds of this happening though are very rare and almost impossible in texas holdem because board requires 
  three cards of one suit for anyone to have a flush in that suit.
STRAIGHT FLUSH	Top Card	NA	
  Straight flushes come in varying strengths from five high to a king high. A King High Straight Flush loses only to a Royal. 
  If more than one player has a Straight Flush, the winner is the player with the highest card used in the Straight. 
  A queen high Straight Flush beats a jack high and a jack high beats a ten high and so on. 
  The suit never comes into play i.e. a seven High Straight Flush of Diamonds will split the pot with a seven high Straight Flush of hearts.
FOUR OF A KIND	Four of a Kind Card	Remaining 1	
  This one is simple. Four Aces beats any other four of a kind, four Kings beats four queens or less and so on. The only tricky part of a tie 
  breaker with four of a kind is when the four falls on the table in a game of Texas Holdem and is therefore shared between two (or more) players. 
  A kicker can be used, however if the fifth community card is higher than any card held by any player still in the hand, then the 
  hand is considered a tie and the pot is split.
FULL HOUSE	Trips & Pair Card	NA	
  When two or more players have full houses, we look first at the strength of the three of a kind to determine the winner. 
  For example, Aces full of deuces (AAA22) beats Kings full of Jacks (KKKJJ). If there are three of a kind on the table (community cards) in a 
  Texas Holdem game that are used by two or more players to make a full house, then we would look at the strength of the pair to determine a winner.
FLUSH	Flush Cards	NA	A flush is any hand with five cards of the same suit. 
  If two or more players hold a flush, the flush with the highest card wins. If more than one player has the same strength high card, 
  then the strength of the second highest card held wins. This continues through the five highest cards in the player's hands.
STRAIGHT	Top Card	NA	A straight is any five cards in sequence, but not necessarily of the same suit. 
  If more than one player has a straight, the straight ending in the card wins. If both straights end in a card of the same strength, the hand is tied.
THREE OF A KIND	Trips Card	Remaining 2	
  If more than one player holds three of a kind, then the higher value of the cards used to make the three of kind determines the winner. 
  If two or more players have the same three of a kind, then a fourth card (and a fifth if necessary) can be used as kickers to determine the winner.
TWO PAIR	1st & 2nd Pair Card	Remaining 1	
  The highest pair is used to determine the winner. If two or more players have the same highest pair, then the highest of the second pair determines the winner. 
  If both players hold identical two pairs, fifth card is used to break the tie.
ONE PAIR	Pair Card	Remaining 3	
  If two or more players hold a single pair, then highest pair wins. If the pairs are of the same value, the highest kicker card determines the winner. 
  A second and even third kicker can be used if necessary.
HIGH CARD	Top Card	Remaining 4	
  When no player has even a pair, then the highest card wins. When both players have identical high cards, the next highest card wins, 
  and so on until five cards have been used. In the unusual circumstance that two players hold the identical five cards, the pot would be split.
#>
