'
'  pb_secur.inc
'
'  public domain code from Don Dickinson
'  don@greatwebdivide.com
'
#IF NOT %DEF(%PB_SECUR_INC)
%PB_SECUR_INC = 1

'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
'  Fills the tsa structure with a valid security attributes structure
'  Returns %true on success and %false on failure.
'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
FUNCTION getGlobalSecurity ALIAS "getGlobalSecurity" _
      ( tsa AS SECURITY_ATTRIBUTES, tsd AS SECURITY_DESCRIPTOR, _
        pSidEveryone AS LONG, BYVAL pACLNewDacl AS ACL PTR ) AS LONG

   DIM bOk AS LONG
   DIM iSIDSize AS LONG
   DIM iACLSize AS LONG
   DIM tsiaWorld AS SID_IDENTIFIER_AUTHORITY
   DIM pSid AS SID_IDENTIFIER_AUTHORITY PTR

   pSidEveryone = %null
   pACLNewDacl = %null

   IF isNt() = %false THEN
      bOk = %false
      GOTO getGlobalSecurity_done
   END IF

   'tsiaWorld.value(5) = 5     '%SECURITY_NT_AUTHORITY
   tsiaWorld.value(5) = 1     '%SECURITY_WORLD_SID_AUTHORITY

   '%SECURITY_LOCAL_SYSTEM_RID

   '- This function is supposed to return 0 on failure, but it
   '  appears to return 0 either way.
   '
   AllocateAndInitializeSid tsiaWorld, 1, %SECURITY_WORLD_RID, _
         0&, 0&, 0&, 0&, 0&, 0&, 0&, pSIDEveryone

   IF pSIDEveryone = 0 THEN
      bOk = %false
      GOTO getGlobalSecurity_done
   END IF

   iSidSize = GetLengthSid(pSIDEveryone)
   iACLSize= iSIDSize * 2 + LEN(ACCESS_ALLOWED_ACE) + LEN(ACCESS_DENIED_ACE) + LEN(ACL)
   pACLNewDacl = GetMem(iACLSize)
   IF pACLNewDacl = %null THEN
      bOk = %false
      GOTO getGlobalSecurity_done
   END IF

   IF InitializeAcl(pACLNewDacl, iACLSize, %ACL_REVISION) = %false THEN
      bOk = %false
      GOTO getGlobalSecurity_done
   END IF

   IF AddAccessAllowedAce ( pACLNewDacl, %ACL_REVISION, _
         %GENERIC_READ OR %GENERIC_WRITE OR %GENERIC_ALL, _
         BYVAL pSIDEveryone ) = %false THEN
      bOk = %false
      GOTO getGlobalSecurity_done
   END IF

   IF InitializeSecurityDescriptor ( tsd, %SECURITY_DESCRIPTOR_REVISION ) _
         = %false THEN
      bOk = %false
      GOTO getGlobalSecurity_done
   END IF

   IF SetSecurityDescriptorDacl ( tsd, %true, pACLNewDacl, %false ) = %false THEN
      bOk = %false
      GOTO getGlobalSecurity_done
   END IF

   tsa.nLength = SIZEOF(tsa)
   tsa.bInheritHandle = %false
   tsa.lpSecurityDescriptor = VARPTR(tsd)

   bOk = %true

getGlobalSecurity_done:

   IF bOk = %false THEN
      IF pSidEveryone THEN FreeSid pSidEveryone
      IF pACLNewDacl THEN FreeMem pACLNewDacl
      pSidEveryone = %null
      pACLNewDacl = %null
   END IF

   FUNCTION = bOk

END FUNCTION
#ENDIF
