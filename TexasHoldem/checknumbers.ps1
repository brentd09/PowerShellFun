$numbers = 10,11,13,12,8


$desiredMatch = 13,12,11,10,9

$sortNums = $numbers | Sort-Object -Descending
$Same = 0
foreach ($index in (0..4)) {
  if ($desiredMatch[$index] -eq $sortNums[$index]) {$Same++}
}
if ($Same -eq 5) {write-host -ForegroundColor green  "All matched"}
else {Write-Host -ForegroundColor Red "Not a complete match"}