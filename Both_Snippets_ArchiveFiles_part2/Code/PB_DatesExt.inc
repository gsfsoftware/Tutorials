'Here are three Julian number routines I converted from
'Mr. Lee's 'C' code to PowerBasic PBDLL
'and or PBCC.
'
'Calendar Conversions by Scott Lee
'original "C" code can be found here:
'Home page [URL=http://www.ScottLee.net/]http://www.ScottLee.net/[/URL]
'
'The routines are very fast as they use only integer math.
'
'JDN = Julian Date Number
'
'GregorianToJdn () - Convert a Gregorian calendar date to a JDN
'JdnToGregorian () - Convert a JDN to a Gregorian calendar date
'DayOfWeek      () - Convert a JDN to a day-of-week number (0 to 6), 0 = Sunday


'=============================================================================
' gregor.c,v 2.0 1995/10/24 01:13:06 lees Exp
' Copyright 1993-1995, Scott E. Lee, all rights reserved.
' Permission granted to use, copy, modify, distribute and sell so long as
' the above copyright and this permission statement are retained in all
' copies.  THERE IS NO WARRANTY - USE AT YOUR OWN RISK.
'=============================================================================

'=============================================================================
'
'  These are the externally visible components of this file:
'
'  SUB JDNToGregorian(BYVAL jdn   AS LONG, _
'                           Year  AS LONG, _
'                           Month AS LONG, _
'                           Day   AS LONG)
'
'  Convert a JDN to a Gregorian calendar date.  If the input JDN is less
'  than 1, the three output values will all be set to zero, otherwise
'  Year will be >= -4714 and <> 0; Month will be in the range 1 to 12
'  inclusive; Day will be in the range 1 to 31 inclusive.
'
'  FUNCTION GregorianToJdn(BYVAL Year AS LONG, _
'                          BYVAL Month AS LONG, _
'                          BYVAL Day AS LONG) AS LONG
'
'  Convert a Gregorian calendar date to a JDN.  Zero is returned when the
'  input date is detected as invalid or out of the supported range.  The
'  return value will be > 0 for all valid, supported dates, but there are
'  some invalid dates that will return a positive value.  To verify that a
'  date is valid, convert it to JDN and then back and compare with the
'  original.
'
'  VALID RANGE
'
'      4714 B.C. to at least 10000 A.D.
'
'      Although this software can handle dates all the way back to 4714
'      B.C., such use may not be meaningful.  The Gregorian calendar was
'      not instituted until October 15, 1582 (or October 5, 1582 in the
'      Julian calendar).  Some countries did not accept it until much
'      later.  For example, Britain converted in 1752, The USSR in 1918 and
'      Greece in 1923.  Most European countries used the Julian calendar
'      prior to the Gregorian.
'
'  CALENDAR OVERVIEW
'
'      The Gregorian calendar is a modified version of the Julian calendar.
'      The only difference being the specification of leap years.  The
'      Julian calendar specifies that every year that is a multiple of 4
'      will be a leap year.  This leads to a year that is 365.25 days long,
'      but the current accepted value for the tropical year is 365.242199
'      days.
'
'      To correct this error in the length of the year and to bring the
'      vernal equinox back to March 21, Pope Gregory XIII issued a papal
'      bull declaring that Thursday October 4, 1582 would be followed by
'      Friday October 15, 1582 and that centennial years would only be a
'      leap year if they were a multiple of 400.  This shortened the year
'      by 3 days per 400 years, giving a year of 365.2425 days.
'
'      Another recently proposed change in the leap year rule is to make
'      years that are multiples of 4000 not a leap year, but this has never
'      been officially accepted and this rule is not implemented in these
'      algorithms.
'
'  ALGORITHMS
'
'      The calculations are based on three different cycles: a 400 year
'      cycle of leap years, a 4 year cycle of leap years and a 5 month
'      cycle of month lengths.
'
'      The 5 month cycle is used to account for the varying lengths of
'      months.  You will notice that the lengths alternate between 30
'      and 31 days, except for three anomalies: both July and August
'      have 31 days, both December and January have 31, and February
'      is less than 30.  Starting with March, the lengths are in a
'      cycle of 5 months (31, 30, 31, 30, 31):
'
'          Mar   31 days  \
'          Apr   30 days   |
'          May   31 days    > First cycle
'          Jun   30 days   |
'          Jul   31 days  /
'
'          Aug   31 days  \
'          Sep   30 days   |
'          Oct   31 days    > Second cycle
'          Nov   30 days   |
'          Dec   31 days  /
'
'          Jan   31 days  \
'          Feb 28/9 days   |
'                           > Third cycle (incomplete)
'
'      For this reason the calculations (internally) assume that the
'      year starts with March 1.
'
'  TESTING
'
'      This algorithm has been tested from the year 4714 B.C. to 10000
'      A.D.  The source code of the verification program is included in
'      this package.
'
'  REFERENCES
'
'      Conversions Between Calendar Date and Julian Day Number by Robert J.
'      Tantzen, Communications of the Association for Computing Machinery
'      August 1963.  (Also published in Collected Algorithms from CACM,
'      algorithm number 199).
'=============================================================================
'$DIM ALL

