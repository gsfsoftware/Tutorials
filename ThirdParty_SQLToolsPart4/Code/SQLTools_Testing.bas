#COMPILE EXE
#DIM ALL
#DEBUG ERROR ON

' include the common display library
#INCLUDE "win32api.inc"
#INCLUDE "..\Libraries\CommonDisplay.inc"

' add the sql tools libraries
#INCLUDE "..\SQL_Libraries\SQLT3.INC"
#LINK "..\SQL_Libraries\SQLT3Pro.PBLIB"
'#INCLUDE "\SQLTOOLS\SQLT3ProDLL.INC" 'SQL Tools Pro
'
'#LINK    "\SQLTOOLS\SQLT3Std.PBLIB"  'SQL Tools Standard
'#INCLUDE "\SQLTOOLS\SQLT3StdDLL.INC" 'SQL Tools Standard

' add the Generic SQL tools libraries
#INCLUDE "..\Libraries\PB_GenericSQLFunctions.inc"
'
' constants for DB handles
%FoodDB = 1
%YT_Projects = 2
'
FUNCTION PBMAIN () AS LONG
' the main PB function that is the first to be executed
  funPrepOutput("SQL Tools",0,0,40,120)
  '
  funLog("Walk through on SQL Tools")
  '
  REDIM g_astrDatabases(2) AS STRING
  g_astrDatabases(1) = "FoodStore"
  g_astrDatabases(2) = "A_YouTubeProjects"

  '
  ' check authorization to use SQLPro.dll
  IF SQL_Authorize(%MY_SQLT_AUTHCODE) <> %SUCCESS THEN
    funLog("Licence problem")
    funWait()
    EXIT FUNCTION
  END IF
  '
  CALL SQL_Init
  '
  ' now we can connet to a DB
  LOCAL strConnectionString AS STRING
  LOCAL lngResult AS LONG
  LOCAL strSQL AS STRING
  LOCAL lngR AS LONG
  LOCAL lngColumn AS LONG
  '
'  strConnectionString = "DRIVER=SQL Server;" & _
'                        "UID=SQLUserName;" & _
'                        "PWD=password;" & _
'                        "DATABASE=FoodStore;" & _
'                        "SERVER=Octal\SqlExpress"
                        '
  strConnectionString = "DRIVER=SQL Server;" & _
                        "Trusted_Connection=Yes;" & _
                        "DATABASE=" & _
                        g_astrDatabases(%FoodDB) & ";" & _
                        "SERVER=Octal\SqlExpress"
                        '
  LOCAL strStatus AS STRING
  IF ISTRUE funUserOpenDB(%FoodDB, _
                          strConnectionString, _
                          strStatus) THEN
  ' db opened ok
    funLog(strStatus)
    '
    ' now do stuff with the database
    ' connect to second db
    strConnectionString = "DRIVER=SQL Server;" & _
                        "Trusted_Connection=Yes;" & _
                        "DATABASE=" & _
                        g_astrDatabases(%YT_Projects) & ";" & _
                        "SERVER=Octal\SqlExpress"
                        '
    IF ISTRUE funUserOpenDB(%YT_Projects, _
                            strConnectionString, _
                            strStatus) THEN
    ' db opened ok
      funLog(strStatus)
    ' now do stuff in the databases
      '
      DIM a_strData() AS STRING
      LOCAL lngStatement AS LONG
      '
      lngStatement = 1
      '
      'strSQL = "SELECT [idxFoodTypes] ,[FoodType] " & _
      '         "FROM [dbo].[tbl_FoodType]"
               '
'      strSQL = "SELECT top 5 [FoodItemName], count(*) as [Total] " & _
'               "FROM [dbo].[tbl_FoodItems] " & _
'               "group by [FoodItemName] " & _
'               "order by count(*) desc"
'               '
      strSQL = "EXEC [dbo].[sprGetTestData]"
      '
      IF ISTRUE funGetGenericSQLData(strSQL, _
                                     a_strData(), _
                                     %FoodDB, _
                                     strStatus , _
                                     lngStatement) THEN
      ' data is now in the array
        FOR lngR = 0 TO UBOUND(a_strData)
        ' to get just one column use the parse command
          lngColumn = 1
          funLog("-> " & PARSE$(a_strData(lngR),"|",lngColumn))
        ' to get all columns {including the delimiter}
        ' funLog("-> " & a_strData(lngR))
        NEXT lngR
      '
      ELSE
        funLog("Processing fails " & strStatus)
      END IF
      '
    ELSE
      funLog(strStatus)
    END IF
    '
  ELSE
  ' db didnt open ok
    funLog(strStatus)
  END IF
  '
  IF ISTRUE funUserCloseDB(%FoodDB, _
                           strStatus) THEN
    funLog(strStatus)
  ELSE
    funLog(strStatus)
  END IF
  '
  IF ISTRUE funUserCloseDB(%YT_Projects, _
                           strStatus) THEN
    funLog(strStatus)
  ELSE
    funLog(strStatus)
  END IF
  '
  lngResult = SQL_Shutdown ' close all open DBs and shutdown SQL tools
  '
  funWait()
  '
END FUNCTION
'
FUNCTION funProcess(strStatus AS STRING) AS LONG
' read from the database
  LOCAL strSQL AS STRING
  LOCAL lngResult AS LONG
  LOCAL lngColumns AS LONG
  LOCAL lngColumn AS LONG
  LOCAL lngRowCount AS LONG
  LOCAL strSQLInfo AS STRING
  LOCAL strValue AS STRING
  '
  strSQL = "SELECT [idxFoodTypes] ,[FoodType] " & _
           "FROM [dbo].[tbl_FoodType]"
           '
  lngResult = SQL_Statement(%FoodDB,1,%SQL_STMT_IMMEDIATE,strSQL)
  IF lngResult = %SUCCESS  OR lngResult = %SUCCESS_WITH_INFO THEN
  ' sql parses ok
    DO UNTIL SQL_EndOfData(%FoodDB,1)
    ' loop to get all the data rows
      lngResult = SQL_FetchResult(%FoodDB,1, %NEXT_ROW)
      '
      IF lngResult = %SUCCESS  OR lngResult = %SUCCESS_WITH_INFO THEN
      ' successful query - we have a row
        SQL_ErrorClearAll
        ' how many columns do we have?
        IF lngRowCount = 0 THEN
          lngColumns = SQL_ResultColumnCount(%FoodDB,1)
        END IF
        '
        ' prepare to build up info on the column names
        strSQLInfo = "" ' this will be a | delimited list
        strValue = ""   ' this contains the data
        '
        FOR lngColumn = 1 TO lngColumns
        ' for each column in the recordset
          IF lngRowCount = 0 THEN
            strSQLinfo = strSQLinfo & _
              SQL_ResultColumnInfoStr(%FoodDB,1,lngColumn, _
                                      %RESCOL_LABEL) & "|"
          END IF
          '
          strValue = TRIM$(strValue) &  _
                       SQL_ResultColumnString(%FoodDB,1,lngColumn) & "|"
        '
        NEXT lngColumn
        '
        strSQLinfo = RTRIM$(strSQLinfo,"|")
        strValue = RTRIM$(strValue,"|")
        '
        IF lngRowCount = 0 THEN
          funLog("Column headers = " & strSQLInfo)
        END IF
        '
        INCR lngRowCount
        funLog("Data = " & strValue)
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
    SQL_CloseStatement(%FoodDB,1)
    FUNCTION = %FALSE
    EXIT FUNCTION
  '
  END IF
  '
END FUNCTION
