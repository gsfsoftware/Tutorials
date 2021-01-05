'
' menu routines

FUNCTION funSetMenuIcon(hDlg AS DWORD, hMenuFile AS DWORD, _
                        lngMenuItem AS LONG, lngIconNumber AS LONG, _
                        lngSize AS LONG) AS LONG
  LOCAL hBmpExp AS DWORD
  LOCAL hIcon AS DWORD
  '
  hIcon = ExtractIcon(GetModuleHandle(""), EXE.FULL$, lngIconNumber)
  hBmpExp = funIconToBmp(hDlg, hIcon, lngSize)
  SetMenuItemBitmaps(hMenuFile, lngMenuItem, %MF_BYPOSITION, hBmpExp, hBmpExp)
  '
END FUNCTION
'
FUNCTION funIconToBmp(hDlg AS DWORD, BYREF hIcon AS DWORD, lngSize AS LONG) AS DWORD
 LOCAL MemDc      AS DWORD
 LOCAL hDC        AS DWORD
 LOCAL hbrush     AS DWORD
 LOCAL hBitmap    AS DWORD
 LOCAL hBitmapOld AS DWORD
 '
 hDC        = GetDC(hDlg)
 MemDc      = CreateCompatibleDC(hDC)
 hBitmap    = CreateBitmap(lngSize, lngSize, 1, 32, BYVAL 0)
 hBitmapOld = SelectObject(MemDc, hBitmap)
 hbrush     = CreateSolidBrush(GetSysColor(%COLOR_MENU))
 DrawIconEx(MemDc, 0, 0, hIcon, lngSize, lngSize, 0, BYVAL hbrush, %DI_NORMAL)

 SelectObject(MemDc, hBitmapOld)
 DeleteObject(hBrush)
 DeleteDC(MemDc)
 ReleaseDC(hDlg, hDC)
 FUNCTION = hBitmap
 '
END FUNCTION
