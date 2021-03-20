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
#RESOURCE ICON, iBooks, "Books.ico"
#RESOURCE ICON, iFolder,"Folder.ico"
#RESOURCE ICON, iFiction, "SF.ico"
#RESOURCE ICON, iNonFiction,"Science.ico"
#RESOURCE ICON, iSelNonFiction, "selected_Science.ico"
'------------------------------------------------------------------------------
'   ** Constants **
'------------------------------------------------------------------------------
#PBFORMS BEGIN CONSTANTS
%IDD_dlgTREEVIEW  =  101
%IDABORT          =    3
%IDC_txtSelection = 1001
%IDC_LABEL1       = 1002
%IDC_tvBooks      = 1003
%IDOK             =    1
#PBFORMS END CONSTANTS
'------------------------------------------------------------------------------
' constants for Treeview edits
%IDM_EditTree     = 3000
%IDM_EndEditTree  = 3010
'
' add globals for Treeview menu
GLOBAL hMenu AS DWORD
GLOBAL hMenuEdit AS DWORD

GLOBAL g_hImgList AS LONG
%Books       = 1
%Folder      = 2
%Fiction     = 3
%NonFiction  = 4
%selNonFiction  = 5
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
  funCreateImageList()
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
  STATIC hTree AS DWORD             ' windows handle for tree object
  STATIC hTVEdit AS DWORD           ' handle for edit portion of node
  STATIC strOriginalEditLabelText AS STRING  ' text before editing
  LOCAL strTemp AS STRING
  '
  SELECT CASE AS LONG CB.MSG
    CASE %WM_INITDIALOG
    ' Initialization handler
      funPopulateTreeView(CB.HNDL,%IDC_tvBooks)
      CONTROL HANDLE CB.HNDL, %IDC_tvBooks TO hTree
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
        CASE %TVN_BeginLabelEditW
        ' get handle of TreeView edit control
          hTVEdit = Treeview_GetEditControl(hTree)
          'get original text
          CONTROL GET TEXT hTree, GetDlgCtrlID(hTVEdit) TO _
                           strOriginalEditLabelText
                           '

        CASE %TVN_EndLabelEditW
        ' get handle of TreeView edit control
          hTVEdit = Treeview_GetEditControl(hTree)
          CONTROL GET TEXT hTree, GetDlgCtrlID(hTVEdit) TO _
                           strTemp  'get new text
          TREEVIEW GET SELECT CB.HNDL, %IDC_tvBooks TO hNode
          TREEVIEW SET TEXT CB.HNDL, %IDC_tvBooks, hNode, strTemp
          FUNCTION = 1     '1=new text  0=original text
          '
      END SELECT

    CASE %WM_COMMAND
      ' Process control notifications
      SELECT CASE AS LONG CB.CTL
        ' /* Inserted by PB/Forms 03-14-2021 13:37:07
        CASE %IDM_EditTree
         ' F2 has been activated
         TREEVIEW GET SELECT CB.HNDL, %IDC_tvBooks TO hNode
         ' start the edit
         CONTROL SEND CB.HNDL, %IDC_tvBooks, %TVM_EditLabel, 0, hNode
         '
        CASE %IDM_EndEditTree
         ' Menu has been activated
           CONTROL SEND CB.HNDL, %IDC_tvBooks, %TVM_EndEditLabelNow, %False, 0
           '
        CASE %IDCANCEL
        ' user has pressed cancel to roll back the change of name
          IF hTVEdit AND LEN(strOriginalEditLabelText) THEN
            ' only if there is text to roll back to
            ' trigger the end edit event to stop editing the node
            SendMessage(hTree, %TVM_EndEditLabelNow, %False, 0)
            ' get the node handle
            TREEVIEW GET SELECT CB.HNDL, %IDC_tvBooks TO hNode
            ' and write the original text to it
            TREEVIEW SET TEXT CB.HNDL, %IDC_tvBooks, hNode, _
                                       strOriginalEditLabelText
            strOriginalEditLabelText = ""
          END IF


        CASE %IDOK
          IF CB.CTLMSG = %BN_CLICKED OR CB.CTLMSG = 1 THEN
             funDisplaySelected(CB.HNDL,%IDC_tvBooks, %IDC_txtSelection)
          END IF
        ' */

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
  CONTROL ADD TEXTBOX,  hDlg, %IDC_txtSelection, "", 300, 50, 205, 70, _
    %WS_CHILD OR %WS_VISIBLE OR %WS_TABSTOP OR %ES_LEFT OR %ES_MULTILINE OR _
    %ES_AUTOHSCROLL, %WS_EX_CLIENTEDGE OR %WS_EX_LEFT OR %WS_EX_LTRREADING _
    OR %WS_EX_RIGHTSCROLLBAR
  CONTROL ADD BUTTON,   hDlg, %IDABORT, "Exit", 450, 235, 50, 15
  CONTROL ADD LABEL,    hDlg, %IDC_LABEL1, "Item Selected", 300, 40, 100, 10
  CONTROL SET COLOR     hDlg, %IDC_LABEL1, %BLUE, -1
  CONTROL ADD TREEVIEW, hDlg, %IDC_tvBooks, "Treeview1", 40, 25, 245, 175, _
    %WS_CHILD OR %WS_VISIBLE OR %WS_TABSTOP OR %TVS_HASBUTTONS OR _
    %TVS_HASLINES OR %TVS_LINESATROOT OR %TVS_EDITLABELS OR _
    %TVS_SHOWSELALWAYS OR %TVS_CHECKBOXES, %WS_EX_LEFT OR %WS_EX_LTRREADING _
    OR %WS_EX_RIGHTSCROLLBAR
  CONTROL ADD BUTTON,   hDlg, %IDOK, "View Selected Nodes", 300, 140, 120, 15
  DIALOG  SEND          hDlg, %DM_SETDEFID, %IDOK, 0
