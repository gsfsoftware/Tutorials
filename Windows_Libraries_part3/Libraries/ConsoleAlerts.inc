'ConsoleAlerts.inc
'
' Index to functions
' funConsoleMsgWithWait(strText) - print to console and wait for key to be pressed
' funGraphicAlert(strText, OPT lngSecondsWait) - graphic window with timed wait
' funGraphicAlertWithWait(strText) - graphic window wait till user exits


' include the speech API library
#INCLUDE ONCE "..\Libraries\PB_SpeechAPI.inc"

#IF %DEF(%PB_CC32)
' routines exclusively for Console compiler
  FUNCTION funConsoleMsgWithWait(strText AS STRING) AS LONG
  ' this displays strText on the console and waits for user
  ' to press any key
    CON.COLOR 4 , -1
    CON.PRINT strText
    CON.PRINT "Press any key to continue"
    WAITKEY$
    CON.COLOR 10,-1
  END FUNCTION
#ENDIF
'
FUNCTION funGraphicAlert(strText AS STRING, _
                         OPTIONAL lngSecondsWait AS LONG) AS LONG
' display a graphic window with strText
  LOCAL hWin AS DWORD
  LOCAL dwFont1 AS DWORD
  LOCAL lngR AS LONG
  LOCAL lngSecWait AS LONG
  '
  ' check for the seconds wait parameter
  IF ISMISSING(lngSecondsWait) THEN
  ' default to 5 seconds
    lngSecWait = 5000
  ELSE
  ' set the default in milliseconds
    lngSecWait = lngSecondsWait * 1000
  END IF
  '
  ' create a big font
  FONT NEW "Tahoma" ,24, 1, 1, 0, 0 TO dwFont1
  GRAPHIC WINDOW "ALERT !", 300, 300, 640, 200 TO hWin
  GRAPHIC ATTACH hWin, 0
  ' set the font and turn on wordwrap
  GRAPHIC SET FONT dwfont1
  GRAPHIC SET WORDWRAP %TRUE
  ' print each line to the graphics window
  FOR lngR = 1 TO PARSECOUNT(strText, $CRLF)
    GRAPHIC PRINT " " & PARSE$(strText,$CRLF,lngR)
  NEXT lngR
  ' wait until the timeout
  SLEEP lngSecWait  ' show it for x seconds, then end
  ' close graphic window and end the fonts
  GRAPHIC WINDOW END hWin
  FONT END dwfont1
  '
END FUNCTION
'
FUNCTION funGraphicAlertWithWait(strText AS STRING) AS LONG
' display a graphic window with strText
  LOCAL hWin AS DWORD
  LOCAL dwFont1 AS DWORD
  LOCAL dwFont2 AS DWORD
  LOCAL lngR AS LONG
  LOCAL strInkeyVar AS STRING
  LOCAL hDC AS DWORD
  '
  ' create one big and one smaller font
  FONT NEW "Tahoma" ,24, 1, 1, 0, 0 TO dwFont1
  FONT NEW "Tahoma" ,18, 0, 1, 0, 0 TO dwFont2
  '
  GRAPHIC WINDOW "ALERT !", 300, 300, 640, 200 TO hWin
  GRAPHIC ATTACH hWin, 0
  ' set the font and turn on wordwrap
  GRAPHIC SET FONT dwfont1
  GRAPHIC SET WORDWRAP %TRUE
  '
  FOR lngR = 1 TO PARSECOUNT(strText, $CRLF)
    GRAPHIC PRINT " " & PARSE$(strText,$CRLF,lngR)
  NEXT lngR
  '
  GRAPHIC SET FONT dwfont2
  GRAPHIC PRINT " Press any key to exit"
  '
  ' wait for either any key to be pressed or the
  ' user to close the window
  GRAPHIC GET DC TO hDC
  strInkeyVar = GRAPHIC$(INKEY$)
  WHILE strInkeyVar = "" AND hDC <> 0
    SLEEP 100
    strInkeyVar = GRAPHIC$(INKEY$)
    GRAPHIC GET DC TO hDC
  WEND
  '
  ' close graphic window and end the fonts
  GRAPHIC WINDOW END hWin
  FONT END dwfont1
  FONT END dwfont2
  '
END FUNCTION
