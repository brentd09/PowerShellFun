if (Test-Path .\BBBlackSqr.png) {
  Add-Type -AssemblyName System.Windows.Forms
  [System.Windows.Forms.Application]::EnableVisualStyles()
  
  $CurrentPath = (Get-Location).Path 

  $Form            = New-Object system.Windows.Forms.Form
  $Form.ClientSize = '652,564'
  $Form.text       = "Form"
  $Form.TopMost    = $false
  $Form.BackColor  = "darkblue"
  
  $PictureBox = [system.Windows.Forms.PictureBox[]]::new(64)
  $TextBoard = [string[]]::new(64)
  $VLabel = [system.Windows.Forms.Label[]]::new(8)
  $HLabel = [system.Windows.Forms.Label[]]::new(8)
  $TextBoard[0] = 'br'; $TextBoard[1] = 'bn'; $TextBoard[2] = 'bb'; $TextBoard[3] = 'bq'; $TextBoard[4] = 'bk'
  $TextBoard[5] = 'bb'; $TextBoard[6] = 'bn'; $TextBoard[7] = 'br'
  foreach ($tbPos in (8..15)) {$TextBoard[$tbPos] = 'bp'} 
  foreach ($tbPos in (48..55)) {$TextBoard[$tbPos] = 'wp'} 
  $TextBoard[56] = 'wr'; $TextBoard[57] = 'wn'; $TextBoard[58] = 'wb'; $TextBoard[59] = 'wq'; $TextBoard[60] = 'wk'
  $TextBoard[61] = 'wb'; $TextBoard[62] = 'wn'; $TextBoard[63] = 'wr'
  
  
  $StartCol = 38 ; $StartRow = 49
  $StartVLbl = 65
  foreach ($index in (0..7)) {
    $VLblPos = $StartVLbl + ($index * 50)
    $VLabel[$index]                          = New-Object system.Windows.Forms.Label
    $VLabel[$index].text                     = (8-$index -as [string])
    $VLabel[$index].AutoSize                 = $true
    $VLabel[$index].width                    = 25
    $VLabel[$index].height                   = 10
    $VLabel[$index].location                 = New-Object System.Drawing.Point(14,$VLblPos)
    $VLabel[$index].Font                     = 'Microsoft Sans Serif,10'
    $VLabel[$index].ForeColor                = 'White'
  }

  $StartHLbl = 55
  foreach ($index in (0..7)) {
    $HLblPos = $StartHLbl + ($index * 50)
    $HLabel[$index]           = New-Object system.Windows.Forms.Label
    $HLabel[$index].text      = [char](65+$index)
    $HLabel[$index].AutoSize  = $true
    $HLabel[$index].width     = 25
    $HLabel[$index].height    = 10
    $HLabel[$index].location  = New-Object System.Drawing.Point($HLblPos,463)
    $HLabel[$index].Font      = 'Microsoft Sans Serif,10'
    $HLabel[$index].ForeColor = 'White'
  }

  foreach ($Row in (0..7)) {
    foreach ($Col in (0..7)) {
      $Pos = $Row * 8 + $Col
      $ColPos = $StartCol + (50 * $Col)
      $RowPos = $StartRow + (50 * $Row)
      $AddRowCol = $Row + $Col
      if (($AddRowCol % 2) -eq 0) {
        if ($TextBoard[$Pos] -match '^[wb]') {
          $Picture = "$CurrentPath\$($TextBoard[$Pos])WhiteSqr.png"
        }
        else {
          $Picture = "$CurrentPath\WhiteEmpty.png"
        }
      }
      else {
        if ($TextBoard[$Pos] -match '^[wb]') {
          $Picture = "$CurrentPath\$($TextBoard[$Pos])BlackSqr.png"
        }
        else {
          $Picture = "$CurrentPath\BlackEmpty.png"
        }
      }
  
      $PictureBox[$Pos]               = New-Object system.Windows.Forms.PictureBox
      $PictureBox[$Pos].width         = 50
      $PictureBox[$Pos].height        = 50
      $PictureBox[$Pos].location      = New-Object System.Drawing.Point($ColPos,$RowPos)
      $PictureBox[$Pos].imageLocation = $Picture
      $PictureBox[$Pos].SizeMode      = [System.Windows.Forms.PictureBoxSizeMode]::zoom
    }
  }
  $Groupbox1                       = New-Object system.Windows.Forms.Groupbox
  $Groupbox1.height                = 422
  $Groupbox1.width                 = 414
  $Groupbox1.location              = New-Object System.Drawing.Point(31,35)
  
  $PictureBox[63].Add_Click({"do something"})
  
  $Form.controls.AddRange(@($PictureBox))
  $Form.controls.AddRange(@($Groupbox1))
  $Form.controls.AddRange(@($VLabel))
  $Form.controls.AddRange(@($HLabel))
  $Form.ShowDialog()
}