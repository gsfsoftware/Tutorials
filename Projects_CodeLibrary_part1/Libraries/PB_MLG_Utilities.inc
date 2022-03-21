' PB GridUtils
' grid utilities for MLG
' PB_MLG_Utilities.inc



FUNCTION funFillCellIfEmpty(hGrid AS DWORD,lngRow AS LONG, lngCol AS LONG, strValue AS STRING) AS LONG
  IF MLG_GET(hGrid,lngRow,lngCol) = "" THEN
    MLG_PUT(hGrid,lngRow,lngCol,strValue,1)
  END IF
END FUNCTION

FUNCTION funLockCell(hGrid AS DWORD, lngRow AS LONG, lngColumn AS LONG) AS LONG
' lock the cell in the grid to prevent updates
  SendMessage hGrid ,%MLG_SETFORMATOVERRIDEEX,MAKLNG(lngRow,lngColumn), MAKLNG(%MLG_TYPE_WRITELOCK, %MLG_LOCK )
END FUNCTION
'
FUNCTION funUnLockCell(hGrid AS DWORD, lngRow AS LONG, lngColumn AS LONG) AS LONG
' Unlock the cell in the grid to allow updates
  SendMessage hGrid ,%MLG_SETFORMATOVERRIDEEX,MAKLNG(lngRow,lngColumn), MAKLNG(%MLG_TYPE_WRITELOCK, %MLG_NOLOCK )
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
      SendMessage hGrid ,%MLG_SETFORMATOVERRIDEEX,MAKLNG(lngRow,lngColumn), MAKLNG(%MLG_TYPE_WRITELOCK, %MLG_LOCK )
    NEXT lngColumn
  NEXT lngRow
  '
  funGridRefresh(hGrid)
  FUNCTION = %TRUE
  '
END FUNCTION
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
FUNCTION funFillColumnWithValue(hGrid AS DWORD, lngColumn AS LONG , strValue AS STRING, OPTIONAL lngTab AS LONG) AS LONG
' fill a grid column with same value for a specific column
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
FUNCTION funCountRecordsByMarker(hGrid AS DWORD, lngUnsavedMarker AS LONG) AS LONG
' count the number of records in the grid with the marker specified
' can be used to count unsaved records
  LOCAL lngRows AS LONG
  LOCAL myrow AS LONG
  LOCAL lngCount AS LONG
  LOCAL lngNeedsSaved AS LONG

  lngRows = funGetRowsInGrid(hGrid)
  '
  FOR myrow = 1 TO lngRows
  ' check each row in the grid
    lngNeedsSaved = MLG_GetRowRecNo(hGrid ,myrow)
    IF lngNeedsSaved = lngUnsavedMarker THEN
      INCR lngCount
    END IF
    '
  NEXT myrow
  '
  FUNCTION = lngCount
'
END FUNCTION
'
FUNCTION funWidenColumnsInGrid(hGrid AS DWORD, OPTIONAL lngColumnExclude AS LONG) AS LONG
' widen the columns in the grid to fit the data and headers in them
  LOCAL lngC AS LONG
  LOCAL lngConsiderHeader AS LONG
  LOCAL lngColumns AS LONG
  '
  lngColumns = funGetColumnsInGrid(hGrid)
  '
  lngConsiderHeader = 1
  ' widen the columns
  FOR lngC = 1 TO lngColumns
    IF lngC <> lngColumnExclude  THEN
      MLG_SetColMaxLen(hGrid, lngC,lngConsiderHeader)
    END IF
  NEXT lngC
'
END FUNCTION
'
MACRO funGridRefresh(hGrid)
' refresh the specified grid
  SendMessage(hGrid, %MLG_REFRESH, 1, 0)
'
END MACRO
'
FUNCTION funFillGridWithCheckboxes(hGrid AS DWORD,lngColumn AS LONG) AS LONG
' fill a grid with checkbox columns starting at column lngColumn
  LOCAL lngColumns AS LONG
  LOCAL lngC AS LONG
  '
  lngColumns = funGetColumnsInGrid(hGrid)
  '
  FOR lngC = lngColumn TO lngColumns
     MLG_FormatColCheck hGrid,lngC  ' set column to be checkbox
  NEXT lngC
  '
END FUNCTION
'
FUNCTION funRemoveUserButtonFromCell(hGrid AS DWORD, lngR AS LONG, lngColumn AS LONG) AS LONG
' remove a button from the column
  SendMessage hGrid ,%MLG_SETFORMATOVERRIDEEX ,MAKLNG(lngR,lngColumn),MAKLNG(%MLG_TYPE_CELLTYPE,%MLG_TYPE_EDIT)
  '
