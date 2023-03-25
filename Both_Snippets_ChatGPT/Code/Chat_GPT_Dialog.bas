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
#RESOURCE "Chat_GPT_Dialog.pbr"
%USEMACROS = 1
#INCLUDE ONCE "WIN32API.INC"
#INCLUDE ONCE "COMMCTRL.INC"
#INCLUDE ONCE "PBForms.INC"
#PBFORMS END INCLUDES
'------------------------------------------------------------------------------
#INCLUDE ONCE "Chat_GPT.inc"

'
' n.b. this application uses the José Roca API libraries
' available from
' for latest version see link below
' http://www.jose.it-berater.org/smfforum/index.php?topic=5061.0
'------------------------------------------------------------------------------
'   ** Constants **
'------------------------------------------------------------------------------
#PBFORMS BEGIN CONSTANTS 
%IDD_DIALOG1      =  101  '*
%IDC_txtURL       = 1001
%IDC_STATUSBAR1   = 1002
%IDC_lblURL       = 1003
%IDC_lblAPIKey    = 1004
%IDC_lblTitle     = 1006
%IDC_lblModel     = 1008
%IDC_lblPrompt    = 1010
%IDC_txtPrompt    = 1011
%IDC_btnSubmit    = 1012
%IDC_txtOutput    = 1013
%IDC_lblOutput    = 1015
%IDABORT          =    3
%IDC_txtAPIkey    = 1007
%IDC_txtModel     = 1009
%IDD_ChatGPTDemo  =   -1
%IDC_lblMaxTokens = 1017
%IDC_txtMaxTokens = 1016
#PBFORMS END CONSTANTS
'------------------------------------------------------------------------------

'------------------------------------------------------------------------------
'   ** Declarations **
'------------------------------------------------------------------------------
DECLARE CALLBACK FUNCTION ShowChatGPTDemoProc()
DECLARE FUNCTION ShowChatGPTDemo(BYVAL hParent AS DWORD) AS LONG
#PBFORMS DECLARATIONS
'------------------------------------------------------------------------------

'------------------------------------------------------------------------------
'   ** Main Application Entry Point **
'------------------------------------------------------------------------------
FUNCTION PBMAIN()
  PBFormsInitComCtls (%ICC_WIN95_CLASSES OR %ICC_DATE_CLASSES OR _
    %ICC_INTERNET_CLASSES)

  ShowChatGPTDemo %HWND_DESKTOP
  '
END FUNCTION
'------------------------------------------------------------------------------

