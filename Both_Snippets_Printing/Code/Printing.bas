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

FUNCTION PBMAIN () AS LONG
' the main PB function that is the first to be executed
  funPrepOutput("Printing",0,0,40,120)
  '
  funLog("Printing")
  '
  LOCAL strPrinterList AS STRING
  LOCAL lngR AS LONG
  '
  FOR lngR = 1 TO PRINTERCOUNT
    strPrinterList = strPrinterList & PRINTER$(NAME,lngR) & $CRLF
  NEXT lngR
  '
  funLog(strPrinterList)
  '
  XPRINT ATTACH "Microsoft Print to PDF"
  '
  IF ERR = 0 THEN
    XPRINT "Test printing to PDF"
    '
    LOCAL WidthVar AS SINGLE
    LOCAL HeightVar AS SINGLE
    XPRINT GET CANVAS TO WidthVar,HeightVar
    '
    XPRINT "Canvas size is " & FORMAT$(WidthVar) & " wide and " & _
                               FORMAT$(HeightVar) & " high"
    '
    XPRINT SET WORDWRAP
    XPRINT ""
    XPRINT "Printing some very long text string that won't " & _
           "fit in a single line, because it is more characters than " & _
           "a single line can cope with"
    XPRINT ""
    '
    XPRINT LINE  (300, 700) - (1600, 700), %RED
    '
    LOCAL Pi2 AS DOUBLE
    Pi2 = ATN(1)* 8  ' 2 * Pi can be useful here
    PREFIX "XPRINT PIE "
      (300, 1000)-(1600, 2300), 0, Pi2 * 0.40, %LTGRAY,%BLUE, 0
      (299, 1000)-(1599, 2300), Pi2 * 0.40, Pi2 * 0.50, %LTGRAY, %RED, 0
      (299, 1001)-(1599, 2301), Pi2 * 0.50,  Pi2 * 0.80, %LTGRAY, %GREEN, 0
      (300, 1001)-(1600, 2300), Pi2 * 0.80, 0, %LTGRAY, %YELLOW, 0
    END PREFIX
    '
    LOCAL FontHndl AS DWORD
    FONT NEW "Times New roman",16,1 TO FontHndl
    XPRINT SET FONT FontHndl
    XPRINT SET POS (300,850)
    XPRINT "Pie Chart for today"
    '
    XPRINT SET POS (800,1200)
    XPRINT COLOR %WHITE
    XPRINT "40%"
    '
    ' print a bitmap
    LOCAL lngFile, lngWidth, lngHeight AS LONG
    lngFile = FREEFILE
    OPEN "Capture2.bmp" FOR BINARY AS lngFile
    GET #lngFile, 19, lngWidth
    GET #lngFile, 23, lngHeight
    CLOSE lngFile
    '
    XPRINT RENDER "Capture2.bmp", _
                  (250,2800)-(250 + lngWidth, 2800 + lngHeight)
    '
    XPRINT CLOSE
  END IF
  '
  LOCAL strCMD AS ASCIIZ * 1024
  strCMD = ENVIRON$("USERPROFILE") & "\Documents\test.pdf"
  IF ISFILE(strCMD) THEN
    ShellExecute 0, "open", strCMD, "", "", %SW_SHOW
  ELSE
    funlog("PDF File not found")
    funWait()
  END IF
  '
END FUNCTION
'