%JDN_OFFSET         = 32045&
%DAYS_PER_5_MONTHS  = 153&
%DAYS_PER_4_YEARS   = 1461&
%DAYS_PER_400_YEARS = 146097&

DECLARE FUNCTION GregorianToJdn(BYVAL Year  AS LONG,  _
                                BYVAL Month AS LONG, _
                                BYVAL Day   AS LONG) AS LONG

DECLARE SUB JdnToGregorian(BYVAL Jdn AS LONG, Year AS LONG, _
                                 Month AS LONG, _
                                 Day AS LONG)

DECLARE FUNCTION DayOfWeek(BYVAL Jdn AS LONG) AS LONG


''=============================================================================
'' small sample for PBCC
''=============================================================================
'FUNCTION PBMAIN() AS LONG
'
'DIM JDN1  AS LONG
'DIM Year  AS LONG
'DIM Month AS LONG
'DIM Day   AS LONG
'
'
'JDN1 = GregorianToJdn(2001, 1, 19)
'PRINT JDN1                ' should be 2451929
'PRINT DayOfWeek(JDN1)     ' should be 5
'CALL JdnToGregorian(JDN1, Year, Month, Day)
'PRINT Year, Month, Day    ' should be 2001, 1, 19
'
'END FUNCTION


'=============================================================================
'  Convert a JDN to a Gregorian calendar date.  If the input JDN is less
'  than 1, the three output values will all be set to zero, otherwise
'  iYear will be >= -4714 and <> 0; iMonth will be in the range 1 to 12
'  inclusive; iDay will be in the range 1 to 31 inclusive.
'
'  VALID RANGE:
'      4714 B.C. to at least 10000 A.D.
'=============================================================================

FUNCTION funJdnToGregorian(Jdn AS LONG, _
                           OPTIONAL strFormat AS STRING) AS STRING
' return a date in format dd/MM/yyyy
' given the Julian date
  LOCAL lngYear AS LONG
  LOCAL lngMonth AS LONG
  LOCAL lngDay AS LONG
  LOCAL strLocalFormat AS STRING
  LOCAL strOutput AS STRING
  '
  JdnToGregorian(Jdn,lngYear,lngMonth,lngDay)
  '
  IF ISTRUE ISMISSING(strFormat) THEN
    strLocalFormat = "UK"
  ELSE
    strLocalFormat = strFormat
  END IF
  '
  SELECT CASE strLocalFormat
    CASE "UK"
      strOutput = RIGHT$("00" & FORMAT$(lngDay),2) & "/" & _
                  RIGHT$("00" & FORMAT$(lngMonth),2) & "/" & _
                  RIGHT$("0000" & FORMAT$(lngYear),4)
    CASE "US"
      strOutput = RIGHT$("00" & FORMAT$(lngMonth),2) & "/" & _
                  RIGHT$("00" & FORMAT$(lngDay),2) & "/" & _
                  RIGHT$("0000" & FORMAT$(lngYear),4)
  END SELECT
  '
  FUNCTION = strOutput
