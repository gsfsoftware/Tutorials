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
#RESOURCE "MLG_grid.pbr"
%USEMACROS = 1
#INCLUDE ONCE "WIN32API.INC"
#INCLUDE ONCE "COMMCTRL.INC"
#INCLUDE ONCE "PBForms.INC"
#PBFORMS END INCLUDES
'------------------------------------------------------------------------------
%MLGSLL = 1
#INCLUDE "MLG.INC"
#LINK "MLG.SLL"
'
#INCLUDE "../Libraries/PB_MLG_Utilities.inc"
#INCLUDE "../Libraries/PB_FileHandlingRoutines.inc"
#INCLUDE "../Libraries/Macros.inc"
'
%IDC_GRID1 = 2000
GLOBAL hGrid1 AS DWORD
'------------------------------------------------------------------------------
'   ** Constants **
'------------------------------------------------------------------------------
#PBFORMS BEGIN CONSTANTS
%IDR_IMGFILE1          =  102
%IDR_IMGFILE2          =  103
%IDR_IMGFILE3          =  104
%IDD_dlgDisplayCSVFile =  101
%IDABORT               =    3
%IDC_TOOLBAR1          = 1001
%IDC_TOOLBAR_NEW1      = 1002
%IDC_TOOLBAR_OPEN1     = 1003
%IDC_TOOLBAR_SAVE1     = 1004
%IDC_lblRecordcount    = 1005
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
  LOCAL strFile AS STRING
  LOCAL flags&
  '
  flags& = %OFN_FILEMUSTEXIST OR %OFN_PATHMUSTEXIST
  DISPLAY OPENFILE %HWND_DESKTOP,,,"Select CSV file to load", _
          EXE.PATH$, CHR$("CSV",0,"*.CSV",0), _
          "","CSV",flags& TO strFile
  '
  IF strFile <> "" THEN
    ShowdlgDisplayCSVFile %HWND_DESKTOP,strFile
  END IF
END FUNCTION
'------------------------------------------------------------------------------

'------------------------------------------------------------------------------
'   ** CallBacks **
'------------------------------------------------------------------------------
CALLBACK FUNCTION ShowdlgDisplayCSVFileProc()
  '
  LOCAL strFile AS STRING
  LOCAL flags&
  DIM a_strWork() AS STRING
  LOCAL lngRows AS LONG
  LOCAL lngColumns AS LONG
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
        ' /* Inserted by PB/Forms 07-12-2020 14:56:55

        CASE %IDC_TOOLBAR_OPEN1
          IF CB.CTLMSG = %BN_CLICKED OR CB.CTLMSG = 1 THEN
          ' load the new csv file
            flags& = %OFN_FILEMUSTEXIST OR %OFN_PATHMUSTEXIST
            DISPLAY OPENFILE %HWND_DESKTOP,,,"Select CSV file to load", _
                  EXE.PATH$, CHR$("CSV",0,"*.CSV",0), _
                  "","CSV",flags& TO strFile
                  '
            IF strFile <> "" THEN
            ' new file has been selected
              funGridClear(hGrid1)
              '
              IF ISTRUE funReadTheCSVFileIntoAnArray(strFile, _
                                      BYREF a_strWork()) THEN
              ' if file is loaded then put it in grid
                lngRows = UBOUND(a_strWork,1)
                lngColumns = UBOUND(a_strWork,2)
                '
                MLG_ArrayRedim(hGrid1, lngRows , lngColumns, _
                               lngRows+10, lngColumns+2)
                MLG_PutEx(hGrid1,a_strWork(),1,1)
                '
                CONTROL SET TEXT CB.HNDL,%IDC_lblRecordcount, _
                     FORMAT$(lngRows) & " records returned"
                '
                funWidenColumnsInGrid(hGrid1)
                funColourBankGridRows(hGrid1)
                '
                funGridRefresh(hGrid1)
              '
              END IF
            '
            END IF
          '
          END IF

'        CASE %IDC_TOOLBAR_SAVE1
'          IF CB.CTLMSG = %BN_CLICKED OR CB.CTLMSG = 1 THEN
'            MSGBOX "%IDC_TOOLBAR_SAVE1=" + FORMAT$(%IDC_TOOLBAR_SAVE1), _
'              %MB_TASKMODAL
'          END IF
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
FUNCTION ShowdlgDisplayCSVFile(BYVAL hParent AS DWORD, _
                               strFile AS STRING) AS LONG
  LOCAL lRslt AS LONG
  DIM a_strWork() AS STRING
  LOCAL lngRows AS LONG
  LOCAL lngColumns AS LONG
  '
