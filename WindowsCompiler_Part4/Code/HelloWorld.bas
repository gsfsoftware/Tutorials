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

#COMPILE EXE "ReadTheData.exe"
#DIM ALL

'------------------------------------------------------------------------------
'   ** Includes **
'------------------------------------------------------------------------------
#PBFORMS BEGIN INCLUDES
#RESOURCE "HelloWorld.pbr"
%USEMACROS = 1
#INCLUDE ONCE "WIN32API.INC"
#INCLUDE ONCE "COMMCTRL.INC"
#INCLUDE ONCE "PBForms.INC"
#PBFORMS END INCLUDES
'------------------------------------------------------------------------------
#INCLUDE "..\Libraries\PB_FileHandlingRoutines.inc"
#INCLUDE "..\Libraries\PB_Windows_Controls.inc"
'------------------------------------------------------------------------------
'   ** Constants **
'------------------------------------------------------------------------------
#PBFORMS BEGIN CONSTANTS
%IDD_dlgFirstDialog =  101
%IDABORT            =    3
%IDC_lblTitle       = 1001
%IDC_cboEyeColour   = 1002
%IDC_STATUSBAR      = 1003
%IDC_lblBloodGroup  = 1004
%IDC_SEARCH         = 1006
%IDC_cboBloodGroup  = 1005
%IDC_GRAPHIC1       = 1007
%IDC_lvDataGrid     = 1008
#PBFORMS END CONSTANTS
'------------------------------------------------------------------------------
ENUM lv
  LEFT = 0
  RIGHT
  Center
END ENUM
'------------------------------------------------------------------------------
'   ** Declarations **
'------------------------------------------------------------------------------
DECLARE CALLBACK FUNCTION ShowdlgFirstDialogProc()
DECLARE FUNCTION ShowdlgFirstDialog(BYVAL hParent AS DWORD) AS LONG
#PBFORMS DECLARATIONS
'------------------------------------------------------------------------------

'------------------------------------------------------------------------------
'   ** Main Application Entry Point **
'------------------------------------------------------------------------------
FUNCTION PBMAIN()
    PBFormsInitComCtls (%ICC_WIN95_CLASSES OR %ICC_DATE_CLASSES OR _
        %ICC_INTERNET_CLASSES)

    ShowdlgFirstDialog %HWND_DESKTOP
    '
END FUNCTION
'------------------------------------------------------------------------------

'------------------------------------------------------------------------------
'   ** CallBacks **
'------------------------------------------------------------------------------
CALLBACK FUNCTION ShowdlgFirstDialogProc()
    LOCAL strText AS STRING
    DIM a_strData() AS STRING
    LOCAL strEyeColour AS STRING
    LOCAL strBloodGroup AS STRING
    LOCAL lngFound AS LONG
    LOCAL strSearchCritera AS STRING
    LOCAL strColumn AS STRING
    '
    SELECT CASE AS LONG CB.MSG
        CASE %WM_INITDIALOG
        ' Initialization handler
        ' populate combo
          IF ISTRUE funGetData(a_strData(), "EyeColour.csv") THEN
            funPopulateCombo(CB.HNDL, %IDC_cboEyeColour, _
                             a_strData(),"")
          END IF
          '
          IF ISTRUE funGetData(a_strData(), "BloodGroups.csv") THEN
            funPopulateCombo(CB.HNDL, %IDC_cboBloodGroup, _
                             a_strData(),"")
          END IF

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
                ' /* Inserted by PB/Forms 10-12-2019 09:56:26
                CASE %IDC_lvDataGrid
                ' */

                ' /* Inserted by PB/Forms 10-05-2019 13:33:12
                ' */

                ' /* Inserted by PB/Forms 10-05-2019 13:32:33
                CASE %IDC_STATUSBAR

                CASE %IDC_SEARCH
                  IF CB.CTLMSG = %BN_CLICKED OR CB.CTLMSG = 1 THEN
                  ' button has been clicked
                    CONTROL GET TEXT CB.HNDL,%IDC_cboEyeColour TO strEyeColour
                    CONTROL GET TEXT CB.HNDL,%IDC_cboBloodGroup TO strBloodGroup
                    '
                    SELECT CASE strEyeColour
                      CASE ""
                        IF strBloodGroup <> "" THEN
                          CONTROL SET TEXT CB.HNDL,%IDC_STATUSBAR, _
                          "Searching for " & strBloodGroup
                          lngFound = %TRUE
                          strSearchCritera = strBloodGroup
                          strColumn = "Blood Group"
                          '
                        END IF
                      CASE ELSE
                        CONTROL SET TEXT CB.HNDL,%IDC_STATUSBAR, _
                          "Searching for " & strEyeColour
                        lngFound = %TRUE
                        strSearchCritera = strEyeColour
                        strColumn = "Eye Colour"
                    END SELECT
                    '
                    IF ISTRUE lngFound THEN
                    ' run the search
                      CONTROL SET TEXT CB.HNDL,%IDC_STATUSBAR,"Searching..."
                      CONTROL DISABLE CB.HNDL,%IDC_SEARCH
                      funRunTheSearch(strSearchCritera, strColumn, _
                                      %IDC_STATUSBAR, CB.HNDL, %IDC_GRAPHIC1, _
                                      %IDC_lvDataGrid)
                      CONTROL ENABLE CB.HNDL,%IDC_SEARCH
                    '
                    END IF
                    '
                  END IF
                ' */

                ' /* Inserted by PB/Forms 09-30-2019 17:06:02
                CASE %IDC_cboEyeColour
                  IF CB.CTLMSG = %BN_CLICKED OR CB.CTLMSG = 1 THEN
                    COMBOBOX UNSELECT CB.HNDL, %IDC_cboBloodGroup
                  END IF
                  '
                CASE %IDC_cboBloodGroup
                  IF CB.CTLMSG = %BN_CLICKED OR CB.CTLMSG = 1 THEN
                    COMBOBOX UNSELECT CB.HNDL, %IDC_cboEyeColour
                  END IF

                ' */

                CASE %IDABORT
                  IF CB.CTLMSG = %BN_CLICKED OR CB.CTLMSG = 1 THEN
                    IF MSGBOX("Are you sure ? ",%MB_YESNO, _
                              "Exit Application") = %IDYES THEN
                      DIALOG END CB.HNDL
                    END IF
                    '
                  END IF

            END SELECT
    END SELECT
