#PBFORMS CREATED V2.01
'------------------------------------------------------------------------------
' The first line in this file is a PB/Forms metastatement.
' It should ALWAYS be the first line of the file. Other
' PB/Forms metastatements are placed at the beginning and
' end of "Named Blocks" of code that should be edited
' with PBForms only. Do not manually edit or delete these
' metastatements or PB/Forms will not be able to reread
' the file correctly.  See the PB/Forms documentation for
' more information.
' Named blocks begin like this:    #PBFORMS BEGIN ...
' Named blocks end like this:      #PBFORMS END ...
' Other PB/Forms metastatements such as:
'     #PBFORMS DECLARATIONS
' are used by PB/Forms to insert additional code.
' Feel free to make changes anywhere else in the file.
'------------------------------------------------------------------------------

#COMPILE EXE
#DIM ALL
#DEBUG ERROR ON
'------------------------------------------------------------------------------
'   ** Includes **
'------------------------------------------------------------------------------
#PBFORMS BEGIN INCLUDES
#RESOURCE "Task_Leader.pbr"
%USEMACROS = 1
#INCLUDE ONCE "WIN32API.INC"
#INCLUDE ONCE "COMMCTRL.INC"
#INCLUDE ONCE "PBForms.INC"
#PBFORMS END INCLUDES
'
#INCLUDE "PB_Processes.inc"
#INCLUDE "UDPcomms.inc"
#INCLUDE "PB_ToolbarLIB.inc"
'
%MLGSLL = 1             ' set to use MLG as a SLL
#INCLUDE "MLG.INC"      ' include MLG library
#LINK "MLG.SLL"         ' link to SSL
'
%AMR_UPDATED            = 99 ' row marker for updated record
%AMR_SAVED              = 0  ' row marker for saved record
#INCLUDE "PB_MLG_Utilities.inc"
'
#INCLUDE "PB_FileHandlingRoutines.inc"  ' file handling library
#INCLUDE "PB_Txt_ConfigFile.inc"        ' load the config file library
#INCLUDE "Datefunctions.inc"            ' load the date functions library
'
%MaxGridColumns = 8     ' set max number of columns in grid
%IDC_MLGGRID1   = 3000  ' windows control handle for grid
'
$Task = "Tasks"                ' name of the underlying Task folder
'                              ' which contains the task applications
$TaskStatus = "TaskStatus.txt" ' Binary file holding task status data
$Log = "TaskLeader_log.txt"    ' log for the task leader
'
%MaxTaskGridColumns = 5 ' set max number of columns in Tasks grid
%IDC_MLGGRID2   = 3001  ' windows control handle for task grid
'
GLOBAL hGrid1 AS LONG  ' local handle for grid
GLOBAL hGrid2 AS LONG  ' local handle for task grid
'
GLOBAL g_strColumnWidths() AS STRING  ' global array for column widths
GLOBAL g_strColumnNames() AS STRING   ' global array for column names
'
' column designations (defines column position and column width)
  %Column_ID = 1
  %Column_WorkerName = 2
  %Column_CoreNumber = 3
  %Column_Status     = 4
  %Column_TimeStamp  = 5
  %Column_Task       = 6
  %Column_RowStart   = 7
  %Column_Records    = 8
  '
  $Column_ID_Width         = "50"
  $Column_WorkerName_Width = "120"
  $Column_CoreNumber_Width = "100"
  $Column_Status_Width     = "100"
  $Column_TimeStamp_Width  = "100"
  $Column_Task_Width       = "95"
  $Column_RowStart_Width   = "80"
  $Column_Records_Width    = "80"
  '
  $Column_ID_Name         = "ID"
  $Column_WorkerName_Name = "Worker Name"
  $Column_CoreNumber_Name = "Core Number"
  $Column_Status_Name     = "Status"
  $Column_TimeStamp_Name  = "Time Stamp"
  $Column_Task_Name       = "Task"
  $Column_RowStart_Name   = "RowStart"
  $Column_Records_Name    = "Records"
  '
GLOBAL g_strTaskColumnWidths() AS STRING ' global array for column widths
GLOBAL g_strTaskColumnNames() AS STRING  ' global array for column names
'
  %Column_Task_ID     = 1
  %Column_Task_Name   = 2
  %Column_Task_Active = 3
  %Column_Task_Status = 4
  '
  $Column_Task_ID_Width     = "70"
  $Column_Task_Name_Width   = "180"
  $Column_Task_Active_Width = "100"
  $Column_Task_Status_Width = "150"
  '
  $Column_Task_ID_Name    = "ID"
  $Column_TaskName_Name   = "Task Name"
  $Column_TaskActive_Name = "Active"
  $Column_TaskStatus_Name = "Status"


'------------------------------------------------------------------------------
%MaxWorkers = 500          ' Total number of supported workers
%MaxTasks   = 15           ' Total number of supported Tasks
'
GLOBAL g_strTaskList() AS STRING     ' Array containing the tasks
                                     ' than can be processed
'
%Worker_Timeout = 180      ' number of seconds before worker is inactive
'
GLOBAL g_lngWorkersActive AS LONG  ' number of currrently active workers
GLOBAL g_lngTasksActive AS LONG    ' number of tasks awaiting processing
'
GLOBAL g_lngEnding AS LONG         ' flag to end the thread
GLOBAL g_hMonitor AS LONG          ' global thread handle
GLOBAL g_hDlg AS DWORD             ' dialog handle
'
TYPE udtWorkers                ' UDT to hold details of workers
  WorkName AS STRING * 50      ' Name of computer
  CoreNumber AS LONG           ' core number of computer
  Condition AS LONG
  Timestamp AS STRING * 50     ' time stamp of status
  AssignedTask AS STRING * 50  ' task assigned to Worker
  RowNumber AS LONG            ' row to start processing at
  Records AS LONG              ' number of records to process
END TYPE
'
ENUM Condition      ' Current condition of worker
  Active = 1        ' Awaiting work
  Assigned          ' work has been assigned
  Processing        ' Processing work
  Completed         ' Completed work
  NotActive         ' Not available for work
END ENUM
'
ENUM Task           ' current status of task
  NotActive = 0     ' created but not yet active
  Active            ' ready to be processed
  Processing        ' currently processing
  Completed         ' completed processing
END ENUM
'
$GridTask_NotActive = ""  ' used for task active/not active in Task grid
$GridTask_Active    = "1"
'
GLOBAL uWorkers() AS udtWorkers  ' Array of workers details
'
'------------------------------------------------------------------------------
'   ** Constants **
'------------------------------------------------------------------------------
#PBFORMS BEGIN CONSTANTS
%IDD_dlgTaskLeader    =  101
%IDC_STATUSBAR1       = 1001
%IDABORT              =    3
%IDC_lblWorkersActive = 1002
%IDC_txtWorkersActive = 1003
%IDC_txtActivity      = 1004
%IDC_lblActivity      = 1005
%IDD_dlgTASKLIST      =  102
%IDC_STATUSBAR2       = 1006
%IDOK                 =    1
#PBFORMS END CONSTANTS
'------------------------------------------------------------------------------
%IDC_Toolbar          = 1100
%IDC_TaskToolbar      = 1101
'------------------------------------------------------------------------------
'   ** Declarations **
'------------------------------------------------------------------------------