#PBFORMS BEGIN DIALOG %IDD_dlgDisplayCSVFile->->
  LOCAL hDlg  AS DWORD

  DIALOG NEW hParent, "Display CSV files", 287, 206, 545, 249, %WS_POPUP OR _
    %WS_BORDER OR %WS_DLGFRAME OR %WS_CAPTION OR %WS_SYSMENU OR _
    %WS_MINIMIZEBOX OR %WS_MAXIMIZEBOX OR %WS_CLIPSIBLINGS OR %WS_VISIBLE OR _
    %DS_MODALFRAME OR %DS_CENTER OR %DS_3DLOOK OR %DS_NOFAILCREATE OR _
    %DS_SETFONT, %WS_EX_CONTROLPARENT OR %WS_EX_LEFT OR %WS_EX_LTRREADING OR _
    %WS_EX_RIGHTSCROLLBAR, TO hDlg
  CONTROL ADD BUTTON,  hDlg, %IDABORT, "Exit", 450, 215, 50, 15
  CONTROL ADD TOOLBAR, hDlg, %IDC_TOOLBAR1, "", 10, 0, 0, 0
  CONTROL ADD LABEL,   hDlg, %IDC_lblRecordcount, "0", 15, 45, 100, 10
  CONTROL SET COLOR    hDlg, %IDC_lblRecordcount, %BLUE, -1
#PBFORMS END DIALOG

  SampleToolbar  hDlg, %IDC_TOOLBAR1
  '
  IF ISTRUE funReadTheCSVFileIntoAnArray(strFile, BYREF a_strWork()) THEN

  '
  ' f = font
  ' s = font size
  ' r = rows
  ' c = columns
  ' z1 = create an array to allow individual cell formatting
  ' b = block selection 1 -> rows. 2-> columns. 3-> rows and columns
  ' x = column widths
  ' e = 1-> return key action 3-> add new row
  ' d = scroll bar
  ' a = row numbering defaults to numbered
  ' y = add extra pixels to row height - needed for some fonts
  '
    MLG_Init ' initialise the grid
    '
    lngRows = UBOUND(a_strWork,1)
    lngColumns = UBOUND(a_strWork,2)
    '
    CONTROL ADD "MYLITTLEGRID", hDlg, %IDC_GRID1, _
        "x20/a2/f3/s10/r" & FORMAT$(lngRows) & "/c" & _
        FORMAT$(lngColumns) & "/z1/b3/e1/d-0/y3", 5,60, 530, _
        120, %WS_CHILD OR %WS_VISIBLE OR %WS_BORDER, _
        %WS_EX_LEFT OR %WS_EX_LTRREADING
    CONTROL HANDLE hDlg, %IDC_Grid1 TO hGrid1
    '
    SendMessage hGrid1,%MLG_SETCELL,0,0
    '
    ' rename the tab
    funRenameTab(hGrid1,1,"CSV file")
    '
    MLG_PutEx(hGrid1,a_strWork(),1,1)
    '
    CONTROL SET TEXT hDlg,%IDC_lblRecordcount, _
                     FORMAT$(lngRows) & " records returned"
    '
    funWidenColumnsInGrid(hGrid1)
    funColourBankGridRows(hGrid1)
    '
    funGridRefresh(hGrid1)
    '
  END IF
  '
  '
  DIALOG SHOW MODAL hDlg, CALL ShowdlgDisplayCSVFileProc TO lRslt

#PBFORMS BEGIN CLEANUP %IDD_dlgDisplayCSVFile
#PBFORMS END CLEANUP

  FUNCTION = lRslt
END FUNCTION
'------------------------------------------------------------------------------

'------------------------------------------------------------------------------
FUNCTION SampleToolbar(BYVAL hDlg AS DWORD, BYVAL lID AS LONG) AS LONG
#PBFORMS BEGIN TOOLBARIMAGES %IDR_IMGFILE1->%IDR_IMGFILE2->%IDR_IMGFILE3->->
  LOCAL hImgList AS LONG

  IMAGELIST NEW ICON 16, 16, 32, 3 TO hImgList
  IMAGELIST ADD ICON hImgList, "#" + FORMAT$(%IDR_IMGFILE1)
  IMAGELIST ADD ICON hImgList, "#" + FORMAT$(%IDR_IMGFILE2)
  IMAGELIST ADD ICON hImgList, "#" + FORMAT$(%IDR_IMGFILE3)
  TOOLBAR SET IMAGELIST hDlg, lID, hImgList, 0
#PBFORMS END TOOLBARIMAGES

#PBFORMS BEGIN TOOLBARBUTTONS %IDC_TOOLBAR_NEW1->%IDC_TOOLBAR_OPEN1->%IDC_TOOLBAR_SAVE1->->
 ' TOOLBAR ADD BUTTON hDlg, lID, 1, %IDC_TOOLBAR_NEW1, %TBSTYLE_BUTTON, "New"
  TOOLBAR ADD BUTTON hDlg, lID, 2, %IDC_TOOLBAR_OPEN1, %TBSTYLE_BUTTON, _
    "Open"
 ' TOOLBAR ADD BUTTON hDlg, lID, 3, %IDC_TOOLBAR_SAVE1, %TBSTYLE_BUTTON, _
 '   "Save"
#PBFORMS END TOOLBARBUTTONS
END FUNCTION
'------------------------------------------------------------------------------
