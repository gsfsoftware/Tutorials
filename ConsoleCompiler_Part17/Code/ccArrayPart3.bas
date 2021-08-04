#COMPILE EXE
#DIM ALL

#INCLUDE "..\Libraries\Macros.inc"
#INCLUDE "..\Libraries\DemoClass.inc"

#LINK "..\Libraries\PB_RandomRoutines_SLL.sll"

FUNCTION PBMAIN () AS LONG

  mPrepConsole("Class Tester")
  LOCAL objDays AS iDaysArray ' array is inside this object
  LOCAL lngR AS LONG
  '
  objDays = CLASS "DaysArray"
  '
  IF ISOBJECT(objDays) THEN
  ' created ok
    CON.STDOUT "Created object"
    '
    objDays.ArrayName = "My simple days array"
    '
    objDays.set_bounds(0,6)
    '
    objDays.Dayname(0) = DAYNAME$(0)
    '
    CON.STDOUT objDays.ArrayName
    CON.STDOUT "Value = " & objDays.Dayname(0)
    '
    CON.STDOUT ""
    FOR lngR = 0 TO 6
      objDays.Dayname(lngR) = DAYNAME$(lngR)
    NEXT lngR
    '
    CON.STDOUT ""
    FOR lngR = 0 TO 6
      CON.STDOUT objDays.Dayname(lngR)
    NEXT lngR
    '
    CON.STDOUT ""
    objDays.DayName(7) = "Bounds Checker"
    '
    IF objDays.errorstatus THEN
      CON.STDOUT objDays.error_msg
    END IF
    '
  ELSE
  ' not created
    CON.STDOUT "Unable to create object"
  '
  END IF
  '
  mConsoleWait

END FUNCTION
