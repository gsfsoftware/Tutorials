' PB_HTML.inc
' used to display an embedded HTML page inside a dialog
'
' functions and macros in library
'
' funPopulateHTML(hDlg AS DWORD, _       ' Populate the selected html control
'                 strURL AS STRING, _    ' with the content of the URL
'                 lngOCX AS LONG)
'
' mPrepHTML(hDlg,XStart,Ystart,lngHeight,lngWidth) ' used to insert the code
'                                                  ' to create the html control
GLOBAL oOcx AS DISPATCH          ' for web page
GLOBAL hOcx AS DWORD             ' windows handle for web control
'
DECLARE FUNCTION AtlAxWinInit LIB "ATL.DLL" _
                 ALIAS "AtlAxWinInit" () AS LONG
' *********************************************************************************************
FUNCTION AtlAxWinTerm () AS LONG
  UnregisterClass ("AtlAxWin", GetModuleHandle(BYVAL %NULL))
END FUNCTION
' *********************************************************************************************
' **********************************************************************************************
DECLARE FUNCTION AtlAxGetControl LIB "ATL.DLL" _
     ALIAS "AtlAxGetControl" _
     ( _
     BYVAL hWnd AS DWORD, _ ' [in] A handle to the window that is hosting the control.
     BYREF pp AS DWORD _    ' [out] The IUnknown of the control being hosted.
  ) AS DWORD
' *********************************************************************************************

' *********************************************************************************************
' Puts the address of an object in a variant and marks it
' as containing a dispatch variable
' *********************************************************************************************
FUNCTION IUnknown_AddRef (BYVAL pthis AS DWORD PTR) AS DWORD
    LOCAL DWRESULT AS DWORD
    IF ISFALSE pthis THEN EXIT FUNCTION
    CALL DWORD @@pthis[1] USING IUnknown_AddRef(pthis) TO DWRESULT
    FUNCTION = DWRESULT
END FUNCTION

SUB AtlMakeDispatch (BYVAL lpObj AS DWORD, BYREF vObj AS VARIANT) EXPORT
   LOCAL lpvObj AS VARIANTAPI PTR  ' Pointer to a VARIANTAPI structure
   LET vObj = EMPTY                ' Make sure is empty to avoid memory leaks
   lpvObj = VARPTR(vObj)           ' Get the VARIANT address
   @lpvObj.vt = %VT_DISPATCH       ' Mark it as containing a dispatch variable
   @lpvObj.pdispVal = lpObj        ' Set the dispatch pointer address
   IUnknown_AddRef lpObj           ' Increment the reference counter
END SUB
'
FUNCTION funPopulateHTML(hDlg AS DWORD, _
                         strURL AS STRING, _
                         lngOCX AS LONG) AS LONG
' populate the html into the browser control
  LOCAL pUnk AS DWORD
  LOCAL vVar AS VARIANT
  ' get the windows handle of the control
  CONTROL HANDLE hDlg, lngOCX TO hOcx
  '
  AtlAxGetControl(hOcx, pUnk)
  AtlMakeDispatch(pUnk, vVar)
  SET oOcx = vVar
  '
  vVar = strUrl
  OBJECT CALL oOcx.Navigate(vVar)
  DIALOG POST hDlg,%WM_SIZE,0,0
  '
END FUNCTION
'

MACRO mPrepHTML(hDlg,XStart,Ystart,lngHeight,lngWidth)
  LOCAL OcxName AS ASCIIZ * 255
  LOCAL lngOCX_Height AS LONG
  LOCAL lngOCX_Width AS LONG
  LOCAL lngOCX_Xstart AS LONG
  LOCAL lngOCX_Ystart AS LONG
  OcxName = "Shell.Explorer"
  AtlAxWinInit   ' // Initializes ATL
  '
  lngOCX_Xstart = XStart ' 10
  lngOCX_Ystart = Ystart ' 50
  lngOCX_Height = lngHeight ' 210
  lngOCX_Width  = lngWidth ' 500
  '
  CONTROL ADD "AtlAxWin", hDlg, %ID_OCX, OcxName, _
                          lngOCX_Xstart, _
                          lngOCX_Ystart, _
                          lngOCX_Width, _
                          lngOCX_Height, _
                          %WS_VISIBLE OR %WS_CHILD
END MACRO
