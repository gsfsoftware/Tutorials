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
#RESOURCE "MLG_Lite.pbr"
%USEMACROS = 1
#INCLUDE ONCE "WIN32API.INC"
#INCLUDE ONCE "COMMCTRL.INC"
#INCLUDE ONCE "PBForms.INC"
#PBFORMS END INCLUDES
'------------------------------------------------------------------------------
%MLGSLL = 1             ' set to use MLG as a SLL
#INCLUDE "MLG.INC"      ' include MLG library
#LINK "MLG.SLL"         ' link to SSL
'
' MLG Lite Utilities
#INCLUDE "MLG_Lite_Utilities.inc"
#INCLUDE "..\Libraries\PB_FileHandlingRoutines.inc"
'------------------------------------------------------------------------------
'   ** Constants **
'------------------------------------------------------------------------------
#PBFORMS BEGIN CONSTANTS
%IDD_dlgMLG_lite = 101
%IDABORT         =   3
#PBFORMS END CONSTANTS
'------------------------------------------------------------------------------
' grid constants & Globals
%MaxGridColumns = 7     ' set starter number of columns in grid
%MaxGridRows    = 50    ' set starter number of rows in grid
' define the column widths
$ColumnWidths   = "x20,50,100,100,150,200,80,100"
' define the column names
$ColumnNames    = "ID,First name,Surname,Department,Division,Active,EmployeeNum"
'
$ColumnNamesSummary = "Department,Head Count"
'
' one constant for each grid
%IDC_MLGGRID1   = 3000  ' dialog control handle for grid

' one global per grid in your application
GLOBAL hGrid1 AS LONG  ' Windows handle for grid
'
' Data constants
$DataFile = "DataFile.csv"  ' name of the file
'------------------------------------------------------------------------------
'   ** Declarations **
'------------------------------------------------------------------------------
DECLARE CALLBACK FUNCTION ShowdlgMLG_liteProc()
DECLARE FUNCTION ShowdlgMLG_lite(BYVAL hParent AS DWORD) AS LONG
#PBFORMS DECLARATIONS
'------------------------------------------------------------------------------

'------------------------------------------------------------------------------
'   ** Main Application Entry Point **
'------------------------------------------------------------------------------
FUNCTION PBMAIN()
  PBFormsInitComCtls (%ICC_WIN95_CLASSES OR %ICC_DATE_CLASSES OR _
    %ICC_INTERNET_CLASSES)

  MLG_Init  ' initialise the grid control

  ShowdlgMLG_lite %HWND_DESKTOP
END FUNCTION
'------------------------------------------------------------------------------

'------------------------------------------------------------------------------
'   ** CallBacks **
'------------------------------------------------------------------------------
CALLBACK FUNCTION ShowdlgMLG_liteProc()
'
  LOCAL MLGN AS MyGridData PTR     ' set up the grid pointer
  LOCAL mycol AS LONG              ' grid column number
  LOCAL myrow AS LONG              ' grid row number
  LOCAL strText AS STRING          ' generic text string
  LOCAL myitem AS LONG             ' number of menu item clicked
  LOCAL lngClipResult AS LONG      ' result of copying to the clipboard
  LOCAL lngSourceColumn AS LONG    ' source column for conditional user buttons
  LOCAL lngColumn AS LONG          ' target column for conditional user buttons
  '
  LOCAL lngSheet AS LONG           ' the number of the sheet/tab
  LOCAL a_strData() AS STRING      ' array to hold data from sheet/tab 1
  '
  SELECT CASE AS LONG CB.MSG
    CASE %WM_INITDIALOG
    ' Initialization handler
      ' fill first column with data (defaults to tab/sheet 1)
      lngColumn = 1
      'funFillColumnWithValue(hGrid1,lngColumn,"TEXT")
      '
      'funFillColumnWithRowNumber(hGrid1,lngColumn)
      '
      ' mark the whole grid as read only
      'funMarkGridasReadOnly(hGrid1)
      '
      LOCAL lngRow AS LONG
      ' unlock a single cell
      lngRow = 2 : lngColumn = 3
      funUnLockCell(hGrid1,lngRow,lngColumn)
      '
      ' mark row 2 , column 3 with background colour
      funMarkGridCellWithColour(hGrid1,lngRow,lngColumn,%CELLCOLORYELLOW)
      '
      ' There are a number of colours predefined in MLG
      ' in 16 slots {lngSlot}
      ' these can be reset with a SendMessage command
      ' SendMessage hGrid,%MLG_SETBKGNDCELLCOLOR,lngSlot, %RGB_HONEYDEW
      '
