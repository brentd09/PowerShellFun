<#
.Synopsis
  Sliding Blocks
.DESCRIPTION
  This is the sliding block game with letters that need to be sorted.
  You can only swap a letter that is directly next to the blank tile 
  depicted by a # symbol (not diagonally), you make the swap by typing 
  the letter of the tile you wish to swap.
.EXAMPLE
  Play-SlidingBlock
.NOTES
  General notes
  Created By  : Brent Denny
  Date Created: 30-May-2018
#>
[CmdletBinding()]
Param (

)
function Show-Block {
  Param (
    $BlockObject
  )
  Clear-Host
  Write-Host -ForegroundColor Yellow "`nSLIDING BLOCKS`n"
  $count = 0
  foreach ($BlockElement in $BlockObject) {
    $count++
    if ($BlockElement.Val -match '[a-o]') {$color = 'Green'}
    else {$color = 'Gray'}
    Write-Host -NoNewline $Spc
    Write-Host -NoNewline -ForegroundColor $color $BlockElement.Val 
    Write-Host -NoNewline "  "
    if ($count -eq 4) {Write-Host; $count = 0}
  }
  Write-Host
}
function New-BlockMeta {
  Param (
    $BlockArray
  )
  $count = 0
  foreach ($BlockElement in $BlockArray) {
    $Property = [ordered]@{
      Position = $count
      Row = [math]::Truncate($count/4) 
      Col = $count % 4
      Val = $BlockElement 
    }
    New-Object -TypeName psobject -Property $Property
    $count++
  }
}
function New-RandomBlock {
  Param (
    $BlockObject
  )
  $NumOfRounds = 200
  ForEach ($count in (1..$NumOfRounds)) {
    $HashPos = $BlockObject | Where-Object {$_.Val -eq '#'}
    $Moveable = $BlockObject | Where-Object {
      ($_.row -eq $HashPos.Row -and ([math]::Abs($_.Col - $HashPos.Col)) -eq 1 ) -or ($_.Col -eq $HashPos.Col -and ([math]::Abs($_.Row - $HashPos.Row)) -eq 1 )
    }
    $Random = $Moveable | Get-Random
    $BlockObject[$HashPos.Position].Val = $BlockObject[$Random.Position].Val
    $BlockObject[$Random.Position].Val = '#'
    Write-Progress -Activity "Randomly shuffling the letters" -PercentComplete ($count / $NumOfRounds * 100 )
  }
  Write-Progress -Activity "Randomly shuffling the letters" -Completed
  $BlockObject
}

# -- MAIN CODE --
$NumOfMoves = 0
$SolvedString = @("A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","#") -join ''
$Block = @("A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","#")
$BlockObj = New-BlockMeta -BlockArray $Block
$BlockObj = New-RandomBlock -BlockObject $BlockObj.psobject.copy()
do {
  Show-Block -BlockObject $BlockObj
  $HashObj = $BlockObj | Where-Object {$_.Val -eq '#'}
  $Moveable = $BlockObj | Where-Object {
#    ($_.row -eq $HashObj.Row -and ([math]::Abs($_.Col - $HashObj.Col)) -eq 1 ) -or ($_.Col -eq $HashObj.Col -and ([math]::Abs($_.Row - $HashObj.Row)) -eq 1 )
    ($_.row -eq $HashObj.Row  -or $_.Col -eq $HashObj.Col) -and $_.Val -ne '#'
}
  do {
    Write-Host -NoNewline -ForegroundColor Green "Which letter to move: "
    if ($Host.Name -eq 'ConsoleHost') {$Move = ($Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")).Character -as [string]}
    else {$Move = (Read-Host).Substring(0,1)}
    Write-Host
  } Until ($Move -in $Moveable.Val)
  $NumOfMoves++
  $Chosen = $BlockObj | Where-Object {$_.Val -eq $Move}
  $BlockObj[$HashObj.Position].Val = $BlockObj[$Chosen.Position].Val
  $BlockObj[$Chosen.Position].Val = '#'
  $CurrentVals = $BlockObj.Val -join ''
} while ($SolvedString -ne $CurrentVals)
Show-Block -BlockObject $BlockObj
Write-Host -ForegroundColor Yellow -NoNewline "YOU DID IT in "
Write-Host -ForegroundColor Green -NoNewline "$NumOfMoves "
Write-Host -ForegroundColor Yellow "moves!!"