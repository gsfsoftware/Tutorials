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
'#RESOURCE "GameBuilder.pbr"
%USEMACROS = 1
#INCLUDE ONCE "WIN32API.INC"
#INCLUDE ONCE "COMMCTRL.INC"
#INCLUDE ONCE "PBForms.INC"
#PBFORMS END INCLUDES
'------------------------------------------------------------------------------
#INCLUDE "PB_FileHandlingRoutines.inc"
#INCLUDE "Macro_Library.inc"
#INCLUDE "ButtonPlus.bas"
#INCLUDE "PB_LoadJPG_as_Bitmap.inc"
'------------------------------------------------------------------------------
'   ** Constants **
'------------------------------------------------------------------------------
#PBFORMS BEGIN CONSTANTS
%IDD_DlgGAMEBUILDER    =  101
%IDABORT               =    3
%IDC_lblWorldMapFile   = 1003
%IDC_lblTerritories    = 1004
%IDC_graph_Territories = 1002
%IDC_graphMapFile      = 1001
%IDC_btnProcessTurns   = 1005
%IDC_TxtTurnNumber     = 1006
%IDC_lblBuildVersion   = 1008
%IDC_lblVersionNumber  = 1009
%IDC_lblTurnNumber     = 1007
%IDC_STATUSBAR         = 1010
%IDC_btnBulkTurns      = 1011
%IDC_lblRulerCount     = 1013
%IDC_txtRulerCount     = 1012
%IDD_dlgTerrainInfo    =  102
%IDC_lblXLocation      = 1014
%IDC_lblYLocation      = 1015
%IDC_lblOwner          = 1016
%IDC_txtXlocation      = 1017
%IDC_txtYlocation      = 1018
%IDC_txtOwner          = 1019
%IDC_lblOwnerDetails   = 1020
%IDC_txtOwnerDetails   = 1021
%IDC_graSmallMap       = 1023
%IDC_gra3DTerrain      = 1022
%IDC_graCompass        = 1024
%IDC_imgNorth          = 1025
%IDC_imgSouth          = 1026
%IDC_imgWest           = 1027
%IDC_imgEast           = 1028
%IDC_txtStep           = 1031
%IDC_udStep            = 1030
%IDC_lblStep           = 1032
#PBFORMS END CONSTANTS
'------------------------------------------------------------------------------
' set the Build and version number
mReleasePackage BuildVersion = "Development Build"
mReleasePackage VerNumber = "1.0.0.1"
'------------------------------------------------------------------------------
#RESOURCE ICON, 2001, "Terrain.ico"
#RESOURCE ICON, 2002, "West.ico"
#RESOURCE ICON, 2003, "East.ico"
#RESOURCE ICON, 2004, "South.ico"
#RESOURCE ICON, 2005, "North.ico"

'
%ID_TIMER1             = 4000
'
GLOBAL g_hDlg AS DWORD    ' global for dialog handle
' Terrain
%TerrainSea  = 16710401
%TerrainLand = 15115264
'
%BoxSize = 8                   ' size of Terrain boxes
%MapWidth = 100                ' width of map in Terrain boxes
%MapHeight = 50                ' height of map in terrain boxes
'
%MaxMountains = 50             ' maximum number of mountains
%VerticalOffset = 15           ' amount of vertical offset for
                               ' each level of hill/mountain
'
GLOBAL a_strMap() AS STRING    ' terrain map
GLOBAL a_lngOwnerMap() AS LONG ' owners of map
GLOBAL g_strGameMap AS STRING  ' save the entire graphics map
'
%TotalRulers = 50
GLOBAL g_lngCurrentRulers AS LONG  ' count of active rulers
'
TYPE udtRulers
  lngX AS LONG         ' x co-ordinate
  lngY AS LONG         ' y co-ordinate
  lngPower AS LONG     ' Power level = territories accumulated
  lngActive AS LONG    ' 1 = active  0 = not active
  lngDefeats AS LONG   ' number of times defeated
  lngVictories AS LONG ' number of times victorious
END TYPE
'
GLOBAL a_Rulers() AS udtRulers
'
GLOBAL g_lngTurnNumber AS LONG ' the current turn
%BulkTurns = 100               ' the number of turns processed in bulk
%TurnForTrimmingRulers = 100   ' turn after which rulers with only
'                                1 territory are trimmed
' Polygons
TYPE PolyPoint
  x AS SINGLE
  y AS SINGLE
END TYPE
'
TYPE PolyArray
  COUNT AS LONG
  xy(1 TO 4) AS PolyPoint
END TYPE
'
%MaxX = 15     ' size of the Polygon map
%MaxY = 15

'------------------------------------------------------------------------------
'   ** Declarations **
'------------------------------------------------------------------------------

#PBFORMS DECLARATIONS
'------------------------------------------------------------------------------
GLOBAL ghFont AS DWORD
'------------------------------------------------------------------------------
'   ** Main Application Entry Point **
'------------------------------------------------------------------------------
FUNCTION PBMAIN()
  ' set up the arrays
  RANDOMIZE TIMER  ' prepare random seed
  ' map array
  REDIM a_strMap(%MapHeight) AS STRING
  ' ruler array
  REDIM a_Rulers(%TotalRulers) AS udtRulers
  ' owners of map
  REDIM a_lngOwnerMap(%MapWidth,%MapHeight) AS LONG
  '
  PBFormsInitComCtls (%ICC_WIN95_CLASSES OR %ICC_DATE_CLASSES OR _
    %ICC_INTERNET_CLASSES)
  FONT NEW "Comic sans MS",12 TO ghFont
  ShowDlgGAMEBUILDER %HWND_DESKTOP
  FONT END ghFont
END FUNCTION
'------------------------------------------------------------------------------

