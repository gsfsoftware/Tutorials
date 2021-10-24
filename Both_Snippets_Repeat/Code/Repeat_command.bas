#COMPILE EXE
#DIM ALL
#DEBUG ERROR ON
'
#TOOLS OFF
'
' include the common display library
#INCLUDE "win32api.inc"
#INCLUDE "..\Libraries\CommonDisplay.inc"
#INCLUDE ONCE "..\Libraries\PB_Common_Strings.inc"
#INCLUDE "..\Libraries\PB_FileHandlingRoutines.inc"


FUNCTION PBMAIN () AS LONG
' the main PB function that is the first to be executed
  funPrepOutput("Repeat Command",0,0,40,120)
  '
  funLog("Repeat Command")
  '
  LOCAL strData AS STRING
  ' repeat one character 5 times
  strData = REPEAT$(5,"*")
  funLog strData & $CRLF
  '
  ' repeat one string of characters 5 times
  strData = REPEAT$(5,$DQ & $DQ & ",")
  funLog strData & $CRLF
  '
  ' repeat a populated set of data
  strData = REPEAT$(5,$DQ & "no data" & $DQ & ",")
  strData = RTRIM$(strData,",")
  funLog strData & $CRLF
  '
  ' update one element of that formated string
  LOCAL lngElement AS LONG
  LOCAL strValue AS STRING
  lngElement = 4
  strValue = "Some New data"
  '
  ' slot in the new data and display
  strData = funParsePut(strData,",",lngElement,strValue)
  funLog strData & $CRLF
  '
  ' use a different delimiter
  strData = REPEAT$(5," | ")
  funLog strData & $CRLF
  '
  ' slot in the new data and display
  lngElement = 2
  strValue = "Some New data"
  strData = funParsePut(strData,"|",lngElement,strValue)
  funLog strData & $CRLF
  '
  funWait()
  '
END FUNCTION
'
