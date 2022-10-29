[CmdletBinding()]
Param (
  [ValidateLength(81,81)]
  [string]$FlatPuzzle = '-9--2-5----4--5-1--6-----93--18---6----9----2-8--72---5----1-7----3--9-1--3------'
  # '2-------4--641------5-2-83--------9--12-3-56--8--------63-5-1------873--8-------2'
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
    if ($Value -notmatch '[1-9]') {
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
    if ($this.PossibleValues.Count -eq 1) {
      $this.Solved = $true
    }
  }

  [void]RemoveOtherValuesFromPossible ([string[]]$StrArray) {
    $this.PossibleValues = $this.PossibleValues | Where-Object {$_ -in $StrArray}
    if ($this.PossibleValues.Count -eq 1) {
      $this.Solved = $true
    }
  }
}

class Board {
  [BoardElement[]]$Element

  Board ($Elements) {
    $this.Element = $Elements
  }

  [string]RetrievePossibles () {
    return $this.Element.PossibleValues -join ''
  }

  [void]ResolveCandidates () {
    $UnsolvedElements = $this.Element | Where-Object {$_.Solved -eq $false}
    foreach ($UnsolvedElement in $UnsolvedElements) {
      $Row = $UnsolvedElement.Row
      $Col = $UnsolvedElement.Col
      $Box = $UnsolvedElement.Box
      $RelatedSolvedValues = $this.Element | 
       Where-Object {($_.Col -eq $Col -or $_.Row -eq $Row -or $_.Box -eq $Box) -and $_.Solved -eq $true}
      foreach ($RelatedSolvedValue in $RelatedSolvedValues) {
        $UnsolvedElement.RemoveFromPossible($RelatedSolvedValue.Value)
        if ($UnsolvedElement.PossibleValues.Count -eq 1) {
          $UnsolvedElement.Value = $UnsolvedElement.PossibleValues[0]
          $UnsolvedElement.Solved = $true
        }
      }
      if ($UnsolvedElement.Solved -eq $true) {break}
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

  [void]ResolveHiddenPair () {
    $ElementCount = 0..8
    foreach ($Row in $ElementCount) {
      $UnsolvedElements = $this.Element | Where-Object {$_.Row -eq $Row -and $_.Solved -eq $false}
      if ($UnsolvedElements.Count -ge 2) {
        $Pairs = ($UnsolvedElements.PossibleValues | Group-Object | Where-Object {$_.Count -eq 2}).Name
        if ($Pairs.Count -ge 2) {
          $PairedElements = foreach ($Pair in $Pairs) {$UnsolvedElements | Where-Object {$_.PossibleValues -contains $Pair} }
          $TwoInSameBox = ($PairedElements.Box | Group-Object | Where-Object {$_.Count -eq 2}).Name
          #need code to finish here 
        }
      }
    }    
  }

  [void]ResolvePointingPair () {
    $ElementCount = 0..8
    foreach ($Row in $ElementCount) {
      $UnsolvedElements = $this.Element | Where-Object {$_.Row -eq $Row -and $_.Solved -eq $false}
      if ($UnsolvedElements.Count -ge 2) {
        $Pairs = ($UnsolvedElements.PossibleValues | Group-Object | Where-Object {$_.Count -eq 2}).Name
        if ($Pairs.Count -gt 0) {
          foreach ($Pair in $Pairs) {
            $UnsolvedPair = $UnsolvedElements | Where-Object {$_.PossibleValues -contains $Pair}
            if (Compare-Array -StrArray $UnsolvedPair.Box) {
              $BoxToRemoveCandidate = $UnsolvedPair[0].Box
              $ElementsToRemoveCandidate = $this.Element | Where-Object {$_.Box -eq $BoxToRemoveCandidate -and $_.Solved -eq $false -and $_.Pos -notin $UnsolvedPair.Pos}
              if ($ElementsToRemoveCandidate.Count -gt 0) {
                foreach ($Element in $ElementsToRemoveCandidate) {$Element.RemoveFromPossible($Pair)}
              }
            }
          }
        } 
      }
    }
    foreach ($Col in $ElementCount) {
      $UnsolvedElements = $this.Element | Where-Object {$_.Col -eq $Col -and $_.Solved -eq $false}
      if ($UnsolvedElements.Count -ge 2) {
        $Pairs = ($UnsolvedElements.PossibleValues | Group-Object | Where-Object {$_.Count -eq 2}).Name
        if ($Pairs.Count -gt 0) {
          foreach ($Pair in $Pairs) {
            $UnsolvedPair = $UnsolvedElements | Where-Object {$_.PossibleValues -contains $Pair}
            if (Compare-Array -StrArray $UnsolvedPair.Box) {
              $BoxToRemoveCandidate = $UnsolvedPair.Box
              $ElementsToRemoveCandidate = $this.Element | Where-Object {$_.Box -eq $BoxToRemoveCandidate -and $_.Solved -eq $false -and $_.Pos -notin $UnsolvedPair.Pos}
              if ($ElementsToRemoveCandidate.Count -gt 0) {
                foreach ($Element in $ElementsToRemoveCandidate) {$Element.RemoveFromPossible($Pair)}
              }
            }
          }
        } 
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
  $MainColor = 'cyan'
  $InnerColor = 'gray'
  $SolvedColor = 'yellow'
  $UnsolvedColor = 'Brown'
  $DL = [Char]449
  Write-Host "+===+===+===+===+===+===+===+===+===+" -ForeGroundColor $MainColor
  foreach ($outercount in (0,27,54)) {
  Write-Host "$DL " -NoNewline -ForeGroundColor $MainColor
    foreach ($count in (0,3,6)) {
      Write-Host $BoardObj.Element.Value[0+$count+$outercount]  -NoNewline -ForeGroundColor $SolvedColor
      Write-Host " | "  -NoNewline -ForeGroundColor $InnerColor
      Write-Host $BoardObj.Element.Value[1+$count+$outercount] -NoNewline -ForeGroundColor $SolvedColor
      Write-Host " | "  -NoNewline -ForeGroundColor $InnerColor
      Write-Host $BoardObj.Element.Value[2+$count+$outercount] -NoNewline -ForeGroundColor $SolvedColor
      Write-Host " $DL "  -NoNewline -ForeGroundColor $Maincolor
    }
    Write-Host
    Write-Host "+" -NoNewline -ForeGroundColor $MainColor
    foreach ($count in (1..3)) {
      Write-Host "---+---+---" -ForeGroundColor $InnerColor -NoNewline
      Write-Host "+" -ForeGroundColor $MainColor -NoNewline
    }
    Write-Host
    Write-Host "$DL " -NoNewline -ForeGroundColor $MainColor
    foreach ($count in (0,3,6)) {
      Write-Host $BoardObj.Element.Value[9+$count+$outercount] -NoNewline -ForeGroundColor $SolvedColor
      Write-Host " | "   -NoNewline -ForeGroundColor $InnerColor
      Write-Host $BoardObj.Element.Value[10+$count+$outercount] -NoNewline -ForeGroundColor $SolvedColor
      Write-Host " | "   -NoNewline -ForeGroundColor $InnerColor
      Write-Host $BoardObj.Element.Value[11+$count+$outercount] -NoNewline -ForeGroundColor $SolvedColor
      Write-Host " $DL "   -NoNewline -ForeGroundColor $MainColor
    }
    Write-Host
    Write-Host "+" -NoNewline -ForeGroundColor $MainColor
    foreach ($count in (1..3)) {
      Write-Host "---+---+---" -ForeGroundColor $InnerColor -NoNewline
      Write-Host "+" -ForeGroundColor $MainColor -NoNewline
    }
    Write-Host
    Write-Host "$DL " -NoNewline -ForeGroundColor $MainColor
    foreach ($count in (0,3,6)) {
      Write-Host $BoardObj.Element.Value[18+$count+$outercount] -NoNewline -ForeGroundColor $SolvedColor
      Write-Host " | "  -NoNewline -ForeGroundColor $InnerColor
      Write-Host $BoardObj.Element.Value[19+$count+$outercount] -NoNewline -ForeGroundColor $SolvedColor
      Write-Host " | "   -NoNewline -ForeGroundColor $InnerColor
      Write-Host $BoardObj.Element.Value[20+$count+$outercount] -NoNewline -ForeGroundColor $SolvedColor
      Write-Host " $DL "   -NoNewline -ForeGroundColor $MainColor
    }  
    Write-Host
    Write-Host "+===+===+===+===+===+===+===+===+===+" -ForeGroundColor $MainColor
  }
  # Start-Sleep -Milliseconds 10000
}

### Main Code
$Elements = 0..80 | ForEach-Object {
  [BoardElement]::New($_,$FlatPuzzle[$_])
} 
$WholeBoard = [Board]::New($Elements)
do {
  Show-Board -BoardObj $WholeBoard
  do {
    $CurrentState = $WholeBoard.RetrievePossibles()
    $WholeBoard.ResolveCandidates()
    if ($WholeBoard.Element.Solved -notcontains $false) {break}
    Show-Board -BoardObj $WholeBoard
    $WholeBoard.ResolveHiddenSingleCandidateRow()
    if ($WholeBoard.Element.Solved -notcontains $false) {break}
    Show-Board -BoardObj $WholeBoard
    $WholeBoard.ResolveCandidates()
    if ($WholeBoard.Element.Solved -notcontains $false) {break}
    Show-Board -BoardObj $WholeBoard
  } until ($CurrentState -eq $WholeBoard.RetrievePossibles())
  Show-Board -BoardObj $WholeBoard
  

 

} Until ($WholeBoard.Element.Solved -notcontains $false)
