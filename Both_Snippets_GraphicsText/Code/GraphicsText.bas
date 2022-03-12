#COMPILE EXE
#DIM ALL
#DEBUG ERROR ON
'
#TOOLS OFF
'
#IF %DEF(%PB_CC32)
  #CONSOLE OFF
#ENDIF

' include the common display library
#INCLUDE "win32api.inc"
#INCLUDE "..\Libraries\PB_FileHandlingRoutines.inc"
'
FUNCTION PBMAIN () AS LONG
' the main PB function that is the first to be executed
  LOCAL hWin AS DWORD        ' handle of the graphics window
  LOCAL dwFont AS DWORD      ' handle of the font used

  LOCAL strInKey AS STRING   ' keyboard input
  '
  GRAPHIC WINDOW "Graphics Text - press any key to exit", _
                  50, 50, 1700,900 TO hWin
  '
  GRAPHIC WINDOW STABILIZE hWin
  GRAPHIC ATTACH hWin, 0, REDRAW
  '
  FONT NEW "Courier New",32,0,1,0,0 TO dwFont
  'GRAPHIC SET FONT dwFont
  GRAPHIC CLEAR %BLACK,0
  GRAPHIC REDRAW
  '
  LOCAL strText AS STRING    ' variable for the text from file
  ' load the file
  strText = funBinaryFileAsString(EXE.PATH$ & "Narration.txt")
  '
  ' display the text on the graphics window
  GRAPHIC COLOR %GREEN,%BLACK
  '
  ' wrap characters
  'GRAPHIC SET WRAP %TRUE
  ' wrap words
  GRAPHIC SET WORDWRAP %TRUE
  ' set virtual window size
  GRAPHIC SET VIRTUAL 1700, 1800, USERSIZE
  '
  ' set the margins
  LOCAL lngLeftMargin AS LONG
  LOCAL lngTopMargin AS LONG
  LOCAL lngRightMargin AS LONG
  LOCAL lngBottomMargin AS LONG
  '
  lngLeftMargin  = 40
  lngRightMargin = 40
  lngTopMargin   = 40
  lngBottomMargin = 0
  '
  GRAPHIC SET CLIP lngLeftMargin, lngTopMargin, _
                   lngRightMargin, lngBottomMargin
                   '
  ' set the position to start at
  GRAPHIC SET POS (0,0)
  '
  ' print title
  LOCAL strTitle AS STRING   ' text for the title
  LOCAL dwFontTitle AS DWORD ' handle for the title font
  LOCAL lngPointSize AS LONG ' initial point size
  lngPointSize = 42
  '
  strTitle = "Adding the RC2014 Pico VGA board to the " & _
             "RC2014 Mini with CP/M board"
             '
  FONT NEW "Times New Roman",lngPointSize,1,1,0,0 TO dwFontTitle
  GRAPHIC SET FONT dwFontTitle
  '
  ' is title font too big?
  ' determine the size of the canvas minus the margins
  LOCAL lngWidth, lngHeight AS LONG
  '
  GRAPHIC GET CANVAS TO lngWidth, lngHeight
  lngWidth = lngWidth - lngLeftMargin - lngRightMargin
  '
  ' work out if the text will fit
  LOCAL strFirstPart AS STRING
  LOCAL strSecondPart AS STRING
  '
  GRAPHIC SPLIT WORD strTitle, lngWidth TO _
                     strFirstPart, strSecondPart
  ' while strSecondPart has text left in it then full text won't fit
  DO WHILE LEN(strSecondPart) > 0
    ' reduce the point size and try again until the text fits
    DECR lngPointSize
    FONT END dwFontTitle
    '
    FONT NEW "Times New Roman",lngPointSize,1,1,0,0 TO dwFontTitle
    GRAPHIC SET FONT dwFontTitle
    GRAPHIC SPLIT WORD strTitle, lngWidth TO _
                       strFirstPart, strSecondPart
  LOOP
  ' print the title
  GRAPHIC PRINT strTitle



  'graphic print strText;
  '
  GRAPHIC SET FONT dwFont
  LOCAL lngR AS LONG
  ' print text on the graphics window
  FOR lngR = 1 TO PARSECOUNT(strText,$CRLF)
    GRAPHIC PRINT PARSE$(strText,$CRLF,lngR)
  NEXT lngR
  '
  ' redraw the graphics window
  GRAPHIC REDRAW
  '
  WHILE LEN(strInkey) = 0
  ' wait for a keypress
    GRAPHIC INKEY$ TO strInKey
    SLEEP 50
  WEND
  '
  ' close down the graphics window
  GRAPHIC WINDOW END
  ' and free up the fonts
  FONT END dwFont
  FONT END dwFontTitle
  '
END FUNCTION