END FUNCTION
'------------------------------------------------------------------------------

'------------------------------------------------------------------------------
'   ** Dialogs **
'------------------------------------------------------------------------------
FUNCTION ShowdlgFirstDialog(BYVAL hParent AS DWORD) AS LONG
    LOCAL lRslt AS LONG

#PBFORMS BEGIN DIALOG %IDD_dlgFirstDialog->->
    LOCAL hDlg  AS DWORD

    DIALOG NEW hParent, "Our First dialog", 267, 169, 450, 242, %WS_POPUP OR _
        %WS_BORDER OR %WS_DLGFRAME OR %WS_CAPTION OR %WS_SYSMENU OR _
        %WS_CLIPSIBLINGS OR %WS_VISIBLE OR %DS_MODALFRAME OR %DS_CENTER OR _
        %DS_3DLOOK OR %DS_NOFAILCREATE OR %DS_SETFONT, %WS_EX_CONTROLPARENT _
        OR %WS_EX_LEFT OR %WS_EX_LTRREADING OR %WS_EX_RIGHTSCROLLBAR, TO _
        hDlg
    CONTROL ADD BUTTON,    hDlg, %IDABORT, "Exit", 376, 210, 50, 15
    CONTROL ADD LABEL,     hDlg, %IDC_lblTitle, "Select the Eye Colour", 20, _
        35, 145, 15
    CONTROL SET COLOR      hDlg, %IDC_lblTitle, %BLUE, -1
    CONTROL ADD COMBOBOX,  hDlg, %IDC_cboEyeColour, , 20, 50, 145, 60, _
        %WS_CHILD OR %WS_VISIBLE OR %WS_TABSTOP OR %CBS_DROPDOWNLIST OR _
        %CBS_SORT, %WS_EX_LEFT OR %WS_EX_LTRREADING OR %WS_EX_RIGHTSCROLLBAR
    CONTROL ADD STATUSBAR, hDlg, %IDC_STATUSBAR, "Ready", 0, 0, 0, 0
    CONTROL ADD LABEL,     hDlg, %IDC_lblBloodGroup, "Select the Blood " + _
        "Group", 195, 35, 145, 15
    CONTROL SET COLOR      hDlg, %IDC_lblBloodGroup, %BLUE, -1
    CONTROL ADD COMBOBOX,  hDlg, %IDC_cboBloodGroup, , 195, 50, 145, 60, _
        %WS_CHILD OR %WS_VISIBLE OR %WS_TABSTOP OR %CBS_DROPDOWNLIST OR _
        %CBS_SORT, %WS_EX_LEFT OR %WS_EX_LTRREADING OR %WS_EX_RIGHTSCROLLBAR
    CONTROL ADD BUTTON,    hDlg, %IDC_SEARCH, "Search", 375, 50, 50, 15
    CONTROL ADD GRAPHIC,   hDlg, %IDC_GRAPHIC1, "", 345, 85, 100, 100, _
        %WS_CHILD OR %WS_VISIBLE OR %WS_BORDER
    CONTROL ADD LISTVIEW,  hDlg, %IDC_lvDataGrid, "", 20, 80, 320, 140
