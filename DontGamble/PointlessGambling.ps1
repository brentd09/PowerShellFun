# Martingale Strategy for winning at a mathmatically fair casino
# If the chances are truly 50-50 % win-lose then doubling your bet on each loss 
# will eventually win you the same amount you started betting effectively netting
# you twice your original bet

function Test-GambleTheory {
  [cmdletbinding()]
  Param (
    [int]$StartingBet = 1,
    [string]$BetChoice = 'Black',
    [ValidateRange(0,3)]
    [int]$GreenNumbers = 3
  )
  $RedNumbers =   @('1','3','5','7', '9','12','14','16','18','19','21','23','25','27','30','32','34','36')
  $BlackNumbers = @('2','4','6','8','10','11','13','15','17','20','22','24','26','28','29','31','33','35')
  switch ($GreenNumbers) {
      0 {$AllNumbers = $RedNumbers + $BlackNumbers}
      1 {$AllNumbers = $RedNumbers + $BlackNumbers + '0'}
      2 {$AllNumbers = $RedNumbers + $BlackNumbers + '0' + '00'}
      3 {$AllNumbers = $RedNumbers + $BlackNumbers + '0' + '00' + '000'}
      Default {
        Write-Warning "there are too many green numbers"
        break
      }
  }
  Write-Verbose "All => $AllNumbers"
  $Turns = 0
  $TotalLoss = 0
  $CurrentBet = $StartingBet
  $FirstLoss = $true
  do {
    $Turns++
    $NumberSpun = $AllNumbers | Get-Random
    if ($NumberSpun -in $RedNumbers) {$RouletteResult = 'Red'}
    elseif ($NumberSpun -in $BlackNumbers) {$RouletteResult = 'Black'}
    else {$RouletteResult = 'Green'}
    if ($RouletteResult -eq $BetChoice) {
      $BetReturn = $CurrentBet
      $Win = $true      
      $NetWin = $BetReturn - $TotalLoss
      Write-Host
      Write-Host -ForegroundColor Green ("WINNER--> {0,6} {1,12} {2,12} {3,7} {4,7}" -f 'Turn','Bet Return','Net Win', 'Color','Number')
      Write-Host -ForegroundColor Green ("          {0,6} {1,12} {2,12} {3,7} {4,7}" -f '----','----------','-------', '-----','------')
      Write-Host -ForegroundColor Green ("          {0,6} {1,12} {2,12} {3,7} {4,7}" -f $Turns, $BetReturn, $NetWin, $RouletteResult, $NumberSpun)
    }
    else {
      $TotalLoss = $TotalLoss + $CurrentBet
      If ($FirstLoss -eq $true) {
        Write-Host -ForegroundColor Yellow ("LOSE-->   {0,6} {1,12} {2,12} {3,7} {4,7}" -f 'Turn','Current Bet','Total Loss', 'Color','Number')
        Write-Host -ForegroundColor Yellow ("          {0,6} {1,12} {2,12} {3,7} {4,7}" -f '----','-----------','----------', '-----','------')
        $FirstLoss = $false
      }
      Write-Host -ForegroundColor Yellow ("          {0,6} {1,12} {2,12} {3,7} {4,7}" -f  $Turns, $CurrentBet, $TotalLoss, $RouletteResult, $NumberSpun)
      $CurrentBet = $CurrentBet * 2
    }
  } until ($Win -eq $true)
}
Test-GambleTheory -GreenNumbers 3 -Verbose
