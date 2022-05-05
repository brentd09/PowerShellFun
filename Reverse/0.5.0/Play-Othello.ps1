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
  [int]$Row
  [int]$Col
  [String]$Color 
  [bool]$Occupied


  Square ([int]$Row,[int]$Col,[bool]$Occupied,[string]$Color) {
    if ($Occupied -eq $true) {
      $this.Row = $Row
      $this.Col = $Col
      $this.Occupied = $true
      $this.Color = $Color
    }
    else {
      $this.Row = $Row
      $this.Col = $Col
      $this.Occupied = $false
      $this.Color = 'None'
    }
  }

  Square ([int]$Row,[int]$Col) {
    $this.Row = $Row
    $this.Col = $Col
    $this.Occupied = $false
    $this.Color = 'None'
  }

  [void]Place ([string]$Color) {
    $this.Occupied = $true
    $this.Color = $Color
  }

  [void]Flip () {
    if ($this.Occupied -eq $true) {
      if ($this.Color -eq 'Black') {$this.Color = 'White'}
      elseif ($this.Color -eq 'White') {$this.Color = 'Black'}
    }
  }
} # END Class Square

Class Board {
  [Square[]]$Squares
}

$Sqr = [Square]::New(0,0)
$sqr.Place('black')
$Sqr.Flip()

$Sqr