' Tool tips include file
'
'  version 1.0    20/5/2003  Graham McPhee
'
#IF NOT %DEF(%EOToolTipsINC)
  %EOToolTipsINC = 1
  '
#IF NOT %DEF(%WINAPI)
  #INCLUDE "WIN32API.INC"
#ENDIF
'
#IF NOT %DEF(%COMDLG32_INC)
  #INCLUDE "Comdlg32.inc"
#ENDIF
'
#IF NOT %DEF(%COMMCTRL_INC)
  #INCLUDE "Commctrl.inc"
#ENDIF
'------------------------------------------
GLOBAL hToolTips AS LONG
'------------------------------------------
%TTS_ALWAYSTIP     = &H01
%TTS_BALLOON       = &H40
%TTF_IDISHWND      = &H0001
%TTF_SUBCLASS      = &H0010
%TTM_ADDTOOL       = %WM_USER +  4
%TTM_DELTOOL       = %WM_USER +  5
%TTM_GETTOOLINFO   = %WM_USER +  8
'------------------------------------------
$txtCRLF = CHR$(13)
'------------------------------------------
DECLARE SUB InitCommonControls LIB "COMCTL32.DLL" ALIAS "InitCommonControls" ()
'------------------------------------------
'いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい
' Internal use only - create tooltips control if needed.
'いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい
FUNCTION ToolTip_Create (BYVAL hWnd AS LONG) AS LONG
  IF hToolTips = 0 THEN
     IF hWnd = 0 THEN hWnd = GetActiveWindow()
     IF hWnd = 0 THEN EXIT FUNCTION
     CALL InitCommonControls
     hToolTips = CreateWindowEx(0, "tooltips_class32", "", %TTS_ALWAYSTIP OR %TTS_BALLOON, _
             0, 0, 0, 0, hWnd, BYVAL 0&, GetModuleHandle(""), BYVAL %NULL)
     DIALOG SEND hToolTips, %TTM_SETMAXTIPWIDTH, 0, 300
  END IF
  FUNCTION = hToolTips
END FUNCTION
'いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい
' Add a tooltip to a window/control
'いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい
FUNCTION ToolTip_SetToolTip (BYVAL hWnd AS LONG, BYVAL TXT AS STRING, _
         OPTIONAL lngBColour AS LONG, _
         OPTIONAL lngTColour AS LONG) AS LONG
         '
  ' set the tooltip on the control
  '
  LOCAL lngBkgColour AS LONG ' background colour on the tooltip
  LOCAL lngTxtColour AS LONG ' text colour on the tooltip
  '
  IF ISMISSING(lngBColour) THEN
  ' no optional parameter - set the defaults
    lngBkgColour = %WHITE
    lngTxtColour = %BLACK
  ELSE
  ' take colours from parameters passed in
    lngBkgColour = lngBColour
    lngTxtColour = lngTColour
  END IF
  '
  LOCAL ti AS TOOLINFO
  IF ToolTip_Create(GetParent(hWnd)) = 0 THEN EXIT FUNCTION 'ensure creation
  REPLACE "|" WITH $txtCRLF IN TXT
  ti.cbSize   = LEN(ti)
  ti.uFlags   = %TTF_SUBCLASS OR %TTF_IDISHWND
  ti.hWnd     = GetParent(hWnd)
  ti.uId      = hWnd
  'Remove existing tooltip
  IF SendMessage (hToolTips, %TTM_GETTOOLINFO, 0, BYVAL VARPTR(ti)) THEN
     SendMessage hToolTips, %TTM_DELTOOL, 0, BYVAL VARPTR(ti)
  END IF
  ti.cbSize   = LEN(ti)
  ti.uFlags   = %TTF_SUBCLASS OR %TTF_IDISHWND
  ti.hWnd     = GetParent(hWnd)
  ti.uId      = hWnd
  ti.lpszText = STRPTR(TXT)
  '
  ' To allow ToolTip Color in Themed Dialog
  SetWindowTheme(hToolTips, " ", " ")
  '
  FUNCTION = SendMessage(hToolTips, %TTM_ADDTOOL, 0, _
                         BYVAL VARPTR(ti)) 'add tooltip
                         '
  Sendmessage hTooltips,%TTM_SETTIPBKCOLOR ,lngBkgColour,&H00000000
  Sendmessage hTooltips,%TTM_SETTIPTEXTCOLOR ,lngTxtColour,&H00000000
  '
END FUNCTION
'
FUNCTION SetWindowTheme (BYVAL hwnd AS DWORD, _
                         BYREF pszSubAppName AS WSTRINGZ, _
                         BYREF pszSubIdList AS WSTRINGZ) AS LONG
' set the window theme
  LOCAL hr AS LONG
  LOCAL hLib AS DWORD
  LOCAL pProc AS DWORD
  '
  hLib = LoadLibrary("UxTheme.dll")
  IF hLib = %NULL THEN
    FUNCTION = GetLastError
    EXIT FUNCTION
  END IF
  '
  pProc = GetProcAddress(hLib, "SetWindowTheme")
  IF pProc = %NULL THEN
    hr = GetLastError
  ELSE
    CALL DWORD pProc USING SetWindowTheme(hwnd, _
                                          pszSubAppName, _
                                          pszSubIdList) TO hr
  END IF
  ' free up the library
  FreeLibrary hLib
  FUNCTION = hr
  '
END FUNCTION
'
#ENDIF
