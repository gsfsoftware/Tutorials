#COMPILE EXE
#DIM ALL
#DEBUG ERROR ON
'
#TOOLS OFF
'
' include the common display library
#INCLUDE "win32api.inc"
#INCLUDE "CommonDisplay.inc"
#INCLUDE "LCD_Display.inc"
#INCLUDE "DriveInfo.inc"
'
GLOBAL g_hComm AS LONG              ' handle for LCD display
'
FUNCTION PBMAIN () AS LONG
' the main PB function that is the first to be executed
  funPrepOutput("Capacity display",0,0,40,120)
  '
  funLog("Capacity display")
  '
  LOCAL strInput AS STRING        ' input to the LCD display
  LOCAL strComputerName AS STRING ' name of current computer
  LOCAL strDriveSize AS STRING    ' drive size in GB
  LOCAL strDriveSpace AS STRING   ' drive space free in GB
  LOCAL strDrives AS STRING       ' drives to report on
  '
  ' get the computer name
  strComputerName = funPCComputerName
  '
  ' open the LCD display
  g_hComm = funLCD_OpenPort("COM9")
  IF g_hComm = 0 THEN
  ' unable to open port?
  ELSE
   'funLCD_SetDisplayAsBig(g_hComm)
   funLCD_ClearDisplay(g_hComm)
   '
   funLCD_Set_Colour(g_hComm, $LCD_LIGHTBLUE)
   funLCD_Set_Brightness(g_hComm,255)
   funLCD_SetContrast(g_hComm,200)
   '
   strDriveSize = funGetDriveSize()
   ' "C:\  476070; D:\  3669886; E:\  1907726; G:\  953867; "
   strDriveSpace =  funGetDriveSpace()
   '
   strDrives = "C|D|E|F|H|J"
   '
   strInput = funDriveInfo(strDrives,strDriveSize,strDriveSpace)
   '
   funLCD_DisplayInfo(g_hComm, strInput)
   '
   funDisplayAllInfo(strDrives,strDriveSize,strDriveSpace)
   '
   funLCD_ClearDisplay(g_hComm)
   '
   funLCD_DisplayInfo(g_hComm, strInput)
   '
   funLCD_ClosePort(g_hComm)
   '
  END IF
  '
  funWait()
  '
END FUNCTION
'
FUNCTION funDisplayAllInfo(strDrives AS STRING, _
                           strDriveSize AS STRING, _
                           strDriveSpace AS STRING) AS LONG
' display each drive separately
  LOCAL lngR AS LONG
  LOCAL strOutput AS STRING
  LOCAL strDriveLetter AS STRING
  LOCAL strDMDriveSize AS STRING
  LOCAL strDMDriveSpace AS STRING
  LOCAL lngPercentFree AS LONG
  '
  FOR lngR = 1 TO PARSECOUNT(strDrives,"|")
    funLCD_ClearDisplay(g_hComm)
    strDriveLetter = PARSE$(strDrives,"|",lngR)
    strDMDriveSize = PARSE$(strDriveSize,strDriveLetter & ":\",2)
    strDMDriveSize = TRIM$(PARSE$(strDMDriveSize,";",1))
    '
    strDMDriveSpace = PARSE$(strDriveSpace,strDriveLetter & ":\",2)
    strDMDriveSpace = TRIM$(PARSE$(strDMDriveSpace,";",1))
    '
    lngPercentFree =  (VAL(strDMDriveSpace) / VAL(strDMDriveSize)) * 100
    '
    strOutput = "Drive " & strDriveLetter & $CRLF & _
                           strDMDriveSpace & " GB free" & $CRLF & _
                           FORMAT$(lngPercentFree) & " % free" & $CRLF & _
                           "of " & strDMDriveSize & " GB size"
                           '
    funLCD_DisplayInfo(g_hComm, strOutput)
    SLEEP 2000
    '
  NEXT lngR
  '
END FUNCTION
'
FUNCTION funDriveInfo(strDrives AS STRING, _
                      strDriveSize AS STRING, _
                      strDriveSpace AS STRING) AS STRING
' return the drive info of strDrives
  LOCAL lngR AS LONG              ' loop counter
  LOCAL strOutput AS STRING       ' output data
  LOCAL strDriveLetter AS STRING  ' current drive letter
  LOCAL strDMDriveSize AS STRING  ' drive size
  LOCAL strDMDriveSpace AS STRING ' drive space free
  LOCAL lngPercentFree AS LONG    ' % free space
  '
  FOR lngR = 1 TO PARSECOUNT(strDrives,"|")
    strDriveLetter = PARSE$(strDrives,"|",lngR)
    '
    strDMDriveSize = PARSE$(strDriveSize,strDriveLetter & ":\",2)
    strDMDriveSize = TRIM$(PARSE$(strDMDriveSize,";",1))
    '
    strDMDriveSpace = PARSE$(strDriveSpace,strDriveLetter & ":\",2)
    strDMDriveSpace = TRIM$(PARSE$(strDMDriveSpace,";",1))
    '
    lngPercentFree =  (VAL(strDMDriveSpace) / VAL(strDMDriveSize)) * 100
    '
    strOutput = strOutput & strDriveLetter & " = " & _
                FORMAT$(lngPercentFree) & " % "
    IF lngR MOD 2 = 0 THEN strOutput = strOutput & $CRLF
    '
    FUNCTION = TRIM$(strOutput,$CRLF)
    '
  NEXT lngR
  '
END FUNCTION
'
FUNCTION funPCComputerName() AS STRING
' get the PCs computer name
  DIM zComputerName AS ASCIIZ * %MAX_COMPUTERNAME_LENGTH
  DIM lngValid AS LONG
  DIM lngComputerNameLength AS LONG
  '
  lngComputerNameLength = %MAX_COMPUTERNAME_LENGTH + 1
  lngValid = GetComputerName(zComputerName, lngComputerNameLength)
  '
  IF NOT lngValid THEN
    FUNCTION = zComputerName ' no longer needed -> LEFT$(zComputerName, INSTR(zComputerName, CHR$(0)) - 1)
  ELSE
    FUNCTION = ""
  END IF
'
END FUNCTION
