#COMPILE EXE
#DIM ALL
#DEBUG ERROR ON
'
' Contact Simulator
'
#TOOLS OFF
'
#IF %DEF(%PB_CC32)
  #CONSOLE OFF
#ENDIF

' include the windows library
#INCLUDE "win32api.inc"
' add in GDI plus library to allow saving of graphics window
#INCLUDE "lib_GDIPlus.inc"
'
' define UDT for Polygons
TYPE PolyPoint
 x AS SINGLE
 y AS SINGLE
END TYPE

' Polygon array for houses
TYPE PolyArray
 count AS LONG
 xy(1 TO 5) AS PolyPoint
END TYPE
'
TYPE PeopleArray
  House AS LONG
  xy AS PolyPoint
  Infected AS LONG
  TurnInfected AS LONG
  PeopleInfected AS LONG    ' New to track R number
  DaysImmunityLeft AS LONG  ' New to work out immunity left
  TurnIsolated AS LONG      ' Period isolation started
END TYPE
'
GLOBAL a_lngColours() AS LONG
GLOBAL a_udtPeople() AS PeopleArray
GLOBAL a_udtHouses() AS PolyPoint
GLOBAL g_lngDayCount AS LONG
GLOBAL g_lngPeriod AS LONG
GLOBAL g_lngDailyInfections() AS LONG
GLOBAL g_lngInitialInfected AS LONG
'
%MaxHouses = 5       ' max number of houses in simulation
%PeoplePerHouse = 30 ' max number of people in one household
%MaxPeriods = 1500   ' max number of time periods per day in simulation
%MaxDistance = 5     ' within this distance is danger of infection
%MaxDays     = 14    ' max days of the simulation
%MaxInfected = 5     ' maximum number of infected
'
%Recovery = %TRUE         ' set to true if people recover
%PeriodsToRecover = 3000  ' Number of time periods before recovery
'
' new constants to allow Isolation and Immunity to be adjusted
%ChanceOfCatchingInfection = 60  ' % chance of catching infection
%DaysOfImmunity = 2              ' number of days of immunity
%UseIsolation = %TRUE            ' set to true to turn on isolation
%PeriodsUntilIsolation = 1500 ' number of time periods after
'                               infection before isolation begins
'
' Polygon array for Days of week graphic line
TYPE PolyArrayDays
  count AS LONG
  xy(1 TO %MaxDays) AS PolyPoint
END TYPE
'

GLOBAL g_lngDays() AS LONG ' array to track amount infected per day
'
%MapX = 780              ' max width of the Simulation
%MapY = 580              ' max height of the Simulation
'
%ChartWidth = 280        ' Width of the chart
%ChartHeight = 190       ' Height of the chart
'
%GraphicStartWidth = 300 ' width of the graphic reporter
'
FUNCTION PBMAIN () AS LONG
' the main PB function that is the first to be executed
  ' prepare the daily arrays
  REDIM g_lngDays(%MaxDays) AS LONG
  REDIM g_lngDailyInfections(%MaxDays) AS LONG
  '
  LOCAL hWin AS DWORD        ' handle of the graphics window
  LOCAL dwFont AS DWORD      ' handle of the font used
  LOCAL lngDayCount AS LONG  ' the day counter
  LOCAL lngPeriod AS LONG    ' the period within the day counter
  '
  GRAPHIC WINDOW "Contact Simulator", 50, 50, 1700,900 TO hWin
  GRAPHIC ATTACH hWin, 0, REDRAW
  GRAPHIC SCALE (0,0)-(%MapX + %GraphicStartWidth,%MapY)
  FONT NEW "Courier New",12,0,1,0,0 TO dwFont
  GRAPHIC SET FONT dwFont
  GRAPHIC CLEAR %BLACK,0
  GRAPHIC REDRAW
  '
  RANDOMIZE TIMER
  ' set up the colours per house
  funSetColours()
  ' place house on the map
  funPlaceHouses()
  ' place the people on the map
  funPrepPeople()
  '
  ' output the results
  funOutputResults()
  ' now start processing
  FOR lngDayCount = 1 TO %MaxDays
    ' store the day number
    g_lngDayCount = lngDayCount
    '
    FOR lngPeriod = 1 TO %MaxPeriods
      '
      IF ISFALSE isWindow(hWin) THEN
      ' exit the loops if Graphics window has been closed
        EXIT, EXIT
      END IF
      ' store the time period we are processing
      g_lngPeriod = lngPeriod
      ' clear the graphic window and paint it black
      GRAPHIC CLEAR %BLACK,0
      ' output the results
      funOutputResults()
      ' place the houses on the window
      funPlaceHouses()
      '
      funMoveToIsolation()
      '
      ' move the people
      funMovePeople()
      ' and then redraw the graphic window
      GRAPHIC REDRAW
      ' sleep 25 ms and repeat
      SLEEP 25
    NEXT lngPeriod
    ' output the results at the end of the day
    funOutputResults()
    funReduceImmunity()
    '
    ' save the screen at end of day
    subGDIPlus_SaveImage "jpg",EXE.PATH$ + "images\Day_" & _
                  FORMAT$(g_lngDayCount) & ".jpg"
    '
  NEXT g_lngDayCount
  '
  ' simulation ending
  GRAPHIC SET POS (10,10)
  GRAPHIC PRINT "Simulation Ending"
  GRAPHIC REDRAW
  ' wait 5 secs and close the app
  SLEEP 5000
  GRAPHIC WINDOW END
  '
  FONT END dwFont
