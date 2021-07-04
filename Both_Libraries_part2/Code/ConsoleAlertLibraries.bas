#COMPILE EXE
#DIM ALL
#DEBUG ERROR ON

' include the common display library
#INCLUDE "win32api.inc"
#INCLUDE "..\Libraries\CommonDisplay.inc"
'
#INCLUDE "..\Libraries\ConsoleAlerts.inc"
'
FUNCTION PBMAIN () AS LONG
' the main PB function that is the first to be executed
  funPrepOutput("Console alerts",0,0,40,120)
  '
  funLog("Walk through on Console alerts")
  '
  'funConsoleMsgWithWait("Paused to inform user")
  '
  'funSpeak("The system has failed, as the file cannot be loaded")
  '
  'funGraphicAlert("Window alert to user" & $CRLF & _
  '                "The system has failed")
  '
  'funGraphicAlert("Window alert to user" & $crlf & _
  '                "The system has failed",1)
  '
  funGraphicAlertWithWait("Window alert to user" & _
                          $CRLF & "The system has failed")
  '
  funLog("Continuing")
  '
  funWait()
  '
END FUNCTION
