function Invoke-DiceRoll {
  Param($DiceFaces = 6)
  return (1..$DiceFaces | Get-Random)
}

function Clear-Dice {
  $tbox_dice1.Text = ''
  $tbox_dice2.Text = ''
  $tbox_dice3.Text = ''
  $tbox_dice4.Text = ''
  $tbox_dice5.Text = ''
  $tbox_dice1.BackColor = 'White'
  $tbox_dice2.BackColor = 'White'
  $tbox_dice3.BackColor = 'White'
  $tbox_dice4.BackColor = 'White'
  $tbox_dice5.BackColor = 'White'
  $Script:RollCount = 0
  $tbox_rollcount.text = $Script:RollCount
}

function Add-TopTotal {
  $SubTotal = 0 + $tbox_one.Text  +
              $tbox_two.Text  +
              $tbox_three.Text  +
              $tbox_four.Text  +
              $tbox_five.Text  +
              $tbox_six.Text 
  $tbox_subtotal.Text = $SubTotal
  if ($SubTotal -ge 63) {$Bonus = 35}
  else {$Bonus = 0}
  $tbox_bonus.Text = $Bonus
  $tbox_toptotal.Text = $SubTotal + $Bonus
}

function Add-GrandTotal {
  $GT = 0 + $tbox_toptotal.Text + $tbox_3kind.Text + $tbox_4kind.Text + $tbox_fullhouse.Text + $tbox_smstraight.Text + $tbox_lgstraight.Text + $tbox_yahtzee.Text +
        $tbox_yahtzeebonus.Text + $tbox_chance.Text
  $tbox_grandtotal.Text = $GT         
}

function Test-EndGame {
  if ($tbox_one.Text -and $tbox_two.Text -and $tbox_three.Text -and $tbox_four.Text -and $tbox_five.Text -and $tbox_six.Text -and $tbox_3kind.Text -and 
      $tbox_4kind.Text -and $tbox_fullhouse.Text -and $tbox_smstraight.Text -and $tbox_lgstraight.Text -and $tbox_yahtzee.Text -and 
      $tbox_yahtzeebonus.Text -and $tbox_chance.Text){
        $butt_rollall.Enabled = $false
        $butt_rollselected.Enabled = $false
        $butt_EndGame.Enabled = $true
      }
}

# Initial variables
$RollCount = 0
$AllDice = @()

# Form coding

Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.Application]::EnableVisualStyles()

$Form                            = New-Object system.Windows.Forms.Form
$Form.ClientSize                 = New-Object System.Drawing.Point(606,710)
$Form.text                       = "Form"
$Form.TopMost                    = $false

$Groupbox1                       = New-Object system.Windows.Forms.Groupbox
$Groupbox1.height                = 277
$Groupbox1.width                 = 287
$Groupbox1.text                  = "Upper Section"
$Groupbox1.location              = New-Object System.Drawing.Point(32,72)

$Groupbox2                       = New-Object system.Windows.Forms.Groupbox
$Groupbox2.height                = 170
$Groupbox2.width                 = 200
$Groupbox2.text                  = "Dice"
$Groupbox2.location              = New-Object System.Drawing.Point(366,281)

$Groupbox3                       = New-Object system.Windows.Forms.Groupbox
$Groupbox3.height                = 305
$Groupbox3.width                 = 288
$Groupbox3.text                  = "Lower Section"
$Groupbox3.location              = New-Object System.Drawing.Point(32,366)

$tbox_one                        = New-Object system.Windows.Forms.TextBox
$tbox_one.multiline              = $false
$tbox_one.width                  = 33
$tbox_one.height                 = 20
$tbox_one.location               = New-Object System.Drawing.Point(14,27)
$tbox_one.Font                   = New-Object System.Drawing.Font('Microsoft Sans Serif',10)
$tbox_one.ReadOnly               = $true

$tbox_two                        = New-Object system.Windows.Forms.TextBox
$tbox_two.multiline              = $false
$tbox_two.width                  = 33
$tbox_two.height                 = 20
$tbox_two.location               = New-Object System.Drawing.Point(14,52)
$tbox_two.Font                   = New-Object System.Drawing.Font('Microsoft Sans Serif',10)
$tbox_two.ReadOnly               = $true

