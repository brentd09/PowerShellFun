[cmdletbinding()]
Param (
  [ValidateSet(3,4,5)]
  [int]$BoardSize = 4
)

Class Element {
  [string]$Value
  [int]$Position
  [int]$Row
  [int]$Col
  [int[]]$Neighbours

  Element ([string]$Val,[int]$Pos,[int]$Size) {  
    $this.Value = $Val 
    $this.Position = $Pos
    $this.Row = [math]::Truncate($Pos/$Size)
    $this.Col = $Pos % $Size
    $RealNeighbours = @()
    $PotentialAboveNeighbour = $Pos-$Size
    $PotentialBelowNeighbour = $Pos+$Size
    $PotentialLeftNeighbour = $Pos-1
    $PotentialRightNeighbour =  $Pos+1
    $RowOfPotLeftNbr = [math]::Abs([math]::Truncate($PotentialLeftNeighbour / $Size))
    $RowOfPotRightNbr = [math]::Abs([math]::Truncate($PotentialRightNeighbour / $Size))
    if ($PotentialAboveNeighbour -ge 0) {$RealNeighbours += $PotentialAboveNeighbour}
    if ($PotentialBelowNeighbour -lt ($Size*$Size)) {$RealNeighbours += $PotentialBelowNeighbour}
    if ($this.Row -eq $RowOfPotLeftNbr -and $PotentialLeftNeighbour -ge 0) {$RealNeighbours += $PotentialLeftNeighbour}
    if ($this.Row -eq $RowOfPotRightNbr -and $PotentialRightNeighbour -lt ($Size*$Size)) {$RealNeighbours += $PotentialRightNeighbour}
    $this.Neighbours = $RealNeighbours
  }
}

Class Board {
  [Element[]]$Element 

  Board ($Elements) {
    $this.Element = $Elements
  }

  [bool]MoveElement ([string]$FaceValue,[int]$Size) {
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
    elseif ($ChosenElement.Row -eq $EmptyElement.Row -or $ChosenElement.Col -eq $EmptyElement.Col) {
      if ($ChosenElement.Row -eq $EmptyElement.Row) {
        if ($ChosenElement.Col -gt $EmptyElement.Col) {
          ($EmptyElement.Position + 1)..$ChosenElement.Position | ForEach-Object {$this.MoveElementByPosition($_)}
        }
        else {          
          ($EmptyElement.Position - 1)..$ChosenElement.Position | ForEach-Object {$this.MoveElementByPosition($_)}
        }
      }
      if ($ChosenElement.Col -eq $EmptyElement.Col) {
        if ($ChosenElement.Row -gt $EmptyElement.Row) {
          for ($Pos = $EmptyElement.Position + $Size;$Pos -le $ChosenElement.Position;$Pos = $Pos + $Size) {$this.MoveElementByPosition($Pos)}
        }
        else {          
          for ($Pos = $EmptyElement.Position - $Size;$Pos -ge $ChosenElement.Position;$Pos = $Pos - $Size) {$this.MoveElementByPosition($Pos)}
        }
      }
      return $true
    } # these are so I can move multiple elements at once either on the came row or col   
    else {return $false}
  }

  [bool]MoveElementByPosition ([int]$PositionToSwap) {
    $EmptyElement = $this.Element | Where-Object {$_.Value -eq '-'}
    $ChosenElement = $this.Element | Where-Object {$_.Position -eq $PositionToSwap}
    $ChosenNeighbours = $ChosenElement.Neighbours
    if ($EmptyElement.Position -in $ChosenNeighbours) {
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
  Param (
    [Board]$Game,
    [int]$Size
  )
  Clear-Host
  $BoardFaces = 'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y'
  $Elements = $Game.Element
  $SizeIndex = $Size - 1
  $Horizontal = (1..$SizeIndex | ForEach-Object {"+---"} ) -join ''
  $Horizontal += '+---+'
  Write-Host $Horizontal
  $Elements | Sort-Object -Property Position | ForEach-Object {
    if ($_.Value -in $BoardFaces) {Write-Host "| $($_.Value) " -NoNewline}
    else {Write-Host "|   " -NoNewline}
    if ($_.Col -eq ($Size - 1)) {
      Write-Host "|"
      Write-Host $Horizontal
    } 
  }
  Write-Host
}

function Set-GameRandom {
  Param (
    [Board]$Game,
    [int]$Size
  )
  Clear-Host
  Write-Host -ForegroundColor Red "Please wait while I shuffle the tiles"
  $BoardFaces = 'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y'
  1..($Size * 50) | ForEach-Object {
    do {
      $Empty = $Game | Where-Object {$_.Element.Value -match '-'}
      $RandomNeighbour = $Empty.Element.Neighbours | Get-Random
      $Result = $Game.MoveElement($BoardFaces[$RandomNeighbour-1],$BoardSize)
    } until ($Result -eq $true)
  }
}

# Main Code 
$BoardFaces = 'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y'
$MaxBoardPos = $BoardSize * $BoardSize - 1
$Numbers = 1..$MaxBoardPos
$Numbers += '-'
$Slides = 0..$MaxBoardPos | ForEach-Object {
  if ($_ -lt $MaxBoardPos) {[Element]::New($BoardFaces[$_],$_,$BoardSize)}
  else {[Element]::New('-',$MaxBoardPos,$BoardSize)}
}

$GameBoard = [Board]::New($Slides)
Set-GameRandom -Game $GameBoard -Size $MaxBoardPos
$TurnCounter = 0

do {
  $GameSolved = $false
  Show-Game -Game $GameBoard -Size $BoardSize
  do {
    $Choice = Read-Host -Prompt "Enter a Letter to move"
    $LegalMove = $GameBoard.MoveElement($Choice,$BoardSize)
  } until ($LegalMove)
  $GameState = $GameBoard.Element.Value -join ''
  if ($BoardSize -eq 3 -and $GameState -eq 'ABCDEFGH-') {$GameSolved = $true}
  elseif ($BoardSize -eq 4 -and $GameState -eq 'ABCDEFGHIJKLMNO-') {$GameSolved = $true}
  elseif ($BoardSize -eq 5 -and $GameState -eq 'ABCDEFGHIJKLMNOPQRSTUVWX-') {$GameSolved = $true}
  $TurnCounter++
} until ($GameSolved -eq $true)    
Show-Game -Game $GameBoard -Size $BoardSize
Write-Host "That took $TurnCounter moves"
