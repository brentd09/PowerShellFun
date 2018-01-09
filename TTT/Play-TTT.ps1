<#
.SYNOPSIS
   Tic Tac Toe game
.DESCRIPTION
   
.EXAMPLE
   
.EXAMPLE
   
.INPUTS
   
.OUTPUTS
   
.NOTES
   
.FUNCTIONALITY
   
#>

function Draw-Board {
  Param ($Board)

  Clear-Host
  $Bdr = "  "
  Write-Host -ForegroundColor Yellow "${Bdr}Tic Tac Toe`n"
  Write-Host -NoNewline "$Bdr "
  Write-Host -NoNewline $Board[0]
  Write-Host -ForegroundColor Yellow -NoNewline " | "  
  write-host -NoNewline $Board[1]
  write-host -ForegroundColor Yellow -NoNewline " | "
  Write-Host $Board[2]
  Write-Host -ForegroundColor Yellow "${Bdr}---+---+---"
  Write-Host -NoNewline "$Bdr "
  Write-Host -NoNewline $Board[3]
  Write-Host -ForegroundColor Yellow -NoNewline " | "  
  write-host -NoNewline $Board[4]
  write-host -ForegroundColor Yellow -NoNewline " | "
  Write-Host $Board[5]
  Write-Host -ForegroundColor Yellow "${Bdr}---+---+---"
  Write-Host -NoNewline "$Bdr "
  Write-Host -NoNewline $Board[6]
  Write-Host -ForegroundColor Yellow -NoNewline " | "  
  write-host -NoNewline $Board[7]
  write-host -ForegroundColor Yellow -NoNewline " | "
  Write-Host $Board[8]
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
$Turn = "X"
do {
  $MainBoard = Pick-Location -Board $MainBoard -WhichTurn $Turn
  Draw-Board -Board $MainBoard
  if ($Turn -eq "X") {$Turn = "O"}
  else {$Turn = "X"} 
  $PossWin = Check-Winner -Board $MainBoard
} until ($MainBoard -notcontains " " -or $PossWin.Winner -eq $true)
if ($PossWin.Winner -eq $true) {
  Write-Host -ForegroundColor Green "The Winner is $($PossWin.WhichWin)"
}