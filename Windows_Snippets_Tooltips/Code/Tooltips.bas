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
#RESOURCE "Tooltips.pbr"
#INCLUDE ONCE "WIN32API.INC"
#INCLUDE ONCE "COMMCTRL.INC"
#INCLUDE ONCE "PBForms.INC"
#PBFORMS END INCLUDES
'------------------------------------------------------------------------------

#INCLUDE "..\Libraries\Tooltips.inc"
'------------------------------------------------------------------------------
'   ** Constants **
'------------------------------------------------------------------------------
#PBFORMS BEGIN CONSTANTS
%IDD_dlgTooltipsDemo =  101
%IDC_LABEL1          = 1001
%IDC_LABEL2          = 1002
%IDC_LABEL3          = 1003
%IDC_LABEL4          = 1004
%IDC_LABEL5          = 1005
%IDC_TEXTBOX1        = 1006
%IDC_TEXTBOX2        = 1007
%IDC_TEXTBOX3        = 1008
%IDC_TEXTBOX4        = 1009
%IDC_TEXTBOX5        = 1010
%IDABORT             =    3
%IDOK                =    1
%IDC_cboType         = 1011
%IDC_LABEL6          = 1012
%IDC_LISTBOX1        = 1013
%IDC_PROGRESSBAR1    = 1014
#PBFORMS END CONSTANTS
'------------------------------------------------------------------------------

'------------------------------------------------------------------------------
'   ** Declarations **
'------------------------------------------------------------------------------
DECLARE CALLBACK FUNCTION ShowdlgTooltipsDemoProc()
DECLARE FUNCTION SampleComboBox(BYVAL hDlg AS DWORD, BYVAL lID AS LONG, BYVAL _
  lCount AS LONG) AS LONG
DECLARE FUNCTION SampleListBox(BYVAL hDlg AS DWORD, BYVAL lID AS LONG, BYVAL _
  lCount AS LONG) AS LONG
DECLARE FUNCTION SampleProgress(BYVAL hDlg AS DWORD, BYVAL lID AS LONG) AS _
  LONG
DECLARE FUNCTION ShowdlgTooltipsDemo(BYVAL hParent AS DWORD) AS LONG
#PBFORMS DECLARATIONS
'------------------------------------------------------------------------------

'------------------------------------------------------------------------------
'   ** Main Application Entry Point **
'------------------------------------------------------------------------------
FUNCTION PBMAIN()
  PBFormsInitComCtls (%ICC_WIN95_CLASSES OR %ICC_DATE_CLASSES OR _
    %ICC_INTERNET_CLASSES)
  DIALOG DEFAULT FONT "MS Sans Serif", 14, 0, %ANSI_CHARSET
  ShowdlgTooltipsDemo %HWND_DESKTOP
END FUNCTION
'------------------------------------------------------------------------------

'------------------------------------------------------------------------------
'   ** CallBacks **
'------------------------------------------------------------------------------
CALLBACK FUNCTION ShowdlgTooltipsDemoProc()

  SELECT CASE AS LONG CB.MSG
    CASE %WM_INITDIALOG
    ' Initialization handler
      PREFIX "CALL ToolTip_SetToolTip (GetDlgItem(CB.HNDL, "
        %IDC_PROGRESSBAR1),"Progressbar will show how|far the process has to go")
        %IDABORT), "Click to exit this form")
        %IDC_cboType), "Select from the list or type in a value")
        %IDC_LABEL1), "This is a label")
        %IDC_TEXTBOX1), "This is a text box")
        %IDOK),"Click here for next screen")
        %IDC_LISTBOX1),"Click to select from list")
      END PREFIX

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
        CASE %IDC_TEXTBOX1

        CASE %IDC_TEXTBOX2

        CASE %IDC_TEXTBOX3

        CASE %IDC_TEXTBOX4

        CASE %IDC_TEXTBOX5

        CASE %IDABORT
          IF CB.CTLMSG = %BN_CLICKED OR CB.CTLMSG = 1 THEN
            DIALOG END CB.HNDL
          END IF

        CASE %IDOK
          IF CB.CTLMSG = %BN_CLICKED OR CB.CTLMSG = 1 THEN
            DIALOG END CB.HNDL, %IDOK
          END IF

        CASE %IDC_cboType

        CASE %IDC_LISTBOX1

        CASE %IDC_PROGRESSBAR1

      END SELECT
  END SELECT
END FUNCTION
'------------------------------------------------------------------------------

'------------------------------------------------------------------------------
'   ** Sample Code **
'------------------------------------------------------------------------------
FUNCTION SampleComboBox(BYVAL hDlg AS DWORD, BYVAL lID AS LONG, BYVAL lCount _
  AS LONG) AS LONG
  LOCAL i AS LONG

  CONTROL SEND hDlg, lID, %CB_SETEXTENDEDUI, %TRUE, 0

  FOR i = 1 TO lCount
    COMBOBOX ADD hDlg, lID, USING$("Test Item #", i)
  NEXT i
END FUNCTION
'------------------------------------------------------------------------------

