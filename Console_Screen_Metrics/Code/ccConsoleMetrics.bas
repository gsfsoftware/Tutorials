#COMPILE EXE
#DIM ALL
' turn off the console
#CONSOLE OFF
'
#INCLUDE "win32api.inc"
'
FUNCTION PBMAIN () AS LONG
  LOCAL hWin AS DWORD
  LOCAL strInkeyVar AS STRING
  LOCAL lngWidthVar AS LONG
  LOCAL lngHeightVar AS LONG
  LOCAL lngFont AS LONG
  LOCAL lngWidthVar_client AS LONG
  LOCAL lngHeightVar_client AS LONG
  LOCAL lngX, lngY AS LONG
  '
  FONT NEW "Courier New",18 TO lngFont
  '
  GRAPHIC WINDOW "Graphic Window", 300,300,680,580 TO hWin
  '
  ' set window so it can't be closed by the user
  GRAPHIC WINDOW STABILIZE hWin
  ' all subsequent graphics command go to this window
  GRAPHIC ATTACH hWin,0 , REDRAW
  '
  ' get the window size in pixels
  GRAPHIC GET SIZE TO lngWidthVar, lngHeightVar
  ' get the client area in pixels
  GRAPHIC GET CLIENT TO lngWidthVar_client, lngHeightVar_client
  '
  GRAPHIC SET FONT lngFont
  '
  GRAPHIC PRINT "Monitor Count = " & FORMAT$(funMonitorCount())
  GRAPHIC PRINT
  GRAPHIC PRINT "Window Size"
  GRAPHIC PRINT " X = " & FORMAT$(lngWidthVar)
  GRAPHIC PRINT " Y = " & FORMAT$(lngHeightVar)
  GRAPHIC PRINT
  GRAPHIC PRINT "Client size"
  GRAPHIC PRINT " X = " & FORMAT$(lngWidthVar_client)
  GRAPHIC PRINT " Y = " & FORMAT$(lngHeightVar_client)
  '
  GRAPHIC PRINT
  funGetPrimaryMaximizedSize_PB(lngX, lngY)
  GRAPHIC PRINT "Client area " & " = " & _
                FORMAT$(lngX) & " x " & FORMAT$(lngY)
                '
  ' resize the graphics window to maximize it
  GRAPHIC SET SIZE lngX, lngY
  GRAPHIC SET LOC 0,0
                '
  GRAPHIC REDRAW
  '
  DO
    GRAPHIC INKEY$ TO strInkeyVar
    IF strInkeyVar = $ESC THEN
    ' wait for Escape key to be pressed
      EXIT LOOP
    ELSE
      SLEEP 100
    END IF
    '
  LOOP
  '
  GRAPHIC WINDOW END hWin
  FONT END lngFont
  '
END FUNCTION
'
FUNCTION funGetPrimaryMaximizedSize_PB(lngX AS LONG, _
                                       lngY AS LONG) AS LONG
' get the size when maximized
  lngX = METRICS(MAXIMIZED.X) - METRICS(SCROLL.VERT)
  lngY = METRICS(MAXIMIZED.Y) - METRICS(SCROLL.HORZ)
  '
END FUNCTION
'
FUNCTION funMonitorCount() AS LONG
' determine number of monitors connected to computer
  FUNCTION = GetSystemMetrics(%SM_CMONITORS)
END FUNCTION
'
