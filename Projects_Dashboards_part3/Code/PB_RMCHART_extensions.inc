' PB_RMCHART_extensions.inc
' this library has additional functions to extend RMChart functionality
'
FUNCTION funGetDivisionNames(strFilename AS STRING) AS STRING
' get the incident Division names
  LOCAL lngR AS LONG
  DIM a_strWork() AS STRING
  LOCAL strDivisionNames AS STRING
  '
  IF ISTRUE funReadTheCSVFileIntoAnArray(strFilename, _
                               BYREF a_strWork()) THEN
    FOR lngR = 1 TO UBOUND(a_strWork)
      strDivisionNames = strDivisionNames & a_strWork(lngR,1) & "*"
    NEXT lngR
    '
    strDivisionNames = RTRIM$(strDivisionNames,"*")
    FUNCTION = strDivisionNames
    '
  ELSE
    FUNCTION = ""
  END IF
'
END FUNCTION
'
FUNCTION funGetDivisionValues(strFilename AS STRING, _
                              BYREF aData() AS DOUBLE) AS LONG
' get the values for division incidents
  LOCAL lngR AS LONG
  DIM a_strWork() AS STRING
  LOCAL strDivisionNames AS STRING
  '
  IF ISTRUE funReadTheCSVFileIntoAnArray(strFilename, _
                               BYREF a_strWork()) THEN
    ' resize the array
    REDIM aData(0 TO UBOUND(a_strWork)) AS DOUBLE
    '
    FOR lngR = 1 TO UBOUND(a_strWork)
      aData(lngR-1) = VAL(a_strWork(lngR,2))
    NEXT lngR
    '
    FUNCTION = %TRUE
    '
  ELSE
    FUNCTION = %FALSE
  END IF
  '
END FUNCTION
'
FUNCTION funGetFixedColours(BYREF aColor() AS LONG, _
                            lngElements AS LONG, _
                            strFilename AS STRING) AS LONG
' get a fixed list of colours
  LOCAL lngC AS LONG
  REDIM aColor(lngElements)
  DIM a_strWork() AS STRING
  '
  IF ISTRUE funReadTheFileIntoAnArray(strFilename, _
                               BYREF a_strWork()) THEN
    FOR lngC = 0 TO UBOUND(aColor)
      aColor(lngC) = VAL(PARSE$(a_strWork(lngC),"=",2))
    NEXT lngC
    '
    FUNCTION = %TRUE
  ELSE
    FUNCTION = %FALSE
  END IF
  '
END FUNCTION
'
FUNCTION funGetRandomColours(BYREF aColor() AS LONG, _
                       lngElements AS LONG, _
                       lngStartColour AS LONG) AS LONG
  ' load colours randomly
  LOCAL lngC AS LONG
  REDIM aColor(lngElements)
  DIM a_strWork() AS STRING
  LOCAL lngR AS LONG
  LOCAL lngE AS LONG
  '
  RANDOMIZE TIMER
  '
  IF ISTRUE funReadTheFileIntoAnArray("Colours.txt", _
                               BYREF a_strWork()) THEN
  ' got the file so pick the colours now
    aColor(0) = lngStartColour
    '
    FOR lngC = 1 TO UBOUND(aColor)
      lngE = RND(1,UBOUND(a_strWork))
      '
      aColor(lngC) = VAL(PARSE$(a_strWork(lngE),"=",2))
    NEXT lngC
    '
    FUNCTION = %TRUE
  ELSE
  ' file not found
    FUNCTION = %TRUE
  END IF
  '
END FUNCTION
