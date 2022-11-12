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
' declare the PostThreadMessage API calls
DECLARE FUNCTION PostThreadMessageA IMPORT "USER32.DLL" _
                                    ALIAS "PostThreadMessageA" ( _
   BYVAL idThread AS DWORD _        ' __in DWORD idThread
 , BYVAL Msg AS DWORD _             ' __in UINT Msg
 , BYVAL wParam AS DWORD _          ' __in WPARAM wParam
 , BYVAL lParam AS LONG _           ' __in LPARAM lParam
 ) AS LONG                          ' BOOL

DECLARE FUNCTION PostThreadMessageW IMPORT "USER32.DLL" _
                                    ALIAS "PostThreadMessageW" ( _
   BYVAL idThread AS DWORD _        ' __in DWORD idThread
 , BYVAL Msg AS DWORD _             ' __in UINT Msg
 , BYVAL wParam AS DWORD _          ' __in WPARAM wParam
 , BYVAL lParam AS LONG _           ' __in LPARAM lParam
 ) AS LONG                          ' BOOL

' work out if we are using Unicode or not
#IF %DEF(%UNICODE)
   MACRO PostThreadMessage = PostThreadMessageW
#ELSE
   MACRO PostThreadMessage = PostThreadMessageA
#ENDIF
'
FUNCTION PBMAIN () AS LONG
' the main PB function that is the first to be executed
  funPrepOutput("Console Timer Demo",0,0,40,120)
  '
  funLog("Console Timer Demo")
  '
  LOCAL Msg      AS tagMSG  ' UDT for message
  '
  'TYPE tagMSG DWORD
  '  hwnd    AS DWORD   ' HWND
  '  message AS DWORD   ' UINT
  '  wParam  AS DWORD   ' WPARAM
  '  lParam  AS LONG    ' LPARAM
  '  time    AS DWORD   ' DWORD
  '  pt      AS POINT   ' POINT
  'END TYPE
  '
  STATIC TimerID AS DWORD  ' the timer ID
  '
  ' Post WM_TIMER message every 3 seconds
  ' referencing your own function
  TimerID = SetTimer(%NULL, %NULL,3000,CODEPTR(funMyFunction))
  '
  WHILE GetMessage(Msg, %NULL, %NULL, %NULL) <> 0
  ' wait for the %WM_QUIT message
  '
  ' The GetMessage function retrieves a message from the calling thread's
  ' message queue and places it in the specified structure i.e. Msg
  '
  ' This function can retrieve both messages associated with a specified
  ' window and thread messages posted via the PostThreadMessage function.
  '
  ' Loop to pass message on - in place of dialog processing
    DispatchMessage  Msg
  ' Dispatches a message to a window procedure. It is typically used to
  ' dispatch a message retrieved by the GetMessage function.
  WEND
  '
  ' SetTimer() returned value used to kill timer off
  KillTimer %NULL, TimerID
  '
  funLog("Completed")
  '
  funWait()
  '
END FUNCTION
'
FUNCTION funMyFunction(BYVAL hWnd AS LONG, _
                       BYVAL uMsg AS LONG, _
                       BYVAL TimerID AS DWORD, _
                       BYVAL dwTime AS DWORD) AS LONG
  STATIC lngRunCount AS LONG ' count times this has run
  '
  SELECT CASE uMsg
    CASE %WM_TIMER
      INCR lngRunCount ' count times this has run
      '
      ' do something - e.g. log the time to the console
      funLog(TIME$)
      '
      IF lngRunCount = 5 THEN
      ' Exit after 5 runs
        PostThreadMessage GetCurrentThreadID, %WM_QUIT, 0, 0
        ' Signal Quit to Msg Loop
        ' This posts a message to the message queue of the
        ' specified thread. It returns without waiting for the
        ' thread to process the message.
      END IF
      '
  END SELECT

END FUNCTION
