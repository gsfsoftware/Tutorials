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
GLOBAL g_hGWin AS DWORD       ' handle of the graphics window
GLOBAL g_hGWChild AS DWORD    ' handle of the graphics window child
GLOBAL pOldCBProc AS DWORD      ' handle of the callback
GLOBAL pOldChildGWProc AS DWORD ' handle of the child callback
'
'
GLOBAL g_lngXGraphic AS LONG  ' X & Y co-ordinates of
GLOBAL g_lngYGraphic AS LONG  ' button on graphics window
GLOBAL g_lngWidth AS LONG     ' width of bitmap
GLOBAL g_lngHeight AS LONG    ' height of bitmap
GLOBAL g_lngLinewidth AS LONG ' width of a line
GLOBAL g_strBmpName AS STRING ' name of the bitmap to load
'
$BigButtonUp = "ButtonUP.bmp"      ' bitmaps for large
$BigButtonDown = "ButtonDOWN.bmp"  ' circular button
'
TYPE ButtonData
  lngX AS LONG      ' position on Graphics Window
  lngY AS LONG
  lngWidth AS LONG  ' width of bmp
  lngHeight AS LONG ' height of bmp
  strName AS STRING * 100 ' name/path to button file
  lngCircle AS LONG ' %TRUE is button is a circle
END TYPE
'
GLOBAL g_aUButtons() AS ButtonData
'
FUNCTION PBMAIN () AS LONG
' the main PB function that is the first to be executed
  funPrepOutput("Mouse click demo",0,0,40,120)
  '
  funLog("Mouse click demo")
  '
  LOCAL dwFont AS DWORD      ' handle of the font used
  LOCAL lngFile AS LONG      ' handle for bitmap file
  REDIM g_aUButtons(2) AS ButtonData   ' array for data
  LOCAL lngI AS LONG         ' index to array
  '
  GRAPHIC WINDOW "Mouse click", 550, 50, 1200,900 TO g_hGWin
  GRAPHIC ATTACH g_hGWin, 0, REDRAW
  FONT NEW "Courier New",24,0,1,0,0 TO dwFont
  GRAPHIC SET FONT dwFont
  GRAPHIC CLEAR %RGB_LIGHTGRAY,0
  GRAPHIC PRINT "Click button when ready"
  GRAPHIC REDRAW
  '
  ' Start Subclassing
  ' subclass GW window  to intercept close
  pOldCBProc      = SetWindowLong(g_hGWin, %GWL_WNDPROC, _
                                  CODEPTR(MainGWSubProc))
  ' find the graphic control child window handle
  g_hGWChild      = GetWindow (g_hGWin, %GW_CHILD)
  ' subclass graphic control child window for process the mouse and keys
  pOldChildGWProc = SetWindowLong(g_hGWChild, %GWL_WNDPROC, _
                                  CODEPTR(ChildGWSubProc))
  '
  g_strBmpName = EXE.PATH$ & "ClickMe.bmp"
  '
  lngFile = FREEFILE
  OPEN g_strBmpName FOR BINARY AS lngFile
  GET #lngFile, 19, g_lngWidth
  GET #lngFile, 23, g_lngHeight
  CLOSE #lngFile
  '
  ' set the position of the 'button'
  g_lngXGraphic = 100
  g_lngYGraphic = 100
  g_lngLinewidth = 2
  '
  GRAPHIC RENDER BITMAP g_strBmpName, (g_lngXGraphic, g_lngYGraphic)- _
                                      (g_lngXGraphic + g_lngWidth, _
                                       g_lngYGraphic + g_lngHeight)
                                      '
 ' prep for buttons
  ' prep up button
  lngI = 1
  PREFIX "g_aUButtons(lngI)."
    lngX = 300
    lngY = 100
    lngWidth = 0
    lngHeight = 0
    strName = $BigButtonUp
    lngCircle = %TRUE
  END PREFIX
  '
  funRenderButton(lngI)
  '
  ' prep down button
  lngI = 2
  PREFIX "g_aUButtons(lngI)."
    lngX = 300
    lngY = 100
    lngWidth = g_aUButtons(1).lngWidth
    lngHeight = g_aUButtons(1).lngHeight
    strName = $BigButtonDown
    lngCircle = %TRUE
  END PREFIX
  '
  GRAPHIC REDRAW
  '
  ' keep the console window and app alive
  DO
    SLEEP 100
  LOOP WHILE isWindow(g_hGWin)
  '
  FONT END dwFont
  '
