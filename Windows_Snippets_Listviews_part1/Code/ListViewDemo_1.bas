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
#RESOURCE "ListViewDemo_1.pbr"
#INCLUDE ONCE "WIN32API.INC"
#INCLUDE ONCE "COMMCTRL.INC"
#INCLUDE ONCE "PBForms.INC"
#PBFORMS END INCLUDES
'------------------------------------------------------------------------------

'------------------------------------------------------------------------------
'   ** Constants **
'------------------------------------------------------------------------------
#PBFORMS BEGIN CONSTANTS
%IDD_DlgListview =  101
%IDABORT         =    3
%IDC_LISTVIEW1   = 1001
#PBFORMS END CONSTANTS
'------------------------------------------------------------------------------

'------------------------------------------------------------------------------
'   ** Declarations **
'------------------------------------------------------------------------------
DECLARE CALLBACK FUNCTION ShowDlgListviewProc()
DECLARE FUNCTION SampleListView(BYVAL hDlg AS DWORD, BYVAL lID AS LONG, BYVAL _
  lColCnt AS LONG, BYVAL lRowCnt AS LONG) AS LONG
DECLARE FUNCTION ShowDlgListview(BYVAL hParent AS DWORD) AS LONG
#PBFORMS DECLARATIONS
'------------------------------------------------------------------------------

'------------------------------------------------------------------------------
'   ** Main Application Entry Point **
'------------------------------------------------------------------------------
FUNCTION PBMAIN()
  PBFormsInitComCtls (%ICC_WIN95_CLASSES OR %ICC_DATE_CLASSES OR _
    %ICC_INTERNET_CLASSES)

  ShowDlgListview %HWND_DESKTOP
END FUNCTION
'------------------------------------------------------------------------------

'------------------------------------------------------------------------------
'   ** CallBacks **
'------------------------------------------------------------------------------
CALLBACK FUNCTION ShowDlgListviewProc()

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
FUNCTION SampleListView(BYVAL hDlg AS DWORD, _
                        BYVAL lID AS LONG, _
                        BYVAL lColCnt AS LONG, _
                        BYVAL lRowCnt AS LONG) AS LONG
  LOCAL lCol   AS LONG
  LOCAL lRow   AS LONG
  LOCAL lStyle AS LONG

  LISTVIEW GET STYLEXX hDlg, lID TO lStyle
  LISTVIEW SET STYLEXX hDlg, lID, lStyle OR _
                       %LVS_EX_FULLROWSELECT OR _
                       %LVS_EX_GRIDLINES

  ' Load column headers.
  FOR lCol = 1 TO lColCnt
    LISTVIEW INSERT COLUMN hDlg, lID, lCol, _
                           USING$("Column #", lCol), 0, 0
  NEXT lCol

  ' Load sample data.
  FOR lRow = 1 TO lRowCnt
    LISTVIEW INSERT ITEM hDlg, lID, lRow, 0, _
                         USING$("Column # Row #", lCol, lRow)
    FOR lCol = 1 TO lColCnt
      LISTVIEW SET TEXT hDlg, lID, lRow, lCol, _
               USING$("Column # Row #", lCol, lRow)
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
FUNCTION ShowDlgListview(BYVAL hParent AS DWORD) AS LONG
  LOCAL lRslt AS LONG

#PBFORMS BEGIN DIALOG %IDD_DlgListview->->
  LOCAL hDlg  AS DWORD

  DIALOG NEW hParent, "Listview demo", 253, 202, 588, 314, %WS_POPUP OR _
    %WS_BORDER OR %WS_DLGFRAME OR %WS_CAPTION OR %WS_SYSMENU OR _
    %WS_MINIMIZEBOX OR %WS_CLIPSIBLINGS OR %WS_VISIBLE OR %DS_MODALFRAME OR _
    %DS_CENTER OR %DS_3DLOOK OR %DS_NOFAILCREATE OR %DS_SETFONT, _
    %WS_EX_CONTROLPARENT OR %WS_EX_LEFT OR %WS_EX_LTRREADING OR _
    %WS_EX_RIGHTSCROLLBAR, TO hDlg
  CONTROL ADD BUTTON,   hDlg, %IDABORT, "Exit", 515, 285, 50, 15
  CONTROL ADD LISTVIEW, hDlg, %IDC_LISTVIEW1, "Listview1", 75, 45, 430, 215
#PBFORMS END DIALOG

  SampleListView hDlg, %IDC_LISTVIEW1, 3, 30

  DIALOG SHOW MODAL hDlg, CALL ShowDlgListviewProc TO lRslt

#PBFORMS BEGIN CLEANUP %IDD_DlgListview
#PBFORMS END CLEANUP

  FUNCTION = lRslt
END FUNCTION
'------------------------------------------------------------------------------
