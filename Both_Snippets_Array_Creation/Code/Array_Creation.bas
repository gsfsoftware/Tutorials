#COMPILE EXE
#DIM ALL
#DEBUG ERROR ON
'
#TOOLS OFF
'
' include the common display library
#INCLUDE "win32api.inc"
#INCLUDE "CommonDisplay.inc"
'
ENUM RainData SINGULAR
  Dayname = 1
  Rainfall
END ENUM
'
FUNCTION PBMAIN () AS LONG
' the main PB function that is the first to be executed
  funPrepOutput("Array creation",0,0,40,120)
  '
  funLog("Array creation")
  '
  RANDOMIZE TIMER
  '
  ' create a one dimensional string
  ' array with 5 elements
 ' dim a_strFruit(5) as string ' equivalent to dim a_strFruit(0 to 5)
  DIM a_strFruit(1 TO 5) AS STRING
  ' assign values
  ARRAY ASSIGN a_strFruit() = "apple","pear","grape","orange","plum"
  '
  LOCAL lngR AS LONG
  'FOR lngR = 1 TO 5
  FOR lngR = LBOUND(a_strFruit) TO UBOUND(a_strFruit)
    funLog FORMAT$(lngR) & " " & a_strFruit(lngR)
  NEXT lngR
  '
  ' create a one dimensional array
  ' with an element for each year
  ' to store numbers of staff working
  LOCAL lngStartYear, lngEndYear AS LONG
  lngStartYear = 2013
  lngEndYear   = 2023
  '
  DIM a_lngStaffCount(lngStartYear TO lngEndYear) AS LONG
  '
  a_lngStaffCount(2022) = 860
  a_lngStaffCount(2023) = 923
  '
  FOR lngR = LBOUND(a_lngStaffCount) TO UBOUND(a_lngStaffCount)
    funLog "Year " & FORMAT$(lngR) & " had  " & _
                     FORMAT$(a_lngStaffCount(lngR)) & " staff"
  NEXT lngR
  '
  ' create a one dimensional array
  ' with an element for each temperature holding
  ' number of days at that temperature
  DIM a_lngTemp(-10 TO 5) AS LONG
  '
  ARRAY ASSIGN a_lngTemp() = 4,6,7,4,2,1,6
  '
  FOR lngR = LBOUND(a_lngTemp) TO UBOUND(a_lngTemp)
    funLog "Temperature of " & FORMAT$(lngR) & " for  " & _
                     FORMAT$(a_lngTemp(lngR)) & " days"
  NEXT lngR
  '
  ' create a two dimensional array
  ' holding day number and rainfall in mm
  DIM a_lngAvgRainfall(1 TO 7,1 TO 2) AS LONG
  '
  FOR lngR = 1 TO 7
  '  a_lngAvgRainfall(lngR,1) = lngR -1   ' store day number
  '  a_lngAvgRainfall(lngR,2) = rnd(0,200)' store rainfall
    a_lngAvgRainfall(lngR,%Dayname) = lngR -1   ' store day number
    a_lngAvgRainfall(lngR,%Rainfall) = RND(0,200)' store rainfall
  NEXT lngR
  '
 ' display the data in the array
'  FOR lngR = LBOUND(a_lngAvgRainfall,1) _
'             TO UBOUND(a_lngAvgRainfall,1)
'    funLog "Rainfall on " & dayname$(a_lngAvgRainfall(lngR,1)) & _
'           " is  " & FORMAT$(a_lngAvgRainfall(lngR,2)) & " mm"
'  NEXT lngR
  '
  FOR lngR = LBOUND(a_lngAvgRainfall,1) _
             TO UBOUND(a_lngAvgRainfall,1)
    funLog "Rainfall on " & DAYNAME$(a_lngAvgRainfall(lngR,%Dayname)) & _
           " is  " & FORMAT$(a_lngAvgRainfall(lngR,%Rainfall)) & " mm"
  NEXT lngR
  funWait()
  '
END FUNCTION
'
