function ConvertTo-PigLatin {
  [CmdletBinding()]
  Param (
    [Parameter(Mandatory=$true)]
    [string]$Sentence
  )
  $Words = $Sentence -split '\s+'
  Write-Verbose ($Words -join " ")
  [string[]]$NewWords = @()
  foreach ($Word in $Words) {
    $Word = $Word.tolower()
    Write-Verbose $Word
    switch -regex ($Word) {
        '^[aeiou]' {
          $NewWords += $Word+'yay'
        }
        '^[bcdfghjklmnpqrstuvwxyz]' {
          $NewWords += $Word -replace '^([bcdfghjklmnpqrstuvwxyz]+)([aeiou]\w*)$','$2$1ay'
        }
        Default {}
    }
  }    
  return $NewWords -join ' '
}