'------------------------------------------------------------------------------
'   ** CallBacks **
'------------------------------------------------------------------------------
CALLBACK FUNCTION ShowDlgGAMEBUILDERProc()
  LOCAL lngFlags AS LONG     ' flags for file selection
  LOCAL strMapFile AS STRING ' path and name of map file selected
  '
  LOCAL lng_imgW AS LONG     ' width of image file
  LOCAL lng_imgH AS LONG     ' height of image file
  LOCAL hBMP AS DWORD        ' handle of bitmap
  LOCAL strTurn AS STRING    ' value of Turn number field
  LOCAL lngTurn AS LONG      ' used for 50 turns button
  '
  LOCAL lngX, lngY AS LONG   ' co-ords on graphics terrain
  LOCAL p AS POINTAPI        ' used to determine mouse position
                             ' on graphics control
  '
  SELECT CASE AS LONG CB.MSG
    CASE %WM_INITDIALOG
      ' Initialization handler
      PREFIX "control set text cb.hndl,"
        %IDC_lblBuildVersion, BuildVersion
        %IDC_lblVersionNumber,"Version number - " & VerNumber
      END PREFIX
      '
      g_lngCurrentRulers = %TotalRulers
      '

      ' disable turn buttons
      PREFIX "CONTROL DISABLE CB.HNDL,"
        %IDC_btnProcessTurns
        %IDC_btnBulkTurns
      END PREFIX
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
        ' /* Inserted by PB/Forms 03-15-2024 13:12:52
        CASE %IDC_txtRulerCount
        ' */

        ' /* Inserted by PB/Forms 03-15-2024 12:38:14
        CASE %IDC_btnBulkTurns
          IF CB.CTLMSG = %BN_CLICKED OR CB.CTLMSG = 1 THEN
            '
            PREFIX "control disable cb.hndl,"
              %IDC_btnProcessTurns
              %IDC_btnBulkTurns
            END PREFIX
            '
            FOR lngTurn = 1 TO %BulkTurns
              funProcessTurn(CB.HNDL,%IDC_graph_Territories, _
                             g_lngTurnNumber)
              SLEEP 100
            NEXT lngTurn
            '
            PREFIX "control enable cb.hndl,"
              %IDC_btnProcessTurns
              %IDC_btnBulkTurns
            END PREFIX
            '
          END IF
        ' */

        ' /* Inserted by PB/Forms 03-10-2024 15:24:40
        CASE %IDC_STATUSBAR
        ' */
        CASE %IDC_graph_Territories
          IF CB.CTLMSG = %STN_CLICKED OR CB.CTLMSG = 1 THEN
           GetCursorPos(p)
           ScreenToClient CB.LPARAM, p
           ' convert to box co-ords
           lngX = (p.x \ %BoxSize)  +1
           lngY = (p.y \ %BoxSize) +1
           '
           ShowDlgTerrainInfo(CB.HNDL, lngX,lngY, _
                              %IDC_graph_Territories, _
                              p.x,p.y)
           '
         END IF

            '
        ' /* Inserted by PB/Forms 03-08-2024 16:12:12
        CASE %IDC_graphMapFile
          lngFlags = %OFN_FILEMUSTEXIST
          '
          IF CB.CTLMSG = %BN_CLICKED OR CB.CTLMSG = 1 THEN
            DISPLAY OPENFILE CB.HNDL, , , "Select Map file", _
              EXE.PATH$ & "Maps", CHR$("Maps", 0, "*.bmp", 0) _
              , "", "", lngFlags TO strMapFile
              '
            IF strMapFile <> "" THEN
            ' file selected - so load it into the Map graphics control
              GRAPHIC ATTACH CB.HNDL, %IDC_graphMapFile, REDRAW
              GRAPHIC RENDER BITMAP strMapFile, (0,0)-(101, 51)
              '
              ' image loaded ok
              GRAPHIC COPY hBmp,0
              GRAPHIC BITMAP END
              GRAPHIC REDRAW
              '
              IF ISTRUE funRebuildMap(CB.HNDL, _
                                      %IDC_graphMapFile, _
                                      %IDC_graph_Territories) THEN
              ' loaded and display successfully
                GRAPHIC REDRAW
                CONTROL SET TEXT CB.HNDL,%IDC_STATUSBAR,"Map loaded"
                '
                g_lngTurnNumber = 0 ' reset turn number
                funSetTurnNumber(g_lngTurnNumber)
                '
                PREFIX "CONTROL enable CB.HNDL,"
                  %IDC_btnProcessTurns
                END PREFIX
                '
                CONTROL SET TEXT CB.HNDL,%IDC_txtRulerCount, _
                                    FORMAT$(g_lngCurrentRulers)
                '
              ELSE
                CONTROL SET TEXT CB.HNDL,%IDC_STATUSBAR, _
                                 "Unable to load map"
              '
              END IF
              '
            END IF
            '
          END IF
          '
        CASE %IDABORT
          IF CB.CTLMSG = %BN_CLICKED OR CB.CTLMSG = 1 THEN
            DIALOG END CB.HNDL
          END IF

        CASE %IDC_btnProcessTurns
          IF CB.CTLMSG = %BN_CLICKED OR CB.CTLMSG = 1 THEN
          ' process a turn
            funProcessTurn(CB.HNDL,%IDC_graph_Territories, _
                           g_lngTurnNumber)
                           '
            IF g_lngTurnNumber = 1 THEN
            ' enable bulk turn button after first turn
              CONTROL ENABLE CB.HNDL,%IDC_btnBulkTurns
            END IF
          '
          END IF

        CASE %IDC_TxtTurnNumber

      END SELECT
  END SELECT
END FUNCTION
'------------------------------------------------------------------------------

'------------------------------------------------------------------------------
'   ** Dialogs **
'------------------------------------------------------------------------------
FUNCTION ShowDlgGAMEBUILDER(BYVAL hParent AS DWORD) AS LONG
  LOCAL lRslt  AS LONG
  LOCAL lngX,lngY AS LONG

#PBFORMS BEGIN DIALOG %IDD_DlgGAMEBUILDER->->
  LOCAL hDlg   AS DWORD
  LOCAL hFont1 AS DWORD

  DIALOG NEW PIXELS, hParent, "Game Builder", 221, 206, 907, 597, %WS_POPUP _
    OR %WS_BORDER OR %WS_DLGFRAME OR %WS_CAPTION OR %WS_SYSMENU OR _
    %WS_MINIMIZEBOX OR %WS_CLIPSIBLINGS OR %WS_VISIBLE OR %DS_MODALFRAME OR _
    %DS_CENTER OR %DS_3DLOOK OR %DS_NOFAILCREATE OR %DS_SETFONT, _
    %WS_EX_CONTROLPARENT OR %WS_EX_LEFT OR %WS_EX_LTRREADING OR _
    %WS_EX_RIGHTSCROLLBAR, TO hDlg
  CONTROL ADD GRAPHIC,   hDlg, %IDC_graphMapFile, "", 680, 45, 136, 67, _
    %WS_CHILD OR %WS_VISIBLE OR %WS_BORDER OR %SS_SUNKEN OR %SS_NOTIFY
  CONTROL ADD GRAPHIC,   hDlg, %IDC_graph_Territories, "", 60, 120, 800, 400, _
    %WS_CHILD OR %WS_VISIBLE OR %WS_BORDER OR %SS_SUNKEN OR %SS_NOTIFY
  CONTROL ADD BUTTON,    hDlg, %IDABORT, "Exit", 792, 544, 64, 23
  CONTROL ADD LABEL,     hDlg, %IDC_lblWorldMapFile, "World Map File", 680, _
    20, 100, 25
  CONTROL SET COLOR      hDlg, %IDC_lblWorldMapFile, %BLUE, -1
  CONTROL ADD LABEL,     hDlg, %IDC_lblTerritories, "World Map Territories", _
    60, 85, 100, 25
  CONTROL SET COLOR      hDlg, %IDC_lblTerritories, %BLUE, -1
  CONTROL ADD BUTTON,    hDlg, %IDC_btnProcessTurns, "Process Turn", 60, 40, _
    80, 25
  CONTROL ADD TEXTBOX,   hDlg, %IDC_TxtTurnNumber, "0", 170, 40, 94, 32, _
    %WS_CHILD OR %WS_VISIBLE OR %WS_TABSTOP OR %ES_CENTER OR %ES_AUTOHSCROLL _
    OR %ES_READONLY, %WS_EX_CLIENTEDGE OR %WS_EX_LEFT OR %WS_EX_LTRREADING _
    OR %WS_EX_RIGHTSCROLLBAR
  CONTROL SET COLOR      hDlg, %IDC_TxtTurnNumber, %BLUE, -1
  CONTROL ADD LABEL,     hDlg, %IDC_lblTurnNumber, "Current Turn", 170, 14, _
    100, 25
  CONTROL SET COLOR      hDlg, %IDC_lblTurnNumber, %BLUE, -1
  CONTROL ADD LABEL,     hDlg, %IDC_lblBuildVersion, "", 300, 30, 150, 15
  CONTROL SET COLOR      hDlg, %IDC_lblBuildVersion, %BLUE, -1
  CONTROL ADD LABEL,     hDlg, %IDC_lblVersionNumber, "", 300, 53, 150, 15
  CONTROL SET COLOR      hDlg, %IDC_lblVersionNumber, %BLUE, -1
  CONTROL ADD STATUSBAR, hDlg, %IDC_STATUSBAR, "Ready", 0, 0, 0, 0
  CONTROL ADD BUTTON,    hDlg, %IDC_btnBulkTurns, "Process Bulk Turns", 296, _
    88, 160, 25
  CONTROL ADD TEXTBOX,   hDlg, %IDC_txtRulerCount, "0", 528, 40, 94, 32, _
    %WS_CHILD OR %WS_VISIBLE OR %WS_TABSTOP OR %ES_CENTER OR %ES_AUTOHSCROLL _
    OR %ES_READONLY, %WS_EX_CLIENTEDGE OR %WS_EX_LEFT OR %WS_EX_LTRREADING _
    OR %WS_EX_RIGHTSCROLLBAR
  CONTROL SET COLOR      hDlg, %IDC_txtRulerCount, %BLUE, -1
  CONTROL ADD LABEL,     hDlg, %IDC_lblRulerCount, "Current Rulers", 528, 14, _
    100, 25
  CONTROL SET COLOR      hDlg, %IDC_lblRulerCount, %BLUE, -1

  FONT NEW "MS Sans Serif", 18, 0, %ANSI_CHARSET TO hFont1

  CONTROL SET FONT hDlg, %IDC_TxtTurnNumber, hFont1
  CONTROL SET FONT hDlg, %IDC_txtRulerCount, hFont1
