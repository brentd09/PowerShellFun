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



# import the word list from insternet http://www-personal.umich.edu/~jlawler/wordlist
# convert to objects that contain word,length,letter

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
[string[]]$WordList = $WebContent.Content -split "`r`n" | Where-Object {$_ -match '^[a-z]+$'}
#$WordObjects = ConvertTo-WordObject -Words $WordList
$WordList | Where-Object {$_.Length -eq 15 -and $_ -match 'z'}