END FUNCTION
'
FUNCTION funMoveToIsolation() AS LONG
' move people to isolation?
  IF ISFALSE %UseIsolation THEN EXIT FUNCTION
  '
  LOCAL lngR AS LONG
  '
  FOR lngR = 1 TO UBOUND(a_udtPeople)
    IF a_udtPeople(lngR).TurnInfected > 0 THEN
    ' person is currently infected
      IF a_udtPeople(lngR).TurnInfected + %PeriodsUntilIsolation = _
         ((g_lngDayCount-1) * %MaxPeriods) + g_lngPeriod THEN
      ' time to isolate
        a_udtPeople(lngR).TurnIsolated = ((g_lngDayCount-1) * %MaxPeriods) + g_lngPeriod
      '
      END IF
    END IF
  NEXT lngR
  '
END FUNCTION
'
FUNCTION funReduceImmunity() AS LONG
' reduce the immunity for those that have recovered
  LOCAL lngR AS LONG
  '
  FOR lngR = 1 TO UBOUND(a_udtPeople)
    IF a_udtPeople(lngR).DaysImmunityLeft >0 THEN
      DECR a_udtPeople(lngR).DaysImmunityLeft
    END IF
  NEXT lngR
'
END FUNCTION
'
FUNCTION funZeroInfectionCount() AS LONG
' zero the counter of people infected
  LOCAL lngR AS LONG
  '
  FOR lngR = 1 TO UBOUND(a_udtPeople)
    IF ISFALSE a_udtPeople(lngR).infected THEN
      a_udtPeople(lngR).PeopleInfected = 0
    END IF
  NEXT lngR
  '
END FUNCTION
'
FUNCTION funGetRnumber() AS STRING
  LOCAL dblRnumber AS DOUBLE
  LOCAL lngTotalInfectionsToday AS LONG
  LOCAL lngR AS LONG
  LOCAL lngCountInfected AS LONG
  '
  FOR lngR = 1 TO UBOUND(a_udtPeople)
    lngTotalInfectionsToday = lngTotalInfectionsToday + a_udtPeople(lngR).PeopleInfected
    IF ISTRUE a_udtPeople(lngR).infected THEN
      INCR lngCountInfected
    END IF
  NEXT lngR
  '
  IF lngTotalInfectionsToday <> 0 AND lngCountInfected <> 0 THEN
    dblRnumber = ROUND(lngTotalInfectionsToday / lngCountInfected,2)
    FUNCTION = FORMAT$(dblRnumber,"0.00")
  ELSE
    FUNCTION = "0.00"
  END IF
  '
END FUNCTION