'      %CELLCOLORWHITE = 0
'      %CELLCOLORBLACK = 1
'      'Same for Text and Background
'      %CELLCOLORRED   = 2
'      %CELLCOLORSALMON = 3
'      %CELLCOLORGREEN = 4
'      %CELLCOLORLIGHTGREEN = 5
'      %CELLCOLORBLUE = 6
'      %CELLCOLORLIGHTBLUE = 7
'      %CELLCOLORMAGENTA = 8
'      %CELLCOLORDARKMAGENTA = 9
'      %CELLCOLORCYAN = 10
'      %CELLCOLORAQUAMARINE = 11
'      %CELLCOLORKHAKI = 12
'      %CELLCOLORBROWN = 13
'      %CELLCOLORYELLOW = 14
'      %CELLCOLORORANGE = 15
'
       ' load the data into the grid
       funLoadTheData(hGrid1)
       ' populate the ID column with row numbers
       lngColumn = 1
       funFillColumnWithRowNumber(hGrid1,lngColumn)
       '
       'widen/narrow columns in grid to match data
       lngColumn = funGetColumnNumber(hGrid1,"Surname")
       mWidenAcolumnInGrid(hGrid1,lngColumn)
       '
       'funWidenColumnsInGrid(hGrid1)
       '
       ' add a user button to every cell in a column
       'lngColumn = funGetColumnNumber(hGrid1,"Surname")
       'funAddUserButtonToColumn(hGrid1,lngColumn)
       '
       ' add a user button conditionally
       lngColumn = funGetColumnNumber(hGrid1,"Surname")
       lngSourceColumn = funGetColumnNumber(hGrid1,"Division")
       funAddUserButtonToColumnConditionally(hGrid1, _
                                             lngColumn, _
                                             lngSourceColumn, _
                                             "Petrochemical")
       '
       ' colour alternate rows for readability
       funColourBankGridRows(hGrid1,%RGB_LIGHTGREEN)
       '
       ' populate the second sheet/tab
       funGetGridTextToArray(hGrid1,a_strData())
       lngSheet = 2
       mSelectSheet(hGrid1,lngSheet)
       '
       ' populate the summary data in this tab/sheet
       funPopulateSummary(hGrid1,a_strData())
       funWidenColumnsInGrid(hGrid1)
       '
       ' colour alternate rows for readability
       funColourBankGridRows(hGrid1,%RGB_LIGHTGREEN)
       '
       ' set tab/sheet back to 1
       lngSheet = 1
       mSelectSheet(hGrid1,lngSheet)
    '
    CASE %WM_NOTIFY
      MLGN = CB.LPARAM   ' pick up msg dependant value
      SELECT CASE @MLGN.NMHeader.idFrom
      ' which dialog control did this notification
      ' come from?
        CASE %IDC_MLGGRID1
        ' if it's the grid
          SELECT CASE @MLGN.NMHeader.code
          ' which grid event has happened?
            CASE %MLGN_USERBUTTON
            ' a user button has been clicked
            ' pick up the row and column that
            ' has been clicked on
              mycol=@MLGN.Param2
              myrow=@MLGN.Param1
              strText = MLG_Get(hGrid1,myrow,mycol)
              '
              MSGBOX "You have clicked on " & $CRLF & _
                     "Row " & FORMAT$(myrow) & $CRLF & _
                     "Column " & FORMAT$(mycol) & $CRLF & _
                     "Text is " & strText, _
                     %MB_ICONINFORMATION OR %MB_TASKMODAL , _
                     "User Button Info"
            '
            CASE %MLGN_RCLICKMENU
            ' user has right clicked and opened a menu
              myitem=@MLGN.Param3  ' Menu Item number
              mycol=@MLGN.Param2   ' column number
              myrow=@MLGN.Param1   ' row number
              '
              SELECT CASE myitem
                CASE 1
                ' Sort by column ascending
                  SendMessage hGrid1,%MLG_SORT, %MLG_ASCEND , mycol
                  ' remove the user button from column for every row
                  lngColumn = funGetColumnNumber(hGrid1,"Surname")
                  funRemoveUserButtonFromColumn(hGrid1,lngColumn)
                  '
                  lngSourceColumn = funGetColumnNumber(hGrid1,"Division")
                  funAddUserButtonToColumnConditionally(hGrid1, _
                                             lngColumn, _
                                             lngSourceColumn, _
                                             "Petrochemical")
                  funGridRefresh(hGrid1)
                  '
                CASE 2
                ' Sort by column descending
                  SendMessage hGrid1,%MLG_SORT, %MLG_DESCEND , mycol
                  lngColumn = funGetColumnNumber(hGrid1,"Surname")
                  funRemoveUserButtonFromColumn(hGrid1,lngColumn)
                  '
                  lngSourceColumn = funGetColumnNumber(hGrid1,"Division")
                  funAddUserButtonToColumnConditionally(hGrid1, _
                                             lngColumn, _
                                             lngSourceColumn, _
                                             "Petrochemical")
                  funGridRefresh(hGrid1)
                  '
                CASE 3
                ' this is the divider bar
                CASE 4
                ' copy cell to the clipboard
                  strText = MLG_Get(hGrid1,myrow,mycol)
                  CLIPBOARD RESET
                  CLIPBOARD SET TEXT strText, lngClipResult
                  '
              END SELECT
              '
          END SELECT
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

      END SELECT
  END SELECT
