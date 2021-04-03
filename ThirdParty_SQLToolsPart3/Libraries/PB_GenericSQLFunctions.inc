' Generic SQL tools library
' PB_GenericSQLFunctions.inc

' prep global array for DBs
GLOBAL g_astrDatabases() AS STRING

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
FUNCTION funUserOpenDB(lngDB AS LONG, _
                       strConnectionString AS STRING, _
                       strStatus AS STRING  ) AS LONG
' connect to database
  LOCAL lngResult AS LONG
  '
  ' attempt to open the database
  lngResult = SQL_OpenDatabase(lngDB, _
                               strConnectionString, _
                               %PROMPT_TYPE_NOPROMPT)
                               '
  IF lngResult = %SUCCESS  OR lngResult = %SUCCESS_WITH_INFO THEN
   ' database opened successfully
     strStatus = g_astrDatabases(lngDB) & " DB Opened successfully"
     FUNCTION = %TRUE
  ELSE
  ' FAILED to open Database
    strStatus = g_astrDatabases(lngDB) & " unable to open " & _
                $CRLF & funAllSQLErrors()
    FUNCTION = %FALSE
  END IF
'
END FUNCTION
'
FUNCTION funUserCloseDB(lngDB AS LONG, _
                        strStatus AS STRING ) AS LONG
                        '
  LOCAL lngResult AS LONG
  ' close the Database
  lngResult = SQL_CloseDatabase(lngDB)
  '
  IF lngResult = %SUCCESS  OR lngResult = %SUCCESS_WITH_INFO THEN
   ' database opened successfully
      strStatus = g_astrDatabases(lngDB) & " DB Closed successfully"
      FUNCTION = %TRUE
  ELSE
  ' FAILED to close Database
    strStatus = g_astrDatabases(lngDB) & " unable to close" & _
                $CRLF & funAllSQLErrors()
    FUNCTION = %FALSE
  END IF
END FUNCTION
'
