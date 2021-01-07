'
'  pb_srvc.inc
'
'  Helper functions for creating an NT service from
'  a pb application.
'   By Don Dickinson
'   Portions of this code were derived from posts by various people in the
'   pb forums.
'   I make no claim to coypright on pb_srvc.inc, it is provided as-is for
'   any use you see fit.
'   See the header files of the required files (pb_file.inc, etc) for their
'   individual copyright information.
'
'   All of this code is licensed as free source code. Do with it as you wish
'   compile it in your programs without needed to acknowledge me, etc.
'
#IF NOT %DEF(%PB_SRVC_INC)
%PB_SRVC_INC = 1
#INCLUDE "pb_file.inc"


'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
'  Globals
'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
GLOBAL g_pbsrvc_Instance AS LONG
GLOBAL g_pbsrvc_ShutDown AS LONG
GLOBAL g_pbsrvc_Control AS LONG
GLOBAL g_pbsrvc_Status AS DWORD
GLOBAL g_pbsrvc_HandlerEvent AS DWORD
GLOBAL g_pbsrvc_Name AS STRING
GLOBAL g_pbsrvc_Disp AS STRING
GLOBAL g_pbsrvc_Description AS STRING
GLOBAL g_SS AS Service_Status
GLOBAL g_STE() AS Service_Table_Entry

'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
'  function prototypes
'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
DECLARE SUB pbsMessage(BYVAL sMsg AS STRING)
DECLARE FUNCTION pbsInstall() AS LONG
DECLARE FUNCTION pbsUninstall() AS LONG
DECLARE SUB pbsMain (BYVAL dwArgs AS DWORD, BYVAL lpszArgv AS DWORD)
DECLARE FUNCTION pbsStart() AS LONG
DECLARE SUB pbsHandler(BYVAL pControl AS DWORD)
DECLARE FUNCTION pbsInit ( BYVAL hCurInst AS LONG, BYVAL sName AS STRING, _
      BYVAL sDispName AS STRING, BYVAL sDescription AS STRING ) AS LONG
'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
'  pbsMessage
'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
SUB pbsMessage(BYVAL sMsg AS STRING)
   #IF %DEF(%PB_CC32)
   STDOUT sMsg
   #ELSE
   msgbox sMsg, %MB_ICONINFORMATION OR %MB_OK, g_pbsrvc_Disp
   #ENDIF
END SUB

'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
'  pbsInit
'
'  Call this function from your program's winmain function right away.
'
'  Function returns %true if the app should be running
'  Function returns %false it they were just installing, etc.
'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
FUNCTION pbsInit ( BYVAL hCurInst AS LONG, BYVAL sName AS STRING, _
      BYVAL sDispName AS STRING, BYVAL sDescription AS STRING ) AS LONG

   DIM iRet AS LONG
   DIM sCommand AS STRING

   FUNCTION = %false
   iRet = GetCurrentProcess()
   iRet = SetPriorityClass(iRet, %IDLE_PRIORITY_CLASS)
   g_pbsrvc_Instance = hCurInst
   g_pbsrvc_Name = sName
   g_pbsrvc_Disp = sDispName
   g_pbsrvc_Description = sDescription

   sCommand = TRIM$(LCASE$(COMMAND$))

   IF INSTR(sCommand,"uninstall") THEN

      iRet = pbsUninstall()
      IF iRet THEN
         pbsMessage "Service '" + sName + "' has been uninstalled"
      ELSE
         pbsMessage "Unable to uninstall service '" + sName + "'"
      END IF

   ELSEIF INSTR(sCommand, "install") THEN
      iRet = pbsInstall()
      IF iRet THEN
         pbsMessage "Service '" + sName + "' has been installed"
      ELSE
         pbsMessage "Unable to install service '" + sName + "'"
      END IF

   ELSEIF INSTR(sCommand, "?") OR INSTR(sCommand, "help") THEN
      pbsMessage "Help on "+ sDispName + ", usage:"+ $CRLF + $CRLF + _
           "-install or /install (installs this service)" + $CRLF + _
           "-uninstall or /uninstall (uninstalls this service)" + $CRLF + _
           "-? or /? shows this helpscreen" + $CRLF+ _
           "No parameters starts the service (if installed)"
   ELSE
      IF pbsStart() = %false THEN
         pbsMessage "Service Start FAILED"
      END IF
   END IF
   FUNCTION = %true

END FUNCTION

'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
'  pbsInstall
'
'  Call this if the user passes -install on the command line.
'
'  Returns
'  %true on success
'  %false on failure
'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