END FUNCTION
'
FUNCTION funRenderButton(lngI AS LONG) AS LONG
' render a button on screen
' where lngI points to the data in the global array
  LOCAL lngFile AS LONG      ' file handle
  LOCAL strName AS STRING    ' name of bitmap
  LOCAL lngWidth AS LONG     ' width of bitmap
  LOCAL lngHeight AS LONG    ' height of bitmap
  '
  strName = TRIM$(g_aUButtons(lngI).strName)
  IF g_aUButtons(lngI).lngWidth = 0 THEN
  ' not yet rendered - get the width and height
    '
    lngFile = FREEFILE
    OPEN strName FOR BINARY AS lngFile
    GET #lngFile, 19, lngWidth
    GET #lngFile, 23, lngHeight
    CLOSE #lngFile
    '
    g_aUButtons(lngI).lngWidth   = lngWidth
    g_aUButtons(lngI).lngHeight  = lngHeight
    '
  END IF
  '
  ' render the bitmap to the graphics window
  GRAPHIC RENDER BITMAP strName, (g_aUButtons(lngI).lngX, _
                                  g_aUButtons(lngI).lngY)- _
                                 (g_aUButtons(lngI).lngX + _
                                  g_aUButtons(lngI).lngWidth, _
                                  g_aUButtons(lngI).lngY + _
                                  g_aUButtons(lngI).lngHeight)
'
END FUNCTION
'
FUNCTION MainGWSubProc (BYVAL hWnd AS DWORD, _
                        BYVAL Msg AS LONG, _
                        BYVAL wParam AS LONG, _
                        BYVAL lPARAM AS LONG) AS LONG
                        '
  SELECT CASE AS LONG Msg    'Select Case with AS LONG clause works faster
    CASE %WM_DESTROY
      IF g_hGWin <> 0 THEN
      ' going to shut it all down
        IF g_hGWChild <> 0 THEN
          ' is the child still subclassed
          ' undo subclassing
          SetWindowLong g_hGWChild, %GWL_WNDPROC, pOldChildGWProc
          ' no longer need to track the handle separatedly
          g_hGWChild = 0
        END IF
        ' un-subclass the main GW
        SetWindowLong hWnd, %GWL_WNDPROC, pOldCBProc
        '
        GRAPHIC ATTACH g_hGWin,0
        GRAPHIC WINDOW END
        g_hGWin = 0     ' signal window is closed to
                        ' exit program loop, if running
      END IF
      '
  END SELECT
  '
  ' pass all other messages back to the original processor
  FUNCTION = CallWindowProc(pOldCBProc, hWnd, Msg, wParam, lParam)
  '
END FUNCTION
'
FUNCTION ChildGWSubProc(BYVAL hWnd AS DWORD, _
                        BYVAL wMsg AS DWORD, _
                        BYVAL wParam AS DWORD, _
                        BYVAL lParam AS LONG) AS LONG
  LOCAL p AS POINTAPI
  '
  LOCAL lngMx,lngMy AS LONG    ' Mouse x and y
  LOCAL lb,rb AS LONG    ' Left and right mouse button
  LOCAL mm,mk AS LONG    ' Detect mouse movements and key presses
  LOCAL bg,fg AS LONG    ' Background and foreground colors
  LOCAL wm,mb AS LONG    ' Wheel mouse and middle button
  LOCAL mw    AS LONG    ' Wheel mouse detected
  '
  SELECT CASE wMsg
    CASE %WM_MOUSEMOVE
      ' Current Mouse X and Y Position in the graphic window
      mm=1
      lngMx=LO(WORD,lParam): lngMy=HI(WORD,lParam)
      '
    CASE %WM_LBUTTONDOWN
      ' left button pressed
      mk=1
      lb=1
      lngMx=LO(WORD,lParam): lngMy=HI(WORD,lParam)
      '
      funLog "Left button X = " & FORMAT$(lngMx) & _
                       "  Y = " & FORMAT$(lngMy)
                       '
      IF ISTRUE funIsButtonClick(lngMx,lngMy) THEN
      ' has square button been clicked?
        funLog "Button Click"
      ELSE
      ' has another button been clicked
        IF ISTRUE funIsNewButtonClick(lngMx,lngMy) THEN
          funLog "Round button Click"
        END IF
      END IF
      '
      FUNCTION = 0
      EXIT FUNCTION
      '
    CASE %WM_RBUTTONDOWN
      ' Right button pressed
      mk=1
      rb=1
      '
      lngMx=LO(WORD,lParam): lngMy=HI(WORD,lParam)
      funLog "right button X = " & FORMAT$(lngMx) & _
                        "  Y = " & FORMAT$(lngMy)
      '
      FUNCTION=0:
      EXIT FUNCTION
      '
    CASE %WM_MBUTTONDOWN
    ' Middle button pressed
      mk=1
      mb=1
      '
      lngMx=LO(WORD,lParam): lngMy=HI(WORD,lParam)
      funLog "middle button X = " & FORMAT$(lngMx) & _
                         "  Y = " & FORMAT$(lngMy)
      '
      FUNCTION=0
      EXIT FUNCTION
      '
    CASE %WM_MOUSEWHEEL
      ' Wheel turned (+)=up (-)=down
      mw=1
      wm=HI(WORD,wParam)
      IF wm>32768 THEN
        wm=-1
        funLog "Wheel down"
      ELSE
        wm=1 ' Wheel turned (+)=up (-)=down
        funLog "Wheel up"
      END IF
      FUNCTION=0
      EXIT FUNCTION
  END SELECT
  '
  FUNCTION = CallWindowProc(pOldChildGWProc, hWnd, wMsg, wParam, lParam)
  '
