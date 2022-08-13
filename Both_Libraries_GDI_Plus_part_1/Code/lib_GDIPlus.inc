' lib_GDIPlus.inc
'
' index to library
' Subroutines
' subGDIPlus_SaveImage(strImgFormat, wstrFileName)
'             Given the image format and the name of the file
'             to create this subroutine will save the currently
'             attached graphics object to disk
'
TYPE GdiplusStartupInput
  GdiplusVersion AS DWORD ' Must be 1
  DebugEventCallback AS DWORD ' Ignored on free builds
  SuppressBackgroundThread AS LONG ' FALSE unless you're prepared to call
  ' the hook/unhook functions properly
  SuppressExternalCodecs AS LONG ' FALSE unless you want GDI+ only to use
  ' its internal image codecs.
END TYPE
'
TYPE GdiplusStartupOutput
  NotificationHook AS DWORD
  NotificationUnhook AS DWORD
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
TYPE ImageCodecInfo
  ClassID AS GUID ' CLSID. Codec identifier
  FormatID AS GUID ' GUID. File format identifier
  CodecName AS DWORD ' WCHAR*. Pointer to a null-terminated string
  ' that contains the codec name
  DllName AS DWORD ' WCHAR*. Pointer to a null-terminated string
  ' that contains the path name of the DLL in
  ' which the codec resides. If the codec is not
  ' a DLL, this pointer is NULL
  FormatDescription AS DWORD ' WCHAR*. Pointer to a null-terminated string
  ' that contains the name of the format used by the codec
  FilenameExtension AS DWORD ' WCHAR*. Pointer to a null-terminated string
  ' that contains all file-name extensions associated
  ' with the codec. The extensions are separated with semicolons.
  MimeType AS DWORD ' WCHAR*. Pointer to a null-terminated string
  ' that contains the mime type of the codec
  Flags AS DWORD ' Combination of flags from the ImageCodecFlags enumeration
  Version AS DWORD ' Integer that indicates the version of the codec
  SigCount AS DWORD ' Integer that indicates the number of signatures
  ' used by the file format associated with the codec
  SigSize AS DWORD ' Integer that indicates the number of bytes of each signature
  SigPattern AS DWORD ' BYTE*. Pointer to an array of bytes that contains
  ' the pattern for each signature
  SigMask AS DWORD ' BYTE*. Pointer to an array of bytes that contains
  ' the mask for each signature
END TYPE
'
DECLARE FUNCTION GdiplusStartup IMPORT "GDIPLUS.DLL" ALIAS "GdiplusStartup" _
(token AS DWORD, inputbuf AS GdiplusStartupInput, _
 outputbuf AS GdiplusStartupOutput) AS LONG
'
DECLARE SUB GdiplusShutdown IMPORT "GDIPLUS.DLL" ALIAS "GdiplusShutdown" _
(BYVAL token AS DWORD)
'
DECLARE FUNCTION GdipCreateBitmapFromHBITMAP IMPORT "GDIPLUS.DLL" _
                 ALIAS "GdipCreateBitmapFromHBITMAP" ( _
                 BYVAL hbm AS DWORD _    ' __in  HBITMAP hbm
               , BYVAL hpal AS DWORD _   ' __in  HPALETTE hpal
               , BYREF bitmap AS DWORD _ ' __out GpBitmap **bitmap
                 ) AS LONG
'
DECLARE FUNCTION GdipCreateFromHDC IMPORT "GDIPLUS.DLL" _
                 ALIAS "GdipCreateFromHDC" _
                 (BYVAL hdc AS LONG, graphics AS LONG) AS LONG
'
DECLARE FUNCTION GDIpDrawImageRect IMPORT "GDIPLUS.DLL" _
                 ALIAS "GdipDrawImageRect" _
                 (pGraphics AS DWORD, pImage AS DWORD, _
                 x AS LONG, y AS LONG, lngImgWidth AS LONG, _
                 lngImgHeight AS LONG) AS LONG
'
DECLARE FUNCTION GdipSaveImageToFile IMPORT "GDIPLUS.DLL" _
                 ALIAS "GdipSaveImageToFile" ( _
   BYVAL image AS DWORD _          ' __in  GpImage *image
 , BYREF filename AS WSTRINGZ _    ' __in  GDIPCONST WCHAR *filename
 , BYREF clsidEncoder AS GUID _    ' __in  GDIPCONST CLSID clsidEncoder
 , BYREF encoderParams AS EncoderParameters _   ' __out GDIPCONST EncoderParameters *encoderParams
 ) AS LONG
'
DECLARE FUNCTION GdipDisposeImage IMPORT "GDIPLUS.DLL" _
                 ALIAS "GdipDisposeImage" _
                 (BYVAL lpImage AS DWORD) AS LONG
'
DECLARE FUNCTION GdipDeleteGraphics IMPORT "GDIPLUS.DLL" _
                 ALIAS "GdipDeleteGraphics" _
                 (BYVAL Graphics AS LONG) AS LONG
