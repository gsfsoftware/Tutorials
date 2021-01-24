' Generic SQL tools library
' PB_GenericSQLFunctions.inc

' prep global array for DBs
GLOBAL g_astrDatabases() AS STRING
'
#IF %DEF(%PB_WIN32)
FUNCTION funPopulateGenericComboFromDB(hDlg AS DWORD, _
                                       lngCBO AS LONG, _
                                       strSQL AS STRING, _
                                       strSelection AS STRING, _
                                       lngDB AS LONG, _
                                       strStatus AS STRING, _
                                       OPTIONAL lngStatement AS LONG) AS LONG
' populate the combo box with whats in the SQL resultset
' and set the preselected value
  DIM a_strData() AS STRING
  LOCAL lngS AS LONG
  '
  IF ISTRUE ISMISSING(lngStatement) THEN
    lngS = 1
  ELSE
    lngS = lngStatement
  END IF
  '
  IF ISTRUE funGetGenericSQLData(strSQL, a_strData(),_
                                 lngDB, strStatus, lngS) THEN
  ' we've got the data so populate the combo now
    funPopulateGenericCombo(hDlg,lngCBO,a_strData(), strSelection)
    FUNCTION = %TRUE
  '
  ELSE
    COMBOBOX RESET hDlg, lngCBO
    FUNCTION = %FALSE
  END IF
  '
END FUNCTION
'
FUNCTION funPopulateGenericCombo(hDlg AS DWORD, _
                                 lngCBO AS LONG, _
                                 BYREF a_strData() AS STRING, _
                                 strSelection AS STRING) AS LONG
' populate the combo with whats in the array
' where array is in the format of
' string | long
'
  LOCAL lngR AS LONG
  LOCAL lngDataV AS LONG
  '
  COMBOBOX RESET hDlg, lngCBO
  '
  FOR lngR = 1 TO UBOUND(a_strData)
   'for each row in the array
   ' populate the string in the combo
     COMBOBOX ADD hDlg, lngCBO, PARSE$(a_strData(lngR),"|",1) TO lngDataV
   ' and set the long user value
     COMBOBOX SET USER hDlg, lngCBO,lngDataV,VAL(PARSE$(a_strData(lngR),"|",2))
   '
  NEXT lngR
  '
  IF strSelection <> "" THEN
  ' if preselection has been populated - then find and select it
    COMBOBOX FIND EXACT hDlg, lngCBO,1 , strSelection TO lngDataV
    COMBOBOX SELECT hDlg, lngCBO,lngDataV
  END IF
'
END FUNCTION
#ENDIF
'
FUNCTION funGetGenericSQLData(strSQL AS STRING, _
                              BYREF a_strData() AS STRING, _
                              lngDB AS LONG, _
                              strStatus AS STRING , _
                              OPTIONAL lngStatement AS LONG) AS LONG
' read from the database
' returning the data in an array
  LOCAL lngS AS LONG
  '
  IF ISTRUE ISMISSING(lngStatement) THEN
    lngS = 1
  ELSE
    lngS = lngStatement
  END IF
  '
  LOCAL lngResult AS LONG
  LOCAL lngColumns AS LONG
  LOCAL lngColumn AS LONG
  LOCAL lngRowCount AS LONG
  LOCAL strSQLInfo AS STRING
  LOCAL strValue AS STRING
  '
  lngResult = SQL_Statement(lngDB,lngS,%SQL_STMT_IMMEDIATE,strSQL)
  IF lngResult = %SUCCESS  OR lngResult = %SUCCESS_WITH_INFO THEN
  ' sql parses ok
    DO UNTIL SQL_EndOfData(lngDB,lngS)
    ' loop to get all the data rows
      lngResult = SQL_FetchResult(lngDB,lngS, %NEXT_ROW)
      '
      IF lngResult = %SUCCESS  OR lngResult = %SUCCESS_WITH_INFO THEN
      ' successful query - we have a row
        SQL_ErrorClearAll
        ' how many columns do we have?
        IF lngRowCount = 0 THEN
          lngColumns = SQL_ResultColumnCount(lngDB,lngS)
        END IF
        '
        ' make the array larger
        REDIM PRESERVE a_strData(UBOUND(a_strData)+1) AS STRING
        '
        ' prepare to build up info on the column names
        strSQLInfo = "" ' this will be a | delimited list
        strValue = ""   ' this contains the data
        '
        FOR lngColumn = 1 TO lngColumns
        ' for each column in the recordset
          IF lngRowCount = 0 THEN
            strSQLinfo = strSQLinfo & _
              SQL_ResultColumnInfoStr(lngDB,lngS,lngColumn, _
                                      %RESCOL_LABEL) & "|"
          END IF
          '
          strValue = TRIM$(strValue) &  _
                       SQL_ResultColumnString(lngDB,lngS,lngColumn) & "|"
        '
        NEXT lngColumn
        '
        strSQLinfo = RTRIM$(strSQLinfo,"|")
        strValue = RTRIM$(strValue,"|")
        '
        IF lngRowCount = 0 THEN
        ' store the headers
          REDIM PRESERVE a_strData(UBOUND(a_strData)+1) AS STRING
          a_strData(lngRowCount) = strSQLinfo
        END IF
        '
        INCR lngRowCount
        a_strData(lngRowCount) = strValue
      '
      ELSEIF lngResult = %SQL_NO_DATA THEN
      ' no data to get
        SQL_ErrorClearAll
        strStatus = "No data"
      ELSE
      ' unsuccessful query
      ' Error fetching row
        strStatus = funAllSQLErrors
        EXIT LOOP
      END IF
      '
    '
    LOOP
    '
    FUNCTION = %TRUE
  '
  ELSE
  ' error in sql?
    strStatus = funAllSQLErrors()
    SQL_CloseStatement(lngDB,lngS)
    FUNCTION = %FALSE
    EXIT FUNCTION
  '
  END IF
  '
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
