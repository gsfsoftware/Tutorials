#COMPILE EXE
#DIM ALL
#CONSOLE OFF
' GameOfLife.bas
' The Game of Life, also known simply as Life,
' is a cellular automaton devised by the
' British mathematician John Horton Conway in 1970
'
' https://en.wikipedia.org/wiki/Conway%27s_Game_of_Life
'
#INCLUDE "win32api.inc"

GLOBAL hWin AS DWORD                    ' handle for graphics window
GLOBAL g_a_lngGrid() AS LONG            ' playing board
GLOBAL g_lngSlot AS LONG                ' current generation pointer
GLOBAL g_lngXBoxes, g_lngYBoxes AS LONG ' maximum size of grid
GLOBAL g_lngX, g_lngY AS LONG           ' maximum size of screen
GLOBAL g_lngXsteps, g_lngYSteps AS LONG ' cell size X & Y
GLOBAL g_lngGenerations AS LONG         ' how many generations to run
GLOBAL hFont AS DWORD                   ' handle for font
GLOBAL g_lngGridOn AS LONG              ' toggle for displaying grid


FUNCTION PBMAIN () AS LONG
  RANDOMIZE TIMER
  '
  FONT NEW "Verdana",14, 0,0,0,0 TO hFont
  '
  g_lngXBoxes = 160  ' set size of grid
  g_lngYBoxes = 96
  g_lngGenerations = 150 ' run for X generations
  g_lngGridOn = %false
  '
  g_lngSlot = 0
  '
  IF ISTRUE funCreateMap() THEN
  ' seed the grid
    funSeedGrid()
    ' run the life cycle for each generation
    funLifeCycle()
    ' wait for key
    GRAPHIC WAITKEY$
  END IF
  '
  FONT END hFont
  '
END FUNCTION
'
FUNCTION funSeedGrid() AS LONG
' seed the grid
  LOCAL lngCells AS LONG
  LOCAL lngCell AS LONG
  LOCAL lngX, lngY AS LONG
  '
  ' pick number of cells to place
  lngCells = RND(2000,4000)
  '
  FOR lngCell = 1 TO lngCells
    lngX = RND(1,g_lngXBoxes)
    lngY = RND(1,g_lngYBoxes)
    g_a_lngGrid(lngX,lngY,g_lngSlot) = 1
    '
  NEXT lngCell
  '
END FUNCTION
'
FUNCTION funLifeCycle() AS LONG
' first display the current grid
' g_lngSlot points to the current generation
  LOCAL lngGeneration AS LONG
  LOCAL lngNextGeneration AS LONG
  ' grid variables
  LOCAL lngX , lngY AS LONG
  '
  funDisplayGrid() ' display initial state of cells
  '
  FOR lngGeneration = 1 TO g_lngGenerations
  ' for each generation
    IF g_lngSlot = 1 THEN
    ' determine the slot of the next generation
      lngNextGeneration = 0
    ELSE
      lngNextGeneration = 1
    END IF
    '
    FOR lngX = 1 TO g_lngXBoxes
      FOR lngY = 1 TO g_lngYBoxes
      ' for each grid square
        SELECT CASE funCellOutcome(lngX,lngY)
          CASE "CREATE","SURVIVE"
            g_a_lngGrid(lngX,lngY,lngNextGeneration) = 1
          CASE "DIES", "STILL DEAD"
            g_a_lngGrid(lngX,lngY,lngNextGeneration) = 0
        END SELECT
      '
      NEXT lngY
    NEXT lngX
    '
    g_lngSlot = lngNextGeneration
    '
    funDisplayGrid() ' display this generation
    GRAPHIC BOX (0,0) - (400,50) , 0 ,%RGB_BLACK,%RGB_BLACK ,0
    GRAPHIC SET POS (10, 10)
    GRAPHIC COLOR %RGB_GREEN , %RGB_BLACK
    GRAPHIC PRINT "Generation " & FORMAT$(lngGeneration)
    GRAPHIC REDRAW
    '
    SLEEP 200
  '
  NEXT lngGeneration
  '
  GRAPHIC BOX (0,0) - (400,50) , 0 ,%RGB_BLACK,%RGB_BLACK ,0
  GRAPHIC SET POS (10, 10)
  GRAPHIC COLOR %RGB_GREEN , %RGB_BLACK
  GRAPHIC PRINT "Complete - press any key to exit"
  GRAPHIC REDRAW
  '
