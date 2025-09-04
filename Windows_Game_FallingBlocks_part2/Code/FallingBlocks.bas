' Falling Blocks game
#COMPILE EXE
#DIM ALL
'
#INCLUDE "WIN32API.INC"
'
' Game constants
%BOARD_WIDTH   = 12
%BOARD_HEIGHT  = 20
%BLOCK_SIZE    = 25
%TIMER_ID      = 1
%DROP_INTERVAL = 500  ' set to 500ms
%Max_Blocks    = 7
%PREVIEW_SIZE  = 15
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
' Game state structure
TYPE GameState
  hDlg AS DWORD
  currentPiece AS LONG
  currentX AS LONG
  currentY AS LONG
  currentRotation AS LONG
  nextPiece AS LONG
  score AS LONG
  lines AS LONG
  level AS LONG
  gameOver AS LONG
  dropInterval AS LONG
END TYPE
'
GLOBAL g_GameState AS GameState
GLOBAL ga_lngGameBoard() AS LONG
GLOBAL ga_lngBlockShapes() AS LONG
' array for colours of blocks
GLOBAL ga_dwColours() AS DWORD

' Precomputed shape data for better performance
TYPE ShapeData
  blocks(0 TO 3, 0 TO 3) AS LONG
END TYPE
'
GLOBAL ga_ShapeCache() AS ShapeData
'
FUNCTION PBMAIN() AS LONG
  ' Initialize arrays
  REDIM ga_lngGameBoard(0 TO %BOARD_WIDTH-1, 0 TO %BOARD_HEIGHT-1)
  REDIM ga_lngBlockShapes(1 TO %Max_Blocks, 0 TO 3, 0 TO 3, 0 TO 3)
  ' array for colours of blocks
  REDIM ga_dwColours(0 TO %Max_Blocks)
  REDIM ga_ShapeCache(1 TO %Max_Blocks, 0 TO 3)
  '
  PREFIX "g_GameState."
    gameOver = %FALSE
    dropInterval = %DROP_INTERVAL
  END PREFIX
  '
  DIALOG NEW PIXELS, 0, "PowerBasic Falling Blocks", , , 550, 650, _
        %WS_CAPTION OR %WS_SYSMENU OR %WS_MINIMIZEBOX, 0 TO g_GameState.hDlg
        '
  DIALOG SHOW MODAL g_GameState.hDlg, CALL funcb_DlgProc
  '
