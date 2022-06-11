' MLG_Lite_Utilities.inc

' Macros
'  mAddSheet - adds a new sheet/tab to the grid
'  funGridClear  - removes content from a specified grid
'  funGridRefresh - redraws the specified grid on screen
'  mAddUserButtonToCell - Adds a user button to a specific cell
'  mHideInfoBar - hides the infobar on the grid
'  mPrepGrid - this macro allows all the normal preparitory code for
'              MLG to be put in place using just one line of code
'  mRemoveUserButtonFromCell - Removes a user button from a specific cell
'  mShowInfoBar - shows an infobar on the grid
'  mWidenAcolumnInGrid - widens or narrows a column to fit the data
'                        within that column

' Functions
'  funAddUserButtonToColumn - adds a user button to a column in every row
'  funAddUserButtonToColumnConditionally - adds a user button to a column
'                                          in every row where condition is
'                                          met
'  funColourBankGridRows - makes alternate rows different colours
'  funCountSheets - return the number of tabs/sheets in the grid
'  funFillColumnWithRowNumber - Populate a column with the row number
'  funFillColumnWithValue - Populate a column, for all rows with same value
'  funFormatColumn - format a column for alingment, colour, locking
'                    or make it a checkbox
'  funFormatGridDropDown - format a column as a dropdown list
'  funGetColumnName - return the column name by providing the number
'  funGetColumnNumber - return the column number by providing the name
'  funGetColumnsInGrid - returns the number of Columns in a grid
'  funGetRowsInGrid - returns the number of Rows in a grid
'  funHideAcolumn - make a column invisble to the user
'  funLockCell - make a specified cell read only
'  funMarkGridasReadOnly - make all cells in grid read only
'  funMarkGridCellWithColour - change the background colour of a specified
'                              cell
'  funRemoveUserButtonFromColumn - remove a user button from a column in
'                                  every row
'  funRemoveUserButtonToColumnConditionally - remove a user button from a
'                                             column in every row where
'                                             condition is met
'  funRenameTab - allows an existing Tab/Sheet to be renamed
'  funSetColumnNames - populate the Column header titles
'  funUnLockCell - make a specified cell editable
'  funWidenColumnsInGrid - auto widens/narrows all columns to fit data

MACRO mShowInfoBar(hGrid)
' macro to show the infobar on the grid
  SendMessage hGrid, %MLG_ALTERATTRIBUTE, %MLG_TOPINFOBAR,1
END MACRO
'
MACRO mHideInfoBar(hGrid)
' macro to hide the infobar on the grid
  SendMessage hGrid, %MLG_ALTERATTRIBUTE, %MLG_TOPINFOBAR,0
END MACRO
'
MACRO mUpdateInfoBar(hGrid,strTitle,lngJustify)
' update the text on an InfoBar
' with justification
  LOCAL zstrInfoBar AS ASCIIZ * 260
  zstrInfoBar = strTitle
  '
  SendMessage hGrid, %MLG_SETINFOBARTEXT,VARPTR(zstrInfoBar) ,_
                      MAKLNG(MAKWRD(lngJustify,%MLGSYSFONTBOLD), _
                      MAKWRD(1,1))
END MACRO
'
MACRO mPrepGrid(hGrid,lngRows,lngColumns,strTabName, lngTabPosition)
' macro to prepare the grid for use
  MLG_ArrayRedim(hGrid, lngRows , lngColumns, _
                 lngRows+10, lngColumns+2)

  ' set override slots for grey colours
  SendMessage hGrid,%MLG_SETBKGNDCELLCOLOR,2, %RGB_HONEYDEW
  ' set up for grid overrides array
  SendMessage hGrid ,%MLG_CREATEFORMATOVERRIDE,0,0
  '
  ' set cell for licence
  SendMessage hGrid,%MLG_SETCELL,0,0
  ' set header colour
  SendMessage hGrid, %MLG_SETHEADERCOLOR , %LTGRAY,0
  '
  ' display the tabs - 300 is the amount of room for the tabs
  ' - rest taken up by scroll bar
  SendMessage hGrid, %MLG_SHOWSHEETTABS,300,0
  funRenameTab(hGrid,lngTabPosition,strTabName)
END MACRO
'
FUNCTION funRenameTab(hGrid AS DWORD, lngTabPos AS LONG, strTabName AS STRING ) AS LONG
' rename a tab of a grid
  LOCAL aTab AS ASCIIZ * 255
  aTab = "  " & strTabName & "  "
  SendMessage hGrid, %MLG_NAMESHEET , lngTabPos,VARPTR(aTab)
  '
