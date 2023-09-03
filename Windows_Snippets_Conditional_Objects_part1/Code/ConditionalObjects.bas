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
#RESOURCE "ConditionalObjects.pbr"
%USEMACROS = 1
#INCLUDE ONCE "WIN32API.INC"
#INCLUDE ONCE "COMMCTRL.INC"
#INCLUDE ONCE "PBForms.INC"
#PBFORMS END INCLUDES
'------------------------------------------------------------------------------
#INCLUDE "PB_FileHandlingRoutines.inc"
#INCLUDE "PB_Windows_Controls.inc"
'------------------------------------------------------------------------------
'   ** Constants **
'------------------------------------------------------------------------------
#PBFORMS BEGIN CONSTANTS
%IDD_dlgMainDialog     =  101
%IDC_lblName           = 1001
%IDC_txtName           = 1002
%IDC_lblDepartment     = 1003
%IDC_cboDepartment     = 1004
%IDC_lblManualHandling = 1005
%IDC_chkManualHandling = 1006
%IDC_lblPermanentStaff = 1007
%IDC_cboPermanentStaff = 1008
%IDC_lblStartDate      = 1010
%IDC_lblEndDate        = 1012
%IDC_dtStartdate       = 1009
%IDC_dtEndDate         = 1011
%IDOK                  =    1
%IDABORT               =    3
#PBFORMS END CONSTANTS
'------------------------------------------------------------------------------

'------------------------------------------------------------------------------
'   ** Declarations **
'------------------------------------------------------------------------------
'
#PBFORMS DECLARATIONS
'------------------------------------------------------------------------------

'------------------------------------------------------------------------------
'   ** Main Application Entry Point **
'------------------------------------------------------------------------------
FUNCTION PBMAIN()
  PBFormsInitComCtls (%ICC_WIN95_CLASSES OR %ICC_DATE_CLASSES OR _
    %ICC_INTERNET_CLASSES)
  '
  ' set a default font for this application
  DIALOG DEFAULT FONT "MS Sans Serif", 14, 0, %ANSI_CHARSET
  '
  ShowMainDialog %HWND_DESKTOP
END FUNCTION
'------------------------------------------------------------------------------

'------------------------------------------------------------------------------
'   ** CallBacks **
'------------------------------------------------------------------------------
CALLBACK FUNCTION ShowMainDialogProc()
  DIM a_strData() AS STRING
  LOCAL strSelection AS STRING
  LOCAL strFile AS STRING
  LOCAL strText AS STRING
  '
  SELECT CASE AS LONG CB.MSG
    CASE %WM_INITDIALOG
    ' Initialization handler
    ' load the departments
      strFile = EXE.PATH$ & "Department.txt"
      '
      IF ISTRUE ISFILE(strFile) THEN
      ' test for file and load it into the array
        IF ISTRUE funReadTheFileIntoAnArray(strFile,a_strData()) THEN
          strSelection = ""
          funPopulateCombo(CB.HNDL, _
                           %IDC_cboDepartment, _
                           BYREF a_strData(), _
                           strSelection)
        END IF
        '
      END IF
      '
      REDIM a_strData(1 TO 2) AS STRING
      ARRAY ASSIGN a_strData() = "YES","NO"
      strSelection = ""
      funPopulateCombo(CB.HNDL, _
                       %IDC_cboPermanentStaff, _
                       BYREF a_strData(), _
                       strSelection)
                       '
      ' make manual handling objects initially invisible
      PREFIX "Control hide cb.hndl,"
        %IDC_chkManualHandling
        %IDC_lblManualHandling
      END PREFIX
      '
      ' make end date invisible until permanent = YES
      PREFIX "Control hide cb.hndl,"
        %IDC_dtEndDate
        %IDC_lblEndDate
      END PREFIX
      '
      ' set the focus to the Name text control
      CONTROL SET FOCUS CB.HNDL,%IDC_txtName
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
        CASE %IDC_txtName

        CASE %IDC_cboDepartment
          ' make manual handling objects visible when Facilities picked
          IF CB.CTLMSG = %BN_CLICKED OR CB.CTLMSG = 1 THEN
            CONTROL GET TEXT CB.HNDL,%IDC_cboDepartment TO strText
            '
            IF strText = "Facilities" THEN
            ' show the objects
              PREFIX "control normalize cb.hndl,"
                %IDC_chkManualHandling
                %IDC_lblManualHandling
              END PREFIX
            ELSE
            ' hide the objects
              PREFIX "control hide cb.hndl,"
                %IDC_chkManualHandling
                %IDC_lblManualHandling
              END PREFIX
            '
            END IF
            '
          END IF

        CASE %IDC_chkManualHandling

        CASE %IDC_cboPermanentStaff
           IF CB.CTLMSG = %BN_CLICKED OR CB.CTLMSG = 1 THEN
             CONTROL GET TEXT CB.HNDL,%IDC_cboPermanentStaff TO strText
             '
             IF strText = "NO" THEN
            ' make end date visible when permanent = NO
              PREFIX "Control normalize cb.hndl,"
                %IDC_dtEndDate
                %IDC_lblEndDate
              END PREFIX
            ELSE
              PREFIX "Control hide cb.hndl,"
                %IDC_dtEndDate
                %IDC_lblEndDate
              END PREFIX
            END IF
           END IF
           '
        CASE %IDC_dtStartdate

        CASE %IDC_dtEndDate

        CASE %IDOK
          IF CB.CTLMSG = %BN_CLICKED OR CB.CTLMSG = 1 THEN
            DIALOG END CB.HNDL, %IDOK
          END IF

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
FUNCTION ShowMainDialog(BYVAL hParent AS DWORD) AS LONG
  LOCAL lRslt AS LONG

