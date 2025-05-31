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
#RESOURCE "SetUser.pbr"
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
%IDD_MAIN_DIALOG         =  101
%IDC_STATUSBAR1          = 1001
%IDC_cboDepartments      = 1002
%IDC_lblDepartments      = 1003
%IDABORT                 =    3
%IDC_lblDepartmentPicked = 1004
%IDC_btnProcess          = 1005
%IDD_dlgSecondForm       =  102
%IDC_lblUserValue        = 1006
#PBFORMS END CONSTANTS
'------------------------------------------------------------------------------

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
    '
  LOCAL lngPoint AS LONG
  LOCAL strFont AS STRING
  LOCAL lngStyle AS LONG
  LOCAL lngCharSet AS LONG
  '
  lngPoint = 14
  strFont = "MS Sans Serif"
  '
  DIALOG DEFAULT FONT strFont ,lngPoint, lngStyle, lngCharSet
  '
  ShowMAIN_DIALOG %HWND_DESKTOP
END FUNCTION
'------------------------------------------------------------------------------

'------------------------------------------------------------------------------
'   ** CallBacks **
'------------------------------------------------------------------------------
CALLBACK FUNCTION ShowMAIN_DIALOGProc()
  LOCAL strDepartment AS STRING ' department name
  LOCAL lngItem AS LONG         ' combobox item number
  LOCAL lngUserValue AS LONG    ' user value stored
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
        CASE %IDC_STATUSBAR1

        CASE %IDC_cboDepartments
          IF CB.CTLMSG = %BN_CLICKED OR CB.CTLMSG = 1 THEN
            ' get the item picked
            COMBOBOX GET SELECT CB.HNDL, %IDC_cboDepartments _
                                TO lngItem
            ' get the text selected
            CONTROL GET TEXT CB.HNDL,%IDC_cboDepartments _
                             TO strDepartment
                             '
            ' get the long value stored
            COMBOBOX GET USER CB.HNDL,%IDC_cboDepartments, _
                             lngItem _
                             TO lngUserValue
            '
            ' display on the dialog
            CONTROL SET TEXT CB.HNDL, %IDC_lblDepartmentPicked, _
                                      strDepartment & _
                                      " has been Picked from" & _
                                      " array item = " & _
                                      FORMAT$(lngUserValue)
          END IF
          '
        CASE %IDABORT
          IF CB.CTLMSG = %BN_CLICKED OR CB.CTLMSG = 1 THEN
            DIALOG END CB.HNDL
          END IF

        CASE %IDC_btnProcess
          IF CB.CTLMSG = %BN_CLICKED OR CB.CTLMSG = 1 THEN
          ' get the item picked
            COMBOBOX GET SELECT CB.HNDL, %IDC_cboDepartments _
                                TO lngItem
                                '
            ' get the long value stored
            COMBOBOX GET USER CB.HNDL,%IDC_cboDepartments, _
                             lngItem _
                             TO lngUserValue
                             '
            ' go to next form/dialog
            ShowdlgSecondForm(CB.HNDL, lngUserValue)
          '
          END IF

      END SELECT
  END SELECT
END FUNCTION
'------------------------------------------------------------------------------
FUNCTION funPopulateDepartments(hDlg AS DWORD, _
                                lngCtrlDepartments AS LONG) AS LONG
' populate the departments dropdown
  LOCAL lngTotalDepts AS LONG       ' total number of deparments
  '
  lngTotalDepts = 5
  DIM a_strDepartments(1 TO lngTotalDepts) AS STRING
  '
  ARRAY ASSIGN a_strDepartments() = "Finance", _
                                    "Payroll", _
                                    "IT", _
                                    "Marketing",_
                                    "Human Resources"
                                    '
  LOCAL lngD AS LONG      ' array item
  LOCAL lngItem AS LONG   ' combobox item
  '
  FOR lngD = 1 TO lngTotalDepts
    ' add to the combo box and pick up the item added
    COMBOBOX ADD hDlg, lngCtrlDepartments, _
                       a_strDepartments(lngD) TO lngItem
    ' store the array item in the control
    COMBOBOX SET USER hDlg,lngCtrlDepartments,lngItem, lngD
    '
  NEXT lngD
  '
END FUNCTION
'
'------------------------------------------------------------------------------

'------------------------------------------------------------------------------
'   ** Dialogs **
'------------------------------------------------------------------------------
FUNCTION ShowMAIN_DIALOG(BYVAL hParent AS DWORD) AS LONG
  LOCAL lRslt AS LONG

