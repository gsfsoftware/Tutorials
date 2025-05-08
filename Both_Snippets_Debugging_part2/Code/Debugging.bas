#COMPILE EXE
#DIM ALL
#DEBUG ERROR ON
'
#TOOLS ON        ' tools OFF turns off the
                 ' TRACE, PROFILE, and CALLSTK commands
                 ' if they exist in your code
'
' The last video we looked at
' 1) Compile time errors
' 2) The use of funcName$ and logging
' 3) Saving the CALLSTK
' 4) The use of the Profile command
'
' In this video we will look at
' 1) Trace command to generate a trace file
' 2) Compile and Debug
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
  funStartProcess()
  '
  funWait()
  '
END FUNCTION
'
FUNCTION funStartProcess() AS LONG
' run the first process
  '
  LOCAL lngValue AS LONG
  LOCAL lngLoop AS LONG
  lngValue = 100
  '
  ' name the Trace file
  ' if no path specified then the file is created in same
  ' folder as the EXE
  TRACE NEW "Trace_file.txt"
  ' turn Tracing on
  TRACE ON
  '
  funLog(FUNCNAME$) ' use funcName$ to extract name of
  '                 ' function or subroutine being executed
  FOR lngLoop = 1 TO 10
    ' turn Tracing on
    TRACE ON
    funSecondProcess(lngValue,lngLoop)

  NEXT lngLoop
  '
  ' turn off the tracing
  TRACE OFF
  ' close down the trace file
  TRACE CLOSE
  '
END FUNCTION
'
FUNCTION funSecondProcess(lngValue AS LONG, _
                          lngLoop AS LONG) AS LONG
' run the second process
  LOCAL lngC AS LONG
  '
  ' turn off the tracing
  TRACE OFF
  funLog(FUNCNAME$)
  '
  ' turn on the tracing
  TRACE ON
  ' print to the trace file
  TRACE PRINT "Value = " & FORMAT$(lngValue)
  '
  FOR lngC = 1 TO 5
  ' call the third process 5 times
    funThirdProcess(lngC)
  NEXT lngC
  '
  TRACE OFF
  '
END FUNCTION
'
FUNCTION funThirdProcess(lngC AS LONG) AS LONG
' run the third process
  SLEEP 200
  LOCAL lngF AS LONG
  LOCAL lngLoop AS LONG
  '
  FOR lngLoop = 1 TO 5
    lngF = lngF + lngLoop
  NEXT lngF
  '
END FUNCTION
