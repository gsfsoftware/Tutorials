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
%MaxBuildings = 30  ' total number of buildings
'
' global array for maps
GLOBAL g_lngTerrain() AS LONG
GLOBAL g_strGameMap AS STRING
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
%IDD_DIALOG1      =  101
%IDC_GRAPHIC1     = 1001
%IDC_STATUSBAR    = 1002
%IDC_lblShowZones = 1006
%IDC_LANDINGZONE  = 1003
%IDC_PICKUPZONE   = 1004
%IDC_TARGETZONE   = 1005
%IDC_imgLANDINGZONE = 1007
%IDC_imgTARGETZONE  = 1008
%IDC_imgPICKUPZONE  = 1009
#PBFORMS END CONSTANTS
'------------------------------------------------------------------------------
#RESOURCE ICON, LandingZone , "Graphics\SmallLandingZone.ico"
#RESOURCE ICON, PickupZone , "Graphics\SmallPickupZone.ico"
#RESOURCE ICON, TargetZone , "Graphics\SmallTargetZone.ico"
'------------------------------------------------------------------------------
'   ** Declarations **
'------------------------------------------------------------------------------
DECLARE CALLBACK FUNCTION ShowDIALOG1Proc()
DECLARE FUNCTION ShowDIALOG1(BYVAL hParent AS DWORD) AS LONG
#PBFORMS DECLARATIONS
'------------------------------------------------------------------------------
' set up names for the terrain
ENUM Terrain
  Grasslands = 65
  SparseForrest
  DenseForrest
  Buildings
  Hills
  Water
END ENUM
'
TYPE udtBuilding
  x AS LONG         ' grid location
  y AS LONG         ' grid location
  z AS LONG         ' offset 1-6
  state AS LONG     ' buildings current condition
END TYPE
'
ENUM Condition      ' Current condition of structure
  Active = 1
  Damaged
  Destroyed
