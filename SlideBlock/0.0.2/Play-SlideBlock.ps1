[cmdletbinding()]
Param ()

Class Element {
  [string]$Value
  [int]$Position
  [int]$Row
  [int]$Col
  [int[]]$Neighbours

  Element ([string]$Val,[int]$Pos) {  
    $this.Value = $Val 
    $this.Position = $Pos
    $this.Row = [math]::Truncate($Pos/3)
    $this.Col = $Pos%3
    if ($Pos -eq 0) {$this.Neighbours = @(1,3)}
    elseif ($Pos -eq 1) {$this.Neighbours = @(0,4,2)}
    elseif ($Pos -eq 2) {$this.Neighbours = @(1,5)}
    elseif ($Pos -eq 3) {$this.Neighbours = @(0,6,4)}
    elseif ($Pos -eq 4) {$this.Neighbours = @(1,3,5,7)}
    elseif ($Pos -eq 5) {$this.Neighbours = @(2,8,4)}
    elseif ($Pos -eq 6) {$this.Neighbours = @(3,7)}
    elseif ($Pos -eq 7) {$this.Neighbours = @(6,4,8)}
    elseif ($Pos -eq 8) {$this.Neighbours = @(5,7)}
  }
}

Class Board {
  [Element[]]$Element 

  Board ($Elements) {
    $this.Element = $Elements
  }

  [bool]MoveElement ([string]$FaceValue) {
    $EmptyElement = $this.Element | Where-Object {$_.Value -eq '-'}
    $ChosenElement = $this.Element | Where-Object {$_.Value -eq $FaceValue}
    $ChosenNeighbours = $ChosenElement.Neighbours
    if ($EmptyElement.Position -in $ChosenNeighbours) {
      # this is a neighbour
      $TempSwapVal = $ChosenElement.Value
      $ChosenElement.Value = $EmptyElement.Value
      $EmptyElement.Value = $TempSwapVal
      return $true
    }
    else {return $false}
  }
}


# Functions 

function Show-Game {
  Param ([Board]$Game)
  Clear-Host
  $Elements = $Game.Element
  Write-Host '+---+---+---+'
  $Elements | Sort-Object -Property Position | ForEach-Object {
    if ($_.Col -eq 0 -and $_.Row -ne 0) {Write-Host }
    if ($_.Value -match '[1-8]') {Write-Host "| $($_.Value) " -NoNewline}
    else {Write-Host "|   " -NoNewline}
    if ($_.Col -eq 2) {
      Write-Host '|' 
      Write-Host '+---+---+---+' -NoNewline
    }
  }
  Write-Host
  Write-Host
}

function Set-GameRandom {
  Param ([Board]$Game)
  1..5000 | ForEach-Object {
    $Move = 1..8 | Get-Random
    $Result = $Game.MoveElement($Move)
  }
}

# Main Code 

$Numbers = '1','2','3','4','5','6','7','8','-'
$Slides = 0..8 | ForEach-Object {[Element]::New($Numbers[$_],$_)}
$GameBoard = [Board]::New($Slides)
Set-GameRandom -Game $GameBoard
$TurnCounter = 0

do {
  Show-Game -Game $GameBoard
  do {
    $Choice = Read-Host -Prompt "Enter a number to move"
    $LegalMove = $GameBoard.MoveElement($Choice)
  } until ($LegalMove)
  $GameState = $GameBoard.Element.Value -join ''
  $TurnCounter++
} until ($GameState -eq '12345678-' )    
Show-Game -Game $GameBoard
Write-Host "That took $TurnCounter moves"