$tbox_three                      = New-Object system.Windows.Forms.TextBox
$tbox_three.multiline            = $false
$tbox_three.width                = 33
$tbox_three.height               = 20
$tbox_three.location             = New-Object System.Drawing.Point(14,77)
$tbox_three.Font                 = New-Object System.Drawing.Font('Microsoft Sans Serif',10)
$tbox_three.ReadOnly             = $true

$tbox_six                        = New-Object system.Windows.Forms.TextBox
$tbox_six.multiline              = $false
$tbox_six.width                  = 33
$tbox_six.height                 = 20
$tbox_six.location               = New-Object System.Drawing.Point(14,152)
$tbox_six.Font                   = New-Object System.Drawing.Font('Microsoft Sans Serif',10)
$tbox_six.ReadOnly               = $true

$tbox_five                       = New-Object system.Windows.Forms.TextBox
$tbox_five.multiline             = $false
$tbox_five.width                 = 33
$tbox_five.height                = 20
$tbox_five.location              = New-Object System.Drawing.Point(14,127)
$tbox_five.Font                  = New-Object System.Drawing.Font('Microsoft Sans Serif',10)
$tbox_five.ReadOnly              = $true

$tbox_four                       = New-Object system.Windows.Forms.TextBox
$tbox_four.multiline             = $false
$tbox_four.width                 = 33
$tbox_four.height                = 20
$tbox_four.location              = New-Object System.Drawing.Point(14,102)
$tbox_four.Font                  = New-Object System.Drawing.Font('Microsoft Sans Serif',10)
$tbox_four.ReadOnly              = $true

$tbox_toptotal                   = New-Object system.Windows.Forms.TextBox
$tbox_toptotal.multiline         = $false
$tbox_toptotal.width             = 33
$tbox_toptotal.height            = 20
$tbox_toptotal.location          = New-Object System.Drawing.Point(158,225)
$tbox_toptotal.Font              = New-Object System.Drawing.Font('Microsoft Sans Serif',10)
$tbox_toptotal.ReadOnly         = $true

$tbox_bonus                      = New-Object system.Windows.Forms.TextBox
$tbox_bonus.multiline            = $false
$tbox_bonus.width                = 33
$tbox_bonus.height               = 20
$tbox_bonus.location             = New-Object System.Drawing.Point(158,200)
$tbox_bonus.Font                 = New-Object System.Drawing.Font('Microsoft Sans Serif',10)
$tbox_bonus.ReadOnly             = $true

$tbox_subtotal                   = New-Object system.Windows.Forms.TextBox
$tbox_subtotal.multiline         = $false
$tbox_subtotal.width             = 33
$tbox_subtotal.height            = 20
$tbox_subtotal.location          = New-Object System.Drawing.Point(158,175)
$tbox_subtotal.Font              = New-Object System.Drawing.Font('Microsoft Sans Serif',10)
$tbox_subtotal.ReadOnly          = $true

