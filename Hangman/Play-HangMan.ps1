#HANGMAN
$drop = "`n`n`n`n`n`n`n`n"; $base = "`t--+------------------"; $beam = "`t  +----------+"
$supwall = "`t  |/         |`n`t  |          O`n`t  |        "; $smlsupp = "`t  |/         |`n`t  |          "
$3nt = "`n`t  |`n`t  |`n`t  |"; $2nt = "`n`t  |`n`t  |"; $bod = "`n`t  |          |"; $bmsupp = $beam+"`n"+$supwall
$6nt = $3nt+$3nt; $bod3base = $bod+$3nt+"`n"+$base; $leggap = "`n`t  |         "
$bodleg = $bod+$leggap; $brace = "`n`t  |/"; $ntn = "`n`t  |`n"; $6ntb = $6nt+$ntn+$base

[array]$HangPic = @()
$HangPic += $drop+$base ; $HangPic += $6ntb; $HangPic += $beam+$6ntb; $HangPic += $beam+$brace+$6nt+"`n"+$base
$HangPic += $beam+$brace+"         |"+$6nt+"`n"+$base; $HangPic += $beam+"`n"+$smlsupp+"O`n`t  |"+$3nt+$ntn+$base
$HangPic += $bmsupp+"  |"+$bod3base; $HangPic += $bmsupp+" /|"+$bod3base; $HangPic += $bmsupp+" /|\"+$bod3base
$HangPic += $bmsupp+" /|\"+$bodleg+"/"+$2nt+"`n"+$base; $HangPic += $bmsupp+" /|\"+$bodleg+"/ \"+$2nt+"`n"+$base

$GameWord ='' ; $MaskedWord = '' ; $ChoiceString = '' ; $WrongGuess = 0
Clear-Host
"Please wait while I create my dictionary and choose a word for you to guess..."
$webDictSite = Invoke-WebRequest -Uri http://www-01.sil.org/linguistics/wordlists/english/wordlist/wordsEn.txt 
$Words = $webDictSite.Content -split "`n" | Where-Object {$_.length -ge 5 -and $_.length -le 10} 
$RandNum = Get-Random -Minimum 0 -Maximum ([Int]$Words.count); $GameWord = $Words[$RandNum] -replace "\s+",''
$MaskedWord = $GameWord -replace '\w','-'; $badChoice = $false

Clear-Host; write-host -ForegroundColor Yellow -BackgroundColor Black "`n   HANGMAN Powershell Style   `n"

"`n`t`t$MaskedWord`n"
Do {
    Do {
        Do {
            $Choice = Read-Host -Prompt 'Enter a single letter'
            if ($Choice.Length -ne 1 -or $Choice -notmatch "[a-z]") {$badChoice = $true}
            else {$badChoice = $false}
            $Choice = $Choice.ToCharArray()[0]
        } While ($badChoice)
        if ($ChoiceString.ToCharArray() -contains $Choice) {'Please Enter a letter you have not yet chosen'}
    } While  ($ChoiceString.ToCharArray() -contains $Choice)
    $ChoiceString = $ChoiceString + $Choice
    if ($GameWord.ToCharArray() -notcontains $Choice) {$WrongGuess++ }
    $MaskedWord = $GameWord -replace "[^$ChoiceString]",'-'
    Clear-Host
    write-host -ForegroundColor Yellow -BackgroundColor Black "`n   HANGMAN Powershell Style   `n"
    "`n`t`t$MaskedWord`n"
    if ($WrongGuess -ge 1) {$HangPic[$WrongGuess-1]}
    if ($WrongGuess -ge 11) { write-host -for Red -BackgroundColor Black "You are hung"; write-host -NoNewline "The word was "; write-host -ForegroundColor Yellow "$GameWord";  break }
    if ($MaskedWord.ToCharArray() -notcontains "-") {
    Write-Host -ForegroundColor Green -BackgroundColor black "You Guessed the word correctly`n`n`n`n"
    break
    }  
    $MaskedWord = $GameWord -replace "[^$ChoiceString]",'-'
} while  ($MaskedWord.ToCharArray() -contains '-' )