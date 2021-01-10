' MLG routines  PB_MLG_Utilities.inc

MACRO funGridClear(hGrid)
' set the specified grid to a cleared state
  SendMessage(hGrid, %MLG_CLEARGRID, 0, 0)
'
END MACRO
'
MACRO funGridRefresh(hGrid)
' refresh the specified grid
  SendMessage(hGrid, %MLG_REFRESH, 1, 0)
'
END MACRO
'
MACRO funSetTabWidth(hGrid,lngWidth)
' set the total width for all tabs
  SendMessage hGrid, %MLG_SHOWSHEETTABS,lngWidth,0
  '
END MACRO
'
FUNCTION funRenameTab(hGrid AS DWORD, lngTabPos AS LONG, _
                      strTabName AS STRING ) AS LONG
' rename a tab of a grid
  LOCAL aTab AS ASCIIZ * 255
  aTab = "  " & strTabName & "  "
  SendMessage hGrid, %MLG_NAMESHEET , lngTabPos,VARPTR(aTab)
  '
END FUNCTION
'
FUNCTION funAddTab(hGrid AS DWORD,strTabName AS STRING, _
                   lngRows AS LONG, lngColumns AS LONG) AS LONG
' add a new tab to the existing grid
' returns the tab number added
  LOCAL aTab AS ASCIIZ * 255
  LOCAL lngTab AS LONG
  aTab = "  " & strTabName & "  "
  lngTab = SendMessage(hGrid, %MLG_ADDSHEET , _
           MAKLNG(lngRows,lngColumns),0)
  SendMessage hGrid, %MLG_NAMESHEET , lngTab,VARPTR(aTab)
  '
  FUNCTION = lngTab
'
END FUNCTION
'
FUNCTION funCountTabs(hGrid AS DWORD) AS LONG
' return the number of tabs/sheets on this grid
  FUNCTION = SendMessage(hGrid, %MLG_GETSHEETINFO, _
             %MLG_SHEET_GETTOT , 0)
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
FUNCTION funFillGridWithCheckboxes(hGrid AS DWORD, _
                                   lngColumn AS LONG) AS LONG
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
FUNCTION funSaveGridToDisk(hGrid AS DWORD, _
                           lngTab AS LONG, _
                           strFile AS STRING) AS LONG
' save the grid to disk
  DIM strGrid() AS STRING
  LOCAL lngRows AS LONG
  LOCAL lngColumns AS LONG
  LOCAL lngR AS LONG
  LOCAL lngC AS LONG
  LOCAL lngFile AS LONG
  '
  lngRows = funGetRowsInGrid(hGrid)
  lngColumns = funGetColumnsInGrid(hGrid)
  REDIM strGrid(lngRows,lngColumns)
  ' now get the grid
  SendMessage hGrid,%MLG_SELECTSHEET, lngTab,0
  MLG_GetEx hGrid,strGrid()
  '
  ' now save it to disk
  lngFile = FREEFILE
  OPEN strFile FOR OUTPUT AS #lngFile
  FOR lngR = 1 TO lngRows
    FOR lngC = 1 TO lngColumns
      PRINT #lngFile ,strGrid(lngR,lngC);"|";
    NEXT lngC
    PRINT #lngFile
  NEXT lngR
  CLOSE #lngFile
  '
END FUNCTION
'
FUNCTION funLoadGridFromDisk(hGrid AS DWORD, _
                           lngTab AS LONG, _
                           strFile AS STRING) AS LONG
' save the grid to disk
  DIM strGrid() AS STRING
  LOCAL lngRows AS LONG
  LOCAL lngColumns AS LONG
  LOCAL lngR AS LONG
  LOCAL lngC AS LONG
  LOCAL lngFile AS LONG
  LOCAL strData AS STRING
  LOCAL lngRefresh AS LONG
  '
  lngRows = funGetRowsInGrid(hGrid)
  lngColumns = funGetColumnsInGrid(hGrid)
  REDIM strGrid(lngRows,lngColumns)
  '
  ' now load it from disk
  lngFile = FREEFILE
  OPEN strFile FOR INPUT AS #lngFile
  FOR lngR = 1 TO lngRows
    LINE INPUT #lngFile, strData
    FOR lngC = 1 TO lngColumns
      strGrid(lngR,lngC) = PARSE$(strData,"|",lngC)
    NEXT lngC
    '
  NEXT lngR
  CLOSE #lngFile
  '
  ' now populate the grid
  SendMessage hGrid,%MLG_SELECTSHEET, lngTab,0
  lngRefresh = 1
  MLG_PutEx hGrid,strGrid(),3, lngRefresh
  '
END FUNCTION
