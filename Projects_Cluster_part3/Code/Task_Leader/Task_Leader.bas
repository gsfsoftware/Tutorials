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

'------------------------------------------------------------------------------
'   ** Includes **
'------------------------------------------------------------------------------
#PBFORMS BEGIN INCLUDES
#RESOURCE "Task_Leader.pbr"
#INCLUDE ONCE "WIN32API.INC"
#INCLUDE ONCE "COMMCTRL.INC"
#INCLUDE ONCE "PBForms.INC"
#PBFORMS END INCLUDES
'
#INCLUDE "..\..\Libraries\PB_Processes.inc"
#INCLUDE "..\..\Libraries\UDPcomms.inc"
'
%MLGSLL = 1             ' set to use MLG as a SLL
#INCLUDE "MLG.INC"      ' include MLG library
#LINK "MLG.SLL"         ' link to SSL
'
%AMR_UPDATED            = 99 ' row marker for updated record
%AMR_SAVED              = 0  ' row marker for saved record
#INCLUDE "..\..\Libraries\PB_MLG_Utilities.inc"
'
%MaxGridColumns = 5     ' set max number of columns in grid
%IDC_MLGGRID1   = 3000  ' windows control handle for grid
'
GLOBAL hGrid1 AS LONG  ' local handle for grid
GLOBAL g_strColumnWidths() AS STRING  ' global array for column widths
GLOBAL g_strColumnNames() AS STRING   ' global array for column names
'
' column designations (defines column position and column width)
  %Column_ID = 1
  %Column_WorkerName = 2
  %Column_CoreNumber = 3
  %Column_Status = 4
  %Column_TimeStamp = 5
  '
  $Column_ID_Width = "70"
  $Column_WorkerName_Width = "180"
  $Column_CoreNumber_Width = "100"
  $Column_Status_Width = "180"
  $Column_TimeStamp_Width = "180"
  '
  $Column_ID_Name = "ID"
  $Column_WorkerName_Name = "Worker Name"
  $Column_CoreNumber_Name = "Core Number"
  $Column_Status_Name = "Status"
  $Column_TimeStamp_Name = "Time Stamp"
'------------------------------------------------------------------------------
%MaxWorkers = 500                  ' Total number of supported workers
GLOBAL g_lngWorkersActive AS LONG  ' number of currrently active workers
GLOBAL g_lngEnding AS LONG         ' flag to end the thread
GLOBAL g_hMonitor AS LONG          ' global thread handle
GLOBAL g_hDlg AS DWORD             ' dialog handle
'
TYPE udtWorkers              ' UDT to hold details of workers
  WorkName AS STRING * 50    ' Name of computer
  CoreNumber AS LONG         ' core number of computer
  Condition AS LONG
  Timestamp AS STRING * 50   ' time stamp of status
END TYPE

ENUM Condition      ' Current condition of worker
  Active = 1        ' Awaiting work
  Processing        ' Processing work
  Completed         ' Completed work
  NotActive         ' Not available for work
END ENUM

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
#PBFORMS END CONSTANTS
'------------------------------------------------------------------------------

'------------------------------------------------------------------------------
'   ** Declarations **
'------------------------------------------------------------------------------
DECLARE CALLBACK FUNCTION ShowdlgTaskLeaderProc()
DECLARE FUNCTION ShowdlgTaskLeader(BYVAL hParent AS DWORD) AS LONG
#PBFORMS DECLARATIONS
'------------------------------------------------------------------------------

'------------------------------------------------------------------------------
'   ** Main Application Entry Point **
'------------------------------------------------------------------------------
FUNCTION PBMAIN()
  '
  IF funProcessCount(GetAppName)>1 THEN
  ' more than one version on this running ?
    EXIT FUNCTION
  END IF
  '
  ' pick up computer name
  g_strThisComputer = funPCComputerName
  '
  REDIM uWorkers(%MaxWorkers) ' prep the global array
  funInitialiseWorkersArray()
  '
  PBFormsInitComCtls (%ICC_WIN95_CLASSES OR %ICC_DATE_CLASSES OR _
    %ICC_INTERNET_CLASSES)
  '
  MLG_Init  ' initialise the grid control
  funSetColumnWidthsNames()
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
    ' update the number of workers currently active
      CONTROL SET TEXT CB.HNDL, %IDC_txtWorkersActive, _
                                FORMAT$(g_lngWorkersActive)
    '
    CASE %WM_COMMAND
      ' Process control notifications
      SELECT CASE AS LONG CB.CTL
        CASE %IDC_STATUSBAR1

        CASE %IDABORT
          IF CB.CTLMSG = %BN_CLICKED OR CB.CTLMSG = 1 THEN
            g_lngEnding = %TRUE
            DIALOG END CB.HNDL
          END IF

        CASE %IDC_txtWorkersActive

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
    35, 55, 10
  CONTROL SET COLOR      hDlg, %IDC_lblWorkersActive, %BLUE, -1
  CONTROL ADD TEXTBOX,   hDlg, %IDC_txtWorkersActive, "0", 10, 45, 55, 12, _
    %WS_CHILD OR %WS_VISIBLE OR %WS_TABSTOP OR %ES_CENTER OR %ES_AUTOHSCROLL _
    OR %ES_READONLY, %WS_EX_CLIENTEDGE OR %WS_EX_LEFT OR %WS_EX_LTRREADING _
    OR %WS_EX_RIGHTSCROLLBAR
  CONTROL ADD TEXTBOX,   hDlg, %IDC_txtActivity, "", 545, 25, 210, 325, _
    %WS_CHILD OR %WS_VISIBLE OR %WS_TABSTOP OR %WS_VSCROLL OR %ES_LEFT OR _
    %ES_MULTILINE OR %ES_AUTOHSCROLL OR %ES_AUTOVSCROLL OR %ES_READONLY, _
    %WS_EX_CLIENTEDGE OR %WS_EX_LEFT OR %WS_EX_LTRREADING OR _
    %WS_EX_RIGHTSCROLLBAR
  CONTROL ADD LABEL,     hDlg, %IDC_lblActivity, "Activity", 550, 15, 100, 10
  CONTROL SET COLOR      hDlg, %IDC_lblActivity, %BLUE, -1
