'
'  Processes running . PB_Processes.inc
'
DECLARE FUNCTION EnumProcesses (lpidProcess AS DWORD, BYVAL cb AS DWORD, cbNeeded AS DWORD) AS LONG
DECLARE FUNCTION GetModuleFileNameEx (BYVAL hProcess AS DWORD, BYVAL hModule AS DWORD, ModuleName AS ASCIIZ, BYVAL nSize AS DWORD) AS DWORD
DECLARE FUNCTION EnumProcessModules (BYVAL hProcess AS DWORD, BYREF lphModule AS DWORD, BYVAL cb AS DWORD, cbNeeded AS DWORD) AS LONG
'
TYPE PROCESSENTRY32
   dwSize AS DWORD
   cntUsage AS DWORD
   th32ProcessID AS DWORD          ' This process
   th32DefaultHeapID AS LONG PTR
   th32ModuleID AS DWORD           ' Associated exe
   cntThreads AS DWORD
   th32ParentProcessID AS DWORD    ' This process's parent process
   pcPriClassBase AS LONG          ' Base priority of process threads
   dwFlags AS DWORD
   szExeFile AS ASCIIZ * %MAX_PATH
END TYPE
'
FUNCTION funProcessCount(strProcessName AS STRING) AS LONG
' count the number of processes running by this name
'
' example call
'  IF funProcessCount(GetAppName)>1 THEN
'  ' more than one version on this running ?
'
  DIM Reply AS STRING
  DIM lngR AS INTEGER
  DIM lngCount AS LONG
  DIM strModule AS STRING
  DIM strEXE AS STRING
  CALL EnumModules(Reply)  ' pick up the processes in a string
  '
  FOR lngR= 1 TO PARSECOUNT(Reply,$CRLF)
    strModule = PARSE$(Reply,$CRLF,lngR)
    strExe = UCASE$(PARSE$(strModule,"|",2))
    IF INSTR(strExe,UCASE$(strProcessName))>0 THEN
      INCR lngCount
    END IF
  NEXT lngR
  '
  FUNCTION = lngCount
'
END FUNCTION
'
FUNCTION GetAppName AS STRING
' return the name of the application
  LOCAL sName AS STRING, zPath AS ASCIIZ * %MAX_PATH
  GetModuleFileName GetModuleHandle(""), zPath , %MAX_PATH
  sName = FileNam(zPath)
  FUNCTION = sName
END FUNCTION