'------------------------------------------------------------------------------
'   ** CallBacks **
'------------------------------------------------------------------------------
CALLBACK FUNCTION ShowChatGPTDemoProc()
  LOCAL wstrPrompt AS WSTRING         ' prompt question to send
  LOCAL wstrURLcompletions AS WSTRING ' URL to call
  LOCAL wstrModel AS WSTRING          ' Model to use
  LOCAL dwMaxTokens AS DWORD          ' Max tokens setting
  LOCAL wstrApiKey AS WSTRING         ' API key for ChatGPT
  LOCAL strTemp AS STRING             ' used to pick up numeric values
  LOCAL strOutput AS STRING           ' output from CHatGPT
  LOCAL strMacError AS STRING         ' macro error message
  LOCAL hFocusID AS LONG              ' handle of field in error
  '
  SELECT CASE AS LONG CB.MSG
    CASE %WM_INITDIALOG
      ' Initialization handler
      PREFIX "control set text cb.hndl,"
        %IDC_txtURL ,"https://api.openai.com/v1/completions"
        %IDC_txtMaxTokens, "500"
        %IDC_txtModel, "text-davinci-003"
      END PREFIX
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
        ' /* Inserted by PB/Forms 03-23-2023 21:16:42
        CASE %IDC_txtMaxTokens
        ' */

        ' /* Inserted by PB/Forms 03-23-2023 21:04:42
        CASE %IDC_txtAPIkey

        CASE %IDC_txtModel
        ' */

        CASE %IDC_txtURL

        CASE %IDC_txtPrompt

        CASE %IDC_btnSubmit
          IF CB.CTLMSG = %BN_CLICKED OR CB.CTLMSG = 1 THEN
            PREFIX "control get text cb.hndl,"
              %IDC_txtPrompt TO wstrPrompt
              %IDC_txtURL TO wstrURLcompletions
              %IDC_txtModel TO wstrModel
              %IDC_txtAPIkey TO wstrApiKey
              %IDC_txtMaxTokens TO strTemp
            END PREFIX
            '
            ' store max tokens
            dwMaxTokens = VAL(strTemp)
            '
            ' check all parameters have been supplied
            IF ISTRUE funIsValidInput(CB.HNDL, _
                                      wstrPrompt, _
                                      wstrURLcompletions, _
                                      wstrModel, _
                                      wstrApiKey, _
                                      dwMaxTokens, _
                                      strMacError, _
                                      hFocusID, _
                                      %IDC_STATUSBAR1) THEN
                               '
              CONTROL SET TEXT CB.HNDL, %IDC_STATUSBAR1, _
                                    "Waiting on ChatGPT...."
              '
              CONTROL DISABLE CB.HNDL,%IDC_btnSubmit
              IF ISTRUE funRunChatGPTQuery(wstrPrompt, _
                                           wstrURLcompletions, _
                                           wstrModel, _
                                           wstrApiKey, _
                                           dwMaxTokens, _
                                           strOutput) THEN
                                           '
              REPLACE "\n" WITH $CRLF IN strOutput
              ' output to dialog
                CONTROL SET TEXT CB.HNDL,%IDC_txtOutput,strOutput
              ELSE
                CONTROL SET TEXT CB.HNDL,%IDC_txtOutput,strOutput
              END IF
              '
              CONTROL ENABLE CB.HNDL,%IDC_btnSubmit
              CONTROL SET TEXT CB.HNDL, %IDC_STATUSBAR1, _
                                    "Ready...."
              '
            ELSE
            ' invalid input
              macValidationWarning(strMacError)
              IF hFocusID <>0 THEN
              ' set the focus to the errored field
                CONTROL SET FOCUS CB.HNDL,hFocusID
              END IF
            '
            END IF
            '
          END IF

        CASE %IDABORT
          IF CB.CTLMSG = %BN_CLICKED OR CB.CTLMSG = 1 THEN
            DIALOG END CB.HNDL
          END IF

        CASE %IDC_STATUSBAR1

        CASE %IDC_txtOutput

      END SELECT
  END SELECT
END FUNCTION
'------------------------------------------------------------------------------
FUNCTION funIsValidInput(hDlg AS DWORD, wstrPrompt AS WSTRING, _
                         wstrURLcompletions AS WSTRING, _
                         wstrModel AS WSTRING, _
                         wstrApiKey AS WSTRING, _
                         dwMaxTokens AS DWORD, _
                         strMacError AS STRING, _
                         hFocusID AS LONG, _
                         lngStatusBar AS LONG) AS LONG
' validate the input
' ensure all fields are populated
  DIM a_lngText(2,4) AS LONG ' storage for the txt & label controls
  LOCAL lngR AS LONG
  LOCAL strValue AS STRING   ' value held in text box
  LOCAL lngFail AS LONG      ' flag to indicate validation failure
  '
  ' specify the controls to check
  a_lngText(1,0) = %IDC_txtURL
  a_lngText(1,1) = %IDC_txtAPIkey
  a_lngText(1,2) = %IDC_txtMaxTokens
  a_lngText(1,3) = %IDC_txtModel
  a_lngText(1,4) = %IDC_txtPrompt
  '
  ' specify the labels to highlight
  a_lngText(2,0) = %IDC_lblURL
  a_lngText(2,1) = %IDC_lblAPIkey
  a_lngText(2,2) = %IDC_lblMaxTokens
  a_lngText(2,3) = %IDC_lblModel
  a_lngText(2,4) = %IDC_lblPrompt
  '
  ' now check the controls
  FOR lngR = 0 TO 4
    CONTROL GET TEXT hDlg,a_lngText(1,lngR) TO strValue
    '
    IF TRIM$(strValue) = "" THEN
      strMacError = "Mandatory Item missed/blank"
      CONTROL SET TEXT hDlg,lngStatusBar,strMacError
      CONTROL SET COLOR hDlg,a_lngText(2,lngR),%RED,-1
      CONTROL REDRAW hDlg,a_lngText(2,lngR)
      hFocusID = a_lngText(1,lngR)
      lngFail = %TRUE
      '
    ELSE
    ' field is ok - clear colour on labels
      CONTROL SET COLOR hDlg,a_lngText(2,lngR),%BLUE,-1
      CONTROL REDRAW hDlg,a_lngText(2,lngR)
    END IF
    '
  NEXT lngR
  '
  IF lngFail = %TRUE THEN
  ' validation has failed
    FUNCTION = %FALSE
  ELSE
    CONTROL SET TEXT hDlg,lngStatusBar,""
    FUNCTION = %TRUE
  END IF
  '
