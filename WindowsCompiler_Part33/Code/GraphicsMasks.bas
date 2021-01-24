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

%MaxX = 13
%MaxY = 6
'
' global array for maps
GLOBAL g_lngTerrain() AS LONG

'------------------------------------------------------------------------------
'   ** Includes **
'------------------------------------------------------------------------------
#PBFORMS BEGIN INCLUDES
#RESOURCE "GraphicsMasks.pbr"
%USEMACROS = 1
#INCLUDE ONCE "WIN32API.INC"
#INCLUDE ONCE "COMMCTRL.INC"
#INCLUDE ONCE "PBForms.INC"
#PBFORMS END INCLUDES
'------------------------------------------------------------------------------

'------------------------------------------------------------------------------
'   ** Constants **
'------------------------------------------------------------------------------
#PBFORMS BEGIN CONSTANTS
%IDD_DIALOG1   =  101
%IDC_GRAPHIC1  = 1001
%IDC_STATUSBAR = 1002
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
  '
  REDIM g_lngTerrain(%MaxX,%MaxY,2) AS LONG
  '
  ShowDIALOG1 %HWND_DESKTOP
END FUNCTION
'------------------------------------------------------------------------------

'------------------------------------------------------------------------------
'   ** CallBacks **
'------------------------------------------------------------------------------
CALLBACK FUNCTION ShowDIALOG1Proc()
  STATIC hGraphic AS DWORD
  LOCAL pLocation AS POINT
  '
  SELECT CASE AS LONG CB.MSG
    CASE %WM_INITDIALOG
      ' Initialization handler
      ' funBuildGraphics(CB.HNDL, %IDC_GRAPHIC1)
      GRAPHIC ATTACH CB.HNDL, %IDC_GRAPHIC1, REDRAW
      GRAPHIC CLEAR %RGB_BLACK,0
      funBuildGraphicsMap(CB.HNDL, %IDC_GRAPHIC1)
      '
      ' get the windows handle of the graphics control
      CONTROL HANDLE CB.HNDL,%IDC_GRAPHIC1 TO hGraphic

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
        ' /* Inserted by PB/Forms 05-02-2020 13:08:45
        CASE %IDC_STATUSBAR
        ' */

        ' /* Inserted by PB/Forms 05-02-2020 13:03:02
        CASE %IDC_GRAPHIC1
          IF CB.CTLMSG = %STN_Clicked THEN
          ' get location on graphics control
            GetCursorPos pLocation
            ScreenToClient(hGraphic,pLocation)
            ' pLocation.x = X location
            ' pLocation.y = Y location
            CONTROL SET TEXT CB.HNDL, %IDC_StatusBar, _
                "x = " & FORMAT$(pLocation.x) & " " & _
                "y = " & FORMAT$(pLocation.y) & " " & _
                funGetHex(pLocation.x,pLocation.y)
          '
          END IF

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

  DIALOG NEW PIXELS, hParent, "Dialog1", 354, 132, 790, 500, %WS_POPUP OR _
    %WS_BORDER OR %WS_DLGFRAME OR %WS_CAPTION OR %WS_SYSMENU OR _
    %WS_CLIPSIBLINGS OR %WS_VISIBLE OR %DS_MODALFRAME OR %DS_CENTER OR _
    %DS_3DLOOK OR %DS_NOFAILCREATE OR %DS_SETFONT, %WS_EX_CONTROLPARENT OR _
    %WS_EX_LEFT OR %WS_EX_LTRREADING OR %WS_EX_RIGHTSCROLLBAR, TO hDlg
  CONTROL ADD GRAPHIC,   hDlg, %IDC_GRAPHIC1, "", 5, 5, 750, 460, %WS_CHILD _
    OR %WS_VISIBLE OR %SS_NOTIFY
  CONTROL ADD STATUSBAR, hDlg, %IDC_STATUSBAR, "", 0, 0, 0, 0
#PBFORMS END DIALOG

  DIALOG SHOW MODAL hDlg, CALL ShowDIALOG1Proc TO lRslt

#PBFORMS BEGIN CLEANUP %IDD_DIALOG1
#PBFORMS END CLEANUP

  FUNCTION = lRslt
