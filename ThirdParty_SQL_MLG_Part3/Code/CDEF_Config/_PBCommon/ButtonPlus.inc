'******************************************************************************
'                    ButtonPlus definitions and declarations
'
' Compiler: PB/Win 8.x - 9.x                     Laurence Jackson, 24-Oct-2008
'
'******************************************************************************

' Public ButtonPlus property identifiers

%BP_TEXT_COLOR    = 1
%BP_ICON_ID       = 2
%BP_ICON_WIDTH    = 3
%BP_ICON_HEIGHT   = 4
%BP_ICON_POS      = 5
%BP_FACE_COLOR    = 6
%BP_FACE_BLEND    = 7
%BP_SPOT_COLOR    = 8
%BP_SPOT_BLEND    = 9
%BP_SPOT_WIDTH    = 10
%BP_SPOT_HEIGHT   = 11
%BP_SPOT_POS      = 12

' Values defined in MS Windows API headers

%NULL             = 0
%FALSE            = 0
%TRUE             = 1
%TRANSPARENT      = 1
%IMAGE_ICON       = 1

%GWL_WNDPROC      = &HFFFFFFFC
%GWL_STYLE        = &HFFFFFFF0
%GWL_USERDATA     = &HFFFFFFEB
%ODT_BUTTON       = &H00000004
%ODS_FOCUS        = &H00000010
%ODS_NOFOCUSRECT  = &H00000200
%DFCS_BUTTONPUSH  = &H00000010
%DFCS_MONO        = &H00008000
%DFC_BUTTON       = &H00000004
%DSS_MONO         = &H00000080
%DSS_DISABLED     = &H00000020
%DST_ICON         = &H00000003
%DST_PREFIXTEXT   = &H00000002
%TME_LEAVE        = &H00000002
%SM_CXICON        = &H0000000B
%SM_CYICON        = &H0000000C
%LR_SHARED        = &H00008000
%BM_GETSTATE      = &H000000F2
%BM_SETSTYLE      = &H000000F4
%BST_PUSHED       = &H00000004
%COLOR_WINDOWTEXT = &H00000008
%COLOR_BTNFACE    = &H0000000F
%COLOR_BTNSHADOW  = &H00000010
%COLOR_GRAYTEXT   = &H00000011
%COLOR_3DDKSHADOW = &H00000015

%WM_SHOWWINDOW    = &H00000018
%WM_GETTEXT       = &H0000000D
%WM_GETFONT       = &H00000031
%WM_MOUSEMOVE     = &H00000200
%WM_MOUSELEAVE    = &H000002A3
%WM_NCACTIVATE    = &H00000086
%WM_DESTROY       = &H00000002
%WM_DRAWITEM      = &H0000002B
%WM_USER          = &H00000400

%BS_OWNERDRAW     = &H0000000B
%BS_LEFT          = &H00000100
%BS_RIGHT         = &H00000200
%BS_CENTER        = &H00000300
%BS_TOP           = &H00000400
%BS_BOTTOM        = &H00000800
%BS_VCENTER       = &H00000C00
%BS_MULTILINE     = &H00002000
%BS_NOTIFY        = &H00004000
%BS_FLAT          = &H00008000

' Additional ButtonPlus identifiers used internally

%BP_HOT           = 20
%BP_DESTROY       = 21
%BP_DEFAULT       = 23
%BP_INIT          = %WM_USER + 791

' GDI+ smoothing mode

%ANTIALIAS        = 4

' Part ID for themed drawing

%BP_PUSHBUTTON    = 1

' State values for themed drawing

%PBS_NORMAL       = 1
%PBS_HOT          = 2
%PBS_PRESSED      = 3
%PBS_DISABLED     = 4
%PBS_DEFAULTED    = 5

' Static structure used by the ButtonPlus function

