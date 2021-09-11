'  generic SQL library
'  PB_GenericSQLFunctions.inc

FUNCTION funReturnSingleValueSQLData(strSQL AS STRING, strError AS STRING, lngDB AS LONG) AS STRING
' this function runs the sql and returns one string variable
  DIM a_strData() AS STRING
  '
  IF ISTRUE funGetGenericData(strSQL ,BYREF a_strData() , lngDB, strError) THEN
    FUNCTION = PARSE$(a_strData(1),"|",1)
  ELSE
    FUNCTION = ""
  END IF
'
END FUNCTION

FUNCTION funGetGenericData(strSQL AS STRING,BYREF a_strData() AS STRING , lngDB AS LONG, _
                           OPTIONAL strInfo AS STRING) AS LONG
' get data from sql and put in generic array
  '
  LOCAL strError AS STRING
  LOCAL lngRows AS LONG
  '
  ERASE a_strData()
  IF ISTRUE funGetSQLResultset(strSQL, strError, a_strData(),lngDB,1) THEN
    '
    IF UBOUND(a_strData) = -1 THEN
    ' empty result set
      FUNCTION = %FALSE
      strInfo = strError
    ELSE
      lngRows = UBOUND(a_strData)
      FUNCTION = %TRUE
    END IF
  ELSE
    strInfo = strError
    FUNCTION = %FALSE
  END IF
  '
END FUNCTION
'
FUNCTION funRunSQL(strSQL AS STRING,strError AS STRING, lngDB AS LONG) AS LONG
'run the sql
'
  DIM lngResult AS LONG
  DIM strValue AS STRING
  '
  lngResult = SQL_Statement(lngDB,1,%SQL_STMT_IMMEDIATE, strSQL)
  '
  IF lngResult = %SUCCESS  OR lngResult = %SUCCESS_WITH_INFO THEN
    FUNCTION = %TRUE
  ELSEIF lngResult = %SQL_NO_DATA THEN
    FUNCTION = %TRUE
    'OutputToConsole "No data"
  ELSE
    FUNCTION = %FALSE
   ' OutputToConsole "unable to parse sql"
    strError = funAllSQLErrors
  END IF
  '
  'close SQL statement
  CALL SQL_CloseStatement(lngDB,1)
END FUNCTION
'
FUNCTION funGetSQLLongVarchar(strSQL AS STRING, strError AS STRING,lngDBNumber AS LONG, OPTIONAL lngStatmentNo AS LONG) AS STRING
' get a single big string back from a stored proc or sql cmd
  LOCAL lngResult AS LONG
  LOCAL strValue AS STRING
  '
  ' handle default database
  IF lngDBNumber = 0 THEN EXIT FUNCTION
  IF lngStatmentNo = 0 THEN lngStatmentNo = 1
  lngResult = SQL_Statement(lngDBNumber,lngStatmentNo,%SQL_STMT_IMMEDIATE, strSQL)
  '
  IF lngResult = %SUCCESS  OR lngResult = %SUCCESS_WITH_INFO THEN
    lngResult = SQL_FetchResult(lngDBNumber,lngStatmentNo, %NEXT_ROW)
    IF lngResult = %SUCCESS  OR lngResult = %SUCCESS_WITH_INFO THEN
    ' successful run
      strValue = SQL_ResultColumnStr(lngDBNumber,lngStatmentNo,1)
      FUNCTION = strValue
    ELSEIF lngResult = %SQL_NO_DATA THEN
    ' No data
      SQL_ErrorClearAll
      strError = "No data"
      FUNCTION = ""
    END IF
    '
  ELSE
   ' "unable to parse sql"
    strError = funAllSQLErrors
    FUNCTION = ""
  END IF
  '
  ' close SQL statement
  CALL SQL_CloseStatement(lngDBNumber,lngStatmentNo)
  '
END FUNCTION
'
FUNCTION funGetSQLResultset(strSQL AS STRING, strError AS STRING, BYREF a_strData() AS STRING, _
                            OPTIONAL lngDBnumber AS LONG, OPTIONAL lngStatmentNo AS LONG) AS LONG
