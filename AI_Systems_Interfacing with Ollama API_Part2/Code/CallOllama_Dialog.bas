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
'------------------------------------------------------------------------------
'   ** Constants **
'------------------------------------------------------------------------------
#PBFORMS BEGIN CONSTANTS
%IDD_dlgOllama      =  101
%IDC_STATUSBAR1     = 1001
%IDC_lblSelectModel = 1003
%IDC_lblEnterPrompt = 1004
%IDC_txtEnterPrompt = 1005
%IDC_cboSelectModel = 1002
%IDC_btnRUNQUERY    = 1006
%IDC_lblInputFile   = 1007
%IDC_txtInputFile   = 1008
%IDC_lblOutput      = 1009
%IDC_chkInputFile   = 1010
#PBFORMS END CONSTANTS
'------------------------------------------------------------------------------
%ID_OCX = 2000
'------------------------------------------------------------------------------
'   ** Declarations **
'------------------------------------------------------------------------------

#PBFORMS DECLARATIONS
'------------------------------------------------------------------------------

'------------------------------------------------------------------------------
'   ** Main Application Entry Point **
'------------------------------------------------------------------------------
FUNCTION PBMAIN()
  PBFormsInitComCtls (%ICC_WIN95_CLASSES OR %ICC_DATE_CLASSES OR _
    %ICC_INTERNET_CLASSES)

  ShowdlgOllama %HWND_DESKTOP
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
      CONTROL HIDE CB.HNDL,%IDC_txtInputFile
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

    CASE %WM_COMMAND
      ' Process control notifications
      SELECT CASE AS LONG CB.CTL
        ' /* Inserted by PB/Forms 09-15-2025 15:15:27
        CASE %IDC_chkInputFile
        ' ticked or unticked
          IF CB.CTLMSG = %BN_CLICKED OR CB.CTLMSG = 1 THEN
            CONTROL GET CHECK CB.HNDL, CB.CTL TO lngResult
            IF lngResult = 0 THEN
            ' box has been unchecked
              CONTROL HIDE CB.HNDL,%IDC_txtInputFile
            ELSE
            ' box has been checked
              CONTROL NORMALIZE CB.HNDL,%IDC_txtInputFile
              CONTROL SET TEXT CB.HNDL,%IDC_txtInputFile, EXE.PATH$
            END IF
          END IF
          '
        CASE %IDC_STATUSBAR1

        CASE %IDC_cboSelectModel

        CASE %IDC_txtEnterPrompt

        CASE %IDC_btnRUNQUERY
          IF CB.CTLMSG = %BN_CLICKED OR CB.CTLMSG = 1 THEN
          ' pick up the inputs
            CONTROL GET TEXT CB.HNDL,%IDC_cboSelectModel TO strModel
            '
            ' is there an input file?
            CONTROL GET CHECK CB.HNDL, %IDC_chkInputFile TO lngResult
            IF lngResult = 0 THEN
              strInputFile = ""
            ELSE
              CONTROL GET TEXT CB.HNDL,%IDC_txtInputFile TO strInputFile
            END IF
            '
            CONTROL GET TEXT CB.HNDL,%IDC_txtEnterPrompt TO strPrompt
            strOutputFile = EXE.PATH$ & "OutputFile.html"
            '
            CONTROL SET TEXT CB.HNDL, %IDC_STATUSBAR1,"Processing..."
            IF ISTRUE funCallOllama_withInput(strInputFile, _
                                    strPrompt, _
                                    strOutputFile, _
                                    strModel) THEN
                                    '
              ' now populate the OCX html control
              strURL = "file://" & strOutputFile
              funPopulateHTML(CB.HNDL, _
                              strURL, _
                              %ID_OCX)
              '
              CONTROL SET TEXT CB.HNDL, %IDC_STATUSBAR1,"Processing Completed"
            ELSE
              CONTROL SET TEXT CB.HNDL, %IDC_STATUSBAR1,"Error Processing..."
            END IF
          '
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
  LOCAL hDlg  AS DWORD

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
#PBFORMS END DIALOG

  DIALOG SHOW MODAL hDlg, CALL ShowdlgOllamaProc TO lRslt

#PBFORMS BEGIN CLEANUP %IDD_dlgOllama
#PBFORMS END CLEANUP

  FUNCTION = lRslt
END FUNCTION
'------------------------------------------------------------------------------
FUNCTION funAppendToFile(strFilePathToAddTo AS STRING, _
                         strData AS STRING) AS LONG
' append strData to the file if it exists or create a new one if it doesn't
  DIM intFile AS INTEGER
  DIM strError AS STRING
  '
  intFile = FREEFILE
  TRY
   IF ISTRUE ISFILE(strFilePathToAddTo) THEN
      OPEN strFilePathToAddTo FOR APPEND LOCK SHARED AS #intFile
    ELSE
      OPEN strFilePathToAddTo FOR OUTPUT AS #intFile
    END IF
    '
    PRINT #intFile, strData
    '
    FUNCTION = %TRUE
  CATCH
    strError = ERROR$   ' trap error for debug purposes
    FUNCTION = %FALSE
  FINALLY
    CLOSE #intfile
  END TRY
  '
END FUNCTION
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
