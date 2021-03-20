' Tool tips include file
'
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
#IF NOT %DEF(%TTM_ADDTOOL)
  %TTM_ADDTOOL       = %WM_USER +  4
#ENDIF
#IF NOT %DEF(%TTM_DELTOOL)
  %TTM_DELTOOL       = %WM_USER +  5
#ENDIF
#IF NOT %DEF(%TTM_GETTOOLINFO)
  %TTM_GETTOOLINFO   = %WM_USER +  8
#ENDIF
'------------------------------------------

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
FUNCTION ToolTip_SetToolTip (BYVAL hWnd AS LONG, BYVAL strText AS STRING) AS LONG
  LOCAL ti AS TOOLINFO
  IF ToolTip_Create(GetParent(hWnd)) = 0 THEN EXIT FUNCTION 'ensure creation
  REPLACE "|" WITH $CR IN strText
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
  ti.lpszText = STRPTR(strText)
  ' disable the XP theme for this control so we have control over the colours
  DisableXPThemeTT  hToolTips
  ' set the foreground and background colours to the tooltip
  SendMessage(hToolTips, %TTM_SETTIPTEXTCOLOR, %BLACK , 0)
  SendMessage(hToolTips, %TTM_SETTIPBKCOLOR, %YELLOW, 0 )
  FUNCTION = SendMessage(hToolTips, %TTM_ADDTOOL, 0, BYVAL VARPTR(ti)) 'add tooltip
  '
END FUNCTION
'
FUNCTION DisableXPThemeTT(BYVAL hControl AS DWORD) AS LONG
' called to disable the XP themes to allow better
' control over the colours of the control
'
  LOCAL hLib AS DWORD, pProc AS DWORD, lRes AS LONG
  hLib = LoadLibrary("UxTheme.dll")
  IF hLib THEN
    pProc = GetProcAddress(hLib, "SetWindowTheme")
    IF pProc THEN
      CALL DWORD pProc USING _
                 SetWindowTheme(hControl, " ", " ")  TO lRes
      FUNCTION = lRes
    END IF
    FreeLibrary hLib
  END IF
END FUNCTION
'
#ENDIF
