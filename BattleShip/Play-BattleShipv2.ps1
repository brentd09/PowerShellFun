<#
.Synopsis
   Battleship Game
.DESCRIPTION
   The game will randomise positions for the ships for the player and the computer,
   you will be asked for your name and then whether you are happy with the placement
   of the ships. The comuter and the player take turns choosing an attack position and
   the game shows a H for hit or M for missed shot, first on to sink the opponents 
   ships is the winner.
   This game shows the players ships, and an attackboard above showing how successful
   the player has been at attacking the computer's ships,
   The game uses a large array of 100 elements like this
        Board Array for game
      0  1  2  3  4  5  6  7  8  9 
     10 11 12 13 14 15 16 17 18 19 
     20 21 22 23 24 25 26 27 28 29 
     30 31 32 33 34 35 36 37 38 39 
     40 41 42 43 44 45 46 47 48 49 
     50 51 52 53 54 55 56 57 58 59 
     60 61 62 63 64 65 66 67 68 69 
     70 71 72 73 74 75 76 77 78 79 
     80 81 82 83 84 85 86 87 88 89 
     90 91 92 93 94 95 96 97 98 99
   This game differs from the first version manily in the coding, in this version each
   position on the grid above references a complete object where the object properties
   are as follows
   Row  Col  Pos  Ship  ShipCol  Peg  PegCol  PegChosen  NSEW
   ---  ---  ---  ----  -------  ---  ------  ---------  ----
   
   the NSEW property deals with actual positions directly North South East and West of 
   the current position, this aids when searching for the next possible hit position.
.EXAMPLE
   BattleShipV2
.NOTES
   Created by: Brent Denny
   Created on: 12 Feb 2018
#>
function Init-Board {
  foreach ($Num in (0..99)) {
    $Nth      = $Num - 10;$Sth = $Num + 10;$Est = $Num + 1;$Wst = $num - 1
    $RowNum   = [System.Math]::Truncate( $Num / 10 )
    $ColNum   = $Num % 10
    $ShipChar = '-'
    $PegChar  = '-'
    # Determine NSEW from position corners only have two values, sides have three
    # and inner postions have four values
    if ($RowNum -in (1..8) -and $ColNum -in (1..8)) {$NSEW = @($Nth,$Sth,$Est,$Wst)}
    elseif ($RowNum -eq 0 -and $ColNum -eq 0) {$NSEW = @($Sth,$Est)}
    elseif ($RowNum -eq 0 -and $ColNum -eq 9) {$NSEW = @($Sth,$Wst)}
    elseif ($RowNum -eq 9 -and $ColNum -eq 0) {$NSEW = @($Nth,$Est)}
    elseif ($RowNum -eq 9 -and $ColNum -eq 9) {$NSEW = @($Nth,$Wst)}
    elseif ($RowNum -eq 0 -and $ColNum -in (1..8)) {$NSEW = @($Sth,$Est,$Wst)}
    elseif ($RowNum -eq 9 -and $ColNum -in (1..8)) {$NSEW = @($Nth,$Est,$Wst)}
    elseif ($RowNum -in (1..8) -and $ColNum -eq 0) {$NSEW = @($Nth,$Sth,$Est)}
    elseif ($RowNum -in (1..8) -and $ColNum -eq 9) {$NSEW = @($Nth,$Sth,$Wst)}
    [PSCustomObject][ordered]@{
      Row     = $RowNum
      Col     = $ColNum
      Pos     = $Num
      Ship    = $ShipChar
      ShipCol = "green"
      Peg     = $PegChar
      PegCol  = "White"
      PegChosen = $false
      NSEW    = $NSEW
    }
  }
}

function Display-Grid {
  Param (
    $Grid,
    [String]$WhosBoard,
    [switch]$Ships,
    [switch]$Key
  )
  # this will show the grid for computer or player, the KEY or LEGEND is optional and the 
  # function displays the peg board by default unless -ships are chosen at launch
  if ($Key -eq $true) {
  $KeyColor = "Cyan"

    Write-Host -ForegroundColor Yellow 'KEY:' 
    Write-Host -ForegroundColor $KeyColor 'SHIPS: '' A - Aircraft Carrier, B - Battleship, C - Cruiser, D - Destroyer, S - Submarine'
    Write-Host -ForegroundColor $KeyColor -NoNewline 'ATTACKS : '
    Write-Host -ForegroundColor White -NoNewline 'M'
    Write-Host -ForegroundColor $KeyColor -NoNewline ' - Missed,  '
    Write-Host -ForegroundColor Red -NoNewline 'H'
    Write-Host -ForegroundColor $KeyColor ' - HIT  '
  }
  Write-Host
  $CoordsColor = "Yellow"  
  $NameColor = "Green"
  Write-Host -ForegroundColor $NameColor $WhosBoard
  Write-Host -ForegroundColor $CoordsColor "   0  1  2  3  4  5  6  7  8  9"
  foreach ($DisplayRow in (0..9)) {
    Write-Host -NoNewline -ForegroundColor $CoordsColor "$([Char]($DisplayRow+65))  "
    foreach ($DisplayCol in (0..9)) {
      $DisplayPos = ($DisplayRow * 10) + $DisplayCol
      if ($Ships -eq $false) { Write-Host -NoNewline -ForegroundColor $Grid[$DisplayPos].PegCol $Grid[$DisplayPos].Peg " "}
      else {Write-Host -NoNewline -ForegroundColor $Grid[$DisplayPos].ShipCol $Grid[$DisplayPos].Ship " "}
    }
    Write-Host
  }
}

