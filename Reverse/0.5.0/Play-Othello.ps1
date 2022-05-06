<#
.SYNOPSIS
  A short one-line action-based description, e.g. 'Tests if a function is valid'
.DESCRIPTION
  A longer description of the function, its purpose, common use cases, etc.
.NOTES
  Information or caveats about the function e.g. 'This function is not supported in Linux'
.LINK
  Specify a URI to a help page, this will show when Get-Help -Online is used.
.EXAMPLE
  Test-MyTestFunction -Verbose
  Explanation of the function or its result. You can include multiple examples with additional .EXAMPLE lines
#>

[cmdletbinding()]
Param ()

Class Square {
  [int]$Pos
  [int]$Row
  [int]$Col
  [String]$Color 
  [bool]$Occupied

  Square ([int]$Pos) {
    $this.Pos = $Pos
    $this.Row = [math]::Truncate($Pos/8)
    $this.Col = $Pos % 8
    if ($Pos -in @(27,36)) {
      $this.Occupied = $true  
      $this.Color = 'White'
    }
    elseif ($Pos -in @(28,35)) {
      $this.Occupied = $True
      $this.Color = 'Black'
    }
    else {
      $this.Occupied = $false
      $this.Color = 'None'
    }
  }

  [bool]Place ([string]$Color) {
    if ($this.Occupied -eq $false) {
      $this.Occupied = $true
      $this.Color = $Color
      return $true
    }
    else {return $false}
  }

  [bool]Flip () {
    if ($this.Occupied -eq $true) {
      if ($this.Color -eq 'Black') {$this.Color = 'White'}
      elseif ($this.Color -eq 'White') {$this.Color = 'Black'}
      return $true
    }
    else {return $false}
  }
} # END Class Square

Class Board {
  [Square[]]$Squares
}

$Sqr = [Square]::New(0,0)
$sqr.Place('black')
$Sqr.Flip()

$Sqr