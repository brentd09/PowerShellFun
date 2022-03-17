[CmdletBinding()]
Param (
  [ValidateLength(81,81)]
  [string]$FlatPuzzle = '2-------4--641------5-2-83--------9--12-3-56--8--------63-5-1------873--8-------2'
)

Class BoardElement {
  [string]$Value 
  [int]$Pos
  [int]$Row 
  [int]$Col 
  [int]$Box 
  [string[]]$PossibleValues
  [bool]$Solved

  BoardElement ([int]$Position,[string]$Value) {
    $this.Row = [math]::Truncate($Position/9)
    $this.Col = $Position%9
    $this.Box = ([math]::Truncate([math]::Truncate($Position/9)/3) * 3) + [math]::Truncate(($Position%9)/3)
    $this.Value = $Value
    $this.Pos = $Position
    if ($Value -notmatch '\d') {
      $this.PossibleValues = '1','2','3','4','5','6','7','8','9'
      $this.Solved = $false
    }
    else {
      $this.PossibleValues = @($Value)
      $this.Solved = $true
    }  
  }

  [void]SetElementValue ($Value) {
    $this.Value = $Value
    $this.PossibleValues = @($Value)
    $this.Solved = $true
  }

  [void]RemoveFromPossible ($Value) {
    $this.PossibleValues = $this.PossibleValues | Where-Object {$_ -ne $Value}
  }
}

class Board {
  [BoardElement[]]$Element

  Board ($Elements) {
    $this.Element = $Elements
  }

  [void]ResolveCandidates () {
    $UnsolvedElements = $this.Element | Where-Object {$_.Solved -eq $false}
    foreach ($UnsolvedElement in $UnsolvedElements) {
      $Row = $UnsolvedElement.Row
      $Col = $UnsolvedElement.Col
      $Box = $UnsolvedElement.Box
      $RelatedSolvedValues = $this.Element | Where-Object {($_.Col -eq $Col -or $_.Row -eq $Row -or $_.Box -eq $Box) -and $_.Solved -eq $true}
      foreach ($RelatedSolvedValue in $RelatedSolvedValues) {
        $UnsolvedElement.RemoveFromPossible($RelatedSolvedValue.Value)
        if ($UnsolvedElement.PossibleValues.Count -eq 1) {
          $UnsolvedElement.Value = $UnsolvedElement.PossibleValues[0]
          $UnsolvedElement.Solved = $true
        }
      }
    }
  }


  [void] ResolveHiddenSingleCandidateRow () {
    $Rows = 0..8 
    foreach ($Row in $Rows) {
      $RowElements = $this.Element | Where-Object {$_.Row -eq $Row}
      $GroupRowValues = $RowElements.PossibleValues | Group-Object
      $SingleValues = ($GroupRowValues | Where-Object {$_.Count -eq 1}).Name
      if ($SingleValues.count -gt 0) {
        foreach ($SingleValue in $SingleValues) {
          $ElementToSet = $RowElements | Where-Object {$_.PossibleValues -contains $SingleValue}
          $ElementToSet.SetElementValue($SingleValue)
        }
      }
    }
  }

  [void] ResolveHiddenSingleCandidateCol () {
    $Cols = 0..8 
    foreach ($Col in $Cols) {
      $ColElements = $this.Element | Where-Object {$_.Col -eq $Col}
      $GroupColValues = $ColElements.PossibleValues | Group-Object
      $SingleValues = ($GroupColValues | Where-Object {$_.Count -eq 1}).Name
      if ($SingleValues.count -gt 0) {
        foreach ($SingleValue in $SingleValues) {
          $ElementToSet = $ColElements | Where-Object {$_.PossibleValues -contains $SingleValue}
          $ElementToSet.SetElementValue($SingleValue)
        }
      }
    }
  }

  [void] ResolveHiddenSingleCandidateBox () {
    $Boxs = 0..8 
    foreach ($Box in $Boxs) {
      $BoxElements = $this.Element | Where-Object {$_.Box -eq $Box}
      $GroupBoxValues = $BoxElements.PossibleValues | Group-Object
      $SingleValues = ($GroupBoxValues | Where-Object {$_.Count -eq 1}).Name
      if ($SingleValues.count -gt 0) {
        foreach ($SingleValue in $SingleValues) {
          $ElementToSet = $BoxElements | Where-Object {$_.PossibleValues -contains $SingleValue}
          $ElementToSet.SetElementValue($SingleValue)
        }
      }
    }
  }

