# Martingale Strategy for winning at a mathmatically fair casino
# If the chances are truly 50-50 % win-lose then doubling your bet on each loss 
# will eventually win you the same amount you started betting effectively netting
# you twice your original bet

function Test-GambleTheory {
  [cmdletbinding()]
  Param (
    [int]$StartingBet = 500,
    [string]$BetChoice = 'Black',
    [ValidateRange(1,2)]
    [int]$GreenNumbers = 2
  )
  $RedNumbers =   @('1','3','5','7', '9','12','14','16','18','19','21','23','25','27','30','32','34','36')
  $BlackNumbers = @('2','4','6','8','10','11','13','15','17','20','22','24','26','28','29','31','33','35')
  switch ($GreenNumbers) {
      0 {$AllNumbers = $RedNumbers + $BlackNumbers}
      1 {$AllNumbers = $RedNumbers + $BlackNumbers + '0'}
      2 {$AllNumbers = $RedNumbers + $BlackNumbers + '0' + '00'}
      Default {
        Write-Warning "there are too many green numbers"
        break
      }
  }
  Write-Verbose "All => $AllNumbers"
  $Turns = 0
  [int]$TotalLoss = 0
  $CurrentBet = $StartingBet
  $NetWin = 0
  $BetReturn = 0
  Write-Host  ("{0,6} {1,12} {2,12} {3,12} {4,12} {5,7} {6,7}" -f 'Turn','Current Bet','Bet Return','Total Loss','Net Win','Color','Number')
  Write-Host  ("{0,6} {1,12} {2,12} {3,12} {4,12} {5,7} {6,7}" -f '----','-----------','----------','----------','-------','-----','------')
  do {
    Start-Sleep -Seconds 1
    $Turns++
    $NumberSpun = $AllNumbers | Get-Random
    if ($NumberSpun -in $RedNumbers) {$RouletteResult = 'Red'}
    elseif ($NumberSpun -in $BlackNumbers) {$RouletteResult = 'Black'}
    else {$RouletteResult = 'Green'}
    if ($RouletteResult -eq $BetChoice) {
      $BetReturn = $CurrentBet
      $Win = $true      
      $NetWin = $BetReturn - $TotalLoss
      Write-Host -ForegroundColor Green ("{0,6} {1,12} {2,12} {3,12} {4,12} {5,7} {6,7}" -f $Turns,$CurrentBet, $BetReturn, $TotalLoss, $NetWin, $RouletteResult, $NumberSpun)
      Write-Host
      Write-Host

    }
    else {
      $TotalLoss = $TotalLoss + $CurrentBet
      Write-Host -ForegroundColor Red ("{0,6} {1,12} {2,12} {3,12} {4,12} {5,7} {6,7}" -f $Turns,$CurrentBet, $BetReturn, $TotalLoss, $NetWin, $RouletteResult, $NumberSpun)    }
      $CurrentBet += $CurrentBet
  } until ($Win -eq $true)
}
Test-GambleTheory -GreenNumbers 2 
