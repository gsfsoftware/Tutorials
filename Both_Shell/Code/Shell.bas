#COMPILE EXE
#DIM ALL
#DEBUG ERROR ON

' include the common display library
#INCLUDE "win32api.inc"
#INCLUDE "..\Libraries\CommonDisplay.inc"
'
FUNCTION PBMAIN () AS LONG
' the main PB function that is the first to be executed
  funPrepOutput("Shell routines",0,0,40,120)
  '
  funLog("Walk through on Shell command")
  '
  funlog("Starting shell")
  LOCAL lngHandle AS LONG
  'lngHandle = shell("Notepad.exe",1)
  'funLog("Process ID = " & format$(lngHandle))
  '
  SHELL(ENVIRON$("COMSPEC") & " /C DIR *.* > List.txt")
  funlog ("list file created")
  '
  SHELL("Notepad.exe " & EXE.PATH$ & "List.txt",1)
  funLog("all done")
  '
  funWait()
  '
END FUNCTION