END FUNCTION
'
FUNCTION funAddUserButtonToCell(hGrid AS DWORD, lngR AS LONG, lngColumn AS LONG) AS LONG
' add a user button to the column
  SendMessage hGrid ,%MLG_SETFORMATOVERRIDEEX ,MAKLNG(lngR,lngColumn),MAKLNG(%MLG_TYPE_CELLTYPE,%MLG_TYPE_USERBUTTON)
  '
END FUNCTION
'
FUNCTION funCountCheckBoxesTicked(hGrid AS DWORD, lngColumn AS LONG) AS LONG
' return the number of rows that have been ticked in a column
  LOCAL lngRows AS LONG
  LOCAL lngColumns AS LONG
  LOCAL lngR AS LONG
  LOCAL lngCount AS LONG
  '
  lngRows = funGetRowsInGrid(hGrid)
  lngColumns = funGetColumnsInGrid(hGrid)
  '
  IF lngColumn > lngColumns THEN EXIT FUNCTION
  '
  FOR lngR = 1 TO lngRows
    IF ISTRUE MLG_GetChecked(hGrid, lngR, lngColumn) THEN
      INCR lngCount
    END IF
  NEXT lngR
  '
  FUNCTION = lngCount
END FUNCTION
'
FUNCTION funChkBoxToSQL(strValue AS STRING) AS STRING
' turn grid checkbox value into SQL value
  IF strValue = "1" THEN
    FUNCTION = "1"
  ELSE
    FUNCTION = "0"
  END IF
END FUNCTION
'
FUNCTION funGetColumnName(hGrid AS DWORD, lngCol AS LONG) AS STRING
' return the name of the grid column as it appears in the header line of the grid
  IF funGetColumnsInGrid(hGrid) < lngCol THEN
    FUNCTION = ""
  ELSE
    FUNCTION = MLG_GET(hGrid,0,lngCol)
  END IF
'
END FUNCTION
'
FUNCTION funColourBankGridRowCell(hGrid AS DWORD, lngRow AS LONG, lngCol AS LONG) AS LONG
  ' colour bank a specific grid row cell
  LOCAL lngColumns AS LONG
  LOCAL lngRefresh AS LONG
  LOCAL lngC AS LONG
  LOCAL I AS LONG
  LOCAL lngRows AS LONG
  '
  SendMessage hGrid,%MLG_SETBKGNDCELLCOLOR,2, %RGB_HONEYDEW
  ' colour bank the data
  IF (lngRow MOD 2) = 0 THEN
    SendMessage hGrid ,%MLG_SETFORMATOVERRIDEEX,MAKLNG(lngRow,lngCol),MAKLNG(%MLG_TYPE_BKGCOLOR, 0)
  ELSE
    SendMessage hGrid ,%MLG_SETFORMATOVERRIDEEX,MAKLNG(lngRow,lngCol),MAKLNG(%MLG_TYPE_BKGCOLOR, 2)
  END IF
END FUNCTION
'
FUNCTION funColourBankGridRow(hGrid AS DWORD, lngRow AS LONG) AS LONG
' colour bank a specific grid row
  LOCAL lngColumns AS LONG
  LOCAL lngRefresh AS LONG
  LOCAL lngC AS LONG
  LOCAL I AS LONG
  LOCAL lngRows AS LONG
  '
  ' determine the size of the grid
  I= SendMessage(hGrid, %MLG_GETROWCOLTOT, 0, 0)
  lngRows = LO(INTEGER, I)
  lngColumns = HI(INTEGER,I)
  '
  SendMessage hGrid,%MLG_SETBKGNDCELLCOLOR,2, %RGB_HONEYDEW
  ' colour bank the data
  FOR lngC = 1 TO lngColumns
    IF (lngRow MOD 2) = 0 THEN
      SendMessage hGrid ,%MLG_SETFORMATOVERRIDEEX,MAKLNG(lngRow,lngC),MAKLNG(%MLG_TYPE_BKGCOLOR, 0)
    ELSE
      SendMessage hGrid ,%MLG_SETFORMATOVERRIDEEX,MAKLNG(lngRow,lngC),MAKLNG(%MLG_TYPE_BKGCOLOR, 2)
    END IF
  NEXT lngC
  '
