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

'------------------------------------------------------------------------------
'   ** Includes **
'------------------------------------------------------------------------------
#PBFORMS BEGIN INCLUDES
#RESOURCE "CallOllama_Dialog.pbr"
%USEMACROS = 1
#INCLUDE ONCE "WIN32API.INC"
#INCLUDE ONCE "COMMCTRL.INC"
#INCLUDE ONCE "PBForms.INC"
#PBFORMS END INCLUDES
'------------------------------------------------------------------------------
#INCLUDE "PB_Windows_Controls.inc"
#INCLUDE "PB_HTML.inc"
#INCLUDE "PB_FileHandlingRoutines.inc"
'------------------------------------------------------------------------------
'   ** Constants **
'------------------------------------------------------------------------------
#PBFORMS BEGIN CONSTANTS
%IDD_dlgOllama           =  101
%IDC_STATUSBAR1          = 1001
%IDC_lblSelectModel      = 1003
%IDC_lblEnterPrompt      = 1004
%IDC_txtEnterPrompt      = 1005
%IDC_cboSelectModel      = 1002
%IDC_btnRUNQUERY         = 1006
%IDC_lblInputFile        = 1007
%IDC_txtInputFile        = 1008
%IDC_lblOutput           = 1009
%IDC_chkInputFile        = 1010
%IDC_lblHTMLformatOutput = 1011
%IDC_chkHTMLformatOutput = 1012
%IDC_imgBrowse           = 1013
%IDC_lblCheckingServer   = 1014
%IDC_lblStatus           = 1015
#PBFORMS END CONSTANTS
'------------------------------------------------------------------------------
%ID_OCX = 2000
%Progress_Completed = 2001
%ID_TIMER1          = 2002    ' timer for startup
'
' following constant is used for conditional compilation
%RunOnServer  = 1             ' if declared queries to
                              ' run on the server below
'
$TargetServer = "mini001"
'
GLOBAL g_hUDP AS LONG
%UPort = 16010                ' UDP port
'
%QueryAccepted = 1            ' confirm query received
'------------------------------------------------------------------------------
'   ** Declarations **
'------------------------------------------------------------------------------
' create a UDT for Ollama data
TYPE udtOllamaData
  strTargetServer AS STRING * 50
  strTask       AS STRING * 50
  lngHTMLformat AS LONG
  hDlg          AS LONG
  strInputFile  AS STRING * 500
  strOutputFile AS STRING * 500
  strModel      AS STRING * 100
  strPrompt     AS STRING * 500
END TYPE
'
GLOBAL g_uOllamaData AS udtOllamaData
GLOBAL g_idThread AS LONG    ' thread handle
'
#PBFORMS DECLARATIONS
'------------------------------------------------------------------------------
#RESOURCE ICON, imgApp,"AI_Client.ico"
#RESOURCE ICON, imgBrowse,"load.ico"
'------------------------------------------------------------------------------
'   ** Main Application Entry Point **
'------------------------------------------------------------------------------
FUNCTION PBMAIN()
  LOCAL lngResult AS LONG
  PBFormsInitComCtls (%ICC_WIN95_CLASSES OR %ICC_DATE_CLASSES OR _
    %ICC_INTERNET_CLASSES)
  'lngResult = ShowdlgStartup(%HWND_DESKTOP)
  '
  'IF lngResult = %IDOK THEN
    ShowdlgOllama %HWND_DESKTOP
  'ELSE
  ' Ollama server not started
  '  MSGBOX "Ollama Server not running", %MB_ICONERROR, _
  '         "Ollama Server error"
    '
  'END IF
END FUNCTION
'------------------------------------------------------------------------------