'
END FUNCTION

SUB JdnToGregorian(BYVAL Jdn    AS LONG, _
                         iYear  AS LONG, _
                         iMonth AS LONG, _
                         iDay   AS LONG)

LOCAL Century   AS LONG
LOCAL Year      AS LONG
LOCAL Month     AS LONG
LOCAL Day       AS LONG
LOCAL Temp      AS LONG
LOCAL DayOfYear AS LONG

' correction as pointed out by Don Schullian
' had wrong names for iYear, iMonth and iDay
IF (Jdn <= 0) THEN
   iYear = 0
   iMonth = 0
   iDay = 0
   EXIT SUB
END IF

Temp = (Jdn + %JDN_OFFSET) * 4 - 1

' Calculate the century (year/100).
Century = temp \ %DAYS_PER_400_YEARS

' Calculate the year and day of year (1 <= dayOfYear <= 366).
Temp = ((temp MOD %DAYS_PER_400_YEARS) \ 4) * 4 + 3
Year = (century * 100) + (temp \ %DAYS_PER_4_YEARS)
DayOfYear = (temp MOD %DAYS_PER_4_YEARS) \ 4 + 1

' Calculate the month and day of month.
Temp = dayOfYear * 5 - 3
Month = temp \ %DAYS_PER_5_MONTHS
Day = (temp MOD %DAYS_PER_5_MONTHS) \ 5 + 1

' Convert to the normal beginning of the year.
IF (Month < 10) THEN
   Month = Month + 3
ELSE
   INCR Year
   Month = Month - 9
END IF

' Adjust to the B.C./A.D. type numbering.
Year = Year - 4800
IF (Year <= 0) THEN DECR Year

iYear  = Year
iMonth = Month
iDay   = Day

END SUB


'=============================================================================
'  Convert a Gregorian calendar date to a JDN.  Zero is returned when the
'  input date is detected as invalid or out of the supported range.  The
'  return value will be > 0 for all valid, supported dates, but there are
'  some invalid dates that will return a positive value.  To verify that a
'  date is valid, convert it to JDN and then back and compare with the
'  original.
'
'  VALID RANGE:
'      4714 B.C. to at least 10000 A.D.
'=============================================================================
FUNCTION GregorianToJdn(BYVAL iYear  AS LONG,  _
                        BYVAL iMonth AS LONG, _
                        BYVAL iDay   AS LONG) AS LONG

LOCAL Year  AS LONG
LOCAL Month AS LONG

' check for invalid dates
IF (iYear = 0 OR iYear < -4714 OR _
   iMonth <= 0 OR iMonth > 12 OR  _
   iDay <= 0 OR iDay > 31) THEN
   FUNCTION = 0
   EXIT FUNCTION
END IF

' check for dates before jDN 1 (Nov 25, 4714 B.C.)
IF (iYear = -4714) THEN
   IF (iMonth < 11) THEN
      FUNCTION = 0
      EXIT FUNCTION
   END IF
   IF (iMonth = 11 AND iDay < 25) THEN
      FUNCTION = 0
      EXIT FUNCTION
   END IF
END IF

' Make year always a positive number.
IF (iYear < 0) THEN
   Year = iYear + 4801
ELSE
   Year = iYear + 4800
END IF

' Adjust the start of the year.
IF (iMonth > 2) THEN
   Month = iMonth - 3
ELSE
   Month = iMonth + 9
   DECR year
END IF

