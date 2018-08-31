<#
.SYNOPSIS
  Uses Letters to find anagrams
.DESCRIPTION
  Uses the wordsmith.org website to uncover anagrams from letters chosen in parameter
  This script webscrapes the content of the web page to produce a list of words.
  This word list can be listed or grouped by word length.
.PARAMETER Letters
  This Parameter lists all of the letters in one string
.PARAMETER Group
  This Parameter will use a Format-Wide command to list just the words grouped by their
  wordlength.
.PARAMETER WordLength
  This Parameter accepts an array of integers and will only display words that have a 
  word length that corresponds with array values given for this parameter.     
.EXAMPLE
  Get-Anagram -Letters qusedtnea 
  This example will just list the words and their length
.EXAMPLE
  Get-Anagram -Letters qusedtnea -Group
  This example will list the words grouped by their length
.EXAMPLE
  Get-Anagram -Letters qusedtnea -WordLength 4,6
  This example will just list the words and their length but only for words that are 4 and 
  6 characters in length 
.INPUTS
  [string]
.NOTES
  General notes
  Created By: Brent Denny
  Created On: 30-Aug-@018
#>
[CmdletBinding()]
Param (
  [Parameter(Mandatory=$true)]
  [string]$Letters,
  [switch]$Group,
  [int[]]$WordLength = 0
)
function Get-Words {
  Param ($LettersFn)
  $Rawweb = Invoke-WebRequest -uri "https://new.wordsmith.org/anagram/anagram.cgi?anagram=$LettersFn&language=english&t=500&d=&include=&exclude=&n=3&m=&a=n&l=y&q=y&k=0" -UseBasicParsing -Method get
  $WebcontentArray = $Rawweb -split "`n"
  $wordList = $WebcontentArray | Where-Object {$_ -match "^<br>\s*\d+\.\s+[a-z]+"}
  $Words = $wordList -replace "^<br>\s*\d+\.\s+([a-z]+)",'$1' 
  foreach ($Word in $Words) {
    New-Object -TypeName psobject -Property @{Words = $Word;CharLength = $Word.Length}
  }
}
if ($WordLength -contains 0) {
  If ($Group -eq $true) {
    Get-Words -LettersFn $Letters | Format-Wide -GroupBy CharLength -Property Words -AutoSize
  }
  else {
    Get-Words -LettersFn $Letters
  }
}
else {
  If ($Group -eq $true) {
    Get-Words -LettersFn $Letters | Where-Object {$_.CharLength -in $WordLength}| Format-Wide -GroupBy CharLength -Property Words -AutoSize
  }
  else {
    Get-Words -LettersFn $Letters| Where-Object {$_.CharLength -in $WordLength}
  }

}