'------------------------------------------------------------------------------
'   ** CallBacks **
'------------------------------------------------------------------------------
CALLBACK FUNCTION ShowdlgOllamaProc()
  LOCAL lngResult AS LONG  ' result of check box check
  '
  LOCAL strPrompt AS STRING      ' prompt to be used
  LOCAL strInputFile AS STRING   ' path and name of input file
  LOCAL strOutputFile AS STRING  ' path and name of output file
  LOCAL strModel AS STRING       ' name of model to be used
  LOCAL lngHTMLformat AS LONG    ' 1/0 for state of HTML format checkbox
  '
  LOCAL lngStatus AS LONG            ' status returned
  LOCAL lngFlags AS LONG             ' flags for file browsing
  LOCAL strFilter AS STRING          ' filter template for file
  LOCAL strFile AS STRING            ' selected file
  '
  SELECT CASE AS LONG CB.MSG
    CASE %WM_INITDIALOG
    ' Initialization handler
      ' populate and preselect the model
      DIM a_strModels(1 TO 2) AS STRING
      ARRAY ASSIGN a_strModels() = "gpt-oss:20b","gpt-oss:120b"
      funPopulateCombo(CB.HNDL, _
                       %IDC_cboSelectModel, _
                       a_strModels(), _
                       a_strModels(2))
                       '
      ' preselect the html output format
      CONTROL SET CHECK CB.HNDL,%IDC_chkHTMLformatOutput,1
      '
      ' hide the input box
      PREFIX "CONTROL HIDE CB.HNDL,"
        %IDC_txtInputFile
        %IDC_imgBrowse
      END PREFIX
      '
      LOCAL XStart,Ystart,lngHeight,lngWidth AS LONG
      '
      XStart    = 30
      Ystart    = 185
      lngHeight = 210
      lngWidth  = 635
      ' prep for html control
      mPrepHTML(CB.HNDL,XStart,Ystart,lngHeight,lngWidth)
      '
      LOCAL strURL AS STRING
      strURL = "file://" & EXE.PATH$ & "BlankOutput.html"
      ' Populate the selected html control
      ' with the content of the URL
      funPopulateHTML(CB.HNDL, _
                      strURL, _
                      %ID_OCX)
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
      '
    CASE %Progress_Completed
    ' thread has completed
      THREAD CLOSE g_idThread TO lngStatus
      '
      ' now populate the OCX html control
      strOutputFile = EXE.PATH$ & "OutputFile.html"
      IF ISTRUE ISFILE(strOutputFile) THEN
      ' output file exists
        strURL = "file://" & strOutputFile
      ELSE
        strURL = "file://" & EXE.PATH$ & "NoFile.html"
      END IF
      '
      funPopulateHTML(CB.HNDL, _
                      strURL, _
                      %ID_OCX)
      '
      CONTROL SET TEXT CB.HNDL, %IDC_STATUSBAR1,"Processing Completed
      ' re-enable the button
      CONTROL ENABLE CB.HNDL,%IDC_btnRUNQUERY
      '
    CASE %WM_COMMAND
      ' Process control notifications
      SELECT CASE AS LONG CB.CTL
       ' /* Inserted by PB/Forms 09-25-2025 11:00:03
         CASE %IDC_imgBrowse
          IF CB.CTLMSG = %BN_CLICKED OR CB.CTLMSG = 1 THEN
          ' browse for a txt file
            lngFlags = %OFN_FILEMUSTEXIST OR _
                       %OFN_PATHMUSTEXIST
                       '
            strFilter = CHR$("Text", 0, "*.TXT", 0)
            DISPLAY OPENFILE CB.HNDL,,,"Select a Text file for input", _
                             EXE.PATH$,strFilter,"",".txt",lngFlags TO strFile
                             '
            IF strFile <> "" THEN
            ' set file selected
              CONTROL SET TEXT CB.HNDL,%IDC_txtInputFile, strFile
            END IF
            '
          END IF
          '
        ' /* Inserted by PB/Forms 09-15-2025 15:15:27
        CASE %IDC_chkInputFile
        ' ticked or unticked
          IF CB.CTLMSG = %BN_CLICKED OR CB.CTLMSG = 1 THEN
            CONTROL GET CHECK CB.HNDL, CB.CTL TO lngResult
            IF lngResult = 0 THEN
            ' box has been unchecked
              PREFIX "CONTROL HIDE CB.HNDL,"
                %IDC_txtInputFile
                %IDC_imgBrowse
              END PREFIX
              '
            ELSE
            ' box has been checked
              PREFIX "CONTROL NORMALIZE CB.HNDL,"
                %IDC_txtInputFile
                %IDC_imgBrowse
              END PREFIX
              '
              CONTROL SET TEXT CB.HNDL,%IDC_txtInputFile, EXE.PATH$
            END IF
          END IF
          '
        CASE %IDC_STATUSBAR1

        CASE %IDC_cboSelectModel

        CASE %IDC_txtEnterPrompt

        CASE %IDC_btnRUNQUERY
          IF CB.CTLMSG = %BN_CLICKED OR CB.CTLMSG = 1 THEN
            ' disable the button
            PREFIX "CONTROL DISABLE CB.HNDL,"
              CB.CTL
            END PREFIX
            '
             ' now overwrite the OCX html control
            strURL = "file://" & EXE.PATH$ & "BlankOutput.html"
            funPopulateHTML(CB.HNDL, _
                            strURL, _
                            %ID_OCX)
                            '
            ' pick up the inputs
            CONTROL GET CHECK CB.HNDL,%IDC_chkHTMLformatOutput _
                              TO lngHTMLformat
            CONTROL GET TEXT CB.HNDL,%IDC_cboSelectModel _
                              TO strModel
            '
            ' is there an input file?
            CONTROL GET CHECK CB.HNDL, %IDC_chkInputFile _
                              TO lngResult
            IF lngResult = 0 THEN
              strInputFile = ""
            ELSE
              CONTROL GET TEXT CB.HNDL,%IDC_txtInputFile _
                               TO strInputFile
            END IF
            '
            CONTROL GET TEXT CB.HNDL,%IDC_txtEnterPrompt TO strPrompt
            REPLACE $CRLF WITH " " IN strPrompt
            strPrompt = TRIM$(strPrompt)
            '
            strOutputFile = EXE.PATH$ & "OutputFile.html"
            '
            CONTROL SET TEXT CB.HNDL, %IDC_STATUSBAR1,"Processing..."
            '
            PREFIX "g_uOllamaData."
              strTargetServer = $TargetServer
              strTask         = "QUERY"
              strInputFile  = strInputFile
              strPrompt     = strPrompt
              strOutputFile = strOutputFile
              strModel      = strModel
              lngHTMLformat = lngHTMLformat
              hDlg          = CB.HNDL
            END PREFIX
            '
            #IF %DEF(%RunOnServer)
            ' run on the server
              lngStatus = 0
              THREAD CREATE funTHCallOllamaServer(lngStatus) TO g_idThread
            '
            #ELSE
            ' run locally
              THREAD CREATE funTHCallOllama(lngStatus) TO g_idThread
            #ENDIF
            ' thread will post a custom message when completed
          END IF

        CASE %IDC_txtInputFile

      END SELECT
  END SELECT
  '
