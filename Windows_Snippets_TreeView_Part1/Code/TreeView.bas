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
#RESOURCE "TreeView.pbr"
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
%IDD_dlgTREEVIEW  =  101
%IDABORT          =    3
%IDC_txtSelection = 1001
%IDC_LABEL1       = 1002
%IDC_tvBooks      = 1003
#PBFORMS END CONSTANTS
'------------------------------------------------------------------------------

'------------------------------------------------------------------------------
'   ** Declarations **
'------------------------------------------------------------------------------
DECLARE CALLBACK FUNCTION ShowdlgTREEVIEWProc()
DECLARE FUNCTION ShowdlgTREEVIEW(BYVAL hParent AS DWORD) AS LONG
#PBFORMS DECLARATIONS
'------------------------------------------------------------------------------

'------------------------------------------------------------------------------
'   ** Main Application Entry Point **
'------------------------------------------------------------------------------
FUNCTION PBMAIN()
  PBFormsInitComCtls (%ICC_WIN95_CLASSES OR %ICC_DATE_CLASSES OR _
    %ICC_INTERNET_CLASSES)
  DIALOG DEFAULT FONT "MS Sans Serif", 14, 0, %ANSI_CHARSET
  ShowdlgTREEVIEW %HWND_DESKTOP
END FUNCTION
'------------------------------------------------------------------------------

'------------------------------------------------------------------------------
'   ** CallBacks **
'------------------------------------------------------------------------------
CALLBACK FUNCTION ShowdlgTREEVIEWProc()
  LOCAL pNMHDR    AS NMHDR PTR     ' Contains info on the WM_NOTIFY message
  LOCAL hNode     AS LONG          ' Selected Treeview node
  LOCAL hParent   AS LONG          ' Selected Treeview parents node
  LOCAL hChild    AS LONG          ' Selected Treeview childs node
  LOCAL strText   AS STRING        ' Text on node selected
  '
  SELECT CASE AS LONG CB.MSG
    CASE %WM_INITDIALOG
    ' Initialization handler
      funPopulateTreeView(CB.HNDL,%IDC_tvBooks)
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
    '
    CASE %WM_NOTIFY
    ' CB.NMHDR contains a pointer to the notification
    ' message header UDT
      pNMHDR = CB.NMHDR
      SELECT CASE AS LONG @pNMHDR.code
        CASE %TVN_SELCHANGEDW
        ' The Treeview selection has changed
        ' get what has been selected
        ' first get the node handle
          TREEVIEW GET SELECT CB.HNDL, %IDC_tvBooks TO hNode
          ' then get the text on that node
          TREEVIEW GET TEXT CB.HNDL, %IDC_tvBooks, hNode TO strText
          ' put the text got from the node into the Text box
          CONTROL SET TEXT CB.HNDL, %IDC_txtSelection, strText
          '
      END SELECT

    CASE %WM_COMMAND
      ' Process control notifications
      SELECT CASE AS LONG CB.CTL
        ' /* Inserted by PB/Forms 02-27-2021 15:26:49
        CASE %IDC_tvBooks
        ' */

        CASE %IDC_txtSelection

        CASE %IDABORT
          IF CB.CTLMSG = %BN_CLICKED OR CB.CTLMSG = 1 THEN
            DIALOG END CB.HNDL
          END IF
          '
      END SELECT
  END SELECT
END FUNCTION
'------------------------------------------------------------------------------

'------------------------------------------------------------------------------
'   ** Dialogs **
'------------------------------------------------------------------------------
FUNCTION ShowdlgTREEVIEW(BYVAL hParent AS DWORD) AS LONG
  LOCAL lRslt AS LONG

#PBFORMS BEGIN DIALOG %IDD_dlgTREEVIEW->->
  LOCAL hDlg  AS DWORD

  DIALOG NEW hParent, "Treeview", 250, 194, 543, 282, %WS_POPUP OR %WS_BORDER _
    OR %WS_DLGFRAME OR %WS_CAPTION OR %WS_SYSMENU OR %WS_MINIMIZEBOX OR _
    %WS_CLIPSIBLINGS OR %WS_VISIBLE OR %DS_MODALFRAME OR %DS_CENTER OR _
    %DS_3DLOOK OR %DS_NOFAILCREATE OR %DS_SETFONT, %WS_EX_CONTROLPARENT OR _
    %WS_EX_LEFT OR %WS_EX_LTRREADING OR %WS_EX_RIGHTSCROLLBAR, TO hDlg
  CONTROL ADD TEXTBOX,  hDlg, %IDC_txtSelection, "", 300, 50, 205, 70
  CONTROL ADD BUTTON,   hDlg, %IDABORT, "Exit", 450, 235, 50, 15
  CONTROL ADD LABEL,    hDlg, %IDC_LABEL1, "Item Selected", 300, 40, 100, 10
  CONTROL SET COLOR     hDlg, %IDC_LABEL1, %BLUE, -1
  CONTROL ADD TREEVIEW, hDlg, %IDC_tvBooks, "Treeview1", 40, 25, 245, 175
#PBFORMS END DIALOG

  DIALOG SHOW MODAL hDlg, CALL ShowdlgTREEVIEWProc TO lRslt

