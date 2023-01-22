' BlockChainUDP.inc
'
GLOBAL g_strThisComputer AS STRING
GLOBAL ip AS LONG
GLOBAL hUdp AS LONG      ' handle for UDP port number
%UPort = 16030
'
FUNCTION funUDPopenPort() AS LONG
' open the UDP port
  HOST ADDR TO ip
  hUDP = FREEFILE
  UDP OPEN PORT %UPort AS hUDP TIMEOUT 10000
  IF ERR THEN
    BEEP
    EXIT FUNCTION
  ELSE
    FUNCTION = %TRUE
  END IF
  '
END FUNCTION
'
FUNCTION funPCComputerName() AS STRING
' return the computer name
  FUNCTION = ENVIRON$("COMPUTERNAME")
'
END FUNCTION
'
FUNCTION funUDPWhoIsActive() AS STRING
' Check what other computers are out there UDP/IP port
  LOCAL ipPort AS LONG        ' UDP Port of sending machine to reply to
  LOCAL strBroadcast AS STRING ' IP address to braodcast to
  LOCAL ipAddr AS LONG         ' IP address to send to
  LOCAL strBuffer AS STRING    ' UDP data received
  '
  #IF NOT %DEF(%Monitor)
    funLog("Polling for Nodes")
  #ENDIF
  '
  strBroadcast = "192.168.0.255"
  HOST ADDR strBroadcast TO ipAddr
  '
  ERRCLEAR
  UDP RECV #hUdp, FROM ipAddr, ipPort, strBuffer
  '
  IF PARSE$(strBuffer,"|",1) = funPCComputerName() THEN
  ' ignore your own broadcasts
    strBuffer = ""
  END IF
  '
  FUNCTION = strBuffer
'
END FUNCTION
'
FUNCTION funDeactivateThisNode() AS LONG
' tell othe nodes this one is closing down
  LOCAL strBroadcast AS STRING ' IP address to broadcast to
  LOCAL ipAddr AS LONG         ' IP address to send to
  '
  funLog("Broadcasting Active")
  strBroadcast = "192.168.0.255"
  HOST ADDR strBroadcast TO ipAddr
  '
  UDP SEND #hUdp, AT ipAddr, %UPort,funPCComputerName & _
                             "|" & "### NOT ACTIVE ###"
'
END FUNCTION
'
FUNCTION funConfirmTransaction(strTransaction AS STRING) AS LONG
' confirm a transaction
  LOCAL strBroadcast AS STRING ' IP address to broadcast to
  LOCAL ipAddr AS LONG         ' IP address to send to
  '
  funLog("Broadcasting Active")
  strBroadcast = "192.168.0.255"
  HOST ADDR strBroadcast TO ipAddr
  '
  UDP SEND #hUdp, AT ipAddr, %UPort,funPCComputerName & "|" & _
                                    "### CONFIRM ###" & "|" & _
                                    strTransaction
'
END FUNCTION
'
FUNCTION funRaiseTransaction(strTransaction AS STRING) AS LONG
' raise a demo transaction
  LOCAL strBroadcast AS STRING ' IP address to broadcast to
  LOCAL ipAddr AS LONG         ' IP address to send to
  '
  funLog("Broadcasting Active")
  strBroadcast = "192.168.0.255"
  HOST ADDR strBroadcast TO ipAddr
  '
  UDP SEND #hUdp, AT ipAddr, %UPort,funPCComputerName & "|" & _
                                    "### TRANSACTION ###" & "|" & _
                                    strTransaction
'
END FUNCTION
'
FUNCTION funBroadcastWhoIam(strAssets AS STRING) AS LONG
' broadcast to the network
  LOCAL strBroadcast AS STRING ' IP address to broadcast to
  LOCAL ipAddr AS LONG         ' IP address to send to
  funLog "Broadcasting Active"
  '
  strBroadcast = "192.168.0.255"
  HOST ADDR strBroadcast TO ipAddr
  '
  UDP SEND #hUdp, AT ipAddr, %UPort,funPCComputerName & _
                             "|" & "### ACTIVE ###" & "|" & strAssets
  '
END FUNCTION
'
FUNCTION funUDPclosePort() AS LONG
' close the UDP port
  CLOSE #hUdp
  IF ERR THEN
    BEEP
    EXIT FUNCTION
  ELSE
    FUNCTION = %TRUE
  END IF
  '
END FUNCTION
