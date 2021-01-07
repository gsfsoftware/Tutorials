#COMPILE EXE
#DIM ALL

#DEBUG ERROR ON

#INCLUDE "Win32api.inc"

#INCLUDE "..\Libraries\DateFunctions.inc"
#INCLUDE "..\Libraries\PC_info.inc"
#INCLUDE "..\Libraries\DriveInfo.inc"     ' new library
#INCLUDE "..\Libraries\PB_FileHandlingroutines.inc"

#INCLUDE "..\Libraries\PB_Processes.inc"
'
' add the sql tools libraries
#INCLUDE "..\SQL_Libraries\SQLT3.INC"
#LINK "..\SQL_Libraries\SQLT3Pro.PBLIB"
'
' add the Generic SQL tools libraries
#INCLUDE "..\Libraries\PB_GenericSQLFunctions.inc"
'
GLOBAL g_strLog AS STRING            ' log for this process
GLOBAL g_lngTotalProcessors AS LONG  ' global for number of processors
GLOBAL g_astrDatabases() AS STRING   ' array to hold list of SQL dbs
'
' new globals for the disk server location
GLOBAL g_strDiskServer AS STRING
GLOBAL g_strDriveLetter AS STRING
'
%DB = 1  ' set the database handle
'
FUNCTION PBMAIN () AS LONG
  '
  g_strDiskServer = "Octal002"
  g_strDriveLetter = "D"
  '
  IF funProcessCount(EXE.NAMEX$)>1 THEN
  ' more than one version on this running ?
    CON.STDOUT "Already running"
    funExitApp
    EXIT FUNCTION
  END IF
  '
  COLOR 10,0  ' set forground colour to green
  ' define the log file
  g_strLog = EXE.PATH$ & EXE.NAME$ & "_logging.log"
  '
  TRY
    KILL g_strLog
  CATCH
  FINALLY
  END TRY
  '
  ' get the total number of processing cores on
  ' this machine
  g_lngTotalProcessors = funCPUcount()
  '
  IF SQL_Authorize(%MY_SQLT_AUTHCODE) <> %SUCCESS THEN
    funLog("Licence problem")
    FUNCTION = %FALSE
    EXIT FUNCTION
  END IF
  '
  ' first initialise the SQL library
  CALL SQL_Init
  '
  ' now we can connect to a DB
  LOCAL strConnectionString AS STRING
  LOCAL lngResult AS LONG
  LOCAL strDBName AS STRING
  LOCAL strStatus AS STRING
  LOCAL strSQLUserName AS STRING
  LOCAL strPassword AS STRING
  '
  strSQLUserName = "Chronos"
  strPassword = "wombat123"
  '
  REDIM g_astrDatabases(1)
  g_astrDatabases(%DB) = "Chronos"
  '
  strConnectionString = "DRIVER=SQL Server;" & _
                        "UID=" & strSQLUserName & ";" & _
                        "PWD=" & strPassword & ";" & _
                        "DATABASE=" & g_astrDatabases(%DB) & ";" & _
                        "SERVER=quad001\SqlExpress"
  '
  'strConnectionString = "DRIVER=SQL Server;" & _
  '                      "Trusted_Connection=Yes;" & _
  '                      "DATABASE=" & _
  '                      g_astrDatabases(%DB) & ";" & _
  '                      "SERVER=quad001\SqlExpress"
  '
  IF ISTRUE funUserOpenDB(%DB, _
                          strConnectionString, _
                          strStatus) THEN
  ' db opened ok
    funLog(strStatus)
    ' run the processing
    funProcess()
    ' close the db connect
    lngResult = funUserCloseDB(%DB, strStatus)
    funLog(strStatus)
  ELSE
  ' db didn't open ok
    funLog(strStatus)
  END IF
  '
  ' shutdown the SQL library
  lngResult = SQL_Shutdown()
  IF lngResult = %SUCCESS THEN
    funLog("SQL library closed down")
  ELSE
    funLog("Unable to close SQL library down")
  END IF
  funExitApp
  '
