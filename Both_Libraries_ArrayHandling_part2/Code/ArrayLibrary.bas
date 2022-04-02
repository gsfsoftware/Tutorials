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
#INCLUDE "..\Libraries\PB_ArrayFunctions.inc"
'
' set up constants for the files to load
$YesterdayFile_text = "Yesterday_File.txt"
$YesterdayFile_csv  = "Yesterday_File.csv"
'
$TodayFile_text     = "Today_File.txt"
$TodayFile_csv      = "Today_File.csv"
'
FUNCTION PBMAIN () AS LONG
' the main PB function that is the first to be executed
  funPrepOutput("Array Library  - differences",0,0,40,120)
  '
  funLog("Array Library  - differences")
  '
  ' load files into a 1 dimensional array
  ' and report on them
  funLoad_a_1Dfile(EXE.PATH$ & $YesterdayFile_text, _
                   EXE.PATH$ & $TodayFile_text)
  '
  ' load files into a 2 dimensional array
  ' and report on them
  funLoad_a_2DFile(EXE.PATH$ & $YesterdayFile_csv, _
                   EXE.PATH$ & $TodayFile_csv)
  '
  funWait()
  '
END FUNCTION
'
FUNCTION funLoad_a_2Dfile(strYesterdayFile AS STRING, _
                          strTodayFile AS STRING) AS LONG
' load both files into 2 dimensional arrays
  DIM a_strYesterdayData() AS STRING ' yesterdays file
  DIM a_strTodayData() AS STRING     ' todays file
  '
  DIM a_strAddedData() AS STRING     ' data added today
  DIM a_strAmendedData() AS STRING   ' data amended today
  DIM a_strRemovedData() AS STRING   ' data removed today
  '
  LOCAL strDelimiter AS STRING       ' delimeter in files
  LOCAL strUniqueFieldname AS STRING ' name of unique field in header
  '
  LOCAL strError AS STRING           ' any error on the comparison
  '
  ' load a 2 dimensional array
  IF ISTRUE funReadTheCSVFileIntoAnArray(strYesterdayFile, _
                                BYREF a_strYesterdayData()) THEN
    funLog("Yesterdays File loaded")
    '
    IF ISTRUE funReadTheCSVFileIntoAnArray(strTodayFile, _
                                  BYREF a_strTodayData()) THEN
      funLog("Todays File loaded")
      '
       ' ready to compare the two arrays now
      strUniqueFieldname = "Account"
      strDelimiter = ""
      strError = ""
      '
      IF ISTRUE funArrayCompare(a_strYesterdayData(), _
                                a_strTodayData(), _
                                a_strAddedData(), _
                                a_strAmendedData(), _
                                a_strRemovedData(), _
                                strDelimiter, _
                                strUniqueFieldname,_
                                strError) THEN
                                '
       ' arrays now compared - so save results to disk
        IF ISTRUE funArraySave_2D(EXE.PATH$ & "AddedData.csv" , _
                     BYREF a_strAddedData(),",",1) THEN
          funLog("Added data file saved")
        END IF
        '
        IF ISTRUE funArraySave_2D(EXE.PATH$ & "AmendedData.csv" , _
                     BYREF a_strAmendedData(),",",1) THEN
          funLog("Amended data file saved")
        END IF
        '
        IF ISTRUE funArraySave_2D(EXE.PATH$ & "RemovedData.csv" , _
                     BYREF a_strRemovedData(),",",1) THEN
          funLog("Removed data file saved")
        END IF
        '
        ELSE
        funLog("Error in comparing arrays " & strError)
      END IF
      '
    ELSE
      funLog("Todays File not loaded")
    END IF
  ELSE
    funLog("Yesterdays File not loaded")
  END IF
END FUNCTION
'
FUNCTION funLoad_a_1Dfile(strYesterdayFile AS STRING, _
                          strTodayFile AS STRING) AS LONG
' load both files into 1 dimensional arrays
  DIM a_strYesterdayData() AS STRING ' yesterdays file
  DIM a_strTodayData() AS STRING     ' todays file
  '
  DIM a_strAddedData() AS STRING     ' data added today
  DIM a_strAmendedData() AS STRING   ' data amended today
  DIM a_strRemovedData() AS STRING   ' data removed today
  '
  LOCAL strDelimiter AS STRING       ' delimeter in files
  LOCAL strUniqueFieldname AS STRING ' name of unique field in header
  '
  LOCAL strError AS STRING           ' any error on the comparison
  '
  ' load a 1 dimensional array
  IF ISTRUE funReadTheFileIntoAnArray(strYesterdayFile, _
                                BYREF a_strYesterdayData()) THEN
    funLog("Yesterdays File loaded")
    '
    IF ISTRUE funReadTheFileIntoAnArray(strTodayFile, _
                                  BYREF a_strTodayData()) THEN
      funLog("Todays File loaded")
      '
       ' ready to compare the two arrays now
      strUniqueFieldname = "Account"
      strDelimiter = "|"
      strError = ""
      '
      IF ISTRUE funArrayCompare(a_strYesterdayData(), _
                                a_strTodayData(), _
                                a_strAddedData(), _
                                a_strAmendedData(), _
                                a_strRemovedData(), _
                                strDelimiter, _
                                strUniqueFieldname,_
                                strError) THEN
                                '
       ' arrays now compared - so save results to disk
        IF ISTRUE funArrayDump(EXE.PATH$ & "AddedData.txt" , _
                     BYREF a_strAddedData()) THEN
          funLog("Added data file saved")
        END IF
        '
        IF ISTRUE funArrayDump(EXE.PATH$ & "AmendedData.txt" , _
                     BYREF a_strAmendedData()) THEN
          funLog("Amended data file saved")
        END IF
        '
        IF ISTRUE funArrayDump(EXE.PATH$ & "RemovedData.txt" , _
                     BYREF a_strRemovedData()) THEN
          funLog("Removed data file saved")
        END IF
        '
        ELSE
        funLog("Error in comparing arrays " & strError)
      END IF
      '
    ELSE
      funLog("Todays File not loaded")
    END IF
  ELSE
    funLog("Yesterdays File not loaded")
  END IF
END FUNCTION
