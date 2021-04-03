#COMPILE EXE
#DIM ALL
#DEBUG ERROR ON


' include the common display library
#INCLUDE "win32api.inc"
#INCLUDE "..\Libraries\CommonDisplay.inc"
#INCLUDE "..\Libraries\DateFunctions.inc"
#INCLUDE "..\Libraries\PB_DatesExt.inc"
'
FUNCTION PBMAIN () AS LONG
' the main PB function that is the first to be executed
  funPrepOutput("Date Handling",0,0,40,120)
  '
  funLog("Walk through on Date Handling Part 2")
  '
  LOCAL strToday AS STRING
  strToday = funUKDate()
  '
  funLog("Today is " & strToday)
  '
  LOCAL lngToday AS LONG
  lngToday = funGregorianToJdn(strToday)
  funlog(FORMAT$(lngToday))
  '
  LOCAL lngNextWeek AS LONG
  lngNextWeek = lngToday + 7
  LOCAL strNextWeek AS STRING
  strNextWeek = funJdnToGregorian(lngNextWeek)
  funLog(strNextWeek)
  '
  funLog("Day number is " & FORMAT$(DayOfWeek(lngToday)))
  '
  funlog("Days = " & _
          FORMAT$(funGetWorkingDaysBetween("22/03/2020","29/03/2020")))
  funlog(funGetWeekCommencingDates(strToday,4))
  '
  funWait()
  '
END FUNCTION
