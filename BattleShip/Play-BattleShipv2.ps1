<# Board Array for game
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
#>

function Init-Board {
  foreach ($Num in (0..99)) {
    $Nth = $Num - 10;$Sth = $Num + 10;$Est = $Num + 1;$Wst = $num - 1
    $RowNum = [System.Math]::Truncate( $Num / 10 )
    $ColNum = $Num % 10
    $ShipChar = '-'
    $PegChar = '-'
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
      Row = $RowNum
      Col = $ColNum
      Pos = $Num
      Ship = $ShipChar
      ShipCol = "green"
      Peg = $PegChar
      PegCol = "White"
      PegChosen = $false
      NSEW = $NSEW
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
  if ($Key -eq $true) {
  $KeyColor = "Cyan"
    Write-Host -ForegroundColor Yellow 'KEY:' 
    Write-Host -ForegroundColor Cyan 'SHIPS: '' A - Aircraft Carrier, B - Battleship, C - Cruiser, D - Destroyer, S - Submarine'
    Write-Host -ForegroundColor Cyan 'ATTACKS : M - Missed, H - HIT  '
  }
  Write-Host
  $CoordsColor = "Yellow"  
  Write-Host -ForegroundColor $CoordsColor $WhosBoard
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
      ### Guess a position for the ship placement and then check no other ship is there already, 
      ### re-guess if required
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
    $Choice =  $Choices | Get-Random
    $Random = $false
  }
  else {
    $Choice = $null
    $Random = $true
  }
  [PSCustomObject][Ordered]@{
    Choice = $Choice
    Random = $Random
  }
  # find which ships have been sunk
  # find hits that are close together on rows
  # find hits that are close together on cols

}

function Guess-Move {
  Param (
    $OpponentGrid,
    [Switch]$ComputersTurn


  )
  if ($ComputersTurn -eq $true) {
    $Likely = Find-LikelyHits -Grid $OpponentGrid.psobject.copy()
    if ($Likely.Random -eq $true) {
      $GuessArray = @(1,3,5,7,9,12,14,16,18,20,21,23,25,27,29,32,34,36,38,40,41,43,45,47,49,52,54,56,58,60,61,63,65,67,69,72,74,76,78,80,81,83,85,87,89,92,94,96,98)
      $PosRemaining = ($OpponentGrid | where {$_.Pegchosen -eq $false -and $_.Pos -in $GuessArray} ).Pos
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
        Write-Host -ForegroundColor Yellow "Enter the coordinates for next attack in the form D7 or 7D"
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
    $ComputersGrid
  )
  $ComputerGuesses = $PlayersGrid | Where-Object {$_.Ship -match "X"}  
  $PlayerGuesses = $ComputersGrid | Where-Object {$_.Ship -match "X"}
  if ($ComputerGuesses.count -eq 17) {$win = "Computer"}
  elseif ($PlayerGuesses.count -eq 17) {$win = "Player"}
  else {$win = "None"}
  $win
}




######  MainCode
$ComputerBoard = $null
$PlayersBoard = $null

#Init boards
do {
  $ComputerBoard = Init-Board
  $PlayersBoard  = Init-Board
  $ComputerBoard = Place-Ship -Grid $ComputerBoard.PSObject.copy()
  $PlayersBoard  = Place-Ship -Grid $PlayersBoard.PSObject.copy()
  Clear-Host
  Display-Grid -Grid $ComputerBoard -Key -WhosBoard "Computer"
  Display-Grid -Grid $PlayersBoard -Ships -WhosBoard "Player"
  $Happy = Read-Host -Prompt "`nAre you happy with the Ship placement?"
  if ($Happy -like "y*") {$PlayerHappy = $true}
  else {$PlayerHappy = $false}
} until ($PlayerHappy -eq $true)
do {
  Clear-Host
  Display-Grid -Grid $ComputerBoard -Key -WhosBoard "Computer"
  Display-Grid -Grid $PlayersBoard -Ships -WhosBoard "Player"
  $PlayersBoard = Guess-Move -OpponentGrid $PlayersBoard.psobject.Copy() -ComputersTurn
  $ComputerBoard = Guess-Move -OpponentGrid $ComputerBoard.psobject.Copy()
  $Winner = Check-Winner -PlayerGrid $PlayersBoard -ComputersGrid $ComputerBoard
  if ($winner -ne 'none') {
    Clear-Host
    Display-Grid -Grid $ComputerBoard -Key -WhosBoard "Computer"
    Display-Grid -Grid $PlayersBoard -Ships -WhosBoard "Player"
    Write-Host -ForegroundColor Yellow "`nThe winner is " $Winner
  }
} until ($Winner -ne 'none')