'
FUNCTION funOutputResults() AS LONG
  ' output the results at this point in time
  LOCAL lngInfected AS LONG          ' count of total infected
  LOCAL lngR AS LONG
  LOCAL udtPolygon AS PolyArrayDays  ' used for Polyline
  LOCAL lngTotalPossibleInfections AS LONG
  DIM a_lngInIsolation(%MaxHouses) AS LONG   ' used for counting number in isolation for each house
  LOCAL strTemp AS STRING
  '
  lngInfected = VAL(funCountInfected)
  ' stored infection count
  g_lngDays(g_lngDayCount) = lngInfected
  ' get number currently isolating
  funGetInIsolationCount(BYREF a_lngInIsolation())
  '
  ' Report current total infected
  GRAPHIC SET POS (%MapX + 10, 5)
  GRAPHIC COLOR %RGB_LIGHTGREEN, %BLACK
  GRAPHIC PRINT "Day " & FORMAT$(g_lngDayCount) & _
                "-> " & FORMAT$(lngInfected) & " people infected"
  '
  ' prep for first chart
  LOCAL lngXStart, lngYStart AS LONG
  LOCAL lngXEnd , lngYEnd AS LONG
  '
  LOCAL lngTotalHeight, lngTotalWidth AS LONG
  '
  lngXStart = %MapX + 35
  lngYStart = 44
  '
  lngXEnd =  %MapX + 35
  lngYEnd =  %ChartHeight +16
  '
  lngTotalHeight = lngYEnd - lngYStart
  lngTotalWidth = %MapX + %ChartWidth - lngXStart

  ' now draw the graph

  GRAPHIC BOX (%MapX + 10, 26) - _
              (%MapX +10 + %ChartWidth, 43 + %ChartHeight), _
              20,%BLUE,%BLACK,0
  GRAPHIC LINE (lngXStart, lngYStart) - (lngXEnd, lngYEnd), %RED
  GRAPHIC LINE (lngXStart, lngYEnd) - (%MapX + %ChartWidth, lngYEnd), %RED
  '
  GRAPHIC SET POS (%MapX + 20, 26)
  GRAPHIC PRINT "Infections per day and Total Infected"
  GRAPHIC SET POS (%MapX + 110,26 + %ChartHeight)
  GRAPHIC PRINT "Day number"
  '
  LOCAL lngXstep AS LONG
  LOCAL lngYStep AS LONG
  ' calc vertical size of 1 infection
  lngYStep = lngTotalHeight \ UBOUND(a_udtPeople)
  ' calc max width of 1 day
  lngXStep = lngTotalWidth \ %MaxDays
  '
  ' draw vertical tick marks
  lngTotalPossibleInfections = UBOUND(a_udtPeople)
  FOR lngR = 0 TO lngTotalPossibleInfections STEP 10
    GRAPHIC LINE (lngXStart-2 , lngYEnd - (lngR * lngYStep)) - _
                 (lngXStart, lngYEnd - (lngR * lngYStep)), %RED
    GRAPHIC SET POS(lngXStart-22 , lngYEnd - (lngR * lngYStep) - (lngYStep*5))
    GRAPHIC PRINT RIGHT$("   " & FORMAT$(lngR),3)
  NEXT lngR

  ' draw the current day
  LOCAL lngX, lngY AS LONG
  LOCAL lngDay AS LONG
  FOR lngDay = 1 TO %MaxDays
    IF g_lngDays(lngDay)= 0 THEN ITERATE
    lngX = (lngDay-1) * lngXStep
    lngY = g_lngDays(lngDay) * lngYStep
    GRAPHIC BOX (lngXStart + lngX+1,lngYEnd-1)- _
                (lngXStart + lngX + lngXStep-1,lngYEnd - lngY), _
                0,%RGB_LIGHTGRAY,%RED,0
    GRAPHIC SET POS (lngXStart + lngX+2,lngYEnd+1)
    GRAPHIC PRINT FORMAT$(lngDay)
                '
    ' set number of vertices in polyline
    PREFIX "udtPolygon."
      Count = g_lngDayCount
      xy(lngDay).x =  lngXStart + lngX + (lngXStep\2)
      xy(lngDay).y =  lngYEnd - ((g_lngDailyInfections(lngDay)) * lngYStep)
    END PREFIX
    '
  NEXT lngDay
  ' now draw the polyline
  GRAPHIC WIDTH 2  ' increase graphic width
  GRAPHIC POLYLINE udtPolygon, %RGB_LIGHTGREEN
  GRAPHIC WIDTH 1  ' return graphic line width to normal
  '
  ' prep second graph
  lngXStart = %MapX + 35
  lngYStart = 60 + lngYEnd
  '
  lngXEnd =  %MapX + 35
  lngYEnd =  (2 * %ChartHeight) +5
  '
  lngTotalHeight = lngYEnd - lngYStart
  lngTotalWidth = %MapX + %ChartWidth - lngXStart
  '
  lngXStep = lngTotalWidth \ %MaxHouses
  lngYStep = lngTotalHeight \ %PeoplePerHouse
  '
  ' now draw the graph
  GRAPHIC BOX (%MapX + 10, 52 + %ChartHeight) - _
              (%MapX +10 + %ChartWidth, 25 + (%ChartHeight*2)), _
              20,%BLUE,%BLACK,0
  GRAPHIC LINE (lngXStart, lngYStart) - (lngXEnd, lngYEnd), %RED
  GRAPHIC LINE (lngXStart, lngYEnd) - (%MapX + %ChartWidth, lngYEnd), %RED
  '
  GRAPHIC SET POS (%MapX + 20, 52 + %ChartHeight)
  GRAPHIC PRINT "Infections per house"
  '
  DIM a_lngHouseInfections(%MaxHouses) AS LONG
  FOR lngR = 1 TO UBOUND(a_udtPeople)
    IF a_udtPeople(lngR).Infected = %True THEN
      INCR a_lngHouseInfections(a_udtPeople(lngR).House)
    END IF
  NEXT lngR
  '
  FOR lngR = 1 TO %MaxHouses
    IF a_lngHouseInfections(lngR)= 0 THEN ITERATE
    lngX = (lngR-1) * lngXStep
    lngY = a_lngHouseInfections(lngR) * lngYStep
    GRAPHIC BOX (lngXStart + lngX+1,lngYEnd-1)- _
                (lngXStart + lngX + lngXStep-1,lngYEnd - lngY), _
                0,a_lngColours(lngR),a_lngColours(lngR),0
    GRAPHIC SET POS (lngXStart + lngX+8,lngYEnd+1)
    IF a_lngHouseInfections(lngR) > 0 THEN
      GRAPHIC PRINT FORMAT$(ROUND((a_lngHouseInfections(lngR) / %PeoplePerHouse) * 100,1),"0.0") & "%"
    ELSE
      GRAPHIC PRINT "0.00%"
    END IF
  NEXT lngR
  '
  ' draw in isolation box
  GRAPHIC BOX (%MapX + 10, 415) - _
              (%MapX +10 + %ChartWidth, 448 ), _
              20,%BLUE,%BLACK,0
  GRAPHIC SET POS (%MapX + 20, 413)
  GRAPHIC PRINT "Number in isolation"
  '
  GRAPHIC SET POS (%MapX + 40 , 426)
  FOR lngR = 1 TO %MaxHouses
    GRAPHIC COLOR a_lngColours(lngR), %BLACK
    IF lngR < %MaxHouses THEN
      GRAPHIC PRINT RIGHT$("   " & FORMAT$(a_lngInIsolation(lngR)),3) & "     ";
    ELSE
      GRAPHIC PRINT RIGHT$("   " & FORMAT$(a_lngInIsolation(lngR)),3)
    END IF
  NEXT lngR
  '
  '
  GRAPHIC COLOR %RGB_LIGHTGREEN, %BLACK
  ' draw information box
  GRAPHIC BOX (%MapX + 10, 455) - _
              (%MapX +10 + %ChartWidth, 570 ), _
              20,%BLUE,%BLACK,0
  '
  GRAPHIC SET POS (%MapX + 20, 455)
  GRAPHIC PRINT "Information"
  GRAPHIC SET POS STEP(%MapX + 20, 2)
  GRAPHIC PRINT "Total Days in simulation = " & FORMAT$(%MaxDays)
  GRAPHIC SET POS STEP(%MapX + 20, 2)
  IF ISTRUE %Recovery THEN
    GRAPHIC PRINT "Recovery after " & _
            FORMAT$(%PeriodsToRecover/%MaxPeriods) & " days"
  ELSE
    GRAPHIC PRINT "Recovery mode off"
  END IF
  '
  GRAPHIC SET POS STEP(%MapX + 20, 2)
  GRAPHIC PRINT "Initial infections = " & _
                FORMAT$(g_lngInitialInfected)
  GRAPHIC SET POS STEP(%MapX + 20, 2)
  GRAPHIC PRINT "R number = " & funGetRnumber()
  GRAPHIC SET POS STEP(%MapX + 20, 2)
  GRAPHIC PRINT "% Chance of catching = " & FORMAT$(%ChanceOfCatchingInfection) & "%"
  GRAPHIC SET POS STEP(%MapX + 20, 2)
  GRAPHIC PRINT "Number of days of immunity = " & FORMAT$(%DaysOfImmunity)
  GRAPHIC SET POS STEP(%MapX + 20, 2)
  IF ISTRUE %UseIsolation THEN
    GRAPHIC PRINT "Use Isolation after " & FORMAT$(%PeriodsUntilIsolation / %MaxPeriods) & " days infection"
  ELSE
    GRAPHIC PRINT "No Isolation"
  END IF
  '