#PBFORMS END DIALOG
  g_hDlg = hDlg
  '
   ' add the MLG
  LOCAL strSorting AS STRING  ' to be used for right click MLG menu
  strSorting = ""
  '
  CONTROL ADD "MYLITTLEGRID", hDlg, %IDC_MLGGRID1, _
          funGetColumnWidths() & "/d-0/e1/r" & FORMAT$(%MaxWorkers) & _
          strSorting & "/c" & _
          FORMAT$(%MaxGridColumns) & "/a2/y3", _
          10, 80, 500, 270, %MLG_STYLE
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
    END SELECT
  NEXT lngCount
  '
  ' colour bank the grid rows and refresh the grid
  funColourBankGridRows(hGrid1)
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
      '
      ' update the active counter
      g_lngWorkersActive = funCountActive()
      CONTROL SET TEXT g_hDlg,%IDC_txtWorkersActive, FORMAT$(g_lngWorkersActive)
      '
      CONTROL GET TEXT g_hDlg, %IDC_txtActivity TO strOutput
      strOutput = RIGHT$(strOutput,1000)
      strOutput = strOutput & strMessage
      CONTROL SET TEXT g_hDlg, %IDC_txtActivity, strOutput
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
  '
  g_strColumnWidths(%Column_ID) = $Column_ID_Width
  g_strColumnWidths(%Column_WorkerName) = $Column_WorkerName_Width
  g_strColumnWidths(%Column_CoreNumber) = $Column_CoreNumber_Width
  g_strColumnWidths(%Column_Status) = $Column_Status_Width
  g_strColumnWidths(%Column_TimeStamp) = $Column_TimeStamp_Width
  '
  g_strColumnNames(%Column_ID) = $Column_ID_Name
  g_strColumnNames(%Column_WorkerName) = $Column_WorkerName_Name
  g_strColumnNames(%Column_CoreNumber) = $Column_CoreNumber_Name
  g_strColumnNames(%Column_Status) = $Column_Status_Name
  g_strColumnNames(%Column_TimeStamp) = $Column_TimeStamp_Name
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
  '
  strWorker = PARSE$(strMessage,"_",1)
  strCore = PARSE$(strMessage, ANY "_ ",2)
  strState = PARSE$(strMessage," ",-2)
  strTimeStamp = RTRIM$(PARSE$(strMessage," ",-1),$CRLF)
  '
  SELECT CASE strState
    CASE "ACTIVE"
      lngCondition = %Condition.Active
    CASE "PROCESSING"
      lngCondition = %Condition.Processing
    CASE "COMPLETED"
      lngCondition = %Condition.Completed
  END SELECT

'  TYPE udtWorkers              ' UDT to hold details of workers
'    WorkName AS STRING * 50    ' Name of computer
'    CoreNumber AS LONG         ' core number of computer   *NEW
'    Condition AS LONG
'    Timestamp AS STRING * 50   ' time stamp of status
'  END TYPE
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
    WorkName = strWorker
    CoreNumber = VAL(strCore)
    Condition  = lngCondition
    Timestamp  = strTimeStamp
  END PREFIX
  '
  '%Column_ID = 1
  '%Column_WorkerName = 2
  '%Column_CoreNumber = 3
  '%Column_Status = 4
  '%Column_TimeStamp = 5
  '
  ' update the grid
  PREFIX "MLG_put(hGrid1,lngFound,"
    %Column_ID,FORMAT$(lngFound),0)
    %Column_WorkerName,strWorker,0)
    %Column_CoreNumber,strCore,0)
    %Column_Status,strState,0)
    %Column_TimeStamp,strTimeStamp,0)
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
FUNCTION funCountActive() AS LONG
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
