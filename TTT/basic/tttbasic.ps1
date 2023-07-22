#   1 | 2 | 3
#  ---+---+---
#   4 | 5 | 6
#  ---+---+---
#   7 | 8 | 9
#
#
[CmdletBinding()]
Param (
  [System.Collections.ArrayList]$Board = @('1','2','3','4','5','6','7','8','9')
)

function Show-Board {
  Param ($BoardToShow)
  Clear-Host
  Write-Host " $($BoardToShow[0]) | $($BoardToShow[1]) | $($BoardToShow[2]) "
  Write-Host "---+---+---"
  Write-Host " $($BoardToShow[3]) | $($BoardToShow[4]) | $($BoardToShow[5]) "
  Write-Host "---+---+---"
  Write-Host " $($BoardToShow[6]) | $($BoardToShow[7]) | $($BoardToShow[8]) "
  Write-Host
}

$GameTurn = 'X'
$GameOver = $false
do {
  Show-Board -BoardToShow $Board
  # ask for a position to play
  # check for wrong places and places that have already been chosen
  # if wrong place chosen ask again until they get it right
  do {
    $GoodChoice = $true
    $ChosenLocation = Read-Host -Prompt "Please enter the number location of you choice to player $GameTurn"
    $Location = $ChosenLocation -as [int]
    if ($Location -lt 1 -or $Location -gt 9  -or $Board[$Location - 1] -in @('X','O')) {$GoodChoice = $false}
  } until ( $GoodChoice -eq $true )

  # change the board to reflect the change
  $Index = $Location - 1
  $Board[$Index] = $GameTurn

  # Test if game is over, tie or win
  $Tests = @(
    @(0,4,8),
    @(2,4,6),
    @(0,1,2),
    @(3,4,5),
    @(6,7,8),
    @(0,3,6),
    @(1,4,7),
    @(1,5,8)
  )
  foreach ($Test in $Tests) {
    if (($Board[$Test] | Select-Object -Unique).Count -eq 1) {
      $GameOver = $true
      $Winner = $GameTurn
      Show-Board -BoardToShow $Board
      break
    }
  }
  # Change to the other player
  if ($GameTurn -eq 'X') {$GameTurn = 'O'}
  else {$GameTurn = 'X'}
} until ($GameOver)
"Winner is $Winner"