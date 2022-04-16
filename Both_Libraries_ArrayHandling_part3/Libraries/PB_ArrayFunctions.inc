' PB_ArrayFunctions.inc
'
' funAddToArray   - add a row to an array
'
' funArrayCompare - compare and return results on
'                   differences between two arrays
'
' funArrayCopyHeaders - copy headers on row 0
'                       from source to destination array
'
' funArrayGetUniqueFieldValue - get the value held in unique
'                               identifier field
'
' funArrayRowChanged - true/false if array row has changed
'                      between two arrays
'
' funArraySave_1D  - save a one dimensional file while
'                    changing the delimeter
'
' funArraySave_2D  - save a two dimensional file with
'                    a delimeter
'
' funArrayTrim_2D  - trims a 2d array to remove empty rows
'
' funCloneArray - create a new copy of an array
'
' funIsInArray - is data in the array at specified column position
'
' funReportAdded_To_Array - compare and report on additions between two arrays
'
' funReportChanged_in_Array - compare and report on changes between two arrays
'


' include the file handling routines as a dependancy
#INCLUDE ONCE "..\Libraries\PB_FileHandlingRoutines.inc"
'
%Array_Block_Addition = 1000
'
FUNCTION funIndexArrayCompare(strMainFile() AS STRING, _
                              a_strOtherFile() AS STRING, _
                              a_strReportData() AS STRING, _
                              strDelimiter AS STRING, _
                              strUniqueFieldname AS STRING,_
                              strComparisonType AS STRING, _
                              strError AS STRING, _
                              lngDimensions AS LONG) AS LONG