FUNCTION = (((year \ 100) * %DAYS_PER_400_YEARS) \ 4   _
           + ((year MOD 100) * %DAYS_PER_4_YEARS) \ 4  _
           + (month * %DAYS_PER_5_MONTHS + 2) \ 5      _
           + iDay                                  _
           - %JDN_OFFSET)
END FUNCTION
'
FUNCTION funGetAllDaysBetween(strStartDate AS STRING, _
                              strEndDate AS STRING, _
                              OPTIONAL strFormat AS STRING) AS LONG
' return the number of days between two dates
  LOCAL lngStart AS LONG
  LOCAL lngEnd AS LONG
  LOCAL lngR AS LONG
  LOCAL lngDays AS LONG
  LOCAL strLocalFormat AS STRING
  '
  IF ISTRUE ISMISSING(strFormat) THEN
    strLocalFormat = "UK"
  ELSE
    strLocalFormat = "US"
  END IF
  '
  lngStart = funGregorianToJdn(strStartDate,strLocalFormat)
  lngEnd = funGregorianToJdn(strEndDate,strLocalFormat)
  '
  lngDays = lngEnd - lngStart
  '
  FUNCTION = lngDays
  '
END FUNCTION
'
FUNCTION funGetWorkingDaysBetween(strStartDate AS STRING, _
                                  strEndDate AS STRING) AS LONG
' get number of working days between two dates
' where dates are in the format dd/MM/yyyy
'
  LOCAL lngStart AS LONG
  LOCAL lngEnd AS LONG
  LOCAL lngR AS LONG
  LOCAL lngDays AS LONG
  '
  lngStart = funGregorianToJdn(strStartDate)
  lngEnd = funGregorianToJdn(strEndDate)
  '
  FOR lngR = lngStart TO lngEnd
    SELECT CASE DayOfWeek(lngR)
      CASE 0,6
      ' its saturday or sunday
      CASE ELSE
      ' its a weekday
        INCR lngDays
      '
    END SELECT
  NEXT lngR
  '
  FUNCTION = lngDays
  '
END FUNCTION
'
FUNCTION funGregorianToJdn(BYVAL strDate AS STRING, _
                           OPTIONAL strFormat AS STRING) AS LONG
' return julian date
  LOCAL lngYear  AS LONG
  LOCAL lngMonth AS LONG
  LOCAL lngDay   AS LONG
  LOCAL strLocalFormat AS STRING
  '
  IF ISTRUE ISMISSING(strFormat) THEN
    strLocalFormat = "UK"
  ELSE
    strLocalFormat = strFormat
  END IF
  '
  SELECT CASE strLocalFormat
    CASE "UK"
      lngYear = VAL(RIGHT$(strDate,4))
      lngMonth = VAL(MID$(strDate,4,2))
      lngDay = VAL(LEFT$(strDate,2))
      '
    CASE "US"
      lngYear = VAL(RIGHT$(strDate,4))
      lngDay = VAL(MID$(strDate,4,2))
      lngMonth = VAL(LEFT$(strDate,2))
  END SELECT
  '
  FUNCTION =  GregorianToJdn(lngYear,lngMonth,lngDay)
  '
END FUNCTION


'=============================================================================
'  FUNCTION DayOfWeek(BYVAL jdn AS LONG) AS LONG
'
'  Convert a JDN to a day-of-week number (0 to 6).  Where 0 stands for
'  Sunday, 1 for Monday, etc. and 6 stands for Saturday.
'=============================================================================
FUNCTION DayOfWeek(BYVAL Jdn AS LONG) AS LONG

' correction pointed out by Don Schullian
' the following seems to work for all dates that I have tested.
FUNCTION = (JDN + 1) MOD 7

' no need to test for negative numbers here, the only way to get
' negative numbers would be if JDN were passed in < 0 which would
' be an error.

' original "C" to PB translation
'DIM dow AS LOCAL LONG
'
'dow = (Jdn + 1) MOD 7
'IF (dow >= 0) THEN
'   FUNCTION = dow
'ELSE
'   FUNCTION = dow + 7
'END IF

