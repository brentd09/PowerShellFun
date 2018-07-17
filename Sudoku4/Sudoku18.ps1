#Create board class
Class SudokuBoardPos {
  [int]$BoardPosition
  [String]$SudokuNumber
  [int]$BoardRow
  [int]$BoardCol
  [int]$BoardSquare

  SudokuBoardPos ([String]$SudokuNumber,[int]$BoardPosition) {
    $this.SudokuNumber = $SudokuNumber
    $this.BoardPosition = $BoardPosition
    $this.BoardRow = [math]::Truncate($BoardPosition / 9)
    $this.BoardCol = $BoardPosition % 9
    if ($BoardPosition -in @(0,1,2,9,10,11,18,19,20)) {$this.BoardSquare = 0}
    elseif ($BoardPosition -in @(3,4,5,12,13,14,21,22,23)) {$this.BoardSquare = 1}
    elseif ($BoardPosition -in @(6,7,8,15,16,17,24,25,26)) {$this.BoardSquare = 2}
    elseif ($BoardPosition -in @(27,28,29,36,37,38,45,46,47)) {$this.BoardSquare = 3}
    elseif ($BoardPosition -in @(30,31,32,39,40,41,48,49,50)) {$this.BoardSquare = 4}
    elseif ($BoardPosition -in @(33,34,35,42,43,44,51,52,53)) {$this.BoardSquare = 5}
    elseif ($BoardPosition -in @(54,55,56,63,64,65,72,73,74)) {$this.BoardSquare = 6}
    elseif ($BoardPosition -in @(57,58,59,66,67,68,75,76,77)) {$this.BoardSquare = 7}
    elseif ($BoardPosition -in @(60,61,62,69,70,71,78,79,80)) {$this.BoardSquare = 8}
  }
}

# Using the https://www.sudoku-solutions.com/ website you can try solving these to help with the 
# coding functions.
# Easy       '-6-3--8-4537-9-----4---63-7-9--51238---------71362--4-3-64---1-----6-5231-2--9-8-'
# Medium     '-1--584-9--------1953---2--2---1--8-6--425--3-3--7---4--5---3973--------1-463--5-'
# Difficult  '-2-------17---9--4---1367--431---2------8------8---163--3624---2--8---49-------3-'
# Extreme    '89-2-3-------------3658---41-8-3--6-----------2--7-3-57---9412-------------8-2-59'
# Extreme    '--9748---7---------2-1-9-----7---24--64-1-59--98---3-----8-3-2---------6---2759--'
# Extreme    '--5--7--4-6--5--9-4--9--2--2--5--1---7--2--4---8--3--2--7--1--3-5--6--1-6--8--4--'

$RawBoard = '-1--584-9--------1953---2--2---1--8-6--425--3-3--7---4--5---3973--------1-463--5-'

function Create-BoardObj {
  Param(
    [string]$RawBrd
  )
  [string[]]$SplitBoard = $RawBrd.ToCharArray()
  $count = 0
  foreach ($element in $SplitBoard) {
    [SudokuBoardPos]::New($element,$count)
    $count++
  }
}


$BoardObj = Create-BoardObj -RawBrd $RawBoard