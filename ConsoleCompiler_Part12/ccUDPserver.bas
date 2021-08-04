#COMPILE EXE
#DIM ALL

#INCLUDE "Win32api.inc"

GLOBAL strThisServer AS STRING
GLOBAL ip AS LONG
GLOBAL hUDP AS LONG
%UPort = 16001
'
FUNCTION PBMAIN () AS LONG
' run the server process
  LOCAL strRequest AS STRING
  '
  strThisServer = "QUAD004" ' set the server name
  CON.CAPTION$= "UDP Server Testing"
  CON.COLOR 10,0
  CON.LOC = 20, 20
  CON.SCREEN = 30,60
  '
  HOST ADDR TO ip
  hUDP = FREEFILE
  UDP OPEN PORT %UPort AS hUDP TIMEOUT 60000
  IF ERR THEN BEEP : EXIT FUNCTION
  '
  CON.STDOUT "Listening for broadcasts to " & DottedIP(ip) & ":" & _
        FORMAT$(%UPort) & "..."
  DO
    strRequest = ""
    funProcessRequests(strRequest)
    IF strRequest = "EXIT" THEN
      EXIT LOOP
    END IF
    SLEEP 100
  LOOP
  CLOSE #hUdp
  SLEEP 5000
'
END FUNCTION
'
FUNCTION funProcessRequests(strRequest AS STRING) AS STRING
' Start listening to the UDP/IP port
' where strRequest is the Request received
  LOCAL Buffer AS STRING      ' UDP data received
  LOCAL strData AS STRING     ' Data received
  LOCAL ipAddr AS LONG        ' IP address of sending machine
  LOCAL ipPort AS LONG        ' UDP Port of sending machine to reply to
  LOCAL strTargetServer AS STRING  ' target server name
  '
  ERRCLEAR
  UDP RECV #hUdp, FROM ipAddr, ipPort, Buffer
  '
  strTargetServer = UCASE$(PARSE$(Buffer,"|",1))
  CON.STDOUT "Received = " & Buffer
  '
  IF strTargetServer <> strThisServer THEN
    UDP SEND #hUdp, AT ipAddr, ipPort, "### NOT ACCEPTED ###"
    EXIT FUNCTION
  END IF
  '
  strRequest = UCASE$(PARSE$(Buffer,"|",2))
  '
  IF ERR THEN EXIT FUNCTION
  '
  CON.STDOUT strRequest & " Received"
  '
  SELECT CASE strRequest
    CASE "LIST"
      UDP SEND #hUdp, AT ipAddr, ipPort," ### ACCEPTED ###"
    CASE "EXIT"
      UDP SEND #hUdp, AT ipAddr, ipPort," ### EXITING ###"
    CASE ELSE
      UDP SEND #hUdp, AT ipAddr, ipPort,"### NOT ACCEPTED ###"
  END SELECT
  '
END FUNCTION
'
MACRO FUNCTION DottedIP(ip)
  MACROTEMP x
  LOCAL x AS BYTE PTR
  x = VARPTR(ip)
END MACRO = USING$("#_.#_.#_.#", @x, @x[1], @x[2], @x[3])
