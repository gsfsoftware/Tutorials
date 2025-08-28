' Falling Blocks game
#COMPILE EXE
#DIM ALL
#INCLUDE "WIN32API.INC"
'
' Game constants
%BOARD_WIDTH   = 12
%BOARD_HEIGHT  = 20
%BLOCK_SIZE    = 25
%TIMER_ID      = 1
%DROP_INTERVAL = 500  ' set to 500ms
%Max_Blocks    = 7
'
' block types
ENUM PieceType SINGULAR
  PIECE_I = 1
  PIECE_O
  PIECE_T
  PIECE_S
  PIECE_Z
  PIECE_J
  PIECE_L
END ENUM
'
' Game state
GLOBAL g_hDlg AS DWORD
GLOBAL ga_lngGameBoard() AS LONG
GLOBAL g_lngCurrentPiece AS LONG
GLOBAL g_lngCurrentX AS LONG
GLOBAL g_lngCurrentY AS LONG
GLOBAL g_lngCurrentRotation AS LONG
GLOBAL g_lngScore AS LONG
GLOBAL g_lngLines AS LONG
GLOBAL g_lngGameOver AS LONG
GLOBAL g_lngNextPiece AS LONG

' Block shapes (4x4 grid, 4 rotations each)
GLOBAL ga_lngBlockShapes() AS LONG
' array for colours of blocks
GLOBAL ga_dwColours() AS DWORD
'
'
FUNCTION PBMAIN () AS LONG
  REDIM ga_lngGameBoard(0 TO %BOARD_WIDTH-1, 0 TO %BOARD_HEIGHT-1)
  REDIM ga_lngBlockShapes(1 TO %Max_Blocks, 0 TO 3, 0 TO 3, 0 TO 3)
  ' array for colours of blocks
  REDIM ga_dwColours(0 TO %Max_Blocks)
  '
  g_lngGameOver = %FALSE
  '
  DIALOG NEW PIXELS, 0, "PowerBasic Falling Blocks", , , 500, 600, _
        %WS_CAPTION OR %WS_SYSMENU OR %WS_MINIMIZEBOX, 0 TO g_hDlg

  DIALOG SHOW MODAL g_hDlg, CALL funcb_DlgProc

END FUNCTION
'
CALLBACK FUNCTION funcb_DlgProc() AS LONG
' callback function for dialog
  LOCAL hDC AS DWORD
  LOCAL ps AS PAINTSTRUCT
  LOCAL newX, newY, newRotation AS LONG
  LOCAL lngClearLines AS LONG
  LOCAL lngKeypress AS LONG
  '
  SELECT CASE CB.MSG
    CASE %WM_INITDIALOG
    ' set random seed
      RANDOMIZE TIMER
      '
      ' prepare the game
      CALL subInitializeShapes()
      CALL subInitializeGame()
      '
      ' start the timer
      SetTimer(CB.HNDL, %TIMER_ID, %DROP_INTERVAL, BYVAL %NULL)
      FUNCTION = 1
      '
      CASE %WM_PAINT
      ' repaint the dialog
        hDC = BeginPaint(CB.HNDL, ps)
        CALL subDrawGame(hDC)
        EndPaint(CB.HNDL, ps)
        FUNCTION = 0
      '
     CASE %WM_TIMER
     ' timer has been triggered
       IF CB.WPARAM = %TIMER_ID AND ISFALSE g_lngGameOver THEN
         ' first test if we can advance any further
         ' by seeing if g_lngCurrentY + 1 is a valid position
         IF ISTRUE funIsValidPosition(g_lngCurrentPiece, g_lngCurrentX, _
                                      g_lngCurrentY + 1, _
                                      g_lngCurrentRotation) THEN
                                      '
           INCR g_lngCurrentY
         ELSE
         ' we can't go any further so place the piece here
         ' and spawn a new one
           CALL subPlacePiece()
           lngClearLines = funClearLines()
           g_lngLines = g_lngLines + lngClearLines
           g_lngScore = g_lngScore + lngClearLines * 100
           CALL subSpawnNewPiece()
         END IF
         '
         InvalidateRect(CB.HNDL, BYVAL %NULL, %FALSE)
       '
       ELSEIF ISTRUE g_lngGameOver THEN
       ' game is over
        KillTimer(CB.HNDL, %TIMER_ID)
       END IF
       '
       FUNCTION = 0
     '
  END SELECT
  '