END FUNCTION
'
FUNCTION funIsNewButtonClick(lngX AS LONG, _
                             lngY AS LONG) AS LONG
' has a new button been clicked?
  LOCAL lngI AS LONG ' index to array
  lngI = 2 ' for DOWN button
  LOCAL lngBx, lngBy AS LONG  ' X & Y values
  LOCAL lngBw, lngBh AS LONG  ' Width and Height
  LOCAL lngCx, lngCy AS LONG  ' centre of image
  LOCAL lngCircle AS LONG     ' %TRUE is button is a circle
  LOCAL lngClickZone AS LONG  ' %TRUE if button clicked on
  LOCAL lngDistance AS LONG   ' distance from click to
                              ' centre of image
  '
  lngBx = g_aUButtons(lngI).lngX  ' top left corner of image
  lngBy = g_aUButtons(lngI).lngY  '
  lngBw = g_aUButtons(lngI).lngWidth  ' width of image
  lngBh = g_aUButtons(lngI).lngHeight ' height of image
  lngCircle = g_aUButtons(lngI).lngCircle ' %TRUE/%FALSE
  lngCx = lngBx + (lngBw / 2)   ' work out centre of image
  lngCy = lngBy + (lngBh / 2)
  '
  IF ISTRUE lngCircle THEN
  ' circle style button
    ' work out distance to centre from click
    lngDistance = SQR((lngX - lngCx)^2 + _
                      (lngY - lngCy)^2)
    IF lngDistance <= (lngBw / 2) THEN
    ' click is inside the circle
      lngClickZone = %TRUE
      FUNCTION = %TRUE
    END IF
  ELSE
  ' non circle button
    IF lngX >= lngBx AND _
      lngX <= lngBx + lngBw AND _
      lngY >= lngBy AND _
      lngY <= lngBy + lngBh THEN
      ' button has been clicked
      lngClickZone = %TRUE
      FUNCTION = %TRUE
    END IF
  END IF
  '
  IF ISTRUE lngClickZone THEN
    GRAPHIC ATTACH g_hGWin, 0, REDRAW
    ' simulate a button push
    ' draw the button
    funRenderButton(lngI)
    GRAPHIC REDRAW  ' display to the user
    ' wait 200ms then redraw button
    SLEEP 200
    ' re-render the original button bitmap
    lngI = 1 ' for UP button
    funRenderButton(lngI)
    GRAPHIC REDRAW  ' display to the user
  END IF
  '
END FUNCTION
'
FUNCTION funIsButtonClick(lngX AS LONG, _
                          lngY AS LONG) AS LONG
' has button been clicked?
  IF lngX >= g_lngXGraphic AND _
     lngX <= g_lngXGraphic + g_lngWidth AND _
     lngY >= g_lngYGraphic AND _
     lngY <= g_lngYGraphic + g_lngHeight THEN
  ' button has been clicked
    FUNCTION = %TRUE
    '
    GRAPHIC ATTACH g_hGWin, 0, REDRAW
    ' simulate a button push
    GRAPHIC WIDTH g_lngLinewidth
    GRAPHIC LINE (g_lngXGraphic, g_lngYGraphic) - _
                 (g_lngXGraphic + g_lngWidth, g_lngYGraphic) _
                 , %RGB_DIMGRAY
                 '
    GRAPHIC LINE (g_lngXGraphic, g_lngYGraphic) - _
                 (g_lngXGraphic , g_lngYGraphic + g_lngHeight) _
                 , %RGB_DIMGRAY
                 '
    ' draw the button
    GRAPHIC RENDER BITMAP g_strBmpName, (g_lngXGraphic + 2, _
                                         g_lngYGraphic + 2)- _
                                        (g_lngXGraphic + g_lngWidth -2, _
                                         g_lngYGraphic + g_lngHeight -2)
    '
    GRAPHIC REDRAW  ' display to the user
    '
    ' wait 100ms then redraw button
    SLEEP 100
    ' re-render the original button bitmap
    GRAPHIC RENDER BITMAP g_strBmpName, (g_lngXGraphic -2 , _
                                         g_lngYGraphic -2)- _
                                        (g_lngXGraphic + g_lngWidth , _
                                         g_lngYGraphic + g_lngHeight )
    GRAPHIC REDRAW  ' display to the user
    '
  END IF
  '
END FUNCTION