END FUNCTION
'
FUNCTION funDayName(BYVAL lngDay AS LONG) AS STRING
' return the name of the day
  LOCAL strDayname AS STRING
  '
  SELECT CASE lngDay
    CASE 0
      strDayname = "Sunday"
    CASE 1
      strDayname = "Monday"
    CASE 2
      strDayname = "Tuesday"
    CASE 3
      strDayname = "Wednesday"
    CASE 4
      strDayname = "Thursday"
    CASE 5
      strDayname = "Friday"
    CASE 6
      strDayname = "Saturday"
  END SELECT
  '
  FUNCTION = strDayName
  '
END FUNCTION
'
FUNCTION funGetWeekCommencingDates(strDate AS STRING, _
                                   lngNoOfWeeks AS LONG) AS STRING
' return the start date of the last X weeks where strDate is today
  LOCAL lngDay AS LONG
  LOCAL lngDate AS LONG
  LOCAL strWeeks AS STRING
  LOCAL lngR AS LONG
  '
  lngDate = funGregorianToJdn(strDate)
  lngDay = DayOfWeek(lngDate)
  '
  ' is this a Monday?
  SELECT CASE lngDay
    CASE 1
    ' its a monday so do nothing
    CASE 0
    ' its a sunday - go back 6 days
      lngDate = lngDate - 6

    CASE ELSE
    ' its not a monday
      lngDate = lngDate - (lngDay-1)
  END SELECT
  '
  strWeeks = funJdnToGregorian(lngDate)
  '
  FOR lngR = 1 TO lngNoOfWeeks-1
  ' get four previous weeks
    lngDate = lngDate - 7
    strWeeks = funJdnToGregorian(lngDate) & "*" & strWeeks
  '
  NEXT lngR
  FUNCTION = strWeeks
'
END FUNCTION

#IF NOT %DEF(%PB_CC32)
FUNCTION funSetaDate(hDlg AS DWORD, lngDate AS LONG, strDate AS STRING) AS LONG
' set a date control to the date passed
' where date is in format dd/MM/yyyy
  LOCAL DT AS SystemTime
  LOCAL lngResult AS LONG
  LOCAL hCalendar AS DWORD
  '
  CONTROL HANDLE hDlg, lngDate TO hCalendar
  '
  DT.wMonth = VAL(MID$(strDate,4,2))
  DT.wDay = VAL(MID$(strDate,1,2))
  DT.wYear = VAL(RIGHT$(strDate,4))
  lngResult = DateTime_SetSystemTime(hCalendar,%GDT_Valid, DT)
  '
END FUNCTION
#ENDIF
'
FUNCTION funIsSecondDateGTorEQtoFirst(strFirstDate AS STRING, _
                                      strSecondDate AS STRING) AS LONG
' return true if the second date is later or equal to the first
  LOCAL lngFirstDate AS LONG
  LOCAL lngSecondDate AS LONG
  '
  lngFirstDate = funGregorianToJdn(strFirstDate)
  lngSecondDate = funGregorianToJdn(strSecondDate)
  '
  IF lngSecondDate >= lngFirstDate THEN
    FUNCTION = %TRUE
  ELSE
    FUNCTION = %FALSE
  END IF
'
END FUNCTION
'
FUNCTION funIsSecondDateGTthanFirst(strFirstDate AS STRING, _
                                    strSecondDate AS STRING) AS LONG
' return true if the second date is later or equal to the first
  LOCAL lngFirstDate AS LONG
  LOCAL lngSecondDate AS LONG
  '
  lngFirstDate = funGregorianToJdn(strFirstDate)
  lngSecondDate = funGregorianToJdn(strSecondDate)
  '
  IF lngSecondDate > lngFirstDate THEN
    FUNCTION = %TRUE
  ELSE
    FUNCTION = %FALSE
  END IF
'
END FUNCTION