FUNCTION SetRegValue(lpKey AS LONG,BYVAL cMainkey AS STRING, BYVAL strKEY AS STRING, BYVAL Setting AS STRING) AS LONG
ON ERROR RESUME NEXT
LOCAL hKey   AS LONG
LOCAL Result AS LONG
LOCAL zText  AS ASCIIZ * 2048
IF strKEY = "*" THEN strKEY = CHR$(0,0)
IF RegCreateKeyEx(lpKey, cMainKey + CHR$(0),0, "", %REG_OPTION_NON_VOLATILE, _
                   %KEY_ALL_ACCESS, BYVAL %NULL, hKey, Result) <> %ERROR_SUCCESS THEN
    FUNCTION = 0
    EXIT FUNCTION
END IF
zText = Setting
IF LEN(Setting) THEN
    RegSetValueEx hKey, strKEY+CHR$(0), 0, %REG_SZ, zText, LEN(Setting)+1
ELSE
    RegSetValueEx hKey, strKEY+CHR$(0), 0, %REG_SZ, zText, 1
END IF
RegCloseKey hKey
FUNCTION = 0
END FUNCTION


FUNCTION pbsInstall () AS LONG

   DIM iRet AS LONG
   DIM hSCManager AS LONG
   DIM hService AS LONG
   DIM sApp AS STRING
   DIM strMainkey AS STRING
   DIM strKey AS STRING
   DIM strSetting AS STRING

   '- Open the SC Manager
   hSCManager = OpenSCManager(BYVAL 0, BYVAL 0, %SC_MANAGER_CREATE_SERVICE)
   IF hSCManager = 0 THEN
      FUNCTION = %false
      EXIT FUNCTION
   END IF

   sApp = GetExeName()
   IF sApp = "" THEN
      FUNCTION = %false
      EXIT FUNCTION
   END IF
   '
   ' SC_HANDLE hSCManager,   // handle to service control manager database
   ' LPCTSTR lpServiceName,  // pointer to name of service to start
   ' LPCTSTR lpDisplayName,  // pointer to display name
   ' DWORD dwDesiredAccess,  // type of access to service
   ' DWORD dwServiceType,  // type of service
   ' DWORD dwStartType,  // when to start service
   ' DWORD dwErrorControl,   // severity if service fails to start
   ' LPCTSTR lpBinaryPathName,   // pointer to name of binary file
   ' LPCTSTR lpLoadOrderGroup,   // pointer to name of load ordering group
   ' LPDWORD lpdwTagId,  // pointer to variable to get tag identifier
   ' LPCTSTR lpDependencies,   // pointer to array of dependency names
   ' LPCTSTR lpServiceStartName,   // pointer to account name of service
   ' LPCTSTR lpPassword    // pointer to password for service account
   '
   hService = CreateService(hSCManager, g_pbsrvc_Name + $NUL, _
                g_pbsrvc_Disp + $NUL, _
                %SERVICE_ALL_ACCESS OR %SERVICE_USER_DEFINED_CONTROL, _
                %SERVICE_WIN32_OWN_PROCESS, _
                %SERVICE_DEMAND_START, %SERVICE_ERROR_NORMAL, _
                sApp + $NUL, BYVAL %NULL, BYVAL %NULL, _
                BYVAL %NULL, BYVAL %NULL, BYVAL %NULL)
   IF hService = 0 THEN
      CloseServiceHandle hSCManager
      FUNCTION = %false
      EXIT FUNCTION
   END IF

   CloseServiceHandle hService
   CloseServiceHandle hSCManager
   '
   strMainkey = "SYSTEM\CurrentControlSet\Services\" & g_pbsrvc_Name
   strKEY =     "Description"
   strSetting = g_pbsrvc_Description

   ' now set the registry key for description
   IF ISFALSE SetRegValue(%HKEY_LOCAL_MACHINE,strMainkey, strKEY , strSetting) THEN
   ' couldnt set the registry key

   '
   END IF
   '
   FUNCTION = %true

END FUNCTION

'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
'  pbsUninstall
'
'  This function un-installs a service by name
'
'  Returns
'  %true on success
'  %false on failure
'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
FUNCTION pbsUninstall () AS LONG

   DIM hSCManager AS LONG
   DIM hService AS LONG

   hSCManager = OpenSCManager(BYVAL %NULL, BYVAL %NULL, _
                %SC_MANAGER_CREATE_SERVICE)
   IF hSCManager = 0 THEN
      FUNCTION = %false
      EXIT FUNCTION
   END IF

   hService = OpenService(hSCManager, g_pbsrvc_Name & $NUL, _
              %SERVICE_ALL_ACCESS)
   IF hService = 0 THEN
      FUNCTION = %false
   ELSEIF DeleteService (hService) THEN
      FUNCTION = %true
   ELSE
      FUNCTION = %false
   END IF

   '- Cleanup
   IF hService THEN CloseServiceHandle hService
   IF hSCManager THEN CloseServiceHandle hSCManager

