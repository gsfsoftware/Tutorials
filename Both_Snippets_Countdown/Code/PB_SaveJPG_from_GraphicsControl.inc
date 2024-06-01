'PB_SaveJPG_from_GraphicsControl.inc

'//--------------------------------------------------------------------------
'// ImageCodecInfo structure
'//--------------------------------------------------------------------------

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
DECLARE FUNCTION GdipDrawImageRect IMPORT "GDIPLUS.DLL" ALIAS "GdipDrawImageRect" ( _
   BYVAL graphics AS DWORD _                            ' __in GpGraphics *graphics
 , BYVAL image AS DWORD _                               ' __in GpImage *image
 , BYVAL x AS SINGLE _                                  ' __in REAL x
 , BYVAL y AS SINGLE _                                  ' __in REAL y
 , BYVAL width AS SINGLE _                              ' __in REAL width
 , BYVAL height AS SINGLE _                             ' __in REAL height
 ) AS LONG                                              ' GpStatus

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
FUNCTION GdiPlusGetEncoderClsid (BYREF wszMimeType AS WSTRINGZ) AS WSTRING

   LOCAL hr AS LONG
   LOCAL i AS LONG
   LOCAL pImageCodecInfo AS ImageCodecInfo PTR
   LOCAL numEncoders AS DWORD
   LOCAL nSize AS DWORD

   hr = GdipGetImageEncodersSize(numEncoders, nSize)
   REDIM buffer(nSize - 1) AS BYTE
   pImageCodecInfo = VARPTR(buffer(0))

   hr = GdipGetImageEncoders(numEncoders, nSize, BYVAL pImageCodecInfo)
   IF hr = 0 THEN
      FOR i = 1 TO numEncoders
         IF INSTR(UCASE$(@pImageCodecInfo.@MimeType), UCASE$(wszMimeType)) THEN
            FUNCTION = GUIDTXT$(@pImageCodecInfo.Clsid)
            EXIT FOR
         END IF
         INCR pImageCodecInfo       '// Increments pointer
      NEXT
   END IF

END FUNCTION
'
FUNCTION funSaveGraphicControl(hDlg AS DWORD, _
                               lngControl AS LONG, _
                               strFileOutput AS WSTRINGZ) AS LONG
' save the contents of the graphics control
  LOCAL gudEncoderClsid AS GUID
  LOCAL hBitmap AS DWORD
  LOCAL pImage AS DWORD
  LOCAL pGraphics AS DWORD
  LOCAL hGraphicDC AS DWORD
  '
  LOCAL token AS DWORD, StartupInput AS GdiplusStartupInput
  '
  're-initialize GDIPlus
  StartupInput.GdiplusVersion = 1
  GdiplusStartup(token, StartupInput, BYVAL %NULL)
  GRAPHIC ATTACH hDlg,lngControl, REDRAW
  '
  ' MimeTypes = "image/bmp,image/jpeg,image/gif,image/tiff,image/png"
  '
  gudEncoderClsid = GUID$(GDIPlusGetEncoderClsid("image/jpeg"))
  '
  '
  ' from graphic control
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
  ' shut down GDIPlus
  GdiplusShutdown token      ' Shutdown GDI+
  FUNCTION = %TRUE
  '
END FUNCTION
