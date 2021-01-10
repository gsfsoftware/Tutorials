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
#RESOURCE "MLG_demo.pbr"
%USEMACROS = 1
#INCLUDE ONCE "WIN32API.INC"
#INCLUDE ONCE "COMMCTRL.INC"
#INCLUDE ONCE "PBForms.INC"
#PBFORMS END INCLUDES
'------------------------------------------------------------------------------
#INCLUDE "MLG.INC"
#INCLUDE "../Libraries/PB_MLG_Utilities.inc"
'------------------------------------------------------------------------------
'   ** Constants **
'------------------------------------------------------------------------------
#PBFORMS BEGIN CONSTANTS
%IDD_dlgMLGDemo =  101
%IDABORT        =    3
%IDC_GRIDACTION = 1001
#PBFORMS END CONSTANTS
'------------------------------------------------------------------------------
%IDC_GRID1 = 2000
GLOBAL hGrid1 AS DWORD
'------------------------------------------------------------------------------
'   ** Declarations **
'------------------------------------------------------------------------------
DECLARE CALLBACK FUNCTION ShowdlgMLGDemoProc()
DECLARE FUNCTION ShowdlgMLGDemo(BYVAL hParent AS DWORD) AS LONG
#PBFORMS DECLARATIONS
'------------------------------------------------------------------------------

'------------------------------------------------------------------------------
'   ** Main Application Entry Point **
'------------------------------------------------------------------------------
FUNCTION PBMAIN()
  PBFormsInitComCtls (%ICC_WIN95_CLASSES OR %ICC_DATE_CLASSES OR _
    %ICC_INTERNET_CLASSES)

  ShowdlgMLGDemo %HWND_DESKTOP
END FUNCTION
'------------------------------------------------------------------------------

'------------------------------------------------------------------------------
'   ** CallBacks **
'------------------------------------------------------------------------------
CALLBACK FUNCTION ShowdlgMLGDemoProc()
  LOCAL strTemp AS STRING
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
        ' /* Inserted by PB/Forms 05-16-2020 14:59:30
        CASE %IDC_GRIDACTION
          IF CB.CTLMSG = %BN_CLICKED OR CB.CTLMSG = 1 THEN
          ' get information on the grid and get some data
            strTemp = MLG_Get(hGrid1,1,2)
            'msgbox strTemp
            funGridClear(hGrid1)
            funGridRefresh(hGrid1)
          '
          END IF
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
FUNCTION ShowdlgMLGDemo(BYVAL hParent AS DWORD) AS LONG
  LOCAL lRslt AS LONG
  LOCAL lngDay AS LONG
  LOCAL lngRefresh AS LONG
  LOCAL strNewTabName AS STRING
  LOCAL lngNewTabNumber AS LONG
  LOCAL lngRows AS LONG
  LOCAL lngColumns AS LONG

#PBFORMS BEGIN DIALOG %IDD_dlgMLGDemo->->
  LOCAL hDlg  AS DWORD

  DIALOG NEW hParent, "MLG Demo", 258, 223, 650, 247, %WS_POPUP OR %WS_BORDER _
    OR %WS_DLGFRAME OR %WS_CAPTION OR %WS_SYSMENU OR %WS_MINIMIZEBOX OR _
    %WS_CLIPSIBLINGS OR %WS_VISIBLE OR %DS_MODALFRAME OR %DS_CENTER OR _
    %DS_3DLOOK OR %DS_NOFAILCREATE OR %DS_SETFONT, %WS_EX_CONTROLPARENT OR _
    %WS_EX_LEFT OR %WS_EX_LTRREADING OR %WS_EX_RIGHTSCROLLBAR, TO hDlg
  CONTROL ADD BUTTON, hDlg, %IDABORT, "Exit", 350, 205, 50, 15
  CONTROL ADD BUTTON, hDlg, %IDC_GRIDACTION, "Grid Action", 25, 205, 50, 15
#PBFORMS END DIALOG
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
  MLG_Init ' initialse the grid
  CONTROL ADD "MYLITTLEGRID", hDlg, %IDC_GRID1, _
        "x20/a2/f3/s10/r10/c8/z1/b3/e1/d-0/y3", 5,20, 600, _
        180, %WS_CHILD OR %WS_VISIBLE OR %WS_BORDER, _
        %WS_EX_LEFT OR %WS_EX_LTRREADING
  CONTROL HANDLE hDlg, %IDC_Grid1 TO hGrid1
  '
  funSetTabWidth(hGrid1,300)
  '
  SendMessage hGrid1, %MLG_SETHEADERCOLOR, %RGB_BLANCHEDALMOND,0
  '
  funRenameTab(hGrid1, 1,"This week")
  '
  ' set the column headings
  MLG_Put hGrid1,0,1 , "Time slot", lngRefresh
  FOR lngDay = 0 TO 6
    MLG_Put hGrid1, 0 ,lngDay +2 , DAYNAME$(lngDay), lngRefresh
  NEXT lngDay
  '
  strNewTabname = "Next Week"
  lngRows = 0
  lngColumns = 0
  lngNewTabNumber = funAddTab(hGrid1, strNewTabname, _
                              lngRows,lngColumns)
  '
  PREFIX "MLG_Put hGrid1,"
    1,1 , "9am",lngRefresh
    2,1 , "10am",lngRefresh
    3,1 , "11am",lngRefresh
    4,1 , "12noon",lngRefresh
    5,1 , "1pm",lngRefresh
  END PREFIX
  '
  LOCAL lngColumn AS LONG
  LOCAL lngJustify AS LONG
  LOCAL lngColumnLock AS LONG
  LOCAL lngColour AS LONG
  '
  lngColumn = 1
  lngJustify = %MLG_JUST_CENTER
  lngColumnLock = %MLG_LOCK
  lngColour = 0
  MLG_FormatColNumber hGrid1,lngColumn,%MLG_NULL, lngJustify, _
                      lngColour , lngColumnLock
  '
  ' make day columns into checkboxes
  'for lngColumn = 2 to 9
  '  MLG_FormatColCheck(hGrid1,lngColumn)
  'next lngColumn
  '
  funFillGridWithCheckboxes(hGrid1,2)
  SendMessage hGrid1,%MLG_SELECTSHEET, lngNewTabNumber,0
  funFillGridWithCheckboxes(hGrid1,2)
  SendMessage hGrid1,%MLG_SELECTSHEET, 1,0
  '
  funGridRefresh(hGrid1)
  '
  DIALOG SHOW MODAL hDlg, CALL ShowdlgMLGDemoProc TO lRslt

#PBFORMS BEGIN CLEANUP %IDD_dlgMLGDemo
#PBFORMS END CLEANUP

  FUNCTION = lRslt
END FUNCTION
'------------------------------------------------------------------------------
