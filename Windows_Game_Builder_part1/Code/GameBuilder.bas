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
#RESOURCE "GameBuilder.pbr"
%USEMACROS = 1
#INCLUDE ONCE "WIN32API.INC"
#INCLUDE ONCE "COMMCTRL.INC"
#INCLUDE ONCE "PBForms.INC"
#PBFORMS END INCLUDES
'------------------------------------------------------------------------------
#INCLUDE "PB_FileHandlingRoutines.inc"
#INCLUDE "PB_LoadJPG_as_Bitmap.inc"
#INCLUDE "Macro_Library.inc"
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
#PBFORMS END CONSTANTS
'------------------------------------------------------------------------------
' set the Build and version number
mReleasePackage BuildVersion = "Development Build"
mReleasePackage VerNumber = "1.0.0.1"
'------------------------------------------------------------------------------
'
GLOBAL g_hDlg AS DWORD    ' global for dialog handle
' Terrain
%TerrainSea  = 16710401
%TerrainLand = 15115264
'
%BoxSize = 8
%MapWidth = 100
%MapHeight = 50
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
  REDIM a_strMap(%MapHeight) AS STRING'

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

        ' /* Inserted by PB/Forms 03-15-2024 12:38:14
        CASE %IDC_btnBulkTurns
          IF CB.CTLMSG = %BN_CLICKED OR CB.CTLMSG = 1 THEN
            '

            '
          END IF
        ' */

        ' /*
        CASE %IDC_graph_Territories
          IF CB.CTLMSG = %STN_CLICKED OR CB.CTLMSG = 1 THEN

           '
         END IF

            '
        ' /* Inserted by PB/Forms 03-08-2024 16:12:12
        CASE %IDC_graphMapFile
          lngFlags = %OFN_FILEMUSTEXIST
          '
          IF CB.CTLMSG = %BN_CLICKED OR CB.CTLMSG = 1 THEN
          '
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
              END IF
              '
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
    150, 25
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
  IF ISTRUE funLoadMapArray(hDlg,a_strMap(),lngMapFile) THEN
    GRAPHIC ATTACH hDlg, lngBigMap,REDRAW
    '
    ' now draw coloured squares
    IF ISTRUE funDrawTerrainMap(hDlg,lngBigMap,a_strMap()) THEN
      '
      IF ISTRUE funDrawGrid(hDlg,lngBigMap) THEN
        FUNCTION = %TRUE
      ELSE
        FUNCTION = %FALSE
      END IF
      '
    ELSE
      FUNCTION = %FALSE
    END IF
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
  '
  lngXsize = lngWidth\%MapWidth
  lngYsize = lngHeight\%MapHeight
  '
  FOR lngR = 1 TO 100
    FOR lngC = 1 TO 50
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
  GRAPHIC ATTACH hDlg, lngMapFile, REDRAW
  '
  FOR lngC = 1 TO 50
    strData = SPACE$(100)
    FOR lngR = 1 TO 100
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
  funArrayDump("Array.txt",a_strMap())
  '
  FUNCTION = %TRUE
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

'
END FUNCTION
'
FUNCTION funCheckRulerTerritories() AS LONG
' check the territories owned by rulers

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

  '
END FUNCTION

'
FUNCTION funUpdateTerritories() AS LONG
' redraw the territories borders
  '
END FUNCTION
'
FUNCTION funCheckTerrainForOwnership(lngO AS LONG, _
                                     lngX AS LONG, _
                                     lngY AS LONG) AS LONG
' check the terrain for ownership
  '
END FUNCTION
'
FUNCTION funMoveRulers() AS LONG
' move rulers
  '
END FUNCTION
'
FUNCTION funBattleWon(lngX AS LONG, _
                      lngY AS LONG, _
                      lngAttacker AS LONG, _
                      lngDefender AS LONG) AS LONG
' determine result of a battle
  '
END FUNCTION
'
FUNCTION funGetDirection(lngX AS LONG, _
                         lngY AS LONG) AS LONG
' return a random direction
  '
  '
END FUNCTION
'
FUNCTION funUpdateRulersOnMap() AS LONG
' place the rulers on the map
'
END FUNCTION
'
FUNCTION funPositionRulers() AS LONG
' position the rulers on the map
  '
