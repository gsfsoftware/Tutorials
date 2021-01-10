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
'
' define columns
%TimeSlot = 1
%Activity = 2
%DayStart = 3
'
%ThisWeek = 1
%NextWeek = 2

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
  LOCAL strFile AS STRING
  '
  SELECT CASE AS LONG CB.MSG
    CASE %WM_INITDIALOG
    ' Initialization handler
      strFile = EXE.PATH$ & "ActivityGrid_" & _
                  FORMAT$(%ThisWeek) & ".txt"
      funLoadGridFromDisk(hGrid1,%ThisWeek,strFile)
      '
      strFile = EXE.PATH$ & "ActivityGrid_" & _
                  FORMAT$(%NextWeek) & ".txt"
      funLoadGridFromDisk(hGrid1,%NextWeek,strFile)
      '
      SendMessage hGrid1,%MLG_SELECTSHEET, %ThisWeek,0
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
        ' /* Inserted by PB/Forms 05-16-2020 14:59:30
        CASE %IDC_GRIDACTION
          IF CB.CTLMSG = %BN_CLICKED OR CB.CTLMSG = 1 THEN
          ' get information on the grid and get some data
            'strTemp = MLG_Get(hGrid1,1,2)
            'msgbox strTemp
            'funGridClear(hGrid1)
            'funGridRefresh(hGrid1)
            strFile  = EXE.PATH$ & "ActivityGrid_" & _
                       FORMAT$(%ThisWeek) & ".txt"
            funSaveGridToDisk(hGrid1,%ThisWeek, strFile)
            '
            strFile  = EXE.PATH$ & "ActivityGrid_" & _
                       FORMAT$(%NextWeek) & ".txt"
            funSaveGridToDisk(hGrid1,%NextWeek, strFile)
            '
            SendMessage hGrid1,%MLG_SELECTSHEET, %ThisWeek,0
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

  DIALOG NEW hParent, "MLG Demo", 258, 223, 710, 247, %WS_POPUP OR %WS_BORDER _
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

  ' add the grid to the dialog
  CONTROL ADD "MYLITTLEGRID", hDlg, %IDC_GRID1, _
        "x20/a2/f3/s10/r10/c9/z1/b3/e1/d-0/y3", 5,20, 640, _
        180, %WS_CHILD OR %WS_VISIBLE OR %WS_BORDER, _
        %WS_EX_LEFT OR %WS_EX_LTRREADING
  CONTROL HANDLE hDlg, %IDC_Grid1 TO hGrid1
  '
  ' set the space available for tabs
  funSetTabWidth(hGrid1,300)
  '
  SendMessage hGrid1, %MLG_SETHEADERCOLOR, %RGB_BLANCHEDALMOND,0
  ' rename the tab
  funRenameTab(hGrid1, %ThisWeek,"This week")
  '
  ' set the column headings
  MLG_Put hGrid1,0,%TimeSlot , "Time slot", lngRefresh
  MLG_Put hGrid1,0,%Activity , "Activity", lngRefresh
  FOR lngDay = 0 TO 6
    MLG_Put hGrid1, 0 ,lngDay + %DayStart , _
            DAYNAME$(lngDay), lngRefresh
  NEXT lngDay
  '
  strNewTabname = "Next Week"
  lngRows = 0
  lngColumns = 0
  ' add and name the new tab
  lngNewTabNumber = funAddTab(hGrid1, strNewTabname, _
                              lngRows,lngColumns)
  ' populate the first column
  PREFIX "MLG_Put hGrid1,"
    1,%TimeSlot , "9am",lngRefresh
    2,%TimeSlot , "10am",lngRefresh
    3,%TimeSlot , "11am",lngRefresh
    4,%TimeSlot , "12noon",lngRefresh
    5,%TimeSlot , "1pm",lngRefresh
    6,%TimeSlot , "2pm",lngRefresh
    7,%TimeSlot , "3pm",lngRefresh
    8,%TimeSlot , "4pm",lngRefresh
    9,%TimeSlot , "5pm",lngRefresh
    10,%TimeSlot , "6pm",lngRefresh
  END PREFIX
  '
  LOCAL lngColumn AS LONG
  LOCAL lngJustify AS LONG
  LOCAL lngColumnLock AS LONG
  LOCAL lngColour AS LONG
  '
  lngColumn = %TimeSlot
  lngJustify = %MLG_JUST_CENTER
  lngColumnLock = %MLG_LOCK
  lngColour = 0
  ' format Column 1 as centered and locked (read-only)
  MLG_FormatColNumber hGrid1,lngColumn,%MLG_NULL, lngJustify, _
                      lngColour , lngColumnLock
  '
  ' make day columns into checkboxes
  'for lngColumn = 2 to 9
  '  MLG_FormatColCheck(hGrid1,lngColumn)
  'next lngColumn
  '
  ' make day columns into checkboxes
  funFillGridWithCheckboxes(hGrid1,%DayStart)

  ' make activity column into drop downs
  LOCAL RC AS RowColDataType
  LOCAL strDropdown AS ASCIIZ * 1024
  '
  strDropdown = "Consult,Develop,On Break"
  RC.CellType = %MLG_type_ComboStatic
  RC.list = VARPTR(strDropdown)
  RC.FormatColor = %RGB_RED
  SendMessage hGrid1, %MLG_SETCOLFORMAT,%Activity ,VARPTR(RC)


  '
  ' select the new tab
  SendMessage hGrid1,%MLG_SELECTSHEET, lngNewTabNumber,0
  ' make day columns into checkboxes
  funFillGridWithCheckboxes(hGrid1,%DayStart)
  '
  ' populate the first column
  PREFIX "MLG_Put hGrid1,"
    1,%TimeSlot , "9am",lngRefresh
    2,%TimeSlot , "10am",lngRefresh
    3,%TimeSlot , "11am",lngRefresh
    4,%TimeSlot , "12noon",lngRefresh
    5,%TimeSlot , "1pm",lngRefresh
    6,%TimeSlot , "2pm",lngRefresh
    7,%TimeSlot , "3pm",lngRefresh
    8,%TimeSlot , "4pm",lngRefresh
    9,%TimeSlot , "5pm",lngRefresh
    10,%TimeSlot , "6pm",lngRefresh
  END PREFIX
  '
  lngColumn = %TimeSlot
  lngJustify = %MLG_JUST_CENTER
  lngColumnLock = %MLG_LOCK
  lngColour = 0
  ' format Column 1 as centered and locked (read-only)
  MLG_FormatColNumber hGrid1,lngColumn,%MLG_NULL, lngJustify, _
                      lngColour , lngColumnLock
  '
  RC.FormatColor = %RGB_BLUE
  SendMessage hGrid1, %MLG_SETCOLFORMAT,%Activity ,VARPTR(RC)


  ' select the first tab
  SendMessage hGrid1,%MLG_SELECTSHEET, %ThisWeek,0
  ' refresh the grid
  funGridRefresh(hGrid1)
  '
  DIALOG SHOW MODAL hDlg, CALL ShowdlgMLGDemoProc TO lRslt

#PBFORMS BEGIN CLEANUP %IDD_dlgMLGDemo
#PBFORMS END CLEANUP

  FUNCTION = lRslt
END FUNCTION
'------------------------------------------------------------------------------
