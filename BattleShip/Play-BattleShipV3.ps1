<#
.SYNOPSIS
  Modelled on the board game Battleships
.DESCRIPTION
  This presents a view of the computers sea and the players sea
  each in turn tries to guess the loceation of each others ships
  with the aim of sinking all of the opponents ships before they
  sink yours.
  You enter the coordinates of the next attack and the screen
  shows you HIT or MISSED your target. The first one to sink the
  others ships is the winner. If you both sink the last ship in
  the same turn the game is considered a drawn game.
.EXAMPLE
  Play-BattleShipV3
.NOTES
  General notes
  Created By: Brent Denny
  Created On: 11 Apr 2019
#>
[CmdletBinding()]
Param()
#Class Definitions
Class BattleShipBoard {
  [int]$Pos
  [int]$Col
  [int]$Row
  [string]$Content
  [string]$Reveal
  [bool]$HitByOpponent
  [string]$Neighbours
  [int]$NextBestPosToGuess
  [int]$ChangeID

  BattleShipBoard ($Position) {
    $ColNum = $Position % 10
    $RowNum = [math]::Truncate($Position / 10)
    $this.Pos = $Position
    $this.Col = $ColNum
    $this.Row = $RowNum
    $this.Content = '-'
    $this.Reveal  = '-'
    $this.HitByOpponent = $false
    if ($RowNum -notin @(0,9) -and $ColNum -notin @(0,9)) {$this.Neighbours = 'UDLR'}
    elseif ($RowNum -eq 0 -and $ColNum -eq 0) {$this.Neighbours = 'DR'}
    elseif ($RowNum -eq 9 -and $ColNum -eq 0) {$this.Neighbours = 'UR'}
    elseif ($RowNum -eq 0 -and $ColNum -eq 9) {$this.Neighbours = 'DL'}
    elseif ($RowNum -eq 9 -and $ColNum -eq 9) {$this.Neighbours = 'UL'}
    elseif ($RowNum -eq 0) {$this.Neighbours = 'DLR'}
    elseif ($RowNum -eq 9) {$this.Neighbours = 'ULR'}
    elseif ($ColNum -eq 0) {$this.Neighbours = 'UDR'}
    elseif ($ColNum -eq 9) {$this.Neighbours = 'UDL'}
    $this.ChangeID = 0
    $this.NextBestPosToGuess = -1
  }

  [void]Attack ([int]$Turn) {
    $this.HitByOpponent = $true
    if ($this.Content -in @('A','B','C','D','S')) {$this.Reveal = 'H'}
    else {$this.Reveal = 'M'}
    $this.ChangeID = $Turn
  }

  [void]SetShipValue ($ShipType) {
    if ($ShipType -in 'A','B','C','D','S') {
      $this.Content = $ShipType
    }
  }

  [void]RemoveNeighbour ([string]$Direction) {
    if ($this.Neighbours -match $Direction -and $Direction.length -eq 1) {$this.Neighbours = $this.Neighbours -replace "$Direction",''}
  }
}
# Function Definitions
function Show-Boards {
  Param (
    [BattleShipBoard[]]$ComputerBoard,
    [BattleShipBoard[]]$PlayerBoard,
    [switch]$ShowShips
  )
  $Host.UI.RawUI.CursorPosition = @{ X = 0; Y = 0 } 
  $LegendColor = 'Yellow'
  foreach ($Grid in ('Computer','Player')) {
    Write-Host "$Grid's Ships"
    if ($Grid -eq 'Computer') {$Array = $ComputerBoard}
    else {$Array = $PlayerBoard}
    foreach ($RowToDisplay in (0..9)) {
      if ($RowToDisplay -eq 0) {Write-Host -ForegroundColor $LegendColor "   A  B  C  D  E  F  G  H  I  J"}
      foreach ($ColToDisplay in (0..9)) {
        if ($ColToDisplay -eq 0) {Write-Host -ForegroundColor $LegendColor -NoNewline "$($RowToDisplay)  "}
        $Position = $RowToDisplay * 10 + $ColToDisplay
        switch -Regex ($Array[$Position].Reveal) {
          '[-M]'       {$FColor = 'Darkgray'}
          '[ABCDS]' {$FColor = 'Yellow'}
          'H'       {$FColor = 'Red'}
        }
        if ($ShowShips -eq $true) {
          if ($Grid -eq 'Computer') {Write-Host -ForegroundColor $FColor -NoNewline "$($Array[$Position].Reveal)  "}
          else {
            if ($Array[$Position].Content -in @('A','B','C','D','S') -and $Array[$Position].HitByOpponent -eq $false) {$FColor = 'Green'}
            Write-Host -ForegroundColor $FColor -NoNewline "$($Array[$Position].Content)  "
          }
        }
        else { # Do not reveal the players ships
          if ($Grid -eq 'Computer') {Write-Host -ForegroundColor $FColor -NoNewline "$($Array[$Position].Reveal)  "}
          else {
            if ($Array[$Position].Content -in @('A','B','C','D','S') -and $Array[$Position].HitByOpponent -eq $false) {$FColor = 'Green'}
            Write-Host -ForegroundColor $FColor -NoNewline "$($Array[$Position].Reveal)  "
          }
        }
      }
      Write-Host
    }  
    Write-Host
  }
}
function Set-ShipPlacement {
  Param ([BattleShipBoard[]]$GameBoard)
  $Ships = @()
  $Ships += New-Object -TypeName psobject -Property @{ID='A';Size=5}
  $Ships += New-Object -TypeName psobject -Property @{ID='B';Size=4}
  $Ships += New-Object -TypeName psobject -Property @{ID='C';Size=3}
  $Ships += New-Object -TypeName psobject -Property @{ID='S';Size=3}
  $Ships += New-Object -TypeName psobject -Property @{ID='D';Size=2}
  foreach ($Ship in $Ships) {
    do {
      $Direction = @('H','V') | Get-Random
      if ($Direction -eq 'V') { # Vertical ship placement
        $StartRow = 0..(10-$Ship.Size) | Get-Random
        $StartCol = 0..9 | get-random
        $EndRow   = $Ship.Size + $StartRow -1
        $GoodPlacement = $true
        foreach ($PotentailRow in @($StartRow..$EndRow)) {
          $PotentailPos = $PotentailRow * 10 + $StartCol
          if ($GameBoard[$PotentailPos].Content -in @('A','B','C','D','S')) {$GoodPlacement = $false}
        }
        if ($GoodPlacement -eq $true) {
          foreach ($PotentailRow in @($StartRow..$EndRow)) {
            $PotentailPos = $PotentailRow * 10 + $StartCol
            $GameBoard[$PotentailPos].Content = $Ship.ID
          }
        }
      }
      else { # Horizontal ship placement
        $StartCol = 0..(10-$Ship.Size) | Get-Random
        $StartRow = 0..9 | get-random
        $EndCol   = $Ship.Size + $StartCol -1
        $GoodPlacement = $true
        foreach ($PotentailCol in @($StartCol..$EndCol)) {
          $PotentailPos = $StartRow * 10 + $PotentailCol
          if ($GameBoard[$PotentailPos].Content -in @('A','B','C','D','S')) {$GoodPlacement = $false}
        }
        if ($GoodPlacement -eq $true) {
          foreach ($PotentailCol in @($StartCol..$EndCol)) {
            $PotentailPos = $StartRow * 10 + $PotentailCol
            $GameBoard[$PotentailPos].Content = $Ship.ID
          }
        }
      }  
    } until ($GoodPlacement -eq $true)
  }
}
function Select-AttackLocation {
  Param (
    [BattleShipBoard[]]$GameBoard,
    [int]$TurnNumber,
    [switch]$Automatic
  )
  if ($AutoMatic -eq $false) {
    $GoodSelection = $false
    do {
      $Choice = Read-Host -Prompt 'Enter the coordinates to attack'
      if ($Choice -match '(^[A-J][0-9]$)|(^[0-9][A-J]$)') {
        $Choice = ($Choice.ToUpper()) -replace '(\d)(\w)','$2$1'
        $ColCoord = [byte][char]($Choice.Substring(0,1)) - 65
        $RowCoord = [byte][char]($Choice.Substring(1,1)) - 48
        $PosCoord = $RowCoord * 10 + $ColCoord
        $GoodSelection = $true
        if ($GameBoard[$PosCoord].HitByOpponent -eq $true) {$GoodSelection = $false}
      }
    } until ($GoodSelection -eq $true)
    $GameBoard[$PosCoord].Attack($TurnNumber)
  }
  else { # If $Automatic is $True 
    $HitCount = ($GameBoard | Where-Object {$_.Reveal -eq 'H'}).Count
    $CheckNeighbours = $GameBoard | Where-Object {$_.Reveal -eq 'H' -and $_.Neighbours.length -gt 0} 
    $CheckNeighbour = $CheckNeighbours | Get-Random
    if ($CheckNeighbours.Count -eq 0 -or $HitCount -le 3) {
      $NonAttackedPosses = ($GameBoard | Where-Object {$_.HitByOpponent -eq $false}).Pos | Where-Object {($_%2) -eq ([math]::Truncate($_/10)%2)}
      $NonAttackedPos = $NonAttackedPosses | Get-Random
      $GameBoard[$NonAttackedPos].Attack($TurnNumber)
    }
    else { 
      # $CurrentHits = $GameBoard | Where-Object {$_.Reveal -eq 'H'}
      # $HitsByRow = $CurrentHits | Sort-Object -Property Row

      #Check Hit neighbours
      # Need to look at all of the HITS to see if any are close proximity
      # if they are need to guess on the same line (row or col) until MISS
      # on both ends of the line are found!
      $RandomDirection = (($CheckNeighbour.Neighbours).toCharArray() | Get-Random) -as [string]
      switch ($RandomDirection) {
        'U' {$Shift = -10}
        'D' {$Shift =  10}
        'L' {$Shift =  -1}
        'R' {$Shift=    1}
      }
      $NeighbourPos = $CheckNeighbour.Pos + $Shift
      $GameBoard[$NeighbourPos].Attack($TurnNumber)
      $GameBoard[$CheckNeighbour.Pos].RemoveNeighbour($RandomDirection)
    }
  }
}
# #########################################
# MAIN CODE
$TurnSequence = 0
[BattleShipBoard[]]$Computer = 0..99 | ForEach-Object {[BattleShipBoard]::New($_)}
Set-ShipPlacement $Computer
$PlayerShipPlacementApproved = $false
do {
  [BattleShipBoard[]]$Player   = 0..99 | ForEach-Object {[BattleShipBoard]::New($_)}
  Set-ShipPlacement $Player
  Show-Boards -ComputerBoard $Computer -PlayerBoard $Player -ShowShips
  $Answer = Read-Host -Prompt "Do you approve of your ship placement"
  if ($Answer -like 'y*') {$PlayerShipPlacementApproved = $true}
} until ($PlayerShipPlacementApproved -eq $true)
Clear-Host
Show-Boards -ComputerBoard $Computer -PlayerBoard $Player
do {
  $TurnSequence++
  # Computer attacks Players's board
  Select-AttackLocation -GameBoard $Player  -TurnNumber $TurnSequence -Automatic
  # Player attacks Computer's board
  Select-AttackLocation -GameBoard $Computer -TurnNumber $TurnSequence 
  Show-Boards -ComputerBoard $Computer -PlayerBoard $Player
  $ComputerBoardHits = ($Computer | Where-Object {$_.Reveal -eq 'H'}).Count
  $PlayerBoardHits = ($Player | Where-Object {$_.Reveal -eq 'H'}).Count
} until ($ComputerBoardHits -eq 17 -or $PlayerBoardHits -eq 17)
If ($ComputerBoardHits -eq 17 -and $PlayerBoardHits -lt 17)     {Write-Host -ForegroundColor Green "`nPLAYER WINS`n`n"}
elseif ($ComputerBoardHits -lt 17 -and $PlayerBoardHits -eq 17) {Write-Host -ForegroundColor Green "`nCOMPUTER WINS`n`n"}
elseif ($ComputerBoardHits -eq 17 -and $PlayerBoardHits -eq 17) {Write-Host -ForegroundColor Green "`nGAME IS A DRAW`n`n"}