#COMPILE EXE
#DIM ALL
#DEBUG ERROR ON

' include the common display library
#INCLUDE "win32api.inc"
#INCLUDE "..\Libraries\CommonDisplay.inc"
#INCLUDE "..\Libraries\PB_FileHandlingRoutines.inc"
'
$CSVFileIn = "MyFile.csv"
$CSVFileOut = "MyNewFile.csv"
'
FUNCTION PBMAIN () AS LONG
' the main PB function that is the first to be executed
  funPrepOutput("Bulk Replace",0,0,40,120)
  '
  funLog("Walk through on Bulk Replacing")
  '
  LOCAL strFile AS STRING
  '
  strFile = funBinaryFileAsString(EXE.PATH$ & $CSVFileIn)
  '
  IF strFile <> "" THEN
    funLog("File loaded successfully")
    REPLACE $LF WITH $CRLF IN strFile
    '
    ERRCLEAR
    '
    IF ISTRUE funBinaryStringSaveAsFile(EXE.PATH$ & $CSVFileOut, _
                                        strFile) THEN
      funlog("File saved successfully")
    ELSE
      funLog("Cannot save file " & ERROR$)
    END IF
    '
  ELSE
    funLog("File not loaded")
  END IF

  '
  funWait()
  '
END FUNCTION
