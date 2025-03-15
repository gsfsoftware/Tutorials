' LCD display common library

' set up the constants the LCD display will take
$Display_command = CHR$(&HFE)
$Set_Display = $Display_command & CHR$(&HD1)
'
$Display_clear = $Display_command & CHR$(&H58)
$Display_off = $Display_command & CHR$(&H46)
$Display_on = $Display_command & CHR$(&H42)
$Display_autoscroll_on = $Display_command & CHR$(&H51)
$Display_home_on = $Display_command & CHR$(&H48)
$Display_cursor_forward = $Display_command & CHR$(&H4D)
$Display_cursor_back = $Display_command & CHR$(&H4C)
$Display_block_on = $Display_command & CHR$(&H53)
$Display_block_off = $Display_command & CHR$(&H54)
$Display_rgb_red = $Display_command & CHR$(&HD0) & _
                   CHR$(&HFF) & CHR$(&H0) & CHR$(&H0)
$Display_rgb_blue = $Display_command & CHR$(&HD0) & _
                   CHR$(&H0) & CHR$(&H0) & CHR$(&HFF)
$Display_rgb_green = $Display_command & CHR$(&HD0) & _
                   CHR$(&H0) & CHR$(&HFF) & CHR$(&H0)
$Display_rgb_white = $Display_command & CHR$(&HD0) & _
                   CHR$(&HFF) & CHR$(&HFF) & CHR$(&HFF)

$Display_rgb_darkgreen = $Display_command & CHR$(&HD0) & _
                   CHR$(&H0) & CHR$(&H10) & CHR$(&H00)
$Display_rgb_lightblue = $Display_command & CHR$(&HD0) & _
                   CHR$(&H0) & CHR$(&H20) & CHR$(&HF0)
$Display_rgb_yellow = $Display_command & CHR$(&HD0) & _
                   CHR$(&HFF) & CHR$(&H20) & CHR$(&H00)
'
' set the constants used as parameters
$LCD_GREEN = $Display_rgb_green
$LCD_DARKGREEN = $Display_rgb_darkgreen
$LCD_YELLOW = $Display_rgb_yellow
$LCD_BLUE = $Display_rgb_blue
$LCD_LIGHTBLUE = $Display_rgb_lightblue
$LCD_RED = $Display_rgb_red
'
FUNCTION funLCD_OpenPort(strComm AS STRING) AS LONG
' open the com port
  LOCAL hComm AS LONG
  '
  hComm = FREEFILE
  COMM OPEN strComm AS #hComm
  ' ERRCLEAR returns the error code of the most
  ' recent run-time error.
  ' In addition, it resets PowerBASIC's internal
  ' error code variable ERR to zero after you reference it.
  IF ERRCLEAR THEN
    EXIT FUNCTION 'Exit if port cannot be opened
  ELSE
    FUNCTION = hComm
  END IF
  '
END FUNCTION
'
FUNCTION funLCD_ClosePort(hComm AS LONG) AS LONG
' close the port down
  COMM CLOSE #hComm
END FUNCTION
'
FUNCTION funLCD_Set_Brightness(hComm AS LONG, _
                               lngLevel AS LONG) AS LONG
' set the brightness of the display to full
  '
  LOCAL strValue AS STRING
  strValue = $Display_command & CHR$(&H99) & CHR$(lngLevel)
  COMM SEND #hComm,strValue
  SLEEP 10
  '
  IF ERRCLEAR THEN
    EXIT FUNCTION
  ELSE
    FUNCTION = %TRUE
  END IF
  '
END FUNCTION

'
FUNCTION funLCD_SetDisplayAsBig(hComm AS LONG) AS LONG
' set the display to be 4 line 20 column
' n.b. this is saved in eeprom and only needs sent once
' power off display and power back on to activate.
'
  COMM SEND #hComm, $Set_Display & CHR$(20) & CHR$(4)
  SLEEP 10
  '
  IF ERRCLEAR THEN
    EXIT FUNCTION
  ELSE
    FUNCTION = %TRUE
  END IF
  '
END FUNCTION
'
FUNCTION funLCD_Set_Colour(hComm AS LONG, _
                    strColour AS STRING) AS LONG
  ' set the colour of the display
  COMM SEND #hComm, strColour
  SLEEP 10
  '
  IF ERRCLEAR THEN
    EXIT FUNCTION
  ELSE
    FUNCTION = %TRUE
  END IF
  '
END FUNCTION
'
FUNCTION funLCD_SetContrast(hComm AS LONG, _
                            lngLevel AS LONG) AS LONG
  ' set the contrast
  LOCAL strValue AS STRING
  strValue = $Display_command & CHR$(&H50) & CHR$(lngLevel)
  COMM SEND #hComm,strValue
  SLEEP 10
  '
  IF ERRCLEAR THEN
    EXIT FUNCTION
  ELSE
    FUNCTION = %TRUE
  END IF
  '
END FUNCTION
'
FUNCTION funLCD_ClearDisplay(hComm AS LONG) AS LONG
  ' wipe all text from the display
  COMM SEND #hComm,$Display_clear
  SLEEP 10

  '
  IF ERRCLEAR THEN
    EXIT FUNCTION
  ELSE
    FUNCTION = %TRUE
  END IF
END FUNCTION
'
FUNCTION funLCD_DisplayInfo(hComm AS LONG, _
                            strInput AS STRING) AS LONG
  ' display text on the display
  ' put a $CRLF on the end of the text if you want
  ' the next call to this function to display on the next line
  COMM SEND #hComm, strInput
  IF ERRCLEAR THEN
    EXIT FUNCTION
  ELSE
    FUNCTION = %TRUE
  END IF
END FUNCTION
