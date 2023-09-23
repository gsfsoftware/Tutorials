'
'  pb_file.inc
'
'   Public domain files from Don Dickinson
'   don@greatwebdivide.com
'
'  PB-32bit misc file routines
'
'  Function FileDate(ByVal sFileName as String, ByVal sFormat as String as String
'  Function FileSize(ByVal sFileName as String) as Long
'  Function FileExists(sFile As String) As Long
'  Function ExtractPath (zFullFile As String) As String
'  Function ExtractFileName(zFillFile as String) as String
'  Function GetExeName() As String
'  Function GetModuleName(ByVal sModule as String) as String
'  Function GetTempFile(ByVal sSeed, ByVal sExt as String) As String
'  Function GetFileDateTime(sFileName as String) as String
'  Function GetFileSize(sFileName as String) as String
'  Function GetWindowsDir() as String
'  Function GetSystemDir() as String
'  Function GetTemporaryDir() as String
'  Sub DeleteFileSpec(ByVal sFileSpec As String)
'  Sub EnsureDirectoryExists(ByVal sFileName As String)
'  Function pbWriteFile(filename,filedata) as Long
'  Function ShellDocument(filename)
'
'  DEPENDS UPON
'     win32api.inc
'

#IF NOT %DEF(%PB_FILE_INC)
%PB_FILE_INC = 1

#IF NOT %DEF(%WINAPI)
#INCLUDE "win32api.inc"
#ENDIF
#INCLUDE "pb_doeve.inc"
#INCLUDE "pb_mem.inc"
#INCLUDE "pb_mtx.inc"

GLOBAL g_pb_file_LastError AS STRING

'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
'  pbFileLastError
'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
FUNCTION pbFileLastError ALIAS "pbFileLastError" EXPORT AS STRING

   FUNCTION = g_pb_file_LastError

END FUNCTION

'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
'  FileDate
'
'  Returns file date as a string formatted in the specified manner.
'  This is the date which the file was last written to.
'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
FUNCTION FileDate ALIAS "FileDate" _
      ( BYVAL sFileName AS STRING, BYVAL sFormat AS STRING) EXPORT AS STRING

   DIM hFind AS LONG
   DIM ampm AS STRING
   DIM rData AS WIN32_FIND_DATA
   DIM rTime AS SYSTEMTIME

   hFind = FindFirstFile(sFileName & $NUL, rData)
   IF hFind = %INVALID_HANDLE_VALUE THEN
      FUNCTION = "n/a"
   ELSE
      FileTimeToSystemTime rData.ftLastWriteTime, rTime

      sFormat = UCASE$(sFormat)
      IF INSTR(sFormat, "A/P") > 0 THEN
         IF rTime.wHour > 12 THEN
            rTime.wHour = rTime.wHour - 12
            ampm = "p"
         ELSEIF rTime.wHour = 12 THEN
            ampm = "p"
         ELSE
            ampm = "a"
         END IF

      ELSEIF INSTR(sFormat, "AM/PM") > 0 THEN
         IF rTime.wHour > 12 THEN
            rTime.wHour = rTime.wHour - 12
            ampm = "pm"
         ELSEIF rTime.wHour = 12 THEN
            ampm = "pm"
         ELSE
            ampm = "am"
         END IF
      ELSE
         ampm = ""
      END IF

      IF LEN(ampm) > 0 THEN
         REPLACE "A/P" WITH ampm IN sFormat
         REPLACE "AM/PM" WITH ampm IN sFormat
      END IF

      REPLACE "YYYY" WITH FORMAT$(rTime.wYear, "0000") IN sFormat
      REPLACE "YY" WITH RIGHT$(FORMAT$(rTime.wYear, "0000"), 2) IN sFormat
      REPLACE "MM" WITH FORMAT$(rTime.wMonth, "00") IN sFormat
      REPLACE "M" WITH FORMAT$(rTime.wMonth, "0") IN sFormat
      REPLACE "DD" WITH FORMAT$(rTime.wDay, "00") IN sFormat
      REPLACE "D" WITH FORMAT$(rTime.wDay) IN sFormat
      REPLACE "HH" WITH FORMAT$(rTime.wHour, "00") IN sFormat
      REPLACE "H" WITH FORMAT$(rTime.wHour) IN sFormat
      REPLACE "NN" WITH FORMAT$(rTime.wMinute, "00") IN sFormat
      REPLACE "N" WITH FORMAT$(rTime.wMinute) IN sFormat
      REPLACE "SS" WITH FORMAT$(rTime.wSecond, "00") IN sFormat
      REPLACE "S" WITH FORMAT$(rTime.wSecond) IN sFormat
      FUNCTION = sFormat
      FindClose hFind
   END IF

