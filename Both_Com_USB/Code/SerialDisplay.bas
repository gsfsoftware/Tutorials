#COMPILE EXE
#DIM ALL
#DEBUG ERROR ON
'
#TOOLS OFF
'
' include the common display library
#INCLUDE "win32api.inc"
#INCLUDE "..\Libraries\CommonDisplay.inc"
'
$Display_command = CHR$(&HFE)
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

$Display_rgb_yellow = $Display_command & CHR$(&HD0) & _
                   CHR$(&HFF) & CHR$(&H20) & CHR$(&H00)
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
  strInput = "Odroid004"
  '
  hComm = FREEFILE
  COMM OPEN "COM3" AS #hComm
  IF ERRCLEAR THEN EXIT FUNCTION 'Exit if port cannot be opened
  '
  FOR lngCount = 1 TO 10
    COMM SEND #hComm,$Display_clear
    'comm send #hComm, $Display_autoscroll_on
    'comm send #hComm, $Display_block_on
    COMM SEND #hComm, $Display_rgb_green
    COMM SEND #hComm, strInput & $CRLF
    COMM SEND #hComm, TIME$
    SLEEP 2000
  NEXT lngCount
  COMM CLOSE #hComm
  '
  funWait()
  '
END FUNCTION
'
