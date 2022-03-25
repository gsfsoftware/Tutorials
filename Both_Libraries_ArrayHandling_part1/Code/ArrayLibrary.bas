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

FUNCTION PBMAIN () AS LONG
' the main PB function that is the first to be executed
  funPrepOutput("Array Library",0,0,40,120)
  '
  funLog("Array Library")
  '
   ' load a file into a 1 dimensional array
  ' and save as CSV format
  funLoad_a_1Dfile(EXE.PATH$ & "1dFile.txt")
  '
  ' load a CSV file into a 2 dimensional array
  ' and save as CSV format
  funLoad_a_2Dfile(EXE.PATH$ & "1dFile.CSV")
  '
  ' load a txt file into an 1 dimensional array
  ' clone the array and save it to disk
  funCopy_An_Array1D(EXE.PATH$ & "1dFile.txt")
  '
  ' load a CSV file into a 2 dimensional array
  ' clone the array and save it to disk
  funCopy_An_Array2D(EXE.PATH$ & "2dFile.csv")
  '
  funWait()
  '
END FUNCTION
'
FUNCTION funCopy_An_Array2D(strFilename AS STRING) AS LONG
' load an array then copy it
  DIM a_strData() AS STRING
  DIM a_strCopy() AS STRING
  LOCAL strError AS STRING
  LOCAL strSavedFile AS STRING
  LOCAL strJustFilename AS STRING
  '
  ' get just the filename excluding the path
  strJustFilename = PARSE$(strFilename,"\",-1)
  '
  strSavedFile = "ClonedArray_" & strJustFilename
  '
  IF ISTRUE funReadTheCSVFileIntoAnArray(strFilename, _
                                      BYREF a_strData()) THEN
    ' report that the file has been loaded - with filename
    funLog("2D Source array loaded - " & strJustFilename)
    ' now copy it
    IF ISTRUE funCloneArray(BYREF a_strData(), _
                            BYREF a_strCopy(), _
                            strError) THEN
    ' array has been copied
      funLog("Array copied successfully")
      '
      IF ISTRUE funArraySave_2D(strSavedFile, _
                         BYREF a_strCopy(), _
                         ",") THEN
        funLog("2D Cloned Array saved successfully")
      ELSE
        funLog("Failure to save Cloned array")
      END IF
      '
    ELSE
      funLog("Failure to copy array with error = " & strError)
    END IF
    '
  ELSE
    funLog("Unable to load source array")
  END IF
END FUNCTION
'
FUNCTION funCopy_An_Array1D(strFilename AS STRING) AS LONG
' load an array then copy it
  DIM a_strData() AS STRING
  DIM a_strCopy() AS STRING
  LOCAL strError AS STRING
  LOCAL strSavedFile AS STRING
  LOCAL strJustFilename AS STRING
  '
  ' get just the filename excluding the path
  strJustFilename = PARSE$(strFilename,"\",-1)
  '
  strSavedFile = "ClonedArray_" & strJustFilename
  '
  IF ISTRUE funReadTheFileIntoAnArray(strFilename, _
                                      BYREF a_strData()) THEN
    ' report that the file has been loaded - with filename
    funLog("1D Source array loaded - " & strJustFilename)
    ' now copy it
    IF ISTRUE funCloneArray(BYREF a_strData(), _
                            BYREF a_strCopy(), _
                            strError) THEN
    ' array has been copied
      funLog("Array copied successfully")
      IF ISTRUE funArrayDump(EXE.PATH$ & strSavedFile, _
                             BYREF a_strCopy()) THEN
        funLog("1D Cloned Array saved successfully")
      ELSE
        funLog("Failure to save Cloned array")
      END IF
      '
    ELSE
      funLog("Failure to copy array with error = " & strError)
    END IF
    '
  ELSE
    funLog("Unable to load source array")
  END IF

END FUNCTION
'
FUNCTION funLoad_a_2Dfile(strFilename AS STRING) AS LONG
' load file into a 2 dimensional array
  DIM a_strData() AS STRING
  LOCAL strDelimiter AS STRING
  '
  IF ISTRUE funReadTheCSVFileIntoAnArray(strFilename, _
                                         BYREF a_strData()) THEN
    funLog("2D File loaded")
    '
     ' save the file to CSV format
    strFilename = EXE.PATH$ & "2dFile.csv"
    strDelimiter = ","
    '
    IF ISTRUE funArraySave_2D(strFilename, _
                         BYREF a_strData(), _
                         strDelimiter) THEN
      FUNCTION = %TRUE
      funLog("2D CSV File saved")
    ELSE
      funLog("unable to save file")
    END IF
    '
  ELSE
    funLog("unable to load file")
  END IF
  '
END FUNCTION
'
FUNCTION funLoad_a_1Dfile(strFilename AS STRING) AS LONG
' load a file into a 1 dimensional array
  DIM a_strData() AS STRING
  LOCAL strExistingDelimiter AS STRING
  LOCAL strNewDelimiter AS STRING
  '
  ' load a 1 dimensional array
  IF ISTRUE funReadTheFileIntoAnArray(strFilename, _
                                      BYREF a_strData()) THEN
    funLog("1D File loaded")
    ' save the file to CSV format
    strFilename = EXE.PATH$ & "1dFile.csv"
    strExistingDelimiter = "|"
    strNewDelimiter      = ","
    '
    IF ISTRUE funArraySave_1D(strFilename, _
                         BYREF a_strData(), _
                         strExistingDelimiter, _
                         strNewDelimiter) THEN
      FUNCTION = %TRUE
      funLog("1D CSV File saved")
    ELSE
      funLog("unable to save file")
    END IF
    '
  ELSE
    funLog("unable to load file")
  END IF
  '
END FUNCTION
