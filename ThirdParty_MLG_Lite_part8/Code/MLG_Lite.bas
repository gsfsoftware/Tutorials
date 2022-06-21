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
#INCLUDE "..\Libraries\MLG_Lite_Utilities.inc"
#INCLUDE "..\Libraries\PB_FileHandlingRoutines.inc"
'-------------------------------------------------------------------------------
'   ** Constants **
'------------------------------------------------------------------------------
#PBFORMS BEGIN CONSTANTS
%IDD_dlgMLG_lite =  101
%IDABORT         =    3
%IDD_NOTES       =  102
%IDC_txtNotes    = 1001
%IDOK            =    1
#PBFORMS END CONSTANTS
'------------------------------------------------------------------------------
' grid constants & Globals
%MaxGridColumns = 9     ' set starter number of columns in grid
%MaxGridRows    = 50    ' set starter number of rows in grid
' define the column widths
$ColumnWidths   = "x20,50,100,100,150,200,50,20,50,100"
' define the column names
$ColumnNames    = "ID,First name,Surname,Department,Division,Active,N,Loc,EmployeeNum"
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
'
' define grid tabs
ENUM tabs SINGULAR
  DemoGrid = 1
  SummaryGrid
END ENUM
'------------------------------------------------------------------------------
'   ** Declarations **
'------------------------------------------------------------------------------
DECLARE CALLBACK FUNCTION ShowdlgMLG_liteProc()
DECLARE FUNCTION ShowdlgMLG_lite(BYVAL hParent AS DWORD) AS LONG
#PBFORMS DECLARATIONS
'------------------------------------------------------------------------------
' pick up the bitmaps
#RESOURCE BITMAP, Notes, "notes.bmp"
'
GLOBAL g_a_strNotes() AS STRING        ' array for notes
GLOBAL g_lngNoteActive AS LONG         ' flag for notes active
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
  STATIC lngUpdating AS LONG       ' when %TRUE updating is in progress
  LOCAL lngMyOldSheet AS LONG      ' on tab select this is tab you are leaving
  LOCAL lngMyNewSheet AS LONG      ' on tab select this is tab you have select
  STATIC lngNotesColumn AS LONG    ' static variable for notes column number
  LOCAL lngSlot AS LONG            ' slot number for bitmap
  '
  SELECT CASE AS LONG CB.MSG
    CASE %WM_INITDIALOG
    ' Initialization handler
      ' fill first column with data (defaults to tab/sheet 1)
      lngNotesColumn = funGetColumnNumber(hGrid1,"N")
      '
      lngColumn = 1
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
      funPopulateSecondTab(hGrid1)
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
            CASE %MLGN_SELCHANGE
              myrow=@MLGN.Param1 'previous row
              mycol=@MLGN.Param2 'previous col
              '
              funGetSelectedRowColumn(hGrid1,myrow,mycol)
              '
              IF mycol = lngNotesColumn AND ISFALSE g_lngNoteActive THEN
                ' notes column selected
                g_lngNoteActive = %TRUE
                '
                ShowNOTES CB.HNDL,g_a_strNotes(myrow), myrow
                g_lngNoteActive = %FALSE
                '
                ' did user update the note
                SELECT CASE g_a_strNotes(myrow)
                  CASE ""
                  ' there is no note so take away the bitmap
                    mSetCellType(hGrid1,myrow,mycol,%MLG_TYPE_EDIT)
                    funGridRefresh(hGrid1)
                  CASE ELSE
                  ' there is a not so add the bitmap
                    lngSlot = 1
                    mAssignBitmapToCell(hGrid1,myrow,mycol,lngSlot)
                    funGridRefresh(hGrid1)
                END SELECT
                '
              END IF
              '
            CASE %MLGN_SHEETSELECT
            ' another tab/sheet has been clicked on
              lngMyOldSheet=@MLGN.Param2   'which tab is being deselected
              lngMyNewSheet=@MLGN.Param1   'which tab is being selected
              '
              ' user is switching tabs/sheets
              IF lngMyNewSheet = %SummaryGrid _
                 AND ISFALSE lngUpdating THEN
              ' user has picked the summary grid
                lngUpdating = %TRUE    ' flag that updates are happining
                funPopulateSecondTab(hGrid1)
                lngUpdating = %FALSE
              END IF
            '
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

  DIALOG NEW hParent, "MLG Lite", 202, 160, 620, 319, %WS_POPUP OR %WS_BORDER _
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
  lngGridWidth = 590
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
  '  show the information bar
  mShowInfoBar(hGrid1)
  '
  ' set the txt in the information bar
  mUpdateInfoBar(hGrid1,"User list of Staff in all Divisions", _
                 %MLG_JUST_CENTER)
                 '
  ' prepare the grid with tab/sheet number 1 as Demo Grid
  mPrepGrid(hGrid1,%MaxGridRows,%MaxGridColumns," Demo grid ", 1)
  '
  ' set the names of each column
  funSetColumnNames(hGrid1,$ColumnNames)
  '
  ' define column types
  ' hide column the EmployeeNum column?
  LOCAL lngColumn AS LONG
  lngColumn = funGetColumnNumber(hGrid1,"EmployeeNum")
  IF lngColumn > 0 THEN
  '  funHideAcolumn(hGrid1,lngColumn)
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
  LOCAL lngRow AS LONG
  LOCAL lngTotalRows AS LONG
  LOCAL lngColumn AS LONG
  LOCAL lngSlot AS LONG
  LOCAL strResource AS STRING
  '
  ' register the bitmap on this grid
  lngSlot = 1
  '
  mRegisterBitmapOnGrid(hGrid,lngSlot, "Notes")
  lngColumn = funGetColumnNumber(hGrid,"N")
  lngTotalRows = funGetRowsInGrid(hGrid)
  '
  ' store the notes
  REDIM g_a_strNotes(1 TO lngTotalRows) AS STRING
  FOR lngRow = 1 TO lngTotalRows
    g_a_strNotes(lngRow) = MLG_get(hGrid,lngRow, lngColumn)
  NEXT lngRow
  '
  FOR lngRow = 1 TO lngTotalRows
  ' sweep through all rows
    IF MLG_Get(hGrid,lngRow,lngColumn) <> "" THEN
      MLG_Put(hGrid, lngRow, lngColumn,"",lngRefresh)
      mAssignBitmapToCell(hGrid, lngRow,lngColumn,lngSlot)
    ELSE

    END IF
    '
  NEXT lngRow
  '
  funGridRefresh(hGrid)
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
'
FUNCTION funPopulateSecondTab(hGrid AS DWORD) AS LONG
' populate the second tab with data
  LOCAL lngSheet AS LONG
  DIM a_strData() AS STRING
  '
  lngSheet = 1
  mSelectSheet(hGrid,lngSheet)
  '
  funGetGridTextToArray(hGrid,a_strData())
  lngSheet = 2
  mSelectSheet(hGrid,lngSheet)
  '
  ' populate the summary data in this tab/sheet
  funPopulateSummary(hGrid,a_strData())
  funWidenColumnsInGrid(hGrid)
  '
  ' colour alternate rows for readability
  funColourBankGridRows(hGrid,%RGB_LIGHTGREEN)
  funGridRefresh(hGrid)
  '