'
DECLARE FUNCTION GdipGetImageEncodersSize IMPORT "GDIPLUS.DLL" _
                 ALIAS "GdipGetImageEncodersSize" _
                 (numEncoders AS DWORD, nSize AS DWORD) AS LONG
'
DECLARE FUNCTION GdipGetImageEncoders IMPORT "GDIPLUS.DLL" _
                 ALIAS "GdipGetImageEncoders" _
                (BYVAL numEncoders AS DWORD, BYVAL nSize AS DWORD, _
                 BYVAL lpEncoders AS DWORD) AS LONG

'
SUB subGDIPlus_SaveImage(strImgFormat AS STRING, _
                         wstrFileName AS WSTRINGZ)
' initialize GDIPlus
  LOCAL hToken AS DWORD                       ' token for GDI Plus
  LOCAL StartupInput AS GDIplusStartupInput   ' prep UDT
  LOCAL strMimeType AS STRING                 ' Mime type for saved file
  LOCAL lngImgWidth, lngImgHeight AS LONG     ' Height & width of graphics control
  '
  LOCAL hGraphicDC AS DWORD
  ' get the device context handle of the current graphics control
  ' to allow use of Windows API functions
  GRAPHIC GET DC TO hGraphicDC
  ' get the size of the current graphic control canvas
  GRAPHIC GET CANVAS TO lngImgWidth, lngImgHeight
  '
  StartupInput.GDIplusVersion = 1
  ' initialise GDI plus and populate token
  GDIplusStartup(hToken, StartupInput, BYVAL %NULL)
  '
  ' Select Mime Type
  SELECT CASE LCASE$(strImgFormat)
    CASE "bmp"
      strMimeType = "image/bmp"
    CASE "jpg"
      strMimeType = "image/jpeg"
    CASE "gif"
      strMimeType = "image/gif"
    CASE "png"
      strMimeType = "image/png"
  END SELECT
  '
  ' prepare to save the image
  LOCAL strClassID AS STRING
  LOCAL guEncoderClsid AS GUID
  LOCAL pImage, hBitmap, pGraphics AS DWORD
  '
  ' get the encoders class ID
  strClassID = GDIPlusGetEncoderClsid((strMimeType))
  guEncoderClsid = GUID$(strClassID)

  ' get bitmap handle from graphic target
  hBitmap = GetCurrentObject(hGraphicDC, %OBJ_Bitmap)
  '
  'create GDI+ image and populate pImage
  GDIpCreateBitmapFromHBITMAP( hBitmap, BYVAL %Null, pImage)
  '
  'create graphic object containing Graphic Control
  GDIpCreateFromHDC(hGraphicDC, pGraphics)
  '
  ' define area of graphics control to grab (0,0)-(lngImgWidth,lngImgHeight)
  GDIpDrawImageRect(pGraphics, pImage, 0, 0, lngImgWidth, lngImgHeight)
  '
  ' save image to file
  GDIpSaveImageToFile(pImage,wstrFileName, guEncoderClsid, BYVAL %Null)
  '
  IF ISTRUE pImage THEN
  ' GDIPlus cleanup
    GDIpDisposeImage(pImage)
  END IF
  '
  IF ISTRUE pGraphics THEN
  ' GDIPlus cleanup
    GDIpDeleteGraphics(pGraphics)
  END IF
  '
  ' shut down GDI+
  GDIplusShutdown hToken
  '
END SUB
'
FUNCTION GdiPlusGetEncoderClsid (BYVAL strMimeType AS STRING) AS STRING
  'Retrieve encoder's clsid, where strMimeType is ansi string e.g. "image/jpeg"
  'Routine courtesy Jose Roca GdipUtils.inc, freeware, posted PB Forums 23/12/09

  LOCAL hr AS LONG
  LOCAL pImageCodecInfo AS ImageCodecInfo PTR
  LOCAL numEncoders AS DWORD
  LOCAL nSize AS DWORD
  LOCAL lngI AS LONG
  LOCAL wstrlen AS LONG
  LOCAL sMimeType AS STRING

  hr = GdipGetImageEncodersSize(numEncoders, nSize)
  REDIM buffer(nSize - 1) AS BYTE
  pImageCodecInfo = VARPTR(buffer(0))
  hr = GdipGetImageEncoders(numEncoders, nSize, BYVAL pImageCodecInfo)
  IF hr = 0 THEN
    FOR lngI = 1 TO numEncoders
      wstrlen = lstrlenW(BYVAL @pImageCodecInfo.MimeType)
      IF wstrlen THEN sMimeType = ACODE$(PEEK$(@pImageCodecInfo.MimeType, wstrlen * 2))
      IF INSTR(UCASE$(sMimeType), UCASE$(strMimeType) ) THEN
        FUNCTION = GUIDTXT$(@pImageCodecInfo.ClassID)
        EXIT FOR
      END IF
      INCR pImageCodecInfo '// Increments pointer
    NEXT lngI
  END IF
  '
END FUNCTION
