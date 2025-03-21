' Datefunctions.inc
' A selection of date handling functions

'   Index to functions
'   funIsDateValid(lngYear,lngMonth,lngDay) AS LONG - Is date valid true/false
'   funIsDateValid_dd_MM_yyyy(strDate) as long - Is this date valid true/false
'   funIsDateValid_MM_dd_yyyy(strDate) as long - Is this date valid true/false
'   funIsDateValid_yyyy_MM_dd(strDate) as long - Is this date valid true/false
'   funLongDate() AS STRING - return the date as 2003Jul10 given dd/MM/yyyy
'   funLongMonthName(strMonthNumber) as string - return long Month name
'   funLongMonthNumber(strMonthName) as string - return long month name
'   funNumberDate(strDate) as string - return date as MMDDYYYY or DDMMYYYY
'   funReverseUKDateAsNumber(strDate) AS STRING - return yyyymmdd given dd/MM/yyyy
'   funReverseUSDateAsNumber(strDate) AS STRING - return yyyymmdd given MM/dd/yyyy
'   funShortMonthName(strMonthNumber) as string - return short month name
'   funShortMonthNumber(strMonthName) as string - return short month number
'   funStandardUKDate(strDate) AS STRING - return 01 Jun 2007 given dd/MM/yyyy
'   funStandardUSDate(strDate) AS STRING - return Jun 30 2020 given MM/dd/yyyy
'   funUKDate() as string     - return date in UK format dd/MM/yyyy
'   funUKMonthNumber() AS STRING - return month number given dd/MM/yyyy
'   funUSMonthNumber() as STRING - return month  number given MM/dd/yyyy
'
FUNCTION funIsDateValid_dd_MM_yyyy(strDate AS STRING) AS LONG
' accept date in dd/MM/yyyy format
  LOCAL lngYear AS LONG
  LOCAL lngMonth AS LONG
  LOCAL lngDay AS LONG
  '
  lngYear  = VAL(RIGHT$(strDate,4))
  lngMonth = VAL(MID$(strDate,4,2))
  lngDay   = VAL(LEFT$(strDate,2))
  '
  FUNCTION = funIsDateValid(lngYear,lngMonth,lngDay)
  '
END FUNCTION
'
FUNCTION funIsDateValid_MM_dd_yyyy(strDate AS STRING) AS LONG
' accept date in MM/dd/yyyy format
  LOCAL lngYear AS LONG
  LOCAL lngMonth AS LONG
  LOCAL lngDay AS LONG
  '
  lngYear  = VAL(RIGHT$(strDate,4))
  lngMonth = VAL(LEFT$(strDate,2))
  lngDay   = VAL(MID$(strDate,4,2))
  '
  FUNCTION = funIsDateValid(lngYear,lngMonth,lngDay)
  '
END FUNCTION
'
FUNCTION funIsDateValid_yyyy_MM_dd(strDate AS STRING) AS LONG
' accept date in yyyy/MM/dd format
  LOCAL lngYear AS LONG
  LOCAL lngMonth AS LONG
  LOCAL lngDay AS LONG
  '
  lngYear  = VAL(LEFT$(strDate,4))
  lngMonth = VAL(MID$(strDate,6,2))
  lngDay   = VAL(RIGHT$(strDate,2))
  '
  FUNCTION = funIsDateValid(lngYear,lngMonth,lngDay)
  '
END FUNCTION
'
FUNCTION funIsDateValid(lngYear AS LONG, _
                        lngMonth AS LONG, _
                        lngDay AS LONG) AS LONG
' accept Date in three variable format
' and return true/false if date is valid of not
  LOCAL lngDate AS IPOWERTIME
  LET lngDate = CLASS "PowerTime"
  '
  ' attempt to populate the date
  lngDate.Newdate(lngYear,lngMonth,lngDay)
  '
  IF OBJRESULT = %S_OK THEN
  ' no error occurred - date must be valid
    FUNCTION = %TRUE
  ELSE
  ' error occurred - date is not valid
    FUNCTION = %FALSE
  END IF
'
END FUNCTION
'
FUNCTION funUKDate AS STRING
' return the current date in dd/MM/yyyy UK format
  DIM strDate AS STRING
  '
  strDate= DATE$
  '
  FUNCTION = MID$(strDate,4,2) & "/" & _
             LEFT$(strDate,2) & "/" & _
             RIGHT$(strDate,4)
END FUNCTION
'
FUNCTION funNumberDate(strDate AS STRING) AS STRING
  ' return date as MMDDYYYY if given strDate as mm/dd/yyyy
  ' or
  ' return date as DDMMYYYY if given strDate as dd/mm/yyyy
  FUNCTION = LEFT$(strDate,2) & MID$(strDate,4,2) & RIGHT$(strDate,4)