'run the sql and return the results
'
  DIM lngResult AS LONG
  DIM strValue AS STRING
  DIM lngR AS LONG
  DIM strSQLinfo AS STRING
  DIM lngCount AS LONG
  '
  strError = ""
  strSQLinfo = ""
  lngCount = 0
  '
  ' handle default database
  IF lngDBNumber = 0 THEN lngDBNumber = 1
  IF lngStatmentNo = 0 THEN lngStatmentNo = 1
  '
  lngResult = SQL_Statement(lngDBNumber,lngStatmentNo,%SQL_STMT_IMMEDIATE, strSQL)
  '
  IF lngResult = %SUCCESS  OR lngResult = %SUCCESS_WITH_INFO THEN
    DO UNTIL  SQL_EndOfData(lngDBNumber,lngStatmentNo)
      lngResult = SQL_FetchResult(lngDBNumber,lngStatmentNo, %NEXT_ROW)
      IF lngResult = %SUCCESS  OR lngResult = %SUCCESS_WITH_INFO THEN
      ' successful run
        INCR lngCount
        SQL_ErrorClearAll
        strValue = ""
        ' pick up the data
        '
        FOR lngR = 1 TO SQL_ResultColumnCount(lngDBNumber,lngStatmentNo)
          IF lngCount = 1 THEN
            strSQLinfo = strSQLinfo & SQL_ResultColumnInfoStr(lngDBNumber,lngStatmentNo,lngR, %RESCOL_LABEL) & "|"
          END IF
          '
          strValue = TRIM$(strValue) & SQL_ResultColumnText(lngDBNumber,lngStatmentNo,lngR) & "|"
        NEXT lngR
        '
        strValue = TRIM$(strValue)
        strValue = RTRIM$(strValue,"|")
        '
        IF lngCount = 1 THEN
          REDIM PRESERVE a_strData(UBOUND(a_strData)+1) AS STRING
          strSQLinfo = RTRIM$(strSQLinfo,"|")
          a_strData(UBOUND(a_strData)) = strSQLinfo
        ELSE
        END IF
        '
        REDIM PRESERVE a_strData(UBOUND(a_strData)+1) AS STRING
        strValue = RTRIM$(strValue)
'
        REPLACE "[ CHR$(0) ]" WITH "" IN strValue
        REPLACE "[ CHR$(4) ]" WITH CHR$(4) IN strValue
        REPLACE "[ CHR$(5) ]" WITH CHR$(5) IN strValue
        REPLACE "[ CHR$(8) ]" WITH CHR$(8) IN strValue
        REPLACE "[ CHR$(11) ]" WITH CHR$(11) IN strValue
        REPLACE "[ CHR$(12) ]" WITH CHR$(12) IN strValue
        REPLACE "[ CHR$(19) ]" WITH CHR$(19) IN strValue
        REPLACE "[ CHR$(29) ]" WITH CHR$(129) IN strValue
        REPLACE "[ CHR$(31) ]" WITH CHR$(31) IN strValue
        REPLACE "[ CHR$(128) ]" WITH CHR$(128) IN strValue
        REPLACE "[ CHR$(132) ]" WITH CHR$(132) IN strValue
        REPLACE "[ CHR$(135) ]" WITH CHR$(135) IN strValue
        REPLACE "[ CHR$(138) ]" WITH CHR$(138) IN strValue
        REPLACE "[ CHR$(139) ]" WITH CHR$(139) IN strValue
        REPLACE "[ CHR$(142) ]" WITH CHR$(142) IN strValue
        REPLACE "[ CHR$(143) ]" WITH CHR$(143) IN strValue
        REPLACE "[ CHR$(148) ]" WITH CHR$(148) IN strValue
        REPLACE "[ CHR$(150) ]" WITH CHR$(150) IN strValue
        REPLACE "[ CHR$(152) ]" WITH CHR$(152) IN strValue
        REPLACE "[ CHR$(153) ]" WITH CHR$(153) IN strValue
        REPLACE "[ CHR$(154) ]" WITH CHR$(154) IN strValue
        REPLACE "[ CHR$(158) ]" WITH CHR$(158) IN strValue
        REPLACE "[ CHR$(160) ]" WITH CHR$(160) IN strValue
        REPLACE "[ CHR$(161) ]" WITH CHR$(161) IN strValue
        REPLACE "[ CHR$(163) ]" WITH CHR$(163) IN strValue
        REPLACE "[ CHR$(165) ]" WITH CHR$(165) IN strValue
        REPLACE "[ CHR$(167) ]" WITH CHR$(167) IN strValue
        REPLACE "[ CHR$(168) ]" WITH CHR$(168) IN strValue
        REPLACE "[ CHR$(169) ]" WITH CHR$(169) IN strValue
        REPLACE "[ CHR$(172) ]" WITH CHR$(172) IN strValue
        REPLACE "[ CHR$(173) ]" WITH CHR$(173) IN strValue
        REPLACE "[ CHR$(174) ]" WITH CHR$(174) IN strValue
        REPLACE "[ CHR$(178) ]" WITH CHR$(178) IN strValue
        REPLACE "[ CHR$(180) ]" WITH CHR$(180) IN strValue
        REPLACE "[ CHR$(181) ]" WITH CHR$(181) IN strValue
        REPLACE "[ CHR$(184) ]" WITH CHR$(184) IN strValue
        REPLACE "[ CHR$(190) ]" WITH CHR$(190) IN strValue
        REPLACE "[ CHR$(193) ]" WITH CHR$(193) IN strValue
        REPLACE "[ CHR$(197) ]" WITH CHR$(197) IN strValue
        REPLACE "[ CHR$(198) ]" WITH CHR$(198) IN strValue
        REPLACE "[ CHR$(199) ]" WITH CHR$(199) IN strValue
        REPLACE "[ CHR$(205) ]" WITH CHR$(205) IN strValue
        REPLACE "[ CHR$(211) ]" WITH CHR$(211) IN strValue
        REPLACE "[ CHR$(212) ]" WITH CHR$(212) IN strValue
        REPLACE "[ CHR$(213) ]" WITH CHR$(213) IN strValue
        REPLACE "[ CHR$(214) ]" WITH CHR$(214) IN strValue
        REPLACE "[ CHR$(226) ]" WITH CHR$(226) IN strValue
        REPLACE "[ CHR$(229) ]" WITH CHR$(229) IN strValue
        REPLACE "[ CHR$(231) ]" WITH CHR$(231) IN strValue
        REPLACE "[ CHR$(233) ]" WITH CHR$(233) IN strValue
        REPLACE "[ CHR$(237) ]" WITH CHR$(237) IN strValue
        REPLACE "[ CHR$(243) ]" WITH CHR$(243) IN strValue
        REPLACE "[ CHR$(244) ]" WITH CHR$(244) IN strValue
        REPLACE "[ CHR$(246) ]" WITH CHR$(246) IN strValue
        REPLACE "[ CHR$(252) ]" WITH CHR$(252) IN strValue
