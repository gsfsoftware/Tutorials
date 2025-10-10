' PipeTostring.inc
' this accesses msvcrt.dll
' which is a dynamic library for the Microsoft Visual C++ runtime
' Msvcrt.dll is a Windows system file
'
' The _popen function creates a pipe.
' It then asynchronously executes a spawned copy of the command
' processor, and uses command as the command line.
' The character string mode specifies the type of access requested,
' as follows.
'
' Access mode - 	Description
'   "r"         	The calling process can read the spawned command's
'               standard output using the returned stream.
'   "w"         	The calling process can write to the spawned
'               command's standard input using the returned stream.
'   "b"         	Open in binary mode.
'   "t"         	Open in text mode.
'
#INCLUDE ONCE "win32api.inc"

DECLARE FUNCTION popen CDECL LIB "msvcrt.dll" _
                 ALIAS "_popen" (BYREF cmd AS STRINGZ, _
                 BYREF MODE AS STRINGZ) AS DWORD
                 '
DECLARE FUNCTION fread CDECL LIB "msvcrt.dll" _
                 ALIAS "fread" (BYVAL buffer AS DWORD, _
                 BYVAL elemSize AS DWORD, _
                 BYVAL elemCount AS DWORD, _
                 BYVAL fp AS DWORD) AS DWORD
                 '
DECLARE FUNCTION fclose CDECL LIB "msvcrt.dll" _
                 ALIAS "fclose" (BYVAL fp AS DWORD) AS LONG
                 '
FUNCTION PipeToString(strCmdIn AS STRING) AS STRING
  LOCAL sbOut AS ISTRINGBUILDERA
  LOCAL szBuf AS STRINGZ * 1024
  LOCAL szCmdIn AS STRINGZ * 256
  LOCAL hP,dwBytesRead  AS DWORD
  szCmdIn = strCmdIn
  '
  #IF NOT %DEF(%PB_CC32)
  ' allocate a console if in the windows compiler
    allocconsole
    '
    SetWindowPos(GetConsoleWindow(), _
                 %NULL, 0, 0, 0, 0, %SWP_NOZORDER)
  #ENDIF
  '
  hP = popen(szCmdIn, "rb")
  IF hP = 0 THEN : EXIT FUNCTION
  sbOut = CLASS "StringBuilderA"
  '
  DO
  ' get the data coming back
    dwBytesRead = fread(VARPTR(szBuf), 1, SIZEOF(szBuf), hP)
    ' use string builder to store it
    sbOut.Add(LEFT$(szBuf, dwBytesRead))
  LOOP WHILE dwBytesRead = SIZEOF(szBuf)
  ' close off the pipe
  fclose(hP)
  '
  #IF NOT %DEF(%PB_CC32)
  ' free up the console if in the windows compiler
    Freeconsole
  #ENDIF
  '
  ' return the output string
  FUNCTION = sbOut.string
  '
END FUNCTION
