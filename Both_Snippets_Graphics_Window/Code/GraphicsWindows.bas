#COMPILE EXE
#DIM ALL
#DEBUG ERROR ON
'
#TOOLS OFF
'
' no need for console if running under Console compiler
#IF %DEF(%PB_CC32)
  #CONSOLE OFF
#ENDIF
'
' include the common display library
#INCLUDE "win32api.inc"
#INCLUDE "GraphicSplashProgress.inc"
#INCLUDE "PB_LoadJPG_as_Bitmap.inc"

'
FUNCTION PBMAIN () AS LONG
' the main PB function that is the first to be executed
  '
  LOCAL hWin AS DWORD        ' handle for the graphics window
  LOCAL dwFont AS DWORD      ' handle for the font
  LOCAL hIcon AS DWORD       ' handle for the icon
  LOCAL hWin2 AS DWORD       ' handle for the second graphics window
  '
  GRAPHIC WINDOW "Sample Graphics window", 50, 50, 800,600 TO hWin
  '
  ' set window to be on top?
  SetWindowPos(hWin, %HWND_TOPMOST, 0, 0, 0, 0, _
               %SWP_NOMOVE OR %SWP_NOSIZE)
  '
  ' set this graphics window as active, with redraw option
  GRAPHIC ATTACH hWin, 0, REDRAW
  '
   ' get the handle of the icon to use
  hIcon = ExtractIcon(GetModuleHandle(""), "Grid.ico", 0)
  ' set the icon on the graphics window
  SendMessage hWin, %WM_SETICON, %ICON_SMALL, hIcon
  '
  FONT NEW "Courier New",18,0,1,0,0 TO dwFont
  GRAPHIC SET FONT dwFont
  '
  GRAPHIC CLEAR %RGB_LIGHTGRAY,0
  '
  GRAPHIC COLOR %BLACK,%RGB_LIGHTGRAY
  GRAPHIC PRINT "Ready now"
  GRAPHIC PRINT "Next line"
  '
  GRAPHIC REDRAW
  '
  ' create a second graphics window
  GRAPHIC WINDOW "Second Graphics window", 150, 700, 700,400 TO hWin2
  ' set window to be on top?
  SetWindowPos(hWin2, %HWND_TOPMOST, 0, 0, 0, 0, _
               %SWP_NOMOVE OR %SWP_NOSIZE)
  '
  GRAPHIC ATTACH hWin2, 0, REDRAW
  GRAPHIC SET FONT dwFont
  GRAPHIC CLEAR %RGB_LIGHTGRAY,0
  '
  GRAPHIC COLOR %BLACK,%RGB_LIGHTGRAY
  GRAPHIC PRINT "More data"
  '
  GRAPHIC REDRAW
  '
  ' reattach to first window and print to it
  GRAPHIC ATTACH hWin, 0, REDRAW
  GRAPHIC PRINT "Yet more data"
  GRAPHIC REDRAW
  '
  ' show a separate progress bar graphics window
  LOCAL hWin3 AS DWORD  ' define a handle for the graphics window
  funOpenGraphicProgress(hWin3,"Sample Graphics Progress",_
                         100,400,"Reporting Progress")
  SetWindowPos(hWin3, %HWND_TOPMOST, 0, 0, 0, 0, _
               %SWP_NOMOVE OR %SWP_NOSIZE)
               '
  funReportProgress()
  '
  GRAPHIC REDRAW
  '
  ' load a JPG file into the graphics window
  LOCAL lng_imgW, lng_imgH AS LONG ' width and height of returned bitmap
  LOCAL hBMP AS DWORD    ' handle of the bitmap
  '
  IF ISTRUE funLoadImageFile(EXE.PATH$ & "Map.jpg", _
                                 lng_imgW, _
                                 lng_imgH, _
                                 hBMP ) THEN
    GRAPHIC ATTACH hWin, 0, REDRAW
    GRAPHIC COPY hBmp,0 TO (100,100)
    GRAPHIC BITMAP END
    GRAPHIC REDRAW
  END IF
  '
  ' wait for graphics window to be closed by user
  DO UNTIL ISFALSE isWindow(hWin)
    SLEEP 1000
  LOOP
  '
END FUNCTION
'
FUNCTION funReportProgress() AS LONG
' report progress to the graphics progress bar
  LOCAL lngValue AS LONG     ' used for the % complete
  LOCAL lngR AS LONG         ' used for a progress loop
  LOCAL strMessage AS STRING ' message to display
  '
  FOR lngR = 1 TO 10
  ' for each 10% of work
    lngValue = lngValue + 10 ' set the percentage done
    '
    IF lngR < 10 THEN
      strMessage = "Still processing - " & _
                    FORMAT$(lngValue) & "%"
    ELSE
      strMessage = "Completed processing - " & _
                    FORMAT$(lngValue) & "%"
    END IF
    '
    ' update the graphics progress
    funUpdateGraphicProgress(strMessage, lngValue)
    SLEEP 500 ' wait 1/2 sec to simulate processing
    '
  NEXT lngR
  SLEEP 500
  ' end this window
  GRAPHIC WINDOW END
  '
END FUNCTION
