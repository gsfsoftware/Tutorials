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
%IDC_STATUSBAR1  = 1002
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
' Old Listview callback procedure pointer
GLOBAL glngOldLVProc AS LONG
GLOBAL glngLVRows AS LONG
GLOBAL glngLVCols AS LONG
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
  LOCAL lplvcd AS nmlvCustomDraw PTR
  LOCAL LVData AS NM_ListView
  STATIC lngSortDirection AS LONG
  '
  SELECT CASE AS LONG CB.MSG
    CASE %WM_INITDIALOG
    ' Initialization handler
      ' Subclass the listview control so we can
      ' receive %WM_LButtonDown and %WM_KeyDown messages
      ' storing the old handle in glngOldLVProc
      glngOldLVProc = SetWindowLongW(GetDlgItem(CB.HNDL, %IDC_LISTVIEW1), _
                                    %GWL_WNDPROC, BYVAL CODEPTR(LVProc))
                                    '
    CASE %WM_DESTROY
      ' Restore the listview controls original callback procedure
      SetWindowLongW(GetDlgItem(CB.HNDL, %IDC_LISTVIEW1), _
                     %GWL_WNDPROC, glngOldLVProc)
    '
    CASE %WM_NOTIFY
    ' pick up notifications
      SELECT CASE CB.NMID
        CASE %IDC_LISTVIEW1
          ' handle this list view
          SELECT CASE CB.NMCODE
            CASE %LVN_COLUMNCLICK
            ' handle column header clicks
              TYPE SET LVData = CB.NMHDR$(SIZEOF(LVData))
              ' toggle the sorting direction
              lngSortDirection = lngSortDirection XOR 1
              '
              IF ISTRUE lngSortDirection THEN
              ' sort ascending
                LISTVIEW SORT CB.HNDL, %IDC_LISTVIEW1, _
                                       LvData.iSubitem+1 , ASCEND
                funDeselectAll(CB.HNDL,%IDC_LISTVIEW1)
                CONTROL SET TEXT CB.HNDL,%IDC_STATUSBAR1,""
                '
              ELSE
              ' sort descending
                LISTVIEW SORT CB.HNDL, %IDC_LISTVIEW1, _
                                       LvData.iSubitem+1 , DESCEND
                funDeselectAll(CB.HNDL,%IDC_LISTVIEW1)
                CONTROL SET TEXT CB.HNDL,%IDC_STATUSBAR1,""
                '
              END IF
            '
            CASE %NM_CUSTOMDRAW
            ' custom draw
              lplvcd = CB.LPARAM
              SELECT CASE @lplvcd.nmcd.dwDrawStage
                CASE %CDDS_PrePaint, %CDDS_ItemPrepaint
                  FUNCTION = %CDRF_NotifyItemDraw
                  '
                CASE %CDDS_ItemPrepaint OR %CDDS_subItem
                ' paint the row?
                  IF ISTRUE funColouredRow(@lpLvCd.nmcd.dwItemSpec) THEN
                  ' set the colour of foreground and background
                    @lpLvCD.clrTextBK = %RGB_PALEGREEN
                    @lpLvCD.clrText   = %BLACK
                  ELSE
                  ' set the default colour of foreground and background
                    @lpLvCD.clrTextBK = %WHITE
                    @lpLvCD.clrText   = %BLACK
                  END IF
                '
              END SELECT
            '
          END SELECT
          '
      END SELECT
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

        CASE %IDC_LISTVIEW1

      END SELECT
  END SELECT
END FUNCTION
'
FUNCTION funDeselectAll(hDlg AS DWORD, _
                        lngListView AS LONG) AS LONG
' deselect all entries in the listview
  LOCAL lngR , lngC AS LONG
  '
  FOR lngR = 1 TO glngLVRows
    FOR lngC = 1 TO glngLVCols
      LISTVIEW UNSELECT hDlg, lngListView, lngR, lngC
    NEXT lngC
  NEXT lngR
  '
END FUNCTION
'
FUNCTION LVProc(BYVAL hWnd AS LONG, _
                BYVAL wMsg AS LONG, _
                BYVAL wParam AS LONG, _
                BYVAL lParam AS LONG) AS LONG
