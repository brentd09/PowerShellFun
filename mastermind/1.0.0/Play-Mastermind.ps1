[CmdletBinding()]
param ()

$SecretNumbers = 1..6 | Get-Random -Count 4

$GuessAttempts = 0
$Output = @()
Clear-Host
"MASTERMIND"
"# # # # - Secret numbers"  
"------------------------"
do {
# Ask player to choose 4 numbers from one to six and test for compliance 
  do {
    $ChosenNumbers = Read-Host "Please enter 4 numbers from 1 - 6"
    $ChosenAsCommaSep = $ChosenNumbers.ToCharArray() -join ',' -replace '\D+',','
    [int[]]$ChosenArray = $ChosenAsCommaSep -split ','
    $SortedArray = $ChosenArray | Sort-Object -Descending
  } while ($ChosenArray.Count -ne 4 -or $SortedArray[0] -gt 6 -or $SortedArray[-1] -lt 1) 
  $BlackPins = 0
  $WhitePins = 0
  foreach ($Index in @(0..3)) {
    if ($ChosenArray[$Index] -eq $SecretNumbers[$Index]) {$BlackPins++}
    elseif ($ChosenArray[$Index] -in $SecretNumbers) {$WhitePins++} 
  }
  $Output += "$ChosenArray - CorrectPositions=$BlackPins WrongPositions=$WhitePins"
  Clear-Host
  "MASTERMIND"
  "# # # # - Secret numbers"
  "------------------------"
  foreach ($Line in $Output) {
    Write-Host $Line
  }
  $GuessAttempts++
} Until ($BlackPins -eq 4 -or $GuessAttempts -ge 10)
if ($BlackPins -eq 4) {Write-Host "Congratulations! The secret numbers were $SecretNumbers"}
else {Write-Host "Sorry you did not guess the secret numbers, they were $SecretNumbers"}