$label_one                       = New-Object system.Windows.Forms.Label
$label_one.text                  = "1s"
$label_one.AutoSize              = $true
$label_one.width                 = 25
$label_one.height                = 10
$label_one.location              = New-Object System.Drawing.Point(58,30)
$label_one.Font                  = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$label_toptotal                  = New-Object system.Windows.Forms.Label
$label_toptotal.text             = "Top Total"
$label_toptotal.AutoSize         = $true
$label_toptotal.width            = 25
$label_toptotal.height           = 10
$label_toptotal.location         = New-Object System.Drawing.Point(200,227)
$label_toptotal.Font             = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$label_bonus                     = New-Object system.Windows.Forms.Label
$label_bonus.text                = "Bonus"
$label_bonus.AutoSize            = $true
$label_bonus.width               = 25
$label_bonus.height              = 10
$label_bonus.location            = New-Object System.Drawing.Point(200,202)
$label_bonus.Font                = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$label_subtotal                  = New-Object system.Windows.Forms.Label
$label_subtotal.text             = "Sub Total"
$label_subtotal.AutoSize         = $true
$label_subtotal.width            = 25
$label_subtotal.height           = 10
$label_subtotal.location         = New-Object System.Drawing.Point(200,177)
$label_subtotal.Font             = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$label_six                       = New-Object system.Windows.Forms.Label
$label_six.text                  = "6s"
$label_six.AutoSize              = $true
$label_six.width                 = 25
$label_six.height                = 10
$label_six.location              = New-Object System.Drawing.Point(58,155)
$label_six.Font                  = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$label_five                      = New-Object system.Windows.Forms.Label
$label_five.text                 = "5s"
$label_five.AutoSize             = $true
$label_five.width                = 25
$label_five.height               = 10
$label_five.location             = New-Object System.Drawing.Point(58,130)
$label_five.Font                 = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$label_four                      = New-Object system.Windows.Forms.Label
$label_four.text                 = "4s"
$label_four.AutoSize             = $true
$label_four.width                = 25
$label_four.height               = 10
$label_four.location             = New-Object System.Drawing.Point(58,105)
$label_four.Font                 = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$label_three                     = New-Object system.Windows.Forms.Label
$label_three.text                = "3s"
$label_three.AutoSize            = $true
$label_three.width               = 25
$label_three.height              = 10
$label_three.location            = New-Object System.Drawing.Point(58,80)
$label_three.Font                = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$label_two                       = New-Object system.Windows.Forms.Label
$label_two.text                  = "2s"
$label_two.AutoSize              = $true
$label_two.width                 = 25
$label_two.height                = 10
$label_two.location              = New-Object System.Drawing.Point(58,56)
$label_two.Font                  = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$tbox_dice1                      = New-Object system.Windows.Forms.TextBox
$tbox_dice1.multiline            = $false
$tbox_dice1.width                = 28
$tbox_dice1.height               = 20
$tbox_dice1.location             = New-Object System.Drawing.Point(14,25)
$tbox_dice1.Font                 = New-Object System.Drawing.Font('Microsoft Sans Serif',10)
$tbox_dice1.ReadOnly             = $true

$tbox_dice5                      = New-Object system.Windows.Forms.TextBox
$tbox_dice5.multiline            = $false
$tbox_dice5.width                = 28
$tbox_dice5.height               = 20
$tbox_dice5.location             = New-Object System.Drawing.Point(13,125)
$tbox_dice5.Font                 = New-Object System.Drawing.Font('Microsoft Sans Serif',10)
$tbox_dice5.ReadOnly             = $true


$tbox_dice4                      = New-Object system.Windows.Forms.TextBox
$tbox_dice4.multiline            = $false
$tbox_dice4.width                = 28
$tbox_dice4.height               = 20
$tbox_dice4.location             = New-Object System.Drawing.Point(13,100)
$tbox_dice4.Font                 = New-Object System.Drawing.Font('Microsoft Sans Serif',10)
$tbox_dice4.ReadOnly             = $true

$tbox_dice3                      = New-Object system.Windows.Forms.TextBox
$tbox_dice3.multiline            = $false
$tbox_dice3.width                = 28
$tbox_dice3.height               = 20
$tbox_dice3.location             = New-Object System.Drawing.Point(14,75)
$tbox_dice3.Font                 = New-Object System.Drawing.Font('Microsoft Sans Serif',10)
$tbox_dice3.ReadOnly             = $true

$tbox_dice2                      = New-Object system.Windows.Forms.TextBox
$tbox_dice2.multiline            = $false
$tbox_dice2.width                = 28
$tbox_dice2.height               = 20
$tbox_dice2.location             = New-Object System.Drawing.Point(14,50)
$tbox_dice2.Font                 = New-Object System.Drawing.Font('Microsoft Sans Serif',10)
$tbox_dice2.ReadOnly             = $true

$butt_rollall                    = New-Object system.Windows.Forms.Button
$butt_rollall.text               = "Roll All"
$butt_rollall.width              = 109
$butt_rollall.height             = 30
$butt_rollall.location           = New-Object System.Drawing.Point(76,72)
$butt_rollall.Font               = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$butt_rollselected               = New-Object system.Windows.Forms.Button
$butt_rollselected.text          = "Roll Selected"
$butt_rollselected.width         = 109
$butt_rollselected.height        = 30
$butt_rollselected.location      = New-Object System.Drawing.Point(76,106)
$butt_rollselected.Font          = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$butt_EndGame                    = New-Object system.Windows.Forms.Button
$butt_EndGame.text               = "End Game"
$butt_EndGame.width              = 109
$butt_EndGame.height             = 30
$butt_EndGame.location           = New-Object System.Drawing.Point(440,640)
$butt_EndGame.Font               = New-Object System.Drawing.Font('Microsoft Sans Serif',10)
$butt_EndGame.Enabled            = $false 

