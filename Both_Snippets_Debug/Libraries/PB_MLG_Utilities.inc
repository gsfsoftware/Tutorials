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
