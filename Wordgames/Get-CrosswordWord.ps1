<#
.SYNOPSIS
  Find a word for crossword puzzles
.DESCRIPTION
  This finds words for crossword puzzles based on basic string wildcards
  ? stands for 1 missing character and * stands for 0 or more missing 
  characters. For example if you type in a??r?e you are looking for a 
  word that is 6 char long and the first char is 'a', the fourth is 'r'
  and the last is 'e'
.EXAMPLE
  Get-CrosswordWord
.NOTES
  General notes
  Created By: Brent Denny
  Created on: 18 Jun 2018
#>
[CmdletBinding()]
Param ()


$WebContent = Invoke-WebRequest -UseBasicParsing -Uri http://www-personal.umich.edu/~jlawler/wordlist 
$WordList = $WebContent.Content -split "`r`n" | Where-Object {$_ -match '^[a-z]+$'} | ConvertFrom-Csv -Header 'Words'
do {
$WordMatch = Read-Host -Prompt 'Enter letters, whole word for anagram, word with ?/* for crossword'
if ($WordMatch -eq '!') {continue}
if ($WordMatch -match '[^a-z]') {
  $WordMatch = $WordMatch -replace '[-,.;:/]','?'
  $WordList | Where-Object {$_.Words -like $WordMatch} | format-wide -AutoSize
}
else {
  $LetterArray = [string[]]$WordMatch.ToCharArray()
  $WordList.Words | Where-Object {
    ([string[]]$_.ToCharArray() | Where-Object {$LetterArray -notin $_}) -eq $null -and
    ( ([string[]]$_.ToCharArray() | Where-Object {$_ -notin $LetterArray}) -ne $null ) -or 
    ( ([string[]]$_.ToCharArray() | Where-Object {$_ -notin $LetterArray}) -eq $null )
  } 
}
} until ($WordMatch -eq "quit")