
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
#RESOURCE "ToolBar_Example.pbr"
%USEMACROS = 1
#INCLUDE ONCE "WIN32API.INC"
#INCLUDE ONCE "COMMCTRL.INC"
#INCLUDE ONCE "PBForms.INC"
#PBFORMS END INCLUDES
'------------------------------------------------------------------------------
' now include any resources specific to this application
#RESOURCE ICON, AppIcon, "..\Libraries\Graphics\Sales.ico"
'
' include the generic toolbar library
#INCLUDE "..\Libraries\PB_ToolbarLIB.inc"

'------------------------------------------------------------------------------
'   ** Constants **
'------------------------------------------------------------------------------
#PBFORMS BEGIN CONSTANTS
%IDD_dlgToolBarExample = 101
%IDD_dlgReports        = 102
#PBFORMS END CONSTANTS
'------------------------------------------------------------------------------
' add handles for the toolbars you are going to add
%MainToolbar    = 2000
%ReportsToolbar = 2001
'------------------------------------------------------------------------------
'   ** Declarations **
'------------------------------------------------------------------------------
#PBFORMS DECLARATIONS
'------------------------------------------------------------------------------

'------------------------------------------------------------------------------
'   ** Main Application Entry Point **
'------------------------------------------------------------------------------
FUNCTION PBMAIN()
  PBFormsInitComCtls (%ICC_WIN95_CLASSES OR %ICC_DATE_CLASSES OR _
    %ICC_INTERNET_CLASSES)
  ' show the first dialog
  ShowdlgToolBarExample %HWND_DESKTOP
END FUNCTION
'------------------------------------------------------------------------------

'------------------------------------------------------------------------------
'   ** CallBacks **
'------------------------------------------------------------------------------
CALLBACK FUNCTION ShowdlgToolBarExampleProc()

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
        CASE %ID_Reports
          IF CB.CTLMSG = %BN_CLICKED OR CB.CTLMSG = 1 THEN
          ' open the reports dialog
            ShowdlgReports CB.HNDL
          END IF
      END SELECT
  END SELECT
END FUNCTION
'------------------------------------------------------------------------------

'------------------------------------------------------------------------------
'   ** Dialogs **
'------------------------------------------------------------------------------
FUNCTION ShowdlgToolBarExample(BYVAL hParent AS DWORD) AS LONG
  LOCAL lRslt AS LONG

#PBFORMS BEGIN DIALOG %IDD_dlgToolBarExample->->
  LOCAL hDlg  AS DWORD

  DIALOG NEW hParent, "Toolbar Example", 258, 143, 729, 395, %WS_POPUP OR _
    %WS_BORDER OR %WS_DLGFRAME OR %WS_CAPTION OR %WS_SYSMENU OR _
    %WS_MINIMIZEBOX OR %WS_MAXIMIZEBOX OR %WS_CLIPSIBLINGS OR %WS_VISIBLE OR _
    %DS_MODALFRAME OR %DS_CENTER OR %DS_3DLOOK OR %DS_NOFAILCREATE OR _
    %DS_SETFONT, %WS_EX_CONTROLPARENT OR %WS_EX_LEFT OR %WS_EX_LTRREADING OR _
    %WS_EX_RIGHTSCROLLBAR, TO hDlg
#PBFORMS END DIALOG
' add a new toolbar to this dialog
  CONTROL ADD TOOLBAR, hDlg, %MainToolbar, "", 0, 0, 0, 0, _
        %WS_CHILD OR %WS_VISIBLE OR %WS_TABSTOP OR %CCS_TOP OR _
        %TBSTYLE_FLAT
  ' add the icons and buttons to the blank toolbar
  CreateToolbar hDlg, %MainToolbar
  ' set the icon on the dialog
  DIALOG SET ICON hDlg,"AppIcon"
  ' show the dialog
  DIALOG SHOW MODAL hDlg, CALL ShowdlgToolBarExampleProc TO lRslt

#PBFORMS BEGIN CLEANUP %IDD_dlgToolBarExample
#PBFORMS END CLEANUP

  FUNCTION = lRslt
END FUNCTION
'------------------------------------------------------------------------------
'------------------------------------------------------------------------------
CALLBACK FUNCTION ShowdlgReportsProc()

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
FUNCTION ShowdlgReports(BYVAL hParent AS DWORD) AS LONG
  LOCAL lRslt AS LONG

#PBFORMS BEGIN DIALOG %IDD_dlgReports->->
  LOCAL hDlg  AS DWORD

  DIALOG NEW hParent, "Reports", 415, 184, 374, 211, %WS_POPUP OR %WS_BORDER _
    OR %WS_DLGFRAME OR %WS_CAPTION OR %WS_SYSMENU OR %WS_MINIMIZEBOX OR _
    %WS_MAXIMIZEBOX OR %WS_CLIPSIBLINGS OR %WS_VISIBLE OR %DS_MODALFRAME OR _
    %DS_CENTER OR %DS_3DLOOK OR %DS_NOFAILCREATE OR %DS_SETFONT, _
    %WS_EX_CONTROLPARENT OR %WS_EX_LEFT OR %WS_EX_LTRREADING OR _
    %WS_EX_RIGHTSCROLLBAR, TO hDlg
#PBFORMS END DIALOG
' add a new toolbar to this dialog
  CONTROL ADD TOOLBAR, hDlg, %ReportsToolbar, "", 0, 0, 0, 0, _
        %WS_CHILD OR %WS_VISIBLE OR %WS_TABSTOP OR %CCS_TOP OR _
        %TBSTYLE_FLAT
        '
  ' add the icons and buttons to the blank toolbar
  CreateToolbar hDlg, %ReportsToolbar
  ' set the icon on the dialog
  DIALOG SET ICON hDlg,"TB_ID_Reports"
  ' show the dialog
  DIALOG SHOW MODAL hDlg, CALL ShowdlgReportsProc TO lRslt

#PBFORMS BEGIN CLEANUP %IDD_dlgReports
#PBFORMS END CLEANUP

  FUNCTION = lRslt
END FUNCTION
'------------------------------------------------------------------------------