TYPE ButtonPlusType
  hButton_DW AS DWORD      'Handle of button (identification)
  TextColor_LG AS LONG     'RGB value for caption text
  IconID_LG AS LONG        'Null for no icon
  IconWidth_LG AS LONG     'In pixels, 0 for default
  IconHeight_LG AS LONG    'In pixels, 0 for default
  IconPos_LG AS LONG       'Left, right, top or bottom
  FaceColor_LG AS LONG     'RGB, 0 for default color
  FaceBlend_LG AS LONG     'Alpha channel value, 0 for default
  SpotColor_LG AS LONG     'RGB, 0 for default color
  SpotBlend_LG AS LONG     'Alpha channel value, 0 for default
  SpotWidth_LG AS LONG     'In pixels, 0 for default
  SpotHeight_LG AS LONG    'In pixels, 0 for default
  SpotPos_LG AS LONG       'Left, right, top or bottom
  Hot_LG AS LONG           'Boolean, mouse pointer over button
  Default_LG AS LONG       'Boolean, true for default button when not in foreground
END TYPE

TYPE FocusType
  hDialog_DW AS DWORD
  hControl_DW AS DWORD
END TYPE

TYPE RECTSIZE
  Left AS LONG
  Top AS LONG
  Width AS LONG
  Height AS LONG
END TYPE

' Structures defined in MS Windows headers

'type RECT
'  nLeft as long
'  nTop as long
'  nRight as long
'  nBottom as long
'end type

TYPE SIZEL
  cx AS LONG
  cy AS LONG
END TYPE

TYPE TRACKMOUSEEVENTAPI
  cbSize AS DWORD
  dwFlags AS DWORD
  hwndTrack AS DWORD
  dwHoverTime AS DWORD
END TYPE

TYPE DRAWITEMSTRUCT
  CtlType AS DWORD
  CtlID AS DWORD
  itemID AS DWORD
  itemAction AS DWORD
  itemState AS DWORD
  hwndItem AS LONG
  hDC AS DWORD
  rcItem AS RECT
  itemData AS DWORD
END TYPE

' GDI+ structures

TYPE GdiplusStartupInput
  GdiplusVersion AS DWORD
  DebugEventCallback AS DWORD
  SuppressBackgroundThread AS LONG
  SuppressExternalCodecs AS LONG
END TYPE

TYPE GdiplusStartupOutput
  NotificationHook AS DWORD
  NotificationUnhook AS DWORD
END TYPE

' KERNEL32.DLL function declarations

'declare function LoadLibrary lib "KERNEL32.DLL" _______________________________
'          alias "LoadLibraryA"               (lpLibFileName as asciiz         _
'                                                          ) as long

DECLARE FUNCTION GetProcAddress LIB "KERNEL32.DLL" ____________________________
          ALIAS "GetProcAddress"             (BYVAL hModule AS DWORD,         _
                                                 lpProcName AS ASCIIZ         _
                                                          ) AS LONG

DECLARE FUNCTION GetModuleHandle LIB "KERNEL32.DLL" ___________________________
          ALIAS "GetModuleHandleA"            (lpModuleName AS ASCIIZ         _
                                                          ) AS DWORD

' USER32.DLL function declarations

DECLARE FUNCTION SetWindowLong LIB "USER32.DLL" _______________________________
          ALIAS "SetWindowLongA"                (BYVAL hWnd AS DWORD,         _
                                               BYVAL nIndex AS LONG,          _
                                             BYVAL lNewLong AS LONG           _
                                                          ) AS LONG

DECLARE FUNCTION GetWindowLong LIB "USER32.DLL" _______________________________
          ALIAS "GetWindowLongA"                (BYVAL hWnd AS DWORD,         _
                                               BYVAL nIndex AS LONG           _
                                                          ) AS LONG

DECLARE FUNCTION CallWindowProc LIB "USER32.DLL" ______________________________
          ALIAS "CallWindowProcA"      (BYVAL lpPrevWndFunc AS DWORD,         _
                                                 BYVAL hWnd AS DWORD,         _
                                                 BYVAL uMsg AS DWORD,         _
                                               BYVAL wParam AS DWORD,         _
                                               BYVAL lParam AS LONG           _
                                                          ) AS LONG

DECLARE FUNCTION GetDlgItem LIB "USER32.DLL" __________________________________
          ALIAS "GetDlgItem"                    (BYVAL hDlg AS DWORD,         _
                                           BYVAL nIDDlgItem AS LONG           _
                                                          ) AS DWORD

