' Main source code file:  pbcodec.bas
' Resulting include file: pbcodec.inc
'
' Created by inClean v1.26, 08-11-2003, 01:09:26
' Press Help-button for some useful information and tips.
'
'  25205 lines of include file data read and compared against
'   1494 lines of code in 7.97 seconds.
'
'-----------------------------------------------------------------
' Equates:  38
'-----------------------------------------------------------------
%WINAPI                                         = 1
%TRUE                                           = -1
%FALSE                                          = 0
%NULL                                           = 0
%ERROR_SUCCESS                                  = 0&
%INVALID_HANDLE_VALUE                           = &HFFFFFFFF???
%KEY_QUERY_VALUE                                = &H1
%MAX_PATH                                       = 260  ' max. length of full pathname
%SW_SHOWNORMAL                                  = 1
%WM_DESTROY                                     = &H2
%WM_NOTIFY                                      = &H4E
%WM_INITDIALOG                                  = &H110
%WM_COMMAND                                     = &H111
%WM_TIMER                                       = &H113
%WM_CTLCOLORSTATIC                              = &H138
%WM_DROPFILES                                   = &H233
%WS_CAPTION                                     = &H00C00000  ' WS_BORDER OR WS_DLGFRAME
%WS_SYSMENU                                     = &H00080000
%WS_MINIMIZEBOX                                 = &H00020000
%WS_EX_CLIENTEDGE                               = &H00000200
%SWP_NOSIZE                                     = &H1
%SWP_NOMOVE                                     = &H2
%SWP_NOZORDER                                   = &H4
%HWND_TOPMOST                                   = &HFFFFFFFF???
%COLOR_INFOBK                                   = 24
%IDOK                                           = 1
%IDCANCEL                                       = 2
%SS_CENTER                                      = &H00000001
%SPI_GETWORKAREA                                = 48
%cmb1                                           = &H470
%HKEY_CURRENT_USER                              = &H80000001
%HKEY_LOCAL_MACHINE                             = &H80000002
%VER_PLATFORM_WIN32_NT                          = 2
%OFN_HIDEREADONLY                               = &H00000004
%OFN_FILEMUSTEXIST                              = &H00001000
%OFN_EXPLORER                                   = &H00080000 ' new look commdlg
%CDN_FIRST                                      = 0-601       ' common dialog new
%CDN_INITDONE                                   = %CDN_FIRST - &H0000
%OFN_FILEBUFFERSIZE                             = 8192


%IDC_CheckBox2                                  = 131
%CheckBox_Includes                              = 132
%CheckBox_UnusedFxs                             = 133
%CheckBox_UnusedSubs                            = 134
%CheckBox_DeclaredButNonExistant                = 135
%CheckBox_UnusedGlobals                         = 136
%CheckBox_UnusedLocals                          = 137
%CheckBox_GlobalLocalMix                        = 138
%CheckBox_DupeGlobal                            = 139
%CheckBox_TotRefCount                           = 140
%CheckBox_SubRefCount                           = 141
%CheckBox_GlobalVariableRpt                     = 142
%CheckBox_StringLiterals                        = 143
%CheckBox_ConstantsRpt                          = 144

%Btn_SelectAll                                  = 150
%Btn_UnselectAll                                = 151
%Btn_Unused                                     = 152
%Btn_Reports                                    = 153

%Frame1                                         = 160
%Frame2                                         = 161
%Frame3                                         = 162

'-----------------------------------------------------------------
' TYPE and UNION structures:  8
'-----------------------------------------------------------------
TYPE RECT
  nLeft AS LONG
  nTop AS LONG
  nRight AS LONG
  nBottom AS LONG
END TYPE



TYPE FILETIME
  dwLowDateTime AS DWORD
  dwHighDateTime AS DWORD
END TYPE