END FUNCTION
'
FUNCTION funColourBankGridRowsMask(hGrid AS DWORD) AS LONG
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
  SendMessage hGrid,%MLG_SETBKGNDCELLCOLOR,2, %RGB_HONEYDEW
  SendMessage hGrid,%MLG_SETBKGNDCELLCOLOR,4, %RGB_WHITE

  ' colour bank the data
  FOR lngR = 1 TO lngRows
    FOR lngC = 1 TO lngColumns
      IF (lngR MOD 2) = 0 THEN
        SendMessage hGrid ,%MLG_SETFORMATOVERRIDEEX,MAKLNG(lngR,lngC),MAKLNG(%MLG_TYPE_BKGCOLOR, 2)
      ELSE
        SendMessage hGrid ,%MLG_SETFORMATOVERRIDEEX,MAKLNG(lngR,lngC),MAKLNG(%MLG_TYPE_BKGCOLOR, 4)
      END IF
    NEXT lngC
  NEXT lngR
  '
END FUNCTION
'
FUNCTION funColourBankGridRows(hGrid AS DWORD) AS LONG
' make alternation lines in the grid different colours making the grid easier to read
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
  SendMessage hGrid,%MLG_SETBKGNDCELLCOLOR,2, %RGB_HONEYDEW
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
FUNCTION funMarkGridCellWithColour(hGrid AS DWORD ,lngRow AS LONG, lngColumn AS LONG, lngColour AS LONG) AS LONG
' mark the cell with selected colour
  SendMessage hGrid ,%MLG_SETFORMATOVERRIDEEX,MAKLNG(lngRow,lngColumn),MAKLNG(%MLG_TYPE_BKGCOLOR, lngColour)
'
END FUNCTION
'
FUNCTION funMarkGridCell(hGrid AS DWORD ,lngRow AS LONG, lngColumn AS LONG) AS LONG
' mark the cell as having changed
  LOCAL lngColour AS LONG
  lngColour = %CELLCOLORLIGHTGREEN
  SendMessage hGrid ,%MLG_SETFORMATOVERRIDEEX,MAKLNG(lngRow,lngColumn),MAKLNG(%MLG_TYPE_BKGCOLOR, lngColour)
'
END FUNCTION
'
FUNCTION funMarkWholeGridAsSaved(hGrid AS DWORD) AS LONG
' Mark each row in the grid as being saved
  LOCAL I AS LONG
  LOCAL lngRows AS LONG , lngE AS LONG
  LOCAL lngColumns AS LONG
  LOCAL lngRefresh AS LONG
  '
  ' determine the size of the grid
  I= SendMessage(hGrid, %MLG_GETROWCOLTOT, 0, 0)
  lngRows = LO(INTEGER, I)
  lngColumns = HI(INTEGER,I)
  '
  FOR lngE = 1 TO lngRows
    MLG_SetRowRecNo(hGrid,lngE,%AMR_SAVED)
    funUnMarkGridRow(hGrid,lngE)
  NEXT lngE
'
END FUNCTION
'
FUNCTION funMarkGridRow(hGrid AS DWORD, lngRow AS LONG) AS LONG
' mark an entire row in highlighted green indicating that it needs to be saved
  LOCAL I AS LONG
  LOCAL lngRows AS LONG , lngE AS LONG
  LOCAL lngColumns AS LONG
  LOCAL lngRefresh AS LONG
  LOCAL lngColour AS LONG
  '
  ' determine the size of the grid
  I= SendMessage(hGrid, %MLG_GETROWCOLTOT, 0, 0)
  lngRows = LO(INTEGER, I)
  lngColumns = HI(INTEGER,I)
  '
  lngColour = %CELLCOLORLIGHTGREEN
  '
  FOR lngE = 1 TO lngColumns
    '
    SendMessage hGrid ,%MLG_SETFORMATOVERRIDEEX,MAKLNG(lngRow,lngE),MAKLNG(%MLG_TYPE_BKGCOLOR, lngColour)
    '
  NEXT lngE
  '
END FUNCTION
'
FUNCTION funUnMarkGridCell(hGrid AS DWORD, lngRow AS LONG, lngColumn AS LONG) AS LONG
' unmark the specific grid cell
  '
  IF (lngRow MOD 2) = 0 THEN
    SendMessage hGrid ,%MLG_SETFORMATOVERRIDEEX,MAKLNG(lngRow,lngColumn),MAKLNG(%MLG_TYPE_BKGCOLOR, 2)
  ELSE
    SendMessage hGrid ,%MLG_SETFORMATOVERRIDEEX,MAKLNG(lngRow,lngColumn),MAKLNG(%MLG_TYPE_BKGCOLOR, 0)
  END IF