' compare Mainfile array to Other file array
' and report depending on comparison type
' in the report data array
  LOCAL lngMainRow AS LONG             ' row in main array
  LOCAL lngMainTotalRows AS LONG       ' total rows in main array
  LOCAL lngOtherRow AS LONG            ' row in other array
  LOCAL lngOtherTotalRows AS LONG      ' total rows in other array
  LOCAL strUniqueFieldValue AS STRING  ' value of unique field in main array
  LOCAL strOtherUniqueValue AS STRING  ' value of unique field in other array
  LOCAL lngFound AS LONG               ' found in search true/false
  LOCAL lngColumn AS LONG              ' column number
  '
  LOCAL lngOtherStart AS LONG   ' start and end elements
  LOCAL lngOtherEnd AS LONG     ' of the other array
  '
  LOCAL lngUniqueField AS LONG      ' unique field number
  LOCAL lngReportRowCount AS LONG   ' row counter in report array
  '
  ' index array
  DIM a_lngIndex(30,2) AS LONG      ' index array used for fast searches
  LOCAL strIndex AS STRING          ' single character used for index
  LOCAL lngSlot AS LONG             ' row in the a_lngIndex array
  '
  ' error handling
  SELECT CASE strComparisonType
    CASE "Missing"
    CASE ELSE
      strError = "Invalid comparison type"
      EXIT FUNCTION
  END SELECT
  '
  IF lngDimensions <> 1 THEN
    strError = "Only handling 1 dimensional arrays so far"
    EXIT FUNCTION
  END IF
  '
  ' prep the report array
  IF lngDimensions = 1 THEN
  ' single dimension
    REDIM a_strReportData(%Array_Block_Addition) AS STRING
    ' add the headers
    a_strReportData(0) = strMainFile(0)
  ELSE
  ' two dimensions
    REDIM a_strReportData(%Array_Block_Addition, _
                          UBOUND(strMainFile,2)) AS STRING
    ' add the headers
    FOR lngColumn = 1 TO UBOUND(strMainFile,2)
      a_strReportData(0,lngColumn) = strMainFile(0,lngColumn)
    NEXT lngColumn
    '
  END IF
  '
  lngUniqueField = 0
  lngUniqueField = funParseFind(strMainFile(0) ,strDelimiter, _
                                strUniqueFieldname)
                                '
  IF lngUniqueField = 0 THEN
    strError = "Unable to find unique field name"
    EXIT FUNCTION
  END IF
  '
  ' get the total number of rows in each array
  lngMainTotalRows = UBOUND(strMainFile)
  lngOtherTotalRows = UBOUND(a_strOtherFile)
  '
   ' get the start and end elements of the other array
  lngOtherStart = 1
  lngOtherEnd   = lngOtherTotalRows
  '
  IF ISTRUE %IndexedSearch THEN
  ' we are doing an indexed search
    ' first sort the Other array based on the lngUniqueField
    IF ISTRUE funArraySort(a_strOtherFile(), _  ' the array to sort
                           "STRING", _          'the type of sort to perform
                           lngUniqueField , _   'the field number to sort on
                           strDelimiter , _     'the separator between the data elements
                           "ASCEND" , _         'is Ascending or Descending
                           strError, _          'contains any error message
                           %TRUE) THEN          'keep the headers
                           '
      funArrayDump(EXE.PATH$ & "SortedOther.csv", _
                   BYREF a_strOtherFile())
      funIndexArray(a_strOtherFile(), a_lngIndex(),lngUniqueField)
    END IF
    '
  END IF
  '
  FOR lngMainRow = 1 TO lngMainTotalRows
  ' for each record in the main file
    IF lngMainRow MOD 1000 = 0 THEN
      funLog("Row = " & FORMAT$(lngMainRow))
    END IF
    '
    ' get the strUniqueFieldValue
    lngFound = %FALSE     ' assume not found
    ' get the value of the unique field
    strUniqueFieldValue = funArrayGetUniqueFieldValue(strMainFile(), _
                                                      lngMainRow, _
                                                      strDelimiter, _
                                                      lngUniqueField, _
                                                      lngDimensions)
    '
    IF ISTRUE %IndexedSearch THEN
    ' we are doing an indexed search
      ' get first character of strUniqueFieldValue as lower case
      strIndex = LCASE$(LEFT$(strUniqueFieldValue,1))
      lngSlot = ASC(strIndex)-96
      '
      lngOtherStart = a_lngIndex(lngSlot,%IndexStart)
      lngOtherEnd   = a_lngIndex(lngSlot,%IndexEnd)
      '
    END IF
    '
    FOR lngOtherRow = lngOtherStart TO lngOtherEnd
    ' check each row in other array
      ' pick up its unique value
      strOtherUniqueValue = PARSE$(a_strOtherFile(lngOtherRow), _
                                   strDelimiter,lngUniqueField)
                                   '
      IF strUniqueFieldValue = strOtherUniqueValue THEN
      ' found a match
        lngFound = %TRUE
        EXIT FOR
      '
      END IF
      '
    NEXT lngOtherRow
    '
    IF ISFALSE lngFound THEN
    ' we didn't find a match - so report this
      INCR lngReportRowCount ' advance row counter
      funAddToArray(lngReportRowCount, _
                    lngMainRow, _
                    BYREF a_strReportData(), _
                    BYREF strMainFile(), _
                    lngDimensions)
    '
    END IF
    '
  NEXT lngMainRow
  '
  ' truncate the array to data actually stored
  IF lngDimensions = 1 THEN
  ' single dimension
    REDIM PRESERVE a_strReportData(lngReportRowCount)
  ELSE
  ' 2 dimension
    funArrayTrim_2D(lngReportRowCount,a_strReportData())
  END IF
  '
  FUNCTION = %TRUE
  '
END FUNCTION
'
FUNCTION funIndexArray(BYREF a_strArray() AS STRING, _
                       BYREF a_lngIndex() AS LONG, _
                       lngField AS LONG) AS LONG