#PBFORMS END DIALOG
  '
  lngX = %MapWidth * %BoxSize
  lngY = %MapHeight * %BoxSize
  '
  GRAPHIC ATTACH hDlg, %IDC_graph_Territories
  GRAPHIC SET SIZE lngX,lngY
  '
  GRAPHIC ATTACH hDlg,%IDC_graphMapFile
  GRAPHIC SET SIZE %MapWidth+1,%MapHeight+1
  '
  PREFIX "control set font hDlg, "
    %IDC_lblTurnNumber, ghFont
    %IDC_lblWorldMapFile, ghFont
    %IDC_lblTerritories, ghFont
    %IDC_lblRulerCount, ghFont
  END PREFIX
  '
  g_hDlg = hDlg  ' store the dialog handle
  '
  DIALOG SET ICON hDlg, "#2001"
  DIALOG SHOW MODAL hDlg, CALL ShowDlgGAMEBUILDERProc TO lRslt
  '
#PBFORMS BEGIN CLEANUP %IDD_DlgGAMEBUILDER
  FONT END hFont1
#PBFORMS END CLEANUP

  FUNCTION = lRslt
END FUNCTION
'------------------------------------------------------------------------------
'
FUNCTION funRebuildMap(hDlg AS DWORD, _
                       lngMapFile AS LONG, _
                       lngBigMap AS LONG) AS LONG
' rebuild the mapfile

  '
  IF ISTRUE funLoadMapArray(hDlg,a_strMap(),lngMapFile) THEN
    GRAPHIC ATTACH hDlg, lngBigMap,REDRAW

    ' now draw coloured squares
    IF ISTRUE funDrawTerrainMap(hDlg,lngBigMap,a_strMap()) THEN
      IF ISTRUE funDrawGrid(hDlg,lngBigMap) THEN
      ' capture the terrain map
      ' now store the whole graphics map
        GRAPHIC GET BITS TO g_strGameMap
        FUNCTION = %TRUE
      ELSE
        FUNCTION = %FALSE
      END IF
    ELSE
      FUNCTION = %FALSE
    END IF
    '
  ELSE
    FUNCTION = %FALSE
  END IF
  '
END FUNCTION
'
FUNCTION funDrawTerrainMap(hDlg AS DWORD,_
                           lngBigMap AS LONG, _
                           BYREF a_strMap() AS STRING) AS LONG
' draw the coloured terrain map
  LOCAL lngR , lngC AS LONG
  LOCAL lngFillColour AS LONG
  LOCAL lngX , lngY AS LONG
  LOCAL lngWidth, lngHeight AS LONG
  LOCAL lngXsize , lngYsize AS LONG
  LOCAL lngX1, lngY1 AS LONG
  LOCAL lngX2, lngY2 AS LONG
  '
  GRAPHIC GET SIZE TO lngWidth, lngHeight
  lngXsize = lngWidth\%MapWidth
  lngYsize = lngHeight\%MapHeight
  '
  FOR lngR = 1 TO 100
    FOR lngC = 1 TO 50
      '
      ' work out co-ordinates
      lngX1 = ((lngR - 1)*lngXsize) +1
      lngY1 = ((lngC - 1)*lngYsize) +1
      lngX2 = lngX1 + lngXsize
      lngY2 = lngY1 + lngYsize
      '
      SELECT CASE MID$(a_strMap(lngC),lngR,1)
        CASE "0"
          lngFillColour = %RGB_LIGHTBLUE
        CASE "1"
          lngFillColour = %RGB_GREEN
      END SELECT
      '
      GRAPHIC BOX (lngX1, lngY1) - (lngX2, lngY2) , 0 , _
                   lngFillColour , lngFillColour , 0
      '
    NEXT lngC
  NEXT lngR
  '
  FUNCTION = %TRUE
  '
END FUNCTION
'
FUNCTION funDrawGrid(hDlg AS DWORD, _
                     lngBigMap AS LONG) AS LONG
' draw the grid on the graphics territory control
  LOCAL lngR AS LONG
  LOCAL lngC AS LONG
  LOCAL lngX1, lngY1 AS LONG
  LOCAL lngX2, lngY2 AS LONG
  LOCAL lngWidth, lngHeight AS LONG
  LOCAL lngXStep,lngYStep AS LONG
  '
  GRAPHIC GET SIZE TO lngWidth, lngHeight
  '
  lngXStep = lngWidth\%MapWidth   ' get X co-ord steps
  lngYStep = lngHeight\%MapHeight ' get Y co-ord steps
  '
  FOR lngR = 1 TO %MapWidth + 1
    lngX1 = ((lngR - 1)*lngXStep)
    lngX2 = lngX1
    '
    lngY1 = 1
    lngY2 = lngHeight
    GRAPHIC LINE (lngX1, lngY1) - (lngX2,lngY2), %RGB_BLACK
  NEXT lngR
  '
  FOR lngC = 1 TO %MapHeight + 1
    lngX1 = 1
    lngX2 = lngWidth
    '
    lngY1 = ((lngC - 1)*lngYStep)
    lngY2 = lngY1
    GRAPHIC LINE (lngX1, lngY1) - (lngX2,lngY2), %RGB_BLACK
  NEXT lngC
  '
  FUNCTION = %TRUE
  '
END FUNCTION
'
FUNCTION funLoadMapArray( hDlg AS DWORD, _
                          BYREF a_strMap() AS STRING, _
                          lngMapFile AS LONG) AS LONG
' load the data into the Map array
  LOCAL lngR AS LONG
  LOCAL lngC AS LONG
  LOCAL lngPixel AS LONG
  LOCAL strData AS STRING
  '
  ' where 15246080 = blue  - sea
  ' and 15115264   = green - land
  '
  GRAPHIC ATTACH hDlg, lngMapFile, REDRAW
  '

  FOR lngC = 1 TO %MapHeight
    strData = SPACE$(%MapWidth)
    FOR lngR = 1 TO %MapWidth
      ' get value of pixel
      GRAPHIC GET PIXEL (lngR, lngC) TO lngPixel
      ' now populate the array
      SELECT CASE lngPixel
        CASE %TerrainSea
          MID$(strData,lngR,1) = "0"
        CASE ELSE
          MID$(strData,lngR,1) = "1"
      END SELECT
    NEXT lngR
      '
    a_strMap(lngC) = strData
  NEXT lngC
  '
  funBuildMountains()
  '
  ' save to disk for reference
  funArrayDump("Array.txt",a_strMap())
  '
  FUNCTION = %TRUE
  '
END FUNCTION
'
FUNCTION funBuildMountains() AS LONG
' position all the mountains
  LOCAL lngCountMountains AS LONG
  '
  LOCAL lngR , lngC AS LONG
  '
  WHILE lngCountMountains < %MaxMountains
    lngR = RND(1,%MapWidth)
    lngC = RND(1,%MapHeight)
    '
    IF MID$(a_strMap(lngC),lngR,1) <> "0" THEN
    ' its land - so make it a mountain
      MID$(a_strMap(lngC),lngR,1) = "3"
      ' advance the count
      INCR lngCountMountains
      ' create some hills around the mountain
      funCreateHills(lngR,lngC)
    '
    END IF
    '
  WEND
  '
END FUNCTION
'
FUNCTION funCreateHills(lngR AS LONG, _
                        lngC AS LONG) AS LONG
' create some hills around the location
  LOCAL lngX, lngY AS LONG
  '
  FOR lngX = lngR -1 TO lngR +1
    FOR lngY = lngC -1 TO lngC +1
      ' dont change the mountain
      IF lngX = lngR AND lngY = lngC THEN ITERATE
      ' ensure within bounds of map
      IF lngX >= 1 AND lngX <= %MapWidth THEN
        IF lngY >= 1 AND lngY <= %MapHeight THEN
          IF MID$(a_strMap(lngY),lngX,1) <> "0" THEN
          ' its not sea
            IF RND(1,100) <= 75 THEN
            ' %75 chance of a hill
              MID$(a_strMap(lngY),lngX,1) = "2"
            END IF
            '
          END IF
        END IF
      END IF
      '
    NEXT lngY
  NEXT lngX
  '
