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
#RESOURCE "Win3dMaps.pbr"
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
%IDD_dlg3dMaps      =  101
%IDC_GRAPHIC1       = 1001
#PBFORMS END CONSTANTS
'
 ' set size of map
  %lngMaxX = 7
  %lngMaxY = 8
  '
  GLOBAL a_lngMap() AS LONG
  '
  %ID_TIMER1    = 2000  ' timer for screen redraw
'
FUNCTION PBMAIN () AS LONG
  PBFormsInitComCtls (%ICC_WIN95_CLASSES OR %ICC_DATE_CLASSES OR _
    %ICC_INTERNET_CLASSES)
  '
  Showdlg3dMaps %HWND_DESKTOP
  '
END FUNCTION

'------------------------------------------------------------------------------
'   ** Dialogs **
'------------------------------------------------------------------------------
FUNCTION Showdlg3dMaps(BYVAL hParent AS DWORD) AS LONG
  LOCAL lRslt AS LONG

#PBFORMS BEGIN DIALOG %IDD_dlg3dMaps->->
  LOCAL hDlg  AS DWORD

  DIALOG NEW PIXELS, hParent, "3D Maps", 357, 232, 1210, 712, %WS_POPUP OR _
    %WS_BORDER OR %WS_DLGFRAME OR %WS_CAPTION OR %WS_SYSMENU OR _
    %WS_MINIMIZEBOX OR %WS_CLIPSIBLINGS OR %WS_VISIBLE OR %DS_MODALFRAME OR _
    %DS_CENTER OR %DS_3DLOOK OR %DS_NOFAILCREATE OR %DS_SETFONT, _
    %WS_EX_CONTROLPARENT OR %WS_EX_LEFT OR %WS_EX_LTRREADING OR _
    %WS_EX_RIGHTSCROLLBAR, TO hDlg
  CONTROL ADD GRAPHIC,   hDlg, %IDC_GRAPHIC1, "", 5, 5, 1187, 675, %WS_CHILD _
    OR %WS_VISIBLE OR %SS_NOTIFY
#PBFORMS END DIALOG

  DIALOG SHOW MODAL hDlg, CALL Showdlg3dMapsProc TO lRslt

#PBFORMS BEGIN CLEANUP %IDD_dlg3dMaps
#PBFORMS END CLEANUP

  FUNCTION = lRslt
END FUNCTION
'
CALLBACK FUNCTION Showdlg3dMapsProc() AS LONG
'
  STATIC lngRunning AS LONG
  '
  SELECT CASE AS LONG CB.MSG
    CASE %WM_INITDIALOG
      ' Initialization handler
      ' attach to the graphic control to write to
      ' but suspend drawing to the graphics control
      ' until the Graphic Redraw command is given
      GRAPHIC ATTACH CB.HNDL, %IDC_GRAPHIC1 , REDRAW
      '
      ' clear it and colour it
      GRAPHIC CLEAR %RGB_BLACK,0
      '
      REDIM a_lngMap(1 TO %lngMaxX,1 TO %lngMaxY, 1 TO 2)  AS LONG
      '
      funPopulateArrayCoords()  ' set up the co-ordinates
      '
      ' draw the graphics map
      funDrawGraphicsMap(CB.HNDL, %IDC_GRAPHIC1)
      '
      ' build the graphics map
      'funBuildGraphicsMap(CB.HNDL, %IDC_GRAPHIC1)
      '
      ' now redraw the graphics control
      GRAPHIC REDRAW
      '
      ' initialise the timer
      SetTimer(CB.HNDL, %ID_TIMER1, _
               50, BYVAL %NULL)
      '
    CASE %WM_TIMER
      SELECT CASE CB.WPARAM
        CASE %ID_TIMER1
        ' timer 1 has triggered
          IF ISTRUE lngRunning THEN EXIT FUNCTION
          '
          lngRunning = %TRUE
        ' recalc positions
          funReCalcPositions()
          '
          ' and redraw the graphics map
          GRAPHIC CLEAR %RGB_BLACK,0
          funDrawGraphicsMap(CB.HNDL, %IDC_GRAPHIC1)
          GRAPHIC REDRAW
          lngRunning = %FALSE
        '
      END SELECT
      '
  END SELECT
  '
END FUNCTION
'
FUNCTION funDrawGraphicsMap(hDlg AS DWORD, _
                            lngGraphic AS LONG) AS LONG
