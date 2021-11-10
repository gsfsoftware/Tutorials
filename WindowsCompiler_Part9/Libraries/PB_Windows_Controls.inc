' Window controls library
' PB_Windows_Controls.inc

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
