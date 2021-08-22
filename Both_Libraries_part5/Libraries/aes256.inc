'aes256.inc  :%AES256=32'AES128=16:%AES192=24:%AES256=32  This uses %AES256
%AES256=32
%BlockSize=16
%NULL=0
%SaltLength=35
'-------------------------------------------------------------------------------------------------------------
FUNCTION funEncrypt(BYVAL strText AS STRING, _
                    BYVAL strPassword AS STRING, _
                    BYVAL strHMACKey AS STRING) AS STRING
                                     'from code by David Roberts
  strText= MKDWD$(LEN(strText)) & strText  'length of string + data is encrypted

  LOCAL strSalt AS STRING
  strSalt = GetRandomString(%SaltLength) ' salt
  strPassword = strSalt & strPassword    'sent in clear after IV

  LOCAL AESstrength AS LONG
  LOCAL ntStatus, hAESAlg, hHashAlg, dwResult, lKeyObject, lHashObject, phHash, hKey AS DWORD

  DIM KeyObject() AS BYTE
  DIM LenKeyObject() AS BYTE
  DIM HashObject() AS BYTE
  DIM LenHashObject() AS BYTE
  DIM BinHash(1 TO 32) AS BYTE
  DIM OutText() AS BYTE
  LOCAL LenOutText AS LONG
  LOCAL strResultText AS STRING

  AESstrength = %AES256 '%AES128=16:%AES192=24:%AES256=32

  ' Use SHA256 And hash Password
  ntStatus = BCryptOpenAlgorithmProvider( hHashAlg, _
                      $$BCRYPT_SHA256_ALGORITHM, $$NUL, 0) 'was 256

  REDIM LenHashObject(1 TO 4) AS BYTE
  lHashObject = VARPTR(LenHashObject(1))
  ntStatus = BCryptGetProperty( hHashAlg, $$BCRYPT_OBJECT_LENGTH, _
                                lHashObject, 4, dwResult, 0 )
  REDIM HashObject(1 TO lHashObject) AS BYTE
  '
  ntStatus = BCryptCreateHash( hHashAlg, phHash, VARPTR(HashObject(1)), _
                               lHashObject, BYVAL %Null, 0, 0 )
  ntStatus = BCryptHashData( phHash,  STRPTR(strPassword), LEN(strPassword), 0)
  ntStatus = BCryptFinishHash( phHash, VARPTR(BinHash(1)), 32, 0)
  '
  BCryptCloseAlgorithmProvider( hHashAlg, 0 )
  BCryptDestroyHash( phHash )

  LOCAL strIV,strIV2 AS STRING   'create IV  16-bytes
  strIV = GetRandomString(%BlockSize)
  strIV2= strIV 'at end of function append unencrypted (IV)+ (ENCRYPTED DATA)
  DIM IV(1 TO %BlockSize) AS BYTE AT STRPTR(strIV)

  ntStatus = BCryptOpenAlgorithmProvider( hAESAlg, $$BCRYPT_AES_ALGORITHM, $$NUL, 0 )
  REDIM LenKeyObject(1 TO 4) AS BYTE
  lKeyObject = VARPTR(LenKeyObject(1))
  ntStatus = BCryptGetProperty( hAESAlg, $$BCRYPT_OBJECT_LENGTH, _
               lKeyObject, 4, dwResult, 0 ) ' We want lKeyObject
  REDIM KeyObject(1 TO lKeyObject) AS BYTE

  LOCAL BCRYPT_CHAIN_MODE_CBC AS WSTRING
  BCRYPT_CHAIN_MODE_CBC = $$BCRYPT_CHAIN_MODE_CBC

  ntStatus = BCryptSetProperty( hAESAlg, $$BCRYPT_CHAINING_MODE, _
                            BYVAL STRPTR(BCRYPT_CHAIN_MODE_CBC), _
                            SIZEOF(BCRYPT_CHAIN_MODE_CBC), 0 )

  ntStatus = BCryptGenerateSymmetricKey( hAESAlg, hKey, VARPTR(KeyObject(1)), _
                            lKeyObject, VARPTR(BinHash(1)), AESstrength, 0 ) ' We want hKey

  ntStatus = BCryptEnCrypt( hKey, STRPTR(strText), LEN(strText), _
                            BYVAL %Null, VARPTR(IV(1)), %BlockSize, _
                            BYVAL %Null, 0, LenOutText, %BCRYPT_BLOCK_PADDING )

  REDIM OutText(1 TO LenOutText) AS BYTE

  ntStatus = BCryptEnCrypt( hKey, STRPTR(strText), LEN(strText), _
                            BYVAL %Null, VARPTR(IV(1)), %BlockSize, _
                            VARPTR(OutText(1)), LenOutText, dwResult, _
                            %BCRYPT_BLOCK_PADDING )

  strResultText = PEEK$(VARPTR(OutText(1)),LenOutText)
  '
  BCryptCloseAlgorithmProvider( hAESAlg, 0 )
  BCryptDestroyKey( hKey )

  LOCAL strEncrypt,strTag AS STRING
  'unencrypted(IV + strSalt) + encrypted(4-byte len + data)
  strEncrypt = strIV2 & strSalt & strResultText
  '
  'HMAC of encrypted data (tag)
  strTag      = SHA256HMAC(strEncrypt,strHMACKey)
  'data to send is HMAC + encry
  FUNCTION  = strTag & strEncrypt
