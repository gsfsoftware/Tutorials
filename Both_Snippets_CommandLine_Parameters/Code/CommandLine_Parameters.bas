#COMPILE EXE
#DIM ALL
#DEBUG ERROR ON
'
#TOOLS OFF
'
' include the common display library
#INCLUDE "win32api.inc"
#INCLUDE "CommonDisplay.inc"
#INCLUDE "PB_FileHandlingRoutines.inc"
#INCLUDE "PB_Shell.inc"
#INCLUDE "PB_commandLine.inc"
'

FUNCTION PBMAIN () AS LONG
' the main PB function that is the first to be executed
  funPrepOutput("Command line parameters",0,0,40,120)
  '
  funLog("Command line parameters")
  '
  LOCAL strParameters AS STRING
  LOCAL lngValue AS LONG
  lngValue = 99
  '
  strParameters = "Test 1,2,3," & FORMAT$(lngValue)
  strParameters = ".1234567890.1234567890.1234567890.1234567890.1234567890" & _
                  ".1234567890.1234567890.1234567890.1234567890.1234567890" & _
                  ".1234567890.1234567890.1234567890.1234567890.1234567890" & _
                  ".1234567890.1234567890.1234567890.1234567890.1234567890" & _
                  ".1234567890.1234567890.1234567890.1234567890.1234567890" & _
                  ".1234567890.1234567890.1234567890.1234567890.1234567890"
  '
  funLog("Tally of Blocks = " & FORMAT$(TALLY(strParameters,".")))
'  LOCAL lngProcessID AS LONG
'  lngProcessID = SHELL(EXE.PATH$ & "ccCalled_Application.exe " & strParameters,1)
'  '
'  IF lngProcessID > 0 THEN
'    funLog("Process launched")
'  ELSE
'    funLog("Unable to launch process")
'  END IF
  '
  ' now call the application using the funExecCmd function
  LOCAL strCmd AS STRING
  strCmd = EXE.PATH$ & "ccCalled_Application.exe "
  '
  strParameters =  "/FileNamePath#" & $DQ & "chart1.png" & $DQ & " " & _
           "/LEGEND#" & $DQ & "Console users*Windows users*Both" & $DQ & _
           "/DATA#" & $DQ & "55|40|5" & $DQ & " " & _
           "/TITLE#" & $DQ & "PB Windows v Console users" & $DQ
  '
  IF ISTRUE funExecCmd(strCMD & strParameters, %CREATE_NEW_CONSOLE) THEN
    funLog("ExecCmd Process launched")
  ELSE
    funLog("Unable to launch ExecCmd process")
  END IF
  '
  '
  funWait()
  '
END FUNCTION
'
