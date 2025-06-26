#COMPILE EXE
#DIM ALL
#DEBUG ERROR ON
'
' Star migration
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
%MaxYears     =  1000     ' max years of the simulation
'
%StarCount    = 100       ' number of stars to seed the simulation
'
%BlackholeMass = 100000   ' mass of Blackhole
'
%EmpireCount = 4          ' number of empires supported
'
' UDT for star information
TYPE udtStarData
  x          AS SINGLE ' x co-ordinate
  y          AS SINGLE ' y co-ordinate
  z          AS SINGLE ' z co-ordinate
  sMass      AS SINGLE ' Mass
  sAccX      AS SINGLE ' Accelation X
  sAccY      AS SINGLE ' Accelation Y
  sAccZ      AS SINGLE ' Accelation Z
  sVelocityX AS SINGLE ' Velocity X
  sVelocityY AS SINGLE ' Velocity Y
  sVelocityZ AS SINGLE ' Velocity Z
  lngCol     AS LONG   ' colour
  lngOwner   AS LONG   ' ref to owner
  lngStatus  AS LONG   ' ref to current status
END TYPE
'
GLOBAL g_uStars() AS udtStarData   ' stars array
GLOBAL g_sGravity AS SINGLE        ' Gravitation force
GLOBAL g_sDT AS SINGLE             ' movement Scaler, smaller is slower
GLOBAL g_sViewDistance AS SINGLE   ' distance to view from
GLOBAL g_alngEmpires() AS LONG     ' Colour of empires
'
FUNCTION PBMAIN () AS LONG
' prepare the graphics window
  LOCAL hWin AS DWORD         ' handle of the graphics window
  LOCAL dwFont AS DWORD       ' handle of the font used
  LOCAL lngYearCount AS LONG  ' the year counter
  '
  LOCAL strFileOutput AS WSTRINGZ * %MAX_PATH  ' image file output
  '
  g_sGravity = -0.005
  g_sDT      = 0.015
  g_sViewDistance = 80.125  ' distance to be viewed
  '
  ' dimension the star array
  REDIM g_uStars(%StarCount) AS udtStarData
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
  FOR lngYearCount = 1 TO %MaxYears
  ' for each year processed
    funMoveStars(lngYearCount)
    funMoveShips()
    funUpdateSettlements()
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
FUNCTION funMoveStars(lngYearCount AS LONG) AS LONG
' work out stars new positions
  LOCAL lngS AS LONG  ' star counter
  LOCAL lngT AS LONG  ' all other stars counter
  ' pointers to star data
  LOCAL pS,pT  AS udtStarData PTR
  '
  LOCAL sDX,sDY,sDZ,tmp  AS SINGLE
  '
  FOR lngS = 2 TO %StarCount
    pS = VARPTR (g_uStars(lngS))
    ' zero the accelerations
    @pS.sAccX = 0
    @pS.sAccY = 0
    @pS.sAccZ = 0
    '
    FOR lngT = 1 TO %Starcount
      ' dont check star on itself
      IF lngS = lngT THEN ITERATE
      '
      pT = VARPTR (g_uStars(lngT))
      '
      'get distance between stars
      sDX = @pS.X -  @pT.X
      sDY = @pS.Y -  @pT.Y
      sDZ = @pS.Z -  @pT.Z
      '
      tmp=(g_sGravity * @pT.sMass)/SQR(sDX*sDX+sDY*sDY+sDZ*sDZ)  ' get acting force
      @pS.sAccX = @pS.sAccX + tmp * sDX  ' add up all the forces
      @pS.sAccY = @pS.sAccY + tmp * sDY  ' add up all the forces
      @pS.sAccZ = @pS.sAccZ + tmp * sDZ  ' add up all the forces
      '
    NEXT lngT
    '
      ' work out velocities
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
     'DEBUG simulate colonistation
    ' change owner
    IF @pS.lngOwner = 0 THEN
    ' only if not yet owned
      IF RND(1,5000) = 10 THEN
        @pS.lngOwner = RND(1,4)
      END IF
    END IF
    '
  NEXT lngS
  '
   ' now place the stars on the map
  funPlaceStars(lngYearCount)
  '
