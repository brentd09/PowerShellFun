

# Class definitions

Class ThreatList {
  [int[]]$XThreats
  [int[]]$OThreats

  ThreatList () {
    $this.XThreats = @()
    $this.OThreats = @()
  }
}

Class TTTBoardCell {
  [int]$Position
  [string]$Value 
  [bool]$Played

  TTTBoardCell ([int]$ArrayPos) {
    $this.Position = $ArrayPos
    $this.Value = ($ArrayPos + 1) -as [string]
    $this.Played = $false
  }

  [bool]PlayCell ([string]$XorO) {
    if ($this.Played -eq $true -or $XorO -notin @('X','O')) {return $false}
    else {
      $this.Played = $true
      $this.Value = $XorO.ToUpper()
      return $true
    }
  }
}

class TTTBoard {
  [TTTBoardCell[]]$Cells

  TTTBoard () {
    $this.Cells = foreach ($Pos in (0..8)) { [TTTBoardCell]::New($Pos)}
  }

  [string]TestWin () {
    [System.Collections.ArrayList]$WinningLines = @(
      @(0,1,2),@(3,4,5),@(6,7,8),
      @(0,3,6),@(1,4,7),@(2,5,8),
      @(0,4,8),@(2,4,6)
    )
    [string]$Win = 'N'
    foreach ($Line in $WinningLines) {
      [string[]]$XsInLine = ($this.Cells[$Line].Value) -eq 'X'
      [string[]]$OsInLine = ($this.Cells[$Line].Value) -eq 'O'
      if ($XsInLine.Count -eq 3) {$Win = 'X'}
      if ($OsInLine.Count -eq 3) {$Win = 'O'}
      if ($Win -ne 'N') {break}
    }
    return $Win
  }

  [ThreatList]TestThreat () {
    [System.Collections.ArrayList]$WinningLines = @(
      @(0,1,2),@(3,4,5),@(6,7,8),
      @(0,3,6),@(1,4,7),@(2,5,8),
      @(0,4,8),@(2,4,6)
    )
    $Threats = [ThreatList]::new()
    foreach ($Line in $WinningLines) {
      [string[]]$XsInLine = ($this.Cells[$Line].Value) -eq 'X'
      [string[]]$OsInLine = ($this.Cells[$Line].Value) -eq 'O'
      if ($XsInLine.count -eq 2 -and $OsInLine.Count -eq 0) {
        $ThreatPosString = ($this.Cells[$Line].Value) -ne 'X'
        $ThreatPos = ($ThreatPosString[0] -as [int]) -1
        $Threats.XThreats += $ThreatPos
      }
      if ($OsInLine.Count -eq 2 -and $XsInLine.Count -eq 0) {
        $ThreatPosString = ($this.Cells[$Line].Value) -ne 'O'
        $ThreatPos = ($ThreatPosString[0] -as [int]) -1
        $Threats.OThreats += $ThreatPos
      }
    }
    return $Threats
  }
}

# Functions

function Show-Board {
  Param (
    [TTTBoard]$GameBoard,
    [string]$Padding = "  ",
    [string]$GridColor = "Cyan",
    [string]$XColor    = "Red",
    [string]$OColor    = "Yellow",
    [string]$TitleCol  = "Green",
    $TermState,
    [switch]$Final
  )
  Clear-Host
  $EntryColors = @('White','White','White','White','White','White','White','White','White')
  $ShowSqr = @(' ',' ',' ',' ',' ',' ',' ',' ',' ')

  foreach ($Pos in (0..8)){
    if ($GameBoard.Cells[$Pos].Value -eq "X") { $EntryColors[$Pos] = $XColor}
    if ($GameBoard.Cells[$Pos].Value -eq "O") { $EntryColors[$Pos] = $OColor}
    if ($GameBoard.Cells[$Pos].Value -eq " ") { $EntryColors[$Pos] = "darkgray"}
    if ($GameBoard.Cells[$Pos].Value -match "[XO]") {$ShowSqr[$Pos] = $GameBoard.Cells[$Pos].Value}
    elseif ($TermState -in @('X','O')) {$ShowSqr[$Pos] = ' '}
    else {$ShowSqr[$Pos] = $Pos + 1}
  }
  if ($Final -eq $false) {Write-Host -ForegroundColor $TitleCol "`n${Padding}Tic Tac Toe`n"}
  else {
    Write-Host -NoNewline -ForegroundColor $TitleCol "`n${Padding}Tic Tac Toe    "
    switch ($Winner) {
      'N' {Write-Host -ForegroundColor Gray -NoNewline 'Game: '; Write-Host -ForegroundColor Gray   'Draw'}
      'O' {Write-Host -ForegroundColor Gray -NoNewline 'Game: '; Write-Host -ForegroundColor Yellow 'O'}
      'X' {Write-Host -ForegroundColor Gray -NoNewline 'Game: '; Write-Host -ForegroundColor Red    'X'}
      Default {}
    }
    Write-Host ""
  }
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
}#END ShowBoard

