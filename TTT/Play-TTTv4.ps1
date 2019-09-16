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
Param(
  [switch]$HumanPlayers
)

# CLASSES

Class TTTCell {
  [int]$Position
  [string]$Value
  [hashtable]$RowColDiag
  [bool]$Empty

  TTTCell($Pos) {
    $this.Position = $Pos
    $this.Value = ($Pos) -as [String]
    $ColNum = $Pos % 3
    $RowNum = [math]::Truncate($Pos / 3)
    if ($Pos -in @(0,8)) {$DiagNum = @(0)}
    elseif ($Pos -in @(2,6) ) {$DiagNum  = @(1)}
    elseif ($Pos -eq 4) {$DiagNum = @(0,1)}
    else {$DiagNum = @(9)}  
    $Hash = @{
      Col = $ColNum
      Row = $RowNum
      Diag = $DiagNum
    }  
    $this.RowColDiag = $Hash
    $this.Empty = $true
  }
} #END TTTCell class

Class TTTBoard {
  [TTTCell[]]$TTTCells
  [string]$GameState # Running / Ended
  [string]$Winner # X - X Wins / O - O Wins / D - Draw / N - none yet
  [int[]]$EmptyCellIndexes

  TTTBoard () {
    foreach ($Pos in (0..8) ) {
      $this.TTTCells += [TTTCell]::New($Pos)
    }
    $this.GameState = 'Running'
    $this.EmptyCellIndexes = 0..8
  }

  [string]CheckWinLose($TurnLetter) {
    [hashtable[]]$WiningLines = @(@{Array=0,1,2},@{Array=3,4,5},
                                  @{Array=6,7,8},@{Array=0,3,6},
                                  @{Array=1,4,7},@{Array=2,5,8},
                                  @{Array=0,4,8},@{Array=2,4,6} 
    )
    foreach ($WiningLine in $WiningLines) {
      $Cell1 = $this.TTTCells[$WiningLine.Array[0]].Value
      $Cell2 = $this.TTTCells[$WiningLine.Array[1]].Value 
      $Cell3 = $this.TTTCells[$WiningLine.Array[2]].Value 
      if ($Cell1 -eq $Cell2 -and $Cell2 -eq $Cell3) {
        if ($Cell1 -eq $TurnLetter) {
          $this.GameState = 'Ended'
          $this.Winner = $Cell1
          return 'Win'        
        }
        else {
          $this.GameState = 'Ended'
          $this.Winner = $Cell1
          return 'Lose'
        }
      }
    }
    return 'NoWinner'
  }

  [string]CheckDraw() { 
    [hashtable[]]$WiningLines = @(@{Array=0,1,2},@{Array=3,4,5},
                                @{Array=6,7,8},@{Array=0,3,6},
                                @{Array=1,4,7},@{Array=2,5,8},
                                @{Array=0,4,8},@{Array=2,4,6} 
    )
    [bool]$WinnerFound = $false
    foreach ($WiningLine in $WiningLines) {
      $Cell1 = $this.TTTCells[$WiningLine.Array[0]].Value
      $Cell2 = $this.TTTCells[$WiningLine.Array[1]].Value 
      $Cell3 = $this.TTTCells[$WiningLine.Array[2]].Value 
      if ($Cell1 -eq $Cell2 -and $Cell2 -eq $Cell3) {$WinnerFound = $true;break}
      else {$WinnerFound = $false}
    }
    if ($WinnerFound -eq $false -and ($this.TTTCells.Empty | Where-Object {$_ -eq $false}).Count -eq 9) {
      $this.GameState = 'Ended'
      $this.Winner = 'D'
      return 'Draw'
    }
    else {return 'NoDraw'}
  }

  [void]FindEmptyCells() {
    [int[]]$Empties = @()
    foreach ($Cell in $this.TTTCells) {
      if ($Cell.Value -notin ('X','O')) {
        $Empties += $Cell.Position
        $this.TTTCells[$Cell.Position].Empty = $true
      }
      else {$this.TTTCells[$Cell.Position].Empty = $false}
    }
    if ($Empties.Count -gt 0) {$This.EmptyCellIndexes = $Empties}
  }

  [bool]PlayCell ($Index, $Player) {
    if ($this.TTTCells[$Index].Empty) {
      $this.TTTCells[$Index].Value = $Player
      $this.TTTCells[$Index].Empty = $false
      $this.FindEmptyCells()
      $this.CheckDraw()
      $this.CheckWinLose($Player)
      return $true
    }
    else {return $false}
  }
} #END TTTBoard Class 

