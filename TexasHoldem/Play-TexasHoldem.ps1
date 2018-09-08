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

  Player ([int]$Number,[playingcard]$Card) {
    $this.PlayerNumber = $Number
    $this.CardsInHand = $Card
    $this.Kitty = 1000
  }
}
### Main Code ###
#################

<#
Classes allow the main code to be much smaller and more effiecient as a lot of
the code is stored in the class, this means when we instantiate a new object
based on this class, the class constructor code will run, and in this case it
takes an index value and from that derives the card face, card suit, card value
and card color... So all we have to do is call the New() method to create a new
object using this class and constructor
#>

function New-Card {
  Param (
    $Index
  )
  [PlayingCard]::New($Index)
} # function New Card

function New-Player {
  Param ([int]$PlayerNumber,[PlayingCard]$Card)
  [Player]::New($PlayerNumber,$Card)
}

[PlayingCard[]]$Deck = @()
[Player[]]$Players = @()

foreach ($CardSpot in (0..51)) {
  $deck += New-Card -Index $CardSpot
}
# Sorts in a random order or in other words, shuffles the objects
$ShuffleDeck = $Deck | Sort-Object {Get-Random}
$ShuffleDeck | Format-Table -AutoSize
foreach ($PlayerNum in (0..($NumberOfPlayers - 1))) {
  $CurrentPlayer += New-Player -PlayerNumber $PlayerNum -Card $Deck[$PlayerNum]
  $SecCardPos = $PlayerNum+$NumberOfPlayers
  $CurrentPlayer.CardsInHand += $Deck[$SecCardPos]
  $Players += $CurrentPlayer
}
$Players