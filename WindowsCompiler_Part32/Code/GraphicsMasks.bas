#PBFORMS CREATED V2.01
'------------------------------------------------------------------------------
' The first line in this file is a PB/Forms metastatement.
' It should ALWAYS be the first line of the file. Other
' PB/Forms metastatements are placed at the beginning and
' end of "Named Blocks" of code that should be edited
' with PBForms only. Do not manually edit or delete these
' metastatements or PB/Forms will not be able to reread
' the file correctly.  See the PB/Forms documentation for
' more information.
' Named blocks begin like this:    #PBFORMS BEGIN ...
' Named blocks end like this:      #PBFORMS END ...
' Other PB/Forms metastatements such as:
'     #PBFORMS DECLARATIONS
' are used by PB/Forms to insert additional code.
' Feel free to make changes anywhere else in the file.
'------------------------------------------------------------------------------

#COMPILE EXE
#DIM ALL

'------------------------------------------------------------------------------
'   ** Includes **
'------------------------------------------------------------------------------
#PBFORMS BEGIN INCLUDES
#RESOURCE "GraphicsMasks.pbr"
#INCLUDE ONCE "WIN32API.INC"
#INCLUDE ONCE "COMMCTRL.INC"
#INCLUDE ONCE "PBForms.INC"
#PBFORMS END INCLUDES
'------------------------------------------------------------------------------

'------------------------------------------------------------------------------
'   ** Constants **
'------------------------------------------------------------------------------
#PBFORMS BEGIN CONSTANTS
%IDD_DIALOG1  =  101
%IDC_GRAPHIC1 = 1001
#PBFORMS END CONSTANTS
'------------------------------------------------------------------------------

'------------------------------------------------------------------------------
'   ** Declarations **
'------------------------------------------------------------------------------
DECLARE CALLBACK FUNCTION ShowDIALOG1Proc()
DECLARE FUNCTION ShowDIALOG1(BYVAL hParent AS DWORD) AS LONG
#PBFORMS DECLARATIONS
'------------------------------------------------------------------------------

'------------------------------------------------------------------------------
'   ** Main Application Entry Point **
'------------------------------------------------------------------------------
FUNCTION PBMAIN()
  PBFormsInitComCtls (%ICC_WIN95_CLASSES OR %ICC_DATE_CLASSES OR _
    %ICC_INTERNET_CLASSES)

  ShowDIALOG1 %HWND_DESKTOP
END FUNCTION
'------------------------------------------------------------------------------

'------------------------------------------------------------------------------
'   ** CallBacks **
'------------------------------------------------------------------------------
CALLBACK FUNCTION ShowDIALOG1Proc()

  SELECT CASE AS LONG CB.MSG
    CASE %WM_INITDIALOG
      ' Initialization handler
      funBuildGraphics(CB.HNDL, %IDC_GRAPHIC1)


    CASE %WM_NCACTIVATE
      STATIC hWndSaveFocus AS DWORD
      IF ISFALSE CB.WPARAM THEN
        ' Save control focus
        hWndSaveFocus = GetFocus()
      ELSEIF hWndSaveFocus THEN
        ' Restore control focus
        SetFocus(hWndSaveFocus)
        hWndSaveFocus = 0
      END IF

    CASE %WM_COMMAND
      ' Process control notifications
      SELECT CASE AS LONG CB.CTL

      END SELECT
  END SELECT
END FUNCTION
'------------------------------------------------------------------------------

'------------------------------------------------------------------------------
'   ** Dialogs **
'------------------------------------------------------------------------------
FUNCTION ShowDIALOG1(BYVAL hParent AS DWORD) AS LONG
  LOCAL lRslt AS LONG

