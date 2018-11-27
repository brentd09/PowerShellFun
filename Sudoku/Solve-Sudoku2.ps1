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
  $Puzzle = '7-542--6-68-1--24--4-76--18-91--2-7482--576--3---1482-158--6--9--25-91-6--684-7-2'
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
    $this.PossibleValues = 1..9
  }
}

function Create-Board {
  Param (
    $fnPuzzle
  )
  $Board = @()
  foreach ($Pos in (0..80)){
    $BoardVal = $fnPuzzle.Substring($Pos,1)
    $Board += [BoardPosition]::New($BoardVal,$Pos)
  }
  $Board
}

# Functions
Function Get-SoleCandidate {
  Param (
    $fnPuzzle
  )
  foreach ($Pos in (0..80)) {
    if ($fnPuzzle[$Pos].PossibleValues.count -eq 1) {
      $fnPuzzle[$Pos].Val = $fnPuzzle[$Pos].PossibleValues[0]
    }
  }
}

function Show-Board {
  Param (
    $fnPuzzle
  )
  Clear-Host
  $FGColor = 'Yellow'
  foreach ($PosCol in (0..8)) {
    if ($PosCol -eq 2 -or $PosCol -eq 5) {$HBdr = "`n------+-------+------"}
    else {$HBdr = ''}
    foreach ($PosRow in (0..8)) {
      if ($PosRow -eq 2 -or $PosRow -eq 5) {$Bdr = ' | '}
      else {$Bdr = ' '}
      Write-Host -NoNewline $fnPuzzle[($PosRow+($PosCol*9))].Val
      Write-Host -NoNewline -ForegroundColor $FGColor "$Bdr"
    }
    Write-Host -ForegroundColor $FGColor $HBdr
  }
}

function Remove-Possibles  {
  Param ($fnPuzzle)

  foreach ($Pos in (0..80)) {
    if ($fnPuzzle[$Pos].Val -match '\d') {
      $fnPuzzle[$Pos].PossibleValues = $fnPuzzle[$Pos].Val
    }
    else {
      [array]$FocusRowVals = ($fnPuzzle | Where-Object {$_.Row -eq $fnPuzzle[$Pos].Row}).Val | Where-Object {$_ -match '\d'}
      [array]$FocusColVals = ($fnPuzzle | Where-Object {$_.Col -eq $fnPuzzle[$Pos].Col}).Val | Where-Object {$_ -match '\d'}
      [array]$FocusBoxVals = ($fnPuzzle | Where-Object {$_.Box -eq $fnPuzzle[$Pos].Box}).Val | Where-Object {$_ -match '\d'}
      $focusArray = ($FocusRowVals + $FocusColVals + $FocusBoxVals) | Select-Object -Unique
      $fnPuzzle[$Pos].PossibleValues = $fnPuzzle[$Pos].PossibleValues | Where-Object {$_ -notin $focusArray}
    }  
  }
}


do {
$Board = Create-Board $Puzzle
Remove-Possibles -fnPuzzle $Board
Get-SoleCandidate -fnPuzzle $Board
Show-Board -fnPuzzle $Board
Read-Host
} while ($true)