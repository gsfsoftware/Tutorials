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
#RESOURCE "FirstForm.pbr"
%USEMACROS = 1
#INCLUDE ONCE "WIN32API.INC"
#INCLUDE ONCE "COMMCTRL.INC"
#INCLUDE ONCE "PBForms.INC"
#PBFORMS END INCLUDES
'------------------------------------------------------------------------------
' include the Macros and Window controls library
#INCLUDE ONCE "..\Libraries\Macros.inc"
#INCLUDE ONCE "..\Libraries\PB_Windows_Controls.inc"
'------------------------------------------------------------------------------
'   ** Constants **
'------------------------------------------------------------------------------
#PBFORMS BEGIN CONSTANTS
%IDD_FIRSTFORM         =  101
%IDABORT               =    3
%IDC_DOIT              = 1001
%IDC_txtName           = 1004
%IDC_lblName           = 1005
%IDC_lblExtension      = 1007
%IDC_txtPhoneExtension = 1006
%IDC_lblDepartment     = 1009
%IDC_cboDepartment     = 1008
#PBFORMS END CONSTANTS
'------------------------------------------------------------------------------

'------------------------------------------------------------------------------
'   ** Declarations **
'------------------------------------------------------------------------------
DECLARE CALLBACK FUNCTION ShowFIRSTFORMProc()
DECLARE FUNCTION ShowFIRSTFORM(BYVAL hParent AS DWORD) AS LONG
#PBFORMS DECLARATIONS
'------------------------------------------------------------------------------

'------------------------------------------------------------------------------
'   ** Main Application Entry Point **
'------------------------------------------------------------------------------
FUNCTION PBMAIN()
  PBFormsInitComCtls (%ICC_WIN95_CLASSES OR %ICC_DATE_CLASSES OR _
    %ICC_INTERNET_CLASSES)

  ShowFIRSTFORM %HWND_DESKTOP
END FUNCTION
'------------------------------------------------------------------------------

'------------------------------------------------------------------------------
'   ** CallBacks **
'------------------------------------------------------------------------------
CALLBACK FUNCTION ShowFIRSTFORMProc()
  LOCAL strName AS STRING
  LOCAL strExtension AS STRING
  LOCAL strDepartment AS STRING
  '
  SELECT CASE AS LONG CB.MSG
    CASE %WM_INITDIALOG
    ' Initialization handler
    ' set maximum number of characters on two fields
      mSetTextLimit(%IDC_txtPhoneExtension,4)
      mSetTextLimit(%IDC_txtName,100)
      '
      ' populate departments and preselect the Distribution entry
      funPopulateDepartment(CB.HNDL,%IDC_cboDepartment,"Distribution")
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
        ' /* Inserted by PB/Forms 06-05-2021 12:35:59
        CASE %IDC_cboDepartment
        ' */

        ' /* Inserted by PB/Forms 06-05-2021 12:34:56
        CASE %IDC_txtPhoneExtension

        ' */

        CASE %IDABORT
          IF CB.CTLMSG = %BN_CLICKED OR CB.CTLMSG = 1 THEN
          ' user wished to exit application
            DIALOG END CB.HNDL
          END IF

        CASE %IDC_DOIT
          IF CB.CTLMSG = %BN_CLICKED OR CB.CTLMSG = 1 THEN
          ' user has pressed button
          ' so get the value on each field
            PREFIX "CONTROL GET TEXT CB.HNDL,"
              %IDC_txtName TO strName
              %IDC_txtPhoneExtension TO strExtension
              %IDC_cboDepartment TO strDepartment
            END PREFIX
            ' and display them in a message box
            MSGBOX strName & $CRLF & strExtension & _
                   $CRLF & strDepartment
          END IF

        CASE %IDC_txtName

      END SELECT
  END SELECT
END FUNCTION
'------------------------------------------------------------------------------

'------------------------------------------------------------------------------
'   ** Dialogs **
'------------------------------------------------------------------------------
FUNCTION ShowFIRSTFORM(BYVAL hParent AS DWORD) AS LONG
  LOCAL lRslt  AS LONG

