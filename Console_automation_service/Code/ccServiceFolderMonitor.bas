' service sample program
' this service is just a framework .
' It compiles conditionally as either a service
' or a console application.
'

' n.b. this application uses the José Roca API libraries
' for latest version see link below
' http://www.jose.it-berater.org/smfforum/index.php?topic=5061.0


' License
' This program is public domain.
' Portions of this source are copyrighted, but free
' for use in your apps from Don Dickinson
' see the header files of the source required by pb_srvc.inc
'
' To install the sample application run:
' [name of exe].exe -install
' on the command line
'
' To start the service:
' go to the services applet in the control panel and find
' "Your Service Display Name" in the list. Highlight it and
' click the "run" button.
'
' To stop it:
' Find it again and click the "stop" button
'
' To uninstall:
' Close the services applet if running
' Get to a command line and execute:
' [name of exe].exe -uninstall
#COMPILE EXE
#DIM ALL

#INCLUDE "win32api.inc"
'
' include file hashing libraries
#INCLUDE "Base32Str.inc"
#INCLUDE "PBCrypto128.inc"
#INCLUDE "PB_FileHash.inc"
#INCLUDE "PB_FileHandlingRoutines.inc"
'
$HashFile = "File_Hash_Record.txt"
'
' The name of the service
$SERVICE_NAME = "AAA_MonitorFolderService"
$SERVICE_DISPLAY_NAME = "AAA_MonitorFolderService display name"
$SERVICE_DESCRIPTION  = "MonitorFolder Service description"
'
'- REM OUT this line to compile as a console application
%COMPILE_AS_SERVICE = 1
'
#IF %DEF(%COMPILE_AS_SERVICE)
  #INCLUDE "pb_srvc.inc"
#ENDIF
'
FUNCTION PBMAIN () AS LONG
  LOCAL lngResult AS LONG
  LOCAL lngWaitThreadID AS LONG

   '- This is the thread in the program
   '  that actually does the work
   '
   THREAD CREATE waitThread(0) TO lngWaitThreadID
   '
    '- Start the service
   #IF %DEF(%COMPILE_AS_SERVICE)
     pbsInit 0, $SERVICE_NAME, $SERVICE_DISPLAY_NAME, _
                $SERVICE_DESCRIPTION

     '- Run in a console
   #ELSE

     CON.STDOUT "Press ESC to shutdown server properly"
     DO
       IF INKEY$ = $ESC THEN
         CON.STDOUT "CONSOLE CANCELLED "
         EXIT DO
       END IF
       SLEEP 1000
     LOOP
   #ENDIF
     '
    '- Clean-up the thread handles
   THREAD CLOSE lngWaitThreadID TO lngResult
   '
END FUNCTION
'
THREAD FUNCTION waitThread ( BYVAL lngDoNothing AS LONG ) AS LONG
'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
'  waitThread
'
'  This thread loops and is the thread you'd
'  use for your service to do something.
'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  LOCAL strFilename AS STRING
  LOCAL strFileNamePath AS STRING
  LOCAL strError AS STRING
  LOCAL strFileHash AS STRING
  '
  #IF %DEF(%COMPILE_AS_SERVICE)
  '- This function tells us if the user stopped the service.
    DO UNTIL pbsIsShutdown()
  #ELSE
    DO
  #ENDIF
  '
  ' this is a sample of what your service could do
    IF ISTRUE ISFILE(EXE.PATH$ & "Monitor\keyfile.txt") THEN
      TRY
        KILL EXE.PATH$ & "Monitor\keyfile.txt"
      CATCH
      FINALLY
      END TRY
    END IF
    '
    ' look for a specific file ext
    strFileNamePath = EXE.PATH$ & "Monitor\"
    strFilename = DIR$(strFileNamePath & "*.dat")
    '
    WHILE strFilename <> ""
    ' have we seen this file before?
      IF ISFALSE funProcessedFileAlready(strFileNamePath & strFilename, _
                                         strError, _
                                         strFileHash, _
                                         strFileNamePath & $HashFile) THEN
      ' file has not been seen yet
      ' do some processing on the file?
      ' --
      ' after processing you need to add file hash
        ' to $HashFile file to ensure
        ' we dont process this file again
        funAppendToFile(strFileNamePath & $HashFile,strFileHash)
      '
      END IF
      strFilename = DIR$
    WEND
    '
    ' sleep for 10 seconds and then repeat
    SLEEP 10000
    '
  LOOP
  '
'
END FUNCTION
'
FUNCTION funProcessedFileAlready(strFile AS STRING, _
                                 strError AS STRING, _
                                 strFileHash AS STRING, _
                                 strHashFile AS STRING) AS LONG
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
  IF ISTRUE funReadTheFileIntoAnArray(strHashFile, _
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
