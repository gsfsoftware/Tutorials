#COMPILE EXE
#DIM ALL
#DEBUG ERROR ON
'
#TOOLS OFF
'
' include the common display library
#INCLUDE "win32api.inc"
#INCLUDE "..\Libraries\CommonDisplay.inc"
#INCLUDE "..\Libraries\PB_FileHandlingRoutines.inc"
'
%IndexedSearch = %TRUE      ' flag for indexed search
%IndexStart = 1             ' start and end of index
%IndexEnd   = 2             ' for unique character
'
#INCLUDE "..\Libraries\PB_ArrayFunctions.inc"
#INCLUDE "..\Libraries\PB_Sorting.inc"
'
' set up constants for the files to load
$MainFile = "Test_DataFile.csv"
$OtherFile = "Test_DataFile_Other.csv"
'
$Differences = "MissingRecords.csv"
'
FUNCTION PBMAIN () AS LONG
' the main PB function that is the first to be executed
  funPrepOutput("Indexed Array Search",0,0,40,120)
  '
  funLog("Indexed Array Search")
  '
  ' load files into a 1 dimensional array
  ' and report on them
  funSearchOutDifferences(EXE.PATH$ & $MainFile, _
                          EXE.PATH$ & $OtherFile)
  '
  funWait()
  '
END FUNCTION
'
FUNCTION funSearchOutDifferences(strMainFile AS STRING, _
                                 strOtherFile AS STRING) AS LONG
' compare two files and report
  ' load both files into 1 dimensional arrays
  DIM a_strMainFile() AS STRING      ' main file
  DIM a_strOtherFile() AS STRING     ' other file
  '
  DIM a_strReportData() AS STRING    ' data removed
  '
  LOCAL strDelimiter AS STRING       ' delimeter in files
  LOCAL strUniqueFieldname AS STRING ' name of unique field in header
  LOCAL strError AS STRING           ' any error on the comparison
  LOCAL strComparisonType AS STRING  ' type of comparison to do
  LOCAL lngDimensions AS LONG        ' number of dimensions in array
  LOCAL qTimer AS QUAD               ' timer
  '
  ' load a 1 dimensional array
  IF ISTRUE funReadTheFileIntoAnArray(strMainFile, _
                                BYREF a_strMainFile()) THEN
    funLog("Main File loaded")
    '
    IF ISTRUE funReadTheFileIntoAnArray(strOtherFile, _
                                BYREF a_strOtherFile()) THEN
      funLog("Smaller File loaded")
      '
      ' ready to compare the two arrays now
      strUniqueFieldname = "Email"
      strDelimiter = ""
      strError = ""
      strComparisonType = "Missing"
      lngDimensions = ARRAYATTR(a_strMainFile(),3)
      '
      qTimer = TIMER                 ' pick up time
      '
      funLog("Comparing Arrays")
      IF ISTRUE funIndexArrayCompare(a_strMainFile(), _
                                     a_strOtherFile(), _
                                     a_strReportData(), _
                                     strDelimiter, _
                                     strUniqueFieldname,_
                                     strComparisonType, _
                                     strError, _
                                     lngDimensions) THEN
      '
      ' save the report
        funArrayDump(EXE.PATH$ & $Differences, _
                     BYREF a_strReportData())
        ' and report on duration
        funLog("Duration = " & FORMAT$(TIMER - qTimer) & " seconds")
      ELSE
        funLog("Failure to compare" & $CRLF & strError)
      END IF
      '
    ELSE
      funLog("Smaller File not loaded")
    END IF

  ELSE
    funLog("Main File not loaded")
  END IF
'
END FUNCTION
'