$tbox_3kind                      = New-Object system.Windows.Forms.TextBox
$tbox_3kind.multiline            = $false
$tbox_3kind.width                = 37
$tbox_3kind.height               = 20
$tbox_3kind.location             = New-Object System.Drawing.Point(14,25)
$tbox_3kind.Font                 = New-Object System.Drawing.Font('Microsoft Sans Serif',10)
$tbox_3kind.ReadOnly             = $true

$tbox_grandtotal                 = New-Object system.Windows.Forms.TextBox
$tbox_grandtotal.multiline       = $false
$tbox_grandtotal.width           = 37
$tbox_grandtotal.height          = 20
$tbox_grandtotal.location        = New-Object System.Drawing.Point(147,270)
$tbox_grandtotal.Font            = New-Object System.Drawing.Font('Microsoft Sans Serif',10)
$tbox_grandtotal.ReadOnly        = $true

$tbox_chance                     = New-Object system.Windows.Forms.TextBox
$tbox_chance.multiline           = $false
$tbox_chance.width               = 37
$tbox_chance.height              = 20
$tbox_chance.location            = New-Object System.Drawing.Point(14,200)
$tbox_chance.Font                = New-Object System.Drawing.Font('Microsoft Sans Serif',10)
$tbox_chance.ReadOnly            = $true

$tbox_yahtzeebonus               = New-Object system.Windows.Forms.TextBox
$tbox_yahtzeebonus.multiline     = $false
$tbox_yahtzeebonus.width         = 37
$tbox_yahtzeebonus.height        = 20
$tbox_yahtzeebonus.location      = New-Object System.Drawing.Point(14,175)
$tbox_yahtzeebonus.Font          = New-Object System.Drawing.Font('Microsoft Sans Serif',10)
$tbox_yahtzeebonus.ReadOnly      = $true

$tbox_yahtzee                    = New-Object system.Windows.Forms.TextBox
$tbox_yahtzee.multiline          = $false
$tbox_yahtzee.width              = 37
$tbox_yahtzee.height             = 20
$tbox_yahtzee.location           = New-Object System.Drawing.Point(14,150)
$tbox_yahtzee.Font               = New-Object System.Drawing.Font('Microsoft Sans Serif',10)
$tbox_yahtzee.ReadOnly           = $true

$tbox_lgstraight                 = New-Object system.Windows.Forms.TextBox
$tbox_lgstraight.multiline       = $false
$tbox_lgstraight.width           = 37
$tbox_lgstraight.height          = 20
$tbox_lgstraight.location        = New-Object System.Drawing.Point(14,125)
$tbox_lgstraight.Font            = New-Object System.Drawing.Font('Microsoft Sans Serif',10)
$tbox_lgstraight.ReadOnly        = $true

$tbox_smstraight                 = New-Object system.Windows.Forms.TextBox
$tbox_smstraight.multiline       = $false
$tbox_smstraight.width           = 37
$tbox_smstraight.height          = 20
$tbox_smstraight.location        = New-Object System.Drawing.Point(14,100)
$tbox_smstraight.Font            = New-Object System.Drawing.Font('Microsoft Sans Serif',10)
$tbox_smstraight.ReadOnly        = $true

$tbox_fullhouse                  = New-Object system.Windows.Forms.TextBox
$tbox_fullhouse.multiline        = $false
$tbox_fullhouse.width            = 37
$tbox_fullhouse.height           = 20
$tbox_fullhouse.location         = New-Object System.Drawing.Point(15,75)
$tbox_fullhouse.Font             = New-Object System.Drawing.Font('Microsoft Sans Serif',10)
$tbox_fullhouse.ReadOnly         = $true

$tbox_4kind                      = New-Object system.Windows.Forms.TextBox
$tbox_4kind.multiline            = $false
$tbox_4kind.width                = 37
$tbox_4kind.height               = 20
$tbox_4kind.location             = New-Object System.Drawing.Point(14,50)
$tbox_4kind.Font                 = New-Object System.Drawing.Font('Microsoft Sans Serif',10)
$tbox_4kind.ReadOnly             = $true