' draw the graphics map
  LOCAL strBitmap AS STRING
  LOCAL strBitmapMask AS STRING
  ' **NEW
  LOCAL strBrownBitmap AS STRING
  '
  LOCAL lngFile, lngWidth, lngHeight AS LONG
  LOCAL hBmp AS DWORD
  LOCAL hBmpMask AS DWORD
  '
  LOCAL hBmpBrown AS DWORD
  '
  LOCAL lngXStart, lngYStart AS LONG
  LOCAL lngColumn, lngRow AS LONG
  '
  LOCAL lngHeightOffset AS LONG
  LOCAL lngWidthOffset AS LONG
  '
  ' define paths to the two bitmaps
  strBitmapMask = EXE.PATH$ & "Graphics\MaskMapCube3.bmp"
  strBitmap     = EXE.PATH$ & "Graphics\MapCube3.bmp"
  '
  strBrownBitmap  = EXE.PATH$ & "Graphics\MapCube3_Red.bmp"
  '
  ' determine the size of the bitmap in x and y
  lngFile = FREEFILE
  OPEN strBitmap FOR BINARY AS lngFile
  GET #lngFile, 19, lngWidth
  GET #lngFile, 23, lngHeight
  CLOSE lngFile
  '
  ' load in the two bitmaps
  GRAPHIC BITMAP LOAD strBitmapMask, lngWidth, lngHeight TO hBmpMask
  GRAPHIC BITMAP LOAD strBitmap, lngWidth, lngHeight TO hBmp
  '
  '**NEW
  GRAPHIC BITMAP LOAD strBrownBitmap, lngWidth, lngHeight TO hBmpBrown
  '
  FOR lngColumn = 1 TO %lngMaxY
  ' take data out of array and use it to plot the graphics masks
    FOR lngRow = 1 TO %lngMaxX
      ' copy the mask & bitmap to the graphic control
      GRAPHIC COPY hBmpMask, %IDC_GRAPHIC1 TO _
                   (a_lngMap(lngRow,lngColumn,1), _
                    a_lngMap(lngRow,lngColumn,2)), %MIX_MASKSRC
  '
  ' what colour are we using?
      IF lngRow >=4 AND lngRow <=5 AND _
         lngColumn >=4 AND lngColumn <=5 THEN
      ' used the brown image
         GRAPHIC COPY hBmpBrown, %IDC_GRAPHIC1 TO _
                   (a_lngMap(lngRow,lngColumn,1), _
                    a_lngMap(lngRow,lngColumn,2)), %MIX_MERGESRC
      ELSE
      ' use the green image
        GRAPHIC COPY hBmp, %IDC_GRAPHIC1 TO _
                   (a_lngMap(lngRow,lngColumn,1), _
                    a_lngMap(lngRow,lngColumn,2)), %MIX_MERGESRC
      END IF
      '
    NEXT lngRow
  NEXT lngColumn
  '
  GRAPHIC BITMAP END   ' close the memory bitmap
  '
END FUNCTION
'
FUNCTION funReCalcPositions() AS LONG
  ' now adjust the heights of some of the cubes
  LOCAL lngRow, lngColumn AS LONG
  '
  ' Capture the initial position
  STATIC lngFrames AS LONG
  STATIC lngVerticalOffset AS LONG
  '
  IF lngVerticalOffset = 0 THEN
    lngVerticalOffset = 1 ' set to 1 pixel
  END IF
  '
  INCR lngFrames
  '
  SELECT CASE lngFrames
    CASE = 50
      lngVerticalOffset = lngVerticalOffset * (-1)
    CASE = 200
      lngVerticalOffset = lngVerticalOffset * (-1)
      lngFrames = -100
  END SELECT
  '
  FOR lngRow = 4 TO 5
    FOR lngColumn = 4 TO 5
      '
      a_lngMap(lngRow,lngColumn,2) = a_lngMap(lngRow,lngColumn,2) _
                                     + lngVerticalOffset
    NEXT lngColumn
  NEXT lngRow
  '
END FUNCTION
'
FUNCTION funPopulateArrayCoords() AS LONG
' set up the initial values in the global array
'
  LOCAL lngXStart, lngYStart AS LONG
  LOCAL lngColumn, lngRow AS LONG
  LOCAL lngWidth, lngHeight AS LONG
  '
  LOCAL lngHeightOffset AS LONG
  LOCAL lngWidthOffset AS LONG
  LOCAL strBitmap AS STRING
  LOCAL lngFile AS LONG
  '
  lngXStart = 280  ' starting positions
  lngYstart = 15
  lngHeightOffset = 39
  lngWidthOffset  = 67
  '
  strBitmap     = EXE.PATH$ & "Graphics\MapCube3.bmp"
  '
  ' determine the size of the bitmap in x and y
  lngFile = FREEFILE
  OPEN strBitmap FOR BINARY AS lngFile
  GET #lngFile, 19, lngWidth
  GET #lngFile, 23, lngHeight
  CLOSE lngFile
  '
  FOR lngColumn = 1 TO %lngMaxY
    FOR lngRow = 1 TO %lngMaxX
    ' store x co-ordinate
      a_lngMap(lngRow,lngColumn,1) = lngXStart + lngWidth
      ' store y co-ordinate
      a_lngMap(lngRow,lngColumn,2) = lngYStart - (lngHeightOffset\2)
      ' update the offset for next row
      lngXStart = lngXStart - lngWidthOffset
      lngYStart = lngYStart + lngHeightOffset
    NEXT lngRow
    ' update the offset for next column by looking at
    ' start cube in this column
    ' store x co-ordinate
    lngXStart = a_lngMap(1,lngColumn,1) - lngWidthOffset
    ' store y co-ordinate
    lngYStart = a_lngMap(1,lngColumn,2) + lngHeightOffset + _
                (lngHeightOffset\2)
    '
  NEXT lngColumn
  '
  ' now adjust the heights of some of the cubes
  FOR lngRow = 4 TO 5
    FOR lngColumn = 4 TO 5
      ' update the y co-ordinate
      a_lngMap(lngRow,lngColumn,2) = a_lngMap(lngRow,lngColumn,2) + 40
    NEXT lngColumn
  NEXT lngRow
  '
  ' raise the height of one cube
  lngRow = 3 :lngColumn = 3
  ' update the y co-ordinate
  a_lngMap(lngRow,lngColumn,2) = a_lngMap(lngRow,lngColumn,2) - 20
  '