'------------------------------------------------------------------------------
FUNCTION SampleListBox(BYVAL hDlg AS DWORD, BYVAL lID AS LONG, BYVAL lCount _
  AS LONG) AS LONG
  LOCAL i AS LONG

  FOR i = 1 TO lCount
    LISTBOX ADD hDlg, lID, USING$("Test Item #", i)
  NEXT i
END FUNCTION
'------------------------------------------------------------------------------

'------------------------------------------------------------------------------
FUNCTION SampleProgress(BYVAL hDlg AS DWORD, BYVAL lID AS LONG) AS LONG
  PROGRESSBAR SET RANGE hDlg, lID, 0, 100
  PROGRESSBAR SET POS   hDlg, lID, 30
END FUNCTION
'------------------------------------------------------------------------------

'------------------------------------------------------------------------------
'   ** Dialogs **
'------------------------------------------------------------------------------
FUNCTION ShowdlgTooltipsDemo(BYVAL hParent AS DWORD) AS LONG
  LOCAL lRslt AS LONG

#PBFORMS BEGIN DIALOG %IDD_dlgTooltipsDemo->->
  LOCAL hDlg  AS DWORD

  DIALOG NEW hParent, "Tooltips demo", 258, 162, 555, 303, %WS_POPUP OR _
    %WS_BORDER OR %WS_DLGFRAME OR %WS_CAPTION OR %WS_SYSMENU OR _
    %WS_MINIMIZEBOX OR %WS_CLIPSIBLINGS OR %WS_VISIBLE OR %DS_MODALFRAME OR _
    %DS_CENTER OR %DS_3DLOOK OR %DS_NOFAILCREATE OR %DS_SETFONT, _
    %WS_EX_CONTROLPARENT OR %WS_EX_LEFT OR %WS_EX_LTRREADING OR _
    %WS_EX_RIGHTSCROLLBAR, TO hDlg
  CONTROL ADD LABEL,       hDlg, %IDC_LABEL1, "Field label 1", 20, 50, 100, _
    10
  CONTROL SET COLOR        hDlg, %IDC_LABEL1, %BLUE, -1
  CONTROL ADD LABEL,       hDlg, %IDC_LABEL2, "Field label 1", 20, 70, 100, _
    10
  CONTROL SET COLOR        hDlg, %IDC_LABEL2, %BLUE, -1
  CONTROL ADD LABEL,       hDlg, %IDC_LABEL3, "Field label 1", 20, 90, 100, _
    10
  CONTROL SET COLOR        hDlg, %IDC_LABEL3, %BLUE, -1
  CONTROL ADD LABEL,       hDlg, %IDC_LABEL4, "Field label 1", 20, 110, 100, _
    10
  CONTROL SET COLOR        hDlg, %IDC_LABEL4, %BLUE, -1
  CONTROL ADD LABEL,       hDlg, %IDC_LABEL5, "Field label 1", 20, 130, 100, _
    10
  CONTROL SET COLOR        hDlg, %IDC_LABEL5, %BLUE, -1
  CONTROL ADD TEXTBOX,     hDlg, %IDC_TEXTBOX1, "TextBox1", 125, 50, 100, 13
  CONTROL ADD TEXTBOX,     hDlg, %IDC_TEXTBOX2, "TextBox2", 125, 69, 100, 13
  CONTROL ADD TEXTBOX,     hDlg, %IDC_TEXTBOX3, "TextBox3", 125, 88, 100, 13
  CONTROL ADD TEXTBOX,     hDlg, %IDC_TEXTBOX4, "TextBox4", 125, 107, 100, 13
  CONTROL ADD TEXTBOX,     hDlg, %IDC_TEXTBOX5, "TextBox5", 125, 126, 100, 13
  CONTROL ADD BUTTON,      hDlg, %IDABORT, "Exit", 30, 265, 50, 15
  CONTROL ADD BUTTON,      hDlg, %IDOK, "Next", 460, 265, 50, 15
  DIALOG  SEND             hDlg, %DM_SETDEFID, %IDOK, 0
  CONTROL ADD COMBOBOX,    hDlg, %IDC_cboType, , 295, 50, 100, 40
  CONTROL ADD LABEL,       hDlg, %IDC_LABEL6, "Select Type", 295, 40, 100, 10
  CONTROL SET COLOR        hDlg, %IDC_LABEL6, %BLUE, -1
  CONTROL ADD LISTBOX,     hDlg, %IDC_LISTBOX1, , 20, 155, 200, 80
  CONTROL ADD PROGRESSBAR, hDlg, %IDC_PROGRESSBAR1, "ProgressBar1", 260, 185, _
    250, 20
#PBFORMS END DIALOG

  SampleComboBox hDlg, %IDC_cboType, 30
  SampleListBox  hDlg, %IDC_LISTBOX1, 30
  SampleProgress hDlg, %IDC_PROGRESSBAR1

  DIALOG SHOW MODAL hDlg, CALL ShowdlgTooltipsDemoProc TO lRslt

#PBFORMS BEGIN CLEANUP %IDD_dlgTooltipsDemo
#PBFORMS END CLEANUP

  FUNCTION = lRslt
END FUNCTION
'------------------------------------------------------------------------------