TYPE WIN32_FIND_DATA
  dwFileAttributes AS DWORD
  ftCreationTime AS FILETIME
  ftLastAccessTime AS FILETIME
  ftLastWriteTime AS FILETIME
  nFileSizeHigh AS DWORD
  nFileSizeLow AS DWORD
  dwReserved0 AS DWORD
  dwReserved1 AS DWORD
  cFileName AS ASCIIZ * %MAX_PATH
  cAlternateFileName AS ASCIIZ * 14
END TYPE

TYPE OSVERSIONINFO
  dwOSVersionInfoSize AS DWORD
  dwMajorVersion AS DWORD
  dwMinorVersion AS DWORD
  dwBuildNumber AS DWORD
  dwPlatformId AS DWORD
  szCSDVersion AS ASCIIZ * 128          'Maintenance string for PSS usage
END TYPE

TYPE NMHDR
  hwndFrom AS DWORD
  idfrom AS DWORD
  CODE AS LONG    ' used for messages, so needs to be LONG, not DWORD...
END TYPE

TYPE OPENFILENAME
    lStructSize       AS DWORD
    hWndOwner         AS LONG
    hInstance         AS LONG
    lpstrFilter       AS ASCIIZ PTR
    lpstrCustomFilter AS ASCIIZ PTR
    nMaxCustFilter    AS DWORD
    nFilterIndex      AS DWORD
    lpstrFile         AS ASCIIZ PTR
    nMaxFile          AS DWORD
    lpstrFileTitle    AS ASCIIZ PTR
    nMaxFileTitle     AS DWORD
    lpstrInitialDir   AS ASCIIZ PTR
    lpstrTitle        AS ASCIIZ PTR
    Flags             AS DWORD
    nFileOffset       AS WORD
    nFileExtension    AS WORD
    lpstrDefExt       AS ASCIIZ PTR
    lCustData         AS LONG
    lpfnHook          AS DWORD
    lpTemplateName    AS ASCIIZ PTR
END TYPE

TYPE OPENFILENAMEEX
    lStructSize       AS DWORD
    hWndOwner         AS DWORD
    hInstance         AS DWORD
    lpstrFilter       AS ASCIIZ PTR
    lpstrCustomFilter AS ASCIIZ PTR
    nMaxCustFilter    AS DWORD
    nFilterIndex      AS DWORD
    lpstrFile         AS ASCIIZ PTR
    nMaxFile          AS DWORD
    lpstrFileTitle    AS ASCIIZ PTR
    nMaxFileTitle     AS DWORD
    lpstrInitialDir   AS ASCIIZ PTR
    lpstrTitle        AS ASCIIZ PTR
    Flags             AS DWORD
    nFileOffset       AS WORD
    nFileExtension    AS WORD
    lpstrDefExt       AS ASCIIZ PTR
    lCustData         AS LONG
    lpfnHook          AS DWORD
    lpTemplateName    AS ASCIIZ PTR
    '--- new Windows 2000 structure members ---
    pvReserved        AS DWORD
    dwReserved        AS DWORD
    FlagsEx           AS DWORD
END TYPE

TYPE TAGOFNOTIFY
    hdr     AS NMHDR
    lpOFN   AS OPENFILENAME
    pszFile AS ASCIIZ PTR
END TYPE

'-----------------------------------------------------------------
' Declared Functions:  23
'-----------------------------------------------------------------
DECLARE FUNCTION DragQueryFile LIB "SHELL32.DLL" ALIAS "DragQueryFileA" (BYVAL hDrop AS DWORD, BYVAL uiFile AS DWORD, lpStr AS ASCIIZ, BYVAL cch AS DWORD) AS DWORD
DECLARE FUNCTION FindClose LIB "KERNEL32.DLL" ALIAS "FindClose" (BYVAL hFindFile AS DWORD) AS LONG
DECLARE FUNCTION FindFirstFile LIB "KERNEL32.DLL" ALIAS "FindFirstFileA" (lpFileName AS ASCIIZ, lpFindFileData AS WIN32_FIND_DATA) AS DWORD
DECLARE FUNCTION GetClientRect LIB "USER32.DLL" ALIAS "GetClientRect" (BYVAL hwnd AS DWORD, lpRect AS RECT) AS LONG
DECLARE FUNCTION GetDlgItem LIB "USER32.DLL" ALIAS "GetDlgItem" (BYVAL hDlg AS DWORD, BYVAL nIDDlgItem AS LONG) AS DWORD
DECLARE FUNCTION GetOpenFileName LIB "COMDLG32.DLL" ALIAS "GetOpenFileNameA" _
    (lpofn AS OPENFILENAME) AS LONG
