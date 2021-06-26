#COMPILE EXE
#DIM ALL
#DEBUG ERROR ON

' include the common display library
#INCLUDE "win32api.inc"
#INCLUDE "..\Libraries\CommonDisplay.inc"
#INCLUDE "..\Libraries\DateFunctions.inc"
'
FUNCTION PBMAIN () AS LONG
' the main PB function that is the first to be executed
  funPrepOutput("Date Libraries",0,0,40,120)
  '
  funLog("Walk through on Date Libraries")
  '
  LOCAL strDate AS STRING
  strDate = funUKDate()
  funlog strDate
  '
  funlog "Month name = " & funLongMonthName(MID$(strDate,4,2))
  '
  strDate = "30/13/2021"
  IF funIsDateValid_dd_MM_yyyy(strDate) THEN
    funLog strDate & " is Valid"
  ELSE
    funLog strDate & " is not Valid"
  END IF
  '
  funWait()
  '
END FUNCTION
