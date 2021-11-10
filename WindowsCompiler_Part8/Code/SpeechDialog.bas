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
#RESOURCE "SpeechDialog.pbr"
%USEMACROS = 1
#INCLUDE ONCE "WIN32API.INC"
#INCLUDE ONCE "COMMCTRL.INC"
#INCLUDE ONCE "PBForms.INC"
#PBFORMS END INCLUDES
'------------------------------------------------------------------------------
#INCLUDE "..\Libraries\PB_SpeechAPI.inc"
'------------------------------------------------------------------------------
'   ** Constants **
'------------------------------------------------------------------------------
#PBFORMS BEGIN CONSTANTS
%IDD_dlgSpeech =  101
%IDABORT       =    3
%IDOK          =    1
%IDC_txtSpeak  = 1001
%IDC_lblVoices = 1003
%IDC_cboVoices = 1002
%IDC_btnArgue  = 1004
#PBFORMS END CONSTANTS
'------------------------------------------------------------------------------

'------------------------------------------------------------------------------
'   ** Declarations **
'------------------------------------------------------------------------------
DECLARE CALLBACK FUNCTION ShowdlgSpeechProc()
DECLARE FUNCTION ShowdlgSpeech(BYVAL hParent AS DWORD) AS LONG
#PBFORMS DECLARATIONS
'------------------------------------------------------------------------------

'------------------------------------------------------------------------------
'   ** Main Application Entry Point **
'------------------------------------------------------------------------------
FUNCTION PBMAIN()
    PBFormsInitComCtls (%ICC_WIN95_CLASSES OR %ICC_DATE_CLASSES OR _
        %ICC_INTERNET_CLASSES)

    ShowdlgSpeech %HWND_DESKTOP
END FUNCTION
'------------------------------------------------------------------------------

'------------------------------------------------------------------------------
'   ** CallBacks **
'------------------------------------------------------------------------------
CALLBACK FUNCTION ShowdlgSpeechProc()
    LOCAL strText AS STRING
    LOCAL strVoiceList AS STRING
    LOCAL lngR AS LONG
    LOCAL strSelectedVoice AS STRING
    '
    SELECT CASE AS LONG CB.MSG
        CASE %WM_INITDIALOG
        ' Initialization handler
          strVoiceList = funGetVoices()
          FOR lngR = 1 TO PARSECOUNT(strVoiceList,"|")
            COMBOBOX ADD CB.HNDL,%IDC_cboVoices, _
                     PARSE$(strVoiceList,"|", lngR)
          NEXT lngR

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
                ' /* Inserted by PB/Forms 10-26-2019 21:40:57
                CASE %IDC_btnArgue
                  IF CB.CTLMSG = %BN_CLICKED OR CB.CTLMSG = 1 THEN
                    funHaveAnArguement()
                  END IF
                ' */

                ' /* Inserted by PB/Forms 10-26-2019 20:12:50
                CASE %IDC_cboVoices
                ' */

                CASE %IDC_txtSpeak

                CASE %IDOK
                  IF CB.CTLMSG = %BN_CLICKED OR CB.CTLMSG = 1 THEN
                  ' speak the text
                    CONTROL GET TEXT CB.HNDL, %IDC_txtSpeak TO strText
                    COMBOBOX GET TEXT CB.HNDL,%IDC_cboVoices TO strSelectedVoice
                    IF TRIM$(strText) <> "" THEN
                    '  funSpeak(strText)
                      funSpeakWithVoice(strText, strSelectedVoice)
                    END IF
                  '
                  END IF

                CASE %IDABORT
                  IF CB.CTLMSG = %BN_CLICKED OR CB.CTLMSG = 1 THEN
                    DIALOG END CB.HNDL
                  END IF

            END SELECT
    END SELECT
END FUNCTION
'------------------------------------------------------------------------------

'------------------------------------------------------------------------------
'   ** Dialogs **
'------------------------------------------------------------------------------
FUNCTION ShowdlgSpeech(BYVAL hParent AS DWORD) AS LONG
    LOCAL lRslt AS LONG

