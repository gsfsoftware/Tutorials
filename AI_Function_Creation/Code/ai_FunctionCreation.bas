#COMPILE EXE
#DIM ALL

FUNCTION PBMAIN () AS LONG
  LOCAL strDate AS STRING
  LOCAL strNewDate AS STRING
  '
  strDate = "10/08/2025"
  '
  strNewDate = Add30DaysToNextMonday(strDate)
  '
  CON.STDOUT "Original Date = " & strDate
  CON.STDOUT "New Date      = " & strNewDate
  '
  PRINT "Press any key to exit"
  WAITKEY$
  '
END FUNCTION

'
FUNCTION Add30DaysToNextMonday(BYVAL inputDate AS STRING) AS STRING
  LOCAL pt AS IPOWERTIME
  LOCAL inputYear AS LONG
  LOCAL inputMonth AS LONG
  LOCAL inputDay AS LONG
  LOCAL dayOfWeek AS LONG
  LOCAL daysToAdd AS LONG
  LOCAL resultDate AS STRING

  ' Create PowerTime object
  pt = CLASS "PowerTime"

  ' Parse the input date (dd/MM/yyyy format)
  inputDay = VAL(LEFT$(inputDate, 2))
  inputMonth = VAL(MID$(inputDate, 4, 2))
  inputYear = VAL(RIGHT$(inputDate, 4))

  ' Set the initial date
  pt.NewDate(inputYear, inputMonth, inputDay)

  ' Add 30 days
  pt.AddDays(30)

  ' Get the day of week (0=Sunday, 1=Monday, ..., 6=Saturday)
  dayOfWeek = pt.DayOfWeek()

  ' If it's not Monday (1), advance to next Monday
  IF dayOfWeek <> 1 THEN
    IF dayOfWeek = 0 THEN
      ' If Sunday, add 1 day to get to Monday
      daysToAdd = 1
    ELSE
      ' If Tuesday-Saturday, calculate days to next Monday
      daysToAdd = 8 - dayOfWeek
    END IF

    pt.AddDays(daysToAdd)
  END IF

  ' Format the result back to dd/MM/yyyy
  resultDate = FORMAT$(pt.Day(), "00") + "/" + _
               FORMAT$(pt.Month(), "00") + "/" + _
               FORMAT$(pt.Year(), "0000")

  ' Clean up object
  pt = NOTHING

  FUNCTION = resultDate
END FUNCTION