'
END FUNCTION
'
FUNCTION funMarkGridCellOrange(hGrid AS DWORD, lngRow AS LONG, lngColumn AS LONG) AS LONG
' mark the specific grid cell in orange colour
  '
  SendMessage hGrid ,%MLG_SETFORMATOVERRIDEEX,MAKLNG(lngRow,lngColumn),MAKLNG(%MLG_TYPE_BKGCOLOR, %CELLCOLORORANGE)
  '
END FUNCTION

'
FUNCTION funUnMarkGridRow(hGrid AS DWORD, lngRow AS LONG) AS LONG
  ' remove the rows Green highlighting and return to standard row banding colours
  LOCAL I AS LONG
  LOCAL lngRows AS LONG , lngE AS LONG
  LOCAL lngColumns AS LONG
  LOCAL lngRefresh AS LONG
  '
  ' determine the size of the grid
  I= SendMessage(hGrid, %MLG_GETROWCOLTOT, 0, 0)
  lngRows = LO(INTEGER, I)
  lngColumns = HI(INTEGER,I)
  '
  FOR lngE = 1 TO lngColumns
    IF lngE = lngColumns THEN lngRefresh = 1
    '
    IF (lngRow MOD 2) = 0 THEN
      SendMessage hGrid ,%MLG_SETFORMATOVERRIDEEX,MAKLNG(lngRow,lngE),MAKLNG(%MLG_TYPE_BKGCOLOR, 0)
    ELSE
      SendMessage hGrid ,%MLG_SETFORMATOVERRIDEEX,MAKLNG(lngRow,lngE),MAKLNG(%MLG_TYPE_BKGCOLOR, 2)
    END IF
  NEXT lngE
  '
END FUNCTION
'
FUNCTION funReturnColumnHeaders(hGrid AS DWORD, BYREF a_strData() AS STRING) AS LONG
' return the visible column headers as an array
  LOCAL lngColumns AS LONG
  LOCAL lngC AS LONG
  LOCAL lngCount AS LONG
  LOCAL lngWidth AS LONG
  LOCAL lngOrigColumns AS LONG
  '
  lngOrigColumns = funGetColumnsInGrid(hGrid)
  lngColumns = lngOrigColumns
  '
  FOR lngC = 1 TO lngColumns
    lngWidth = SendMessage(hGrid,%MLG_GETCOLWIDTH,lngC,0)
    IF lngWidth = 0 THEN
      DECR lngColumns
    END IF
  NEXT lngC
  '
  REDIM a_strData(lngColumns)
  '
  FOR lngC = 1 TO lngOrigColumns
    lngWidth = SendMessage(hGrid,%MLG_GETCOLWIDTH,lngC,0)
    IF lngWidth >0 THEN
      INCR lngCount
      a_strData(lngCount) = MLG_GET(hGrid,0,lngC)
    END IF
  NEXT lngC
  '
  FUNCTION = %TRUE
END FUNCTION
'
FUNCTION funBlankGridRow(hGrid AS DWORD, lngRow AS LONG) AS LONG
  ' erase the contents of each cell in a row.
  LOCAL I AS LONG
  LOCAL lngRows AS LONG , lngE AS LONG
  LOCAL lngColumns AS LONG
  LOCAL lngRefresh AS LONG
  '
  ' determine the size of the grid
  I= SendMessage(hGrid, %MLG_GETROWCOLTOT, 0, 0)
  lngRows = LO(INTEGER, I)
  lngColumns = HI(INTEGER,I)
  '
  FOR lngE = 1 TO lngColumns
    IF lngE = lngColumns THEN lngRefresh = 1
    MLG_Put hGrid,lngRow,lngE,"",lngRefresh
    IF (lngRow MOD 2) = 0 THEN
      SendMessage hGrid ,%MLG_SETFORMATOVERRIDEEX,MAKLNG(lngRow,lngE),MAKLNG(%MLG_TYPE_BKGCOLOR, 2)
    ELSE
      SendMessage hGrid ,%MLG_SETFORMATOVERRIDEEX,MAKLNG(lngRow,lngE),MAKLNG(%MLG_TYPE_BKGCOLOR, 0)
    END IF
  NEXT lngE
  '
END FUNCTION
'
FUNCTION funSortGrid(dwGrid AS DWORD, mycol AS LONG, myItem AS LONG) AS LONG
' resort the selected grid in either ascending or descending alphabetical order
  SELECT CASE myItem
    CASE 1
      SendMessage dwGrid, %MLG_SORT, %MLG_ASCEND ,mycol
    CASE 2
      SendMessage dwGrid, %MLG_SORT, %MLG_DESCEND ,mycol
  END SELECT
  ' refresh the grid
  funGridRefresh(dwGrid)
