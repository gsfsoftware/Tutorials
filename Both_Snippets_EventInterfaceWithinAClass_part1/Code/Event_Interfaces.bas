#COMPILE EXE
#DIM ALL
#DEBUG ERROR ON
'
#TOOLS OFF
'
' include the common display library
#INCLUDE "win32api.inc"
#INCLUDE "CommonDisplay.inc"
'
CLASS evClass AS EVENT
' Event class
  INTERFACE iStatus AS EVENT
    INHERIT IUNKNOWN
    '
    METHOD Started
    ' started method
      funLog("Started processing")
    END METHOD
    '
    METHOD Complete
    ' completion method
      funLog "Completed"
    END METHOD
    '
    METHOD Progressing(lngProgress AS LONG, _
                       lngTotal AS LONG)
    ' progressing method
      LOCAL lngPercent AS LONG
      lngPercent = (lngProgress/lngTotal) *100
      funLog "Progressing " & FORMAT$(lngPercent) & "%"
    END METHOD
    '
  END INTERFACE
  '
END CLASS
'
CLASS Processing
  INTERFACE iProcessing
    INHERIT IUNKNOWN
    '
    METHOD RunProcess
    ' start processing
      RAISEEVENT iStatus.Started()
      '
      SLEEP 1000
      LOCAL lngR AS LONG     ' current progress
      LOCAL lngTotal AS LONG ' completed progress
      '
      lngTotal = 4
      '
      FOR lngR = 1 TO lngTotal
        ' raise an event to report progress
        RAISEEVENT iStatus.Progressing(lngR,lngTotal)
        SLEEP 1000
      NEXT lngR
      SLEEP 1000
      '
      RAISEEVENT iStatus.Complete()
    END METHOD
    '
  END INTERFACE
  '
  ' Declare an event interface to be called by RaiseEvent by the server
  EVENT SOURCE iStatus
  '
END CLASS
'
FUNCTION PBMAIN () AS LONG
' the main PB function that is the first to be executed
  funPrepOutput("Event Interfaces within a class",0,0,40,120)
  '
  funLog("Event Interfaces within a class")
  '
  LOCAL oProcessing AS iProcessing ' object reference to iProcessing interface
  LOCAL oStatus AS iStatus         ' object reference to IStatus event Interface
  '
  oProcessing = CLASS "Processing" ' create the instance of Processing object
  oStatus = CLASS "evClass"        ' create the instance of Status object
  '
  ' Connect the event handler interface to the event source Interface
  EVENTS FROM oProcessing CALL oStatus
  '
  ' Call the RunProcess method in iProcessing Interface
  oProcessing.RunProcess
  '
  ' Disconnect the event handler interface from the event source Interface
  EVENTS END oStatus
  '
  funWait()
  '
END FUNCTION
'