END ENUM
'
GLOBAL PickupLocation AS POINT
GLOBAL LandingZone AS POINT
GLOBAL TargetZone AS POINT    '
GLOBAL g_uBuildings() AS udtBuilding
'
' set the elements in the array for X & Y co-ords
%Terrain = 0
%X = 1
%Y = 2

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
  STATIC hTimer AS QUAD
  STATIC lngCount AS LONG
  '
  SELECT CASE AS LONG CB.MSG
    CASE %WM_INITDIALOG
      ' Initialization handler
      '
      GRAPHIC ATTACH CB.HNDL, %IDC_GRAPHIC1, REDRAW
      GRAPHIC CLEAR %RGB_BLACK,0
      funBuildRandomTerrain()
      funBuildGraphicsMap(CB.HNDL, %IDC_GRAPHIC1)
      '
      ' now store the whole graphics map
      GRAPHIC GET BITS TO g_strGameMap
      '
      ' work out the pickup point
      funSetPickup(CB.HNDL,%TRUE)
      ' work out landing zone
      funSetLandingZone(CB.HNDL,%TRUE)
      ' work out Targetzone
      funSetTargetZone(CB.HNDL,%TRUE)
      ' set the buildings
      funSetBuildings(CB.HNDL,%TRUE)
      '
      PREFIX "control set check cb.hndl, "
        %IDC_LANDINGZONE, 1
        %IDC_TARGETZONE,1
        %IDC_PICKUPZONE,1
      END PREFIX
      '
      ' get the windows handle of the graphics control
      CONTROL HANDLE CB.HNDL,%IDC_GRAPHIC1 TO hGraphic
      '
      ' set time to trigger every 500ms
      hTimer = SetTimer(CB.HNDL, 1&,500&, BYVAL %NULL)
      '
    CASE %WM_TIMER
    ' advance the timer count
      INCR lngCount
      IF lngCount < 12 THEN
        IF (lngCount MOD 2) = 0 THEN
        ' put the pickup back
          funSetPickup(CB.HNDL,%FALSE)
          funSetLandingZone(CB.HNDL,%FALSE)
          funSetTargetZone(CB.HNDL,%FALSE)
          funSetBuildings(CB.HNDL,%FALSE)
        ELSE
        ' put the terrain back
          GRAPHIC SET BITS g_strGameMap
          funSetBuildings(CB.HNDL,%FALSE)
          GRAPHIC REDRAW
        '
        END IF
      ELSE
        KillTimer CB.HNDL, hTimer
        funSetPickup(CB.HNDL,%FALSE)
        funSetLandingZone(CB.HNDL,%FALSE)
        funSetTargetZone(CB.HNDL,%FALSE)
        funSetBuildings(CB.HNDL,%FALSE)
      END IF
    '
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
        ' /* Inserted by PB/Forms 04-05-2021 10:54:12
        CASE %IDC_LANDINGZONE
          IF CB.CTLMSG = %BN_CLICKED OR CB.CTLMSG = 1 THEN
            funRedrawMap(CB.HNDL)
          END IF
          '
        CASE %IDC_PICKUPZONE
          IF CB.CTLMSG = %BN_CLICKED OR CB.CTLMSG = 1 THEN
            funRedrawMap(CB.HNDL)
          END IF
          '
        CASE %IDC_TARGETZONE
          IF CB.CTLMSG = %BN_CLICKED OR CB.CTLMSG = 1 THEN
            funRedrawMap(CB.HNDL)
          END IF
        ' */

        ' /* Inserted by PB/Forms 05-02-2020 13:08:45
        CASE %IDC_STATUSBAR
        ' */

        ' /* Inserted by PB/Forms 05-02-2020 13:03:02
        CASE %IDC_GRAPHIC1
          IF CB.CTLMSG = %STN_Clicked THEN
          ' get location on graphics control - X & Y co-ords
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
          '
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

  DIALOG NEW PIXELS, hParent, "Hex Maps", 357, 232, 1005, 500, %WS_POPUP OR _
    %WS_BORDER OR %WS_DLGFRAME OR %WS_CAPTION OR %WS_SYSMENU OR _
    %WS_MINIMIZEBOX OR %WS_CLIPSIBLINGS OR %WS_VISIBLE OR %DS_MODALFRAME OR _
    %DS_CENTER OR %DS_3DLOOK OR %DS_NOFAILCREATE OR %DS_SETFONT, _
    %WS_EX_CONTROLPARENT OR %WS_EX_LEFT OR %WS_EX_LTRREADING OR _
    %WS_EX_RIGHTSCROLLBAR, TO hDlg
  CONTROL ADD GRAPHIC,   hDlg, %IDC_GRAPHIC1, "", 5, 5, 750, 460, %WS_CHILD _
    OR %WS_VISIBLE OR %SS_NOTIFY
  CONTROL ADD STATUSBAR, hDlg, %IDC_STATUSBAR, "", 0, 0, 0, 0
  CONTROL ADD CHECKBOX,  hDlg, %IDC_LANDINGZONE, "Landing Zone", 810, 48, _
    150, 16, %WS_CHILD OR %WS_VISIBLE OR %WS_TABSTOP OR %BS_TEXT OR _
    %BS_AUTOCHECKBOX OR %BS_LEFTTEXT OR %BS_LEFT OR %BS_VCENTER, %WS_EX_LEFT _
    OR %WS_EX_LTRREADING
  CONTROL ADD CHECKBOX,  hDlg, %IDC_PICKUPZONE, "Pickup Zone", 810, 83, 150, _
    16, %WS_CHILD OR %WS_VISIBLE OR %WS_TABSTOP OR %BS_TEXT OR _
    %BS_AUTOCHECKBOX OR %BS_LEFTTEXT OR %BS_LEFT OR %BS_VCENTER, %WS_EX_LEFT _
    OR %WS_EX_LTRREADING
  CONTROL ADD CHECKBOX,  hDlg, %IDC_TARGETZONE, "Target Zone", 810, 118, 150, _
    16, %WS_CHILD OR %WS_VISIBLE OR %WS_TABSTOP OR %BS_TEXT OR _
    %BS_AUTOCHECKBOX OR %BS_LEFTTEXT OR %BS_LEFT OR %BS_VCENTER, %WS_EX_LEFT _
    OR %WS_EX_LTRREADING
  CONTROL ADD LABEL,     hDlg, %IDC_lblShowZones, "Show Zones?", 784, 16, _
    150, 16
  CONTROL SET COLOR      hDlg, %IDC_lblShowZones, %BLUE, -1
