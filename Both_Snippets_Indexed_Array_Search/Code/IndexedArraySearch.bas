#COMPILE EXE
#DIM ALL
#DEBUG ERROR ON
'
#TOOLS OFF
'
' include the common display library
#INCLUDE "win32api.inc"
#INCLUDE "CommonDisplay.inc"
#INCLUDE "PB_FileHandlingRoutines.inc"
'
$InputFile = "MyLargeFile.txt"
$SearchString = "Shannon.Christensen57@gmail.com"
$SearchString2 = "Paige.Richardson03@gmail.com"
'
%IndexStart = 1 ' Element number in indexed array
%IndexEnd   = 2 ' start and end row for each starting character
'
FUNCTION PBMAIN () AS LONG
' the main PB function that is the first to be executed
  funPrepOutput("Indexed Array Search",0,0,40,120)
  '
  funLog("Indexed Array Search")
  '
  DIM a_strData() AS STRING
  '
  IF ISTRUE funReadTheFileIntoAnArray(EXE.PATH$ & $InputFile, _
                                      a_strData()) THEN
     ' sort the array from row 1 - row 0 is the headers
    ARRAY SORT a_strData(1), ASCEND   ' ascending order
    funLog("Array sorted")
    '
    LOCAL qCount AS QUAD
    '
    TIX qCount
    funSearch_For_Next(a_strData(),$SearchString)
    funSearch_For_Next(a_strData(),$SearchString2)
    TIX END qCount
    funLog("CPU cycles = " & FORMAT$(qCount,"###,###") & $CRLF)
    '
    TIX qCount
    funSearchArrayScan(a_strData(), $SearchString)
    funSearchArrayScan(a_strData(), $SearchString2)
    TIX END qCount
    funLog("CPU cycles = " & FORMAT$(qCount,"###,###") & $CRLF)
    '
    ' now do an indexed search

    TIX qCount
    LOCAL lngUniqueField AS LONG
    lngUniqueField = 1 ' set field number
    LOCAL strDelimiter AS STRING
    strDelimiter = $TAB
    '
    ' index array used for fast searches
    DIM a_lngIndex(30,2) AS LONG
    '
    funIndexArray(a_strData(), _
                  a_lngIndex(), _
                  lngUniqueField, _
                  strDelimiter)
    TIX END qCount
    funLog("CPU cycles for index = " & FORMAT$(qCount,"###,###") & $CRLF)
    '
    TIX qCount
    funSearchIndexed(a_strData(), $SearchString, _
                     a_lngIndex())
    funSearchIndexed(a_strData(), $SearchString2, _
                     a_lngIndex())
                     '
    TIX END qCount
    funLog("CPU cycles = " & FORMAT$(qCount,"###,###") & $CRLF)
    '
  END IF
  '
  funWait()
  '
END FUNCTION
'
FUNCTION funSearchIndexed(BYREF a_strData() AS STRING, _
                          strSearchString AS STRING, _
                          BYREF a_lngIndex() AS LONG) AS LONG
  funLog("Searching Indexed Array")
  '
  LOCAL lngR AS LONG
  '
  LOCAL lngStart, lngEnd, lngSlot AS LONG
  LOCAL strIndex AS STRING
  '
  strIndex = LCASE$(LEFT$(strSearchString,1))
  lngSlot = ASC(strIndex)-96
  '
  lngStart = a_lngIndex(lngSlot,%IndexStart)
  lngEnd   = a_lngIndex(lngSlot,%IndexEnd)
  '
  FOR lngR = lngStart TO lngEnd
    IF LEFT$(a_strData(lngR),LEN(strSearchString)) = strSearchString THEN
    ' entry found
      funLog(LEFT$(a_strData(lngR),50))
      funLog("Entry found in row " & FORMAT$(lngR))
      EXIT FOR
    END IF
  NEXT lngR
  '
END FUNCTION
'
FUNCTION funIndexArray(BYREF a_strArray() AS STRING, _
                       BYREF a_lngIndex() AS LONG, _
                       lngField AS LONG, _
                       strDelimiter AS STRING) AS LONG
' build index based on the a_strArray
' assumes array has already been sorted
  LOCAL lngR AS LONG
  LOCAL strIndex AS STRING
  LOCAL strCurrent AS STRING
  LOCAL lngSlot AS LONG
  LOCAL strUniqueID AS STRING
  '
  FOR lngR = 1 TO UBOUND(a_strArray)
    strUniqueID = PARSE$(a_strArray(lngR),strDelimiter,lngField)
    strCurrent = LCASE$(LEFT$(strUniqueID,1))
    IF TRIM$(strCurrent) = "" THEN ITERATE
    lngSlot = ASC(strIndex)-96
    IF strCurrent <> strIndex THEN
    ' change to index
      IF strIndex <> "" THEN
      ' save details to a_lngIndex()
        a_lngIndex(lngSlot,%IndexEnd) = lngR - 1
        strIndex = strCurrent
        lngSlot = ASC(strIndex)-96
        a_lngIndex(lngSlot,%IndexStart) = lngR
      ELSE
      ' first index
        strIndex = strCurrent
        lngSlot = ASC(strIndex)-96
        a_lngIndex(lngSlot,%IndexStart) = lngR
      END IF
    ELSE
    ' same index do nothing
    END IF
    '
  NEXT lngR
  '
  a_lngIndex(lngSlot,%IndexEnd) = UBOUND(a_strArray)
  '
END FUNCTION
'
FUNCTION funSearchArrayScan(BYREF a_strData() AS STRING, _
                            strSearchString AS STRING) AS LONG
  funLog("Searching Array Scan")
  LOCAL lngR AS LONG
  '
  ARRAY SCAN a_strData(), FROM 1 TO LEN(strSearchString), _
                           = strSearchString, TO lngR
                           '
  funLog(LEFT$(a_strData(lngR-1),50))
  funLog("Entry found in row " & FORMAT$(lngR-1))
  '
END FUNCTION
'
FUNCTION funSearch_For_Next(BYREF a_strData() AS STRING, _
                            strSearchString AS STRING) AS LONG
  funLog("Searching For-Next")
  LOCAL lngR AS LONG
  '
  FOR lngR = 1 TO UBOUND(a_strData)
    IF LEFT$(a_strData(lngR),LEN(strSearchString)) = strSearchString THEN
      ' entry found
      funLog(LEFT$(a_strData(lngR),50))
      funLog("Entry found in row " & FORMAT$(lngR))
      EXIT FOR
    END IF
  NEXT lngR
  '
END FUNCTION
