#COMPILE EXE
#DIM ALL
#DEBUG ERROR ON
'
' Optimized Star Migration Simulation
#TOOLS OFF
'
#IF %DEF(%PB_CC32)
  #CONSOLE OFF
#ENDIF

' include the win 32 routines
#INCLUDE "win32api.inc"
'
#INCLUDE "GDIPlus_included_functions.inc"
'
%MapX = 780               ' max width of the Simulation
%MapY = 580               ' max height of the Simulation
%MapZ = 300               ' max depth of the Simulation
'
%Map_Edge = 30            ' set margin for map edge
'
%ChartWidth = 280         ' Width of the chart
%ChartHeight = 200        ' Height of the chart
'
%GraphicStartWidth = 300  ' width of the graphic reporter
'
%MaxYears     =  10000    ' max years of the simulation
'
%StarCount    = 200       ' number of stars to seed the simulation
'
%BlackholeMass = 100000   ' mass of Blackhole
'
%EmpireCount = 4          ' number of empires supported
'
' Optimization constants
%MinDistanceSquared = 1 ' minimum distance squared to prevent division by zero
%MaxInfluenceDistance = 1000 ' stars beyond this distance have negligible influence
%ColonizationCheckInterval = 100 ' check colonization every N years instead of every year
'
' UDT for star information - optimized layout
TYPE udtStarData
  x          AS SINGLE ' x co-ordinate
  y          AS SINGLE ' y co-ordinate
  z          AS SINGLE ' z co-ordinate
  sMass      AS SINGLE ' Mass
  sVelocityX AS SINGLE ' Velocity X
  sVelocityY AS SINGLE ' Velocity Y
  sVelocityZ AS SINGLE ' Velocity Z
  sAccX      AS SINGLE ' Acceleration X (computed each frame)
  sAccY      AS SINGLE ' Acceleration Y (computed each frame)
  sAccZ      AS SINGLE ' Acceleration Z (computed each frame)
  lngCol     AS LONG   ' colour
  lngOwner   AS LONG   ' ref to owner
  lngStatus  AS LONG   ' ref to current status
END TYPE
'
' Pre-computed values for optimization
TYPE udtPrecomputed
  sGravityMass AS SINGLE ' pre-computed gravity * mass
  sScreenX     AS SINGLE ' pre-computed screen X position
  sScreenY     AS SINGLE ' pre-computed screen Y position
END TYPE
'
GLOBAL g_uStars() AS udtStarData   ' stars array
GLOBAL g_uPrecomp() AS udtPrecomputed ' pre-computed values
GLOBAL g_sGravity AS SINGLE        ' Gravitation force
GLOBAL g_sDT AS SINGLE             ' movement Scaler, smaller is slower
GLOBAL g_sViewDistance AS SINGLE   ' distance to view from
GLOBAL g_alngEmpires() AS LONG     ' Colour of empires
'
' Optimization variables
GLOBAL g_sGravityDT AS SINGLE         ' pre-computed gravity * dt
GLOBAL g_sViewDistanceRecip AS SINGLE ' 1 / view distance for optimization
GLOBAL g_sMaxInfluenceDistSq AS SINGLE ' max influence distance squared
'
FUNCTION PBMAIN () AS LONG
' prepare the graphics window
  LOCAL hWin AS DWORD         ' handle of the graphics window
  LOCAL dwFont AS DWORD       ' handle of the font used
  LOCAL lngYearCount AS LONG  ' the year counter
  LOCAL dblStartTime AS DOUBLE ' timing
  '
  LOCAL strFileOutput AS WSTRINGZ * %MAX_PATH  ' image file output
  '
  g_sGravity = -0.005
  g_sDT      = 0.015
  g_sViewDistance = 80.125  ' distance to be viewed
  '
  ' Pre-compute commonly used values
  g_sGravityDT = g_sGravity * g_sDT
  g_sViewDistanceRecip = 1.0 / g_sViewDistance
  g_sMaxInfluenceDistSq = %MaxInfluenceDistance * %MaxInfluenceDistance
  '
  ' dimension the star array
  REDIM g_uStars(%StarCount) AS udtStarData
  REDIM g_uPrecomp(%StarCount) AS udtPrecomputed
  ' dimension the empire colours array
  REDIM g_alngEmpires(%EmpireCount) AS LONG
  '
  RANDOMIZE TIMER
  '
  ' set up the empires
  funInitialiseEmpires()
  '
  GRAPHIC WINDOW NEW "Star Migration", 50, 50, 1700,900 TO hWin
  GRAPHIC ATTACH hWin, 0, REDRAW
  GRAPHIC SCALE (0,0)-(%MapX + %GraphicStartWidth,%MapY)
  FONT NEW "Courier New",12,0,1,0,0 TO dwFont
  GRAPHIC SET FONT dwFont
  GRAPHIC CLEAR %BLACK,0
  '
  funDrawMapBoundary()
  GRAPHIC REDRAW
  '
  funInitialiseStars()
  '
  dblStartTime = TIMER
  '
  FOR lngYearCount = 1 TO %MaxYears
  ' for each year processed
    funMoveStarsOptimized(lngYearCount)
    funMoveShips()
    funUpdateSettlements()
    '
     ' Display performance info
      GRAPHIC COLOR %CYAN,%BLACK
      GRAPHIC SET POS (10,50)
      GRAPHIC PRINT "Avg FPS: " & _
              FORMAT$(lngYearCount/(TIMER - dblStartTime), "0.0")
      GRAPHIC REDRAW
  NEXT lngYearCount

  ' simulation ending
  GRAPHIC COLOR %GREEN,%BLACK
  GRAPHIC SET POS (10,10)
  GRAPHIC PRINT "Simulation Ending"
  GRAPHIC REDRAW
  ' wait 5 secs and close the app
  SLEEP 5000
  GRAPHIC WINDOW END
  '
  FONT END dwFont
  '
