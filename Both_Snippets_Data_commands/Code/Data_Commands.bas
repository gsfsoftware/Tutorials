#COMPILE EXE
#DIM ALL
#DEBUG ERROR ON
'
#TOOLS OFF
'
' include the common display library
#INCLUDE "win32api.inc"
#INCLUDE "CommonDisplay.inc"
'
DECLARE FUNCTION funReturnData LIB "libData.dll" _
                    ALIAS "funReturnData" _
                    () AS STRING
'
FUNCTION PBMAIN () AS LONG
' the main PB function that is the first to be executed
  funPrepOutput("Data Commands",0,0,40,120)
  '
  funLog("Data Commands")
  '
  LOCAL strData AS STRING
  strData = funBuildData()
  '
  funLog("The data is -> " & strData)
  funLog("")
  '
  strData = funReturnData()
  funLog("The data is -> " & strData)
  '
  funWait()
  '
END FUNCTION
'
FUNCTION funBuildData() AS STRING
' build up some data
  LOCAL lngTotalEntries AS LONG
  LOCAL lngR AS LONG
  LOCAL strData AS STRING
  '
  lngTotalEntries = DATACOUNT
  '
  FOR lngR = 1 TO lngTotalEntries
  ' for each data item
    strData = strData & READ$(lngR) & ","
  '
  NEXT lngR
  '
  strData = RTRIM$(strData,",")
  '
  DATA "Blue","Green","Brown","Hazel","Amber","Gray"
  DATA 1,2,3,4
  DATA Test
  DATA More Test "data"
  '
  'prefix "Data "
  ' 17,List,book
  ' 18,small,paper
  'end prefix
  '
  FUNCTION = strData
  '
END FUNCTION
