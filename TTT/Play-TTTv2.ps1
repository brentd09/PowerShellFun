[CmdletBinding()]
Param(
  [switch]$ComputerX = $true,
  [switch]$ComputerO = $true
)

Class TTTBoardCell {
  [int]$Pos
  [int]$Col
  [int]$Row
  [Int[]]$Diag # Diag = 0 => 0-5-8 , Diag = 1 => 2,5,6 , Diag = 9 => not on a diagonal
  [string]$Content
  [bool]$ThreatO
  [bool]$ThreatX
  [bool]$Winner
  [string]$StategicLocation 

  TTTBoardCell($Position) {
    $ColNum = $Position % 3
    $RowNum = [math]::Truncate($Position / 3)
    $this.Pos = $Position
    $this.Col = $ColNum
    $this.Row = $RowNum
    $this.Content = '-'
    if ($Position -in @(0,8)) {$this.Diag = @(0)}
    elseif ($Position -in @(2,6) ) {$this.Diag  = @(1)}
    elseif ($Position -eq 4) {$this.Diag = @(0,1)}
    else {$this.Diag = 9}
    $this.ThreatO = $false
    $this.ThreatX = $false
    $this.Winner = $false
    if ($Position -in @(0,2,6,8)) {$this.StategicLocation = 'Corner'}
    elseif ($Position -in @(1,3,5,7)) {$this.StategicLocation = 'Edge'}
    else {$this.StategicLocation = 'Middle'}
  }
   
  [bool]PlaceChoice([string]$Char) {
    if ($this.Content -eq '-') {
      $this.Content = $Char
      $this.ThreatO = $false
      $this.ThreatX = $false
      return $true
    }
    else {return $false}
  }
  
  [void]UpdateStatus([TTTBoardCell[]]$Board,[string]$TurnLetter) {
    $RowCells = $Board | Where-Object {$_.Row -eq $this.Row}
    $CountXinRow   = ($RowCells | Where-Object {$_.Content -eq 'X'}).Count
    $CountOinRow   = ($RowCells | Where-Object {$_.Content -eq 'O'}).Count
    $ColCells      = $Board | Where-Object {$_.Col -eq $this.Col}
    $CountXinCol   = ($ColCells | Where-Object {$_.Content -eq 'X'}).Count
    $CountOinCol   = ($ColCells | Where-Object {$_.Content -eq 'O'}).Count
    $DiagCells0    = $Board | Where-Object {$_.Diag -contains 0}
    $CountXinDiag0 = ($DiagCells0 | Where-Object {$_.Content -eq 'X'}).Count
    $CountOinDiag0 = ($DiagCells0 | Where-Object {$_.Content -eq 'O'}).Count
    $DiagCells1    = $Board | Where-Object {$_.Diag -contains 1}
    $CountXinDiag1 = ($DiagCells1 | Where-Object {$_.Content -eq 'X'}).Count
    $CountOinDiag1 = ($DiagCells1 | Where-Object {$_.Content -eq 'O'}).Count
    if ($this.Content -eq '-'){
      if ($CountXinRow -eq 2 ){$this.ThreatO = $true}
      if ($CountOinRow -eq 2 ){$this.ThreatX = $true}
      if ($CountXinCol -eq 2 ){$this.ThreatO = $true}
      if ($CountOinCol -eq 2 ){$this.ThreatX = $true}
      if ($this.Diag -contains 0) {
        if ($CountXinDiag0 -eq 2 ){$this.ThreatO = $true}
        if ($CountOinDiag0 -eq 2 ){$this.ThreatX = $true}
      }
      if ($this.Diag -contains 1) {
        if ($CountXinDiag1 -eq 2 ){$this.ThreatO = $true}
        if ($CountOinDiag1 -eq 2 ){$this.ThreatX = $true}
      }
    }
    else {
      $this.ThreatX = $false
      $this.ThreatO = $false
      #Check for winner
      if ($CountXinRow -eq 3) {$this.Winner = $true}
      if ($CountOinRow -eq 3) {$this.Winner = $true} 
      if ($CountXinCol -eq 3) {$this.Winner = $true}
      if ($CountOinCol -eq 3) {$this.Winner = $true}
      if ($this.Diag -contains 0) {
        if ($CountXinDiag0 -eq 3) {$this.Winner = $true}
        if ($CountOinDiag0 -eq 3) {$this.Winner = $true}
      }
      if ($this.Diag -contains 1) {
        if ($CountXinDiag1 -eq 3) {$this.Winner = $true}
        if ($CountOinDiag1 -eq 3) {$this.Winner = $true} 
      }
    }
  } #END DetectThreat Method
} #END Class

#Functions

