' PB_shell.inc

FUNCTION funWipeFolder (strFolder AS STRING) AS LONG
' wipe the specified folder and everything underneath it
  DIM strPVCS_Command AS STRING
  '
  TRY
    '
    IF TRIM$(strFolder) ="" THEN
      ERROR 151 ' raise an error
    END IF
    '
    strPVCS_Command = "RMDIR /S /Q " & strFolder
    '
    SHELL ENVIRON$("COMSPEC") + " /C " + strPVCS_Command ,0
    '
    FUNCTION = %TRUE
    '
  CATCH
    FUNCTION = %FALSE
  FINALLY
  END TRY
  '
END FUNCTION
'
FUNCTION funExecCmd(cmdLine1 AS ASCIIZ, _
                    OPTIONAL BYVAL lngConsole AS LONG) AS LONG
' execute process - optional console
  LOCAL rcProcess AS Process_Information
  LOCAL rcStart AS startupInfo
  LOCAL Retc AS LONG
  '
  LOCAL lngWindow AS LONG
  '
  IF lngConsole = 0 OR lngConsole = %CREATE_NO_WINDOW THEN
    lngWindow = %CREATE_NO_WINDOW
  ELSE
    lngWindow = %CREATE_NEW_CONSOLE
  END IF
  '
  rcStart.cb = LEN(rcStart)
  '
  RetC = CreateProcess(BYVAL %NULL, CmdLine1, BYVAL %NULL, BYVAL %NULL, 1&, lngWindow OR _
                       %NORMAL_PRIORITY_CLASS, _
                       BYVAL %NULL, BYVAL %NULL, rcStart, rcProcess)
  IF RetC = 0 THEN
  ' unable to start process
    EXIT FUNCTION
  END IF

  RetC = %WAIT_TIMEOUT
  DO WHILE RetC = %WAIT_TIMEOUT
    ' wait for x milliseconds ; if x = -1 then wait forever
    RetC = WaitForSingleObject(rcProcess.hProcess,-1)
    SLEEP 50
  LOOP
  CALL GetExitCodeProcess(rcProcess.hProcess, RetC)
  CALL CloseHandle(rcProcess.hThread)
  CALL CloseHandle(rcProcess.hProcess)
  '
  FUNCTION = %TRUE
  '
END FUNCTION
'
FUNCTION ConsoleShell(BYVAL CmdLine$, BYVAL ShowWindState&) AS LONG
' start process on console
    LOCAL Si     AS STARTUPINFO
    LOCAL Pi     AS PROCESS_INFORMATION
    LOCAL Result AS LONG

    Si.cb = SIZEOF(Si)
    Si.dwFlags = %STARTF_USESHOWWINDOW
    Si.wShowWindow = ShowWindState&

    Result = CreateProcess("", BYVAL STRPTR (CmdLine$), BYVAL %NULL, BYVAL %NULL, _
        0, %NORMAL_PRIORITY_CLASS OR %CREATE_NEW_CONSOLE, BYVAL %NULL, BYVAL %NULL, Si, Pi)

    IF Result THEN
        CALL CloseHandle(pi.hProcess)
        CALL CloseHandle(pi.hThread)
        FUNCTION = Result
    END IF
END FUNCTION

'
FUNCTION funShellToCommandNoWait(BYVAL strCMDString AS STRING, _
                           OPTIONAL BYVAL lngRedirect AS LONG, _
                           OPTIONAL BYVAL strFile AS STRING) AS LONG
' shell to the command line and run as a hidden window
' The optional parameters are lngRedirect = defaults to %False
' If it is true then the strFile should have the path to the file to be appended to
   '
   DIM lngResult AS LONG
   TRY
     FUNCTION = %TRUE
     ' e.g. strCMDString ="PCLI echo PCLI_VERSION=$PCLI_VERSION > " & strAppPath & "..\_Users\" & strUser & ".txt"
     IF ISFALSE lngRedirect THEN
     ' no redirection so shell out
       lngResult = SHELL( ENVIRON$("COMSPEC") + " /C " + strCMDString ,0)
       IF lngResult = 0 THEN
         FUNCTION = %FALSE
       ELSE
         FUNCTION = %TRUE
       END IF
       '
     ELSE
     ' redirection to file is required
       IF ISFALSE funAppendToFile(strFile, strCMDString) THEN
         FUNCTION = %FALSE
       END IF
     END IF
   CATCH
     FUNCTION = %FALSE
   FINALLY
   END TRY
END FUNCTION
'
FUNCTION funShellToCommand(BYVAL strCMDString AS STRING, _
                           OPTIONAL BYVAL lngRedirect AS LONG, _
                           OPTIONAL BYVAL strFile AS STRING) AS LONG
' shell to the command line and run as a hidden window
' The optional parameters are lngRedirect = defaults to %False
' If it is true then the strFile should have the path to the file to be appended to
   '
   TRY
     FUNCTION = %TRUE
     ' e.g. strCMDString ="PCLI echo PCLI_VERSION=$PCLI_VERSION > " & strAppPath & "..\_Users\" & strUser & ".txt"
     IF ISFALSE lngRedirect THEN
     ' no redirection so shell out
       SHELL ENVIRON$("COMSPEC") + " /C " + strCMDString ,0
     ELSE
     ' redirection to file is required
       IF ISFALSE funAppendToFile(strFile, strCMDString) THEN
         FUNCTION = %FALSE
       END IF
     END IF
   CATCH
     FUNCTION = %FALSE
   FINALLY
   END TRY
END FUNCTION