END FUNCTION
'
CALLBACK FUNCTION funcb_DlgProc() AS LONG
' callback function for dialog
  LOCAL hDC AS DWORD
  LOCAL ps AS PAINTSTRUCT
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
      CALL subPrecomputeShapes()
      CALL subInitializeGame()
      SetTimer(CB.HNDL, %TIMER_ID, g_GameState.dropInterval, _
               BYVAL %NULL)
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
      IF CB.WPARAM = %TIMER_ID AND ISFALSE g_GameState.gameOver THEN
        ' Check if piece can drop
        IF ISTRUE funIsValidPosition(g_GameState.currentPiece, _
                                     g_GameState.currentX, _
                                     g_GameState.currentY + 1, _
                                     g_GameState.currentRotation) THEN
           INCR g_GameState.currentY
           '
         ELSE
         ' we can't go any further so place the piece here
         ' and spawn a new one
           CALL subPlacePiece()
           lngClearLines = funClearLines()
          IF lngClearLines > 0 THEN
            g_GameState.lines = g_GameState.lines + lngClearLines
            '
            ' Progressive scoring system
            g_GameState.score = g_GameState.score + _
                               lngClearLines * 100 * (g_GameState.level + 1)
            ' Level progression
            PREFIX "g_GameState."
              level = g_GameState.lines \ 10
              dropInterval = MAX(50, 500 - g_GameState.level * 25)
            END PREFIX
            ' remove the existing timer
            KillTimer(CB.HNDL, %TIMER_ID)
            ' recreate with new interval
            SetTimer(CB.HNDL, %TIMER_ID, _
                     g_GameState.dropInterval, BYVAL %NULL)
            '
          END IF
           CALL subSpawnNewPiece()
         END IF
         '
         InvalidateRect(CB.HNDL, BYVAL %NULL, %FALSE)
       '
      ELSEIF ISTRUE g_GameState.gameOver THEN
        KillTimer(CB.HNDL, %TIMER_ID)
       END IF
      FUNCTION = 0
      '
    CASE %WM_KEYUP
      lngKeypress = CB.WPARAM
      '
      IF ISFALSE g_GameState.gameOver THEN
        SELECT CASE lngKeypress
          CASE %VK_LEFT
            CALL subMovePiece(-1, 0, 0)
          CASE %VK_RIGHT
            CALL subMovePiece(1, 0, 0)
          CASE %VK_DOWN
            CALL subMovePiece(0, 1, 0)
          CASE %VK_UP
            CALL subMovePiece(0, 0, 1)
          CASE %VK_SPACE
            CALL subHardDrop()
        END SELECT
       '
      ELSE
      ' game is over
        SELECT CASE lngKeypress
          CASE ASC("R"), ASC("r")
            CALL subInitializeGame()
            InvalidateRect(CB.HNDL, BYVAL %NULL, %FALSE)
            SetTimer(CB.HNDL, %TIMER_ID, g_GameState.dropInterval, BYVAL %NULL)
          CASE ASC("Q") , ASC("q")
            DIALOG END CB.HNDL
            FUNCTION = 1
        END SELECT
      END IF
       FUNCTION = 0
     '
    CASE %WM_CLOSE
      KillTimer(CB.HNDL, %TIMER_ID)
      DIALOG END CB.HNDL
      FUNCTION = 1
      '
    CASE ELSE
      FUNCTION = 0
  END SELECT
  '
END FUNCTION
'
FUNCTION funClearLines() AS LONG
  LOCAL lngY, lngX, lngClearLines AS LONG
  LOCAL lngWriteRow AS LONG
  LOCAL a_lngLinesToClear() AS LONG
  '
  ' Mark lines to clear
  REDIM a_lngLinesToClear(0 TO %BOARD_HEIGHT-1)
  lngClearLines = 0
  '
  FOR lngY = 0 TO %BOARD_HEIGHT-1
    LOCAL lngFullLine AS LONG
    lngFullLine = 1
    FOR lngX = 0 TO %BOARD_WIDTH-1
      IF ga_lngGameBoard(lngX, lngY) = 0 THEN
        lngFullLine = 0
        EXIT FOR
      END IF
    NEXT lngX
    '
    IF lngFullLine THEN
      a_lngLinesToClear(lngY) = 1
      INCR lngClearLines
    END IF
  NEXT lngY
      '
  ' Compact the board in one pass
  IF lngClearLines > 0 THEN
    lngWriteRow = %BOARD_HEIGHT - 1
    FOR lngY = %BOARD_HEIGHT - 1 TO 0 STEP -1
      IF a_lngLinesToClear(lngY) = 0 THEN
        IF lngWriteRow <> lngY THEN
      FOR lngX = 0 TO %BOARD_WIDTH-1
            ga_lngGameBoard(lngX, lngWriteRow) = ga_lngGameBoard(lngX, lngY)
      NEXT lngX
    END IF
        DECR lngWriteRow
      END IF
    NEXT lngY
    '
    ' Clear top lines
    FOR lngY = 0 TO lngClearLines - 1
      FOR lngX = 0 TO %BOARD_WIDTH-1
        ga_lngGameBoard(lngX, lngY) = 0
      NEXT lngX
  NEXT lngY
  END IF
  '
  FUNCTION = lngClearLines
  '
