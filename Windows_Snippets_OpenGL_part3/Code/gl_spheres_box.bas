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
GLOBAL gAngle   AS SINGLE     ' Angle
GLOBAL glngBondCount AS LONG  ' bond count
'
' list molecules supported
%Benzene = 1
%Trichlorophenol = 2
%Caffeine = 3
'
' select the molecule to be displayed
'%MoleculeSelected = %Benzene
'%MoleculeSelected = %Trichlorophenol
%MoleculeSelected = %Caffeine
'
' number of atoms variables
GLOBAL g_lngNUM_CARBON AS LONG
GLOBAL g_lngNUM_HYDROGEN AS LONG
GLOBAL g_lngNUM_ATOMS AS LONG
GLOBAL g_lngNUM_BONDS AS LONG
'
GLOBAL ga_atomX()  AS SINGLE   ' x,y & Z co-ordinate arrays
GLOBAL ga_atomY()  AS SINGLE
GLOBAL ga_atomZ()  AS SINGLE
GLOBAL ga_atomR()  AS SINGLE   ' sphere radius (deliberately large -> overlap)
GLOBAL ga_atomCR() AS SINGLE   ' base colour, red component
GLOBAL ga_atomCG() AS SINGLE   ' base colour, green component
GLOBAL ga_atomCB() AS SINGLE   ' base colour, blue component
'
GLOBAL ga_bondA()  AS LONG     ' bond list: atom index at one end...
GLOBAL ga_bondB()  AS LONG     ' ...and atom index at the other end
'
' Molecular geometry
GLOBAL g_sngCC_BOND_LEN AS SINGLE     ' carbon-carbon ring bond length
GLOBAL g_sngCH_BOND_LEN AS SINGLE     ' carbon-hydrogen bond length
GLOBAL g_sngCO_BOND_LEN  AS SINGLE    ' carbon-oxygen bond length (phenolic C-O)
GLOBAL g_sngOH_BOND_LEN  AS SINGLE    ' oxygen-hydrogen bond length
GLOBAL g_sngCCL_BOND_LEN AS SINGLE    ' carbon-chlorine bond length
GLOBAL g_sngCO_DOUBLE_LEN AS SINGLE   ' carbonyl C=O bond length
GLOBAL g_sngCN_METHYL_LEN AS SINGLE   ' bond length from a ring N out to its methyl carbon

' radius of atoms
GLOBAL g_sngCARBON_RADIUS   AS SINGLE ' sphere radius for carbon atoms (overlaps neighbours)
GLOBAL g_sngHYDROGEN_RADIUS AS SINGLE ' sphere radius for hydrogen atoms (overlaps its carbon)
GLOBAL g_sngOXYGEN_RADIUS   AS SINGLE ' sphere radius for oxygen atoms
GLOBAL g_sngCHLORINE_RADIUS AS SINGLE ' sphere radius for chlorine atoms
GLOBAL g_sngNITROGEN_RADIUS AS SINGLE ' sphere radius for Nitrogen atoms
'
' Tetrahedral-angle terms used to splay the 3 H's of each methyl group
' (cos/sin of 109.47 degrees)
GLOBAL g_sngTETRA_COS AS SINGLE
GLOBAL g_sngTETRA_SIN AS SINGLE
'
' additional globals for Caffine molecule
GLOBAL g_lngIDX_N1, g_lngIDX_C2,g_lngIDX_N3 AS LONG
GLOBAL g_lngIDX_C4,g_lngIDX_C5,g_lngIDX_C6 AS LONG
GLOBAL g_lngIDX_N7,g_lngIDX_C8,g_lngIDX_N9 AS LONG
GLOBAL g_lngIDX_O2,g_lngIDX_O6 AS LONG
GLOBAL g_lngIDX_C1M,g_lngIDX_C3M,g_lngIDX_C7M AS LONG
GLOBAL g_lngIDX_H8,g_lngIDX_H1M_START,g_lngIDX_H3M_START AS LONG
GLOBAL g_lngIDX_H7M_START AS LONG
'
SUB subInitPhysicalConstants()
' setup the inital constants for atoms
  '
  g_sngCC_BOND_LEN  = 1.40
  g_sngCH_BOND_LEN  = 1.09
  g_sngCO_DOUBLE_LEN = 1.22
  g_sngCN_METHYL_LEN = 1.47
  '
  g_sngCO_BOND_LEN  = 1.36
  g_sngOH_BOND_LEN  = 0.96
  g_sngCCL_BOND_LEN = 1.74
  '
  g_sngCARBON_RADIUS   = 0.85
  g_sngHYDROGEN_RADIUS = 0.45
  g_sngOXYGEN_RADIUS   = 0.70
  g_sngCHLORINE_RADIUS = 1.00
  g_sngNITROGEN_RADIUS = 0.75
  '
  g_sngTETRA_COS = -0.333333
  g_sngTETRA_SIN = 0.942809
  '
END SUB
'
FUNCTION WINMAIN (BYVAL hInstance AS DWORD, _
                  BYVAL hPrevInstance AS DWORD, _
                  BYVAL lpCmdLine AS ASCIIZ PTR, _
                  BYVAL iCmdShow AS LONG) AS LONG
