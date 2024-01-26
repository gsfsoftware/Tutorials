'
'  pb_mtx.inc
'
'  Mutex wrappers for use in local locking
'  PUBLIC DOMAIN CODE
'  from Don Dickinson
'  don@greatwebdivide.com
'
#IF NOT %DEF(%PB_MTX_INC)
%PB_MTX_INC = 1
#INCLUDE "pb_secur.inc"

'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
'  mtxLock
'
'  Returns %true if the mutex named sMutexName is able to be owned.
'  If not, it returns %false.
'
'  iTimeout_ms is the timeout value in milliseconds. It can be set
'  to %INFINITE to wait forever or 0 to return instantly.
'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
FUNCTION mtxLock ALIAS "mtxLock" _
      (BYVAL sMutexName AS STRING, BYVAL iTimeout_ms AS LONG ) _
       EXPORT AS LONG

   DIM hMutex AS LONG

   '- Back slashes are not allowed so I replace
   '  with a ":"
   '
   REPLACE "\" WITH ":" IN sMutexName

   hMutex = CreateMutex(BYVAL %null, 0, sMutexName + $NUL)
   IF hMutex = 0 THEN
      hMutex = OpenMutex(%MUTEX_ALL_ACCESS, 0, sMutexName + $NUL)
   END IF

   IF hMutex = 0 THEN
      FUNCTION = %false
   ELSE
      SELECT CASE WaitForSingleObject(hMutex, iTimeout_ms)
         CASE %WAIT_ABANDONED, %WAIT_OBJECT_0
            FUNCTION = %true
         CASE ELSE      '%WAIT_FAILED, %WAIT_TIMEOUT
            FUNCTION = %false
      END SELECT
   END IF

END FUNCTION

'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
'  mtxLock2
'
'  Like mtxLock, but gets a security descriptor
'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
FUNCTION mtxLock2 ALIAS "mtxLock2" _
      (BYVAL sMutexName AS STRING, BYVAL iTimeout_ms AS LONG ) _
       EXPORT AS LONG

   DIM hMutex AS LONG
   DIM pSid AS LONG
   DIM pACL AS LONG
   DIM rSecurity AS SECURITY_ATTRIBUTES
   DIM rSecDesc AS SECURITY_DESCRIPTOR

   '- Back slashes are not allowed so I replace
   '  with a ":"
   '
   REPLACE "\" WITH ":" IN sMutexName

   '- Get full rights
   IF isNt() = %false THEN
      hMutex = CreateMutex(BYVAL %null, 0, sMutexName + $NUL)

   ELSEIF getGlobalSecurity(rSecurity, rSecDesc, pSid, pACL) = %false THEN
      hMutex = CreateMutex(BYVAL %null, 0, sMutexName + $NUL)

   ELSE
      hMutex = CreateMutex(rSecurity, 0, sMutexName + $NUL)
   END IF

   IF hMutex = 0 THEN
      hMutex = OpenMutex(%MUTEX_ALL_ACCESS, 0, sMutexName + $NUL)
   END IF

   IF hMutex = 0 THEN
      FUNCTION = %false
   ELSE
      SELECT CASE WaitForSingleObject(hMutex, iTimeout_ms)
         CASE %WAIT_ABANDONED, %WAIT_OBJECT_0
            FUNCTION = %true
         CASE ELSE      '%WAIT_FAILED, %WAIT_TIMEOUT
            FUNCTION = %false
      END SELECT
   END IF

   IF pSid THEN FreeSid pSid
   IF pAcl THEN FreeMem pAcl

END FUNCTION

'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
'  mtxUnlock
'
'  Frees the mutex obtained with mtxLock - reference the mutex by name
'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
FUNCTION mtxUnlock ALIAS "mtxUnlock" _
      ( BYVAL sMutexName AS STRING ) EXPORT AS LONG

   DIM hMutex AS LONG

   '- Just as in mtxLock, back slashes are not
   '  allowed so I replace with a ":"
   '
   REPLACE "\" WITH ":" IN sMutexName

   hMutex = OpenMutex(%MUTEX_ALL_ACCESS, 0, sMutexName + $NUL)
   IF hMutex THEN
      ReleaseMutex hMutex
   END IF

END FUNCTION
#ENDIF