$label_3kind                     = New-Object system.Windows.Forms.Label
$label_3kind.text                = "3 of a kind"
$label_3kind.AutoSize            = $true
$label_3kind.width               = 25
$label_3kind.height              = 10
$label_3kind.location            = New-Object System.Drawing.Point(67,28)
$label_3kind.Font                = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$label_chance                    = New-Object system.Windows.Forms.Label
$label_chance.text               = "Chance"
$label_chance.AutoSize           = $true
$label_chance.width              = 25
$label_chance.height             = 10
$label_chance.location           = New-Object System.Drawing.Point(67,203)
$label_chance.Font               = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$label_yahtzeebonus              = New-Object system.Windows.Forms.Label
$label_yahtzeebonus.text         = "Yahtzee bonus"
$label_yahtzeebonus.AutoSize     = $true
$label_yahtzeebonus.width        = 25
$label_yahtzeebonus.height       = 10
$label_yahtzeebonus.location     = New-Object System.Drawing.Point(67,177)
$label_yahtzeebonus.Font         = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$label_yahtzee                   = New-Object system.Windows.Forms.Label
$label_yahtzee.text              = "YAHTZEE"
$label_yahtzee.AutoSize          = $true
$label_yahtzee.width             = 25
$label_yahtzee.height            = 10
$label_yahtzee.location          = New-Object System.Drawing.Point(67,152)
$label_yahtzee.Font              = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$label_lgstraight                = New-Object system.Windows.Forms.Label
$label_lgstraight.text           = "Lg Straight"
$label_lgstraight.AutoSize       = $true
$label_lgstraight.width          = 25
$label_lgstraight.height         = 10
$label_lgstraight.location       = New-Object System.Drawing.Point(67,128)
$label_lgstraight.Font           = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$label_smstraight                = New-Object system.Windows.Forms.Label
$label_smstraight.text           = "Sm Straight"
$label_smstraight.AutoSize       = $true
$label_smstraight.width          = 25
$label_smstraight.height         = 10
$label_smstraight.location       = New-Object System.Drawing.Point(67,102)
$label_smstraight.Font           = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$label_fullhouse                 = New-Object system.Windows.Forms.Label
$label_fullhouse.text            = "Full House"
$label_fullhouse.AutoSize        = $true
$label_fullhouse.width           = 25
$label_fullhouse.height          = 10
$label_fullhouse.location        = New-Object System.Drawing.Point(67,78)
$label_fullhouse.Font            = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$label_4kind                     = New-Object system.Windows.Forms.Label
$label_4kind.text                = "4 of a kind"
$label_4kind.AutoSize            = $true
$label_4kind.width               = 25
$label_4kind.height              = 10
$label_4kind.location            = New-Object System.Drawing.Point(67,53)
$label_4kind.Font                = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$label_grandtotal                = New-Object system.Windows.Forms.Label
$label_grandtotal.text           = "Grand Total"
$label_grandtotal.AutoSize       = $true
$label_grandtotal.width          = 25
$label_grandtotal.height         = 10
$label_grandtotal.location       = New-Object System.Drawing.Point(195,273)
$label_grandtotal.Font           = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$Label19                         = New-Object system.Windows.Forms.Label
$Label19.text                    = "YAHTZEE GAME"
$Label19.AutoSize                = $true
$Label19.width                   = 25
$Label19.height                  = 10
$Label19.location                = New-Object System.Drawing.Point(240,29)
$Label19.Font                    = New-Object System.Drawing.Font('Microsoft Sans Serif',14)

$tbox_rollcount                  = New-Object system.Windows.Forms.TextBox
$tbox_rollcount.multiline        = $false
$tbox_rollcount.width            = 28
$tbox_rollcount.height           = 20
$tbox_rollcount.location         = New-Object System.Drawing.Point(85,25)
$tbox_rollcount.Font             = New-Object System.Drawing.Font('Microsoft Sans Serif',10)
$tbox_rollcount.Text             = $Script:RollCount
$tbox_rollcount.ReadOnly         = $true


