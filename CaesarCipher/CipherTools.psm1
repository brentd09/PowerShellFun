function ConvertTo-CipherText {
  <#
  .SYNOPSIS
    Encrypting text with a random Caesar cipher
  .DESCRIPTION
    This command encrypts all alpa characters with a caesar cipher
    the shift is set randomly and then included in the encypted output
  .EXAMPLE
    ConvertTo-CipherText -ClearText "When the dogz of war are at it again we can all be sure that our lives will be at risk, as they do not regard life or limb they only see power"
    This will encrypt this text with a shifted caesar cipher
  .PARAMETER   ClearText
    This accepts the string that will be encrypted
  .NOTES
    General notes
      Created By: Brent Denny
      Created On: 11-Nov-2021
      Last Modified: 12-Nov-2021
  #>
  [cmdletbinding()]
  Param ([string]$ClearText)
  [char[]]$CipherText = @()
  $CaesarShift = 1..20 | Get-Random
  $Chars = $ClearText.ToCharArray()
  foreach ($Char in $Chars) {
    if ($Char -cmatch '[a-z]') {
      $AscVal = [byte][char]$Char 
      $CiphAscVal = $AscVal + $CaesarShift
      if ($CiphAscVal -gt 122) {$CiphAscVal = $CiphAscVal - 26}
      $CipherText += [char]$CiphAscVal
    }
    elseif ($Char -cmatch '[A-Z]') {
      $AscVal = [byte][char]$Char 
      $CiphAscVal = $AscVal + $CaesarShift
      if ($CiphAscVal -gt 90) {$CiphAscVal = $CiphAscVal - 26}
      $CipherText += [char]$CiphAscVal
    }
    else {
      $CipherText += $Char
    }
  }
  $CipherText += [char]($CaesarShift+96)
  return ($CipherText -join '')
}

function ConvertFrom-CipherText {
  <#
  .SYNOPSIS
    Decrypting cipher text by reversing the Caesar cipher
  .DESCRIPTION
    This command decrypts all alpa characters from a caesar cipher
    the shift was set randomly and is found in the encypted output
  .EXAMPLE
    ConvertFrom-CipherText -CipherText "Itqz ftq pasl ar imd mdq mf uf msmuz iq omz mxx nq egdq ftmf agd xuhqe iuxx nq mf duew, me ftqk pa zaf dqsmdp xurq ad xuyn ftqk azxk eqq baiqdl"
    This will decrypt the cipher text with the shifted caesar cipher key
  .PARAMETER   CipherText
    This accepts the encrypted string that will be decrypted
  .NOTES
    General notes
      Created By: Brent Denny
      Created On: 11-Nov-2021
      Last Modified: 12-Nov-2021
  #>
  [cmdletbinding()]
  Param ([string]$CipherText)
  $CleanCipherText = $CipherText.Trim()
  $CaesarKey = ($CleanCipherText.ToCharArray())[-1]
  $CipherTextWithoutKey = $CleanCipherText.Substring(0,$CleanCipherText.Length-1)
  $CaesarShift = [byte][char]$CaesarKey - 96
  $Chars =$CipherTextWithoutKey.ToCharArray()
  foreach ($Char in $Chars) {
    if ($Char -cmatch '[a-z]') {
      $AscVal = [byte][char]$Char 
      $ClearTextAscVal = $AscVal - $CaesarShift
      if ($ClearTextAscVal -lt 97) {$ClearTextAscVal = $ClearTextAscVal + 26}
      $ClearText += [char]$ClearTextAscVal
    }
    elseif ($Char -cmatch '[A-Z]') {
      $AscVal = [byte][char]$Char 
      $ClearTextAscVal = $AscVal - $CaesarShift
      if ($ClearTextAscVal -lt 65) {$ClearTextAscVal = $ClearTextAscVal + 26}
      $ClearText += [char]$ClearTextAscVal
    }
    else {
      $ClearText += $Char
    }
  }
  return ($ClearText -join '')
}