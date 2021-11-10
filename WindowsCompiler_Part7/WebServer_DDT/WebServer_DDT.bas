#PBFORMS CREATED V2.01
'------------------------------------------------------------------------------
' The first line in this file is a PB/Forms metastatement.
' It should ALWAYS be the first line of the file. Other
' PB/Forms metastatements are placed at the beginning and
' end of "Named Blocks" of code that should be edited
' with PBForms only. Do not manually edit or delete these
' metastatements or PB/Forms will not be able to reread
' the file correctly.  See the PB/Forms documentation for
' more information.
' Named blocks begin like this:    #PBFORMS BEGIN ...
' Named blocks end like this:      #PBFORMS END ...
' Other PB/Forms metastatements such as:
'     #PBFORMS DECLARATIONS
' are used by PB/Forms to insert additional code.
' Feel free to make changes anywhere else in the file.
'------------------------------------------------------------------------------

#COMPILE EXE
#DIM ALL
#DEBUG ERROR ON

'------------------------------------------------------------------------------
'   ** Includes **
'------------------------------------------------------------------------------
%NOANIMATE             =    1
%NODRAGLIST            =    1
%NOHEADER              =    1
%NOIMAGELIST           =    1
%NOLISTVIEW            =    1
%NOTABCONTROL          =    1
%NOTRACKBAR            =    1
%NOTREEVIEW            =    1
%NOUPDOWN              =    1
'
#PBFORMS BEGIN INCLUDES
#RESOURCE "WebServer_DDT.pbr"
%USEMACROS = 1
#INCLUDE ONCE "WIN32API.INC"
#INCLUDE ONCE "COMMCTRL.INC"
#INCLUDE ONCE "PBForms.INC"
#PBFORMS END INCLUDES
'------------------------------------------------------------------------------
#INCLUDE "WinSOCK2.INC"
#INCLUDE "..\Libraries\PB_Processes.inc"
'------------------------------------------------------------------------------
'   ** Constants **
'------------------------------------------------------------------------------
#PBFORMS BEGIN CONSTANTS
%IDD_WEBSERVER = 101
%IDOK          =   1
#PBFORMS END CONSTANTS
'------------------------------------------------------------------------------
%IDM_USER              = %WM_USER + 2048
%IDM_MSG               = %IDM_USER + 11
%WM_PAGEREQUEST        = %IDM_USER + 12
%PortNumber            = 8000     ' port number for the web server
%MonitorDelay          = 10000    ' delay in milliseconds before rechecking the threads
%MaxThreadAge          = 15       ' maximum age in seconds of thread
%MaxThreads            = 1000     ' maximum number of threads
%TerminateThread       = 99999    ' flag to terminate thread
'------------------------------------------------------------------------------
'   ** Declarations **
'------------------------------------------------------------------------------
GLOBAL g_hTxtWin AS DWORD       ' used for the text window
GLOBAL g_hTcp AS LONG
GLOBAL g_hMonitor AS LONG
GLOBAL g_lngIDthread() AS LONG      ' array for thread handles
GLOBAL g_dblTimeThread() AS DOUBLE  ' array for start times of threads
GLOBAL g_lngFileNum AS LONG
GLOBAL g_hDlg  AS DWORD

#PBFORMS DECLARATIONS
'------------------------------------------------------------------------------

'------------------------------------------------------------------------------
'   ** Main Application Entry Point **
'------------------------------------------------------------------------------
FUNCTION PBMAIN()
  '
  IF funProcessCount(GetAppName)>1 THEN
    EXIT FUNCTION
  END IF
  '
  PBFormsInitComCtls (%ICC_WIN95_CLASSES OR %ICC_DATE_CLASSES OR _
      %ICC_INTERNET_CLASSES)
  '
  ' create a text window
  TXT.WINDOW("Console output",0,0,40,80) TO g_hTxtWin
  '
  TXT.PRINT "Console Running"
  '
  REDIM g_lngIDthread(0 TO %MaxThreads)
  REDIM g_dblTimeThread(0 TO %MaxThreads)
  '
  g_hTcp = FREEFILE
  '
  ShowWEBSERVER %HWND_DESKTOP
