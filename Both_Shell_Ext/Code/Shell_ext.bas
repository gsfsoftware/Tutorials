#COMPILE EXE
#DIM ALL
#DEBUG ERROR ON


' include the common display library
#INCLUDE "win32api.inc"
#INCLUDE "..\Libraries\CommonDisplay.inc"
#INCLUDE "..\Libraries\PB_FileHandlingRoutines.inc"
#INCLUDE "..\Libraries\PB_shell.inc"
'
FUNCTION PBMAIN () AS LONG
' the main PB function that is the first to be executed
  funPrepOutput("Shell ext routines",0,0,40,120)
  '
  funLog("Walk through on extended Shelling")
  '
  funlog("Starting shell")
  LOCAL lngHandle AS LONG
  '
  'SHELL(ENVIRON$("COMSPEC") & " /C DIR *.* > List.txt")
  'funlog ("list file created")
  '
  'SHELL("Notepad.exe " & EXE.PATH$ & "List.txt",1)
  'funLog("all done")
  '
  LOCAL strCMD AS STRING
  strCMD = EXE.PATH$ & "ccShelledApp.exe"
  'shell(strCMD)
  IF ISTRUE funExecCmd(strCMD & "", %CREATE_NEW_CONSOLE) THEN
    funLog("Shelled successfully")
  ELSE
    funLog("Failed to shell")
  END IF
  '
  funWait()
  '
END FUNCTION