END FUNCTION
'
FUNCTION funSetTurnNumber(lngTurn AS LONG) AS LONG
' set the turn number
  CONTROL SET TEXT g_hDlg, %IDC_TxtTurnNumber,FORMAT$(lngTurn)
  CONTROL REDRAW g_hDlg, %IDC_TxtTurnNumber
  g_lngTurnNumber = lngTurn
  '
END FUNCTION
'
FUNCTION funProcessTurn(hDlg AS DWORD, _
                        lngBigMap AS LONG, _
                        lngTurnNumber AS LONG) AS LONG
' process a turn
  '
  GRAPHIC ATTACH hDlg, lngBigMap,REDRAW
  '
  IF lngTurnNumber = 0 THEN
  ' first turn so position the Rulers
    funPositionRulers()
    funUpdateRulersOnMap()
  ELSE
  ' work out movement
    funMoveRulers()
    '
    ' redraw the basic map
    GRAPHIC SET BITS g_strGameMap
    '
    funUpdateRulersOnMap()
    funUpdateTerritories()
    funCheckRulerTerritories()
    funUpdateRulerCount(hDlg)
    '
  END IF
  '
  INCR lngTurnNumber
  funSetTurnNumber(lngTurnNumber)
  '
  GRAPHIC REDRAW
  '
END FUNCTION
'
FUNCTION funCheckRulerTerritories() AS LONG
' check the territories owned by rulers
  LOCAL lngR AS LONG
  LOCAL lngCount AS LONG
  LOCAL lngX , lngY AS LONG
  '
  FOR lngR = 1 TO %TotalRulers
    IF a_rulers(lngR).lngActive = 0 THEN
    ' not active should have no territorial power
      a_rulers(lngR).lngPower = 0
    ELSE
    ' still active, recount territories
      a_rulers(lngR).lngPower = funCountTerritoriesOwned(lngR)
      '
    END IF
  NEXT lngR
  '
END FUNCTION
'
FUNCTION funUpdateRulerCount(hDlg AS DWORD) AS LONG
' count the currently active rulers
  LOCAL lngR AS LONG
  LOCAL lngCount AS LONG
  '
  FOR lngR = 1 TO %TotalRulers
    IF a_rulers(lngR).lngActive = 1 THEN
      INCR lngCount
    END IF
  NEXT lngR
  '
  CONTROL SET TEXT hDlg,%IDC_txtRulerCount, FORMAT$(lngCount)
  CONTROL REDRAW hDlg,%IDC_txtRulerCount
  g_lngCurrentRulers = lngCount
  '
END FUNCTION
'
FUNCTION funCountTerritoriesOwned(lngOwner AS LONG) AS LONG
' count the territories owned by this ruler
  LOCAL lngX , lngY AS LONG
  LOCAL lngCount AS LONG
  '
  FOR lngX = 1 TO %MapWidth
    FOR lngY = 1 TO %MapHeight
      IF a_lngOwnerMap(lngX,lngY) = lngOwner THEN
        INCR lngCount
      END IF
    NEXT lngY
  NEXT lngX
  '
  FUNCTION = lngCount
  '
END FUNCTION

'
FUNCTION funUpdateTerritories() AS LONG
' redraw the territories borders
  LOCAL lngX, lngY AS LONG
  LOCAL strTerrain AS STRING
  LOCAL lngXstart, lngYstart AS LONG
  '
  LOCAL lngWidth, lngHeight AS LONG
  LOCAL lngXsize, lngYsize AS LONG
  '
  LOCAL lngCheckX, lngCheckY AS LONG
  LOCAL lngO AS LONG
  LOCAL lngX1, lngY1 AS LONG
  '
  GRAPHIC GET SIZE TO lngWidth, lngHeight
  lngXsize = lngWidth\%MapWidth
  lngYsize = lngHeight\%MapHeight
  '
  FOR lngX = 1 TO %MapWidth
    FOR lngY = 1 TO %MapHeight
      strTerrain = MID$(a_strMap(lngY),lngX,1)
      IF strTerrain = "0" THEN ITERATE ' do nothing if Sea
      '
      lngO = a_lngOwnerMap(lngX,lngY) ' get the owner
      IF lngO = 0 THEN ITERATE ' not owned by anyone
      '
      ' check if ruler is now inactive
      IF a_rulers(lngO).lngActive = 0 THEN
      ' clear territory ownership
        a_lngOwnerMap(lngX,lngY) = 0
        ' and iterate
        ITERATE
      END IF
      '
      ' work out borders on all four sides
      ' get top left co-ords
      lngX1 = ((lngX - 1)*lngXsize)
      lngY1 = ((lngY - 1)*lngYsize)
      '
      ' check terrain to left
      lngCheckX = lngX -1
      IF ISTRUE funCheckTerrainForOwnership(lngO,lngCheckX,lngY) THEN
      ' redraw border
        GRAPHIC LINE (lngX1, lngY1) - _
                     (lngX1,lngY1 + lngYsize), %RGB_GREEN
      END IF
      '
      ' check terrain to right
      lngCheckX = lngX +1
      IF ISTRUE funCheckTerrainForOwnership(lngO,lngCheckX,lngY) THEN
      ' redraw border
        GRAPHIC LINE (lngX1 + lngXsize, lngY1) -  _
                     (lngX1 + lngXsize,lngY1 + lngYsize), %RGB_GREEN
      END IF
      ' check terrain above
      lngCheckY = lngY -1
      IF ISTRUE funCheckTerrainForOwnership(lngO,lngX,lngCheckY) THEN
      ' redraw border
        GRAPHIC LINE (lngX1 , lngY1) -  _
                     (lngX1 + lngXsize,lngY1), %RGB_GREEN
      END IF
      ' check terrain below
      lngCheckY = lngY +1
      IF ISTRUE funCheckTerrainForOwnership(lngO,lngX,lngCheckY) THEN
      ' redraw border
        GRAPHIC LINE (lngX1 , lngY1 + lngYsize) -  _
                     (lngX1 + lngXsize,lngY1 + lngYsize), %RGB_GREEN
      END IF
      '
    NEXT lngY
  NEXT lngX
  '
END FUNCTION
'
FUNCTION funCheckTerrainForOwnership(lngO AS LONG, _
                                     lngX AS LONG, _
                                     lngY AS LONG) AS LONG
' check the terrain for ownership
  '
  IF lngX = 0 OR lngY = 0 OR _
     lngX > %MapWidth OR _
     lngY > %MapHeight THEN
  ' off the map
    FUNCTION = %FALSE
  ELSE
  ' on the map
    IF MID$(a_strMap(lngY),lngX,1) <> "0" THEN
    ' on map and not sea
      IF a_lngOwnerMap(lngX,lngY) = lngO THEN
      ' owned by this ruler
        FUNCTION = %TRUE
      ELSE
        FUNCTION = %FALSE
      END IF
    '
    ELSE
    ' it's sea terrain
      FUNCTION = %FALSE
    END IF
    '
  END IF
  '
END FUNCTION
'
FUNCTION funTerrainAdjacent(lngDX AS LONG, _
                            lngDY AS LONG, _
                            lngR AS LONG) AS LONG
' is the terrain being moved to adjacent to an already
' owned territory?
' lngX, lngY is where they are moving to
' lngR is the player number
  LOCAL lngRT, lngCT AS LONG
  LOCAL lngX, lngY AS LONG
  '
  ' pick up players current position
  lngX = a_rulers(lngR).lngX
  lngY = a_rulers(lngR).lngY
  '
  IF lngX = lngDX AND lngY = lngDY THEN
  ' player is not moving
    FUNCTION = %TRUE
  ELSE
  ' player is moving
    IF a_lngOwnerMap(lngDX,lngDY-1) = lngR THEN
    ' adjacent terrain is already allied
      FUNCTION = %TRUE
    ELSEIF a_lngOwnerMap(lngDX,lngDY+1) = lngR THEN
      FUNCTION = %TRUE
    ELSEIF a_lngOwnerMap(lngDX-1,lngDY) = lngR THEN
      FUNCTION = %TRUE
    ELSEIF a_lngOwnerMap(lngDX+1,lngDY) = lngR THEN
      FUNCTION = %TRUE
    ELSE
      FUNCTION = %FALSE
    END IF
    '
  END IF
  '
