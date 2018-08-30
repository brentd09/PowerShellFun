[CmdletBinding()]
Param (
  [Parameter(Mandatory=$true)]
  [string]$Letters
)
$Rawweb = Invoke-WebRequest -uri "https://new.wordsmith.org/anagram/anagram.cgi?anagram=$Letters&language=english&t=500&d=&include=&exclude=&n=4&m=&a=n&l=y&q=y&k=0" -UseBasicParsing -Method get
$WebcontentArray = $Rawweb -split "`n"
$wordList = $WebcontentArray | Where-Object {$_ -match "^<br>\s*\d+\.\s+[a-z]+"}
$Words = $wordList -replace "^<br>\s*\d+\.\s+([a-z]+)",'$1' 
foreach ($Word in $Words) {
  New-Object -TypeName psobject -Property @{Words = $Word}
}