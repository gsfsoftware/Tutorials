'
' sserv.exe
'
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
' sserv.exe -install
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
' sserv.exe -uninstall
'
#COMPILE EXE
#DIM ALL

' The name of the service
$SERVICE_NAME = "AAA_testService"
$SERVICE_DISPLAY_NAME = "AAA_testService display name"
$SERVICE_DESCRIPTION  = "Service description"


'- REM OUT this line to compile as a console application
%COMPILE_AS_SERVICE = 1

#IF %DEF(%COMPILE_AS_SERVICE)
  #INCLUDE "pb_srvc.inc"
#ENDIF

#IF %DEF(%COMPILE_AS_SERVICE)
'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
'  waitThread
'
'  This thread loops and does nothing. this is the thread you'd
'  use for your service to do something.
'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
THREAD FUNCTION waitThread ( BYVAL foo AS LONG ) AS LONG

  '- This function tells us if the user stopped the service.
  DO UNTIL pbsIsShutdown()

    '- your code here ... monitor for tcp connections,
    ' check for the existence of a file, whatever you want.
    '  in this sample program all we do is sleep for 10 seconds.
    '

    ' this is a sample of what your service could do
    IF ISTRUE ISFILE("c:\temp\keyfile.txt") THEN
      TRY
        KILL "c:\temp\keyfile.txt"
      CATCH
      FINALLY
      END TRY
    END IF
    '
    ' sleep for 10 seconds and then repeat
    apiSleep 10000

  LOOP

END FUNCTION
#ENDIF

'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
' pbmain
'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
FUNCTION PBMAIN

  DIM foo AS LONG
  DIM waitThreadID AS LONG

   '- This is the thread in the program
   '  that actually does the work
   '
   THREAD CREATE waitThread(0) TO waitThreadID

   '- Start the service
   #IF %DEF(%COMPILE_AS_SERVICE)
     pbsInit 0, $SERVICE_NAME, $SERVICE_DISPLAY_NAME, _
                $SERVICE_DESCRIPTION

     '- Run in a console
   #ELSE
     STDOUT "Press <ESC> to shutdown server properly"
     DO
       IF INKEY$ = $ESC THEN
         STDOUT "CONSOLE CANCELLED with <esc>"
         EXIT DO
       END IF
       apiSleep 1000
     LOOP
   #ENDIF

   '- Clean-up the thread handles
   THREAD CLOSE waitThreadID TO foo

END FUNCTION