END FUNCTION
'
SUB subPlacePiece()
' place the piece
  LOCAL lngPX, lngPY, lngBoardX, lngBoardY AS LONG
  '
  FOR lngPX = 0 TO 3
    FOR lngPY = 0 TO 3
      IF ga_ShapeCache(g_GameState.currentPiece, _
                       g_GameState.currentRotation).blocks(lngPX, lngPY) THEN
        lngBoardY = g_GameState.currentY + lngPY
        IF lngBoardY >= 0 THEN
          lngBoardX = g_GameState.currentX + lngPX
          ga_lngGameBoard(lngBoardX, lngBoardY) = g_GameState.currentPiece
        END IF
      END IF
    NEXT lngPY
  NEXT lngPX
  '
END SUB
'
SUB subDrawGame(hDC AS DWORD)
' draw the game board - with a next piece preview
  LOCAL lngX, lngY, lngPX, lngPY AS LONG
  LOCAL hBrush, hOldBrush AS DWORD
  LOCAL uRect AS RECT
  LOCAL strText AS ASCIIZ * 50
  LOCAL lngBlock AS LONG
  '
  ' Clear background
  GetClientRect(g_GameState.hDlg, uRect)
  hBrush = CreateSolidBrush(RGB(16, 16, 32))
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
        hBrush = CreateSolidBrush(RGB(48, 48, 64))
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
      ' Draw a subtle border
      SetPixel(hDC, uRect.left, uRect.top, RGB(128, 128, 128))
      '
    NEXT lngY
  NEXT lngX
  '
  ' Draw current piece
  IF ISFALSE g_GameState.gameOver THEN
    hBrush = CreateSolidBrush(ga_dwColours(g_GameState.currentPiece))
    FOR lngPX = 0 TO 3
      FOR lngPY = 0 TO 3
        IF ga_ShapeCache(g_GameState.currentPiece, _
                         g_GameState.currentRotation) _
                         .blocks(lngPX, lngPY) THEN
          IF (g_GameState.currentY + lngPY) >= 0 THEN
            PREFIX "uRect."
              left = 50 + (g_GameState.currentX + lngPX) * %BLOCK_SIZE
              top = 50 + (g_GameState.currentY + lngPY) * %BLOCK_SIZE
              right = uRect.left + %BLOCK_SIZE - 1
              bottom = uRect.top + %BLOCK_SIZE - 1
            END PREFIX
            FillRect(hDC, urect, hBrush)
          END IF
        END IF
      NEXT lngPY
    NEXT lngPX
    DeleteObject(hBrush)
  END IF
  '
  ' Draw UI elements with better formatting
  SetTextColor(hDC, RGB(255, 255, 255))
  SetBkMode(hDC, %TRANSPARENT)
  '
  strText = "Score: " & FORMAT$(g_GameState.score, "#,##0")
  TextOut(hDC, 380, 50, strText, LEN(strText))
  '
  strText = "Lines: " & FORMAT$(g_GameState.lines)
  TextOut(hDC, 380, 80, strText, LEN(strText))
  '
  strText = "Level: " & FORMAT$(g_GameState.level)
  TextOut(hDC, 380, 110, strText, LEN(strText))
  '
  ' Draw next piece preview
  strText = "Next:"
  TextOut(hDC, 380, 150, strText, LEN(strText))
  '
  IF ISFALSE g_GameState.gameOver THEN
    hBrush = CreateSolidBrush(ga_dwColours(g_GameState.nextPiece))
    FOR lngPX = 0 TO 3
      FOR lngPY = 0 TO 3
        IF ga_ShapeCache(g_GameState.nextPiece, 0).blocks(lngPX, lngPY) THEN
          PREFIX "uRect."
            left = 380 + lngPX * %PREVIEW_SIZE
            top = 170 + lngPY * %PREVIEW_SIZE
            right = uRect.left + %PREVIEW_SIZE - 1
            bottom = uRect.top + %PREVIEW_SIZE - 1
          END PREFIX
          FillRect(hDC, uRect, hBrush)
        END IF
      NEXT lngPY
    NEXT lngPX
    DeleteObject(hBrush)
  END IF
  '
  ' Game over screen
  IF ISTRUE g_GameState.gameOver THEN
    strText = "GAME OVER!"
    TextOut(hDC, 380, 280, strText, LEN(strText))
    strText = "Press R to restart"
    TextOut(hDC, 380, 310, strText, LEN(strText))
    strText = "Press Q to quit"
    TextOut(hDC, 380, 340, strText, LEN(strText))
  END IF
  '
  ' Controls help
  strText = "Controls:"
  TextOut(hDC, 360, 400, strText, LEN(strText))
  '
  strText = "Right/Left Arrow Keys: Move"
  TextOut(hDC, 360, 420, strText, LEN(strText))
  '
  strText = "Up Arrow Key: Rotate"
  TextOut(hDC, 360, 440, strText, LEN(strText))
  '
  strText = "Space: Hard Drop"
  TextOut(hDC, 360, 460, strText, LEN(strText))
  '