' build index based on the a_strArray
' assumes array has already been sorted
  LOCAL lngR AS LONG
  LOCAL strIndex AS STRING
  LOCAL strCurrent AS STRING
  LOCAL lngSlot AS LONG
  LOCAL strUniqueID AS STRING
  '
  FOR lngR = 1 TO UBOUND(a_strArray)
    strUniqueID = PARSE$(a_strArray(lngR),"",lngField)
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
    '
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
FUNCTION funArrayCompare(BYREF a_strYesterdayData() AS STRING, _
                         BYREF a_strTodayData() AS STRING, _
                         BYREF a_strAddedData() AS STRING, _
                         BYREF a_strAmendedData() AS STRING, _
                         BYREF a_strRemovedData() AS STRING, _
                         strDelimiter AS STRING, _
                         strUniqueFieldname AS STRING,_
                         strError AS STRING) AS LONG
' compare and return results on differences between two arrays
  ' firstly report additions
  IF ISTRUE funReportAdded_To_Array(a_strYesterdayData(), _
                                    a_strTodayData(), _
                                    a_strAddedData(), _
                                    strDelimiter, _
                                    strUniqueFieldname,_
                                    strError) THEN
  '
  ELSE
    ' strError has already been populated
    FUNCTION = %FALSE
    EXIT FUNCTION
  END IF
  '
  ' now report removals - reversing the arrays
  IF ISTRUE funReportAdded_To_Array(a_strTodayData(), _
                                    a_strYesterdayData(), _
                                    a_strRemovedData(), _
                                    strDelimiter, _
                                    strUniqueFieldname,_
                                    strError) THEN
  ELSE
    ' strError has already been populated
    FUNCTION = %FALSE
    EXIT FUNCTION
  END IF
  '
  ' now report changes
  IF ISTRUE funReportChanged_in_Array(a_strYesterdayData(), _
                                    a_strTodayData(), _
                                    a_strAmendedData(), _
                                    strDelimiter, _
                                    strUniqueFieldname,_
                                    strError) THEN
  ELSE
    ' strError has already been populated
    FUNCTION = %FALSE
    EXIT FUNCTION
  END IF
  '
  FUNCTION = %TRUE
  '
END FUNCTION
'
FUNCTION funReportChanged_in_Array(BYREF a_strYesterdayData() AS STRING, _
                                   BYREF a_strTodayData() AS STRING, _
                                   BYREF a_strReportData() AS STRING, _
                                   strDelimiter AS STRING, _
                                   strUniqueFieldname AS STRING,_
                                   strError AS STRING) AS LONG
