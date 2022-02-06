' UDPcomms.inc

GLOBAL g_strThisComputer AS STRING
GLOBAL g_strUDPServer AS STRING
GLOBAL ip AS LONG
GLOBAL hUdp AS LONG      ' handle for UDP port number
%UPort = 16020
'
FUNCTION funPCComputerName() AS STRING
' return the computer name
  FUNCTION = ENVIRON$("COMPUTERNAME")
'
END FUNCTION
'
FUNCTION funUDPopenPort() AS LONG
' open the UDP port
  HOST ADDR TO ip
  hUDP = FREEFILE
  UDP OPEN PORT %UPort AS hUDP TIMEOUT 60000
  IF ERR THEN
    BEEP
    EXIT FUNCTION
  ELSE
    FUNCTION = %TRUE
  END IF
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
'
MACRO FUNCTION DottedIP(ip)
  MACROTEMP x
  LOCAL x AS BYTE PTR
  x = VARPTR(ip)
END MACRO = USING$("#_.#_.#_.#", @x, @x[1], @x[2], @x[3])
'
FUNCTION funUDPLeaderListen() AS STRING
' Start listening to the UDP/IP port
  LOCAL strBuffer AS STRING   ' UDP data received
  LOCAL strStatus AS STRING   ' status
  LOCAL strSource AS STRING   ' Source worker name
  LOCAL ipAddr AS LONG        ' IP address of sending machine
  LOCAL ipPort AS LONG        ' UDP Port of sending machine to reply to
  LOCAL strTargetServer AS STRING  ' target server name
  LOCAL strOutput AS STRING   ' data being sent back
  LOCAL lngPid AS LONG        ' handle of remote running app
  LOCAL strAppToRun AS STRING ' name of app to run
  LOCAL o_strTask AS STRING   ' Name of task to execute
  LOCAL strMessage AS STRING  ' message to pass back
  ' NEW
  LOCAL strCore AS STRING     ' core number of Task worker
  '
  ERRCLEAR
  UDP RECV #hUdp, FROM ipAddr, ipPort, strBuffer
  '
  IF strBuffer = "" THEN EXIT FUNCTION
  ' pick up target computer name
  strTargetServer = UCASE$(PARSE$(strBuffer,"|",1))
  'CON.STDOUT "Received = " & strBuffer
  '
  IF strTargetServer <> g_strThisComputer THEN
  '  UDP SEND #hUdp, AT ipAddr, ipPort, "### NOT ACCEPTED ###"
    strMessage =  strBuffer & " Not Accepted"
    FUNCTION = strMessage
    EXIT FUNCTION
  END IF
  '
  ' where strBuffer = "LeaderName|WorkerName|Status|CoreNumber
  strSource = PARSE$(strBuffer,"|",2)
  strStatus = UCASE$(PARSE$(strBuffer,"|",3))
  strCore   = PARSE$(strBuffer,"|",4)
  '
  IF ERR THEN EXIT FUNCTION
  '
  'CON.STDOUT strRequest & " Received"
  '
  SELECT CASE strStatus
    CASE "ACTIVE"
    ' Worker is now active
      IF ISTRUE funNewTask(strSource, o_strTask,strCore) THEN
      ' send details of new task to Worker
        UDP SEND #hUdp, AT ipAddr, ipPort,"### TASK ###|" & o_strTask
        strMessage = strSource & "_" & strCore & " ACTIVE " & TIME$
      ELSE
      ' no task pending
        UDP SEND #hUdp, AT ipAddr, ipPort,"### ACCEPTED ###"
        strMessage = strSource & "_" & strCore & " ACTIVE " & TIME$
      END IF
      '
    CASE "PROCESSING"
    ' Worker is now processing
      IF ISTRUE funUpdateToProcessing(strSource,strCore) THEN
        UDP SEND #hUdp, AT ipAddr, ipPort,"### ACCEPTED ###"
      ELSE
        UDP SEND #hUdp, AT ipAddr, ipPort,"### NOT ACCEPTED ###"
      END IF
      '
    CASE "COMPLETED"
    ' Worker has now completed the task
      IF ISTRUE funUpdateToCompleted(strSource,strCore) THEN
        UDP SEND #hUdp, AT ipAddr, ipPort,"### ACCEPTED ###"
      ELSE
        UDP SEND #hUdp, AT ipAddr, ipPort,"### NOT ACCEPTED ###"
      END IF
    '
    CASE ELSE
    ' some other response
      strMessage =  strBuffer
    '  UDP SEND #hUdp, AT ipAddr, ipPort,"### NOT ACCEPTED ###"
  END SELECT
  '
  FUNCTION = strMessage & $CRLF
  '
END FUNCTION
'
FUNCTION funNewTask(strSource AS STRING, o_strTask AS STRING, _
                    strCore AS STRING) AS LONG
' is there a new task for this Worker?
'
END FUNCTION
'
FUNCTION funUpdateToProcessing(strSource AS STRING, _
                               strCore AS STRING) AS LONG
' update that this worker has started working on a task
'
END FUNCTION
'
FUNCTION funUpdateToCompleted(strSource AS STRING, _
                              strCore AS STRING) AS LONG
' update that this worker has completed a task
'
END FUNCTION
'
FUNCTION funQueryUDPServer(strQuery AS STRING) AS STRING
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
  strBuffer = g_strUDPServer & "|" & g_strThisComputer & "|" & strQuery
  #IF %DEF(%PB_CC32)
    CON.STDOUT "Sending to " & DottedIP(bip) & " -> " & strBuffer
  #ENDIF
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
