' This snippet draws each of the ten primitives
' supported by OpenGL.
' original code by Gary Beene with some small enhancements
' for this Video.
'
' https://www.garybeene.com/power/code/index.htm#Graphics%20-%20OpenGL
'
' GL_POINTS     GL_LINE_STRIP
' GL_LINES      GL_LINE_LOOP
' GL_POLYGON    GL_TRIANGLE_STRIP
' GL_TRIANGLES  GL_TRIANGLE_FAN
' GL_QUADS      GL_QUAD_STRIP

' Compiler Comments:
' This code was written to compile in PBWin10.
' To compile with PBWin9, split pt
' into pt.x and pt.y as arguments wherever the
' ChildWindowFromPoint() API is used (4 places).

' Compilable Example:  (Jose Includes)
' n.b. this application uses the José Roca API libraries
' but I've included the necessary Include files with
' this source
'
'
#COMPILER PBWIN 9, PBWIN 10
#COMPILE EXE
#DIM ALL
%Unicode=1
#INCLUDE "win32api.inc"
#INCLUDE "gl.inc"
#INCLUDE "glu.inc"
#INCLUDE "AfxGlut.inc"

%ID_Timer = 1001
%ID_Label = 1002

GLOBAL hDlg, hDC, hRC, hLabel AS DWORD
GLOBAL g_sngScalefactor AS SINGLE
'
ENUM Primitives SINGULAR
  BaseConstant = 500
  Points
  LINES
  Line_Strip
  Line_Loop
  Triangles
  Triangle_Strip
  Triangle_Fan
  Quads
  Quad_Strip
  Polygons
  Circles
  Spheres
  WireSphere
  Teapot
END ENUM
'
' set up macro for value of PI
MACRO mPi = 3.14159265358979324## ' ie 80-bit precision
'
FUNCTION PBMAIN() AS LONG
   DIALOG NEW PIXELS, 0, "OpenGL Example",,, 800, 700,%WS_OVERLAPPEDWINDOW TO hDlg
   CONTROL ADD LABEL, hdlg, %ID_Label,"",110,10,100,100, %WS_CHILD OR %WS_VISIBLE OR %SS_SUNKEN OR %SS_NOTIFY
   CONTROL ADD OPTION, hdlg, %Points,"Points",10,10,100,20
   CONTROL ADD OPTION, hdlg, %Lines,"Lines" ,10,35,100,20
   CONTROL ADD OPTION, hdlg, %Line_Strip,"Line_Strip",10,60,100,20
   CONTROL ADD OPTION, hdlg, %Line_Loop,"Line_Loop",10,85,100,20
   CONTROL ADD OPTION, hdlg, %Triangles,"Triangles",10,110,100,20
   CONTROL ADD OPTION, hdlg, %Triangle_Strip,"Triangle_Strip",10,135,100,20
   CONTROL ADD OPTION, hdlg, %Triangle_Fan,"Triangle_Fan",10,160,100,20
   CONTROL ADD OPTION, hdlg, %Quads,"Quads",10,185,100,20
   CONTROL ADD OPTION, hdlg, %Quad_Strip,"Quad_Strip",10,210,100,20
   CONTROL ADD OPTION, hdlg, %Polygons,"Polygons",10,235,100,20
   CONTROL ADD OPTION, hdlg, %Circles,"Circles",10,260,100,20
   CONTROL ADD OPTION, hdlg, %Spheres,"Spheres",10,285,100,20
   CONTROL ADD OPTION, hdlg, %WireSphere,"Wire Sphere",10,310,100,20
   CONTROL ADD OPTION, hdlg, %Teapot,"Teapot",10,335,100,20
   CONTROL SET OPTION  hDlg, %Points, %Points, %Teapot
   DIALOG SHOW MODAL hdlg CALL dlgproc