END FUNCTION

'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
'  pbsStart
'
'  Starts the service
'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
FUNCTION pbsStart() AS LONG

   DIM iRet AS LONG
   DIM iErr AS LONG

   REDIM g_STE(1 TO 2) AS Service_Table_Entry
   g_STE(1).lpServiceName = STRPTR(g_pbsrvc_Name)
   g_STE(1).lpServiceProc = CODEPTR(pbsMain)
   g_STE(2).lpServiceName = 0
   g_STE(2).lpServiceProc = 0

   iRet = StartServiceCtrlDispatcher(g_STE(1))
   iErr = GetLastError()
   IF iRet = 0 THEN
      FUNCTION = %true
   ELSE
      FUNCTION = %false
   END IF

END FUNCTION

'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
'  pbsMain
'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
SUB pbsMain(BYVAL dwArgs AS DWORD, BYVAL lpszArgv AS DWORD) EXPORT

   DIM iRet AS LONG
   DIM iLong AS LONG

   g_SS.dwServiceType = %SERVICE_WIN32_OWN_PROCESS
   g_SS.dwCurrentState = %SERVICE_START_PENDING
   g_SS.dwControlsAccepted = %SERVICE_ACCEPT_STOP OR %SERVICE_ACCEPT_SHUTDOWN
      '%SERVICE_ACCEPT_PAUSE_CONTINUE Or %SERVICE_ACCEPT_SHUTDOWN
   g_SS.dwWin32ExitCode = 0
   g_SS.dwServiceSpecificExitCode = 0
   g_SS.dwCheckPoint = 0
   g_SS.dwWaitHint = 0

   g_pbsrvc_Status = RegisterServiceCtrlHandler (g_pbsrvc_Name & $NUL, _
         CODEPTR(pbsHandler))

   g_SS.dwCurrentState = %SERVICE_START_PENDING
   SetServiceStatus g_pbsrvc_Status, g_SS

   '- Initialization code goes here
   g_pbsrvc_HandlerEvent = CreateEvent (BYVAL %Null, _
                           BYVAL 0, BYVAL 0, "HandlerEvent" & $NUL)

   '- Notify SCM that we're in running
   g_SS.dwCurrentState = %SERVICE_RUNNING
   SetServiceStatus g_pbsrvc_Status, g_SS

   '- Add handler events here
   g_pbsrvc_ShutDown = %false
   DO UNTIL g_pbsrvc_ShutDown
      iRet = WaitForSingleObject(BYVAL g_pbsrvc_HandlerEvent, 50)
      SELECT CASE iRet
         CASE %WAIT_FAILED
            g_pbsrvc_ShutDown = %True

         CASE %WAIT_OBJECT_0
            SELECT CASE g_pbsrvc_Control
               CASE %SERVICE_CONTROL_STOP, %SERVICE_CONTROL_SHUTDOWN
                  g_pbsrvc_ShutDown = %True

'               case %SERVICE_CONTROL_PAUSE
'                  g_SS.dwCurrentState = %SERVICE_PAUSED
'                  SetServiceStatus g_pbsrvc_Status, g_SS

'               case %SERVICE_CONTROL_CONTINUE
'                  g_SS.dwCurrentState = %SERVICE_RUNNING
'                  SetServiceStatus g_pbsrvc_Status, g_SS

               CASE %SERVICE_CONTROL_INTERROGATE
                  SetServiceStatus g_pbsrvc_Status, g_SS

               CASE ELSE

            END SELECT

         CASE %WAIT_TIMEOUT

         CASE ELSE

      END SELECT
   LOOP
   g_SS.dwCurrentState = %SERVICE_STOP_PENDING
   SetServiceStatus g_pbsrvc_Status, g_SS
   CloseHandle g_pbsrvc_HandlerEvent

   g_SS.dwCurrentState = %SERVICE_STOPPED
   SetServiceStatus g_pbsrvc_Status, g_SS

END SUB

'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
'  pbsHandler
'
'  Handles all service requests
'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
SUB pbsHandler(BYVAL pControl AS DWORD)

  g_pbsrvc_Control = pControl
  SetEvent g_pbsrvc_HandlerEvent

END SUB

'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
'  pbsShutdown
'
'  Sets the internal shut-down flag
'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
SUB pbsShutdown

   g_pbsrvc_ShutDown = %true

END SUB

'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
'  pbsIsShutdown
'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
FUNCTION pbsIsShutdown() AS LONG

   FUNCTION = g_pbsrvc_ShutDown

END FUNCTION

'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
'  pbsStatus
'
'  Returns the current service status
'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
FUNCTION pbsStatus() AS LONG

   FUNCTION = g_pbsrvc_Status

END FUNCTION

#ENDIF
