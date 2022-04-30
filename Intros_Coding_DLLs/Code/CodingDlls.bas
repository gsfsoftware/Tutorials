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
DECLARE FUNCTION funReverse_the_string LIB "Demo_One.dll" _
                    ALIAS "funReverseString" _
                    (strString AS STRING) AS STRING
                    '
DECLARE FUNCTION funDoTheOutput LIB "Demo_One.dll" _
                    ALIAS "funOutputDataToScreen" _
                    () AS STRING
                    '
DECLARE FUNCTION funGetSomeNewData LIB "Demo_One.dll" _
                    ALIAS "funGetSomeData" _
                    (BYREF a_strArray() AS STRING) AS STRING

'
FUNCTION PBMAIN () AS LONG
' the main PB function that is the first to be executed
  funPrepOutput("Coding DLL",0,0,40,120)
  '
  funLog("Coding DLL")
  '
  LOCAL strString AS STRING
  strString = "A short string"
  '
  ' reverse the string
  funLog("String reversed = " & STRREVERSE$(strString))
  funLog("String reversed = " & funReverse_A_string(strString))
  funLog("String reversed = " & funReverse_the_string(strString))
  '
  ' output some data to the screen
  funOutputData()
  funLog(funDoTheOutput())
  '
  ' pass an array and get data back in it
  DIM a_strArray(5) AS STRING
  funlog(funGetData(a_strArray() ))
  funLog(funGetSomeNewData(a_strArray() ))
  '
  funWait()
  '
END FUNCTION
'
FUNCTION funGetData(BYREF a_strArray() AS STRING) AS STRING
  ' populate the array and return as a string
  LOCAL lngR AS LONG
  LOCAL strData AS STRING
  '
  subPopulateArray(BYREF a_strArray())
  '
  FOR lngR = 1 TO UBOUND(a_strArray)
    strData = strData & a_strArray(lngR) & $CRLF
  NEXT lngR
  '
  FUNCTION = strData

END FUNCTION
'
SUB subPopulateArray(BYREF a_strArray() AS STRING)
  LOCAL lngR AS LONG
  '
  FOR lngR = 1 TO UBOUND(a_strArray)
    a_strArray(lngR) = FORMAT$(RND(1,10))
  NEXT lngR
  '
END SUB
'
FUNCTION funOutputData() AS LONG
  LOCAL lngR AS LONG
  '
  FOR lngR =1 TO 5
    funLog("Row = " & FORMAT$(lngR))
  NEXT lngR
  '
END FUNCTION
'
FUNCTION funReverse_A_string(strString AS STRING) AS STRING
' take a string in return it reversed
  LOCAL strReversed AS STRING
  '
  strReversed = STRREVERSE$(strString)
  '
  FUNCTION = strReversed
'
END FUNCTION
