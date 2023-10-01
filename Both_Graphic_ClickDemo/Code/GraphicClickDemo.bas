#COMPILE EXE
#DIM ALL
#DEBUG ERROR ON
'
#TOOLS OFF
'
' include the common display library
#INCLUDE "win32api.inc"
#INCLUDE "CommonDisplay.inc"
'
FUNCTION PBMAIN () AS LONG
' the main PB function that is the first to be executed
  funPrepOutput("Mouse click demo",0,0,40,120)
  '
  funLog("Mouse click demo")
  '
  LOCAL hWin AS DWORD        ' handle of the graphics window
  LOCAL dwFont AS DWORD      ' handle of the font used
  LOCAL strBmpName AS STRING ' name of the bitmap to load
  LOCAL lngWidth AS LONG     ' width of bitmap
  LOCAL lngHeight AS LONG    ' height of bitmap
  LOCAL lngFile AS LONG      ' handle for bitmap file
  LOCAL lngXGraphic AS LONG  ' X & Y co-ordinates of
  LOCAL lngYGraphic AS LONG  ' button on graphics window
  LOCAL lngClick AS LONG     ' 1 for one click, 2 for double click
  LOCAL lngX , lngY AS LONG  ' X & Y co-ordinates of the mouse click
  LOCAL lngLinewidth AS LONG ' width of a line

  '
  GRAPHIC WINDOW "Mouse click", 550, 50, 1200,900 TO hWin
  GRAPHIC ATTACH hWin, 0, REDRAW
  FONT NEW "Courier New",24,0,1,0,0 TO dwFont
  GRAPHIC SET FONT dwFont
  GRAPHIC CLEAR %RGB_LIGHTGRAY,0
  GRAPHIC PRINT "Click button when ready"
  GRAPHIC REDRAW
  '
  strBmpName = EXE.PATH$ & "ClickMe.bmp"
  '
  lngFile = FREEFILE
  OPEN strBmpName FOR BINARY AS lngFile
  GET #lngFile, 19, lngWidth
  GET #lngFile, 23, lngHeight
  CLOSE #lngFile
  '
  ' set the position of the 'button'
  lngXGraphic = 100
  lngYGraphic = 100
  lngLinewidth = 2
  '
  GRAPHIC RENDER BITMAP strBmpName, (lngXGraphic, lngYGraphic)- _
                                    (lngXGraphic + lngWidth, _
                                     lngYGraphic + lngHeight)
  GRAPHIC REDRAW
  '
  DO
  ' loop to capture mouse clicks
    SLEEP 100
    IF ISFALSE isWindow(hWin) THEN
    ' graphics window has been closed
      EXIT DO
    ELSE
    ' graphics window is still open
      GRAPHIC WINDOW CLICK hWin TO lngClick, lngX, lngY
      '
      IF lngClick > 0 THEN
      ' window has been clicked
        funLog "X = " & FORMAT$(lngX) & "  Y = " & FORMAT$(lngY)
        '
        IF lngX >= lngXGraphic AND lngX <= lngXGraphic + lngWidth AND _
           lngY >= lngYGraphic AND lngY <= lngYGraphic + lngHeight THEN
        ' button has been clicked
          funLog("button click")
          '
          ' simulate a button push
          GRAPHIC WIDTH lngLinewidth
          GRAPHIC LINE (lngXGraphic, lngYGraphic) - _
                       (lngXGraphic + lngWidth, lngYGraphic) _
                        , %RGB_DIMGRAY
                        '
          GRAPHIC LINE (lngXGraphic, lngYGraphic) - _
                       (lngXGraphic , lngYGraphic +lngHeight) _
                       , %RGB_DIMGRAY
                       '
          ' draw the button
          GRAPHIC RENDER BITMAP strBmpName, (lngXGraphic + 2, _
                                             lngYGraphic + 2)- _
                                    (lngXGraphic + lngWidth -2, _
                                     lngYGraphic + lngHeight -2)
                     '
          GRAPHIC REDRAW  ' display to the user
          ' wait 100ms then redraw button
          SLEEP 100
          ' re-render the original button bitmap
          GRAPHIC RENDER BITMAP strBmpName, (lngXGraphic -2 , _
                                             lngYGraphic -2)- _
                                    (lngXGraphic + lngWidth , _
                                     lngYGraphic + lngHeight )
          GRAPHIC REDRAW  ' display to the user
          lngClick = 0
         '
        END IF
        '

        '
      '
      END IF
    '
    END IF
  '
  LOOP
  '
  funWait()
  '
END FUNCTION
'
