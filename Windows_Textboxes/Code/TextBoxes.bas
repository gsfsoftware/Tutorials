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
#RESOURCE "TextBoxes.pbr"
%USEMACROS = 1
#INCLUDE ONCE "WIN32API.INC"
#INCLUDE ONCE "COMMCTRL.INC"
#INCLUDE ONCE "PBForms.INC"
#PBFORMS END INCLUDES
'------------------------------------------------------------------------------
#INCLUDE ONCE "..\Libraries\Macros.inc"
'------------------------------------------------------------------------------
'   ** Constants **
'------------------------------------------------------------------------------
#PBFORMS BEGIN CONSTANTS
%IDD_dlgTextBoxDemo =  101
%IDC_lblText_1      = 1002
%IDC_lblText_2      = 1004
%IDC_lblText_3      = 1006
%IDC_txtText_1      = 1001
%IDC_txtText_2      = 1003
%IDC_txtText_3      = 1005
%IDABORT            =    3
#PBFORMS END CONSTANTS
'------------------------------------------------------------------------------

'------------------------------------------------------------------------------
'   ** Declarations **
'------------------------------------------------------------------------------
DECLARE CALLBACK FUNCTION ShowdlgTextBoxDemoProc()
DECLARE FUNCTION ShowdlgTextBoxDemo(BYVAL hParent AS DWORD) AS LONG
#PBFORMS DECLARATIONS
'------------------------------------------------------------------------------

'------------------------------------------------------------------------------
'   ** Main Application Entry Point **
'------------------------------------------------------------------------------
FUNCTION PBMAIN()
  PBFormsInitComCtls (%ICC_WIN95_CLASSES OR %ICC_DATE_CLASSES OR _
    %ICC_INTERNET_CLASSES)
  DIALOG DEFAULT FONT "Arial", 16
  ShowdlgTextBoxDemo %HWND_DESKTOP
END FUNCTION
'------------------------------------------------------------------------------

'------------------------------------------------------------------------------
'   ** CallBacks **
'------------------------------------------------------------------------------
CALLBACK FUNCTION ShowdlgTextBoxDemoProc()

  SELECT CASE AS LONG CB.MSG
    CASE %WM_INITDIALOG
      ' Initialization handler
      CONTROL SET TEXT CB.HNDL,%IDC_txtText_1,"1234"
      ' limit text box 1 to 4 characters
      'CONTROL POST CB.HNDL,%IDC_txtText_1, %EM_SETLIMITTEXT,4, 0
      mSetTextLimit(%IDC_txtText_1,4)
      '
      ' set text box to read only or writable
      'control post CB.HNDL,%IDC_txtText_2, %EM_SETREADONLY,%FALSE,0
      mSetTextReadOnly(%IDC_txtText_2, %FALSE)
      '
      ' change the foreground/background colour of a text box
      CONTROL SET COLOR CB.HNDL, %IDC_txtText_3, %WHITE, %RED
      '
      ' set the focus of the cursor to a field
      CONTROL SET FOCUS CB.HNDL, %IDC_txtText_3
      '
      ' hide a control
      CONTROL HIDE CB.HNDL,%IDC_txtText_1
      '
       ' restore a control to visibility
      CONTROL NORMALIZE CB.HNDL,%IDC_txtText_1

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
        CASE %IDC_txtText_1

        CASE %IDC_txtText_2
          IF CB.CTLMSG = %EN_SETFOCUS THEN
            ' do once text box has the focus
            'CONTROL POST CB.HNDL, %IDC_txtText_2, %EM_SETSEL, 0,-1
            'CONTROL POST CB.HNDL, cb.ctl, %EM_SETSEL, 0,-1
            mSetTextPreSelect(CB.CTL)
          END IF
          '
        CASE %IDC_txtText_3

        CASE %IDABORT
          IF CB.CTLMSG = %BN_CLICKED OR CB.CTLMSG = 1 THEN
            DIALOG END CB.HNDL
          END IF

      END SELECT
  END SELECT
END FUNCTION
'------------------------------------------------------------------------------

'------------------------------------------------------------------------------
'   ** Dialogs **
'------------------------------------------------------------------------------
FUNCTION ShowdlgTextBoxDemo(BYVAL hParent AS DWORD) AS LONG
  LOCAL lRslt AS LONG

#PBFORMS BEGIN DIALOG %IDD_dlgTextBoxDemo->->
  LOCAL hDlg  AS DWORD

  DIALOG NEW hParent, "Text box demo", 302, 188, 386, 216, %WS_POPUP OR _
    %WS_BORDER OR %WS_DLGFRAME OR %WS_CAPTION OR %WS_SYSMENU OR _
    %WS_MINIMIZEBOX OR %WS_CLIPSIBLINGS OR %WS_VISIBLE OR %DS_MODALFRAME OR _
    %DS_CENTER OR %DS_3DLOOK OR %DS_NOFAILCREATE OR %DS_SETFONT, _
    %WS_EX_CONTROLPARENT OR %WS_EX_LEFT OR %WS_EX_LTRREADING OR _
    %WS_EX_RIGHTSCROLLBAR, TO hDlg
  CONTROL ADD TEXTBOX, hDlg, %IDC_txtText_1, "", 125, 40, 100, 13
  CONTROL ADD LABEL,   hDlg, %IDC_lblText_1, "Text box 1", 15, 41, 100, 10
  CONTROL SET COLOR    hDlg, %IDC_lblText_1, %BLUE, -1
  CONTROL ADD TEXTBOX, hDlg, %IDC_txtText_2, "", 125, 60, 100, 13, %WS_CHILD _
    OR %WS_VISIBLE OR %WS_TABSTOP OR %ES_LEFT OR %ES_AUTOHSCROLL OR _
    %ES_READONLY, %WS_EX_CLIENTEDGE OR %WS_EX_LEFT OR %WS_EX_LTRREADING OR _
    %WS_EX_RIGHTSCROLLBAR
  CONTROL ADD LABEL,   hDlg, %IDC_lblText_2, "Text box 2", 15, 61, 100, 10
  CONTROL SET COLOR    hDlg, %IDC_lblText_2, %BLUE, -1
  CONTROL ADD TEXTBOX, hDlg, %IDC_txtText_3, "", 125, 80, 100, 13
  CONTROL ADD LABEL,   hDlg, %IDC_lblText_3, "Text box 3", 15, 80, 100, 10
  CONTROL SET COLOR    hDlg, %IDC_lblText_3, %BLUE, -1
  CONTROL ADD BUTTON,  hDlg, %IDABORT, "Exit", 310, 185, 50, 15
#PBFORMS END DIALOG

  DIALOG SHOW MODAL hDlg, CALL ShowdlgTextBoxDemoProc TO lRslt

#PBFORMS BEGIN CLEANUP %IDD_dlgTextBoxDemo
#PBFORMS END CLEANUP

  FUNCTION = lRslt
END FUNCTION
'------------------------------------------------------------------------------
