#COMPILE EXE
#DIM ALL
#DEBUG ERROR ON
#TOOLS OFF
'
' include the common display library
#INCLUDE "win32api.inc"
#INCLUDE "..\Libraries\CommonDisplay.inc"
#INCLUDE "..\Libraries\PB_FileHandlingRoutines.inc"
'
#INCLUDE "..\Libraries\Base32Str.inc"
#INCLUDE "..\Libraries\PBCrypto128.inc"
#INCLUDE "..\Libraries\PB_FileHash.inc"
'
$HashFile = "File_Hash_Record.txt"
'
FUNCTION PBMAIN () AS LONG
' the main PB function that is the first to be executed
  funPrepOutput("File Hash ID",0,0,40,120)
  '
  funLog("File Hash ID")
  '
  LOCAL strFileName AS STRING
  LOCAL strError AS STRING
  LOCAL strFileHash AS STRING
  '
   ' look for CSV files
  strFileName = DIR$(EXE.PATH$ & "Data\*.csv",ONLY %NORMAL)
  '
  WHILE strFilename <> ""
  ' have we processes this file already?
    funLog("Processing -> " & strFilename)
    '
    IF ISTRUE funProcessedFileAlready(EXE.PATH$ & "Data\" & strFileName, _
                                      strError, _
                                      strFileHash) THEN
      funLog "File already processed -> " & strFileName
      '
    ELSE
      funLog "File not yet processed -> " & strFileName
      ' process the file - if there is no error
      IF strError = "" THEN
      ' continue processing and
      ' then save the File Hash
        IF ISTRUE funAppendToFile(EXE.PATH$ & $HashFile, _
                                  strFileHash) THEN
          funLog("File Hash record updated")
        ELSE
          funLog("unable to save to File Hash record")
        END IF
        '
      ELSE
        ' process was unable to hash the file
        funLog("Error in hashing file -> " & strFileName)
        funLog("Error = " & strError)
      '
      END IF
      '
    END IF
    '
    ' get the next matching file - if any
    strFileName = DIR$
    '
  WEND
  '
  funWait()
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
  '
  END IF
  '
END FUNCTION