#PBFORMS DECLARATIONS
'------------------------------------------------------------------------------

'------------------------------------------------------------------------------
'   ** Main Application Entry Point **
'------------------------------------------------------------------------------
FUNCTION PBMAIN()
  '
  IF funProcessCount(GetAppName)>1 THEN
  ' more than one version of this running ?
    EXIT FUNCTION
  END IF
  '
  ' pick up computer name
  g_strThisComputer = funPCComputerName
  '
  REDIM uWorkers(%MaxWorkers) ' prep the global array
  funInitialiseWorkersArray()
  '
  funInitialiseTaskArray()    ' prep the task array
  '
  PBFormsInitComCtls (%ICC_WIN95_CLASSES OR %ICC_DATE_CLASSES OR _
    %ICC_INTERNET_CLASSES)
  '
  MLG_Init  ' initialise the grid control
  funSetColumnWidthsNames()
  funSetTaskColumnWidthsNames()
  '
  ShowdlgTaskLeader %HWND_DESKTOP
END FUNCTION
'------------------------------------------------------------------------------

'------------------------------------------------------------------------------
'   ** CallBacks **
'------------------------------------------------------------------------------
CALLBACK FUNCTION ShowdlgTaskLeaderProc()
  STATIC hTimer AS QUAD
  '
  SELECT CASE AS LONG CB.MSG
    CASE %WM_INITDIALOG
    ' Initialization handler
      ' set time to trigger every 10 secs - 10000ms
      hTimer = SetTimer(CB.HNDL, 1&,10000&, BYVAL %NULL)
      '
      THREAD CREATE funMonitorThread(0) TO g_hMonitor
      '
    CASE %WM_NCACTIVATE
      STATIC hWndSaveFocus AS DWORD
      IF ISFALSE CB.WPARAM THEN
        ' Save control focus
        hWndSaveFocus = GetFocus()
      ELSEIF hWndSaveFocus THEN
        ' Restore control focus
        SetFocus(hWndSaveFocus)
        hWndSaveFocus = 0
      END IF
    '
    CASE %WM_TIMER
    ' have any workers stopped responding?
    ' check the uWorkers array
      funUpdateWorkersArray()
    '
    ' update the number of workers currently active
      CONTROL SET TEXT CB.HNDL, %IDC_txtWorkersActive, _
                                FORMAT$(g_lngWorkersActive)
    '
    CASE %WM_COMMAND
      ' Process control notifications
      SELECT CASE AS LONG CB.CTL
        ' /* Inserted by PB/Forms 03-05-2022 12:04:18
        CASE %IDC_txtActivity
        ' */

        CASE %IDC_STATUSBAR1

        CASE %IDABORT
          IF CB.CTLMSG = %BN_CLICKED OR CB.CTLMSG = 1 THEN
            g_lngEnding = %TRUE
            DIALOG END CB.HNDL
          END IF

        CASE %IDC_txtWorkersActive
        CASE %ID_ADD
        ' show task list
          ShowdlgTASKLIST CB.HNDL,%IDC_txtActivity
        '
        CASE %ID_Save
        CASE %ID_Help
        CASE %ID_Reports
          '
      END SELECT
  END SELECT
END FUNCTION
'------------------------------------------------------------------------------

'------------------------------------------------------------------------------
'   ** Dialogs **
'------------------------------------------------------------------------------
FUNCTION ShowdlgTaskLeader(BYVAL hParent AS DWORD) AS LONG
  LOCAL lRslt AS LONG

#PBFORMS BEGIN DIALOG %IDD_dlgTaskLeader->->
  LOCAL hDlg  AS DWORD

  DIALOG NEW hParent, "Cluster Processing Task Leader", 187, 163, 767, 392, _
    %WS_POPUP OR %WS_BORDER OR %WS_DLGFRAME OR %WS_CAPTION OR %WS_SYSMENU OR _
    %WS_MINIMIZEBOX OR %WS_CLIPSIBLINGS OR %WS_VISIBLE OR %DS_MODALFRAME OR _
    %DS_CENTER OR %DS_3DLOOK OR %DS_NOFAILCREATE OR %DS_SETFONT, _
    %WS_EX_CONTROLPARENT OR %WS_EX_LEFT OR %WS_EX_LTRREADING OR _
    %WS_EX_RIGHTSCROLLBAR, TO hDlg
  CONTROL ADD STATUSBAR, hDlg, %IDC_STATUSBAR1, "Ready", 0, 0, 0, 0
  CONTROL ADD BUTTON,    hDlg, %IDABORT, "Exit", 680, 355, 50, 15
  CONTROL ADD LABEL,     hDlg, %IDC_lblWorkersActive, "Workers Active", 10, _
    40, 55, 10
  CONTROL SET COLOR      hDlg, %IDC_lblWorkersActive, %BLUE, -1
  CONTROL ADD TEXTBOX,   hDlg, %IDC_txtWorkersActive, "0", 10, 50, 55, 12, _
    %WS_CHILD OR %WS_VISIBLE OR %WS_TABSTOP OR %ES_CENTER OR %ES_AUTOHSCROLL _
    OR %ES_READONLY, %WS_EX_CLIENTEDGE OR %WS_EX_LEFT OR %WS_EX_LTRREADING _
    OR %WS_EX_RIGHTSCROLLBAR
  CONTROL ADD TEXTBOX,   hDlg, %IDC_txtActivity, "", 545, 60, 210, 290, _
    %WS_CHILD OR %WS_VISIBLE OR %WS_TABSTOP OR %WS_VSCROLL OR %ES_LEFT OR _
    %ES_MULTILINE OR %ES_AUTOHSCROLL OR %ES_AUTOVSCROLL OR %ES_READONLY, _
    %WS_EX_CLIENTEDGE OR %WS_EX_LEFT OR %WS_EX_LTRREADING OR _
    %WS_EX_RIGHTSCROLLBAR
  CONTROL ADD LABEL,     hDlg, %IDC_lblActivity, "Activity", 545, 45, 100, 10
  CONTROL SET COLOR      hDlg, %IDC_lblActivity, %BLUE, -1