END FUNCTION
'
CALLBACK FUNCTION ShowNOTESProc()
  LOCAL lngRow AS LONG
  LOCAL strText AS STRING
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
        ' /* Inserted by PB/Forms 06-19-2022 21:03:23
        CASE %IDOK
          IF CB.CTLMSG = %BN_CLICKED OR CB.CTLMSG = 1 THEN
          ' save the note to the array
          ' first get the lngRow value
            DIALOG GET USER CB.HNDL,1 TO lngRow
            ' then the text in the text box
            CONTROL GET TEXT CB.HNDL,%IDC_txtNotes TO strText
            ' and save it to the global array
            g_a_strNotes(lngRow) = strText
            '
            DIALOG END CB.HNDL, %IDOK
          END IF
        ' */

        CASE %IDC_txtNotes

      END SELECT
  END SELECT
END FUNCTION
'------------------------------------------------------------------------------

'------------------------------------------------------------------------------
FUNCTION ShowNOTES(BYVAL hParent AS DWORD, _
                         strNotes AS STRING, _
                         lngRow AS LONG) AS LONG
  LOCAL lRslt AS LONG

#PBFORMS BEGIN DIALOG %IDD_NOTES->->
  LOCAL hDlg  AS DWORD

  DIALOG NEW hParent, "Notes", 443, 246, 201, 121, %WS_POPUP OR %WS_BORDER OR _
    %WS_DLGFRAME OR %WS_CAPTION OR %WS_SYSMENU OR %WS_CLIPSIBLINGS OR _
    %WS_VISIBLE OR %DS_MODALFRAME OR %DS_CENTER OR %DS_3DLOOK OR _
    %DS_NOFAILCREATE OR %DS_SETFONT, %WS_EX_CONTROLPARENT OR %WS_EX_LEFT OR _
    %WS_EX_LTRREADING OR %WS_EX_RIGHTSCROLLBAR, TO hDlg
  CONTROL ADD TEXTBOX, hDlg, %IDC_txtNotes, "", 10, 15, 175, 80
  CONTROL ADD BUTTON,  hDlg, %IDOK, "Save", 135, 100, 50, 15
  DIALOG  SEND         hDlg, %DM_SETDEFID, %IDOK, 0
#PBFORMS END DIALOG
  ' display the text of the note
  CONTROL SET TEXT hDlg,%IDC_txtNotes, strNotes
  ' store the row number
  DIALOG SET USER hDlg, 1 , lngRow
  '
  DIALOG SHOW MODAL hDlg, CALL ShowNOTESProc TO lRslt

#PBFORMS BEGIN CLEANUP %IDD_NOTES
#PBFORMS END CLEANUP

  FUNCTION = lRslt
END FUNCTION
'------------------------------------------------------------------------------
