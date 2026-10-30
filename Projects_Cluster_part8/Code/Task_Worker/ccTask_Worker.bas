#COMPILE EXE
#DIM ALL

#DEBUG ERROR ON

#INCLUDE ONCE "WIN32API.INC"
#INCLUDE "UDPcomms.inc"                 ' load the UDP library
#INCLUDE "PB_Processes.inc"             ' load the processes library
#INCLUDE "PB_FileHandlingRoutines.inc"  ' file handling library
#INCLUDE "PB_Txt_ConfigFile.inc"        ' load the config file library
'
GLOBAL g_lngProccessorCount AS LONG
GLOBAL g_strTaskFolder AS STRING
'
%ThreadTerminated = 13    ' arbitary value for thread termination
'
ENUM Condition      ' Current condition of worker
  Active = 1        ' Awaiting work
  Processing        ' Processing work
  Completed         ' Completed work
  NotActive         ' Not available for work
END ENUM
'
TYPE udtTask
  lngCore AS LONG
  strTask AS STRING * 50
  lngRecordStart AS LONG
  lngRecordCount AS LONG
END TYPE
'
FUNCTION PBMAIN () AS LONG
  LOCAL strMessage AS STRING
  LOCAL lngCore AS LONG
  LOCAL strTask AS STRING
  LOCAL strConfigFile AS STRING
  LOCAL lngActiveThreads AS LONG
  LOCAL lngRunLoop AS LONG         ' true/false to run loop
  LOCAL lngThread AS LONG          ' thread loop
  LOCAL uTask AS udtTask           ' UDT for Task
  LOCAL lngResult AS LONG          ' result of Thread status
  LOCAL lngRecordStart AS LONG     ' Record to start at
  LOCAL lngRecordCount AS LONG     ' number of records to process
  '
  IF funProcessCount(GetAppName)>1 THEN
  ' more than one version of this running ?
  ' exit this app
    EXIT FUNCTION
  END IF
  '
  strConfigFile = EXE.PATH$ & "TaskConfig.txt"
  '
  IF ISTRUE funTxtCfg_LoadFile(strConfigFile) THEN
  ' config file loaded - now get field values
    g_strUDPServer = funTxtCfg_GetValue("TaskLeader")
    g_strTaskFolder = funTxtCfg_GetValue("Tasks")
    '
  ELSE
    CON.STDOUT "Unable to load config file
    SLEEP 2000
    EXIT FUNCTION
  END IF
  '
  ' work out the number of processors
  g_lngProccessorCount = funProcessorCount
  ' and the computer name
  g_strThisComputer = funPCComputerName
  '
  ' prep the threads array
  DIM a_lngThreads(1 TO g_lngProccessorCount) AS LONG
  DIM a_strTaskID(1 TO g_lngProccessorCount) AS STRING
  '
  ' set amber colour and report
  COLOR 14,0
  PREFIX "con.stdout "
    "Launching " & g_strThisComputer
    "With " & FORMAT$(g_lngProccessorCount) & " cores"
  END PREFIX
  '
  lngRunLoop = %TRUE ' set to loop
  '
  WHILE ISTRUE lngRunLoop
  ' now launch each of the Worker Cores
    FOR lngCore = 1 TO g_lngProccessorCount
      ' query the Task Leader to report status
      '
      ' is core already processing?
      IF a_lngThreads(lngCore) > 0 THEN
      ' thread already launched or already completed
        SLEEP 100
        ITERATE  ' check next core
      END IF
      '
      strMessage = funQueryUDPServer("ACTIVE|" & FORMAT$(lngCore))
      '
      CON.STDOUT strMessage
      'SLEEP 2000 ' ## TEMP delay ##
      '
      ' work out what to do with the message that has come back
      SELECT CASE PARSE$(strMessage,"|",1)
        CASE "### ACCEPTED ###"
        ' accepted but no task awaiting
          CON.STDOUT "No tasks available"
        CASE "### TASK ###"
        ' accepted and given task
          CON.STDOUT "Task Assigned"
          '
          IF TRIM$(strTask) <> "" THEN
          ' only if there is a task specified
            strTask = PARSE$(strMessage,"|",2)
            lngRecordStart = VAL(PARSE$(strMessage,"|",3))
            lngRecordCount = VAL(PARSE$(strMessage,"|",4))
            '
            ' store task ID
            a_strTaskID(lngCore) = strTask
            '
            ' tell worker leader that we are now processing the Task given
            strMessage = funQueryUDPServer("PROCESSING|" & FORMAT$(lngCore) & _
                                           "|" & strTask)
            '
            ' processing code goes here
            PREFIX "uTask."
              lngCore = lngCore
              strTask = strTask
              lngRecordStart = lngRecordStart
              lngRecordCount = lngRecordCount
            END PREFIX
            '
            THREAD CREATE funExecutionThread(BYVAL VARPTR(uTask)) TO a_lngThreads(lngCore)
            '
          END IF
      END SELECT
      '
    NEXT lngCore
    '
    ' check for threads still running?
    lngRunLoop = %FALSE ' assume not running
    '
    FOR lngThread = 1 TO UBOUND(a_lngThreads)
    ' check the status of the thread
      THREAD STATUS a_lngThreads(lngThread) TO lngResult
      CON.STDOUT "Thread " & FORMAT$(lngThread) & " Status = " & FORMAT$(lngResult)
      '
      IF lngResult = %ThreadTerminated THEN
      ' if marked as terminated
        a_lngThreads(lngThread) = %ThreadTerminated
        THREAD CLOSE a_lngThreads(lngThread) TO lngResult
        ' get Task ID
        strTask = a_strTaskID(lngThread)
        '
        ' and report to Task Leader
        strMessage = funQueryUDPServer("COMPLETED|" & FORMAT$(lngThread) & _
                                       "|" & strTask)
        '
        SLEEP 500
        '
      END IF
      '
      IF a_lngThreads(lngThread) > 0 AND _
         a_lngThreads(lngThread) <> 13 THEN
      ' at least one thread still processing
        CON.STDOUT "Thread " & FORMAT$(lngThread) & " still running"
        lngRunLoop = %TRUE
      END IF
      '
    NEXT lngThread
    '
  WEND
  '
  SLEEP 5000
  '