END FUNCTION
'
FUNCTION funColourBankGridRows(hGrid AS DWORD, _
             OPTIONAL lngBackgroundColour AS LONG) AS LONG
' make alternating lines in the grid different colours
' making the grid easier to read
'
  LOCAL lngBKColour AS LONG
  '
  IF ISMISSING(lngBackgroundColour) THEN
    lngBKColour = %RGB_HONEYDEW
  ELSE
    lngBKColour = lngBackgroundColour
  END IF
  '
  LOCAL I AS LONG
  LOCAL lngRows AS LONG , lngE AS LONG
  LOCAL lngColumns AS LONG
  LOCAL lngRefresh AS LONG
  LOCAL lngR AS LONG
  LOCAL lngC AS LONG
  '
  ' determine the size of the grid
  I= SendMessage(hGrid, %MLG_GETROWCOLTOT, 0, 0)
  lngRows = LO(INTEGER, I)
  lngColumns = HI(INTEGER,I)
  '
  SendMessage hGrid,%MLG_SETBKGNDCELLCOLOR,2, lngBKColour
  ' colour bank the data
  FOR lngR = 1 TO lngRows
    FOR lngC = 1 TO lngColumns
      IF (lngR MOD 2) = 0 THEN
        SendMessage hGrid ,%MLG_SETFORMATOVERRIDEEX,MAKLNG(lngR,lngC),MAKLNG(%MLG_TYPE_BKGCOLOR, 0)
      ELSE
        SendMessage hGrid ,%MLG_SETFORMATOVERRIDEEX,MAKLNG(lngR,lngC),MAKLNG(%MLG_TYPE_BKGCOLOR, 2)
      END IF
    NEXT lngC
  NEXT lngR
  '
END FUNCTION
'
MACRO funGridRefresh(hGrid)
' refresh the specified grid
  SendMessage(hGrid, %MLG_REFRESH, 1, 0)
'
END MACRO
'
MACRO funGridClear(hGrid)
' refresh the specified grid in a cleared state
  SendMessage(hGrid, %MLG_CLEARGRID, 0, 0)
'
END MACRO
'
FUNCTION funGetColumnsInGrid(hGrid AS DWORD) AS LONG
  ' determine the size of the grid
  LOCAL I AS LONG
  LOCAL lngRows AS LONG
  LOCAL lngColumns AS LONG
  '
  I= SendMessage(hGrid, %MLG_GETROWCOLTOT, 0, 0)
  lngRows = LO(INTEGER, I)
  lngColumns = HI(INTEGER,I)
  FUNCTION = lngColumns
END FUNCTION
'
FUNCTION funGetRowsInGrid(hGrid AS DWORD) AS LONG
  ' determine the size of the grid
  LOCAL I AS LONG
  LOCAL lngRows AS LONG
  LOCAL lngColumns AS LONG
  '
  I= SendMessage(hGrid, %MLG_GETROWCOLTOT, 0, 0)
  lngRows = LO(INTEGER, I)
  lngColumns = HI(INTEGER,I)
  FUNCTION = lngRows
END FUNCTION
'
MACRO mWidenAcolumnInGrid(hGrid,lngColumn)
' widen/narrow a single column in the grid to fit
' the data including header lines
'
  MLG_SetColMaxLen(hGrid, lngColumn,1)
'
END MACRO
'
FUNCTION funWidenColumnsInGrid(hGrid AS DWORD, _
                      OPTIONAL lngColumnExclude AS LONG) AS LONG
' widen the columns in the grid to fit the data and headers in them
  LOCAL lngC AS LONG
  LOCAL lngConsiderHeader AS LONG
  LOCAL lngColumns AS LONG
  LOCAL lngColumnToExclude AS LONG
  '
  IF ISTRUE ISMISSING(lngColumnExclude) THEN
    lngColumnToExclude = 0
  ELSE
    lngColumnToExclude = lngColumnExclude
  END IF
  '
  lngColumns = funGetColumnsInGrid(hGrid)
  '
  lngConsiderHeader = 1
  ' widen the columns
  FOR lngC = 1 TO lngColumns
    IF lngC <> lngColumnToExclude  THEN
      MLG_SetColMaxLen(hGrid, lngC,lngConsiderHeader)
    END IF
  NEXT lngC
'
END FUNCTION
'
FUNCTION funFillColumnWithRowNumber(hGrid AS DWORD, _
                                    lngColumn AS LONG, _
                                    OPTIONAL lngTab AS LONG) AS LONG