function Find-BestMove {
  Param (
    [string]$TurnLetter,
    [TTTBoardCell[]]$Board,
    [int]$WhichTurn
  )
  if ($TurnLetter -eq 'X') {
    $Threats = $Board | Where-Object {$_.ThreatX -eq $true}
    if ($Threats.count -eq 1) {return [PSCustomObject]@{Index = $Threats[0].Pos}}
    else {
      $RandomEmpty = $Board | Where-Object {$_.content -eq '-' }| Get-Random
      return [PSCustomObject]@{Index = $RandomEmpty.Pos}
    }
  }
  If ($TurnLetter -eq 'O') {
    $Threats = $Board | Where-Object {$_.ThreatO -eq $true}
    if ($Threats.count -eq 1) {return [PSCustomObject]@{Index = $Threats[0].Pos}}
    else {
      $RandomEmpty = $Board | Where-Object {$_.content -eq '-'} | Get-Random
      return [PSCustomObject]@{Index = $RandomEmpty.Pos}
    }
  }
}
function Show-Board {
  Param ([TTTBoardCell[]]$Board,[string]$Padding='  ')

  Clear-Host
  $EntryColors = @('White','White','White','White','White','White','White','White','White')
  $ShowSqr = @(' ',' ',' ',' ',' ',' ',' ',' ',' ')
  $GridColor = "Yellow"
  $XColor = "Red"
  $OColor = "white"
  foreach ($Pos in (0..8)){
    if ($Board[$Pos].Content -eq "X") { $EntryColors[$Pos] = $XColor}
    if ($Board[$Pos].Content -eq "O") { $EntryColors[$Pos] = $OColor}
    if ($Board[$Pos].Content -eq "-") { $EntryColors[$Pos] = "darkgray"}
    if ($Board[$Pos].Content -match "[XO]") {$ShowSqr[$Pos] = $Board[$Pos].Content}
    else {$ShowSqr[$Pos] = $Pos + 1}
  }
  Write-Host -ForegroundColor 'Yellow' "`n${Padding}Tic Tac Toe`n"
  Write-Host -NoNewline "$Padding "
  Write-Host -ForegroundColor $EntryColors[0] -NoNewline $ShowSqr[0]
  Write-Host -ForegroundColor $GridColor -NoNewline " | "  
  write-host -ForegroundColor $EntryColors[1] -NoNewline $ShowSqr[1]
  write-host -ForegroundColor $GridColor -NoNewline " | "
  Write-Host -ForegroundColor $EntryColors[2] $ShowSqr[2]
  Write-Host -ForegroundColor $GridColor "${Padding}---+---+---"
  Write-Host -NoNewline "$Padding "
  Write-Host -ForegroundColor $EntryColors[3] -NoNewline $ShowSqr[3]
  Write-Host -ForegroundColor $GridColor -NoNewline " | "  
  write-host -ForegroundColor $EntryColors[4] -NoNewline $ShowSqr[4]
  write-host -ForegroundColor $GridColor -NoNewline " | "
  Write-Host -ForegroundColor $EntryColors[5] $ShowSqr[5]
  Write-Host -ForegroundColor $GridColor "${Padding}---+---+---"
  Write-Host -NoNewline "$Padding "
  Write-Host -ForegroundColor $EntryColors[6] -NoNewline $ShowSqr[6]
  Write-Host -ForegroundColor $GridColor -NoNewline " | "  
  write-host -ForegroundColor $EntryColors[7] -NoNewline $ShowSqr[7]
  write-host -ForegroundColor $GridColor -NoNewline " | "
  Write-Host -ForegroundColor $EntryColors[8] $ShowSqr[8]
  Write-Host 
}

#Main code
Clear-Host
$AIGameHistory = Get-content C:\GameHistory.json | ConvertFrom-Json
[TTTBoardCell[]]$TTTBoard = foreach ($Pos in (0..8)) {[TTTBoardCell]::New($Pos)}
Show-Board -Board $TTTBoard
$Turn = 'X'
$TurnCount = 1
[string]$TurnHistory = $null
do {
  if (($Turn -eq 'X' -and $ComputerX -eq $true) -or ($Turn -eq 'O' -and $ComputerO -eq $true)) {
    $BestMove = Find-BestMove -TurnLetter $Turn -Board $TTTBoard -WhichTurn $TurnCount
    $TTTBoard[$BestMove.index].PlaceChoice($Turn)
    $TurnHistory = $TurnHistory + ($BestMove.Index -as [string])
  }
  else {
    do {
      $BadChoice = $false
      $BoardChoice = Read-Host "$Turn's turn - Enter the choice"
      if ($BoardChoice -notmatch '^[1-9]$') {$BadChoice = $true}
      else {[int]$ChoiceIndex = ($BoardChoice -as [int]) -1}
    } until ($TTTBoard[$ChoiceIndex].PlaceChoice($Turn) -and $BadChoice -eq $false)
    $TurnHistory = $TurnHistory + ($ChoiceIndex -as [string])
  }
  Show-Board -Board $TTTBoard
  $TTTBoard | ForEach-Object {$_.UpdateStatus($TTTBoard,$Turn)}
  $TTTBoard | Format-Table
  $TurnHistory
  $Turn = @('X','O') | Where-Object {$_ -ne $Turn}
  $TurnCount++
} until ($TTTBoard.Content -notcontains '-' -or $TTTBoard.Winner -contains $true)
$WinningCells = $TTTBoard | Where-Object {$_.Winner -contains $true}
if ($WinningCells.count -eq 3) {$Winner = $WinningCells[0].Content}
else {$Winner = 'D'}
write-host "Winner is $Winner"
$GameObj = [PSCustomObject]@{Moves = $TurnHistory;Result = $Winner}
$AIGameHistory.GamePlays += $GameObj
$AIGameHistory | ConvertTo-Json | Out-File -FilePath C:\GameHistory.json


<#
[PsCustomObject[]]$c1 = @()
$c1 += [PSCustomObject]@{Moves = '0148356';Result = 'X'}
$c1 += [PSCustomObject]@{Moves = '0845216';Result = 'X'}
$c1 += [PSCustomObject]@{Moves = '048536217';Result = 'D'}
$c2 = [PSCustomObject]@{Moves = '048536271';Result = 'O'}
$hash = [ordered]@{
  GamePlays = $c1
}
New-Object -TypeName psobject -Property $hash | ConvertTo-Json | Out-File c:\GameHistory.json

$History = Get-Content C:\GameHistory.json | ConvertFrom-Json
$History.GamePlays += $c2
#>