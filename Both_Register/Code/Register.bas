#COMPILE EXE
#DIM ALL
#DEBUG ERROR ON
'
#TOOLS OFF
'
'#register none

' include the common display library
#INCLUDE "win32api.inc"
#INCLUDE "..\Libraries\CommonDisplay.inc"

FUNCTION PBMAIN () AS LONG
' the main PB function that is the first to be executed
  #REGISTER NONE
  funPrepOutput("#Register",0,0,40,120)
  '
  funLog("#Register")
  '
  LOCAL lngR AS LONG
  REGISTER lngCount AS LONG
  LOCAL CycleCount AS QUAD
  '
  TIX CycleCount
  FOR lngR = 1 TO 10000
    INCR lngCount
  NEXT lngR
  TIX END CycleCount
  '
  funLog("Took " & FORMAT$(CycleCount,"#,###") & " clock Cycles")
  '
  funWait()
  '
END FUNCTION
'
