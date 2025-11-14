' SQLite_lib.inc
' sqlite routines
'
DECLARE FUNCTION sqlite3_open LIB "sqlite3.dll" ALIAS "sqlite3_open" _
                (BYVAL filename AS STRING, _
                 BYREF ppDb AS LONG) AS LONG
                 '
DECLARE FUNCTION sqlite3_close LIB "sqlite3.dll" ALIAS "sqlite3_close" _
                (BYVAL pDb AS LONG) AS LONG
                '
DECLARE FUNCTION sqlite3_exec LIB "sqlite3.dll" ALIAS "sqlite3_exec" _
                (BYVAL pDb AS LONG, _
                 BYVAL sql AS STRING, _
                 BYVAL callback AS LONG, _
                 BYVAL pArg AS LONG, _
                 BYREF pzErrMsg AS LONG) AS LONG
                 '
DECLARE FUNCTION sqlite3_prepare_v2 LIB "sqlite3.dll"  _
         ALIAS "sqlite3_prepare_v2" _
        (BYVAL pDb AS LONG, _
         BYVAL zSql AS STRING, _
         BYVAL nByte AS LONG, _
         BYREF ppStmt AS LONG, _
         BYREF pzTail AS LONG) AS LONG
         '
DECLARE FUNCTION sqlite3_step LIB "sqlite3.dll" _
         ALIAS "sqlite3_step" _
         (BYVAL pStmt AS LONG) AS LONG
          '
DECLARE FUNCTION sqlite3_column_text LIB "sqlite3.dll" _
         ALIAS "sqlite3_column_text" _
         (BYVAL pStmt AS LONG, BYVAL iCol AS LONG) AS LONG
         '
DECLARE FUNCTION sqlite3_column_int LIB "sqlite3.dll" _
         ALIAS "sqlite3_column_int" _
         (BYVAL pStmt AS LONG, BYVAL iCol AS LONG) AS LONG
         '
DECLARE FUNCTION sqlite3_finalize LIB "sqlite3.dll" _
         ALIAS "sqlite3_finalize" _
         (BYVAL pStmt AS LONG) AS LONG
         '
DECLARE FUNCTION sqlite3_errmsg LIB "sqlite3.dll" _
         ALIAS "sqlite3_errmsg" _
         (BYVAL pDb AS LONG) AS STRING
         '
DECLARE FUNCTION sqlite3_column_count LIB "sqlite3.dll" _
         ALIAS "sqlite3_column_count" _
         (BYVAL pStmt AS LONG) AS LONG
         '
DECLARE FUNCTION sqlite3_column_name LIB "sqlite3.dll" _
         ALIAS "sqlite3_column_count" _
         (BYVAL pStmt AS LONG, _
          BYVAL iCol AS LONG) AS DWORD
          '
DECLARE FUNCTION sqlite3_free LIB "sqlite3.dll" _
         ALIAS "sqlite3_free" _
         (BYVAL x AS LONG) AS LONG

%SQLite_OK    = 0         ' sql command successful
%SQLite_ROW   = 100       ' row returned
%SQLite_DONE  = 101       ' no more rows to read
'
FUNCTION funCreateDB(strDB AS STRING, _
                     lngDB AS LONG, _
                     strError AS STRING) AS LONG
' create a SQLite database
' strDB is the path and name of the DB
' lngDB is the DB handle passed back to the calling routine
'
' this routine is intended to create a new database
' and return true if it have been created and false if it already exists
  LOCAL lngRC AS LONG
  '
  IF ISTRUE ISFILE(strDB) THEN
  ' file already exists
    strError = "File already exists"
    FUNCTION = %FALSE
    EXIT FUNCTION
  END IF
  '
  ' no file exists so create it
  lngRC = sqlite3_open(strDB, lngDB)
  '
  IF lngRC = %SQLite_OK THEN
  ' no errors
    FUNCTION = %TRUE
  ELSE
  ' pick up error message
    strError = sqlite3_errmsg(lngDB)
    FUNCTION = %FALSE
  END IF
  '
END FUNCTION
'
FUNCTION funLog(strData AS STRING) AS LONG
' log details
  LOCAL lngFile AS LONG
  '
  #IF %DEF(%PB_CC32)
    CON.STDOUT strData
  #ENDIF
  '
  lngFile = FREEFILE
  '
  TRY
    OPEN $log FOR APPEND AS #lngFile
      PRINT #lngFile, strData
  CATCH
  FINALLY
    CLOSE #lngFile
  END TRY
  '
END FUNCTION
'
FUNCTION funOpenDB(strDB AS STRING, _
                   lngDB AS LONG, _
                   strError AS STRING) AS LONG
' open an existing DB
  LOCAL lngRC AS LONG
  '
  lngRC = sqlite3_open(strDB, lngDB)
  '
  IF lngRC = %SQLite_OK THEN
  ' no errors on DB open
    FUNCTION = %TRUE
  ELSE
    strError = sqlite3_errmsg(lngDB)
    FUNCTION = %FALSE
  END IF
  '
END FUNCTION
'
FUNCTION funExecuteSQL(lngDB AS LONG, _
                       strSQL AS STRING, _
                       strError AS STRING) AS LONG
' execute sql statement that returns no data
  LOCAL lngRC AS LONG      ' return code
  LOCAL lngErrMsg AS LONG  ' error message
  LOCAL ptrErrMsg AS ASCIIZ PTR   ' pointer for the error message
  '
  lngRC = sqlite3_exec(lngDB,strSQL,0,0,lngErrMsg)
  '
  IF lngRC = %SQLite_OK THEN
    FUNCTION = %TRUE
    strError = ""
  ELSE
    ptrErrMsg = lngErrMsg
    strError = @ptrErrMsg
    sqlite3_free(ptrErrMsg)
    FUNCTION = %FALSE
  END IF
  '
