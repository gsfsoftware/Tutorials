#COMPILE EXE
#DIM ALL

GLOBAL g_strUDPServer AS STRING
%UPort = 16010

FUNCTION PBMAIN () AS LONG
  LOCAL strResult AS STRING
  '
  g_strUDPServer = "quad004"
  '
  CON.CAPTION$= "UDP client Testing"
  CON.COLOR 6,0
  CON.LOC = 500, 20
  CON.SCREEN = 30,60
  '
  strResult = QueryUDPServer("LIST")
  CON.STDOUT strResult
  strResult = QueryUDPServer("RUN|ccRemoteApp.exe")
  CON.STDOUT strResult
  strResult = QueryUDPServer("EXIT")
  CON.STDOUT strResult
  '
  CON.STDOUT $CRLF & "Press any key to exit"
  WAITKEY$
  '
END FUNCTION
'
FUNCTION QueryUDPServer(strQuery AS STRING) AS STRING
'
  LOCAL ip     AS LONG      ' This machines IP address
  LOCAL bip    AS LONG      ' Broadcase IP address for this segment (class D)
  LOCAL hUdp   AS LONG      ' UDP file number
  LOCAL strBuffer AS STRING ' UDP data received
  LOCAL ipAddr AS LONG      ' IP address of sending machine
  LOCAL ipPort AS LONG      ' UDP Port of sending machine to reply to
  LOCAL t      AS SINGLE    ' Timer for reply monitoring
  LOCAL x      AS LONG      ' Counter
  '
  ' get the IP address
  HOST ADDR TO ip
  '
  HOST ADDR g_strUDPServer TO bip
  '
  ' open channel
  hUdp = FREEFILE
  UDP OPEN AS #hUdp TIMEOUT 5000
  IF ERR THEN
    EXIT FUNCTION
  END IF
  '
  strBuffer = g_strUDPServer & "|" & strQuery
  CON.STDOUT "Sending to " & DottedIP(bip) & " -> " & strBuffer
  '
  DO
    UDP SEND hUdp, AT bip, %UPort, strBuffer
    '
    t = TIMER
    WHILE ABS(TIMER - t) < 5
      ERRCLEAR
      UDP RECV #hUdp, FROM ipAddr, ipPort, strBuffer
      ' Ignore any timout or other errors
      IF ERR THEN ITERATE
      FUNCTION = strBuffer
      CLOSE #hUdp
      EXIT FUNCTION
      '
    WEND
    '
    INCR x
  LOOP WHILE x < 1
  '
  CLOSE #hUdp
  '
END FUNCTION


MACRO FUNCTION DottedIP(ip)
  MACROTEMP x
  LOCAL x AS BYTE PTR
  x = VARPTR(ip)
END MACRO = USING$("#_.#_.#_.#", @x, @x[1], @x[2], @x[3])
'
