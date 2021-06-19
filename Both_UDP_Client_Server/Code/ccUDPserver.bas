#COMPILE EXE
#DIM ALL

#INCLUDE "Win32api.inc"

GLOBAL g_strThisServer AS STRING
GLOBAL ip AS LONG
GLOBAL hUDP AS LONG
%UPort = 16010
'
FUNCTION funPCComputerName() AS STRING
' return the computer name
  FUNCTION = ENVIRON$("COMPUTERNAME")
'
END FUNCTION
'
FUNCTION PBMAIN () AS LONG
' run the server process
  LOCAL strRequest AS STRING
  '
  g_strThisServer = UCASE$(funPCComputerName()) ' set the server name
  CON.CAPTION$= g_strThisServer & " - UDP Server Testing"
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
    ELSE
    ' restore console colours
      CON.CAPTION$= g_strThisServer & " - UDP Server Testing"
      CON.COLOR 10,0
      CON.LOC = 20, 20
      CON.SCREEN = 30,60
      CON.CLS
      '
      CON.STDOUT "Listening for broadcasts to " & DottedIP(ip) & ":" & _
        FORMAT$(%UPort) & "..."
      '
    END IF
    SLEEP 100
  LOOP
  CLOSE #hUdp
  SLEEP 5000
'
END FUNCTION
'
FUNCTION funProcessRequests(strRequest AS STRING) AS LONG
' Start listening to the UDP/IP port
' where strRequest is the Request received
  LOCAL strBuffer AS STRING   ' UDP data received
  LOCAL ipAddr AS LONG        ' IP address of sending machine
  LOCAL ipPort AS LONG        ' UDP Port of sending machine to reply to
  LOCAL strTargetServer AS STRING  ' target server name
  LOCAL strOutput AS STRING   ' data being sent back
  LOCAL lngPid AS LONG        ' handle of remote running app
  LOCAL strAppToRun AS STRING ' name of app to run
  '
  ERRCLEAR
  UDP RECV #hUdp, FROM ipAddr, ipPort, strBuffer
  '
  IF strBuffer = "" THEN EXIT FUNCTION
  '
  strTargetServer = UCASE$(PARSE$(strBuffer,"|",1))
  CON.STDOUT "Received = " & strBuffer
  '
  IF strTargetServer <> g_strThisServer THEN
    UDP SEND #hUdp, AT ipAddr, ipPort, "### NOT ACCEPTED ###"
    EXIT FUNCTION
  END IF
  '
  strRequest = UCASE$(PARSE$(strBuffer,"|",2))
  '
  IF ERR THEN EXIT FUNCTION
  '
  CON.STDOUT strRequest & " Received"
  '
  SELECT CASE strRequest
    CASE "LIST"
      strOutput = funGetList()
      UDP SEND #hUdp, AT ipAddr, ipPort," ### ACCEPTED ###" & _
                                        $CRLF & strOutput
    CASE "EXIT"
      UDP SEND #hUdp, AT ipAddr, ipPort," ### EXITING ###"
    CASE ELSE
      IF PARSE$(strRequest,"|",1) = "RUN" THEN
        strAppToRun = PARSE$(strBuffer,"|",3)
        lngPid = SHELL(strAppToRun)
        UDP SEND #hUdp, AT ipAddr, ipPort," ### RUNNING " & _
                  FORMAT$(lngPid) & " ###"
        strRequest = "RUN"
      END IF
      '
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
'
FUNCTION funGetList() AS STRING
  LOCAL strData AS STRING
  '
  strData = BUILD$("apples",$CRLF,"oranges",$CRLF,"pears")
  FUNCTION = strData
  '
END FUNCTION