END FUNCTION
'
MACRO macValidationWarning(strError)
' handle error messages
  MSGBOX "Unfortunately validation has failed on this page with '" & _
          strError & "'." & $CRLF & _
          "The field or fields that have failed will be indicated in RED" & $CRLF & _
          "and an error message will appear at the bottom of the page, now click OK" _
                       ,%MB_ICONWARNING OR %MB_TASKMODAL, "Validation Error"
END MACRO
'------------------------------------------------------------------------------
'   ** Dialogs **
'------------------------------------------------------------------------------
FUNCTION ShowChatGPTDemo(BYVAL hParent AS DWORD) AS LONG
  LOCAL lRslt  AS LONG
  LOCAL hFont1 AS DWORD
  LOCAL hFont2 AS DWORD
  '
#PBFORMS BEGIN DIALOG %IDD_ChatGPTDemo->->
  LOCAL hDlg  AS DWORD

  DIALOG NEW hParent, "ChatGPT Demo", 52, 112, 925, 483, %WS_POPUP OR _
    %WS_BORDER OR %WS_DLGFRAME OR %WS_CAPTION OR %WS_SYSMENU OR _
    %WS_MINIMIZEBOX OR %WS_CLIPSIBLINGS OR %WS_VISIBLE OR %DS_MODALFRAME OR _
    %DS_3DLOOK OR %DS_NOFAILCREATE OR %DS_SETFONT, %WS_EX_CONTROLPARENT OR _
    %WS_EX_LEFT OR %WS_EX_LTRREADING OR %WS_EX_RIGHTSCROLLBAR, TO hDlg
  CONTROL ADD TEXTBOX,   hDlg, %IDC_txtURL, "", 35, 60, 615, 21
  CONTROL ADD TEXTBOX,   hDlg, %IDC_txtAPIkey, "", 35, 110, 615, 21, _
    %WS_CHILD OR %WS_VISIBLE OR %WS_TABSTOP OR %ES_LEFT OR %ES_PASSWORD OR _
    %ES_AUTOHSCROLL, %WS_EX_CLIENTEDGE OR %WS_EX_LEFT OR %WS_EX_LTRREADING _
    OR %WS_EX_RIGHTSCROLLBAR
  CONTROL ADD TEXTBOX,   hDlg, %IDC_txtMaxTokens, "", 685, 110, 165, 21, _
    %WS_CHILD OR %WS_VISIBLE OR %WS_TABSTOP OR %ES_CENTER OR _
    %ES_AUTOHSCROLL, %WS_EX_CLIENTEDGE OR %WS_EX_LEFT OR %WS_EX_LTRREADING _
    OR %WS_EX_RIGHTSCROLLBAR
  CONTROL ADD TEXTBOX,   hDlg, %IDC_txtModel, "", 35, 158, 615, 21
  CONTROL ADD TEXTBOX,   hDlg, %IDC_txtPrompt, "", 35, 225, 615, 75, _
    %WS_CHILD OR %WS_VISIBLE OR %WS_TABSTOP OR %WS_VSCROLL OR %ES_LEFT OR _
    %ES_MULTILINE OR %ES_AUTOHSCROLL OR %ES_WANTRETURN, %WS_EX_CLIENTEDGE OR _
    %WS_EX_LEFT OR %WS_EX_LTRREADING OR %WS_EX_RIGHTSCROLLBAR
  CONTROL ADD BUTTON,    hDlg, %IDC_btnSubmit, "Submit Request", 665, 275, _
    90, 25
  CONTROL ADD BUTTON,    hDlg, %IDABORT, "Exit", 860, 445, 50, 15
  CONTROL ADD STATUSBAR, hDlg, %IDC_STATUSBAR1, "Ready", 0, 0, 0, 0
  CONTROL ADD LABEL,     hDlg, %IDC_lblURL, "ChatGPT URL for completions", _
    35, 44, 275, 16
  CONTROL SET COLOR      hDlg, %IDC_lblURL, %BLUE, -1
  CONTROL ADD LABEL,     hDlg, %IDC_lblAPIKey, "API Key", 35, 94, 275, 16
  CONTROL SET COLOR      hDlg, %IDC_lblAPIKey, %BLUE, -1
  CONTROL ADD LABEL,     hDlg, %IDC_lblTitle, "Chat GPT Demo", 35, 10, 220, _
    25
  CONTROL SET COLOR      hDlg, %IDC_lblTitle, %BLUE, -1
  CONTROL ADD LABEL,     hDlg, %IDC_lblModel, "Model", 35, 142, 275, 16
  CONTROL SET COLOR      hDlg, %IDC_lblModel, %BLUE, -1
  CONTROL ADD LABEL,     hDlg, %IDC_lblPrompt, "Prompt", 35, 205, 275, 16
  CONTROL SET COLOR      hDlg, %IDC_lblPrompt, %BLUE, -1
  CONTROL ADD TEXTBOX,   hDlg, %IDC_txtOutput, "", 35, 330, 815, 130, _
    %WS_CHILD OR %WS_VISIBLE OR %WS_TABSTOP OR %WS_HSCROLL OR %WS_VSCROLL OR _
    %ES_LEFT OR %ES_MULTILINE OR %ES_AUTOHSCROLL OR %ES_READONLY OR _
    %ES_WANTRETURN, %WS_EX_CLIENTEDGE OR %WS_EX_LEFT OR %WS_EX_LTRREADING OR _
    %WS_EX_RIGHTSCROLLBAR
  CONTROL ADD LABEL,     hDlg, %IDC_lblOutput, "Output from ChatGPT", 35, _
    313, 275, 16
  CONTROL SET COLOR      hDlg, %IDC_lblOutput, %BLUE, -1
  CONTROL ADD LABEL,     hDlg, %IDC_lblMaxTokens, "Max Tokens", 685, 94, 100, _
    16
  CONTROL SET COLOR      hDlg, %IDC_lblMaxTokens, %BLUE, -1
