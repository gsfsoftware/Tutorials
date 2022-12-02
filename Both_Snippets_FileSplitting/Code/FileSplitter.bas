#COMPILE EXE
#DIM ALL
#DEBUG ERROR ON
'
#TOOLS OFF
'
' include the common display library
#INCLUDE "win32api.inc"
#INCLUDE "CommonDisplay.inc"
#INCLUDE "PB_FileHandlingRoutines.inc"
'
FUNCTION PBMAIN () AS LONG
' the main PB function that is the first to be executed
  funPrepOutput("File Splitter",0,0,40,120)
  '
  funLog("File Splitter")
  '
  ' read a file in and split it into smaller files
  LOCAL lngBatchSize AS LONG ' Maximum size of the split files
  lngBatchSize = 1000
  LOCAL strInputFile AS STRING
  strInputFile = EXE.PATH$ & "GenerateData\MyLargeFile.txt"
  '
  funLog("Starting to split file")
  '
  ' split by batch size
  'if istrue funSplitFileByBatchSize(strInputFile,lngBatchSize) then
  '  funLog("File split completed")
  'else
  '  funLog("Failure to split file")
  'end if
  '
  ' split using a data marker
  LOCAL strMarker AS STRING
  LOCAL strColumnName AS STRING
  LOCAL strDelimiter AS STRING
  LOCAL strBeforeAfter AS STRING ' Either "Before" OR "After"
                                 ' used to trigger new file
                                 ' after or before data is written
                                 '
  strMarker = $DQ & "002" & $DQ
  strColumnName = "Zone"
  strDelimiter = $TAB
  strBeforeAfter = "After"
  '
  IF ISTRUE funSplitFileByDataMarker(strInputFile, _
                                     strMarker, _
                                     strDelimiter, _
                                     strColumnName, _
                                     strBeforeAfter) THEN
    funLog("File split completed")
  ELSE
    funLog("Failure to split file")
  END IF

  '
  funWait()
  '
END FUNCTION
'
FUNCTION funSplitFileByDataMarker(strInputFile AS STRING, _
                                  strMarker AS STRING, _
                                  strDelimiter AS STRING, _
                                  strColumnName AS STRING, _
                                  strBeforeAfter AS STRING) AS LONG
