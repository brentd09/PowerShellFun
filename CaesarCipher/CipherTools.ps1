function ConvertTo-CipherText {
  Param ([string]$ClearText)
  [char[]]$CipherText = @()
  $CaesarShift = 1..20 | Get-Random
  $Chars = $ClearText.ToCharArray()
  foreach ($Char in $Chars) {
    if ($Char -cmatch '[a-z]') {
      $AscVal = [byte][char]$Char 
      $CiphAscVal = $AscVal + $CaesarShift
      if ($CiphAscVal -gt 122) {$CiphAscVal = $CiphAscVal - 24}
      $CipherText += [char]$CiphAscVal
    }
    elseif ($Char -cmatch '[A-Z]') {
      $AscVal = [byte][char]$Char 
      $CiphAscVal = $AscVal + $CaesarShift
      if ($CiphAscVal -gt 90) {$CiphAscVal = $CiphAscVal - 24}
      $CipherText += [char]$CiphAscVal
    }
    else {
      $CipherText += $Char
    }
  }
  $CipherText += [char]($CaesarShift+96)
  return $CipherText
}

function ConvertFrom-CipherText {
  Param ([string]$CipherText)
  $CleanCipherText = $CipherText.Trim()
  $CaesarKey = ($CleanCipherText.ToCharArray())[-1]
  $CipherTextWithoutKey = $CleanCipherText.Substring(0,$CleanCipherText.Length-1)
  $CaesarShift = [byte][char]$CaesarKey
  $Chars =$CipherTextWithoutKey.ToCharArray()
  foreach ($Char in $Chars) {
    if ($Char -cmatch '[a-z]') {
      $AscVal = [byte][char]$Char 
      $ClearTextAscVal = $AscVal - $CaesarShift
      if ($ClearTextAscVal -lt 97) {$ClearTextAscVal = $ClearTextAscVal + 24}
      $ClearText += [char]$ClearTextAscVal
    }
    elseif ($Char -cmatch '[A-Z]') {
      $AscVal = [byte][char]$Char 
      $ClearTextAscVal = $AscVal - $CaesarShift
      if ($ClearTextAscVal -lt 65) {$ClearTextAscVal = $ClearTextAscVal + 24}
      $ClearText += [char]$ClearTextAscVal
    }
    else {
      $ClearText += $Char
    }
  }
  return $ClearText  
}

#$Encoded = ConvertTo-CipherText -ClearText "When the dogs of war are at it again we can all be sure that our lives will be at risk, as they do not regard life or limb they only see power"
#$Encoded -join ''

$Clear = ConvertFrom-CipherText -CipherText 'Clir xli hskw sj cev evi ex mx ekemr ci ger epp fi wyvi xlex syv pmziw cmpp fi ex vmwo, ew xlie hs rsx vikevh pmji sv pmqf xlie srpe wii tscivd'
$Clear -join ''