function Place-Ship {
  Param (
    $Grid
  )
  $ShipCol = "White"
  foreach ($Ship in "AAAAA","BBBB","CCC","SSS","DD") {
    do {
      $ShipChar = $Ship.substring(0,1)
      $GoodPos = $true
      $ShipLen = $Ship.length - 1
      $RandDir = "V","H" | Get-Random
      # Guess a position for the ship placement and then check no other ship is there already, 
      # re-guess if required
      if ($RandDir -eq 'V') {
        $VAdjusted = 9 - $Shiplen 
        $HAdjusted = 9
        $RandCol = 0..$VAdjusted | Get-Random 
        $RandRow = 0..$HAdjusted | Get-Random 
        foreach ($Pos in (0..$ShipLen)) {
          $PotentialPos = $Grid | Where-Object {$_.Row -eq $RandRow -and $_.Col -eq ($RandCol+$Pos) }
          if ($PotentialPos.ship -match '[ABSCD]') {$GoodPos = $false}
        }
      }
      if ($RandDir -eq 'H') {
        $HAdjusted = 9 - $ShipLen 
        $VAdjusted = 9
        $RandCol = 0..$VAdjusted | Get-Random 
        $RandRow = 0..$HAdjusted | Get-Random 
        foreach ($Pos in (0..$ShipLen)) {
          $PotentialPos = $Grid | Where-Object {$_.Row -eq ($RandRow+$Pos) -and $_.Col -eq $RandCol }
          if ($PotentialPos.ship -match '[ABSCD]') {$GoodPos = $false}
        }
      }
    } until ($GoodPos -eq $true)
    ### Add the Ship values in the guessed positions AAAAA or SSS etc.
    if ($RandDir -eq 'V') {
      foreach ($Pos in (0..$ShipLen)) {
        $ArrayPos = ($RandRow * 10) + ($RandCol + $Pos)
        $Grid[$ArrayPos].Ship = $ShipChar
        $Grid[$ArrayPos].ShipCol = $ShipCol
      }
    }
    if ($RandDir -eq 'H') {
      foreach ($Pos in (0..$ShipLen)) {
        $ArrayPos = (($RandRow +$Pos) * 10) + $RandCol
        $Grid[$ArrayPos].Ship = $ShipChar
        $Grid[$ArrayPos].ShipCol = $ShipCol
      }
    }
  }
  $Grid
}


function Find-LikelyHits {
  Param (
    $Grid
  )
  # Randomise the choice of computer hit unless there are previous hits
  # if hits exist use the NSEW property to discover other possible hits
  $Choices = @()
  $Hits = $grid | Where-Object {$_.ship -eq "X"}
  foreach ($Hit in $Hits) {
    foreach ($Direction in $Hit.NSEW) {
      if ($grid[$Direction].PegChosen -eq $false) {
        $Choices += $Direction
      }
    }
  }
  if ($Choices.count -gt 0) {
    $Choice = $Choices | Get-Random
    $Random = $false
  }
  else {
    $Choice = $null
    $Random = $true
  }
  #still needs more logic to stop checking once a line is completed...
  :AllForLoops foreach ($Hit in $Hits) {
    foreach ($Direction in $Hit.NSEW) {
      if ($Grid[$Direction].Ship -eq "X") {
        $PossibleHitPos = (2 * ($Hit.pos)) - $Direction
        if ($PossibleHitPos -in $Hit.NSEW) {
          if ($Grid[$PossibleHitPos].PegChosen -eq $false) {
            $Choice = $PossibleHitPos
            $Random = $false
            break AllForLoops
          }
        } 
      }
    }
  }
  [PSCustomObject][Ordered]@{
    Choice = $Choice
    Random = $Random
  }
}