#PBFORMS BEGIN CLEANUP %IDD_dlgTREEVIEW
#PBFORMS END CLEANUP

  FUNCTION = lRslt
END FUNCTION
'------------------------------------------------------------------------------
FUNCTION funPopulateTreeView(hDlg AS DWORD, _
                             lng_tvBooks AS LONG) AS LONG
  ' populate the treeview
' first reset the treeview
  LOCAL hItem AS LONG
  LOCAL hParent AS LONG
  LOCAL o_hParent AS LONG
  LOCAL hAfter AS LONG
  LOCAL lngImageList AS LONG
  LOCAL lngSelectImage AS LONG
  LOCAL strText AS STRING
  '
  TREEVIEW RESET hDlg, lng_tvBooks
  '
  ' insert the root item
  hParent = 0
  hAfter = %TVI_FIRST
  lngImageList   = 0
  lngSelectImage = 0
  strText = "Books"
  TREEVIEW INSERT ITEM hDlg, lng_tvBooks, hParent, _
                       hAfter, lngImageList, _
                       lngSelectImage, strText TO hItem
  '
  hParent = hItem ' store the parent handle
  ' add next level
  strText = "Fiction"
  hAfter = %TVI_SORT
  TREEVIEW INSERT ITEM hDlg, lng_tvBooks, hParent, _
                       hAfter, lngImageList, _
                       lngSelectImage, strText TO hItem
  '
  strText = "Non-fiction"
  hAfter = %TVI_SORT
  TREEVIEW INSERT ITEM hDlg, lng_tvBooks, hParent, _
                       hAfter, lngImageList, _
                       lngSelectImage, strText TO hItem
                       '
  TREEVIEW SET EXPANDED hDlg, lng_tvBooks, hParent, %TRUE
  '
  ' now add an entry to an existing node
  IF ISTRUE funGetTvNodeHandle(hDlg,lng_tvBooks,"Fiction", _
                               o_hParent) THEN
  ' we've found the node
    strText = "Starship Troopers"
    hAfter = %TVI_SORT  ' %TVI_FIRST or %TVI_LAST
    TREEVIEW INSERT ITEM hDlg, lng_tvBooks, o_hParent, _
                       hAfter, lngImageList, _
                       lngSelectImage, strText TO hItem
  '
  ELSE
  ' node not found
  '
  END IF
  '
  hItem = funAddNodeEntry(hDlg,lng_tvBooks,"Fiction","The Colour of Magic")
  hItem = funAddNodeEntry(hDlg,lng_tvBooks,"Fiction","The Magic goes away")
  hItem = funAddNodeEntry(hDlg,lng_tvBooks,"Non-fiction","The Arrow of Time")

END FUNCTION
'
FUNCTION funAddNodeEntry(hDlg AS DWORD ,lng_tvBooks AS LONG, _
                         strNodeRoot AS STRING, strTitle AS STRING) AS LONG
' add an entry to the tree returning the handle
  LOCAL o_hParent AS LONG
  LOCAL hAfter AS LONG
  LOCAL hItem AS LONG
  LOCAL lngImageList AS LONG
  LOCAL lngSelectImage AS LONG
  '
  IF ISTRUE funGetTvNodeHandle(hDlg,lng_tvBooks,strNodeRoot, o_hParent) THEN
  ' found the node
    hAfter = %TVI_SORT  ' %TVI_FIRST or %TVI_LAST
    TREEVIEW INSERT ITEM hDlg, lng_tvBooks, o_hParent, _
                       hAfter, lngImageList, _
                       lngSelectImage, strTitle TO hItem
    FUNCTION = hItem
  ELSE
    FUNCTION = %FALSE
  END IF
  '
END FUNCTION
'
FUNCTION funGetTvNodeHandle(hDlg AS DWORD, lng_tvBooks AS LONG, _
                            strName AS STRING, o_hParent AS LONG) AS LONG
' run through the Treeview and find the node
  LOCAL hParent AS LONG
  LOCAL lngFound AS LONG
  LOCAL strText AS STRING
  LOCAL lngCurrentItem AS LONG
  '
  ' first get the root node
  TREEVIEW GET ROOT hDlg, lng_tvBooks TO hParent
  TREEVIEW GET CHILD hDlg, lng_tvBooks, hParent TO lngFound
  '
  IF lngFound > 0 THEN
    TREEVIEW GET TEXT hDlg, lng_tvBooks, lngFound TO strText
    IF strText = strName THEN
      o_hParent = lngFound
      FUNCTION = %TRUE
      EXIT FUNCTION
    ELSE
      ' get the next one
      WHILE lngFound > 0
        lngCurrentItem = lngFound
        TREEVIEW GET NEXT hDlg, lng_tvBooks, lngCurrentItem TO lngFound
        IF lngFound > 0 THEN
          TREEVIEW GET TEXT hDlg, lng_tvBooks, lngFound TO strText
          IF strText = strName THEN
            o_hParent = lngFound
            FUNCTION = %TRUE
            EXIT FUNCTION
          END IF
        END IF
      WEND
    END IF
  END IF
END FUNCTION