END FUNCTION
'-------------------------------------------------------------------------------------------------------------
FUNCTION funDecrypt(BYVAL strText AS STRING, BYVAL strPassword AS STRING,BYVAL strHMACKey AS STRING) AS STRING

 'IF bytes 1-32      <> computed  HMAC of bytes 33 then data is not authenticated
  IF LEFT$(strText,32) <> SHA256HMAC(MID$(strText,33),strHMACKey) THEN
    ? "HMAC authorization did not match encrypted data",%MB_ICONERROR OR %MB_SYSTEMMODAL,"Decrypt failed"
    EXIT FUNCTION 'authenticate (tag)
  END IF
  strText = MID$(strText,33)                    'encrypted data received

  LOCAL strIV AS STRING  'from code by David Roberts
  LOCAL AESstrength AS LONG
  LOCAL ntStatus, hAESAlg, hHashAlg, dwResult, _
        lKeyObject, lHashObject, phHash, hKey AS DWORD
  DIM KeyObject()      AS BYTE
  DIM LenKeyObject()   AS BYTE
  DIM HashObject()     AS BYTE
  DIM LenHashObject()  AS BYTE
  DIM BinHash(1 TO 32) AS BYTE
  DIM OutText()        AS BYTE
  LOCAL LenOutText     AS LONG
  LOCAL strResultText  AS STRING
  LOCAL strSalt        AS STRING

  AESstrength = %AES256
  strIV = LEFT$(strText,16)'first 16-bytes is IV
  REDIM IV(1 TO %BlockSize) AS BYTE AT STRPTR(strIV)

  strSalt = MID$(strText,17,%SaltLength)
  strPassword = strSalt & strPassword

  strText = MID$(strText,17+%SaltLength) 'strip off leading 16-byte IV

  ' Use SHA256 And hash Password
  ntStatus = BCryptOpenAlgorithmProvider( hHashAlg, _
                 $$BCRYPT_SHA256_ALGORITHM, $$NUL, 0)
                 '
  REDIM LenHashObject(1 TO 4) AS BYTE
  '
  lHashObject = VARPTR(LenHashObject(1))
  ntStatus = BCryptGetProperty( hHashAlg, $$BCRYPT_OBJECT_LENGTH, _
             lHashObject, 4, dwResult, 0 )
             '
  REDIM HashObject(1 TO lHashObject) AS BYTE
  '
  ntStatus = BCryptCreateHash( hHashAlg, phHash, _
                 VARPTR(HashObject(1)), _
                 lHashObject, BYVAL %Null, 0, 0 )
  ntStatus = BCryptHashData( phHash,  STRPTR(strPassword), _
                             LEN(strPassword), 0)
  ntStatus = BCryptFinishHash( phHash, VARPTR(BinHash(1)), 32, 0)
  '
  BCryptCloseAlgorithmProvider( hHashAlg, 0 )
  BCryptDestroyHash( phHash )

  ntStatus = BCryptOpenAlgorithmProvider( hAESAlg, _
                 $$BCRYPT_AES_ALGORITHM, $$NUL, 0 )
  REDIM LenKeyObject(1 TO 4) AS BYTE
  lKeyObject = VARPTR(LenKeyObject(1))
  '
  ntStatus = BCryptGetProperty( hAESAlg, $$BCRYPT_OBJECT_LENGTH, _
                 lKeyObject, 4, dwResult, 0 ) ' We want lKeyObject
  REDIM KeyObject(1 TO lKeyObject) AS BYTE

  LOCAL BCRYPT_CHAIN_MODE_CBC AS WSTRING
  BCRYPT_CHAIN_MODE_CBC = $$BCRYPT_CHAIN_MODE_CBC

  ntStatus = BCryptSetProperty( hAESAlg, $$BCRYPT_CHAINING_MODE, _
                    BYVAL STRPTR(BCRYPT_CHAIN_MODE_CBC), _
                    SIZEOF(BCRYPT_CHAIN_MODE_CBC), 0 )

  ntStatus = BCryptGenerateSymmetricKey( hAESAlg, hKey, _
                    VARPTR(KeyObject(1)), lKeyObject, _
                    VARPTR(BinHash(1)), AESstrength, 0 )' We want hKey

  ntStatus = BCryptDecrypt( hKey, STRPTR(strText), LEN(strText), _
                            BYVAL %Null, VARPTR(IV(1)), _
                            %BlockSize, BYVAL %Null, 0, LenOutText, _
                            %BCRYPT_BLOCK_PADDING ) ' We want LenOutText

  IF ntStatus THEN
    ? "BCryptDecrypt one length inaccurate",,"Decrypt failed"
    BCryptCloseAlgorithmProvider( hAESAlg, 0 )
    BCryptDestroyKey( hKey )
    EXIT FUNCTION
  END IF


  REDIM OutText(1 TO LenOutText) AS BYTE

  ntStatus = BCryptDecrypt(hKey, STRPTR(strText), LEN(strText), _
                           BYVAL %Null, VARPTR(IV(1)), _
                          %BlockSize, VARPTR(OutText(1)), LenOutText, _
                          0, %BCRYPT_BLOCK_PADDING )

  IF ntStatus THEN
   ? "Decrypt password different than encrypt password",,"Decrypt failed"
   BCryptCloseAlgorithmProvider( hAESAlg, 0 )
   BCryptDestroyKey( hKey )
   EXIT FUNCTION
  END IF
  '
  strResultText = PEEK$(VARPTR(OutText(1)),LenOutText) 'update 8/29/18

  BCryptCloseAlgorithmProvider( hAESAlg, 0 )
  BCryptDestroyKey( hKey )

  LOCAL ActualLength AS DWORD
  ActualLength = CVDWD(strResultText)
  FUNCTION = MID$(strResultText,5,ActualLength)

