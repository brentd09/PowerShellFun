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
  Write-Host -NoNewline "$Bdr "
  Write-Host -NoNewline $Board[0]
  Write-Host -NoNewline " | "  
  write-host -NoNewline $Board[1]
  write-host -NoNewline " | "
  Write-Host $Board[2]
  Write-Host "${Bdr}---+---+---"
  Write-Host -NoNewline "$Bdr "
  Write-Host -NoNewline $Board[3]
  Write-Host -NoNewline " | "  
  write-host -NoNewline $Board[4]
  write-host -NoNewline " | "
  Write-Host $Board[5]
  Write-Host "${Bdr}---+---+---"
  Write-Host -NoNewline "$Bdr "
  Write-Host -NoNewline $Board[6]
  Write-Host -NoNewline " | "  
  write-host -NoNewline $Board[7]
  write-host -NoNewline " | "
  Write-Host $Board[8]
  Write-Host 
}