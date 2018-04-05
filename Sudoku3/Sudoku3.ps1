[Cmdletbinding()]
Param (
  [ValidateLength(81,81)]
  [string]$SudokuBoard = '--5--7--4-6--5--9-4--9--2--2--5--1---7--2--4---8--3--2--7--1--3-5--6--1-6--8--4--'
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
      Block    = ($BlockListObj | Where-Object {$_.BlockLocation -contains $PosNum}).BlockNumber
      Value   = @('1','2','3','4','5','6','7','8','9') -as [char[]]
      Solved   = $false
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

function Find-CandidateSolvedCell {
  param (
    $fnBoardObj,
    $fnCandidateObj
  )
  $NotBlankList = $fnBoardObj | Where-Object {$_.Value -ne [char]'-'}
  foreach ($NotBlank in $NotBlankList) {
    $fnCandidateObj[$NotBlank.Position].Value = $NotBlank.Value 
    $fnCandidateObj[$NotBlank.Position].Solved = $true
  } # Foreach
  $fnCandidateObj
} # Function

function Update-CandidateList {
  Param (
    $fnCandidate
  )
  foreach ($PosNum in (0..80)) {
    $Row   = $fnCandidate[$PosNum].Row
    $Col   = $fnCandidate[$PosNum].Col
    $Block = $fnCandidate[$PosNum].Block
    $Solved = $fnCandidate | Where-Object {$_.Solved -eq $true} 
    $RelatedSolved =  $Solved | Where-Object {$_.Row -eq $Row -or $_.Col -eq $Col -or $_.Block -eq $Block }
    $NewValues = $fnCandidate[$PosNum].Value | Where-Object {$_ -notin $RelatedSolved.Value}
    if ($NewValues.count -gt 1) {
      $fnCandidate[$PosNum].Value = $NewValues
    }
    elseif ($NewValues.count -eq 1) {
      $fnCandidate[$PosNum].Value = $NewValues
      $fnCandidate[$PosNum].Solved = $true
    }
  }
  return $fnCandidate
}

function Find-CandidateHiddenPairs {
  Param (
    $fnCandidateObj
  )

  foreach ($RowNum in (0..8)) {
    $RowObjs = ($fnCandidateObj | Where-Object {$_.Row -eq $RowNum -and $_.Solved -eq $false}) 
    $GroupRowObj = $RowObjs | Group-Object -Property Value
    $GroupRowVals = ($GroupRowObj.Group.value | Group-Object | Where-Object {$_.count -eq 2}).Group | Select-Object -Unique
    foreach ($RowObj in $RowObjs) {
      if ($RowObj.Value -contains $GroupRowVals) { } # if 
    } # foreach
    $FoundRowObj = $RowObj | Where-Object {$_.Value -contains $GroupRowVals} | Select-Object -Unique
    if ($FoundRowObj.Block.Count -eq 1) {
      foreach ($FoundRow in $FoundRowObj) {
        $fnCandidateObj[$FoundRow.Position].Value = $fnCandidateObj[$FoundRow.Position].Value | Where-Object {$_ -in $GroupRowVals}
      } # foreach
    } # if
    Start-Sleep -Milliseconds 10
  } # foreach
  foreach ($ColNum in (0..8)) {

  }
  return $fnCandidateObj
} 


function Find-CandidateSingleHiddenBlock {
  Param (
    $fnCandidateObj
  )
  foreach ($BlockNum in (0..8)) {
    $CandidateBlockObj = $fnCandidateObj | Where-Object {$_.Block -eq $BlockNum -and $_.Solved -eq $false}
    $SingleCandidateValues = ($CandidateBlockObj.Value | Group-Object | Where-Object {$_.count -eq 1}).Group
    foreach ($SingleCandidateValue in $SingleCandidateValues) {
      $TargetCandidate = $CandidateBlockObj | Where-Object {$_.Value -contains $SingleCandidateValue -and $_.Solved -eq $false}
      if ($TargetCandidate -ne $null ){
        $fnCandidateObj[$TargetCandidate.Position].Value = $SingleCandidateValue -as [char]
        $fnCandidateObj[$TargetCandidate.Position].Solved = $true
      }
        continue 
    }
  }
  return $fnCandidateObj
}

function Update-Board {
  Param (
    $fnBoardObj,
    $fnCandidateObj
  )
  foreach ($Candidate in $fnCandidateObj) {
    if ($Candidate.Value.count -eq 1) {
      $fnBoardObj[$Candidate.Position].Value = $Candidate.Value[0]
    }
  }
  return $fnBoardObj
}

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




## MAIN CODE ##

$BlockListObj = New-BlockValidation
$AllCandidates = New-CandidateList -fnBlockListObj $BlockListObj
$RawBoardArray = New-RawBoard -Board $SudokuBoard
$BoardObj = New-BoardObject -fnRawBoard $RawBoardArray
do {
  $StartBlankCount = ($AllCandidates | Where-Object {$_.Solved -eq $false}).count
  $AllCandidates = Find-CandidateSolvedCell -fnBoardObj $BoardObj -fnCandidateObj $AllCandidates
  $AllCandidates = Update-CandidateList -fnCandidate $AllCandidates
  $EndBlankCount = ($AllCandidates | Where-Object {$_.Solved -eq $false}).count
  if ($StartBlankCount -eq $EndBlankCount) {
    $AllCandidates = Find-CandidateSingleHiddenBlock -fnCandidateObj $AllCandidates
    #$AllCandidates = Find-CandidateHiddenPairs -fnCandidateObj $AllCandidates
  }  
  $BoardObj = Update-Board -fnBoardObj $BoardObj -fnCandidateObj $AllCandidates
  Show-Board -fnBoardObj $BoardObj
  Start-Sleep -Seconds 1
} until ($BoardObj.Value -notcontains [char]'-')