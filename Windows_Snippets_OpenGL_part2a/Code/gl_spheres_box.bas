#COMPILE EXE
#DIM ALL
#INCLUDE "WIN32API.INC"

'------------------------------------------------------------------------
' OpenGL / GLU declarations (not in WIN32API.INC, so declared here)
'------------------------------------------------------------------------
DECLARE SUB glClearColor  LIB "OPENGL32.DLL" ALIAS "glClearColor"  (BYVAL r AS SINGLE, BYVAL g AS SINGLE, BYVAL b AS SINGLE, BYVAL a AS SINGLE)
DECLARE SUB glClear       LIB "OPENGL32.DLL" ALIAS "glClear"       (BYVAL mask AS DWORD)
DECLARE SUB glEnable      LIB "OPENGL32.DLL" ALIAS "glEnable"      (BYVAL cap AS LONG)
DECLARE SUB glDisable     LIB "OPENGL32.DLL" ALIAS "glDisable"     (BYVAL cap AS LONG)
DECLARE SUB glBlendFunc   LIB "OPENGL32.DLL" ALIAS "glBlendFunc"   (BYVAL sfactor AS LONG, BYVAL dfactor AS LONG)
DECLARE SUB glDepthMask   LIB "OPENGL32.DLL" ALIAS "glDepthMask"   (BYVAL flag AS LONG)
DECLARE SUB glMatrixMode  LIB "OPENGL32.DLL" ALIAS "glMatrixMode"  (BYVAL MODE AS LONG)
DECLARE SUB glLoadIdentity LIB "OPENGL32.DLL" ALIAS "glLoadIdentity" ()
DECLARE SUB glViewport    LIB "OPENGL32.DLL" ALIAS "glViewport"    (BYVAL x AS LONG, BYVAL y AS LONG, BYVAL cw AS LONG, BYVAL ch AS LONG)
DECLARE SUB glTranslatef  LIB "OPENGL32.DLL" ALIAS "glTranslatef"  (BYVAL x AS SINGLE, BYVAL y AS SINGLE, BYVAL z AS SINGLE)
DECLARE SUB glRotatef     LIB "OPENGL32.DLL" ALIAS "glRotatef"     (BYVAL ang AS SINGLE, BYVAL x AS SINGLE, BYVAL y AS SINGLE, BYVAL z AS SINGLE)
DECLARE SUB glColor4f     LIB "OPENGL32.DLL" ALIAS "glColor4f"     (BYVAL r AS SINGLE, BYVAL g AS SINGLE, BYVAL b AS SINGLE, BYVAL a AS SINGLE)
DECLARE SUB glBegin       LIB "OPENGL32.DLL" ALIAS "glBegin"       (BYVAL MODE AS LONG)
DECLARE SUB glEnd         LIB "OPENGL32.DLL" ALIAS "glEnd"         ()
DECLARE SUB glVertex3f    LIB "OPENGL32.DLL" ALIAS "glVertex3f"    (BYVAL x AS SINGLE, BYVAL y AS SINGLE, BYVAL z AS SINGLE)
DECLARE SUB glFlush       LIB "OPENGL32.DLL" ALIAS "glFlush"       ()
DECLARE SUB glLineWidth   LIB "OPENGL32.DLL" ALIAS "glLineWidth"   (BYVAL w AS SINGLE)
DECLARE SUB glShadeModel  LIB "OPENGL32.DLL" ALIAS "glShadeModel"  (BYVAL MODE AS LONG)
'
DECLARE SUB gluPerspective LIB "GLU32.DLL" ALIAS "gluPerspective" (BYVAL fovy AS DOUBLE, BYVAL aspect AS DOUBLE, BYVAL zn AS DOUBLE, BYVAL zf AS DOUBLE)
'
'------------------------------------------------------------------------
' GL constants used
'------------------------------------------------------------------------
%GL_COLOR_BUFFER_BIT   = &H00004000
%GL_DEPTH_BUFFER_BIT   = &H00000100
%GL_DEPTH_TEST         = &H0B71
%GL_BLEND              = &H0BE2
%GL_SRC_ALPHA          = &H0302
%GL_ONE_MINUS_SRC_ALPHA = &H0303
%GL_PROJECTION         = &H1701
%GL_MODELVIEW          = &H1700
%GL_LINES              = &H0001
%GL_LINE_LOOP          = &H0002
%GL_QUADS              = &H0007
%GL_QUAD_STRIP         = &H0008
%GL_CULL_FACE          = &H0B44
%GL_BACK               = &H0405
%GL_SMOOTH             = &H1D01