DECLARE FUNCTION GetClientRect LIB "USER32.DLL" _______________________________
          ALIAS "GetClientRect"                 (BYVAL hwnd AS DWORD,         _
                                                     lpRect AS RECT           _
                                                          ) AS LONG

'declare function GetDC lib "USER32.DLL" _______________________________________
'          alias "GetDC"                         (byval hWnd as dword          _
'                                                          ) as dword

DECLARE FUNCTION GetDlgCtrlID LIB "USER32.DLL" ________________________________
          ALIAS "GetDlgCtrlID"                  (BYVAL hWnd AS DWORD          _
                                                          ) AS LONG

'declare function GetParent lib "USER32.DLL" ___________________________________
'          alias "GetParent"                     (byval hWnd as dword          _
'                                                          ) as long

DECLARE FUNCTION SendMessage LIB "USER32.DLL" _________________________________
          ALIAS "SendMessageA"                  (BYVAL hWnd AS DWORD,         _
                                                BYVAL dwMsg AS DWORD,         _
                                               BYVAL wParam AS DWORD,         _
                                               BYVAL lParam AS LONG           _
                                                          ) AS LONG

DECLARE FUNCTION SendDlgItemMessage LIB "USER32.DLL" __________________________
          ALIAS "SendDlgItemMessageA"           (BYVAL hDlg AS DWORD,         _
                                           BYVAL nIDDlgItem AS LONG,          _
                                                 BYVAL wMsg AS DWORD,         _
                                               BYVAL wParam AS DWORD,         _
                                               BYVAL lParam AS LONG           _
                                                          ) AS LONG

DECLARE FUNCTION TrackMouseEvent LIB "USER32.DLL" _____________________________
          ALIAS "TrackMouseEvent"         (lpEventTrack AS TRACKMOUSEEVENTAPI _
                                                      ) AS LONG               _

DECLARE FUNCTION InvalidateRect LIB "USER32.DLL" ______________________________
          ALIAS "InvalidateRect"                (BYVAL hWnd AS DWORD,         _
                                                     lpRect AS RECT,          _
                                               BYVAL bErase AS LONG           _
                                                          ) AS LONG

DECLARE FUNCTION UpdateWindow LIB "USER32.DLL" ________________________________
          ALIAS "UpdateWindow"                  (BYVAL hWnd AS DWORD          _
                                                          ) AS LONG

'declare function GetSysColor lib "USER32.DLL" _________________________________
'          alias "GetSysColor"                 (byval nIndex as long           _
'                                                          ) as long

'declare function GetSysColorBrush lib "USER32.DLL" ____________________________
'          alias "GetSysColorBrush"            (byval nIndex as long           _
'                                                          ) as long

DECLARE FUNCTION InflateRect LIB "USER32.DLL" _________________________________
          ALIAS "InflateRect"                       (lpRect AS RECT,          _
                                                    BYVAL x AS LONG,          _
                                                    BYVAL y AS LONG           _
                                                          ) AS LONG

DECLARE FUNCTION FrameRect LIB "USER32.DLL" ___________________________________
          ALIAS "FrameRect"                      (BYVAL hDC AS DWORD,         _
                                                     lpRect AS RECT,          _
                                               BYVAL hBrush AS DWORD          _
                                                          ) AS LONG

DECLARE FUNCTION FillRect LIB "USER32.DLL" ____________________________________
          ALIAS "FillRect"                       (BYVAL hDC AS DWORD,         _
                                                     lpRect AS RECT,          _
                                               BYVAL hBrush AS DWORD          _
                                                          ) AS LONG

DECLARE FUNCTION DrawFrameControl LIB "USER32.DLL" ____________________________
          ALIAS "DrawFrameControl"               (BYVAL hDC AS DWORD,         _
                                                     lpRect AS RECT,          _
                                                BYVAL uType AS LONG,          _
                                               BYVAL uState AS LONG           _
                                                          ) AS LONG

