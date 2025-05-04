#COMPILE EXE
#DIM ALL

#INCLUDE "win32api.inc"
#INCLUDE "PB_FileHandlingRoutines.inc"

$OutputFile = "ExtractFile.txt"
$InputFile = "MyLargeFile.txt"

FUNCTION PBMAIN () AS LONG
  RANDOMIZE TIMER
  '
  DIM a_strWork() AS STRING
  LOCAL lngR AS LONG
  LOCAL strOldEmail AS STRING
  LOCAL strNewEmail AS STRING
  LOCAL lngFileout AS LONG
  '
  TRY
    KILL EXE.PATH$ & $OutputFile
  CATCH
  FINALLY
  END TRY
  '
  lngFileOut = FREEFILE
  OPEN EXE.PATH$ & $OutputFile FOR OUTPUT AS #lngFileout
  PRINT #lngFileout,"Old Email" & $TAB & "New Email"
  '
  IF funReadTheFileIntoAnArray(EXE.PATH$ & $InputFile, a_strWork()) THEN
    FOR lngR = 1 TO UBOUND(a_strWork)
      IF RND(1,10) = 1 THEN
      ' extract ~10% of the data
        strOldEmail = PARSE$(a_strWork(lngR),$TAB,7)
        strNewEmail = PARSE$(strOldEmail,"@",1) & "@NewMailCo.com"
        PRINT #lngFileout,strOldEmail & $TAB & strNewEmail
      '
      END IF
    NEXT lngR
    '
  END IF
  '
  CLOSE #lngFileout
  '
  CON.STDOUT "Completed"
  SLEEP 2000
  '
END FUNCTION
