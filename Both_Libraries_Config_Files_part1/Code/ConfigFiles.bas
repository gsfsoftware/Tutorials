#COMPILE EXE
#DIM ALL
#DEBUG ERROR ON
'
#TOOLS OFF
'
' include the common display library
#INCLUDE ONCE "win32api.inc"
#INCLUDE ONCE "..\Libraries\CommonDisplay.inc"
#INCLUDE ONCE "..\Libraries\PB_FileHandlingRoutines.inc"
#INCLUDE ONCE "..\Libraries\PB_Txt_ConfigFile.inc"
' include the encryption library
#INCLUDE ONCE "..\Libraries\aes256.inc"
'
' encryption configuration
' set your two pass phrases - your encryption depends
' on a good long set of passphrases
$datapass= "Your_data_passphrasE^#("
$hmacpass= "Your_hmac_passphraSe_-@"
'
FUNCTION PBMAIN () AS LONG
' the main PB function that is the first to be executed
  funPrepOutput("Config Files",0,0,40,120)
  '
  funLog("Config Files")
  '
  LOCAL strServer AS STRING
  LOCAL strDatabase AS STRING
  LOCAL strUser AS STRING
  LOCAL strPassword AS STRING
  LOCAL strEncryptedPassword AS STRING
  '
  '
  IF ISTRUE funTxtCfg_LoadFile(EXE.PATH$ & "Config.txt") THEN
  ' config file is loaded
    funLog("Config file loaded")
    '
    strServer   = funTxtCfg_GetValue("server")
    strDatabase = funTxtCfg_GetValue("database")
    strUser     = funTxtCfg_GetValue("user")
    strPassword = funTxtCfg_GetValue("password")
    '
    ' get data back from the config file
    funLog("Server   = " & strServer)
    funLog("Database = " & strDatabase)
    funLog("User     = " & strUser)

'    funLog("Password = " & strPassword)
    '
    ' encrypt the password
'    strEncryptedPassword = Bin2HexNew(funEncrypt(strPassword, _
'                                                 $datapass, _
'                                                 $hmacpass))
 ' decrypt the password
    strPassword = funDecrypt(Hex2Bin(strPassword),$datapass,$hmacpass)
    '
    funLog("Password = " & strPassword)
'
    '
    ' update the config file
    IF ISTRUE funTxtCfg_PutValue("user setting","abc") THEN
    ' save to array successful
      IF ISTRUE funTxtCfg_SaveFile(EXE.PATH$ & "Config.txt") THEN
        funLog("Config file saved successfully")
      ELSE
        funLog("unable to save config file")
      END IF
      '
    ELSE
      funLog("unable to update config array")
    END IF
    '
  ELSE
    funLog("Unable to load config file")
  END IF
  funWait()
  '
END FUNCTION
'
