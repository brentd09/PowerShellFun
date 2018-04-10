[Cmdletbinding()]
Param (
  [ValidateLength(81,81)]
  [string]$SudokuBoard = '89-2-3-------------3658---41-8-3--6-----------2--7-3-57---9412-------------8-2-59'
)

# Using the https://www.sudoku-solutions.com/ website you can try solving these to help with the 
# coding functions.
# Easy       '-6-3--8 4537-9-----4---63-7-9..51238---------71362--4-3-64---1-----6-5231-2--9-8-'
# Medium     '-1--584-9--------1953---2--2---1--8-6--425--3-3--7---4--5---3973--------1-463--5-'
# Difficult  '-2-------17---9--4---1367--431---2------8------8---163--3624---2--8---49-------3-'
# Extreme    '89-2-3-------------3658---41-8-3--6-----------2--7-3-57---9412-------------8-2-59'
# Extreme    '--9748---7---------2-1-9-----7---24--64-1-59--98---3-----8-3-2---------6---2759--'
# Extreme    '--5--7--4-6--5--9-4--9--2--2--5--1---7--2--4---8--3--2--7--1--3-5--6--1-6--8--4--'
function New-BlockValidation {
  $Blocklocation = @(
    @(0,1,2,9,10,11,18,19,20),
    @(3,4,5,12,13,14,21,22,23),
    @(6,7,8,15,16,17,24,25,26),
    @(27,28,29,36,37,38,45,46,47),
    @(30,31,32,39,40,41,48,49,50),
    @(33,34,35,42,43,44,51,52,53),
    @(54,55,56,63,64,65,72,73,74),
    @(57,58,59,66,67,68,75,76,77),
    @(60,61,62,69,70,71,78,79,80)
  )
  $BlockNumber = @(0,1,2,3,4,5,6,7,8)
  foreach ($Num in (0..8)) {
    $BlockValidationProp = @{
      BlockLocation = $Blocklocation[$Num]
      BlockNumber   = $BlockNumber[$Num]    
    }
    New-Object -TypeName psobject -Property $BlockValidationProp
  }
}

function New-RawBoard {
  Param (
    $Board
  )
  if ($Board.length -eq 81) {
    $Board = $Board -replace "\D",'-'
    $BoardArray = $Board -as [char[]]
    return $BoardArray  
  } # if board.length
  else {break}
} # fn new-rawboard

function New-CandidateList {
  Param (
    $fnBlockListObj
  )
  foreach ($PosNum in (0..80)) {
    $CandidateProp = @{
      Position = $PosNum
      Row      = [math]::Truncate($PosNum / 9)
      Col      = $PosNum % 9
      Block    = ($fnBlockListObj | Where-Object {$_.BlockLocation -contains $PosNum}).BlockNumber
      Value   = @('1','2','3','4','5','6','7','8','9') -as [char[]]
    }
    New-Object -TypeName psobject -Property $CandidateProp
  }
}

function New-BoardObject {
  Param (
    $fnRawBoard,
    $BlockListObj
  )
  foreach ($PosNum in (0..80)) {
    $PosObjProp = [ordered]@{
      Position   = $PosNum
      Row        = ([math]::Truncate($PosNum/9))
      Col        = $PosNum % 9
      Block      = ($BlockListObj | Where-Object {$_.BlockLocation -contains $PosNum}).BlockNumber
      Value      = $fnRawBoard[$PosNum]
    } # HashTable posobjprops
    New-Object -TypeName psobject -Property $PosObjProp
  } # foreach posnum
} # fn Get-BoardObject

