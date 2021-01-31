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
%Portrait  = 1
%Landscape = 2
'
FUNCTION PBMAIN () AS LONG
' the main PB function that is the first to be executed
  funPrepOutput("Printing",0,0,40,120)
  '
  funLog("Printing")
  '
  LOCAL strPrinterList AS STRING
  LOCAL lngR AS LONG
  ' obtain a list of printers accessible by this computer
  FOR lngR = 1 TO PRINTERCOUNT
    strPrinterList = strPrinterList & PRINTER$(NAME,lngR) & $CRLF
  NEXT lngR
  '
  funLog(strPrinterList)
  '
  XPRINT ATTACH "Microsoft Print to PDF"  ' attach to a named printer
  '
  IF ERR = 0 THEN
  ' is anything other than err = 0 then you can't connect to that printer
    ' get the list of paper sizes this printer supports
    LOCAL strPaperSizesSupport AS STRING
    XPRINT GET PAPERS TO strPaperSizesSupport
    funLog(strPaperSizesSupport)
    '
    ' get the current paper size selected
    LOCAL lngPaperSize AS LONG
    XPRINT GET PAPER TO lngPaperSize
    '
    ' set the paper size
    XPRINT SET PAPER %DMPAPER_A3
    XPRINT GET PAPER TO lngPaperSize
    funLog(FORMAT$(lngPaperSize))
    '
    ' set the page orientation
    XPRINT SET ORIENTATION %Landscape
    '
    ' set the colour mode
    'XPRINT SET COLORMODE %DMCOLOR_MONOCHROME
    XPRINT SET COLORMODE %DMCOLOR_COLOR
    '
    ' set the number of copies required
    LOCAL lngCopies AS LONG
    lngCopies = 2
    XPRINT SET COPIES lngCopies
    '
    ' configure duplex or simplex mode
    XPRINT SET DUPLEX %DMDUP_SIMPLEX    ' single sided printing
    XPRINT SET DUPLEX %DMDUP_VERTICAL   ' page is flipped on the vertical edge
    XPRINT SET DUPLEX %DMDUP_HORIZONTAL ' page is flipped on the horizontal edge
    '
    ' determine and set the collation status of this printer
    LOCAL lngCollateStatus AS LONG
    XPRINT GET COLLATE TO lngCollateStatus
    '
    XPRINT SET COLLATE %DMCOLLATE_FALSE ' set printer to not collate
    XPRINT SET COLLATE %DMCOLLATE_TRUE  ' set printer to collate copies
    '
    ' error 5 will be returned if you try to set printer
    ' to setting it cant support
    '
    ' not actually print to the printer
    XPRINT "Test printing to PDF"
    '
    LOCAL WidthVar AS SINGLE
    LOCAL HeightVar AS SINGLE
    XPRINT GET CANVAS TO WidthVar,HeightVar
    '
    XPRINT "Canvas size is " & FORMAT$(WidthVar) & " wide and " & _
                               FORMAT$(HeightVar) & " high"
    ' turn on the wordwrap feature
    XPRINT SET WORDWRAP
    XPRINT ""
    XPRINT "Printing some very long text string that won't " & _
           "fit in a single line, because it is more characters than " & _
           "a single line can cope with"
    XPRINT ""
    ' print a line on the printer
    XPRINT LINE  (300, 700) - (1600, 700), %RED
    '
    XPRINT FORMFEED    '**** new page
    '
    ' create a pie chart
    LOCAL Pi2 AS DOUBLE
    Pi2 = ATN(1)* 8  ' 2 * Pi can be useful here
    PREFIX "XPRINT PIE "
      (300, 1000)-(1600, 2300), 0, Pi2 * 0.40, %LTGRAY,%BLUE, 0
      (299, 1000)-(1599, 2300), Pi2 * 0.40, Pi2 * 0.50, %LTGRAY, %RED, 0
      (299, 1001)-(1599, 2301), Pi2 * 0.50,  Pi2 * 0.80, %LTGRAY, %GREEN, 0
      (300, 1001)-(1600, 2300), Pi2 * 0.80, 0, %LTGRAY, %YELLOW, 0
    END PREFIX
    '
    ' set the font to be used
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
    ' print the bitmap again but twice the width & height
    XPRINT RENDER "Capture2.bmp", _
                  (250,3800)-(250 + (lngWidth*2), 3800 + (lngHeight*2))
    '
    XPRINT CLOSE
  END IF
  '
  SLEEP 1000
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