Function Test-TerminalState {
  Param (
    [TTTBoard]$GameBoard
  )
  [System.Collections.ArrayList]$WinningLines = @(
    @(0,1,2),@(3,4,5),@(6,7,8),
    @(0,3,6),@(1,4,7),@(2,5,8),
    @(0,4,8),@(2,4,6)
  )
  foreach ($Line in $WinningLines) {
    # Check to see if all three places have the same Value (X or O)
  
  }
}

function Find-BestMove {
  Param ($GameBoard)
  $WinningIndexes = ($GameBoard.TestThreat()).XThreats
  $GameTurns = ($GameBoard.Cells | Where-Object {$_.Played -eq $true}).Count
  if ($GameTurns -eq 0) {$Index = 0,2,6,8 | Get-Random}
  elseif ($GameTurns -eq 1) {
    if ($GameBoard.Cells[4].Played -eq $false) {$Index = 4}
    else {$Index = 0,2,6,8 | Get-Random}
  } 
  elseif ($GameTurns -eq 2) {
    if ($GameBoard.Cells[4].Played -eq $false) {$Index = 4}
    else {
      $FirstX = $GameBoard.Cells | Where-Object {$_.Value -eq 'X'}
      $NonPlayed = $GameBoard.Cells | Where-Object {$_.Played -eq $false}
      if ($FirstX.Position -eq 0 -and $NonPlayed.Position -contains 8) {$Index = 8}
      elseif ($FirstX.Position -eq 8 -and $NonPlayed.Position -contains 0) {$Index = 0}
      elseif ($FirstX.Position -eq 2 -and $NonPlayed.Position -contains 6) {$Index = 6}
      elseif ($FirstX.Position -eq 6 -and $NonPlayed.Position -contains 2) {$Index = 2}
      else {$Index = $NonPlayed.Position | Get-Random}
    } 
  }
  elseif ($GameTurns -ge 3) {
    $OPositions = $GameBoard.Cells | Where-Object {$_.Value -eq 'O'}
    if (($OPositions.Position -contains 0 -and $OPositions.Position -contains 8 -and $GameBoard.Cells[4].Value -eq 'X') -or
    ($OPositions.Position -contains 2 -and $OPositions.Position -contains 6 -and $GameBoard.Cells[4].Value -eq 'X')) {
      $Index = 1,3,5,7 | Get-Random
    }
    # still need to check for opponent in a corner and side placement 
    if ($WinningIndexes -ge 1) {
      $Index = $WinningIndexes | Get-Random
    }
    else {
      $OpponentThreats = ($GameBoard.TestThreat()).OThreats
      If ($OpponentThreats.Count -eq 1) {
        $Index = $OpponentThreats[0]
      }
      elseif ($OpponentThreats.Count -gt 1) {
        $Index = $OpponentThreats | Get-Random
      }
      else {
        $UnplayedCells = $GameBoard.Cells | Where-Object {$_.Played -eq $false}
        $RandomPick = $UnplayedCells | Get-Random
        $Index = $RandomPick.Position
      }
    }
  }
  $GameBoard.Cells[$Index].PlayCell('X')
}

#Main code
$Board = [TTTBoard]::New()
[string]$Turn = 'X','O' | Get-Random
do {
  Show-Board -GameBoard $Board
  if ($Turn -eq 'X') {Find-BestMove -GameBoard $Board}
  else {
    do {
      $Index = Read-Host "Please enter a number - ${Turn}'s Turn"
      $TurnResult = $Board.Cells[$Index-1].PlayCell($Turn)
    } until ($TurnResult -eq $true) 
  }   
  $Turn = @('X','O') | Where-Object {$_ -ne $Turn}
  $Threats = $Board.TestThreat()
  $Winner = $Board.TestWin()
  # $Threats
  # Start-Sleep -sec 2
} until ($Board.Cells.Played -notcontains $false -or $Winner -ne 'N')  
Show-Board -GameBoard $Board -Termstate $Winner -Final