'
END FUNCTION
'
FUNCTION funSetRowHeight(hGrid AS DWORD, lngHeight AS LONG) AS LONG
' set the row height to be lngHeight on all rows except the header row
  LOCAL lngRows AS LONG
  LOCAL lngR AS LONG
  '
  lngRows =  funGetRowsInGrid(hGrid)
  '
  FOR lngR = 1 TO lngRows
    SendMessage hGrid, %MLG_SETROWHEIGHT,lngR,lngHeight
  NEXT lngR
  funGridRefresh(hGrid)
  '
END FUNCTION
'
FUNCTION funSelectRowColumn(hGrid AS DWORD, lngRow AS LONG, lngColumn AS LONG) AS LONG
' set a selected row and column
  LOCAL I AS LONG
  LOCAL myrow AS LONG
  LOCAL myCol AS LONG
  '
  I= SendMessage(hGrid, %MLG_SetSELECTED, lngRow, lngColumn)
  myrow = LO(INTEGER, I)
  mycol = HI(INTEGER,I)
  '
  IF myrow = lngRow AND mycol = lngColumn THEN
    FUNCTION = %TRUE
  ELSE
    FUNCTION = %FALSE
  END IF
  '
END FUNCTION
'
FUNCTION funGetSelectedRowColumn(hGrid AS DWORD, myRow AS LONG, myCol AS LONG) AS LONG
' return the row and column currently selected in the grid
  LOCAL I AS LONG
  '
  I= SendMessage(hGrid, %MLG_GETSELECTED, 0, 0)
  myrow = LO(INTEGER, I)
  mycol = HI(INTEGER,I)
  FUNCTION = I
END FUNCTION
'
FUNCTION funGetSelectedRow(hGrid AS DWORD) AS LONG
' get the selected row
  LOCAL I AS LONG
  LOCAL myrow AS LONG
  LOCAL myCol AS LONG
  '
  I= SendMessage(hGrid, %MLG_GETSELECTED, 0, 0)
  myrow = LO(INTEGER, I)
  mycol = HI(INTEGER,I)
  '
  FUNCTION = myrow
  '
END FUNCTION
'
FUNCTION funCountChanges(hGrid AS DWORD) AS LONG
' count the changed rows in this grid
  LOCAL I AS LONG
  LOCAL lngRows AS LONG
  LOCAL lngColumns AS LONG
  LOCAL strText AS STRING
  LOCAL lngR AS LONG, lngC AS LONG
  LOCAL lngCount AS LONG
  '
  ' determine the size of the grid
  lngRows = funGetRowsInGrid(hGrid)
  '
  FOR lngR = 1 TO lngRows
    IF MLG_GetRowRecNo(hGrid ,lngR) = %AMR_UPDATED THEN
      INCR lngCount
    END IF
  NEXT lngR
  '
  FUNCTION = lngCount
  '
END FUNCTION

'
FUNCTION funUncheckAllCheckboxesOnRow(hGrid AS DWORD,myRow AS LONG) AS LONG
' uncheck all the checkboxes on this row
  LOCAL lngC AS LONG
  LOCAL lngCellType AS LONG
  '
  FOR lngC = 1 TO funGetColumnsInGrid(hGrid)
    lngCellType =  SendMessage(hGrid,%MLG_GETCELLTYPE,myRow,lngC)
    IF lngCellType = 2 THEN
    ' its a checkbox
      MLG_Put(hGrid,myRow,lngC,"",0)  ' set the value to be blank
    END IF
  NEXT lngC

END FUNCTION
'
FUNCTION funUncheckAllOtherCheckboxesOnRow(hGrid AS DWORD,myRow AS LONG,myCol AS LONG) AS LONG
' uncheck all the checkboxes other that the column pointed to my mycol
  LOCAL lngC AS LONG
  LOCAL lngCellType AS LONG
  '
  FOR lngC = 1 TO funGetColumnsInGrid(hGrid)
    IF lngC <> myCol THEN
      lngCellType =  SendMessage(hGrid,%MLG_GETCELLTYPE,myRow,lngC)
      IF lngCellType = 2 THEN
      ' its a checkbox
        MLG_Put(hGrid,myRow,lngC,"",0)  ' set the value to be blank
      END IF
    END IF
  NEXT lngC

END FUNCTION
'
FUNCTION funGetSelectedColumn(hGrid AS DWORD) AS LONG
' get the selected column
  LOCAL I AS LONG
  LOCAL myrow AS LONG
  LOCAL myCol AS LONG
  '
  I= SendMessage(hGrid, %MLG_GETSELECTED, 0, 0)
  myrow = LO(INTEGER, I)
  mycol = HI(INTEGER,I)
  '
  FUNCTION = mycol
  '