END FUNCTION
'------------------------------------------------------------------------------

'------------------------------------------------------------------------------
'   ** Dialogs **
'------------------------------------------------------------------------------
FUNCTION ShowdlgMLG_lite(BYVAL hParent AS DWORD) AS LONG
  LOCAL lRslt AS LONG

#PBFORMS BEGIN DIALOG %IDD_dlgMLG_lite->->
  LOCAL hDlg  AS DWORD

  DIALOG NEW hParent, "MLG Lite", 202, 160, 558, 319, %WS_POPUP OR %WS_BORDER _
    OR %WS_DLGFRAME OR %WS_CLIPSIBLINGS OR %WS_VISIBLE OR %DS_MODALFRAME OR _
    %DS_CENTER OR %DS_3DLOOK OR %DS_NOFAILCREATE OR %DS_SETFONT, _
    %WS_EX_CONTROLPARENT OR %WS_EX_LEFT OR %WS_EX_LTRREADING OR _
    %WS_EX_RIGHTSCROLLBAR, TO hDlg
  CONTROL ADD BUTTON, hDlg, %IDABORT, "Exit", 440, 290, 50, 15
#PBFORMS END DIALOG
  '
  ' Set the dimensions of the grid
  LOCAL lngGridX, lngGridY AS LONG
  LOCAL lngGridWidth, lngGridHeight AS LONG
  lngGridX = 10
  lngGridY = 20
  lngGridWidth = 490
  lngGridHeight = 250
  '
  ' Set the options in the right click menu for the grid
  LOCAL strMenu AS STRING
  strMenu = "/m1Sort column ascending," & _
             "Sort column descending," & _
             "-," & _
             "Copy cell to Clipboard"
  '
  ' add the grid control
  CONTROL ADD "MYLITTLEGRID", hDlg, %IDC_MLGGRID1, _
          $ColumnWidths & "/d-0/e1/r" & FORMAT$(%MaxGridRows) & _
          strMenu & "/c" & _
          FORMAT$(%MaxGridColumns) & "/a2/y3", _
          lngGridX, lngGridY, lngGridWidth, lngGridHeight, %MLG_STYLE
  '
  ' capture the windows handle to the grid
  CONTROL HANDLE hDlg, %IDC_MLGGRID1 TO hGrid1
  '
  ' prepare the grid with tab/sheet number 1 as Demo Grid
  mPrepGrid(hGrid1,%MaxGridRows,%MaxGridColumns," Demo grid ", 1)
  '
  ' set the names of each column
  funSetColumnNames(hGrid1,$ColumnNames)
  '
  ' define column types
  ' hide column 7 the EmployeeNum column?
  'funHideAcolumn(hGrid1,7)
  LOCAL lngColumn AS LONG
  lngColumn = funGetColumnNumber(hGrid1,"EmployeeNum")
  IF lngColumn > 0 THEN
    funHideAcolumn(hGrid1,lngColumn)
  END IF
  '
  ' Center and lock the ID column
  lngColumn = funGetColumnNumber(hGrid1,"ID")
  funFormatColumn(hGrid1,lngColumn,"CENTER",%BLUE,"LOCK")
  '
  lngColumn = funGetColumnNumber(hGrid1,"ACTIVE")
  funFormatColumn(hGrid1,lngColumn,"CENTER",%BLUE,"UNLOCK",%TRUE)
  '
  ' create a dropdown column
  lngColumn = funGetColumnNumber(hGrid1,"DIVISION")
  LOCAL strList AS STRING
  strList = "Banking,Computing,Finance,Healthcare,Hotels," & _
            "Marketing,Outsourcing,Petrochemical,Research,"
  funFormatGridDropDown(hGrid1,lngColumn,strList)

  ' colour alternate rows for readability
  'funColourBankGridRows(hGrid1,%RGB_LIGHTGREEN)
  '
  ' add a new worksheet/tab
  LOCAL lngTabPos AS LONG
  LOCAL strTabName AS STRING
  ' set new tab/sheet number
  lngTabPos = 2
  mAddSheet(hGrid1)
  '
  ' set tab name
  strTabName = "Summary Data"
  funRenameTab(hGrid1, lngTabPos, strTabName)
  '
  mSelectSheet(hGrid1,lngTabPos)
  '
  ' set the names of each column
  funSetColumnNames(hGrid1,$ColumnNamesSummary)
  ' widen columns
  funWidenColumnsInGrid(hGrid1)
  '
  ' adjust the columns
  lngColumn = funGetColumnNumber(hGrid1,"Department")
  funFormatColumn(hGrid1,lngColumn,"LEFT",%BLUE,"LOCK")
  '
  lngColumn = funGetColumnNumber(hGrid1,"Head Count")
  funFormatColumn(hGrid1,lngColumn,"CENTER",%RED,"LOCK")
  '
  lngTabPos = 1 ' change back to sheet/tab 1
  mSelectSheet(hGrid1,lngTabPos)
  '
  ' refresh the grid on screen
  funGridRefresh(hGrid1)
  '
  DIALOG SHOW MODAL hDlg, CALL ShowdlgMLG_liteProc TO lRslt

