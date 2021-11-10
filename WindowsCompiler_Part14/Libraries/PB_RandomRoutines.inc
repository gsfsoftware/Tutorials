' PB_RandomRoutines.inc

FUNCTION funGetTelephone() AS STRING
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
  FUNCTION = FORMAT$(RND(1, 1200))
END FUNCTION

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
    REDIM a_strArray(lngMaxRecord) AS STRING
    '
    WHILE NOT EOF(#lngFile)
      INCR lngCount
      IF lngCount = 1 THEN
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
