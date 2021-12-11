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
' set the file names of our two files
$DataFile = "BigDataFile.txt"
$SmallSearchFile = "SmallDataFile.txt"
' set the name of the results files
$ResultFile = "Results"
'
' set the maximum number of records to create
%MaxRecords = 2000000
'
%StartSection  = 1     ' start section number
%TotalSections = 10    ' total number of sections/threads
%RunThreaded = %TRUE   ' if defined then run in threaded mode
'                        otherwise comment out to run in non threaded
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
  ' first build the files
  'funBuildFiles() ' comment this in to initially create the files
  funLoadAndCompareFiles()  ' load and compare files
  '
  funWait()
  '
END FUNCTION
'
FUNCTION funLoadAndCompareFiles() AS LONG
' compare the two arrays
  LOCAL lngSection AS LONG
  '
  #IF %DEF(%RunThreaded)
  ' handle multi threading
    DIM idThread(1 TO %TotalSections) AS LONG
    DIM idThreadStatus(1 TO %TotalSections) AS LONG
  #ENDIF
  '
  funLog "Data loading.."
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
      ' now compare it
      #IF %DEF(%RunThreaded)
      ' if threaded create a thread for each section
        FOR lngSection = 1 TO %TotalSections
          THREAD CREATE funCompareFiles(lngSection) _
                         TO idThread(lngSection)
        NEXT lngSection
        '
      #ELSE
      ' run unthreaded
        FOR lngSection = 1 TO %TotalSections
          funCompareFiles(lngSection)
        NEXT lngSection
      #ENDIF
      '
      #IF %DEF(%RunThreaded)
      ' if running threads - what happens now?
      ' are they all finished?
        funWaitForThreads(%TotalSections, idThread(), 1)
      #ENDIF
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
'
' define function dependant on the definition of the %RunThreaded constant
#IF %DEF(%RunThreaded)
' compile as threaded
  THREAD FUNCTION funCompareFiles(BYVAL lngSection AS LONG) AS LONG
#ELSE
' compile as unthreaded
  FUNCTION funCompareFiles(lngSection AS LONG) AS LONG
#ENDIF
'
  LOCAL lngR AS LONG
  LOCAL lngI AS LONG
  LOCAL strSmallGUID AS STRING
  LOCAL lngLength AS LONG
  '
  LOCAL lngFileOut AS LONG
  LOCAL strFilename AS STRING
  '
  LOCAL lngStart AS LONG
  LOCAL lngEnd AS LONG
  LOCAL lngBlockSize AS LONG
  '
  funLog "Scanning for matches in Section " & _
           FORMAT$(lngSection) & $CRLF
           '
  lngFileOut = FREEFILE
  '
  strFilename = EXE.PATH$ & $ResultFile & "_" & _
                FORMAT$(lngSection) & ".txt"
  '
  OPEN strFilename FOR OUTPUT AS #lngFileOut
  '
  '  capture the length of the small data GUID
  lngLength = LEN(a_strSmallData(1))
  '
   ' calculate the row to start at
  lngBlockSize = (UBOUND(a_strSmallData)\%TotalSections)
  lngStart = (lngSection -1) * lngBlockSize +1
  '
  ' work out where the block ends
  IF lngSection = %TotalSections THEN
  ' doing the last section
    lngEnd = UBOUND(a_strSmallData)
  ELSE
  ' doing something other than the last section
    lngEnd = lngStart + lngBlockSize - 1
  END IF
  '
  FOR lngR = lngStart TO lngEnd
  ' for each record in this section
    ' pick up the GUID we will be searching for
    strSmallGUID = a_strSmallData(lngR)
    '
    ' does this exist in the Big array?
    ARRAY SCAN a_strBigData(), FROM 1 TO lngLength, = strSmallGUID, TO lngI
    '
    IF lngI > 0 THEN
    ' we found the record
      PRINT #lngFileOut, strSmallGUID,lngI
    END IF
    '
  NEXT lngR
  '
  CLOSE #lngFileOut
  '
  funLog "Scanning for matches completed in section "& _
          FORMAT$(lngSection)
          '

