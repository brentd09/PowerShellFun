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

# -- MAIN CODE --
$SolvedBlock = @("A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","#") -join ''
$Block = @("A","B","C","D","E","F","G","H","I","J","#","K","M","N","O","L")
$BlockObj = New-BlockMeta -BlockArray $Block
do {
  Show-Block -BlockObject $BlockObj
  Write-Host 
  $HashObj = $BlockObj | Where-Object {$_.Val -eq '#'}
  $Moveable = $BlockObj | Where-Object {
    ($_.row -eq $HashObj.Row -and ([math]::Abs($_.Col - $HashObj.Col)) -eq 1 ) -or ($_.Col -eq $HashObj.Col -and ([math]::Abs($_.Row - $HashObj.Row)) -eq 1 )
  }
  do {
    Write-Host -NoNewline -ForegroundColor Green "Which letter to move: "
    $Move = ($Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")).Character -as [string]
    Write-Host
  } Until ($Move -in $Moveable.Val)
  $Chosen = $BlockObj | Where-Object {$_.Val -eq $Move}
  $BlockObj[$HashObj.Position].Val = $BlockObj[$Chosen.Position].Val
  $BlockObj[$Chosen.Position].Val = '#'
  $CurrentVals = $BlockObj.Val -join ''
} while ($SolvedBlock -ne $CurrentVals)
Show-Block -BlockObject $BlockObj
Write-Host -ForegroundColor Yellow "`nYOU DID IT!!"