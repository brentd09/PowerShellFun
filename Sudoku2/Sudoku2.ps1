[Cmdletbinding()]
Param (
  [ValidateLength(81,81)]
  [string]$SudokuBoard = '-6-3--8-4537-9-----4---63-7-9--51238---------71362--4-3-64---1-----6-5231-2--9-8-'
)
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
    return $Board
  } # if board.length
} # fn new-rawboard

function Get-BoardObjects {
  Param (
    [string]$fnRawBoard,
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
      Position = $PosNum
      Row      = ([math]::Truncate($PosNum/9))
      Col      = $PosNum % 9
      Block    = $BlockNum
      Value    = $fnRawBoard[$PosNum]
    } # HashTable posobjprops
    New-Object -TypeName psobject -Property $PosObjProp
  } # foreach posnum
} # fn get-boardobjects

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
  foreach ($ShowRow in (0..8)) {
    foreach ($ShowCol in (0..8)) {
      
    } # foreach showcol
  } #foreach showrow
}
#MAIN CODE

$RawBoard = New-RawBoard -Board $SudokuBoard
$BoardObj = Get-BoardObjects -fnRawBoard $RawBoard -fnBlockList $BlockList
$BoardObj
$MissingObj = Get-MissingObjects -fnBoardObj $BoardObj
$MissingObj