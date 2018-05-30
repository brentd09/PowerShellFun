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
  $count = 0
  foreach ($BlockElement in $BlockObject) {
    $count++
    Write-Host -NoNewline $Spc
    Write-Host -NoNewline $BlockElement.Val 
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
$SolvedBlock = @("A","B","C","D","E","F","G","H","I","J","K","L","M","N","O"," ")
$Block = @("A","B","C","D","E","F","G","H","I","J"," ","K","M","N","O","L")
$BlockObj = Create-BlockMeta -BlockArray $Block
do {
Draw-Block -BlockObject $BlockObj
Write-Host 
$Move = Read-Host -Prompt "Which letter to move"
} while ($Block -eq $SolvedBlock)