#COMPILE EXE
#DIM ALL
#DEBUG ERROR ON
'
#TOOLS OFF
'
' include the common display library
#INCLUDE "win32api.inc"
#INCLUDE "Bcrypt.inc"
#INCLUDE "..\Libraries\CommonDisplay.inc"
#INCLUDE "..\Libraries\aes256.inc"
'
' set your two pass phrases - your encryption depends
' on a good long set of passphrases
$datapass= "Your_data_passphrasE^#("
$hmacpass= "Your_hmac_passphraSe_-@"
'
FUNCTION PBMAIN () AS LONG
' the main PB function that is the first to be executed
  funPrepOutput("Encryption",0,0,40,120)
  '
  funLog("Encryption")
  '
  LOCAL strData AS STRING       ' holds data to be encrypted
  LOCAL strEncrypted AS STRING  ' data after encryption
  LOCAL strDecrypted AS STRING  ' data after decryption
  '
  LOCAL strPlainEncrypted AS STRING ' plain text version of encrypted string
  '
  strData = "This is the data to be encrypted"
  ' encrypt the string
  strEncrypted = funEncrypt(strData,$datapass,$hmacpass)
  '
  IF strEncrypted = "" THEN
  ' zero length string indicates failure to encrypt
    funLog("Encryption failed")
  ELSE
  ' otherwise it encrypted ok
    funLog("Encryption success")
    ' store encrypted string as Hex values in plain text
    strPlainEncrypted = Bin2HexNew(strEncrypted)
    funlog(strPlainEncrypted)
  END IF
  '
  funLog("")
  ' return Hex values to Binary formats
  strEncrypted = Hex2Bin(strPlainEncrypted)
  ' decrypt the string
  strDecrypted = funDecrypt(strEncrypted,$datapass,$hmacpass)
  '
  IF strDecrypted = "" THEN
  ' decription failed - wrong passphrase?
    funLog("Decryption failed")
  ELSE
  ' decryption succeeded
    funLog("Decryption success")
    ' print out the decrypted string
    funlog(strDecrypted)
  END IF
  '
  funWait()
  '
END FUNCTION
'
