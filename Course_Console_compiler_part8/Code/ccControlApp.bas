#COMPILE EXE
#DIM ALL
#DEBUG ERROR ON
'
#TOOLS OFF
' include the common display library
#INCLUDE "win32api.inc"
#INCLUDE "CommonDisplay.inc"
#INCLUDE "PB_CommandLine.inc"
'
FUNCTION PBMAIN () AS LONG
  funPrepOutput("Control App",0,0,40,120)
  ' control app
  funLog("Control App running")
  funLog("Calling Parameter app")
  '
  LOCAL strCmd AS STRING
  strCmd = "ccCommandLineParameters.exe " & _
           "/TimeSlotRef#" & $DQ & "Monday" & $DQ & " " & _
           "/Building#" & $DQ & "Tuesday" & $DQ & " " & _
           "/Hour#" & $DQ & "Wednesday" & $DQ & " " & _
           "/TimeSlot#" & $DQ & "Thursday" & $DQ
  funExecCmd strCMD & "", %TRUE
  '
  ' change order and casing of parameters
  strCmd = "ccCommandLineParameters.exe " & _
           "/TimeSlotRef#" & $DQ & "Monday" & $DQ & " " & _
           "/Hour#" & $DQ & "Wednesday" & $DQ & " " & _
           "/TimeSlot#" & $DQ & "Thursday" & $DQ & " " & _
           "/BuilDing#" & $DQ & "Tuesday" & $DQ
  funExecCmd strCMD & "", %TRUE
  '
  ' change delimiters on one parameter from / to |
  strCmd = "ccCommandLineParameters.exe " & _
           "/TimeSlotRef#" & $DQ & "Monday" & $DQ & " " & _
           "/Hour#" & $DQ & "Wednesday" & $DQ & " " & _
           "/TimeSlot#" & $DQ & "Thursday" & $DQ & " " & _
           "|Building#" & $DQ & "Tuesday" & $DQ
  funExecCmd strCMD & "", %TRUE
  funWait()
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