'
FUNCTION FileNam (BYVAL Src AS STRING) AS STRING
' return the file name given the path
  LOCAL x AS LONG

  x = INSTR(-1, Src, ANY ":/\")
  IF x THEN
      FUNCTION = MID$(Src, x + 1)
  ELSE
      FUNCTION = Src
  END IF

END FUNCTION
'
FUNCTION GetProcessNameRunningHandle(strProcessName AS STRING) AS LONG
  ' is this process already running
  ' - where strProcessname is the name of the exe and not its path
  DIM Reply AS STRING
  DIM lngR AS INTEGER
  DIM strModule AS STRING
  DIM strEXE AS STRING
  CALL EnumModules(Reply)  ' pick up the processes in a string
  '
  FOR lngR= 1 TO PARSECOUNT(Reply,$CRLF)
    strModule = PARSE$(Reply,$CRLF,lngR)
    strExe = PARSE$(strModule,"|",2)
    IF FileNam(strExe) = strProcessName THEN
      FUNCTION = VAL(PARSE$(strModule,"|",1))
      EXIT FUNCTION
    END IF
  NEXT lngR
  '
  FUNCTION = %False
'
END FUNCTION
'
FUNCTION ProcessNameRunning(strProcessName AS STRING) AS LONG
  ' is this process already running
  ' - where strProcessname is the name of the exe and not its path
  DIM Reply AS STRING
  DIM lngR AS INTEGER
  DIM strModule AS STRING
  DIM strEXE AS STRING
  CALL EnumModules(Reply)  ' pick up the processes in a string
  '
  FOR lngR= 1 TO PARSECOUNT(Reply,$CRLF)
    strModule = PARSE$(Reply,$CRLF,lngR)
    strExe = PARSE$(strModule,"|",2)
    IF FileNam(strExe) = strProcessName THEN
      FUNCTION = %TRUE
      EXIT FUNCTION
    END IF
  NEXT lngR
  '
  FUNCTION = %False
'
END FUNCTION
'
FUNCTION ProcessRunning(ProcessID AS DWORD)AS INTEGER
' return true or false for process is running
' example call
'  if istrue ProcessRunning(GetModuleHandle("")) then
'
  DIM Reply AS STRING
  DIM intR AS INTEGER
  DIM strModule AS STRING
  '
  FUNCTION = %FALSE
  '
  CALL EnumModules(Reply)
  IF TRIM$(Reply) = "" THEN
  ' nothing running ?
    FUNCTION = %FALSE
    EXIT FUNCTION
  ELSE
    FOR intR= 1 TO PARSECOUNT(Reply,$CRLF)
      strModule = PARSE$(Reply,$CRLF,intR)
      IF VAL(PARSE$(strModule,"|",1)) = ProcessID THEN
        FUNCTION = %TRUE
      END IF
    NEXT intR
  END IF
  '
END FUNCTION

SUB EnumModules(Reply AS STRING)
' enumerate the processes running
  LOCAL Proc AS PROCESSENTRY32
  LOCAL cb AS DWORD, cbNeeded AS DWORD
  LOCAL i AS LONG, nProcesses AS LONG, hProcess AS DWORD, lResult AS LONG
  LOCAL hPsApiDll AS DWORD, hEnumProcesses AS DWORD, hGetModuleFileNameEx AS DWORD, hEnumProcessModules AS DWORD

  hPsApiDll = GetModuleHandle("psApi.dll")
  IF hPsApiDll = 0 THEN hPsApiDll = LoadLibrary("psApi.dll")
    hEnumProcesses = GetProcAddress(hPsApiDll, "EnumProcesses")
    hGetModuleFileNameEx = GetProcAddress(hPsApiDll, "GetModuleFileNameExA")
    hEnumProcessModules = GetProcAddress(hPsApiDll, "EnumProcessModules")
    cb = 1000
    DO
      REDIM ProcessIDs(1 TO cb / 4) AS DWORD
      CALL DWORD hEnumProcesses USING EnumProcesses (ProcessIDs(1), cb, cbNeeded) TO lResult
      IF cb > cbNeeded THEN EXIT DO
      cb = cb * 2
    LOOP
    '
    Reply = ""
    nProcesses = cbNeeded / 4
    FOR i = 1 TO nProcesses
       hProcess = OpenProcess(%PROCESS_ALL_ACCESS  , %TRUE, _
                              ProcessIDs(i))
      IF hProcess THEN
        '
        cb = 100
        DO
          REDIM Modules(1 TO cb / 4) AS DWORD
          CALL DWORD hEnumProcessModules USING _
          EnumProcessModules (hProcess, Modules(1), cb, cbNeeded) TO lResult
          IF lResult = 0 THEN cbNeeded = 0: EXIT DO
          IF cb > cbNeeded THEN EXIT DO ELSE cb = cb * 2
        LOOP
        IF cbNeeded >= 4 THEN
          CALL DWORD hGetModuleFileNameEx USING GetModuleFileNameEx _
            (hProcess, Modules(1), Proc.szExeFile, SIZEOF(Proc.szExeFile)) TO lResult
            IF lResult THEN Reply = Reply + STR$(ProcessIDs(i))+ "|" + Proc.szExeFile + $CRLF
        END IF
       CloseHandle hProcess
     END IF
  NEXT nProcesses
END SUB

'
