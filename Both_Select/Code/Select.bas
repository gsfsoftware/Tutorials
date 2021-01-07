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
  funPrepOutput("Select command",0,0,40,120)
  '
  funLog("Select command")
  ' seed the random number generator
  RANDOMIZE TIMER
  '
  funSelectNumber()  ' select a number
  'funSelectString()  ' select a string
  '
  funWait()
  '
END FUNCTION
'
FUNCTION funSelectString() AS LONG
  LOCAL strA AS STRING
  LOCAL strB AS STRING
  LOCAL lngLoop AS LONG
  '
  strB = "G"
  '
  FOR lngLoop = 1 TO 5
    'strA = funGetLetter()
    'select case strA
    SELECT CASE funGetLetter()
      CASE "B" TO "F"
        funLog("B to F clause")
      CASE strB
        funLog("Value of strB=" & strB & " clause")
      CASE "F","T","Q" TO "U"
        funLog("F,T,Q TO U clause")
      CASE ELSE
        funLog("else clause")
    END SELECT
     funLog("")
    '
  NEXT lngLoop
  '
END FUNCTION
'
FUNCTION funSelectNumber() AS LONG
  LOCAL lngA AS LONG
  LOCAL lngB AS LONG
  LOCAL lngLoop AS LONG
  '
  lngB = 20
  '
  FOR lngLoop = 1 TO 5
    lngA = funGetNumber()
    '
    SELECT CASE lngA
      CASE IS 2 TO 10
        funLog("2 - 10 clause")
      CASE IS 11
        funLog("=11 clause")
      CASE 12 TO lngB
        funLog("12 - value of lngB=" & FORMAT$(lngB) & " clause")
      CASE 21,23,25,27 TO 40
        funLog("21,23,25,27 TO 40 clause")
      CASE ELSE
        funLog("Else clause")
    END SELECT
    '
    funLog("")
  NEXT lngLoop

END FUNCTION
'
FUNCTION funGetNumber() AS LONG
' return a number
  LOCAL lngNumber AS LONG
  lngNumber = RND(1,100)
  funLog("Number generated = " & FORMAT$(lngNumber))
  FUNCTION = lngNumber
'
END FUNCTION
'
FUNCTION funGetLetter() AS STRING
  LOCAL strLetter AS STRING
  strLetter = CHR$(RND(65,90))
  funLog("Letter generated = " & strLetter)
  FUNCTION = strLetter
END FUNCTION
