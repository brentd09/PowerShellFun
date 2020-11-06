<#
.SYNOPSIS
  Yahtzee Solitare
.DESCRIPTION
  This currently allows one player to play the traditional 
  game of Yahtzee
.EXAMPLE
  Play-Yahtzee.ps1
  This will show a tradtional Yahtzee score board and at the
  bottom show the current dice faces
.NOTES
  General notes
    Created by: Brent Denny
    Created on: 6 Nov 2020
#>
[CmdletBinding()]
Param ()
# Classes
class YahtzeeScore {
  [string]$Label
  [string]$Name
  [int]$Value
  [int]$PlayCount
  [int]$LegalPlayCount
 
  YahtzeeScore ($Position) {
    $Labels = @('A-','B-','C-','D-','E-','F-','G-','H-','I-','J-','K-','L-','M-')
    $Names = @('Aces','Twos','Threes','Fours','Fives','Sixes','3 of a kind','4 of a kind','Full House','Small Strait','Large Strait','YAHTZEE','Chance')
    if ($Position -in @(0,1,2,3,4,5,6,7,8,9,10,12)) {
      $this.Label = $Labels[$Position]
      $this.Name = $Names[$Position]
      $this.LegalPlayCount = 1
      $this.PlayCount = 0
      $this.Value = $null
    }
    elseif ($Position -eq 11) {
      $this.Label = $Labels[$Position]
      $this.Name = $Names[$Position]
      $this.LegalPlayCount = 4
      $this.PlayCount = 0
      $this.Value = $null
    }
  }


}

Class YahtzeeCard {
  [YahtzeeScore[]]$Scores

  YahtzeeCard ([YahtzeeScore[]]$ScoreArray) {
    $this.Scores = $ScoreArray
  }

  [void]SetScore ([int]$Position,[int[]]$DiceValues) {
    $UpperScoreNumber = $Position + 1
    if ($this.Scores[$Position].PlayCount -lt $this.Scores[$Position].LegalPlayCount) {
      if ($Position -ge 0 -and $Position -le 5) {
        $RelevantDice = ($DiceValues | Where-Object {$_ -eq $UpperScoreNumber}).Count
        $PositionScore = $RelevantDice * $UpperScoreNumber
        $this.Scores[$Position].Value = $PositionScore
        $this.Scores[$Position].PlayCount++
      } 
      elseif ($Position -in @(6,7)) {
        $Kind = $Position - 3
        $DiceGroup = $DiceValues | Group-Object | Where-Object {$_.Count -ge $Kind}
        $RelevantDice = $DiceGroup.Name.Count
        if ($RelevantDice -eq 1) {
          $PositionScore = ($DiceValues | Measure-Object -Sum).Sum
          $this.Scores[$Position].Value = $PositionScore
          $this.Scores[$Position].PlayCount++
        }
        else {
          $PositionScore = 0
          $this.Scores[$Position].Value = $PositionScore
          $this.Scores[$Position].PlayCount++
        }
      } 
      elseif ($Position -eq 8) {
        $DiceGroupCount = ($DiceValues | Group-Object).Count
        if ($DiceGroupCount -eq 2) {
          $PositionScore = 25
          $this.Scores[$Position].Value = $PositionScore
          $this.Scores[$Position].PlayCount++
        }
        else {
          $PositionScore = 0
          $this.Scores[$Position].Value = $PositionScore
          $this.Scores[$Position].PlayCount++
        }
      }
      elseif ($Position -in @(9,10)) {
        $ValuesInRow = $Position - 6
        $UniqueDiceSorted = $DiceValues |  Select-Object -Unique | Sort-Object 
        $UniqueDiceSortedCount = $UniqueDiceSorted.Count
        if ($UniqueDiceSortedCount -lt 4) {$PositionScore = 0}
        else {
          $SeqCount = 0
          foreach ($Index in @(0..($UniqueDiceSortedCount-2))) {
            if ($UniqueDiceSorted[$Index] -eq $UniqueDiceSorted[$Index+1] - 1) {$SeqCount++}
            else {$SeqCount = 0}
          }
          if ($SeqCount -ge $ValuesInRow) {$PositionScore = ($ValuesInRow - 1) * 10} 
          else {$PositionScore = 0}
        }
        $this.Scores[$Position].Value = $PositionScore
        $this.Scores[$Position].PlayCount++
      }
      elseif ($Position -eq 11) {
        $UniqueDiceCount = ($DiceValues | Select-Object -Unique).Count 
        if ($UniqueDiceCount -eq 1) {
          if ($this.Scores[$Position].PlayCount -eq 0) {$YahtzeeScore = 50}
          else {
            $YahtzeeScore = 100
            $Script:GameTurns--
          }
          $this.Scores[$Position].Value = $this.Scores[$Position].Value + $YahtzeeScore
          $this.Scores[$Position].PlayCount++ 
        }
        else {
          $this.Scores[$Position].Value = 0
          $this.Scores[$Position].PlayCount = 4
        }
      }
      elseif ($Position -eq 12) {
        $PositionScore = ($DiceValues | Measure-Object -Sum).Sum
        $this.Scores[$Position].Value = $PositionScore
        $this.Scores[$Position].PlayCount++ 
      }
    }
  }
}

# functions

function Get-DiceRoll {
  Param (
    [int]$DiceCount = 5
  )
  1..$DiceCount | ForEach-Object {1..6 | Get-Random }
}