'------------------------------------------------------------------------
' Globals
'------------------------------------------------------------------------
GLOBAL ghWnd    AS DWORD      ' window handle
GLOBAL ghDC     AS DWORD      ' device context handle
GLOBAL ghRC     AS DWORD      ' OpenGL rendering context
'
GLOBAL gAngle   AS SINGLE     ' angle of rotation
' total number of spheres to be drawn
%NUM_SPHERES = 100

GLOBAL a_sphX()  AS SINGLE   ' x,y & Z co-ordinate arrays
GLOBAL a_sphY()  AS SINGLE   '
GLOBAL a_sphZ()  AS SINGLE   '
GLOBAL a_sphR()  AS SINGLE   ' radius
GLOBAL a_sphCR() AS SINGLE   ' colour red component
GLOBAL a_sphCG() AS SINGLE   ' colour green component
GLOBAL a_sphCB() AS SINGLE   ' colour blue component
'
%BOX_LIMIT = 5  ' box extends from -5 to +5 on each axis

FUNCTION WINMAIN (BYVAL hInstance AS DWORD, _
                  BYVAL hPrevInstance AS DWORD, _
                  BYVAL lpCmdLine AS ASCIIZ PTR, _
                  BYVAL iCmdShow AS LONG) AS LONG
' first function called when app executes
  LOCAL wc      AS WNDCLASSEX
  LOCAL msg     AS tagMSG
  LOCAL szClass AS ASCIIZ * 32
  '
  szClass = "GLSphereBoxClass"

  wc.cbSize        = SIZEOF(wc)
  wc.style         = %CS_HREDRAW OR %CS_VREDRAW OR %CS_OWNDC
  wc.lpfnWndProc   = CODEPTR(WndProc)
  wc.cbClsExtra    = 0
  wc.cbWndExtra    = 0
  wc.hInstance     = hInstance
  wc.hIcon         = LoadIcon(%NULL, BYVAL %IDI_APPLICATION)
  wc.hCursor       = LoadCursor(%NULL, BYVAL %IDC_ARROW)
  wc.hbrBackground = 0
  wc.lpszMenuName  = %NULL
  wc.lpszClassName = VARPTR(szClass)
  wc.hIconSm       = wc.hIcon

  RegisterClassEx wc
  '
   ghWnd = CreateWindowEx(0, szClass, "PowerBasic OpenGL - Transparent Box, 100 Spheres (R/G/B)", _
                          %WS_OVERLAPPEDWINDOW, 100, 100, 900, 700, _
                          %NULL, %NULL, hInstance, BYVAL %NULL)

  ShowWindow ghWnd, iCmdShow
  UpdateWindow ghWnd
  '
  SetTimer ghWnd, 1, 16, BYVAL %NULL   ' ~60 fps render tick
  '
  DO WHILE GetMessage(msg, %NULL, 0, 0)
    TranslateMessage msg
    DispatchMessage msg
  LOOP
  '
  FUNCTION = msg.wParam
