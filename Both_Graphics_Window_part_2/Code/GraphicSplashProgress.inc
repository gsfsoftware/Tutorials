' GraphicSplashProgress.inc
'
' index to library
' funCloseGraphicProgress - close a graphics window
' funOpenGraphicProgress - open a graphics window - opt location
' funUpdateGraphicProgress - update the progress bar and msg
'
GLOBAL g_dwProgressFont AS DWORD ' font handle
'
FUNCTION funOpenGraphicProgress(hWin AS DWORD, _
                                strText AS STRING, _
                                OPTIONAL lngX AS LONG, _
                                lngY AS LONG, _
                                strTextBody AS STRING) AS LONG
  ' open a generic graphics progress screen
  LOCAL lngStartX, lngStartY AS LONG
  LOCAL strBodyText AS STRING
  '
  ' determine starting position
  IF ISTRUE ISMISSING(lngX) THEN
    lngStartX = 50
    lngStartY = 50
  ELSE
    lngStartX = lngX
    lngStartY = lngY
  END IF
  '
  IF ISMISSING(strTextBody) THEN
    strBodyText = ""
  ELSE
    strBodyText = strTextBody
  END IF
  '
  FONT NEW "Courier New",18,0,1,0,0 TO g_dwProgressFont
  '
  ' open the graphics progress window
  GRAPHIC WINDOW strText,lngStartX, lngStartY, 530,130 TO hWin
  ' make the window non-closable by user
  GRAPHIC WINDOW STABILIZE hWin
  GRAPHIC ATTACH hWin, 0, REDRAW
  GRAPHIC SET FONT g_dwProgressFont
  '
  GRAPHIC SET POS (1,5)
  GRAPHIC PRINT strBodyText
  '
  GRAPHIC BOX (15,90) - (518,110),20, %BLUE, RGB(191,191,191),0
  GRAPHIC REDRAW
  '
END FUNCTION
'
FUNCTION funCloseGraphicProgress(hWin AS DWORD) AS LONG
' close down the specified graphics window
  GRAPHIC WINDOW END hWin
  FONT END g_dwProgressFont
  '
END FUNCTION
'
FUNCTION funUpdateGraphicProgress(strMessage AS STRING, _
                                  lngValue AS LONG) AS LONG
' advance the progress bar
  LOCAL lngStart AS LONG
  LOCAL lngTop AS LONG
  LOCAL lngPercent AS LONG
  '
  lngTop = 500
  lngStart = 17
  '
  IF lngValue > 100 THEN lngValue = 100
  '
  lngPercent = ((lngTop * lngValue)\100) + lngStart - 1
  GRAPHIC BOX (lngStart,92) - (lngPercent,108),0,%BLACK,%RED,0
  GRAPHIC SET POS (15,30)
  GRAPHIC PRINT strMessage
  GRAPHIC REDRAW
  '
END FUNCTION