$label_rollcount                 = New-Object system.Windows.Forms.Label
$label_rollcount.text            = "Roll Count"
$label_rollcount.AutoSize        = $true
$label_rollcount.width           = 25
$label_rollcount.height          = 10
$label_rollcount.location        = New-Object System.Drawing.Point(121,29)
$label_rollcount.Font            = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$Form.controls.AddRange(@($Groupbox1,$Groupbox2,$Groupbox3,$Label19,$butt_EndGame))
$Groupbox1.controls.AddRange(@($tbox_one,$tbox_two,$tbox_three,$tbox_six,$tbox_five,$tbox_four,$tbox_toptotal,$tbox_bonus,$tbox_subtotal,$label_one,$label_toptotal,$label_bonus,$label_subtotal,$label_six,$label_five,$label_four,$label_three,$label_two))
$Groupbox2.controls.AddRange(@($tbox_dice1,$tbox_dice5,$tbox_dice4,$tbox_dice3,$tbox_dice2,$butt_rollall,$butt_rollselected,$tbox_rollcount,$label_rollcount))
$Groupbox3.controls.AddRange(@($tbox_3kind,$tbox_grandtotal,$tbox_chance,$tbox_yahtzeebonus,$tbox_yahtzee,$tbox_lgstraight,$tbox_smstraight,$tbox_fullhouse,$tbox_4kind,$label_3kind,$label_chance,$label_yahtzeebonus,$label_yahtzee,$label_lgstraight,$label_smstraight,$label_fullhouse,$label_4kind,$label_grandtotal))