DECLARE FUNCTION DrawFocusRect LIB "USER32.DLL" _______________________________
          ALIAS "DrawFocusRect"                  (BYVAL hDC AS DWORD,         _
                                                     lpRect AS RECT           _
                                                          ) AS LONG

DECLARE FUNCTION OffsetRect LIB "USER32.DLL" __________________________________
          ALIAS "OffsetRect"                        (lpRect AS RECT,          _
                                                    BYVAL x AS LONG,          _
                                                    BYVAL y AS LONG           _
                                                          ) AS LONG

DECLARE FUNCTION GetFocus LIB "USER32.DLL" ____________________________________
          ALIAS "GetFocus"                               () AS DWORD

DECLARE FUNCTION IsWindowEnabled LIB "USER32.DLL" _____________________________
          ALIAS "IsWindowEnabled"               (BYVAL hWnd AS DWORD          _
                                                          ) AS LONG

DECLARE FUNCTION GetSystemMetrics LIB "USER32.DLL" ____________________________
          ALIAS "GetSystemMetrics"            (BYVAL nIndex AS LONG           _
                                                          ) AS LONG

DECLARE FUNCTION LoadImage LIB "USER32.DLL" ___________________________________
          ALIAS "LoadImageA"                   (BYVAL hInst AS DWORD,         _
                                                       lpsz AS ASCIIZ,        _
                                                BYVAL uType AS DWORD,         _
                                            BYVAL cxDesired AS LONG,          _
                                            BYVAL cyDesired AS LONG,          _
                                               BYVAL fuLoad AS DWORD          _
                                                          ) AS DWORD

DECLARE FUNCTION DrawState LIB "USER32.DLL" ___________________________________
          ALIAS "DrawStateA"                     (BYVAL hDC AS DWORD,         _
                                               BYVAL hBrush AS DWORD,         _
                                      BYVAL lpDrawStateProc AS DWORD,         _
                                               BYVAL lParam AS LONG,          _
                                               BYVAL wParam AS DWORD,         _
                                                    BYVAL x AS LONG,          _
                                                    BYVAL y AS LONG,          _
                                                   BYVAL cx AS LONG,          _
                                                   BYVAL cy AS LONG,          _
                                              BYVAL fuFlags AS DWORD          _
                                                          ) AS LONG

DECLARE FUNCTION GetClassName LIB "USER32.DLL" ________________________________
          ALIAS "GetClassNameA"                 (BYVAL hwnd AS DWORD,         _
                                                lpClassName AS ASCIIZ,        _
                                            BYVAL nMaxCount AS LONG           _
                                                          ) AS LONG

'declare function SetFocus lib "USER32.DLL" ____________________________________
'          alias "SetFocus"                      (byval hWnd as dword          _
'                                                          ) as long

' GDI32.DLL function declarations

DECLARE FUNCTION CreateSolidBrush LIB "GDI32.DLL" _____________________________
          ALIAS "CreateSolidBrush"           (BYVAL crColor AS DWORD          _
                                                          ) AS DWORD

DECLARE FUNCTION SelectObject LIB "GDI32.DLL"__________________________________
          ALIAS "SelectObject"                   (BYVAL hdc AS DWORD,         _
                                              BYVAL hObject AS DWORD          _
                                                          ) AS DWORD

DECLARE FUNCTION DeleteObject LIB "GDI32.DLL" _________________________________
          ALIAS "DeleteObject"               (BYVAL hObject AS DWORD          _
                                                          ) AS LONG

DECLARE FUNCTION SetBkMode LIB "GDI32.DLL" ____________________________________
          ALIAS "SetBkMode"                      (BYVAL hdc AS DWORD,         _
                                              BYVAL nBkMode AS LONG           _
                                                          ) AS LONG

DECLARE FUNCTION SetTextColor LIB "GDI32.DLL" _________________________________
          ALIAS "SetTextColor"                   (BYVAL hdc AS DWORD,         _
                                              BYVAL crColor AS DWORD          _
                                                          ) AS DWORD

