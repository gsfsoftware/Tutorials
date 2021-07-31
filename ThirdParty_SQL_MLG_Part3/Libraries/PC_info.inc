' PC_info.inc
'
TYPE NATIVE_SYSTEM_INFO
  wProcessorArchitecture AS WORD
  wReserved AS WORD
  dwPageSize AS DWORD
  lpMinimumApplicationAddress AS DWORD
  lpMaximumApplicationAddress AS DWORD
  dwActiveProcessorMask AS DWORD
  dwNumberOfProcessors AS DWORD
  dwProcessorType AS DWORD
  dwAllocationGranularity AS DWORD
  wProcessorLevel AS WORD
  wProcessorRevision AS WORD
END TYPE
'
FUNCTION funPCComputerName() AS STRING
' return the computer name
  FUNCTION = ENVIRON$("COMPUTERNAME")
'
END FUNCTION
'
FUNCTION funUserName() AS STRING
' return the user name
  'LOCAL zName AS ASCIIZ * %UNLEN +1
  'GetUsername zName, SIZEOF(zName)
  '
  FUNCTION = ENVIRON$("USERNAME")
'
END FUNCTION
'
FUNCTION funGetDomain() AS STRING
  FUNCTION = ENVIRON$("USERDOMAIN")
END FUNCTION
'
FUNCTION funGetMemory() AS STRING
' return the memory in GB
  LOCAL YourMem AS MEMORYSTATUSEX
  '
  YourMem.dwlength = SIZEOF(YourMem)
  GlobalMemoryStatusEx YourMem
  '
  FUNCTION = FORMAT$(ROUND(YourMem.ullTotalPhys /(1024*1024*1024),0))
'
END FUNCTION
'
FUNCTION funProcessorCount() AS STRING
' return the core count
  'LOCAL SI AS SYSTEM_INFO
  'GetSystemInfo SI
  'FUNCTION = SI.dwNumberOfProcessors
  '
  FUNCTION = ENVIRON$("NUMBER_OF_PROCESSORS")
'
END FUNCTION
'
FUNCTION fun64or32bit() AS STRING
' is it 32 or 64 bit
  LOCAL si                    AS NATIVE_SYSTEM_INFO
  LOCAL arch,CPUnum           AS LONG
  LOCAL SystemInfo            AS NATIVE_SYSTEM_INFO
  LOCAL pGetNativeSystemInfo  AS LONG
  '
  pGetNativeSystemInfo = GetProcAddress(GetModuleHandle("kernel32.dll"), _
                         "GetNativeSystemInfo")
  IF (pGetNativeSystemInfo) THEN
    CALL DWORD pGetNativeSystemInfo USING _
                           GetNativeSystemInfo(SystemInfo)
    arch = SystemInfo.wProcessorArchitecture
    CPUnum=SystemInfo.dwNumberOfProcessors
    '
    IF (arch = %PROCESSOR_ARCHITECTURE_AMD64) THEN
      FUNCTION = "64 bit system"
    ELSE
      FUNCTION = "32 bit system"
    END IF
  ELSE
  'get system information
    GetSystemInfo BYVAL VARPTR(si)
    arch = si.wProcessorArchitecture
    '
    SELECT CASE arch
      CASE %PROCESSOR_ARCHITECTURE_AMD64,%PROCESSOR_ARCHITECTURE_IA64
        FUNCTION = "64 bit system"
      CASE %PROCESSOR_ARCHITECTURE_INTEL
        FUNCTION = "64 bit system"
      CASE ELSE
        FUNCTION = "32 bit system"
    END SELECT
  END IF
  '
END FUNCTION
'
