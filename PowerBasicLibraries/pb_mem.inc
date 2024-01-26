'
'  pb_mem.inc
'
'  DESCRIPTION
'     Power Basic memory allocation routines.
'     By Don Dickinson
'     ddickinson@usinternet.com
'     Sept, 2000
'
'  AUTHOR
'     Don Dickinson
'     don@greatwebdivide.com
'     http://dickinson.basicguru.com
'
'  LICENSE and DISCLAIMER
'     Hereby Public Domain
'
'     Use this code as you see fit. By using or compiling this code or derivative
'     thereof, you are consenting to the hold the author, Don Dickinson, harmless
'     for all effects or side-effects its use. This code works great for me,
'     but you are using it at your own risk.
'
'  DEPENDS ON
'     no other modules. some win32api.inc functions are conditionally
'     compiled here if they're not already defined.
'
'  FUNCTIONS
'     function GetMem ( ByVal howMuchMemory as Long ) as Long
'     sub FreeMem ( ByVal memoryHandle as Long )
'     sub AllocMem ( pMem as Long, iBytes as Long )
'     function isNt() as Long
'     Function GetAsciiz ( Byval sData as String ) as DWord
'     Function zToString ( zString as Asciiz PTR ) as String
'     function binToString ( pData as Long, ByVal iLen as Long ) as String
'     function GetPointer ( sString as String ) as Long
'
#IF NOT %DEF(%PB_MEM_BAS)
%PB_MEM_BAS = 1

'- I assume that if %GMEM_FIXED isn't defined, then
'  none of the windows api is included (win32api.inc)
'  so I declare everything that's needed by this module.
'
#IF NOT %DEF(%GMEM_FIXED)
   %GMEM_FIXED                                  = &H0
   %GMEM_MOVEABLE                               = &H2
   %GMEM_NOCOMPACT                              = &H10
   %GMEM_NODISCARD                              = &H20
   %GMEM_ZEROINIT                               = &H40
   %GMEM_MODIFY                                 = &H80
   %GMEM_DISCARDABLE                            = &H100
   %GMEM_NOT_BANKED                             = &H1000
   %GMEM_SHARE                                  = &H2000
   %GMEM_DDESHARE                               = &H2000
   %GMEM_NOTIFY                                 = &H4000
   %GMEM_LOWER                                  = %GMEM_NOT_BANKED
   %GMEM_VALID_FLAGS                            = &H7F72
   %GMEM_INVALID_HANDLE                         = &H8000
   DECLARE FUNCTION GlobalAlloc LIB "KERNEL32.DLL" ALIAS "GlobalAlloc" _
         ( BYVAL wFlags AS LONG, BYVAL dwBytes AS LONG) AS LONG
   DECLARE FUNCTION GlobalFree LIB "KERNEL32.DLL" ALIAS "GlobalFree" _
         ( BYVAL hMem AS LONG) AS LONG

#ENDIF

#IF %DEF(%DEBUG_PB_MEM_BAS)
GLOBAL g_totalAlloc AS QUAD
GLOBAL g_countAlloc AS QUAD
GLOBAL g_totalFreed AS QUAD
GLOBAL g_countFreed AS QUAD
#ENDIF

'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
'  isNt
'
'  Returns %true if the os is nt/2000pro, %false if not
'  I don't know what it returns on an XP Home or Pro box.
'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
FUNCTION isNt ALIAS "isNt" EXPORT AS LONG

   DIM tOsVersion AS OSVERSIONINFO

   tOsVersion.dwOSVersionInfoSize = SIZEOF(tOsVersion)
   IF GetVersionEx(tOsVersion) THEN
      IF tOsVersion.dwPlatformId  = %VER_PLATFORM_WIN32_NT THEN
         FUNCTION = %true
      ELSE
         FUNCTION = %false
      END IF
   ELSE
      FUNCTION = %false
   END IF

END FUNCTION

'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
'  GetMem
'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
FUNCTION GetMem ALIAS "GetMem" _
      (BYVAL iBytes AS LONG) EXPORT AS LONG

   #IF %DEF(%DEBUG_PB_MEM_BAS)
   DIM iReturn AS LONG

   g_totalAlloc = g_totalAlloc + iBytes
   INCR g_countAlloc
   iReturn = GlobalAlloc(%GMEM_FIXED OR %GMEM_ZEROINIT, iBytes)
   IF iReturn = 0 THEN
      STDOUT "GetMem FAILURE"
      iReturn = GlobalAlloc(%GMEM_FIXED OR %GMEM_ZEROINIT, iBytes)
      IF iReturn = 0 THEN
         STDOUT "GetMem FAILURE AGAIN"
      ELSE
         STDOUT "Success this time"
         FUNCTION = iReturn
      END IF
      WAITKEY$
   ELSE
      FUNCTION = iReturn
   END IF
   #ELSE
   FUNCTION = GlobalAlloc(%GMEM_FIXED OR %GMEM_ZEROINIT, iBytes)
   #ENDIF

