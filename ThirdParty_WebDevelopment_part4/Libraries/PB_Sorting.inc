' PB_Sorting.inc
'
' Index to functions
'
' Sort a single element delimited string array using TagArray
' funArraySort(a_strWork(), _     the array to sort
'               strSortType, _    the type of sort to perform
'               lngField , _      the field number to sort on
'               strDelimiter , _  the separator between the data elements
'               strSortOrder , _  is Ascending or Descending
'               strError)         contains any error message
'
FUNCTION funArraySort(BYREF a_strWork() AS STRING, _
                      strSortType AS STRING, _
                      lngField AS LONG, _
                      strDelimiter AS STRING, _
                      strSortOrder AS STRING, _
                      strError AS STRING, _
                      OPTIONAL lngKeepHeaders AS LONG) AS LONG
                      '
  ' where a_strWork() is the array to sort
  '       strSortType is the type of sort to perform
  '       lngField is the field to sort on
  '       strDelimiter is the separator between the data elements
  '       strSortOrder is Ascending or Descending
  '       strError contains any error message
  '
  LOCAL lngMaxRecords AS LONG
  LOCAL lngBaseRecord AS LONG
  LOCAL lngR AS LONG
  LOCAL lngStart AS LONG
  '
  ' if delimiter is a comma blank it out to take advantage of
  ' parse commands inbuilt logic to handle CSV strings
  IF strDelimiter = "," THEN strDelimiter = ""
  ' pick up the upper and lower bounding of the main array
  lngMaxRecords = UBOUND(a_strWork)
  lngBaseRecord = LBOUND(a_strWork)
  '
  IF ISTRUE lngKeepHeaders THEN
  ' keep the header line
    lngStart = lngBaseRecord + 1  ' start at second element
  ELSE
    lngStart = lngBaseRecord  ' start at first element
  END IF
  '
  strError = ""
  '
  SELECT CASE strSortType
    CASE "SINGLE"
      ' prepare a tag array to hold the values you wish to sort on
      DIM a_sglTagArray(lngBaseRecord TO lngMaxRecords) AS SINGLE
      ' populate the tag array based on the field user has selected to sort on
      FOR lngR = lngBaseRecord TO lngMaxRecords
        a_sglTagArray(lngR) = VAL(PARSE$(a_strWork(lngR), _
                              strDelimiter,lngField))
      NEXT lngR
      ' perform the sorting of the tag array , specifiying the main array
      ' which will be resorted based on the changes to that tag array
      IF strSortOrder = "ASCEND" THEN
        ARRAY SORT a_sglTagArray(lngStart), _
              TAGARRAY a_strWork(), ASCEND
      ELSE
        ARRAY SORT a_sglTagArray(lngStart), _
              TAGARRAY a_strWork(), DESCEND
      END IF
      '
    CASE "DOUBLE"
      DIM a_dblTagArray(lngBaseRecord TO lngMaxRecords) AS DOUBLE
      '
      FOR lngR = lngBaseRecord TO lngMaxRecords
        a_dblTagArray(lngR) = VAL(PARSE$(a_strWork(lngR), _
                              strDelimiter,lngField))
      NEXT lngR
      '
      IF strSortOrder = "ASCEND" THEN
        ARRAY SORT a_dblTagArray(lngStart), _
              TAGARRAY a_strWork(), ASCEND
      ELSE
        ARRAY SORT a_dblTagArray(lngStart), _
              TAGARRAY a_strWork(), DESCEND
      END IF
      '
    CASE "CURRENCY"
      DIM a_curTagArray(lngBaseRecord TO lngMaxRecords) AS CURRENCY
      '
      FOR lngR = lngBaseRecord TO lngMaxRecords
        a_curTagArray(lngR) = VAL(PARSE$(a_strWork(lngR), _
                              strDelimiter,lngField))
      NEXT lngR
      '
      IF strSortOrder = "ASCEND" THEN
        ARRAY SORT a_curTagArray(lngStart), _
              TAGARRAY a_strWork(), ASCEND
              '
      ELSE
        ARRAY SORT a_curTagArray(lngStart), _
              TAGARRAY a_strWork(), DESCEND
      END IF
      '
    CASE "LONG"
      DIM a_lngTagArray(lngBaseRecord TO lngMaxRecords) AS LONG
      '
      FOR lngR = lngBaseRecord TO lngMaxRecords
        a_lngTagArray(lngR) = VAL(PARSE$(a_strWork(lngR), _
                                  strDelimiter,lngField))
      NEXT lngR
      '
      IF strSortOrder = "ASCEND" THEN
        ARRAY SORT a_lngTagArray(lngStart), _
              TAGARRAY a_strWork(), ASCEND
      ELSE
        ARRAY SORT a_lngTagArray(lngStart), _
              TAGARRAY a_strWork(), DESCEND
      END IF
      '
    CASE "STRING"
      DIM a_strTagArray(lngBaseRecord TO lngMaxRecords) AS STRING
      '
      FOR lngR = lngBaseRecord TO lngMaxRecords
        a_strTagArray(lngR) = PARSE$(a_strWork(lngR),_
                              strDelimiter,lngField)
      NEXT lngR
      '
      IF strSortOrder = "ASCEND" THEN
        ARRAY SORT a_strTagArray(lngStart), _
              COLLATE UCASE, _
              TAGARRAY a_strWork(), ASCEND
      ELSE
        ARRAY SORT a_strTagArray(lngStart), _
              COLLATE UCASE, _
              TAGARRAY a_strWork(), DESCEND
      END IF
      '
    CASE ELSE
      strError = "Invalid sort type"
      FUNCTION = %FALSE
      EXIT FUNCTION
  END SELECT
  '
  FUNCTION = %TRUE
  '
END FUNCTION
