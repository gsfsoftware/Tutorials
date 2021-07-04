' UDP_routines.inc

GLOBAL strThisServer AS STRING
GLOBAL ip AS LONG
GLOBAL hUDP AS LONG
%UPort = 16010

FUNCTION funOpenUDP() AS LONG
  strThisServer = "OCTAL"
  '
  ERRCLEAR
  HOST ADDR TO ip
  hUDP = FREEFILE
  UDP OPEN PORT %UPort AS hUDP TIMEOUT 60000
  IF ERR THEN
    CON.STDOUT "Error " & ERROR$
    EXIT FUNCTION
  ELSE
    CON.STDOUT "UDP Open"
    FUNCTION = %TRUE
  END IF
  '
END FUNCTION
'
FUNCTION funCloseUDP() AS LONG
  CON.STDOUT "UDP Closed"
  CLOSE #hUDP
  FUNCTION = %TRUE
END FUNCTION
'
FUNCTION funListenForRequests() AS LONG
  LOCAL strRequest AS STRING
  '
  CON.STDOUT "UDP Listening"
  DO
    strRequest = ""
    funProcessRequests(strRequest)
    IF strRequest = "EXIT" THEN
      EXIT LOOP
    END IF
    SLEEP 100
  LOOP
  '
  FUNCTION = %TRUE
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
  CON.STDOUT "Got Buffer " & Buffer & " from " & DottedIP(ipAddr)
  strTargetServer = UCASE$(PARSE$(Buffer,"|",1))
  '
  IF strTargetServer <> strThisServer THEN
    UDP SEND #hUdp, AT ipAddr, ipPort, "### NOT ACCEPTED ###"
    EXIT FUNCTION
  END IF
  '
  strRequest = UCASE$(PARSE$(Buffer,"|",2))
  strRequest = PARSE$(strRequest," ",1)
  ' "SUM 'Eye Colour'='BLUE'"
  IF ERR THEN EXIT FUNCTION
  '
  SELECT CASE strRequest
    CASE "SUM"
      UDP SEND #hUdp, AT ipAddr, ipPort,funSum(Buffer)
    CASE "COUNT"
    ' how many record are there
      UDP SEND #hUdp, AT ipAddr, ipPort,"Records = " & _
                             FORMAT$(UBOUND(a_strWork))
    '
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
FUNCTION funSum(Buffer AS STRING) AS STRING
  'Buffer = Octal|SUM 'Eye Colour'='BLUE'
  LOCAL strRequest AS STRING
  LOCAL strColumn AS STRING
  LOCAL strType AS STRING
  LOCAL strValue AS STRING
  LOCAL lngColumn AS LONG
  LOCAL lngR AS LONG
  LOCAL lngCount AS LONG
  '
  strRequest = PARSE$(Buffer,"|",2)
  ' SUM 'Eye Colour'='BLUE'
  strRequest = MID$(strRequest,5)
  ' 'Eye Colour'='BLUE'
  strColumn = PARSE$(strRequest, "'",2)
  strType = PARSE$(strRequest, "'",3)
  strValue = PARSE$(strRequest, "'",4)
  '
  lngColumn = funParseFind(a_strWork(0),$TAB,strColumn)
  '
  lngCount = 0
  FOR lngR = 1 TO UBOUND(a_strWork)
    IF LCASE$(PARSE$(a_strWork(lngR),$TAB, lngColumn)) _
             = LCASE$(strValue) THEN
      INCR lngCount
    END IF
    '
  NEXT lngR
  '
  FUNCTION = "Records = " & FORMAT$(lngCount)
  '
END FUNCTION
'
MACRO FUNCTION DottedIP(ip)
  MACROTEMP x
  LOCAL x AS BYTE PTR
  x = VARPTR(ip)
END MACRO = USING$("#_.#_.#_.#", @x, @x[1], @x[2], @x[3])
