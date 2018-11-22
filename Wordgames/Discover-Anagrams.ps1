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
$webDictSite = Invoke-WebRequest -Uri http://www.mieliestronk.com/corncob_lowercase.txt 
[string[]]$Words = ($webDictSite.Content -split "`n" | Where-Object {$_.length -ge 3}).trim() 
$MatchWord = ''
While ($MatchWord -ne "q") {
  $MatchWord = Read-Host -Prompt "Enter the word with - for unknown letters, Q - Quit"
  if ($MatchWord -eq 'q') {continue}
  [string]$RegExMW = ($MatchWord -replace "[^a-z]",'.').trim()
  Write-Host '-------------------------'
  Write-Host $MatchWord
  Write-Host '-------------------------'
  $Words -match "^$RegExMW$"
  Write-Host '-------------------------'
}