#PBFORMS END DIALOG
    ' populate combo
    DIALOG SET TEXT hDlg, "Search the Data"
    '
    GRAPHIC ATTACH hDlg, %IDC_GRAPHIC1
    '
    LISTVIEW SET STYLEXX hDlg, %IDC_lvDataGrid, _
                         %LVS_EX_GRIDLINES OR %LVS_EX_FULLROWSELECT
                         '
    LISTVIEW INSERT COLUMN hDlg, %IDC_lvDataGrid, 1, "First Name", _
                           75,%lv.Center
    LISTVIEW INSERT COLUMN hDlg, %IDC_lvDataGrid, 2, "Surname", _
                           75,%lv.Center
    LISTVIEW INSERT COLUMN hDlg, %IDC_lvDataGrid, 3, "Telephone", _
                           75,%lv.Center


    '
    DIALOG SHOW MODAL hDlg, CALL ShowdlgFirstDialogProc TO lRslt

#PBFORMS BEGIN CLEANUP %IDD_dlgFirstDialog
#PBFORMS END CLEANUP

    FUNCTION = lRslt
END FUNCTION
'------------------------------------------------------------------------------

FUNCTION funGetData(BYREF a_strData() AS STRING, _
                    strFile AS STRING) AS LONG
  LOCAL lngR AS LONG
' read the data into an array
  IF ISTRUE funReadTheFileIntoAnArray(strFile,a_strData()) THEN
    FOR lngR = 1 TO UBOUND(a_strData)
      a_strData(lngR) = PARSE$(a_strData(lngR),",",1)
    NEXT lngR
    '
    FUNCTION = %TRUE
  ELSE
    FUNCTION = %FALSE
  END IF
'
END FUNCTION
'
FUNCTION funRunTheSearch(strSearchCritera AS STRING , _
                         strColumn  AS STRING, _
                         lngStatusBar AS LONG, _
                         hDlg AS DWORD, _
                         lngGRAPHIC AS LONG, _
                         lngListView AS LONG)  AS LONG
                         '
  DIM a_strWork() AS STRING
  LOCAL lngR AS LONG
  LOCAL lngColumn AS LONG
  LOCAL strValue AS STRING
  LOCAL lngCount AS LONG

  '
' search the file for matches
  IF ISTRUE funReadTheFileIntoAnArray(EXE.PATH$ & "MyLargeFile.txt", _
                            a_strWork()) THEN
  '
  lngColumn = funParseFind(a_strWork(0) ,$TAB,strColumn)
  '
  FOR lngR = 1 TO UBOUND(a_strWork)
    strValue = PARSE$(a_strWork(lngR),$TAB,lngColumn)
    IF UCASE$(strSearchCritera) = UCASE$(strValue) THEN
    ' match found
      INCR lngCount

      LISTVIEW INSERT ITEM hDlg, lngListView, lngCount, 0, _
               PARSE$(a_strWork(lngR),$TAB,1)
      LISTVIEW SET TEXT hDlg, lngListView, lngCount, 2, _
               PARSE$(a_strWork(lngR),$TAB,2)
      LISTVIEW SET TEXT hDlg, lngListView, lngCount, 3, _
               PARSE$(a_strWork(lngR),$TAB,4)
    '
    END IF
    '
  NEXT lngR
  '
  CONTROL SET TEXT hDlg,lngStatusBar, "Records found = " & _
                   FORMAT$(lngCount)
  '
  LOCAL lngTotal AS LONG
  LOCAL dbPercent AS DOUBLE
  LOCAL Pi2 AS DOUBLE
  pi2 = 8 * ATN(1)
  lngTotal = UBOUND(a_strWork)
  dbPercent = (lngCount/lngTotal)
  '
  GRAPHIC PIE (2,2)-(95,95),0,Pi2 * dbPercent,%BLACK,%BLUE,0
  GRAPHIC PIE (2,2)-(95,95),Pi2 * dbPercent,pi2 * 1,%BLACK,%GREEN,0
  '
  ELSE
    CONTROL SET TEXT hDlg,lngStatusBar, "File not loaded"
  END IF
'
END FUNCTION
