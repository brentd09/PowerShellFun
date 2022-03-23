function PaulsCipher {
  [cmdletBinding()]
  Param ([string]$DataToEncode)

  function ShiftChar {
    Param ([string]$Char,[string]$PrevChar)
    $Char = $Char.ToUpper()
    $PrevChar = $PrevChar.ToUpper()
    $Shift = ([byte][char]$PrevChar) - 64
    $CharAscii = [byte][char]$Char
    $NewAscii = $CharAscii + $Shift
    if ($NewAscii -gt 90) {$NewAscii = $NewAscii - 26}
    $NewChar = [char]$NewAscii
    return [pscustomobject]@{
      Original = $Char
      Previous  = $PrevChar
      NewChar  = $NewChar
    }
  }

  $StrArray = $DataToEncode.ToUpper().ToCharArray() -as [string[]]
  [string]$NewString = ''
  $FirstFlag = $true
  foreach ($Char in $StrArray) {
    if ($FirstFlag -eq $true) {
      $NewString = $Char
      $FirstFlag = $false
    }
    elseif ($Char -notmatch '[a-z]') {
      $NewString += $Char
      continue      
    }
    else {
      $ShiftObj = ShiftChar -Char $Char -PrevChar $OldChar
      $NewString += $ShiftObj.NewChar
    }
    $OldChar = $Char
  }
  return $NewString
}

PaulsCipher -DataToEncode "muBas41r"