END FUNCTION
'
FUNCTION funMoveRulers() AS LONG
' move rulers
  LOCAL lngR AS LONG             ' current ruler
  LOCAL lngX, lngY AS LONG       ' x & y co-ords of terrain on map
  LOCAL lngDX,lngDY AS LONG      ' direction of planned movement
  LOCAL lngTerrain AS LONG       ' terrain type
  LOCAL lngCount AS LONG         ' loop count to prevent infinite loops
  LOCAL lngPrevOwner AS LONG     ' previous owner
  '
  FOR lngR = 1 TO %TotalRulers
    IF a_rulers(lngR).lngActive = 1 THEN
    ' move this ruler?
      lngTerrain = 0 ' default to sea
      lngCount = 0
      '
      WHILE lngTerrain = 0 AND lngCount < 10
        INCR lngCount ' max of 10 attempts
        lngX = a_rulers(lngR).lngX
        lngY = a_rulers(lngR).lngY
        '
        lngDX = 0 : lngDY = 0
        funGetDirection(lngDX,lngDY)
        '
        ' set the new location
        IF lngX + lngDX > 0 AND lngX + lngDX <= %MapWidth THEN
          lngX = lngX + lngDX
        END IF
        '
        IF lngY + lngDY > 0 AND lngY + lngDY <= %MapHeight THEN
          lngY = lngY + lngDY
        END IF
        '
        ' get the terrain ruler could be moving to
        lngTerrain = VAL(MID$(a_strMap(lngY),lngX,1))
        ' skip if this is sea
        IF lngTerrain = 0 THEN ITERATE LOOP
        '
        ' is terrain adjacent to existing owned territory?
        IF ISFALSE funTerrainAdjacent(lngX,lngY,lngR) THEN
          ITERATE LOOP
        END IF
        '
        ' is this terrain already owned?
        SELECT CASE a_lngOwnerMap(lngX,lngY)
          CASE 0
          ' not owned so move to this terrain and
          ' mark it as owned
            a_lngOwnerMap(lngX,lngY) = lngR
            ' add to rulers power (1 more territory)
            INCR a_rulers(lngR).lngPower
            '
            PREFIX "a_rulers(lngR)."
              lngX = lngX
              lngY = lngY
            END PREFIX
            '
          CASE lngR
          ' owned by this ruler- so just move into it
            PREFIX "a_rulers(lngR)."
              lngX = lngX
              lngY = lngY
            END PREFIX
            '
          CASE ELSE
          ' owned by someone else - battle for it?
            lngPrevOwner = a_lngOwnerMap(lngX,lngY)
            '
            IF ISTRUE funBattleWon(lngX,lngY,lngR,lngPrevOwner) THEN
            ' this ruler has won the territory
            ' now owned by this ruler- so just move into it
              PREFIX "a_rulers(lngR)."
                lngX = lngX
                lngY = lngY
              END PREFIX
              '
              ' mark it as owned
              a_lngOwnerMap(lngX,lngY) = lngR
              INCR a_rulers(lngR).lngPower
              '
            ELSE
            ' battle has not been won
            ' so don't move or change territory ownership
            '
            END IF
          '
        END SELECT
        '
        EXIT LOOP
        '
      WEND
      '
    END IF
  NEXT lngR
  '
END FUNCTION
'
FUNCTION funBattleWon(lngX AS LONG, _
                      lngY AS LONG, _
                      lngAttacker AS LONG, _
                      lngDefender AS LONG) AS LONG
' determine result of a battle
  LOCAL lngDefenderPowerPoints AS LONG
  LOCAL lngAttackerPowerPoints AS LONG
  LOCAL lngDefenderPresent AS LONG
  '
  LOCAL lngDefenderAdj AS LONG  ' adjustments for victories - defeats
  LOCAL lngAttackerAdj AS LONG
  '
  lngDefenderPowerPoints = a_rulers(lngDefender).lngPower
  lngAttackerPowerPoints = a_rulers(lngAttacker).lngPower
  '
  ' is defender in the territory?
  IF a_rulers(lngDefender).lngX = lngX AND _
     a_rulers(lngDefender).lngX = lngY THEN
  ' increase defenders power point by 10%
    lngDefenderPowerPoints = lngDefenderPowerPoints * 1.10
    lngDefenderPresent = %TRUE
  END IF
  '
  ' any adjustments for victories?
  lngAttackerAdj = a_rulers(lngAttacker).lngVictories - _
                   a_rulers(lngAttacker).lngDefeats
                   '
  lngDefenderAdj = a_rulers(lngDefender).lngVictories - _
                   a_rulers(lngDefender).lngDefeats
                   '
  lngAttackerPowerPoints = lngAttackerPowerPoints + lngAttackerAdj
  lngDefenderPowerPoints = lngDefenderPowerPoints + lngDefenderAdj
  '
  IF lngAttackerPowerPoints > lngDefenderPowerPoints THEN
  ' reduce territories owned by defender
    DECR a_rulers(lngDefender).lngPower
    '
    ' adjust victories as attacker won
    INCR a_rulers(lngDefender).lngDefeats
    INCR a_rulers(lngAttacker).lngVictories
    '
    IF a_rulers(lngDefender).lngPower = 0 THEN
    ' defenders last territory has gone
      a_rulers(lngDefender).lngActive = 0
      '
    END IF
    '
    IF ISTRUE lngDefenderPresent THEN
    ' defender ruler eliminated
      a_rulers(lngDefender).lngActive = 0
    END IF
    '
    FUNCTION = %TRUE
    '
  ELSE
  ' adjust victories as defender won
    INCR a_rulers(lngAttacker).lngDefeats
    INCR a_rulers(lngDefender).lngVictories
    FUNCTION = %FALSE
  END IF
  '
END FUNCTION
'
FUNCTION funGetDirection(lngX AS LONG, _
                         lngY AS LONG) AS LONG
' return a random direction
  '
  WHILE lngX = 0 AND lngY = 0
    lngX = RND(-1,+1)
    lngY = RND(-1,+1)
  WEND
  '
END FUNCTION
'
FUNCTION funUpdateRulersOnMap() AS LONG
' place the rulers on the map
  LOCAL lngR AS LONG
  LOCAL lngX , lngY AS LONG
  '
  LOCAL lngWidth, lngHeight AS LONG
  LOCAL lngXsize, lngYsize AS LONG
  '
  LOCAL lngX1,lngY1,lngX2, lngY2 AS LONG
  LOCAL lngFillColour AS LONG
  '
  lngFillColour = %RGB_RED
  '
  GRAPHIC GET SIZE TO lngWidth, lngHeight
  lngXsize = lngWidth\%MapWidth
  lngYsize = lngHeight\%MapHeight
  '
  FOR lngR = 1 TO %TotalRulers
    '
    IF a_rulers(lngR).lngPower = 1 AND _
       g_lngTurnNumber > %TurnForTrimmingRulers THEN
    ' ruler has only one territory - so remove them
      a_rulers(lngR).lngActive = 0
      a_lngOwnerMap(a_rulers(lngR).lngX,a_rulers(lngR).lngY) = 0
    '
    END IF
    '
    IF a_rulers(lngR).lngActive = 1 THEN
    ' ruler is active
      lngX = a_rulers(lngR).lngX
      lngY = a_rulers(lngR).lngY
      '
       ' work out co-ordinates
      lngX1 = ((lngX - 1)*lngXsize) +1
      lngY1 = ((lngY - 1)*lngYsize) +1
      lngX2 = lngX1 + lngXsize -1
      lngY2 = lngY1 + lngYsize -1
      '
      GRAPHIC BOX (lngX1, lngY1) - (lngX2, lngY2) , 80 , _
                   lngFillColour , lngFillColour , 0
    '
    END IF
    '
  NEXT lngR
