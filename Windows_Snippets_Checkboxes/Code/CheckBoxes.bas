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
'#RESOURCE "CheckBoxes.pbr"
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
%IDD_dlgCheckboxes =  101
%IDOK              =    1
%IDC_CHECKBOX1     = 1001
%IDC_CHECKBOX2     = 1002
%IDC_CHECK3STATE1  = 1003
%IDC_txtOutput     = 1004
%IDC_CHECKBOX3     = 1005
#PBFORMS END CONSTANTS
'------------------------------------------------------------------------------
'#RESOURCE MANIFEST, 1, "XPTheme.xml"
#RESOURCE ICON, 4000, "add.ico"
'------------------------------------------------------------------------------
'   ** Declarations **
'------------------------------------------------------------------------------
DECLARE CALLBACK FUNCTION ShowdlgCheckboxesProc()
DECLARE FUNCTION ShowdlgCheckboxes(BYVAL hParent AS DWORD) AS LONG
#PBFORMS DECLARATIONS
'------------------------------------------------------------------------------

'------------------------------------------------------------------------------
'   ** Main Application Entry Point **
'------------------------------------------------------------------------------
FUNCTION PBMAIN()
  PBFormsInitComCtls (%ICC_WIN95_CLASSES OR %ICC_DATE_CLASSES OR _
    %ICC_INTERNET_CLASSES)

  ShowdlgCheckboxes %HWND_DESKTOP
END FUNCTION
'------------------------------------------------------------------------------

'------------------------------------------------------------------------------
'   ** CallBacks **
'------------------------------------------------------------------------------
CALLBACK FUNCTION ShowdlgCheckboxesProc()
  LOCAL lngResult AS LONG
  '
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
        ' /* Inserted by PB/Forms 06-23-2024 14:25:21
        CASE %IDC_txtOutput
        '
        CASE %IDC_CHECKBOX3
          IF CB.CTLMSG = %BN_CLICKED OR CB.CTLMSG = 1 THEN
            funDisplayCheckState(CB.HNDL, CB.CTL,%IDC_txtOutput)
          END IF
          '
        CASE %IDC_CHECKBOX2
          IF CB.CTLMSG = %BN_CLICKED OR CB.CTLMSG = 1 THEN
            funDisplayCheckState(CB.HNDL, CB.CTL,%IDC_txtOutput)
          END IF
          '
        CASE %IDC_CHECK3STATE1
          IF CB.CTLMSG = %BN_CLICKED OR CB.CTLMSG = 1 THEN
            funDisplayCheckState(CB.HNDL, CB.CTL,%IDC_txtOutput)
          END IF

        ' /* Inserted by PB/Forms 06-23-2024 14:07:53
        CASE %IDC_CHECKBOX1
          IF CB.CTLMSG = %BN_CLICKED OR CB.CTLMSG = 1 THEN
            funDisplayCheckState(CB.HNDL, CB.CTL,%IDC_txtOutput)
          END IF
          '
        CASE %IDOK
          IF CB.CTLMSG = %BN_CLICKED OR CB.CTLMSG = 1 THEN
            DIALOG END CB.HNDL, %IDOK
          END IF

      END SELECT
  END SELECT
END FUNCTION
'------------------------------------------------------------------------------
FUNCTION funDisplayCheckState(hDlg AS DWORD, _
                              lngControl AS LONG, _
                              lngOutput AS LONG) AS LONG
' display the state of the checkbox in the text box
  LOCAL lngResult AS LONG
  '
  CONTROL GET CHECK hDlg, lngControl TO lngResult
  SELECT CASE lngResult
    CASE 0
    ' unchecked
      CONTROL SET TEXT hDlg,lngOutput, "Unchecked"
    CASE 1
    ' checked
      CONTROL SET TEXT hDlg,lngOutput, "Checked"
    CASE 2
    ' greyed out - indeterminate
      CONTROL SET TEXT hDlg,lngOutput, "Indeterminate"
      '
  END SELECT
  '
END FUNCTION
'------------------------------------------------------------------------------
'   ** Dialogs **
'------------------------------------------------------------------------------
FUNCTION ShowdlgCheckboxes(BYVAL hParent AS DWORD) AS LONG
  LOCAL lRslt AS LONG
  LOCAL hFont1 AS DWORD
  LOCAL hImage AS DWORD
  '
