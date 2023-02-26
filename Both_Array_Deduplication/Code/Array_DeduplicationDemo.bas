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
%Type  = 1    ' type of fruit
%Count = 2    ' item count
'
FUNCTION PBMAIN () AS LONG
' the main PB function that is the first to be executed
  funPrepOutput("Array Deduplication",0,0,40,120)
  '
  funLog("Array Deduplication")
  '
  ' set up arrays
  DIM a_strSource() AS STRING
  DIM a_strDest() AS STRING
  LOCAL lngStartRow AS LONG
  '
  IF ISTRUE funPrepareData(a_strSource()) THEN
    funLog("Data prepared")
    '
    funDisplayArray(a_strSource())
    '
    IF ISTRUE funDeduplicate_ArrayByRow(a_strSource(), _
                                        a_strDest(), _
                                        lngStartRow) THEN
      funLog("Array deduplicated")
      '
      funDisplayArray(a_strDest())
      '
    ELSE
      funLog("unable to deduplicate array")
    END IF
    '
  ELSE
    funLog("Unable to Prepare data")
  END IF
  '
  funWait()
  '
END FUNCTION
'
FUNCTION funDeduplicate_ArrayByRow(BYREF a_strSource() AS STRING, _
                                   BYREF a_strDest() AS STRING, _
                                   lngStartRow AS LONG) AS LONG
' deduplicate array by whole rows
  ' prepare Destination array - make same size as Source
  REDIM a_strDest(UBOUND(a_strSource,1), _
                  UBOUND(a_strSource,2)) AS STRING
  '
  ' sweep through Source array
  ' and populate Destination array with unique values
  LOCAL lngR, lngC AS LONG    ' row & column
  LOCAL lngCount AS LONG      ' count of entries into Destination
  LOCAL lngMaxRows AS LONG    ' max rows in array
  LOCAL lngMaxColumns AS LONG ' max columns in array
  '
  lngMaxRows    = UBOUND(a_strSource,1)
  lngMaxColumns = UBOUND(a_strSource,2)
  '
  FOR lngR = lngStartRow TO lngMaxRows
  ' for each entry in Source array
    IF ISFALSE funIsAlreadyInDestination(lngR, a_strSource(), _
                                         a_strDest()) THEN
                                         '
      INCR lngCount ' advance destination counter
      ' copy data into destination
      FOR lngC = 1 TO lngMaxColumns
        a_strDest(lngCount,lngC) = a_strSource(lngR,lngC)
      NEXT lngC
      '
    END IF
    '
  NEXT lngR
  '
  ' now redim the destination to just the rows needed
  REDIM PRESERVE a_strDest(lngCount,lngMaxColumns) AS STRING
  '
  FUNCTION = %TRUE
  '
END FUNCTION
'
FUNCTION funIsAlreadyInDestination(lngR AS LONG, _
                                   BYREF a_strSource() AS STRING, _
                                   BYREF a_strDest() AS STRING) AS LONG
' is this record already in the destination
  LOCAL lngD AS LONG
  LOCAL lngColumn AS LONG
  LOCAL lngMinColumn, lngMaxColumn AS LONG
  LOCAL lngMaxRow AS LONG
  LOCAL lngFound AS LONG
  '
  ' set the boundings
  lngMinColumn = LBOUND(a_strDest,2)
  lngMaxColumn = UBOUND(a_strDest,2)
  '
  lngMaxRow = UBOUND(a_strDest,1)
  '
  FOR lngD = 1 TO lngMaxRow
  ' for each item in Destination
    lngFound = %TRUE   ' default to found
    '
    FOR lngColumn = lngMinColumn TO lngMaxColumn
      IF a_strDest(lngD,lngColumn) <> a_strSource(lngR,lngColumn) THEN
        lngFound = %FALSE
        EXIT FOR
      END IF
    NEXT lngColumn
    '
    ' if lngFound = %TRUE then we found a match
    IF ISTRUE lngFound THEN
    ' a match found - no point in going further
      FUNCTION = %TRUE
      EXIT FUNCTION
    END IF
    '
  NEXT lngD
  '
  FUNCTION = %FALSE
  '
END FUNCTION
'
FUNCTION funDisplayArray(BYREF a_strArray() AS STRING) AS LONG
' display the array to the log
  LOCAL lngR, lngC AS LONG
  LOCAL strData AS STRING
  '
  funLog($CRLF & "Output is")
  '
  FOR lngR = 1 TO UBOUND(a_strArray,1)
    FOR lngC = 1 TO UBOUND(a_strArray,2)
      strData = strData & a_strArray(lngR,lngC) & " "
    NEXT lngC
    funLog(strData)
    strData = ""
  NEXT lngR

END FUNCTION
'
FUNCTION funPrepareData(BYREF a_strSource() AS STRING) AS LONG
' prepare source array data
  REDIM a_strSource(6,2) AS STRING
  '
  ' populate the array
  a_strSource(1,%Type) = "Apple"
  a_strSource(1,%Count) = "4"
  '
  a_strSource(2,%Type) = "Pear"
  a_strSource(2,%Count) = "4"
  '
  a_strSource(3,%Type) = "Watermelon"
  a_strSource(3,%Count) = "4"
  '
  a_strSource(4,%Type) = "Apple"
  a_strSource(4,%Count) = "4"
  '
  a_strSource(5,%Type) = "Lime"
  a_strSource(5,%Count) = "4"
  '
  a_strSource(6,%Type) = "Watermelon"
  a_strSource(6,%Count) = "4"
  '
  FUNCTION = %TRUE
END FUNCTION