END FUNCTION
'
FUNCTION funMoveStarsOptimized(lngYearCount AS LONG) AS LONG
' Optimized star movement calculation
  LOCAL lngS AS LONG  ' star counter
  LOCAL lngT AS LONG  ' all other stars counter
  ' pointers to star data for faster access
  LOCAL pS, pT AS udtStarData PTR
  LOCAL pPreS, pPreT AS udtPrecomputed PTR
  '
  LOCAL sDX, sDY, sDZ AS SINGLE
  LOCAL sDistanceSquared AS SINGLE
  LOCAL sForce AS SINGLE
  LOCAL sInvDistance AS SINGLE
  '
  ' Pre-compute gravity * mass for all stars
  FOR lngS = 1 TO %StarCount
    pPreS = VARPTR(g_uPrecomp(lngS))
    @pPreS.sGravityMass = g_sGravity * g_uStars(lngS).sMass
  NEXT lngS
  '
  ' Calculate forces (skip black hole at index 1 for movement)
  FOR lngS = 2 TO %StarCount
    pS = VARPTR (g_uStars(lngS))
    ' zero the accelerations
    @pS.sAccX = 0
    @pS.sAccY = 0
    @pS.sAccZ = 0
    '
    FOR lngT = 1 TO %Starcount
      ' Skip self-interaction
      IF lngS = lngT THEN ITERATE
      '
      pT = VARPTR(g_uStars(lngT))
      pPreT = VARPTR(g_uPrecomp(lngT))
      '
      ' Calculate distance components
      sDX = @pS.X -  @pT.X
      sDY = @pS.Y -  @pT.Y
      sDZ = @pS.Z -  @pT.Z
      '
      ' Calculate distance squared
      sDistanceSquared = sDX*sDX + sDY*sDY + sDZ*sDZ
      '
      ' Skip if too far away (optimization)
      IF sDistanceSquared > g_sMaxInfluenceDistSq THEN ITERATE
      '
      ' Prevent division by zero
      IF sDistanceSquared < %MinDistanceSquared THEN
        sDistanceSquared = %MinDistanceSquared
      END IF
      '
      ' Use pre-computed gravity * mass and optimize division
      sInvDistance = 1.0 / SQR(sDistanceSquared)
      sForce = @pPreT.sGravityMass * sInvDistance
      '
      ' Apply force components
      @pS.sAccX = @pS.sAccX + sForce * sDX * sInvDistance
      @pS.sAccY = @pS.sAccY + sForce * sDY * sInvDistance
      @pS.sAccZ = @pS.sAccZ + sForce * sDZ * sInvDistance
      '
    NEXT lngT
    '
    ' Update velocities
    @pS.sVelocityX = @pS.sVelocityX + @pS.sAccX * g_sDT
    @pS.sVelocityY = @pS.sVelocityY + @pS.sAccY * g_sDT
    @pS.sVelocityZ = @pS.sVelocityZ + @pS.sAccZ * g_sDT
    '
    ' store new position X & Y & Z
    @pS.X = @pS.X + _
            @pS.sVelocityX * _
            g_sDT
    @pS.Y = @pS.Y + _
            @pS.sVelocityY * _
            g_sDT
    @pS.Z = @pS.Z + _
            @pS.sVelocityZ * _
            g_sDT
            '
    ' Optimized colonization check - only every N years
    IF (lngYearCount MOD %ColonizationCheckInterval) = 0 THEN
      IF @pS.lngOwner = 0 THEN
        ' Reduced random check frequency
        IF RND(1,1000) = 10 THEN
          @pS.lngOwner = RND(1,4)
        END IF
      END IF
    END IF
    '
  NEXT lngS
  '
  ' Pre-compute screen positions for rendering
  funPrecomputeScreenPositions()
  '
  ' Render stars
  funPlaceStarsOptimized(lngYearCount)
  '