END FUNCTION
'
FUNCTION funProcess() AS LONG
' Run the processing
  LOCAL strComputerName AS STRING
  LOCAL strDriveSize AS STRING
  LOCAL strDriveSpace AS STRING
  LOCAL strDMDriveSize AS STRING
  LOCAL strDMDriveSpace AS STRING
  '
  LOCAL strSQL AS STRING
  LOCAL strError AS STRING
  '
  funLog("Processing started")
  IF ISTRUE funGetMachineInfo(strComputerName, _
                              strDriveSize, _
                              strDriveSpace, _
                              strDMDriveSize, _
                              strDMDriveSpace) THEN
    funLog("computer name   -> " & strComputerName)
    funlog("drive size      -> " & strDriveSize)
    funlog("drive space     -> " & strDriveSpace)
    funlog("data drive size -> " & strDMDriveSize)
    funlog("data drive Space-> " & strDMDriveSpace) '
    '
    strSQL = "EXEC dbo.sprUpdateHeartbeat '" & strComputerName & "'," _
                                           & strDriveSize & "," _
                                           & strDriveSpace & "," _
                                           & strDMDriveSize & "," _
                                           & strDMDriveSpace
    IF ISTRUE funRunSQL(strSQL,strError, %DB) THEN
       funlog("Heartbeat updated")
    ELSE
       funlog("SQL error " & strError)
    END IF
    '
  END IF


  SLEEP 2000
  funLog("Processing ended")
'
END FUNCTION
'
FUNCTION funGetMachineInfo(strComputerName AS STRING,_
                           strDriveSize AS STRING, _
                           strDriveSpace AS STRING, _
                           strDMDriveSize AS STRING, _
                           strDMDriveSpace AS STRING) AS LONG
  ' get the computer name
  strComputerName = funPCComputerName
  '
  ' get all the drive sizes
  strDriveSize = funGetDriveSize()
  ' store the info for Disk manager
  strDMDriveSize = strDriveSize
  '
  strDriveSize = PARSE$(strDriveSize,";",1)
  strDriveSize = PARSE$(strDriveSize,":\ ",2)
  '
  strDriveSpace =  funGetDriveSpace
  strDMDriveSpace = funGetDriveSpace
  ' in gigabytes
  strDriveSpace = PARSE$(PARSE$(strDriveSpace,";",1),"  ",2)
  '
  ' is the the disk server?
  IF UCASE$(strComputerName) = UCASE$(g_strDiskServer) THEN
    strDMDriveSize = PARSE$(strDMDriveSize,g_strDriveLetter & ":\",2)
    strDMDriveSize = TRIM$(PARSE$(strDMDriveSize,";",1))
    '
    strDMDriveSpace = PARSE$(strDMDriveSpace,g_strDriveLetter & ":\",2)
    strDMDriveSpace = TRIM$(PARSE$(strDMDriveSpace,";",1))
  ELSE
    strDMDriveSize = "0"
    strDMDriveSpace = "0"
  END IF
  '
  FUNCTION = %TRUE
  '
END FUNCTION
'
FUNCTION funLog(strData AS STRING) AS LONG
' log to the file
  LOCAL strText AS STRING
  strText = funUKDate() & " " & TIME$ & " " & strData
  funAppendToFile(g_strLog,strText)
  CON.STDOUT strData
END FUNCTION
'
FUNCTION funExitApp() AS LONG
' exit the application
'
  DIM strText AS STRING
  DIM strI AS STRING
  DIM lngExit AS LONG
  DIM lngWait AS LONG
  '
    strText = "All Operations completed " & funUKDate & " " & TIME$
    STDOUT strText
    STDOUT "Press any key to exit"
    '
    WHILE ISFALSE lngExit
      strI = INKEY$
      IF LEN(strI) <> 0 THEN
        lngExit = %TRUE
      ELSE
        SLEEP 500
        INCR lngWait
        '
        IF lngWait > 20 THEN
        ' been waiting more that 10 seconds
        ' so exit
          lngExit = %TRUE
        ELSE
          STDOUT ".";
        END IF
        '
      END IF
    WEND
END FUNCTION
