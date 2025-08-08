' Parabola Graph Program for Picocalc
' Displays x = y*y using LINE command

CLS
' Set up screen dimensions and scaling
SCREEN_WIDTH = 320
SCREEN_HEIGHT = 240
CENTER_X = SCREEN_WIDTH / 2
CENTER_Y = SCREEN_HEIGHT / 2


TXT_Y_OF = 8  ' offset 
TXT_X_OF = 8  ' offset

' Scaling factors to fit the parabola nicely on screen
SCALE_X = 3
SCALE_Y = 20

PRINT "Graphing x = y*y"
PAUSE 500
CLS

' Draw axes
' X-axis (horizontal line through center)
LINE 0, CENTER_Y, SCREEN_WIDTH, CENTER_Y, 1, RGB(WHITE)
' Y-axis (vertical line through center)  
LINE CENTER_X, 0, CENTER_X, SCREEN_HEIGHT, 1, RGB(WHITE)

' Add axis labels and tick marks
' X-axis tick marks
FOR i = -5 TO 5
  x_pos = CENTER_X + i * 20
  IF x_pos >= 0 AND x_pos <= SCREEN_WIDTH THEN
    LINE x_pos, CENTER_Y - 3, x_pos, CENTER_Y + 3, 1, RGB(WHITE)
    IF i <> 0 then
      TEXT x_pos,CENTER_Y - 3 + TXT_Y_OF, STR$(i),,,,RGB(WHITE)
    END IF
  END IF
NEXT i

' Y-axis tick marks
FOR i = -5 TO 5
  y_pos = CENTER_Y - i * 20
  IF y_pos >= 0 AND y_pos <= SCREEN_HEIGHT THEN
    LINE CENTER_X - 3, y_pos, CENTER_X + 3, y_pos, 1, RGB(WHITE)
    IF i <> 0 then
      TEXT CENTER_X - 3 + TXT_X_OF,y_pos, STR$(i),,,,RGB(WHITE)
    END IF
  END IF
NEXT i

' Draw the parabola x = y*y
' We'll plot points and connect them with lines
' Start with the first point
y = -6
x = y * y
prev_screen_x = CENTER_X + x * SCALE_X
prev_screen_y = CENTER_Y - y * SCALE_Y

' Plot the curve by connecting points
FOR y = -5.9 TO 5.9 STEP 0.1
  x = y * y
  ' Convert to screen coordinates
  screen_x = CENTER_X + x * SCALE_X
  screen_y = CENTER_Y - y * SCALE_Y
  IF screen_x >= 0 AND screen_x <= SCREEN_WIDTH AND screen_y >= 0 AND screen_y <= SCREEN_HEIGHT THEN
    IF prev_screen_x >= 0 AND prev_screen_x <= SCREEN_WIDTH AND prev_screen_y >= 0 AND prev_screen_y <= SCREEN_HEIGHT THEN
      LINE prev_screen_x, prev_screen_y, screen_x, screen_y, 1, RGB(YELLOW)
    END IF
  END IF
  
  prev_screen_x = screen_x
  prev_screen_y = screen_y
NEXT y

' Add title and labels
TEXT 10, 10, "x = y*y",,,, RGB(WHITE)
TEXT 10, 25, "Yellow: Parabola",,,, RGB(YELLOW)
TEXT 10, 40, "White: Axes",,,, RGB(WHITE)

TEXT 5,SCREEN_HEIGHT +20, "Graph complete. Press any key to exit...",,,, RGB(GREEN)
Do While Inkey$ <> "" : Loop  ' Clear existing input.
Do While Inkey$ = ""  : Loop  ' Wait for a new key to be pressed.
END