END FUNCTION
'------------------------------------------------------------------------------
FUNCTION funCallOllama_withInput(strInputFile AS STRING, _
                                 strPrompt AS STRING, _
                                 strOutputFile AS STRING, _
                                 strModel AS STRING) AS LONG
' call Ollama on the command line an give it an input
  LOCAL strCMD AS STRING         ' holds command line string
  LOCAL strOllamaBatch AS STRING ' batch file to run
  LOCAL strInputString AS STRING ' used to hold optional
                                 ' input file name
  '
  IF TRIM$(strInputFile) = "" THEN
  ' no input file?
    strInputString = ""
  ELSE
  ' populate the Input file section of strCMD
    strInputString =  " < " & $DQ & strInputFile & $DQ
  END IF
  '
  strOllamaBatch = EXE.PATH$ & "Ollama_Batch.bat
  '
  strCMD = "ollama run " & strModel & " " & _
           $DQ & strPrompt & $DQ & _
           strInputString & _
           " >>" & $DQ & strOutputFile & $DQ
           '
  TRY
    KILL strOllamaBatch
  CATCH
  FINALLY
  END TRY
  '
  TRY
    KILL strOutputFile
  CATCH
  FINALLY
  END TRY
  '
  funAppendToFile(strOllamaBatch,strCMD)
  funExecCmd(strOllamaBatch & "")
  '
  FUNCTION = %TRUE
  '