#PBFORMS END DIALOG
  ' build in F2 functionality
  BuildAcceleratorTable(hDlg)
  ' now add a menu
  AddMenu(hDlg)
  '
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
  TREEVIEW SET IMAGELIST hDlg, lng_tvBooks, g_hImgList
  '
  ' insert the root item
  hParent = 0
  hAfter = %TVI_FIRST
  lngImageList   = %Books
  lngSelectImage = %Books
  strText = "Books"
  '
  TREEVIEW INSERT ITEM hDlg, lng_tvBooks, hParent, _
                       hAfter, lngImageList, _
                       lngSelectImage, strText TO hItem
  '
  hParent = hItem ' store the parent handle
  ' add next level
  strText = "Fiction"
  hAfter = %TVI_SORT
  lngImageList   = %Folder
  lngSelectImage = %Folder
  TREEVIEW INSERT ITEM hDlg, lng_tvBooks, hParent, _
                       hAfter, lngImageList, _
                       lngSelectImage, strText TO hItem
  '
  strText = "Non-fiction"
  hAfter = %TVI_SORT
  lngImageList   = %Folder
  lngSelectImage = %Folder
  TREEVIEW INSERT ITEM hDlg, lng_tvBooks, hParent, _
                       hAfter, lngImageList, _
                       lngSelectImage, strText TO hItem
                       '
  TREEVIEW SET EXPANDED hDlg, lng_tvBooks, hParent, %TRUE
  '
  hItem = funAddNodeEntry(hDlg,lng_tvBooks,"Fiction","Starship Troopers")
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
    '
    SELECT CASE strNodeRoot
      CASE "Fiction"
        lngImageList   = %Fiction
        lngSelectImage = %Fiction
      CASE "Non-fiction"
        lngImageList   = %NonFiction
        lngSelectImage = %selNonFiction
      CASE ELSE
        lngImageList   = 0
        lngSelectImage = 0
    END SELECT
    '
    TREEVIEW INSERT ITEM hDlg, lng_tvBooks, o_hParent, _
                       hAfter, lngImageList, _
                       lngSelectImage, strTitle TO hItem
                       '
    SELECT CASE strNodeRoot
      CASE "Fiction"
      ' Set the node as checked
        TREEVIEW SET CHECK hDlg, lng_tvBooks, hItem, 1
        ' Set the node text as bold
        TREEVIEW SET BOLD hDlg, lng_tvBooks, hItem, 1
    END SELECT
    '
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
'
FUNCTION funCreateImageList() AS LONG
' create the imagelist for the treeview
  LOCAL lngDepth,lngWidth,lngHeight,lngInitial AS LONG
  lngDepth = 32    ' depth of colour e.g. 32bit - how many colours allowed
  lngWidth = 32    ' width of icon in pixels
  lngHeight = 32   ' height of icon in pixels
  lngInitial = 5   ' allocated space in imagelist object to store images
  '                  (increase as more are needed)
  '
  IMAGELIST NEW ICON lngDepth,lngWidth,lngHeight,lngInitial _
                     TO g_hImgList
                     '
  IF g_hImgList > 0 THEN
    PREFIX "IMAGELIST ADD ICON g_hImgList,"
      "iBooks"
      "iFolder"
      "iFiction"
      "iNonFiction"
      "iSelNonFiction"
    END PREFIX
    '
    FUNCTION = %TRUE
    '
  ELSE
    FUNCTION = %FALSE
  END IF
  '
