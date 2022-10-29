#COMPILE EXE
#DIM ALL
#DEBUG ERROR ON
'
#TOOLS OFF
'
' include the common display library
#INCLUDE "win32api.inc"
#INCLUDE "..\Libraries\CommonDisplay.inc"
'
' set up the indexing constants
%IndexedSearch = %TRUE      ' use indexed search?
%IndexStart = 1             ' start and end of index
%IndexEnd   = 2             ' for unique character
'
#INCLUDE ONCE "..\Libraries\PB_ArrayFunctions.inc"
'
#INCLUDE ONCE "..\Libraries\PB_FileHandlingRoutines.inc"
'
' set the file names of our two files
$DataFile        = "Data\BigTest_DataFile.csv"
$SmallSearchFile = "Data\SmallTest_DataFile.csv"
'
' set the name of the result output file
$ResultFile = "Data\Output.csv"
'
' prepare two global arrays to hold the data
GLOBAL a_strBigData() AS STRING
GLOBAL a_strSmallData() AS STRING
'
FUNCTION PBMAIN () AS LONG
' the main PB function that is the first to be executed
  funPrepOutput("Search and Compare",0,0,40,120)
  '
  funLog("Search and Compare")
  '
  funLookForMissingRecords()
  '
  funWait()
  '
END FUNCTION
'
FUNCTION funLookForMissingRecords() AS LONG
  funLog "Data loading.."
  '
  IF ISTRUE funReadTheFileIntoAnArray(EXE.PATH$ & $DataFile, _
                                      a_strBigData()) THEN
  ' big file loaded
    funLog "Big data loaded"
    '
    IF ISTRUE funReadTheFileIntoAnArray(EXE.PATH$ & $SmallSearchFile, _
                                        a_strSmallData()) THEN
      funLog "Small data loaded"
      '
      LOCAL qDuration AS QUAD
      qDuration = TIMER
      '
      ' prepare to compare arrays
      LOCAL strDelimiter AS STRING
      LOCAL strUniqueFieldname AS STRING
      LOCAL strComparisonType AS STRING
      LOCAL strError AS STRING
      LOCAL lngDimensions AS LONG
      DIM a_strReportData() AS STRING
      '
      strDelimiter = ","
      strUniqueFieldname = "Email"
      strComparisonType = "Missing"
      lngDimensions = 1
      '
      IF ISTRUE funIndexArrayCompare(a_strSmallData(), _
                                     a_strBigData(), _
                                     a_strReportData(), _
                                     strDelimiter, _
                                     strUniqueFieldname,_
                                     strComparisonType, _
                                     strError, _
                                     lngDimensions) THEN
                                     '
        ' save a_strReportData() to file
        LOCAL strExistingDelimiter AS STRING
        LOCAL strNewDelimiter AS STRING
        '
        strNewDelimiter = ","
        strExistingDelimiter = ","
        '
        funArraySave_1D(EXE.PATH$ & $ResultFile, _
                         a_strReportData(), _
                         strExistingDelimiter, _
                         strNewDelimiter)
                         '
      ELSE
        funLog "Error occurred - " & strError
      END IF
      '
      qDuration = TIMER - qDuration
      funLog("This took " & FORMAT$(qDuration) & " seconds to run")
      '
    ELSE
      funLog "Unable to load small data"
      FUNCTION = %FALSE
    END IF
    '
  ELSE
    funLog "Unable to load Big data"
    FUNCTION = %FALSE
  END IF

END FUNCTION