END FUNCTION
'
'------------------------------------------------------------------------------

'------------------------------------------------------------------------------
'   ** Dialogs **
'------------------------------------------------------------------------------
FUNCTION ShowdlgOllama(BYVAL hParent AS DWORD) AS LONG
  LOCAL lRslt AS LONG

#PBFORMS BEGIN DIALOG %IDD_dlgOllama->->
  LOCAL hDlg   AS DWORD
  LOCAL hFont1 AS DWORD

  DIALOG NEW hParent, "Query using Ollama", 324, 189, 693, 447, %WS_POPUP OR _
    %WS_BORDER OR %WS_DLGFRAME OR %WS_THICKFRAME OR %WS_CAPTION OR _
    %WS_SYSMENU OR %WS_MINIMIZEBOX OR %WS_MAXIMIZEBOX OR %WS_CLIPSIBLINGS OR _
    %WS_VISIBLE OR %DS_MODALFRAME OR %DS_CENTER OR %DS_3DLOOK OR _
    %DS_NOFAILCREATE OR %DS_SETFONT, %WS_EX_CONTROLPARENT OR %WS_EX_LEFT OR _
    %WS_EX_LTRREADING OR %WS_EX_RIGHTSCROLLBAR, TO hDlg
  CONTROL ADD STATUSBAR, hDlg, %IDC_STATUSBAR1, "Ready", 0, 0, 0, 0
  CONTROL ADD COMBOBOX,  hDlg, %IDC_cboSelectModel, , 25, 120, 125, 40, _
    %WS_CHILD OR %WS_VISIBLE OR %WS_TABSTOP OR %CBS_DROPDOWNLIST OR _
    %CBS_SORT, %WS_EX_LEFT OR %WS_EX_LTRREADING OR %WS_EX_RIGHTSCROLLBAR
  CONTROL ADD LABEL,     hDlg, %IDC_lblSelectModel, "Select Model", 25, 110, _
    100, 10
  CONTROL SET COLOR      hDlg, %IDC_lblSelectModel, %BLUE, -1
  CONTROL ADD LABEL,     hDlg, %IDC_lblEnterPrompt, "Enter Prompt", 25, 20, _
    100, 10
  CONTROL SET COLOR      hDlg, %IDC_lblEnterPrompt, %BLUE, -1
  CONTROL ADD TEXTBOX,   hDlg, %IDC_txtEnterPrompt, "", 25, 30, 635, 65, _
    %WS_CHILD OR %WS_VISIBLE OR %WS_TABSTOP OR %ES_LEFT OR %ES_MULTILINE OR _
    %ES_AUTOHSCROLL OR %ES_WANTRETURN, %WS_EX_CLIENTEDGE OR %WS_EX_LEFT OR _
    %WS_EX_LTRREADING OR %WS_EX_RIGHTSCROLLBAR
  CONTROL ADD BUTTON,    hDlg, %IDC_btnRUNQUERY, "Run Query", 580, 400, 75, _
    25
  CONTROL ADD LABEL,     hDlg, %IDC_lblInputFile, "Input File?", 210, 110, _
    50, 10
  CONTROL SET COLOR      hDlg, %IDC_lblInputFile, %BLUE, -1
  CONTROL ADD TEXTBOX,   hDlg, %IDC_txtInputFile, "", 210, 120, 430, 15
  CONTROL ADD LABEL,     hDlg, %IDC_lblOutput, "Output", 30, 170, 100, 10
  CONTROL SET COLOR      hDlg, %IDC_lblOutput, %BLUE, -1
  CONTROL ADD CHECKBOX,  hDlg, %IDC_chkInputFile, "", 265, 110, 100, 10
  CONTROL ADD LABEL,     hDlg, %IDC_lblHTMLformatOutput, "HTML format " + _
    "output?", 210, 151, 70, 10
  CONTROL SET COLOR      hDlg, %IDC_lblHTMLformatOutput, %BLUE, -1
  CONTROL ADD CHECKBOX,  hDlg, %IDC_chkHTMLformatOutput, "", 285, 151, 100, _
    10

  FONT NEW "MS Sans Serif", 14, 0, %ANSI_CHARSET TO hFont1

  CONTROL SET FONT hDlg, %IDC_txtEnterPrompt, hFont1
