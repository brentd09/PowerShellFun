

# Class definitions

Class TTTBoardCell {
  [int]$Position
  [string]$Value 
  [bool]$Played

  TTTBoardCell ([int]$ArrayPos) {
    $this.Position = $ArrayPos
    $this.Value = ($ArrayPos + 1) -as [string]
    $this.Played = $false
  }

  [bool]PlayCell ([string]$XorO) {
    if ($this.Played -eq $true -or $XorO -notin @('X','O')) {return $false}
    else {
      $this.Played = $true
      $this.Value = $XorO
      return $true
    }
  }
}

class TTTBoard {
  [TTTBoardCell[]]$Cells
  [string]$Winner 

  TTTBoard () {
    $this.Cells = foreach ($Pos in (0..8)) { [TTTBoardCell]::New($Pos)}
    $this.Winner = 'N'
  }
}

Function Test-TerminalState {
  Param (
    [TTTBoard]$GameBoard
  )
  [System.Collections.ArrayList]$WinningLines = @(
    @(0,1,2),@(3,4,5),@(6,7,8),
    @(0,3,6),@(1,4,7),@(2,5,8),
    @(0,4,8),@(2,4,6)
  )
  foreach ($Line in $WinningLines) {
    # Check to see if all three places have the same Value (X or O)
    if ($GameBoard.Cells[$Line[0]])
  }
}

$Board = [TTTBoard]::New()
$Board