#PBFORMS END DIALOG
  g_hDlg = hDlg
  CONTROL ADD TOOLBAR, hDlg,%IDC_Toolbar,"",0,0,0,0
  CreateToolbar(hDlg,%IDC_Toolbar)
  '
   ' add the MLG
  LOCAL strSorting AS STRING  ' to be used for right click MLG menu
  strSorting = ""
  '
  CONTROL ADD "MYLITTLEGRID", hDlg, %IDC_MLGGRID1, _
          funGetColumnWidths() & "/d-0/e1/r" & FORMAT$(%MaxWorkers) & _
          strSorting & "/c" & _
          FORMAT$(%MaxGridColumns) & "/a2/y3", _
          10, 80, 510, 270, %MLG_STYLE
  CONTROL HANDLE hDlg, %IDC_MLGGRID1 TO hGrid1
  '
  funGridClear(hGrid1)
  '
   ' ensure dimensioned rows and columns are bigger
  MLG_ArrayRedim(hGrid1, %MaxWorkers , %MaxGridColumns, _
                         %MaxWorkers+10, %MaxGridColumns+2)

  ' set override slots for grey colours on name
  SendMessage hGrid1,%MLG_SETBKGNDCELLCOLOR,2, %RGB_HONEYDEW
  '
  SendMessage hGrid1 ,%MLG_CREATEFORMATOVERRIDE,0,0 ' set up for grid overrides array
  '
  ' set cell for licence
  SendMessage hGrid1,%MLG_SETCELL,0,0
  '
  SendMessage hGrid1, %MLG_SETHEADERCOLOR , %LTGRAY,0
  '
  ' display the tabs - 300 is the amount of room for the tabs
  ' - rest taken up by scroll bar
  SendMessage hGrid1, %MLG_SHOWSHEETTABS,300,0
  funRenameTab(hGrid1,1,"  Task Workers ")
  '
  ' populate the column headers
  LOCAL lngRefresh AS LONG
  LOCAL lngCount AS LONG
  '
  FOR lngCount = 1 TO %MaxGridColumns
    MLG_Put hGrid1,0,lngCount,g_strColumnNames(lngCount),lngRefresh
  NEXT lngCount
  '
  '%Column_ID = 1
  '%Column_WorkerName = 2
  '%Column_CoreNumber = 3
  '%Column_Status = 4
  '%Column_TimeStamp = 5
  '%Column_Task = 6
  '%Column_RowStart   = 7
  '%Column_Records    = 8
  ' handle the centering of data in the columns
  FOR lngCount = 1 TO %MaxGridColumns
    SELECT CASE lngCount
      CASE %Column_ID, %Column_WorkerName, _
           %Column_CoreNumber,%Column_TimeStamp
        MLG_FormatColNumber hGrid1,lngCount, _
            %MLG_NULL,%MLG_JUST_CENTER,%BLACK ,%MLG_LOCK
      CASE %Column_Status
        MLG_FormatColNumber hGrid1,lngCount, _
            %MLG_NULL,%MLG_JUST_CENTER,%BLUE,%MLG_LOCK
      CASE %Column_Task
        MLG_FormatColNumber hGrid1,lngCount, _
            %MLG_NULL,%MLG_JUST_LEFT,%BLUE,%MLG_LOCK
      CASE %Column_RowStart,%Column_Records
        MLG_FormatColNumber hGrid1,lngCount, _
            %MLG_NULL,%MLG_JUST_RIGHT,%BLACK,%MLG_LOCK
    END SELECT
  NEXT lngCount
  '
  ' colour bank the grid rows and refresh the grid
  funColourBankGridRows(hGrid1)
  '
  funGridRefresh(hGrid1)
  '
  DIALOG SHOW MODAL hDlg, CALL ShowdlgTaskLeaderProc TO lRslt

#PBFORMS BEGIN CLEANUP %IDD_dlgTaskLeader
#PBFORMS END CLEANUP

  FUNCTION = lRslt
END FUNCTION
'
THREAD FUNCTION funMonitorThread(BYVAL hSocket AS LONG) AS LONG
  ' every few seconds check all of the workers
  LOCAL strMessage AS STRING
  LOCAL strOutput AS STRING
  '
  IF ISTRUE funUDPopenPort() THEN
    CONTROL SET TEXT g_hDlg, %IDC_txtActivity, _
                     "Listener Created" & $CRLF
                     '
    DO UNTIL ISTRUE g_lngEnding
      strMessage = funUDPLeaderListen()
      '
      ' update the message in the global array
      funUpdateArray(strMessage)
      funLog(strMessage)
'      funAppendToFile(EXE.PATH$ & "log.txt",strMessage)
      '
      ' update the active counter
      g_lngWorkersActive = funCountActiveWorkers()
      CONTROL SET TEXT g_hDlg,%IDC_txtWorkersActive, FORMAT$(g_lngWorkersActive)
      '
      funAddRowToActivity(g_hDlg , _
                          %IDC_txtActivity, _
                          strMessage)
      '
      SLEEP 100
      '
    LOOP
    '
    funUDPclosePort
    '
  ELSE
    CONTROL SET TEXT g_hDlg, %IDC_txtActivity, _
                     "Unable to create listener"
  END IF
  '
END FUNCTION
'
FUNCTION funSetColumnWidthsNames() AS LONG
' set the column widths/Names for the main grid
  LOCAL lngR AS LONG
  REDIM g_strColumnWidths(%MaxGridColumns) AS STRING
  REDIM g_strColumnNames(%MaxGridColumns) AS STRING
  '
  '%Column_ID = 1
  '%Column_WorkerName = 2
  '%Column_CoreNumber = 3
  '%Column_Status = 4
  '%Column_TimeStamp = 5
  '%Column_Task = 6
  '%Column_RowStart   = 7
  '%Column_Records    = 8
  '
  g_strColumnWidths(%Column_ID) = $Column_ID_Width
  g_strColumnWidths(%Column_WorkerName) = $Column_WorkerName_Width
  g_strColumnWidths(%Column_CoreNumber) = $Column_CoreNumber_Width
  g_strColumnWidths(%Column_Status) = $Column_Status_Width
  g_strColumnWidths(%Column_TimeStamp) = $Column_TimeStamp_Width
  g_strColumnWidths(%Column_Task) = $Column_Task_Width
  g_strColumnWidths(%Column_RowStart) = $Column_RowStart_Width
  g_strColumnWidths(%Column_Records)  = $Column_Records_Width
  '
  g_strColumnNames(%Column_ID) = $Column_ID_Name
  g_strColumnNames(%Column_WorkerName) = $Column_WorkerName_Name
  g_strColumnNames(%Column_CoreNumber) = $Column_CoreNumber_Name
  g_strColumnNames(%Column_Status) = $Column_Status_Name
  g_strColumnNames(%Column_TimeStamp) = $Column_TimeStamp_Name
  g_strColumnNames(%Column_Task) = $Column_Task_Name
  g_strColumnNames(%Column_RowStart) = $Column_RowStart_Name
  g_strColumnNames(%Column_Records)  = $Column_Records_Name
  '
END FUNCTION
'
FUNCTION funGetColumnWidths() AS STRING
' return the column widths
' in the format "x20,40,120,100,60,110,280,260,260,90,100"  '
  LOCAL strWidths AS STRING
  LOCAL lngR AS LONG
  '
  strWidths = "x20,"
  '
  FOR lngR = 1 TO %MaxGridColumns
    strWidths = strWidths & g_strColumnWidths(lngR) & ","
  NEXT lngR
  '
  strWidths = RTRIM$(strWidths)
  '
  FUNCTION = strWidths
  '
