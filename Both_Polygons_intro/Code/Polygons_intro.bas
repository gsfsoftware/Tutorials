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
  xy(1 TO 5) AS PolyPoint
END TYPE
'
FUNCTION PBMAIN () AS LONG
' the main PB function that is the first to be executed
  funPrepOutput("Polygons",0,0,40,120)
  '
  funLog("Polygons")
  '
  LOCAL hWin AS DWORD
  '
  GRAPHIC WINDOW "Polygons", 300,300,680,580 TO hWin
  GRAPHIC ATTACH hWin,0 , REDRAW
  '
  funDrawPolygon()
  '
  funWait()
  '
END FUNCTION
'
FUNCTION funDrawPolygon() AS LONG
' draw a polygon on the graphics page
  LOCAL udtPolygon AS PolyArray
  LOCAL lngXStart, lngYStart, lngSize AS LONG
  '
  lngXStart = 250
  lngYStart = 50
  lngSize   = 125
  '
  PREFIX "udtPolygon."
    count = 5
    xy(1).x = lngXStart
    xy(1).y = lngYStart
    xy(2).x = lngXStart + lngSize
    xy(2).y = lngYStart
    xy(3).x = lngXStart + lngSize
    xy(3).y = lngYStart + lngSize
    xy(4).x = lngXStart
    xy(4).y = lngYStart + lngSize
    xy(5).x = lngXStart - (lngSize\2)
    xy(5).y = lngYStart + (lngSize\2)
  END PREFIX
  '
  GRAPHIC POLYGON udtPolygon, %BLACK, %RGB_DEEPSKYBLUE, 0
  '
  lngXStart = 265
  lngYStart = 65
  lngSize   = 100
  '
  PREFIX "udtPolygon."
    count = 5
    xy(1).x = lngXStart
    xy(1).y = lngYStart
    xy(2).x = lngXStart + lngSize
    xy(2).y = lngYStart
    xy(3).x = lngXStart + lngSize
    xy(3).y = lngYStart + lngSize
    xy(4).x = lngXStart
    xy(4).y = lngYStart + lngSize
    xy(5).x = lngXStart - (lngSize\2)
    xy(5).y = lngYStart + (lngSize\2)
  END PREFIX
  GRAPHIC POLYGON udtPolygon, %BLACK, %RED, 0
  GRAPHIC REDRAW
'
END FUNCTION
  '