END FUNCTION
'------------------------------------------------------------------------------
'
FUNCTION funBuildGraphicsMap(hDlg AS DWORD, _
                          lngGraphic AS LONG) AS LONG
 ' draw a blank hex map
  LOCAL lngXStart AS LONG
  LOCAL lngYStart AS LONG
  '
  LOCAL lngPolygonX AS LONG
  LOCAL lngPolygonY AS LONG
  '
  LOCAL lngX AS LONG
  LOCAL lngY AS LONG
  LOCAL lngYTemp AS LONG
  LOCAL lngXOffSet AS LONG
  LOCAL lngYOffSet AS LONG
  LOCAL lngWidth AS LONG
  LOCAL lngDrop AS LONG
  LOCAL lngR AS LONG
  LOCAL lngC AS LONG
  LOCAL strBitmap AS STRING
  LOCAL strBitmapMask AS STRING
  LOCAL nFile&, nWidth&, nHeight&
  LOCAL hBmp AS DWORD
  LOCAL hBmpMask AS DWORD
  LOCAL lngXLetter AS LONG
  LOCAL lngTerrain AS LONG
  '
  RANDOMIZE
  '
  lngWidth = 28
  lngDrop =  28
  lngX = 35
  lngY = 15
  '
  lngXOffSet = lngDrop + lngWidth - 2
  lngYOffSet = (lngWidth * 2) +10
  lngXLetter = 64 ' set start letter to A
  '
  FOR lngR = 1 TO %MaxX
    FOR lngC = 1 TO %MaxY
      lngPolygonX = lngX + ((lngR - 1) * lngXOffSet)
      lngYTemp = lngY + ((lngC - 1) * (lngYOffSet-1))
      '
      IF lngR MOD 2 = 0 THEN
      ' offset alternate columns
        lngYTemp = lngYTemp + lngWidth + 4
      END IF
      '
      lngPolygonY = lngYTemp
      '
      lngXStart = lngPolygonX - lngDrop
      lngYStart = lngPolygonY
      '
      strBitmapMask = EXE.PATH$ & "\Graphics\MaskBig.bmp"
      '
      nFile& = FREEFILE
      OPEN strBitmap FOR BINARY AS nFile&
      GET #nFile&, 19, nWidth&
      GET #nFile&, 23, nHeight&
      CLOSE nFile&
      '
      ' work out the terrain type
      lngTerrain = RND(65,69)
      ' now store the terrain
      g_lngTerrain(lngR,lngC,0) = lngTerrain
      ' now store the centre of the hex
      g_lngTerrain(lngR,lngC,1) = lngXStart + (nWidth& \ 2)
      g_lngTerrain(lngR,lngC,2) = lngYStart + (nHeight& \ 2)
      '
      strBitmap = EXE.PATH$ & "\Graphics\" & CHR$(lngTerrain) & ".bmp"
      GRAPHIC BITMAP LOAD strBitmapMask, nWidth&, nHeight& TO hBmpMask
      GRAPHIC BITMAP LOAD strBitmap, nWidth&, nHeight& TO hBmp
      '
      GRAPHIC COPY hBmpMask, %IDC_GRAPHIC1 TO _
           (lngXStart, lngYStart), %MIX_MASKSRC
      GRAPHIC COPY hBmp, %IDC_GRAPHIC1 TO _
           (lngXStart, lngYStart), %MIX_MERGESRC
           '
      GRAPHIC BITMAP END
      '
      ' now set up the grid ids
      IF lngR = 1 THEN
      ' first column
        GRAPHIC COLOR %RGB_WHITE, -2
        GRAPHIC SET POS (lngXStart,lngPolygonY +lngDrop +(lngDrop\2) +4)
        GRAPHIC PRINT FORMAT$(lngC);
      END IF
      '
      IF lngR = %MaxX THEN
      ' last column
        GRAPHIC COLOR %RGB_WHITE, -2
        GRAPHIC SET POS (lngXStart + (lngDrop *2) +12, _
                         lngPolygonY +lngDrop +(lngDrop\2) +4)
        GRAPHIC PRINT FORMAT$(lngC);
      END IF
      '
      ' draw column marker
      SELECT CASE lngC
        CASE 1
          GRAPHIC COLOR %RGB_WHITE, -2
          GRAPHIC SET POS (lngPolygonX +6, lngPolygonY-12)
          GRAPHIC PRINT CHR$(lngXLetter + lngR);
          '
        CASE %MaxY
          GRAPHIC COLOR %RGB_WHITE, -2
          GRAPHIC SET POS (lngPolygonX +6,lngPolygonY + nHeight& )
          GRAPHIC PRINT CHR$(lngXLetter + lngR);
          '
      END SELECT
      '
    NEXT lngC
  NEXT lngR
  '
END FUNCTION
'
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
'
FUNCTION funGetHex(lngX AS LONG,lngY AS LONG) AS STRING
' work out what hex we are on
' by getting the closest match
  LOCAL lngDistance AS LONG
  LOCAL lngR AS LONG
  LOCAL lngC AS LONG
  '
  LOCAL lngShortestDist AS LONG
  LOCAL strFound AS STRING
  lngShortestDist = 10000000
  '
  FOR lngR = 1 TO %MaxX
    FOR lngC = 1 TO %MaxY
      lngDistance = SQR((ABS(lngX - g_lngTerrain(lngR,lngC,1))^2) + _
                       (ABS(lngY - g_lngTerrain(lngR,lngC,2))^2))
      IF lngDistance < lngShortestDist THEN
        lngShortestDist = lngDistance
        strFound = CHR$(64 +lngR) & FORMAT$(lngC) & _
                   " Terrain = " & CHR$(g_lngTerrain(lngR,lngC,0))
      END IF
    NEXT lngC
  NEXT lngR
  '
  FUNCTION = strFound
'
END FUNCTION