END FUNCTION
'
FUNCTION funCountInfected() AS STRING
' count the people currently infected
  LOCAL lngR AS LONG
  LOCAL lngCount AS LONG
  '
  FOR lngR = 1 TO UBOUND(a_udtPeople)
    IF a_udtPeople(lngR).Infected = %TRUE THEN
      INCR lngCount
    END IF
  NEXT lngR
  '
  IF lngCount = 0 AND g_lngDayCount = 1 THEN
  ' infect someone if we are on first day
    lngR = RND(1,UBOUND(a_udtPeople))
    PREFIX "a_udtPeople(lngR)."
      Infected = %TRUE
      TurnInfected = ((g_lngDayCount-1) * %MaxPeriods) + g_lngPeriod
    END PREFIX
  '
  END IF
  '
  FUNCTION = FORMAT$(lngCount)
  '
END FUNCTION
'
FUNCTION funMovePeople() AS LONG
  LOCAL lngP AS LONG
  LOCAL lngX AS LONG
  LOCAL lngY AS LONG
  LOCAL lngColour AS LONG
  LOCAL lngHouse AS LONG
  '
  FOR lngP = 1 TO UBOUND(a_udtPeople)
  '
    IF ISTRUE %Recovery THEN
    ' people can recover
      IF a_udtPeople(lngP).Infected = %TRUE THEN
      ' this person is infected
        IF a_udtPeople(lngP).TurnInfected + %PeriodsToRecover = _
          ((g_lngDayCount-1) * %MaxPeriods) + g_lngPeriod THEN
        ' they have recovered
          PREFIX "a_udtPeople(lngP)."
            Infected = %FALSE
            PeopleInfected = 0      ' zero people infected count
            DaysImmunityLeft = %DaysOfImmunity
            TurnIsolated = 0        ' no longer isolating
          END PREFIX
          '
        END IF
      '
      END IF
    '
    END IF
  ' change the persons location
    funSimulateMovement(lngP)
  '
  ' place this person on the graphic
    IF a_udtPeople(lngP).TurnIsolated = 0 THEN
    ' place on map only if not isolating
      lngX = a_udtPeople(lngP).xy.x
      lngY = a_udtPeople(lngP).xy.y
      lngHouse = a_udtPeople(lngP).House
      IF a_udtPeople(lngP).Infected = %FALSE THEN
        lngColour = a_lngColours(lngHouse)
        GRAPHIC BOX (lngX, lngY) - (lngX+8, lngY+8),100,%WHITE,lngColour,0
      ELSE
        lngColour = %BLACK
        GRAPHIC BOX (lngX, lngY) - (lngX+8, lngY+8),100,a_lngColours(lngHouse),lngColour,0
      END IF
    ELSE
    ' dont place people on the map if they are isolating
    END IF
  '
  NEXT lngP
  '
