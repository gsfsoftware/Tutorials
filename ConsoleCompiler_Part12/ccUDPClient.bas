#COMPILE EXE
#DIM ALL

GLOBAL g_strUDPServer AS STRING
%UPort = 16001

FUNCTION PBMAIN () AS LONG
  LOCAL strResult AS STRING
  '
  g_strUDPServer = "QUAD004"
  '
  CON.CAPTION$= "UDP client Testing"
  CON.COLOR 6,0
  CON.LOC = 1000, 20
  CON.SCREEN = 30,60
  '
  strResult = QueryUDPServer("LIST")
  CON.STDOUT strResult
  strResult = QueryUDPServer("TV")
  CON.STDOUT strResult
  strResult = QueryUDPServer("EXIT")
  CON.STDOUT strResult
  '
  WAITKEY$
  '
END FUNCTION
'
FUNCTION QueryUDPServer(strQuery AS STRING) AS STRING
'
  LOCAL ip     AS LONG      ' This machines IP address
  LOCAL bip    AS LONG      ' Broadcase IP address for this segment (class D)
  LOCAL hUdp   AS LONG      ' UDP file number
  LOCAL Buffer AS STRING    ' UDP data received
  LOCAL ipAddr AS LONG      ' IP address of sending machine
  LOCAL ipPort AS LONG      ' UDP Port of sending machine to reply to
  LOCAL t      AS SINGLE    ' Timer for reply monitoring
  LOCAL x      AS LONG      ' Counter
  LOCAL Op     AS STRING    ' Status text
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
  Buffer = g_strUDPServer & "|" & strQuery
  CON.STDOUT "Sending to " & DottedIP(bip) & " -> " & Buffer
  '
  DO
   ' We'll monitor replies for 5 seconds, then do another broadcast
    t = TIMER
    WHILE ABS(TIMER - t) < 5
      '
      ERRCLEAR
      UDP RECV #hUdp, FROM ipAddr, ipPort, Buffer
      '
      ' Ignore any timout or other errors
      IF ERR THEN ITERATE
      '
      ' We got one!  return the data (remote date)
      FUNCTION = Buffer
      CLOSE #hUdp
      EXIT FUNCTION
    WEND
  '
  INCR x
  LOOP WHILE x < 1
  '
  CLOSE #hUdp
  '
END FUNCTION
'
MACRO FUNCTION DottedIP(ip)
  MACROTEMP x
  LOCAL x AS BYTE PTR
  x = VARPTR(ip)
END MACRO = USING$("#_.#_.#_.#", @x, @x[1], @x[2], @x[3])
'