' file a grid column with the row number
  LOCAL lngRows AS LONG
  LOCAL lngRow AS LONG
  LOCAL lngRedraw AS LONG
  '
  lngRows = funGetRowsInGrid(hGrid)
  FOR lngRow = 1 TO lngRows
    IF lngRow = lngRows THEN INCR lngRedraw
    IF ISFALSE ISMISSING(lngTab) THEN
      MLG_PUT(hGrid,lngRow, lngColumn,FORMAT$(lngRow),lngRedraw, lngTab)
    ELSE
      MLG_PUT(hGrid,lngRow, lngColumn,FORMAT$(lngRow),lngRedraw)
    END IF
  NEXT lngRow
  '
END FUNCTION
'
FUNCTION funFillColumnWithValue(hGrid AS DWORD, _
                                lngColumn AS LONG , _
                                strValue AS STRING, _
                                OPTIONAL lngTab AS LONG) AS LONG
' fill a grid column with same value
  LOCAL lngRows AS LONG
  LOCAL lngRow AS LONG
  LOCAL lngRedraw AS LONG
  '
  lngRows = funGetRowsInGrid(hGrid)
  FOR lngRow = 1 TO lngRows
    IF lngRow = lngRows THEN INCR lngRedraw
    IF ISFALSE ISMISSING(lngTab) THEN
      MLG_PUT(hGrid,lngRow, lngColumn,strValue,lngRedraw, lngTab)
    ELSE
      MLG_PUT(hGrid,lngRow, lngColumn,strValue,lngRedraw)
    END IF
  NEXT lngRow
  '
END FUNCTION
'
MACRO mSelectSheet(hGrid,lngSheet)
' select the tab/sheet
  SendMessage hGrid, %MLG_SELECTSHEET, lngSheet,0
END MACRO

MACRO mAddSheet(hGrid)
' add a new tab/sheet to grid
  SendMessage(hGrid, %MLG_ADDSHEET, 0,0)
END MACRO
'
FUNCTION funCountSheets(hGrid AS DWORD) AS LONG
' return the number of sheets/tabs on this grid
  FUNCTION = SendMessage(hGrid, %MLG_GETSHEETINFO, _
                         %MLG_SHEET_GETTOT , 0)
'
END FUNCTION
'
FUNCTION funLockCell(hGrid AS DWORD, _
                     lngRow AS LONG, _
                     lngColumn AS LONG) AS LONG
' lock the cell in the grid to prevent updates
  SendMessage hGrid ,%MLG_SETFORMATOVERRIDEEX,MAKLNG(lngRow,lngColumn), _
              MAKLNG(%MLG_TYPE_WRITELOCK, %MLG_LOCK )
END FUNCTION
'
FUNCTION funUnLockCell(hGrid AS DWORD, _
                       lngRow AS LONG, _
                       lngColumn AS LONG) AS LONG
' Unlock the cell in the grid to allow updates
  SendMessage hGrid ,%MLG_SETFORMATOVERRIDEEX,MAKLNG(lngRow,lngColumn), _
              MAKLNG(%MLG_TYPE_WRITELOCK, %MLG_NOLOCK )
END FUNCTION
'
FUNCTION funMarkGridasReadOnly(hGrid AS DWORD) AS LONG
  LOCAL lngRow AS LONG
  LOCAL lngColumn AS LONG
  LOCAL lngRows AS LONG
  LOCAL lngColumns AS LONG
  '
  lngColumns = funGetColumnsInGrid(hGrid)
  lngRows = funGetRowsInGrid(hGrid)
  '
  FOR lngRow = 1 TO lngRows
    FOR lngColumn = 1 TO lngColumns
      SendMessage hGrid ,%MLG_SETFORMATOVERRIDEEX,MAKLNG(lngRow,lngColumn), _
                  MAKLNG(%MLG_TYPE_WRITELOCK, %MLG_LOCK )
    NEXT lngColumn
  NEXT lngRow
  '
  funGridRefresh(hGrid)
  FUNCTION = %TRUE
  '
END FUNCTION
'
FUNCTION funMarkGridCellWithColour(hGrid AS DWORD, _
                                   lngRow AS LONG, _
                                   lngColumn AS LONG, _
                                   lngColour AS LONG) AS LONG
' mark the cell with selected colour
  SendMessage hGrid ,%MLG_SETFORMATOVERRIDEEX,MAKLNG(lngRow,lngColumn), _
                     MAKLNG(%MLG_TYPE_BKGCOLOR, lngColour)
'
END FUNCTION
'
FUNCTION funSetColumnNames(hGrid AS DWORD, _
                           strColumnNames AS STRING) AS LONG
