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
    $RowNum = [System.Math]::Truncate( $Num / 10 )
    $ColNum = $Num % 10
    $ShipChar = '-'
    $PegChar = '-'
    [PSCustomObject]@{
      Row = $RowNum
      Col = $ColNum
      Pos = $Num
      Ship = $ShipChar
      ShipCol = "green"
      Peg = $PegChar
      PegCol = "White"
    }
  }
}

function Display-Grid {  
  Param (
    $Grid,
    [switch]$Ships
  )
  $Color = "Yellow"  
  Write-Host -ForegroundColor $Color "   0  1  2  3  4  5  6  7  8  9"
  foreach ($DisplayRow in (0..9)) {
    Write-Host -NoNewline -ForegroundColor $Color "$([Char]($DisplayRow+65))  "
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
  foreach ($Ship in "AAAAA","BBBB","CCC","SSS","DD") {
    do {
      $GoodPos = $true
      $ShipLen = $Ship.length - 1
      $RandDir = "V","H" | Get-Random
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
        $VAdjusted 
        $RandCol = 0..$VAdjusted | Get-Random 
        $RandRow = 0..$HAdjusted | Get-Random 
        foreach ($Pos in (0..$ShipLen)) {
          $PotentialPos = $Grid | Where-Object {$_.Row -eq ($RandRow+$Pos) -and $_.Col -eq $RandCol }
          if ($PotentialPos.ship -match '[ABSCD]') {$GoodPos = $false}
        }
      }
    } until ($GoodPos -eq $true)
    if ($RandDir -eq 'V') {}
    if ($RandDir -eq 'H') {}
  }
}








######  MainCode

#Init boards
$ComputerBoard = Init-Board
$PlayersBoard  = Init-Board

Clear-Host
Write-Host -ForegroundColor Yellow "Computer"
Display-Grid -Grid $ComputerBoard
Write-Host -ForegroundColor Yellow "`nPlayer"
Display-Grid -Grid $PlayersBoard -Ships

