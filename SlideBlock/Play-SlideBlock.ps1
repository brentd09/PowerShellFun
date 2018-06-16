<#
.Synopsis
  Sliding Tile Block Game
.DESCRIPTION
  This is the sliding block game with letters that need to be sorted.
  You can only swap letters that are on the same horizontal or 
  vertical line as the blank position. You make the swap by typing 
  the letter of the tile you wish to swap the blank spot to and all
  of the letters between the the chosen letter and the blank square
  will slide. This means you can choose letter directly next to the
  blank or any letter on that line and all the letters move just like
  a traditional slide puzzle.
.EXAMPLE
  Play-SlidingBlock
.NOTES
  General notes
  Created By  : Brent Denny
  Date Created:  30-May-2018
  Date Finished: 15-Jun-2018
#>
[CmdletBinding()]
Param ()
function Show-Block {
  Param (
    $BlockObject
  )
  Clear-Host
  $Spc = '  '
  Write-Host -ForegroundColor Yellow "`n${Spc}SLIDING BLOCKS"
  Write-Host -ForegroundColor Yellow   "${Spc}--------------"
  $count = 0
  foreach ($BlockElement in $BlockObject) {
    $count++
    if ($BlockElement.Val -match '[a-o]') {$color = 'Green'}
    else {$color = 'Gray'}
    If ($count -eq 1) {Write-Host -NoNewline "  $Spc"}
    Write-Host -NoNewline -ForegroundColor $color $BlockElement.Val 
    Write-Host -NoNewline '  '
    if ($count -eq 4) {Write-Host; $count = 0}
  }
  Write-Host
}
function New-BlockMeta {
  Param (
    $BlockArray
  )
  # Builds the objects to describe where each tile is in the block
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
    $BlankPos = $BlockObject | Where-Object {$_.Val -eq ' '}
    $Moveable = $BlockObject | Where-Object {
      ($_.row -eq $BlankPos.Row -and ([math]::Abs($_.Col - $BlankPos.Col)) -eq 1 ) -or ($_.Col -eq $BlankPos.Col -and ([math]::Abs($_.Row - $BlankPos.Row)) -eq 1 )
    }
    $Random = $Moveable | Get-Random
    $BlockObject[$BlankPos.Position].Val = $BlockObject[$Random.Position].Val
    $BlockObject[$Random.Position].Val = ' '
    Write-Progress -Activity 'Randomly shuffling the letters' -PercentComplete ($count / $NumOfRounds * 100 )
  }
  Write-Progress -Activity 'Randomly shuffling the letters' -Completed
  $BlockObject
}

