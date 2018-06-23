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
  $UserWordMatch = Read-Host -Prompt 'Enter letters, whole word for anagram, word with ?/* for crossword'
  if ($UserWordMatch -eq '!') {continue}
  if ($UserWordMatch -match '[^a-z]') {
    $UserWordMatch = $UserWordMatch -replace '[-,.;:/]','?'
    $WordList | Where-Object {$_.Words -like $UserWordMatch} | format-wide -AutoSize
  }
  else {
    $UserLetterArray = [string[]]$UserWordMatch.ToCharArray()
    foreach ($Word in $WordList.Words) {
      $WordArray = [string[]]$Word.ToCharArray()
      if (($WordArray | Where-Object {$_ -notin $UserLetterArray}) -eq $null -and
         ($WordArray.count -le $UserLetterArray.count )) {$Word}
    }
  }
} until ($UserWordMatch -eq "!")