#PBFORMS BEGIN DIALOG %IDD_dlgMainDialog->->
  LOCAL hDlg  AS DWORD

  DIALOG NEW hParent, "Confitional Dialogs", 70, 70, 529, 276, %WS_POPUP OR _
    %WS_BORDER OR %WS_DLGFRAME OR %WS_CAPTION OR %WS_SYSMENU OR _
    %WS_MINIMIZEBOX OR %WS_CLIPSIBLINGS OR %WS_VISIBLE OR %DS_MODALFRAME OR _
    %DS_CENTER OR %DS_3DLOOK OR %DS_NOFAILCREATE OR %DS_SETFONT, _
    %WS_EX_CONTROLPARENT OR %WS_EX_LEFT OR %WS_EX_LTRREADING OR _
    %WS_EX_RIGHTSCROLLBAR, TO hDlg
  CONTROL ADD TEXTBOX,  hDlg, %IDC_txtName, "", 15, 20, 100, 13
  CONTROL ADD COMBOBOX, hDlg, %IDC_cboDepartment, , 15, 60, 100, 40, _
    %WS_CHILD OR %WS_VISIBLE OR %WS_TABSTOP OR %WS_VSCROLL OR _
    %CBS_DROPDOWNLIST OR %CBS_SORT, %WS_EX_LEFT OR %WS_EX_LTRREADING OR _
    %WS_EX_RIGHTSCROLLBAR
  CONTROL ADD CHECKBOX, hDlg, %IDC_chkManualHandling, "", 240, 60, 65, 15
  CONTROL ADD COMBOBOX, hDlg, %IDC_cboPermanentStaff, , 15, 120, 100, 40, _
    %WS_CHILD OR %WS_VISIBLE OR %WS_TABSTOP OR %WS_VSCROLL OR _
    %CBS_DROPDOWNLIST OR %CBS_SORT, %WS_EX_LEFT OR %WS_EX_LTRREADING OR _
    %WS_EX_RIGHTSCROLLBAR
  CONTROL ADD "SysMonthCal32", hDlg, %IDC_dtStartdate, "SysMonthCal32_1", _
    195, 121, 155, 104, %WS_CHILD OR %WS_VISIBLE OR %WS_TABSTOP, _
    %WS_EX_CLIENTEDGE OR %WS_EX_LEFT OR %WS_EX_LTRREADING OR _
    %WS_EX_RIGHTSCROLLBAR
  CONTROL ADD "SysMonthCal32", hDlg, %IDC_dtEndDate, "SysMonthCal32_1", 360, _
    120, 155, 105, %WS_CHILD OR %WS_VISIBLE OR %WS_TABSTOP, _
    %WS_EX_CLIENTEDGE OR %WS_EX_LEFT OR %WS_EX_LTRREADING OR _
    %WS_EX_RIGHTSCROLLBAR
  CONTROL ADD BUTTON,   hDlg, %IDABORT, "Exit", 15, 235, 80, 25
  CONTROL ADD BUTTON,   hDlg, %IDOK, "Submit", 430, 235, 80, 25
  DIALOG  SEND          hDlg, %DM_SETDEFID, %IDOK, 0
  CONTROL ADD LABEL,    hDlg, %IDC_lblName, "Enter Name", 15, 10, 100, 10
  CONTROL SET COLOR     hDlg, %IDC_lblName, %BLUE, -1
  CONTROL ADD LABEL,    hDlg, %IDC_lblDepartment, "Select Department", 15, _
    50, 100, 10
  CONTROL SET COLOR     hDlg, %IDC_lblDepartment, %BLUE, -1
  CONTROL ADD LABEL,    hDlg, %IDC_lblManualHandling, "Completed Manual " + _
    "Handling Course?", 195, 50, 135, 10
  CONTROL SET COLOR     hDlg, %IDC_lblManualHandling, %BLUE, -1
  CONTROL ADD LABEL,    hDlg, %IDC_lblPermanentStaff, "Permanent staff", 15, _
    110, 100, 10
  CONTROL SET COLOR     hDlg, %IDC_lblPermanentStaff, %BLUE, -1
  CONTROL ADD LABEL,    hDlg, %IDC_lblStartDate, "Start Date", 195, 110, 100, _
    10
  CONTROL SET COLOR     hDlg, %IDC_lblStartDate, %BLUE, -1
  CONTROL ADD LABEL,    hDlg, %IDC_lblEndDate, "End Date", 360, 109, 100, 10
  CONTROL SET COLOR     hDlg, %IDC_lblEndDate, %BLUE, -1
#PBFORMS END DIALOG

  DIALOG SHOW MODAL hDlg, CALL ShowMainDialogProc TO lRslt

#PBFORMS BEGIN CLEANUP %IDD_dlgMainDialog
#PBFORMS END CLEANUP

  FUNCTION = lRslt
END FUNCTION
'------------------------------------------------------------------------------
