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
#>