' compare and report on changes between two arrays
  LOCAL lngRow AS LONG
  LOCAL lngRows AS LONG
  LOCAL lngColumn AS LONG
  '
  LOCAL lngDimensions_Y AS LONG ' number of dimensions in
  LOCAL lngDimensions_T AS LONG ' each of the arrays
  '
  ' check number of dimensions
  lngDimensions_Y = ARRAYATTR(a_strYesterdayData(),3)
  lngDimensions_T = ARRAYATTR(a_strTodayData(),3)
  '
  IF lngDimensions_Y > 2 _
     OR lngDimensions_T > 2 THEN
    strError = strError & "Too many dimensions in arrays in " & _
                           FUNCNAME$ & $CRLF
    FUNCTION = %FALSE
    EXIT FUNCTION
  END IF
  '
  IF lngDimensions_Y <> lngDimensions_T THEN
    strError = "Arrays have different numbers of dimensions in " & _
                           FUNCNAME$ & $CRLF
    FUNCTION = %FALSE
    EXIT FUNCTION
  END IF
  '
  ' prepare some rows in Report data
  IF lngDimensions_Y = 1 THEN
  ' single dimension
    REDIM a_strReportData(%Array_Block_Addition) AS STRING
  ELSE
  ' two dimensions
    REDIM a_strReportData(%Array_Block_Addition, _
                          UBOUND(a_strYesterdayData,2)) AS STRING
  END IF
  ' copy headers in
  funArrayCopyHeaders(a_strTodayData(),a_strReportData())
  'a_strReportData(0) = a_strTodayData(0) ' copy headers in
  '
  LOCAL lngRowCount AS LONG         ' last written row in
  '                                   a_strReportData() array
  LOCAL lngUniqueField AS LONG
  LOCAL strUniqueField AS STRING
  LOCAL lngRowFound AS LONG         ' row in the other array (if found)
  '
  ' determine the column number of the unique field
  IF lngDimensions_Y = 1 THEN
  ' single dimension
    lngUniqueField = funParseFind(a_strTodayData(0) ,strDelimiter, _
                                  strUniqueFieldname)
  ELSE
  ' two dimensional array
    FOR lngColumn = 1 TO UBOUND(a_strTodayData,2)
      IF a_strTodayData(0,lngColumn) = strUniqueFieldname THEN
      ' match found
        lngUniqueField = lngColumn
        EXIT FOR
      END IF
    NEXT lngColumn
  '
  END IF
  IF lngUniqueField = 0 THEN
    strError = strError & "Unable to locate Unique field in " & FUNCNAME$ & $CRLF
    FUNCTION = %FALSE
    EXIT FUNCTION
  END IF
  '
  ' are there any entries in a_strTodayData() that
  ' do exist in the a_strYesterdayData() array?
  '
  lngRows = UBOUND(a_strTodayData) ' get total rows in array
  FOR lngRow = 1 TO lngRows
  ' step through each record
    strUniqueField = funArrayGetUniqueFieldValue(a_strTodayData(), _
                                                 lngRow, _
                                                 strDelimiter, _
                                                 lngUniqueField, _
                                                 lngDimensions_Y)
    'strUniqueField = PARSE$(a_strTodayData(lngRow),_
    '                        strDelimiter,lngUniqueField)                               '
  ' does this exist in the other array?
    IF ISTRUE funIsInArray(a_strYesterdayData(), _
                           strUniqueField, _
                           lngUniqueField, _
                           strDelimiter, _
                           lngRowFound, _
                           lngDimensions_Y) THEN
    ' found it, but has it changed?
      'IF a_strTodayData(lngRow) <> a_strYesterdayData(lngRowFound) THEN
      IF ISTRUE funArrayRowChanged(lngRowFound,lngRow, _
                                   a_strYesterdayData(), _
                                   a_strTodayData(), _
                                   lngDimensions_Y) THEN
      ' rows are different - so a change has happened
        INCR lngRowCount
        funAddToArray(lngRowCount,lngRow,a_strReportData(), _
                      a_strTodayData(),lngDimensions_Y)
        '
      END IF
    '
    END IF
  '
  NEXT lngRow
  ' truncate the array to data actually stored
  IF lngDimensions_Y = 1 THEN
  ' single dimension
    REDIM PRESERVE a_strReportData(lngRowCount)
  ELSE
  ' 2 dimension
    funArrayTrim_2D(lngRowCount,a_strReportData())
  END IF
  '
  FUNCTION = %TRUE
  '
END FUNCTION
'
FUNCTION funArrayRowChanged(lngRowFound AS LONG,_
                            lngRow AS LONG, _
                            BYREF a_strPrevious() AS STRING, _
                            BYREF a_strCurrent() AS STRING, _
                            lngDimensions AS LONG) AS LONG
' has the array row changed? true/false
'
  LOCAL lngColumn AS LONG
  LOCAL strPrevious AS STRING
  LOCAL strCurrent AS STRING
  '
  IF lngDimensions = 1 THEN
  ' single dimension
    IF a_strCurrent(lngRow) <> a_strPrevious(lngRowFound) THEN
    ' rows are different
      FUNCTION = %TRUE
    END IF
  ELSE
  ' two dimensional
    FOR lngColumn = LBOUND(a_strPrevious,2) TO UBOUND(a_strPrevious,2)
      strPrevious = strPrevious & a_strPrevious(lngRowFound,lngColumn)
      strCurrent = strCurrent & a_strCurrent(lngRow,lngColumn)
    NEXT lngColumn
    '
    IF strPrevious <> strCurrent THEN
    ' rows are different
      FUNCTION = %TRUE
    END IF
    '
  END IF