END FUNCTION
'
MACRO funGridClear(hGrid)
' refresh the specified grid in a cleared state
  SendMessage(hGrid, %MLG_CLEARGRID, 0, 0)
'
END MACRO
'
FUNCTION funEmptyGrid(hGrid AS DWORD) AS LONG
' empty out the grid, removing rows, leaving just 1 empty row
  LOCAL lngColumns AS LONG
  LOCAL lngRows AS LONG
  '
  lngColumns = funGetColumnsInGrid(hGrid)
  lngRows = 1
  DIM a_strDisplayGrid(lngRows,lngColumns) AS STRING
  MLG_ArrayRedim(hGrid, lngRows , lngColumns , lngRows+10, lngColumns +2)   ' ensure dimensioned rows and columns are bigger
  MLG_PutEx (hGrid,a_strDisplayGrid(),4,0)'
  funGridRefresh(hGrid)
  '
END FUNCTION
'
FUNCTION funGetSelectedTabName(hGrid AS DWORD, o_lngSheetSlot AS LONG) AS STRING
' return the selected tab name
  LOCAL strSheetSlot AS STRING
  LOCAL szBuffer AS ASCIIZ PTR
  '
  o_lngSheetSlot = SendMessage(hGrid, %MLG_GETSHEETINFO, %MLG_SHEET_GETCURRENT , 0)
  strSheetSlot = FORMAT$(o_lngSheetSlot)
  szBuffer = STRPTR(strSheetSlot)
  SendMessage(hGrid, %MLG_GETSHEETINFO,  %MLG_SHEET_GETNAME  , szBuffer)
  FUNCTION = TRIM$(@szBuffer)
  '
END FUNCTION
'
FUNCTION funCountSheets(hGrid AS DWORD) AS LONG
' return the number of sheets on this grid
  FUNCTION = SendMessage(hGrid, %MLG_GETSHEETINFO, %MLG_SHEET_GETTOT , 0)
'
END FUNCTION
'
FUNCTION funGetGridText(hDlg AS DWORD, lngStatus AS LONG, hGrid AS DWORD) AS STRING
' get the text from the specified grid and return it as a tab delimited string
  LOCAL lngRows AS LONG
  LOCAL lngColumns AS LONG
  LOCAL strText AS STRING
  LOCAL lngR AS LONG, lngC AS LONG
  '
  ' determine the size of the grid
  lngRows = funGetRowsInGrid(hGrid)
  lngColumns = funGetColumnsInGrid(hGrid)
  '
  ' now prep an array to hold the data
  DIM a_strWork(lngRows,lngColumns) AS STRING
  MLG_GetEx (hGrid ,a_strWork() )
  '
  strText = ""
  ' now put this into a string block
  FOR lngR = 0 TO lngRows
    FOR lngC = 1 TO lngColumns
      strText = strText & a_strWork(lngR,lngC) & $TAB
    NEXT lngC
    strText = strText & $CRLF
  NEXT lngR
  '
  FUNCTION = strText
  '