'
END FUNCTION
'
FUNCTION funPositionRulers() AS LONG
' position the rulers on the map
  LOCAL lngR AS LONG
  LOCAL lngX, lngY AS LONG
  LOCAL lngValid AS LONG
  '
  FOR lngR = 1 TO %TotalRulers
    lngValid = %FALSE
    '
    WHILE lngValid = %FALSE
      lngX = RND(1,%MapWidth)
      lngY = RND(1,%MapHeight)
      '
      IF MID$(a_strMap(lngY),lngX,1) <> "0" THEN
      ' land area
        IF a_lngOwnerMap(lngX,lngY) = 0 THEN
        ' not currently owned
          a_lngOwnerMap(lngX,lngY) = lngR ' set ruler
          'TYPE udtRulers
          '  lngX AS LONG      ' x co-ordinate
          '  lngY AS LONG      ' y co-ordinate
          '  lngPower AS LONG  ' Power level = territories accumulated
          '  lngActive AS LONG ' 1 = active  0 = not active
          'END TYPE
          '
          ' populate the Rulers array
          PREFIX "a_rulers(lngR)."
            lngX = lngX
            lngY = lngY
            lngPower = 1
            lngActive = 1
          END PREFIX
          '
          lngValid = %TRUE
          '
        END IF
      '
      END IF
      '
    WEND
    '
  NEXT lngR
  '
END FUNCTION
'------------------------------------------------------------------------------
CALLBACK FUNCTION ShowdlgTerrainInfoProc()
  STATIC lngX, lngY AS LONG
  STATIC lngStep AS LONG        ' use for size of navigation movement
  LOCAL strStep AS STRING
  '
  LOCAL o_lng_imgW,o_lng_imgH AS LONG
  LOCAL o_hBMP AS DWORD
  '
  SELECT CASE AS LONG CB.MSG
    CASE %WM_INITDIALOG
      ' Initialization handler
        lngStep = 1
        ' Create WM_TIMER events with the SetTimer API
      SetTimer(CB.HNDL, %ID_TIMER1, _
               200, BYVAL %NULL)
               '
    CASE %WM_TIMER
      SELECT CASE CB.WPARAM
        CASE %ID_TIMER1
          '
          KillTimer(CB.HNDL, %ID_TIMER1)
           '
          DIALOG GET USER CB.HNDL,1 TO lngX
          DIALOG GET USER CB.HNDL,2 TO lngY
          '
          GRAPHIC ATTACH CB.HNDL,%IDC_gra3DTerrain , REDRAW
          GRAPHIC SCALE (0,0)- (680,580)
          funDrawPolygonsTerrain(lngX, lngY)
          GRAPHIC REDRAW
          '
      END SELECT
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
        ' /* Inserted by PB/Forms 04-28-2024 13:51:17

        CASE %IDC_txtStep
          IF CB.CTLMSG = %EN_CHANGE THEN
          ' value has changed
            CONTROL GET TEXT CB.HNDL, CB.CTL TO strStep
            lngStep = VAL(strStep)
          '
          END IF
          '
        CASE %IDC_imgNorth
          IF CB.CTLMSG = %BN_CLICKED OR CB.CTLMSG = 1 THEN
            IF lngY - lngStep > 0 THEN
              lngY = lngY - lngStep
              GRAPHIC ATTACH CB.HNDL,%IDC_gra3DTerrain , REDRAW
              funDrawPolygonsTerrain(lngX, lngY)
              GRAPHIC REDRAW
              '
              funCopySmallMap(CB.HNDL, _
                              %IDC_graSmallMap, _
                              g_hDlg, _
                              %IDC_graph_Territories,_
                              lngX, lngY)
                              '
              funUpdateTerrainDetails(CB.HNDL,lngX, lngY)
              '
            END IF
          END IF

        CASE %IDC_imgSouth
          IF CB.CTLMSG = %BN_CLICKED OR CB.CTLMSG = 1 THEN
            IF lngY + lngStep < %MapHeight THEN
              lngY = lngY + lngStep
              GRAPHIC ATTACH CB.HNDL,%IDC_gra3DTerrain , REDRAW
              funDrawPolygonsTerrain(lngX, lngY)
              GRAPHIC REDRAW
              '
              funCopySmallMap(CB.HNDL, _
                              %IDC_graSmallMap, _
                              g_hDlg, _
                              %IDC_graph_Territories,_
                              lngX, lngY)
                              '
              funUpdateTerrainDetails(CB.HNDL,lngX, lngY)
              '
            END IF
          END IF

        CASE %IDC_imgWest
          IF CB.CTLMSG = %BN_CLICKED OR CB.CTLMSG = 1 THEN
            IF lngX - lngStep > 0 THEN
              lngX = lngX - lngStep
              GRAPHIC ATTACH CB.HNDL,%IDC_gra3DTerrain , REDRAW
              funDrawPolygonsTerrain(lngX, lngY)
              GRAPHIC REDRAW
              '
              funCopySmallMap(CB.HNDL, _
                              %IDC_graSmallMap, _
                              g_hDlg, _
                              %IDC_graph_Territories,_
                              lngX, lngY)
                              '
              funUpdateTerrainDetails(CB.HNDL,lngX, lngY)
              '
            END IF
          END IF

        CASE %IDC_imgEast
          IF CB.CTLMSG = %BN_CLICKED OR CB.CTLMSG = 1 THEN
            IF lngX + lngStep < %MapWidth THEN
              lngX = lngX + lngStep
              GRAPHIC ATTACH CB.HNDL,%IDC_gra3DTerrain , REDRAW
              funDrawPolygonsTerrain(lngX, lngY)
              GRAPHIC REDRAW
              '
              funCopySmallMap(CB.HNDL, _
                              %IDC_graSmallMap, _
                              g_hDlg, _
                              %IDC_graph_Territories,_
                              lngX, lngY)
                              '
              funUpdateTerrainDetails(CB.HNDL, lngX, lngY)
              '
            END IF
          END IF
        ' */

        ' /* Inserted by PB/Forms 03-15-2024 16:03:28

      END SELECT
  END SELECT
END FUNCTION
'------------------------------------------------------------------------------
'
FUNCTION funUpdateTerrainDetails(hDlg AS DWORD, _
                                 lngX AS LONG, _
                                 lngY AS LONG) AS LONG
' update the co-ordinates
  LOCAL lngOwner AS LONG            ' owner number
  LOCAL strOwner AS STRING          ' owner as string
  LOCAL strOwnerDetails AS STRING   ' details of the owner
  LOCAL strValue AS STRING          ' temp string
  '
  lngOwner = a_lngOwnerMap(lngX,lngY)
  '
  IF lngOwner = 0 THEN
    strOwner = "None"
  ELSE
    strOwner = FORMAT$(lngOwner)
  END IF
  '
  IF a_rulers(lngOwner).lngActive = 1 THEN
    strValue = "Owner is active"
  ELSE
    IF lngOwner = 0 THEN
      strValue = "This terrain has no owner"
    ELSE
      strValue = "Owner is not active"
    END IF
  END IF
  '
  ' is owner in the territory?
  IF a_rulers(lngOwner).lngX = lngX AND _
     a_rulers(lngOwner).lngY = lngY THEN
     '
     strValue = strValue & $CRLF & "Owner is in the territory"
  END IF
  '
  strOwnerDetails = strOwnerDetails & strValue & $CRLF
  '
  IF lngOwner > 0 THEN
  ' only where there is an owner
    strOwnerDetails = strOwnerDetails & _
                      "Ruler has " & _
                      FORMAT$(funCountTerritoriesOwned(lngOwner)) & _
                      " Territories" & $CRLF
  END IF
  '
  PREFIX "control set text hDlg,"
    %IDC_txtXlocation, FORMAT$(lngX)
    %IDC_txtYlocation, FORMAT$(lngY)
    %IDC_txtOwner,strOwner
    %IDC_txtOwnerDetails, strOwnerDetails
  END PREFIX
  '
END FUNCTION
'------------------------------------------------------------------------------
FUNCTION ShowdlgTerrainInfo(BYVAL hParent AS DWORD, _
                            lngX AS LONG,lngY AS LONG, _
                            lng_graph_Territories AS LONG, _
                            lngGX AS LONG,lngGY AS LONG) AS LONG
  LOCAL lRslt AS LONG
  LOCAL lngOwner AS LONG
  LOCAL strValue AS STRING
  LOCAL strOwnerDetails AS STRING
  LOCAL lngXOffset , lngYOffset AS LONG
  LOCAL lngXSize, lngYSize AS LONG
  '
  LOCAL lng_imgW,lng_imgH AS LONG
  LOCAL hBMP AS DWORD
  '