#PBFORMS END DIALOG
  CONTROL ADD IMAGE, hDlg, %IDC_imgLANDINGZONE, "LandingZone", 776, 48, 24, 24
  CONTROL ADD IMAGE, hDlg, %IDC_imgPICKUPZONE, "PickupZone", 776, 80, 24, 24
  CONTROL ADD IMAGE, hDlg, %IDC_imgTARGETZONE, "TargetZone", 776, 112, 24, 24
  '
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
      ' get the terrain type
      lngTerrain = g_lngTerrain(lngR,lngC,%Terrain)
      ' now store the centre of the hex
      g_lngTerrain(lngR,lngC,%X) = lngXStart + (nWidth& \ 2)
      g_lngTerrain(lngR,lngC,%Y) = lngYStart + (nHeight& \ 2)
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
      lngDistance = SQR((ABS(lngX - g_lngTerrain(lngR,lngC,%X))^2) + _
                       (ABS(lngY - g_lngTerrain(lngR,lngC,%Y))^2))
      IF lngDistance < lngShortestDist THEN
        lngShortestDist = lngDistance
        strFound = CHR$(%Terrain.Grasslands-1 +lngR) & FORMAT$(lngC) & _
                   " Terrain = " & CHR$(g_lngTerrain(lngR,lngC,%Terrain))
      END IF
    NEXT lngC
  NEXT lngR
  '
  FUNCTION = strFound
'
END FUNCTION
'
FUNCTION funBuildRandomTerrain() AS LONG
' generate random terrain
  LOCAL lngR AS LONG
  LOCAL lngC AS LONG
  LOCAL lngTerrain AS LONG
  '
  RANDOMIZE TIMER
  '
  FOR lngR = 1 TO %MaxX
    FOR lngC = 1 TO %MaxY
      lngTerrain = RND(%Terrain.Grasslands,%Terrain.Water)
      g_lngTerrain(lngR,lngC,%Terrain) = lngTerrain
    NEXT lngC
  NEXT lngR
  '
END FUNCTION
'
FUNCTION funSetPickup(hDlg AS DWORD,lngRedo AS LONG) AS LONG
' set the pickup point
' look for Terrain = %Terrain.Grasslands for pickup
  LOCAL lngR AS LONG
  LOCAL lngC AS LONG
  LOCAL lngFound AS LONG
  '
  LOCAL strBitmapMask AS STRING
  LOCAL strBitmap AS STRING
  LOCAL nFile&, nWidth&, nHeight&
  LOCAL lngXStart AS LONG
  LOCAL lngYStart AS LONG
  LOCAL hBmpMask AS DWORD
  LOCAL hBmp AS DWORD
  '
  IF ISTRUE lngRedo THEN
    DO WHILE ISFALSE(lngFound)
      lngR = RND(1,%MaxX)
      lngC = RND(1,%MaxY)
      '
      IF g_lngTerrain(lngR,lngC,%Terrain) = %Terrain.Grasslands THEN
        lngFound = %TRUE
      END IF
    LOOP
    '
    PREFIX "PickUpLocation."
      x = lngR
      y = lngC
    END PREFIX
  ELSE
    lngR = PickUpLocation.x
    lngC = PickUpLocation.y
  END IF
  '
  strBitmapMask = EXE.PATH$ & "\Graphics\PickupMask.bmp"
  '
  nFile& = FREEFILE
  OPEN strBitmapMask FOR BINARY AS nFile&
  GET #nFile&, 19, nWidth&
  GET #nFile&, 23, nHeight&
  CLOSE nFile&
  '
  strBitmap = EXE.PATH$ & "\Graphics\Pickup.bmp"
  '
  GRAPHIC BITMAP LOAD strBitmapMask, nWidth&, nHeight& TO hBmpMask
  GRAPHIC BITMAP LOAD strBitmap, nWidth&, nHeight& TO hBmp
  '
  lngXStart = g_lngTerrain(lngR, lngC,%X) - (nWidth& \ 2)
  lngYStart = g_lngTerrain(lngR, lngC,%Y) - (nHeight& \ 2)
  '
  GRAPHIC COPY hBmpMask, %IDC_GRAPHIC1 TO _
           (lngXStart, lngYStart), %MIX_MASKSRC
  GRAPHIC COPY hBmp, %IDC_GRAPHIC1 TO _
           (lngXStart, lngYStart), %MIX_MERGESRC
  '
  GRAPHIC BITMAP END
  GRAPHIC REDRAW
  '
