' libLoadJpegPNG.inc
'
' allow loading of JPG & PNG files
'
' all credit to Gary Beane & Dave Biggs for this code
' https://forum.powerbasic.com/forum/user-to-user-discussions/
' powerbasic-for-windows/56710-read-pixels-from-jpg-gif-tiff-png

#INCLUDE ONCE "Win32API.inc"
'
TYPE GdiplusStartupInput
   GdiplusVersion           AS DWORD
   DebugEventCallback       AS DWORD
   SuppressBackgroundThread AS LONG
   SuppressExternalCodecs   AS LONG
END TYPE
'
TYPE GdiplusStartupOutput
   NotificationHook         AS DWORD
   NotificationUnhook       AS DWORD
END TYPE
'
DECLARE FUNCTION GdiplusStartup _
                LIB "GDIPLUS.DLL" ALIAS "GdiplusStartup" _
               (token AS DWORD, inputbuf AS GdiplusStartupInput, _
                outputbuf AS GdiplusStartupOutput) AS LONG
DECLARE SUB GdiplusShutdown _
                LIB "GDIPLUS.DLL" ALIAS "GdiplusShutdown" _
               (BYVAL token AS DWORD)
DECLARE FUNCTION GdipLoadImageFromFile _
                LIB "GDIPLUS.DLL" ALIAS "GdipLoadImageFromFile" _
               (BYVAL sFileName AS STRING, lpImage AS DWORD) AS LONG
DECLARE FUNCTION GdipGetImageWidth  _
                LIB "GDIPLUS.DLL" ALIAS "GdipGetImageWidth" _
               (BYVAL image AS DWORD, BYREF width AS DWORD) AS LONG
DECLARE FUNCTION GdipGetImageHeight _
                LIB "GDIPLUS.DLL" ALIAS "GdipGetImageHeight" _
               (BYVAL image AS DWORD, BYREF height AS DWORD) AS LONG
DECLARE FUNCTION GdipCreateFromHDC _
                LIB "GDIPLUS.DLL" ALIAS "GdipCreateFromHDC" _
               (BYVAL hdc AS LONG, graphics AS LONG) AS LONG
DECLARE FUNCTION GdipDrawImage _
                LIB "gdiplus.dll" ALIAS "GdipDrawImage" _
               (BYVAL graphics AS LONG, BYVAL nImage AS DWORD, _
                BYVAL x AS LONG, BYVAL y AS LONG) AS LONG
DECLARE FUNCTION GdipDisposeImage   _
                LIB "GDIPLUS.DLL" ALIAS "GdipDisposeImage" _
               (BYVAL lpImage AS DWORD) AS LONG
DECLARE FUNCTION GdipDeleteGraphics _
                LIB "GDIPLUS.DLL" ALIAS "GdipDeleteGraphics" _
               (BYVAL Graphics AS LONG) AS LONG
'
FUNCTION funLoadFileToGraphicControl(strImage AS STRING, _
                                     hDlg AS DWORD, _
                                     lngGraphic AS LONG) AS LONG
' load a JPG or PNG file into a Graphic Control
  LOCAL hBMP AS DWORD               ' handle for bitmap
  '
  LOCAL lng_imgW, lng_imgH AS LONG  ' width and height of image
  '
  IF ISFALSE ISFILE(strImage) THEN
  ' unable to locate image
    FUNCTION = %FALSE
  ELSE
  ' load image , get the size and bitmap handle
    IF ISTRUE funLoadImageFile(strImage, _
                               lng_imgW, _
                               lng_imgH, _
                               hBMP ) THEN
                               '
      ' copy memory bitmap to graphic control
      GRAPHIC ATTACH hDlg, lngGraphic, REDRAW
      GRAPHIC COPY hBmp,0
      GRAPHIC BITMAP END
      FUNCTION = %TRUE
      '
    ELSE
      FUNCTION = %FALSE
    END IF
  END IF
  '
END FUNCTION
'
FUNCTION funLoadImageFile(str_imgFileName AS STRING, _
                          o_lng_imgW AS LONG, _
                          o_lng_imgH AS LONG, _
                          o_hBMP AS DWORD ) AS LONG
' load graphic file
  LOCAL pImage,pGraphics,hDC AS DWORD
  LOCAL token AS DWORD, StartupInput AS GdiplusStartupInput
  '
  IF ISFALSE ISFILE(str_imgFileName) THEN
  ' file doesn't exist
    EXIT FUNCTION
  END IF
  '
  'initialize GDIPlus
  StartupInput.GdiplusVersion = 1
  GdiplusStartup(token, StartupInput, BYVAL %NULL)
  '
  ' load image/get properties
  str_imgFileName = UCODE$(str_imgFileName)
  ' pImage - image object  ' File can be jpg, gif, tif or png
  GdipLoadImageFromFile((str_imgFileName), pImage)
  '
  ' get width
  GdipGetImageWidth(pImage,o_lng_imgW)
  '
  ' get height
  GdipGetImageHeight(pImage,o_lng_imgH)
  '
  ' memory bitmap
  GRAPHIC BITMAP NEW o_lng_imgW,o_lng_imgH TO o_hBMP
  '
  GRAPHIC ATTACH o_hBMP,0
  '
  ' hDC for memory bitmap
  GRAPHIC GET DC TO hDc
  '
  ' create graphic object associated with hDC
  GdipCreateFromHDC(hDC, pGraphics)
  ' draw image to memory bitmap at 0,0
  GdipDrawImage(pGraphics, pImage, 0,0)
  '
  ' GDIP cleanup
  IF pImage THEN GdipDisposeImage(pImage)
  IF pGraphics THEN GdipDeleteGraphics(pGraphics)
  '
  ' shut down GDIPlus
  GdiplusShutdown token      ' Shutdown GDI+
  FUNCTION = %TRUE
  '
END FUNCTION
'
FUNCTION funLoadFileToGraphicArray(strPathAndName AS STRING, _
                                   lngFiles AS LONG, _
                                   hDlg AS DWORD, _
                                   lngGraphic AS LONG, _
                                   BYREF g_astrGraphics() AS STRING) AS LONG
                                   '
' load each image of the graphic into the array
  LOCAL lngR AS LONG
  LOCAL strFilename AS STRING
  LOCAL strGraphicImage AS STRING
  '
  FOR lngR = 1 TO lngFiles
    strFilename = RIGHT$("0000" & FORMAT$(lngR),4) & ".png"
    IF ISFALSE ISFILE(strPathAndName & strFilename) THEN
    ' file not found
      FUNCTION = %FALSE
      EXIT FUNCTION
    ELSE
    ' file found
      IF ISTRUE funLoadFileToGraphicControl(strPathAndName & strFilename, _
                                            hDlg , _
                                            lngGraphic) THEN
      ' file loaded
      ' save the graphic in the array
        GRAPHIC GET BITS TO strGraphicImage
        g_astrGraphics(lngR) = strGraphicImage
        '
      ELSE
        FUNCTION = %FALSE
        EXIT FUNCTION
      END IF
    END IF
    '
  NEXT lngR
  '
  FUNCTION = %TRUE
END FUNCTION
