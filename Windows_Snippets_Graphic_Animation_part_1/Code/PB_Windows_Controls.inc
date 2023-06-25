' Window controls library
' PB_Windows_Controls.inc

#INCLUDE ONCE "RichEdit.inc"

FUNCTION funSetRTcolour(hDlg AS DWORD, _
                        lngRichEdit AS LONG, _
                        strText AS STRING, _
                        lngColour AS LONG, _
                        lngOffset AS LONG) AS LONG
' set the section of text on the richedit control to the specified colour
'
  LOCAL pd AS CHARRANGE  ' set the character range
  LOCAL cf AS CHARFORMAT ' set the character format
  LOCAL strFullText AS STRING  ' the full text in the rich text control
  LOCAL lngStart AS LONG   ' start position of the string to be highlighted
  LOCAL lngEnd AS LONG     ' end position
  '
  ' get the text in the control
  CONTROL GET TEXT hDlg, lngRichEdit TO strFullText
  ' get the start position
  lngStart = INSTR(strFulltext, strText)
  IF lngStart = 0 THEN EXIT FUNCTION ' exit if we dont find it
  '
  PD.cpmin = lngStart - lngOffset
  PD.cpmax = lngStart + LEN(strText)
  '
  ' select the text on the rich edit control
  CONTROL SEND hDlg, lngRichEdit, %EM_EXSetSel,0, VARPTR(pd)
  cf.cbSize = LEN(cf)    ' set length of structure
  cf.dwmask = %CFM_COLOR ' set the mask to colours only
  cf.crTextColor = lngColour ' set the new colour value
  '
  CONTROL SEND hDlg, lngRichEdit, %EM_SETCHARFORMAT, _
               %SCF_SELECTION, VARPTR(cf)
  FUNCTION = %TRUE
'
END FUNCTION

FUNCTION funRichEd_HyperLink_HandleURL(BYVAL hWnd AS DWORD, _
                                       BYVAL lpLink AS DWORD, _
                                       lngRichEdit AS LONG) AS LONG
' Handle clicking on Rich edit URL
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
' populate a combo dropdown
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
'
FUNCTION funClearHighlight(hDlg AS DWORD, _
                           lnglblID AS LONG, _
                           lngColour AS LONG, _
                           lngStatusID AS LONG, _
                           strStatusText AS STRING) AS LONG
' unhighlight control
  CONTROL SET COLOR hDlg,lnglblID,lngColour,-1
  CONTROL REDRAW hDlg,lnglblID
  CONTROL SET TEXT hDlg,lngStatusID,strStatusText
END FUNCTION
'
FUNCTION funHighlightControl(hDlg AS DWORD, _
                             lngtxtID AS LONG, _
                             lnglblID AS LONG, _
                             lngColour AS LONG, _
                             lngStatusID AS LONG, _
                             strStatusText AS STRING) AS LONG
' highlight and set focus to a control
' to be used when user has not filled in or selected from a combo
  CONTROL SET FOCUS hDlg,lngtxtID
  CONTROL SET TEXT hDlg,lngStatusID,strStatusText
  CONTROL SET COLOR hDlg,lnglblID,lngColour,-1
  CONTROL REDRAW hDlg,lnglblID
  '
END FUNCTION
