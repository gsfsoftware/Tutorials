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
%IDD_dlgDisplayCSVFile = 101
%IDABORT               =   3
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
  ShowdlgDisplayCSVFile %HWND_DESKTOP,strFile
END FUNCTION
'------------------------------------------------------------------------------

'------------------------------------------------------------------------------
'   ** CallBacks **
'------------------------------------------------------------------------------
CALLBACK FUNCTION ShowdlgDisplayCSVFileProc()

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
  CONTROL ADD BUTTON, hDlg, %IDABORT, "Exit", 450, 215, 50, 15
#PBFORMS END DIALOG
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
