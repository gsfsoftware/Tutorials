#COMPILE DLL
#DIM ALL

#INCLUDE ONCE "Win32API.inc"

GLOBAL ghInstance AS DWORD

' PB_Sort.DLL


'-------------------------------------------------------------------------------
' Main DLL entry point called by Windows...
'
FUNCTION LIBMAIN (BYVAL hInstance   AS LONG, _
                  BYVAL fwdReason   AS LONG, _
                  BYVAL lpvReserved AS LONG) AS LONG

    SELECT CASE fwdReason

    CASE %DLL_PROCESS_ATTACH
        'Indicates that the DLL is being loaded by another process (a DLL
        'or EXE is loading the DLL).  DLLs can use this opportunity to
        'initialize any instance or global data, such as arrays.

        ghInstance = hInstance

        FUNCTION = 1   'success!

        'FUNCTION = 0   'failure!  This will prevent the EXE from running.

    CASE %DLL_PROCESS_DETACH
        'Indicates that the DLL is being unloaded or detached from the
        'calling application.  DLLs can take this opportunity to clean
        'up all resources for all threads attached and known to the DLL.

        FUNCTION = 1   'success!

        'FUNCTION = 0   'failure!

    CASE %DLL_THREAD_ATTACH
        'Indicates that the DLL is being loaded by a new thread in the
        'calling application.  DLLs can use this opportunity to
        'initialize any thread local storage (TLS).

        FUNCTION = 1   'success!

        'FUNCTION = 0   'failure!

    CASE %DLL_THREAD_DETACH
        'Indicates that the thread is exiting cleanly.  If the DLL has
        'allocated any thread local storage, it should be released.

        FUNCTION = 1   'success!

        'FUNCTION = 0   'failure!

    END SELECT

END FUNCTION
'
FUNCTION funArraySort ALIAS "funDLLArraysort" _
                     (BYREF a_strWork() AS STRING, _
                      strSortType AS STRING, _
                      lngField AS LONG, _
                      strDelimiter AS STRING, _
                      strSortOrder AS STRING, _
                      strError AS STRING) EXPORT AS LONG
                      '
  LOCAL lngMaxRecords AS LONG
  LOCAL lngBaseRecord AS LONG
  LOCAL lngR AS LONG
  ' if delimiter is a comma blank it out to take advantage of
  ' parse commands inbuilt logic to handle CSV strings
  IF strDelimiter = "," THEN strDelimiter = ""
  ' pick up the upper and lower bounding of the main array
  lngMaxRecords = UBOUND(a_strWork)
  lngBaseRecord = LBOUND(a_strWork)
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
        ARRAY SORT a_sglTagArray(lngBaseRecord), _
              TAGARRAY a_strWork(), ASCEND
      ELSE
        ARRAY SORT a_sglTagArray(lngBaseRecord), _
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
        ARRAY SORT a_dblTagArray(lngBaseRecord), _
              TAGARRAY a_strWork(), ASCEND
      ELSE
        ARRAY SORT a_dblTagArray(lngBaseRecord), _
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
        ARRAY SORT a_curTagArray(lngBaseRecord), _
              TAGARRAY a_strWork(), ASCEND
      ELSE
        ARRAY SORT a_curTagArray(lngBaseRecord), _
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
        ARRAY SORT a_lngTagArray(lngBaseRecord), _
              TAGARRAY a_strWork(), ASCEND
      ELSE
        ARRAY SORT a_lngTagArray(lngBaseRecord), _
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
        ARRAY SORT a_strTagArray(lngBaseRecord), COLLATE UCASE, _
              TAGARRAY a_strWork(), ASCEND
      ELSE
        ARRAY SORT a_strTagArray(lngBaseRecord), COLLATE UCASE, _
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
