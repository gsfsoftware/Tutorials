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
    ' now do stuff in the databases


      funLog(strStatus)
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