$tbox_one.Add_Click({
  If ($Script:RollCount -ge 1 -and -not $tbox_one.Text) {
    $HowMany = ($Script:AllDice | Where-Object {$_ -eq '1'}).Count
    $tbox_one.Text = 1 * $HowMany
    Clear-Dice
    Add-TopTotal
    Add-GrandTotal
    Test-EndGame
  }
})
$tbox_two.Add_Click({
  If ($Script:RollCount -ge 1 -and -not $tbox_two.Text) {
    $HowMany = ($Script:AllDice | Where-Object {$_ -eq '2'}).Count
    $tbox_two.Text = 2 * $HowMany
    Clear-Dice
    Add-TopTotal
    Add-GrandTotal
    Test-EndGame
  }
})
$tbox_three.Add_Click({
  If ($Script:RollCount -ge 1 -and -not $tbox_three.Text) {
    $HowMany = ($Script:AllDice | Where-Object {$_ -eq '3'}).Count
    $tbox_three.Text = 3 * $HowMany
    Clear-Dice
    Add-TopTotal
    Add-GrandTotal
    Test-EndGame
  }
})
$tbox_four.Add_Click({
  If ($Script:RollCount -ge 1 -and -not $tbox_four.Text) {
    $HowMany = ($Script:AllDice | Where-Object {$_ -eq '4'}).Count
    $tbox_four.Text = 4 * $HowMany
    Clear-Dice
    Add-TopTotal
    Add-GrandTotal
    Test-EndGame
  }
})
$tbox_five.Add_Click({
  If ($Script:RollCount -ge 1 -and -not $tbox_five.Text) {
    $HowMany = ($Script:AllDice | Where-Object {$_ -eq '5'}).Count
    $tbox_five.Text = 5 * $HowMany
    Clear-Dice
    Add-TopTotal
    Add-GrandTotal
    Test-EndGame
  }
})
$tbox_six.Add_Click({
  If ($Script:RollCount -ge 1 -and -not $tbox_six.Text) {
    $HowMany = ($Script:AllDice | Where-Object {$_ -eq '6'}).Count
    $tbox_six.Text = 6 * $HowMany
    Clear-Dice
    Add-TopTotal
    Add-GrandTotal
    Test-EndGame
  }
})
$tbox_3kind.Add_Click({
  if ($Script:RollCount -ge 1 -and -not $tbox_3kind.Text) {
    $GroupDice = $Script:AllDice | Group-Object | Select-Object -Property *,@{n='Duplicates';e={$_.count}}
    if ($GroupDice.Duplicates -contains 3 -or $GroupDice.Duplicates -contains 4 -or $GroupDice.Duplicates -contains 5 ) {
      $tbox_3kind.Text = 0 + $tbox_dice1.Text + $tbox_dice2.Text + $tbox_dice3.Text + $tbox_dice4.Text + $tbox_dice5.Text
    }
    else {$tbox_3kind.Text = 0}
    Clear-Dice
    Add-TopTotal
    Add-GrandTotal
    Test-EndGame
  }
})
$tbox_4kind.Add_Click({
  if ($Script:RollCount -ge 1 -and -not $tbox_4kind.Text) {
    $GroupDice = $Script:AllDice | Group-Object | Select-Object -Property *,@{n='Duplicates';e={$_.count}}
    if ($GroupDice.Duplicates -contains 4 -or $GroupDice.Duplicates -contains 5 ) {
      $tbox_4kind.Text = 0 + $tbox_dice1.Text + $tbox_dice2.Text + $tbox_dice3.Text + $tbox_dice4.Text + $tbox_dice5.Text
    }
    else {$tbox_4kind.Text = 0}
    Clear-Dice
    Add-TopTotal
    Add-GrandTotal
    Test-EndGame
  }
})
$tbox_fullhouse.Add_Click({
  if ($Script:RollCount -ge 1 -and -not $tbox_fullhouse.Text) {
    $GroupDice = $Script:AllDice | Group-Object | Select-Object -Property *,@{n='Duplicates';e={$_.count}}
    if ($GroupDice.Duplicates -contains 3 -and $GroupDice.Duplicates -contains 2 ) {
      $tbox_fullhouse.Text = 25
    }
    else {$tbox_fullhouse.Text = 0}
    Clear-Dice
    Add-TopTotal
    Add-GrandTotal
    Test-EndGame
  }
})
$tbox_smstraight.Add_Click({
  if ($Script:RollCount -ge 1 -and -not $tbox_smstraight.Text) {
    $GroupDice = $Script:AllDice | Group-Object | Select-Object -Property *,@{n='Duplicates';e={$_.count}}
    if (($Script:AllDice -contains 1 -and $Script:AllDice -contains 2 -and $Script:AllDice -contains 3 -and $Script:AllDice -contains 4) -or
       ($Script:AllDice -contains 2 -and $Script:AllDice -contains 3 -and $Script:AllDice -contains 4 -and $Script:AllDice -contains 5) -or
       ($Script:AllDice -contains 3 -and $Script:AllDice -contains 4 -and $Script:AllDice -contains 5 -and $Script:AllDice -contains 6) ) {
      $tbox_smstraight.Text = 30
    }
    else {$tbox_smstraight.Text = 0}
    Clear-Dice
    Add-TopTotal
    Add-GrandTotal
    Test-EndGame
  }
})
$tbox_lgstraight.Add_Click({
  if ($Script:RollCount -ge 1 -and -not $tbox_lgstraight.Text) {
    $GroupDice = $Script:AllDice | Group-Object | Select-Object -Property *,@{n='Duplicates';e={$_.count}}
    if ($GroupDice.Duplicates -notcontains 2 -and $GroupDice.Duplicates -notcontains 3 -and $GroupDice.Duplicates -notcontains 4 -and $GroupDice.Duplicates -notcontains 5 ) {
      $tbox_lgstraight.Text = 40
    }
    else {$tbox_lgstraight.Text = 0}
    Clear-Dice
    Add-TopTotal
    Add-GrandTotal
    Test-EndGame
  }
})
$tbox_yahtzee.Add_Click({
  if ($Script:RollCount -ge 1 -and -not $tbox_yahtzee.Text) {
    $Same = $Script:AllDice | Group-Object | Select-Object -Property *,@{n='Duplicates';e={$_.count}}
    if ($Same.Duplicates -eq 5) {$tbox_yahtzee.Text = 50}
    else {$tbox_yahtzee.Text = 0; $tbox_yahtzeebonus.Text = 0}
    Clear-Dice
    Add-TopTotal
    Add-GrandTotal
    Test-EndGame
  }  
})
$tbox_yahtzeebonus.Add_Click({
  if ($Script:RollCount -ge 1 -and -not $tbox_yahtzeebonus.Text) {
    $Same = $Script:AllDice | Group-Object | Select-Object -Property *,@{n='Duplicates';e={$_.count}}
    if ($Same.Duplicates -eq 5 -and $tbox_yahtzee.Text -eq 50) {$tbox_yahtzeebonus.Text = 100}
    else {$tbox_yahtzeebonus.Text = 0}
    Clear-Dice
    Add-TopTotal
    Add-GrandTotal
    Test-EndGame
  }
})
$tbox_chance.Add_Click({
  if ($Script:RollCount -ge 1 -and -not $tbox_chance.Text) {
    $tbox_chance.Text = 0 + $tbox_dice1.Text + $tbox_dice2.Text + $tbox_dice3.Text + $tbox_dice4.Text + $tbox_dice5.Text
    Clear-Dice
    Add-TopTotal
    Add-GrandTotal
    Test-EndGame
  }
})