END FUNCTION
'
FUNCTION funCellOutcome(lngX AS LONG,lngY AS LONG) AS STRING
' g_lngSlot points to the current generation
  LOCAL lngNeighbours AS LONG
  LOCAL lngXn , lngYn AS LONG  ' pointers to local neighbours
  LOCAL lngXnp, lngYnp AS LONG ' pointers allowing grid folding
  '
  ' first count the live neighbours
  FOR lngXn = lngX -1 TO lngX +1
    FOR lngYn = lngY -1 TO lngY +1
      IF lngYn = lngY AND lngXn = lngX THEN ITERATE
      '
      IF lngXn < 1 THEN
        lngXnp = g_lngXBoxes
      ELSE
        lngXnp = lngXn
      END IF
      '
      IF lngXn > g_lngXBoxes THEN
        lngXnp = 1
      ELSE
        lngXnp = lngXn
      END IF
      '
      IF lngYn < 1 THEN
        lngYnp = g_lngYBoxes
      ELSE
        lngYnp = lngYn
      END IF
      '
      IF lngYn > g_lngYBoxes THEN
        lngYnp = 1
      ELSE
        lngYnp = lngYn
      END IF
      '
      IF g_a_lngGrid(lngXnp,lngYnp,g_lngSlot) = 1 THEN
      ' slot contains live cell
        INCR lngNeighbours
      END IF
      '
    NEXT lngYn
  NEXT lngXn
  '
  IF g_a_lngGrid(lngX,lngY,g_lngSlot) = 1 THEN
  ' cell is currently alive
    SELECT CASE lngNeighbours
      CASE <2
        FUNCTION = "DIES"
      CASE 2,3
        FUNCTION = "SURVIVE"
      CASE ELSE
        FUNCTION = "DIES"
    END SELECT
  ELSE
  ' cell is currently dead
    SELECT CASE lngNeighbours
      CASE 3
        FUNCTION = "CREATE"
      CASE ELSE
        FUNCTION = "STILL DEAD"
    END SELECT
  END IF
'
END FUNCTION
'
FUNCTION funDisplayGrid() AS LONG
' map the array to the screen grid
  LOCAL lngX , lngY AS LONG    ' grid cells
  LOCAL lngXc , lngYc AS LONG  ' screen coords
  LOCAL lngColour AS LONG      ' colour of the cell
  '
  FOR lngX = 1 TO g_lngXBoxes
    FOR lngY = 1 TO g_lngYBoxes
      lngXc = ((g_lngX \ g_lngXBoxes) * lngX) + 5
      lngYc = ((g_lngY \ g_lngYBoxes) * lngY) + 5
      '
      IF g_a_lngGrid(lngX,lngY,g_lngSlot) = 1 THEN
        lngColour = %RGB_GREEN
      ELSE
        lngColour = %RGB_BLACK
      END IF
      GRAPHIC BOX (lngXc,lngYc) - _
                  (lngXc+g_lngXsteps-0,lngYc+g_lngYsteps-0) _
                  , 20 ,%RGB_BLACK,lngColour ,0
      '
    NEXT lngY
  NEXT lngR
  GRAPHIC REDRAW
END FUNCTION
'
FUNCTION funCreateMap() AS LONG
' create the graphics window
  LOCAL lngRow , lngColumn AS LONG
  '
  REDIM g_a_lngGrid(g_lngXBoxes,g_lngyBoxes,1)  ' prepare the game grid
  g_lngSlot = 0 ' set the slot
  '
  g_lngX = GetSystemMetrics (%SM_CXSCREEN)       ' get size of screen
  g_lngY = GetSystemMetrics (%SM_CYSCREEN)
  '
  GRAPHIC WINDOW "",-5, -5, g_lngX+10, g_lngY+10 TO hWin
  GRAPHIC ATTACH hWin, 0, REDRAW
  GRAPHIC COLOR %RGB_WHITE,%RGB_BLACK
  GRAPHIC CLEAR %RGB_BLACK
  GRAPHIC SET FONT hFont
  GRAPHIC REDRAW
  '
  g_lngXsteps = g_lngX \ g_lngXBoxes
  g_lngYSteps = g_lngY \ g_lngYBoxes
  '
  IF ISTRUE g_lngGridOn THEN
    FOR lngRow = 1 TO g_lngXBoxes
      GRAPHIC LINE (lngRow * g_lngXsteps ,0) - _
                   (lngRow * g_lngXsteps,g_lngY), %RGB_WHITE
    NEXT lngRow
    '
    FOR lngColumn = 1 TO g_lngYBoxes
      GRAPHIC LINE (0,lngColumn * g_lngYsteps) - _
                   (g_lngX,lngColumn * g_lngYsteps), %RGB_WHITE
    NEXT lngColumn
    GRAPHIC REDRAW
  END IF
  '
  FUNCTION = %TRUE
'
END FUNCTION
