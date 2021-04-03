' Generic SQL tools library
' PB_GenericSQLFunctions.inc

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