# functions
function Show-Board {
  Param ([TTTBoard]$Board,[string]$Padding='  ')

  #Clear-Host
  $EntryColors = @('White','White','White','White','White','White','White','White','White')
  $ShowSqr = @(' ',' ',' ',' ',' ',' ',' ',' ',' ')
  $GridColor = "Yellow"
  $XColor = "Red"
  $OColor = "Green"
  $EmptyColor = 'DarkGray'
  foreach ($Pos in (0..8)){
    if ($Board.TTTCells[$Pos].Value -eq "X") { $EntryColors[$Pos] = $XColor}
    if ($Board.TTTCells[$Pos].Value -eq "O") { $EntryColors[$Pos] = $OColor}
    if ($Board.TTTCells[$Pos].Value -notin ('X','O')) { $EntryColors[$Pos] = $EmptyColor}
    if ($Board.TTTCells[$Pos].Value -in ('X','O')) {$ShowSqr[$Pos] = $Board.TTTCells[$Pos].value}
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
} # END function ShowBoard
function Get-MiniMaxIndex { # This DOES NOT WORK
  Param ([TTTBoard]$OrigBoard,[string]$TurnLetter)
  $HumanPlayer = 'O' ; $ComputerPlayer = 'X'
  If ($TurnLetter -eq $ComputerPlayer) {$OtherLetter = $HumanPlayer} else {$OtherLetter = $ComputerPlayer}
  $Hash = @{}
  $OrigBoard.psobject.properties | ForEach-Object {$Hash.Add($_.name,$_.Value)}
  [tttBoard]$CopyBoard = New-Object -TypeName TTTBoard -Property $Hash
  $CopyBoard.FindEmptyCells()
  $EmptyCells = $CopyBoard.EmptyCellIndexes
  $CopyBoard.CheckWinLose($TurnLetter)
  $CopyBoard.CheckDraw()
  if ($CopyBoard.Winner -eq $ComputerPlayer ) {return @{Score = [int](10)}}
  elseif ($CopyBoard.Winner -eq $HumanPlayer) {return ${Score = [int](-10)}} 
  elseif ($CopyBoard.Winner -eq 'D') {return @{Score = [int](0)}}
  [System.Collections.ArrayList]$Moves = @()
  foreach ($Counter in (0..$EmptyCells.Count)) {
    $Move = @{Index = $CopyBoard.TTTCells[$EmptyCells[$Counter]].Position}
    $CopyBoard.PlayCell($Move.Index,$TurnLetter)
    if ($TurnLetter -eq $ComputerPlayer) {
      $Result = Get-MiniMaxIndex($CopyBoard,$HumanPlayer)
      $Move.Add('Score',$Result.Score)
    } 
    else {
      $Result = Get-MiniMaxIndex($CopyBoard,$ComputerPlayer)
      $Move.Add('Score',$Result.Score)      
    }
    $HashBack = @{}
    $CopyBoard.psobject.properties | ForEach-Object {$HashBack.Add($_.name,$_.Value)}
    [tttBoard]$OrigBoard = New-Object -TypeName TTTBoard -Property $Hash
    $Moves.Add($Move)
  }
  if ($TurnLetter -eq $ComputerPlayer) {
    $BestScore = -10000
    0..($moves.Count) | ForEach-Object {
      if ($Moves[$_].Score -gt $BestScore) {
        $BestScore = $Moves[$_].Score
        $BestMove = $_
      }
    }
  }
  else {
    $BestScore = 10000
    0..($moves.Count) | ForEach-Object {
      if ($Moves[$_].Score -lt $BestScore) {
        $BestScore = $Moves[$_].Score
        $BestMove = $_
      }
    }
  }
  return $Moves[$BestMove]
} # END function MiniMaxIndex

# Main Code
$Board = [TTTBoard]::New()
Show-Board -Board $Board
$PlayerXO = 'X'
do { # loop until game ended
  switch ($PlayerXO) {
    'X' { $TurnColor = 'Red' }
    'O' {$TurnColor = 'Green'}
  }
  if (($PlayerXO -eq 'X' -and $HumanPlayers -eq $true) -or $PlayerXO -eq 'O') {
    do { # loop until a good choice is made
      $GoodChoice = $true 
      try {$ErrorActionPreference = 'Stop'; [int]$Choice = Read-Host -Prompt "Enter an empty position number (Player $PlayerXO)"}
      catch {$GoodChoice = $false; continue}
      finally {$ErrorActionPreference = 'Continue'}
      if ($Choice -gt 9 -or $Choice -lt 1) {$GoodChoice = $false;continue}
      else {$PlayCellSuccess = $Board.PlayCell($Choice-1,$PlayerXO)}
    } until ($GoodChoice -eq $true -and $PlayCellSuccess -eq $true )
  }
  elseif ($PlayerXO -eq 'X' -and $HumanPlayers -eq $false) { # Computer chooses for X
    $IndexX = (Get-MiniMaxIndex -OrigBoard $Board -TurnLetter $PlayerXO)[0]
    $Board.PlayCell($IndexX,$PlayerXO) > $null
  }
  Show-Board -Board $Board
  if ($PlayerXO -eq 'X') {$PlayerXO = 'O'} else {$PlayerXO = 'X'}
} until ($Board.GameState -eq 'Ended')
if ($Board.Winner -in ('X','O')) {Write-Host -ForegroundColor $TurnColor 'The winner is '$Board.Winner}
else {write-host -ForegroundColor DarkMagenta 'The game is a draw'}
break
