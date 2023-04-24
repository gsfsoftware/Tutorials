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
' add an icon
#RESOURCE ICON MainappIcon,"add.ico"
'
FUNCTION PBMAIN () AS LONG
' the main PB function that is the first to be executed
  funPrepOutput("Demo",0,0,40,120)
  '
  funLog("Demo")
  '
  funLog("Running application")

  '
  funWait()
  '
END FUNCTION
'