END SUB
'
SUB subInitializeGame()
' initialise the game
  ' Clear board
  RESET ga_lngGameBoard()
  '
  PREFIX "g_GameState."
    score = 0
    lines = 0
    level = 0
    gameOver = %FALSE
    dropInterval = %DROP_INTERVAL
    nextPiece = RND(1, %Max_Blocks)
  END PREFIX
  '
  CALL subSpawnNewPiece()
  '
END SUB
'
SUB subSpawnNewPiece()
' spawn a new piece
  PREFIX "g_GameState."
    currentPiece = g_GameState.nextPiece
    nextPiece = RND(1, %Max_Blocks)
    currentX = %BOARD_WIDTH \ 2 - 2
    currentY = -1
    currentRotation = 0
  END PREFIX
  '
  IF ISFALSE funIsValidPosition(g_GameState.currentPiece, _
                                g_GameState.currentX, _
                                g_GameState.currentY, _
                                g_GameState.currentRotation) THEN
    g_GameState.gameOver = %TRUE
    '
  END IF
  '
END SUB
'
SUB subMovePiece(lngDeltaX AS LONG, _
                 lngDeltaY AS LONG, _
                 lngDeltaRotation AS LONG)
' move a piece on the board
  LOCAL lngNewX, lngNewY, lngNewRotation AS LONG
  '
  lngNewX = g_GameState.currentX + lngDeltaX
  lngNewY = g_GameState.currentY + lngDeltaY
  lngNewRotation = (g_GameState.currentRotation + _
                    lngDeltaRotation) MOD 4
  '
  IF ISTRUE funIsValidPosition(g_GameState.currentPiece, _
                               lngNewX, lngNewY, lngNewRotation) THEN
    PREFIX "g_GameState."
      currentX = lngNewX
      currentY = lngNewY
      currentRotation = lngNewRotation
    END PREFIX
    '
    InvalidateRect(g_GameState.hDlg, BYVAL %NULL, %FALSE)
    '
  END IF
  '