#PBFORMS END DIALOG
  DIALOG SET ICON hDlg,"imgApp"
  ' add the image to the button
  CONTROL SET IMGBUTTON hDlg, %IDC_imgBrowse, "imgBrowse"
  '
  DIALOG SHOW MODAL hDlg, CALL ShowdlgOllamaProc TO lRslt

#PBFORMS BEGIN CLEANUP %IDD_dlgOllama
  FONT END hFont1
#PBFORMS END CLEANUP

  FUNCTION = lRslt
END FUNCTION
'------------------------------------------------------------------------------
'
FUNCTION funExecCmd(cmdLine1 AS ASCIIZ, OPTIONAL BYVAL lngConsole AS LONG) AS LONG
  DIM rcProcess AS Process_Information
  DIM rcStart AS startupInfo
  DIM Retc AS LONG
  '
  DIM lngWindow AS LONG
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
  RetC = %WAIT_TIMEOUT
  DO WHILE RetC = %WAIT_TIMEOUT
    RetC = WaitForSingleObject(rcProcess.hProcess,-1)
    SLEEP 50
  LOOP
  CALL GetExitCodeProcess(rcProcess.hProcess, RetC)
  CALL CloseHandle(rcProcess.hThread)
  CALL CloseHandle(rcProcess.hProcess)
  '
END FUNCTION
'
#IF %DEF(%RunOnServer)
' only compile this if running on server
THREAD FUNCTION funTHCallOllamaServer(BYVAL lngStatus AS LONG) AS LONG
' call the ollama server
' open UDP channel to the server
  LOCAL ip     AS LONG      ' This machines IP address
  LOCAL bip    AS LONG      ' Broadcase IP address for this segment (class D)
  LOCAL hUdp   AS LONG      ' UDP file number
  LOCAL strBuffer AS STRING ' UDP data received
  LOCAL ipAddr AS LONG      ' IP address of sending machine
  LOCAL ipPort AS LONG      ' UDP Port of sending machine to reply to
  LOCAL strTargetServer AS STRING ' target server
  LOCAL strQuery AS STRING  ' query type
  LOCAL t      AS SINGLE    ' Timer for reply monitoring
  LOCAL x      AS LONG      ' Counter
  '
  strTargetServer = TRIM$(g_uOllamaData.strTargetServer)
  strQuery = "QUERY"
  '
'  PREFIX "g_uOllamaData."
'    strTargetServer = $TargetServer
'    strTask         = "QUERY"
'    strInputFile    = strInputFile
'    strPrompt       = strPrompt
'    strOutputFile   = strOutputFile
'    strModel        = strModel
'    lngHTMLformat   = lngHTMLformat
'    hDlg            = CB.HNDL
'  END PREFIX
   ' get the IP address
  HOST ADDR TO ip
  '
  HOST ADDR strTargetServer TO bip
  '
  ' open channel
  hUdp = FREEFILE
  UDP OPEN AS #hUdp TIMEOUT 5000
  IF ERR THEN
    EXIT FUNCTION
  END IF
  '
  strBuffer = strTargetServer & "|" & strQuery & "|" & _
              funGetData()
  '
  DO
    UDP SEND hUdp, AT bip, %UPort, strBuffer
    t = TIMER
    WHILE ABS(TIMER - t) < 5
      ERRCLEAR
      UDP RECV #hUdp, FROM ipAddr, ipPort, strBuffer
      ' Ignore any timeout or other errors
      IF ERR THEN ITERATE
      FUNCTION = %QueryAccepted
      CLOSE #hUdp
      EXIT FUNCTION
      '
    WEND
    '
    INCR x
  LOOP WHILE x < 1
  '
  CLOSE #hUdp
  '