#PBFORMS END DIALOG
  ' create fonts
  FONT NEW "MS Sans Serif", 12, 1, %ANSI_CHARSET TO hFont1
  FONT NEW "MS Sans Serif", 18, 1, %ANSI_CHARSET TO hFont2
  '
  ' set screen objects with fonts
  PREFIX "CONTROL SET FONT hDlg,"
    %IDC_txtURL, hFont1
    %IDC_txtAPIkey, hFont1
    %IDC_txtMaxTokens, hFont1
    %IDC_txtModel, hFont1
    %IDC_txtPrompt, hFont1
    %IDC_lblURL, hFont1
    %IDC_lblAPIKey, hFont1
    %IDC_lblModel, hFont1
    %IDC_lblPrompt, hFont1
    %IDC_txtOutput, hFont1
    %IDC_lblOutput, hFont1
    %IDC_lblMaxTokens, hFont1
    %IDC_lblTitle, hFont2
  END PREFIX
  '
  DIALOG SHOW MODAL hDlg, CALL ShowChatGPTDemoProc TO lRslt

#PBFORMS BEGIN CLEANUP %IDD_ChatGPTDemo
#PBFORMS END CLEANUP
  '
  FUNCTION = lRslt
END FUNCTION
'------------------------------------------------------------------------------

              