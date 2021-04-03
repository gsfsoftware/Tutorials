' Compilable Example:  PBWin9 or PBWin10
' all credit to Gary Beane & Dave Biggs for this code
' https://forum.powerbasic.com/forum/user-to-user-discussions/
' powerbasic-for-windows/56710-read-pixels-from-jpg-gif-tiff-png
'
#COMPILE EXE
#DIM ALL
#INCLUDE "Win32API.inc"
 '#Include "cgdiplus.inc" 'Jose Roca Includes Or these extracts..

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

'constants
%IDC_Graphic = 101

$Image = "Computer.jpg"


FUNCTION PBMAIN() AS LONG
  LOCAL hDlg AS DWORD
  '
  DIALOG NEW PIXELS, 0, "Load JPG, GIF, TIF or PNG",300,300,600,600, _
            %WS_OVERLAPPEDWINDOW TO hDlg
  DIALOG SHOW MODAL hDlg CALL DlgProc
END FUNCTION

CALLBACK FUNCTION DlgProc() AS LONG
  LOCAL x,y,lngColour AS LONG, pt AS POINT
  LOCAL lng_imgW, lng_imgH AS LONG
  LOCAL lng_imgWu, lng_imgHu AS LONG
  '
  SELECT CASE CB.MSG
    CASE %WM_INITDIALOG
      LOCAL hBMP AS DWORD
      '
      ' load image , get the size and bitmap handle
      IF ISTRUE funLoadImageFile(EXE.PATH$ & $image, _
                                 lng_imgW, _
                                 lng_imgH, _
                                 hBMP ) THEN
        ' set dialog to size
        DIALOG SET CLIENT CB.HNDL, lng_imgW, lng_imgH
        '
        ' add graphic control
        CONTROL ADD GRAPHIC , CB.HNDL, %IDC_Graphic,"", _
           0,0,lng_imgW, lng_imgW, %SS_NOTIFY
        GRAPHIC ATTACH CB.HNDL, %IDC_Graphic
        ' copy memory bitmap to graphic control
        GRAPHIC COPY hBmp,0
        GRAPHIC BITMAP END
        '
      ELSE
        MSGBOX "No image loaded",0,"Failure to load"
      END IF
      '
  END SELECT
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
