#COMPILE EXE
#DIM ALL
#DEBUG ERROR ON
'
#TOOLS OFF
'
' include the common display library
#INCLUDE "win32api.inc"
#INCLUDE "CommonDisplay.inc"
#INCLUDE "BlockChainUDP.inc"
'
%MaxNodes = 500              ' Total number of nodes
%LoopLimit = 10              ' limit on listening time
'
'
TYPE udtNodes                ' UDT to hold details of nodes
  WorkName AS STRING * 50    ' Name of computer
  Condition AS LONG          ' condition of node
END TYPE
'
ENUM Condition      ' Current condition of Node
  Active = 1        ' Active
  NotActive         ' Not active
END ENUM
'
GLOBAL uNodes() AS udtNodes  ' Array of Nodes details
GLOBAL g_hMonitor AS LONG    ' global thread handle
GLOBAL g_lngEnding AS LONG   ' flag to end the thread
'
'
FUNCTION PBMAIN () AS LONG
' the main PB function that is the first to be executed
  funPrepOutput("BlockChain demo",0,0,40,120)
  '
  funLog("BlockChain Demo")
  '
  RANDOMIZE TIMER   ' seed random number generator
  '
  funPrepNodeArray()     ' prep the global array
  '
  ' create a thread to check active nodes
  THREAD CREATE funMonitorThread(0) TO g_hMonitor
  '
  SLEEP 30000 ' wait 30 seconds
  '
  funWait()
  '
  ' deactivate this node
  funDeactivateThisNode()
  g_lngEnding = %TRUE    ' end the thread
  SLEEP 1000
  '
END FUNCTION
'
THREAD FUNCTION funMonitorThread(BYVAL hSocket AS LONG) AS LONG
' start and run the monitor thread
'
  LOCAL strMessage AS STRING
  LOCAL lngLoop AS LONG
  LOCAL strTransaction AS STRING
  '
  IF ISTRUE funUDPopenPort() THEN
    funLog "Listener Created" & $CRLF
    '
    DO UNTIL ISTRUE g_lngEnding
      funBroadcastWhoIam()
      funListActiveNodes()
      '
      strTransaction = "Demo Transaction"
      funRaiseTransaction(strTransaction)
      '
      FOR lngLoop = 1 TO %LoopLimit
      ' get messages from active nodes
        strMessage = funUDPWhoIsActive()
        '
        IF strMessage <> "" THEN
        ' received a message from an active node
          funLog(strMessage)
          '
          ' decide what to do with it
          SELECT CASE PARSE$(strMessage,"|",2)
            CASE "### ACTIVE ###"
            ' active message - update list
              funUpdateNodeArray(strMessage,"ACTIVE")
              '
            CASE "### NOT ACTIVE ###"
            ' deactivation of a node
              funUpdateNodeArray(strMessage,"NOT_ACTIVE")
              '
            CASE ELSE
            ' some other message?
          END SELECT
          '
        END IF
      NEXT lngLoop
      '
      SLEEP 10000
      '
    LOOP
    '
    funUDPclosePort
    '
  ELSE
    funLog("Unable to open UDP port")
  END IF
  '
END FUNCTION
'
FUNCTION funUpdateNodeArray(strMessage AS STRING, _
                            strState AS STRING) AS LONG
' update the list of Nodes
  LOCAL lngN AS LONG
  LOCAL lngEmpty AS LONG
  LOCAL strComputer AS STRING
  '
  strComputer = PARSE$(strMessage,"|",1)
  '
  funLog "Updating node array"
  '
  FOR lngN = 1 TO %MaxNodes
    IF lngEmpty = 0 THEN
      IF TRIM$(uNodes(lngN).WorkName) = "" THEN
        lngEmpty = lngN
      END IF
    END IF
    '
    IF TRIM$(uNodes(lngN).WorkName) = strComputer THEN
    ' this computer already in array
      SELECT CASE strState
        CASE "ACTIVE"
          uNodes(lngN).Condition = %Condition.Active
        CASE "NOT_ACTIVE"
          uNodes(lngN).Condition = %Condition.NotActive
      END SELECT
      EXIT FUNCTION
    END IF
    '
  NEXT lngN
  '
  ' computer not in array already
  ' so add it and make it active
  uNodes(lngEmpty).WorkName = strComputer
  '
  SELECT CASE strState
    CASE "ACTIVE"
      uNodes(lngN).Condition = %Condition.Active
    CASE "NOT_ACTIVE"
      uNodes(lngN).Condition = %Condition.NotActive
  END SELECT
  '
END FUNCTION
'
FUNCTION funListActiveNodes() AS LONG
' list all currently active nodes
  LOCAL lngN AS LONG
  '
  #IF %DEF(%PB_CC32)
    COLOR 7,-1
  #ENDIF
  '
  FOR lngN = 1 TO %MaxNodes
    IF uNodes(lngN).Condition = %Condition.Active THEN
      funLog("Node = " & TRIM$(uNodes(lngN).workname))
    END IF
  NEXT lngN
  '
  #IF %DEF(%PB_CC32)
    COLOR 10,-1
  #ENDIF
  '
END FUNCTION
'
FUNCTION funPrepNodeArray() AS LONG
' prepare the node array for use
  LOCAL lngN AS LONG
  '
  REDIM uNodes(1 TO %MaxNodes)
  '
  FOR lngN = 1 TO %MaxNodes
  ' set all nodes to not active and blank name
    PREFIX "uNodes(lngN)."
      WorkName = ""
      Condition = %Condition.NotActive
    END PREFIX
  NEXT lngN
  '
  FUNCTION = %TRUE
  '
END FUNCTION
'
