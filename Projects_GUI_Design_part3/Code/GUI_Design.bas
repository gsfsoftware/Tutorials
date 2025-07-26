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
#RESOURCE "GUI_Design.pbr"
%USEMACROS = 1
#INCLUDE ONCE "WIN32API.INC"
#INCLUDE ONCE "COMMCTRL.INC"
#INCLUDE ONCE "PBForms.INC"
#PBFORMS END INCLUDES
'------------------------------------------------------------------------------
%IdCol           = 1
%WidthCol        = 2
%HeightCol       = 3
%MinWindowHeight = 300        ' minimum size of the height - window will not shrink below this value
%MaxWindowHeight = 99999      ' maximum size of the window height
%MinWindowWidth  = 480        ' minimum size of the width - window will not shrink below this value
%MaxWindowWidth  = 99999      ' maximum size of the width

#INCLUDE "PB_Redraw.inc"
'
#RESOURCE ICON Appicon, "Graphics\App.ICO"
'
'------------------------------------------------------------------------------
'   ** Constants **
'------------------------------------------------------------------------------
#PBFORMS BEGIN CONSTANTS
%IDD_dlgMainDialog =  101
%IDC_GRAPHIC1      = 1001
#PBFORMS END CONSTANTS
'------------------------------------------------------------------------------
GLOBAL g_a_pHexLocations() AS POINT  ' global locations of hexes
GLOBAL g_lngShortDistance AS LONG    ' shortest distance for click
'
GLOBAL OldGraphicProc AS DWORD       ' for subclassing
GLOBAL g_hGraphic AS DWORD           ' graphic handle
GLOBAL g_hDlg AS DWORD               ' dialog handle
'------------------------------------------------------------------------------
'   ** Declarations **
'------------------------------------------------------------------------------
DECLARE CALLBACK FUNCTION ShowdlgMainDialogProc()
DECLARE FUNCTION ShowdlgMainDialog(BYVAL hParent AS DWORD) AS LONG
#PBFORMS DECLARATIONS
'------------------------------------------------------------------------------
%Max_Hexes = 7     ' total number of hex symbols to use
'
ENUM Hex SINGULAR
  ExitApp = 1
  MenuApp
  ReportApp
  WebApp
  SearchApp
  MessageApp
  SaveApp
END ENUM
'
GLOBAL g_astrButtonTooltips() AS STRING   ' array of button tooltips
GLOBAL g_strGraphicBitmap AS STRING       ' saved graphic bitmap
GLOBAL g_dwdhFont AS DWORD                ' handle of the font used for tooltips
'------------------------------------------------------------------------------
'   ** Main Application Entry Point **
'------------------------------------------------------------------------------
FUNCTION PBMAIN()
  PBFormsInitComCtls (%ICC_WIN95_CLASSES OR %ICC_DATE_CLASSES OR _
    %ICC_INTERNET_CLASSES)
  '
  DIM g_a_pHexLocations(1 TO %Max_Hexes) AS POINT
  '
   DIM g_astrButtonTooltips(1 TO %Max_Hexes) AS STRING
  ' create a font
  FONT NEW "Courier New",12,1,0,0 TO g_dwdhFont
  ' populate the array
  ARRAY ASSIGN g_astrButtonTooltips() =" Exit Application ", _
                                       " Menu Application ", _
                                       " Report Application ", _
                                       " Web Application ", _
                                       " Search Application ", _
                                       " Message Application ", _
                                       " Save Application "
  '
  ShowdlgMainDialog %HWND_DESKTOP
  '
  FONT END g_dwdhFont
  '
END FUNCTION
'------------------------------------------------------------------------------

