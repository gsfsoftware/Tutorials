' Window controls library
' PB_Windows_Controls.inc

FUNCTION funRichEd_HyperLink_HandleURL(BYVAL hWnd AS DWORD, _
                                       BYVAL lpLink AS DWORD, _
                                       lngRichEdit AS LONG) AS LONG
  LOCAL enlinkPtr AS ENLINK PTR
  LOCAL tr        AS TEXTRANGE
  LOCAL linkText  AS STRING
  '
  enlinkPtr = lpLink
  tr.chrg = @enlinkPtr.chrg
  linkText = SPACE$(tr.chrg.cpMax - tr.chrg.cpMin +2)
  tr.lpstrText = STRPTR(linkText)
  '
  ' send back to the richedit control to get the text range
  CONTROL SEND hWnd,lngRichEdit, %EM_GETTEXTRANGE, 0,VARPTR(tr)
  '
  SELECT CASE @enLinkPtr.msg
    CASE %WM_LBUTTONDOWN
      ShellExecute(%NULL, "open", BYCOPY linktext,"","",%SW_SHOW)
      FUNCTION = %TRUE
    CASE %WM_LBUTTONDBLCLK, %WM_LBUTTONUP  ' ignore these
      FUNCTION = %TRUE
  END SELECT
  '
END FUNCTION
'
FUNCTION funPopulateCombo(hDlg AS DWORD, _
                          lngCombo AS LONG, _
                          BYREF a_strData() AS STRING, _
                          strSelection AS STRING) AS LONG
  LOCAL lngR AS LONG
  LOCAL lngItem AS LONG
  '
  COMBOBOX RESET hDlg, lngCombo
  FOR lngR = 1 TO UBOUND(a_strData)
    COMBOBOX ADD hDlg, lngCombo, a_strData(lngR)
  NEXT lngR
  '
  IF strSelection <> "" THEN
    COMBOBOX FIND EXACT hDlg, lngCombo, 1, strSelection TO lngItem
    '
    IF lngItem > 0 THEN
      COMBOBOX SELECT hDlg, lngCombo, lngItem
    END IF
    '
  END IF
  '
END FUNCTION