END FUNCTION

'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
'  AllocMem
'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
SUB AllocMem ALIAS "AllocMem" ( pMem AS LONG, iBytes AS LONG ) EXPORT
   #IF %DEF(%DEBUG_PB_MEM_BAS)
   DIM iReturn AS LONG

   g_totalAlloc = g_totalAlloc + iBytes
   INCR g_countAlloc
   iReturn = GlobalAlloc(%GMEM_FIXED OR %GMEM_ZEROINIT, iBytes)
   IF iReturn = 0 THEN
      STDOUT "GetMem FAILURE"
      pMem = GlobalAlloc(%GMEM_FIXED OR %GMEM_ZEROINIT, iBytes)
      IF pMem = 0 THEN
         STDOUT "GetMem FAILURE AGAIN"
      ELSE
         STDOUT "Success this time"
      END IF
      WAITKEY$
   ELSE
      FUNCTION = pMem
   END IF
   #ELSE
   pMem = GlobalAlloc(%GMEM_FIXED OR %GMEM_ZEROINIT, iBytes)
   #ENDIF

END SUB

'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
'  FreeMem
'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
SUB FreeMem ALIAS "FreeMem" _
      (BYVAL ptrMem AS LONG) EXPORT

   #IF %DEF(%DEBUG_PB_MEM_BAS)
   g_totalFreed = g_totalFreed + GlobalSize(ptrMem)
   INCR g_countFreed
   #ENDIF
   IF ptrMem THEN
      GlobalFree ptrMem
   END IF

END SUB

'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
'  GetAsciiz
'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
FUNCTION GetAsciiz ALIAS "GetAsciiz" _
      (BYVAL sData AS STRING) EXPORT AS DWORD

   DIM ptrData AS ASCIIZ PTR

   ptrData = 0
   IF LEN(sData) > 0 THEN
      ptrData = GetMem(LEN(sData) + 1)
      IF ptrData THEN
         @ptrData = sData
      END IF
   END IF
   FUNCTION = ptrData

END FUNCTION

'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
'  zToString
'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
FUNCTION zToString ALIAS "zToString" _
      ( BYVAL zString AS ASCIIZ PTR ) AS STRING

   IF zString = 0 THEN
      FUNCTION = ""
   ELSE
      FUNCTION = @zString
   END IF

END FUNCTION

'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
'  binToString
'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
FUNCTION binToString ALIAS "binToString" _
      ( pData AS LONG, BYVAL iLen AS LONG ) AS STRING

   DIM iPos AS LONG
   DIM pInput AS BYTE PTR
   DIM pOutput AS BYTE PTR
   DIM sTemp AS STRING

   IF (iLen < 1) OR (pData = 0) THEN
      FUNCTION = ""
      EXIT FUNCTION
   END IF

   sTemp = STRING$(iLen, $NUL)
   pOutput = STRPTR(sTemp)
   pInput = pData
   DO
      @pOutput[iPos] = @pInput[iPos]
      INCR iPos
      IF iPos >= iLen THEN EXIT DO
   LOOP
   FUNCTION = sTemp

END FUNCTION

'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
'  stringToPointer
'
'  Gets memory to hold a binary string in memory, then copies the
'  string into that memory. Note, this does not null terminate the
'  string and allows binary data to be copied.
'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
FUNCTION GetPointer ALIAS "GetPointer" _
      ( sString AS STRING ) AS LONG

   DIM iLen AS LONG
   DIM iPos AS LONG
   DIM pOutput AS BYTE PTR
   DIM pInput AS BYTE PTR

   iLen = LEN(sString)
   IF iLen < 1 THEN
      FUNCTION = 0
      EXIT FUNCTION
   END IF

   pInput = STRPTR(sString)
   pOutput = GetMem(LEN(sString))

   IF pOutput THEN
      iPos = 0
      DO
         @pOutput[iPos] = @pInput[iPos]
         INCR iPos
         IF iPos >= iLen THEN EXIT DO
      LOOP
   END IF

   FUNCTION = pOutput

END FUNCTION

#ENDIF