#PBFORMS BEGIN DIALOG %IDD_dlgCheckboxes->->
  LOCAL hDlg  AS DWORD

  DIALOG NEW hParent, "Checkboxes demo", 259, 187, 594, 315, %WS_POPUP OR _
    %WS_BORDER OR %WS_DLGFRAME OR %WS_CAPTION OR %WS_SYSMENU OR _
    %WS_CLIPSIBLINGS OR %WS_VISIBLE OR %DS_MODALFRAME OR %DS_CENTER OR _
    %DS_3DLOOK OR %DS_NOFAILCREATE OR %DS_SETFONT, %WS_EX_CONTROLPARENT OR _
    %WS_EX_LEFT OR %WS_EX_LTRREADING OR %WS_EX_RIGHTSCROLLBAR, TO hDlg
  CONTROL ADD BUTTON,      hDlg, %IDOK, "Ok", 490, 275, 50, 15
  DIALOG  SEND             hDlg, %DM_SETDEFID, %IDOK, 0
  CONTROL ADD CHECKBOX,    hDlg, %IDC_CHECKBOX1, "CheckBox1 details", 50, 55, _
    150, 20
  CONTROL ADD TEXTBOX,     hDlg, %IDC_txtOutput, "", 50, 180, 490, 75, _
    %WS_CHILD OR %WS_VISIBLE OR %WS_TABSTOP OR %ES_LEFT OR %ES_MULTILINE OR _
    %ES_AUTOHSCROLL, %WS_EX_CLIENTEDGE OR %WS_EX_LEFT OR %WS_EX_LTRREADING _
    OR %WS_EX_RIGHTSCROLLBAR
  'CONTROL ADD CHECKBOX,    hDlg, %IDC_CHECKBOX2, "CheckBox2 details", 50, 85, _
  '  150, 20, %WS_CHILD OR %WS_VISIBLE OR %WS_TABSTOP OR %BS_ICON OR _
  '  %BS_AUTOCHECKBOX OR %BS_LEFT OR %BS_VCENTER, %WS_EX_LEFT OR _
  '  %WS_EX_LTRREADING
  CONTROL ADD CHECK3STATE, hDlg, %IDC_CHECK3STATE1, "Check3State1", 50, 115, _
    160, 15
#PBFORMS END DIALOG
  FONT NEW "MS Sans Serif", 18, 0, %ANSI_CHARSET TO hFont1
  '
  DIALOG SET ICON hDlg, "#4000"
  ' create the 2nd checkbox with an icon
  CONTROL ADD "Button", hDlg, %IDC_CHECKBOX2, "", 50,85,160,20, _
              %WS_VISIBLE OR %WS_CHILD OR %BS_ICON OR _
              %BS_AUTOCHECKBOX
  hImage = LoadImage(%NULL, "add.ico", %IMAGE_ICON, 0, 0, _
           %LR_LOADFROMFILE OR %LR_DEFAULTCOLOR)
  CONTROL SEND hDlg, %IDC_CHECKBOX2, %BM_SETIMAGE, %IMAGE_ICON, hImage
  '
  ' create the 3rd checkbox with an image
  CONTROL ADD "Button", hDlg, %IDC_CHECKBOX3, "", 50,140,160,20, _
              %WS_VISIBLE OR %WS_CHILD OR %BS_BITMAP OR _
              %BS_AUTOCHECKBOX
  hImage = LoadImage(%NULL, "confirm.bmp", %IMAGE_BITMAP, 0, 0, _
           %LR_LOADFROMFILE OR %LR_DEFAULTCOLOR)
  CONTROL SEND hDlg, %IDC_CHECKBOX3, %BM_SETIMAGE, %IMAGE_BITMAP, hImage
  '
  PREFIX "CONTROL SET FONT hDlg, "
    %IDC_CHECKBOX1, hFont1
    %IDC_CHECKBOX2, hFont1
    %IDC_CHECK3STATE1, hFont1
  END PREFIX
  '
  PREFIX "CONTROL SET COLOR hDlg,"
    %IDC_CHECKBOX1, %BLUE,-1
    %IDC_CHECKBOX2, %BLUE,-1
    %IDC_CHECK3STATE1, %BLUE,-1
  END PREFIX
  '
  DIALOG SHOW MODAL hDlg, CALL ShowdlgCheckboxesProc TO lRslt
  ' close down font
  FONT END hFont1
  '
#PBFORMS BEGIN CLEANUP %IDD_dlgCheckboxes
#PBFORMS END CLEANUP

  FUNCTION = lRslt
END FUNCTION
'------------------------------------------------------------------------------