END FUNCTION
'
FUNCTION WndProc (BYVAL hWnd AS DWORD, BYVAL wMsg AS DWORD, BYVAL wParam AS DWORD, BYVAL lParam AS DWORD) AS LONG

  LOCAL pfd    AS PIXELFORMATDESCRIPTOR
  LOCAL nPixFmt AS LONG
  LOCAL cw, ch AS LONG
  LOCAL ps AS PAINTSTRUCT
  '
  SELECT CASE wMsg
    '
    CASE %WM_CREATE
      RANDOMIZE TIMER
      subInitSphereData
      ghDC = GetDC(hWnd)
      '
      pfd.nSize      = SIZEOF(pfd)
      pfd.nVersion   = 1
      pfd.dwFlags    = %PFD_DRAW_TO_WINDOW OR %PFD_SUPPORT_OPENGL OR %PFD_DOUBLEBUFFER
      pfd.iPixelType = %PFD_TYPE_RGBA
      pfd.cColorBits = 32
      pfd.cDepthBits = 24
      pfd.cAlphaBits = 8
      pfd.iLayerType = %PFD_MAIN_PLANE
      '
      nPixFmt = ChoosePixelFormat(ghDC, pfd)
      SetPixelFormat ghDC, nPixFmt, pfd
      '
      ghRC = wglCreateContext(ghDC)
      wglMakeCurrent ghDC, ghRC
      '
      glEnable %GL_DEPTH_TEST
      glShadeModel %GL_SMOOTH
      glClearColor 0.05, 0.05, 0.08, 1.0
      '
      FUNCTION = 0
      EXIT FUNCTION
      '
    CASE %WM_SIZE
      cw = LO(WORD, lParam)
      ch = HI(WORD, lParam)
      IF ch = 0 THEN ch = 1
      wglMakeCurrent ghDC, ghRC
      glViewport 0, 0, cw, ch
      glMatrixMode %GL_PROJECTION
      glLoadIdentity
      gluPerspective 45.0, cw / (ch * 1.0), 0.5, 100.0
      glMatrixMode %GL_MODELVIEW
      glLoadIdentity
      FUNCTION = 0
      EXIT FUNCTION
      '
    CASE %WM_TIMER
    ' timer tiggered
    ' advance angle
      gAngle = gAngle + 0.6
      ' reset angle if >= 360
      IF gAngle >= 360 THEN gAngle = gAngle - 360
      ' ensure area is repainted
      ' triggering %WM_PAINT
      InvalidateRect hWnd, BYVAL %NULL, 0
      FUNCTION = 0
      EXIT FUNCTION
      '
    CASE %WM_PAINT
     ' repaint the scene
      BeginPaint hWnd, ps
      subRenderScene()
      SwapBuffers ghDC
      EndPaint hWnd, ps
      FUNCTION = 0
      EXIT FUNCTION
      '
    CASE %WM_KEYDOWN
      ' post close msg if ESC keypress
      IF wParam = %VK_ESCAPE THEN
        PostMessage hWnd, %WM_CLOSE, 0, 0
      END IF
      FUNCTION = 0
      EXIT FUNCTION
      '
    CASE %WM_DESTROY
      ' stop timer if window closing
      KillTimer hWnd, 1
      '
      PostQuitMessage 0
      FUNCTION = 0
      EXIT FUNCTION
      '
  END SELECT
  '
  FUNCTION = DefWindowProc(hWnd, wMsg, wParam, lParam)
END FUNCTION
'
SUB subInitSphereData()
' initialise the sphere data
' random positions and colour
  LOCAL lngS AS LONG              ' sphere counter
  LOCAL lngColourPick AS LONG     ' colour selected
  LOCAL sngMargin AS SINGLE       ' box margin
  ' set up the arrays
  REDIM a_sphX(1 TO %NUM_SPHERES)
  REDIM a_sphY(1 TO %NUM_SPHERES)
  REDIM a_sphZ(1 TO %NUM_SPHERES)
  REDIM a_sphR(1 TO %NUM_SPHERES)
  REDIM a_sphCR(1 TO %NUM_SPHERES)
  REDIM a_sphCG(1 TO %NUM_SPHERES)
  REDIM a_sphCB(1 TO %NUM_SPHERES)
  '
  sngMargin = 0.6   ' keep spheres away from the box walls
  '
  FOR lngS = 1 TO %NUM_SPHERES
  ' for each sphere
    a_sphX(lngS) = (RND * 2.0 - 1.0) * (%BOX_LIMIT - sngMargin)
    a_sphY(lngS) = (RND * 2.0 - 1.0) * (%BOX_LIMIT - sngMargin)
    a_sphZ(lngS) = (RND * 2.0 - 1.0) * (%BOX_LIMIT - sngMargin)
    a_sphR(lngS) = 0.18 + RND * 0.22          ' radius 0.18 - 0.40
    '
    ' randomly select a colour
    lngColourPick = RND(0,2)   ' 0, 1, or 2
    SELECT CASE lngColourPick
      CASE 0   ' Red
        a_sphCR(lngS) = 1.0
        a_sphCG(lngS) = 0.1
        a_sphCB(lngS) = 0.1
      CASE 1   ' Green
        a_sphCR(lngS) = 0.1
        a_sphCG(lngS) = 1.0
        a_sphCB(lngS) = 0.1
      CASE ELSE ' Blue
        a_sphCR(lngS) = 0.15
        a_sphCG(lngS) = 0.15
        a_sphCB(lngS) = 1.0
    END SELECT
  '
  NEXT lngS
  '