END FUNCTION
'
FUNCTION funSimulateMovement(lngP AS LONG) AS LONG
' work out which direction this person is to go
  LOCAL lngDirection AS LONG
  LOCAL lngValidPosition AS LONG
  LOCAL lngStartX, lngStartY AS LONG
  LOCAL lngNewX , lngNewY AS LONG
  LOCAL lngCurrentDistance AS LONG
  LOCAL lngNewDistance AS LONG
  LOCAL lngHouse AS LONG
  LOCAL lngHouseX AS LONG
  LOCAL lngHouseY AS LONG
  LOCAL lngInfector AS LONG
  LOCAL lngChance AS LONG
  '
  IF a_udtPeople(lngP).TurnIsolated > 0 THEN EXIT FUNCTION
  '
  lngStartX = a_udtPeople(lngP).xy.x
  lngStartY = a_udtPeople(lngP).xy.y
  '
  ' get the current distance to the house
  lngHouse = a_udtPeople(lngP).House
  lngHouseX = a_udtHouses(lngHouse).x
  lngHouseY = a_udtHouses(lngHouse).y
  lngCurrentDistance = funDetermineDistance(lngStartX,lngStartY, _
                                            lngHouseX, lngHouseY)
  '
  WHILE ISFALSE lngValidPosition
    lngDirection = RND(1,8)
    ' store current co-ords
    lngNewX = lngStartX
    lngNewY = lngStartY
    '
    SELECT CASE lngDirection
      CASE 1
        DECR lngNewX
        DECR lngNewY
      CASE 2
        DECR lngNewY
      CASE 3
        INCR lngNewX
        DECR lngNewY
      CASE 4
        INCR lngNewX
      CASE 5
        INCR lngNewX
        INCR lngNewY
      CASE 6
        INCR lngNewY
      CASE 7
        DECR lngNewX
        INCR lngNewY
      CASE 8
        DECR lngNewX
    END SELECT
    '
    ' get the new distance
    lngNewDistance = funDetermineDistance(lngNewX,lngNewY, _
                                          lngHouseX,lngHouseY)
    '
    ' is position valid
    IF lngNewX > 10 AND lngNewX < (%MapX-10) AND _
       lngNewY > 10 AND lngNewY < (%MapY-10) THEN
       '
       ' test if moving towards or away from house
       IF g_lngPeriod < (%MaxPeriods\2) THEN
       ' moving away from house
         IF lngNewDistance < lngCurrentDistance THEN
         ' dont accept this direction
           EXIT IF
         END IF
       ELSE
       ' moving towards house
         IF lngCurrentDistance < lngNewDistance THEN
         ' dont accept this direction
           EXIT IF
         END IF
       END IF
       '
       lngValidPosition = %TRUE
       a_udtPeople(lngP).xy.x = lngNewX
       a_udtPeople(lngP).xy.y = lngNewY
       '
       IF ISTRUE funInDistance(lngP, lngInfector) THEN
       ' to close to someone infected
         IF g_lngDayCount = 1 AND g_lngPeriod < (%MaxPeriods\2) THEN
         ' do nothing
         ELSEIF a_udtPeople(lngP).DaysImmunityLeft > 0 THEN
         ' still has some immunity left so no infection
         ELSE
         ' work out chance of infection taking hold
           lngChance = RND(1,100)  ' deterine chance of catching infection
           IF lngChance <= %ChanceOfCatchingInfection THEN
             PREFIX "a_udtPeople(lngP)."
               Infected = %TRUE
               TurnInfected = ((g_lngDayCount-1) * %MaxPeriods) + g_lngPeriod
             END PREFIX
             ' advance the count of people infected by infector
             INCR a_udtPeople(lngInfector).PeopleInfected
             '
             INCR g_lngDailyInfections(g_lngDayCount)
           END IF
           '
         END IF
       END IF
       '
    END IF
    '
  WEND
  '
