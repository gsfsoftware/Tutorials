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
#RESOURCE "Modeless_dialogs.pbr"
%USEMACROS = 1
#INCLUDE ONCE "WIN32API.INC"
#INCLUDE ONCE "COMMCTRL.INC"
#INCLUDE ONCE "PBForms.INC"
#PBFORMS END INCLUDES
'------------------------------------------------------------------------------
GLOBAL g_hDlg AS DWORD
'------------------------------------------------------------------------------
'   ** Constants **
'------------------------------------------------------------------------------
#PBFORMS BEGIN CONSTANTS
%IDD_DIALOG1   =  101
%IDABORT       =    3
%IDC_LISTVIEW1 = 1001
%IDD_DIALOG2   =  102
%IDC_LABEL1    = 1002
#PBFORMS END CONSTANTS
'------------------------------------------------------------------------------

'------------------------------------------------------------------------------
'   ** Declarations **
'------------------------------------------------------------------------------
DECLARE CALLBACK FUNCTION ShowDIALOG1Proc()
DECLARE FUNCTION SampleListView(BYVAL hDlg AS DWORD, BYVAL lID AS LONG, BYVAL _
  lColCnt AS LONG, BYVAL lRowCnt AS LONG) AS LONG
DECLARE FUNCTION ShowDIALOG1(BYVAL hParent AS DWORD) AS LONG
DECLARE CALLBACK FUNCTION ShowDIALOG2Proc()
DECLARE FUNCTION ShowDIALOG2(BYVAL hDlg AS DWORD) AS LONG
#PBFORMS DECLARATIONS
'------------------------------------------------------------------------------

'------------------------------------------------------------------------------
'   ** Main Application Entry Point **
'------------------------------------------------------------------------------
FUNCTION PBMAIN()
  PBFormsInitComCtls (%ICC_WIN95_CLASSES OR %ICC_DATE_CLASSES OR _
    %ICC_INTERNET_CLASSES)
  ShowDIALOG2 %HWND_DESKTOP  ' show the splash screen modelessly
  ShowDIALOG1 %HWND_DESKTOP  ' show the main dialog
END FUNCTION
'------------------------------------------------------------------------------

'------------------------------------------------------------------------------
'   ** CallBacks **
'------------------------------------------------------------------------------
CALLBACK FUNCTION ShowDIALOG1Proc()

  SELECT CASE AS LONG CB.MSG
    CASE %WM_INITDIALOG
      ' Initialization handler
      ' simulate a delay in getting information on the screen
      SLEEP 5000
      ' after the delay close the splash screen and continue to
      ' show this form
      DIALOG END g_hDlg
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

    CASE %WM_COMMAND
      ' Process control notifications
      SELECT CASE AS LONG CB.CTL
        CASE %IDABORT
          IF CB.CTLMSG = %BN_CLICKED OR CB.CTLMSG = 1 THEN
            DIALOG END CB.HNDL
          END IF

        CASE %IDC_LISTVIEW1

      END SELECT
  END SELECT
END FUNCTION
'------------------------------------------------------------------------------

'------------------------------------------------------------------------------
'   ** Sample Code **
'------------------------------------------------------------------------------
FUNCTION SampleListView(BYVAL hDlg AS DWORD, BYVAL lID AS LONG, BYVAL lColCnt _
  AS LONG, BYVAL lRowCnt AS LONG) AS LONG
  LOCAL lCol   AS LONG
  LOCAL lRow   AS LONG
  LOCAL lStyle AS LONG

  LISTVIEW GET STYLEXX hDlg, lID TO lStyle
  LISTVIEW SET STYLEXX hDlg, lID, lStyle OR %LVS_EX_FULLROWSELECT OR _
    %LVS_EX_GRIDLINES

  ' Load column headers.
  FOR lCol = 1 TO lColCnt
    LISTVIEW INSERT COLUMN hDlg, lID, lCol, USING$("Column #", lCol), 0, 0
  NEXT lCol

  ' Load sample data.
  FOR lRow = 1 TO lRowCnt
    LISTVIEW INSERT ITEM hDlg, lID, lRow, 0, USING$("Column # Row #", lCol, _
      lRow)
    FOR lCol = 1 TO lColCnt
      LISTVIEW SET TEXT hDlg, lID, lRow, lCol, USING$("Column # Row #", lCol, _
        lRow)
    NEXT lCol
  NEXT lRow

  ' Auto size columns.
  FOR lCol = 1 TO lColCnt
    LISTVIEW FIT HEADER hDlg, lID, lCol
  NEXT lCol
