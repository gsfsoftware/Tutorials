#COMPILE EXE
#DIM ALL
#DEBUG ERROR ON


' include the common display library
#INCLUDE "win32api.inc"
#INCLUDE "..\Libraries\CommonDisplay.inc"
#INCLUDE "..\Libraries\DateFunctions.inc"
'
FUNCTION PBMAIN () AS LONG
' the main PB function that is the first to be executed
  funPrepOutput("Date Handling",0,0,40,120)
  '
  funLog("Walk through on Date Handling")
  '
  'funLog(funReverseUKDateAsNumber(funUKDate))
  'funLog(monthname$(1))
  'funLog(dayname$(1))
  '
  LOCAL DateCalc AS IPOWERTIME
  LET DateCalc = CLASS "PowerTime"
  LOCAL lngDayNumber AS LONG
  '
  'DateCalc.Now
  DateCalc.Today
  'lngDayNumber = DateCalc.DayOfWeek
  'funLog(dayname$(lngDayNumber))
'  funLog(DateCalc.DayOfWeekString)
'  funLog(format$(DateCalc.DaysInMonth))
'  funlog DateCalc.DateStringLong
'  funlog DateCalc.DateString
'  '
'  DateCalc.AddDays(21)
'  funlog(DateCalc.DateString)
'  '
'  DateCalc.AddMonths(9)
'  funlog(DateCalc.DateString)
  '
  LOCAL lngDay1 AS IPOWERTIME
  LET lngDay1 = CLASS "PowerTime"
  LOCAL lngDay2 AS IPOWERTIME
  LET lngDay2 = CLASS "PowerTime"
  '
  lngDay1.NewDate(2020,03,20)
  lngDay2.NewDate(2021,02,21)
  '
  LOCAL lngYears, lngMonths, lngDays, lngSign AS LONG
  '
  lngDay1.DateDiff(lngDay2, lngSign,lngYears, lngMonths, lngDays)
  '
  funLog( FORMAT$(lngSign) & " sign, " & _
          FORMAT$(lngYears) & " years, " & _
          FORMAT$(lngMonths) & " months, " & _
          FORMAT$(lngDays) & " days")
  '
  '
  funWait()
  '
END FUNCTION