'
END FUNCTION
'
FUNCTION funArrayCopyHeaders(BYREF a_strSource() AS STRING, _
                             BYREF a_strDestination() AS STRING) AS LONG
' copy headers from source to destination
  LOCAL lngDimensions AS LONG
  LOCAL lngColumn AS LONG
  '
  lngDimensions = ARRAYATTR(a_strSource(),3)
  '
  IF lngDimensions = 1 THEN
  ' single dimension
    a_strDestination(0) = a_strSource(0)
  ELSE
  ' two dimensions (or more?)
    FOR lngColumn = LBOUND(a_strSource,2) TO UBOUND(a_strSource,2)
      a_strDestination(0,lngColumn) = a_strSource(0,lngColumn)
    NEXT lngColumn
  '
  END IF
  '
END FUNCTION
'
FUNCTION funArrayGetUniqueFieldValue(BYREF a_strArray() AS STRING, _
                                     lngRow AS LONG, _
                                     strDelimiter AS STRING, _
                                     lngUniqueField AS LONG, _
                                     lngDimensions AS LONG) AS STRING
' return the value of the unique field
'
  IF lngDimensions = 1 THEN
  ' single dimension
    FUNCTION = PARSE$(a_strArray(lngRow),_
                      strDelimiter,lngUniqueField)
  ELSE
  ' two dimensions
    FUNCTION = a_strArray(lngRow,lngUniqueField)
  '
  END IF
  '
END FUNCTION
'
FUNCTION funReportAdded_To_Array(BYREF a_strYesterdayData() AS STRING, _
                                 BYREF a_strTodayData() AS STRING, _
                                 BYREF a_strReportData() AS STRING, _
                                 strDelimiter AS STRING, _
                                 strUniqueFieldname AS STRING,_
                                 strError AS STRING) AS LONG
' compare and report on additions between two arrays
  LOCAL lngRow AS LONG
  LOCAL lngRows AS LONG
  LOCAL lngColumn AS LONG
  LOCAL lngDimensions_Y AS LONG ' number of dimensions in
  LOCAL lngDimensions_T AS LONG ' each of the arrays
  '
  ' check number of dimensions
  lngDimensions_Y = ARRAYATTR(a_strYesterdayData(),3)
  lngDimensions_T = ARRAYATTR(a_strTodayData(),3)
  '
  IF lngDimensions_Y > 2 _
     OR lngDimensions_T > 2 THEN
    strError = "Too many dimensions in arrays in " & _
                           FUNCNAME$ & $CRLF
    FUNCTION = %FALSE
    EXIT FUNCTION
  END IF
  '
  IF lngDimensions_Y <> lngDimensions_T THEN
    strError = "Arrays have different numbers of dimensions in " & _
                           FUNCNAME$ & $CRLF
    FUNCTION = %FALSE
    EXIT FUNCTION
  END IF
  '
  ' prepare some rows in Report data
  IF lngDimensions_Y = 1 THEN
  ' single dimension
    REDIM a_strReportData(%Array_Block_Addition) AS STRING
  ELSE
  ' two dimensions
    REDIM a_strReportData(%Array_Block_Addition, _
                          UBOUND(a_strYesterdayData,2)) AS STRING
  END IF
  '
  ' copy headers in
  funArrayCopyHeaders(a_strTodayData(),a_strReportData())
  'a_strReportData(0) = a_strTodayData(0) ' copy headers in
  '
  LOCAL lngRowCount AS LONG         ' last written row in
  '                                   a_strReportData() array
  LOCAL lngUniqueField AS LONG
  LOCAL strUniqueField AS STRING
  LOCAL lngRowFound AS LONG         ' row in the other array (if found)
  '
  lngUniqueField = 0
  '
  ' determine the column number of the unique field
  IF lngDimensions_Y = 1 THEN
  ' single dimension
    lngUniqueField = funParseFind(a_strTodayData(0) ,strDelimiter, _
                                strUniqueFieldname)
  ELSE
  ' two dimensional array
    FOR lngColumn = 1 TO UBOUND(a_strTodayData,2)
      IF a_strTodayData(0,lngColumn) = strUniqueFieldname THEN
      ' match found
        lngUniqueField = lngColumn
        EXIT FOR
      END IF
    NEXT lngColumn
  '
  END IF
  '                              '
  IF lngUniqueField = 0 THEN
    strError = strError & "Unable to locate Unique field in " & _
                           FUNCNAME$ & $CRLF
    FUNCTION = %FALSE
    EXIT FUNCTION
  END IF
  ' are there any entries in a_strTodayData() that
  ' do not exist in the a_strYesterdayData() array?
  '
  lngRows = UBOUND(a_strTodayData) ' get total rows in array
  FOR lngRow = 1 TO lngRows
  ' step through each record
    strUniqueField = funArrayGetUniqueFieldValue(a_strTodayData(), _
                                                 lngRow, _
                                                 strDelimiter, _
                                                 lngUniqueField, _
                                                 lngDimensions_Y)
                                                 '
    'strUniqueField = PARSE$(a_strTodayData(lngRow),_
    '                        strDelimiter,lngUniqueField)
  ' does this exist in the other array?
    IF ISFALSE funIsInArray(a_strYesterdayData(), _
                            strUniqueField, _
                            lngUniqueField, _
                            strDelimiter, _
                            lngRowFound, _
                            lngDimensions_Y) THEN
    ' not found so add to the array
      INCR lngRowCount
      funAddToArray(lngRowCount,lngRow,a_strReportData(), _
                    a_strTodayData(),lngDimensions_Y)
    '
    END IF
  '
  NEXT lngRow
  ' truncate the array to data actually stored
  IF lngDimensions_Y = 1 THEN
  ' single dimension
    REDIM PRESERVE a_strReportData(lngRowCount)
  ELSE
  ' 2 dimension
    funArrayTrim_2D(lngRowCount,a_strReportData())
  END IF
  '
  FUNCTION = %TRUE
  '