END FUNCTION
'
FUNCTION funPrecomputeScreenPositions() AS LONG
' Pre-compute screen positions for all stars
  LOCAL lngS AS LONG
  LOCAL pStar AS udtStarData PTR
  LOCAL pPre AS udtPrecomputed PTR
  LOCAL sDepthFactor AS SINGLE
  '
  FOR lngS = 1 TO %StarCount
    pStar = VARPTR(g_uStars(lngS))
    pPre = VARPTR(g_uPrecomp(lngS))
    '
    sDepthFactor = g_sViewDistance / (g_sViewDistance + @pStar.Z)
    @pPre.sScreenX = (@pStar.X * sDepthFactor) + 200
    @pPre.sScreenY = (@pStar.Y * sDepthFactor) + 200
    '
  NEXT lngS
  '
END FUNCTION
'
FUNCTION funPlaceStarsOptimized(lngYearCount AS LONG) AS LONG
' Optimized star rendering using pre-computed positions
  LOCAL lngS AS LONG
  LOCAL pStar AS udtStarData PTR
  LOCAL pPre AS udtPrecomputed PTR
  LOCAL lngColour AS LONG
  '
  GRAPHIC CLEAR %BLACK,0
  '
  GRAPHIC COLOR %GREEN,%BLACK
  GRAPHIC SET POS (10,10)
  GRAPHIC PRINT "Year = " & FORMAT$(lngYearCount * 10)
  '
  funDrawMapBoundary()
  '
  FOR lngS = 1 TO %StarCount
    pStar = VARPTR(g_uStars(lngS))
    pPre = VARPTR(g_uPrecomp(lngS))
    '
    ' avoid showing stars outside the boundary
    IF @pPre.sScreenX >= %MapX OR @pPre.sScreenY >= %MapY THEN
      ITERATE FOR
    END IF
    '
    SELECT CASE lngS
      CASE 1
        ' Black hole
        GRAPHIC ELLIPSE (@pPre.sScreenX, @pPre.sScreenY) - _
                        (@pPre.sScreenX+5, @pPre.sScreenY+5), _
                         %RED, %RED, 0
      CASE ELSE
        ' Determine color based on ownership
        IF @pStar.lngOwner = 0 THEN
          lngColour = @pStar.lngCol
        ELSE
          lngColour = g_alngEmpires(@pStar.lngOwner)
        END IF
        '
        ' Draw star
        GRAPHIC ELLIPSE (@pPre.sScreenX, @pPre.sScreenY) - _
                        (@pPre.sScreenX+3, @pPre.sScreenY+3), _
                         lngColour, lngColour, 0
    END SELECT
  NEXT lngS
  '