#PBFORMS BEGIN CLEANUP %IDD_dlgMLG_lite
#PBFORMS END CLEANUP

  FUNCTION = lRslt
END FUNCTION
'------------------------------------------------------------------------------
FUNCTION funLoadTheData(hGrid AS DWORD) AS LONG
  DIM a_strData() AS STRING
  LOCAL lngRefresh AS LONG
  LOCAL lngOption AS LONG
  '
  IF ISTRUE funReadTheCSVFileIntoAnArray(EXE.PATH$ & $DataFile, _
                                         BYREF a_strData()) THEN
    ' populate the grid with the contents of the array
    lngRefresh = 1 ' refresh the grid once done
    lngOption = -2
    '1 then replace the grid with array data only if nothing
    '  is out of bounds
    '2 then do not write over column headers
    '3 then do not write over row headers
    '4 then do not write over row or column headers
    'If op is negative then resize the grid to fit the array
    MLG_PutEX(hGrid,a_strData(),lngOption,lngRefresh)
  END IF
  '
END FUNCTION
'
FUNCTION funPopulateSummary(hGrid AS DWORD, _
                            BYREF a_strData() AS STRING) AS LONG
' populate the grid with data
  LOCAL lngR AS LONG
  LOCAL lngD AS LONG
  LOCAL lngCount AS LONG               ' count of staff
  LOCAL lngDepartment AS LONG          ' department column
  LOCAL lngActive AS LONG              ' active column
  LOCAL strDepartment AS STRING        ' dept name in source array
  LOCAL strDepartmentCount AS STRING   ' dept name in count array
  DIM a_strDepartments(20) AS STRING   ' department count data
  '
  ' set columns
  lngDepartment = 4
  lngActive = 6
  '
  FOR lngR = 1 TO UBOUND(a_strData)
  ' for each row
    IF a_strData(lngR,lngActive) <> "" THEN
    ' active employee
    ' add to departments
      strDepartment = a_strData(lngR,lngDepartment)
      '
      FOR lngD = 1 TO UBOUND(a_strDepartments)
        strDepartmentCount = PARSE$(a_strDepartments(lngD),"|",1)
        '
        IF strDepartmentCount = strDepartment THEN
        ' department match found
          lngCount = VAL(PARSE$(a_strDepartments(lngD),"|",2))
          INCR lngCount
          a_strDepartments(lngD) = strDepartmentCount & _
                                   "|" & FORMAT$(lngCount)
          EXIT FOR  ' dept found
          '
        ELSE
        ' no match so far - is entry blank?
          IF strDepartmentCount = "" THEN
          ' record department
            a_strDepartments(lngD) = strDepartment & "|1"
            EXIT FOR
          END IF
          '
        END IF
      NEXT lngD

    END IF
  '
  NEXT lngR
  '
  ' now sort departments
  ARRAY SORT a_strDepartments(1), COLLATE UCASE, DESCEND
  '
  ' how many departments are there?
  lngCount = 0
  FOR lngD = 1 TO UBOUND(a_strDepartments)
    IF a_strDepartments(lngD) <> "" THEN
      INCR lngCount
    END IF
  NEXT lngD
  '
  DIM a_strResult(lngCount,2) AS STRING
  FOR lngD = 1 TO lngCount
    a_strResult(lngD,1) = PARSE$(a_strDepartments(lngD),"|",1)
    a_strResult(lngD,2) = PARSE$(a_strDepartments(lngD),"|",2)
  NEXT lngD
  '
  ' populate the grid with the contents of the array
  LOCAL lngRefresh AS LONG
  LOCAL lngOption AS LONG
  lngRefresh = 1 ' refresh the grid once done
  lngOption = -4
  '1 then replace the grid with array data only if nothing
  '  is out of bounds
  '2 then do not write over column headers
  '3 then do not write over row headers
  '4 then do not write over row or column headers
  'If op is negative then resize the grid to fit the array
  MLG_PutEX(hGrid,a_strResult(),lngOption,lngRefresh)
  '
END FUNCTION