#PBFORMS BEGIN DIALOG %IDD_dlgTerrainInfo->->
  LOCAL hDlg  AS DWORD
  LOCAL hFont1 AS DWORD

  DIALOG NEW hParent, "Terrain Information", 398, 192, 609, 418, %WS_POPUP OR _
    %WS_BORDER OR %WS_DLGFRAME OR %WS_CAPTION OR %WS_SYSMENU OR _
    %WS_CLIPSIBLINGS OR %WS_VISIBLE OR %DS_MODALFRAME OR %DS_CENTER OR _
    %DS_3DLOOK OR %DS_NOFAILCREATE OR %DS_SETFONT, %WS_EX_CONTROLPARENT OR _
    %WS_EX_LEFT OR %WS_EX_LTRREADING OR %WS_EX_RIGHTSCROLLBAR, TO hDlg
  CONTROL ADD LABEL,   hDlg, %IDC_lblXLocation, "X = ", 20, 5, 40, 10
  CONTROL SET COLOR    hDlg, %IDC_lblXLocation, %BLUE, -1
  CONTROL ADD LABEL,   hDlg, %IDC_lblYLocation, "Y = ", 20, 21, 40, 11
  CONTROL SET COLOR    hDlg, %IDC_lblYLocation, %BLUE, -1
  CONTROL ADD LABEL,   hDlg, %IDC_lblOwner, "Owner", 20, 38, 40, 11
  CONTROL SET COLOR    hDlg, %IDC_lblOwner, %BLUE, -1
  CONTROL ADD TEXTBOX,   hDlg, %IDC_txtXlocation, "", 60, 5, 45, 13, _
    %WS_CHILD OR %WS_VISIBLE OR %WS_TABSTOP OR %ES_CENTER OR %ES_AUTOHSCROLL _
    OR %ES_READONLY, %WS_EX_CLIENTEDGE OR %WS_EX_LEFT OR %WS_EX_LTRREADING _
    OR %WS_EX_RIGHTSCROLLBAR
  CONTROL ADD TEXTBOX,   hDlg, %IDC_txtYlocation, "", 60, 20, 45, 12, _
    %WS_CHILD OR %WS_VISIBLE OR %WS_TABSTOP OR %ES_CENTER OR %ES_AUTOHSCROLL _
    OR %ES_READONLY, %WS_EX_CLIENTEDGE OR %WS_EX_LEFT OR %WS_EX_LTRREADING _
    OR %WS_EX_RIGHTSCROLLBAR
  CONTROL ADD TEXTBOX,   hDlg, %IDC_txtOwner, "", 60, 35, 45, 13, %WS_CHILD _
    OR %WS_VISIBLE OR %WS_TABSTOP OR %ES_LEFT OR %ES_AUTOHSCROLL OR _
    %ES_READONLY, %WS_EX_CLIENTEDGE OR %WS_EX_LEFT OR %WS_EX_LTRREADING OR _
    %WS_EX_RIGHTSCROLLBAR
  CONTROL ADD LABEL,     hDlg, %IDC_lblOwnerDetails, "Owner Details", 20, _
    260, 55, 10
  CONTROL SET COLOR    hDlg, %IDC_lblOwnerDetails, %BLUE, -1
  CONTROL ADD TEXTBOX,   hDlg, %IDC_txtOwnerDetails, "", 20, 271, 315, 95, _
    %WS_CHILD OR %WS_VISIBLE OR %WS_TABSTOP OR %WS_VSCROLL OR %ES_LEFT OR _
    %ES_MULTILINE OR %ES_AUTOHSCROLL OR %ES_AUTOVSCROLL OR %ES_READONLY, _
    %WS_EX_CLIENTEDGE OR %WS_EX_LEFT OR %WS_EX_LTRREADING OR _
    %WS_EX_RIGHTSCROLLBAR
  CONTROL ADD GRAPHIC,   hDlg, %IDC_gra3DTerrain, "", 120, 5, 460, 245, _
    %WS_CHILD OR %WS_VISIBLE OR %WS_BORDER
  CONTROL ADD GRAPHIC,   hDlg, %IDC_graSmallMap, "", 20, 95, 90, 85, _
    %WS_CHILD OR %WS_VISIBLE OR %WS_BORDER
  CONTROL ADD IMGBUTTON, hDlg, %IDC_imgNorth, "", 460, 260, 21, 20
  CONTROL ADD IMGBUTTON, hDlg, %IDC_imgSouth, "", 460, 390, 21, 20
  CONTROL ADD IMGBUTTON, hDlg, %IDC_imgWest, "", 385, 319, 21, 19
  CONTROL ADD IMGBUTTON, hDlg, %IDC_imgEast, "", 531, 319, 21, 20
  CONTROL ADD GRAPHIC,   hDlg, %IDC_graCompass, "", 418, 285, 100, 100
  CONTROL ADD TEXTBOX,   hDlg, %IDC_txtStep, "1", 555, 375, 25, 25, %WS_CHILD _
    OR %WS_VISIBLE OR %WS_TABSTOP OR %ES_CENTER OR %ES_AUTOHSCROLL, _
    %WS_EX_CLIENTEDGE OR %WS_EX_LEFT OR %WS_EX_LTRREADING OR _
    %WS_EX_RIGHTSCROLLBAR
  CONTROL ADD LABEL,     hDlg, %IDC_lblStep, "Step", 560, 365, 70, 10
  CONTROL SET COLOR      hDlg, %IDC_lblStep, %BLUE, -1

  FONT NEW "MS Sans Serif", 14, 0, %ANSI_CHARSET TO hFont1

  CONTROL SET FONT hDlg, %IDC_txtStep, hFont1
#PBFORMS END DIALOG
  '
  funUpdateTerrainDetails(hDlg,lngX,lngY)
'  lngOwner = a_lngOwnerMap(lngX,lngY)
'  '
'  IF a_rulers(lngOwner).lngActive = 1 THEN
'    strValue = "Owner is active"
'  ELSE
'    IF lngOwner = 0 THEN
'      strValue = "This terrain has no owner"
'    ELSE
'      strValue = "Owner is not active"
'    END IF
'  END IF
'  '
'  ' is owner in the territory?
'  IF a_rulers(lngOwner).lngX = lngX AND _
'     a_rulers(lngOwner).lngY = lngY THEN
'     '
'     strValue = strValue & $CRLF & "Owner is in the territory"
'  END IF
'  '
'  strOwnerDetails = strOwnerDetails & strValue & $CRLF
'  '
'  IF lngOwner > 0 THEN
'    strOwnerDetails = strOwnerDetails & _
'                      "Ruler has " & _
'                      FORMAT$(funCountTerritoriesOwned(lngOwner)) & _
'                      " Territories" & $CRLF
'  END IF
'  '
'  PREFIX "control set text hDlg,"
'    %IDC_txtXlocation, FORMAT$(lngX)
'    %IDC_txtYlocation, FORMAT$(lngY)
'    %IDC_txtOwner,FORMAT$(lngOwner)
'    %IDC_txtOwnerDetails, strOwnerDetails
'  END PREFIX
  '
  DIALOG SET USER hDlg,1,lngX
  DIALOG SET USER hDlg,2,lngY
  '
   ' grab part of the terrain map and display it here
  funCopySmallMap(hDlg,%IDC_graSmallMap, _
                  hParent,lng_graph_Territories, _
                  lngX, lngY)
  '
  PREFIX "ButtonPlus hDlg, %IDC_imgWest, "
    %BP_ICON_ID, 2002
    %BP_ICON_WIDTH, 32
  END PREFIX
  '
  PREFIX "ButtonPlus hDlg, %IDC_imgEast, "
    %BP_ICON_ID, 2003
    %BP_ICON_WIDTH, 32
  END PREFIX
  '
  PREFIX "ButtonPlus hDlg, %IDC_imgSouth, "
    %BP_ICON_ID, 2004
    %BP_ICON_WIDTH, 32
  END PREFIX
  '
  PREFIX "ButtonPlus hDlg, %IDC_imgNorth, "
    %BP_ICON_ID, 2005
    %BP_ICON_WIDTH, 32
  END PREFIX
  '
  IF ISTRUE funLoadImageFile(EXE.PATH$ & "TerrainCompass.png", _
                                 lng_imgW, _
                                 lng_imgH, _
                                 hBMP ) THEN
    GRAPHIC ATTACH hDlg,%IDC_graCompass, REDRAW
    GRAPHIC COPY hBmp,0
    GRAPHIC BITMAP END
    GRAPHIC REDRAW
  END IF
  '
  DIALOG SHOW MODAL hDlg, CALL ShowdlgTerrainInfoProc TO lRslt

