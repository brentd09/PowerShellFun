<#
.SYNOPSIS
  Discovers a word from the letters given
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
Param()

Class DictWord {
  [string]$Word
  [string]$LettersSorted
  [Char[]]$CharactersSorted
  [int]$WordLength

  DictWord ([string]$WordFromDictionary) {
    $this.Word = $WordFromDictionary
    $this.LettersSorted = ($WordFromDictionary -as [Char[]] | Sort-Object) -join ''
    $this.CharactersSorted = $WordFromDictionary -as [Char[]] | Sort-Object
    $this.WordLength = $WordFromDictionary.Length
  }
}
  $webDictSite = Invoke-WebRequest -Uri http://www.mieliestronk.com/corncob_lowercase.txt 
  [string[]]$Words = ($webDictSite.Content -split "`n" | Where-Object {$_.length -ge 3}).trim() 
  $Dictionary = @()
  foreach ($Word in $Words) {
    $Dictionary += [DictWord]::New($Word)
  }
  $Dictionary | ConvertTo-Json | out-file C:\Users\Brent\Documents\Git-Root\PowerShellFun\Wordgames\WordsDict.json
#[DictWord[]]$Dictionary = Get-Content ".\WordsDict.json" | ConvertFrom-Json | Sort-Object -Property WordLength
#$Anagram = Read-Host -Prompt "Enter a bunch of letters"