END FUNCTION
'
FUNCTION funSetTaskColumnWidthsNames() AS LONG
' set the column widths/Names for the Task grid
  LOCAL lngR AS LONG
  REDIM g_strTaskColumnWidths(%MaxTaskGridColumns) AS STRING
  REDIM g_strTaskColumnNames(%MaxTaskGridColumns) AS STRING
  '
  '%Column_Task_ID = 1
  '%Column_Task_Name = 2
  '%Column_Task_Active = 3
  '%Column_Task_Status = 4
  '
  g_strTaskColumnWidths(%Column_Task_ID) = $Column_Task_ID_Width
  g_strTaskColumnWidths(%Column_Task_Name) = $Column_Task_Name_Width
  g_strTaskColumnWidths(%Column_Task_Active) = $Column_Task_Active_Width
  g_strTaskColumnWidths(%Column_Task_Status) = $Column_Task_Status_Width
  '
  g_strTaskColumnNames(%Column_Task_ID) = $Column_Task_ID_Name
  g_strTaskColumnNames(%Column_Task_Name) = $Column_TaskName_Name
  g_strTaskColumnNames(%Column_Task_Active) = $Column_TaskActive_Name
  g_strTaskColumnNames(%Column_Task_Status) = $Column_TaskStatus_Name
  '
END FUNCTION
'
FUNCTION funGetTaskColumnWidths() AS STRING
' return the column widths
' in the format "x20,40,120,100,60,110,280,260,260,90,100"  '
  LOCAL strWidths AS STRING
  LOCAL lngR AS LONG
  '
  strWidths = "x20,"
  '
  FOR lngR = 1 TO %MaxTaskGridColumns
    strWidths = strWidths & g_strTaskColumnWidths(lngR) & ","
  NEXT lngR
  '
  strWidths = RTRIM$(strWidths)
  '
  FUNCTION = strWidths
END FUNCTION
'
FUNCTION funInitialiseWorkersArray() AS LONG
  LOCAL lngR AS LONG
  '
  FOR lngR = 1 TO UBOUND(uWorkers)
    PREFIX "uWorkers(lngR)."
      WorkName = ""
      CoreNumber = 0
      Condition  = 0
      Timestamp  = ""
    END PREFIX
  NEXT lngR
  '
END FUNCTION
'
FUNCTION funUpdateArray(strMessage AS STRING) AS LONG
' update the global array uWorkers()
  LOCAL strWorker AS STRING
  LOCAL strCore AS STRING
  LOCAL strState AS STRING
  LOCAL strTimeStamp AS STRING
  LOCAL lngFound AS LONG
  LOCAL lngCondition AS LONG
  LOCAL strTask AS STRING
  '
  LOCAL strRowStart AS STRING
  LOCAL strRecords AS STRING
  '
  strWorker = PARSE$(strMessage,"_",1)
  '
  ' ignore blank work names
  IF strWorker = "" THEN EXIT FUNCTION
  '
  strCore = PARSE$(strMessage, ANY "_ ",2)
  strState = PARSE$(strMessage," ",-2)
  strTimeStamp = PARSE$(RTRIM$(PARSE$(strMessage," ",-1),$CRLF),"|",1)
  strTask = PARSE$(RTRIM$(PARSE$(strMessage," ",-1),$CRLF),"|",2)
  '
  funLog(strMessage) '~~DEBUG~~
  '
  SELECT CASE strState
    CASE "ACTIVE"
      lngCondition = %Condition.Active
    CASE "PROCESSING"
      lngCondition = %Condition.Processing
    CASE "COMPLETED"
      lngCondition = %Condition.Completed
  END SELECT

  'type udtWorkers
  '  WorkName AS STRING * 50      ' Name of computer
  '  CoreNumber AS LONG           ' core number of computer
  '  Condition AS LONG
  '  Timestamp AS STRING * 50     ' time stamp of status
  '  AssignedTask AS STRING * 50  ' task assigned to Worker
  '  RowNumber AS LONG            ' row to start processing at
  '  Records AS LONG              ' number of records to process
  'end type
'
'  ENUM Condition      ' Current condition of worker
'    Active = 1        ' Awaiting work
'    Processing        ' Processing work
'    Completed         ' Completed work            *NEW
'    NotActive         ' Not available for work
'  END ENUM
  '
  ' find in uWorkers() array
  lngFound = funInArray(strWorker, strCore)
  '
  PREFIX "uWorkers(lngFound)."
    WorkName     = strWorker
    CoreNumber   = VAL(strCore)
    Condition    = lngCondition
    Timestamp    = strTimeStamp
    AssignedTask = strTask
    RowNumber    = 0
    Records      = 0
  END PREFIX
  '
  '%Column_ID         = 1
  '%Column_WorkerName = 2
  '%Column_CoreNumber = 3
  '%Column_Status     = 4
  '%Column_TimeStamp  = 5
  '%Column_Task       = 6
  '%Column_RowStart   = 7
  '%Column_Records    = 8
  '

  ' update the grid
  PREFIX "MLG_put(hGrid1,lngFound,"
    %Column_ID,FORMAT$(lngFound),0)
    %Column_WorkerName,strWorker,0)
    %Column_CoreNumber,strCore,0)
    %Column_Status,strState,0)
    %Column_TimeStamp,strTimeStamp,0)
    %Column_Task, strTask,0)
    %Column_RowStart,FORMAT$(uWorkers(lngFound).RowNumber),0)
    %Column_Records,FORMAT$(uWorkers(lngFound).Records),0)
  END PREFIX
  '
  funGridRefresh(hGrid1)
END FUNCTION
'
FUNCTION funInArray(strWorker AS STRING, _
                    strCore AS STRING) AS LONG
  LOCAL lngR AS LONG
  LOCAL lngMarker AS LONG  ' Row to be updated
  '
  FOR lngR = 1 TO UBOUND(uWorkers)
    IF TRIM$(uWorkers(lngR).WorkName) = "" AND lngMarker = 0 THEN
      lngMarker = lngR
    END IF
    '
    IF TRIM$(uWorkers(lngR).WorkName) = strWorker AND _
             uWorkers(lngR).CoreNumber = VAL(strCore) THEN
    ' record found
      lngMarker = lngR
      EXIT FOR
    END IF
    '
  NEXT lngR
  '
  FUNCTION = lngMarker
  '
END FUNCTION
'
FUNCTION funCountActiveButIdleWorkers() AS LONG
' count the number of Workers Active but currently idle
' i.e. not processing
  LOCAL lngR AS LONG
  LOCAL lngCount AS LONG
  '
  FOR lngR = 1 TO UBOUND(uWorkers)
    IF uWorkers(lngR).Condition = %Condition.Active THEN
      INCR lngCount
    END IF
  NEXT lngR
  '
  FUNCTION = lngCount
END FUNCTION
'
FUNCTION funCountActiveWorkers() AS LONG
  ' count workers either active or processing
  LOCAL lngR AS LONG
  LOCAL lngCount AS LONG
  '
  FOR lngR = 1 TO UBOUND(uWorkers)
    IF uWorkers(lngR).Condition = %Condition.Active OR _
       uWorkers(lngR).Condition = %Condition.Processing THEN
      INCR lngCount
    END IF
  NEXT lngR
  '
  FUNCTION = lngCount
  '
END FUNCTION
'
FUNCTION funGetFirstActiveTask() AS LONG
' return pointer to the first active task
  LOCAL lngR AS LONG
  LOCAL strActive AS STRING
  LOCAL strStatus AS STRING
  '
  FOR lngR = 1 TO %MaxTasks
    strActive = g_strTaskList(lngR,%Column_Task_Active)
    strStatus = g_strTaskList(lngR,%Column_Task_Status)
    '
    SELECT CASE strActive
      CASE "1", CHR$(1)
        IF strStatus = "" THEN
        ' status is blank and looking for workers
          FUNCTION = lngR
          EXIT FUNCTION
        END IF
    END SELECT
  NEXT lngR
  '
  FUNCTION = 0  ' no task if we get this far
  '