function Show-Board {
  param (
    $fnBoardObj
  )
  #Clear-Host
  $Coords = New-Object -TypeName System.Management.Automation.Host.Coordinates
  $host.UI.RawUI.CursorPosition = $Coords
  Write-Host
  $Margin = '   '
  $LineColor = "Cyan"
  $NumberColor = "Yellow"
  $BlankColor = "Red"
  Write-Host -ForegroundColor $LineColor "$Margin -----------------------"
  foreach ($ShowRow in (0..8)) {
    Write-Host -NoNewline $Margin
    foreach ($ShowCol in (0..8)) {
      if ($ShowCol -eq 0) {Write-Host -NoNewline -ForegroundColor $LineColor "| "}      
      $BoardPosObj = $fnBoardObj | Where-Object {$_.Row -eq $ShowRow -and $_.Col -eq $ShowCol}
      if ($BoardPosObj.Value -match '\d') {Write-Host -NoNewline -ForegroundColor $NumberColor $BoardPosObj.Value}
      if ($BoardPosObj.Value -eq '-') {Write-Host -NoNewline -ForegroundColor $BlankColor $BoardPosObj.Value}
      Write-Host -NoNewline " "
      if ($ShowCol -eq 2 -or $ShowCol -eq 5 -or $ShowCol -eq 8) {Write-Host -NoNewline -ForegroundColor $LineColor "| "}
    } # foreach showcol
    Write-Host # This is to seperate the rows
    if ($ShowRow -eq 2 -or $ShowRow -eq 5) {Write-Host -ForegroundColor $LineColor "$Margin|-----------------------|"}

  } #foreach showrow
  Write-Host -ForegroundColor $LineColor "$Margin -----------------------"
} # fn Showboard

function Update-CandidateFromBoard {
  Param (
    $fnBoard,
    $fnCandidate
  )
  $AllFound = $fnBoard | Where-Object {$_.Value -ne '-'}
  foreach ($Position in (0..80)) {
    if ($fnBoard[$Position].Value -ne '-') {
      $fnCandidate[$Position].Value = $fnBoard[$Position].Value
    }
    else {
      $Row   = $fnBoard[$Position].Row
      $Col   = $fnBoard[$Position].Col
      $Block = $fnBoard[$Position].Block
      $RelatedSolved = $AllFound | Where-Object {$_.Row -eq $Row -or $_.Col -eq $Col -or $_.Block -eq $Block} 
      $ValuesRemain = $fnCandidate[$Position].Value | Where-Object {$_ -notin $RelatedSolved.Value}
      $fnCandidate[$Position].Value = $ValuesRemain
    }
  }
  return $fnCandidate
}

function Update-CandidateHiddenSingle {
  Param (
    $fnCandidate
  )
  foreach ($BlockNum in (0..8)) {
    $Block = $fnCandidate | Where-Object {$_.Block -eq $BlockNum}
    $GrpBlockSingleVals = ($Block.Value | Sort-Object | Group-Object | Where-Object {$_.Count -eq 1}).Name
    foreach ($SingleVal in $GrpBlockSingleVals) {
      $FoundSingle = $Block | Where-Object {$_.Value -contains $SingleVal}
      $fnCandidate[$FoundSingle.Position].Value = $SingleVal
    }
  }
  return $fnCandidate
}