END FUNCTION
'
FUNCTION funSetTargetZone(hDlg AS DWORD,lngRedo AS LONG) AS LONG
' set the Target zone
' look for Terrain = %Terrain.Buildings for target zone
  LOCAL lngR AS LONG
  LOCAL lngC AS LONG
  LOCAL lngFound AS LONG
  '
  LOCAL strBitmapMask AS STRING
  LOCAL strBitmap AS STRING
  LOCAL nFile&, nWidth&, nHeight&
  LOCAL lngXStart AS LONG
  LOCAL lngYStart AS LONG
  LOCAL hBmpMask AS DWORD
  LOCAL hBmp AS DWORD
  '
  IF ISTRUE lngRedo THEN
    DO WHILE ISFALSE(lngFound)
      lngR = RND(1,%MaxX)
      lngC = RND(1,%MaxY)
      ' target zone is building and not at
      ' the pickup location or landing zone
      IF g_lngTerrain(lngR,lngC,%Terrain) = %Terrain.Buildings AND _
                      lngR <> PickupLocation.x AND _
                      lngC <> PickupLocation.y AND _
                      lngR <> LandingZone.x AND _
                      lngC <> LandingZone.y THEN
        lngFound = %TRUE
      END IF
    LOOP
    '
    PREFIX "TargetZone."
      x = lngR
      y = lngC
    END PREFIX
  ELSE
    lngR = TargetZone.x
    lngC = TargetZone.y
  END IF
  '
  strBitmapMask = EXE.PATH$ & "\Graphics\SmallTargetZoneMask.bmp"
  '
  nFile& = FREEFILE
  OPEN strBitmapMask FOR BINARY AS nFile&
  GET #nFile&, 19, nWidth&
  GET #nFile&, 23, nHeight&
  CLOSE nFile&
  '
  strBitmap = EXE.PATH$ & "\Graphics\SmallTargetZone.bmp"
  '
  GRAPHIC BITMAP LOAD strBitmapMask, nWidth&, nHeight& TO hBmpMask
  GRAPHIC BITMAP LOAD strBitmap, nWidth&, nHeight& TO hBmp
  '
  lngXStart = g_lngTerrain(lngR, lngC,%X) - (nWidth& \ 2)
  lngYStart = g_lngTerrain(lngR, lngC,%Y) - (nHeight& \ 2)
  '
  GRAPHIC COPY hBmpMask, %IDC_GRAPHIC1 TO _
           (lngXStart, lngYStart), %MIX_MASKSRC
  GRAPHIC COPY hBmp, %IDC_GRAPHIC1 TO _
           (lngXStart, lngYStart), %MIX_MERGESRC
  '
  GRAPHIC BITMAP END
  GRAPHIC REDRAW
  '