END FUNCTION
'
FUNCTION funCountActiveTasks() AS LONG
' count the active tasks
  LOCAL lngR AS LONG
  LOCAL strActive AS STRING
  LOCAL strStatus AS STRING
  LOCAL lngCount AS LONG
  '
  FOR lngR = 1 TO %MaxTasks
    strActive = g_strTaskList(lngR,%Column_Task_Active)
    strStatus = g_strTaskList(lngR,%Column_Task_Status)
    '
    SELECT CASE strActive
      CASE "1", CHR$(1)
        IF strStatus = "" THEN
        ' status is blank and looking for workers
          INCR lngCount
        END IF
    END SELECT
  NEXT lngR
  ' return the count of tasks not yet assigned
  FUNCTION = lngCount
  '
END FUNCTION
'
FUNCTION funUpdateWorkersArray() AS LONG
' update the workers array
  LOCAL lngR AS LONG
  LOCAL dblTimestamp AS DOUBLE
  LOCAL dblNow AS DOUBLE
  LOCAL lngTasksActive AS LONG     ' number of tasks currently active
  LOCAL lngIdleWorkers AS LONG     ' funCountActiveButIdleWorkers
  LOCAL lngTask AS LONG            ' pointer to Active task
  LOCAL strTaskID AS STRING        ' TaskID
  LOCAL lngInputRows AS LONG       ' Total rows in input file
  LOCAL lngBatchSize AS LONG       ' number of rows per Worker
  LOCAL lngRecordsLeft AS LONG     ' records left to assign
  LOCAL lngRecordsAssigned AS LONG ' records assigned to worker
  LOCAL lngRowNumber AS LONG       ' Row number to start at
  '
  lngTasksActive = funCountActiveTasks() ' count active tasks
  g_lngTasksActive = lngTasksActive
  '
  ' count workers awaiting work
  lngIdleWorkers = funCountActiveButIdleWorkers()
  '
  lngTask = funGetFirstActiveTask() ' get first active task
  '
  IF lngTask > 0 THEN
  ' there is a task waiting
  ' determine the size of the input file
  '%Column_Task_ID = 1
  '%Column_Task_Name = 2
  '%Column_Task_Active = 3
  '%Column_Task_Status = 4
  '
  ' get the task ID
    strTaskID = g_strTaskList(lngTask,%Column_Task_ID)
    lngInputRows = funGetTotalRows_In_InputFile(strTaskID)
    IF lngInputRows > 0 THEN
    ' work out the batch size for each worker
      lngBatchSize = lngInputRows \ lngIdleWorkers
      lngRecordsLeft  = lngInputRows
      lngRowNumber = 2 ' start at row 2 i.e. not the header line
    ELSE
      lngBatchSize = 0
    END IF
  '
  END IF
  '
  dblNow = TIMER  ' get the current number of secs since midnight
  '
  'TYPE udtWorkers               ' UDT to hold details of workers
  '  WorkName AS STRING * 50     ' Name of computer
  '  CoreNumber AS LONG          ' core number of computer
  '  Condition AS LONG
  '  Timestamp AS STRING * 50    ' time stamp of status
  '  AssignedTask AS STRING * 50 ' task assigned to Worker
  '  RowNumber AS LONG           ' row to start processing at
  '  Records AS LONG             ' number of records to process
  'END TYPE
  '
  FOR lngR = 1 TO UBOUND(uWorkers)
    IF TRIM$(uWorkers(lngR).WorkName) = "" THEN ITERATE
    IF uWorkers(lngR).Condition = %Condition.NotActive THEN ITERATE
    '
    dblTimestamp = funGetSeconds(TRIM$(uWorkers(lngR).Timestamp))
    IF dblNow - dblTimestamp > %Worker_Timeout THEN
    ' worker hasn't updated within the time period - assume inactive
      uWorkers(lngR).Condition = %Condition.NotActive
      ' update the grid
      PREFIX "MLG_put(hGrid1,lngR,"
        %Column_Status,"INACTIVE",0)
        %Column_Task,"",0)
        %Column_RowStart,"",0)
        %Column_Records,"",0)
      END PREFIX
      '
    ELSE
    ' worker hasn't timed out
      IF lngTasksActive = 0 THEN
      ' there are no active tasks
        ITERATE
      ELSE
      ' there are active tasks
      ' update array to mark as processing
      '  g_strTaskList(lngTask,%Column_Task_Status) = "PROCESSING"
      '
      END IF
      '
      ' is this worker active?
      IF uWorkers(lngR).Condition = %Condition.Active THEN
        IF TRIM$(uWorkers(lngR).AssignedTask) = "" THEN
        ' this worker has no tasks - so assign it
          IF lngRecordsLeft > 0 THEN
          ' there are some records left to assign
            uWorkers(lngR).AssignedTask = strTaskID
            '
            lngRecordsAssigned = MIN(lngBatchSize,lngRecordsLeft)
            lngRecordsLeft = lngRecordsLeft - lngRecordsAssigned
            '
            uWorkers(lngR).RowNumber = lngRowNumber
            uWorkers(lngR).Records   = lngRecordsAssigned
            '
            ' advance the row number
            lngRowNumber = lngRowNumber + lngRecordsAssigned
            '
            uWorkers(lngR).Condition = %Condition.Assigned
            '
            ' update the grid
            PREFIX "MLG_put(hGrid1,lngR,"
              %Column_Status,"ASSIGNED",0)
              %Column_Task,strTaskID,0)
              %Column_RowStart,FORMAT$(lngRowNumber) ,0)
              %Column_Records,FORMAT$(lngRecordsAssigned),0)
            END PREFIX
            '
          END IF
        '
        END IF
      END IF
    '
    END IF
    '
  NEXT lngR
  '
  funGridRefresh(hGrid1)
  g_lngWorkersActive = funCountActiveWorkers()
  '
END FUNCTION
'
FUNCTION funGetTotalRows_In_InputFile(strTaskID AS STRING) AS LONG
' look for input file and count Total rows in file
  LOCAL strInputFolder AS STRING  ' path & name of Input folder
  LOCAL strConfigFile AS STRING   ' path & name of config file
  LOCAL strInputFile AS STRING    ' name of input file
  LOCAL lngRowCount AS LONG       ' total rows in the file
  LOCAL lngFile AS LONG           ' file handle for input file
  '
  strInputFolder = EXE.PATH$ & "Tasks\" & strTaskID
  strConfigFile = strInputFolder & "\" & strTaskID & ".cfg"
  '
  IF ISTRUE funTxtCfg_LoadFile(strConfigFile) THEN
  ' config file found
    strInputFile = funTxtCfg_GetValue("Input")
    '
    IF ISTRUE ISFILE(strInputFolder & strInputFile) THEN
      lngFile = FREEFILE
      OPEN strInputFolder & strInputFile FOR INPUT AS #lngFile
      FILESCAN lngFile, RECORDS TO lngRowCount
      CLOSE #lngFile
      FUNCTION = lngRowCount
    ELSE
      FUNCTION = 0
    END IF
  '
  ELSE
    FUNCTION = 0
  END IF
  '
