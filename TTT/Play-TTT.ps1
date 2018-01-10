<#
.SYNOPSIS
   Tic Tac Toe game
.DESCRIPTION
   This is a standard Tic Tac Toe game, it is currently 
   run with two players hoever there are plans to add 
   some AI to this game so that you could play the 
   computer
.EXAMPLE
   Play-TTT 

   This launches the TTT game as a two player game 
.EXAMPLE
   Play-TTT  -Computer

   This launches the TTT game as a computer opponent
.Parameter Computer
   Computer is a switch parameter that tells the game 
   the computer should be the opponent.
.Notes
   Created
     By: Brent Denny
     On: 5 Jan 2018
#>
[CmdLetBinding()]
Param (
  [switch]$Computer
)

function Draw-Board {
  Param ($Board)

  Clear-Host
  $EntryColors = @('White','White','White','White','White','White','White','White','White')
  $GridColor = "Yellow"
  $XColor = "Red"
  $OColor = "white"
  $TitleCol = "Yellow"
  foreach ($Pos in (0..8)){
    if ($Board[$pos] -eq "X"){ $EntryColors[$Pos] = $XColor}
    if ($Board[$pos] -eq "O"){ $EntryColors[$Pos] = $OColor}
  }
  $Bdr = "  "
  Write-Host -ForegroundColor $GridColor "${Bdr}Tic Tac Toe`n"
  Write-Host -NoNewline "$Bdr "
  Write-Host -ForegroundColor $EntryColors[0] -NoNewline $Board[0]
  Write-Host -ForegroundColor $GridColor -NoNewline " | "  
  write-host -ForegroundColor $EntryColors[1] -NoNewline $Board[1]
  write-host -ForegroundColor $GridColor -NoNewline " | "
  Write-Host -ForegroundColor $EntryColors[2] $Board[2]
  Write-Host -ForegroundColor $GridColor "${Bdr}---+---+---"
  Write-Host -NoNewline "$Bdr "
  Write-Host -ForegroundColor $EntryColors[3] -NoNewline $Board[3]
  Write-Host -ForegroundColor $GridColor -NoNewline " | "  
  write-host -ForegroundColor $EntryColors[4] -NoNewline $Board[4]
  write-host -ForegroundColor $GridColor -NoNewline " | "
  Write-Host -ForegroundColor $EntryColors[5] $Board[5]
  Write-Host -ForegroundColor $GridColor "${Bdr}---+---+---"
  Write-Host -NoNewline "$Bdr "
  Write-Host -ForegroundColor $EntryColors[6] -NoNewline $Board[6]
  Write-Host -ForegroundColor $GridColor -NoNewline " | "  
  write-host -ForegroundColor $EntryColors[7] -NoNewline $Board[7]
  write-host -ForegroundColor $GridColor -NoNewline " | "
  Write-Host -ForegroundColor $EntryColors[8] $Board[8]
  Write-Host 
}

function Pick-Location {
  Param (
    $Board,
    $WhichTurn
  )
  do {
    Write-Host -ForegroundColor Yellow -NoNewline "Choose location to play $WhichTurn (1,2,3 top, 4,5,6 Middle, 7,8,9 bottom) "
    $Location = Read-Host 
    $arrayLoc = $Location - 1
  } until (1..9 -contains $Location -and $Board[$arrayLoc] -eq " ") 
  $Board[$arrayLoc] = $WhichTurn
  return $Board
}

function Check-Winner {
  Param (
    $Board
  )
  $Winner = $false
  $WhichWin = ' '
  foreach ($Col in (0..2)) {
    if ($Board[$col + 0] -eq $Board[$col + 1] -and $Board[$col + 0] -eq $Board[$col + 2] -and $Board[$col + 0] -match "[XO]") {
      $Winner = $true
      $WhichWin = $Board[$col + 0]
    }
    if ($Board[$col + 0] -eq $Board[$col + 3] -and $Board[$col + 0] -eq $Board[$col + 6] -and $Board[$col + 0] -match "[XO]" ) {
      $Winner = $true
      $WhichWin = $Board[$col + 0]
    }
  }
  if ($Board[0] -eq $Board[4] -and $Board[0] -eq $Board[8]  -and $Board[$col + 0] -match "[XO]" ) {
    $Winner = $true
    $WhichWin = $Board[$col + 0]
  }
  if ($Board[2] -eq $Board[4] -and $Board[2] -eq $Board[6] -and $Board[$col + 0] -match "[XO]" ) {
    $Winner = $true
    $WhichWin = $Board[$col + 0]
  }
  If ($Winner -eq $true) {
    $WinProp = @{
      Winner = $Winner
      WhichWin = $WhichWin
    }
    $WinObj = New-Object -TypeName psobject -Property $WinProp
    return $WinObj
  }
  else {
    $WinProp = @{
      Winner = $Winner
      WhichWin = $WhichWin
    }
    $WinObj = New-Object -TypeName psobject -Property $WinProp
    return $WinObj  
  }
}


##################################
#  MAIN CODE


$MainBoard = @(' ',' ',' ',' ',' ',' ',' ',' ',' ')
Draw-Board -Board $MainBoard
$Turn = @("X","O") | Get-Random
do {
  $MainBoard = Pick-Location -Board $MainBoard -WhichTurn $Turn
  Draw-Board -Board $MainBoard
  if ($Turn -eq "X") {$Turn = "O"}
  elseif ($Turn -eq "O") {$Turn = "X"} 
  $PossWin = Check-Winner -Board $MainBoard
} until ($MainBoard -notcontains " " -or $PossWin.Winner -eq $true)
if ($PossWin.Winner -eq $true) {
  Write-Host -ForegroundColor Green "The Winner is $($PossWin.WhichWin)"
}