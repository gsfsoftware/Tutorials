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
FUNCTION PBMAIN () AS LONG
' the main PB function that is the first to be executed
  funPrepOutput("String Insert and Delete",0,0,40,120)
  '
  funLog("String Insert and Delete")
  '
  LOCAL strData AS STRING     ' original data
  '
  strData = "This is a short data string to " & $CRLF & _
            "be used on Monday, but not at the weekend"
            '
  LOCAL strNewData AS STRING  ' content to be amended
  LOCAL strTarget AS STRING   ' target string to be replaced
  strTarget = "Monday"        ' look for Monday
  LOCAL qTimer AS QUAD        ' Timer for CPU cycles
  LOCAL lngLoop AS LONG       ' loop number
  LOCAL lngLoops AS LONG      ' number of loops
  lngLoops = 1000             ' Total loops to execute
  '
  ' first using replace command
  TIX qTimer                  ' start the timer
  FOR lngLoop = 1 TO lngLoops
    strNewData = funReplaceDay_1(strData,strTarget,"Tuesday")
  NEXT lngLoop
  TIX END qTimer              ' end the timer
  '
  funPrintResult(strNewData,qTimer,lngLoops,"Replace")
  '
  ' now using Delete and Insert
  TIX qTimer
  FOR lngLoop = 1 TO lngLoops
    strNewData = funReplaceDay_2(strData,strTarget,"Tuesday")
  NEXT lngLoop
  TIX END qTimer
  '
  funPrintResult(strNewData,qTimer,lngLoops,"Delete/Insert")
  '
  ' now using string appending
  TIX qTimer
  FOR lngLoop = 1 TO lngLoops
    strNewData = funReplaceDay_3(strData,strTarget,"Tuesday")
  NEXT lngLoop
  TIX END qTimer
  '
  funPrintResult(strNewData,qTimer,lngLoops,"String Append")
  '
  funWait()
  '
END FUNCTION
'
FUNCTION funReplaceDay_3(strData AS STRING, _
                         strTarget AS STRING, _
                         strNewDay AS STRING) AS STRING
' replace the Day with another day - using appending
  LOCAL strAmendedData AS STRING
  '
  ' first get position
  LOCAL lngPosition AS LONG
  lngPosition = INSTR(strData,strTarget)
  '
  strAmendedData = LEFT$(strData,lngPosition -1) & _
                   strNewDay & MID$(strData,lngPosition + LEN(strTarget))
  '
  FUNCTION = strAmendedData
  '
END FUNCTION
'
FUNCTION funReplaceDay_2(strData AS STRING, _
                         strTarget AS STRING, _
                         strNewDay AS STRING) AS STRING
' replace the Day with another day - using delete and insert
  LOCAL strAmendedData AS STRING
  strAmendedData = strData
  ' first get position
  LOCAL lngPosition AS LONG
  lngPosition = INSTR(strAmendedData,strTarget)
  '
  ' delete from the string
  strAmendedData = STRDELETE$(strAmendedData,lngPosition, _
                              LEN(strTarget))
  '
  ' now insert new data
  strAmendedData = STRINSERT$(strAmendedData,strNewDay,lngPosition)
  '
  FUNCTION = strAmendedData
  '
END FUNCTION
'
FUNCTION funPrintResult(strData AS STRING, _
                        qTimer AS QUAD, _
                        lngLoops AS LONG, _
                        strType AS STRING) AS LONG
' print out the results
  funLog strData
  funLog FORMAT$(qTimer\lngLoops,"#,###") & " CPU cycles" & _
         " using " & strType
  funLog ""
  '
END FUNCTION
'
FUNCTION funReplaceDay_1(strData AS STRING, _
                         strTarget AS STRING, _
                         strNewDay AS STRING) AS STRING
' replace the Day with another day - using Replace
  LOCAL strAmendedData AS STRING
  strAmendedData = strData
  '
  REPLACE strTarget WITH strNewDay IN strAmendedData
  '
  FUNCTION = strAmendedData
  '
END FUNCTION
