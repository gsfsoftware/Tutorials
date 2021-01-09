#COMPILE EXE
#DIM ALL
#DEBUG ERROR ON
'
#TOOLS OFF
'
' include the common display library
#INCLUDE "win32api.inc"
#INCLUDE "..\Libraries\CommonDisplay.inc"
#INCLUDE "..\Libraries\PB_FileHandlingRoutines.inc"
'

FUNCTION PBMAIN () AS LONG
' the main PB function that is the first to be executed
  funPrepOutput("Min & Max commands",0,0,40,100)
  '
  funLog("Min & Max commands")
  '
  LOCAL lngOutput AS LONG
  LOCAL strOutput AS STRING
  '
  lngOutput = MIN(10,15,20,4,6,2,1)
  '
  funlog("Output is " & FORMAT$(lngOutput))
  '
  LOCAL lngA, lngB, lngC AS LONG
  lngA = 45
  lngB = 3
  lngC = 12
  '
  lngOutput = MIN(lngA,lngB,lngC)
  funLog("Output is " & FORMAT$(lngOutput))
  '
  strOutput = FORMAT$(MIN(lngA,lngB,lngC,0.1#))
  funLog("Output is " & strOutput)
  '
  DIM alngData(1 TO 4) AS LONG
  ARRAY ASSIGN alngData() = 34,3,12,0
  '
  strOutput = FORMAT$(MIN&(alngData(1), alngData(2), _
                          alngData(3),alngData(4)))
  funLog("Output is " & strOutput)
  '
  DIM astrData(1 TO 5) AS STRING
  ARRAY ASSIGN astrData() = "Apple","pear","cherry", "banana","kiwi"
  '
  strOutput = MIN$(astrData(1), astrData(2), _
                   astrData(3),astrData(4),astrData(5) )
  funLog("Output is " & strOutput)
  '
  funWait()
  '
END FUNCTION
'
