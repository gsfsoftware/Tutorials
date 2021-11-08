#COMPILE EXE
#DIM ALL

' include the common display library
#INCLUDE "win32api.inc"
#INCLUDE "..\Libraries\CommonDisplay.inc"
'
'
FUNCTION PBMAIN () AS LONG
' the main PB function that is the first to be executed
  funPrepOutput("UDTs",0,0,40,80)
  '
  funLog("Walk through on Subs and functions ")
  '
  LOCAL strValue AS STRING
  strValue = "This is some data"
  '
  funLog(funProcessTheData(strValue))
  '
  funWait()
'
END FUNCTION
'
SUB subProcessTheData(strInfo AS STRING)
' Process the data
  strInfo = strInfo & " ..more data"
  funLog(strInfo)
'
END SUB

FUNCTION funProcessTheData(strInfo AS STRING) AS STRING
' Process the data
  LOCAL strLocal AS STRING
  strLocal = strInfo
  strLocal = strLocal & " ..more extra data"
  funLog(strLocal)
  FUNCTION = strLocal
'
END FUNCTION
'
FASTPROC funCalc_4(BYVAL lngValue AS LONG) AS LONG
  STATIC lngR AS LONG
  '
  FOR lngR = 1 TO 100000
    INCR lngValue
  NEXT lngR
  '
END FASTPROC = lngValue
