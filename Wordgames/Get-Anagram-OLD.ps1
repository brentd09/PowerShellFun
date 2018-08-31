[CmdletBinding()]
Param (
  [Parameter(Mandatory=$true)]
  [string]$Letters
)
if ($Letters.Length -le 9) {
  $AnaAPI = Invoke-RestMethod -Uri "http://www.anagramica.com/all/:$Letters" -UseBasicParsing -Method Get
  [string[]]$Results = $AnaAPI.all  |  Where-Object {$_.length -ge 4} 
  foreach ($Result in $Results) {
    $ObjectProps = @{Words =$Result}
    New-Object -TypeName psobject -Property $ObjectProps
  }
}
else {
  Write-Warning -Message "This will only accept up to 9 letters"
}