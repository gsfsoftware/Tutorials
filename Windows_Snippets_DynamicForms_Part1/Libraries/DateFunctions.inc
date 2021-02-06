' Datefunctions.inc
' A selection of date handling functions

FUNCTION funUKDate AS STRING
' return the current date in dd/mm/yyyy UK format
  DIM strDate AS STRING
  '
  strDate= DATE$
  '
  FUNCTION = MID$(strDate,4,2) & "/" & LEFT$(strDate,2) & "/" & RIGHT$(strDate,4)
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
  '
  DIM intMonthNumber AS INTEGER
  '
  intMonthNumber = VAL(strMonthNumber)
  '
  SELECT CASE intMonthNumber
    CASE 1
      FUNCTION = "January"
    CASE 2
      FUNCTION = "February"
    CASE 3
      FUNCTION = "March"
    CASE 4
      FUNCTION = "April"
    CASE 5
      FUNCTION = "May"
    CASE 6
      FUNCTION = "June"
    CASE 7
      FUNCTION = "July"
    CASE 8
      FUNCTION = "August"
    CASE 9
      FUNCTION = "September"
    CASE 10
      FUNCTION = "October"
    CASE 11
      FUNCTION = "November"
    CASE 12
      FUNCTION = "December"
    CASE ELSE
      FUNCTION = ""
    END SELECT
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
  DIM intMonthNumber AS INTEGER
  '
  intMonthNumber = VAL(strMonthNumber)
  '
  SELECT CASE intMonthNumber
    CASE 1
      FUNCTION = "Jan"
    CASE 2
      FUNCTION = "Feb"
    CASE 3
      FUNCTION = "Mar"
    CASE 4
      FUNCTION = "Apr"
    CASE 5
      FUNCTION = "May"
    CASE 6
      FUNCTION = "Jun"
    CASE 7
      FUNCTION = "Jul"
    CASE 8
      FUNCTION = "Aug"
    CASE 9
      FUNCTION = "Sep"
    CASE 10
      FUNCTION = "Oct"
    CASE 11
      FUNCTION = "Nov"
    CASE 12
      FUNCTION = "Dec"
    CASE ELSE
      FUNCTION = ""
    END SELECT
    '
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
FUNCTION funReverseUSDateAsNumber(strDate AS STRING) AS STRING
' given the date as mm/dd/yyyy return yyyymmdd
  FUNCTION = RIGHT$(strDate,4) & MID$(strDate,1,2) & MID$(strDate,4,2)
'
END FUNCTION
'
