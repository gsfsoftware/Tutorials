#COMPILE EXE
#DIM ALL
#DEBUG ERROR ON
'
#TOOLS ON
'
' include the common display library
#INCLUDE "win32api.inc"
#INCLUDE "CommonDisplay.inc"
'
FUNCTION PBMAIN () AS LONG
' the main PB function that is the first to be executed
  funPrepOutput("Profiling Apps",0,0,40,120)
  '
  funLog("Profiling Apps")
  '
  funStartProcessing()
  '
  funWait()
  '
  PROFILE "Profile.txt"
END FUNCTION
'
FUNCTION funStartProcessing() AS LONG
' start of processing
  funLog("Processing started")
  SLEEP 2000
  funStep_1()
END FUNCTION
'
FUNCTION funStep_1() AS LONG
  LOCAL lngR AS LONG
  SLEEP 2000
  '
  FOR lngR = 1 TO 10
    funStep_2()
  NEXT lngR
  '
END FUNCTION
'
FUNCTION funStep_2() AS LONG
  SLEEP 250
END FUNCTION