END FUNCTION
'
FUNCTION funBuildFiles() AS LONG
' build a large file with data
' and a subset of this data in the
' second file
  LOCAL strGUID AS STRING
  LOCAL lngR AS LONG
  LOCAL lngFileOutBig AS LONG
  LOCAL lngFileOutSmall AS LONG
  '
  funLog "Building the files"
  '
  lngFileOutBig = FREEFILE
  OPEN EXE.PATH$ & $DataFile FOR OUTPUT AS #lngFileOutBig
  lngFileOutSmall = FREEFILE
  OPEN EXE.PATH$ & $SmallSearchFile FOR OUTPUT AS #lngFileOutSmall
  '
  FOR lngR = 1 TO %MaxRecords
    strGUID = GUIDTXT$(GUID$)
    PRINT #lngFileOutBig,strGUID & "," & TIME$
    '
    IF RND(1,1000) = 12 THEN
      PRINT #lngFileOutSmall,strGUID
    END IF
    '
  NEXT lngR
  '
  CLOSE #lngFileOutBig
  CLOSE #lngFileOutSmall
  '
END FUNCTION
'
FUNCTION funWaitForThreads(ThreadToWaitFor AS LONG, hThread() AS LONG, _
                           StartThreadIndex AS LONG) AS LONG
' wait till all threads whose handles are in the array have been completed
  LOCAL Looper           AS LONG
  LOCAL RetVal           AS LONG
  LOCAL TotalThreadCount AS LONG
  LOCAL LastError        AS LONG
  LOCAL ThreadBatch      AS LONG

  '
  DO
    ThreadBatch = MIN(%MAXIMUM_WAIT_OBJECTS, ThreadToWaitFor) 'Do wait for a batch of threads
    RetVal = WaitForMultipleObjects(ThreadBatch, _ 'MAXIMUM_WAIT_OBJECTS = 64
                                  BYVAL VARPTR(hThread(StartThreadIndex)), _
                                  %TRUE, %INFINITE)
    LastError = GetLastError 'Check if success or if an error occured
    SELECT CASE RetVal
      CASE %WAIT_OBJECT_0    : IF 01 THEN 'Use zero to bypass following status MessageBox
                               funLog("Total threads" & STR$(TotalThreadCount) & $CRLF & _
                               "Current group size is" & STR$(ThreadBatch)     & $CRLF & _
                               "Thread index " & STR$(StartThreadIndex) & " to " & _
                               STR$(StartThreadIndex + ThreadBatch - 1) & " done...")
                             END IF
      CASE %WAIT_ABANDONED_0
        funLog("WAIT_ABANDONED_0")
      CASE %WAIT_TIMEOUT
        funLog("WAIT_TIMEOUT")
      CASE %WAIT_FAILED
        funLog(WinError$(LastError))
      CASE ELSE
        funLog(WinError$(LastError))
    END SELECT
    '
    StartThreadIndex += %MAXIMUM_WAIT_OBJECTS
    ThreadToWaitFor  -= %MAXIMUM_WAIT_OBJECTS
  LOOP WHILE ThreadToWaitFor > 0
  '
END FUNCTION
'
FUNCTION WinError$(BYVAL ErrorIndex AS LONG) AS STRING
' handle any errors
 LOCAL zBuffer AS ASCIIZ * 1024

 FormatMessage(%FORMAT_MESSAGE_FROM_SYSTEM, BYVAL %NULL, ErrorIndex, %NULL, ZBuffer, SIZEOF(ZBuffer), BYVAL %NULL)
 REPLACE $CRLF WITH $SPC IN zBuffer
 FUNCTION = "Error" & STR$(ErrorIndex) & ": " & zBuffer

END FUNCTION