DECLARE FUNCTION GetParent LIB "USER32.DLL" ALIAS "GetParent" (BYVAL hWnd AS DWORD) AS LONG
DECLARE FUNCTION GetPrivateProfileString LIB "KERNEL32.DLL" ALIAS "GetPrivateProfileStringA" (lpApplicationName AS ASCIIZ, lpKeyName AS ASCIIZ, lpDefault AS ASCIIZ, lpReturnedString AS ASCIIZ, BYVAL nSize AS DWORD, lpFileName AS ASCIIZ) AS DWORD
DECLARE FUNCTION GetSysColor LIB "USER32.DLL" ALIAS "GetSysColor" (BYVAL nIndex AS LONG) AS LONG
DECLARE FUNCTION GetSysColorBrush LIB "USER32.DLL" ALIAS "GetSysColorBrush" (BYVAL nIndex AS LONG) AS LONG
DECLARE FUNCTION GetVersionEx LIB "KERNEL32.DLL" ALIAS "GetVersionExA" (lpVersionInformation AS OSVERSIONINFO) AS LONG
DECLARE FUNCTION GetWindowRect LIB "USER32.DLL" ALIAS "GetWindowRect" (BYVAL hWnd AS DWORD, lpRect AS RECT) AS LONG
DECLARE FUNCTION IsCharAlphaNumeric LIB "USER32.DLL" ALIAS "IsCharAlphaNumericA" (BYVAL cChar AS BYTE) AS LONG
DECLARE FUNCTION KillTimer LIB "USER32.DLL" ALIAS "KillTimer" (BYVAL hWnd AS DWORD, BYVAL nIDEvent AS LONG) AS LONG
DECLARE FUNCTION MessageBeep LIB "USER32.DLL" ALIAS "MessageBeep" (BYVAL dwType AS DWORD) AS LONG
DECLARE FUNCTION RegCloseKey LIB "ADVAPI32.DLL" ALIAS "RegCloseKey" (BYVAL hKey AS DWORD) AS LONG
DECLARE FUNCTION RegOpenKeyEx LIB "ADVAPI32.DLL" ALIAS "RegOpenKeyExA" (BYVAL hKey AS DWORD, lpSubKey AS ASCIIZ, BYVAL ulOptions AS DWORD, BYVAL samDesired AS LONG, phkResult AS DWORD) AS LONG
DECLARE FUNCTION RegQueryValueEx LIB "ADVAPI32.DLL" ALIAS "RegQueryValueExA" (BYVAL hKey AS DWORD, lpValueName AS ASCIIZ, BYVAL lpReserved AS LONG, lpType AS LONG, lpData AS ANY, lpcbData AS LONG) AS LONG
DECLARE FUNCTION SetBkColor LIB "GDI32.DLL" ALIAS "SetBkColor" (BYVAL hdc AS DWORD, BYVAL crColor AS DWORD) AS DWORD
DECLARE FUNCTION SetTimer LIB "USER32.DLL" ALIAS "SetTimer" (BYVAL hWnd AS DWORD, BYVAL nIDEvent AS LONG, BYVAL uElapse AS DWORD, BYVAL lpTimerFunc AS LONG) AS LONG
DECLARE FUNCTION SetWindowPos LIB "USER32.DLL" ALIAS "SetWindowPos" (BYVAL hWnd AS DWORD, BYVAL hWndInsertAfter AS DWORD, BYVAL x AS LONG, BYVAL y AS LONG, BYVAL cx AS LONG, BYVAL cy AS LONG, BYVAL wFlags AS DWORD) AS LONG
DECLARE FUNCTION ShellExecute LIB "SHELL32.DLL" ALIAS "ShellExecuteA" (BYVAL hwnd AS DWORD, lpOperation AS ASCIIZ, lpFile AS ASCIIZ, lpParameters AS ASCIIZ, lpDirectory AS ASCIIZ, BYVAL nShowCmd AS LONG) AS DWORD
DECLARE FUNCTION SystemParametersInfo LIB "USER32.DLL" ALIAS "SystemParametersInfoA" (BYVAL uAction AS DWORD, BYVAL uParam AS DWORD, lpvParam AS ANY, BYVAL fuWinIni AS DWORD) AS LONG

