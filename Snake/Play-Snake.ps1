Clear-Host 
$HeadPosObj = New-Object -TypeName psobject -Property @{PosX = 3;PosY = 3}
$lastPosx = @()
$SnakeLength = 5
do {
  $Host.UI.RawUI.CursorPosition = @{ X = $HeadPosObj.PosX; Y = $HeadPosObj.PosY } ; Write-Host -NoNewline '@'
  $NumDisplayed = $lastPosx.Count
  if ($NumDisplayed -ge $SnakeLength) {$Host.UI.RawUI.CursorPosition = @{ X = $lastPosx[$NumDisplayed-$SnakeLength]; Y = $HeadPosObj.PosY } ; Write-Host -NoNewline ' ' }
  Start-Sleep -Milliseconds 100
  $lastPosx += $HeadPosObj.PosX
  $HeadPosObj.PosX++
} while ($true)

