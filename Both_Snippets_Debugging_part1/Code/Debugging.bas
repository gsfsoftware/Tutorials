#COMPILE EXE
#DIM ALL
#DEBUG ERROR ON
'
'#TOOLS OFF      ' tools OFF turns off the
                 ' TRACE, PROFILE, and CALLSTK commands
                 ' if they exist in your code
'
' include the common display library
#INCLUDE "win32api.inc"
#INCLUDE "CommonDisplay.inc"
'
FUNCTION PBMAIN () AS LONG
' the main PB function that is the first to be executed
  funPrepOutput("Debugging",0,0,40,120)
  '
  funLog("Debugging")
  '
  ' compile time errors
  LOCAL lngR AS LONG
  LOCAL a,b AS LONG
  FOR lngR = 1 TO 10   ' has lngR not been declared?
  '
    IF a = 1 THEN      ' nested commands which are
      '                  missing END statements can be more
      IF b = 2 THEN    ' easily spotted by using code indenting
      ELSE
      END IF
      '
    ELSE
    END IF
    '
  NEXT lngR
  '
  funStartProcess()
  '
  funWait()
  '
  PROFILE "Profile.txt"    ' use profile to log performance
  '
END FUNCTION
'
FUNCTION funStartProcess() AS LONG
' run the first process
  SLEEP 100
  funLog(FUNCNAME$) ' use funcName$ to extract name of
  '                 ' function or subroutine being executed
  funSecondProcess()
'
END FUNCTION
'
FUNCTION funSecondProcess() AS LONG
' run the second process
  SLEEP 200
  funLog(FUNCNAME$)
  '
  funReportErrors("Error details")
'
END FUNCTION
'
FUNCTION funReportErrors(strData AS STRING) AS LONG
' common routine to report errors
  SLEEP 400
  funLog(strData)
  '
  ' report how we got here by saving the call stack
  CALLSTK "StackFrame.txt"
  '
END FUNCTION
