#COMPILE EXE
#DIM ALL
#DEBUG ERROR ON
'
#TOOLS OFF
'
' include the common display library
#INCLUDE "win32api.inc"
#INCLUDE "CommonDisplay.inc"
'

FUNCTION PBMAIN () AS LONG
' the main PB function that is the first to be executed
  funPrepOutput("Array Searching",0,0,40,120)
  '
  funLog("Array Searching")
  '
  ' prepare an array
  DIM a_strData(1 TO 20) AS STRING
  '
  ' populate the array with data
  funPopulateArray(a_strData())
  '
  LOCAL strSearchCriteria AS STRING
  strSearchCriteria = "Prepare to see"
  '
  LOCAL lngLoop AS LONG       ' loop count
  LOCAL lngLoopCount AS LONG  ' Total loops executed
  LOCAL lngMatches AS LONG    ' for number of matches found
  '
  lngLoopCount = 50000
  '
  LOCAL qCycles AS QUAD
  TIX qCycles
  '
  FOR lngLoop = 1 TO lngLoopCount
    lngMatches = funSearchForData(strSearchCriteria,a_strData())
  NEXT lngLoop
  '
  TIX END qCycles
  '
  funLog("Search Cycles = " & FORMAT$(qCycles\lngLoopCount, "#,"))
  funLog("Matches found = " & FORMAT$(lngMatches))
  funLog("")
  '
  ' now use array scan
  TIX qCycles
  '
  FOR lngLoop = 1 TO lngLoopCount
    lngMatches = funScanForData(strSearchCriteria,a_strData())
  NEXT lngLoop

  TIX END qCycles
  funLog("Scan Cycles = " & FORMAT$(qCycles\lngLoopCount, "#,"))
  funLog("Matches found = " & FORMAT$(lngMatches))
  funWait()
  '
END FUNCTION
'
FUNCTION funScanForData(strSearchCriteria AS STRING, _
                        BYREF a_strData() AS STRING) AS LONG
' use array scan for data
  LOCAL lngMatch AS LONG
  LOCAL lngMatches AS LONG   ' count of matches found
  LOCAL lngNextMatch AS LONG ' element of next match
  '
  ARRAY SCAN a_strData(), _
             FROM 1 TO LEN(strSearchCriteria), _
             COLLATE UCASE, = strSearchCriteria, TO lngMatch
             '
  IF lngMatch > 0 THEN
    INCR lngMatches ' record a match
    ' might be more matches ?
    lngNextMatch = lngMatch +1 ' start at next slot
    '
    WHILE lngMatch > 0
    ' scan for matches
      ARRAY SCAN a_strData(lngNextMatch), _
             FROM 1 TO LEN(strSearchCriteria), _
             COLLATE UCASE, = strSearchCriteria, TO lngMatch
             '
      IF lngMatch > 0 THEN
        INCR lngMatches  ' record a match
        lngNextMatch = lngNextMatch + lngMatch
      END IF
      '
    WEND
    '
  END IF
  '
  FUNCTION = lngMatches
  '
END FUNCTION
'
FUNCTION funSearchForData(strSearchCriteria AS STRING, _
                          BYREF a_strData() AS STRING) AS LONG
' search for data in the array
  LOCAL lngRow AS LONG      ' row counter
  LOCAL lngMatches AS LONG  ' count of matches found
  '
  FOR lngRow = 1 TO UBOUND(a_strData)
    'if a_strData(lngRow) = strSearchCriteria then
    'if instr(a_strData(lngRow),strSearchCriteria) > 0 then
    IF UCASE$(LEFT$(a_strData(lngRow),LEN(strSearchCriteria))) = _
                               UCASE$(strSearchCriteria) THEN
      INCR lngMatches
      EXIT FOR
    END IF
  NEXT lngRow
  '
  FUNCTION = lngMatches
  '
END FUNCTION
'
FUNCTION funPopulateArray(BYREF a_strData() AS STRING) AS LONG
' populate the array with data
  ARRAY ASSIGN a_strData() = _
               "we wont look", _
               "we will see", _
               "we will continue", _
               "we shall see", _
               "We will prepare", _
               "Today we will", _
               "Prepare to see", _
               "Start to prepare", _
               "Prepare to configure", _
               "Configure the system", _
               "we will return", _
               "we will need", _
               "we will create", _
               "we will populate", _
               "we will call", _
               "we will link", _
               "we will pick", _
               "we will display", _
               "we will give", _
               "we will start"
'
END FUNCTION