#PBFORMS BEGIN DIALOG %IDD_DIALOG1->->
  LOCAL hDlg  AS DWORD

  DIALOG NEW hParent, "Dialog1", 354, 132, 468, 272, %WS_POPUP OR %WS_BORDER _
    OR %WS_DLGFRAME OR %WS_CAPTION OR %WS_SYSMENU OR %WS_CLIPSIBLINGS OR _
    %WS_VISIBLE OR %DS_MODALFRAME OR %DS_CENTER OR %DS_3DLOOK OR _
    %DS_NOFAILCREATE OR %DS_SETFONT, %WS_EX_CONTROLPARENT OR %WS_EX_LEFT OR _
    %WS_EX_LTRREADING OR %WS_EX_RIGHTSCROLLBAR, TO hDlg
  CONTROL ADD GRAPHIC, hDlg, %IDC_GRAPHIC1, "", 5, 5, 420, 240
#PBFORMS END DIALOG

  DIALOG SHOW MODAL hDlg, CALL ShowDIALOG1Proc TO lRslt

#PBFORMS BEGIN CLEANUP %IDD_DIALOG1
#PBFORMS END CLEANUP

  FUNCTION = lRslt
END FUNCTION
'------------------------------------------------------------------------------

FUNCTION funBuildGraphics(hDlg AS DWORD, _
                          lngGraphic AS LONG) AS LONG
  LOCAL lngFile AS LONG
  LOCAL lngWidth AS LONG
  LOCAL lngHeight AS LONG
  '
  LOCAL strBitmap AS STRING
  LOCAL strBitmapMask AS STRING
  LOCAL lngXstart AS LONG
  LOCAL lngYstart AS LONG
  '
  LOCAL hBmp AS DWORD
  LOCAL hBmpMask AS DWORD
  '
  lngXstart = 50
  lngYstart = 50
  '
  GRAPHIC ATTACH hDlg, lngGraphic, REDRAW
  GRAPHIC CLEAR %RGB_GRAY,0
  '
  strBitmapMask = EXE.PATH$ & "\Graphics\MaskBig.bmp"
  '
  lngFile = FREEFILE
  OPEN strBitmap FOR BINARY AS lngFile
  GET #lngFile, 19, lngWidth
  GET #lngFile, 23, lngHeight
  CLOSE #lngFile
  '
  GRAPHIC BITMAP LOAD strBitmapMask ,lngWidth, lngHeight TO hBmpMask
  '
  strBitmap = EXE.PATH$ & "\Graphics\A.bmp"
  funDrawHex(lngGraphic,lngXStart , lngYStart, _
                    strBitmap,lngWidth, lngHeight, hBmpMask)
                    '
  lngYStart = lngYStart + 40
  strBitmap = EXE.PATH$ & "\Graphics\B.bmp"
  funDrawHex(lngGraphic,lngXStart , lngYStart, _
                    strBitmap,lngWidth, lngHeight, hBmpMask)
  '
  lngXStart = lngXStart + 36
  lngYStart = lngYStart - 20
  strBitmap = EXE.PATH$ & "\Graphics\C.bmp"
  funDrawHex(lngGraphic,lngXStart , lngYStart, _
                    strBitmap,lngWidth, lngHeight, hBmpMask)
  '
  GRAPHIC BITMAP END
  GRAPHIC REDRAW
  '
END FUNCTION
'
FUNCTION funDrawHex(lngGraphic AS LONG, _
                    lngXStart AS LONG , lngYStart AS LONG, _
                    strBitmap AS STRING, _
                    lngWidth AS LONG, lngHeight AS LONG, _
                    hBmpMask AS DWORD) AS LONG
                    '
 LOCAL hBmp AS DWORD
 GRAPHIC BITMAP LOAD strBitmap, lngWidth, lngHeight TO hBmp
 '
 GRAPHIC COPY hBmpMask, lngGraphic TO _
             (lngXStart, lngYStart), %MIX_MASKSRC
 GRAPHIC COPY hBmp, lngGraphic TO _
           (lngXStart, lngYStart), %MIX_MERGESRC

END FUNCTION