END FUNCTION
'
SUB subCopyRowWholeGridToClipBoard(BYVAL hGrid AS LONG)
    LOCAL startblock,endblock AS LONG
    LOCAL totrows,totcols AS LONG
    LOCAL flag,I,x,y,rowlimit,skey AS LONG
    LOCAL mystr AS STRING
    LOCAL stLen AS LONG, hData AS LONG, hGlob AS LONG, mg AS LONG
    LOCAL CopyColHeader AS LONG
    CopyColHeader = 1


    rowlimit = 8000   'Adjust to suit.  This prevents accidently trying to copy 2,000,000,000,000 rows

    SendMessage hGrid ,%MLG_GETROWCOLTOTEX,VARPTR(totrows),VARPTR(totcols)
    'flag = SendMessage (hGrid, %MLG_GETROWCOLALLBLOCKSEL, 0 ,0)
    'IF flag = 1 AND AllowAllRowsCols <> 0 THEN 'The whole grid has been selected - this could be a problem with selecting many NULL rows
       startblock = 1
       endblock = totrows
     ' ELSE   'The whole grid is not selected so check for a row block being selected
     '   SendMessage hGrid ,%MLG_GETROWBLOCKSELEX,VARPTR(startblock),VARPTR(endblock)
   ' END IF

    IF startblock > 0 AND endblock > 0 AND (endblock - startblock) < rowlimit THEN
       'Only copy visible columns
       DIM widths(totcols) AS LONG
       mystr=""
       FOR I = 0 TO totcols
         widths(I)=SendMessage(hGrid,%MLG_GETCOLWIDTH,I,0)
       NEXT I

       IF CopyColHeader > 0 THEN
          FOR x= 0 TO totcols
             IF widths(x) > 0 THEN
                 mystr=mystr & MLG_Get(hGrid,y,x)& $TAB
             END IF
           NEXT x
           mystr=mystr & $CRLF
       END IF
       MOUSEPTR 11 'Hourglass - this needs a progress bar like MS Access
       FOR y = startblock TO endblock
           skey=GetKeyState(%VK_ESCAPE) AND &H8000
           IF skey<>0 THEN EXIT SUB
           FOR x= 0 TO totcols
             IF widths(x) > 0 THEN
                 mystr=mystr & MLG_Get(hGrid,y,x)& $TAB
             END IF
           NEXT x
           mystr=mystr & $CRLF
       NEXT y
       MOUSEPTR 1 'Arrow
    END IF


    stLen = LEN(mystr)
    ' Create a global memory object and copy the data into it
    hData = GlobalAlloc(%GMEM_MOVEABLE OR %GMEM_DDESHARE, stLen + 1)
    hGlob = GlobalLock(hData)
    mg = STRPTR(mystr)
    MoveMemory BYVAL hGlob, BYVAL mg, BYVAL stLen
    GlobalUnlock hData

     ' Open the clipboard
    IF ISFALSE (OpenClipboard(%NULL)) THEN
      GlobalFree hData
      EXIT SUB
    END IF

    ' Paste the data into the clipboard
    EmptyClipboard
    SetClipboardData %CF_TEXT, hData
    CloseClipboard

END SUB
'
FUNCTION funMoveAllRowstoNewGrid(hFromGrid AS DWORD,hToGrid AS DWORD) AS LONG
' copy all rows in grid to another grid
  LOCAL lngR AS LONG
  LOCAL lngTR AS LONG
  LOCAL lngC AS LONG
  LOCAL lngTotalRowsFrom AS LONG
  LOCAL lngTotalRowsTo AS LONG
  LOCAL lngTotalColumns AS LONG
  LOCAL lngNewRows AS LONG
  LOCAL lngRefresh AS LONG
  LOCAL strValue AS STRING
  LOCAL lngResult AS LONG
  LOCAL lngFound AS LONG
  '
  lngTotalRowsFrom = funGetRowsInGrid(hFromGrid)
  lngTotalRowsTo   = funGetRowsInGrid(hToGrid)
  lngTotalColumns = funGetColumnsInGrid(hFromGrid)
  lngNewRows =  lngTotalRowsTo + lngTotalRowsFrom
  '
  FOR lngR = 1 TO lngTotalRowsFrom
    '
    FOR lngC = 1 TO lngTotalColumns
      strValue = MLG_GET(hFromGrid,lngR,lngC)
      IF strValue ="" THEN ITERATE
      '
      SELECT CASE lngC
        CASE 1
        ' find first empty row in hToGrid
          FOR lngTR = 1 TO lngTotalRowsTo
            IF MLG_GET(hToGrid,lngTR,1) = "" THEN
              lngFound = %TRUE
              EXIT FOR
            END IF
          NEXT lngTR
      END SELECT
      '
      ' copy value into the TO grid
      MLG_PUT(hToGrid,lngTR,lngC,strValue,lngRefresh)
      ' and wipe it in the RROM grid
      MLG_PUT(hFromGrid,lngR,lngC,"",lngRefresh)
      '
    NEXT lngC
  NEXT lngR
  '
  funColourBankGridRows(hToGrid)
  funGridRefresh(hToGrid)
  funGridRefresh(hFromGrid)
  '
END FUNCTION
'
FUNCTION funMoveRowToNewGrid(hFromGrid AS DWORD,myrow AS LONG,hToGrid AS DWORD) AS LONG
' move a row from Grid to Another grid
' assumes that both Grids have the same number of columns defined
  LOCAL lngC AS LONG
  LOCAL lngR AS LONG
  LOCAL lngTotalColumns AS LONG
  LOCAL lngTotalRows AS LONG
  LOCAL strValue AS STRING
  LOCAL lngRefresh AS LONG
  LOCAL lngFound AS LONG
  lngRefresh = 0
  '
  lngTotalColumns = funGetColumnsInGrid(hFromGrid)
  lngTotalRows = funGetRowsInGrid(hToGrid)
  '
  ' find first empty row in hToGrid
  FOR lngR = 1 TO lngTotalRows
    IF MLG_GET(hToGrid,lngR,1) = "" THEN
      lngFound = %TRUE
      EXIT FOR
    END IF
  NEXT lngR
  '
  FOR lngC = 1 TO lngTotalColumns
  ' for each column
    strValue = MLG_GET(hFromGrid,myrow, lngC)
    MLG_PUT(hToGrid,lngR,lngC,strValue,lngRefresh)
  NEXT lngC
  '  blank the original row from From grid
  funBlankGridRow(hFromGrid, myrow)
  '
  funGridRefresh(hFromGrid)
  funGridRefresh(hToGrid)
  '