$tbox_dice1.Add_Click({
  if ($Script:RollCount -lt 3) {
    if ($tbox_dice1.BackColor -ne 'Red' -and $tbox_dice1.text) {$tbox_dice1.BackColor = 'Red'}
    else {$tbox_dice1.BackColor = 'White'}
  }
})
$tbox_dice2.Add_Click({  
  if ($Script:RollCount -lt 3) {
    if ($tbox_dice2.BackColor -ne 'Red' -and $tbox_dice2.text) {$tbox_dice2.BackColor = 'Red'}
    else {$tbox_dice2.BackColor = 'White'}
  }
})
$tbox_dice3.Add_Click({  
  if ($Script:RollCount -lt 3) {
    if ($tbox_dice3.BackColor -ne 'Red' -and $tbox_dice3.text) {$tbox_dice3.BackColor = 'Red'}
    else {$tbox_dice3.BackColor = 'White'}
  }
})
$tbox_dice4.Add_Click({
  if ($Script:RollCount -lt 3) {
    if ($tbox_dice4.BackColor -ne 'Red' -and $tbox_dice4.text) {$tbox_dice4.BackColor = 'Red'}
    else {$tbox_dice4.BackColor = 'White'}
  }
})
$tbox_dice5.Add_Click({
  if ($Script:RollCount -lt 3) {
    if ($tbox_dice5.BackColor -ne 'Red' -and $tbox_dice5.text) {$tbox_dice5.BackColor = 'Red'}
    else {$tbox_dice5.BackColor = 'White'}
  }
})
$butt_rollall.Add_Click({
  if ($Script:RollCount -lt 3) {
    $tbox_dice1.text = Invoke-DiceRoll
    $tbox_dice2.text = Invoke-DiceRoll
    $tbox_dice3.text = Invoke-DiceRoll
    $tbox_dice4.text = Invoke-DiceRoll
    $tbox_dice5.text = Invoke-DiceRoll
    $tbox_dice1.BackColor = 'White'
    $tbox_dice2.BackColor = 'White'
    $tbox_dice3.BackColor = 'White'
    $tbox_dice4.BackColor = 'White'
    $tbox_dice5.BackColor = 'White'
    $Script:RollCount++
    $tbox_rollcount.Text = $Script:RollCount
    $Script:AllDice = $tbox_dice1.text,$tbox_dice2.text,$tbox_dice3.text,$tbox_dice4.text,$tbox_dice5.text
  }
})
$butt_rollselected.Add_Click({  
  $AnyRolled = $false
  if ($Script:RollCount -lt 3) {
    if ($tbox_dice1.BackColor -eq 'Red' -and $tbox_dice1.text ) {
      $tbox_dice1.BackColor = 'White'
      $tbox_dice1.Text = Invoke-DiceRoll
      $AnyRolled = $true
    }
    if ($tbox_dice2.BackColor -eq 'Red' -and $tbox_dice2.text) {
      $tbox_dice2.BackColor = 'White'
      $tbox_dice2.Text = Invoke-DiceRoll
      $AnyRolled = $true
    }
    if ($tbox_dice3.BackColor -eq 'Red' -and $tbox_dice3.text) {
      $tbox_dice3.BackColor = 'White'
      $tbox_dice3.Text = Invoke-DiceRoll
      $AnyRolled = $true
    }
    if ($tbox_dice4.BackColor -eq 'Red' -and $tbox_dice4.text) {
      $tbox_dice4.BackColor = 'White'
      $tbox_dice4.Text = Invoke-DiceRoll
      $AnyRolled = $true
    }
    if ($tbox_dice5.BackColor -eq 'Red' -and $tbox_dice5.text) {
      $tbox_dice5.BackColor = 'White'
      $tbox_dice5.Text = Invoke-DiceRoll
      $AnyRolled = $true
    }
    if ($AnyRolled -eq $true) {
      $Script:RollCount++
      $tbox_rollcount.Text = $Script:RollCount
      $Script:AllDice = $tbox_dice1.text,$tbox_dice2.text,$tbox_dice3.text,$tbox_dice4.text,$tbox_dice5.text
    }
  }
})
$butt_EndGame.Add_Click({
  $Form.Close()  
  $Form.Dispose()
})

#region Logic 

#endregion

[void]$Form.ShowDialog()