END FUNCTION
'
FUNCTION funSetLandingZone(hDlg AS DWORD,lngRedo AS LONG) AS LONG
' set the Landing zone
' look for Terrain <> %Terrain.Water for landing zone
  LOCAL lngR AS LONG
  LOCAL lngC AS LONG
  LOCAL lngFound AS LONG
  '
  LOCAL strBitmapMask AS STRING
  LOCAL strBitmap AS STRING
  LOCAL nFile&, nWidth&, nHeight&
  LOCAL lngXStart AS LONG
  LOCAL lngYStart AS LONG
  LOCAL hBmpMask AS DWORD
  LOCAL hBmp AS DWORD
  '
  IF ISTRUE lngRedo THEN
    DO WHILE ISFALSE(lngFound)
      lngR = RND(1,%MaxX)
      lngC = RND(1,%MaxY)
      ' landing zone is not water or the pickup location
      IF g_lngTerrain(lngR,lngC,%Terrain) <> %Terrain.Water AND _
                      lngR <> PickupLocation.x AND _
                      lngC <> PickupLocation.y THEN
                      '
        lngFound = %TRUE
      END IF
    LOOP
    '
    PREFIX "LandingZone."
      x = lngR
      y = lngC
    END PREFIX
  ELSE
    lngR = LandingZone.x
    lngC = LandingZone.y
  END IF
  '
  strBitmapMask = EXE.PATH$ & "\Graphics\SmallLandingZoneMask.bmp"
  '
  nFile& = FREEFILE
  OPEN strBitmapMask FOR BINARY AS nFile&
  GET #nFile&, 19, nWidth&
  GET #nFile&, 23, nHeight&
  CLOSE nFile&
  '
  strBitmap = EXE.PATH$ & "\Graphics\SmallLandingZone.bmp"
  '
  GRAPHIC BITMAP LOAD strBitmapMask, nWidth&, nHeight& TO hBmpMask
  GRAPHIC BITMAP LOAD strBitmap, nWidth&, nHeight& TO hBmp
  '
  lngXStart = g_lngTerrain(lngR, lngC,%X) - (nWidth& \ 2)
  lngYStart = g_lngTerrain(lngR, lngC,%Y) - (nHeight& \ 2)
  '
  GRAPHIC COPY hBmpMask, %IDC_GRAPHIC1 TO _
           (lngXStart, lngYStart), %MIX_MASKSRC
  GRAPHIC COPY hBmp, %IDC_GRAPHIC1 TO _
           (lngXStart, lngYStart), %MIX_MERGESRC
  '
  GRAPHIC BITMAP END
  GRAPHIC REDRAW
  '
END FUNCTION

'
FUNCTION funRedrawHexTerrain(lngX AS LONG , lngY AS LONG) AS STRING
' Redraw the Terrain type for given Hex location
  LOCAL strTerrain AS STRING
  LOCAL strBitmap AS STRING
  LOCAL strBitmapMask AS STRING
  LOCAL nFile&, nWidth&, nHeight&
  LOCAL hBmp AS DWORD
  LOCAL hBmpMask AS DWORD
  LOCAL lngXstart AS LONG
  LOCAL lngYstart AS LONG
  '
  ' determine the terrain
  strTerrain = CHR$(g_lngTerrain(lngX,lngY,%Terrain))
  lngXstart = g_lngTerrain(lngX,lngY,%X)
  lngYstart = g_lngTerrain(lngX,lngY,%Y)

  ' open the Bitmap mask
  strBitmapMask = EXE.PATH$ & "\Graphics\MaskBig.bmp"
  '
  nFile& = FREEFILE
  OPEN strBitmapMask FOR BINARY AS nFile&
  GET #nFile&, 19, nWidth&
  GET #nFile&, 23, nHeight&
  CLOSE nFile&
  '
  strBitmap = EXE.PATH$ & "\Graphics\" & strTerrain & ".bmp"
  '
  GRAPHIC BITMAP LOAD strBitmapMask, nWidth&, nHeight& TO hBmpMask
  GRAPHIC BITMAP LOAD strBitmap, nWidth&, nHeight& TO hBmp
  '
  lngXstart = lngXstart - (nWidth&\2)
  lngYstart = lngYstart - (nHeight&\2)
  '
  GRAPHIC COPY hBmpMask, %IDC_GRAPHIC1 TO _
      (lngXstart, lngYstart), %MIX_MASKSRC
  GRAPHIC COPY hBmp, %IDC_GRAPHIC1 TO _
      (lngXstart, lngYstart), %MIX_MERGESRC
      '
  GRAPHIC BITMAP END
  GRAPHIC REDRAW
