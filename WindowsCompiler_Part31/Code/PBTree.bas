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
#RESOURCE "PBTree.pbr"
%USEMACROS = 1
#INCLUDE ONCE "WIN32API.INC"
#INCLUDE ONCE "COMMCTRL.INC"
#INCLUDE ONCE "PBForms.INC"
#PBFORMS END INCLUDES
'------------------------------------------------------------------------------
#INCLUDE ONCE "..\Libraries\PB_Common_Strings.inc"

GLOBAL a_strData() AS STRING
GLOBAL hImageList AS LONG ' handle for imagelist
'------------------------------------------------------------------------------
'   ** Constants **
'------------------------------------------------------------------------------
#PBFORMS BEGIN CONSTANTS
%IDD_dlgTree   =  101
%IDABORT       =    3
%IDC_TREEVIEW1 = 1001
#PBFORMS END CONSTANTS
'------------------------------------------------------------------------------

'------------------------------------------------------------------------------
'   ** Declarations **
'------------------------------------------------------------------------------
DECLARE CALLBACK FUNCTION ShowdlgTreeProc()
DECLARE FUNCTION ShowdlgTree(BYVAL hParent AS DWORD) AS LONG
#PBFORMS DECLARATIONS
'------------------------------------------------------------------------------

'------------------------------------------------------------------------------
'   ** Main Application Entry Point **
'------------------------------------------------------------------------------
FUNCTION PBMAIN()
  PBFormsInitComCtls (%ICC_WIN95_CLASSES OR %ICC_DATE_CLASSES OR _
    %ICC_INTERNET_CLASSES)

  ShowdlgTree %HWND_DESKTOP
END FUNCTION
'------------------------------------------------------------------------------

'------------------------------------------------------------------------------
'   ** CallBacks **
'------------------------------------------------------------------------------
CALLBACK FUNCTION ShowdlgTreeProc()

  SELECT CASE AS LONG CB.MSG
    CASE %WM_INITDIALOG
      ' Initialization handler
      funPopulateTree()
      funBuildOurTree(CB.HNDL,%IDC_TREEVIEW1)

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
        ' /* Inserted by PB/Forms 03-07-2020 16:06:01
        CASE %IDC_TREEVIEW1
        ' */

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
FUNCTION ShowdlgTree(BYVAL hParent AS DWORD) AS LONG
  LOCAL lRslt AS LONG

#PBFORMS BEGIN DIALOG %IDD_dlgTree->->
  LOCAL hDlg  AS DWORD

  DIALOG NEW hParent, "Tree Controls", 352, 133, 383, 239, %WS_POPUP OR _
    %WS_BORDER OR %WS_DLGFRAME OR %WS_CLIPSIBLINGS OR %WS_VISIBLE OR _
    %DS_MODALFRAME OR %DS_CENTER OR %DS_3DLOOK OR %DS_NOFAILCREATE OR _
    %DS_SETFONT, %WS_EX_CONTROLPARENT OR %WS_EX_LEFT OR %WS_EX_LTRREADING OR _
    %WS_EX_RIGHTSCROLLBAR, TO hDlg
  CONTROL ADD BUTTON,   hDlg, %IDABORT, "Exit", 295, 210, 50, 15
  CONTROL ADD TREEVIEW, hDlg, %IDC_TREEVIEW1, "Treeview1", 25, 30, 320, 170
#PBFORMS END DIALOG

  DIALOG SHOW MODAL hDlg, CALL ShowdlgTreeProc TO lRslt

#PBFORMS BEGIN CLEANUP %IDD_dlgTree
#PBFORMS END CLEANUP

  FUNCTION = lRslt
