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