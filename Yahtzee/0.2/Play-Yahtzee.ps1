<#
.SYNOPSIS
  Short description
.DESCRIPTION
  Long description
.EXAMPLE
  PS C:\> <example usage>
  Explanation of what the example does
.INPUTS
  Inputs (if any)
.OUTPUTS
  Output (if any)
.NOTES
  General notes
#>
[CmdletBinding()]
Param ()

function Get-DiceRoll {
  Param (
    [int[]]$WhichDiceReroll,
    [int[]]$Dice
  )
  if ($WhichDiceReroll.Count -eq 0) {
    $Dice = 0..4 | ForEach-Object {1..6 | Get-Random}
  }
  else {
    foreach ($Index in $WhichDiceReroll) {$Dice[$Index] = 1..6 | Get-Random}
  }
  return $Dice
}

function Show-ScoreCard {
  Param ([int[]]$Score,[int[]]$Dice)
  Write-Host
  Write-Host -NoNewline -ForegroundColor Green "UPPER"
  Write-Host -ForegroundColor Yellow "                                  Dice: $($Dice -join ',')"
  Write-Host -ForegroundColor Green '-----'
  Write-Host -NoNewline -ForegroundColor cyan '  0..Aces:   '
  if ($Score[0] -eq -1) {Write-Host 'PickMe'} else {Write-Host $Score[0]}
  Write-Host -NoNewline -ForegroundColor Cyan '  1..Twos:   '
  if ($Score[1] -eq -1) {Write-Host 'PickMe'} else {Write-Host $Score[1]}
  Write-Host -NoNewline -ForegroundColor Cyan '  2..Threes: '
  if ($Score[2] -eq -1) {Write-Host 'PickMe'} else {Write-Host $Score[2]}
  Write-Host -NoNewline -ForegroundColor Cyan '  3..Fours:  '
  if ($Score[3] -eq -1) {Write-Host 'PickMe'} else {Write-Host $Score[3]}
  Write-Host -NoNewline -ForegroundColor Cyan '  4..Fives:  '
  if ($Score[4] -eq -1) {Write-Host 'PickMe'} else {Write-Host $Score[4]}
  Write-Host -NoNewline -ForegroundColor Cyan '  5..Sixes:  '
  if ($Score[5] -eq -1) {Write-Host 'PickMe'} else {Write-Host $Score[5]}
  Write-Host -NoNewline -ForegroundColor Yellow '  UpperSubTotal: '
  $UpperChosenScores = $Score[0..5] | Where-Object {$_ -ne -1}
  if ($UpperChosenScores.count -ne 0) {$Score[6] = ($UpperChosenScores | Measure-Object -Sum).Sum} else {$Score[6]=0}
  Write-Host $Score[6]
  Write-Host -NoNewline -ForegroundColor Yellow '  Bonus:         '
  if ($Score[6] -ge 63) {$Score[7]= 35} else {$Score[7]= 0}
  Write-Host $Score[7]
  Write-Host -NoNewline -ForegroundColor Yellow '  UpperTotal:    '
  $Score[8] = $Score[7] + $Score[6]
  Write-Host $Score[8]
  Write-Host
  Write-Host -ForegroundColor Green 'LOWER' 
  Write-Host -ForegroundColor Green '-----'
  Write-Host -NoNewline -ForegroundColor Cyan '  6..3ofKind:     '
  if ($Score[9] -eq -1) {Write-Host 'PickMe'} else {Write-Host $Score[9]}
  Write-Host -NoNewline -ForegroundColor Cyan '  7..4ofKind:     '
  if ($Score[10] -eq -1) {Write-Host 'PickMe'} else {Write-Host $Score[10]}
  Write-Host -NoNewline -ForegroundColor Cyan '  8..FullHouse:   '
  if ($Score[11] -eq -1) {Write-Host 'PickMe'} else {Write-Host $Score[11]}
  Write-Host -NoNewline -ForegroundColor Cyan '  9..SmlStraight: '
  if ($Score[12] -eq -1) {Write-Host 'PickMe'} else {Write-Host $Score[12]}
  Write-Host -NoNewline -ForegroundColor Cyan ' 10..LrgStraight: '
  if ($Score[13] -eq -1) {Write-Host 'PickMe'} else {Write-Host $Score[13]}
  Write-Host -NoNewline -ForegroundColor Cyan ' 11..Yahtzee:     '
  if ($Score[14] -eq -1) {Write-Host 'PickMe'} else {Write-Host $Score[14]}
  $LowerChosenScores = $Score[9..14] | Where-Object {$_ -ne -1}
  if ($LowerChosenScores.count -ne 0) {$Score[15] = ($LowerChosenScores | Measure-Object -Sum).Sum} else {$Score[15]=0}
  Write-Host -NoNewline -ForegroundColor Yellow '  LowerTotal: '
  Write-Host $Score[15]
  Write-Host -NoNewline -ForegroundColor Yellow '  UpperTotal: '
  $score[16] = $score[8]
  Write-Host $Score[16]
  Write-Host -NoNewline -ForegroundColor Yellow '  GrandTotal: '
  $Score[17] = $Score[15] + $Score[16]
  Write-Host $Score[17]
  Write-Host
  
}

function Show-DiceRoll {
  Param ([int[]]$Dice,[int]$TurnNumber)
  $DiceObj = @()
  foreach ($Index in (0..4)) {
    $objprop = [ordered]@{
      DiceNumber = $Index
      DiceFace   = $Dice[$Index]
    }
    $DiceObj  += New-Object -TypeName psobject -Property $objprop
  }  
  return $DiceObj
}

# Main code
Clear-Host
$GameScore = @(-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1)
$InitRoll = Get-DiceRoll 
$DicePos = Show-DiceRoll -Dice $InitRoll -TurnNumber 1
$DicePos
#$NextRoll = Get-DiceRoll -Dice $InitRoll -WhichDiceReroll 0,4,2
Show-ScoreCard -Score $GameScore -Dice $InitRoll
