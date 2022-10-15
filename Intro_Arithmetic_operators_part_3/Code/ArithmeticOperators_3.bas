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
FUNCTION PBMAIN () AS LONG
' the main PB function that is the first to be executed
  funPrepOutput("Arithmetic Operators",0,0,40,120)
  '
  funLog("Arithmetic Operators")
  '
  LOCAL lngRooms AS LONG     ' number of rooms in hotel
  LOCAL lngVisitors AS LONG  ' number of visitors in one day
  LOCAL lngVisitorsPerRoom AS LONG ' number in each room
  LOCAL sngRoomsNeeded AS SINGLE   ' number of rooms needed
  '
  lngRooms = 45
  lngVisitors = 17
  lngVisitorsPerRoom = 2
  '
  sngRoomsNeeded = lngVisitors / lngVisitorsPerRoom
  PRINT "Rooms needed = " ;sngRoomsNeeded
  '
  ' rounding uses Bankers rounding
  sngRoomsNeeded = ROUND(lngVisitors / lngVisitorsPerRoom,0)
  PRINT "Rooms needed (rounded) = " ;sngRoomsNeeded
  '
  ' integer division
  PRINT "Full Rooms = "; lngVisitors \ lngVisitorsPerRoom
  '
  ' return the modulus  - modulo operation
  PRINT "Half full rooms ";lngVisitors MOD lngVisitorsPerRoom
  '
  LOCAL lngConferenceRoomSize AS LONG
  LOCAL lngTradeStandSize AS LONG
  '
  lngConferenceRoomSize = 25   ' size of conference room 25x25m
  lngTradeStandSize = 5        ' size of trade stand 5x5m
  '
  PRINT "Each Trade stand is "; lngTradeStandSize ^ 2 ; " sq metres"
  PRINT "Room is " ; lngConferenceRoomSize ^ 2 ; " sq metres"
  '
  PRINT "Total stands = " ; SQR(lngConferenceRoomSize ^ 2)
  '
  PRINT "Total stands = " ; (lngConferenceRoomSize ^ 2) ^ (1/2)
  '
  ' Two to the power of 2 squared
  PRINT "2 to the power of 2 squared = "; 2^2^2
  PRINT "2 to the power of 4 "; 2^4
  '
  ' square roots
  PRINT "Square root of 4 = "; SQR(4)
  PRINT "Square root of 4 = "; 4^(1/2)
  '
  ' 3 cubed & cube roots
  PRINT "3 cubed = "; 3^3
  PRINT "Cube root of 27 = "; 27^(1/3)
  '
  PRINT "3 to the power of 4 = "; 3^4
  PRINT "Quad root of 81 = "; 81^(1/4)

  '
  funWait()
  '
END FUNCTION
'