END FUNCTION
'------------------------------------------------------------------------------
FUNCTION funPopulateTree() AS LONG
' populate the global tree array
  REDIM a_strData(10) AS STRING
  '
  a_strData(0) = "Company\Susan Gold"
  a_strData(1) = "Company\Susan Gold\Tom Copper"
  a_strData(2) = "Company\Susan Gold\Jane Silver"
  a_strData(3) = "Company\Susan Gold\Tom Copper\Fred Platinum"
  a_strData(4) = "Company\Susan Gold\Amanda Iron"
  a_strData(5) = "Company\Susan Gold\Amanda Iron\Julie Steel"
  a_strData(6) = "New Company\Sam Gold\Trudy Bronze\Julie Mercury"
  '
  IMAGELIST NEW ICON 16,16,32,10 TO hImageList
  IMAGELIST ADD ICON hImageList, "A_Icon.ico"
  IMAGELIST ADD ICON hImageList, "B_Icon.ico"

  '
END FUNCTION
'
FUNCTION funBuildOurTree(hDlg AS DWORD, _
                         hTV AS LONG) AS LONG
' build the tree with the data
  '
  LOCAL lngR AS LONG
  LOCAL lngC AS LONG
  LOCAL strWork AS STRING
  LOCAL strData AS STRING
  LOCAL strParent AS STRING
  LOCAL lngTotalElements AS LONG
  '
  LOCAL hndl AS LONG
  LOCAL hParent AS LONG
  LOCAL lngCount AS LONG
  '
  DIM a_strNodes(1 TO 1) AS STRING 'used to hold node numbers
  DIM a_lngNodes(1 TO 1) AS LONG
  LOCAL lngI AS LONG
  '
  TREEVIEW RESET hDlg, hTV
  TREEVIEW SET IMAGELIST hDlg, hTV, hImagelist
  '
  ' sort our array
  ARRAY SORT a_strData(), COLLATE UCASE, ASCEND
  '
  FOR lngR = 0 TO UBOUND(a_strData)
  ' for each item in the array
  ' pick up the full data line
    strWork = a_strData(lngR)
    ' if its blank then skip over this
    IF strWork = "" THEN ITERATE
    lngTotalElements = PARSECOUNT(strWork,"\")
    '
    FOR lngC = 1 TO lngTotalElements
      SELECT CASE lngC
        CASE 1
        ' this is the beginning of a new node
        ' pick up the element in the string
          strData = PARSE$(strWork,"\",lngC)
          '
          ' do we have a node for this yet?
          ARRAY SCAN a_strNodes(), COLLATE UCASE, = strData, TO lngI
          IF lngI = 0 THEN
          ' didnt find it so add the node
            TREEVIEW INSERT ITEM hDlg,hTV,0, %TVI_SORT,1,1,strData _
                     TO hndl
                     '
            ' now add this data to the nodes arrays
            REDIM PRESERVE a_strNodes(1 TO UBOUND(a_strNodes)+1)
            a_strNodes(UBOUND(a_strNodes)) = strData
            REDIM PRESERVE a_lngNodes(1 TO UBOUND(a_lngNodes)+1)
            a_lngNodes(UBOUND(a_lngNodes)) = hndl
            '
          END IF
          '
        CASE ELSE
        ' get the parent node first
          strData = PARSE$(strWork,"\",lngC)
          strParent = RTRIM$(funStartRangeParse(strWork, "\", lngC-1),"\")
          '
          ARRAY SCAN a_strNodes(), COLLATE UCASE, = strParent, TO lngI
          '
          IF lngI > 0 THEN
            hParent = a_lngNodes(lngI)
            ARRAY SCAN a_strNodes(), COLLATE UCASE, = strParent & _
                       "\" & strData, TO lngI
            IF lngI = 0 THEN
            ' insert the node
              TREEVIEW INSERT ITEM hDlg, hTV, hParent, %TVI_LAST, 2,2, _
                    strData TO hndl
              TREEVIEW SET EXPANDED hDlg, hTV, hParent, %TRUE
              ' add it to the a_strNodes tree
              REDIM PRESERVE a_strNodes(1 TO UBOUND(a_strNodes)+1)
              a_strNodes(UBOUND(a_strNodes)) = strParent & "\" & strData
              REDIM PRESERVE a_lngNodes(1 TO UBOUND(a_lngNodes)+1)
              a_lngNodes(UBOUND(a_lngNodes)) = hndl
            '
            END IF
          END IF
        '
      END SELECT
    NEXT lnC
    '
  NEXT lngR
  '
END FUNCTION
