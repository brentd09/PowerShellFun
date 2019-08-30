Class TTTBoardCell {
  [int]$Pos
  [int]$Col
  [int]$Row
  [Int]$Diag # Diag 0 = 0-5-8 , Diag 1 = 2,5,6
  [string]$Content

  TTTBoardCell($Position) {
    $this.BackDiag = $false
    $this.FwdDiag  = $false
    $ColNum = $Position % 3
    $RowNum = [math]::Truncate($Position / 3)
    $this.Pos = $Position
    $this.Col = $ColNum
    $this.Row = $RowNum
    $this.Content = '-'
    if ($Position -in @(0,5,8) ) {$this.Diag = 0}
    if ($Position -in @(2,5,6) ) {$this.Diag  = 1}
  }
   
  [bool]PlaceChoice([string]$Char) {
    if ($this.Content -eq '-') {
      $this.Content = $Char
      return $true
    }
    else {return $false}
  }
  
  [psobject]RowThreats([TTTBoardCell[]]$Board,[string]$TurnLetter) {
    $OppositeLetter = @('X','O') | Where-Object {$_ -ne $TurnLetter}
    foreach ($Index in (0..2)) {
      $RowObjects = $Board | Where-Object {$_.Row -eq $Index}
      $NumberOfBlanks = ($RowObjects | Group-Object | Where-Object {$_.Content -eq '-'}).count
      if ($NumberOfBlanks -eq 1) {
        $NumberOfOpposite = ($RowObjects | Group-Object | Where-Object {$_.Content -eq $OppositeLetter[0]}).count
        if ($NumberOfOpposite -eq 2) {
          $ThreatRowProp = @{
            ThreatReal = $true
            RowIndexUnderThreat = $Index
            EmptyPos = ($RowObjects | Where-Object {$_.Content -eq '-' }).Pos
          }
        }
        else {
          $ThreatRowProp = @{
            ThreatReal = $false
            RowIndexUnderThreat = $Index
            EmptyPos = ($RowObjects | Where-Object {$_.Content -eq '-' }).Pos
          }         
        }
      } #end if
      New-Object -TypeName psobject -Property $ThreatRowProp
    } #end foreach
  } #end Method
} #END Class

#Main code

[TTTBoardCell[]]$TTTBoard = foreach ($Pos in (0..8)) {[TTTBoardCell]::New($Pos)}
do {
  $BoardChoice = Read-Host 'Enter the choice'
  $Pos = $BoardChoice -as [int]
} until ($true)
$TTTBoard[1].PlaceChoice('X')
$TTTBoard[0].PlaceChoice('X')

$TTTBoard | ft 