END FUNCTION
'
FUNCTION funClearLines() AS LONG
  LOCAL lngY, lngX AS LONG
  LOCAL lngClearLines, lngFullLine AS LONG
  LOCAL lngMoveY AS LONG
  '
  lngClearLines = 0
  '
  ' do we have a full completed line?
  FOR lngY = %BOARD_HEIGHT-1 TO 0 STEP -1
    lngFullLine = 1 ' assume yes
    FOR lngX = 0 TO %BOARD_WIDTH-1
      IF ga_lngGameBoard(lngX, lngY) = 0 THEN
        lngFullLine = 0
        EXIT FOR
      END IF
    NEXT lngX
    '
    IF lngFullLine = 1 THEN
    ' Move all Lines above down
       FOR lngMoveY = lngY TO 1 STEP -1
        FOR lngX = 0 TO %BOARD_WIDTH-1
          ga_lngGameBoard(lngX, lngMoveY) = _
                    ga_lngGameBoard(lngX, lngMoveY-1)
        NEXT lngX
      NEXT lngMoveY
      '
      ' Clear top line
      FOR lngX = 0 TO %BOARD_WIDTH-1
        ga_lngGameBoard(lngX, 0) = 0
      NEXT lngX
      '
      INCR lngClearLines
      INCR lngY ' Check this line again
      '
    END IF
    '
  NEXT lngY
  '
  FUNCTION = lngClearLines
  '
END FUNCTION
'
SUB subPlacePiece()
' place piece on the board
  LOCAL lngPX, lngPY AS LONG
  '
  FOR lngPX = 0 TO 3
    FOR lngPY = 0 TO 3
      IF ga_lngBlockShapes(g_lngCurrentPiece, lngPX, lngPY, _
                           g_lngCurrentRotation) THEN
         IF (g_lngCurrentY + lngPY) >= 0 THEN
           ga_lngGameBoard(g_lngCurrentX + lngPX, _
                           g_lngCurrentY + lngPY) = g_lngCurrentPiece
        END IF
      END IF
    NEXT lngPY
  NEXT lngPX
  '