END FUNCTION
'
FUNCTION funArrayTrim_2D(lngRows AS LONG, _
                         BYREF a_strArray() AS STRING) AS LONG
' trim 2D array to specified row count
  LOCAL lngColumns AS LONG
  LOCAL lngStartColumn AS LONG
  LOCAL a_strClone() AS STRING
  LOCAL strError AS STRING
  LOCAL lngStartRow AS LONG
  '
  LOCAL lngRow AS LONG
  LOCAL lngColumn AS LONG
  '
  lngStartRow = LBOUND(a_strArray,1)
  '
  lngStartColumn = LBOUND(a_strArray,2)
  lngColumns = UBOUND(a_strArray,2)
  '
  IF ISTRUE funCloneArray(a_strArray(), _
                         a_strClone(), _
                         strError) THEN
  ' array cloned successfully
  ' redim the array smaller
    REDIM a_strArray(lngStartRow TO lngRows, _
                     lngStartColumn TO lngColumns) AS STRING
    '
    ' and populate
    FOR lngRow = lngStartRow TO lngRows
      FOR lngColumn = lngStartColumn TO lngColumns
        a_strArray(lngRow,lngColumn) = a_strClone(lngRow,lngColumn)
      NEXT lngColumn
    NEXT lngR
    '
    FUNCTION = %TRUE
  '
  ELSE
    FUNCTION = %FALSE
  END IF
  '
END FUNCTION
'
FUNCTION funAddToArray(lngRowCount AS LONG, _
                       lngRow AS LONG, _
                       BYREF a_strDestination() AS STRING, _
                       BYREF a_strSource() AS STRING, _
                       lngDimensions AS LONG) AS LONG
