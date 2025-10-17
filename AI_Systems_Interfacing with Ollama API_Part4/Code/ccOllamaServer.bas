#COMPILE EXE
#DIM ALL
#INCLUDE "win32api.inc"
' Ollama server app
' listen for incoming requests
' using UDP
'
GLOBAL g_strThisServer AS STRING ' name of this computer
GLOBAL g_lngIP AS LONG           ' ip address of this computer
GLOBAL g_hUDP AS LONG            ' handle for UDP connection
%UPort = 16010                   ' port number for UDP connection
'
FUNCTION PBMAIN () AS LONG
'
  LOCAL strRequest AS STRING   ' request to be processed
  '
  g_strThisServer = funPCComputerName ' set the server name
  CON.CAPTION$= "UDP Ollama Server"
  CON.COLOR 10,0
  CON.LOC = 20, 20
  CON.SCREEN = 30,60
  '
  HOST ADDR TO g_lngIP
  g_hUDP = FREEFILE
  UDP OPEN PORT %UPort AS g_hUDP TIMEOUT 60000
  IF ERR THEN BEEP : EXIT FUNCTION
  '
  CON.STDOUT "Listening for broadcasts to " & _
        mDottedIP(g_lngIP) & ":" & _
        FORMAT$(%UPort) & "..."
        '
  DO
    strRequest = ""
    funProcessRequests(strRequest)
    IF strRequest = "EXIT" THEN
    ' shutdown requested
      EXIT LOOP
    END IF
    '
    SLEEP 100
    '
  LOOP
  ' exit requested
  CLOSE #g_hUDP
  SLEEP 5000
  '
END FUNCTION
'
FUNCTION funPCComputerName() AS STRING
' return the computer name
  FUNCTION = ENVIRON$("COMPUTERNAME")
'
END FUNCTION
'
MACRO FUNCTION mDottedIP(ip)
' return the IP address is readable format
  MACROTEMP x
  LOCAL x AS BYTE PTR
  x = VARPTR(ip)
END MACRO = USING$("#_.#_.#_.#", @x, @x[1], @x[2], @x[3])
'
FUNCTION funProcessRequests(strRequest AS STRING) AS LONG
' Start listening to the UDP/IP port
' where strRequest is the Request received
  LOCAL Buffer AS STRING      ' UDP data received
  LOCAL strData AS STRING     ' Data received
  LOCAL ipAddr AS LONG        ' IP address of sending machine
  LOCAL ipPort AS LONG        ' UDP Port of sending machine to reply to
  LOCAL strTargetServer AS STRING  ' target server name
  '
  ERRCLEAR
  UDP RECV #g_hUDP, FROM ipAddr, ipPort, Buffer
   '
  strTargetServer = UCASE$(PARSE$(Buffer,"|",1))
    '
  IF strTargetServer <> g_strThisServer THEN
  ' not intended for this computer
    EXIT FUNCTION
  ELSE
    CON.STDOUT "Received from " & mDottedIP(ipAddr)
  END IF
  '
  strRequest = UCASE$(PARSE$(Buffer,"|",2))
  '
  IF ERR THEN EXIT FUNCTION
  '
  CON.STDOUT strRequest & " Received"
  '
  SELECT CASE strRequest
    CASE "QUERY"
    ' run a query
      UDP SEND #g_hUDP, AT ipAddr, ipPort," ### ACCEPTED ###"
      ' run the query - add to the queue to run
      funRunAQuery(Buffer)
      '
    CASE "EXIT"
    ' shut down the server
      UDP SEND #g_hUDP, AT ipAddr, ipPort," ### EXITING ###"
      '
    CASE ELSE
    ' anything else
      UDP SEND #g_hUDP, AT ipAddr, ipPort,"### NOT ACCEPTED ###"
      '
  END SELECT
  '
END FUNCTION
'
FUNCTION funRunAQuery(strBuffer AS STRING) AS LONG
' run the query
  CON.STDOUT strBuffer
'
END FUNCTION