END FUNCTION
'
FUNCTION funGetSeconds(strTimeStamp AS STRING) AS DOUBLE
  LOCAL lngHours, lngMinutes, lngSeconds AS LONG
  lngHours = VAL(LEFT$(strTimeStamp,2))
  lngMinutes = VAL(MID$(strTimeStamp,4,2))
  lngSeconds = VAL(RIGHT$(strTimeStamp,2))
  '
  FUNCTION = (lngHours*60*60)+(lngMinutes*60)+lngSeconds
  '
END FUNCTION
'------------------------------------------------------------------------------
CALLBACK FUNCTION ShowdlgTASKLISTProc()
  LOCAL hParent AS DWORD
  LOCAL lngActivity AS LONG
  '
  LOCAL MLGN AS MyGridData PTR     ' set up the grid pointer
  LOCAL mycol AS LONG              ' grid column number
  LOCAL myrow AS LONG              ' grid row number
  LOCAL strText AS STRING          ' generic text string
  LOCAL mychar AS LONG             ' previous value of checkbox
  LOCAL lngRefresh AS LONG         ' refresh flag
  '
  LOCAL lngResult AS LONG          ' thread suspend result
  '
  SELECT CASE AS LONG CB.MSG
    CASE %WM_INITDIALOG
      ' Initialization handler
      funPopulateTasks(hGrid2)
      '
    CASE %WM_NCACTIVATE
      STATIC hWndSaveFocus AS DWORD
      IF ISFALSE CB.WPARAM THEN
        ' Save control focus
        hWndSaveFocus = GetFocus()
      ELSEIF hWndSaveFocus THEN
        ' Restore control focus
        SetFocus(hWndSaveFocus)
        hWndSaveFocus = 0
      END IF
      '
    CASE %WM_NOTIFY
      MLGN = CB.LPARAM   ' pick up msg dependant value
      SELECT CASE @MLGN.NMHeader.idFrom
      ' which dialog control did this notification
      ' come from?
        CASE %IDC_MLGGRID2
        ' if it's the grid
          SELECT CASE @MLGN.NMHeader.code
          ' which grid event has happened?
            CASE %MLGN_CHECKCHANGED
            ' checkbox has been amended
              myrow=@MLGN.Param1 ' current row
              mycol=@MLGN.Param2 ' current col
              mychar=@MLGN.Param3 ' check status
              '
              ' highlight the cell & mark row as updated
              ' but only if there is a task name
              IF MLG_Get(hGrid2,myrow,%Column_Task_Name) <> "" THEN
              ' there is a name - mark row as updated
                MLG_SetRowRecNo(hGrid2,myrow,%AMR_UPDATED)
                ' and highlight the cell
                funMarkGridCell(hGrid2 ,myrow, mycol)
              ELSE
                ' dont allow box to be checked
                ' as it has no name
                lngRefresh  = 1
                IF mychar = 1 THEN
                  MLG_Put(hGrid2, myrow, mycol, "", lngRefresh)
                END IF
              END IF
              '
          END SELECT
      END SELECT
      '
    CASE %WM_COMMAND
      ' Process control notifications
      SELECT CASE AS LONG CB.CTL
        ' /* Inserted by PB/Forms 02-25-2024 14:51:52
        CASE %IDOK
          IF CB.CTLMSG = %BN_CLICKED OR CB.CTLMSG = 1 THEN
          ' apply the changes to the Tasks array
          '
            THREAD SUSPEND g_hMonitor TO lngResult
            '
            IF ISTRUE funApplyTaskChanges(hGrid2) THEN
            ' apply and notify the changes
              PREFIX "dialog get user cb.hndl,"
                1 TO hParent
                2 TO lngActivity
              END PREFIX
              ' add active tasks to Activity report
              funAddToActivity(hParent,lngActivity,hGrid2)
            '
            END IF
            '
            THREAD RESUME g_hMonitor TO lngResult
            '
            DIALOG END CB.HNDL
          '
          END IF
        ' */

        CASE %IDC_STATUSBAR2
        '
        CASE %IDABORT
          IF CB.CTLMSG = %BN_CLICKED OR CB.CTLMSG = 1 THEN
          ' end the dialog
            DIALOG END CB.HNDL
          END IF

      END SELECT
  END SELECT
END FUNCTION
'------------------------------------------------------------------------------

'------------------------------------------------------------------------------
FUNCTION ShowdlgTASKLIST(BYVAL hParent AS DWORD, _
                         lngActivity AS LONG) AS LONG
  LOCAL lRslt AS LONG
  '
#PBFORMS BEGIN DIALOG %IDD_dlgTASKLIST->->
  LOCAL hDlg  AS DWORD

  DIALOG NEW hParent, "Task List", 386, 185, 402, 314, %WS_POPUP OR _
    %WS_BORDER OR %WS_DLGFRAME OR %WS_CAPTION OR %WS_SYSMENU OR _
    %WS_CLIPSIBLINGS OR %WS_VISIBLE OR %DS_MODALFRAME OR %DS_CENTER OR _
    %DS_3DLOOK OR %DS_NOFAILCREATE OR %DS_SETFONT, %WS_EX_CONTROLPARENT OR _
    %WS_EX_LEFT OR %WS_EX_LTRREADING OR %WS_EX_RIGHTSCROLLBAR, TO hDlg
  CONTROL ADD STATUSBAR, hDlg, %IDC_STATUSBAR2, "Ready", 0, 0, 0, 0
  CONTROL ADD BUTTON,    hDlg, %IDABORT, "Exit", 15, 275, 50, 15
  CONTROL ADD BUTTON,    hDlg, %IDOK, "Apply", 330, 275, 50, 15
  DIALOG  SEND           hDlg, %DM_SETDEFID, %IDOK, 0