#PBFORMS BEGIN DIALOG %IDD_dlgSpeech->->
    LOCAL hDlg  AS DWORD

    DIALOG NEW hParent, "Speech Dialong", 376, 205, 301, 192, %WS_POPUP OR _
        %WS_BORDER OR %WS_DLGFRAME OR %WS_CAPTION OR %WS_SYSMENU OR _
        %WS_MINIMIZEBOX OR %WS_CLIPSIBLINGS OR %WS_VISIBLE OR %DS_MODALFRAME _
        OR %DS_CENTER OR %DS_3DLOOK OR %DS_NOFAILCREATE OR %DS_SETFONT, _
        %WS_EX_CONTROLPARENT OR %WS_EX_LEFT OR %WS_EX_LTRREADING OR _
        %WS_EX_RIGHTSCROLLBAR, TO hDlg
    CONTROL ADD TEXTBOX,  hDlg, %IDC_txtSpeak, "", 10, 85, 275, 55
    CONTROL ADD BUTTON,   hDlg, %IDOK, "Speak", 10, 160, 50, 15
    DIALOG  SEND          hDlg, %DM_SETDEFID, %IDOK, 0
    CONTROL ADD BUTTON,   hDlg, %IDABORT, "Exit", 235, 160, 50, 15
    CONTROL ADD COMBOBOX, hDlg, %IDC_cboVoices, , 140, 35, 145, 40, %WS_CHILD _
        OR %WS_VISIBLE OR %WS_TABSTOP OR %CBS_DROPDOWNLIST OR %CBS_SORT, _
        %WS_EX_LEFT OR %WS_EX_LTRREADING OR %WS_EX_RIGHTSCROLLBAR
    CONTROL ADD LABEL,    hDlg, %IDC_lblVoices, "Please Pick a voice", 140, _
        25, 100, 10
    CONTROL SET COLOR     hDlg, %IDC_lblVoices, %BLUE, -1
    CONTROL ADD BUTTON,   hDlg, %IDC_btnArgue, "Have an arguement", 10, 60, _
        95, 15
#PBFORMS END DIALOG

    DIALOG SHOW MODAL hDlg, CALL ShowdlgSpeechProc TO lRslt

#PBFORMS BEGIN CLEANUP %IDD_dlgSpeech
#PBFORMS END CLEANUP

    FUNCTION = lRslt
