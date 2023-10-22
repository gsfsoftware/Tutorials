#COMPILE EXE
#DIM ALL
#DEBUG ERROR ON
'
#TOOLS OFF
'
#INCLUDE "win32api.inc"
'
FUNCTION PBMAIN () AS LONG
' the main PB function that is the first to be executed
' make the text green and default background
  CON.COLOR 10,-1   ' amend the foreground colour
  CON.PRINT "Console Sizing"
  ' determine the size of the current console
  LOCAL lngColWidth, lngRowHeight AS LONG
  CON.SCREEN TO lngRowHeight, lngColWidth
  '
  CON.PRINT "Console is " & FORMAT$(lngColWidth) & " characters wide"
  CON.PRINT "and " & FORMAT$(lngRowHeight) & " characters high"
  '
  'sleep 2000
  ' set the width of the console to 100 characters
  lngColWidth = 100
  CON.SCREEN = lngRowHeight, lngColWidth
  ' display the console size
  mConsoleSize
  '
  ' get the console size in pixels
  LOCAL lngXPixels, lngYPixels AS LONG
  CON.SIZE TO lngXPixels, lngYPixels
  '
  CON.PRINT "Console is " & FORMAT$(lngXPixels) & " pixels wide "
  CON.PRINT "and " & FORMAT$(lngYPixels) & " pixels high"
  '
  ' set virtual size of the console
  LOCAL lngVColWidth,lngVRowHeight AS LONG
  lngVColWidth = 100
  lngVRowHeight  = 100
  CONSOLE SET VIRTUAL lngVRowHeight,lngVColWidth
  ' display the virtual console size
  mVirtualConsoleSize
  '
  CON.PRINT "Line 1"
  CON.PRINT "Line 2"
  '
  ' set where to print on the console, in character positions
  LOCAL lngRow, lngColumn AS LONG
  lngRow = 10: lngColumn = 1
  CON.CELL = lngRow, lngColumn
  '
  CON.PRINT "New data"
  '
  lngRow = 9: lngColumn = 1
  CON.CELL = lngRow, lngColumn
  CON.PRINT "Old data";
  '
  lngRow = 9: lngColumn = 10
  CON.CELL = lngRow, lngColumn
  CON.COLOR 5,-1   ' amend the foreground colour
  CON.PRINT "Extra data";

  '
  lngRow = 20: lngColumn = 1
  CON.CELL = lngRow, lngColumn
  CON.COLOR 10,-1
  CON.STDOUT "Press any key to exit"
  WAITKEY$
  '
END FUNCTION
'
MACRO mVirtualConsoleSize()
' display the current console size
  CON.VIRTUAL TO lngVRowHeight, lngVColWidth
  '
  CON.PRINT "Virtual Console is " & FORMAT$(lngVColWidth) & " characters wide"
  CON.PRINT "and " & FORMAT$(lngVRowHeight) & " characters high"
  '
END MACRO
'
MACRO mConsoleSize()
' display the current console size
  CON.SCREEN TO lngRowHeight, lngColWidth
  '
  CON.PRINT "Console is " & FORMAT$(lngColWidth) & " characters wide"
  CON.PRINT "and " & FORMAT$(lngRowHeight) & " characters high"
  '
END MACRO