' set the column names
  LOCAL lngColumn AS LONG
  LOCAL lngMaxColumns AS LONG
  '
  lngMaxColumns = funGetColumnsInGrid(hGrid)
  '
  FOR lngColumn = 1 TO lngMaxColumns
    MLG_PUT(hGrid,0,lngColumn,PARSE$(strColumnNames,",",lngColumn),0)
  NEXT lngColumn
  '
END FUNCTION
'
FUNCTION funHideAcolumn(hGrid AS DWORD, _
                        lngColumn AS LONG) AS LONG
' make a column invisible to the user
  LOCAL lngColumns AS LONG
  '
  lngColumns = funGetColumnsInGrid(hGrid)
  IF lngColumn <= lngColumns AND lngColumn > 0 THEN
    SendMessage hGrid ,%MLG_HIDECOLUMN, %MLG_HIDECOL, lngColumn
  END IF
  '
END FUNCTION
'
FUNCTION funGetGridTextToArray(hGrid AS DWORD, _
                               BYREF a_strData() AS STRING) AS LONG
' return the data in the current grid in an array
  LOCAL lngRows AS LONG
  LOCAL lngColumns AS LONG

  ' determine the size of the grid
  lngRows = funGetRowsInGrid(hGrid)
  lngColumns = funGetColumnsInGrid(hGrid)
  '
  IF lngRows > 0 AND lngColumns > 0 THEN
  ' now prep an array to hold the data
    DIM a_strData(lngRows,lngColumns) AS STRING
    MLG_GetEx (hGrid ,a_strData() )
    '
    FUNCTION = %TRUE
  ELSE
    FUNCTION = %FALSE
  END IF
  '
END FUNCTION
'
FUNCTION funGetColumnName(hGrid AS DWORD, _
                          lngColumn AS LONG) AS STRING
' return the name of the grid column as it appears
' in the header line of the grid
  IF funGetColumnsInGrid(hGrid) < lngColumn THEN
    FUNCTION = ""
  ELSE
    FUNCTION = MLG_GET(hGrid,0,lngColumn)
  END IF
'
END FUNCTION
'
FUNCTION funGetColumnNumber(hGrid AS DWORD, _
                            strColumnName AS STRING) AS LONG
' given the column name return the column number
' if column not found then return zero (0)
'
  LOCAL lngColumns AS LONG
  LOCAL lngColumn AS LONG
  LOCAL lngFound AS LONG
  '
  lngColumns = funGetColumnsInGrid(hGrid)
  FOR lngColumn = 1 TO lngColumns
    IF UCASE$(MLG_GET(hGrid,0,lngColumn)) = UCASE$(strColumnName) THEN
      lngFound = lngColumn
      EXIT FOR
    END IF
  NEXT lngColumn
  '
  FUNCTION = lngFound
  '
END FUNCTION
'
FUNCTION funFormatColumn(hGrid AS DWORD, _
                         lngColumn AS LONG, _
                         strAlingment AS STRING, _
                         lngColour AS LONG, _
                         strLocking AS STRING, _
                         OPTIONAL lngCheck AS LONG) AS LONG
' format a column number
  LOCAL lngColumns AS LONG
  LOCAL lngAlignment AS LONG
  LOCAL lngLockState AS LONG
  LOCAL lngSetCheck AS LONG
  '
  IF ISFALSE ISMISSING(lngCheck) THEN
    lngSetCheck = lngCheck
  END IF
  '
  lngColumns = funGetColumnsInGrid(hGrid)
  '
  IF lngColumn <= lngColumns AND lngColumn > 0 THEN
  ' column is in range
    SELECT CASE UCASE$(strAlingment)
      CASE "LEFT"
      ' left align
        lngAlignment = %MLG_JUST_LEFT
      CASE "RIGHT"
      ' right align
        lngAlignment = %MLG_JUST_RIGHT
      CASE "CENTER"
      ' center the text in column
        lngAlignment = %MLG_JUST_CENTER
      CASE "WORDWRAP"
      ' word wrap the text
        lngAlignment = %MLG_JUST_WORDWRAP
      CASE ELSE
        lngAlignment = %MLG_NULL
    END SELECT
    '
    SELECT CASE UCASE$(strLocking)
      CASE "LOCK"
        lngLockState = %MLG_LOCK
      CASE ELSE
      ' default to unlocked
        lngLockState = %MLG_NOLOCK
    END SELECT
    '
    MLG_FormatColNumber(hGrid,lngColumn,%MLG_NULL, _
                        lngAlignment,lngColour ,lngLockState)
                        '
    IF ISTRUE lngSetCheck THEN
    ' set column as checkbox
      MLG_FormatColCheck hGrid,lngColumn
    END IF
  '
  END IF
  '
