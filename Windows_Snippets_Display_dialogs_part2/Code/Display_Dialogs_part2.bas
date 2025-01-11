#COMPILE EXE
#DIM ALL
' display dialogs part 1
'
' create type for font details
TYPE udtFontDetails
  strFontName AS STRING * 100
  lngPointSize AS LONG
  lngStyle AS LONG
  lngColour AS LONG
  lngCharSet AS LONG
END TYPE
'
' create type for storage of custom colours
TYPE udtCustomColours
  lngColor1 AS LONG
  lngColor2 AS LONG
  lngColor3 AS LONG
  lngColor4 AS LONG
  lngColor5 AS LONG
  lngColor6 AS LONG
  lngColor7 AS LONG
  lngColor8 AS LONG
  lngColor9 AS LONG
  lngColor10 AS LONG
  lngColor11 AS LONG
  lngColor12 AS LONG
  lngColor13 AS LONG
  lngColor14 AS LONG
  lngColor15 AS LONG
  lngColor16 AS LONG
END TYPE
'
' global UDT to hold custom colours
GLOBAL g_uCustomColours AS udtCustomColours
'
FUNCTION PBMAIN () AS LONG

' DISPLAY COLOR
  LOCAL lngRGBColourSelected AS LONG
  'lngRGBColourSelected = funDisplay_RGBColour(%HWND_DESKTOP)
  '
  ' call display colour again to ensure custom colours
  ' are displayed from last call
  'lngRGBColourSelected = funDisplay_RGBColour(%HWND_DESKTOP)
  '
  ' DISPLAY FONT
  LOCAL uFontSelected AS udtFontDetails ' udt for what's selected
  '
  PREFIX "uFontSelected."
    strFontName  = "Comic Sans MS"
    lngPointSize = 14   ' 14 point
    lngStyle     = 0    ' normal
  END PREFIX
  '
  funDisplayFont(%HWND_DESKTOP, uFontSelected)
  '
END FUNCTION
'
FUNCTION funDisplay_RGBColour(hDlg AS DWORD) AS LONG
' display color dialog
  LOCAL lngFlags AS LONG            ' holds flag values
  LOCAL lngRGBColourValue AS LONG   ' RGB colour selected
  LOCAL lngFirstColour AS LONG      ' default colour
  '
  LOCAL lngX, lngY AS LONG          ' X & Y co-ords of dialog
  LOCAL hWin AS DWORD               ' window handle
  '
  lngFirstColour = %RGB_BLACK       ' set the default
  '
  'lngFlags = %CC_PREVENTFULLOPEN   ' set flag/s
  lngFlags = %CC_FULLOPEN
  '
  ' display the colour selection dialog
  DISPLAY COLOR hDlg, lngX, lngY, _
                 lngFirstColour, g_uCustomColours, _
                 lngFlags TO lngRGBColourValue
                 '
  IF lngRGBColourValue > 0 THEN
  ' colour has been picked
    '
    ' create a graphics window to display user selection
    GRAPHIC WINDOW NEW "Colour Selected",100,100,250,250 TO hWin
    GRAPHIC ATTACH hWin,0
    GRAPHIC CLEAR lngRGBColourValue
    SLEEP 5000
    GRAPHIC WINDOW END hWin
  END IF
  '
END FUNCTION
'
FUNCTION funDisplayFont(hDlg AS DWORD, _
                        uFontSelected AS udtFontDetails) AS LONG
' display font dialog
  LOCAL lngX, lngY AS LONG              ' X & Y co-ords of dialog
  LOCAL strDefaultFont AS STRING        ' default font
  LOCAL lngDefaultPointSize AS LONG     ' default point size
  LOCAL lngDefaultStyle AS LONG         ' default style
  LOCAL lngDefaultColour AS LONG        ' default colour
  LOCAL lngFlags AS LONG                ' holds flag values
  '
  LOCAL strFontSelected AS STRING       ' font selected by user
  LOCAL lngPointSizeSelected AS LONG    ' point size selected
  LOCAL lngStyleSelected AS LONG        ' style selected
  LOCAL lngRGBColourSelected AS LONG    ' RGB colour selected
  LOCAL lngCharacterSetSelected AS LONG ' Character set selected
  '
  LOCAL hFont AS DWORD                  ' font handle
  LOCAL hWin AS LONG                    ' window handle
  '
  ' set the flags
  lngFlags = %CF_SCREENFONTS OR %CF_FORCEFONTEXIST OR %CF_EFFECTS
  '
 ' set any defaults passed in
  strDefaultFont      = TRIM$(uFontSelected.strFontName)
  lngDefaultPointSize = uFontSelected.lngPointSize
  lngDefaultStyle     = uFontSelected.lngStyle
  '
  DISPLAY FONT hDlg, lngX, lngy, strDefaultFont, lngDefaultPointSize, _
               lngDefaultStyle, lngFlags _
               TO strFontSelected, lngPointSizeSelected, _
               lngStyleSelected , lngRGBColourSelected, _
               lngCharacterSetSelected
               '
  IF strFontSelected <> "" THEN
  ' a font has been selected
  '
    ' store the selections in the UDT to be passed back to
    ' calling routine
    PREFIX "uFontSelected."
      strFontName  = strFontSelected
      lngPointSize = lngPointSizeSelected
      lngStyle     = lngStyleSelected
      lngColour    = lngRGBColourSelected
      lngCharSet   = lngCharacterSetSelected
    END PREFIX
   '
    FONT NEW strFontSelected,lngPointSizeSelected, _
             lngStyleSelected,lngCharacterSetSelected TO hFont
    '
    ' create a graphics window to display user selection
    GRAPHIC WINDOW NEW "Font Selected",100,100,450,250 TO hWin
    GRAPHIC ATTACH hWin,0
    GRAPHIC SET FONT hFont
    '
    IF lngRGBColourSelected > 0 THEN
    ' colour has been selected
      GRAPHIC COLOR lngRGBColourSelected,-1
    END IF
    ' print text to the graphics window
    GRAPHIC PRINT strFontSelected & " font has been selected"
    SLEEP 5000
    GRAPHIC WINDOW END hWin
    ' close off the font
    FONT END hFont
    '
  END IF
  '
END FUNCTION
