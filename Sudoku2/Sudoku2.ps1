[Cmdletbinding()]
Param (
  [ValidateLength(81,81)]
  [string]$SudokuBoard = '89-2-3-------------3658---41-8-3--6-----------2--7-3-57---9412-------------8-2-59'
)
# Easy       '-6-3--8 4537-9-----4---63-7-9..51238---------71362--4-3-64---1-----6-5231-2--9-8-'
# Medium     '-1--584-9--------1953---2--2---1--8-6--425--3-3--7---4--5---3973--------1-463--5-'
# Difficult  '-2-------17---9--4---1367--431---2------8------8---163--3624---2--8---49-------3-'
# Extreme    '89-2-3-------------3658---41-8-3--6-----------2--7-3-57---9412-------------8-2-59'
# Extreme    '--9748---7---------2-1-9-----7---24--64-1-59--98---3-----8-3-2---------6---2759--'
# Extreme    '--5--7--4-6--5--9-4--9--2--2--5--1---7--2--4---8--3--2--7--1--3-5--6--1-6--8--4--'
$BlockList = @(
  @( 0, 1, 2, 9,10,11,18,19,20),@( 3, 4, 5,12,13,14,21,22,23),@( 6, 7, 8,15,16,17,24,25,26),
  @(27,28,29,36,37,38,45,46,47),@(30,31,32,39,40,41,48,49,50),@(33,34,35,42,43,44,51,52,53),
  @(54,55,56,63,64,65,72,73,74),@(57,58,59,66,67,68,75,76,77),@(60,61,62,69,70,71,78,79,80)
)


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

function Get-BoardObject {
  Param (
    $fnRawBoard,
    $fnBlockList
  )
  foreach ($PosNum in (0..80)) {
    foreach ($BlockPos in (0..8)) {
      if ($PosNum -in $fnBlockList[$BlockPos]) {
        $BlockNum = $BlockPos
        Break
      } # if posnum
    }  # foreach blockpos
    $PosObjProp = [ordered]@{
      Position   = $PosNum
      Row        = ([math]::Truncate($PosNum/9))
      Col        = $PosNum % 9
      Block      = $BlockNum
      Value      = $fnRawBoard[$PosNum]
      AllPosInBlock = $fnBlockList[$BlockNum]
      PosInBlock = $fnBlockList[$BlockNum].indexOf($PosNum)
    } # HashTable posobjprops
    New-Object -TypeName psobject -Property $PosObjProp
  } # foreach posnum
} # fn Get-BoardObject

function Get-MissingObjects {
  Param (
    $fnBoardObj
  )
  $CompleteSet = @('1','2','3','4','5','6','7','8','9')
  foreach ($PosNum in (0..80)) {
    if ($fnBoardObj[$PosNum].Value -eq '-'){ 
      $Row = $fnBoardObj[$PosNum].Row
      $Col = $fnBoardObj[$PosNum].Col
      $Blk = $fnBoardObj[$PosNum].Block
      
      $RowNumbers = ($fnBoardObj | Where-Object {$_.Row -eq $Row} ).Value
      $ColNumbers = ($fnBoardObj | Where-Object {$_.Col -eq $Col} ).Value
      $BlkNumbers = ($fnBoardObj | Where-Object {$_.Block -eq $Blk}  ).Value   
      $AllNumbers = ($RowNumbers+$ColNumbers+$BlkNumbers) | 
                    Where-Object {$_ -match '\d'} | 
                    Select-Object -Unique |
                    Sort-Object
      $Missing    = $CompleteSet | Where-Object {$AllNumbers -notcontains $_}  
      $MissingObjProp = [ordered]@{
        Position     = $PosNum
        Row          = $Row
        Col          = $Col
        Block        = $Blk
        Values       = $AllNumbers
        Missing      = $Missing
        MissingCount = $Missing.Count
      } # hashtable missingobjprops
      New-Object -TypeName psobject -Property $MissingObjProp
    } # if pos -eq - (blank position)
  } # foreach posnum
} # fn getmissingobjects

