#COMPILE EXE
#DIM ALL
#DEBUG ERROR ON
'
#TOOLS OFF
'
' include the common display library
#INCLUDE "win32api.inc"
#INCLUDE "..\Libraries\CommonDisplay.inc"
'
#INCLUDE "..\Libraries\PB_FileHandlingRoutines.inc"
'
' include file hashing libraries
#INCLUDE "..\Libraries\Base32Str.inc"
#INCLUDE "..\Libraries\PBCrypto128.inc"
#INCLUDE "..\Libraries\PB_FileHash.inc"
'
$HashFile = "File_Hash_Record.txt"
'
FUNCTION PBMAIN () AS LONG
' the main PB function that is the first to be executed
  funPrepOutput("Monitor Folder",0,0,40,120)
  '
  funLog("Monitor Folder")
  '
  ' check the folder for a specific file
  LOCAL strFileName AS STRING
  LOCAL strFolder AS STRING
  LOCAL strFileNamePath AS STRING
  '
  ' populate the name of the file and folder to monitor
  strFileName = "TargetFile.txt"
  strFolder   = EXE.PATH$ & "Targetfolder"
  '
  strFileNamePath = strFolder & "\" & strFileName
  '
  ' check for file appearing
  funCheckForSpecificFile(strFileNamePath)
  '
  funWait()
  '
END FUNCTION
'
FUNCTION funCheckForSpecificFile(strFileNamePath AS STRING) AS LONG
' look for a specific file
  LOCAL strError AS STRING
  LOCAL strFileHash AS STRING
  '
  funLog("Looking for " & strFileNamePath)
  '
  DO
  ' loop until found
    IF ISTRUE ISFILE(strFileNamePath) THEN
      funLog("File Found")
      ' do something?
      IF ISFALSE funProcessedFileAlready(strFileNamePath, _
                                         strError, _
                                         strFileHash) THEN
        ' we've not seen this file before
        '
        ' do some processing?
        funLog("Processing")
        '
        ' after processing you need to add file hash
        ' to $HashFile file to ensure
        ' we dont process this file again
        funAppendToFile($HashFile,strFileHash)
        '
        EXIT LOOP ' do you want to exit having found a file?
        '           or wait for more files
        '
      ELSE
      ' we have seen this file before - so keep looking
      '
      END IF
      '
    END IF
    ' delay for a while before checking again
    ' to ensure you don't max out a processing core
    '
    SLEEP 1000  ' wait for 1 second before checking again
    ' or increase this to 60000 to check once a minute
  LOOP
  '
END FUNCTION
'
FUNCTION funProcessedFileAlready(strFile AS STRING, _
                                 strError AS STRING, _
                                 strFileHash AS STRING) AS LONG
' has this file already been processed?
  LOCAL strSHAhash AS STRING
  DIM a_strHashDB() AS STRING
  LOCAL lngIndex AS LONG
  '
  FUNCTION = %FALSE
  '
  ' get the file hash
  strSHAhash = funGetSHA(strFile)
  '
  IF INSTR(strSHAhash,"Unable to HASH") > 0 THEN
  ' routine was unable to hash the file
  ' so return the error
    strError = strSHAhash
    FUNCTION = %FALSE
    EXIT FUNCTION
  END IF
  '
  ' is this in Hash DB already?
  funLog("checking FileHash record")
  IF ISTRUE funReadTheFileIntoAnArray(EXE.PATH$ & $HashFile, _
                                      a_strHashDB()) THEN
    ' is this hash in the array
    ' is this hash in the array
    ARRAY SCAN a_strHashDB(), COLLATE UCASE, = strSHAhash, _
               TO lngIndex
               '
    IF lngIndex > 0 THEN
    ' item found
      strError = ""
      strFileHash = strSHAhash
      FUNCTION = %TRUE
    ELSE
    ' item not found
      strError = ""
      strFileHash = strSHAhash
      FUNCTION = %FALSE
    END IF
    '
  ELSE
  ' no Hash file yet - so just return the hash
    strError = ""
    strFileHash = strSHAhash
    FUNCTION = %FALSE
  END IF
'
END FUNCTION
