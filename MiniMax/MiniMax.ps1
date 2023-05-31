# Define the Tic-Tac-Toe board
$board = @(
    @("-", "-", "-"),
    @("-", "-", "-"),
    @("-", "-", "-")
)

# Constants for players
$player = "X"
$computer = "O"

# Function to check if the game is over
function IsGameOver($board) {
    # Check rows
    for ($row = 0; $row -lt 3; $row++) {
        if ($board[$row][0] -ne "-" -and $board[$row][0] -eq $board[$row][1] -and $board[$row][0] -eq $board[$row][2]) {
            return $true
        }
    }

    # Check columns
    for ($col = 0; $col -lt 3; $col++) {
        if ($board[0][$col] -ne "-" -and $board[0][$col] -eq $board[1][$col] -and $board[0][$col] -eq $board[2][$col]) {
            return $true
        }
    }

    # Check diagonals
    if ($board[0][0] -ne "-" -and $board[0][0] -eq $board[1][1] -and $board[0][0] -eq $board[2][2]) {
        return $true
    }

    if ($board[2][0] -ne "-" -and $board[2][0] -eq $board[1][1] -and $board[2][0] -eq $board[0][2]) {
        return $true
    }

    # Check if the board is full
    for ($row = 0; $row -lt 3; $row++) {
        for ($col = 0; $col -lt 3; $col++) {
            if ($board[$row][$col] -eq "-") {
                return $false
            }
        }
    }

    # Game is a draw
    return $true
}

# Function to calculate the score for the current board state
function GetScore($board) {
    if (IsGameOver $board) {
        if (CheckWinner $board $computer) {
            return 1
        }
        elseif (CheckWinner $board $player) {
            return -1
        }
        else {
            return 0
        }
    }
    return 0
}

# Function to check if a player has won
function CheckWinner($board, $player) {
    # Check rows
    for ($row = 0; $row -lt 3; $row++) {
        if ($board[$row][0] -eq $player -and $board[$row][1] -eq $player -and $board[$row][2] -eq $player) {
            return $true
        }
    }

    # Check columns
    for ($col = 0; $col -lt 3; $col++) {
        if ($board[0][$col] -eq $player -and $board[1][$col] -eq $player -and $board[2][$col] -eq $player) {
            return $true
        }
    }

    # Check diagonals
    if ($board[0][0] -eq $player -and $board[1][1] -eq $player -and $board[2][2] -eq $player) {
        return $true
    }

    if ($board[2][0] -eq $player -and $board[1][1] -eq $player -and $board[0][2] -eq $player) {
        return $true
    }

    return $false
}

# Function to make a player's move
function MakeMove($board, $player, $row, $col) {
    if ($board[$row][$col] -eq "-") {
        $board[$row][$col] = $player
        return $true
    }
    return $false
}

# Function to undo a move
function UndoMove($board, $row, $col) {
    $board[$row][$col] = "-"
}

# Minimax algorithm
function Minimax($board, $depth, $maximizingPlayer) {
    if (IsGameOver $board) {
        return GetScore $board
    }

    if ($maximizingPlayer) {
        $bestScore = -999
        for ($row = 0; $row -lt 3; $row++) {
            for ($col = 0; $col -lt 3; $col++) {
                if ($board[$row][$col] -eq "-") {
                    MakeMove $board $computer $row $col
                    $score = Minimax $board ($depth + 1) $false
                    UndoMove $board $row $col
                    $bestScore = [Math]::Max($bestScore, $score)
                }
            }
        }
        return $bestScore
    }
    else {
        $bestScore = 999
        for ($row = 0; $row -lt 3; $row++) {
            for ($col = 0; $col -lt 3; $col++) {
                if ($board[$row][$col] -eq "-") {
                    MakeMove $board $player $row $col
                    $score = Minimax $board ($depth + 1) $true
                    UndoMove $board $row $col
                    $bestScore = [Math]::Min($bestScore, $score)
                }
            }
        }
        return $bestScore
    }
}

# Function to find the best move using Minimax
function FindBestMove($board) {
    $bestScore = -999
    $bestMove = $null

    for ($row = 0; $row -lt 3; $row++) {
        for ($col = 0; $col -lt 3; $col++) {
            if ($board[$row][$col] -eq "-") {
                MakeMove $board $computer $row $col
                $score = Minimax $board 0 $false
                UndoMove $board $row $col

                if ($score -gt $bestScore) {
                    $bestScore = $score
                    $bestMove = $row, $col
                }
            }
        }
    }

    return $bestMove
}

# Main game loop
while (-not (IsGameOver $board)) {
    # Player's move
    $validMove = $false
    while (-not $validMove) {
        $playerRow = Read-Host "Enter row (0-2):"
        $playerCol = Read-Host "Enter column (0-2):"

        if ([int]$playerRow -ge 0 -and [int]$playerRow -lt 3 -and [int]$playerCol -ge 0 -and [int]$playerCol -lt 3) {
            if (MakeMove $board $player [int]$playerRow [int]$playerCol) {
                $validMove = $true
            }
            else {
                Write-Host "Invalid move! Try again."
            }
        }
        else {
            Write-Host "Invalid input! Try again."
        }
    }

    # Check if the player has won
    if (CheckWinner $board $player) {
        Write-Host "Player wins!"
        break
    }

    # Computer's move
    $computerMove = FindBestMove $board
    MakeMove $board $computer $computerMove[0] $computerMove[1]
    Write-Host "Computer moves to row $($computerMove[0]), column $($computerMove[1])"

    # Check if the computer has won
    if (CheckWinner $board $computer) {
        Write-Host "Computer wins!"
        break
    }

    # Print the current board
    Write-Host "Current Board:"
    for ($row = 0; $row -lt 3; $row++) {
        Write-Host ($board[$row] -join " ")
    }
}

# If there is no winner, it's a draw
if (IsGameOver $board) {
    Write-Host "It's a draw!"
}