END FUNCTION
'------------------------------------------------------------------------------

'------------------------------------------------------------------------------
'   ** Dialogs **
'------------------------------------------------------------------------------
FUNCTION ShowDIALOG1(BYVAL hParent AS DWORD) AS LONG
  LOCAL lRslt AS LONG

#PBFORMS BEGIN DIALOG %IDD_DIALOG1->->
  LOCAL hDlg  AS DWORD

  DIALOG NEW hParent, "Dialog1", 92, 138, 652, 333, %WS_POPUP OR %WS_BORDER _
    OR %WS_DLGFRAME OR %WS_CAPTION OR %WS_SYSMENU OR %WS_MINIMIZEBOX OR _
    %WS_MAXIMIZEBOX OR %WS_CLIPSIBLINGS OR %WS_VISIBLE OR %DS_MODALFRAME OR _
    %DS_CENTER OR %DS_3DLOOK OR %DS_NOFAILCREATE OR %DS_SETFONT, _
    %WS_EX_CONTROLPARENT OR %WS_EX_LEFT OR %WS_EX_LTRREADING OR _
    %WS_EX_RIGHTSCROLLBAR, TO hDlg
  CONTROL ADD BUTTON,   hDlg, %IDABORT, "Exit", 570, 300, 50, 15
  CONTROL ADD LISTVIEW, hDlg, %IDC_LISTVIEW1, "Listview1", 40, 25, 505, 250
#PBFORMS END DIALOG
  ' load the list view with some sample data
  SampleListView hDlg, %IDC_LISTVIEW1, 3, 30
  ' show this dialog modally
  DIALOG SHOW MODAL hDlg, CALL ShowDIALOG1Proc TO lRslt

#PBFORMS BEGIN CLEANUP %IDD_DIALOG1
#PBFORMS END CLEANUP

  FUNCTION = lRslt
END FUNCTION
'------------------------------------------------------------------------------
'------------------------------------------------------------------------------
CALLBACK FUNCTION ShowDIALOG2Proc()

  SELECT CASE AS LONG CB.MSG
    CASE %WM_INITDIALOG
      ' Initialization handler

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

    CASE %WM_COMMAND
      ' Process control notifications
      SELECT CASE AS LONG CB.CTL

      END SELECT
  END SELECT
END FUNCTION
'------------------------------------------------------------------------------

'------------------------------------------------------------------------------
FUNCTION ShowDIALOG2(BYVAL hParent AS DWORD) AS LONG
  LOCAL lRslt  AS LONG

#PBFORMS BEGIN DIALOG %IDD_DIALOG2->->
  LOCAL hDlg   AS DWORD
  LOCAL hFont1 AS DWORD

  DIALOG NEW hParent, "Dialog2", 410, 245, 201, 82, %WS_POPUP OR _
    %WS_CLIPSIBLINGS OR %WS_VISIBLE OR %DS_CENTER OR %DS_3DLOOK OR _
    %DS_NOFAILCREATE OR %DS_SETFONT, %WS_EX_CONTROLPARENT OR %WS_EX_TOPMOST _
    OR %WS_EX_LEFT OR %WS_EX_LTRREADING OR %WS_EX_RIGHTSCROLLBAR, TO hDlg
  DIALOG  SET COLOR  hDlg, -1, %RED
  CONTROL ADD LABEL, hDlg, %IDC_LABEL1, "Loading - please wait", 10, 10, 180, _
    65, %WS_CHILD OR %WS_VISIBLE OR %SS_CENTER OR %SS_CENTERIMAGE, _
    %WS_EX_LEFT OR %WS_EX_LTRREADING
  CONTROL SET COLOR  hDlg, %IDC_LABEL1, %WHITE, %BLUE

  FONT NEW "MS Sans Serif", 18, 0, %ANSI_CHARSET TO hFont1

  CONTROL SET FONT hDlg, %IDC_LABEL1, hFont1
#PBFORMS END DIALOG
  g_hDlg = hDlg  ' store the handle of this dialog
  ' and show the dialog modelessly - returning immediately
  ' to the calling routine
  DIALOG SHOW MODELESS hDlg, CALL ShowDIALOG2Proc TO lRslt
  '
#PBFORMS BEGIN CLEANUP %IDD_DIALOG2
  FONT END hFont1
#PBFORMS END CLEANUP

  FUNCTION = lRslt
END FUNCTION
'------------------------------------------------------------------------------