#PBFORMS BEGIN DIALOG %IDD_MAIN_DIALOG->->
  LOCAL hDlg  AS DWORD

  DIALOG NEW hParent, "Main Dialog", 407, 237, 603, 316, %WS_POPUP OR _
    %WS_BORDER OR %WS_DLGFRAME OR %WS_CAPTION OR %WS_SYSMENU OR _
    %WS_MINIMIZEBOX OR %WS_CLIPSIBLINGS OR %WS_VISIBLE OR %DS_MODALFRAME OR _
    %DS_CENTER OR %DS_3DLOOK OR %DS_NOFAILCREATE OR %DS_SETFONT, _
    %WS_EX_CONTROLPARENT OR %WS_EX_LEFT OR %WS_EX_LTRREADING OR _
    %WS_EX_RIGHTSCROLLBAR, TO hDlg
  CONTROL ADD STATUSBAR, hDlg, %IDC_STATUSBAR1, "Ready", 0, 0, 0, 0
  CONTROL ADD COMBOBOX,  hDlg, %IDC_cboDepartments, , 25, 60, 100, 40, _
    %WS_CHILD OR %WS_VISIBLE OR %WS_TABSTOP OR %WS_VSCROLL OR _
    %CBS_DROPDOWNLIST OR %CBS_SORT, %WS_EX_LEFT OR %WS_EX_LTRREADING OR _
    %WS_EX_RIGHTSCROLLBAR
  CONTROL ADD LABEL,     hDlg, %IDC_lblDepartments, "Departments", 25, 50, _
    100, 10
  CONTROL SET COLOR      hDlg, %IDC_lblDepartments, %BLUE, -1
  CONTROL ADD BUTTON,    hDlg, %IDABORT, "Exit", 525, 275, 50, 15
  CONTROL ADD LABEL,     hDlg, %IDC_lblDepartmentPicked, "No Department " + _
    "Picked", 250, 60, 100, 15
  CONTROL SET COLOR      hDlg, %IDC_lblDepartmentPicked, %BLUE, -1
  CONTROL ADD BUTTON,    hDlg, %IDC_btnProcess, "Process", 255, 275, 50, 15
#PBFORMS END DIALOG

  funPopulateDepartments(hDlg, %IDC_cboDepartments)

  DIALOG SHOW MODAL hDlg, CALL ShowMAIN_DIALOGProc TO lRslt

#PBFORMS BEGIN CLEANUP %IDD_MAIN_DIALOG
#PBFORMS END CLEANUP

  FUNCTION = lRslt
END FUNCTION
'------------------------------------------------------------------------------
'------------------------------------------------------------------------------
CALLBACK FUNCTION ShowdlgSecondFormProc()
  LOCAL lngUserValue AS LONG  ' user value picked
  '
  SELECT CASE AS LONG CB.MSG
    CASE %WM_INITDIALOG
    ' Initialization handler
    ' get the long value stored in slot 1 of the dialog
      DIALOG GET USER CB.HNDL,1 TO lngUserValue
      '
      ' populate the label on screen with the value
      ' retrieved
      CONTROL SET TEXT CB.HNDL,%IDC_lblUserValue, _
                       "User value picked = " & FORMAT$(lngUserValue)
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

      END SELECT
  END SELECT
END FUNCTION
'------------------------------------------------------------------------------

'------------------------------------------------------------------------------
FUNCTION ShowdlgSecondForm(BYVAL hParent AS DWORD, _
                           lngUserValue AS LONG ) AS LONG
  LOCAL lRslt AS LONG

#PBFORMS BEGIN DIALOG %IDD_dlgSecondForm->->
  LOCAL hDlg  AS DWORD

  DIALOG NEW hParent, "Second Form", 437, 238, 335, 189, %WS_POPUP OR _
    %WS_BORDER OR %WS_DLGFRAME OR %WS_CAPTION OR %WS_SYSMENU OR _
    %WS_CLIPSIBLINGS OR %WS_VISIBLE OR %DS_MODALFRAME OR %DS_CENTER OR _
    %DS_3DLOOK OR %DS_NOFAILCREATE OR %DS_SETFONT, %WS_EX_CONTROLPARENT OR _
    %WS_EX_LEFT OR %WS_EX_LTRREADING OR %WS_EX_RIGHTSCROLLBAR, TO hDlg
  CONTROL ADD BUTTON, hDlg, %IDABORT, "Exit", 265, 160, 50, 15
  CONTROL ADD LABEL,  hDlg, %IDC_lblUserValue, "User value picked is = ", 35, _
    50, 185, 15
  CONTROL SET COLOR   hDlg, %IDC_lblUserValue, %BLUE, -1
#PBFORMS END DIALOG
  '
  ' store the user value
  DIALOG SET USER hDlg,1,lngUserValue
  '
  DIALOG SHOW MODAL hDlg, CALL ShowdlgSecondFormProc TO lRslt

#PBFORMS BEGIN CLEANUP %IDD_dlgSecondForm
#PBFORMS END CLEANUP

  FUNCTION = lRslt
END FUNCTION
'------------------------------------------------------------------------------