END FUNCTION
'
FUNCTION funPlaceStars(lngYearCount AS LONG) AS LONG
' now place the stars on the map from the array
  LOCAL lngS AS LONG ' star counter
  LOCAL sX AS SINGLE
  LOCAL sY AS SINGLE
  LOCAL sZ AS SINGLE
  LOCAL lngColour AS LONG   ' colour to indicate owner of star system
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
  ' place the star
    '
    sX = ((g_uStars(lngS).X * g_sViewDistance) / _
            (g_sViewDistance + g_uStars(lngS).z))+200
    sY = ((g_uStars(lngS).Y * g_sViewDistance) / _
             (g_sViewDistance + g_uStars(lngS).z))+200
    '
    SELECT CASE lngS
      CASE 1
        ' place black hole
        GRAPHIC ELLIPSE (sX, _
                         sY) - _
                        (sX+5, _
                         sY+5) , _
                         %RED,%RED , 0
      CASE ELSE
      ' Place all other stars - with colour
        IF g_uStars(lngS).lngOwner = 0 THEN
        ' star is not owned
          lngColour = g_uStars(lngS).lngCol
        ELSE
          lngColour = g_alngEmpires(g_uStars(lngS).lngOwner)
        END IF
        '
        GRAPHIC ELLIPSE (sX, _
                         sY) - _
                        (sX+3, _
                         sY+3) , _
                         lngColour, _
                         lngColour , 0
        '
    END SELECT
  NEXT lngS
  '
  GRAPHIC REDRAW
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
   ' now place all the stars
  FOR lngS = 2 TO %StarCount
    ' lngS = 1 is blackhole
    lngX = RND(%Map_Edge,%MapX-%Map_Edge)
    lngY = RND(%Map_Edge,%MapY-%Map_Edge)
    lngZ = RND(%Map_Edge,%MapZ-%Map_Edge)
    '
    WHILE ISFALSE funEmptyStarLocation(lngX,lngY,lngZ)
    ' look until a free location has been found
      lngX = RND(%Map_Edge,%MapX-%Map_Edge)
      lngY = RND(%Map_Edge,%MapY-%Map_Edge)
      lngZ = RND(%Map_Edge,%MapZ-%Map_Edge)
    WEND
    '
    PREFIX "g_uStars(lngS)."
      X = lngX
      Y = lngY
      Z = lngZ
      sMass = RND(50,255)
      lngCol = RGB(g_uStars(lngS).sMass, _
                   g_uStars(lngS).sMass, _
                   g_uStars(lngS).sMass)
    END PREFIX
    '
  NEXT lngS
  '
END FUNCTION
'
FUNCTION funEmptyStarLocation(lngX AS LONG, _
                              lngY AS LONG, _
                              lngZ AS LONG ) AS LONG
' is this location occupied by a star?
  LOCAL lngS AS LONG  ' star counter
  FOR lngS = 1 TO %StarCount
    IF g_uStars(lngS).X = lngX AND _
       g_uStars(lngS).Y = lngY AND _
       g_uStars(lngS).Z = lngZ THEN
    ' location is already occupied
      EXIT FUNCTION
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
  ' store black hole position
  '
  g_uStars(1).X = lngCentreX
  g_uStars(1).Y = lngCentreY
  g_uStars(1).Z = lngCentreZ
  g_uStars(1).sMass = %BlackHoleMass
  '
  ' place black hole
  GRAPHIC ELLIPSE (lngCentreX, lngCentreY) - _
                  (lngCentreX+5, lngCentreY+5) , _
                  %RED,%RED , 0
                  '
END FUNCTION
'
FUNCTION funDrawMapBoundary() AS LONG
' draw the boundary of the map
  GRAPHIC WIDTH 4
  GRAPHIC BOX (1, 1) - (%MapX, %MapY) , 0, %YELLOW , _
                        -2 , 0
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