END FUNCTION
'
FUNCTION funDisplaySelected(hDlg AS DWORD, _
                            lng_tvBooks AS LONG, _
                            lngSelection AS LONG) AS LONG
                            '
  LOCAL hItem AS LONG
  LOCAL hParent AS LONG
  LOCAL hChild AS LONG
  LOCAL hSibling AS LONG
  LOCAL hNode AS LONG
  LOCAL strInfo AS STRING
  LOCAL strNodeText AS STRING
  LOCAL lngChecked AS LONG
  LOCAL lngCount AS LONG
  '
  ' first get the root node
  TREEVIEW GET ROOT hDlg, lng_tvBooks TO hParent
  TREEVIEW GET TEXT hDlg, lng_tvBooks, hParent TO strNodeText
  TREEVIEW GET CHECK hDlg, lng_tvBooks, hParent TO lngChecked
  '
  strInfo = strNodeText & " = " & FORMAT$(lngChecked) & $CRLF
  '
  funTraverseTree(hDlg,lng_tvBooks, hParent, strInfo)
  ' update the selection box
  CONTROL SET TEXT hDlg,lngSelection, strInfo
END FUNCTION
'
FUNCTION funTraverseTree(hDlg AS DWORD, _
                         lng_tvBooks AS LONG , _
                         hParent AS LONG, _
                         strInfo AS STRING) AS LONG
  LOCAL hNode AS LONG          ' handle of node currently looked at
  LOCAL hChild AS LONG         ' handle of child of node
  LOCAL lngChecked AS LONG     ' is node checked true/false
  LOCAL strNodeText AS STRING  ' the text on the node
  LOCAL hSibling AS LONG       ' handle of a sibling
  LOCAL hFirstSibling AS LONG  ' handle of the first sibling
  '
  hNode = hParent              ' store the handle of the parent
                               ' so we dont overwrite the value from the
                               ' calling function
  ' is there a child of this node?
  TREEVIEW GET CHILD hDlg, lng_tvBooks, hNode TO hChild
  '
  IF hChild = 0 THEN
  ' no children so return to calling routine if there are no siblings
    TREEVIEW GET NEXT hDlg, lng_tvBooks, hNode TO hSibling
    WHILE hSibling <> 0
    ' for each sibling of the node
      TREEVIEW GET TEXT hDlg, lng_tvBooks, hSibling TO strNodeText
      TREEVIEW GET CHECK hDlg, lng_tvBooks, hSibling TO lngChecked
      strInfo = strInfo & strNodeText & " = " & FORMAT$(lngChecked) & $CRLF
      TREEVIEW GET NEXT hDlg, lng_tvBooks, hSibling TO hSibling
    WEND
    '
    EXIT FUNCTION
  ELSE
    ' at least one child
    TREEVIEW GET TEXT hDlg, lng_tvBooks, hChild TO strNodeText
    TREEVIEW GET CHECK hDlg, lng_tvBooks, hChild TO lngChecked
    strInfo = strInfo & strNodeText & " = " & FORMAT$(lngChecked) & $CRLF
    '
    ' traverse down this node till you can go no further
    funTraverseTree(hDlg,lng_tvBooks, hChild, strInfo)
    ' got to the end of a node path - are there any siblings?
    TREEVIEW GET NEXT hDlg, lng_tvBooks, hNode TO hSibling
    '
    IF hSibling <> 0 THEN
      ' only where a sibling exists
      WHILE hSibling <> 0
      ' for each sibling
      ' store the node handle of the first sibling
        IF hFirstSibling = 0 THEN hFirstSibling = hSibling
        ' get the details of the sibling
        TREEVIEW GET TEXT hDlg, lng_tvBooks, hSibling TO strNodeText
        TREEVIEW GET CHECK hDlg, lng_tvBooks, hSibling TO lngChecked
        strInfo = strInfo & strNodeText & " = " & FORMAT$(lngChecked) & $CRLF
        TREEVIEW GET NEXT hDlg, lng_tvBooks, hSibling TO hSibling
        ' traverse the tree for any children of this sibling
        FUNCTION = funTraverseTree(hDlg,lng_tvBooks, hFirstSibling, strInfo)
        '
      WEND
    ELSE
    ' if no siblings then return to calling routine
      EXIT FUNCTION
    END IF
  END IF
  '
END FUNCTION
'
FUNCTION BuildAcceleratorTable(hDlg AS DWORD) AS LONG
  ' for keyboard accelator table values
  DIM ac() AS ACCELAPI, hAccelerator AS DWORD
  REDIM ac(0)
  ac(0).fvirt = %FVIRTKEY
  ac(0).key   = %VK_F2
  ac(0).cmd   = %IDM_EditTree
  '
  ACCEL ATTACH hDlg, AC() TO hAccelerator
  '
END FUNCTION
'
FUNCTION AddMenu(hDlg AS DWORD)  AS LONG
  MENU NEW BAR TO hMenu
  MENU NEW POPUP TO hMenuEdit
  MENU ADD POPUP, hMenu, "&Edit", hMenuEdit, %MF_ENABLED
  MENU ADD STRING, hMenuEdit, "&Edit Tree Node" + $TAB + "F2", %IDM_EditTree, %MF_ENABLED
  MENU ADD STRING, hMenuEdit, "&Cancel Edit of Tree Node", %IDM_EndEditTree, %MF_ENABLED
  MENU ATTACH hMenu, hDlg
END FUNCTION