END FUNCTION
'
FUNCTION funGetInIsolationCount(BYREF a_lngInIsolation() AS LONG) AS LONG
  LOCAL lngR AS LONG
  ' for each person
  FOR lngR = 1 TO UBOUND(a_udtPeople)
    ' who is currently isolating
    IF a_udtPeople(lngR).TurnIsolated > 0 THEN
      ' increment the house counter as total in isolation in that house
      INCR a_lngInIsolation(a_udtPeople(lngR).House)
    END IF
  NEXT lngR
  '
END FUNCTION
'
FUNCTION funInDistance(lngP AS LONG, lngInfector AS LONG) AS LONG
' is this person too close to someone that is infected
  LOCAL lngR AS LONG
  '
  LOCAL lngPx AS LONG
  LOCAL lngPy AS LONG
  LOCAL lngRx AS LONG
  LOCAL lngRy AS LONG
  '
  IF a_udtPeople(lngP).Infected = %TRUE THEN
  ' this person already infected
    EXIT FUNCTION
  END IF
  '
  FOR lngR = 1 TO UBOUND(a_udtPeople)
    IF lngR = lngP THEN ITERATE
    '
    IF a_udtPeople(lngR).Infected = %TRUE THEN
      '
      lngPx = a_udtPeople(lngP).xy.X
      lngPy =a_udtPeople(lngP).xy.Y
      '
      lngRx = a_udtPeople(lngR).xy.X
      lngRy =a_udtPeople(lngR).xy.Y
      '
      IF funDetermineDistance(lngPx, lngPy, lngRx, lngRy) < = %MaxDistance THEN
      ' close enough to become infected
        lngInfector = lngR
        FUNCTION = %TRUE
        EXIT FUNCTION
      END IF
    END IF
    '
  NEXT lngR
  '
  lngInfector = 0
  '