END FUNCTION
'
FUNCTION funMoveShips() AS LONG
' move ships
'
END FUNCTION
'
FUNCTION funUpdateSettlements() AS LONG
' update settlements
'
END FUNCTION
'
FUNCTION funInitialiseStars() AS LONG
' set initial star positions
  LOCAL lngS AS LONG    ' star counter
  LOCAL lngX AS LONG    ' X co-ordinate
  LOCAL lngY AS LONG    ' Y co-ordinate
  LOCAL lngZ AS LONG    ' Z co-ordinate
  '
  funPlaceBlackHole()   ' place the black hole
  '
  ' Place all other stars
  FOR lngS = 2 TO %StarCount
    ' Generate random position
    lngX = RND(%Map_Edge,%MapX-%Map_Edge)
    lngY = RND(%Map_Edge,%MapY-%Map_Edge)
    lngZ = RND(%Map_Edge,%MapZ-%Map_Edge)
    '
    ' Ensure unique positions (simplified check)
    WHILE ISFALSE funEmptyStarLocationOptimized(lngX,lngY,lngZ,lngS)
      lngX = RND(%Map_Edge,%MapX-%Map_Edge)
      lngY = RND(%Map_Edge,%MapY-%Map_Edge)
      lngZ = RND(%Map_Edge,%MapZ-%Map_Edge)
    WEND
    '
    ' Initialize star properties
    g_uStars(lngS).X = lngX
    g_uStars(lngS).Y = lngY
    g_uStars(lngS).Z = lngZ
    g_uStars(lngS).sMass = RND(50,255)
    g_uStars(lngS).lngCol = RGB(g_uStars(lngS).sMass, _
                   g_uStars(lngS).sMass, _
                   g_uStars(lngS).sMass)
    g_uStars(lngS).lngOwner = 0
    g_uStars(lngS).lngStatus = 0
    '
    ' Initialize velocities and accelerations
    g_uStars(lngS).sVelocityX = 0
    g_uStars(lngS).sVelocityY = 0
    g_uStars(lngS).sVelocityZ = 0
    g_uStars(lngS).sAccX = 0
    g_uStars(lngS).sAccY = 0
    g_uStars(lngS).sAccZ = 0
    '
  NEXT lngS
  '
END FUNCTION
'
FUNCTION funEmptyStarLocationOptimized(lngX AS LONG, _
                              lngY AS LONG, _
                                      lngZ AS LONG, _
                                      lngCurrentIndex AS LONG) AS LONG
' Optimized location check - only check already placed stars
  LOCAL lngS AS LONG
  LOCAL sMinDistance AS SINGLE
  LOCAL sDX, sDY, sDZ AS SINGLE
  '
  sMinDistance = 20.0  ' minimum distance between stars
  '
  FOR lngS = 1 TO lngCurrentIndex - 1
    sDX = g_uStars(lngS).X - lngX
    sDY = g_uStars(lngS).Y - lngY
    sDZ = g_uStars(lngS).Z - lngZ
    '
    IF SQR(sDX*sDX + sDY*sDY + sDZ*sDZ) < sMinDistance THEN
      EXIT FUNCTION  ' Too close to existing star
    END IF
  NEXT lngS
  '
  FUNCTION = %TRUE
  '
END FUNCTION
'
FUNCTION funPlaceBlackHole() AS LONG
' Place the black hole at the centre
  LOCAL lngCentreX AS LONG
  LOCAL lngCentreY AS LONG
  LOCAL lngCentreZ AS LONG
  '
  lngCentreX = %MapX \ 2
  lngCentreY = %MapY \ 2
  lngCentreZ = %MapZ \ 2
  '
  ' Initialize black hole
  g_uStars(1).X = lngCentreX
  g_uStars(1).Y = lngCentreY
  g_uStars(1).Z = lngCentreZ
  g_uStars(1).sMass = %BlackHoleMass
  g_uStars(1).lngCol = %RED
  g_uStars(1).lngOwner = 0
  g_uStars(1).lngStatus = 0
  '
  ' Black hole doesn't move
  g_uStars(1).sVelocityX = 0
  g_uStars(1).sVelocityY = 0
  g_uStars(1).sVelocityZ = 0
  g_uStars(1).sAccX = 0
  g_uStars(1).sAccY = 0
  g_uStars(1).sAccZ = 0
                  '
END FUNCTION
'
FUNCTION funDrawMapBoundary() AS LONG
' draw the boundary of the map
  GRAPHIC WIDTH 4
  GRAPHIC BOX (1, 1) - (%MapX, %MapY), 0, %YELLOW, -2, 0
  GRAPHIC WIDTH 1  ' Reset to default width
'
END FUNCTION
'
FUNCTION funInitialiseEmpires() AS LONG
' initialise the empires
  LOCAL lngE AS LONG
  '
  FOR lngE = 1 TO %EmpireCount
    SELECT CASE lngE
      CASE 1
        g_alngEmpires(lngE) = %RGB_YELLOW
      CASE 2
        g_alngEmpires(lngE) = %RGB_VIOLET
      CASE 3
        g_alngEmpires(lngE) = %RGB_LAWNGREEN
      CASE 4
        g_alngEmpires(lngE) = %RGB_DODGERBLUE
    END SELECT
    '
  NEXT lngE
'
END FUNCTION
