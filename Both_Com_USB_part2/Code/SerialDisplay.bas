#COMPILE EXE
#DIM ALL
#DEBUG ERROR ON
'
#TOOLS OFF
'
' include the common display library
#INCLUDE "win32api.inc"
#INCLUDE "..\Libraries\CommonDisplay.inc"
#INCLUDE "..\Libraries\LCD_Display.inc"
'
FUNCTION PBMAIN () AS LONG
' the main PB function that is the first to be executed
  funPrepOutput("COMM USB",0,0,40,120)
  '
  funLog("COMM USB")
  '
  LOCAL hComm   AS LONG
  LOCAL strInput AS STRING
  LOCAL lngCount AS LONG
  '
  strInput = "Odroid006"
  ' first open the Port and get back the hComm handle
  hComm = funLCD_OpenPort("COM4")
  ' set the colour
  IF ISTRUE funLCD_Set_Colour(hComm, $LCD_RED) THEN
    FOR lngCount = 1 TO 5
      ' clear the display
      funLCD_ClearDisplay(hComm)
      ' display information on the display
      funLCD_DisplayInfo(hComm, strInput & $CRLF)
      funLCD_DisplayInfo(hComm, TIME$)
      ' wait a second as this runs in a loop
      SLEEP 1000
    NEXT lngCount
    ' close the port down
    funLCD_ClosePort(hComm)
  END IF
  '
  funWait()
  '
END FUNCTION
'