'
END FUNCTION
'
FUNCTION funRedrawMap(hDlg AS DWORD) AS LONG
' redraw the map
  LOCAL lngState AS LONG
  ' put the terrain back
  GRAPHIC SET BITS g_strGameMap
  '
  CONTROL GET CHECK hDlg,%IDC_LANDINGZONE TO lngState
  '
  IF lngState = 1 THEN
    funSetLandingZone(hDlg,%FALSE)
  END IF
  '
  CONTROL GET CHECK hDlg,%IDC_PICKUPZONE TO lngState
  IF lngState = 1 THEN
    funSetPickup(hDlg,%FALSE)
  END IF
  '
  CONTROL GET CHECK hDlg,%IDC_TARGETZONE TO lngState
  IF lngState = 1 THEN
    funSetTargetZone(hDlg,%FALSE)
  END IF
  '
  GRAPHIC REDRAW
  '
END FUNCTION
'
FUNCTION funSetBuildings(hDlg AS DWORD, lngRedo AS LONG) AS LONG
' set the buildings location
' start with the Target zone which needs a building
'TYPE udtBuilding
  '  x AS LONG         ' grid location
  '  y AS LONG         ' grid location
  '  z AS LONG         ' offset 1-6
  '  condition AS LONG ' buildings current condition
  'END TYPE
  LOCAL lngR AS LONG
  LOCAL lngC AS LONG
  LOCAL lngZ AS LONG
  LOCAL lngB AS LONG
  '
  LOCAL strBitmapMask AS STRING
  LOCAL strBitmap AS STRING
  LOCAL nFile&, nWidth&, nHeight&
  LOCAL lngXStart AS LONG
  LOCAL lngYStart AS LONG
  LOCAL lngXOffset AS LONG
  LOCAL lngYOffset AS LONG
  LOCAL hBmpMask AS DWORD
  LOCAL hBmp AS DWORD
  LOCAL lngFound AS LONG
  '
  FOR lngB = 1 TO %MaxBuildings
    IF ISTRUE lngRedo THEN
      ' save the buildings as it's first run?
      IF lngB = 1 THEN
        ' pick up target zone location
        lngR = TargetZone.x
        lngC = TargetZone.y
        lngZ = RND(1,6)
        '
        REDIM g_uBuildings(1 TO %MaxBuildings)
        '
      ELSE
      ' handle all other buildings and work out
      ' value of lngR,lngC,lngZ
        lngFound = %FALSE
        DO WHILE ISFALSE lngFound
          IF ISTRUE funFindTerrain(%Terrain.Buildings,lngR,lngC) THEN
          ' found a building zone - is it occupied?
            lngFound = funFindBuildingSpace(lngR,lngC,lngZ)
          END IF
        LOOP

      END IF
      '
      ' now store the data
      PREFIX "g_uBuildings(lngB)."
        x = lngR
        y = lngC
        z = lngZ
        state = %Condition.Active
      END PREFIX
      '
    ELSE
      ' use the stored locations of buildings
      lngR = g_uBuildings(lngB).x
      lngC = g_uBuildings(lngB).y
      lngZ = g_uBuildings(lngB).z
    END IF
    '
    SELECT CASE lngZ
      CASE 1
        lngXOffset = 0
        lngYOffset = -20
      CASE 2
        lngXOffset = 12
        lngYOffset = -12
      CASE 3
        lngXOffset = 12
        lngYOffset =  12
      CASE 4
        lngXOffset = 0
        lngYOffset = 20
      CASE 5
        lngXOffset = -12
        lngYOffset = 12
      CASE 6
        lngXOffset = -12
        lngYOffset = -12
    END SELECT
    '
    ' determine the state of the building
    SELECT CASE g_uBuildings(lngB).state
      CASE %Condition.Active
      ' building is operational
        strBitmapMask = EXE.PATH$ & "\Graphics\BuildingMask.bmp"
        strBitmap = EXE.PATH$ & "\Graphics\Building.bmp"
        '
      CASE %Condition.Damaged
      ' building is damaged
      '
      CASE %Condition.Destroyed
      ' building is destroyed

      '
    END SELECT
    '
    ' get the details of the bitmap
    nFile& = FREEFILE
    OPEN strBitmapMask FOR BINARY AS nFile&
    GET #nFile&, 19, nWidth&
    GET #nFile&, 23, nHeight&
    CLOSE nFile&
    '
    GRAPHIC BITMAP LOAD strBitmapMask, nWidth&, nHeight& TO hBmpMask
    GRAPHIC BITMAP LOAD strBitmap, nWidth&, nHeight& TO hBmp
    '
    lngXStart = g_lngTerrain(lngR, lngC,%X) - (nWidth& \ 2) + lngXOffset
    lngYStart = g_lngTerrain(lngR, lngC,%Y) - (nHeight& \ 2) + lngYOffset
    '
    GRAPHIC COPY hBmpMask, %IDC_GRAPHIC1 TO _
             (lngXStart, lngYStart), %MIX_MASKSRC
    GRAPHIC COPY hBmp, %IDC_GRAPHIC1 TO _
             (lngXStart, lngYStart), %MIX_MERGESRC
    '
    '
  NEXT lngB
  '
  GRAPHIC BITMAP END
  GRAPHIC REDRAW
  '
