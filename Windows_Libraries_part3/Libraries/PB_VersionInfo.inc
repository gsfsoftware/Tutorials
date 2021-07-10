' PB_VersionInfo.inc

FUNCTION funInitExeVersionControl() AS LONG
  LOCAL wc AS WNDCLASSEX, szName AS ASCIIZ * 20
  szName       = "PbCustomExeLabel"
  wc.cbSize    = LEN(wc)
  wc.hInstance = GetModuleHandle("")
  IF GetClassInfoEx(wc.hInstance, szName, wc) = 0 THEN 'if not already registered
      wc.Style         = %CS_DBLCLKS
      wc.lpfnWndProc   = CODEPTR(PbCustomExeLabelProc)
      wc.cbWndExtra    = 4  ' 4 extra bytes
      wc.hCursor       = LoadCursor(%NULL, BYVAL %IDC_HAND)  ' hand cursor
      wc.hbrBackground = 0 ' GetSysColorBrush(%COLOR_HIGHLIGHT)  ' highlight background, or whatever..
      wc.lpszClassName = VARPTR(szName)
      RegisterClassEx wc
  END IF
END FUNCTION
'
FUNCTION PbCustomExeLabelProc (BYVAL hWnd AS DWORD, BYVAL wMsg AS DWORD, _
                               BYVAL wParam AS DWORD, BYVAL lParam AS LONG) AS LONG
  LOCAL c, oldMode, oldTextColor AS LONG
  LOCAL sBuf AS STRING, rc AS RECT, ps AS PAINTSTRUCT
  LOCAL strVersion AS STRING

  SELECT CASE wMsg
  CASE %WM_INITDIALOG

  CASE %WM_CREATE   ' entry point
  CASE %WM_DESTROY  ' exit point
  CASE %WM_PAINT
    '
      strVersion = funGetEXEVersion
     ' c = len(strVersion)
     ' c = GetWindowTextLength(hWnd)  ' grab control's text
      'sBuf = STRING$(c+1, $SPC)      ' size string buffer
      sBuf = strVersion & $SPC
      'GetWindowText(hWnd, BYVAL STRPTR(sBuf), LEN(sBuf))
      GetClientRect hWnd, rc         ' grab text area

      BeginPaint hWnd, ps
        'oldMode = SetBkMode(ps.hDC, %TRANSPARENT)
        SetBkMode(ps.hDC, %TRANSPARENT)
        'oldTextColor = SetTextColor(ps.hDC, %gray)
        SetTextColor(ps.hDC, %GRAY)
        ' draw control's text centered and vcentered (single line only) in control
        DrawText ps.hDC, BYVAL STRPTR(sBuf), -1, rc, _
                         %DT_LEFT OR %DT_VCENTER OR %DT_SINGLELINE
        'SetBkMode(ps.hDC, oldMode)         ' restore bk mode
        'SetTextColor(ps.hDC, oldTextColor) ' restore text color
      EndPaint hWnd, ps

    CASE %WM_LBUTTONDBLCLK
    CASE %WM_LBUTTONDOWN
    CASE %WM_LBUTTONUP
    CASE %WM_MOUSEMOVE
    CASE %WM_KEYDOWN
  END SELECT
  '
  FUNCTION = DefWindowProc(hWnd, wMsg, wParam, lParam)

END FUNCTION
'
'
FUNCTION funGetEXEVersion() AS STRING
' return the version of this exe
  DIM strFile AS ASCIIZ * %MAX_PATH
  LOCAL strVersion AS STRING
  LOCAL Built AS IPOWERTIME
  '
  ' default to this executable
  strFile =  EXE.FULL$
  '
  LET Built = CLASS "PowerTime"
  Built.FileTime = %PB_COMPILETIME
  '
  strVersion =  "Exe Version " & GetVersionInfo(strFile,"") & _
                " - " & Built.DateString & " " & Built.TimeString
  '
  FUNCTION = strVersion
'
END FUNCTION
'
FUNCTION GetVersionInfo(BYVAL sFile AS STRING, BYVAL sItem AS STRING) AS STRING
  LOCAL pLang AS LONG PTR, sLangID AS STRING, fvTail AS STRING, pvTail AS STRING, sBuf AS STRING
  LOCAL bSize AS LONG, prtValue AS ASCIIZ PTR, dwDummy AS DWORD, ffi AS VS_FIXEDFILEINFO PTR
  DIM strMajor AS STRING
  DIM strMinor AS STRING
  DIM strRevision AS STRING
  DIM strBuild AS STRING
  '
  ' Obtain the version block
  bSize = GetFileVersionInfoSize(BYCOPY sFile, dwDummy)
  IF ISFALSE bSize THEN EXIT FUNCTION
  sBuf = SPACE$(bSize)
  IF ISFALSE GetFileVersionInfo(BYCOPY sFile, 0, bSize, BYVAL STRPTR(sBuf)) THEN EXIT FUNCTION
  ' If string item was specified, attempt to obtain it
  IF LEN(sItem) THEN
   ' Check language id - default to American English if not found
   IF ISFALSE VerQueryValue(BYVAL STRPTR(sBuf), "\VarFileInfo\Translation", pLang, dwDummy) THEN
     sLangID = "040904E4" ' American English/ANSI
   ELSE
     sLangID = HEX$(LOWRD(@pLang), 4) + HEX$(HIWRD(@pLang), 4)
   END IF
   ' Get the string information from the resource and return it
   IF VerQueryValue(BYVAL STRPTR(sBuf), "\StringFileInfo\" + sLangID + "\" + sItem, prtValue, dwDummy) THEN
     FUNCTION = @prtValue
   END IF
   '
  ELSE
  ' Otherwise, query the numeric version value
    IF VerQueryValue(BYVAL STRPTR(sBuf), "\", BYVAL VARPTR(ffi), dwDummy) THEN
      fvTail = FORMAT$(LOWRD(@ffi.dwFileVersionLS), "00")
      pvTail = FORMAT$(LOWRD(@ffi.dwProductVersionLS), "00")
      IF HIWRD(@ffi.dwFileversionLS) THEN fvTail = FORMAT$(HIWRD(@ffi.dwFileVersionLS), "00") + fvTail
      IF HIWRD(@ffi.dwProductVersionLS) THEN pvTail = FORMAT$(HIWRD(@ffi.dwProductVersionLS), "00") + pvTail
      strMajor = FORMAT$(HIWRD(@ffi.dwFileVersionMS))
      strMinor = FORMAT$(LOWRD(@ffi.dwFileVersionMS))
      strRevision = FORMAT$(HIWRD(@ffi.dwFileVersionLS))
      strBuild = FORMAT$(LOWRD(@ffi.dwFileVersionLS))
      FUNCTION =   strMajor & "." & strMinor & "." & strRevision & "." & strBuild '   FORMAT$(HIWRD(@ffi.dwFileVersionMS)) + "." + FORMAT$(LOWRD(@ffi.dwFileVersionMS), "00") + "." + fvTail
    END IF
  END IF
END FUNCTION
