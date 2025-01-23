#COMPILE EXE
#DIM ALL
#DEBUG ERROR ON
'
#TOOLS OFF
'
' Demonstrate short circuit evaluation
' where AND/OR are used as boolean operators
' rather than bitwise operators
'
' include the common display library
#INCLUDE "win32api.inc"
#INCLUDE "CommonDisplay.inc"
'
FUNCTION PBMAIN () AS LONG
' the main PB function that is the first to be executed
   funPrepOutput("Conditional Code",0,0,40,120)
  '
  funLog("Conditional Code")
  '
  LOCAL strResult AS STRING     ' result of the processing
  LOCAL lngValue AS LONG        ' value to pass to check functions
  lngValue = 2
  '
  LOCAL qTimer AS QUAD          ' clock cycle timer for duration
  ' run the first check
  TIX qTimer
  '
  strResult = ""
  funRunFirstCheck(lngValue, strResult)
  '
  TIX END qTimer
  strResult = "First Check -> " & strResult & $CRLF & _
              FORMAT$(qTimer,"#,###") & $CRLF
              '
  '
  funLog(strResult)
  '
  ' run the second check
  TIX qTimer
  '
  strResult = ""
  funRunSecondCheck(lngValue, strResult)
  '
  TIX END qTimer
  strResult = "Second Check -> " & strResult & $CRLF & _
              FORMAT$(qTimer,"#,###") & $CRLF
              '
  funLog(strResult)
  '
  funWait()
  '
END FUNCTION
'
FUNCTION funRunSecondCheck(lngValue AS LONG, _
                           strResult AS STRING) AS LONG
' test the value and run process
  '
  IF ISTRUE lngValue > 4 AND ISTRUE funProcess()  THEN
  ' return the result to the calling function
    strResult = "TRUE - value > 4"
  ELSE
    strResult = "FALSE - value <= 4"
  END IF
END FUNCTION
'
FUNCTION funRunFirstCheck(lngValue AS LONG, _
                          strResult AS STRING) AS LONG
' test the value and run process
  IF ISTRUE funProcess() AND ISTRUE lngValue > 4 THEN
  ' return the result to the calling function
    strResult = "TRUE - value > 4"
  ELSE
    strResult = "FALSE - value <= 4"
  END IF
  '
END FUNCTION
'
FUNCTION funProcess() AS LONG
' simulate a process performing a complex calculation
  SLEEP 1000  ' do nothing for 1 sec
  FUNCTION = %TRUE
  '
END FUNCTION