# -- MAIN CODE --
Clear-Host
$NumOfMoves = 0
$SolvedString = @('A','B','C','D','E','F','G','H','I','J','K','L','M','N','O',' ') -join '' # solution is checked as a string at end of main code
$Block = @('A','B','C','D','E','F','G','H','I','J','K','L','M','N','O',' ')
$BlockObj = New-BlockMeta -BlockArray $Block  # Changing the simple block array into a powershell object with Properties:Col,Row,Val,Position
$BlockObj = New-RandomBlock -BlockObject $BlockObj.psobject.copy()  # Randomise the placement of the tiles to start the game
do {
  Show-Block -BlockObject $BlockObj
  $BlankObj = $BlockObj | Where-Object {$_.Val -eq ' '} # Find the blank tile and return the object 
  $Moveable = $BlockObj | Where-Object {($_.row -eq $BlankObj.Row -or $_.Col -eq $BlankObj.Col) -and $_.Val -ne ' '} # which tiles are valid choices
  do { 
    Write-Host -NoNewline -ForegroundColor Green 'Which letter to move: '
    # If PowerShell Console host use a single key press, if other hosts (like ISE VSCode) use the Read-Host cmdlet instead
    if ($Host.Name -eq 'ConsoleHost') {$Move = ($Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')).Character -as [string]} 
    else {$Move = (Read-Host).Substring(0,1)}
    Write-Host
  } Until ($Move -in $Moveable.Val) # Keep asking until it is a valid choice
  $ChosenObj = $BlockObj | Where-Object {$_.Val -eq $Move} # Get the object details of the chosen tile
  $NumberTilesMove = [math]::Abs($ChosenObj.Col - $BlankObj.Col) + [math]::Abs($ChosenObj.Row - $BlankObj.Row) #Count number of tiles from chosen tile to Blank tile
  switch ($NumberTilesMove) {
    {$_ -eq 1} { # if the chosen tile is just one tile away from blank
      $BlockObj[$BlankObj.Position].Val = $BlockObj[$ChosenObj.Position].Val
      $BlockObj[$ChosenObj.Position].Val = ' '
      $NumOfMoves++ # Add one to the move tally
    }
    {$_ -eq 2 -or $_ -eq 3} { # if the chosen tile is more than one tile away, many tiles are sliding
      $ChangeCols=@();$ChangeRows=@()
      if ($ChosenObj.Row -eq $BlankObj.Row) { # Row Slide
        $ChangeCols = ($BlankObj.Col)..($ChosenObj.Col)
        $Moves = ($ChangeCols | Measure-Object).Count - 1
        foreach ($ChangeCol in $ChangeCols) {
          if ($ChangeCol -eq $ChangeCols[0]) {$PrevCol = $ChangeCol} # first time in loop store blank tile Col in PrevCol and do nothing else
          else { # For second+ times through this loop get the current object and the previous object
            $PrevObj = $BlockObj | Where-Object {$_.Col -eq $PrevCol -and $_.Row -eq $ChosenObj.Row}
            $ThisObj = $BlockObj | Where-Object {$_.Col -eq $ChangeCol -and $_.Row -eq $ChosenObj.Row}
            if ($ChangeCol -eq $ChangeCols[-1]) { # if last time in loop set the blank value to this tile as it is the one that was chosen
              $BlockObj[$PrevObj.Position].Val = $BlockObj[$ThisObj.Position].Val
              $BlockObj[$ThisObj.Position].Val = ' '
            }
            else { # If not last loop interation then set the previos tiles value to be the same as the current tile's value 
              $BlockObj[$PrevObj.Position].Val = $BlockObj[$ThisObj.Position].Val
              $PrevCol = $ChangeCol
            }
          }
        }
      }
      elseif ($ChosenObj.Col -eq $BlankObj.Col) { # Column Slide
        $ChangeRows = ($BlankObj.Row)..($ChosenObj.Row)
        $Moves = ($ChangeRows | Measure-Object).Count - 1
        foreach ($ChangeRow in $ChangeRows) {
          if ($ChangeRow -eq $ChangeRows[0]) {$PrevRow = $ChangeRow} # first time in loop store blank tile Row in PrevRow and do nothing else
          else { # For second+ times through this loop get the current object and the previous object
            $PrevObj = $BlockObj | Where-Object {$_.Row -eq $PrevRow -and $_.Col -eq $ChosenObj.Col}
            $ThisObj = $BlockObj | Where-Object {$_.Row -eq $ChangeRow -and $_.Col -eq $ChosenObj.Col}
            if ($ChangeRow -eq $ChangeRows[-1]) { # if last time in loop set the blank value to this tile as it is the one that was chosen
              $BlockObj[$PrevObj.Position].Val = $BlockObj[$ThisObj.Position].Val
              $BlockObj[$ThisObj.Position].Val = ' '
            }
            else { # If not last loop interation then set the previos tiles value to be the same as the current tile's value
              $BlockObj[$PrevObj.Position].Val = $BlockObj[$ThisObj.Position].Val
              $PrevRow = $ChangeRow
            }
          }
        }
      }
      $NumOfMoves = $NumOfMoves + $Moves # Tally up the number of tiles moved for multi slide moves
    }
  }
  $CurrentVals = $BlockObj.Val -join '' # Convert the values from the object into one string to compare with completed string
} while ($SolvedString -ne $CurrentVals)
Show-Block -BlockObject $BlockObj # Show Completed puzzle and report on how many moves
Write-Host -ForegroundColor Yellow -NoNewline 'YOU DID IT in '
Write-Host -ForegroundColor Green -NoNewline "$NumOfMoves "
Write-Host -ForegroundColor Yellow 'moves!!'