END FUNCTION
'------------------------------------------------------------------------------
CALLBACK FUNCTION ShowdlgTerrainInfoProc()

  SELECT CASE AS LONG CB.MSG
    CASE %WM_INITDIALOG
      ' Initialization handler

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
        ' /* Inserted by PB/Forms 03-15-2024 16:03:28

      END SELECT
  END SELECT
END FUNCTION
'------------------------------------------------------------------------------

'------------------------------------------------------------------------------
FUNCTION ShowdlgTerrainInfo(BYVAL hParent AS DWORD, _
                            lngX AS LONG,lngY AS LONG) AS LONG
  LOCAL lRslt AS LONG
  LOCAL lngOwner AS LONG
  LOCAL strValue AS STRING
  LOCAL strOwnerDetails AS STRING
  '
#PBFORMS BEGIN DIALOG %IDD_dlgTerrainInfo->->
  LOCAL hDlg  AS DWORD

  DIALOG NEW hParent, "Terrain Inofrmation", 398, 192, 300, 181, %WS_POPUP OR _
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
  CONTROL ADD TEXTBOX, hDlg, %IDC_txtXlocation, "", 60, 5, 45, 13, %WS_CHILD _
    OR %WS_VISIBLE OR %WS_TABSTOP OR %ES_CENTER OR %ES_AUTOHSCROLL OR _
    %ES_READONLY, %WS_EX_CLIENTEDGE OR %WS_EX_LEFT OR %WS_EX_LTRREADING OR _
    %WS_EX_RIGHTSCROLLBAR
  CONTROL ADD TEXTBOX, hDlg, %IDC_txtYlocation, "", 60, 20, 45, 12, %WS_CHILD _
    OR %WS_VISIBLE OR %WS_TABSTOP OR %ES_CENTER OR %ES_AUTOHSCROLL OR _
    %ES_READONLY, %WS_EX_CLIENTEDGE OR %WS_EX_LEFT OR %WS_EX_LTRREADING OR _
    %WS_EX_RIGHTSCROLLBAR
  CONTROL ADD TEXTBOX, hDlg, %IDC_txtOwner, "", 60, 35, 45, 13, %WS_CHILD OR _
    %WS_VISIBLE OR %WS_TABSTOP OR %ES_LEFT OR %ES_AUTOHSCROLL OR _
    %ES_READONLY, %WS_EX_CLIENTEDGE OR %WS_EX_LEFT OR %WS_EX_LTRREADING OR _
    %WS_EX_RIGHTSCROLLBAR
  CONTROL ADD LABEL,   hDlg, %IDC_lblOwnerDetails, "Owner Details", 20, 55, _
    55, 10
  CONTROL SET COLOR    hDlg, %IDC_lblOwnerDetails, %BLUE, -1
  CONTROL ADD TEXTBOX, hDlg, %IDC_txtOwnerDetails, "", 20, 65, 260, 105, _
    %WS_CHILD OR %WS_VISIBLE OR %WS_TABSTOP OR %WS_VSCROLL OR %ES_LEFT OR _
    %ES_MULTILINE OR %ES_AUTOHSCROLL OR %ES_AUTOVSCROLL OR %ES_READONLY, _
    %WS_EX_CLIENTEDGE OR %WS_EX_LEFT OR %WS_EX_LTRREADING OR _
    %WS_EX_RIGHTSCROLLBAR
#PBFORMS END DIALOG
  '
  lngOwner = a_lngOwnerMap(lngX,lngY)
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
  strOwnerDetails = strOwnerDetails & strValue & $CRLF
  '
  IF lngOwner > 0 THEN
    strOwnerDetails = strOwnerDetails & _
                      "Ruler has " & _
                      FORMAT$(funCountTerritoriesOwned(lngOwner)) & _
                      " Territories" & $CRLF
  END IF
  '
  PREFIX "control set text hDlg,"
    %IDC_txtXlocation, FORMAT$(lngX)
    %IDC_txtYlocation, FORMAT$(lngY)
    %IDC_txtOwner,FORMAT$(lngOwner)
    %IDC_txtOwnerDetails, strOwnerDetails
  END PREFIX
  '
  DIALOG SHOW MODAL hDlg, CALL ShowdlgTerrainInfoProc TO lRslt

#PBFORMS BEGIN CLEANUP %IDD_dlgTerrainInfo
#PBFORMS END CLEANUP

  FUNCTION = lRslt
END FUNCTION
'------------------------------------------------------------------------------
