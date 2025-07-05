' GDIPlus included functions
'//--------------------------------------------------------------------------
'// ImageCodecInfo structure
'//--------------------------------------------------------------------------
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
' // Size = 76 bytes
TYPE ImageCodecInfo DWORD
   Clsid             AS GUID           ' CLSID
   FormatID          AS GUID           ' GUID
   CodecName         AS WSTRINGZ PTR   ' const WCHAR*
   DllName           AS WSTRINGZ PTR   ' const WCHAR*
   FormatDescription AS WSTRINGZ PTR   ' const WCHAR*
   FilenameExtension AS WSTRINGZ PTR   ' const WCHAR*
   MimeType          AS WSTRINGZ PTR   ' const WCHAR*
   Flags             AS DWORD          ' DWORD
   Version           AS DWORD          ' DWORD
   SigCount          AS DWORD          ' DWORD
   SigSize           AS DWORD          ' DWORD
   SigPattern        AS BYTE PTR       ' const BYTE*
   SigMask           AS BYTE PTR       ' const BYTE*
END TYPE
'
' // Size = 28 bytes
TYPE EncoderParameter DWORD
   pGuid          AS GUID    '  // GUID of the parameter
   NumberOfValues AS DWORD   '  // Number of the parameter values
   dwType         AS DWORD   '  // Value type, like ValueTypeLONG  etc.
   Value          AS DWORD   '  // A pointer to the parameter values
END TYPE
'
' // Size = 32 bytes
TYPE EncoderParameters   DWORD
   Count        AS DWORD             ' // Number of parameters in this structure
   Parameter(0) AS EncoderParameter  ' // Parameter values - variable-length array
END TYPE
'
DECLARE FUNCTION GdiplusStartup _
                LIB "GDIPLUS.DLL" ALIAS "GdiplusStartup" _
               (token AS DWORD, inputbuf AS GdiplusStartupInput, _
                outputbuf AS GdiplusStartupOutput) AS LONG
DECLARE SUB GdiplusShutdown _
                LIB "GDIPLUS.DLL" ALIAS "GdiplusShutdown" _
               (BYVAL token AS DWORD)
'
DECLARE FUNCTION GdipDrawImageRect IMPORT "GDIPLUS.DLL" ALIAS "GdipDrawImageRect" ( _
   BYVAL graphics AS DWORD _                            ' __in GpGraphics *graphics
 , BYVAL image AS DWORD _                               ' __in GpImage *image
 , BYVAL x AS SINGLE _                                  ' __in REAL x
 , BYVAL y AS SINGLE _                                  ' __in REAL y
 , BYVAL width AS SINGLE _                              ' __in REAL width
 , BYVAL height AS SINGLE _                             ' __in REAL height
 ) AS LONG                                              ' GpStatus

'
DECLARE FUNCTION GdipDisposeImage   _
                LIB "GDIPLUS.DLL" ALIAS "GdipDisposeImage" _
               (BYVAL lpImage AS DWORD) AS LONG
'
DECLARE FUNCTION GdipDeleteGraphics _
                LIB "GDIPLUS.DLL" ALIAS "GdipDeleteGraphics" _
               (BYVAL Graphics AS LONG) AS LONG
               '
DECLARE FUNCTION GdipGetImageEncodersSize IMPORT "GDIPLUS.DLL" ALIAS "GdipGetImageEncodersSize" ( _
   BYREF numEncoders AS DWORD _                         ' __in  UINT *numEncoders
 , BYREF size AS DWORD _                                ' __out UINT *size
 ) AS LONG                                              ' Status
'
DECLARE FUNCTION GdipGetImageEncoders IMPORT "GDIPLUS.DLL" ALIAS "GdipGetImageEncoders" ( _
   BYVAL numEncoders AS DWORD _                         ' __in  UINT numEncoders
 , BYVAL size AS DWORD _                                ' __in  UINT size
 , BYREF encoders AS ANY _                              ' __out ImageCodecInfo *encoders
 ) AS LONG