END FUNCTION

'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
'  FileSize
'
'  Returns file size in bytes or -1 if there's an error
'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
FUNCTION FileSize ALIAS "FileSize" (BYVAL sFileName AS STRING) EXPORT AS LONG

   DIM hFind AS LONG
   DIM rData AS WIN32_FIND_DATA

   hFind = FindFirstFile(sFileName & $NUL, rData)
   IF hFind = %INVALID_HANDLE_VALUE THEN
      FUNCTION = -1
   ELSE
      FUNCTION = rData.nFileSizeLow
      FindClose hFind
   END IF

END FUNCTION

'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
'  ExtractFileName
'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
FUNCTION ExtractFileName ALIAS "ExtractFileName" _
      ( BYVAL sFileName AS STRING ) EXPORT AS STRING

   FUNCTION = PARSE$(sFileName, ANY "\/:", -1)

END FUNCTION

'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
'  FileExists
'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
FUNCTION FileExists ALIAS "FileExists" _
      ( BYVAL sFile AS STRING ) EXPORT AS LONG

   IF DIR$(sFile) = "" THEN
      FUNCTION = %false
   ELSE
      FUNCTION = %true
   END IF

END FUNCTION

'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
'  EnsureDirectoryExists
'
'  Creates all subdirectories if they don't already exist.
'  You can specify a full file name and or just the path.
'  If just the path is specified, it must end in a backslash
'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
SUB EnsureDirectoryExists ALIAS "EnsureDirectoryExists" _
      ( BYVAL sFileName AS STRING ) EXPORT

   DIM i AS LONG
   DIM sDrive AS STRING

   IF INSTR(sFileName, "\") < 1 THEN EXIT SUB

   '- All errors are ignored
   ON ERROR RESUME NEXT
   sDrive = ""
   FOR i = 1 TO PARSECOUNT(sFileName, "\") - 1
      IF sDrive = "" THEN
         sDrive = PARSE$(sFileName, "\", 1)
      ELSE
         sDrive = sDrive & "\" & PARSE$(sFileName, "\", i)
      END IF
      MKDIR sDrive
   NEXT i

   ERRCLEAR
   ON ERROR GOTO 0

END SUB

'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
'  ExtractPath
'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
FUNCTION ExtractPath ALIAS "ExtractPath" _
      ( BYVAL sFullFile AS STRING ) EXPORT AS STRING

   '- This routine strips the file
   '  path from the full name.
   '
   DIM i AS LONG
   DIM iStartAccum AS LONG
   DIM iLen AS LONG
   DIM sFile AS STRING
   DIM sAccum AS STRING

   sFile = LTRIM$(RTRIM$(sFullFile))
   iLen = LEN(sFile)
   sAccum = ""

   iStartAccum = %False
   IF iLen > 0 THEN
      FOR i = iLen TO 1 STEP -1
         IF (MID$(sFile, i, 1) = "\") OR _
            (MID$(sFile, i, 1) = ":") THEN
            iStartAccum = %True
         END IF
         IF iStartAccum = %True THEN
            sAccum = MID$(sFile, i, 1) + sAccum
         END IF
      NEXT i
   END IF

   sAccum = TRIM$(sAccum)
   IF sAccum = "" THEN
      sAccum = ".\"
   ELSEIF RIGHT$(sAccum, 1) <> "\" THEN
    sAccum = sAccum & "\"
   END IF

   FUNCTION = sAccum

END FUNCTION

'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
'  GetModuleName
'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
FUNCTION GetModuleName ALIAS "GetModuleName" _
      ( BYVAL sModule AS STRING ) EXPORT AS STRING

   DIM zFileName AS ASCIIZ * 400

   GetModuleFileName GetModuleHandle(BYCOPY sModule + $NUL), zFileName, 400
   FUNCTION = TRIM$(zFileName)

END FUNCTION

'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
'  GetExeName
'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
FUNCTION GetExeName ALIAS "GetExeName" EXPORT AS STRING

   DIM zFileName AS ASCIIZ * 400

   GetModuleFileName BYVAL %NULL, zFileName, 400
   FUNCTION = TRIM$(zFileName)

END FUNCTION

'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
'  GetAppPath
'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
'  GetTempFile
'
'  Takes a seed value (up to 4 characters)
'  and an extension (e.g. ".ddc") and
'  returns a unique file name.
'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
FUNCTION GetTempFile ALIAS "GetTempFile" _
      ( BYVAL sSeed AS STRING, BYVAL sExt AS STRING ) EXPORT AS STRING

   DIM iCount AS LONG
   DIM sName AS STRING
   DIM sPath AS STRING
   DIM sTest AS STRING
   DIM sFormat AS STRING
   DIM zPath AS ASCIIZ * 300
   DIM zSeed AS ASCIIZ * 100

   '- Get Temp Path
   GetTempPath SIZEOF(zPath), zPath

   sPath = TRIM$(zPath)
   IF RIGHT$(sPath, 1) <> "\" THEN
      sPath$ = sPath + "\"
   END IF

   IF LEN(sSeed) > 7 THEN sSeed = LEFT$(sSeed,7)
   sFormat = STRING$(8 - LEN(sSeed), "0")
   sName = ""
   FOR iCount = 1 TO 9999
      sTest = sPath & sSeed & FORMAT$(iCount, sFormat) & sExt
      IF FileExists(sTest) = %False THEN
         sName = sTest
         EXIT FOR
      END IF
   NEXT iCount

   FUNCTION = sName

END FUNCTION

'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
'  GetTemporaryDir
'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
FUNCTION GetTemporaryDir ALIAS "GetTemporaryDir" EXPORT AS STRING

   DIM zPath AS ASCIIZ * 500
   DIM sPath AS STRING

   GetTempPath SIZEOF(zPath), zPath
   sPath = TRIM$(zPath)
   IF RIGHT$(sPath, 1) <> "\" THEN sPath = sPath & "\"
   FUNCTION = sPath

END FUNCTION

'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
'  GetWindowsDir
'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
FUNCTION GetWindowsDir ALIAS "GetWindowsDir" EXPORT AS STRING

   DIM zPath AS ASCIIZ * 500
   DIM sPath AS STRING

   GetWindowsDirectory zPath, SIZEOF(zPath)
   sPath = TRIM$(zPath)
   IF RIGHT$(sPath, 1) <> "\" THEN sPath = sPath & "\"
   FUNCTION = sPath

END FUNCTION

'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
'  GetSystemDir
'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
FUNCTION GetSystemDir ALIAS "GetSystemDir" EXPORT AS STRING

   DIM zPath AS ASCIIZ * 500
   DIM sPath AS STRING

   GetSystemDirectory zPath, SIZEOF(zPath)
   sPath = TRIM$(zPath)
   IF RIGHT$(sPath, 1) <> "\" THEN sPath = sPath & "\"
   FUNCTION = sPath

END FUNCTION

'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
'  DeleteFileSpec
'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
SUB DeleteFileSpec ALIAS "DeleteFileSpec" _
      ( BYVAL sFileSpec AS STRING ) EXPORT

   DIM i AS LONG
   DIM lngCount AS LONG
   DIM sF AS STRING
   DIM sPath AS STRING
   DIM sFiles() AS STRING

   ON ERROR RESUME NEXT

   REDIM sFiles(0 TO 0) AS STRING
   lngCount = 0

   sPath = TRIM$(ExtractPath(sFileSpec))

   sF = DIR$(sFileSpec)
   DO UNTIL sF = ""
      INCR lngCount
      REDIM PRESERVE sFiles(0 TO lngCount) AS STRING
      sFiles(lngCount) = sPath & sF
      sF = DIR$
   LOOP
   FOR i = 1 TO lngCount
      ERRCLEAR
      KILL sFiles(i)
   NEXT i

END SUB

'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
'  pbWriteFile
'     Writes a block of binary data to the file specified. If the
'     file exists, this fails.
'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
FUNCTION pbWriteFile ALIAS "pbWriteFile" _
      ( BYVAL sFileName AS STRING, BYVAL sFileData AS STRING ) _
        EXPORT AS LONG

   DIM iFF AS LONG

   IF DIR$(sFileName) <> "" THEN
      g_pb_file_LastError = "Output file exists."
      FUNCTION = %false
      EXIT FUNCTION
   END IF

   iFF = FREEFILE
   OPEN sFileName FOR BINARY LOCK READ WRITE AS #iFF
   IF ERR THEN
      g_pb_file_LastError = "Unable to open output file '" & _
            sFileName + "' error=" + FORMAT$(ERR)
      FUNCTION = %false
      EXIT FUNCTION
   END IF

   PUT #iFF,, sFileData

   CLOSE #iFF

   FUNCTION = %true

END FUNCTION

'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
'  pbzWriteFile
'
'  Writes a block of binary data to the file specified. If the
'  file exists, this fails.
'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
FUNCTION pbzWriteFile ALIAS "pbzWriteFile" _
      ( zFileName AS ASCIIZ, zFileData AS ASCIIZ ) EXPORT AS LONG

   FUNCTION = pbWriteFile( (zFileName), (zFileData) )

END FUNCTION

'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
'  pbReadFile
'     Reads a file into a string
'     returns %true if successful or %false if it fails
'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
FUNCTION pbReadFile ALIAS "pbReadFile" _
      ( BYVAL sFileName AS STRING, sFileData AS STRING ) _
        EXPORT AS LONG

   DIM iFF AS LONG

  sFileData = ""

   IF DIR$(sFileName) = "" THEN
      g_pb_file_LastError = "Input file not found."
      FUNCTION = %false
      EXIT FUNCTION
   END IF

   iFF = FREEFILE
   OPEN sFileName FOR BINARY LOCK READ WRITE AS #iFF
   IF ERR THEN
      g_pb_file_LastError = "Unable to open input file '" & _
            sFileName & "' error=" & FORMAT$(ERR)
      FUNCTION = %false
      EXIT FUNCTION
   END IF

  IF LOF(iFF) > 0 THEN
    sFileData = SPACE$(LOF(iFF))
     GET #iFF,, sFileData
  END IF

   CLOSE #iFF

   FUNCTION = %true

END FUNCTION

'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
'  ShellDocument
'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
SUB ShellDocument ALIAS "ShellDocument" (BYVAL sFile AS STRING) EXPORT

  ShellExecute 0, BYVAL %null, sFile & $NUL, BYVAL %null, BYVAL %null, _
      %SW_NORMAL

END SUB

'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
'  RunWaitAndClose
'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
FUNCTION RunWaitAndClose ALIAS "RunWaitAndClose" _
      ( BYVAL sCmdLine AS STRING, BYVAL sCurDir AS STRING, _
        BYVAL conTitle AS STRING, BYVAL iAllocConsole AS LONG, _
        BYVAL iShow AS LONG ) AS LONG

   DIM SI AS STARTUPINFO
   DIM PI AS PROCESS_INFORMATION
   DIM ex AS DWORD
   DIM lngCREATE_PROCESS_ERROR AS LONG

   lngCREATE_PROCESS_ERROR = -9999

   ex = 1

   IF iAllocConsole THEN AllocConsole

   SI.cb          = SIZEOF(SI)
   SI.dwFlags     = %STARTF_USESTDHANDLES OR %STARTF_USESHOWWINDOW
   SI.hStdInput   = GetStdHandle( %STD_INPUT_HANDLE )
   SI.hStdOutput  = GetStdHandle( %STD_OUTPUT_HANDLE )
   SI.hStdError   = GetStdHandle( %STD_ERROR_HANDLE )
   SI.wShowWindow = iShow

'
'    SI.hStdOutput  := CreateFile('c:\file_o.txt',
'                            GENERIC_WRITE, 0,
'                            nil, CREATE_ALWAYS, 0, 0);
'
'   SI.hStdError   := CreateFile('c:\file_e.txt',
'                            GENERIC_WRITE, 0,
'                            nil, CREATE_ALWAYS, 0, 0);
   IF CreateProcess( "", sCmdLine + $NUL, BYVAL 0, BYVAL 0, %true, 0, _
         BYVAL 0, sCurDir + $NUL, SI, PI ) THEN
      IF conTitle <> "" THEN SetConsoleTitle( conTitle & $NUL)

      DO UNTIL WaitForSingleObject(pi.hProcess, 100) <> %WAIT_TIMEOUT
         IF iAllocConsole THEN
            SLEEP 100
         ELSE
            apiDoevents
         END IF
      LOOP

      IF GetExitCodeProcess(pi.hProcess, ex) = 0 THEN
         ex = GetLastError()
      END IF
   ELSE
      ex = lngCREATE_PROCESS_ERROR
   END IF

   IF iAllocConsole THEN
      FreeConsole
      CloseHandle SI.hStdOutput
      CloseHandle SI.hStdError
   END IF

   FUNCTION = ex

END FUNCTION

'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
'  dirExists
'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
FUNCTION dirExists(BYVAL sDir AS STRING) AS LONG

   DIM iCode AS LONG

   ERRCLEAR
   iCode = GETATTR(sDir)
   IF ERR THEN
      FUNCTION = %false
   ELSEIF (iCode AND %SUBDIR) = %SUBDIR THEN
      FUNCTION = %true
   ELSE
      FUNCTION = %false
   END IF

END FUNCTION

'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
'  pbAppendLog
'
'  safely appends data to a log file. the file is opened exclusively
'  by protecting the open with a mutex.
'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
FUNCTION pbAppendLog ALIAS "pbAppendLog" _
      ( zLogFile AS ASCIIZ, zData AS ASCIIZ ) EXPORT AS LONG

   DIM iFF AS LONG

   IF mtxLock( TRIM$(zLogFile), 3000 ) THEN
      ERRCLEAR
      iFF = FREEFILE
      OPEN zLogFile FOR APPEND AS #iFF
      IF ERR THEN
         FUNCTION = %false
      ELSE
         PRINT #iFF, DATE$ & " " & TIME$ & "  " & TRIM$(zData)
         CLOSE #iFF
         FUNCTION = %true
      END IF
      mtxUnlock TRIM$(zLogFile)
   ELSE
      FUNCTION = %false
   END IF

END FUNCTION

'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
'  RunWaitAndCloseEx
'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
FUNCTION RunWaitAndCloseEx ALIAS "RunWaitAndCloseEx" _
      ( BYVAL sCmdLine AS STRING, BYVAL sCurDir AS STRING, _
        BYVAL conTitle AS STRING, BYVAL iAllocConsole AS LONG, _
        BYVAL iShow AS LONG, sStdout AS STRING ) AS LONG

   DIM SI AS STARTUPINFO
   DIM PI AS PROCESS_INFORMATION
   DIM SA AS SECURITY_ATTRIBUTES
   DIM ex AS DWORD
   DIM tempFile AS ASCIIZ * %MAX_PATH
   DIM lngCREATE_PROCESS_ERROR AS LONG

   sStdOut = ""

   lngCREATE_PROCESS_ERROR = -9999

   ex = 1

   IF iAllocConsole THEN AllocConsole

   SI.cb          = SIZEOF(SI)
   SI.dwFlags     = %STARTF_USESTDHANDLES OR %STARTF_USESHOWWINDOW    '
   SI.hStdInput   = GetStdHandle( %STD_INPUT_HANDLE )
   'SI.hStdOutput  = GetStdHandle( %STD_OUTPUT_HANDLE )
   SI.hStdError   = GetStdHandle( %STD_ERROR_HANDLE )
   SI.wShowWindow = iShow

  '- we have to create a security attributes structure in order
  '   to specify that the handle can be inherited. if we try to
  '   pass it as byval %null, it won't work because the handles
  '   cannot be inheritted.
  '
  SA.nLength = SIZEOF(SA)
  SA.lpSecurityDescriptor = %NULL
  SA.bInheritHandle = %true
  tempFile = getTempFile("~pb", ".tmp")
   SI.hStdOutput = CreateFile(tempFile, _
      %GENERIC_WRITE, 0, _
         SA, %CREATE_ALWAYS, 0, 0)
   IF CreateProcess( "", sCmdLine & $NUL, BYVAL 0, BYVAL 0, %true, 0, _
         BYVAL 0, sCurDir & $NUL, SI, PI ) THEN
      IF conTitle <> "" THEN SetConsoleTitle( conTitle + $NUL)

      DO UNTIL WaitForSingleObject(pi.hProcess, 100) <> %WAIT_TIMEOUT
         IF iAllocConsole THEN
            SLEEP 100
         ELSE
            apiDoevents
         END IF
      LOOP

      IF GetExitCodeProcess(pi.hProcess, ex) = 0 THEN
         ex = GetLastError()
      END IF
   ELSE
      ex = lngCREATE_PROCESS_ERROR
   END IF

   IF iAllocConsole THEN
      FreeConsole
      CloseHandle SI.hStdOutput
      CloseHandle SI.hStdError
   ELSE
      closeHandle SI.hStdOutput
   END IF

  '- read back the stdoutput of the shelled process
  '   and delete the temporary file.
  '
  IF fileExists(tempFile) THEN
    pbReadFile tempFile, sStdout
    KILL tempFile
  END IF
   FUNCTION = ex

END FUNCTION

#ENDIF
