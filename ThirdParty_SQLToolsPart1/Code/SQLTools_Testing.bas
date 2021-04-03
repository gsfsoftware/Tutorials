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
FUNCTION PBMAIN () AS LONG
' the main PB function that is the first to be executed
  funPrepOutput("SQL Tools",0,0,40,120)
  '
  funLog("Walk through on SQL Tools")
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
  strConnectionString = "DRIVER=SQL Server;" & _
                        "UID=SQLUserName;" & _
                        "PWD=password;" & _
                        "DATABASE=FoodStore;" & _
                        "SERVER=Octal\SqlExpress"
                        '
  strConnectionString = "DRIVER=SQL Server;" & _
                        "Trusted_Connection=Yes;" & _
                        "DATABASE=FoodStores;" & _
                        "SERVER=Octal\SqlExpress"
                        '
  lngResult = SQL_OpenDB(strConnectionString, _
                         %PROMPT_TYPE_NOPROMPT)
                         '
  SELECT CASE lngResult
    CASE %SQL_SUCCESS , %SQL_SUCCESS_WITH_INFO
    ' connected ok
      funLog ("connected ok")
    CASE ELSE
    ' not connected
      funLog ("not connected" & $CRLF & funAllSQLErrors())
  END SELECT
  '
  lngResult = SQL_CloseDB  ' close current DB
  lngResult = SQL_Shutdown ' close all open DBs and shutdown SQL tools

  '
  funWait()
  '
END FUNCTION