'
DECLARE FUNCTION GdipCreateBitmapFromHBITMAP IMPORT "GDIPLUS.DLL" ALIAS "GdipCreateBitmapFromHBITMAP" ( _
   BYVAL hbm AS DWORD _                                 ' __in  HBITMAP hbm
 , BYVAL hpal AS DWORD _                                ' __in  HPALETTE hpal
 , BYREF bitmap AS DWORD _                              ' __out GpBitmap **bitmap
 ) AS LONG                                              ' GpStatus
'
DECLARE FUNCTION GdipSaveImageToFile IMPORT "GDIPLUS.DLL" ALIAS "GdipSaveImageToFile" ( _
   BYVAL image AS DWORD _                               ' __in  GpImage *image
 , BYREF filename AS WSTRINGZ _                         ' __in  GDIPCONST WCHAR *filename
 , BYREF clsidEncoder AS GUID _                         ' __in  GDIPCONST CLSID clsidEncoder
 , BYREF encoderParams AS EncoderParameters _           ' __out GDIPCONST EncoderParameters *encoderParams
 ) AS LONG                                              ' GpStatus
'
FUNCTION funStartUpGDIplus(dwToken AS DWORD) AS LONG
' start up GDIplus
  're-initialize GDIPlus
  LOCAL StartupInput AS GdiplusStartupInput
  StartupInput.GdiplusVersion = 1
  GdiplusStartup(dwToken, StartupInput, BYVAL %NULL)
'
END FUNCTION
'
FUNCTION funShutDownGDIPlus(dwToken AS DWORD) AS LONG
' shut down GDI plus
  GdiplusShutdown dwToken      ' Shutdown GDI+
END FUNCTION

FUNCTION funSaveGraphicControl(strFileOutput AS WSTRINGZ) AS LONG
' save the contents of the graphics control
  LOCAL gudEncoderClsid AS GUID
  LOCAL hBitmap AS DWORD
  LOCAL pImage AS DWORD
  LOCAL pGraphics AS DWORD
  LOCAL hGraphicDC AS DWORD
  '
  LOCAL token AS DWORD, StartupInput AS GdiplusStartupInput
  '
  ' MimeTypes = "image/bmp,image/jpeg,image/gif,image/tiff,image/png"
  '
  gudEncoderClsid = GUID$(GDIPlusGetEncoderClsid("image/png"))
  '
  '
  ' take from graphic control
  GRAPHIC GET DC TO hGraphicDC
  hBitmap = GetCurrentObject(hGraphicDC, %OBJ_Bitmap)
  ' create GDI+ image (pImage)
  GDIpCreateBitmapFromHBITMAP(hBitmap, BYVAL %Null, pImage)
  ' save to file
  GdipSaveImageToFile(pImage,strFileOutput, _
                      gudEncoderClsid, BYVAL %Null)
                      '
  ' tidy up
  IF pImage THEN GdipDisposeImage(pImage)
  IF pGraphics THEN GdipDeleteGraphics(pGraphics)
  '
  FUNCTION = %TRUE
  '
END FUNCTION
'
FUNCTION GdiPlusGetEncoderClsid (BYREF wszMimeType AS WSTRINGZ) AS WSTRING
' Get encoders class ID
  LOCAL hr AS LONG
  LOCAL lngEncoder AS LONG
  LOCAL pImageCodecInfo AS ImageCodecInfo PTR
  LOCAL numEncoders AS DWORD
  LOCAL nSize AS DWORD
  '
  hr = GdipGetImageEncodersSize(numEncoders, nSize)
  REDIM buffer(nSize - 1) AS BYTE
  pImageCodecInfo = VARPTR(buffer(0))
  '
  hr = GdipGetImageEncoders(numEncoders, nSize, BYVAL pImageCodecInfo)
  IF hr = 0 THEN
    FOR lngEncoder = 1 TO numEncoders
      IF INSTR(UCASE$(@pImageCodecInfo.@MimeType), UCASE$(wszMimeType)) THEN
      ' return GUID as text
        FUNCTION = GUIDTXT$(@pImageCodecInfo.Clsid)
        EXIT FOR
      END IF
      INCR pImageCodecInfo       '// Increments pointer
    NEXT lngEncoder
  END IF
  '
END FUNCTION
