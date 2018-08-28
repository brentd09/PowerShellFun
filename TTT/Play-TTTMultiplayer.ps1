[CmdletBinding()]
Param (
  $IPAddress,
  [int]$Port,
  [switch]$Primary
)

function receive-UDP {
  Param (
    $port = 20000
  )
  $endpoint = New-Object System.Net.IPEndPoint ([IPAddress]::Any, $port)
  Try {
      do {
          $socket = New-Object System.Net.Sockets.UdpClient $port
          $content = $socket.Receive([ref]$endpoint)
          $socket.Close()
          $DataTransferred = [Text.Encoding]::ASCII.GetString($content)
      } until ($content -ne $null)
  } Catch {
      "$($Error[0])"
  }
  $DataTransferred | ConvertFrom-Json
}
function Send-UDP {
  Param (
    [int] $Port , 
    $IP  
  )
    [string[]]$board = '---------'
  $hashtable = @{
    Master = 'X'
    Slave  = 'O'
    Board  = $board
  }
  $BoardObj = New-Object -TypeName psobject -Property $hashtable
  $SerializeBoard = $BoardObj | ConvertTo-Json
  
  $Address = [system.net.IPAddress]::Parse($IP) 
  
  # Create IP Endpoint 
  $End = New-Object System.Net.IPEndPoint $address, $port 
  
  # Create Socket 
  $Saddrf   = [System.Net.Sockets.AddressFamily]::InterNetwork 
  $Stype    = [System.Net.Sockets.SocketType]::Dgram 
  $Ptype    = [System.Net.Sockets.ProtocolType]::UDP 
  $Sock     = New-Object System.Net.Sockets.Socket $saddrf, $stype, $ptype 
  $Sock.TTL = 26 
  
  # Connect to socket 
  $sock.Connect($end) 
  
  # Create encoded buffer 
  $Enc     = [System.Text.Encoding]::ASCII 
  $Message = get-service -Name BITS | ConvertTo-Json
  $Buffer  = $Enc.GetBytes($SerializeBoard) 
  
  # Send the buffer 
  $Sent   = $Sock.Send($Buffer)
}

### Main Code ###
#################

If ($Primary -eq $true) {
  
}
else {

}