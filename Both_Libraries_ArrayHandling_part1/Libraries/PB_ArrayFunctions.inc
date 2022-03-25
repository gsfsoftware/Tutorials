' PB_ArrayFunctions.inc
'
' funArraySave_1D  - save a one dimensional file while
'                    changing the delimeter
'
' funArraySave_2D  - save a two dimensional file with
'                    a delimeter
'
' funCloneArray - create a new copy of an array
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