function Show-ScoreCard {
  Param(
    [YahtzeeCard]$ScoreCard
  )
  Clear-Host
  $Coords = New-Object -TypeName System.Management.Automation.Host.Coordinates
  $host.UI.RawUI.CursorPosition = $Coords
  $UpTotal = ($ScoreCard.Scores[0..5].Value | Measure-Object -Sum).Sum
  $LowScore = ($ScoreCard.Scores[6..12].Value | Measure-Object -Sum).Sum
  if ($UpTotal -ge 63) {$Bonus = 35}
  else {$Bonus = 0}
  $UpTotalWithBonus = $UpTotal + $Bonus
  $GTScore = $UpTotalWithBonus + $LowScore
  Write-Host 'YAHTZEE'
  Write-Host 
  Write-Host 'UPPER SECTION'
  foreach ($Index in @(0..5)) {
    Write-Host -ForegroundColor Green $MyScoreCard.Scores[$Index].Label -NoNewline
    if ($ScoreCard.Scores[$Index].PlayCount -eq 0) {Write-host "$($ScoreCard.Scores[$Index].Name)"}
    else {
      Write-Host "$($ScoreCard.Scores[$Index].Name) " -NoNewline
      Write-Host  -ForegroundColor Yellow "$($ScoreCard.Scores[$Index].Value)"
    }
  }
  Write-Host '-------------------------------'
  Write-Host "Total Score " -NoNewline
  Write-Host -ForegroundColor Cyan "$UpTotal"  
  Write-Host "BONUS " -NoNewline
  Write-Host -ForegroundColor Cyan "$Bonus"
  Write-Host "Upper Score " -NoNewline
  Write-Host -ForegroundColor Cyan "$UPTotalWithBonus"
  Write-Host '-------------------------------'
  Write-Host "LOWER SECTION"
  foreach ($Index in @(6..12)) {
    Write-Host -ForegroundColor Green $MyScoreCard.Scores[$Index].Label -NoNewline
    if ($ScoreCard.Scores[$Index].PlayCount -eq 0) {Write-host "$($ScoreCard.Scores[$Index].Name)"}
    else {
      Write-Host "$($ScoreCard.Scores[$Index].Name) " -NoNewline
      Write-Host  -ForegroundColor Yellow "$($ScoreCard.Scores[$Index].Value)"
    }
  }
  Write-Host '-------------------------------'
  Write-Host "Lower Total Score " -NoNewline
  Write-Host -ForegroundColor Cyan "$LowScore"
  Write-Host "Upper Score " -NoNewline
  Write-Host -ForegroundColor Cyan "$UpTotalWithBonus"
  Write-Host "Grand Total Score " -NoNewline
  Write-Host -ForegroundColor Cyan "$GTScore"
  Write-Host '-------------------------------'
  Write-Host
}

function Show-Dice (
  [int[]]$DiceFaces,
  [int]$RollNumber
  ) {
  Write-Host -ForegroundColor DarkGreen  -BackgroundColor Gray 'Dice   ' -NoNewline
  Write-Host -ForegroundColor DarkGreen -BackgroundColor Gray "Roll Attempt: $RollNumber"
  Write-Host -ForegroundColor Cyan ' A    B    C    D    E'
  Write-Host -ForegroundColor Yellow -NoNewline '['
  Write-Host -ForegroundColor Yellow  ($DiceFaces -join "]  [") -NoNewline 
  Write-Host -ForegroundColor Yellow  "]"
}


#Main Code 
Clear-Host
$NewScoreObjects = 0..12 | ForEach-Object {[YahtzeeScore]::New($_)}
[YahtzeeCard]$MyScoreCard = [YahtzeeCard]::New($NewScoreObjects)
$DiceValues = Get-DiceRoll
$GameTurns = 0
do {
  $GameTurns++
  $DiceRollAttempts=0
  do {
    $DiceRollAttempts++
    Write-Debug 'Change Dice here $DiceValues'
    Show-ScoreCard -ScoreCard $MyScoreCard
    Show-Dice -DiceFaces $DiceValues -RollNumber $DiceRollAttempts
    if ($DiceRollAttempts -le 2) {
      Write-Host "Re-Roll which dice? " -NoNewline
      [Char[]]$DiceToReRoll = ((Read-Host) -replace '[^a-e]','').Trim().ToCharArray() | Select-Object -Unique | Sort-Object
      #Write-Debug 'after dice to reroll'
      if ($DiceToReRoll.Count -eq 0) {
        $Script:DiceRollAttempts = 2
        continue
      }
      else {
        foreach ($ReRoll in $DiceToReRoll) {
          $Index = ([byte][char]$ReRoll) - 97
          $DiceValues[$Index] = Get-DiceRoll -DiceCount 1
        }
      }
    }
    elseif ($DiceRollAttempts -eq 3) {
      do {
        Write-Host -ForegroundColor Green 'Which scoring category are you going to choose ' -NoNewline
        $ScoreCategory = ((Read-host).Trim().ToLower())  -replace '[^a-m]',''
        $ScoreIndex = ([byte][char]$ScoreCategory) - 97
      } until ($ScoreCategory -match '^[a-m]$' -and $MyScoreCard.Scores[$ScoreIndex].PlayCount -lt $MyScoreCard.Scores[$ScoreIndex].LegalPlayCount)
      $MyScoreCard.SetScore($ScoreIndex,$DiceValues)
      Write-Debug -Message 'After score set'
      $DiceValues = Get-DiceRoll
    }
  } until ($DiceRollAttempts -eq 3)
} until ($GameTurns -eq 13 )
Show-ScoreCard -ScoreCard $MyScoreCard