function Guess-Move {
  Param (
    $OpponentGrid,
    [Switch]$ComputersTurn


  )
  if ($ComputersTurn -eq $true) {
    $Likely = Find-LikelyHits -Grid $OpponentGrid.psobject.copy()
    if ($Likely.Random -eq $true) {
      #$GuessArray = @(0,2,4,6,8,11,13,15,17,19,20,22,24,26,28,31,33,35,37,39,40,42,44,46,48,51,53,55,57,59,60,62,64,66,68,71,73,75,77,79,80,82,84,86,88,91,93,95,97,99)
      $GuessArray = @(0,3,6,9,11,14,17,22,25,28,30,33,36,39,41,44,47,52,55,58,60,63,66,69,71,74,77,82,85,88,90,93,96,99)
      $PosRemaining = ($OpponentGrid | where {$_.Pegchosen -eq $false -and $_.Pos -in $GuessArray} ).Pos
      if ($PosRemaining.count -eq 0) {$PosRemaining = ($OpponentGrid | Where-Object {$_.PegChosen -eq $false}).Pos }
      $GuessPos = $PosRemaining | get-random
    }
    else {
      $GuessPos = $Likely.Choice
    }
    if ($OpponentGrid[$GuessPos].Ship -match "[ABCDS]") {
      $OpponentGrid[$GuessPos].Peg = "H"
      $OpponentGrid[$GuessPos].Pegcol = "Red"
      $OpponentGrid[$GuessPos].PegChosen = $true 
      $OpponentGrid[$GuessPos].Ship = "X"
      $OpponentGrid[$GuessPos].ShipCol = "Red" 
    }
    else {
      $OpponentGrid[$GuessPos].Peg = "M"
      $OpponentGrid[$GuessPos].Pegcol = "Gray"
      $OpponentGrid[$GuessPos].PegChosen = $true        
    }
  }
  else {
    do {
      do {
        Write-Host
        Write-Host -ForegroundColor Yellow -NoNewline "Enter the coordinates for next attack in the form D7 or 7D: "
        $Guess = Read-Host 
        $Guess = ($Guess -replace "[^A-J0-9]",'').ToUpper()
        if ($Guess -match "^[0-9][A-J]$") {$Guess = $Guess -replace "^(.)(.)$",'$2$1'}
      } until ($Guess -match "^[A-J][0-9]$")  
      $GuessRow = [int](([byte][char]$Guess[0]-65).ToString())
      $GuessCol = [int]($guess[1].tostring())
      $GuessPos = ( $GuessRow * 10 ) + $GuessCol
    } until ($OpponentGrid[$GuessPos].PegChosen -eq $false)
    if ($OpponentGrid[$GuessPos].Ship -match "[ABCDS]") {
      $OpponentGrid[$GuessPos].Peg = "H"
      $OpponentGrid[$GuessPos].Pegcol = "Red"
      $OpponentGrid[$GuessPos].PegChosen = $true  
      $OpponentGrid[$GuessPos].Ship = "X"
      $OpponentGrid[$GuessPos].ShipCol = "Red" 
    }
    else {
      $OpponentGrid[$GuessPos].Peg = "M"
      $OpponentGrid[$GuessPos].Pegcol = "Gray"
      $OpponentGrid[$GuessPos].PegChosen = $true        
    }
  }
  return $OpponentGrid
}

function Check-Winner {
  Param (
    $PlayersGrid,
    $PersonName,
    $ComputersGrid
  )
  $ComputerGuesses = $PlayersGrid | Where-Object {$_.Ship -match "X"}  
  $PlayerGuesses = $ComputersGrid | Where-Object {$_.Ship -match "X"}
  if ($ComputerGuesses.count -eq 17) {$win = "Computer"}
  elseif ($PlayerGuesses.count -eq 17) {$win = $PersonName}
  else {$win = "None"}
  $win
}




######  MainCode
$QuestionColor = "Red"
$ComputerBoard = $null
$PlayersBoard = $null
Clear-Host
$PlayerName = Read-Host -Prompt "What is your name"
#Init boards
do {
  $ComputerBoard = Init-Board
  $PlayersBoard  = Init-Board
  $ComputerBoard = Place-Ship -Grid $ComputerBoard.PSObject.copy()
  $PlayersBoard  = Place-Ship -Grid $PlayersBoard.PSObject.copy()
  Clear-Host
  Display-Grid -Grid $ComputerBoard -Key -WhosBoard "Computer"
  Display-Grid -Grid $PlayersBoard -Ships -WhosBoard $PlayerName
  Write-Host -ForegroundColor $QuestionColor -NoNewline "`nAre you happy with the Ship placement? "
  $Happy = Read-Host 
  if ($Happy -like "y*") {$PlayerHappy = $true}
  else {$PlayerHappy = $false}
} until ($PlayerHappy -eq $true)
do {
  Clear-Host
  Display-Grid -Grid $ComputerBoard -Key -WhosBoard "Computer"
  Display-Grid -Grid $PlayersBoard -Ships -WhosBoard $PlayerName
  $PlayersBoard = Guess-Move -OpponentGrid $PlayersBoard.psobject.Copy() -ComputersTurn
  $Winner = Check-Winner -PlayersGrid $PlayersBoard -PersonName $PlayerName -ComputersGrid $ComputerBoard
  if ($Winner -ne 'Computer') { 
    $ComputerBoard = Guess-Move -OpponentGrid $ComputerBoard.psobject.Copy()
    $Winner = Check-Winner -PlayersGrid $PlayersBoard -PersonName $PlayerName -ComputersGrid $ComputerBoard
  }
  if ($winner -ne 'none') {
    Clear-Host
    Display-Grid -Grid $ComputerBoard -Key -WhosBoard "Computer"
    Display-Grid -Grid $PlayersBoard -Ships -WhosBoard $PlayerName
    Write-Host -ForegroundColor Yellow "`nThe winner is "$Winner
  }
} until ($Winner -ne 'none')