  [void]ResolvePointingPair () {
    $Rows = 0..8
    foreach ($Row in $Rows) {
      $UnsolvedElements = $this.Element | Where-Object {$_.Row -eq $Row -and $_.Solved -eq $false}
      if ($UnsolvedElements.Count -gt 0) {
        
      }
    }
  }
}

### Functions

function Compare-Array {
  Param ([string[]]$StrArray) 
  foreach ($Str in $StrArray) {
    $GroupObj = $StrArray | Group-Object
    $NumOfGrps = $GroupObj.Name.Count
    if ($NumOfGrps -eq 1 -and $GroupObj.Count -eq $StrArray.Count -and $StrArray[0] -eq $GroupObj.Name) {return $true }
    else {return $false}
  }
}
function Show-Board {
  Param ([Board]$BoardObj)
  Clear-Host 
  $MainColor = 'Green'
  $InnerColor = 'DarkGray'
  $SolvedColor = 'Gray'
  $UnsolvedColor = 'Brown'
  $DL = [Char]449
  Write-Host "+===+===+===+===+===+===+===+===+===+" -ForeGroundColor $MainColor
  Write-Host "$DL " -NoNewline -ForeGroundColor $MainColor
  Write-Host $BoardObj.Element.Value[0]  -NoNewline -ForeGroundColor $SolvedColor
  Write-Host " | "  -NoNewline -ForeGroundColor $InnerColor
  Write-Host $BoardObj.Element.Value[1] -NoNewline -ForeGroundColor $SolvedColor
  Write-Host " | "  -NoNewline -ForeGroundColor $InnerColor
  Write-Host $BoardObj.Element.Value[2] -NoNewline -ForeGroundColor $SolvedColor
  Write-Host " $DL "  -NoNewline -ForeGroundColor $Maincolor
  Write-Host $BoardObj.Element.Value[3] -NoNewline -ForeGroundColor $SolvedColor
  Write-Host " | "  -NoNewline -ForeGroundColor $InnerColor
  Write-Host $BoardObj.Element.Value[4] -NoNewline -ForeGroundColor $SolvedColor
  Write-Host " | "  -NoNewline -ForeGroundColor $InnerColor
  Write-Host $BoardObj.Element.Value[5] -NoNewline -ForeGroundColor $SolvedColor
  Write-Host " $DL "  -NoNewline -ForeGroundColor $MainColor
  Write-Host $BoardObj.Element.Value[6] -NoNewline -ForeGroundColor $SolvedColor
  Write-Host " | "  -NoNewline -ForeGroundColor $InnerColor
  Write-Host $BoardObj.Element.Value[7] -NoNewline -ForeGroundColor $SolvedColor
  Write-Host " | "  -NoNewline -ForeGroundColor $InnerColor
  Write-Host $BoardObj.Element.Value[8] -NoNewline -ForeGroundColor $SolvedColor
  Write-Host " $DL "   -ForeGroundColor $MainColor
  Write-Host "+" -NoNewline -ForeGroundColor $MainColor
  Write-Host "---+---+---" -ForeGroundColor $InnerColor -NoNewline
  Write-Host "+" -ForeGroundColor $MainColor -NoNewline
  Write-Host "---+---+---" -ForeGroundColor $InnerColor -NoNewline
  Write-Host "+" -ForeGroundColor $MainColor -NoNewline
  Write-Host "---+---+---"  -ForeGroundColor $InnerColor -NoNewline
  Write-Host "+"  -ForeGroundColor $MainColor
  Write-Host "$DL " -NoNewline -ForeGroundColor $MainColor
  Write-Host $BoardObj.Element.Value[9] -NoNewline -ForeGroundColor $SolvedColor
  Write-Host " | "   -NoNewline -ForeGroundColor $InnerColor
  Write-Host $BoardObj.Element.Value[10] -NoNewline -ForeGroundColor $SolvedColor
  Write-Host " | "   -NoNewline -ForeGroundColor $InnerColor
  Write-Host $BoardObj.Element.Value[11] -NoNewline -ForeGroundColor $SolvedColor
  Write-Host " $DL "   -NoNewline -ForeGroundColor $MainColor
  Write-Host $BoardObj.Element.Value[12] -NoNewline -ForeGroundColor $SolvedColor
  Write-Host " | "   -NoNewline -ForeGroundColor $InnerColor
  Write-Host $BoardObj.Element.Value[13] -NoNewline -ForeGroundColor $SolvedColor
  Write-Host " | "   -NoNewline -ForeGroundColor $InnerColor
  Write-Host $BoardObj.Element.Value[14] -NoNewline -ForeGroundColor $SolvedColor
  Write-Host " $DL "   -NoNewline -ForeGroundColor $MainColor
  Write-Host $BoardObj.Element.Value[15] -NoNewline -ForeGroundColor $SolvedColor
  Write-Host " | "   -NoNewline -ForeGroundColor $InnerColor
  Write-Host $BoardObj.Element.Value[16] -NoNewline -ForeGroundColor $SolvedColor
  Write-Host " | "   -NoNewline -ForeGroundColor $InnerColor
  Write-Host $BoardObj.Element.Value[17] -NoNewline  -ForeGroundColor $SolvedColor
  Write-Host " $DL "    -ForeGroundColor $MainColor
  Write-Host "+" -NoNewline -ForeGroundColor $MainColor
  Write-Host "---+---+---" -ForeGroundColor $InnerColor -NoNewline
  Write-Host "+" -ForeGroundColor $MainColor -NoNewline
  Write-Host "---+---+---" -ForeGroundColor $InnerColor -NoNewline
  Write-Host "+" -ForeGroundColor $MainColor -NoNewline
  Write-Host "---+---+---"  -ForeGroundColor $InnerColor -NoNewline
  Write-Host "+"  -ForeGroundColor $MainColor
  Write-Host "$DL " -NoNewline -ForeGroundColor $MainColor
  Write-Host $BoardObj.Element.Value[18] -NoNewline -ForeGroundColor $SolvedColor
  Write-Host " | "  -NoNewline -ForeGroundColor $InnerColor
  Write-Host $BoardObj.Element.Value[19] -NoNewline -ForeGroundColor $SolvedColor
  Write-Host " | "   -NoNewline -ForeGroundColor $InnerColor
  Write-Host $BoardObj.Element.Value[20] -NoNewline -ForeGroundColor $SolvedColor
  Write-Host " $DL "   -NoNewline -ForeGroundColor $MainColor
  Write-Host $BoardObj.Element.Value[21] -NoNewline -ForeGroundColor $SolvedColor
  Write-Host " | "   -NoNewline -ForeGroundColor $InnerColor
  Write-Host $BoardObj.Element.Value[22] -NoNewline -ForeGroundColor $SolvedColor
  Write-Host " | "   -NoNewline -ForeGroundColor $InnerColor
  Write-Host $BoardObj.Element.Value[23] -NoNewline -ForeGroundColor $SolvedColor
  Write-Host " $DL "   -NoNewline -ForeGroundColor $MainColor
  Write-Host $BoardObj.Element.Value[24] -NoNewline -ForeGroundColor $SolvedColor
  Write-Host " | "   -NoNewline -ForeGroundColor $InnerColor
  Write-Host $BoardObj.Element.Value[25] -NoNewline -ForeGroundColor $SolvedColor
  Write-Host " | "   -NoNewline -ForeGroundColor $InnerColor
  Write-Host $BoardObj.Element.Value[26] -NoNewline -ForeGroundColor $SolvedColor
  Write-Host " $DL"    -ForeGroundColor $MainColor
  Write-Host "+===+===+===+===+===+===+===+===+===+" -ForeGroundColor $MainColor
  Write-Host "$DL " -NoNewline -ForeGroundColor $MainColor
  Write-Host $BoardObj.Element.Value[27] -NoNewline -ForeGroundColor $SolvedColor
  Write-Host " | "   -NoNewline -ForeGroundColor $InnerColor
  Write-Host $BoardObj.Element.Value[28] -NoNewline -ForeGroundColor $SolvedColor
  Write-Host " | "   -NoNewline -ForeGroundColor $InnerColor
  Write-Host $BoardObj.Element.Value[29] -NoNewline -ForeGroundColor $SolvedColor
  Write-Host " $DL "   -NoNewline -ForeGroundColor $MainColor
  Write-Host $BoardObj.Element.Value[30] -NoNewline -ForeGroundColor $SolvedColor
  Write-Host " | "   -NoNewline -ForeGroundColor $InnerColor
  Write-Host $BoardObj.Element.Value[31] -NoNewline -ForeGroundColor $SolvedColor
  Write-Host " | "   -NoNewline -ForeGroundColor $InnerColor
  Write-Host $BoardObj.Element.Value[32] -NoNewline -ForeGroundColor $SolvedColor
  Write-Host " $DL "   -NoNewline -ForeGroundColor $MainColor
  Write-Host $BoardObj.Element.Value[33] -NoNewline -ForeGroundColor $SolvedColor
  Write-Host " | "   -NoNewline -ForeGroundColor $InnerColor
  Write-Host $BoardObj.Element.Value[34] -NoNewline -ForeGroundColor $SolvedColor
  Write-Host " | "   -NoNewline -ForeGroundColor $InnerColor
  Write-Host $BoardObj.Element.Value[35] -NoNewline -ForeGroundColor $SolvedColor
  Write-Host " $DL"    -ForeGroundColor $MainColor
  Write-Host "+" -NoNewline -ForeGroundColor $MainColor
  Write-Host "---+---+---" -ForeGroundColor $InnerColor -NoNewline
  Write-Host "+" -ForeGroundColor $MainColor -NoNewline
  Write-Host "---+---+---" -ForeGroundColor $InnerColor -NoNewline
  Write-Host "+" -ForeGroundColor $MainColor -NoNewline
  Write-Host "---+---+---"  -ForeGroundColor $InnerColor -NoNewline
  Write-Host "+"  -ForeGroundColor $MainColor
  Write-Host "$DL " -NoNewline -ForeGroundColor $MainColor
  Write-Host $BoardObj.Element.Value[36] -NoNewline -ForeGroundColor $SolvedColor
  Write-Host " | "  -NoNewline -ForeGroundColor $InnerColor
  Write-Host $BoardObj.Element.Value[37] -NoNewline -ForeGroundColor $SolvedColor
  Write-Host " | "  -NoNewline -ForeGroundColor $InnerColor
  Write-Host $BoardObj.Element.Value[38] -NoNewline -ForeGroundColor $SolvedColor
  Write-Host " $DL "  -NoNewline -ForeGroundColor $MainColor
  Write-Host $BoardObj.Element.Value[39] -NoNewline -ForeGroundColor $SolvedColor
  Write-Host " | "  -NoNewline -ForeGroundColor $InnerColor
  Write-Host $BoardObj.Element.Value[40] -NoNewline -ForeGroundColor $SolvedColor
  Write-Host " | "  -NoNewline -ForeGroundColor $InnerColor
  Write-Host $BoardObj.Element.Value[41] -NoNewline -ForeGroundColor $SolvedColor
  Write-Host " $DL "  -NoNewline -ForeGroundColor $MainColor
  Write-Host $BoardObj.Element.Value[42] -NoNewline -ForeGroundColor $SolvedColor
  Write-Host " | "  -NoNewline -ForeGroundColor $InnerColor
  Write-Host $BoardObj.Element.Value[43] -NoNewline -ForeGroundColor $SolvedColor
  Write-Host " | "  -NoNewline -ForeGroundColor $InnerColor
  Write-Host $BoardObj.Element.Value[44] -NoNewline -ForeGroundColor $SolvedColor
  Write-Host " $DL"  -ForeGroundColor $MainColor
  Write-Host "+" -NoNewline -ForeGroundColor $MainColor
  Write-Host "---+---+---" -ForeGroundColor $InnerColor -NoNewline
  Write-Host "+" -ForeGroundColor $MainColor -NoNewline
  Write-Host "---+---+---" -ForeGroundColor $InnerColor -NoNewline
  Write-Host "+" -ForeGroundColor $MainColor -NoNewline
  Write-Host "---+---+---"  -ForeGroundColor $InnerColor -NoNewline
  Write-Host "+"  -ForeGroundColor $MainColor
  Write-Host "$DL " -NoNewline -ForeGroundColor $MainColor
  Write-Host $BoardObj.Element.Value[45] -NoNewline -ForeGroundColor $SolvedColor
  Write-Host " | "  -NoNewline -ForeGroundColor $InnerColor
  Write-Host $BoardObj.Element.Value[46] -NoNewline -ForeGroundColor $SolvedColor
  Write-Host " | "  -NoNewline -ForeGroundColor $InnerColor
  Write-Host $BoardObj.Element.Value[47] -NoNewline -ForeGroundColor $SolvedColor
  Write-Host " $DL "  -NoNewline -ForeGroundColor $MainColor
  Write-Host $BoardObj.Element.Value[48] -NoNewline -ForeGroundColor $SolvedColor
  Write-Host " | "  -NoNewline -ForeGroundColor $InnerColor
  Write-Host $BoardObj.Element.Value[49] -NoNewline -ForeGroundColor $SolvedColor
  Write-Host " | "  -NoNewline -ForeGroundColor $InnerColor
  Write-Host $BoardObj.Element.Value[50] -NoNewline -ForeGroundColor $SolvedColor
  Write-Host " $DL "  -NoNewline -ForeGroundColor $MainColor
  Write-Host $BoardObj.Element.Value[51] -NoNewline -ForeGroundColor $SolvedColor
  Write-Host " | "  -NoNewline -ForeGroundColor $InnerColor
  Write-Host $BoardObj.Element.Value[52] -NoNewline -ForeGroundColor $SolvedColor
  Write-Host " | "  -NoNewline -ForeGroundColor $InnerColor
  Write-Host $BoardObj.Element.Value[53] -NoNewline -ForeGroundColor $SolvedColor
  Write-Host " $DL"   -ForeGroundColor $MainColor
  Write-Host "+===+===+===+===+===+===+===+===+===+" -ForeGroundColor $MainColor
  Write-Host "$DL " -NoNewline -ForeGroundColor $MainColor
  Write-Host $BoardObj.Element.Value[54] -NoNewline -ForeGroundColor $SolvedColor
  Write-Host " | "  -NoNewline -ForeGroundColor $InnerColor
  Write-Host $BoardObj.Element.Value[55] -NoNewline -ForeGroundColor $SolvedColor
  Write-Host " | "  -NoNewline -ForeGroundColor $InnerColor
  Write-Host $BoardObj.Element.Value[56] -NoNewline -ForeGroundColor $SolvedColor
  Write-Host " $DL "  -NoNewline -ForeGroundColor $MainColor
  Write-Host $BoardObj.Element.Value[57] -NoNewline -ForeGroundColor $SolvedColor
  Write-Host " | "  -NoNewline -ForeGroundColor $InnerColor
  Write-Host $BoardObj.Element.Value[58] -NoNewline -ForeGroundColor $SolvedColor
  Write-Host " | "  -NoNewline -ForeGroundColor $InnerColor
  Write-Host $BoardObj.Element.Value[59] -NoNewline -ForeGroundColor $SolvedColor
  Write-Host " | "  -NoNewline -ForeGroundColor $MainColor
  Write-Host $BoardObj.Element.Value[60] -NoNewline -ForeGroundColor $SolvedColor
  Write-Host " | "  -NoNewline -ForeGroundColor $InnerColor
  Write-Host $BoardObj.Element.Value[61] -NoNewline -ForeGroundColor $SolvedColor
  Write-Host " | "  -NoNewline -ForeGroundColor $InnerColor
  Write-Host $BoardObj.Element.Value[62] -NoNewline -ForeGroundColor $SolvedColor
  Write-Host " $DL"   -ForeGroundColor $MainColor
  Write-Host "+" -NoNewline -ForeGroundColor $MainColor
  Write-Host "---+---+---" -ForeGroundColor $InnerColor -NoNewline
  Write-Host "+" -ForeGroundColor $MainColor -NoNewline
  Write-Host "---+---+---" -ForeGroundColor $InnerColor -NoNewline
  Write-Host "+" -ForeGroundColor $MainColor -NoNewline
  Write-Host "---+---+---"  -ForeGroundColor $InnerColor -NoNewline
  Write-Host "+"  -ForeGroundColor $MainColor
  Write-Host "$DL " -NoNewline -ForeGroundColor $MainColor
  Write-Host $BoardObj.Element.Value[63] -NoNewline -ForeGroundColor $SolvedColor
  Write-Host " | "  -NoNewline -ForeGroundColor $InnerColor
  Write-Host $BoardObj.Element.Value[64] -NoNewline -ForeGroundColor $SolvedColor
  Write-Host " | "  -NoNewline -ForeGroundColor $InnerColor
  Write-Host $BoardObj.Element.Value[65] -NoNewline -ForeGroundColor $SolvedColor
  Write-Host " $DL "  -NoNewline -ForeGroundColor $MainColor
  Write-Host $BoardObj.Element.Value[66] -NoNewline -ForeGroundColor $SolvedColor
  Write-Host " | "  -NoNewline -ForeGroundColor $InnerColor
  Write-Host $BoardObj.Element.Value[67] -NoNewline -ForeGroundColor $SolvedColor
  Write-Host " | "  -NoNewline -ForeGroundColor $InnerColor
  Write-Host $BoardObj.Element.Value[68] -NoNewline -ForeGroundColor $SolvedColor
  Write-Host " $DL "  -NoNewline -ForeGroundColor $MainColor
  Write-Host $BoardObj.Element.Value[69] -NoNewline -ForeGroundColor $SolvedColor
  Write-Host " | "  -NoNewline -ForeGroundColor $InnerColor
  Write-Host $BoardObj.Element.Value[70] -NoNewline -ForeGroundColor $SolvedColor
  Write-Host " | "  -NoNewline -ForeGroundColor $InnerColor
  Write-Host $BoardObj.Element.Value[71] -NoNewline -ForeGroundColor $SolvedColor
  Write-Host " $DL"   -ForeGroundColor $MainColor
  Write-Host "+" -NoNewline -ForeGroundColor $MainColor
  Write-Host "---+---+---" -ForeGroundColor $InnerColor -NoNewline
  Write-Host "+" -ForeGroundColor $MainColor -NoNewline
  Write-Host "---+---+---" -ForeGroundColor $InnerColor -NoNewline
  Write-Host "+" -ForeGroundColor $MainColor -NoNewline
  Write-Host "---+---+---"  -ForeGroundColor $InnerColor -NoNewline
  Write-Host "+"  -ForeGroundColor $MainColor
  Write-Host "$DL " -NoNewline -ForeGroundColor $MainColor
  Write-Host $BoardObj.Element.Value[72] -NoNewline -ForeGroundColor $SolvedColor
  Write-Host " | "  -NoNewline -ForeGroundColor $InnerColor
  Write-Host $BoardObj.Element.Value[73] -NoNewline -ForeGroundColor $SolvedColor
  Write-Host " | "  -NoNewline -ForeGroundColor $InnerColor
  Write-Host $BoardObj.Element.Value[74] -NoNewline -ForeGroundColor $SolvedColor
  Write-Host " $DL "  -NoNewline -ForeGroundColor $MainColor
  Write-Host $BoardObj.Element.Value[75] -NoNewline -ForeGroundColor $SolvedColor
  Write-Host " | "  -NoNewline -ForeGroundColor $InnerColor
  Write-Host $BoardObj.Element.Value[76] -NoNewline -ForeGroundColor $SolvedColor
  Write-Host " | "  -NoNewline -ForeGroundColor $InnerColor
  Write-Host $BoardObj.Element.Value[77] -NoNewline -ForeGroundColor $SolvedColor
  Write-Host " $DL "  -NoNewline -ForeGroundColor $MainColor
  Write-Host $BoardObj.Element.Value[78] -NoNewline -ForeGroundColor $SolvedColor
  Write-Host " | "  -NoNewline -ForeGroundColor $InnerColor
  Write-Host $BoardObj.Element.Value[79] -NoNewline -ForeGroundColor $SolvedColor
  Write-Host " | "  -NoNewline -ForeGroundColor $InnerColor
  Write-Host $BoardObj.Element.Value[80] -NoNewline -ForeGroundColor $SolvedColor
  Write-Host " $DL"  -ForeGroundColor $MainColor
  Write-Host "+===+===+===+===+===+===+===+===+===+" -ForeGroundColor $MainColor
  Start-Sleep -Seconds 1
}

### Main Code
$Elements = 0..80 | ForEach-Object {
  [BoardElement]::New($_,$FlatPuzzle[$_])
} 
$WholeBoard = [Board]::New($Elements)

do {
  Show-Board -BoardObj $WholeBoard
  $WholeBoard.ResolveCandidates()
  $WholeBoard.ResolveHiddenSingleCandidateRow()
  $WholeBoard.ResolveCandidates()
  Show-Board -BoardObj $WholeBoard
  $WholeBoard.ResolveHiddenSingleCandidateCol()
  $WholeBoard.ResolveCandidates()
  Show-Board -BoardObj $WholeBoard
  $WholeBoard.ResolveHiddenSingleCandidateBox()
  $WholeBoard.ResolveCandidates()
  Show-Board -BoardObj $WholeBoard
  $WholeBoard.ResolvePointingPair()
  $WholeBoard.ResolveCandidates()
  Show-Board -BoardObj $WholeBoard
} Until ($WholeBoard.Element.Solved -notcontains $false)