#PBFORMS END DIALOG
  '
  ' store the parameters
  PREFIX "DIALOG SET USER hDlg,"
    1,hParent
    2,lngActivity
  END PREFIX
  '
    ' add the MLG
  LOCAL strSorting AS STRING  ' to be used for right click MLG menu
  strSorting = ""
  '
  CONTROL ADD "MYLITTLEGRID", hDlg, %IDC_MLGGRID2, _
          funGetTaskColumnWidths() & "/d-0/e1/r" & FORMAT$(%MaxTasks) & _
          strSorting & "/c" & _
          FORMAT$(%MaxTaskGridColumns) & "/a2/y3", _
          10, 40, 370, 220, %MLG_STYLE
  CONTROL HANDLE hDlg, %IDC_MLGGRID2 TO hGrid2
  '
  funGridClear(hGrid2)
  '
  ' set override slots for grey colours on name
  SendMessage hGrid2,%MLG_SETBKGNDCELLCOLOR,2, %RGB_HONEYDEW
  '
  SendMessage hGrid2 ,%MLG_CREATEFORMATOVERRIDE,0,0 ' set up for grid overrides array
  '
  ' set cell for licence
  SendMessage hGrid2,%MLG_SETCELL,0,0
  '
  SendMessage hGrid2, %MLG_SETHEADERCOLOR , %LTGRAY,0
  '
  ' display the tabs - 300 is the amount of room for the tabs
  ' - rest taken up by scroll bar
  SendMessage hGrid2, %MLG_SHOWSHEETTABS,300,0
  funRenameTab(hGrid2,1,"  Tasks List ")
  '
  ' populate the column headers
  LOCAL lngRefresh AS LONG
  LOCAL lngCount AS LONG
  '
  FOR lngCount = 1 TO %MaxTaskGridColumns
    MLG_Put hGrid2,0,lngCount,g_strTaskColumnNames(lngCount),lngRefresh
  NEXT lngCount
  '
  '%Column_Task_ID = 1
  '%Column_Task_Name = 2
  '%Column_Task_Active = 3
  '
  ' handle the centering of data in the columns
  FOR lngCount = 1 TO %MaxTaskGridColumns
    MLG_FormatColNumber hGrid2,lngCount, _
            %MLG_NULL,%MLG_JUST_CENTER,%BLACK ,%MLG_NOLOCK
  NEXT lngCount
  '
  MLG_FormatColCheck hGrid2,%Column_Task_Active
  '
  ' colour bank the grid rows and refresh the grid
  funColourBankGridRows(hGrid2)
  funGridRefresh(hGrid2)
  '

  'CONTROL ADD TOOLBAR, hDlg,%IDC_TaskToolbar,"",0,0,0,0
  'CreateToolbar(hDlg,%IDC_TaskToolbar)
  '
  DIALOG SHOW MODAL hDlg, CALL ShowdlgTASKLISTProc TO lRslt

#PBFORMS BEGIN CLEANUP %IDD_dlgTASKLIST
#PBFORMS END CLEANUP

  FUNCTION = lRslt
END FUNCTION
'------------------------------------------------------------------------------
FUNCTION funPopulateTasks(hGrid AS DWORD) AS STRING
' fill the task grid with the tasks currently set up
' in the task list array
  '
  MLG_PutEx (hGrid,g_strTaskList(),4,1)
'
END FUNCTION
'
FUNCTION funInitialiseTaskArray() AS LONG
' set up an populate the Task array
  REDIM g_strTaskList(%MaxTasks,5) AS STRING
  '
  LOCAL strFolder AS STRING
  LOCAL strSubFolder AS STRING
  LOCAL lngCount AS LONG
  DIM a_strDisplayGrid(%MaxTasks,3) AS STRING
  LOCAL strConfigFile AS STRING
  LOCAL strTaskActiveFile AS STRING
  '
  '%Column_Task_ID = 1
  '%Column_Task_Name = 2
  '%Column_Task_Active = 3
  '%Column_Task_Status = 4
  '
  strFolder = EXE.PATH$ & $Task
  strSubFolder = DIR$(strFolder & "\*.*" , %SUBDIR)
  WHILE strSubFolder <> ""
    INCR lngCount
    '
    strConfigFile = strFolder & "\" & strSubFolder & _
                    "\" & strSubFolder & ".cfg"
    IF ISTRUE funTxtCfg_LoadFile(strConfigFile) THEN
      ' store the name of the subfolder as the task ID
      g_strTaskList(lngCount,%Column_Task_ID) = strSubFolder
      '
      ' config file loaded - now get name of task
      g_strTaskList(lngCount,%Column_Task_Name) = funTxtCfg_GetValue("Name")
      '
      ' get path and name of active file
      strTaskActiveFile = strFolder & "\" & strSubFolder & _
                          "\" & "Active.txt"
                          '
      ' is the task currently active?
      IF ISTRUE ISFILE(strTaskActiveFile) THEN
        g_strTaskList(lngCount,%Column_Task_Active) = $GridTask_Active
      ELSE
        g_strTaskList(lngCount,%Column_Task_Active) = $GridTask_NotActive
      END IF
    '
    END IF
    '
    strSubFolder = DIR$
  WEND
  '
END FUNCTION
'
FUNCTION funApplyTaskChanges(hGrid AS DWORD) AS LONG
' apply the changes in the grid to the global array
' g_strTaskList
'
  MLG_GetEx hGrid,g_strTaskList()
  FUNCTION = %TRUE
  '
END FUNCTION
'
FUNCTION funAddToActivity(hDlg AS DWORD, _
                          lngActivity AS LONG, _
                          hGrid AS DWORD) AS LONG
' add active tasks in g_strTaskList to activity control
  LOCAL lngR AS LONG
  LOCAL strOutput AS STRING
  LOCAL strMessage AS STRING
  LOCAL strActive AS STRING
  LOCAL strProcessing AS STRING
  LOCAL lngStatus AS LONG
  LOCAL strResultsFolder AS STRING    ' path and name of the results folder
  LOCAL strTaskID AS STRING           ' task ID of the current task
  '
  FOR lngR = 1 TO UBOUND(g_strTaskList)
    strActive     = g_strTaskList(lngR,%Column_Task_Active)
    strProcessing = g_strTaskList(lngR,%Column_Task_Status)
    ' get the row status from the grid i.e. has it changed
    ' at this time?
    lngStatus = MLG_GetRowRecNo(hGrid,lngR)
    '
    IF lngStatus <> %AMR_UPDATED THEN
    ' row has not changed
      ITERATE
    END IF
    '
    SELECT CASE strActive
      CASE "1", CHR$(1)
      ' report active tasks
        IF strProcessing = "" THEN
          strMessage = g_strTaskList(lngR,%Column_Task_Name) & " Active"
          funAddRowToActivity(hDlg,%IDC_txtActivity,strMessage)
          '
          strTaskID = g_strTaskList(lngR,%Column_Task_ID)
          strResultsFolder = EXE.PATH$ & $Task & "\" & strTaskID & "\Results\*.*"
          ' ensure results folder is ready by wiping it
          TRY
            KILL strResultsFolder
          CATCH
          FINALLY
          END TRY
          '
          ' distribute task to active task workers
          funDistributeTask(hDlg,strTaskID)
          '
          ' now create "Active.txt" file
          funAppendToFile(EXE.PATH$ & $Task & "\" & strTaskID & "\Active.txt", _
                          "Active Task")
          '
        END IF
        '
      CASE ELSE
        strMessage = g_strTaskList(lngR,%Column_Task_Name) & " Not Active"
        funAddRowToActivity(hDlg,%IDC_txtActivity,strMessage)
        strTaskID = g_strTaskList(lngR,%Column_Task_ID)
        '
        ' delete active.txt file
        TRY
          KILL EXE.PATH$ & $Task & "\" & strTaskID & "\Active.txt"
        CATCH
        FINALLY
        END TRY
        '
    END SELECT
    '
  NEXT lngR
  '
END FUNCTION
'
FUNCTION funDistributeTask(hDlg AS DWORD, _
                           strTaskID AS STRING) AS LONG