END FUNCTION
'
#ELSE
' otherwise compile this function into code
' to run locally
THREAD FUNCTION funTHCallOllama(BYVAL lngStatus AS LONG) AS LONG
' call Ollama for response
  ' call Ollama on the command line an give it an input
  LOCAL strCMD AS STRING          ' holds command line string
  LOCAL strOllamaBatch AS STRING  ' batch file to run
  LOCAL strInputString AS STRING  ' used to hold optional
                                  ' input file name
  LOCAL strPrompt AS STRING       ' prompt to be used
  '
  IF TRIM$(g_uOllamaData.strInputFile) = "" THEN
  ' no input file?
    strInputString = ""
  ELSE
  ' populate the Input file section of strCMD
    strInputString =  " < " & $DQ & TRIM$(g_uOllamaData.strInputFile) & $DQ
  END IF
  '
  strPrompt = TRIM$(g_uOllamaData.strPrompt)
  '
  IF g_uOllamaData.lngHTMLformat = 1 THEN
  ' force html format
    strPrompt = strPrompt & " .Provide output in HTML format"
  '
  END IF
  '
  strOllamaBatch = EXE.PATH$ & "Ollama_Batch.bat
  '
  strCMD = "ollama run " & TRIM$(g_uOllamaData.strModel) & " " & _
           $DQ & strPrompt & $DQ & _
           strInputString & _
           " >>" & $DQ & TRIM$(g_uOllamaData.strOutputFile) & $DQ
           '
  ' wipe any existing batch file
  mWipe_A_File(strOllamaBatch)
  '
  ' wipe any existing output file
  mWipe_A_File(TRIM$(g_uOllamaData.strOutputFile))
  '
  ' save the batch file
  funAppendToFile(strOllamaBatch,strCMD)
  '
  ' execute the batch file and wait till completed
  funExecCmd(strOllamaBatch & "")
  '
  FUNCTION = %TRUE
  '
  ' post completed message to dialog
  DIALOG POST g_uOllamaData.hDlg, %Progress_Completed,0,0
  '
END FUNCTION
'
#ENDIF
'
FUNCTION funGetData() AS STRING
' get the data in the global UDT
  '  PREFIX "g_uOllamaData."
'    strTargetServer = $TargetServer
'    strTask         = "QUERY"
'    strInputFile    = strInputFile
'    strPrompt       = strPrompt
'    strOutputFile   = strOutputFile
'    strModel        = strModel
'    lngHTMLformat   = lngHTMLformat
'    hDlg            = CB.HNDL
'  END PREFIX
'
  LOCAL strData AS STRING
  LOCAL strPrompt AS STRING
  '
  strPrompt = g_uOllamaData.strPrompt
  REPLACE $CRLF WITH " " IN strPrompt

  '
  strData = TRIM$(g_uOllamaData.strInputFile) & "|" & _
            TRIM$(strPrompt) & "|" & _
            TRIM$(g_uOllamaData.strOutputFile) & "|" & _
            TRIM$(g_uOllamaData.strModel) & "|" & _
            FORMAT$(g_uOllamaData.lngHTMLformat) & "|"
            '
  FUNCTION = strData
  '
END FUNCTION
'
FUNCTION ShowdlgStartup(BYVAL hParent AS DWORD) AS LONG
  LOCAL lRslt  AS LONG