'------------------------------------------------------------------------------
'   ** CallBacks **
'------------------------------------------------------------------------------
CALLBACK FUNCTION ShowdlgMainDialogProc()
' callback function to handle all window events
'
  LOCAL pLocation AS POINT   ' location as POINT
  LOCAL lngHex AS LONG       ' hex user has clicked on
  '
  SELECT CASE AS LONG CB.MSG
    CASE %WM_INITDIALOG
      ' Initialization handler
      ' get the windows handle of the graphics control
      CONTROL HANDLE CB.HNDL,%IDC_GRAPHIC1 TO g_hGraphic
      '
      OldGraphicProc = SetWindowLong(g_hGraphic, %GWL_WNDPROC, _
                       CODEPTR(GraphicProc))
      DIALOG MAXIMIZE CB.HNDL
      '
    CASE %WM_NCACTIVATE
      STATIC hWndSaveFocus AS DWORD
      IF ISFALSE CB.WPARAM THEN
        ' Save control focus
        hWndSaveFocus = GetFocus()
        '
      ELSEIF hWndSaveFocus THEN
        ' Restore control focus
        SetFocus(hWndSaveFocus)
        hWndSaveFocus = 0
      END IF
      '
    CASE %WM_PAINT
      ' fill with a gradient colour
      funGradientFillGraphicControl(CB.HNDL,%IDC_GRAPHIC1)
      '
      funDrawHexMenu(CB.HNDL,%IDC_GRAPHIC1)
      '
      ' save the screen
      GRAPHIC GET BITS TO g_strGraphicBitmap
      '
    CASE %WM_SIZE
    ' form is resizing
      IF ISTRUE isIconic(CB.HNDL) THEN EXIT FUNCTION  ' Exit if app is minimized
      '
      funResize CB.HNDL, 0, "Initialize"  ' Must be called first
      ' now resize the graphic control
      funResizeGraphicControl(CB.HNDL,%IDC_GRAPHIC1)
      ' and repaint it
      DIALOG SEND CB.HNDL,%WM_PAINT,0,0
      '
    CASE %WM_COMMAND
      ' Process control notifications
      SELECT CASE AS LONG CB.CTL
        CASE %IDC_GRAPHIC1
          IF CB.CTLMSG = %STN_Clicked THEN
          ' get location on graphics control - X & Y co-ords
'            GetCursorPos pLocation
'            ScreenToClient(hGraphic,pLocation)
            ' pLocation.X = X location of mouse click
            ' pLocation.Y = Y location of mouse click
            '
          SELECT CASE CB.CTLMSG
'            case %WM_MOUSEMOVE
''            ' mouse has moved
'              GetCursorPos pLocation
'              ScreenToClient(g_hGraphic,pLocation)
'              ' pLocation.X = X location of mouse
'              ' pLocation.Y = Y location of mouse
'              lngHex = funGetHex(pLocation.X, pLocation.Y, _
'                                 g_lngShortDistance)
'              '
'              if lngHex > 0 then
'                ' break
'              end if
            '
'            case %STN_Clicked
'            ' get location on graphics control - X & Y co-ords
'              GetCursorPos pLocation
'              ScreenToClient(g_hGraphic,pLocation)
'              ' pLocation.X = X location of mouse click
'              ' pLocation.Y = Y location of mouse click
'              '
'              lngHex = funGetHex(pLocation.X, pLocation.Y, _
'                                 g_lngShortDistance)
'              '
'              SELECT CASE lngHex
'                CASE %ExitApp
'                  IF MSGBOX("Are you sure you wish to exit?" , _
'                    %MB_YESNO OR %MB_ICONQUESTION, _
'                    "Exit Application?") = %IDYES THEN
'                    FUNCTION = 0
'                    DIALOG END CB.HNDL
'                  ELSE
'                    FUNCTION = 1
'                  END IF
'                  '
'                CASE %MenuApp
'                  MSGBOX "Menu?",%MB_ICONQUESTION,"Hex click"
'                  'local X , Y , Buttons , Wheel AS LONG
'                  'GETMOUSE X, Y, Buttons, Wheel
'                  '
'                CASE %ReportApp
'                  MSGBOX "Reports?",%MB_ICONQUESTION,"Hex click"
'                CASE %WebApp
'                  MSGBOX "Web?",%MB_ICONQUESTION,"Hex click"
'                CASE %SearchApp
'                  MSGBOX "Search?",%MB_ICONQUESTION,"Hex click"
'                CASE %MessageApp
'                  MSGBOX "Message?",%MB_ICONQUESTION,"Hex click"
'                CASE %SaveApp
'                  MSGBOX "Save?",%MB_ICONQUESTION,"Hex click"
'              END SELECT
                '
'              CASE %MenuApp
'                MSGBOX "Menu?",%MB_ICONQUESTION,"Hex click"
'              CASE %ReportApp
'                MSGBOX "Reports?",%MB_ICONQUESTION,"Hex click"
'              CASE %WebApp
'                MSGBOX "Web?",%MB_ICONQUESTION,"Hex click"
'              CASE %SearchApp
'                MSGBOX "Search?",%MB_ICONQUESTION,"Hex click"
'              CASE %MessageApp
'                MSGBOX "Message?",%MB_ICONQUESTION,"Hex click"
'              CASE %SaveApp
'                MSGBOX "Save?",%MB_ICONQUESTION,"Hex click"
            END SELECT
          '
          END IF

      END SELECT
  END SELECT