'-----------------------------------------------------------------
' Declared Subs:  2
'-----------------------------------------------------------------
DECLARE SUB DragAcceptFiles LIB "SHELL32.DLL" ALIAS "DragAcceptFiles" (BYVAL hwnd AS DWORD, BYVAL fAccept AS LONG)
DECLARE SUB DragFinish LIB "SHELL32.DLL" ALIAS "DragFinish" (BYVAL hDrop AS DWORD)

'-----------------------------------------------------------------
' Functions:  3  (begins with declarations)
'-----------------------------------------------------------------
DECLARE FUNCTION IsWin2000orXP AS LONG
DECLARE FUNCTION OpenCommDlg_Proc( BYVAL hWnd AS DWORD, BYVAL wMsg AS DWORD, _
                                   BYVAL wParam AS DWORD, BYVAL lParam AS LONG ) AS LONG
DECLARE FUNCTION OpenFileDialog (BYVAL hWnd AS DWORD, _           ' parent window
                                 BYVAL sCaption AS STRING, _       ' caption
                                 sFileSpec AS STRING, _            ' filename
                                 BYVAL sInitialDir AS STRING, _    ' start directory
                                 BYVAL sFilter AS STRING, _        ' filename filter
                                 BYVAL sDefExtension AS STRING, _  ' default extension
                                 dFlags AS DWORD) AS LONG          ' flags
'- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
FUNCTION IsWin2000orXP AS LONG
  LOCAL os AS OSVERSIONINFO
  os.dwOSVersionInfoSize = SIZEOF(os)
  IF GetVersionEx(os) THEN
     FUNCTION = ((os.dwPlatformId = %VER_PLATFORM_WIN32_NT) AND _
                (os.dwMajorVersion > 4)) '5 or higher..
  END IF
END FUNCTION

FUNCTION OpenCommDlg_Proc( BYVAL hWnd AS DWORD, BYVAL wMsg AS DWORD, _
                           BYVAL wParam AS DWORD, BYVAL lParam AS LONG ) EXPORT AS LONG
  LOCAL X AS LONG, Y AS LONG, R AS RECT, hftCombo AS DWORD, tNOTIFY AS TAGOFNOTIFY PTR
  SELECT CASE wMsg
     CASE %WM_NOTIFY
        tNOTIFY = lParam
        SELECT CASE @tNOTIFY.hdr.Code
           CASE %CDN_INITDONE
              'CENTER DIALOG IN PARENT
              GetWindowRect GetParent(GetParent(hWnd)), R     'get parent's data - dialog is child of child..
              X = R.nLeft + ((R.nRight   - R.nLeft) \ 2)      'calculate parent's width
              Y = R.nTop  + ((R.nBottom  - R.nTop)  \ 2)      'calculate parent's height
              GetWindowRect GetParent(hWnd), R                'get dialog's width and height
              X = X - (( R.nRight   - R.nLeft ) \ 2)
              Y = Y - (( R.nBottom  - R.nTop  ) \ 2)
              SetWindowPos GetParent(hWnd), %NULL, X, Y, 0, 0, %SWP_NOSIZE OR %SWP_NOZORDER 'set centered pos
              'INCREASE HEIGHT OF DROPPED LIST IN FILETYPE COMBO
              hftCombo = GetDlgItem(GetParent(hWnd), %cmb1)    'handle, Filetype combo
              IF hftCombo THEN                                 'if we get handle
                 GetClientRect hftCombo, R                     'get combo's width and set new height
                 SetWindowPos hftCombo, %NULL, 0, 0, R.nRight, 200, %SWP_NOMOVE OR %SWP_NOZORDER
              END IF
              FUNCTION = %TRUE : EXIT FUNCTION
        'CASE %CDN_HELP : BEEP
        END SELECT
  END SELECT