' ListView callback procedure
  STATIC lngCol   AS LONG            ' Selected column
  STATIC lngRow   AS LONG            ' Selected row
  LOCAL  lngRows  AS LONG            ' Number of rows per page
  LOCAL  LVHT     AS LVHITTESTINFO   ' Contains information about
                                     ' a mouse click on the ListView
  LOCAL strData AS STRING            ' data in the listview cell
  '
  SELECT CASE AS LONG wMsg
  '
    CASE %WM_LBUTTONDOWN
      lvht.pt.x = LO(WORD, lparam)   ' X coordinate of mouse left button down
      lvht.pt.y = HI(WORD, lparam)   ' Y coordinate of mouse left button down
      '
      ' Find the listview item and subitem at these X, Y coordinates
      SendMessageW(hWnd, %LVM_SUBITEMHITTEST, BYVAL 0, BYVAL VARPTR(LVHT))
      '
      ' Did we find a listview item at these coordinates?
      IF lVHT.iItem <> -1 THEN
        ' Update the ListView with the new selection
        UpdateLVSelect(GetParent(hWnd), lngRow, lngCol, _
                       lVHT.iItem+1 , LVHT.iSubItem+1)
                       '
        LISTVIEW GET TEXT GetParent(hWnd), %IDC_LISTVIEW1, _
                          lVHT.iItem+1, LVHT.iSubItem+1 TO strData
                          '
        CONTROL SET TEXT GetParent(hWnd), _
                         %IDC_STATUSBAR1,"Row = " & FORMAT$(lVHT.iItem+1) & _
                                         ". " & _
                                         "Column = " & FORMAT$(LVHT.iSubItem+1) & _
                                         ". " & _
                                         "Data = " & strData
      END IF
      '
      ' We handled this message, so we need to return a zero
      ' and not call the the original listview callback.
      FUNCTION = 0
      EXIT FUNCTION
      '
    CASE %WM_KEYDOWN
      SELECT CASE AS LONG wParam
        '
        CASE %VK_UP
          ' Update the ListView with the new selection
          UpdateLVSelect(GetParent(hWnd), lngRow, lngCol, lngRow-1, lngCol)
          '
        CASE %VK_DOWN
          ' Update the ListView with the new selection
          UpdateLVSelect(GetParent(hWnd), lngRow, lngCol, lngRow+1, lngCol)
          '
        CASE %VK_RIGHT
          ' Update the ListView with the new selection
          UpdateLVSelect(GetParent(hWnd), lngRow, lngCol, lngRow, lngCol+1)
          '
        CASE %VK_LEFT
          ' Update the ListView with the new selection
          UpdateLVSelect(GetParent(hWnd), lngRow, lngCol, lngRow, lngCol-1)
          '
        CASE %VK_PGUP
          ' Get the number of rows per page in the ListView
          lngRows = SendMessageW(hWnd, %LVM_GETCOUNTPERPAGE, 0, 0)
          ' Update the ListView with the new selection
          UpdateLVSelect(GetParent(hWnd), lngRow, lngCol, lngRow-lngRows, lngCol)
          '
        CASE %VK_PGDN
          ' Get the number of rows per page in the ListView
          lngRows = SendMessageW(hWnd, %LVM_GETCOUNTPERPAGE, 0, 0)
          ' Update the ListView with the new selection
          UpdateLVSelect(GetParent(hWnd), lngRow, lngCol, lngRow+lngRows, lngCol)
          '
        CASE %VK_HOME
          ' Update the ListView with the new selection
          UpdateLVSelect(GetParent(hWnd), lngRow, lngCol, 1, 1)
          '
        CASE %VK_END
          ' Update the ListView with the new selection
          UpdateLVSelect(GetParent(hWnd), lngRow, lngCol, glngLVRows, 1)
          '
      END SELECT

      ' We handled this message, so we need to return a zero
      ' and not call the the original listview callback.
      FUNCTION = 0
      EXIT FUNCTION
      '
  END SELECT
  '
  ' if we did not handle this message, pass the message on to the
  ' original callback for the listview control.
  FUNCTION = CallWindowProcW(glngOldLVProc, hWnd, wMsg, wParam, lParam)
  '
END FUNCTION
'
SUB UpdateLVSelect(BYVAL hDlg AS LONG, _
                   BYREF lngROW AS LONG, _
                   BYREF lngCOL AS LONG, _
                   BYVAL lngNewRow AS LONG, _
                   BYVAL lngNewCol AS LONG)
                   '
  ' Make sure the new row is within range
  IF lngNewRow < 1 THEN
    lngNewRow = 1
  ELSEIF lngNewRow > glngLVRows THEN
    lngNewRow = glngLVRows
  END IF
  '
  ' Make sure the new column is within range
  IF lngNewCol < 1 THEN
    lngNewCol = 1
  ELSEIF lngNewCol > glngLVCols THEN
    lngNewCol = glngLVCols
  END IF
  '
  ' If the previous and new selection are the same then do nothing
  IF (lngRow = lngNewRow) AND (lngCOL = lngNewCol) THEN EXIT SUB
  '
  ' Unselect the previous selection, required when seleting subitems
  ' even if the ListView contains the %LVS_SINGLESEL style
  LISTVIEW UNSELECT hDlg, %IDC_LISTVIEW1, lngRow, lngCOL
  '
  ' Update the Row and Column variables
  lngRow = lngNewRow
  lngCOL = lngNewCol
  '
  ' Select the new ListView item
  LISTVIEW SELECT hDlg, %IDC_LISTVIEW1, lngRow, lngCOL
  '
  ' Ensure the new ListView item is visible
  LISTVIEW VISIBLE hDlg, %IDC_LISTVIEW1, lngRow
  '
END SUB
'------------------------------------------------------------------------------
FUNCTION funColouredRow(lngRow AS LONG) AS LONG
' determine if this row needs coloured
  IF lngRow MOD 2 = 0 THEN
    FUNCTION = %TRUE
  ELSE
    FUNCTION = %FALSE
  END IF
  '
END FUNCTION
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
                       %LVS_EX_GRIDLINES OR %LVS_EX_BORDERSELECT OR _
                       %LVS_EX_ONECLICKACTIVATE  _
                       OR %LVS_EX_SINGLEROW

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
  CONTROL ADD STATUSBAR, hDlg, %IDC_STATUSBAR1, "", 0, 0, 0, 0
#PBFORMS END DIALOG

  glngLVRows = 30
  glngLVCols = 3
  SampleListView hDlg, %IDC_LISTVIEW1, glngLVCols, glngLVRows

  DIALOG SHOW MODAL hDlg, CALL ShowDlgListviewProc TO lRslt

#PBFORMS BEGIN CLEANUP %IDD_DlgListview
#PBFORMS END CLEANUP

  FUNCTION = lRslt
END FUNCTION
'------------------------------------------------------------------------------
