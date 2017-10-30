function Display-Grid {  
  Param (
    $Grid,
    $Color,
    $NameOnGrid,
    [switch]$ClearScreen
  )
  if ($ClearScreen -eq $true) {
    Clear-Host 
    Write-Host
  }
  Write-Host -ForegroundColor $Color "   $NameOnGrid Grid"
  Write-Host -ForegroundColor $Color "   0  1  2  3  4  5  6  7  8  9"
  foreach ($Row in (0..9)) {
    Write-Host -NoNewline -ForegroundColor $Color "$([Char]($Row+65))  "
    foreach ($Col in (0..9)) {
      $Pos = ($row * 10) + $Col
      if ($Grid[$Pos] -eq "O"){$DisplayColor = "Red"}
      if ($Grid[$Pos] -eq "X"){$DisplayColor = "DarkGray"}
      if ($Grid[$Pos] -eq "-"){$DisplayColor = "White"}
      Write-Host -NoNewline -ForegroundColor $DisplayColor $Grid[$Pos] " "
    }
    Write-Host
  }
}

function Find-LikelyHits {
  Param (
    $Grid
  )
  $Hits = @()
  $PossHits = @()
  $LeftEdge = $false; $RightEdge = $false; $TopEdge = $false; $BottomEdge = $false
  $HitCount = 0
  $BadEast = @(10,20,30,40,50,60,70,80,90,100); $BadWest = @(-1,9,19,29,39,49,59,69,79,89)
  foreach ($location in (0..99)) {
    if ($grid[$location] -eq 'O') {$Hits += $location; $HitCount++}
  }
  if ($HitCount -gt 0) {
    foreach ($Hit in $Hits) {
      $ColPos = $Hit % 10
      $RowPos = [math]::Truncate($Hit / 10)
      $North = $Hit - 10; $South = $Hit + 10; $East = $Hit+ 1; $West = $Hit - 1
      if ($North -ge 0 -and $Grid[$North] -eq '-') {$PossHits += $North}
      if ($South -le 99 -and $Grid[$South] -eq '-') {$PossHits += $South}
      if ($East -notin $BadEast -and $Grid[$East] -eq '-') {$PossHits += $East}
      if ($West -notin $BadWest -and $Grid[$West] -eq '-') {$PossHits += $West}
    }
  }
  $HitCount = $PossHits.count
  $ReturnObj = New-Object -TypeName psobject -Property @{HitCount=$HitCount;PossHits=$PossHits}
  return $ReturnObj
}

function Set-ShipPlacement {
  Param (
    $Grid
  )
  $ShipObj = @{}
  $ShipNames = @("AirCraft-Carrier","Battleship","Cruiser","Submarine","Destroyer")
  $ShipSize = @(5,4,3,3,2)
  0..4 | ForEach-Object {
    $ShipObj = 0..4 | ForEach-Object {
      New-Object -TypeName psobject -Property @{Name = $ShipNames[$_];Size = $ShipSize[$_]} 
    }
  }
  foreach ($Ship in $ShipObj) {
    do {
      $Direction = @("c","r") | Get-Random
      if ($Direction -eq "c") {
        $ColPos = 0..9 | Get-Random
        $RowPos = 0..(10 - $Ship.Size) | Get-Random
        $Nextjump = 10
      }
      else {
        $RowPos = 0..9 | Get-Random
        $ColPos = 0..(10 - $Ship.Size) | Get-Random
        $Nextjump = 1
      }
      $PlacementOK = $true
      $GridPos = ($RowPos * 10) + $ColPos
      $GridPosDup = $GridPos
      1..($Ship.Size) | ForEach-Object {
        if ($Grid[$GridPosDup] -ne "-") { $PlacementOK = $false }
        $GridPosDup = $GridPosDup + $Nextjump
      } #FE
    } until ($PlacementOK -eq $true)
    $ShipLetter = $Ship.Name.substring(0,1)
    1..($Ship.Size) | ForEach-Object {
      $Grid[$GridPos] = $ShipLetter
      $GridPos = $GridPos + $Nextjump
    } #FE
  } #FE
}