END FUNCTION

FUNCTION OpenFileDialog (BYVAL hWnd AS DWORD, _           ' parent window
                         BYVAL sCaption AS STRING, _       ' caption
                         sFileSpec AS STRING, _            ' filename
                         BYVAL sInitialDir AS STRING, _    ' start directory
                         BYVAL sFilter AS STRING, _        ' filename filter
                         BYVAL sDefExtension AS STRING, _  ' default extension
                         dFlags AS DWORD) AS LONG          ' flags
  LOCAL ix          AS LONG
  LOCAL Ofn         AS OPENFILENAMEEX
  LOCAL szFileTitle AS ASCIIZ * %MAX_PATH
  REPLACE "|" WITH $NUL IN sFilter
  sFilter = sFilter + $NUL
  IF LEN(sInitialDir) = 0 THEN sInitialDir = CURDIR$
  ix = INSTR(sFileSpec, $NUL)
  IF ix THEN
     sFileSpec = LEFT$(sFileSpec, ix) + SPACE$( MAX&(0, %OFN_FILEBUFFERSIZE - ix) )
  ELSE
     sFileSpec = sFileSpec + $NUL + SPACE$( MAX&(0, %OFN_FILEBUFFERSIZE - (LEN(sFileSpec) + 1)) )
  END IF
  IF IsWin2000orXP THEN
     ofn.lStructSize       = LEN(OPENFILENAMEEX) ' if Win2K or later, use full size of new structure
  ELSE
     ofn.lStructSize       = LEN(OPENFILENAME)   ' else set size to old, smaller one's (76 bytes)
  END IF
  ofn.hWndOwner         = hWnd
  ofn.lpstrFilter       = STRPTR(sFilter)
  ofn.lpstrFile         = STRPTR(sFileSpec)
  ofn.nMaxFile          = LEN(sFileSpec)
  ofn.lpstrFileTitle    = VARPTR(szFileTitle)
  ofn.nMaxFileTitle     = SIZEOF(szFileTitle)
  ofn.lpstrInitialDir   = STRPTR(sInitialDir)
  IF LEN(sCaption) THEN
      ofn.lpstrTitle    = STRPTR(sCaption)
  END IF
  ofn.Flags             = dFlags
  ofn.lpfnHook          = CODEPTR(OpenCommDlg_Proc)
  IF LEN(sDefExtension) THEN
     ofn.lpstrDefExt  = STRPTR(sDefExtension)
  END IF
  ofn.nFilterIndex = 1  ' nFilterIndex decides File type combo's ListItem
  'Note: following Select Case table must be adjusted to match used Filter string
  '     (also remeber to do the same in OpenDlgHookProc procedure..)
  FUNCTION = GetOpenFilename(BYVAL VARPTR(ofn))
  ix = INSTR(-1, sFileSpec, $NUL)
  IF ix THEN
     sFileSpec = LEFT$(sFileSpec, ix - 1)
  ELSE
     sFileSpec = ""
  END IF
  dFlags = ofn.Flags
END FUNCTION
