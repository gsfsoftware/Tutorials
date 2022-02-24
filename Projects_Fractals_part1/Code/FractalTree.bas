' Fractal Trees - FractalTree.bas
#COMPILE EXE
#DIM ALL
#DEBUG ERROR ON
'
' Increase the Stack size
' as we will be doing recursion
#STACK 1024 * 1024 * 4
'
#TOOLS OFF
'
#IF %DEF(%PB_CC32)
  #CONSOLE OFF
#ENDIF
'
' include the windows library
#INCLUDE "win32api.inc"
'
%MapX = 1080             ' max width of the Simulation
%MapY = 580              ' max height of the Simulation
'
TYPE StartPoint          ' starting point of branch/tree
 x AS LONG
 y AS LONG
 z AS LONG
END TYPE
'
' used to determine minimum branch length for colour change
GLOBAL g_lngMinBranchLength AS LONG
'
' used to store colour of tree trunk
GLOBAL g_lngTreeTrunk AS LONG
'
' used to store the colour of leaves
GLOBAL g_lngLeafColour AS LONG
'
' used for iterative shortening of branch length
GLOBAL g_lngShortening AS LONG
'
FUNCTION PBMAIN () AS LONG
' the main PB function that is the first to be executed
  LOCAL hWin AS DWORD        ' handle of the graphics window
  LOCAL dwFont AS DWORD      ' handle of the font used
  LOCAL strInKey AS STRING   ' keyboard input
  '
  GRAPHIC WINDOW "Fractal Trees", 50, 50, 1700,900 TO hWin
  ' set window stop user closing it.
  GRAPHIC WINDOW STABILIZE hWin
  GRAPHIC ATTACH hWin, 0, REDRAW
  GRAPHIC SCALE (0,0)-(%MapX,%MapY)
  '
  FONT NEW "Courier New",12,0,1,0,0 TO dwFont
  GRAPHIC SET FONT dwFont
  GRAPHIC CLEAR %BLACK,0
  GRAPHIC REDRAW
  '
  RANDOMIZE TIMER
  '
  funDrawTrees()
  GRAPHIC REDRAW
  '
  WHILE LEN(strInkey) = 0
  ' wait for a keypress
    GRAPHIC INKEY$ TO strInKey
    SLEEP 50
  WEND
  '
  GRAPHIC WINDOW END
  '
  FONT END dwFont
'
END FUNCTION
'
FUNCTION funDrawTrees() AS LONG
' draw some trees
  LOCAL lngBranchLength AS LONG
  LOCAL uStartPosition AS StartPoint
  LOCAL lngStartDirection AS LONG
  '
  ' set the starting branch length
  lngBranchLength = 105
  ' set the minimum length at which
  ' branch colour changes
  g_lngMinBranchLength = lngBranchLength\10

  ' set the tree trunk colour
  g_lngTreeTrunk = %RGB_PERU
  '
  ' set the leaf colour
  g_lngLeafColour = %RGB_LIME
  '
  ' set the shortening value
  g_lngShortening = 10
  '
  PREFIX "uStartPosition."
    x = %MapX\2
    y = %MapY - 5
    z = 0
  END PREFIX
  '
  subDrawTree(lngBranchLength, _
              uStartPosition, _
              lngStartDirection)
END FUNCTION
'
SUB subDrawTree(lngBranchLength AS LONG,_
                uStartPosition AS StartPoint, _
                lngStartDirection AS LONG)
' Draw a tree
  LOCAL lngShortening AS LONG
  ' amount to reduce branch length
  lngShortening = g_lngShortening
  '
  GRAPHIC COLOR g_lngTreeTrunk,-1
  '
  subDrawTrunk(uStartPosition,lngBranchLength)
  '
  subDrawBranches(lngBranchLength, _
                    uStartPosition, _
                    lngStartDirection, _
                    lngShortening)
  ' end of tree drawing
  '