' add record to an array
  LOCAL lngColumn AS LONG
  '
  IF lngDimensions = 1 THEN
  ' single dimension
    a_strDestination(lngRowCount) = a_strSource(lngRow)
  ELSE
  ' two dimensional
    FOR lngColumn = LBOUND(a_strSource,2) TO UBOUND(a_strSource,2)
      a_strDestination(lngRowCount,lngColumn) = _
                       a_strSource(lngRow,lngColumn)
    NEXT lngColumn
  END IF
  '
  IF (lngRowCount MOD %Array_Block_Addition) = 0 THEN
  ' needs more rows in results array
    IF lngDimensions = 1 THEN
    ' single dimension
      REDIM PRESERVE a_strDestination(UBOUND(a_strDestination) _
                                     +%Array_Block_Addition)
    ELSE
    ' two dimension
      REDIM PRESERVE a_strDestination(UBOUND(a_strDestination,1) _
                                     +%Array_Block_Addition, _
                                     UBOUND(a_strDestination,2))
    END IF
  '
  END IF
'
END FUNCTION
'
FUNCTION funIsInArray(BYREF a_strData() AS STRING, _
                      strUniqueField AS STRING, _
                      lngUniqueField AS LONG, _
                      strDelimiter AS STRING, _
                      lngRowFound AS LONG, _
                      lngDimensions AS LONG) AS LONG
' is this data in the array at specified column position?
  LOCAL lngR AS LONG
  ' for each record in the array
  FOR lngR = LBOUND(a_strData) TO UBOUND(a_strData)
    IF lngDimensions = 1 THEN
    ' single dimension
      IF strUniqueField = PARSE$(a_strData(lngR), _
                               strDelimiter, _
                               lngUniqueField) THEN
        ' match has been found
        lngRowFound = lngR
        FUNCTION = %TRUE
        EXIT FUNCTION
      END IF
      '
    ELSE
    ' more than one dimension
      IF strUniqueField = a_strData(lngR,lngUniqueField) THEN
      ' match has been found
        lngRowFound = lngR
        FUNCTION = %TRUE
        EXIT FUNCTION
      END IF
    END IF
    '
  NEXT lngR
  ' no match found
  FUNCTION = %FALSE
  '
END FUNCTION
'
FUNCTION funArraySave_1D(strFile AS STRING, _
                         BYREF a_strWork() AS STRING, _
                         strExistingDelimiter AS STRING, _
                         strNewDelimiter AS STRING) AS LONG
' save a 1 dimensional array with change to demiliter
  LOCAL lngFile AS LONG
  LOCAL lngR AS LONG
  LOCAL strData AS STRING
  '
  lngFile = FREEFILE
  TRY
    OPEN strFile FOR OUTPUT AS #lngFile
    ' for each row in the array
    FOR lngR = LBOUND(a_strWork) TO UBOUND(a_strWork)
      strData = a_strWork(lngR)
      '
      IF strNewDelimiter = "," THEN
      ' special handling for CSV files
        REPLACE strExistingDelimiter _
                WITH $QCQ IN strData
                '
        strData = $DQ & strData & $DQ
        '
      ELSE
      ' all other delimiters
        REPLACE strExistingDelimiter _
                WITH strNewDelimiter IN strData
      '
      END IF
      '
      PRINT #lngFile, strData
      '
    NEXT lngR
    FUNCTION = %TRUE
    '
  CATCH
  ' handle errors
    FUNCTION = %FALSE
    #IF %DEF(%PB_CC32)
      CON.STDOUT ERROR$
    #ENDIF
  FINALLY
  ' close the file
    CLOSE #lngFile
  END TRY
  '
END FUNCTION
'
FUNCTION funArraySave_2D(strFile AS STRING, _
                         BYREF a_strWork() AS STRING, _
                         strNewDelimiter AS STRING, _
                         OPTIONAL lngColumnStart AS LONG) AS LONG