DECLARE FUNCTION GetTextExtentPoint32 LIB "GDI32.DLL" _________________________
          ALIAS "GetTextExtentPoint32A"          (BYVAL hdc AS DWORD,         _
                                                       lpsz AS ASCIIZ,        _
                                             BYVAL cbString AS LONG,          _
                                                     lpSize AS SIZEL          _
                                                          ) AS LONG

' GDIPLUS.DLL function declarations
' GDI+ was introduced with Windows XP but is available as a redistributable
' for earlier systems. Dynamic linking is used. GDIPLUS.DLL must be present.

DECLARE FUNCTION GdipSetClipRectI LIB "GDIPLUS.DLL" ___________________________
          ALIAS "GdipSetClipRectI"        (BYVAL GpGraphics AS DWORD,         _
                                                BYVAL xLeft AS LONG,          _
                                                 BYVAL yTop AS LONG,          _
                                               BYVAL xWidth AS LONG,          _
                                              BYVAL yHeight AS LONG,          _
                                          BYVAL CombineMode AS LONG           _
                                                          ) AS LONG

DECLARE FUNCTION GdiplusStartup LIB "GDIPLUS.DLL" _____________________________
          ALIAS "GdiplusStartup"         (BYREF Token AS DWORD,               _
                                   BYREF StartupInput AS GdiplusStartupInput, _
                                  BYREF StartupOutout AS GdiplusStartupOutput _
                                                    ) AS LONG

DECLARE FUNCTION GdiplusShutdown LIB "GDIPLUS.DLL" ____________________________
          ALIAS "GdiplusShutdown"              (BYVAL Token AS DWORD          _
                                                          ) AS LONG

DECLARE FUNCTION GdipCreateFromHDC LIB "GDIPLUS.DLL" __________________________
          ALIAS "GdipCreateFromHDC"              (BYVAL hDC AS DWORD,         _
                                           BYREF GpGraphics AS DWORD          _
                                                          ) AS LONG

DECLARE FUNCTION GdipDeleteGraphics LIB "GDIPLUS.DLL" _________________________
          ALIAS "GdipDeleteGraphics"      (BYVAL GpGraphics AS DWORD          _
                                                          ) AS LONG

DECLARE FUNCTION GdipSetSmoothingMode LIB "GDIPLUS.DLL" _______________________
          ALIAS "GdipSetSmoothingMode"    (BYVAL GpGraphics AS DWORD,         _
                                      BYVAL GpSmoothingMode AS LONG           _
                                                          ) AS LONG

DECLARE FUNCTION GdipCreateSolidFill LIB "GDIPLUS.DLL" ________________________
          ALIAS "GdipCreateSolidFill"      (BYVAL ColorARGB AS DWORD,         _
                                              BYREF GpBrush AS DWORD          _
                                                          ) AS LONG

DECLARE FUNCTION GdipFillRectangleI LIB "GDIPLUS.DLL" _________________________
          ALIAS "GdipFillRectangleI"      (BYVAL GpGraphics AS DWORD,         _
                                              BYVAL GpBrush AS DWORD,         _
                                                BYVAL xLeft AS LONG,          _
                                                 BYVAL yTop AS LONG,          _
                                               BYVAL xWidth AS LONG,          _
                                              BYVAL yHeight AS LONG           _
                                                          ) AS LONG

DECLARE FUNCTION GdipFillEllipseI LIB "GDIPLUS.DLL" ___________________________
          ALIAS "GdipFillEllipseI"        (BYVAL GpGraphics AS DWORD,         _
                                              BYVAL GpBrush AS DWORD,         _
                                                BYVAL xLeft AS LONG,          _
                                                 BYVAL yTop AS LONG,          _
                                               BYVAL xWidth AS LONG,          _
                                              BYVAL yHeight AS LONG           _
                                                          ) AS LONG

DECLARE FUNCTION GdipDeleteBrush LIB "GDIPLUS.DLL" ____________________________
          ALIAS "GdipDeleteBrush"            (BYVAL GpBrush AS DWORD          _
                                                          ) AS LONG

' UXTHEME.DLL function declarations
' LoadLibrary and GetProcAddress wrappers are used rather than the dynamic
' linking used for other libraries to avoid failure on pre-XP systems.