END SUB
'
SUB subDrawGame(hDC AS DWORD)
' draw the game board
  LOCAL lngX, lngY AS LONG
  LOCAL lngPX, lngPY AS LONG
  LOCAL hBrush AS DWORD
  LOCAL uRect AS RECT
  LOCAL strText AS ASCIIZ * 20
  LOCAL lngBlock AS LONG
  '
  ' Clear background
  GetClientRect(g_hDlg, uRect)
  hBrush = CreateSolidBrush(RGB(32, 32, 32))
  FillRect(hDC, uRect, hBrush)
  DeleteObject(hBrush)
  '
  ' Draw game board
  FOR lngX = 0 TO %BOARD_WIDTH-1
    FOR lngY = 0 TO %BOARD_HEIGHT-1
      ' get block found at location
      lngBlock = ga_lngGameBoard(lngX, lngY)
      ' get colour of brush
      IF lngBlock > 0 THEN
        hBrush = CreateSolidBrush(ga_dwColours(lngBlock))
      ELSE
        hBrush = CreateSolidBrush(RGB(64, 64, 64))
      END IF
      '
      PREFIX "uRect."
        left = 50 + lngX * %BLOCK_SIZE
        top = 50 + lngY * %BLOCK_SIZE
        right = uRect.left + %BLOCK_SIZE - 1
        bottom = uRect.top + %BLOCK_SIZE - 1
      END PREFIX
      '
      FillRect(hDC, uRect, hBrush)
      DeleteObject(hBrush)
      '
      ' Draw border
      MoveToEx(hDC, urect.left, urect.top, BYVAL %NULL)
      LineTo(hDC, urect.right, urect.top)
      LineTo(hDC, urect.right, urect.bottom)
      LineTo(hDC, urect.left, urect.bottom)
      LineTo(hDC, urect.left, urect.top)
      '
    NEXT lngY
  NEXT lngX
  '
  'Draw current piece if game not over
  IF ISFALSE g_lngGameOver THEN
    hBrush = CreateSolidBrush(ga_dwColours(g_lngCurrentPiece))
    FOR lngPX = 0 TO 3
      FOR lngPY = 0 TO 3
        IF ga_lngBlockShapes(g_lngCurrentPiece, lngPX, lngPY, _
                             g_lngCurrentRotation) THEN
                             '
          IF (g_lngCurrentY + lngPY) >= 0 THEN
            urect.left = 50 + (g_lngCurrentX + lngPX) * %BLOCK_SIZE
            urect.top = 50 + (g_lngCurrentY + lngPY) * %BLOCK_SIZE
            urect.right = urect.left + %BLOCK_SIZE - 1
            urect.bottom = urect.top + %BLOCK_SIZE - 1
            '
            FillRect(hDC, urect, hBrush)
            '
            ' Draw border
            MoveToEx(hDC, urect.left, urect.top, BYVAL %NULL)
            LineTo(hDC, urect.right, urect.top)
            LineTo(hDC, urect.right, urect.bottom)
            LineTo(hDC, urect.left, urect.bottom)
            LineTo(hDC, urect.left, urect.top)
            '
          END IF
          '
        END IF
      NEXT lnyPY
    NEXT lngPX
    DeleteObject(hBrush)
  END IF
  '
  ' Draw score and g_lngLines
  SetTextColor(hDC, RGB(255, 255, 255))
  SetBkMode(hDC, %TRANSPARENT)
  '
  strText = "Score: " & FORMAT$(g_lngScore)
  TextOut(hDC, 360, 50, strText, LEN(strText))
  '
  strText = "Lines: " & FORMAT$(g_lngLines)
  TextOut(hDC, 360, 80, strText, LEN(strText))
  '
  IF ISTRUE g_lngGameOver THEN
    strText = "GAME OVER!"
    TextOut(hDC, 360, 120, strText, LEN(strText))
    '
    strText = "Press R to restart"
    TextOut(hDC, 360, 150, strText, LEN(strText))
  END IF
  '
END SUB
'
SUB subInitializeGame()
' initialise the game
  ' Clear board
  RESET ga_lngGameBoard()
  '
  g_lngScore = 0
  g_lngLines = 0
  g_lngGameOver = %FALSE
  '
  g_lngNextPiece = RND(1, %Max_Blocks)
  '
  CALL subSpawnNewPiece()
  '
END SUB
'
SUB subSpawnNewPiece()
' create a new piece
  g_lngCurrentPiece = g_lngNextPiece
  g_lngNextPiece = RND(1,%Max_Blocks)
  g_lngCurrentX = %BOARD_WIDTH / 2 - 2
  g_lngCurrentY = -1
  g_lngCurrentRotation = 0
  '
  IF ISFALSE funIsValidPosition(g_lngCurrentPiece, _
                                g_lngCurrentX, _
                                g_lngCurrentY, _
                                g_lngCurrentRotation) THEN
    g_lngGameOver = %TRUE
    '
  END IF
  '
END SUB
'
FUNCTION funIsValidPosition(lngPiece AS LONG, lngX AS LONG, lngY AS LONG, _
                            lngRotation AS LONG) AS LONG
' is the position valid?
  LOCAL lngPX, lngPY AS LONG
  '
  FOR lngPX = 0 TO 3
    FOR lngPY = 0 TO 3
      IF ga_lngBlockShapes(lngPiece, lngPX, lngPY, lngRotation) THEN
        IF (lngX + lngPX) < 0 OR (lngX + lngPX) >= %BOARD_WIDTH THEN
          FUNCTION = %FALSE
          EXIT FUNCTION
        END IF
        '
        IF (lngY + lngPY) >= %BOARD_HEIGHT THEN
          FUNCTION = %FALSE
          EXIT FUNCTION
        END IF
        '
        IF (lngY + lngPY) >= 0 AND _
            ga_lngGameBoard(lngX + lngPX, lngY + lngPY) THEN
          FUNCTION = %FALSE
          EXIT FUNCTION
        END IF
      END IF
    NEXT lngPY
  NEXT lngPX
  '
  FUNCTION = %TRUE
  '