' first function called when app executes
  LOCAL wc      AS WNDCLASSEX
  LOCAL msg     AS tagMSG
  LOCAL szClass AS ASCIIZ * 32
  '
  ' set the sizes of atoms
  subInitPhysicalConstants
  '
  szClass = "GLMoleculeClass"
  '
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
  ghWnd = CreateWindowEx(0, szClass, "PowerBasic OpenGL - Moleculer Modeller", _
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
' event handler
  LOCAL pfd    AS PIXELFORMATDESCRIPTOR
  LOCAL nPixFmt AS LONG
  LOCAL cw, ch AS LONG
  LOCAL ps AS PAINTSTRUCT
  '
  SELECT CASE wMsg
    '
    CASE %WM_CREATE
      RANDOMIZE TIMER
      subInitialiseMolecule()
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
      IF gAngle >= 360 THEN gAngle = 0
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
SUB subInitialiseMolecule()
' prep for the molecule selected
  SELECT CASE %MoleculeSelected
    CASE %Benzene
      subInitBenzeneMolecule()
    CASE %Trichlorophenol
      subInitTCPMolecule()
    CASE %Caffeine
      subInitCaffeineMolecule
  END SELECT
END SUB
'
SUB subInitCaffeineMolecule()
' initialise caffine molecule
  LOCAL i    AS LONG
  LOCAL ang  AS DOUBLE
  LOCAL pi   AS DOUBLE
  LOCAL px, pz AS DOUBLE
  '
  LOCAL dx, dz, edgeLen AS DOUBLE
  LOCAL ux, uz AS DOUBLE
  LOCAL ox1, oz1, ox2, oz2 AS DOUBLE
  LOCAL ox, oz AS DOUBLE
  LOCAL midX, midZ AS DOUBLE
  LOCAL dot1, dot2 AS DOUBLE
  LOCAL tan36, sin36 AS DOUBLE
  LOCAL pentApothem, pentR AS DOUBLE
  LOCAL centerLx, centerLy AS DOUBLE
  LOCAL pentCenterWorldX, pentCenterWorldZ AS DOUBLE
  LOCAL Lx, Ly AS DOUBLE
  LOCAL dirX, dirZ AS DOUBLE
  '
  pi = 3.14159265358979
  '
  g_lngNUM_ATOMS = 24   ' 8 C + 10 H + 4 N + 2 O
  g_lngNUM_BONDS = 25   ' 6 ring + 4 fused-ring + 2 C=O + 3 C-N(methyl) + 1 C-H(ring) + 9 methyl C-H
  '
  ' ---- Caffeine (C8H10N4O2) atom layout ------------------------------------
  ' Atom index map (filled in by InitCaffeineMolecule):
  '   1 N1   2 C2   3 N3   4 C4   5 C5   6 C6      six-membered ring
  '   7 N7   8 C8   9 N9                           fused five-membered ring
  '   10 O2 (=C2)   11 O6 (=C6)                    carbonyl oxygens
  '   12 C1M (methyl on N1)  13 C3M (methyl on N3)  14 C7M (methyl on N7)
  '   15 H8 (ring hydrogen on C8)
  '   16-18 methyl H's on C1M, 19-21 on C3M, 22-24 on C7M

  '
  g_lngIDX_N1 = 1  : g_lngIDX_C2 = 2  : g_lngIDX_N3 = 3
  g_lngIDX_C4 = 4  : g_lngIDX_C5 = 5  : g_lngIDX_C6 = 6
  g_lngIDX_N7 = 7  : g_lngIDX_C8 = 8  : g_lngIDX_N9 = 9
  g_lngIDX_O2 = 10 : g_lngIDX_O6 = 11
  g_lngIDX_C1M = 12 : g_lngIDX_C3M = 13 : g_lngIDX_C7M = 14
  g_lngIDX_H8  = 15
  g_lngIDX_H1M_START = 16
  g_lngIDX_H3M_START = 19
  g_lngIDX_H7M_START = 22
  '
  REDIM ga_atomX(1 TO g_lngNUM_ATOMS)
  REDIM ga_atomY(1 TO g_lngNUM_ATOMS)
  REDIM ga_atomZ(1 TO g_lngNUM_ATOMS)
  REDIM ga_atomR(1 TO g_lngNUM_ATOMS)
  REDIM ga_atomCR(1 TO g_lngNUM_ATOMS)
  REDIM ga_atomCG(1 TO g_lngNUM_ATOMS)
  REDIM ga_atomCB(1 TO g_lngNUM_ATOMS)
  REDIM ga_bondA(1 TO g_lngNUM_BONDS)
  REDIM ga_bondB(1 TO g_lngNUM_BONDS)
  '
  glngBondCount = 0
  '
  ' ================= Six-membered pyrimidinedione ring =================
  ' Order around the ring: N1, C2, N3, C4, C5, C6 (60 degrees apart)
  FOR i = 0 TO 5
    ang = pi * (90.0 + 60.0 * i) / 180.0
    px = g_sngCC_BOND_LEN * COS(ang)
    pz = g_sngCC_BOND_LEN * SIN(ang)
    ga_atomX(i + 1) = px
    ga_atomY(i + 1) = 0.0
    ga_atomZ(i + 1) = pz
  NEXT i
  '
  ga_atomR(g_lngIDX_N1) = g_sngNITROGEN_RADIUS
  ga_atomCR(g_lngIDX_N1) = 0.20
  ga_atomCG(g_lngIDX_N1) = 0.20
  ga_atomCB(g_lngIDX_N1) = 0.90
  ga_atomR(g_lngIDX_C2) = g_sngCARBON_RADIUS
  ga_atomCR(g_lngIDX_C2) = 0.22
  ga_atomCG(g_lngIDX_C2) = 0.22
  ga_atomCB(g_lngIDX_C2) = 0.24
  ga_atomR(g_lngIDX_N3) = g_sngNITROGEN_RADIUS
  ga_atomCR(g_lngIDX_N3) = 0.20
  ga_atomCG(g_lngIDX_N3) = 0.20
  ga_atomCB(g_lngIDX_N3) = 0.90
  ga_atomR(g_lngIDX_C4) = g_sngCARBON_RADIUS
  ga_atomCR(g_lngIDX_C4) = 0.22
  ga_atomCG(g_lngIDX_C4) = 0.22
  ga_atomCB(g_lngIDX_C4) = 0.24
  ga_atomR(g_lngIDX_C5) = g_sngCARBON_RADIUS
  ga_atomCR(g_lngIDX_C5) = 0.22
  ga_atomCG(g_lngIDX_C5) = 0.22
  ga_atomCB(g_lngIDX_C5) = 0.24
  ga_atomR(g_lngIDX_C6) = g_sngCARBON_RADIUS
  ga_atomCR(g_lngIDX_C6) = 0.22
  ga_atomCG(g_lngIDX_C6) = 0.22
  ga_atomCB(g_lngIDX_C6) = 0.24
  '
  INCR glngBondCount
  ga_bondA(glngBondCount) = g_lngIDX_N1
  ga_bondB(glngBondCount) = g_lngIDX_C2
  '
  INCR glngBondCount
  ga_bondA(glngBondCount) = g_lngIDX_C2
  ga_bondB(glngBondCount) = g_lngIDX_N3
  '
  INCR glngBondCount
  ga_bondA(glngBondCount) = g_lngIDX_N3
  ga_bondB(glngBondCount) = g_lngIDX_C4
  '
  INCR glngBondCount
  ga_bondA(glngBondCount) = g_lngIDX_C4
  ga_bondB(glngBondCount) = g_lngIDX_C5
  '
  INCR glngBondCount
  ga_bondA(glngBondCount) = g_lngIDX_C5
  ga_bondB(glngBondCount) = g_lngIDX_C6
  '
  INCR glngBondCount
  ga_bondA(glngBondCount) = g_lngIDX_C6
  ga_bondB(glngBondCount) = g_lngIDX_N1
  '
  ' ================= Fused five-membered imidazole ring =================
  ' Shares the C4-C5 edge; N7, C8, N9 come from a regular pentagon built
  ' on that edge, bulging away from the six-ring centre.
  dx = ga_atomX(g_lngIDX_C5) - ga_atomX(g_lngIDX_C4)
  dz = ga_atomZ(g_lngIDX_C5) - ga_atomZ(g_lngIDX_C4)
  edgeLen = SQR(dx * dx + dz * dz)
  ux = dx / edgeLen : uz = dz / edgeLen ' unit vector along the shared edge
  '
  midX = (ga_atomX(g_lngIDX_C4) + ga_atomX(g_lngIDX_C5)) / 2.0
  midZ = (ga_atomZ(g_lngIDX_C4) + ga_atomZ(g_lngIDX_C5)) / 2.0
  '
  ox1 = -uz : oz1 = ux
  ox2 = uz  : oz2 = -ux
  dot1 = ox1 * midX + oz1 * midZ
  dot2 = ox2 * midX + oz2 * midZ
  IF dot1 > dot2 THEN
    ox = ox1
    oz = oz1
  ELSE
    ox = ox2
    oz = oz2
  END IF
  '
  tan36 = TAN(pi * 36.0 / 180.0)
  sin36 = SIN(pi * 36.0 / 180.0)
  pentApothem = edgeLen / (2.0 * tan36)
  pentR       = edgeLen / (2.0 * sin36)
  '
  centerLx = edgeLen / 2.0
  centerLy = pentApothem
  pentCenterWorldX = ga_atomX(g_lngIDX_C4) + centerLx * ux + centerLy * ox
  pentCenterWorldZ = ga_atomZ(g_lngIDX_C4) + centerLx * uz + centerLy * oz
  '
  ' N7 (adjacent to C5)
  Lx = centerLx + pentR * COS(pi * 18.0 / 180.0)
  Ly = centerLy + pentR * SIN(pi * 18.0 / 180.0)
  ga_atomX(g_lngIDX_N7) = ga_atomX(g_lngIDX_C4) + Lx * ux + Ly * ox
  ga_atomZ(g_lngIDX_N7) = ga_atomZ(g_lngIDX_C4) + Lx * uz + Ly * oz
  ga_atomY(g_lngIDX_N7) = 0.0
  ga_atomR(g_lngIDX_N7) = g_sngNITROGEN_RADIUS
  ga_atomCR(g_lngIDX_N7) = 0.20
  ga_atomCG(g_lngIDX_N7) = 0.20
  ga_atomCB(g_lngIDX_N7) = 0.90
  '
  ' C8 (apex, carries the ring H)
  Lx = centerLx + pentR * COS(pi * 90.0 / 180.0)
  Ly = centerLy + pentR * SIN(pi * 90.0 / 180.0)
  ga_atomX(g_lngIDX_C8) = ga_atomX(g_lngIDX_C4) + Lx * ux + Ly * ox
  ga_atomZ(g_lngIDX_C8) = ga_atomZ(g_lngIDX_C4) + Lx * uz + Ly * oz
  ga_atomY(g_lngIDX_C8) = 0.0
  ga_atomR(g_lngIDX_C8) = g_sngCARBON_RADIUS
  ga_atomCR(g_lngIDX_C8) = 0.22
  ga_atomCG(g_lngIDX_C8) = 0.22
  ga_atomCB(g_lngIDX_C8) = 0.24
  '
  ' N9 (adjacent to C4)
  Lx = centerLx + pentR * COS(pi * 162.0 / 180.0)
  Ly = centerLy + pentR * SIN(pi * 162.0 / 180.0)
  ga_atomX(g_lngIDX_N9) = ga_atomX(g_lngIDX_C4) + Lx * ux + Ly * ox
  ga_atomZ(g_lngIDX_N9) = ga_atomZ(g_lngIDX_C4) + Lx * uz + Ly * oz
  ga_atomY(g_lngIDX_N9) = 0.0
  ga_atomR(g_lngIDX_N9) = g_sngNITROGEN_RADIUS
  ga_atomCR(g_lngIDX_N9) = 0.20
  ga_atomCG(g_lngIDX_N9) = 0.20
  ga_atomCB(g_lngIDX_N9) = 0.90

  INCR glngBondCount
  ga_bondA(glngBondCount) = g_lngIDX_C5
  ga_bondB(glngBondCount) = g_lngIDX_N7
  '
  INCR glngBondCount
  ga_bondA(glngBondCount) = g_lngIDX_N7
  ga_bondB(glngBondCount) = g_lngIDX_C8
  '
  INCR glngBondCount
  ga_bondA(glngBondCount) = g_lngIDX_C8
  ga_bondB(glngBondCount) = g_lngIDX_N9
  '
  INCR glngBondCount
  ga_bondA(glngBondCount) = g_lngIDX_N9
  ga_bondB(glngBondCount) = g_lngIDX_C4
  '
  ' ================= Carbonyl oxygens: C2=O2, C6=O6 =================
  dirX = ga_atomX(g_lngIDX_C2) / g_sngCC_BOND_LEN
  dirZ = ga_atomZ(g_lngIDX_C2) / g_sngCC_BOND_LEN
  ga_atomX(g_lngIDX_O2) = ga_atomX(g_lngIDX_C2) + g_sngCO_DOUBLE_LEN * dirX
  ga_atomZ(g_lngIDX_O2) = ga_atomZ(g_lngIDX_C2) + g_sngCO_DOUBLE_LEN * dirZ
  ga_atomY(g_lngIDX_O2) = 0.0
  ga_atomR(g_lngIDX_O2) = g_sngOXYGEN_RADIUS
  ga_atomCR(g_lngIDX_O2) = 0.85
  ga_atomCG(g_lngIDX_O2) = 0.10
  ga_atomCB(g_lngIDX_O2) = 0.10
  INCR glngBondCount
  ga_bondA(glngBondCount) = g_lngIDX_C2
  ga_bondB(glngBondCount) = g_lngIDX_O2

  dirX = ga_atomX(g_lngIDX_C6) / g_sngCC_BOND_LEN
  dirZ = ga_atomZ(g_lngIDX_C6) / g_sngCC_BOND_LEN
  ga_atomX(g_lngIDX_O6) = ga_atomX(g_lngIDX_C6) + g_sngCO_DOUBLE_LEN * dirX
  ga_atomZ(g_lngIDX_O6) = ga_atomZ(g_lngIDX_C6) + g_sngCO_DOUBLE_LEN * dirZ
  ga_atomY(g_lngIDX_O6) = 0.0
  ga_atomR(g_lngIDX_O6) = g_sngOXYGEN_RADIUS
  ga_atomCR(g_lngIDX_O6) = 0.85
  ga_atomCG(g_lngIDX_O6) = 0.10
  ga_atomCB(g_lngIDX_O6) = 0.10
  INCR glngBondCount
  ga_bondA(glngBondCount) = g_lngIDX_C6
  ga_bondB(glngBondCount) = g_lngIDX_O6

  ' ================= N-methyl groups on N1, N3, N7 =================
  dirX = ga_atomX(g_lngIDX_N1) / g_sngCC_BOND_LEN
  dirZ = ga_atomZ(g_lngIDX_N1) / g_sngCC_BOND_LEN
  ga_atomX(g_lngIDX_C1M) = ga_atomX(g_lngIDX_N1) + g_sngCN_METHYL_LEN * dirX
  ga_atomZ(g_lngIDX_C1M) = ga_atomZ(g_lngIDX_N1) + g_sngCN_METHYL_LEN * dirZ
  ga_atomY(g_lngIDX_C1M) = 0.0
  ga_atomR(g_lngIDX_C1M) = g_sngCARBON_RADIUS
  ga_atomCR(g_lngIDX_C1M) = 0.22
  ga_atomCG(g_lngIDX_C1M) = 0.22
  ga_atomCB(g_lngIDX_C1M) = 0.24
  INCR glngBondCount
  ga_bondA(glngBondCount) = g_lngIDX_N1
  ga_bondB(glngBondCount) = g_lngIDX_C1M
  '
  dirX = ga_atomX(g_lngIDX_N3) / g_sngCC_BOND_LEN
  dirZ = ga_atomZ(g_lngIDX_N3) / g_sngCC_BOND_LEN
  ga_atomX(g_lngIDX_C3M) = ga_atomX(g_lngIDX_N3) + g_sngCN_METHYL_LEN * dirX
  ga_atomZ(g_lngIDX_C3M) = ga_atomZ(g_lngIDX_N3) + g_sngCN_METHYL_LEN * dirZ
  ga_atomY(g_lngIDX_C3M) = 0.0
  ga_atomR(g_lngIDX_C3M) = g_sngCARBON_RADIUS
  ga_atomCR(g_lngIDX_C3M) = 0.22
  ga_atomCG(g_lngIDX_C3M) = 0.22
  ga_atomCB(g_lngIDX_C3M) = 0.24
  INCR glngBondCount
  ga_bondA(glngBondCount) = g_lngIDX_N3
  ga_bondB(glngBondCount) = g_lngIDX_C3M

  ' N7's methyl direction is measured from the FIVE-ring centre, not the six-ring
  dirX = (ga_atomX(g_lngIDX_N7) - pentCenterWorldX) / pentR
  dirZ = (ga_atomZ(g_lngIDX_N7) - pentCenterWorldZ) / pentR
  ga_atomX(g_lngIDX_C7M) = ga_atomX(g_lngIDX_N7) + g_sngCN_METHYL_LEN * dirX
  ga_atomZ(g_lngIDX_C7M) = ga_atomZ(g_lngIDX_N7) + g_sngCN_METHYL_LEN * dirZ
  ga_atomY(g_lngIDX_C7M) = 0.0
  ga_atomR(g_lngIDX_C7M) = g_sngCARBON_RADIUS
  ga_atomCR(g_lngIDX_C7M) = 0.22
  ga_atomCG(g_lngIDX_C7M) = 0.22
  ga_atomCB(g_lngIDX_C7M) = 0.24
  INCR glngBondCount
  ga_bondA(glngBondCount) = g_lngIDX_N7
  ga_bondB(glngBondCount) = g_lngIDX_C7M

  ' ================= Ring hydrogen on C8 =================
  dirX = (ga_atomX(g_lngIDX_C8) - pentCenterWorldX) / pentR
  dirZ = (ga_atomZ(g_lngIDX_C8) - pentCenterWorldZ) / pentR
  ga_atomX(g_lngIDX_H8) = ga_atomX(g_lngIDX_C8) + g_sngCH_BOND_LEN * dirX
  ga_atomZ(g_lngIDX_H8) = ga_atomZ(g_lngIDX_C8) + g_sngCH_BOND_LEN * dirZ
  ga_atomY(g_lngIDX_H8) = 0.0
  ga_atomR(g_lngIDX_H8) = g_sngHYDROGEN_RADIUS
  ga_atomCR(g_lngIDX_H8) = 0.95
  ga_atomCG(g_lngIDX_H8) = 0.95
  ga_atomCB(g_lngIDX_H8) = 0.92
  INCR glngBondCount
  ga_bondA(glngBondCount) = g_lngIDX_C8
  ga_bondB(glngBondCount) = g_lngIDX_H8

  ' ================= Methyl hydrogens (3 per methyl, tetrahedral) =================
  subPlaceMethylHydrogens(ga_atomX(g_lngIDX_N1), ga_atomY(g_lngIDX_N1), ga_atomZ(g_lngIDX_N1), _
                          ga_atomX(g_lngIDX_C1M), ga_atomY(g_lngIDX_C1M), ga_atomZ(g_lngIDX_C1M), _
                          g_lngIDX_H1M_START, g_lngIDX_C1M)

  subPlaceMethylHydrogens(ga_atomX(g_lngIDX_N3), ga_atomY(g_lngIDX_N3), ga_atomZ(g_lngIDX_N3), _
                          ga_atomX(g_lngIDX_C3M), ga_atomY(g_lngIDX_C3M), ga_atomZ(g_lngIDX_C3M), _
                          g_lngIDX_H3M_START, g_lngIDX_C3M)

  subPlaceMethylHydrogens(ga_atomX(g_lngIDX_N7), ga_atomY(g_lngIDX_N7), ga_atomZ(g_lngIDX_N7), _
                          ga_atomX(g_lngIDX_C7M), ga_atomY(g_lngIDX_C7M), ga_atomZ(g_lngIDX_C7M), _
                          g_lngIDX_H7M_START, g_lngIDX_C7M)
  '
END SUB
'
SUB subInitBenzeneMolecule
' initialise the benzene molecule
  LOCAL lngAtom AS LONG
  LOCAL ang   AS DOUBLE
  LOCAL pi    AS DOUBLE
  LOCAL cx, cz AS SINGLE   ' carbon x/z for this ring position
  LOCAL hx, hz AS SINGLE   ' hydrogen x/z for this ring position
  LOCAL ringHydrogenDist AS SINGLE
  '
  ' ---- Benzene molecule: 6 carbons (index 1-6) + 6 hydrogens (index 7-12) --
  ' Hydrogen atom (7..12) shares the same ring position index as its carbon
  ' (1..6), i.e. hydrogen (lngAtom+6) is bonded to carbon (lngAtom).
  g_lngNUM_CARBON = 6
  g_lngNUM_HYDROGEN = 6
  g_lngNUM_ATOMS = g_lngNUM_CARBON + g_lngNUM_HYDROGEN
  '
  pi = 3.14159265358979
  ringHydrogenDist = g_sngCC_BOND_LEN + g_sngCH_BOND_LEN
  '
  REDIM ga_atomX(1 TO g_lngNUM_ATOMS)
  REDIM ga_atomY(1 TO g_lngNUM_ATOMS)
  REDIM ga_atomZ(1 TO g_lngNUM_ATOMS)
  REDIM ga_atomR(1 TO g_lngNUM_ATOMS)
  REDIM ga_atomCR(1 TO g_lngNUM_ATOMS)
  REDIM ga_atomCG(1 TO g_lngNUM_ATOMS)
  REDIM ga_atomCB(1 TO g_lngNUM_ATOMS)
  '
  FOR lngAtom = 0 TO g_lngNUM_CARBON - 1
  ' for each of the atoms
    ang = 2.0 * pi * (lngAtom / g_lngNUM_CARBON)
    '
    cx = g_sngCC_BOND_LEN * COS(ang)
    cz = g_sngCC_BOND_LEN * SIN(ang)
    '
    ' ---- Carbon atom (ring position lngAtom+1) ----
    ga_atomX(lngAtom + 1) = cx
    ga_atomY(lngAtom + 1) = 0.0
    ga_atomZ(lngAtom + 1) = cz
    ga_atomR(lngAtom + 1) = g_sngCARBON_RADIUS
    ga_atomCR(lngAtom + 1) = 0.22
    ga_atomCG(lngAtom + 1) = 0.22
    ga_atomCB(lngAtom + 1) = 0.24   ' charcoal grey
    '
    ' ---- Hydrogen atom bonded to this carbon (index i+1+NUM_CARBON) ----
    hx = ringHydrogenDist * COS(ang)
    hz = ringHydrogenDist * SIN(ang)
    '
    ga_atomX(lngAtom + 1 + g_lngNUM_CARBON) = hx
    ga_atomY(lngAtom + 1 + g_lngNUM_CARBON) = 0.0
    ga_atomZ(lngAtom + 1 + g_lngNUM_CARBON) = hz
    ga_atomR(lngAtom + 1 + g_lngNUM_CARBON) = g_sngHYDROGEN_RADIUS
    ga_atomCR(lngAtom + 1 + g_lngNUM_CARBON) = 0.95
    ga_atomCG(lngAtom + 1 + g_lngNUM_CARBON) = 0.95
    ga_atomCB(lngAtom + 1 + g_lngNUM_CARBON) = 0.92  ' off-white
    '
  NEXT lngAtom
  '
END SUB
'
SUB subInitTCPMolecule()
' initalise TCP molecule
  LOCAL lngAtom  AS LONG
  LOCAL nc       AS LONG
  LOCAL ang      AS DOUBLE
  LOCAL pi       AS DOUBLE
  LOCAL cx, cz   AS SINGLE
  LOCAL nextIdx  AS LONG
  LOCAL bondCount AS LONG
  LOCAL oIdx, hIdx, clIdx AS LONG
  '
  g_lngNUM_CARBON = 6
  g_lngNUM_ATOMS  = 13   ' 6 C + 1 O + 2 H(ring+substituent H's: 2 ring H + 1 OH) + 3 Cl
  g_lngNUM_BONDS  = 13   ' 6 ring C-C bonds + 6 carbon-substituent bonds + 1 O-H bond
  '
  pi = 3.14159265358979
  '
  REDIM ga_atomX(1 TO g_lngNUM_ATOMS)
  REDIM ga_atomY(1 TO g_lngNUM_ATOMS)
  REDIM ga_atomZ(1 TO g_lngNUM_ATOMS)
  REDIM ga_atomR(1 TO g_lngNUM_ATOMS)
  REDIM ga_atomCR(1 TO g_lngNUM_ATOMS)
  REDIM ga_atomCG(1 TO g_lngNUM_ATOMS)
  REDIM ga_atomCB(1 TO g_lngNUM_ATOMS)
  REDIM ga_bondA(1 TO g_lngNUM_BONDS)
  REDIM ga_bondB(1 TO g_lngNUM_BONDS)

  ' ---- Ring carbons C1..C6 ----
  FOR lngAtom = 0 TO g_lngNUM_CARBON - 1
    ang = 2.0 * pi * (lngAtom / g_lngNUM_CARBON)
    cx = g_sngCC_BOND_LEN * COS(ang)
    cz = g_sngCC_BOND_LEN * SIN(ang)
     '
    ga_atomX(lngAtom + 1) = cx
    ga_atomY(lngAtom + 1) = 0.0
    ga_atomZ(lngAtom + 1) = cz
    ga_atomR(lngAtom + 1) = g_sngCARBON_RADIUS
    ga_atomCR(lngAtom + 1) = 0.22
    ga_atomCG(lngAtom + 1) = 0.22
    ga_atomCB(lngAtom + 1) = 0.24   ' charcoal grey
  NEXT lngAtom

  ' ---- Ring C-C bonds (C1-C2, C2-C3, ... C6-C1) ----
  bondCount = 0
  FOR lngAtom = 1 TO g_lngNUM_CARBON
    nc = lngAtom + 1
    IF nc > g_lngNUM_CARBON THEN nc = 1
    bondCount = bondCount + 1
    ga_bondA(bondCount) = lngAtom
    ga_bondB(bondCount) = nc
  NEXT lngAtom
  '
  ' ---- Substituents: one per carbon, per the 2,4,6-TCP substitution pattern ----
  nextIdx = g_lngNUM_CARBON + 1   ' first free atom slot (7)
  '
  FOR lngAtom = 0 TO g_lngNUM_CARBON - 1
    ' for each atom
    ang = 2.0 * pi * (lngAtom / g_lngNUM_CARBON)
    '
    SELECT CASE lngAtom
      '
      CASE 0   ' C1: hydroxyl group -O-H (the "phenol")
        oIdx = nextIdx : nextIdx = nextIdx + 1
        ga_atomX(oIdx) = (g_sngCC_BOND_LEN + g_sngCO_BOND_LEN) * COS(ang)
        ga_atomZ(oIdx) = (g_sngCC_BOND_LEN + g_sngCO_BOND_LEN) * SIN(ang)
        ga_atomY(oIdx) = 0.0
        ga_atomR(oIdx) = g_sngOXYGEN_RADIUS
        ga_atomCR(oIdx) = 0.85
        ga_atomCG(oIdx) = 0.10
        ga_atomCB(oIdx) = 0.10   ' red
        INCR bondCount
        ga_bondA(bondCount) = lngAtom + 1
        ga_bondB(bondCount) = oIdx
        '
        hIdx = nextIdx
        INCR nextIdx
        ga_atomX(hIdx) = (g_sngCC_BOND_LEN + g_sngCO_BOND_LEN + g_sngOH_BOND_LEN) * COS(ang)
        ga_atomZ(hIdx) = (g_sngCC_BOND_LEN + g_sngCO_BOND_LEN + g_sngOH_BOND_LEN) * SIN(ang)
        ga_atomY(hIdx) = 0.0
        ga_atomR(hIdx) = g_sngHYDROGEN_RADIUS
        ga_atomCR(hIdx) = 0.95
        ga_atomCG(hIdx) = 0.95
        ga_atomCB(hIdx) = 0.92   ' off-white
        INCR bondCount
        ga_bondA(bondCount) = oIdx
        ga_bondB(bondCount) = hIdx
        '
      CASE 1, 3, 5   ' C2, C4, C6: chlorine substituents
        clIdx = nextIdx
        INCR nextIdx
        ga_atomX(clIdx) = (g_sngCC_BOND_LEN + g_sngCCL_BOND_LEN) * COS(ang)
        ga_atomZ(clIdx) = (g_sngCC_BOND_LEN + g_sngCCL_BOND_LEN) * SIN(ang)
        ga_atomY(clIdx) = 0.0
        ga_atomR(clIdx) = g_sngCHLORINE_RADIUS
        ga_atomCR(clIdx) = 0.15
        ga_atomCG(clIdx) = 0.80
        ga_atomCB(clIdx) = 0.25   ' green
        INCR bondCount
        ga_bondA(bondCount) = lngAtom + 1
        ga_bondB(bondCount) = clIdx
          '
      CASE 2, 4   ' C3, C5: unchanged ring hydrogens
        hIdx = nextIdx
        INCR nextIdx
        ga_atomX(hIdx) = (g_sngCC_BOND_LEN + g_sngCH_BOND_LEN) * COS(ang)
        ga_atomZ(hIdx) = (g_sngCC_BOND_LEN + g_sngCH_BOND_LEN) * SIN(ang)
        ga_atomY(hIdx) = 0.0
        ga_atomR(hIdx) = g_sngHYDROGEN_RADIUS
        ga_atomCR(hIdx) = 0.95
        ga_atomCG(hIdx) = 0.95
        ga_atomCB(hIdx) = 0.92   ' off-white
        INCR bondCount
        ga_bondA(bondCount) = lngAtom + 1
        ga_bondB(bondCount) = hIdx
    '
    END SELECT
  '
  NEXT lngAtom
  '
