' PB_RandomRoutines.inc

FUNCTION funGetUserID(strUserName AS STRING) AS STRING
' form up a userid from name
  LOCAL strUserID AS STRING
  '
  strUserID = PARSE$(strUserName," ",1) & _
              LEFT$(PARSE$(strUserName," ",2),2) & _
              RIGHT$("00" & FORMAT$(RND(1,3)),2)
              '
  FUNCTION = strUserID
'
END FUNCTION
'
FUNCTION funGetDate(strSeedDate AS STRING, _
                    strDateFormat AS STRING, _
                    lngDays AS LONG) AS STRING
' return a random date
  LOCAL ipNewDate AS IPOWERTIME
  LET ipNewDate = CLASS "PowerTime
  LOCAL lngYear, lngMonth, lngDay AS LONG
  '
  ' populate the date
  SELECT CASE strDateFormat
    CASE "US"
      lngYear = VAL(RIGHT$(strSeedDate,4))
      lngMonth = VAL(LEFT$(strSeedDate,2))
      lngDay = VAL(MID$(strSeedDate,4,2))
    CASE ELSE
      lngYear = VAL(RIGHT$(strSeedDate,4))
      lngMonth = VAL(MID$(strSeedDate,4,2))
      lngDay = VAL(LEFT$(strSeedDate,2))
  END SELECT
  '
  ipNewDate.NewDate(lngYear,lngMonth,lngDay)
  ' add days on
  ipNewDate.AddDays(lngDays)
  '
  FUNCTION = ipNewDate.DateString
  '
END FUNCTION
'
FUNCTION funGetTime(OPTIONAL strTime AS STRING) AS STRING
' return a random time in hh:mm format (24hr)
  LOCAL lngHour AS LONG
  LOCAL lngMin AS LONG
  LOCAL strNewTime AS STRING
  '
  IF ISTRUE ISMISSING(strTime) THEN
  ' no time given
    lngHour = 0
    lngMin  = 0
  ELSE
    lngHour = VAL(LEFT$(strTime,2))
    lngMin = VAL(RIGHT$(strTime,2))
  END IF
  '
  strNewTime = RIGHT$("00" & FORMAT$(RND(lngHour,23)),2)
  strNewTime = strNewTime & ":" & _
               RIGHT$("00" & FORMAT$(RND(lngMin,59)),2)
               '
  FUNCTION = strNewTime
  '
END FUNCTION
'
FUNCTION funGetTelephone() AS STRING
' return a random telephone number
  LOCAL strCity AS STRING
  LOCAL strArea AS STRING
  LOCAL strNumber AS STRING
  '
  strCity = RIGHT$("0000" & FORMAT$(RND(200 , 600)),4)
  strArea = RIGHT$("0000" & FORMAT$(RND(100 , 900)),4)
  strNumber = RIGHT$("0000" & FORMAT$(RND(1 , 999)),4)
  '
  FUNCTION = strCity & " " & strArea & " " & strNumber

END FUNCTION

FUNCTION funStreetNumber() AS STRING
' return a random street number
  FUNCTION = FORMAT$(RND(1, 1200))
END FUNCTION
'
FUNCTION funGetAge(strDOB AS STRING) AS STRING
' return the age where strDOB = "yyyy-MM-dd"
  LOCAL MyDate AS IPOWERTIME
  LET MyDate = CLASS "PowerTime"
  MyDate.now
  '
  LOCAL DOB AS IPOWERTIME
  LET DOB = CLASS "PowerTime"
  '
  LOCAL lngYear, lngMonth, lngDay,lngSign AS LONG
  lngYear = VAL(LEFT$(strDOB,4))
  lngMonth = VAL(MID$(strDOB,6,2))
  lngDay = VAL(RIGHT$(strDOB,2))
  '
  DOB.newdate(lngYear,lngMonth,lngDay)
  DOB.DateDiff(MyDate,lngSign,lngYear,lngMonth,lngDay)
  '
  FUNCTION = FORMAT$(lngYear)
'
END FUNCTION
'
FUNCTION funAddDays(strDate AS STRING, lngDays AS LONG) AS STRING
' add x days to date  - where date in format "yyyy-MM-dd"
  LOCAL lngYear, lngMonth, lngDay,lngSign AS LONG
  '
  LOCAL MyDate AS IPOWERTIME
  LET MyDate = CLASS "PowerTime"
  '
  lngYear = VAL(LEFT$(strDate,4))
  lngMonth = VAL(MID$(strDate,6,2))
  lngDay = VAL(RIGHT$(strDate,2))
  '
  MyDate.newdate(lngYear,lngMonth,lngDay)
  MyDate.AddDays(lngDays)
  '
  FUNCTION = MyDate.DateString
'
END FUNCTION
'
FUNCTION funGetEmail(strName AS STRING) AS STRING
' return random email
  LOCAL strEmail AS STRING
  strEmail = strName
  REPLACE " " WITH "." IN strEmail
  strEmail = strEmail & "@gmail.com"
  FUNCTION = strEmail
END FUNCTION
'
FUNCTION funGetArrayValue(BYREF a_strArray() AS STRING) AS STRING
' get a random value from the array
  LOCAL lngTop AS LONG
  '
  lngTop = RND(1, UBOUND(a_strArray))
  '
  FUNCTION =a_strArray(lngTop)
  '
END FUNCTION
'
FUNCTION funBuildArray(strType AS STRING, _
                       BYREF a_strArray() AS STRING, _
                       strFileName AS STRING, _
                       lngColumn AS LONG, strDelimiter AS STRING) AS LONG
  'CON.STDOUT "Building Array " & strType
  funSetProgressText("Building Array - " & strType)
  LOCAL lngFile AS LONG
  LOCAL lngCount AS LONG
  LOCAL strData AS STRING
  LOCAL strValue AS STRING
  LOCAL lngMaxRecord AS LONG
  LOCAL strError AS STRING
  '
  TRY
    OPEN strFileName FOR INPUT AS #lngFile
    FILESCAN #lngFile, RECORDS TO lngMaxRecord
    '
    DECR lngMaxRecord
    REDIM a_strArray(1 TO lngMaxRecord) AS STRING
    '
    WHILE NOT EOF(#lngFile)
      INCR lngCount
      IF lngCount = 1 THEN
      ' ignore the header line
        LINE INPUT #lngFile, strData
        ITERATE LOOP
      END IF
      '
      LINE INPUT #lngFile, strData
      strValue = PARSE$(strData,strDelimiter,lngColumn)
      a_strArray(lngCount - 1) = strValue
    WEND
    FUNCTION = %TRUE
  CATCH
    FUNCTION = %FALSE
  FINALLY
    CLOSE #lngFile
  END TRY
END FUNCTION
'
FUNCTION funGenerateDOB() AS STRING
' generate a random Date of Birth
  LOCAL strDay AS STRING
  LOCAL strMonth AS STRING
  LOCAL strYear AS STRING
  '
  strYear = FORMAT$(RND(1930,2000))
  strMonth = RIGHT$("0" & FORMAT$(RND(1,12)),2)
  strDay = RIGHT$("0" & FORMAT$(RND(1,28)),2)
  '
  FUNCTION = strYear & "-" & strMonth & "-" & strDay
  '
END FUNCTION
'
FUNCTION funGeneratePostCode(strCity AS STRING) AS STRING
' generate random-ish postcode
  FUNCTION = UCASE$(LEFT$(strCity,2)) & FORMAT$(RND(1,50)) & _
              " " & FORMAT$(RND(1,9)) &  _
              CHR$(RND(65,90)) & CHR$(RND(65,90))
END FUNCTION