FUNCTION GetThemeProcAddress __________________________________________________
                                               (ProcName_SZ AS ASCIIZ         _
                                                          ) AS DWORD
STATIC s_ThemeModule_DW AS DWORD
IF s_ThemeModule_DW = 0 THEN
  s_ThemeModule_DW = LoadLibrary("uxTheme.dll")
  IF s_ThemeModule_DW = 0 THEN EXIT FUNCTION
END IF
GetThemeProcAddress = GetProcAddress(s_ThemeModule_DW, ProcName_SZ)
END FUNCTION

FUNCTION IsThemeActive ________________________________________________________
                                                         () AS LONG
LOCAL ProcAddress_DW AS DWORD
LOCAL Result_LG AS LONG
ProcAddress_DW = GetThemeProcAddress("IsThemeActive")
IF ProcAddress_DW = 0 THEN EXIT FUNCTION
CALL DWORD ProcAddress_DW USING IsThemeActive() TO Result_LG
FUNCTION = Result_LG
END FUNCTION

FUNCTION IsThemeDialogTextureEnabled __________________________________________
                                                (BYVAL hwnd AS DWORD          _
                                                          ) AS DWORD
LOCAL ProcAddress_DW AS DWORD
LOCAL Result_DW AS DWORD
ProcAddress_DW = GetThemeProcAddress("IsThemeDialogTextureEnabled")
IF ProcAddress_DW = 0 THEN EXIT FUNCTION
CALL DWORD ProcAddress_DW USING IsThemeDialogTextureEnabled(hwnd) TO Result_DW
FUNCTION = Result_DW
END FUNCTION

FUNCTION OpenThemeData ________________________________________________________
                                                (BYVAL hwnd AS DWORD,         _
                                         BYVAL pszClassList AS DWORD          _
                                                          ) AS DWORD
LOCAL ProcAddress_DW AS DWORD
LOCAL Result_DW AS DWORD
ProcAddress_DW = GetThemeProcAddress("OpenThemeData")
IF ProcAddress_DW = 0 THEN EXIT FUNCTION
CALL DWORD ProcAddress_DW USING OpenThemeData(hwnd, pszClassList) TO Result_DW
FUNCTION = Result_DW
END FUNCTION

FUNCTION DrawThemeBackground __________________________________________________
                                              (BYVAL hTheme AS DWORD,         _
                                                  BYVAL hdc AS DWORD,         _
                                              BYVAL iPartId AS LONG,          _
                                             BYVAL iStateId AS LONG,          _
                                                BYREF pRect AS RECT,          _
                                            BYREF pClipRect AS RECT           _
                                                          ) AS LONG
LOCAL ProcAddress_DW AS DWORD
LOCAL Result_LG AS LONG
ProcAddress_DW = GetThemeProcAddress("DrawThemeBackground")
IF ProcAddress_DW = 0 THEN EXIT FUNCTION
CALL DWORD ProcAddress_DW USING DrawThemeBackground(hTheme, hdc, iPartId _
, iStateId, pRect, BYVAL VARPTR(pClipRect)) TO Result_LG
FUNCTION = Result_LG
END FUNCTION

FUNCTION GetThemeBackgroundContentRect ________________________________________
                                              (BYVAL hTheme AS DWORD,         _
                                                  BYVAL hdc AS DWORD,         _
                                              BYVAL iPartId AS LONG,          _
                                             BYVAL iStateId AS LONG,          _
                                        BYREF pBoundingRect AS RECT,          _
                                         BYREF pContentRect AS RECT           _
                                                          ) AS LONG
LOCAL ProcAddress_DW AS DWORD
LOCAL Result_LG AS LONG
ProcAddress_DW = GetThemeProcAddress("GetThemeBackgroundContentRect")
IF ProcAddress_DW = 0 THEN EXIT FUNCTION
CALL DWORD ProcAddress_DW USING GetThemeBackgroundContentRect(hTheme, hdc _
, iPartId, iStateId, pBoundingRect, pContentRect) TO Result_LG
FUNCTION = Result_LG
END FUNCTION

'------------------------------------------------------------------------------
