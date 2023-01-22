'%Monitor   = -1          ' define if just monitoring
'                          and comment out if compiling the node
'                          application
#IF %DEF(%Monitor)
  #COMPILE EXE "BlockChainDemo_Monitor.exe"
#ELSE
  #COMPILE EXE
#ENDIF
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
%StartAssetCount = 100       ' number of assets at start
%NodeLoopCount = 100         ' number of tries to find a node to sell to
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
GLOBAL g_lngAssets AS LONG   ' Number of assets held
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
  ' prep number of assets at start
  g_lngAssets = %StartAssetCount
  '
  ' create a thread to check active nodes
  THREAD CREATE funMonitorThread(0) TO g_hMonitor
  '
  SLEEP 30000 ' wait 30 seconds
  '
  funWait()
  '
  ' deactivate this node
  #IF NOT %DEF(%Monitor)
  ' but only if this is not the monitoring appliction
    funDeactivateThisNode()
  #ENDIF
  '
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
  LOCAL strNode AS STRING
  '
  ' number of assets transferred to this node
  LOCAL lngAssetsReceived AS LONG
  '
  IF ISTRUE funUDPopenPort() THEN
    funLog "Listener Created" & $CRLF
    '
    DO UNTIL ISTRUE g_lngEnding
      #IF NOT %DEF(%Monitor)
      ' only compile these in if not monitoring
        funBroadcastWhoIam(FORMAT$(g_lngAssets))
        funListActiveNodes()
        '
        ' build up a transaction
        strTransaction = funBuild_A_Transaction()

        ' send that transaction ?
        IF strTransaction <> "" THEN
        ' we have a node to transact with
          funRaiseTransaction(strTransaction)
        END IF
        '
      #ENDIF
      '
      FOR lngLoop = 1 TO %LoopLimit
      ' get messages from active nodes
        strMessage = funUDPWhoIsActive()
        '
        IF strMessage <> "" THEN
        ' received a message from an active node
          #IF NOT %DEF(%Monitor)
            funLog(strMessage)
          #ELSE
          ' add the time when monitoring
            funLog(TIME$ & " " & strMessage)
          #ENDIF
          '
          ' decide what to do with it
          SELECT CASE PARSE$(strMessage,"|",2)
            CASE "### ACTIVE ###"
            ' active message - update list
              #IF NOT %DEF(%Monitor)
              ' only update if not monitoring
                funUpdateNodeArray(strMessage,"ACTIVE")
              #ENDIF
              '
            CASE "### NOT ACTIVE ###"
            ' deactivation of a node
              #IF NOT %DEF(%Monitor)
              ' only update if not monitoring
                funUpdateNodeArray(strMessage,"NOT_ACTIVE")
              #ENDIF
              '
            CASE "### TRANSACTION ###"
            ' incoming transaction
              #IF NOT %DEF(%Monitor)
              ' only handle if not monitoring
                IF PARSE$(strMessage,"|",3) = funPCComputerName() THEN
                ' transaction is for this node
                ' pick up number of assets
                  lngAssetsReceived = VAL(PARSE$(strMessage,"|",4))
                  ' add to this assets
                  g_lngAssets = g_lngAssets + lngAssetsReceived
                  '
                  ' now acknowledge the transfer back to the
                  ' node that sent it
                  strNode = PARSE$(strMessage,"|",1)
                  strTransaction = strNode & "|" & PARSE$(strMessage,"|",4)
                  funConfirmTransaction(strTransaction)
                END IF
                '
              #ENDIF
              '
            CASE "### CONFIRM ###"
            ' incoming confirmation
              #IF NOT %DEF(%Monitor)
              ' only handle if not monitoring
                IF PARSE$(strMessage,"|",3) = funPCComputerName() THEN
                ' confirmation is for this node
                  ' pick up number of assets
                  lngAssetsReceived = VAL(PARSE$(strMessage,"|",4))
                  ' subtract from this nodes list
                  g_lngAssets = g_lngAssets - lngAssetsReceived
                  '
                END IF
                '
              #ENDIF
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
FUNCTION funBuild_A_Transaction() AS STRING
' build a transaction and return the transaction string
  LOCAL lngAssetsToSell AS LONG
  LOCAL strNode AS STRING
  '
  ' first determine if we have some assets to sell
  IF g_lngAssets > 0 THEN
  ' at least 1 asset left
    lngAssetsToSell = RND(1,5)  ' set between 1 and 5
    '
    ' ensure assets sold are not > that this nodes has
    lngAssetsToSell = MIN(g_lngAssets,lngAssetsToSell)
    '
    ' now decide who to sell to
    strNode = funPick_An_Active_Node()
    '
    IF strNode = "" THEN
    ' no nodes available
      EXIT FUNCTION
    ELSE
    ' found a node - so build the transaction string
      FUNCTION = strNode & "|" & FORMAT$(lngAssetsToSell)
      EXIT FUNCTION
    '
    END IF
    '
  ELSE
  ' no assets left to sell
    FUNCTION = ""
  END IF
  '
END FUNCTION
'
FUNCTION funPick_An_Active_Node() AS STRING
' pick one of the other active nodes
  LOCAL lngLoopCount AS LONG
  LOCAL lngNode AS LONG
  LOCAL strThisComputer AS STRING
  '
  ' pick up this computers name
  strThisComputer = funPCComputerName
  '
  FOR lngLoopCount = 1 TO %NodeLoopCount
  ' look for another active node at random
    lngNode = RND(1,%MaxNodes)
    '
    IF uNodes(lngNode).Condition = %Condition.NotActive THEN
    ' ignore those that are not active
      ITERATE FOR
    END IF
    '
    IF TRIM$(uNodes(lngNode).WorkName) = strThisComputer THEN
    ' dont trade with yourself
      ITERATE FOR
    ELSE
    ' found a node - so return its name
      FUNCTION = TRIM$(uNodes(lngNode).WorkName)
      EXIT FUNCTION
    '
    END IF
    '
  NEXT lngLoopCount
  '
  FUNCTION = ""
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