END SUB
'
SUB subPlaceMethylHydrogens(BYVAL nx AS SINGLE, _
                            BYVAL ny AS SINGLE, _
                            BYVAL nz AS SINGLE, _
                            BYVAL cx AS SINGLE, _
                            BYVAL cy AS SINGLE, _
                            BYVAL cz AS SINGLE, _
                            BYVAL startIdx AS LONG, _
                            BYVAL parentIdx AS LONG)

  LOCAL dx, dz, dlen AS DOUBLE
  LOCAL ux, uz       AS DOUBLE
  LOCAL k            AS LONG
  LOCAL phi          AS DOUBLE
  LOCAL hx, hy, hz   AS DOUBLE
  LOCAL pi           AS DOUBLE
  LOCAL idx          AS LONG

  pi = 3.14159265358979

  ' u = unit vector from the methyl carbon toward its parent heteroatom;
  ' each C-H bond splays out at 109.47 deg from u, 120 deg apart in azimuth.
  dx = nx - cx : dz = nz - cz
  dlen = SQR(dx * dx + dz * dz)
  ux = dx / dlen : uz = dz / dlen

  FOR k = 0 TO 2
    phi = 2.0 * pi * k / 3.0

    hx = g_sngTETRA_COS * ux - g_sngTETRA_SIN * COS(phi) * uz
    hy = -g_sngTETRA_SIN * SIN(phi)
    hz = g_sngTETRA_COS * uz + g_sngTETRA_SIN * COS(phi) * ux

    idx = startIdx + k
    ga_atomX(idx) = cx + g_sngCH_BOND_LEN * hx
    ga_atomY(idx) = cy + g_sngCH_BOND_LEN * hy
    ga_atomZ(idx) = cz + g_sngCH_BOND_LEN * hz
    ga_atomR(idx) = g_sngHYDROGEN_RADIUS
    ga_atomCR(idx) = 0.95
    ga_atomCG(idx) = 0.95
    ga_atomCB(idx) = 0.92
    '
    INCR glngBondCount
    ga_bondA(glngBondCount) = parentIdx
    ga_bondB(glngBondCount) = idx
  NEXT k
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
' render the molecule
  LOCAL lngAtom AS LONG
  '
  wglMakeCurrent ghDC, ghRC
  '
  glClear %GL_COLOR_BUFFER_BIT OR %GL_DEPTH_BUFFER_BIT
  glLoadIdentity
  glTranslatef 0.0, 0.0, -12.0
  glRotatef 25.0, 1.0, 0.0, 0.0        ' gentle tilt so the ring isn't edge-on
  glRotatef gAngle, 0.0, 1.0, 0.0      ' continuous spin around vertical axis
  '
  ' ---- Opaque pass: solid spheres, depth writes on ----
  glDisable %GL_BLEND
  glDepthMask 1
   '
  ' ---- Bond sticks first (thin dark lines through atom centres) ----
  'glColor4f 0.75, 0.75, 0.78, 1.0
  'glLineWidth 2.0
  'subDrawBonds()
  '
  ' ---- Atom spheres: gradient-filled, overlapping (CPK space-filling) ----
  FOR lngAtom = 1 TO g_lngNUM_ATOMS
  ' Top of each sphere is a lightened tint of its base colour,
  ' bottom is a deepened/darkened tint -> smooth gradient fill.
     subDrawGradientSphere( _
        ga_atomX(lngAtom), _
        ga_atomY(lngAtom), _
        ga_atomZ(lngAtom), _
        ga_atomR(lngAtom), 20, 16, _
        ga_atomCR(lngAtom) + (1.0 - ga_atomCR(lngAtom)) * 0.70, _
        ga_atomCG(lngAtom) + (1.0 - ga_atomCG(lngAtom)) * 0.70, _
        ga_atomCB(lngAtom) + (1.0 - ga_atomCB(lngAtom)) * 0.70, _
        ga_atomCR(lngAtom) * 0.30, ga_atomCG(lngAtom) * 0.30, _
        ga_atomCB(lngAtom) * 0.30, 1.0)
  NEXT lngAtom
  '
  glFlush
  '