END SUB
'
FUNCTION funIsValidPosition(lngPiece AS LONG, _
                            lngX AS LONG, lngY AS LONG, _
                            lngRotation AS LONG) AS LONG
  ' is this a valid position?
  LOCAL lngPX, lngPY, lngBoardX, lngBoardY AS LONG
  '
  ' Use precomputed shape data
  FOR lngPX = 0 TO 3
    FOR lngPY = 0 TO 3
      IF ga_ShapeCache(lngPiece, lngRotation).blocks(lngPX, lngPY) THEN
        lngBoardX = lngX + lngPX
        lngBoardY = lngY + lngPY
        '
        ' Check boundaries
        IF lngBoardX < 0 OR _
           lngBoardX >= %BOARD_WIDTH OR _
           lngBoardY >= %BOARD_HEIGHT THEN
          FUNCTION = %FALSE
          EXIT FUNCTION
        END IF
        '
        ' Check collision with existing blocks
        IF lngBoardY >= 0 AND ga_lngGameBoard(lngBoardX, lngBoardY) <> 0 THEN
          FUNCTION = %FALSE
          EXIT FUNCTION
        END IF
        '
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
  PREFIX "ga_lngBlockShapes"
    (%PIECE_I, 1, 0, 0) = 1
    (%PIECE_I, 1, 1, 0) = 1
    (%PIECE_I, 1, 2, 0) = 1
    (%PIECE_I, 1, 3, 0) = 1
    (%PIECE_I, 0, 1, 1) = 1
    (%PIECE_I, 1, 1, 1) = 1
    (%PIECE_I, 2, 1, 1) = 1
    (%PIECE_I, 3, 1, 1) = 1
  END PREFIX

  ' O-piece (square) - all rotations same
  PREFIX "ga_lngBlockShapes"
    (%PIECE_O, 1, 1, 0) = 1
    (%PIECE_O, 2, 1, 0) = 1
    (%PIECE_O, 1, 2, 0) = 1
    (%PIECE_O, 2, 2, 0) = 1
  END PREFIX

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
  PREFIX "ga_lngBlockShapes"
    (%PIECE_T, 1, 0, 0) = 1
    (%PIECE_T, 0, 1, 0) = 1
    (%PIECE_T, 1, 1, 0) = 1
    (%PIECE_T, 2, 1, 0) = 1
    (%PIECE_T, 1, 0, 1) = 1
    (%PIECE_T, 1, 1, 1) = 1
    (%PIECE_T, 1, 2, 1) = 1
    (%PIECE_T, 2, 1, 1) = 1
    (%PIECE_T, 1, 2, 2) = 1
    (%PIECE_T, 0, 1, 2) = 1
    (%PIECE_T, 1, 1, 2) = 1
    (%PIECE_T, 2, 1, 2) = 1
    (%PIECE_T, 1, 0, 3) = 1
    (%PIECE_T, 0, 1, 3) = 1
    (%PIECE_T, 1, 1, 3) = 1
    (%PIECE_T, 1, 2, 3) = 1
  END PREFIX

  ' S-piece
  PREFIX "ga_lngBlockShapes"
    (%PIECE_S, 1, 0, 0) = 1
    (%PIECE_S, 2, 0, 0) = 1
    (%PIECE_S, 0, 1, 0) = 1
    (%PIECE_S, 1, 1, 0) = 1
    (%PIECE_S, 0, 0, 1) = 1
    (%PIECE_S, 0, 1, 1) = 1
    (%PIECE_S, 1, 1, 1) = 1
    (%PIECE_S, 1, 2, 1) = 1
    (%PIECE_S, 1, 0, 2) = 1
    (%PIECE_S, 2, 0, 2) = 1
    (%PIECE_S, 0, 1, 2) = 1
    (%PIECE_S, 1, 1, 2) = 1
    (%PIECE_S, 0, 0, 3) = 1
    (%PIECE_S, 0, 1, 3) = 1
    (%PIECE_S, 1, 1, 3) = 1
    (%PIECE_S, 1, 2, 3) = 1
  END PREFIX

  ' Z-piece
  PREFIX "ga_lngBlockShapes"
    (%PIECE_Z, 0, 0, 0) = 1
    (%PIECE_Z, 1, 0, 0) = 1
    (%PIECE_Z, 1, 1, 0) = 1
    (%PIECE_Z, 2, 1, 0) = 1
    (%PIECE_Z, 1, 0, 1) = 1
    (%PIECE_Z, 1, 1, 1) = 1
    (%PIECE_Z, 0, 1, 1) = 1
    (%PIECE_Z, 0, 2, 1) = 1
    (%PIECE_Z, 0, 0, 2) = 1
    (%PIECE_Z, 1, 0, 2) = 1
    (%PIECE_Z, 1, 1, 2) = 1
    (%PIECE_Z, 2, 1, 2) = 1
    (%PIECE_Z, 0, 0, 3) = 1
    (%PIECE_Z, 1, 0, 3) = 1
    (%PIECE_Z, 1, 1, 3) = 1
    (%PIECE_Z, 2, 1, 3) = 1
  END PREFIX

  ' J-piece
  PREFIX "ga_lngBlockShapes"
    (%PIECE_J, 0, 0, 0) = 1
    (%PIECE_J, 0, 1, 0) = 1
    (%PIECE_J, 1, 1, 0) = 1
    (%PIECE_J, 2, 1, 0) = 1
    (%PIECE_J, 1, 0, 1) = 1
    (%PIECE_J, 2, 0, 1) = 1
    (%PIECE_J, 1, 1, 1) = 1
    (%PIECE_J, 1, 2, 1) = 1
    (%PIECE_J, 0, 1, 2) = 1
    (%PIECE_J, 1, 1, 2) = 1
    (%PIECE_J, 2, 1, 2) = 1
    (%PIECE_J, 2, 2, 2) = 1
    (%PIECE_J, 1, 0, 3) = 1
    (%PIECE_J, 1, 1, 3) = 1
    (%PIECE_J, 1, 2, 3) = 1
    (%PIECE_J, 0, 2, 3) = 1
  END PREFIX

  ' L-piece
  PREFIX "ga_lngBlockShapes"
    (%PIECE_L, 2, 0, 0) = 1
    (%PIECE_L, 0, 1, 0) = 1
    (%PIECE_L, 1, 1, 0) = 1
    (%PIECE_L, 2, 1, 0) = 1
    (%PIECE_L, 1, 0, 1) = 1
    (%PIECE_L, 1, 1, 1) = 1
    (%PIECE_L, 1, 2, 1) = 1
    (%PIECE_L, 2, 2, 1) = 1
    (%PIECE_L, 0, 1, 2) = 1
    (%PIECE_L, 1, 1, 2) = 1
    (%PIECE_L, 2, 1, 2) = 1
    (%PIECE_L, 0, 2, 2) = 1
    (%PIECE_L, 0, 0, 3) = 1
    (%PIECE_L, 1, 0, 3) = 1
    (%PIECE_L, 1, 1, 3) = 1
    (%PIECE_L, 1, 2, 3) = 1
  END PREFIX
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
  ga_dwColours(%PIECE_T) = RGB(160, 32, 240)  ' T - purple (enhanced)
  ga_dwColours(%PIECE_S) = RGB(50, 205, 50)   ' S - green (enhanced)
  ga_dwColours(%PIECE_Z) = RGB(255, 69, 0)    ' Z - red-orange (enhanced)
  ga_dwColours(%PIECE_J) = RGB(30, 144, 255)  ' J - blue (enhanced)
  ga_dwColours(%PIECE_L) = RGB(255, 140, 0)   ' L - orange (enhanced)
  FUNCTION = %TRUE
  '