END FUNCTION
'
CALLBACK FUNCTION dlgproc()
   LOCAL pt AS POINT
   LOCAL sngXDelta, sngYDelta AS SINGLE
   STATIC lngSpinInWork,lngXLast,lngYLast AS LONG
   '
   SELECT CASE CB.MSG
      CASE %WM_INITDIALOG
        subGetRenderContext
        subInitializeScene
        ' prepare a timer
        SetTimer(hDlg, %ID_Timer, 50, %NULL)
        g_sngScalefactor = 1
        '
      CASE %WM_COMMAND
        IF CB.CTL >= %Points AND CB.CTL <= %Teapot THEN
        ' option button has been clicked on
          subDrawScene(0,0,0)
        END IF
        '
      CASE %WM_TIMER
      ' timer triggered to redraw scene
        subDrawScene(1,1,0)  'redraw with rotation on all 3 axes
        '
      CASE %WM_PAINT
        subDrawScene(0,0,0)  'redraw with no rotation
        '
      CASE %WM_SIZE
        CONTROL SET SIZE hDlg, %ID_Label, LO(WORD, CB.LPARAM)-120, _
                                          HI(WORD, CB.LPARAM)-20
        subResizeScene LO(WORD, CB.LPARAM)-120, HI(WORD, CB.LPARAM)-20
        subDrawScene(0,0,0)  'redraw with no rotation
        '
      CASE %WM_CLOSE
        wglmakecurrent %null, %null ' unselect rendering context
        wgldeletecontext hRC        ' delete the rendering context
        releasedc hDlg, hDC         ' release device context
        '
      CASE %WM_MOUSEWHEEL
        SELECT CASE HI(INTEGER,CB.WPARAM)
          CASE > 0
            g_sngScalefactor = g_sngScalefactor + 0.1
            subDrawScene(0,0,0)
          CASE < 0
            g_sngScalefactor = g_sngScalefactor - 0.1
            subDrawScene(0,0,0)
        END SELECT
        '
      CASE %WM_SetCursor
      ' p.x and p.y are in screen coordinates
        GetCursorPos pt
        ' p.x and p.y are now dialog client coordinates
        ScreenToClient hDlg, pt
        '
        IF GetDlgCtrlID(ChildWindowFromPoint( hDlg, pt )) <> %ID_Label THEN
          EXIT FUNCTION
        END IF
        '
        SELECT CASE HI(WORD, CB.LPARAM)
          CASE %WM_LBUTTONDOWN
          ' pt has xy screen coordinates
            GetCursorPos pt
            ' pt now has dialog client coordinates
            ScreenToClient hDlg, pt
            IF pt.y < 0 THEN
              EXIT SELECT
            END IF
            '
            ' kill off the timer
            KillTimer CB.HNDL, %ID_Timer
            lngSpinInWork = 1
            lngXLast = Pt.x
            lngYLast = Pt.y
            '
          CASE %WM_MOUSEMOVE
            IF lngSpinInWork THEN
            ' pt has xy screen coordinates
              GetCursorPos pt
              ' pt now has dialog client coordinates
              ScreenToClient hDlg, pt
              IF pt.y < 0 THEN
                EXIT SELECT
              END IF
              '
              sngXDelta = lngXLast - Pt.x
              sngYDelta = lngYLast - Pt.y
              subDrawScene(-sngYDelta, -sngXDelta, 0)
              lngXLast = pt.x
              lngYLast = pt.y
              '
            END IF
            '
          CASE %WM_LBUTTONUP
            lngSpinInWork = 0
            ' recreate the timer
            SetTimer(hDlg, %ID_Timer, 50, %NULL)
       END SELECT
       '
   END SELECT
   '
END FUNCTION

SUB subGetRenderContext
   ' pixel format properties for device context
   LOCAL pfd AS PIXELFORMATDESCRIPTOR
   '
   pfd.nSize       =  SIZEOF(PIXELFORMATDESCRIPTOR)
   pfd.nVersion    =  1
   pfd.dwFlags     = %pfd_draw_to_window _
                     OR %pfd_support_opengl _
                     OR %pfd_doublebuffer
   pfd.dwlayermask = %pfd_main_plane
   pfd.iPixelType  = %pfd_type_rgba
   pfd.ccolorbits  = 24
   pfd.cdepthbits  = 24
   '
   CONTROL HANDLE hdlg, %ID_Label TO hLabel
   hDC = GetDC(hLabel)
   'set properties of device context
   SetPixelFormat(hDC, ChoosePixelFormat(hDC, pfd), pfd)
   'get rendering context
   hRC = wglCreateContext (hDC)
   'make the RC current
   wglMakeCurrent hDC, hRC