END FUNCTION
'-------------------------------------------------------------------------------------------------------------
FUNCTION GetRandomString(TheLength AS DWORD) AS STRING
  LOCAL hRand AS DWORD      'from code by David Roberts
  LOCAL sBuf  AS STRING
  BCryptOpenAlgorithmProvider(hRand, $$BCRYPT_RNG_ALGORITHM, $$NUL, 0)
  sBuf = STRING$(TheLength,0)
  BCryptGenRandom(hRand, STRPTR(sBuf), TheLength, 0)
  BCryptCloseAlgorithmProvider(hRand, 0)
  FUNCTION = sBuf
END FUNCTION
'-------------------------------------------------------------------------------------------------------------
FUNCTION SHA256HMAC( BYVAL strText AS STRING, BYVAL strPBsecrect AS STRING ) AS STRING ' Binary
' strText is message to be hashed  code by David Roberts
' strPBsecrect is secret HMAC key

  LOCAL hAlg, phHash AS DWORD
  LOCAL sBinHMAC AS STRING * 32 ' 32 for SHA256

  BCryptOpenAlgorithmProvider( hAlg, "SHA256"$$, $$NUL, _
                              %BCRYPT_ALG_HANDLE_HMAC_FLAG ) ' We need hAlg
  BCryptCreateHash( hAlg, phHash, BYVAL %Null, 0, STRPTR( strPBsecrect ), _
                              LEN( strPBsecrect ), 0 ) ' We need pbHash
  BCryptHashData( phHash, STRPTR( strText ), LEN( strText ), 0 )
  BCryptFinishHash( phHash, VARPTR( sBinHMAC ), 32, 0 ) '  32 for SHA256, We need sBinHMAC
  BCryptDestroyHash( phHash )
  BCryptCloseAlgorithmProvider( hAlg, 0 )
  FUNCTION = sBinHMAC

END FUNCTION
'-------------------------------------------------------------------------------------------------------------
'
FUNCTION Bin2HexNew( BYVAL strBinHash AS STRING ) AS STRING
' another David roberts function
' to turn your encrypted string into printable characters
' namely hex values
  LOCAL lngLength AS LONG
  LOCAL strHex AS STRING

  lngLength = LEN(strBinHash)*2 + 1 ' + 1 to accomodate a null terminator
  strHex = SPACE$( lngLength )
  ' at MSDN lngLength 'out' is Len(sBinHash) * 2, so
  CryptBinaryToStringA BYVAL STRPTR(strBinHash), LEN(strBinHash), _
                       %crypt_string_hexraw + %crypt_string_nocrlf, _
                       BYVAL STRPTR(strHex), lngLength
  FUNCTION = UCASE$( LEFT$( strHex, lngLength ) )
  '
END FUNCTION
'
FUNCTION Hex2Bin(BYREF strHex AS STRING) AS STRING
 'derivered from Rick Kelly's code
 ' Convert hex string to binary
 LOCAL lngBinaryLength AS LONG
 LOCAL strBinary AS STRING
 '
 strBinary = ""
 IF LEN(strHex) MOD 2 = 0 THEN
   lngBinaryLength = LEN(strHex) / 2
   strBinary = SPACE$(lngBinaryLength)
   CryptStringToBinary(BYVAL STRPTR(strHex), _
                       LEN(strHex), _
                       %CRYPT_STRING_HEXRAW, _
                       BYVAL STRPTR(strBinary), _
                       lngBinaryLength, _
                       0, _
                       0)
   FUNCTION = strBinary
 END IF
END FUNCTION