END FUNCTION
'
FUNCTION funDetermineDistance(lngPx AS LONG, _
                              lngPy AS LONG, _
                              lngRx AS LONG, _
                              lngRy AS LONG) AS LONG
' determine the distance between two people

  LOCAL lngDistance AS LONG
  '
  lngDistance = SQR(((ABS(lngPx - lngRx) ) ^ 2) + _
                    ((ABS(lngPy - lngRy) ) ^ 2))
                    '
  FUNCTION = lngDistance
'
END FUNCTION
'
FUNCTION funInfected() AS LONG
' work out if the person is infected or not
  LOCAL lngResult AS LONG
  STATIC lngInfectedsoFar AS LONG
  '
  lngResult = RND(1,20)  ' chance of being infected
  '
  IF lngResult = 1 THEN
    IF lngInfectedsoFar < %MaxInfected THEN
    ' only if count doesn't exceed max allowed
      INCR lngInfectedsoFar
      FUNCTION = %TRUE
    END IF
  END IF
  '
  g_lngInitialInfected = lngInfectedsoFar
  '
END FUNCTION
'
FUNCTION funPrepPeople() AS LONG
' prepare and populate the people array
  REDIM a_udtPeople(1 TO %MaxHouses * %PeoplePerHouse) AS PeopleArray
  LOCAL lngR, lngC AS LONG
  LOCAL lngP AS LONG
  '
  FOR lngR = 1 TO %MaxHouses
    FOR lngC = 1 TO %PeoplePerHouse
      INCR lngP
      ' set the house and current location of the person
      PREFIX "a_udtPeople(lngP)."
        House = lngR
        xy.x = a_udtHouses(lngR).x
        xy.y = a_udtHouses(lngR).y
        Infected = funInfected()
      END PREFIX
    NEXT lngC
  NEXT lngR
  '
END FUNCTION
'
FUNCTION funSetColours() AS LONG
' set up the colours for each house
  REDIM a_lngColours(1 TO %MaxHouses) AS LONG
  '
  a_lngColours(1) = %RGB_LIGHTBLUE
  a_lngColours(2) = %RGB_DARKGOLDENROD
  a_lngColours(3) = %RGB_LIMEGREEN
  a_lngColours(4) = %RGB_VIOLET
  a_lngColours(5) = %RGB_RED

END FUNCTION
'
FUNCTION funPlaceHouses() AS LONG
  LOCAL lngR AS LONG
  LOCAL lngXStart, lngYStart, lngSize AS LONG
  LOCAL udtPolygon AS PolyArray
  LOCAL lngVOffset AS LONG
  LOCAL lngHOffset AS LONG
  '
  REDIM a_udtHouses(%MaxHouses) AS PolyPoint
  '
  lngXStart = 250
  lngYStart = 0
  lngSize   = 25
  lngVOffset = 100
  '
  FOR lngR = 1 TO %MaxHouses
  ' for each house
    lngYStart = lngYStart + lngVOffset
    ' store house location
    IF lngR MOD 2 = 0 THEN
    ' stagger the house location
      lngHOffset = 50
    ELSE
      lngHOffset = 0
    END IF
    '
    a_udtHouses(lngR).x = lngXStart + (lngSize\2) + lngHOffset
    a_udtHouses(lngR).y = lngYStart + (lngSize\2)
    '
    PREFIX "udtPolygon."
      count = 5
      xy(1).x = lngXStart + lngHOffset
      xy(1).y = lngYStart
      xy(2).x = lngXStart + (lngSize\2) + lngHOffset
      xy(2).y = lngYStart - (lngSize\2)
      xy(3).x = lngXStart + lngSize + lngHOffset
      xy(3).y = lngYStart
      xy(4).x = lngXStart + lngSize + lngHOffset
      xy(4).y = lngYStart + lngSize
      xy(5).x = lngXStart + lngHOffset
      xy(5).y = lngYStart + lngSize
    END PREFIX
    GRAPHIC POLYGON udtPolygon, %WHITE , a_lngColours(lngR), 0
  NEXT lngR
  '
END FUNCTION
'