function Show-Board {
  param (
    $fnBoardObj
  )
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

function Update-SingleMissing {
  Param (
    $fnBoardObj,
    $fnRawBoard,
    $MissingObj
  )
  $Singles = $MissingObj | Where-Object {$_.MissingCount -eq 1}
  foreach ($Single in $Singles) {
    if ($fnBoardObj[$Single.position].Value -eq '-') {$fnRawBoard[$Single.position] = $Single.Missing}
  }
  return $fnRawBoard
} # Updatesinglemissing

function Update-BlockRevSingle {
  Param (
    $fnBoardObj,
    $fnMissingObj,
    $fnRawBoard,
    $fnBlockList
  )
  foreach ($Block in (0..8)) {
    $AllMissingInBlock  = $fnMissingObj | Where-Object {$_.Block -eq $Block}
    $MissingInBlock = $AllMissingInBlock.Missing
    $GroupMissing = $MissingInBlock | Group-Object
    $Singles = $GroupMissing | Where-Object {$_.count -eq 1}
    foreach ($Single in $Singles) {
      foreach ($MissingInPos in $AllMissingInBlock) {
        if ($MissingInPos.Missing -contains $Single.Name) {
          $fnRawBoard[$MissingInPos.Position] = ($Single.Name) -as [char]
        }
      }
    }
  }
  return $fnRawBoard
}

function Test-GuessedValue {
  Param (
    $fnBoardObj,
    $fnMissingObj,
    $fnRawBoard,
    [int]$NumberOfGuess
  )
  $WhichOfFour = $NumberOfGuess % 4 
  $FirstMissObjIndex = ([math]::Truncate($NumberOfGuess / 4 )) * 2
  $SecondMissObjIndex = $FirstMissObjIndex + 1
  $FirstMissValueIndex = if ($WhichOfFour -lt 2) {0 -as [int]} else {1 -as [int]}
  $SecondMissValueIndex = $NumberOfGuess % 2
  $MissingPairs = $fnMissingObj | Where-Object {$_.MissingCount -eq 2}
  $FirstGuessObj = $MissingPairs[$FirstMissObjIndex]
  $SecondGuessObj = $MissingPairs[$SecondMissObjIndex]
  $FirstGuessValue = $MissingPairs[$FirstMissObjIndex].Missing[$FirstMissValueIndex]
  $SecondGuessValue = $MissingPairs[$SecondMissObjIndex].Missing[$SecondMissValueIndex]
  $fnRawBoard[$FirstGuessObj.Position] = $FirstGuessValue -as [char]
  $fnRawBoard[$SecondGuessObj.Position] = $SecondGuessValue -as [char]
  return $fnRawBoard
}



#######     MAIN CODE     ####### 
Clear-Host
$FirstTime = $true
$RawBoard = New-RawBoard -Board $SudokuBoard
$Guessing = $false
$Attempt = 0
$GuessNumber = 0
do {
  $Attempt++
  $BeginNumBlank = ($RawBoard -match '-').count
  $BoardObj = Get-BoardObject -fnRawBoard $RawBoard -fnBlockList $BlockList
  $MissingObj = Get-MissingObjects -fnBoardObj $BoardObj.psobject.Copy()
  #$NakedSet = Get-NakedPair -fnMissingObj $MissingObj 
  if ($FirstTime) {Show-Board -fnBoardObj $BoardObj;$FirstTime=$false}
  if ($MissingObj.MissingCount -contains 1) {
    $RawBoard = Update-SingleMissing -fnBoard $BoardObj.psobject.Copy() -fnRawBoard $RawBoard -Missing $MissingObj
    $BoardObj = Get-BoardObject -fnRawBoard $RawBoard -fnBlockList $BlockList
    $MissingObj = Get-MissingObjects -fnBoardObj $BoardObj.psobject.Copy()
  }
  else {
    $RawBoard = Update-BlockRevSingle -fnBoardObj $BoardObj.psobject.Copy() -fnRawBoard $RawBoard -fnMissingObj $MissingObj -fnBlockList $BlockList
    $BoardObj = Get-BoardObject -fnRawBoard $RawBoard -fnBlockList $BlockList
    $MissingObj = Get-MissingObjects -fnBoardObj $BoardObj.psobject.Copy()
  }
  $EndNumBlanks = ($RawBoard -match '-').count
  
  # Check to see if we need to start guessing
  if ($BeginNumBlank -eq $EndNumBlanks -and $Guessing -eq $false) {
    $BackupRaw = $RawBoard.psobject.Copy()
    $RawBoard = Test-GuessedValue -fnBoardObj $BoardObj.psobject.Copy() -fnMissingObj $MissingObj -fnRawBoard $RawBoard.psobject.Copy() -NumberOfGuess $GuessNumber
    $Guessing = $true 
    $GuessOnAttempt = $Attempt
    $GuessNumber++ 
  }
  if ($Guessing -eq $true -and $BeginNumBlank -eq $EndNumBlanks -and $GuessOnAttempt -lt $Attempt ) {
    $RawBoard = $BackupRaw.psobject.Copy()
    $Guessing = $false  
  }
  if ($FirstTime -eq $false) {Show-Board -fnBoardObj $BoardObj}  
  start-sleep -Milliseconds 100
} while ($BoardObj.Value -contains '-')
