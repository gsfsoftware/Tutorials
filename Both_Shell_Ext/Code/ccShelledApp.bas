#COMPILE EXE
#DIM ALL

FUNCTION PBMAIN () AS LONG
  LOCAL lngCount AS LONG
  '
  FOR lngCount = 1 TO 10
    CON.STDOUT FORMAT$(lngCount)
    SLEEP 500
  NEXT lngCount
  '
END FUNCTION