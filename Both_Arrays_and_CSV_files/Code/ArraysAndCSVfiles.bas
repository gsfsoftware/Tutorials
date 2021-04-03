#COMPILE EXE
#DIM ALL
#DEBUG ERROR ON

' include the common display library
#INCLUDE "win32api.inc"
#INCLUDE "..\Libraries\CommonDisplay.inc"
'
$CSVFile = "Myfile.csv"
'
FUNCTION PBMAIN () AS LONG
' the main PB function that is the first to be executed
  funPrepOutput("Arrays and CSV files",0,0,40,120)
  '
  funLog("Walk through on Arrays & CSV files")
  '
  DIM a_strData() AS STRING
  LOCAL lngFile AS LONG
  LOCAL lngRecords AS LONG
  ' first read the CSV file into an array
  lngFile = FREEFILE
  '
  TRY
    OPEN EXE.PATH$ & $csvFile FOR INPUT AS lngFile
    FILESCAN #lngFile, RECORDS TO lngRecords
    REDIM a_strData(0 TO lngRecords - 1) AS STRING
    LINE INPUT #lngFile, a_strData()
    '
  CATCH
    funLog("File cannot be opened")
  FINALLY
    CLOSE #lngFile
  END TRY
  '
  funLog(FORMAT$(lngRecords) & " Records read")
  LOCAL lngR AS LONG
  '
  FOR lngR = 0 TO 10
    funLog("Record " & FORMAT$(lngR) & " = " & a_strData(lngR))
  NEXT lngR
  '
  ' now put the work array into a 2 dimensional array
  LOCAL lngC AS LONG
  LOCAL lngColumns AS LONG
  LOCAL strValue AS STRING
  '
  lngColumns = PARSECOUNT(a_strData(0),",")
  ' dimension the Big data array to the size needed
  DIM a_strBigData(0 TO lngRecords,lngColumns) AS STRING
  '
  FOR lngR = 0 TO lngRecords
    FOR lngC = 1 TO lngColumns
      strValue = PARSE$(a_strData(lngR),"",lngC)
      a_strBigData(lngR,lngC) = strValue
    NEXT lngC
  NEXT lngR
  '
  funLog($CRLF & "2d array data")
  '
  FOR lngR = 0 TO 10
    funLog("Record " & FORMAT$(lngR) & " = " & _
           a_strBigData(lngR,1) & _
           " - " & _
           a_strBigData(lngR,2) & _
           " - " & _
           a_strBigData(lngR,3))

  NEXT lngR
  '
  funWait()
  '
END FUNCTION
