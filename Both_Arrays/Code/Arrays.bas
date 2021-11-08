#COMPILE EXE
#DIM ALL

' include the common display library
#INCLUDE "win32api.inc"
#INCLUDE "..\Libraries\CommonDisplay.inc"
'

'
FUNCTION PBMAIN () AS LONG
' the main PB function that is the first to be executed
  funPrepOutput("Arrays",0,0,40,80)
  '
  funLog("Walk through on Arrays ")
  '
  DIM lngArrayName(1 TO 10) AS LONG
  DIM strArrayName(1 TO 10) AS STRING
  LOCAL lngValue AS LONG
  lngValue = 99
  LOCAL lngElement AS LONG
  lngElement = 1
  '
  lngArrayName(lngElement) = lngValue
  strArrayName(lngElement) = "Some data"
  '
  funLog(FORMAT$(lngArrayName(1)))
  funLog(strArrayName(1))
  '
  REDIM PRESERVE lngArrayName(20) AS LONG
  DIM lngArrayNameDouble(1 TO 10) AS DOUBLE


  '
  funWait()
'
END FUNCTION
'