END FUNCTION
'------------------------------------------------------------------------------
FUNCTION funGetHex(lngX AS LONG,lngY AS LONG, _
                   BYVAL lngShortestDist AS LONG) AS LONG
' work out what hex we are on
' by getting the closest match
  LOCAL lngDistance AS LONG
  LOCAL lngR AS LONG
  '
  LOCAL lngFound AS LONG
  '
  FOR lngR = 1 TO %Max_Hexes
    lngDistance = SQR((ABS(lngX - g_a_pHexLocations(lngR).X)^2) + _
                      (ABS(lngY - g_a_pHexLocations(lngR).Y)^2))
    '
    IF lngDistance < lngShortestDist THEN
    ' store hex if this is shortest distance
      lngShortestDist = lngDistance
      lngFound = lngR
    END IF
  NEXT lngR
  '
  FUNCTION = lngFound
  '
END FUNCTION
'------------------------------------------------------------------------------
'   ** Dialogs **
'------------------------------------------------------------------------------
FUNCTION ShowdlgMainDialog(BYVAL hParent AS DWORD) AS LONG
  LOCAL lRslt AS LONG

#PBFORMS BEGIN DIALOG %IDD_dlgMainDialog->->
  LOCAL hDlg  AS DWORD

  DIALOG NEW PIXELS, hParent, "Hex Dialog Demo", 205, 185, 688, 399, %WS_POPUP OR _
    %WS_BORDER OR %WS_DLGFRAME OR %WS_THICKFRAME OR %WS_CAPTION OR _
    %WS_SYSMENU OR %WS_MINIMIZEBOX OR %WS_MAXIMIZEBOX OR %WS_CLIPSIBLINGS OR _
    %WS_VISIBLE OR %DS_MODALFRAME OR %DS_CENTER OR %DS_3DLOOK OR _
    %DS_NOFAILCREATE OR %DS_SETFONT, %WS_EX_CONTROLPARENT OR %WS_EX_LEFT OR _
    %WS_EX_LTRREADING OR %WS_EX_RIGHTSCROLLBAR, TO hDlg
  CONTROL ADD GRAPHIC, hDlg, %IDC_GRAPHIC1, "", 0, 0, 445, 270, %WS_CHILD _
    OR %WS_VISIBLE OR %SS_NOTIFY
#PBFORMS END DIALOG
  g_hDlg = hDlg
  '
  '
  ' prepare the graphic control
  GRAPHIC ATTACH hDlg, %IDC_GRAPHIC1
  'GRAPHIC COLOR -1, %BLACK
  GRAPHIC CLEAR
  '
  DIALOG SET ICON hDlg, "AppIcon"
  '
  DIALOG SHOW MODAL hDlg, CALL ShowdlgMainDialogProc TO lRslt

#PBFORMS BEGIN CLEANUP %IDD_dlgMainDialog
#PBFORMS END CLEANUP

  FUNCTION = lRslt
END FUNCTION
'------------------------------------------------------------------------------
FUNCTION funGradientFillGraphicControl(hDlg AS DWORD, _
                                       lngGraphicCtl AS LONG) AS LONG
' fill the graphic with a gradient
  DIM V(1) AS TriVertex
  LOCAL w,h AS LONG     ' width and height of graphics control
  LOCAL hDC AS DWORD    ' device context handle
  LOCAL gRect AS Gradient_Rect
  '
  CONTROL GET CLIENT hDlg, lngGraphicCtl TO w,h
  '
  GRAPHIC GET DC TO hDC
  ' define the colours to be used
  V(0).x      = 0
  V(0).y      = 0
  V(0).Red    = MAK(WORD,0,255)  ' from RED
  V(0).Green  = 0
  V(0).Blue   = 0
  V(1).x      = w   '<--- not w-1
  V(1).y      = h   '<--- not h-1
  V(1).Red    = 0
  V(1).Green  = 0
  V(1).Blue   = MAK(WORD,0,255)  ' to BLUE
  '
  gRect.UpperLeft = 0
  gRect.LowerRight = 1
  '
  ' apply the gradient fill to the graphics control
  GradientFill hDC, V(0), 2, gRect, 1, %Gradient_Fill_Rect_H
  GRAPHIC REDRAW      ' now redraw the graphic control
'
END FUNCTION
'
FUNCTION funResizeGraphicControl(hDlg AS DWORD, _
                                 lngGraphicCtl AS LONG) AS LONG