'
        '
        a_strData(UBOUND(a_strData)) = strValue
        '
      ELSEIF lngResult = %SQL_NO_DATA THEN
        ' No data
        SQL_ErrorClearAll
        strError = "No data"
        strValue = "0"
      ELSE
      ' "Error fetching row"
        strError = funAllSQLErrors
        EXIT LOOP
      END IF
    LOOP
  ELSE
    ' "unable to parse sql"
    strError = funAllSQLErrors
    CALL SQL_CloseStatement(lngDBNumber,lngStatmentNo)
    EXIT FUNCTION
  END IF
  '
  FUNCTION = %TRUE
  ' close SQL statement
  CALL SQL_CloseStatement(lngDBNumber,lngStatmentNo)
  '
END FUNCTION
'
FUNCTION funEscapeApostrophe(BYVAL strData AS STRING) AS STRING
  ' Handle single ' in sql strings
  REPLACE "'" WITH "''" IN strData
  FUNCTION = strData
END FUNCTION
'
FUNCTION funAllSQLErrors() AS STRING
' return all errors
  DIM strText AS STRING
  DIM strErrors AS STRING
  '
  WHILE ISTRUE SQL_ErrorPending
  'process and clear error message(s)
    strText = SQL_ErrorQuickOne
    strErrors = strErrors & MID$(strText,82) & $CRLF
    REPLACE "[Microsoft][ODBC SQL Server Driver][SQL Server]" WITH "" IN strErrors
    REPLACE "[Microsoft][ODBC SQL Server Driver]" WITH "" IN strErrors
  WEND
  '
  FUNCTION = strErrors
END FUNCTION
'
FUNCTION funUserOpenDB(lngDBNumber AS LONG, strServer AS STRING, strDBaseName AS STRING, _
                       strConnectionString AS STRING) AS LONG
   ' opens a connection to a database specified on the server sprecified
   ' returns %TRUE if database opens successfully, otherwise returns %FALSE
   '
   ' **********    USEAGE:    lngResult = funUserOpenDB()
 LOCAL lngResult AS LONG
 LOCAL strerror AS STRING
  '
  ' attempt to open the database
   lngResult = SQL_OpenDatabase(lngDBNumber, strConnectionString, %PROMPT_TYPE_NOPROMPT)
   ' check result of opening the database
   IF lngResult = %SUCCESS  OR lngResult = %SUCCESS_WITH_INFO THEN
   ' database opened successfully
      FUNCTION = %TRUE
   ELSE
   ' FAILED to open Database
     strError = funAllSQLErrors()
      FUNCTION = %FALSE
   END IF
   '
