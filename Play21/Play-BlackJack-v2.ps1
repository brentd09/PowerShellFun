function Build-OrderedDeck {
  foreach ($CardSuit in ('♠','♣','♥','♦')) {
    if ($CardSuit -eq '♠' -or $CardSuit -eq '♣') {$CardColor = "Black"}
    else {$CardColor = "Red"}
    foreach ($CardNumber in (' A',' 2',' 3',' 4',' 5',' 6',' 7',' 8',' 9','10',' J',' Q',' K')) {
      switch -regex ($CardNumber)
      {
          ' A' {$CardScore = 11}
          ' [JQK]' {$CardScore = 10}
          ' [1-9]$' {$CardScore = $CardNumber -as [int]}
          '10' {$CardScore = 10}
          Default {}
      }
      $CardProperties = [ordered]@{
        Suit = $CardSuit
        Color = $CardColor
        Number = $CardNumber
        Score = $CardScore
      }
      New-Object -TypeName psobject -Property $CardProperties
    }
  }
}

function Display-Card {
  Param($DeckShuffled,$WhichCard,[switch]$HideCard)
  $SingleCard = $DeckShuffled[$WhichCard] 
  if ($HideCard) {$ForeColor = "White"}
  else {$ForeColor = $SingleCard.Color}
  Write-Host -ForegroundColor $ForeColor "$($SingleCard.Number)$($SingleCard.Suit)" -BackgroundColor White -NoNewline
  write-host ' ' -NoNewline
}

function Check-HandScore {
  Param ($EntireHand)
  $HandBusted = $false
  $ScoreAdjust = 0
  $AceCount = ($EntireHand | Where-Object -FilterScript {$_.number -match "^\s*A\s*$"} | Measure-Object).Count  
  $TotalScore = ($EntireHand |  Measure-Object -Sum -Property score).Sum
  if (($TotalScore -gt 21 -and $AceCount -eq 0) -or $TotalScore -gt 61) {$HandBusted = $true}
  elseif ($TotalScore -gt 21 -and $TotalScore -le 31 -and $AceCount -ge 1) {$ScoreAdjust = 10}
  if ($TotalScore -gt 31 -and $TotalScore -le 41 -and $AceCount -lt 2) {$HandBusted = $true}
  elseif ($TotalScore -gt 31 -and $TotalScore -le 41 -and $AceCount -ge 2) {$ScoreAdjust = 20}
  if ($TotalScore -gt 41 -and $TotalScore -le 51 -and $AceCount -lt 3) {$HandBusted = $true}
  elseif ($TotalScore -gt 41 -and $TotalScore -le 51 -and $AceCount -ge 3) {$ScoreAdjust = 30}
  if ($TotalScore -gt 51 -and $TotalScore -le 61 -and $AceCount -lt 4) {$HandBusted = $true}
  elseif ($TotalScore -gt 51 -and $TotalScore -le 61 -and $AceCount -eq 4) {$ScoreAdjust = 40}
  $ScoreParam = @{
    Busted = $HandBusted
    Score = $TotalScore - $ScoreAdjust  
  }
  New-Object -TypeName psobject -Property $ScoreParam
}

function Check-WhoWon {
  Param($DealerInfo,$PlayerInfo)
  if ($PlayerInfo.busted) {
    if ($DealerInfo.score -le 21) {$WhoWon = "Dealer"}
    else {$WhoWon = "noone"}
  }
  if ($DealerInfo.busted) {
    if ($PlayerInfo.score -le 21) {$WhoWon = "Player"}
    else {$WhoWon = "noone"}
  }
  if ($DealerInfo.busted -eq $false -and $PlayerInfo.busted -eq $false) {
    if ($DealerInfo.score  -eq $PlayerInfo.score) {$WhoWon = "No One"}
    elseif ($DealerInfo.score -gt $PlayerInfo.score) {$WhoWon = "Dealer"}
    elseif ($PlayerInfo.score -gt $DealerInfo.score) {$WhoWon = "Player"} 
  }
  $WhoWon
}

