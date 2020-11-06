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
        $RelevantDice = $DiceGroup.Count
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
        $ValuesInRow = $Position - 5
        $UniqueDiceSorted = $DiceValues |  Select-Object -Unique | Sort-Object 
        $UniqueDiceSortedCount = $UniqueDiceSorted.Count
        if ($UniqueDiceSortedCount -lt 4) {$PositionScore = 0}
        else {
          $SeqCount = 0
          foreach ($Index in @(0..$UniqueDiceSortedCount-2)) {
            if ($DiceValues[$Index] -eq $DiceValues[$Index+1] - 1) {$SeqCount++}
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
          else {$YahtzeeScore = 100}
          $PositionScore = $YahtzeeScore
          $this.Scores[$Position].Value = $this.Scores[$Position].Value + $PositionScore
          $this.Scores[$Position].PlayCount++ 
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
    [YahtzeeCard]$ScoreCard,
    [int[]]$DiceValues,
    [int]$RollAttempt
  )
  #Clear-Host
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
  Write-host 'UPPER SECTION'
  foreach ($Index in @(0..5)) {
    Write-Host -ForegroundColor Green $MyScoreCard.Scores[$Index].Label -NoNewline
    if ($ScoreCard.Scores[$Index].PlayCount -eq 0) {Write-host "$($ScoreCard.Scores[$Index].Name)"}
    else {Write-host "$($ScoreCard.Scores[$Index].Name) $($ScoreCard.Scores[$Index].Value)"}
  }
  Write-Host '-------------------------------'
  Write-Host "Total Score $UpTotal" 
  Write-Host "BONUS $Bonus"
  Write-Host "Upper Score $UPTotalWithBonus"
  Write-Host '-------------------------------'
  Write-Host "LOWER SECTION"
  foreach ($Index in @(6..12)) {
    Write-Host -ForegroundColor Green $MyScoreCard.Scores[$Index].Label -NoNewline
    if ($ScoreCard.Scores[$Index].PlayCount -eq 0) {Write-host "$($ScoreCard.Scores[$Index].Name)"}
    else {Write-host "$($ScoreCard.Scores[$Index].Name) $($ScoreCard.Scores[$Index].Value)"}
  }
  Write-Host '-------------------------------'
  Write-Host "Lower Total Score $LowScore"
  Write-Host "Upper Score $UpTotalWithBonus"
  Write-Host "Grand Total Score $GTScore"
  Write-Host '-------------------------------'
  Write-Host
  Write-Host -ForegroundColor Gray 'Dice   ' -NoNewline
  Write-Host -ForegroundColor Cyan "Roll Attempt: $RollAttempt"
  Write-Host -ForegroundColor Cyan ' A    B    C    D    E'
  Write-Host -ForegroundColor Yellow -NoNewline '['
  Write-Host -ForegroundColor Yellow  ($DiceValues -join "]  [") -NoNewline 
  Write-Host -ForegroundColor Yellow  "]"


}


#Main Code 
Clear-Host
$NewScoreObjects = 0..12 | ForEach-Object {[YahtzeeScore]::New($_)}
[YahtzeeCard]$MyScoreCard = [YahtzeeCard]::New($NewScoreObjects)
$DiceValues = Get-DiceRoll
do {
  Show-ScoreCard -ScoreCard $MyScoreCard -DiceValues $DiceValues
  Read-Host "wow"
} until ($false)