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
    [string[]]$SuitColors = @('Black','Red','Red','Black')
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


# Main Code #

[PlayingCard[]]$Deck = @()
[Player[]]$Players=@()

foreach ($CardSpot in (0..51)) {
  $deck += New-Card -Index $CardSpot
}
# Sorts in a random order or in other words, shuffles the objects
$ShuffleDeck = $Deck | Sort-Object {Get-Random}
$NumberOfPlayersIndex = $NumberOfPlayers - 1
foreach ($PlayerNum in (0..$NumberOfPlayersIndex)) {
  $Players += New-Player -PlayerNumber $PlayerNum -Card @($ShuffleDeck[$PlayerNum],$ShuffleDeck[$PlayerNum+$NumberOfPlayers] )
}
$DeadCard = ($NumberOfPlayers * 2 )
[PlayingCard[]]$CommunityCards = $ShuffleDeck[$DeadCard+1],$ShuffleDeck[$DeadCard+2],$ShuffleDeck[$DeadCard+3],$ShuffleDeck[$DeadCard+5],$ShuffleDeck[$DeadCard+7]

Clear-Host
foreach ($EachPlayer in $Players) {
  Write-Host -NoNewline -ForegroundColor Black -BackgroundColor Yellow "Player $($EachPlayer.PlayerNumber + 1)"
  if ($EachPlayer.Result -ne '') {Write-Host -ForegroundColor Yellow "  $($EachPlayer.Result)  $($EachPlayer.Reason)"}
  else {Write-Host}
  foreach ($Card in $EachPlayer.CardsInHand) {
    if ($Card.CardValue -eq 10) {$Spc = ''}
    else {$Spc = ' '}
    Write-Host -NoNewline '  '
    Write-Host -BackgroundColor White -ForegroundColor $Card.CardSuitColor "$Spc$($Card.CardFace)$($Card.CardSuitIcon)"
  }
  Write-Host
}
Write-Host -BackgroundColor Red -ForegroundColor White "The CommunityCards"
$count = 0
foreach ($CommCard in $CommunityCards) {
  $count++
  if ($CommCard.CardValue -eq 10) {$Spc = ''}
  else {$Spc = ' '}
  if ($count -eq 4) {Write-Host -BackgroundColor Red -ForegroundColor White "The Turn"}
  if ($count -eq 5) {Write-Host -BackgroundColor Red -ForegroundColor White "The River"}
  Write-Host -NoNewline '  '
  Write-Host -BackgroundColor White -ForegroundColor $CommCard.CardSuitColor "$Spc$($CommCard.CardFace)$($CommCard.CardSuitIcon)"
  if ($count -ge 3) {start-sleep -Seconds 3}
}

<#
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