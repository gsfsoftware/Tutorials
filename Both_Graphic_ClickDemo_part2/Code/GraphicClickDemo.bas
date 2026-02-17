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
FUNCTION PBMAIN () AS LONG
' the main PB function that is the first to be executed
  funPrepOutput("Mouse click demo",0,0,40,120)
  '
  funLog("Mouse click demo")
  '
  LOCAL dwFont AS DWORD      ' handle of the font used
  LOCAL lngFile AS LONG      ' handle for bitmap file

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
        funLog "Button Click"
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