#PBFORMS BEGIN CLEANUP %IDD_dlgTerrainInfo
  FONT END hFont1
#PBFORMS END CLEANUP

  FUNCTION = lRslt
END FUNCTION
'------------------------------------------------------------------------------
FUNCTION funCopySmallMap(hDlg AS DWORD, _
                         graSmallMap AS LONG, _
                         hParent AS DWORD, _
                         lng_graph_Territories AS LONG,_
                         lngX AS LONG, lngY AS LONG) AS LONG
' populate the small map                         '
  LOCAL lngXOffset , lngYOffset AS LONG
  LOCAL lngXSize, lngYSize AS LONG
  LOCAL lngGX , lngGY AS LONG
  '
  lngGX = (lngX * %BoxSize)
  lngGY = (lngY * %BoxSize)
  '
  GRAPHIC ATTACH hDlg,graSmallMap, REDRAW
  GRAPHIC CLEAR
  GRAPHIC GET SIZE TO lngXSize, lngySize
  lngXOffset = (lngXSize \ 2)+20
  lngYOffset = (lngySize \ 2)+20
  '
  ' copy section of the large graphic terrain
  ' to the small graphics control
  GRAPHIC COPY hParent, lng_graph_Territories, _
               (lngGX-lngXOffset,lngGY-lngYOffset)- _
               (lngGX+lngXOffset+10,lngGY+lngYOffset+10) TO (0,0)
                             '
  ' draw circle round centre terrain
  LOCAL lngXTerrain, lngYTerrain AS LONG
  '
  lngXTerrain = (lngXSize\2) - %BoxSize +1
  lngYTerrain = (lngYSize\2) - %BoxSize -2
  '
  GRAPHIC ELLIPSE (lngXTerrain, lngYTerrain) - _
                  (lngXTerrain + %BoxSize, _
                   lngYTerrain + %BoxSize) , %RGB_YELLOW ,-2,0
               '
  GRAPHIC REDRAW
  '
END FUNCTION
'
FUNCTION funDrawPolygonsTerrain(lngX AS LONG, _
                                lngY AS LONG) AS LONG
' draw the polygons on the graphics control
  LOCAL lngR , lngC, lngH AS LONG
  LOCAL udtPolygon AS PolyArray
  LOCAL lngCorner AS LONG
  '
  LOCAL lngXStart, lngYStart AS LONG
  LOCAL lngSize, lngHOffset, lngVOffset AS LONG
  LOCAL lngSea AS LONG , lngAdj AS LONG
  '
  LOCAL lngMountain AS LONG ' used to determine hill/mountain
  '
  GRAPHIC CLEAR
  '
  lngXStart = 250
  lngYStart = 50
  lngSize   = 25
  lngHOffset = 15
  lngAdj = 25
  '
  ' work out which vertex has height
  DIM a_lngHeight(%MaxX+1,%MaxY+1) AS LONG
  ' get Terrain from global array
  funDetermine_Terrain(a_lngHeight(), lngX,lngY)
  '
  udtPolygon.count = 4
  FOR lngC = 1 TO %MaxY
    lngYStart = lngYstart + lngAdj
    lngXStart = lngXStart - (lngHOffset + 1)
    '
    lngMountain = %FALSE
    '
    FOR lngR = 1 TO %MaxX
      lngSea = %TRUE
      lngMountain = %FALSE
      ' set the coords of each corner of the polygon
      ' and its horizontal and vertical offsets
      lngVOffset = a_lngHeight(lngC,lngR)
      '
      IF lngVOffset > 0 THEN
        lngSea = %FALSE
        ' is this a mountain/hill?
        lngMountain = funDetermineMountain(lngVOffset,lngMountain)
      END IF
      '
      udtPolygon.xy(1).x = lngXStart + (lngR * lngAdj)
      udtPolygon.xy(1).y = lngYStart - lngVOffset
      '
      lngVOffset = a_lngHeight(lngC,lngR+1)
      IF lngVOffset > 0 THEN
        lngSea = %FALSE
      ' is this a mountain/hill?
        lngMountain = funDetermineMountain(lngVOffset,lngMountain)
      END IF
      '
      udtPolygon.xy(2).x = lngXStart + lngSize + (lngR * lngAdj)
      udtPolygon.xy(2).y = lngYStart - lngVOffset
      '
      lngVOffset = a_lngHeight(lngC+1,lngR+1)
      IF lngVOffset > 0 THEN
        lngSea = %FALSE
      ' is this a mountain/hill?
        lngMountain = funDetermineMountain(lngVOffset,lngMountain)
      END IF
      '
      udtPolygon.xy(3).x = lngXStart + lngSize + (lngR * lngAdj) - lngHOffset
      udtPolygon.xy(3).y = lngYStart + lngSize - lngVOffset
      '
      lngVOffset = a_lngHeight(lngC+1,lngR)
      IF lngVOffset > 0 THEN
        lngSea = %FALSE
      ' is this a mountain/hill?
        lngMountain = funDetermineMountain(lngVOffset,lngMountain)
      END IF
      '
      udtPolygon.xy(4).x = lngXStart + (lngR * lngAdj) - lngHOffset
      udtPolygon.xy(4).y = lngYStart + lngSize - lngVOffset
      '
      IF ISTRUE lngSea THEN
      ' all 4 corners of the polygon have a zero vertical offset
        GRAPHIC POLYGON udtPolygon,%BLACK,%RGB_DEEPSKYBLUE,0
      ELSE
        IF ISTRUE lngMountain THEN
        ' its a hill or mountain
          GRAPHIC POLYGON udtPolygon,%BLACK,%RGB_PERU ,0
        ELSE
        ' just normal land
          GRAPHIC POLYGON udtPolygon,%BLACK,%RGB_LIMEGREEN,0
        END IF
      END IF
      '
      'sleep 200 ' delay to allow debugging
      '
    NEXT lngR
    '
    'sleep 400 ' delay to allow debugging
  NEXT lngC
  GRAPHIC REDRAW
  '
END FUNCTION
'
FUNCTION funDetermineMountain(lngVOffset AS LONG, _
                              lngMountain AS LONG) AS LONG
' work out if terrain is 1,2 or 3
  LOCAL lngTerrainType AS LONG
  '
  IF ISTRUE lngMountain THEN
  ' it's already a mountain or hill
    FUNCTION = %TRUE
    '
  ELSE
  ' not yet a mountain
    lngTerrainType = lngVOffset / %VerticalOffset
    '
    IF lngTerrainType > 1 THEN
    ' its either a mountain or a hill
      FUNCTION = %TRUE
    END IF
  END IF
  '
END FUNCTION
'
FUNCTION funDetermine_Terrain(BYREF a_lngHeight() AS LONG, _
                              lngX AS LONG,lngY AS LONG) AS LONG
  ' work out which vertex has height
  LOCAL lngR , lngC AS LONG
  LOCAL lngVOffset AS LONG
  lngVOffset = %VerticalOffset      ' amount of vertical offset for each land type
  '
  LOCAL lngXO, lngYO AS LONG
  LOCAL lngTerrainType AS LONG
  '
  '
  FOR lngC = 1 TO UBOUND(a_lngHeight,2)   ' %MaxY
    FOR lngR = 1 TO UBOUND(a_lngHeight,1) '%MaxX
    ' establish the height of this location
       lngXO = lngX - 7 + lngR
       lngYO = lngY - 7 + lngC
       '
       IF lngXO > 0 AND lngXO <= %MapWidth AND _
          lngYO > 0 AND lngYO <= %MapHeight THEN
         '
         lngTerrainType = VAL(MID$(a_strMap(lngYO),lngXO,1))
         IF lngTerrainType > 0 THEN
         ' its land - set height
         ' handling hills and mountains
           a_lngHeight(lngC,lngR) = lngVOffset * lngTerrainType
         ELSE
         ' its sea
           a_lngHeight(lngC,lngR) = 0
         END IF
       ELSE
         ' its sea
           a_lngHeight(lngC,lngR) = 0
       END IF
       '
    NEXT lngR
  NEXT lngC
  '
END FUNCTION
'
