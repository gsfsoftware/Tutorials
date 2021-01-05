#COMPILE EXE
#DIM ALL
#DEBUG ERROR ON
'
#TOOLS OFF
'
' include the common display library
#INCLUDE "win32api.inc"
#INCLUDE "..\Libraries\CommonDisplay.inc"
'
FUNCTION PBMAIN () AS LONG
' the main PB function that is the first to be executed
  'funPrepOutput("Code Templates",0,0,40,120)
  '
  PREFIX "con."
    VIRTUAL = 40, 120  ' set the columns and rows for the console
    CAPTION$= "Our caption"  ' set the title of the console window
    COLOR 10,-1 ' make the text green and default background
    LOC = 0,0   ' set the screen location of the console
  END PREFIX

  funLog("Code Templates")
  ' place text on the current line in the console
  CON.STDOUT "Any text here"
  '
  CON.STDOUT "Press any key to exit"
  WAITKEY$   ' wait for any key to be pressed before continuing
  'funWait()
  '
END FUNCTION
'