' save a 2 dimensional array with delimiter
  LOCAL lngColumnBegin AS LONG
  '
  IF ISTRUE ISMISSING(lngColumnStart) THEN
  ' if no column start given assume column 1
    lngColumnBegin = 1
  ELSE
    lngColumnBegin = lngColumnStart
  END IF
  '
  LOCAL lngFile AS LONG
  LOCAL lngR AS LONG
  LOCAL lngC AS LONG
  LOCAL strData AS STRING
  LOCAL strCell AS STRING
  '
  LOCAL strPrefix AS STRING
  LOCAL strSuffix AS STRING
  '
  IF strNewDelimiter = "," THEN
  ' special handling for CSV files
    strPrefix = $DQ
    strSuffix = $QCQ
  ELSE
  ' normal delimiter
    strSuffix = strNewDelimiter
  END IF
  '
  lngFile = FREEFILE
  TRY
    OPEN strFile FOR OUTPUT AS #lngFile
    ' for each row in the array
    FOR lngR = LBOUND(a_strWork,1) TO UBOUND(a_strWork,1)
      FOR lngC = lngColumnBegin TO UBOUND(a_strWork,2)
      ' load cell from the array
        strCell = a_strWork(lngR,lngC)
        '
      ' special handling for CSV files
        IF lngC = lngColumnBegin THEN
        ' first element
          strData = strPrefix & strCell
        ELSE
        ' all other elements
          strData = strSuffix & strCell
        END IF
        '
        IF lngC = UBOUND(a_strWork,2) THEN
        ' last element
          PRINT #lngFile, strData & strPrefix
          'funAppendToFile(exe.path$ & "debug.txt",strData)
        ELSE
          PRINT #lngFile, strData;
          'funAppendToFile(EXE.PATH$ & "debug.txt",strData)
        END IF
      '
      NEXT lngC
      '
    NEXT lngR
    FUNCTION = %TRUE
    '
  CATCH
  ' handle errors
    FUNCTION = %FALSE
    #IF %DEF(%PB_CC32)
      CON.STDOUT ERROR$
    #ENDIF
  FINALLY
  ' close the file
    CLOSE #lngFile
  END TRY
  '
END FUNCTION
'
FUNCTION funCloneArray(BYREF a_strData1() AS STRING, _
                       BYREF a_strData2() AS STRING, _
                       strError AS STRING) AS LONG
' clone a 1 or 2 dimensional array
  LOCAL lngR AS LONG
  LOCAL lngC AS LONG
  '
  LOCAL lngDimensions AS LONG
  '
  ' work out how many dimensions this array has
  lngDimensions = ARRAYATTR(a_strData1(),3)
  ' test that array with more dimensions hasn't been passed in
  IF lngDimensions > 2 THEN
  ' report the error and exit
    strError = "This function (" & FUNCNAME$ & ") " & _
               "only handles 1 & 2 Dimensional arrays"
    FUNCTION = %FALSE
    EXIT FUNCTION
  END IF
  '
  TRY
  ' redim array
    SELECT CASE lngDimensions
    ' redimension the new array to size of first array
      CASE 1
        REDIM a_strData2(LBOUND(a_strData1) TO UBOUND(a_strData1))
      CASE 2
        REDIM a_strData2(LBOUND(a_strData1,1) TO UBOUND(a_strData1,1), _
                         LBOUND(a_strData1,2) TO UBOUND(a_strData1,2))
    END SELECT
    '
    ' now populate the array
     SELECT CASE lngDimensions
      CASE 1
      ' populate 1 dimensional array
        FOR lngR = LBOUND(a_strData1,1) TO UBOUND(a_strData1,1)
          a_strData2(lngR) = a_strData1(lngR)
        NEXT lngR
        '
      CASE 2
      ' populate 2 dimensional array
        FOR lngR = LBOUND(a_strData1,1) TO UBOUND(a_strData1,1)
          FOR lngC = LBOUND(a_strData1,2) TO UBOUND(a_strData1,2)
            a_strData2(lngR,lngC) = a_strData1(lngR,lngC)
          NEXT lngC
        NEXT lngR

     END SELECT
    '
    FUNCTION = %TRUE
  CATCH
  ' handle any errors
    strError = ERROR$
    FUNCTION = %FALSE
  FINALLY
  END TRY
END FUNCTION
