<#
.SYNOPSIS
  Original MasterMind Game
.DESCRIPTION
  This game gets you to choose four colors from a possible six, the aim is to guess
  the master set of colors chosen randomly by the computer, they remain hidden at 
  the top of the board until you guess them. Each guess will be accompanied by 
  white and black pegs, each white peg matches a color that is correct but is in the
  wrong position, each black peg show there is a correct color in the correct position.
  The difficulty is you cannot assume the first white or black peg relates to the first
  guessed color because it doesn't. Two white pegs just mean that any two of the color
  chosen are in the wrong position but are the right colors, same goes for Black Pegs.
.EXAMPLE
  Play-MasterMind
.NOTES
  Created:
    On: 22 April 2017
    By: Brent Denny 


#>

#region FUNCTIONS
function Get-Master {
  $MasterArray = @()
  $MasterArray = 1..6 | 
    Sort-Object {Get-Random} |
    Select-Object -Skip 1 -First 4
  $MasterProperties = @{
    block = ($MasterArray -join '') -as [string]
    strings = $MasterArray -as [string[]]
    numbers = $MasterArray -as [int[]]
  } ; $Master = New-Object -TypeName psobject -Property $MasterProperties
  Return $Master
}#FUNCTION

function Get-Guess {
  $ValidChoice = $false
  $Guess = @()
  Do {
    Write-Host
    Write-Host -NoNewline -ForegroundColor 0  "  1 Black " -BackgroundColor DarkGray
    write-host -NoNewline ' '
    Write-Host -NoNewline -ForegroundColor 10 " 2 Green  " -BackgroundColor DarkGray
    write-host -NoNewline ' '
    Write-Host -NoNewline -ForegroundColor 11 "  3 Blue  " -BackgroundColor DarkGray
    write-host -NoNewline ' '
    Write-Host -NoNewline -ForegroundColor 12 "  4 Red   " -BackgroundColor DarkGray
    write-host -NoNewline ' '
    Write-Host -NoNewline -ForegroundColor 14 " 5 Yellow " -BackgroundColor DarkGray
    write-host -NoNewline ' '
    Write-Host            -ForegroundColor 15 "  6 White " -BackgroundColor DarkGray 
    $Choice = Read-Host -Prompt "Enter your choice as one string of numbers. Example 1342"
    $Choice = $Choice -replace "\D",""
    $Choice = ($Choice -as [char[]] | Select-Object -Unique ) -join ''
    if ($choice -match "^[123456]{4}$") {$ValidChoice = $true}
    else {$ValidChoice = $false}
  } until ($ValidChoice)
  $GuessProperties = @{
    Block = $Choice -as [string]
    Strings = ($Choice -split '' | Where-Object {$_ -match "^\d$"}) -as [string[]]
    Numbers = ($Choice -split '' | Where-Object {$_ -match "^\d$"}) -as [int[]]
  } ; $Guess = New-Object -TypeName psobject -Property $GuessProperties
  return $Guess
}#FUNCTION

function Compare-GuessToMaster {
  Param (
    [Parameter(Mandatory=$true)]
    $Master,
    [Parameter(Mandatory=$true)]
    $Guess,
    [Parameter(Mandatory=$true)]
    $Sequence
  )
  $RightPlace = 0; $WrongPlace = 0; $WrongColor = 0
  if ($Master.Block -eq $Guess.Block) {
    $RightPlace = 4
    $WrongPlace = 0
    $WrongColor = 0
  }#IF
  else {
    foreach ($Pos in 0..3) {
      if ($Master.Numbers[$Pos] -eq $Guess.Numbers[$Pos]) {
        $RightPlace++
      }#IF
      elseif ($Master.Numbers -contains $Guess.Numbers[$Pos]){
        $WrongPlace++
      }#ELSEIF
      else {
        $WrongColor++
      }#ELSE
    }#FOREACH
  }#ELSE
  $ResultProperties = @{
    Order = $Sequence
    Master = $Master
    Guess = $Guess
    RightPlace = $RightPlace
    WrongPlace = $WrongPlace
    WrongColor = $WrongColor
  } ; $Result = New-Object -TypeName psobject -Property $ResultProperties
  return $Result
}#FUNCTION