function Update-CandidateHiddenPair {
  Param (
    $fnCandidate
  )
  foreach ($RowNum in (0..8)) {
    $RowCells = $fnCandidate | Where-Object {$_.Row -eq $RowNum}
    $PairVals = ($RowCells.Value | Group-Object | Where-Object {$_.Count -eq 2}).Name
    if ($PairVals -ne $null) {
      $Cell1 = $RowCells | Where-Object {$_.Value -contains $PairVals[0]}
      $Cell2 = $RowCells | Where-Object {$_.Value -contains $PairVals[1]}
      $CompCell12 = $Cell1.Position | Where-Object {$_ -notin $Cell2.Position}
      $CompCell21 = $Cell2.Position | Where-Object {$_ -notin $Cell1.Position}
      if ($Cell1.count -eq 2 -and $Cell2.count -eq 2 -and ($fnCandidate[$Cell1[0].Position].Value.count -gt 2 -or $fnCandidate[$Cell1[1].Position].Value.count -gt 2)) {
        if ($CompCell12 -eq $null -and $CompCell21 -eq $null -and $PairVals.count -eq 2) {
          $fnCandidate[$Cell1[0].Position].Value = $PairVals
          $fnCandidate[$Cell1[1].Position].Value = $PairVals
        }
      }
    }
  }
  foreach ($ColNum in (0..8)) {
    $ColCells = $fnCandidate | Where-Object {$_.Col -eq $ColNum}
    $PairVals = ($ColCells.Value | Group-Object | Where-Object {$_.Count -eq 2}).Name
    if ($PairVals -ne $null) {
      $Cell1 = $ColCells | Where-Object {$_.Value -contains $PairVals[0]}
      $Cell2 = $ColCells | Where-Object {$_.Value -contains $PairVals[1]}
      $CompCell12 = $Cell1.Position | Where-Object {$_ -notin $Cell2.Position}
      $CompCell21 = $Cell2.Position | Where-Object {$_ -notin $Cell1.Position}
      if ($Cell1.count -eq 2 -and $Cell2.count -eq 2 -and ($fnCandidate[$Cell1[0].Position].Value.count -gt 2 -or $fnCandidate[$Cell1[1].Position].Value.count -gt 2)) {
        if ($CompCell12 -eq $null -and $CompCell21 -eq $null -and $PairVals.count -eq 2) {
          $fnCandidate[$Cell1[0].Position].Value = $PairVals
          $fnCandidate[$Cell1[1].Position].Value = $PairVals
        }
      }
    }
  }
  foreach ($BlockNum in (0..8)) {
    $BlockCells = $fnCandidate | Where-Object {$_.Block -eq $BlockNum}
    $PairVals = ($BlockCells.Value | Group-Object | Where-Object {$_.Count -eq 2}).Name
    if ($PairVals -ne $null) {
      $Cell1 = $BlockCells | Where-Object {$_.Value -contains $PairVals[0]}
      $Cell2 = $BlockCells | Where-Object {$_.Value -contains $PairVals[1]}
      $CompCell12 = $Cell1.Position | Where-Object {$_ -notin $Cell2.Position}
      $CompCell21 = $Cell2.Position | Where-Object {$_ -notin $Cell1.Position}
      if ($Cell1.count -eq 2 -and $Cell2.count -eq 2 -and ($fnCandidate[$Cell1[0].Position].Value.count -gt 2 -or $fnCandidate[$Cell1[1].Position].Value.count -gt 2)) {
        if ($CompCell12 -eq $null -and $CompCell21 -eq $null -and $PairVals.count -eq 2) {
          $fnCandidate[$Cell1[0].Position].Value = $PairVals
          $fnCandidate[$Cell1[1].Position].Value = $PairVals
        }
      }
    }
  }
  return $fnCandidate
}

function Update-Board {
  Param (
    $fnBoard,
    $fnCandidate
  )
  foreach ($Position in (0..80)) {
    if ($fnCandidate[$position].Value.Count -eq 1) {
      $fnBoard[$Position].Value = $fnCandidate[$Position].Value
    }
  }
  return $fnBoard
}


#### MAIN CODE ####

#INIT SETUP#
$BlockList = New-BlockValidation
$Candidates = New-CandidateList -fnBlockListObj $BlockList
$Board = New-BoardObject -fnRawBoard $SudokuBoard -BlockListObj $BlockList
$Candidates = Update-CandidateFromBoard -fnBoard $Board -fnCandidate $Candidates
#END OF INIT SETUP
do { 
$Candidates = Update-CandidateHiddenSingle -fnCandidate $Candidates
$Candidates = Update-CandidateFromBoard -fnBoard $Board -fnCandidate $Candidates
$Board = Update-Board -fnBoard $Board -fnCandidate $Candidates
Show-Board -fnBoardObj $Board 
Start-Sleep -Seconds 1
$Candidates = Update-CandidateHiddenPair -fnCandidate $Candidates
$Candidates = Update-CandidateFromBoard -fnBoard $Board -fnCandidate $Candidates
$Board = Update-Board -fnBoard $Board -fnCandidate $Candidates
Show-Board -fnBoardObj $Board
Start-Sleep -Seconds 1
} Until ($Board.Value -notcontains '-')