END SUB'
'SUB subDrawBoxFaces
'' draw the 6 box faces
'  LOCAL sngH AS SINGLE
'  sngH = %BOX_LIMIT
'  '
'  glBegin %GL_QUADS
'  '
'  ' Front  (z = +sngH)
'  PREFIX "glVertex3f "
'    -sngH, -sngH,  sngH
'     sngH, -sngH,  sngH
'     sngH,  sngH,  sngH
'    -sngH,  sngH,  sngH
'  END PREFIX
'  '
'  ' Back   (z = -sngH)
'  PREFIX "glVertex3f "
'    -sngH, -sngH, -sngH
'    -sngH,  sngH, -sngH
'     sngH,  sngH, -sngH
'     sngH, -sngH, -sngH
'  END PREFIX
'  '
'  ' Left   (x = -sngH)
'  PREFIX "glVertex3f "
'    -sngH, -sngH, -sngH
'    -sngH, -sngH,  sngH
'    -sngH,  sngH,  sngH
'    -sngH,  sngH, -sngH
'   END PREFIX
'  '
'  ' Right  (x = +sngH)
'  PREFIX "glVertex3f "
'    sngH, -sngH, -sngH
'    sngH,  sngH, -sngH
'    sngH,  sngH,  sngH
'    sngH, -sngH,  sngH
'    END PREFIX
'  '
'  ' Top    (y = +sngH)
'  PREFIX "glVertex3f "
'    -sngH,  sngH, -sngH
'    -sngH,  sngH,  sngH
'     sngH,  sngH,  sngH
'     sngH,  sngH, -sngH
'  END PREFIX
'  '
'  ' Bottom (y = -sngH)
'  PREFIX "glVertex3f "
'    -sngH, -sngH, -sngH
'     sngH, -sngH, -sngH
'     sngH, -sngH,  sngH
'    -sngH, -sngH,  sngH
'  END PREFIX
'  '
'  glEnd
'  '
'END SUB
'
'SUB subDrawBoxEdges
'' draw the 12 edges of the box
'  LOCAL sngH AS SINGLE
'  sngH = %BOX_LIMIT
'  '
'  glBegin %GL_LINES
'  '
'  ' bottom face
'  PREFIX "glVertex3f "
'    -sngH,-sngH,-sngH
'     sngH,-sngH,-sngH
'     sngH,-sngH,-sngH
'     sngH,-sngH, sngH
'     sngH,-sngH, sngH
'    -sngH,-sngH, sngH
'    -sngH,-sngH, sngH
'    -sngH,-sngH,-sngH
'  END PREFIX
'  '
'  ' top face
'  PREFIX "glVertex3f "
'    -sngH, sngH,-sngH
'     sngH, sngH,-sngH
'     sngH, sngH,-sngH
'     sngH, sngH, sngH
'     sngH, sngH, sngH
'    -sngH, sngH, sngH
'    -sngH, sngH, sngH
'    -sngH, sngH,-sngH
'  END PREFIX
'  '
'  ' verticals
'  PREFIX "glVertex3f "
'    -sngH,-sngH,-sngH
'    -sngH, sngH,-sngH
'     sngH,-sngH,-sngH
'     sngH, sngH,-sngH
'     sngH,-sngH, sngH
'     sngH, sngH, sngH
'    -sngH,-sngH, sngH
'    -sngH, sngH, sngH
'  END PREFIX
'  '
'  glEnd
'  '
'END SUB
