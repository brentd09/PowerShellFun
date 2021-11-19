<#
.SYNOPSIS
  Short description
.DESCRIPTION
  Long description
.EXAMPLE
  PS C:\> <example usage>
  Explanation of what the example does
.INPUTS
  Inputs (if any)
.OUTPUTS
  Output (if any)
.NOTES
  General notes
#>
[CmdletBinding()]
Param()

## Classes
class PegBoardPosition {
  [int]$Pos
  [int]$Row
  [int]$Col
  [int]$State # State: -1 = out-of-bounds, 0 = empty board position, 1 = Peg in board position
}

## Functions


## Main