' resize the graphic control
  LOCAL lngX, lngY AS LONG
  '
  ' get the client area
  DIALOG GET CLIENT hDlg TO lngX, lngY
  '
  ' set the graphic control to the same size
  GRAPHIC SET CLIENT lngX , lngY
  '
END FUNCTION
'
FUNCTION funDrawHexMenu(hDlg AS DWORD, _
                        lngGraphic AS LONG) AS LONG
' draw the hex menu
  LOCAL lngFile AS LONG           ' file handle
  LOCAL lngWidth AS LONG          ' width of bitmap
  LOCAL lngHeight AS LONG         ' height of bitmap
  '
  LOCAL hBmp AS DWORD             ' handle of bitmap
  LOCAL hBmpMask AS DWORD         ' handle of mask
  LOCAL strBitmap AS STRING       ' name/path to bitmap
  LOCAL strBitmapMask AS STRING   ' name/path to mask
  LOCAL lngXstart AS LONG         ' starting X location
  LOCAL lngYstart AS LONG         ' starting Y location
  LOCAL lngP AS LONG              ' location pointer to array
  '
  DIM a_lngLocations(1 TO %Max_Hexes) AS POINT  ' array locations of the hex icons
  DIM a_strIcon(1 TO %Max_Hexes) AS STRING      ' bitmap name/path
  '
  strBitmapMask = EXE.PATH$ & "\Graphics\MaskBig.bmp"
  '
  lngFile = FREEFILE
  OPEN strBitmapMask FOR BINARY AS lngFile
  GET #lngFile, 19, lngWidth
  GET #lngFile, 23, lngHeight
  CLOSE #lngFile
  ' store the max size of a hex
  g_lngShortDistance = MAX(lngWidth,lngHeight) \2
  '
  GRAPHIC BITMAP LOAD strBitmapMask ,lngWidth, lngHeight TO hBmpMask
  '
  lngXstart = 100
  lngYstart = 100
  '
  PREFIX "a_lngLocations"
    (1).X = lngXstart
    (1).Y = lngYstart
    (2).X = a_lngLocations(1).X + (lngWidth*0.7)
    (2).Y = a_lngLocations(1).Y + (lngHeight\2)
    (3).X = a_lngLocations(2).X - (lngWidth*0.7)
    (3).Y = a_lngLocations(2).Y + (lngHeight\2)
    (4).X = a_lngLocations(3).X - (lngWidth*0.7)
    (4).Y = a_lngLocations(3).Y - (lngHeight\2)
    (5).X = a_lngLocations(4).X
    (5).Y = a_lngLocations(4).Y - (lngHeight)
    (6).X = a_lngLocations(5).X + (lngWidth*0.7)
    (6).Y = a_lngLocations(5).Y - (lngHeight\2)
    (7).X = a_lngLocations(6).X + (lngWidth*0.7)
    (7).Y = a_lngLocations(6).Y + (lngHeight\2)
  END PREFIX
  '
  ' assign the bitmaps to be used
  ARRAY ASSIGN a_strIcon() = EXE.PATH$ & "\Graphics\Hex_1.bmp", _
                             EXE.PATH$ & "\Graphics\Hex_2.bmp", _
                             EXE.PATH$ & "\Graphics\Hex_1.bmp", _
                             EXE.PATH$ & "\Graphics\Hex_2.bmp", _
                             EXE.PATH$ & "\Graphics\Hex_1.bmp", _
                             EXE.PATH$ & "\Graphics\Hex_2.bmp", _
                             EXE.PATH$ & "\Graphics\Hex_1.bmp"
  '
  FOR lngP = 1 TO %Max_Hexes
  ' draw the hex symbol
    funDrawHex(lngGraphic, _
               a_lngLocations(lngP).X , _
               a_lngLocations(lngP).Y, _
               a_strIcon(lngP),lngWidth, lngHeight, hBmpMask)
               '
   ' store global locations of centre of hex
   PREFIX "g_a_pHexLocations(lngP)."
     X = a_lngLocations(lngP).X + (lngWidth \2)
     Y = a_lngLocations(lngP).Y + (lngHeight \2)
   END PREFIX
   '
  NEXT lngP
  '
  GRAPHIC BITMAP END
  GRAPHIC REDRAW
'
END FUNCTION
'
'
FUNCTION funDrawHex(lngGraphic AS LONG, _
                    lngXStart AS LONG , lngYStart AS LONG, _
                    strBitmap AS STRING, _
                    lngWidth AS LONG, lngHeight AS LONG, _
                    hBmpMask AS DWORD) AS LONG