END FUNCTION
'------------------------------------------------------------------------------

'------------------------------------------------------------------------------
'   ** CallBacks **
'------------------------------------------------------------------------------
CALLBACK FUNCTION ShowWEBSERVERProc()
    LOCAL lngIP AS LONG
    LOCAL lng_hSocket AS LONG
    '
    SELECT CASE AS LONG CB.MSG
        CASE %WM_INITDIALOG
        ' Initialization handler
          TXT.CLS
          PREFIX "txt.print "
            "To use this web server"
            "run a web browser program and"
            "enter the URL/location - or 127.0.0.1:8000"
            "for local host sites"
            "Click the button on the dialog to close the web server"
          END PREFIX
          '
          g_lngFileNum = 20
          '
          ' create a thread to monitor requests
          THREAD CREATE funMonitorThread(0) TO g_hMonitor
          '
          HOST ADDR TO lngIP   ' get the network address
          IF lngIP <> 0 THEN
            TXT.PRINT "Primary IP address (network card) is " & _
                      funIPAddress(lngIP)
          END IF
          '
          ' if you want the web site to be just local host
          ' then uncomment the next line
          'HOST ADDR "localhost" TO lngIP
          '
          ' open for listening
          TCP OPEN SERVER ADDR lngIP PORT %PortNumber AS #g_hTcp TIMEOUT 60000
          IF ERR THEN
            TXT.PRINT "Error opening listening port " & FORMAT$(%PortNumber)
          END IF
          '
          TCP NOTIFY #g_hTcp, ACCEPT CONNECT TO g_hDlg AS %WM_PAGEREQUEST
        '
        CASE %WM_PAGEREQUEST
        ' notification received
          SELECT CASE LOWRD(CB.LPARAM)
            CASE %FD_ACCEPT
              lng_hSocket = g_lngFileNum
              INCR g_lngFileNum
              IF g_lngFileNum > (%MaxThreads -1) THEN g_lngFileNum = 20
              TCP ACCEPT g_hTcp AS lng_hSocket
            THREAD CREATE funSocketThread(lng_hSocket) TO g_lngIDthread(lng_hSocket)
              g_dblTimeThread(lng_hSocket) = TIMER
          END SELECT
        '
        CASE %WM_NCACTIVATE
            STATIC hWndSaveFocus AS DWORD
            IF ISFALSE CB.WPARAM THEN
                ' Save control focus
                hWndSaveFocus = GetFocus()
            ELSEIF hWndSaveFocus THEN
                ' Restore control focus
                SetFocus(hWndSaveFocus)
                hWndSaveFocus = 0
            END IF

        CASE %WM_COMMAND
            ' Process control notifications
            SELECT CASE AS LONG CB.CTL
              CASE %IDOK
                IF CB.CTLMSG = %BN_CLICKED OR CB.CTLMSG = 1 THEN
                  DIALOG END CB.HNDL, %IDOK
                END IF

            END SELECT
    END SELECT
END FUNCTION
'------------------------------------------------------------------------------

'------------------------------------------------------------------------------
'   ** Dialogs **
'------------------------------------------------------------------------------
FUNCTION ShowWEBSERVER(BYVAL hParent AS DWORD) AS LONG
    LOCAL lRslt AS LONG

#PBFORMS BEGIN DIALOG %IDD_WEBSERVER->->
    LOCAL hDlg  AS DWORD
    DIALOG NEW hParent, "Personal Web Server", 261, 173, 197, 92, %WS_POPUP _
        OR %WS_BORDER OR %WS_DLGFRAME OR %WS_CLIPSIBLINGS OR %WS_VISIBLE OR _
        %DS_MODALFRAME OR %DS_SETFOREGROUND OR %DS_3DLOOK OR _
        %DS_NOFAILCREATE OR %DS_SETFONT, %WS_EX_CONTROLPARENT OR %WS_EX_LEFT _
        OR %WS_EX_LTRREADING OR %WS_EX_RIGHTSCROLLBAR, TO hDlg
    CONTROL ADD BUTTON, hDlg, %IDOK, "Click to Stop Web Server", 30, 45, 125, _
        35
    'DIALOG  SEND        hDlg, %DM_SETDEFID, %IDOK, 0