END SUB
'
SUB subDrawGradientSphere(BYVAL cx AS SINGLE, _
                          BYVAL cy AS SINGLE, _
                          BYVAL cz AS SINGLE, _
                          BYVAL radius AS SINGLE, _
                          BYVAL slices AS LONG, _
                          BYVAL stacks AS LONG, _
                          BYVAL rTop AS SINGLE, _
                          BYVAL gTop AS SINGLE, _
                          BYVAL bTop AS SINGLE, _
                          BYVAL rBot AS SINGLE, _
                          BYVAL gBot AS SINGLE, _
                          BYVAL bBot AS SINGLE, _
                          BYVAL alpha AS SINGLE)
  ' draw the gradient filled sphere
  ' cx,cy,cz       - sphere centre
  ' radius         - sphere radius
  ' slices         - subdivisions around the equator (longitude)
  ' stacks         - subdivisions from pole to pole (latitude)
  ' rTop/gTop/bTop - colour at the very top of the sphere
  ' rBot/gBot/bBot - colour at the very bottom of the sphere
  ' alpha          - constant alpha applied to every vertex
  '
  ' Since GL_SMOOTH shading is enabled, OpenGL interpolates colour smoothly
  ' across every band, producing a continuous top-to-bottom gradient fill
  ' rather than one flat colour per sphere.
  '
  LOCAL lngStack, lngSlice AS LONG
  LOCAL lat0, lat1 AS DOUBLE   ' latitude angle, -PI/2 (south pole) to +PI/2 (north pole)
  LOCAL lon        AS DOUBLE
  LOCAL x0, y0, z0 AS DOUBLE
  LOCAL x1, y1, z1 AS DOUBLE
  LOCAL t0, t1     AS SINGLE   ' 0.0 at bottom .. 1.0 at top
  LOCAL c0r, c0g, c0b AS SINGLE
  LOCAL c1r, c1g, c1b AS SINGLE
  LOCAL pi AS DOUBLE
  '
  pi = 3.14159265358979
  '
  FOR lngStack = 0 TO stacks - 1

    lat0 = pi * (-0.5 + (lngStack / stacks))
    lat1 = pi * (-0.5 + ((lngStack + 1) / stacks))

    ' fraction of height (0=bottom pole, 1=top pole) drives the gradient
    t0 = (SIN(lat0) + 1.0) / 2.0
    t1 = (SIN(lat1) + 1.0) / 2.0
    '
    c0r = rBot + (rTop - rBot) * t0
    c0g = gBot + (gTop - gBot) * t0
    c0b = bBot + (bTop - bBot) * t0
    c1r = rBot + (rTop - rBot) * t1
    c1g = gBot + (gTop - gBot) * t1
    c1b = bBot + (bTop - bBot) * t1
     '
    glBegin %GL_QUAD_STRIP
     '
    FOR lngSlice = 0 TO slices
    ' for each slice
      lon = 2.0 * pi * (lngSlice / slices)
      '
      x0 = COS(lat0) * COS(lon)
      y0 = SIN(lat0)
      z0 = COS(lat0) * SIN(lon)
      x1 = COS(lat1) * COS(lon)
      y1 = SIN(lat1)
      z1 = COS(lat1) * SIN(lon)
      '
      glColor4f c0r, c0g, c0b, alpha
      glVertex3f cx + radius * x0, cy + radius * y0, cz + radius * z0
      '
      glColor4f c1r, c1g, c1b, alpha
      glVertex3f cx + radius * x1, cy + radius * y1, cz + radius * z1
      '
    NEXT lngSlice
    '
    glEnd
    '
  NEXT lngStack
  '