END FUNCTION

'
FUNCTION funCloseDBbyNumber(lngNumber AS LONG) AS LONG

   ' close the connection to the database
   '
   ' *************   USAGE :    lngResult = funCloseDB()
   '
 DIM lngResult AS LONG
   '
   ' close the Database
   lngResult = SQL_CloseDatabase(lngNumber)
   ' check result of closing Database
   IF lngResult = %SUCCESS  OR lngResult = %SUCCESS_WITH_INFO THEN
      FUNCTION = %TRUE
   ELSE
      ' FAILED to close Database
      FUNCTION = %FALSE
   END IF
   '
END FUNCTION
'
FUNCTION funUNSQLDate(strDate AS STRING) AS STRING
' take input as yyyy-mm-dd and return dd/mm/yyyy for sql queries
  FUNCTION = RIGHT$(strDate,2) & "/" & MID$(strDate,6,2) & "/" & LEFT$(strDate,4)
'
END FUNCTION

'
FUNCTION funSQLDate(strDate AS STRING) AS STRING
' take input as dd/mm/yyyy and return yyyy-mm-dd for sql queries
  FUNCTION = RIGHT$(strDate,4) & "-" & MID$(strDate,4,2) & "-" & LEFT$(strDate,2)
'
END FUNCTION
'
FUNCTION funSQLDateAndTime(strSQLdate AS STRING) AS STRING
' take input as dd/mm/yyyy hh:mm:ss.000 and return yyyy-mm-dd hh:mm:ss.000 for sql queries
  FUNCTION = MID$(strSQLdate,7,4) & "-" & MID$(strSQLdate,4,2) & "-" & LEFT$(strSQLdate,2) & MID$(strSQLdate,11)
END FUNCTION
'
FUNCTION funSQLDateNULL(strDate AS STRING) AS STRING
' take input as dd/mm/yyyy and return 'yyyy-mm-dd' or NULL for sql queries
  IF LEN(strDate) > 0 THEN
  ' handle correctly formattted dates
    FUNCTION = "'" & RIGHT$(strDate,4) & "-" & MID$(strDate,4,2) & "-" & LEFT$(strDate,2) & "'"
  ELSE
  ' handle blank dates
    FUNCTION = "NULL"
  END IF
'
END FUNCTION
'
FUNCTION funCloseSQLTools() AS LONG
' shut down  the SQL Tools dll
  LOCAL lngResult AS LONG
  lngResult = SQL_Shutdown()
  ' check result of Shutting down SQL Tools
  IF lngResult = %SUCCESS  OR lngResult = %SUCCESS_WITH_INFO THEN
  ' Successfully Closed Database and shut down SQL Tools
    FUNCTION = %TRUE
  ELSE
  ' FAILED to Shut down SQL Tools
  ' append error to SQL error log of the application calling the function.
    funAppendToFile(EXE.PATH$ & EXE.NAME$ & "_SQLError.log" , _
                       "Error trying to Shut Down SQL Tools: " & $CRLF & SQL_ErrorQuickAll & $CRLF)
    FUNCTION = %FALSE
  END IF
  '
END FUNCTION
'
FUNCTION funGetDataFromColumn(BYREF a_strData() AS STRING , lngR AS LONG, strColumnName AS STRING) AS STRING
' return the data from a row in a sql query array
  LOCAL lngColumnFound AS LONG
  LOCAL strHeaders AS STRING
  LOCAL strLocalColumnName AS STRING
  '
  strLocalColumnName = UCASE$(strColumnName)
  '
  strHeaders = UCASE$(a_strData(0)) ' force to upper case for case independant search
  lngColumnFound = funParseFind(strHeaders, "|", strLocalColumnName)
  '
  IF lngColumnFound > 0 THEN
  ' return the data in the column
    FUNCTION = PARSE$(a_strData(lngR),"|",lngColumnFound)
  ELSE
  ' nothing found
    FUNCTION = ""
  END IF
  '
END FUNCTION