END FUNCTION
'
SUB subInitializeShapes()
' initialise the shapes to be used
  LOCAL lngI, lngJ, lngK AS LONG
  '
  ' define the colours to be used
  funDefineBlockColours()
  '
  ' Clear all shapes
  RESET ga_lngBlockShapes()
  '
  ' I-piece (line)
  ga_lngBlockShapes(%PIECE_I, 1, 0, 0) = 1
  ga_lngBlockShapes(%PIECE_I, 1, 1, 0) = 1
  ga_lngBlockShapes(%PIECE_I, 1, 2, 0) = 1
  ga_lngBlockShapes(%PIECE_I, 1, 3, 0) = 1
  ga_lngBlockShapes(%PIECE_I, 0, 1, 1) = 1
  ga_lngBlockShapes(%PIECE_I, 1, 1, 1) = 1
  ga_lngBlockShapes(%PIECE_I, 2, 1, 1) = 1
  ga_lngBlockShapes(%PIECE_I, 3, 1, 1) = 1
  '
  ' O-piece (square)
  ga_lngBlockShapes(%PIECE_O, 1, 1, 0) = 1
  ga_lngBlockShapes(%PIECE_O, 2, 1, 0) = 1
  ga_lngBlockShapes(%PIECE_O, 1, 2, 0) = 1
  ga_lngBlockShapes(%PIECE_O, 2, 2, 0) = 1
  '
  FOR lngI = 1 TO 3
    FOR lngJ = 0 TO 3
      FOR lngK = 0 TO 3
        ga_lngBlockShapes(%PIECE_O, lngJ, lngK, lngI) = _
                          ga_lngBlockShapes(%PIECE_O, lngJ, lngK, 0)
      NEXT lngK
    NEXT lngJ
  NEXT lngI
  '
  ' T-piece
  ga_lngBlockShapes(%PIECE_T, 1, 0, 0) = 1
  ga_lngBlockShapes(%PIECE_T, 0, 1, 0) = 1
  ga_lngBlockShapes(%PIECE_T, 1, 1, 0) = 1
  ga_lngBlockShapes(%PIECE_T, 2, 1, 0) = 1
  ga_lngBlockShapes(%PIECE_T, 1, 0, 1) = 1
  ga_lngBlockShapes(%PIECE_T, 1, 1, 1) = 1
  ga_lngBlockShapes(%PIECE_T, 1, 2, 1) = 1
  ga_lngBlockShapes(%PIECE_T, 2, 1, 1) = 1
  ga_lngBlockShapes(%PIECE_T, 1, 2, 2) = 1
  ga_lngBlockShapes(%PIECE_T, 0, 1, 2) = 1
  ga_lngBlockShapes(%PIECE_T, 1, 1, 2) = 1
  ga_lngBlockShapes(%PIECE_T, 2, 1, 2) = 1
  ga_lngBlockShapes(%PIECE_T, 1, 0, 3) = 1
  ga_lngBlockShapes(%PIECE_T, 0, 1, 3) = 1
  ga_lngBlockShapes(%PIECE_T, 1, 1, 3) = 1
  ga_lngBlockShapes(%PIECE_T, 1, 2, 3) = 1
  '
  ' S-piece
  ga_lngBlockShapes(%PIECE_S, 1, 0, 0) = 1
  ga_lngBlockShapes(%PIECE_S, 2, 0, 0) = 1
  ga_lngBlockShapes(%PIECE_S, 0, 1, 0) = 1
  ga_lngBlockShapes(%PIECE_S, 1, 1, 0) = 1
  ga_lngBlockShapes(%PIECE_S, 0, 0, 1) = 1
  ga_lngBlockShapes(%PIECE_S, 0, 1, 1) = 1
  ga_lngBlockShapes(%PIECE_S, 1, 1, 1) = 1
  ga_lngBlockShapes(%PIECE_S, 1, 2, 1) = 1

  ' Z-piece
  ga_lngBlockShapes(%PIECE_Z, 0, 0, 0) = 1
  ga_lngBlockShapes(%PIECE_Z, 1, 0, 0) = 1
  ga_lngBlockShapes(%PIECE_Z, 1, 1, 0) = 1
  ga_lngBlockShapes(%PIECE_Z, 2, 1, 0) = 1
  ga_lngBlockShapes(%PIECE_Z, 1, 0, 1) = 1
  ga_lngBlockShapes(%PIECE_Z, 1, 1, 1) = 1
  ga_lngBlockShapes(%PIECE_Z, 0, 1, 1) = 1
  ga_lngBlockShapes(%PIECE_Z, 0, 2, 1) = 1
  '
  ' J-piece
  ga_lngBlockShapes(%PIECE_J, 0, 0, 0) = 1
  ga_lngBlockShapes(%PIECE_J, 0, 1, 0) = 1
  ga_lngBlockShapes(%PIECE_J, 1, 1, 0) = 1
  ga_lngBlockShapes(%PIECE_J, 2, 1, 0) = 1
  ga_lngBlockShapes(%PIECE_J, 1, 0, 1) = 1
  ga_lngBlockShapes(%PIECE_J, 2, 0, 1) = 1
  ga_lngBlockShapes(%PIECE_J, 1, 1, 1) = 1
  ga_lngBlockShapes(%PIECE_J, 1, 2, 1) = 1
  ga_lngBlockShapes(%PIECE_J, 0, 1, 2) = 1
  ga_lngBlockShapes(%PIECE_J, 1, 1, 2) = 1
  ga_lngBlockShapes(%PIECE_J, 2, 1, 2) = 1
  ga_lngBlockShapes(%PIECE_J, 2, 2, 2) = 1
  ga_lngBlockShapes(%PIECE_J, 1, 0, 3) = 1
  ga_lngBlockShapes(%PIECE_J, 1, 1, 3) = 1
  ga_lngBlockShapes(%PIECE_J, 1, 2, 3) = 1
  ga_lngBlockShapes(%PIECE_J, 0, 2, 3) = 1
  '
  ' L-piece
  ga_lngBlockShapes(%PIECE_L, 2, 0, 0) = 1
  ga_lngBlockShapes(%PIECE_L, 0, 1, 0) = 1
  ga_lngBlockShapes(%PIECE_L, 1, 1, 0) = 1
  ga_lngBlockShapes(%PIECE_L, 2, 1, 0) = 1
  ga_lngBlockShapes(%PIECE_L, 1, 0, 1) = 1
  ga_lngBlockShapes(%PIECE_L, 1, 1, 1) = 1
  ga_lngBlockShapes(%PIECE_L, 1, 2, 1) = 1
  ga_lngBlockShapes(%PIECE_L, 2, 2, 1) = 1
  ga_lngBlockShapes(%PIECE_L, 0, 1, 2) = 1
  ga_lngBlockShapes(%PIECE_L, 1, 1, 2) = 1
  ga_lngBlockShapes(%PIECE_L, 2, 1, 2) = 1
  ga_lngBlockShapes(%PIECE_L, 0, 2, 2) = 1
  ga_lngBlockShapes(%PIECE_L, 0, 0, 3) = 1
  ga_lngBlockShapes(%PIECE_L, 1, 0, 3) = 1
  ga_lngBlockShapes(%PIECE_L, 1, 1, 3) = 1
  ga_lngBlockShapes(%PIECE_L, 1, 2, 3) = 1
  '
END SUB
'
FUNCTION funDefineBlockColours() AS LONG
  ' Define colors for each piece type
  ' %PIECE_I = 1
  ' %PIECE_O
  ' %PIECE_T
  ' %PIECE_S
  ' %PIECE_Z
  ' %PIECE_J
  ' %PIECE_L
  ga_dwColours(0)        = RGB(0, 0, 0)       ' Empty - black
  ga_dwColours(%PIECE_I) = RGB(0, 255, 255)   ' I - cyan
  ga_dwColours(%PIECE_O) = RGB(255, 255, 0)   ' O - yellow
  ga_dwColours(%PIECE_T) = RGB(128, 0, 128)   ' T - purple
  ga_dwColours(%PIECE_S) = RGB(0, 255, 0)     ' S - green
  ga_dwColours(%PIECE_Z) = RGB(255, 0, 0)     ' Z - red
  ga_dwColours(%PIECE_J) = RGB(0, 0, 255)     ' J - blue
  ga_dwColours(%PIECE_L) = RGB(255, 165, 0)   ' L - orange
  '
  FUNCTION = %TRUE
  '
END FUNCTION