END FUNCTION
'
SUB subHardDrop()
' drop the piece to the bottom of the board
  LOCAL lngDropDistance AS LONG
  '
  lngDropDistance = 0
  WHILE ISTRUE funIsValidPosition(g_GameState.currentPiece, _
                                  g_GameState.currentX, _
                                  g_GameState.currentY + lngDropDistance + 1, _
                                  g_GameState.currentRotation)
    INCR lngDropDistance
    '
  WEND
  '
  ' Bonus for hard drop
  PREFIX "g_GameState."
    currentY = g_GameState.currentY + lngDropDistance
    score = g_GameState.score + lngDropDistance * 2
  END PREFIX
  '
  InvalidateRect(g_GameState.hDlg, BYVAL %NULL, %FALSE)
  '
END SUB
'
SUB subPrecomputeShapes()
' Precompute shape data for faster collision detection
  LOCAL lngPiece, lngRotation, lngX, lngY AS LONG
  '
  FOR lngPiece = 1 TO %Max_Blocks
    FOR lngRotation = 0 TO 3
      FOR lngX = 0 TO 3
        FOR lngY = 0 TO 3
          ga_ShapeCache(lngPiece, lngRotation).blocks(lngX, lngY) = _
            ga_lngBlockShapes(lngPiece, lngX, lngY, lngRotation)
        NEXT lngY
      NEXT lngX
    NEXT lngRotation
  NEXT lngPiece
  '
END SUB
