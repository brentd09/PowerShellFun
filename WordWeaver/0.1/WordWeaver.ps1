$WordsFromInternet = Invoke-WebRequest -Uri 'https://www.wordgamedictionary.com/sowpods/download/sowpods.txt' -UseBasicParsing 
# $WordsFromInternet.Content