' split specified file into smaller files each time
' a value occurs in a specific column
'
  LOCAL lngColumn AS LONG   ' column number containing marker
  '
  LOCAL lngFileInput AS LONG    ' handle of source file
  LOCAL lngFileOutput AS LONG   ' handle of output file/s
  LOCAL lngMaxRecords AS LONG   ' max records in input file
  LOCAL strHeader AS STRING     ' header for each file
  LOCAL strData AS STRING       ' user for data from source file
  LOCAL lngFileCounter AS LONG  ' counter for output files
  LOCAL strOutputFilename AS STRING ' name of the currentr output file
  '
  IF ISFALSE ISFILE(strInputFile) THEN
    funLog("File does not exist")
    EXIT FUNCTION
  END IF
  '
  lngFileInput = FREEFILE
  OPEN strInputFile FOR INPUT AS #lngFileInput
  '
  FILESCAN #lngFileInput, RECORDS TO lngMaxRecords
  '
  IF lngMaxRecords < 1 THEN
    funLog("File has no records")
    EXIT FUNCTION
  END IF
  '
  ' first get the header
  LINE INPUT #lngFileInput,strHeader
  '
  ' check if strMarker exists in the header
  lngColumn = funParseFind(strHeader, _
                           strDelimiter, _
                           strColumnName)
                           '
  IF lngColumn = 0 THEN
  ' check header contains Column name
    funLog(strColumnName & " not found in header")
    EXIT FUNCTION
  END IF
  '
  lngFileCounter = 1       ' set file counter at start
  lngFileOutput = FREEFILE ' get file handle
  ' build output file name
  strOutputFilename = "Output_" & _
                      RIGHT$("0000" & FORMAT$(lngFileCounter),4) & _
                      ".txt"
                      '
  ' open the output file
  funLog("Opening File " & strOutputFilename)
  OPEN EXE.PATH$ & strOutputFilename FOR OUTPUT AS #lngFileOutput
  PRINT #lngFileOutput, strHeader  ' output the header
  '
  WHILE NOT EOF(#lngFileInput)
  ' for each remaining row in the source file
    LINE INPUT #lngFileInput,strData
    '
    IF PARSE$(strData,strDelimiter,lngColumn) = strMarker THEN
    ' a marker line has been found
      ' close the previous filename
      IF strBeforeAfter = "After" THEN
      ' on detecting marker output then close file
        PRINT #lngFileOutput,strData ' output the data line
      END IF
      CLOSE #lngFileOutput
      '
      INCR lngFileCounter      ' advance file counter
      lngFileOutput = FREEFILE ' get file handle
      ' build output file name
      strOutputFilename = "Output_" & _
                          RIGHT$("0000" & FORMAT$(lngFileCounter),4) & _
                          ".txt"
      ' open the output file
      funLog("Opening File " & strOutputFilename)
      OPEN EXE.PATH$ & strOutputFilename FOR OUTPUT AS #lngFileOutput
      PRINT #lngFileOutput, strHeader  ' output the header
      '
      IF strBeforeAfter = "Before" THEN
      ' on detecting marker output when file opened
        PRINT #lngFileOutput,strData     ' and the data line
      END IF
      '
    ELSE
    ' no marker found
      PRINT #lngFileOutput,strData ' output the data line
    END IF
  '
  WEND
  '
  ' close down files
  CLOSE #lngFileOutput
  CLOSE #lngFileInput
  '
  FUNCTION = %TRUE
  '
END FUNCTION
'
FUNCTION funSplitFileByBatchSize(strInputFile AS STRING, _
                                 lngBatchSize AS LONG) AS LONG
' split specified file into smaller files of specified batch size
  LOCAL lngFileInput AS LONG    ' handle of source file
  LOCAL lngFileOutput AS LONG   ' handle of output file/s
  LOCAL lngMaxRecords AS LONG   ' max records in input file
  LOCAL lngLineCount AS LONG    ' line counter
  LOCAL strHeader AS STRING     ' header for each file
  LOCAL strData AS STRING       ' user for data from source file
  LOCAL lngFileCounter AS LONG  ' counter for output files
  LOCAL strOutputFilename AS STRING ' name of the currentr output file
  '
  IF ISFALSE ISFILE(strInputFile) THEN
    funLog("File does not exist")
    EXIT FUNCTION
  END IF
  '
  lngFileInput = FREEFILE
  OPEN strInputFile FOR INPUT AS #lngFileInput
  '
  FILESCAN #lngFileInput, RECORDS TO lngMaxRecords
  '
  IF lngMaxRecords < 1 THEN
    funLog("File has no records")
    EXIT FUNCTION
  END IF
  '
  ' first get the header
  LINE INPUT #lngFileInput,strHeader
  '
  lngFileCounter = 1       ' set file counter at start
  lngFileOutput = FREEFILE ' get file handle
  ' build output file name
  strOutputFilename = "Output_" & _
                      RIGHT$("0000" & FORMAT$(lngFileCounter),4) & _
                      ".txt"
  '
  ' open the output file
  funLog("Opening File " & strOutputFilename)
  OPEN EXE.PATH$ & strOutputFilename FOR OUTPUT AS #lngFileOutput
  PRINT #lngFileOutput, strHeader  ' output the header
  '
  WHILE NOT EOF(#lngFileInput)
  ' for each remaining row in the source file
    LINE INPUT #lngFileInput,strData
    '
    '
    INCR lngLineCount ' advance line counter
    '
    IF lngLineCount > lngBatchSize THEN
    ' close the previous filename
      CLOSE #lngFileOutput
      '
      INCR lngFileCounter      ' advance file counter
      '
      lngFileOutput = FREEFILE ' get file handle
      ' build output file name
      strOutputFilename = "Output_" & _
                          RIGHT$("0000" & FORMAT$(lngFileCounter),4) & _
                          ".txt"
                          '
      ' open the output file
      funLog("Opening File " & strOutputFilename)
      OPEN EXE.PATH$ & strOutputFilename FOR OUTPUT AS #lngFileOutput
      PRINT #lngFileOutput, strHeader  ' output the header
      PRINT #lngFileOutput, strData    ' and the data line
      '
      lngLineCount = 1 ' reset the line counter
      '
    ELSE
    ' not reached the max size of file yet
      PRINT #lngFileOutput,strData ' output the data line
    END IF
    '
  WEND
  '
  ' close down files
  CLOSE #lngFileOutput
  CLOSE #lngFileInput
  '
  FUNCTION = %TRUE
  '
END FUNCTION
