' PB_GDIplus_startup.inc
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

DECLARE FUNCTION GdiplusStartup _
                LIB "GDIPLUS.DLL" ALIAS "GdiplusStartup" _
               (token AS DWORD, inputbuf AS GdiplusStartupInput, _
                outputbuf AS GdiplusStartupOutput) AS LONG
DECLARE SUB GdiplusShutdown _
                LIB "GDIPLUS.DLL" ALIAS "GdiplusShutdown" _
               (BYVAL token AS DWORD)