END FUNCTION
'
FUNCTION funCloseDB(lngDB AS LONG, _
                    strError AS STRING) AS LONG
' now close the DB
  LOCAL lngRC AS LONG
  '
  lngRC = sqlite3_close(lngDB)
  IF lngRC <> %SQLite_OK THEN
    strError = "Problem closing DB " & _
               sqlite3_errmsg(lngDB)
    FUNCTION = %FALSE
  ELSE
    strError = ""
    FUNCTION = %TRUE
  END IF
  '
END FUNCTION
'
FUNCTION funRecordsetAsArray(lngDB AS LONG, _
                             strSQL AS STRING, _
                             BYREF a_strData() AS STRING, _
                             strError AS STRING, _
                             OPTIONAL lngSkipHeaders AS LONG) AS LONG
  LOCAL lngRC AS LONG             ' return code
  LOCAL lngErrMsg AS LONG         ' error message
  LOCAL lngStatementID AS LONG    ' statement ID
  LOCAL lngTail AS LONG           ' unused here
  '
  DIM a_strData() AS STRING       ' array for data
  DIM a_strHeaders() AS STRING    ' array for the column names
  LOCAL lngColumnsCount AS LONG   ' number of columns
  LOCAL lngColumn AS LONG         ' current column
  LOCAL strColumnName AS STRING   ' column name
  LOCAL lngRowCount AS LONG       ' number of rows
  LOCAL lngRow AS LONG            ' current row
  LOCAL ptrField AS ASCIIZ PTR    ' pointer for field
  '
  LOCAL lngWithHeaders AS LONG    ' get headers?
  '
  IF ISMISSING(lngSkipHeaders) THEN
    lngWithHeaders = %TRUE
  ELSE
    lngWithHeaders = lngSkipHeaders
  END IF
  '
  lngRC = sqlite3_prepare_v2(lngDB,strSQL , -1, _
                             lngStatementID, lngTail)
  '
  IF lngRC <> %SQLITE_OK THEN
    strError = "Unable to prepare select statement - " & _
                strSQL & " " & _
                sqlite3_errmsg(lngDB)
    FUNCTION = %FALSE
    EXIT FUNCTION
  END IF
  '
  ' work out how many columns
  lngColumnsCount = sqlite3_column_count(lngStatementID)
  '
  IF lngColumnsCount = 0 THEN
    strError = "No columns returned"
    sqlite3_finalize lngStatementID
    FUNCTION = %FALSE
    EXIT FUNCTION
  END IF
  '
  REDIM a_strHeaders(lngColumnsCount)
  ' get the column headers
  IF ISTRUE lngWithHeaders THEN
  ' only if we need headers
    funGetHeaders(lngDB,BYREF a_strHeaders(),strSQL)
  END IF
  '
  ' assume minimum of 1000 data rows
  REDIM a_strData(1000,lngColumnsCount) AS STRING
  '
  IF ISTRUE lngWithHeaders THEN
  ' insert column headers?
    FOR lngColumn = 0 TO lngColumnsCount -1
      a_strData(0,lngColumn) = a_strHeaders(lngColumn+1)
    NEXT lngColumn
  END IF
  '
  DO
    lngRC = sqlite3_step(lngStatementID)
    '
    SELECT CASE lngRC
      CASE %SQLite_ROW
      ' pick up data
        INCR lngRowCount
        INCR lngRow
        '
        IF lngRow > UBOUND(a_strData,1) THEN
        ' add on another block of rows
          REDIM PRESERVE a_strData(lngRow + 999,lngColumnsCount)
        END IF
        '
        ' pull every column
        FOR lngColumn = 0 TO lngColumnsCount -1
        ' columns count from 0
          ' pull back column data as string
          ptrField = sqlite3_column_text(lngStatementID, lngColumn)
          ' populate the array
          a_strData(lngRow,lngColumn) = @ptrField
          sqlite3_free(ptrField)
          '
        NEXT lngColumn
        '
      CASE %SQLite_DONE
      ' no more data
      ' trim the array of blank rows
        funArrayTrim_2D(lngRow, a_strData())
        FUNCTION = %TRUE
        EXIT DO
        '
      CASE ELSE
      ' error?
        strError = "Problem reading data - " & strSQL & _
                   " - after row " & FORMAT$(lngRowCount)
        FUNCTION = %FALSE
        EXIT DO
    END SELECT
    '
  LOOP
  '
  ' clean up
  lngRC = sqlite3_finalize(lngStatementID)
  IF lngRC <> %SQLite_OK THEN
    strError = "Warning: sqlite3_finalize lngRC= " & FORMAT$(lngRC)
    FUNCTION = %FALSE
  END IF
  '
END FUNCTION
'
FUNCTION funGetHeaders(lngDB AS LONG, _
                       BYREF a_strHeaders() AS STRING, _
                       strOrigSQL AS STRING) AS LONG
' get the table headers
  LOCAL strError AS STRING
  LOCAL strTable AS STRING
  LOCAL strSQL AS STRING
  '
  ' extract the table name
  strTable = PARSE$(UCASE$(strOrigSQL),"FROM ",2)
  IF INSTR(strTable," ") > 0 THEN
    strTable = PARSE$(strTable," ",1)
  END IF
  '
  strSQL = "select name as ColumnName from pragma_table_info('" & _
            strTable & "');"
            '
  FUNCTION = funRecordsetAsArray(lngDB, _
                                 strSQL, _
                                 BYREF a_strHeaders(), _
                                 strError, _
                                 %FALSE)
                                 '
END FUNCTION
