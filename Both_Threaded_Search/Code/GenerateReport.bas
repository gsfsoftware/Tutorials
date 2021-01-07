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
GLOBAL ga_strWork() AS STRING
$ExtractFile = "ExtractFile.txt"
$NewFile = "Updated_CurrentEmails_"
$CurrentData = "MyLargeFile.txt"
'
%StartSection  = 1
%TotalSections = 10
%MaxBlockSize = 5000
%RunThreaded = %TRUE
'
FUNCTION PBMAIN () AS LONG
' the main PB function that is the first to be executed
  funPrepOutput("Threaded File Processing",0,0,40,120)
  '
  funLog("Threaded File Processing")
  '
  LOCAL qDuration AS QUAD
  qDuration = TIMER
  '
  LOCAL lngSection AS LONG
  '
  #IF %DEF(%RunThreaded)
    DIM idThread(1 TO %TotalSections) AS LONG
    DIM idThreadStatus(1 TO %TotalSections) AS LONG
  #ENDIF

  IF ISTRUE funReadTheFileIntoAnArray(EXE.PATH$ & $ExtractFile, _
                                      BYREF ga_strWork()) THEN
  '
  TRY
    KILL EXE.PATH$ & $NewFile & "*.txt"
  CATCH
  FINALLY
  END TRY
  '
  #IF %DEF(%RunThreaded)
     FOR lngSection = %StartSection TO %TotalSections
       THREAD CREATE funProcessFileSection(lngSection) _
                     TO idThread(lngSection)
     NEXT lngSection
  #ELSE
    FOR lngSection = %StartSection TO %TotalSections
      funProcessFileSection(lngSection)
    NEXT lngSection
  #ENDIF
  '
  ELSE
  ' unable to read file
  END IF
  '
  #IF %DEF(%RunThreaded)
  ' what happens now?
  ' are they all finished?
    funWaitForThreads(%TotalSections, idThread(), 1)
  #ENDIF
  '
  qDuration = TIMER - qDuration
  funLog("This took " & FORMAT$(qDuration) & " seconds to run")
  '
  '
  funWait()
  '
END FUNCTION
'
#IF %DEF(%RunThreaded)
  THREAD FUNCTION funProcessFileSection(BYVAL lngSection AS LONG) AS LONG
#ELSE
  FUNCTION funProcessFileSection(lngSection AS LONG) AS LONG
#ENDIF

' process the section
  LOCAL lngFileIn AS LONG
  LOCAL lngFileOut AS LONG
  LOCAL lngCount AS LONG
  LOCAL lngStart AS LONG
  LOCAL lngEnd AS LONG
  LOCAL lngProcessed AS LONG
  LOCAL strHeaders AS STRING
  LOCAL strCurrentEmail AS STRING
  LOCAL strNewEmail AS STRING
  LOCAL strData AS STRING
  '
  ' calculate the row to start at
  lngStart = (lngSection * %MaxBlockSize) - (%MaxBlockSize -1)
  lngEnd = lngStart + %MaxBlockSize - 1
  '
  lngFileIn = FREEFILE
  OPEN EXE.PATH$ & $CurrentData FOR INPUT LOCK SHARED AS #lngFileIn
  lngFileOut = FREEFILE
  OPEN EXE.PATH$ & $NewFile & FORMAT$(lngSection) & ".txt" FOR OUTPUT AS #lngFileOut
  WHILE NOT EOF(#lngFileIn)
    LINE INPUT #lngFileIn, strData
    INCR lngCount
    '
    IF lngCount = 1 THEN
      strHeaders = strData
      ITERATE LOOP
    END IF
    '
    IF lngCount < lngStart THEN
      ITERATE LOOP
    ELSE
      INCR lngProcessed
      IF lngProcessed MOD 200 = 0 THEN
        funlog("Section " & FORMAT$(lngSection) & " Record " & FORMAT$(lngProcessed))
      END IF
      '
      IF lngCount > lngEnd THEN
        EXIT LOOP
      ELSE
        IF lngProcessed = 1 THEN
          PRINT #lngFileOut, strHeaders & $TAB & "New_email"
        END IF
        '
        strCurrentEmail = PARSE$(strData,$TAB,7)
        strNewEmail = funFindNewEmail(strCurrentEmail)
        '
        IF strNewEmail <> "" THEN
          PRINT #lngFileOut, strData & $TAB & strNewEmail
        END IF
      END IF
    END IF
    '
  WEND
  '
  CLOSE #lngFileIn
  CLOSE #lngFileOut
  '
END FUNCTION
'
FUNCTION funFindNewEmail(strCurrentEmail AS STRING) AS STRING
' find the new email
  LOCAL lngR AS LONG
  FOR lngR = 1 TO UBOUND(ga_strWork)
    IF UCASE$(strCurrentEmail) = UCASE$(PARSE$(ga_strWork(lngR),$TAB,1)) THEN
      FUNCTION = PARSE$(ga_strWork(lngR),$TAB,2)
      EXIT FUNCTION
    END IF
  NEXT lngR
  '
  FUNCTION = ""
  '
END FUNCTION
'
FUNCTION funWaitForThreads(ThreadToWaitFor AS LONG, hThread() AS LONG, _
                           StartThreadIndex AS LONG) AS LONG
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
 LOCAL zBuffer AS ASCIIZ * 1024

 FormatMessage(%FORMAT_MESSAGE_FROM_SYSTEM, BYVAL %NULL, ErrorIndex, %NULL, ZBuffer, SIZEOF(ZBuffer), BYVAL %NULL)
 REPLACE $CRLF WITH $SPC IN zBuffer
 FUNCTION = "Error" & STR$(ErrorIndex) & ": " & zBuffer

END FUNCTION
