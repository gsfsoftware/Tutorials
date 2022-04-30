#COMPILE DLL
#DIM ALL

#INCLUDE ONCE "Win32API.inc"

GLOBAL ghInstance AS DWORD

'-------------------------------------------------------------------------------
' Main DLL entry point called by Windows...
'
FUNCTION LIBMAIN (BYVAL hInstance   AS LONG, _
                  BYVAL fwdReason   AS LONG, _
                  BYVAL lpvReserved AS LONG) AS LONG

    SELECT CASE fwdReason

    CASE %DLL_PROCESS_ATTACH
        'Indicates that the DLL is being loaded by another process (a DLL
        'or EXE is loading the DLL).  DLLs can use this opportunity to
        'initialize any instance or global data, such as arrays.

        ghInstance = hInstance

        FUNCTION = 1   'success!

        'FUNCTION = 0   'failure!  This will prevent the EXE from running.

    CASE %DLL_PROCESS_DETACH
        'Indicates that the DLL is being unloaded or detached from the
        'calling application.  DLLs can take this opportunity to clean
        'up all resources for all threads attached and known to the DLL.

        FUNCTION = 1   'success!

        'FUNCTION = 0   'failure!

    CASE %DLL_THREAD_ATTACH
        'Indicates that the DLL is being loaded by a new thread in the
        'calling application.  DLLs can use this opportunity to
        'initialize any thread local storage (TLS).

        FUNCTION = 1   'success!

        'FUNCTION = 0   'failure!

    CASE %DLL_THREAD_DETACH
        'Indicates that the thread is exiting cleanly.  If the DLL has
        'allocated any thread local storage, it should be released.

        FUNCTION = 1   'success!

        'FUNCTION = 0   'failure!

    END SELECT

END FUNCTION
'
FUNCTION funReverseString ALIAS "funReverseString" _
  (strString AS STRING) EXPORT AS STRING
' take a string in return it reversed
  LOCAL strReversed AS STRING
  '
  strReversed = STRREVERSE$(strString)
  '
  FUNCTION = strReversed
'
END FUNCTION
'
FUNCTION funOutputDataToScreen ALIAS "funOutputDataToScreen" _
         () EXPORT AS STRING
  LOCAL lngR AS LONG
  LOCAL strData AS STRING
  '
  FOR lngR =1 TO 5
    strData = strData & "New Row = " & FORMAT$(lngR) & $CRLF
  NEXT lngR
  '
  FUNCTION = strData
  '
END FUNCTION
'
FUNCTION funGetData ALIAS "funGetSomeData" _
         (BYREF a_strArray() AS STRING) EXPORT AS STRING
         '
  LOCAL lngR AS LONG
  LOCAL strData AS STRING
  '
  subPopulateArray(BYREF a_strArray())
  '
  FOR lngR = 1 TO UBOUND(a_strArray)
    strData = strData & a_strArray(lngR) & $CRLF
  NEXT lngR
  '
  FUNCTION = strData

END FUNCTION
'
SUB subPopulateArray(BYREF a_strArray() AS STRING)
  LOCAL lngR AS LONG
  '
  RANDOMIZE TIMER
  '
  FOR lngR = 1 TO UBOUND(a_strArray)
    a_strArray(lngR) = FORMAT$(RND(1,10))
  NEXT lngR
  '
END SUB