END FUNCTION
'------------------------------------------------------------------------------
FUNCTION funHaveAnArguement() AS LONG
' run an arguement with three voices
  LOCAL oSp AS DISPATCH
  LOCAL vRes AS VARIANT
  LOCAL vTxt AS VARIANT
  LOCAL vTime AS VARIANT
  LOCAL oTokens AS DISPATCH
  '
  LOCAL oTokenHeather AS DISPATCH
  LOCAL oTokenStuart AS DISPATCH
  LOCAL oTokenAnna AS DISPATCH
  '
  LOCAL vToken AS VARIANT
  LOCAL i AS LONG
  LOCAL vIdx AS VARIANT
  LOCAL nCount AS LONG
  LOCAL strDesc AS STRING
  LOCAL lngCount AS LONG
  '

    LET oSp = NEWCOM "SAPI.SpVoice"
    IF ISFALSE ISOBJECT( oSp ) THEN
      EXIT FUNCTION
    END IF
    ' Get a reference to the SAPI ISpeechObjectTokens collection
    OBJECT CALL oSp.GetVoices( ) TO vRes
    IF ISFALSE OBJRESULT THEN
      LET oTokens = vRes
      vRes = EMPTY
      ' Get the number of tokens
      OBJECT GET oTokens.Count TO vRes
      nCount = VARIANT#( vRes )
      ' Parse the collection (zero based)
      FOR i = 0 TO nCount - 1
        INCR lngCount
        IF lngCount = 4 THEN EXIT FOR
        '
        vIdx = i AS LONG
        ' Get the item by his index
        OBJECT CALL oTokens.Item( vIdx ) TO vRes
        IF ISFALSE OBJRESULT THEN
          SELECT CASE lngCount
            CASE 3
              LET oTokenHeather = vRes
            CASE 2
              LET oTokenStuart = vRes
            CASE 1
              LET oTokenAnna = vRes
          END SELECT
          vRes = EMPTY
        END IF
      NEXT i
      LET oTokens = NOTHING
      ' voices tokens got
      '
      ' set to first token
      LET vToken = oTokenStuart
      OBJECT SET oSp.Voice = vToken
      '
      vTxt = "Welcome to our house"
      OBJECT CALL oSp.Speak( vTxt ) TO vRes
      ' Wait until finished
      vTime = - 1 AS LONG   ' -1 = INFINITE
      OBJECT CALL oSp.WaitUntilDone( vTime ) TO vRes
      '
      LET vToken = oTokenHeather
      OBJECT SET oSp.Voice = vToken
      '
      vTxt = "What are you doing?"
      OBJECT CALL oSp.Speak( vTxt ) TO vRes
      ' Wait until finished
      vTime = - 1 AS LONG   ' -1 = INFINITE
      OBJECT CALL oSp.WaitUntilDone( vTime ) TO vRes
      '
      LET vToken = oTokenStuart
      OBJECT SET oSp.Voice = vToken
      '
      vTxt = "I'm talking to these people"
      OBJECT CALL oSp.Speak( vTxt ) TO vRes
      ' Wait until finished
      vTime = - 1 AS LONG   ' -1 = INFINITE
      OBJECT CALL oSp.WaitUntilDone( vTime ) TO vRes
      '
      LET vToken = oTokenHeather
      OBJECT SET oSp.Voice = vToken
      '
      vTxt = "What for, you haven't done the washing up yet!"
      OBJECT CALL oSp.Speak( vTxt ) TO vRes
      ' Wait until finished
      vTime = - 1 AS LONG   ' -1 = INFINITE
      OBJECT CALL oSp.WaitUntilDone( vTime ) TO vRes
      '
      LET vToken = oTokenStuart
      OBJECT SET oSp.Voice = vToken
      '
      vTxt = "I can do that later, this is important"
      OBJECT CALL oSp.Speak( vTxt ) TO vRes
      ' Wait until finished
      vTime = - 1 AS LONG   ' -1 = INFINITE
      OBJECT CALL oSp.WaitUntilDone( vTime ) TO vRes
      '
      LET vToken = oTokenHeather
      OBJECT SET oSp.Voice = vToken
      '
      vTxt = "You always say that and it never gets done!"
      OBJECT CALL oSp.Speak( vTxt ) TO vRes
      ' Wait until finished
      vTime = - 1 AS LONG   ' -1 = INFINITE
      OBJECT CALL oSp.WaitUntilDone( vTime ) TO vRes
      '
      LET vToken = oTokenStuart
      OBJECT SET oSp.Voice = vToken
      '
      vTxt = "But this is my job, it puts food on the table"
      OBJECT CALL oSp.Speak( vTxt ) TO vRes
      ' Wait until finished
      vTime = - 1 AS LONG   ' -1 = INFINITE
      OBJECT CALL oSp.WaitUntilDone( vTime ) TO vRes
      '
      LET vToken = oTokenHeather
      OBJECT SET oSp.Voice = vToken
      '
      vTxt = "What table, we've still just got a virtual one, I want a real table!"
      OBJECT CALL oSp.Speak( vTxt ) TO vRes
      ' Wait until finished
      vTime = - 1 AS LONG   ' -1 = INFINITE
      OBJECT CALL oSp.WaitUntilDone( vTime ) TO vRes
      '
      LET vToken = oTokenAnna
      OBJECT SET oSp.Voice = vToken
      '
      vTxt = "Now you shouldn't start arguing"
      OBJECT CALL oSp.Speak( vTxt ) TO vRes
      ' Wait until finished
      vTime = - 1 AS LONG   ' -1 = INFINITE
      OBJECT CALL oSp.WaitUntilDone( vTime ) TO vRes
      '
      LET vToken = oTokenHeather
      OBJECT SET oSp.Voice = vToken
      '
      vTxt = "And who is this! Where did she come from?"
      OBJECT CALL oSp.Speak( vTxt ) TO vRes
      ' Wait until finished
      vTime = - 1 AS LONG   ' -1 = INFINITE
      OBJECT CALL oSp.WaitUntilDone( vTime ) TO vRes
      '
      LET vToken = oTokenStuart
      OBJECT SET oSp.Voice = vToken
      '
      vTxt = "This is Anna she is a Microsoft voice"
      OBJECT CALL oSp.Speak( vTxt ) TO vRes
      ' Wait until finished
      vTime = - 1 AS LONG   ' -1 = INFINITE
      OBJECT CALL oSp.WaitUntilDone( vTime ) TO vRes
      '
      LET vToken = oTokenHeather
      OBJECT SET oSp.Voice = vToken
      '
      vTxt = "I don't want your virtual floozies in my house"
      OBJECT CALL oSp.Speak( vTxt ) TO vRes
      ' Wait until finished
      vTime = - 1 AS LONG   ' -1 = INFINITE
      OBJECT CALL oSp.WaitUntilDone( vTime ) TO vRes
      '
      LET vToken = oTokenStuart
      OBJECT SET oSp.Voice = vToken
      '
      vTxt = "It's not a house its a laptop"
      OBJECT CALL oSp.Speak( vTxt ) TO vRes
      ' Wait until finished
      vTime = - 1 AS LONG   ' -1 = INFINITE
      OBJECT CALL oSp.WaitUntilDone( vTime ) TO vRes
      '
      LET vToken = oTokenHeather
      OBJECT SET oSp.Voice = vToken
      '
      vTxt = "Or even in the laptop then! And that reminds me you have still to clean out the hard disk"
      OBJECT CALL oSp.Speak( vTxt ) TO vRes
      ' Wait until finished
      vTime = - 1 AS LONG   ' -1 = INFINITE
      OBJECT CALL oSp.WaitUntilDone( vTime ) TO vRes
      '
      LET vToken = oTokenStuart
      OBJECT SET oSp.Voice = vToken
      '
      vTxt = "I'm waiting for better weather"
      OBJECT CALL oSp.Speak( vTxt ) TO vRes
      ' Wait until finished
      vTime = - 1 AS LONG   ' -1 = INFINITE
      OBJECT CALL oSp.WaitUntilDone( vTime ) TO vRes
      '
      LET vToken = oTokenHeather
      OBJECT SET oSp.Voice = vToken
      '
      vTxt = "That's it I'm going back to my Motherboard!"
      OBJECT CALL oSp.Speak( vTxt ) TO vRes
      ' Wait until finished
      vTime = - 1 AS LONG   ' -1 = INFINITE
      OBJECT CALL oSp.WaitUntilDone( vTime ) TO vRes
      '
      LET oTokenStuart = NOTHING
      LET oTokenHeather = NOTHING
      LET oTokenAnna = NOTHING
      LET oSp = NOTHING
      '
    END IF
  '
END FUNCTION