END FUNCTION
'
FUNCTION funFindTerrain(lngTerrainType AS LONG, _
                        o_lngR AS LONG, _
                        o_lngC AS LONG) AS LONG
' look for the terrain type requested on the map
  LOCAL lngR AS LONG
  LOCAL lngC AS LONG
  LOCAL lngFound AS LONG
  '
  DO WHILE ISFALSE(lngFound)
    lngR = RND(1,%MaxX)
    lngC = RND(1,%MaxY)
    '
    IF g_lngTerrain(lngR,lngC,%Terrain) = lngTerrainType THEN
      lngFound = %TRUE
    END IF
  LOOP
  '
  o_lngR = lngR
  o_lngC = lngC
  FUNCTION = lngFound
  '
END FUNCTION
'
FUNCTION funFindBuildingSpace(lngR AS LONG, _
                              lngC AS LONG, _
                              o_lngZ AS LONG) AS LONG
' find if there is any more space for buildings at this location
  LOCAL lngB AS LONG
  LOCAL strBuildingSlots AS STRING
  LOCAL lngFound AS LONG
  '
  strBuildingSlots = "000000"
  'TYPE udtBuilding
  '  x AS LONG         ' grid location
  '  y AS LONG         ' grid location
  '  z AS LONG         ' offset 1-6
  '  state AS LONG     ' buildings current condition
  'END TYPE
  '
  ' check all buildings at this location
  FOR lngB = 1 TO %MaxBuildings
    ' found the location - record it
    IF g_uBuildings(lngB).x = lngR AND _
       g_uBuildings(lngB).y = lngC THEN
       MID$(strBuildingSlots,g_uBuildings(lngB).z,1) = "1"
       lngFound = %TRUE
    END IF
    '
  NEXT lngB
  '
  IF ISTRUE lngFound THEN
    ' strBuildingSlots will now be populated with total number of populated slots
    FOR lngB = 1 TO 6
      IF MID$(strBuildingSlots,lngB,1) = "0" THEN
        o_lngZ = lngB
        FUNCTION = %TRUE
        EXIT FUNCTION
      END IF
    NEXT lngB
    '
    ' we couldn't find a slot at this location
    o_lngZ = 0
    FUNCTION = %FALSE
    '
  ELSE
  ' no buildings found so far
    o_lngZ = 1
    FUNCTION = %TRUE
  END IF
  '
END FUNCTION