END SUB

SUB subInitializeScene
  ' sets color to be used with glClear
  glClearColor 0,0,0,0
  ' sets zvalue to be used with glClear
  glClearDepth 1
  '
  ' specify how depth-buffer comparisons are made
  glDepthFunc %gl_less
  ' enable depth testing
  glEnable %gl_depth_test
  ' smooth shading
  glShadeModel %gl_smooth
  ' best quality rendering
  glHint %gl_perspective_correction_hint, %gl_nicest
END SUB
'
SUB subResizeScene (lngW AS LONG, lngH AS LONG)
' resize viewport to match window size
  glViewport 0, 0, lngW, lngH
  ' select the projection matrix
  glMatrixMode %gl_projection
  ' reset the projection matrix
  glLoadIdentity
  ' calculate the aspect ratio of the Window
  gluPerspective 45, lngW/lngH, 0.1, 100
  ' select the modelview matrix
  glMatrixMode %gl_modelview
  '
END SUB

SUB subDrawScene (sngDx AS SINGLE, _
                  sngDy AS SINGLE, _
                  sngDz AS SINGLE)
' draw the scene with the selected object
'
  STATIC sngAngleX, sngAngleY, sngAngleZ AS SINGLE
  LOCAL lngI,lngJ AS LONG
  LOCAL lngRadius AS LONG
  LOCAL lngRed, lngGreen, lngBlue AS LONG
  LOCAL sngAlpha, sngBeta AS SINGLE
  LOCAL lngGradation AS LONG
  '
  FOR lngI = 1 TO 14
  ' see which option has been picked
    CONTROL GET CHECK hDlg, %BaseConstant + lngI TO lngJ
    IF lngJ = %True THEN
      EXIT FOR
    END IF
  NEXT lngI
  '
  'clear buffers
  glClear %gl_color_buffer_bit OR %gl_depth_buffer_bit
  '
  'clear the modelview matrix
  'The glLoadIdentity function replaces the current matrix
  'with the identity matrix. It is semantically equivalent
  'to calling glLoadMatrix with the following identity matrix.
  ' 1 0 0 0
  ' 0 1 0 0
  ' 0 0 1 0
  ' 0 0 0 1
  glLoadIdentity
  '
  'creates a viewing matrix derived from an eye point,
  'a reference point indicating the center of the scene,
  'and an UP vector.
  gluLookAt 0,0,10,0,0,0,0,1,0
  '
  ' scales an object along the x, y, and z axes
  glScalef g_sngScalefactor, g_sngScalefactor, g_sngScalefactor
  '
  ' compute a matrix that performs a counterclockwise rotation
  ' of angle degrees about the vector from the origin
  ' through the point (x, y, z)
  sngAngleX = sngAngleX + sngDx : glRotatef sngAngleX, 1,0,0
  sngAngleY = sngAngleY + sngDy : glRotatef sngAngleY, 0,1,0
  sngAngleZ = sngAngleZ + sngDz : glRotatef sngAngleZ, 0,0,1
  '
  SELECT CASE lngI
    CASE 1
    ' points
      glcolor3ub 255,0,0        'set default vertex color
      glBegin %gl_points
      glvertex3f -1, 0, 0  ' vertex1
      glvertex3f  1, 0, 0  ' vertex2
      glvertex3f  0, 1, 0  ' vertex3
      glvertex3f  0, -1, 0 ' vertex4
      glvertex3f  0, 0, -1 ' vertex5
      glvertex3f  0, 0, 1  ' vertex6
      glEnd
      '
    CASE 2
    ' lines
      glBegin %gl_lines
      glcolor3ub 0,0,255 : glvertex3f   2, 2, -2 ' vertex1
      glcolor3ub 255,0,0 : glvertex3f  -1, 1, 2  ' vertex2
      glvertex3f   -2, -1, -2    ' vertex1
      glvertex3f    2, -3, -1    ' vertex2
      glEnd
      '
    CASE 3
    ' line strip
      glBegin %gl_line_strip
      glcolor3ub 0,0,255
      glvertex3f   -1, -1, -1   ' vertex1
      glvertex3f   -1, -1,  2   ' vertex2
      glvertex3f   -1, 2, -1    ' vertex3
      glvertex3f    1, -1.5, -1 ' vertex4
      glEnd
      '
    CASE 4
    ' line loop
      glBegin %gl_line_loop
      glcolor3ub 255,0,255
      glvertex3f   2, 2, -1    ' vertex1
      glvertex3f  -1, 1.5, -1  ' vertex2
      glvertex3f   -2, -1, -2  ' vertex3
      glvertex3f    2, -3, -1  ' vertex4
      glEnd
      '
    CASE 5
    ' triangles
      glBegin %gl_triangles
      glcolor3ub 0,255,0 : glvertex3f  0, 3,  -2 ' vertex1
      glcolor3ub 255,0,0 : glvertex3f  -3, 0, 2  ' vertex2
      glcolor3ub 0,0,255 : glvertex3f  2, -3, -1 ' vertex3
      glEnd
      '
    CASE 6
    ' triangle strip
      glBegin %gl_triangle_strip
      glcolor3ub 0,255,0 : glvertex3f   -1, 3, -2  ' vertex1
      glcolor3ub 255,0,0 : glvertex3f   2, 2, 2    ' vertex2
      glcolor3ub 0,0,255 : glvertex3f   -2, 2, -2  ' vertex3
      glcolor3ub 255,0,255 : glvertex3f   2, 1, 2  ' vertex4
      glcolor3ub 0,255,255 : glvertex3f   0, 1, -2 ' vertex5
      glcolor3ub 255,0,255 : glvertex3f   2, 0, 2  ' vertex6
      glEnd
      '
    CASE 7
    ' triangle fan
      glBegin %gl_triangle_fan
      glcolor3ub 0,255,0   : glvertex3f  -2, -2,  -1 ' vertex1
      glcolor3ub 255,0,0   : glvertex3f  -1,  3, 1   ' vertex2
      glcolor3ub 0,0,255 : glvertex3f   3,  1, -2    ' vertex3
      glcolor3ub 255,0,255 : glvertex3f   2,  1, 2   ' vertex3
      glcolor3ub 255,255,0 : glvertex3f   1,  -2, 1  ' vertex3
      glEnd
      '
    CASE 8
    ' quads
      glcolor3ub 0,255,0  ' set default vertex color
      glBegin %gl_quads
      glVertex2f  0.0, 0.0
      glVertex2f  1.0, 0.0
      glVertex2f  1.5, 1.1
      glVertex2f  0.5, 1.1
      glEnd
      '
    CASE 9
    ' quad strip
      glBegin %gl_quad_strip
      glcolor3ub 0,255,0   : glVertex2f  -2,-3
      glcolor3ub 0,255,255 : glVertex2f   2, -3
      glcolor3ub 255,0,0   : glVertex2f  -2, 0
      glcolor3ub 0,255,255 : glVertex2f   2, 0
      glcolor3ub 255,255,0 : glVertex2f  -3, 3
      glcolor3ub 0,255,0   : glVertex2f   1, 1
      glcolor3ub 255,0,0   : glVertex2f  -4, 3
      glcolor3ub 0,255,255 : glVertex2f  -2, 3
      glEnd
      '
    CASE 10
    ' polygon
      glBegin %gl_polygon
      glVertex2f -0.5, -0.5
      glVertex2f -0.5,  0.5
      glVertex2f  1.0,  1.0
      glVertex2f  1.5,  0.5
      glVertex2f  0.5, -0.5
      glEnd
      '
    CASE 11
    ' circle
       glBegin %gl_triangle_fan
       glVertex2f 0.0, 0.0  ' Center
       lngRadius = 2
       '
       lngRed = 255
       lngGreen = 200
       lngBlue = 255
       '
       FOR lngI = 0 TO 360
         '
         IF lngI < 180 THEN
           DECR lngRed
           DECR lngGreen
           DECR lngBlue
         ELSE
           INCR lngBlue
           INCR lngRed
         END IF
         '
         glcolor3ub lngRed,lngGreen,lngBlue
         '
         glVertex2f(lngRadius*COS(mPi * lngI / 180.0) + sngDx, _
                    lngRadius*SIN(mPi * lngI / 180.0) + sngDy)
       NEXT lngI
       glEnd
       '
     CASE 12
     ' solid sphere
     ' duplicates the current matrix by pushing the
     ' current matrix stack down by one
       glPushMatrix
       '
       ' glTranslate lets you "move" things
       glTranslatef sngDx, sngDy, sngDz

       ' set the three parameters
       ' 1 - Radius
       ' 2 - The number of subdivisions around the Z axis
       '     (similar to lines of longitude).
       ' 3 - The number of subdivisions along the Z axis
       '     (similar to lines of latitude).
       AfxGlutSolidSphere 0.8, 64, 64
       '
       DIM position(3) AS SINGLE
       DIM matx(2) AS SINGLE

       ARRAY ASSIGN position() = 0.5, 0.5, 3.0, 0.0
       '
       glEnable %GL_DEPTH_TEST
       '
       ' set up the lighting
       glLightfv %GL_LIGHT0, %GL_POSITION, position(0)
       glEnable %GL_LIGHTING
       glEnable %GL_LIGHT0
       '
       ARRAY ASSIGN matx() = 0.1745, 0.01175, 0.01175
       ' sets material parameters, such as colors and shininess, for shading:
       glMaterialfv %GL_FRONT, %GL_AMBIENT, matx(0)
       matx(0) = 0.61424 : matx(1) = 0.04136 : matx(2) = 0.04136
       '
       glMaterialfv %GL_FRONT, %GL_DIFFUSE, matx(0)
       matx(0) = 0.727811 : matx(1) = 0.626959 : matx(2) = 0.626959
       '
       glMaterialfv %GL_FRONT, %GL_SPECULAR, matx(0)
       glMaterialf %GL_FRONT, %GL_SHININESS, 0.6 * 128.0
       '
       ' pops the current matrix stack
       glPopMatrix
       '
     CASE 13
     ' wire frame sphere
     ' duplicates the current matrix by pushing the
     ' current matrix stack down by one
       glPushMatrix
       '
       ' glTranslate lets you "move" things
       glTranslatef sngDx, sngDy, sngDz

       ' set the three parameters
       ' 1 - Radius
       ' 2 - The number of subdivisions around the Z axis
       '     (similar to lines of longitude).
       ' 3 - The number of subdivisions along the Z axis
       '     (similar to lines of latitude).
       AfxGlutWireSphere 0.8, 16, 16
       '
       glEnable %GL_DEPTH_TEST
       '
       ' pops the current matrix stack
       glPopMatrix
       '
     CASE 14
     ' teapot
       ' duplicates the current matrix by pushing the
     ' current matrix stack down by one
       glPushMatrix
       '
       ' glTranslate lets you "move" things
       glTranslatef sngDx, sngDy, sngDz

       ' set the three parameters
       ' 1 - Radius
       ' 2 - The number of subdivisions around the Z axis
       '     (similar to lines of longitude).
       ' 3 - The number of subdivisions along the Z axis
       '     (similar to lines of latitude).
       AfxGlutSolidTeapot 0.8
       '
       DIM position(3) AS SINGLE
       DIM matx(2) AS SINGLE

       ARRAY ASSIGN position() = 0.5, 0.5, 3.0, 0.0
       '
       glEnable %GL_DEPTH_TEST
       '
       ' set up the lighting
       glLightfv %GL_LIGHT0, %GL_POSITION, position(0)
       glEnable %GL_LIGHTING
       glEnable %GL_LIGHT0
       '
       ARRAY ASSIGN matx() = 0.1745, 0.01175, 0.01175
       ' sets material parameters, such as colors and shininess, for shading:
       glMaterialfv %GL_FRONT, %GL_AMBIENT, matx(0)
       matx(0) = 0.61424 : matx(1) = 0.04136 : matx(2) = 0.04136
       '
       glMaterialfv %GL_FRONT, %GL_DIFFUSE, matx(0)
       matx(0) = 0.727811 : matx(1) = 0.626959 : matx(2) = 0.626959
       '
       glMaterialfv %GL_FRONT, %GL_SPECULAR, matx(0)
       glMaterialf %GL_FRONT, %GL_SHININESS, 0.6 * 128.0
       '
       ' pops the current matrix stack
       glPopMatrix
     '
   END SELECT
   '
   SwapBuffers hDC  ' display the buffer (image) to the user
   '
END SUB
'