#PBFORMS BEGIN DIALOG %IDD_dlgStartup->->
  LOCAL hDlg   AS DWORD
  LOCAL hFont1 AS DWORD

  DIALOG NEW hParent, "Checking Ollama Server", 549, 273, 262, 121, %WS_POPUP _
    OR %WS_BORDER OR %WS_DLGFRAME OR %WS_CAPTION OR %WS_SYSMENU OR _
    %WS_CLIPSIBLINGS OR %WS_VISIBLE OR %DS_MODALFRAME OR %DS_CENTER OR _
    %DS_3DLOOK OR %DS_NOFAILCREATE OR %DS_SETFONT, %WS_EX_CONTROLPARENT OR _
    %WS_EX_LEFT OR %WS_EX_LTRREADING OR %WS_EX_RIGHTSCROLLBAR, TO hDlg
  CONTROL ADD LABEL, hDlg, %IDC_lblCheckingServer, "Please Wait.. Checking " + _
    "Server", 25, 10, 210, 30
  CONTROL SET COLOR  hDlg, %IDC_lblCheckingServer, %BLUE, -1
  CONTROL ADD LABEL, hDlg, %IDC_lblStatus, "Waiting....", 25, 45, 210, 45

  FONT NEW "MS Sans Serif", 14, 0, %ANSI_CHARSET TO hFont1

  CONTROL SET FONT hDlg, %IDC_lblCheckingServer, hFont1
  CONTROL SET FONT hDlg, %IDC_lblStatus, hFont1
#PBFORMS END DIALOG

  DIALOG SHOW MODAL hDlg, CALL ShowdlgStartupProc TO lRslt

#PBFORMS BEGIN CLEANUP %IDD_dlgStartup
  FONT END hFont1
#PBFORMS END CLEANUP

  FUNCTION = lRslt
END FUNCTION
'
CALLBACK FUNCTION ShowdlgStartupProc()
  '
  SELECT CASE AS LONG CB.MSG
    CASE %WM_INITDIALOG
    ' Initialization handler
       SetTimer(CB.HNDL, %ID_TIMER1, _
               1000, BYVAL %NULL)
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
      '
    CASE %WM_TIMER
      SELECT CASE CB.WPARAM
        CASE %ID_TIMER1
        ' timer triggered
          KillTimer(CB.HNDL, %ID_TIMER1)
          '
          IF ISTRUE funCheckOllamaServer(CB.HNDL) THEN
          ' Ollama server started
            DIALOG END CB.HNDL,%IDOK
          ELSE
          ' unable to start server
            DIALOG END CB.HNDL,%IDABORT
          END IF
        '
      END SELECT
      '
    CASE %WM_COMMAND
      ' Process control notifications
      SELECT CASE AS LONG CB.CTL

      END SELECT
  END SELECT
  '
END FUNCTION
'
FUNCTION funCheckOllamaServer(hDlg AS DWORD) AS LONG
' check the ollama server is up and running
  LOCAL strCMD AS STRING          ' command line string
  LOCAL strOllamaBatch AS STRING  ' path/name of batch file
  LOCAL strOutput AS STRING       ' output from the batch file
  '
  strCMD = "curl http://127.0.0.1:11434/api/version > " & _
            $DQ & EXE.PATH$ & "OllamaServer.txt" & $DQ
            '
  strOllamaBatch = EXE.PATH$ & "Ollama_Batch.bat"
  '
  ' wipe any existing batch file
  mWipe_a_file(strOllamaBatch)
  '
  ' wipe any existing output file
  mWipe_a_file(EXE.PATH$ & "OllamaServer.txt")
  '
  '
  ' save the batch file
  funAppendToFile(strOllamaBatch,strCMD)
  '
  ' execute the batch file and wait till completed
  funExecCmd(strOllamaBatch & "")
  '
  ' now look for version string?
  strOutput = funBinaryFileAsString(EXE.PATH$ & "OllamaServer.txt")
  IF INSTR(strOutput,"{""version"":") > 0 THEN
    FUNCTION = %TRUE
  ELSE
  ' server not started ?
    MSGBOX "The Ollama server is not running" & $CRLF & _
           "Please start the server",%MB_ICONERROR, _
           "Ollama server issue"
           '
    FUNCTION = %FALSE
  END IF
  '
END FUNCTION
'