END SUB
'
SUB subRenderScene
' render the scene, rotate and display spheres
  LOCAL lngS AS LONG   ' sphere counter
  '
  wglMakeCurrent ghDC, ghRC
  '
  glClear %GL_COLOR_BUFFER_BIT OR %GL_DEPTH_BUFFER_BIT
  glLoadIdentity
  glTranslatef 0.0, 0.0, -18.0
  glRotatef gAngle, 0.3, 1.0, 0.15
  glRotatef gAngle * 0.4, 1.0, 0.0, 0.0
  '
  ' ---- Opaque pass: solid spheres, depth writes on ----
  glDisable %GL_BLEND
  glDepthMask 1
  FOR lngS = 1 TO %NUM_SPHERES
  ' Top of each sphere is a lightened tint of its base colour,
  ' bottom is a deepened/darkened tint -> smooth gradient fill.
     subDrawGradientSphere( _
        a_sphX(lngS), a_sphY(lngS), a_sphZ(lngS), a_sphR(lngS), 20, 16, _
        a_sphCR(lngS) + (1.0 - a_sphCR(lngS)) * 0.70, _
        a_sphCG(lngS) + (1.0 - a_sphCG(lngS)) * 0.70, _
        a_sphCB(lngS) + (1.0 - a_sphCB(lngS)) * 0.70, _
        a_sphCR(lngS) * 0.30, a_sphCG(lngS) * 0.30, _
        a_sphCB(lngS) * 0.30, 1.0)
  NEXT lngS
  '
  ' ---- Transparent pass: glass box, depth writes off so it blends ----
  glEnable %GL_BLEND
  glBlendFunc %GL_SRC_ALPHA, %GL_ONE_MINUS_SRC_ALPHA
  glDepthMask 0
  glDisable %GL_CULL_FACE
  '
  glColor4f 0.5, 0.8, 1.0, 0.18    ' pale, semi-transparent glass tint
  subDrawBoxFaces()
   '
  glDepthMask 1
  glDisable %GL_BLEND
  '
  ' ---- Wireframe edges on top so the box shape reads clearly ----
  glColor4f 0.9, 0.95, 1.0, 0.9
  glLineWidth 1.5
  '
  subDrawBoxEdges()
  '
  glFlush
  '
END SUB'
SUB subDrawBoxFaces
' draw the 6 box faces
  LOCAL sngH AS SINGLE
  sngH = %BOX_LIMIT
  '
  glBegin %GL_QUADS
  '
  ' Front  (z = +sngH)
  PREFIX "glVertex3f "
    -sngH, -sngH,  sngH
     sngH, -sngH,  sngH
     sngH,  sngH,  sngH
    -sngH,  sngH,  sngH
  END PREFIX
  '
  ' Back   (z = -sngH)
  PREFIX "glVertex3f "
    -sngH, -sngH, -sngH
    -sngH,  sngH, -sngH
     sngH,  sngH, -sngH
     sngH, -sngH, -sngH
  END PREFIX
  '
  ' Left   (x = -sngH)
  PREFIX "glVertex3f "
    -sngH, -sngH, -sngH
    -sngH, -sngH,  sngH
    -sngH,  sngH,  sngH
    -sngH,  sngH, -sngH
   END PREFIX
  '
  ' Right  (x = +sngH)
  PREFIX "glVertex3f "
    sngH, -sngH, -sngH
    sngH,  sngH, -sngH
    sngH,  sngH,  sngH
    sngH, -sngH,  sngH
    END PREFIX
  '
  ' Top    (y = +sngH)
  PREFIX "glVertex3f "
    -sngH,  sngH, -sngH
    -sngH,  sngH,  sngH
     sngH,  sngH,  sngH
     sngH,  sngH, -sngH
  END PREFIX
  '
  ' Bottom (y = -sngH)
  PREFIX "glVertex3f "
    -sngH, -sngH, -sngH
     sngH, -sngH, -sngH
     sngH, -sngH,  sngH
    -sngH, -sngH,  sngH
  END PREFIX
  '
  glEnd
  '
END SUB
'
SUB subDrawBoxEdges
' draw the 12 edges of the box
  LOCAL sngH AS SINGLE
  sngH = %BOX_LIMIT
  '
  glBegin %GL_LINES
  '
  ' bottom face
  PREFIX "glVertex3f "
    -sngH,-sngH,-sngH
     sngH,-sngH,-sngH
     sngH,-sngH,-sngH
     sngH,-sngH, sngH
     sngH,-sngH, sngH
    -sngH,-sngH, sngH
    -sngH,-sngH, sngH
    -sngH,-sngH,-sngH
  END PREFIX
  '
  ' top face
  PREFIX "glVertex3f "
    -sngH, sngH,-sngH
     sngH, sngH,-sngH
     sngH, sngH,-sngH
     sngH, sngH, sngH
     sngH, sngH, sngH
    -sngH, sngH, sngH
    -sngH, sngH, sngH
    -sngH, sngH,-sngH
  END PREFIX
  '
  ' verticals
  PREFIX "glVertex3f "
    -sngH,-sngH,-sngH
    -sngH, sngH,-sngH
     sngH,-sngH,-sngH
     sngH, sngH,-sngH
     sngH,-sngH, sngH
     sngH, sngH, sngH
    -sngH,-sngH, sngH
    -sngH, sngH, sngH
  END PREFIX
  '
  glEnd
  '
END SUB