END FUNCTION
'
FUNCTION funFormatGridDropDown(hGrid AS DWORD, _
                               lngColumn AS LONG,_
                               strList AS STRING) AS LONG
' format a column as a dropdown
  LOCAL RC AS RowColDataType
  LOCAL lngColumns AS LONG
  LOCAL strCombolist AS ASCIIZ * 1024
  ' make the dropdown bigger by adding an option to
  ' the start of the list
  strCombolist = "|7/8," & strList
  '
  lngColumns = funGetColumnsInGrid(hGrid)
  '
  IF lngColumn <= lngColumns AND lngColumn > 0 THEN
  ' column is in range
  ' set the cell type
    RC.CellType = %MLG_TYPE_COMBOSTATIC
    RC.List = VARPTR(strCombolist)
    '
    ' set the format of column
    SendMessage hGrid, %MLG_SETCOLFORMAT,lngColumn ,VARPTR(RC)
  END IF
  '
END FUNCTION
'
MACRO mAddUserButtonToCell(hGrid,lngR,lngColumn)
' add a user button to the column
  SendMessage hGrid ,%MLG_SETFORMATOVERRIDEEX, _
              MAKLNG(lngR,lngColumn), _
              MAKLNG(%MLG_TYPE_CELLTYPE,%MLG_TYPE_USERBUTTON)
END MACRO
'
MACRO mRemoveUserButtonFromCell(hGrid,lngR,lngColumn)
' remove a button from the column
  SendMessage hGrid ,%MLG_SETFORMATOVERRIDEEX, _
              MAKLNG(lngR,lngColumn), _
              MAKLNG(%MLG_TYPE_CELLTYPE,%MLG_TYPE_EDIT)
END MACRO
'
FUNCTION funAddUserButtonToColumn(hGrid AS DWORD, _
                                  lngColumn AS LONG) AS LONG
' add a user button to a column for every row in the grid
  LOCAL lngRows AS LONG
  LOCAL lngRow AS LONG
  '
  lngRows = funGetRowsInGrid(hGrid)
  '
  FOR lngRow = 1 TO lngRows
    mAddUserButtonToCell(hGrid,lngRow,lngColumn)
  NEXT lngRow
  '
END FUNCTION
'
FUNCTION funRemoveUserButtonFromColumn(hGrid AS DWORD, _
                                       lngColumn AS LONG) AS LONG
' remove a user button from a column for every row in the grid
  LOCAL lngRows AS LONG
  LOCAL lngRow AS LONG
  '
  lngRows = funGetRowsInGrid(hGrid)
  '
  FOR lngRow = 1 TO lngRows
    mRemoveUserButtonFromCell(hGrid,lngRow,lngColumn)
  NEXT lngRow
  '
END FUNCTION
'
FUNCTION funAddUserButtonToColumnConditionally(hGrid AS DWORD, _
                                               lngTargetColumn AS LONG, _
                                               lngSourceColumn AS LONG, _
                                               strValue AS STRING) AS LONG
' add a user button to a Target column
' where the source column has a certain value
'
  LOCAL lngRows AS LONG
  LOCAL lngRow AS LONG
  LOCAL strSourceValue AS STRING
  '
  lngRows = funGetRowsInGrid(hGrid)
  FOR lngRow = 1 TO lngRows
  ' get the source value
    strSourceValue = MLG_get(hGrid,lngRow,lngSourceColumn)
    IF UCASE$(strSourceValue) = UCASE$(strValue) THEN
    ' if match found apply the button
      mAddUserButtonToCell(hGrid,lngRow,lngTargetColumn)
    END IF
    '
  NEXT lngR
  '
END FUNCTION
'
FUNCTION funRemoveUserButtonToColumnConditionally(hGrid AS DWORD, _
                                               lngTargetColumn AS LONG, _
                                               lngSourceColumn AS LONG, _
                                               strValue AS STRING) AS LONG
' remove a user button from a Target column
' where the source column has a certain value
'
  LOCAL lngRows AS LONG
  LOCAL lngRow AS LONG
  LOCAL strSourceValue AS STRING
  '
  lngRows = funGetRowsInGrid(hGrid)
  FOR lngRow = 1 TO lngRows
  ' get the source value
    strSourceValue = MLG_get(hGrid,lngRow,lngSourceColumn)
    IF UCASE$(strSourceValue) = UCASE$(strValue) THEN
    ' if match found apply the button
      mRemoveUserButtonFromCell(hGrid,lngRow,lngTargetColumn)
    END IF
    '
  NEXT lngR
  '
END FUNCTION
