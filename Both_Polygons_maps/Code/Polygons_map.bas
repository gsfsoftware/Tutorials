#COMPILE EXE
#DIM ALL
#DEBUG ERROR ON
'
#TOOLS OFF
'
' include the common display library
#INCLUDE "win32api.inc"
#INCLUDE "..\Libraries\CommonDisplay.inc"
'
TYPE PolyPoint
  x AS SINGLE
  y AS SINGLE
END TYPE
'
TYPE PolyArray
  count AS LONG
  xy(1 TO 4) AS PolyPoint
END TYPE
'
%MaxX = 15
%MaxY = 15
'
FUNCTION PBMAIN () AS LONG
' the main PB function that is the first to be executed
  funPrepOutput("Polygons",0,0,40,120)
  '
  funLog("Polygons")
  '
  LOCAL hWin AS DWORD
  ' create the graphics window
  GRAPHIC WINDOW "Polygons", 300,300,680,580 TO hWin
  GRAPHIC ATTACH hWin,0 , REDRAW
  '
  funDrawPolygons()
  '
  funWait()
  '
END FUNCTION
'
FUNCTION funDrawPolygons() AS LONG
' draw the polygons on the graphics page
  LOCAL lngR , lngC, lngH AS LONG
  LOCAL udtPolygon AS PolyArray
  LOCAL lngCorner AS LONG
  '
  LOCAL lngXStart, lngYStart AS LONG
  LOCAL lngSize, lngHOffset, lngVOffset AS LONG
  LOCAL lngSea AS LONG
  '
  RANDOMIZE TIMER
  '
  lngXStart = 250
  lngYStart = 50
  lngSize   = 25
  lngHOffset = 15
  '
  RANDOMIZE TIMER
  '
  ' work out which vertex has height
  DIM a_lngHeight(%MaxX+1,%MaxX+1) AS LONG
  funDetermine_Terrain(a_lngHeight())
  '
  udtPolygon.count = 4
  FOR lngC = 1 TO %MaxY
    lngYStart = lngYstart + 25
    lngXStart = lngXStart - (lngHOffset + 1)
    '
    FOR lngR = 1 TO %MaxX
      lngSea = %TRUE
      ' set the coords of each corner of the polygon
      ' and its horizontal and vertical offsets
      lngVOffset = a_lngHeight(lngC,lngR)
      IF lngVOffset > 0 THEN lngSea = %FALSE
      udtPolygon.xy(1).x = lngXStart + (lngR * 25)
      udtPolygon.xy(1).y = lngYStart - lngVOffset
      '
      lngVOffset = a_lngHeight(lngC,lngR+1)
      IF lngVOffset > 0 THEN lngSea = %FALSE
      udtPolygon.xy(2).x = lngXStart + lngSize + (lngR * 25)
      udtPolygon.xy(2).y = lngYStart - lngVOffset
      '
      lngVOffset = a_lngHeight(lngC+1,lngR+1)
      IF lngVOffset > 0 THEN lngSea = %FALSE
      udtPolygon.xy(3).x = lngXStart + lngSize + (lngR * 25) - lngHOffset
      udtPolygon.xy(3).y = lngYStart + lngSize - lngVOffset
      '
      lngVOffset = a_lngHeight(lngC+1,lngR)
      IF lngVOffset > 0 THEN lngSea = %FALSE
      udtPolygon.xy(4).x = lngXStart + (lngR * 25) - lngHOffset
      udtPolygon.xy(4).y = lngYStart + lngSize - lngVOffset
      '
      IF ISTRUE lngSea THEN
      ' all 4 corners of the polygon have a zero vertical offset
        GRAPHIC POLYGON udtPolygon,%BLACK,%RGB_DEEPSKYBLUE,0
      ELSE
        GRAPHIC POLYGON udtPolygon,%BLACK,%RGB_LIMEGREEN,0
      END IF
      '
    NEXT lngR
  NEXT lngC
  GRAPHIC REDRAW
  '
END FUNCTION
'
FUNCTION funDetermine_Terrain(BYREF a_lngHeight() AS LONG) AS LONG
  ' work out which vertex has height
  LOCAL lngR , lngC AS LONG
  LOCAL lngVOffset AS LONG
  lngVOffset = 20
  '
  FOR lngC = 1 TO %MaxY
    FOR lngR = 1 TO %MaxX
    ' establish the height of this location
      IF funVOffset() = 1 THEN
      ' set the height
        a_lngHeight(lngC,lngR) = lngVOffset
      ELSE
        a_lngHeight(lngC,lngR) = 0
      END IF
    NEXT lngR
  NEXT lngC
  '
END FUNCTION
'
FUNCTION funVOffset() AS LONG
' determine probabilty that this location
' is at or above sea level
  LOCAL lngHeight AS LONG
  '
  lngHeight = RND(1,6)
  SELECT CASE lngHeight
    CASE 1,2
      FUNCTION = 1
    CASE ELSE
      FUNCTION = 0
  END SELECT
END FUNCTION
