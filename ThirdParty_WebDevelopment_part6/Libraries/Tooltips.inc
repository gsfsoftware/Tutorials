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
FUNCTION ToolTip_SetToolTip (BYVAL hWnd AS LONG, BYVAL txt AS STRING) AS LONG
  LOCAL ti AS TOOLINFO
  IF ToolTip_Create(GetParent(hWnd)) = 0 THEN EXIT FUNCTION 'ensure creation
  REPLACE "|" WITH $txtCRLF IN txt
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
  ti.lpszText = STRPTR(txt)
  FUNCTION = SendMessage(hToolTips, %TTM_ADDTOOL, 0, BYVAL VARPTR(ti)) 'add tooltip
END FUNCTION

#ENDIF