' draw the hex to location on the screen
 '
 LOCAL hBmp AS DWORD
 GRAPHIC BITMAP LOAD strBitmap, lngWidth, lngHeight TO hBmp
 '
 GRAPHIC COPY hBmpMask, lngGraphic TO _
             (lngXStart, lngYStart), %MIX_MASKSRC
 GRAPHIC COPY hBmp, lngGraphic TO _
           (lngXStart, lngYStart), %MIX_MERGESRC
 '
END FUNCTION
'
FUNCTION GraphicProc (BYVAL hWnd AS DWORD, BYVAL wMsg AS DWORD, _
                      BYVAL wParam AS DWORD, BYVAL lParam AS LONG) AS LONG
'--------------------------------------------------------------------
  ' Subclass procedure
  '------------------------------------------------------------------
LOCAL lngX, lngY AS LONG
  LOCAL lngWidthVar, lngHeightVar AS LONG ' position of the graphic view
  '
  LOCAL lngHex AS LONG        ' hex number pointed at
  LOCAL pLocation AS POINT    ' location as POINT
  STATIC strTooltip AS STRING ' text on current tooltip

  '
  SELECT CASE wMsg
    '
    CASE %WM_MOUSEMOVE
    ' mouse has moved
      lngX = LO(INTEGER, lParam)
      lngY = HI(INTEGER, lParam)
      '
      ' are we over a hex?
      GetCursorPos pLocation
      ScreenToClient(g_hGraphic,pLocation)
      ' pLocation.X = X location of mouse
      ' pLocation.Y = Y location of mouse
      lngHex = funGetHex(pLocation.X, pLocation.Y, _
                         g_lngShortDistance)
                         '
      IF lngHex > 0 THEN
      ' hex button pointed at
        ' set the position
        IF strTooltip <> g_astrButtonTooltips(lngHex) THEN
        ' new tooltip
          strTooltip = g_astrButtonTooltips(lngHex)
          ' restore the graphic screen
          GRAPHIC SET BITS g_strGraphicBitmap
          ' set the font
          GRAPHIC SET FONT g_dwdhFont
          ' position where the text will go
          GRAPHIC SET POS (pLocation.X, pLocation.Y)
          ' set the colour
          GRAPHIC COLOR %BLUE,%YELLOW
          ' print the tooltip
          GRAPHIC PRINT g_astrButtonTooltips(lngHex)
          ' wait for a little while
          SLEEP 750
          ' and restore the graphics screen
          GRAPHIC SET BITS g_strGraphicBitmap
          '
      END IF
    END IF
    '
    CASE %WM_LBUTTONUP
    ' get mouse co-ords
       ' get location on graphics control - X & Y co-ords
      GetCursorPos pLocation
      ScreenToClient(g_hGraphic,pLocation)
      ' pLocation.X = X location of mouse click
      ' pLocation.Y = Y location of mouse click
      '
      lngHex = funGetHex(pLocation.X, pLocation.Y, _
                         g_lngShortDistance)
      '
      SELECT CASE lngHex
        CASE %ExitApp
          IF MSGBOX("Are you sure you wish to exit?" , _
            %MB_YESNO OR %MB_ICONQUESTION OR %MB_TASKMODAL, _
            "Exit Application?") = %IDYES THEN
            FUNCTION = 0
            DIALOG END g_hDlg
          ELSE
            FUNCTION = 1
          END IF
          '
        CASE %MenuApp
          MSGBOX "Menu?",%MB_ICONQUESTION OR %MB_TASKMODAL,"Hex click"
          '
        CASE %ReportApp
          MSGBOX "Reports?",%MB_ICONQUESTION OR %MB_TASKMODAL,"Hex click"
        CASE %WebApp
          MSGBOX "Web?",%MB_ICONQUESTION OR %MB_TASKMODAL,"Hex click"
        CASE %SearchApp
          MSGBOX "Search?",%MB_ICONQUESTION OR %MB_TASKMODAL,"Hex click"
        CASE %MessageApp
          MSGBOX "Message?",%MB_ICONQUESTION OR %MB_TASKMODAL,"Hex click"
        CASE %SaveApp
          MSGBOX "Save?",%MB_ICONQUESTION OR %MB_TASKMODAL,"Hex click"
      END SELECT
    '
    CASE %WM_RBUTTONUP
    ' get mouse co-ords and show popup dialog

      '
  END SELECT
  '
  FUNCTION = CallWindowProc (OldGraphicProc, hWnd, wMsg, wParam, lParam)
  '
END FUNCTION