END FUNCTION
'
FUNCTION funLongMonthName(strMonthNumber AS STRING) AS STRING
' return month name
  FUNCTION = MONTHNAME$(VAL(strMonthNumber))
  '
END FUNCTION
'
FUNCTION funLongMonthNumber(strMonthName AS STRING) AS STRING
' return the long month number given the month name
  SELECT CASE strMonthName
    CASE "January"
      FUNCTION = "01"
    CASE "February"
      FUNCTION = "02"
    CASE "March"
      FUNCTION = "03"
    CASE "April"
      FUNCTION = "04"
    CASE "May"
      FUNCTION = "05"
    CASE "June"
      FUNCTION = "06"
    CASE "July"
      FUNCTION = "07"
    CASE "August"
      FUNCTION = "08"
    CASE "September"
      FUNCTION = "09"
    CASE "October"
      FUNCTION = "10"
    CASE "November"
      FUNCTION = "11"
    CASE "December"
      FUNCTION = "12"
    CASE ELSE
      FUNCTION = "0"
  END SELECT
  '
END FUNCTION
'
FUNCTION funShortMonthName(strMonthNumber AS STRING) AS STRING
' return the short month name for the month number given
  FUNCTION = LEFT$(funLongMonthName(strMonthNumber),3)
END FUNCTION
'
FUNCTION funShortMonthNumber(strMonthName AS STRING) AS STRING
' return the short month number given the month name
  SELECT CASE strMonthName
    CASE "Jan"
      FUNCTION = "01"
    CASE "Feb"
      FUNCTION = "02"
    CASE "Mar"
      FUNCTION = "03"
    CASE "Apr"
      FUNCTION = "04"
    CASE "May"
      FUNCTION = "05"
    CASE "Jun"
      FUNCTION = "06"
    CASE "Jul"
      FUNCTION = "07"
    CASE "Aug"
      FUNCTION = "08"
    CASE "Sep"
      FUNCTION = "09"
    CASE "Oct"
      FUNCTION = "10"
    CASE "Nov"
      FUNCTION = "11"
    CASE "Dec"
      FUNCTION = "12"
    CASE ELSE
      FUNCTION = "0"
  END SELECT
END FUNCTION
'
FUNCTION funUKMonthNumber() AS STRING
' return the month number of current date
  FUNCTION = MID$(funUKDate(),4,2)
END FUNCTION
'
FUNCTION funUSMonthNumber() AS STRING
' return the month number of current date
  FUNCTION = LEFT$(DATE$,2)
END FUNCTION
'
FUNCTION funLongDate() AS STRING
' return the date as 2003Jul10
  DIM strDate AS STRING
  '
  strDate = DATE$
  FUNCTION = RIGHT$(strDate,4) & " " & _
             funShortMonthName(MID$(strDate,1,2)) & _
             " " & MID$(strDate,4,2)
'
END FUNCTION
'
FUNCTION funStandardUKDate(strDate AS STRING) AS STRING
' return 01 Jun 2007 where strDate = 01/06/2007
  FUNCTION = LEFT$(strDate,1) & " " & _
             funShortMonthName(MID$(strDate,4,2)) & " " & _
             RIGHT$(strDate,4)
END FUNCTION
'
FUNCTION funStandardUSDate(strDate AS STRING) AS STRING
' return Jun 30 2020 where strDate = 06/30/2020
  FUNCTION = funShortMonthName(MID$(strDate,1,2)) & " " & _
             MID$(strDate,1,2) & " " & _
             RIGHT$(strDate,4)
'
END FUNCTION
'
FUNCTION funReverseUKDateAsNumber(strDate AS STRING) AS STRING
' given the date as dd/mm/yyyy return yyyymmdd
  FUNCTION = RIGHT$(strDate,4) & MID$(strDate,4,2) & LEFT$(strDate,2)
'
END FUNCTION
'
FUNCTION funReverseUKDateAsNumberWithDelimter(strDate AS STRING, strDelimiter AS STRING) AS STRING
' given the date as dd/mm/yyyy return yyyymmdd
  FUNCTION = RIGHT$(strDate,4) & strDelimiter & MID$(strDate,4,2) & strDelimiter & LEFT$(strDate,2)
'
END FUNCTION
'
FUNCTION funReverseUSDateAsNumber(strDate AS STRING) AS STRING
' given the date as mm/dd/yyyy return yyyymmdd
  FUNCTION = RIGHT$(strDate,4) & MID$(strDate,1,2) & MID$(strDate,4,2)
'
END FUNCTION
'
