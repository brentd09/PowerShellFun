function Draw-Border {
  Param (
    $Bdr = '#'
  )
  Write-host -ForegroundColor Yellow "`n                                          SNAKE"
  foreach ($x in (0,2,4,6,8,10,12,14,16,18,20,22,24,26,28,30,32,34,36,38,40,42,44,46,48,50,52,54,56,58,60,62,64,66,68,70,72,74,76,78,80,82)) {
    $Host.ui.RawUI.CursorPosition = @{ X = $x; Y = 3} ; Write-Host -NoNewline $Bdr
  }
  foreach ($y in (4..42)) {
    $Host.UI.RawUI.CursorPosition = @{ X = 0; Y = $y} ; Write-Host -NoNewline $Bdr 
    $Host.UI.RawUI.CursorPosition = @{ X = 82; Y = $y} ; Write-Host -NoNewline $Bdr
  }
  foreach ($x in (0,2,4,6,8,10,12,14,16,18,20,22,24,26,28,30,32,34,36,38,40,42,44,46,48,50,52,54,56,58,60,62,64,66,68,70,72,74,76,78,80,82)) {
    $Host.ui.RawUI.CursorPosition = @{ X = $x; Y = 42} ; Write-Host -NoNewline $Bdr
  }
}

function Read-KeyOrTimeout {
  Param(
    [int]$seconds = 5,
    [string]$prompt = 'Hit a key',
    [string]$default = 'A'
  )
  
  $startTime = Get-Date
  $timeOut = New-TimeSpan -Seconds $seconds
  Write-Host $prompt
  while (-not $host.ui.RawUI.KeyAvailable) {
    $currentTime = Get-Date
    if ($currentTime -gt $startTime + $timeOut) {
        Break
    }
  }
  if ($host.ui.RawUI.KeyAvailable) {
    [string]$response = ($host.ui.RawUI.ReadKey("IncludeKeyDown,NoEcho")).character
  }
  else {
    $response = $default
  }
  $response
}


Clear-Host 
Draw-Border
read-host
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