#PBFORMS BEGIN DIALOG %IDD_FIRSTFORM->->
  LOCAL hDlg   AS DWORD
  LOCAL hFont1 AS DWORD

  DIALOG NEW hParent, "First form ", 332, 159, 513, 271, %WS_POPUP OR _
    %WS_BORDER OR %WS_DLGFRAME OR %WS_CAPTION OR %WS_SYSMENU OR _
    %WS_MINIMIZEBOX OR %WS_CLIPSIBLINGS OR %WS_VISIBLE OR %DS_MODALFRAME OR _
    %DS_CENTER OR %DS_3DLOOK OR %DS_NOFAILCREATE OR %DS_SETFONT, _
    %WS_EX_CONTROLPARENT OR %WS_EX_LEFT OR %WS_EX_LTRREADING OR _
    %WS_EX_RIGHTSCROLLBAR, TO hDlg
  CONTROL ADD TEXTBOX,  hDlg, %IDC_txtName, "", 40, 40, 285, 15
  CONTROL ADD TEXTBOX,  hDlg, %IDC_txtPhoneExtension, "", 370, 40, 65, 15, _
    %WS_CHILD OR %WS_VISIBLE OR %WS_TABSTOP OR %ES_LEFT OR %ES_AUTOHSCROLL _
    OR %ES_NUMBER, %WS_EX_CLIENTEDGE OR %WS_EX_LEFT OR %WS_EX_LTRREADING OR _
    %WS_EX_RIGHTSCROLLBAR
  CONTROL ADD COMBOBOX, hDlg, %IDC_cboDepartment, , 40, 95, 165, 40, _
    %WS_CHILD OR %WS_VISIBLE OR %WS_TABSTOP OR %CBS_DROPDOWNLIST OR _
    %CBS_SORT, %WS_EX_LEFT OR %WS_EX_LTRREADING OR %WS_EX_RIGHTSCROLLBAR
  CONTROL ADD BUTTON,   hDlg, %IDC_DOIT, "Do It", 390, 225, 65, 30
  CONTROL ADD BUTTON,   hDlg, %IDABORT, "Exit", 30, 240, 50, 15
  CONTROL ADD LABEL,    hDlg, %IDC_lblName, "Please enter your name", 40, 26, _
    225, 10
  CONTROL SET COLOR     hDlg, %IDC_lblName, %BLUE, -1
  CONTROL ADD LABEL,    hDlg, %IDC_lblExtension, "Telephone extension", 350, _
    25, 125, 15
  CONTROL SET COLOR     hDlg, %IDC_lblExtension, %BLUE, -1
  CONTROL ADD LABEL,    hDlg, %IDC_lblDepartment, "Department", 40, 80, 125, _
    15
  CONTROL SET COLOR     hDlg, %IDC_lblDepartment, %BLUE, -1

  FONT NEW "MS Sans Serif", 12, 1, %ANSI_CHARSET TO hFont1

  CONTROL SET FONT hDlg, %IDC_lblName, hFont1
  CONTROL SET FONT hDlg, %IDC_lblExtension, hFont1
  CONTROL SET FONT hDlg, %IDC_lblDepartment, hFont1
#PBFORMS END DIALOG

  DIALOG SHOW MODAL hDlg, CALL ShowFIRSTFORMProc TO lRslt

#PBFORMS BEGIN CLEANUP %IDD_FIRSTFORM
  FONT END hFont1
#PBFORMS END CLEANUP

  FUNCTION = lRslt
END FUNCTION
'------------------------------------------------------------------------------

FUNCTION funPopulateDepartment(hDlg AS DWORD, _
                               lngCombo AS LONG, _
                               strSelection AS STRING) AS LONG
' populate the combobox
  DIM a_strData(1 TO 3) AS STRING
  '
  ARRAY ASSIGN a_strData() = "Payroll","IT", "Distribution"
  '
  funPopulateCombo(hDlg,lngCombo,a_strData(), strSelection)
'
END FUNCTION