#PBFORMS END DIALOG
    g_hDlg = hDlg
    DIALOG SHOW MODAL hDlg, CALL ShowWEBSERVERProc TO lRslt

#PBFORMS BEGIN CLEANUP %IDD_WEBSERVER
#PBFORMS END CLEANUP
    '
    FUNCTION = lRslt
END FUNCTION
'------------------------------------------------------------------------------
THREAD FUNCTION funMonitorThread(BYVAL hSocket AS LONG) AS LONG
  ' every few seconds check all of the threads and if
  ' any are over x seconds old tell them to terminate
  ' When the do terminate then close them
  SLEEP 500
  LOCAL lngThreadnum AS LONG
  LOCAL result AS LONG
  '
  DO
    SLEEP %MonitorDelay  ' how often to check
    FOR lngThreadnum = 20 TO %MaxThreads -1
      IF g_lngIDthread(lngThreadnum) THEN

        IF g_dblTimeThread(lngThreadnum) = %TerminateThread THEN ' close the dead thread
          SLEEP 1000
          THREAD CLOSE g_lngIDthread(lngThreadnum) TO result
          IF result = 0 THEN TXT.PRINT "Thread close failed"
          g_dblTimeThread(lngThreadnum) = 0
          g_lngIDthread(lngThreadnum) = 0
        ELSE
          IF TIMER - g_dblTimeThread(lngThreadnum) > %MaxThreadAge THEN
          ' if thread is older than this then mark it
            g_dblTimeThread(lngThreadnum) = -1
          END IF
        END IF

      END IF
      '
    NEXT lngThreadnum
    '
  LOOP
  '
END FUNCTION
'
FUNCTION WriteErrorPage AS LONG

  LOCAL lngFile AS LONG
  LOCAL strText AS STRING
  '
  strText = "<html><head>" & _
            "<title>Error 404 - File Not Found</title>" & _
            "</head>" & _
            "<body><p>Error 404 - File not found</p></body" & _
            "/<html>"
  '
  lngFile = FREEFILE
  OPEN "error.html" FOR OUTPUT AS #lngFile
  PRINT #lngFile, strText
  CLOSE #lngFile
  '
END FUNCTION
'
FUNCTION WriteIndexPage AS LONG
  LOCAL strText AS STRING
  LOCAL lngFile AS LONG
  '
  strText = "<html><head>" & _
            "<title>Sample index.html for web server</title>" & _
            "</head>" & _
            "<body><p>Sample index.html for web server</p></body" & _
            "/<html>"
  lngFile = FREEFILE
  OPEN "index.html" FOR OUTPUT AS #lngFile
  PRINT #lngFile, strText
  CLOSE #lngFile
END FUNCTION
'
FUNCTION funIPAddress(lngIP AS LONG) AS STRING
' return IP address in readable format
  LOCAL p AS BYTE PTR
  '
  p = VARPTR(lngIP)
  FUNCTION = FORMAT$(@p) & "." & FORMAT$(@p[1]) & "." & _
             FORMAT$(@p[2]) & "." & FORMAT$(@p[3])

END FUNCTION
'
THREAD FUNCTION funSocketThread(BYVAL hsocket AS LONG ) AS LONG
  ' Run a unique thread for each client request

  LOCAL strRcvData AS STRING
  LOCAL InBuffer AS STRING
  LOCAL file AS STRING
  LOCAL extension AS STRING
  LOCAL strCmd AS STRING
  LOCAL contentheader AS STRING
  LOCAL HTTPheader AS STRING
  LOCAL strHTML AS STRING
  LOCAL lngFile AS LONG
  LOCAL responseflag AS LONG
  LOCAL lngC AS LONG
'
  lngFile = FREEFILE
