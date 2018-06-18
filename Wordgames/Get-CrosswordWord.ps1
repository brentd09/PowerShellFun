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
function ConvertTo-WordObject {
  Param (
    [string[]]$Words
  )
  foreach ($Word in $Words) {
    $ObjParameters =  [ordered]@{
      LetterArray = $Word.ToCharArray()
      WordLength = $Word.Length
      Sorted = (($Word.ToCharArray() | Sort-Object ) -join '' ).tostring()
      Word = $Word
    }
    New-Object -TypeName psobject -Property $ObjParameters
  }
}


$WebContent = Invoke-WebRequest -UseBasicParsing -Uri http://www-personal.umich.edu/~jlawler/wordlist 
$WordList = $WebContent.Content -split "`r`n" | Where-Object {$_ -match '^[a-z]+$'} | ConvertFrom-Csv -Header 'Words'
#$WordObjects = ConvertTo-WordObject -Words $WordList
do {
$WordMatch = Read-Host -Prompt 'Enter the bits of the word that you know seperated by ?'
if ($WordMatch -eq 'quit') {continue}
$wordlist | Where-Object {$_.Words -like $WordMatch} | format-wide -AutoSize
} until ($WordMatch -eq "quit")