' distribute the task to the active task workers
' first get the number of workers active
  LOCAL strMessage AS STRING
  strMessage = FORMAT$(g_lngWorkersActive) & _
               " workers active or processing"
  funAddRowToActivity(hDlg,%IDC_txtActivity,strMessage)
   '
  LOCAL strTaskFolder AS STRING  ' path to Task folder
  LOCAL strConfigFile AS STRING  ' path and name of config file
  LOCAL lngFile AS LONG          ' file handle of input file
  LOCAL lngRowCount AS LONG      ' number of rows in input file
  LOCAL lngRows AS LONG          ' number of rows per worker
  LOCAL lngGridRow AS LONG       ' worker being processed
  LOCAL lngWorkersActive AS LONG ' active status workers counted
  DIM a_lngGridWorkers(%MaxWorkers) AS LONG ' array of active worker IDs
  LOCAL lngGridWorker AS LONG    ' row in GridWorkers array
  LOCAL lngWorker AS LONG        ' incremental worker number
  LOCAL strInputFile AS STRING   ' input data file
  LOCAL lngProgress AS LONG      ' grid progress flag
  LOCAL lngWorkerCount AS LONG   ' count of workers processed
  LOCAL lngStartRow AS LONG      ' start row for task
  LOCAL lngEndRow AS LONG        ' end row for task
  '
  lngProgress = 1
  '
  strTaskFolder = EXE.PATH$ & $Task & "\" & strTaskID
  ' then look to size of input file
  strConfigFile = strTaskFolder & "\" & strTaskID & ".cfg"
  '
  IF ISTRUE funTxtCfg_LoadFile(strConfigFile) THEN
  ' config file found
    strInputFile = funTxtCfg_GetValue("Input")
     ' open the input file and determine row count
    IF ISTRUE ISFILE(strTaskFolder & "\" & strInputFile) THEN
      lngFile = FREEFILE
      OPEN strTaskFolder & "\" & strInputFile FOR INPUT AS #lngFile
      FILESCAN lngFile, RECORDS TO lngRowCount
      CLOSE #lngFile
       '
      lngGridRow = 1
      lngGridWorker = 1
      '
      ' look through the grid
      ' and work out number of workers in active state
      DO UNTIL MLG_Get(hGrid1,lngGridRow,%Column_ID) = ""
        IF MLG_Get(hGrid1,lngGridRow,%Column_Status) = "ACTIVE" THEN
          INCR lngWorkersActive
          ' add row to list in array
          a_lngGridWorkers(lngGridWorker) = lngGridRow
          INCR lngGridWorker
        END IF
        INCR lngGridRow
      LOOP
      '
      ' work out how many rows per worker
      lngRows = lngRowCount \ lngWorkersActive
      '
      ' and update the main grid
      lngStartRow = 1
      '
      FOR lngGridWorker = 1 TO UBOUND(a_lngGridWorkers)
        IF a_lngGridWorkers(lngGridWorker) = 0 THEN ITERATE
        ' add to worker count
        INCR lngWorkerCount
        ' put the task name in
        lngWorker = a_lngGridWorkers(lngGridWorker)
        MLG_PUT(hGrid1,lngWorker,%Column_Task,strTaskID,lngProgress)
        ' put the start row in
        MLG_PUT(hGrid1,lngWorker,%Column_RowStart, _
                FORMAT$(lngStartRow),lngProgress)
        '
        IF lngWorkerCount = lngWorkersActive THEN
        ' this is the last worker - so adjust the rows to process
          lngRows = lngRowCount - lngStartRow
        END IF
        ' put the number of records
        MLG_PUT(hGrid1,lngWorker,%Column_Records, _
                FORMAT$(lngRows),lngProgress)
        '
        lngStartRow = lngStartRow + lngRows
        '
      NEXT lngGridWorker
      '
      FUNCTION = %TRUE
    ELSE
      FUNCTION = 0
    END IF
    '
  ELSE
    FUNCTION = 0
  END IF



'
END FUNCTION
'
FUNCTION funAddRowToActivity(hDlg AS DWORD, _
                             lngActivity AS LONG, _
                             strMessage AS STRING) AS LONG
' add a data row to the activity control
  LOCAL strOutput AS STRING
  '
  CONTROL GET TEXT hDlg, lngActivity TO strOutput
  ' keep only the last 1000 characters
  strOutput = RIGHT$(strOutput,1000)
  ' add on the latest message
  strOutput = strOutput & strMessage & $CRLF
  ' update the control
  CONTROL SET TEXT hDlg, lngActivity, strOutput
  '
END FUNCTION
'
FUNCTION funNewTask(strWorkerName AS STRING, o_strTask AS STRING, _
                    strCore AS STRING) AS LONG
' is there a new task for this Worker?
' has the worker been assigned any tasks?
  LOCAL lngW AS LONG              ' row in workers array
  LOCAL strTask AS STRING
  LOCAL strRowNumber AS STRING
  LOCAL strRecords AS STRING
  '
'  TYPE udtWorkers                ' UDT to hold details of workers
  '  WorkName AS STRING * 50      ' Name of computer
  '  CoreNumber AS LONG           ' core number of computer
  '  Condition AS LONG
  '  Timestamp AS STRING * 50     ' time stamp of status
  '  AssignedTask AS STRING * 50  ' task assigned to Worker
  '  RowNumber AS LONG            ' row to start processing at
  '  Records AS LONG              ' number of records to process
'  END TYPE
  '
  lngW = funFindWorker(strWorkerName, strCore)
  IF lngW > 0 THEN
  ' worker found
    strTask = TRIM$(uWorkers(lngW).AssignedTask)
    strRowNumber = FORMAT$(uWorkers(lngW).RowNumber)
    strRecords   = FORMAT$(uWorkers(lngW).Records)
    '
    IF strTask = "" THEN
      strTask = "Idle"
      uWorkers(lngW).AssignedTask = strTask
    END IF
    '
    o_strTask = strTask & "|" & strRowNumber & "|" & strRecords
    FUNCTION = %TRUE
  '
  ELSE
  ' worker not found - not in array yet?
    o_strTask = ""
    FUNCTION = %FALSE
  END IF
  '



' o_strTask = "\\octal002\TaskRunner\Task_Leader\Tasks\Task_001" & _
'              "|" & "Task1.exe"
'
'
END FUNCTION
'
FUNCTION funFindWorker(strWorkerName AS STRING, _
                       strCore AS STRING) AS LONG
' find the worker in the workers array and
' return the row
  LOCAL lngW AS LONG
  '
  FOR lngW = 1 TO UBOUND(uWorkers)
    IF TRIM$(uWorkers(lngW).WorkName) = "" THEN ITERATE
    '
    IF TRIM$(uWorkers(lngW).WorkName) = strWorkerName AND _
             uWorkers(lngW).CoreNumber = VAL(strCore) THEN
    ' worker found
      FUNCTION = lngW
      EXIT FUNCTION
    END IF
  NEXT lngW
  '
  ' not found
  FUNCTION = 0
  '
END FUNCTION
'
FUNCTION funUpdateToCompleted(strSource AS STRING, _
                              strCore AS STRING) AS LONG
' update that this worker has completed a task

'
END FUNCTION
'
FUNCTION funLog(strData AS STRING) AS LONG
' write to the log
  funAppendToFile(EXE.PATH$ & $Log,funUKDate & " " & TIME$ & " " & strData)
  '
END FUNCTION
