<#
.Synopsis
  Sliding Blocks
.DESCRIPTION
  this is the sliding block game with numbers to sort them
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
function Draw-Block {
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
function Create-BlockMeta {
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
$BlockObj = Create-BlockMeta -BlockArray $Block
do {
  Draw-Block -BlockObject $BlockObj
  Write-Host 
  $HashObj = $BlockObj | Where-Object {$_.Val -eq '#'}
  $Moveable = $BlockObj | Where-Object {
    ($_.row -eq $HashObj.Row -and ([math]::Abs($_.Col - $HashObj.Col)) -eq 1 ) -or ($_.Col -eq $HashObj.Col -and ([math]::Abs($_.Row - $HashObj.Row)) -eq 1 )
  }
  do {
    $Move = Read-Host -Prompt "Which letter to move"
  } Until ($Move -in $Moveable.Val)
  $Chosen = $BlockObj | Where-Object {$_.Val -eq $Move}
  $BlockObj[$HashObj.Position].Val = $BlockObj[$Chosen.Position].Val
  $BlockObj[$Chosen.Position].Val = '#'
  $CurrentVals = $BlockObj.Val -join ''
} while ($SolvedBlock -ne $CurrentVals)
Draw-Block -BlockObject $BlockObj
Write-Host -ForegroundColor Yellow "`nYOU DID IT!!"