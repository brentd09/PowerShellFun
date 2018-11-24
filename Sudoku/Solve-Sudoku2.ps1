<#
.SYNOPSIS
  Short description
.DESCRIPTION
  Long description
.EXAMPLE
  PS C:\> <example usage>
  Explanation of what the example does
.INPUTS
  Inputs (if any)
.OUTPUTS
  Output (if any)
.NOTES
  General notes
#>
[CmdletBinding()]
Param (
  $Puzzle = '--9748---7---------2-1-9-----7---24--64-1-59--98---3-----8-3-2---------6---2759--'
)
class BoardPosition {
  [string]$Val
  [int]$Pos
  [int]$Col
  [int]$Row
  [int]$Box
  [string[]]$PossibleValues
  [string[]]$RulledOutValues

  BoardPosition([string]$Val,[int]$Pos) {
    $this.Val = $Val
    $this.Pos = $Pos
    $this.Row = [math]::Truncate($Pos / 9)
    $this.Col = $Pos % 9
    if     ($Pos -in @(0,1,2,9,10,11,18,19,20))     {$this.Box = 0}
    elseif ($Pos -in @(3,4,5,12,13,14,21,22,23))    {$this.Box = 1}
    elseif ($Pos -in @(6,7,8,15,16,17,24,25,26))    {$this.Box = 2}
    elseif ($Pos -in @(27,28,29,36,37,38,45,46,47)) {$this.Box = 3}
    elseif ($Pos -in @(30,31,32,39,40,41,48,49,50)) {$this.Box = 4}
    elseif ($Pos -in @(33,34,35,42,43,44,51,52,53)) {$this.Box = 5}
    elseif ($Pos -in @(54,55,56,63,64,65,72,73,74)) {$this.Box = 6}
    elseif ($Pos -in @(57,58,59,66,67,68,75,76,77)) {$this.Box = 7}
    elseif ($Pos -in @(60,61,62,69,70,71,78,79,80)) {$this.Box = 8}
  }
}

# Functions
Function Get-SoleCandidate {
  Param {
    [BoardPosition[]]$fnPuzzle
  }
  $RefNums = @('1','2','3','4','5','6','7','8','9')
  foreach ($fnPos in $fnBoardPosition) {
    if ($fnPos.Val -match '\d' ) {continue}
    [String[]]$RowVals = ($fnPuzzle | Where-Object {$_.Row -eq $fnPos.Row}).Val | Where-Object {$_ -match '\d'}
    [String[]]$ColVals = ($fnPuzzle | Where-Object {$_.Col -eq $fnPos.Col}).val | Where-Object {$_ -match '\d'}
    [String[]]$BoxVals = ($fnPuzzle | Where-Object {$_.Box -eq $fnPos.Box}).val | Where-Object {$_ -match '\d'}
    $AllVals = ($RowVals + $ColVals + $BoxVals) | Select-Object -Unique
    $PossVals = $RefNums | Where-Object {$_ -notin $AllVals}
    $fnPuzzle.$PossibleValues = $PossVals
  }
}
