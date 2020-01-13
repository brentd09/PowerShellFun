

# Class definitions

Class ThreatList {
  [int[]]$XThreats
  [int[]]$OThreats

  ThreatList () {
    $this.XThreats = @()
    $this.OThreats = @()
  }
}

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

  TTTBoard () {
    $this.Cells = foreach ($Pos in (0..8)) { [TTTBoardCell]::New($Pos)}
  }

  [string]TestWin () {
    [System.Collections.ArrayList]$WinningLines = @(
      @(0,1,2),@(3,4,5),@(6,7,8),
      @(0,3,6),@(1,4,7),@(2,5,8),
      @(0,4,8),@(2,4,6)
    )
    [string]$Win = 'N'
    foreach ($Line in $WinningLines) {
      if ($this.Cells[$Line[0]].Value -eq $this.Cells[$Line[1]].Value -and $this.Cells[$Line[0]].Value -eq $this.Cells[$Line[2]].Value) {
        $Win = $this.Cells[$Line[0]].Value
        break
      }
    }
    return $Win
  }

  [ThreatList]TestThreat () {
    [System.Collections.ArrayList]$WinningLines = @(
      @(0,1,2),@(3,4,5),@(6,7,8),
      @(0,3,6),@(1,4,7),@(2,5,8),
      @(0,4,8),@(2,4,6)
    )
    $Threats = [ThreatList]::new()
    foreach ($Line in $WinningLines) {
      [string[]]$XsInLine = ($this.Cells[$Line].Value) -eq 'X'
      [string[]]$OsInLine = ($this.Cells[$Line].Value) -eq 'O'
      if ($XsInLine.count -eq 2 -and $OsInLine.Count -eq 0) {
        $ThreatPosString = ($this.Cells[$Line].Value) -ne 'X'
        $ThreatPos = ($ThreatPosString[0] -as [int]) -1
        $Threats.XThreats += $ThreatPos
      }
      if ($OsInLine.Count -eq 2 -and $XsInLine.Count -eq 0) {
        $ThreatPosString = ($this.Cells[$Line].Value) -ne 'O'
        $ThreatPos = ($ThreatPosString[0] -as [int]) -1
        $Threats.OThreats += $ThreatPos
      }
    }
    return $Threats
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
  
  }
}

$Board = [TTTBoard]::New()
$Board