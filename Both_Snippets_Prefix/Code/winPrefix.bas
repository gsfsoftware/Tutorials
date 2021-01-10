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
#RESOURCE "winPrefix.pbr"
%USEMACROS = 1
#INCLUDE ONCE "WIN32API.INC"
#INCLUDE ONCE "COMMCTRL.INC"
#INCLUDE ONCE "PBForms.INC"
#PBFORMS END INCLUDES
'------------------------------------------------------------------------------

'------------------------------------------------------------------------------
'   ** Constants **
'------------------------------------------------------------------------------
#PBFORMS BEGIN CONSTANTS
%IDD_DIALOG1   =  101
%IDABORT       =    3
%IDC_TEXTBOX1  = 1001
%IDC_TEXTBOX2  = 1002
%IDC_TEXTBOX3  = 1003
%IDC_TEXTBOX4  = 1004
%IDC_TEXTBOX5  = 1005
%IDC_TEXTBOX6  = 1006
%IDC_TEXTBOX7  = 1007
%IDC_TEXTBOX8  = 1008
%IDC_TEXTBOX9  = 1009
%IDC_TEXTBOX10 = 1010
%IDC_COMBOBOX1 = 1011
#PBFORMS END CONSTANTS
'------------------------------------------------------------------------------

'------------------------------------------------------------------------------
'   ** Declarations **
'------------------------------------------------------------------------------
DECLARE CALLBACK FUNCTION ShowDIALOG1Proc()
DECLARE FUNCTION ShowDIALOG1(BYVAL hParent AS DWORD) AS LONG
#PBFORMS DECLARATIONS
'------------------------------------------------------------------------------

'------------------------------------------------------------------------------
'   ** Main Application Entry Point **
'------------------------------------------------------------------------------
FUNCTION PBMAIN()
  PBFormsInitComCtls (%ICC_WIN95_CLASSES OR %ICC_DATE_CLASSES OR _
    %ICC_INTERNET_CLASSES)

  ShowDIALOG1 %HWND_DESKTOP
END FUNCTION
'------------------------------------------------------------------------------

'------------------------------------------------------------------------------
'   ** CallBacks **
'------------------------------------------------------------------------------
CALLBACK FUNCTION ShowDIALOG1Proc()

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
        ' /* Inserted by PB/Forms 05-15-2020 21:31:27
        CASE %IDC_COMBOBOX1
        ' */

        CASE %IDABORT
          IF CB.CTLMSG = %BN_CLICKED OR CB.CTLMSG = 1 THEN
            DIALOG END CB.HNDL
          END IF

        CASE %IDC_TEXTBOX1

        CASE %IDC_TEXTBOX2

        CASE %IDC_TEXTBOX3

        CASE %IDC_TEXTBOX4

        CASE %IDC_TEXTBOX5

        CASE %IDC_TEXTBOX6

        CASE %IDC_TEXTBOX7

        CASE %IDC_TEXTBOX8

        CASE %IDC_TEXTBOX9

        CASE %IDC_TEXTBOX10

      END SELECT
  END SELECT
END FUNCTION
'------------------------------------------------------------------------------

'------------------------------------------------------------------------------
'   ** Dialogs **
'------------------------------------------------------------------------------
FUNCTION ShowDIALOG1(BYVAL hParent AS DWORD) AS LONG
  LOCAL lRslt AS LONG

#PBFORMS BEGIN DIALOG %IDD_DIALOG1->->
  LOCAL hDlg  AS DWORD

  DIALOG NEW hParent, "Dialog1", 389, 250, 506, 263, %WS_POPUP OR %WS_BORDER _
    OR %WS_DLGFRAME OR %WS_CAPTION OR %WS_SYSMENU OR %WS_CLIPSIBLINGS OR _
    %WS_VISIBLE OR %DS_MODALFRAME OR %DS_3DLOOK OR %DS_NOFAILCREATE OR _
    %DS_SETFONT, %WS_EX_CONTROLPARENT OR %WS_EX_LEFT OR %WS_EX_LTRREADING OR _
    %WS_EX_RIGHTSCROLLBAR, TO hDlg
  CONTROL ADD BUTTON,   hDlg, %IDABORT, "Exit", 415, 225, 50, 15
  CONTROL ADD TEXTBOX,  hDlg, %IDC_TEXTBOX1, "TextBox1", 15, 16, 100, 13
  CONTROL ADD TEXTBOX,  hDlg, %IDC_TEXTBOX2, "TextBox1", 15, 35, 100, 13
  CONTROL ADD TEXTBOX,  hDlg, %IDC_TEXTBOX3, "TextBox1", 15, 53, 100, 13
  CONTROL ADD TEXTBOX,  hDlg, %IDC_TEXTBOX4, "TextBox1", 15, 67, 100, 13
  CONTROL ADD TEXTBOX,  hDlg, %IDC_TEXTBOX5, "TextBox1", 15, 82, 100, 13
  CONTROL ADD TEXTBOX,  hDlg, %IDC_TEXTBOX6, "TextBox1", 15, 97, 100, 13
  CONTROL ADD TEXTBOX,  hDlg, %IDC_TEXTBOX7, "TextBox1", 15, 112, 100, 13
  CONTROL ADD TEXTBOX,  hDlg, %IDC_TEXTBOX8, "TextBox1", 15, 127, 100, 13
  CONTROL ADD TEXTBOX,  hDlg, %IDC_TEXTBOX9, "TextBox1", 15, 142, 100, 13
  CONTROL ADD TEXTBOX,  hDlg, %IDC_TEXTBOX10, "TextBox1", 15, 157, 100, 13
  CONTROL ADD COMBOBOX, hDlg, %IDC_COMBOBOX1, , 140, 15, 100, 40
#PBFORMS END DIALOG
  '
  PREFIX "Control disable hDlg,"
    %IDC_TEXTBOX1
    %IDC_TEXTBOX2
    %IDC_TEXTBOX3
    %IDC_TEXTBOX4
    %IDC_TEXTBOX5
    %IDC_TEXTBOX6
    %IDC_TEXTBOX7
    %IDC_TEXTBOX8
    %IDC_TEXTBOX9
    %IDC_TEXTBOX10
    %IDC_COMBOBOX1
  END PREFIX
  '
  DIALOG SHOW MODAL hDlg, CALL ShowDIALOG1Proc TO lRslt

#PBFORMS BEGIN CLEANUP %IDD_DIALOG1
#PBFORMS END CLEANUP

  FUNCTION = lRslt
END FUNCTION
'------------------------------------------------------------------------------
