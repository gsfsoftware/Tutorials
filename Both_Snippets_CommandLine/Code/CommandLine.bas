#COMPILE EXE
#DIM ALL
#DEBUG ERROR ON
'
#TOOLS OFF
'
' include the common display library
#INCLUDE "win32api.inc"
#INCLUDE "..\Libraries\CommonDisplay.inc"
#INCLUDE "..\Libraries\PB_FileHandlingRoutines.inc"
#INCLUDE "..\Libraries\PB_Shell.inc"
#INCLUDE "..\Libraries\PB_commandLine.inc"
'

FUNCTION PBMAIN () AS LONG
' the main PB function that is the first to be executed
  funPrepOutput("Command Line parameters",0,0,40,120)
  '
  funLog("Command Line parameters")
  '
  LOCAL strCommand AS STRING
  '
  strCommand = COMMAND$
  'funLog (strCommand)
  '
  LOCAL strFirst , strSecond AS STRING
  'strFirst = parse$(strCommand," ", 1)
  'strSecond = PARSE$(strCommand," ", 2)
  '
  funLog(strFirst & $CRLF & strSecond)
  '
  '/First#"SomeNewData" /Second#"SomeMoreData"
  strFirst = funReturnNamedParameterEXP("/FIRST#", _
                                       strCommand)
  strSecond = funReturnNamedParameterEXP("/Second#", _
                                       strCommand)
  LOCAL strThird AS STRING
  strThird = funReturnNamedParameterEXP("/Third#", _
                                        strCommand)
  '
  funLog("1st = " & strFirst & $CRLF & _
         "2nd = " & strSecond & $CRLF & _
         "3rd = " & strThird )
         '
  LOCAL strCmd AS STRING
  strCmd = "GenericPieChartGenerator.exe " & _
           "/FileNamePath#" & $DQ & EXE.PATH$ & _
                          "chart1.png" & $DQ & " " & _
           "/LEGEND#" & $DQ & "Console users*Windows users*Both" & $DQ & _
           "/DATA#" & $DQ & "55|40|5" & $DQ & " " & _
           "/TITLE#" & $DQ & "PB Windows v Console users" & $DQ
  funExecCmd strCMD & ""

  funWait()
  '
END FUNCTION
'
