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

'------------------------------------------------------------------------------
%MaxWorkers = 500                  ' Total number of supported workers
GLOBAL g_lngWorkersActive AS LONG  ' number of currrently active workers
GLOBAL g_lngEnding AS LONG         ' flag to end the thread
GLOBAL g_hMonitor AS LONG          ' global thread handle
GLOBAL g_hDlg AS DWORD             ' dialog handle
'
TYPE udtWorkers              ' UDT to hold details of workers
  WorkName AS STRING * 50
  Condition AS LONG
END TYPE

ENUM Condition      ' Current condition of worker
  Active = 1        ' Awaiting work
  Processing        ' Processing work
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
  '
  PBFormsInitComCtls (%ICC_WIN95_CLASSES OR %ICC_DATE_CLASSES OR _
    %ICC_INTERNET_CLASSES)

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
