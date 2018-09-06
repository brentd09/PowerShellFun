$tlc = [char]9484
$hb  = [char]9480
$tt  = [char]9516
$trc = [char]9488
$lt  = [char]9500
$rt  = [char]9508
$blc = [char]9492
$bt  = [char]9524
$brc = [char]9496
$mc  = [char]9532
$vb  = [char]9474
$BK = [char]9812
$BQ = [char]9813
$BR = [char]9814
$BB = [char]9815
$BN = [char]9816
$BP = [char]9817
$WK = [char]9818
$WQ = [char]9819
$WR = [char]9820
$WB = [char]9821
$WN = [char]9822
$WP = [char]9823

function Show-Board {
Param ($BoardPlacements)

  $color = 'blue'
  $Pos = @("$br","$bn","$bb","$bq","$bk","$bb","$bn","$br",
           "$bp","$bp","$bp","$bp","$bp","$bp","$bp","$bp",
           " "," "," "," "," "," "," "," ",
           " "," "," "," "," "," "," "," ",
           " "," "," "," "," "," "," "," ",
           " "," "," "," "," "," "," "," ",
           "$wp","$wp","$wp","$wp","$wp","$wp","$wp","$wp",
           "$wr","$wn","$wb","$wq","$wk","$wb","$wn","$wr")
  $Gtr = '  '
  

  Write-Host "                 PGN Player"
  
  write-host $gtr$tlc$hb$hb$hb$hb$tt$hb$hb$hb$hb$tt$hb$hb$hb$hb$tt$hb$hb$hb$hb$tt$hb$hb$hb$hb$tt$hb$hb$hb$hb$tt$hb$hb$hb$hb$tt$hb$hb$hb$hb$trc
  write-host -NoNewline '8 '
  Write-Host -NoNewline "$vb"
  write-host -BackgroundColor $color -NoNewline " $($Pos[0])  "
  Write-Host -NoNewline "$vb"
  write-host -NoNewline " $($Pos[1])  "
  write-host -NoNewline "$vb"
  write-host -NoNewline -BackgroundColor $color " $($Pos[2])  "
  write-host -NoNewline "$vb"
  write-host -NoNewline " $($Pos[3])  "
  write-host -NoNewline "$vb"
  write-host -NoNewline -BackgroundColor $color " $($Pos[4])  "
  write-host -NoNewline "$vb"
  write-host -NoNewline " $($Pos[5])  "
  write-host -NoNewline "$vb"
  write-host -NoNewline -BackgroundColor $color " $($Pos[6])  "
  write-host -NoNewline "$vb"
  write-host -NoNewline " $($Pos[7])  "
  write-host "$vb"
  write-host $gtr$lt$hb$hb$hb$hb$mc$hb$hb$hb$hb$mc$hb$hb$hb$hb$mc$hb$hb$hb$hb$mc$hb$hb$hb$hb$mc$hb$hb$hb$hb$mc$hb$hb$hb$hb$mc$hb$hb$hb$hb$rt
  write-host -NoNewline '7 '
  Write-Host -NoNewline "$vb"
  write-host -NoNewline " $($Pos[8])  "
  Write-Host -NoNewline "$vb"
  write-host -BackgroundColor $color -NoNewline " $($Pos[9])  "
  write-host -NoNewline "$vb"
  write-host -NoNewline " $($Pos[10])  "
  write-host -NoNewline "$vb"
  write-host -BackgroundColor $color -NoNewline " $($Pos[11])  "
  write-host -NoNewline "$vb"
  write-host -NoNewline " $($Pos[12])  "
  write-host -NoNewline "$vb"
  write-host -BackgroundColor $color -NoNewline " $($Pos[13])  "
  write-host -NoNewline "$vb"
  write-host -NoNewline " $($Pos[14])  "
  write-host -NoNewline "$vb"
  write-host -BackgroundColor $color -NoNewline " $($Pos[15])  "
  write-host "$vb"
  write-host $gtr$lt$hb$hb$hb$hb$mc$hb$hb$hb$hb$mc$hb$hb$hb$hb$mc$hb$hb$hb$hb$mc$hb$hb$hb$hb$mc$hb$hb$hb$hb$mc$hb$hb$hb$hb$mc$hb$hb$hb$hb$rt
  write-host -NoNewline '6 '
  Write-Host -NoNewline "$vb"
  write-host -BackgroundColor $color -NoNewline " $($Pos[16])  "
  Write-Host -NoNewline "$vb"
  write-host -NoNewline " $($Pos[17])  "
  write-host -NoNewline "$vb"
  write-host -NoNewline -BackgroundColor $color " $($Pos[18])  "
  write-host -NoNewline "$vb"
  write-host -NoNewline " $($Pos[19])  "
  write-host -NoNewline "$vb"
  write-host -NoNewline -BackgroundColor $color " $($Pos[20])  "
  write-host -NoNewline "$vb"
  write-host -NoNewline " $($Pos[21])  "
  write-host -NoNewline "$vb"
  write-host -NoNewline -BackgroundColor $color " $($Pos[22])  "
  write-host -NoNewline "$vb"
  write-host -NoNewline " $($Pos[23])  "
  write-host "$vb"
  write-host $gtr$lt$hb$hb$hb$hb$mc$hb$hb$hb$hb$mc$hb$hb$hb$hb$mc$hb$hb$hb$hb$mc$hb$hb$hb$hb$mc$hb$hb$hb$hb$mc$hb$hb$hb$hb$mc$hb$hb$hb$hb$rt
  write-host -NoNewline '5 '
  Write-Host -NoNewline "$vb"
  write-host -NoNewline " $($Pos[24])  "
  Write-Host -NoNewline "$vb"
  write-host -BackgroundColor $color -NoNewline " $($Pos[25])  "
  write-host -NoNewline "$vb"
  write-host -NoNewline " $($Pos[26])  "
  write-host -NoNewline "$vb"
  write-host -BackgroundColor $color -NoNewline " $($Pos[27])  "
  write-host -NoNewline "$vb"
  write-host -NoNewline " $($Pos[28])  "
  write-host -NoNewline "$vb"
  write-host -BackgroundColor $color -NoNewline " $($Pos[29])  "
  write-host -NoNewline "$vb"
  write-host -NoNewline " $($Pos[30])  "
  write-host -NoNewline "$vb"
  write-host -BackgroundColor $color -NoNewline " $($Pos[31])  "
  write-host "$vb"
  write-host $gtr$lt$hb$hb$hb$hb$mc$hb$hb$hb$hb$mc$hb$hb$hb$hb$mc$hb$hb$hb$hb$mc$hb$hb$hb$hb$mc$hb$hb$hb$hb$mc$hb$hb$hb$hb$mc$hb$hb$hb$hb$rt
  write-host -NoNewline '4 '
  Write-Host -NoNewline "$vb"
  write-host -BackgroundColor $color -NoNewline " $($Pos[32])  "
  Write-Host -NoNewline "$vb"
  write-host -NoNewline " $($Pos[33])  "
  write-host -NoNewline "$vb"
  write-host -NoNewline -BackgroundColor $color " $($Pos[34])  "
  write-host -NoNewline "$vb"
  write-host -NoNewline " $($Pos[35])  "
  write-host -NoNewline "$vb"
  write-host -NoNewline -BackgroundColor $color " $($Pos[36])  "
  write-host -NoNewline "$vb"
  write-host -NoNewline " $($Pos[37])  "
  write-host -NoNewline "$vb"
  write-host -NoNewline -BackgroundColor $color " $($Pos[38])  "
  write-host -NoNewline "$vb"
  write-host -NoNewline " $($Pos[39])  "
  write-host "$vb"
  write-host $gtr$lt$hb$hb$hb$hb$mc$hb$hb$hb$hb$mc$hb$hb$hb$hb$mc$hb$hb$hb$hb$mc$hb$hb$hb$hb$mc$hb$hb$hb$hb$mc$hb$hb$hb$hb$mc$hb$hb$hb$hb$rt
  write-host -NoNewline '3 '
  Write-Host -NoNewline "$vb"
  write-host -NoNewline " $($Pos[40])  "
  Write-Host -NoNewline "$vb"
  write-host -BackgroundColor $color -NoNewline " $($Pos[41])  "
  write-host -NoNewline "$vb"
  write-host -NoNewline " $($Pos[42])  "
  write-host -NoNewline "$vb"
  write-host -BackgroundColor $color -NoNewline " $($Pos[43])  "
  write-host -NoNewline "$vb"
  write-host -NoNewline " $($Pos[44])  "
  write-host -NoNewline "$vb"
  write-host -BackgroundColor $color -NoNewline " $($Pos[45])  "
  write-host -NoNewline "$vb"
  write-host -NoNewline " $($Pos[46])  "
  write-host -NoNewline "$vb"
  write-host -BackgroundColor $color -NoNewline " $($Pos[47])  "
  write-host "$vb"
  write-host $gtr$lt$hb$hb$hb$hb$mc$hb$hb$hb$hb$mc$hb$hb$hb$hb$mc$hb$hb$hb$hb$mc$hb$hb$hb$hb$mc$hb$hb$hb$hb$mc$hb$hb$hb$hb$mc$hb$hb$hb$hb$rt
  write-host -NoNewline '2 '
  Write-Host -NoNewline "$vb"
  write-host -BackgroundColor $color -NoNewline " $($Pos[48])  "
  Write-Host -NoNewline "$vb"
  write-host -NoNewline " $($Pos[49])  "
  write-host -NoNewline "$vb"
  write-host -NoNewline -BackgroundColor $color " $($Pos[50])  "
  write-host -NoNewline "$vb"
  write-host -NoNewline " $($Pos[51])  "
  write-host -NoNewline "$vb"
  write-host -NoNewline -BackgroundColor $color " $($Pos[52])  "
  write-host -NoNewline "$vb"
  write-host -NoNewline " $($Pos[53])  "
  write-host -NoNewline "$vb"
  write-host -NoNewline -BackgroundColor $color " $($Pos[54])  "
  write-host -NoNewline "$vb"
  write-host -NoNewline " $($Pos[55])  "
  write-host "$vb"
  write-host $gtr$lt$hb$hb$hb$hb$mc$hb$hb$hb$hb$mc$hb$hb$hb$hb$mc$hb$hb$hb$hb$mc$hb$hb$hb$hb$mc$hb$hb$hb$hb$mc$hb$hb$hb$hb$mc$hb$hb$hb$hb$rt
  write-host -NoNewline '1 '
  Write-Host -NoNewline "$vb"
  write-host -NoNewline " $($Pos[56])  "
  Write-Host -NoNewline "$vb"
  write-host -BackgroundColor $color -NoNewline " $($Pos[57])  "
  write-host -NoNewline "$vb"
  write-host -NoNewline " $($Pos[58])  "
  write-host -NoNewline "$vb"
  write-host -BackgroundColor $color -NoNewline " $($Pos[59])  "
  write-host -NoNewline "$vb"
  write-host -NoNewline " $($Pos[60])  "
  write-host -NoNewline "$vb"
  write-host -BackgroundColor $color -NoNewline " $($Pos[61])  "
  write-host -NoNewline "$vb"
  write-host -NoNewline " $($Pos[62])  "
  write-host -NoNewline "$vb"
  write-host -BackgroundColor $color -NoNewline " $($Pos[63])  "
  write-host "$vb"
  write-host $gtr$blc$hb$hb$hb$hb$bt$hb$hb$hb$hb$bt$hb$hb$hb$hb$bt$hb$hb$hb$hb$bt$hb$hb$hb$hb$bt$hb$hb$hb$hb$bt$hb$hb$hb$hb$bt$hb$hb$hb$hb$brc
  Write-Host "$gtr  A    B    C    D    E    F    G    H`n"
}


Show-Board