END FUNCTION
'
FUNCTION funProcessorCount() AS LONG
' return the core count
  '
  FUNCTION = VAL(ENVIRON$("NUMBER_OF_PROCESSORS"))
'
END FUNCTION
'
THREAD FUNCTION funExecutionThread(BYVAL pTask AS udtTask POINTER) AS LONG
' run this thread for this core and task
  LOCAL lngCore AS LONG
  LOCAL strTask AS STRING        ' task name
  LOCAL strConfigFile AS STRING  ' name an location of config file for task
  LOCAL strResultsFolder AS STRING ' name and location of results folder
  LOCAL strExecutable AS STRING  ' name of the EXE to run
  LOCAL lngRecordStart AS LONG   ' Record to start at
  LOCAL lngRecordCount AS LONG   ' number of records to process
  '
  LOCAL uTask AS udtTask  ' set up a local type
  uTask = @pTask          ' copy the details to a local copy
  '
  lngCore = uTask.lngCore
  strTask = TRIM$(uTask.strTask)
  lngRecordStart = uTask.lngRecordStart
  lngRecordCount = uTask.lngRecordCount
  '
  ' get name and location of the task config file
  strConfigFile = "\\" & g_strUDPServer & "\" & _
                   g_strTaskFolder & "\" & _
                   strTask & "\" & strTask & ".cfg"
                   '
  strResultsFolder = "\\" & g_strUDPServer & "\" & _
                   g_strTaskFolder & "\" & _
                   strTask & "\"
                   '
  IF ISTRUE funTxtCfg_LoadFile(strConfigFile) THEN
    strExecutable = funTxtCfg_GetValue("App")
    '
    ' pass details to EXE
    ' strResultsFolder
    ' lngRecordStart
    ' lngRecordXCCount
    '
    SLEEP RND(6000,8000) ' simulate processing
    '
    '
  ELSE
  ' unable to find config?
  END IF
  '
  FUNCTION = %ThreadTerminated  ' set return value
  '
END FUNCTION
