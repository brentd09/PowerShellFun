# Define an empty Sudoku board
$board = @(
  @(0, 8, 3, 5, 9, 0, 7, 0, 0),
  @(0, 0, 0, 7, 0, 0, 0, 0, 2),
  @(0, 0, 1, 0, 0, 0, 0, 0, 0),
  @(0, 5, 8, 0, 0, 3, 0, 0, 6),
  @(1, 0, 0, 0, 0, 0, 8, 0, 0),
  @(2, 0, 0, 0, 5, 0, 0, 0, 0),
  @(0, 9, 7, 0, 3, 0, 2, 0, 0),
  @(5, 0, 0, 0, 0, 0, 0, 0, 0),
  @(0, 0, 0, 0, 0, 6, 0, 4, 0)
)

# Function to check if a number is valid in a given cell
function IsValid($board, $row, $col, $num) {
  # Check if the number exists in the same row or column
  for ($i = 0; $i -lt 9; $i++) {
    if ($board[$row][$i] -eq $num -or $board[$i][$col] -eq $num) {
      return $false
    }
  }

  # Determine the start indices of the 3x3 grid
  $gridRow = 3 * [math]::Floor($row / 3)
  $gridCol = 3 * [math]::Floor($col / 3)

  # Check if the number exists in the same 3x3 grid
  for ($i = 0; $i -lt 3; $i++) {
    for ($j = 0; $j -lt 3; $j++) {
      if ($board[$gridRow + $i][$gridCol + $j] -eq $num) {
        return $false
      }
    }
  }

  return $true
}

# Function to solve the Sudoku puzzle using backtracking
function SolveSudoku {
  param (
    [ref]$board
  )

  for ($row = 0; $row -lt 9; $row++) {
    for ($col = 0; $col -lt 9; $col++) {
      if ($board.Value[$row][$col] -eq 0) {
        for ($num = 1; $num -le 9; $num++) {
          if (IsValid $board.Value $row $col $num) {
            $board.Value[$row][$col] = $num

            if (SolveSudoku -board ([ref]$board.Value)) {
              return $true
            }

            $board.Value[$row][$col] = 0
          }
        }
        return $false
      }
    }
  }

  return $true
}

# Solve the Sudoku puzzle
if (SolveSudoku -board ([ref]$board)) {
  # Print the solved puzzle
  for ($row = 0; $row -lt 9; $row++) {
    for ($col = 0; $col -lt 9; $col++) {
      Write-Host -NoNewline "$($board[$row][$col]) "
    }
    Write-Host
  }
}
else {
  Write-Host "No solution found."
}
