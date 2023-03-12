#COMPILE EXE
#DIM ALL
#DEBUG ERROR ON
'
#TOOLS OFF
'
' include the common display library
#INCLUDE "win32api.inc"
#INCLUDE "CommonDisplay.inc"
'
#INCLUDE "PB_ArchiveFiles.inc"

'
FUNCTION PBMAIN () AS LONG
' the main PB function that is the first to be executed
  funPrepOutput("Archive Files",0,0,40,120)
  '
  funLog("Archive Files")
  '
  LOCAL strFolder AS STRING      ' Folder to scan
  LOCAL strLogFile AS STRING     ' path & name of log file
  LOCAL strAction AS STRING      ' action to perform  (LOG/DELETE)
  LOCAL strWildCard AS STRING    ' mask of files to look for
  LOCAL strTimePeriod AS STRING  ' time period DAYS/MINS
  LOCAL strError AS STRING       ' variable to hold any error messages
  LOCAL lngUnits AS LONG         ' number if Days/Mins
  '
  strFolder = EXE.PATH$ & "ArchiveFolder"
  strAction = "LOG" ' "DELETE"
  strLogFile = EXE.PATH$ & "Archive_Log.txt"
  strWildCard = "*.txt"
  strTimePeriod = "DAYS"
  lngUnits      = 30             ' log/delete files older than this
                                 ' number of days/hours/mins
  '
  IF ISTRUE funArchiveFiles(strFolder, _
                            strAction, _
                            strLogFile, _
                            strWildCard, _
                            strTimePeriod, _
                            lngUnits, _
                            strError) THEN
  ELSE
  ' some error occurred
    funLog(strError)
  '
  END IF
  '
  funWait()
  '
END FUNCTION
'
