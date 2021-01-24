#COMPILE EXE
#DIM ALL
#DEBUG ERROR ON


' include the common display library
#INCLUDE "win32api.inc"
#INCLUDE "..\Libraries\CommonDisplay.inc"
'
FUNCTION PBMAIN () AS LONG
' the main PB function that is the first to be executed
  funPrepOutput("For Next Loops",0,0,40,120)
  '
  funLog("Walk through on For Next Loops")
  '
  DIM a_lngData(1 TO 6) AS LONG
  ARRAY ASSIGN a_lngData() = 10,12,15,67,7,300
  '
  LOCAL lngRecord AS LONG
  LOCAL lngData AS LONG
  LOCAL lngTotal AS LONG
  '
  FOR lngRecord = 1 TO 6 STEP 1
    lngData = a_lngData(lngRecord)
    '
    'if lngData > 20 then exit for
    IF lngData = 67 THEN ITERATE FOR
    '
    funlog "Record " & FORMAT$(lngRecord) & "= " & _
           FORMAT$(lngData)
    lngTotal = lngTotal + lngData
  NEXT lngRecord
  '
  funlog "Total = " & FORMAT$(lngTotal)
  '
  funWait()
  '
END FUNCTION