function Draw-Board {
  Param (
    [Parameter(Mandatory=$false)]
    $Results,
    [Parameter(Mandatory=$true)]
    $TurnNumber,
    [Parameter(Mandatory=$true)]
    $BoardSpecs
  )
  $BoardLinesRequired = 10 - $TurnNumber
  Clear-Host
  Write-Host -NoNewline -ForegroundColor Yellow "`n`n         MASTER MIND         "
  Write-Host -NoNewline -BackgroundColor DarkGray -ForegroundColor Black " BLACK-PIN " 
  Write-Host  -ForegroundColor Yellow " One is correct and in the right position   " 
  Write-Host -NoNewline "                             "      
  Write-Host -NoNewline -BackgroundColor DarkGray -ForegroundColor White " WHITE-PIN "
  Write-Host  -ForegroundColor Yellow " One is correct but in the wrong position"
  write-host -NoNewline (" " * $BoardSpecs.LGutter)
  write-host -BackgroundColor DarkGray (" " * $BoardSpecs.Overall)
  write-host -NoNewline (" " * $BoardSpecs.LGutter)
  write-host -NoNewline -BackgroundColor DarkGray -ForegroundColor Black ("   MASTER -> " )
  if ($TurnNumber -ge 1) {
    if ($results[0].RightPlace -eq 4 -or $TurnNumber -eq 10) {
      foreach ($Digit in $Master.strings){
        switch ($Digit) {
          1 {$Color = 0}
          2 {$Color = 10}
          3 {$Color = 11}
          4 {$Color = 12}
          5 {$Color = 14}
          6 {$Color = 15}
        }#SWITCH
        write-host -NoNewline -BackgroundColor DarkGray -ForegroundColor $Color ("$Digit  ")
      }#FOREACH
    }#IF
    else {
      write-host -NoNewline -BackgroundColor Black (" " * $BoardSpecs.GuessPart)
    }#ELSE
  }#IF
  else {
    write-host -NoNewline -BackgroundColor Black (" " * $BoardSpecs.GuessPart)
  }
  write-host -BackgroundColor DarkGray (" " * $BoardSpecs.RBorder)      
  write-host -NoNewline (" " * $BoardSpecs.LGutter)
  write-host -BackgroundColor DarkGray (" " * $BoardSpecs.Overall)
  write-host -NoNewline (" " * $BoardSpecs.LGutter)
  write-host -BackgroundColor DarkGray (" " * $BoardSpecs.Overall)  
  if ($BoardLinesRequired -ge 1) {
    1..$BoardLinesRequired | foreach {
      write-host -NoNewline (" " * $BoardSpecs.LGutter)
      write-host -BackgroundColor DarkGray (" " * $BoardSpecs.Overall)
      write-host -NoNewline (" " * $BoardSpecs.LGutter)
      write-host -BackgroundColor DarkGray (" " * $BoardSpecs.Overall)  
    }#FOREACH
  }#IF
  if ($Results -ne  $null){
    foreach ($Result in $Results) {

    write-host -NoNewline (" " * $BoardSpecs.LGutter)
    write-host -NoNewline -BackgroundColor DarkGray (" " * $BoardSpecs.LBorder)
    write-host -NoNewline -BackgroundColor DarkGray -ForegroundColor DarkGray ("  " * $Result.WrongColor)    
    write-host -NoNewline -BackgroundColor DarkGray -ForegroundColor Black ("▌ " * $Result.RightPlace)    
    write-host -NoNewline -BackgroundColor DarkGray -ForegroundColor white ("▌ " * $Result.WrongPlace)
    write-host -NoNewline -BackgroundColor DarkGray (" " * $BoardSpecs.MBorder)
    foreach ($Digit in $Result.Guess.Numbers){
      switch ($Digit) {
        1 {$Color = 0}
        2 {$Color = 10}
        3 {$Color = 11}
        4 {$Color = 12}
        5 {$Color = 14}
        6 {$Color = 15}
      }#SWITCH
      write-host -NoNewline -BackgroundColor DarkGray -ForegroundColor $Color ("$Digit  ")
    }#FOREACH
    write-host -BackgroundColor DarkGray (" " * $BoardSpecs.RBorder)
    write-host -NoNewline (" " * $BoardSpecs.LGutter)
    write-host -BackgroundColor DarkGray (" " * $BoardSpecs.Overall)
    }#FOREACH
  }#IF
}#FUNCTION

#endregion FUNCTIONS

#region MAINCODE

#region VARIABLE DECLARATION
$Turn = 0
[psobject[]]$Results = @()
$LGutter = 1; $LBorder = 3;$MBorder = 2;$RBorder = 1;$SSpace  = 1;$GSpace  = 2
$Overall = $LBorder+$RBorder+$MBorder+($SSpace *4)+($GSpace*4)+4+4
$LeftHalf = $LBorder+($SSpace*4)+4+$MBorder
$GuessPart =  4+($GSpace*4)
$BoardProperties =@{
  LGutter = $LGutter
  LBorder = $LBorder
  RBorder = $RBorder
  MBorder = $MBorder
  SSpace = $SSpace
  GSpace = $GSpace
  LeftHalf = $LeftHalf
  GuessPart = $GuessPart
  Overall = $Overall
}; $BoardSpec = New-Object -TypeName psobject -Property $BoardProperties

#endregion VARIABLE DECLARATION

#region CORE CODE
$Master = Get-Master
Draw-Board -TurnNumber $Turn -BoardSpecs $BoardSpec
Do {
  $CurrentGuess = Get-Guess 
  $Turn++
  $CurrentResult = Compare-GuessToMaster -Master $Master -Guess $CurrentGuess -Sequence $Turn  
  $Results += $CurrentResult 
  $Results = $Results | Sort-Object -Descending -Property Order
  Draw-Board -Results $Results -TurnNumber $Turn -BoardSpecs $BoardSpec
  if ($Results[0].RightPlace -eq 4) {Break}
} Until ($Turn -eq 10)

if ($Results[0].RightPlace -eq 4) {Write-Host -ForegroundColor Green "`n`nYOU DID IT`n`n"}
else {Write-Host -ForegroundColor Red "`n`nYOU RAN OUT OF CHANCES`n`n"}
#endregion CORE CODE

#endregion MAINCODE