END SUB
'
SUB subDrawBranches(lngBranchLength AS LONG, _
                    uStartPosition AS StartPoint, _
                    lngStartDirection AS LONG, _
                    lngShortening AS LONG)
  ' draw a branch/trunk
  LOCAL lngX, lngY,lngLength AS LONG ' local storage
  ' first shorten the branch length
  lngBranchLength = lngBranchLength - lngShortening
  '
  IF lngBranchLength <= 0 THEN
  ' got to the end of the tree
    GRAPHIC ELLIPSE (uStartPosition.x-6, uStartPosition.y-4) - _
                    (uStartPosition.x+6, uStartPosition.y) , _
                    g_lngLeafColour ,g_lngLeafColour , 0
    EXIT SUB
  END IF
  '
  GRAPHIC WIDTH lngBranchLength\5
  '
  SELECT CASE lngBranchLength
    CASE <=g_lngMinBranchLength
      GRAPHIC COLOR g_lngLeafColour,-1
    CASE ELSE
      GRAPHIC COLOR g_lngTreeTrunk,-1
  END SELECT
  '
  LOCAL uNewPosition AS StartPoint
  ' work out new ending point of branch
  funGetNewPosition(uStartPosition,uNewPosition,lngBranchLength,"Left")
  '
  lngX = uStartPosition.x
  lngY = uStartPosition.y
  lngLength = lngBranchLength
  '
  GRAPHIC LINE (uStartPosition.x,uStartPosition.y) - _
               (uNewPosition.x,uNewPosition.y)
               '
  ' save the new positions
  PREFIX "uStartPosition."
    x = uNewPosition.x
    y = uNewPosition.y
    z = uNewPosition.z
  END PREFIX
  '
  ' call recursively
  subDrawBranches(lngBranchLength, _
                  uStartPosition, _
                  lngStartDirection, _
                  lngShortening)
                  '
  ' do other branch
  PREFIX "uStartPosition."
    x = lngX
    y = lngY
  END PREFIX
  lngBranchLength = lngLength
  '
  GRAPHIC WIDTH lngBranchLength\5
  SELECT CASE lngBranchLength
    CASE <=g_lngMinBranchLength
      GRAPHIC COLOR g_lngLeafColour,-1
    CASE ELSE
      GRAPHIC COLOR g_lngTreeTrunk,-1
  END SELECT
  '
  ' work out new ending point of branch
  funGetNewPosition(uStartPosition,uNewPosition,lngBranchLength,"Right")
  GRAPHIC LINE (uStartPosition.x,uStartPosition.y) - _
               (uNewPosition.x,uNewPosition.y)
  ' save the new positions
  PREFIX "uStartPosition."
    x = uNewPosition.x
    y = uNewPosition.y
    z = uNewPosition.z
  END PREFIX

  ' call recursively
  subDrawBranches(lngBranchLength, _
                  uStartPosition, _
                  lngStartDirection, _
                  lngShortening)
  '
END SUB
'
MACRO DegreesToRadians(dpDegrees) = (dpDegrees*0.0174532925199433##)
'
FUNCTION funGetNewPosition(uStartPosition AS StartPoint, _
                           uNewPosition AS StartPoint, _
                           lngBranchLength AS LONG, _
                           strDirection AS STRING) AS LONG
' work out the new position of the end of the branch
  LOCAL lngAngle AS LONG
  ' generate an angle for the branch
  lngAngle = RND(5,75)
  '
  LOCAL lngX, lngY AS LONG
  lngX = ABS(lngBranchLength * COS(DegreesToRadians(lngAngle)))
  lngY = ABS(lngBranchLength * SIN(DegreesToRadians(lngAngle)))
  '
  LOCAL lngAdj AS LONG
  SELECT CASE strDirection
    CASE "Right"
      lngAdj = -1
    CASE "Left"
      lngAdj = 1
  END SELECT
  '
  PREFIX "uNewPosition."
    x = uStartPosition.x - (lngX * lngAdj)
    y = uStartPosition.y - lngY
  END PREFIX
  '
END FUNCTION
'
SUB subDrawTrunk(uStartPosition AS StartPoint, _
                 lngBranchLength AS LONG)
  ' draw the trunk
  '
  ' trunk width is proportional to length
  GRAPHIC WIDTH lngBranchLength\3
  '
  GRAPHIC LINE (uStartPosition.x,uStartPosition.y) - _
               (uStartPosition.x,uStartPosition.y - lngBranchLength)
               '
  uStartPosition.y = uStartPosition.y - lngBranchLength
  '
END SUB
