#COMPILE EXE
#DIM ALL

FUNCTION PBMAIN () AS LONG
  LOCAL strDate AS STRING
  LOCAL strNewDate AS STRING
  '
  strDate = "10/08/2025"
  '
  strNewDate = funAddThirtyDaysToMonday(strDate)
  '
  CON.STDOUT "Original Date = " & strDate
  CON.STDOUT "New Date      = " & strNewDate
  '
  PRINT "Press any key to exit"
  WAITKEY$
  '
END FUNCTION

'
FUNCTION funAddThirtyDaysToMonday(BYVAL strInputDate AS STRING) AS STRING
    LOCAL pt AS IPOWERTIME
    LOCAL strResultDate AS STRING
    LOCAL lngDayOfWeek AS LONG
    LOCAL lngInputDay AS LONG
    LOCAL lngInputMonth AS LONG
    LOCAL lngInputYear AS LONG
    LOCAL lngDaysToAdd AS LONG

    ' Create PowerTime object
    pt = CLASS "PowerTime"

    ' Parse the input date (dd/MM/yyyy format)
    lngInputDay = VAL(LEFT$(strInputDate, 2))
    lngInputMonth = VAL(MID$(strInputDate, 4, 2))
    lngInputYear = VAL(RIGHT$(strInputDate, 4))

    ' Set the initial date
    pt.NewDate(lngInputYear, lngInputMonth, lngInputDay)

    ' Add 30 days to the input date
    CALL pt.AddDays(30)

    ' Get the day of the week (0=Sunday, 1=Monday, 2=Tuesday, ..., 6=Saturday)
    lngDayOfWeek = pt.DayOfWeek()

    ' If the date is not a Monday (1), advance to next Monday
    IF lngDayOfWeek <> 1 THEN
        ' Calculate days to add to reach next Monday
        IF lngDayOfWeek = 0 THEN
            ' If Sunday, add 1 day to get to Monday
            lngDaysToAdd = 1
        ELSE
            ' If Tuesday through Saturday, calculate days to next Monday
            lngDaysToAdd = 8 - lngDayOfWeek
        END IF

        ' Add the calculated days to reach Monday
        CALL pt.AddDays(lngDaysToAdd)
    END IF

    ' Get the result date in dd/MM/yyyy format
    strResultDate = pt.DateString

    ' Return the result
    FUNCTION = strResultDate

END FUNCTION
