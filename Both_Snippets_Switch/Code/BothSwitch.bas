#COMPILE EXE
#DIM ALL
#DEBUG ERROR ON
'
#TOOLS OFF
'
' include the common display library
#INCLUDE "win32api.inc"
#INCLUDE "..\Libraries\CommonDisplay.inc"
'
FUNCTION PBMAIN () AS LONG
' the main PB function that is the first to be executed
  funPrepOutput("Switch command",0,0,40,120)
  '
  funLog("Switch command")
  '
  LOCAL lngX AS LONG
  LOCAL lngChoice AS LONG
  '
  lngX = -1
  lngChoice = SWITCH&(funValue(lngX), 1, _
                      funValue(lngX), 2, _
                      funValue(lngX), 3)
  '
  funLog FORMAT$(lngChoice)
  '
  DIM a_lngValue(1 TO 5) AS LONG
  ARRAY ASSIGN a_lngValue() = 5,10,15,40,50
  '
  LOCAL lngPicked AS LONG
  lngPicked = 4
  LOCAL lngNumber AS LONG
  lngNumber = 5
  '
  funLog SWITCH$(a_lngValue(lngPicked) <=5, "Low", _
                 a_lngValue(lngPicked) <=10, "Medium", _
                 a_lngValue(lngPicked) <=40, "High", _
                 a_lngValue(lngPicked) >40,"Very high", _
                 lngNumber = 5,"Other Value")
  '
  funWait()
  '
END FUNCTION
'
FUNCTION funValue(lngNumber AS LONG) AS LONG
' increment and return a value
 INCR lngNumber
 '
 FUNCTION = lngNumber
 '
END FUNCTION
