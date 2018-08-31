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
Param ()

Class PlayingCard {
  # NOTE: the original order will be (Clubs, Diamonds, Hearts, Spades) going on the Alphabetic sort that seems standard
  # Class: This is the properties of the PlayingCard Class
  [int]$CardIndex
  [int]$CardValue
  [string]$CardFace
  [string]$CardSuitName
  [string]$CardSuitColor
  
  #Class Constructor: This is the code that runs every time the script creates a new PlayingCard object
  PlayingCard ([int]$CardIndex) {
    [string[]]$SuitNames = @('Clubs','Diamonds','Hearts','Spades')
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

  } # Playingcard constructor
} # Class PlayingCard

function New-Card {
  Param (
    $Index
  )
  [PlayingCard]::New($Index)
} # function New Card


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

[PlayingCard[]]$Deck = @()
foreach ($CardSpot in (0..51)) {
  $deck += New-Card -Index $CardSpot
}
$deck | Format-Table -AutoSize