'
  DO UNTIL g_dblTimeThread(hSocket) < 0
    SLEEP 100  ' release some CPU time
    TCP RECV hSocket, 1024, strRcvData

    IF LEN(strRcvData) > 0 THEN  ' if receive data is present
      g_dblTimeThread(hSocket) = TIMER  ' start a timer for this request
      ' output received request to console
      TXT.PRINT "--- Request ---"
      FOR lngC = 1 TO PARSECOUNT(strRcvData,$CRLF)
        TXT.PRINT PARSE$(strRcvData,$CRLF,lngC)
      NEXT lngR
      ' Add input data to buffer
      REPLACE $CRLF WITH $CR IN strRcvData  ' filter out crlf pairs, make them cr
      InBuffer = InBuffer & strRcvData

      DO WHILE INSTR(InBuffer, $CR)  ' do while input contains lines with CR
        SLEEP 1 'release CPU time
        strCMD = LEFT$(InBuffer, INSTR(InBuffer, $CR) - 1 )
        InBuffer = MID$(InBuffer, INSTR(InBuffer, $CR) + 1 )

        IF LEFT$(strCMD,3) = "GET" THEN  ' GET an object by name

          responseflag = 1

          ' start with [GET /page.htm HTTP/1.x]
          file = MID$(strCMD, 5)  ' [/page.htm HTTP/1.x]
          file = LEFT$(file, LEN(file) - 9) ' [/page.htm]

          IF file = "/" OR file = "\" OR file = "" THEN file = "index.html"  ' no file specified

          REPLACE "/" WITH "\" IN file  ' change unix style slashes
          IF LEFT$(file,1) = "\" THEN file = MID$(file,2)  ' [page.htm]
          IF RIGHT$(file,1) = "\" THEN file = file & "index.html"
          ' Should actually do real http error headers here, but this is good enough

          IF DIR$(file) = "" THEN  ' if page not found
            IF file = "index.html" THEN  ' if index.htm not found, create it
              WriteIndexPage
            ELSE
              file = "error.html"
              IF ISFALSE ISFILE("error.html") THEN
                WriteErrorPage
              END IF
            END IF
          END IF
          '
          ' file has been found
          extension = MID$(file,INSTR(file,".") + 1)  ' get file extension
          SELECT CASE LCASE$(extension)
            CASE "htm", "html", "bas", "txt"
              contentheader = "text/html"
            CASE "jpg","jpeg"
              contentheader = "image/jpeg"
            CASE "gif"
              contentheader = "image/gif"
            CASE ELSE
              contentheader = "application/octet-stream"
          END SELECT

        END IF  ' GET strCMD

        IF strCMD = "" THEN ' CRLF only indicates header is over

          IF responseflag = 1 THEN

            OPEN file FOR BINARY AS #lngFile  ' read the page from disk
            GET$ #lngFile, LOF(lngFile), strHTML
            CLOSE #lngFile

            ' replace Tags?
            REPLACE "%TIME%" WITH TIME$ IN strHTML
            REPLACE "%DATE%" WITH DATE$ IN strHTML

            ' create the header for this page
            HTTPheader = "HTTP/1.0 200 OK" & $CRLF & _
                         "Server: HTTP232" & $CRLF & _
                         "Content-Type: " & contentheader & $CRLF & _
                         "Accept-Ranges: bytes" & $CRLF & _
                         "Content-Length: " & FORMAT$(LEN(strHTML)) & $CRLF & $CRLF

            g_dblTimeThread(hSocket) = TIMER  ' update activity timer
            TCP PRINT #hSocket, HTTPheader & strHTML ;

            ' display the details on console
            PREFIX "txt.print "
              "--- File Sent ---"
              file
            END PREFIX
          END IF

          TCP CLOSE #hSocket
          g_dblTimeThread(hSocket) = %TerminateThread  ' tell monitor thread to terminate this thread
          EXIT FUNCTION

        END IF  ' null command, end of header

      LOOP  ' while input contains lines with CR (header)

    END IF  ' receive data present

  LOOP  ' until timeout

  TCP CLOSE #hSocket
  g_dblTimeThread(hSocket) = %TerminateThread  ' tell monitor thread to terminate this thread

END FUNCTION
