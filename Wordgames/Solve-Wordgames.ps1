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
Param (
  [Parameter(Mandatory=$true)]
  [string]$WordPattern
)


$WebContent = Invoke-WebRequest -UseBasicParsing -Uri http://www-personal.umich.edu/~jlawler/wordlist 
$WordList = $WebContent.Content -split "`r`n" | Where-Object {$_ -match '^[a-z]+$'} | ConvertFrom-Csv -Header Word
if ($WordPattern -eq '!') {continue}
if ($WordPattern -match '[^a-z]') {
  $WordPattern = $WordPattern -replace '[-,.;:/]','?'
  $WordList | Where-Object {$_.Word -like $WordPattern}
}
else {
  $UserLetterArray = [string[]]$WordPattern.ToCharArray()
  $UserWordGroup = $UserLetterArray | Group-Object
  foreach ($SingleWord in $WordList) {
    $WordArray = [string[]]$SingleWord.Word.ToCharArray()
    $WordGroup = $WordArray | Group-Object 
    $WordMatch = $true
    if (($WordArray | Where-Object {$_ -notin $UserLetterArray}) -eq $null -and ($WordArray.count -le $UserLetterArray.count )) {
      $MultiLetters = $WordGroup | Where-Object {$_.Count -gt 1}
      foreach ($WordLetter in $MultiLetters) {
        $UserWordGroupMatch = $UserWordGroup | Where-Object {$_.name -eq $WordLetter.Name}
        if ($UserWordGroupMatch.Count -lt $WordLetter.Count) {$WordMatch = $false}
      } 
      if ($WordMatch -eq $true) {$SingleWord}
    }
  }
}