function Try-Guess {
  Param (
    $ShipGrid,
    $GameGrid,
    $ChooseFrom,
    [switch]$AutoGuess
  )
  $AutoGuessArray = @(0,2,4,6,8,11,13,15,17,19,20,22,24,26,28,31,33,35,37,39,40,42,44,46,48,51,53,55,57,59,60,62,64,66,68,71,73,75,77,79,80,82,84,86,88,91,93,95,97,99)
  if ($AutoGuess -eq $false) {
    do {
      do {
        Write-Host
        Write-Host -ForegroundColor Yellow "Enter the coordinates for next attack in the form D7"
        $Guess = Read-Host 
        $Guess = ($Guess -replace "[^A-J0-9]",'').ToUpper()
        if ($Guess -match "^[0-9][A-J]$") {$Guess = $Guess -replace "^(.)(.)$",'$2$1'}
      } until ($Guess -match "^[A-J][0-9]$")  
      $GuessRow = [int](([byte][char]$Guess[0]-65).ToString())
      $GuessCol = [int]($guess[1].tostring())
      $GuessPos = ( $GuessRow * 10 ) + $GuessCol
    } while ($GameGrid[$GuessPos] -ne "-")
  }#IF
  else {
    do {
      if ($ChooseFrom.HitCount -eq 0) {$GuessPos = $AutoGuessArray | Get-Random}
      else {$GuessPos = ($chooseFrom.PossHits)| Get-Random}
    } while ($GameGrid[$GuessPos] -ne "-")   
    ### I need to add more logic to this section random guesses are not going to cut it
  }#ELSE

  ## (0..($b.Count-1)) | where {$b[$_] -eq 'D'}

  if ($ShipGrid[$GuessPos] -match "[ABCDS]") {
    $GameGrid[$GuessPos] = "O"
    $ShipGrid[$GuessPos] = "#"
  }#IF
  if ($ShipGrid[$GuessPos] -match "-") {
    $GameGrid[$GuessPos] = "X"
  }#IF
}
###################################################################################

##### Main Code ####

### INIT SETUP ###

$CompGameGrid = @()
$CompShipGrid = @()
$PlayGameGrid = @()
$PlayShipGrid = @()
$PlayFound = @()
$CompFound = @()
$Finished = $false

foreach ($Pos in (0..99)) { 
  $CompGameGrid += "-"
  $PlayGameGrid += "-"
  $PlayShipGrid += "-"
  $CompShipGrid += "-"
}
Set-ShipPlacement -Grid $PlayShipGrid
Set-ShipPlacement -Grid $CompShipGrid
Clear-Host 
Write-Host 
$Player2Name = Read-Host -Prompt "Enter your name"
if ($Player2Name -eq '') {$Player2Name = "Brent"}
$Player1Name = "Computer"
Display-Grid -Grid $CompGameGrid -Color Yellow -NameOnGrid $Player1Name -ClearScreen
Write-Host
Display-Grid -Grid $PlayShipGrid -Color Green -NameOnGrid $Player2Name
### PLAY GAME ###
do {
  Try-Guess -ShipGrid $CompShipGrid -GameGrid $CompGameGrid  # Players turn
  $Likely = Find-LikelyHits -grid $PlayGameGrid 
  Try-Guess -ShipGrid $PlayShipGrid -GameGrid $PlayGameGrid -ChooseFrom $Likely -AutoGuess
  Display-Grid -Grid $CompGameGrid -Color Yellow -NameOnGrid $Player1Name -ClearScreen
  Write-Host
  Display-Grid -Grid $PlayShipGrid -Color Green -NameOnGrid $Player2Name

  if ((($CompGameGrid -join '') -replace "[^O]",'').length -eq 17) {
    Write-Host -ForegroundColor Black -BackgroundColor Green "`n          $Player2Name Wins          "
    $Finished = $true
  }
  if ((($PlayGameGrid -join '') -replace "[^O]",'').length -eq 17) {
    Write-Host -ForegroundColor Black -BackgroundColor Yellow "`n         Computer Wins         "
    $Finished = $true
  }
} Until ($Finished)