#-------------- 
# MAIN CODE


# init variables 
$OrderedCards = @()
$DealerHand = @()
$PlayerHand = @()
$OrderedCards = Build-OrderedDeck
$InitShuffle = $OrderedCards | Sort-Object{Get-Random} # this will shuffle a list of objects, e.g. PlayingCards
$DealersTurn = $false ; $PlayersTurn = $true
$NextCardPosition = 0
$DealerTurnNum = 0
# iv

# initial hand deal
$DealerHand = @(0,2)
$PlayerHand = @(1,3)
$NextCardPosition = 4
# ihd

do {
  Clear-Host
  if ($PlayersTurn) {$Title = "Players "}
  elseif ($DealersTurn) {$Title = "Dealers "}
  Write-Host -ForegroundColor black -BackgroundColor Red "$Title Turn"
  Write-Host ''
  # Display the Dealers Hand
  Write-Host -ForegroundColor Yellow  "Dealer Hand"
  $DealerStatus = Check-HandScore -EntireHand $InitShuffle[$DealerHand] 
  foreach ($DealerCard in $DealerHand) {
    if (-not $DealersTurn -and $DealerCard -eq $DealerHand[0]) {Display-Card -DeckShuffled $InitShuffle -WhichCard $DealerCard -HideCard}
    else {Display-Card -DeckShuffled $InitShuffle -WhichCard $DealerCard}
  }
  Write-Host ''
  if ($DealerStatus.Busted) { 
    Write-Host -ForegroundColor Red "BUSTED"
    $DealersTurn = $false
  }
  elseif ($DealersTurn) {
    Write-Host -ForegroundColor Cyan $($DealerStatus.Score)
    $DealerTurnNum++
  }
  else {Write-Host -ForegroundColor Cyan "Waiting For Player"}
  # Display the Players Hand
  Write-Host -ForegroundColor Green  "`nPlayer Hand"
  $PlayerStatus = Check-HandScore -EntireHand $InitShuffle[$PlayerHand] 
  foreach ($PlayerCard in $PlayerHand) {
    Display-Card -DeckShuffled $InitShuffle -WhichCard $PlayerCard
  }
  Write-Host ''
  if ($PlayerStatus.Busted) { 
    Write-Host -ForegroundColor Red "BUSTED"
    $PlayersTurn = $false
    $DealersTurn = $true
  }
  else {Write-Host -ForegroundColor Cyan $($PlayerStatus.Score)}
  Write-Host ''
  # Get Player to choose to HIT or STAND
  if ($PlayersTurn) {
    $Question = Read-Host -Prompt "[H]it or [S]tand"
    if ($Question -like "h*") {
      $PlayerHand += $NextCardPosition
      $NextCardPosition++
    }  
    else {
      $PlayersTurn = $false
      $DealersTurn = $true
      $DealerTurnNum = 0
    }
  }
  # Dealer needs to find out if cards are needed to win
  if ($DealersTurn -and $PlayerStatus.Busted -eq $false) {
    if ($DealerStatus.score -le 17) {
      $DealerHand += $NextCardPosition
      $NextCardPosition++
    } 
    elseif ($DealerStatus.score -lt $PlayerStatus.Score) {
      $DealerHand += $NextCardPosition
      $NextCardPosition++
    }
    elseif ($DealerTurnNum -gt 0) {$DealersTurn = $false}
  }
  if ($DealersTurn -and $PlayerStatus.Busted -eq $true -and $DealerTurnNum -gt 0) {
    $DealersTurn = $false
  }

} until ($DealersTurn -eq $false -and $PlayersTurn -eq $false)
# Determine the winner, if there is one
$Winner = Check-WhoWon -DealerInfo $DealerStatus -PlayerInfo $PlayerStatus
Write-Host -NoNewline  "Winner is:"
if ($Winner -eq 'Player') {$WinColor = 'Green'}
if ($Winner -eq 'Dealer') {$WinColor = 'Yellow'}

write-host -foregroundcolor $WinColor "$Winner"