END FUNCTION
'
FUNCTION funCloneEmptyGrid(hGridFrom AS DWORD, hGridTo AS DWORD) AS LONG
' create blank lines but same number of rows in the hGridTo Grid
  LOCAL lngRows AS LONG
  LOCAL lngColumns AS LONG
  '
  lngColumns = funGetColumnsInGrid(hGridFrom)
  lngRows = funGetRowsInGrid(hGridFrom)
  '
  DIM a_strDisplayGrid(lngRows,lngColumns) AS STRING
  MLG_ArrayRedim(hGridTo, lngRows , lngColumns , lngRows+10, lngColumns +2)   ' ensure dimensioned rows and columns are bigger
  MLG_PutEx (hGridTo,a_strDisplayGrid(),4,0)
  '
  funColourBankGridRows(hGridTo)
  funGridRefresh(hGridTo)
  '
END FUNCTION
'
FUNCTION funDeleteRows(hGrid AS DWORD, lngFirstRow AS LONG, lngLastRow AS LONG) AS LONG
' delete a range of rows from the Specified Grid
  LOCAL lngResult AS LONG
  LOCAL lngR AS LONG
  LOCAL lngC AS LONG
  LOCAL lngRows AS LONG
  LOCAL lngColumns AS LONG
  '
  lngRows = funGetRowsInGrid(hGrid)
  lngColumns = funGetColumnsInGrid(hGrid)
  '
  IF lngRows = 1 THEN
  ' only one row in the grid
    FOR lngC = 1 TO lngColumns
      MLG_PUT(hGrid,1,lngC,"",0)
    NEXT lngC
    EXIT FUNCTION
  END IF
  '
  IF lngLastRow > lngRows OR lngFirstRow > lngRows THEN EXIT FUNCTION
  '
  FOR lngR = lngFirstRow TO lngLastRow
    FOR lngC = 1 TO lngColumns
      MLG_PUT(hGrid,lngR,lngC,"",0)
    NEXT lngC
  NEXT lngR
  '
  IF lngLastRow - lngFirstRow = lngRows THEN
  ' always leave one row
    INCR lngFirstRow
  END IF
  '
  lngResult = SendMessage(hGrid, %MLG_DELETEROWS,lngFirstRow,lngLastRow)
  IF lngResult = 0 THEN
    FUNCTION = %TRUE
  ELSE
    FUNCTION = %FALSE
  END IF
  '
END FUNCTION

FUNCTION funInsertRowToTopOfGrid(hGrid AS DWORD) AS LONG
  LOCAL I AS LONG
  LOCAL lngRows AS LONG
  LOCAL lngColumns AS LONG
  '
  ' determine the size of the grid
  lngRows = funGetRowsInGrid(hGrid)
  lngColumns = funGetColumnsInGrid(hGrid)
  '
  IF lngRows = 1 THEN
  ' only one row is it empty?
    IF MLG_Get(hGrid,1,1) = "" THEN
      MLG_ArrayRedim(hGrid, lngRows , lngColumns, lngRows, lngColumns +2)
    ELSE
      INCR lngRows
      SendMessage hGrid, %MLG_INSERTROWBEFORE,1,1
      MLG_ArrayRedim(hGrid, lngRows , lngColumns, lngRows, lngColumns +2)
    END IF
    '
  ELSE
    INCR lngRows
    ' redim grid array
    SendMessage hGrid, %MLG_INSERTROWBEFORE,1,1
    MLG_ArrayRedim(hGrid, lngRows , lngColumns, lngRows, lngColumns +2)
  END IF
  '
  funGridRefresh(hGrid)
  '
END FUNCTION
'
FUNCTION funRenameTab(hGrid AS DWORD, lngTabPos AS LONG, strTabName AS STRING ) AS LONG
' rename a tab of a grid
  LOCAL aTab AS ASCIIZ * 255
  aTab = "  " & strTabName & "  "
  SendMessage hGrid, %MLG_NAMESHEET , lngTabPos,VARPTR(aTab)
  '
END FUNCTION