END FUNCTION
'
FUNCTION funBuildGraphicsMap(hDlg AS DWORD, _
                             lngGraphic AS LONG) AS LONG
' build a graphics map
'
  LOCAL strBitmap AS STRING
  LOCAL strBitmapMask AS STRING
  LOCAL lngFile, lngWidth, lngHeight AS LONG
  LOCAL hBmp AS DWORD
  LOCAL hBmpMask AS DWORD
  LOCAL lngXStart, lngYStart AS LONG
  LOCAL lngColumn, lngRow AS LONG
  '
  LOCAL lngHeightOffset AS LONG
  LOCAL lngWidthOffset AS LONG
  '
  ' define paths to the two bitmaps
  strBitmapMask = EXE.PATH$ & "Graphics\MaskMapCube3.bmp"
  strBitmap     = EXE.PATH$ & "Graphics\MapCube3.bmp"
  '
  ' determine the size of the bitmap in x and y
  lngFile = FREEFILE
  OPEN strBitmap FOR BINARY AS lngFile
  GET #lngFile, 19, lngWidth
  GET #lngFile, 23, lngHeight
  CLOSE lngFile
  '
  ' load in the two bitmaps
  GRAPHIC BITMAP LOAD strBitmapMask, lngWidth, lngHeight TO hBmpMask
  GRAPHIC BITMAP LOAD strBitmap, lngWidth, lngHeight TO hBmp
  '
  lngXStart = 280  ' starting positions
  lngYstart = 15
  lngHeightOffset = 39
  lngWidthOffset  = 67
  '
  ' work out co-ordinates
  LOCAL lngMaxX , lngMaxY AS LONG
  lngMaxX = 7
  lngMaxY = 8
  '
  DIM a_lngMap(1 TO lngMaxX,1 TO lngMaxY, 1 TO 2)  AS LONG
  ' store the X & Y co-ordinates in the array
  FOR lngColumn = 1 TO lngMaxY
    FOR lngRow = 1 TO lngMaxX
      ' store x co-ordinate
      a_lngMap(lngRow,lngColumn,1) = lngXStart + lngWidth
      ' store y co-ordinate
      a_lngMap(lngRow,lngColumn,2) = lngYStart - (lngHeightOffset\2)
      ' update the offset for next row
      lngXStart = lngXStart - lngWidthOffset
      lngYStart = lngYStart + lngHeightOffset
    NEXT lngRow
    ' update the offset for next column by looking at
    ' start cube in this column
    ' store x co-ordinate
    lngXStart = a_lngMap(1,lngColumn,1) - lngWidthOffset
    ' store y co-ordinate
    lngYStart = a_lngMap(1,lngColumn,2) + lngHeightOffset + _
                (lngHeightOffset\2)
    '
  NEXT lngColumn
  '
  ' now adjust the heights of some of the cubes
  FOR lngRow = 4 TO 5
    FOR lngColumn = 4 TO 5
      ' update the y co-ordinate
      a_lngMap(lngRow,lngColumn,2) = a_lngMap(lngRow,lngColumn,2) + 40
    NEXT lngColumn
  NEXT lngRow
  '
  ' raise the height of one cube
  lngRow = 3 :lngColumn = 3
  ' update the y co-ordinate
  a_lngMap(lngRow,lngColumn,2) = a_lngMap(lngRow,lngColumn,2) - 20
  '
  ' display all the cubes
  FOR lngColumn = 1 TO lngMaxY
  ' take data out of array and use it to plot the graphics masks
    FOR lngRow = 1 TO lngMaxX
      ' copy the mask & bitmap to the graphic control
      GRAPHIC COPY hBmpMask, %IDC_GRAPHIC1 TO _
                   (a_lngMap(lngRow,lngColumn,1), _
                    a_lngMap(lngRow,lngColumn,2)), %MIX_MASKSRC
      GRAPHIC COPY hBmp, %IDC_GRAPHIC1 TO _
                   (a_lngMap(lngRow,lngColumn,1), _
                    a_lngMap(lngRow,lngColumn,2)), %MIX_MERGESRC
    NEXT lngRow
  NEXT lngColumn
  '
  GRAPHIC BITMAP END   ' close the memory bitmap
  '
END FUNCTION
