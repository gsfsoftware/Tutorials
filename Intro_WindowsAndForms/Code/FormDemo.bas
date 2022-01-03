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
#RESOURCE "FormDemo.pbr"
%USEMACROS = 1
#INCLUDE ONCE "WIN32API.INC"
#INCLUDE ONCE "COMMCTRL.INC"
#INCLUDE ONCE "PBForms.INC"
#PBFORMS END INCLUDES
'------------------------------------------------------------------------------

'------------------------------------------------------------------------------
'   ** Constants **
'------------------------------------------------------------------------------
#PBFORMS BEGIN CONSTANTS
%IDD_dlgLogin    =  101
%IDC_LABEL1      = 1001
%IDC_LABEL2      = 1002
%IDC_txtUserName = 1003
%IDC_txtPassword = 1004
%IDOK            =    1
%IDABORT         =    3
%IDD_dlgContinue =  102
#PBFORMS END CONSTANTS
'------------------------------------------------------------------------------

'------------------------------------------------------------------------------
'   ** Declarations **
'------------------------------------------------------------------------------
DECLARE CALLBACK FUNCTION ShowdlgLoginProc()
DECLARE FUNCTION ShowdlgLogin(BYVAL hParent AS DWORD) AS LONG
DECLARE CALLBACK FUNCTION ShowdlgContinueProc()
DECLARE FUNCTION ShowdlgContinue(BYVAL hDlg AS DWORD) AS LONG
#PBFORMS DECLARATIONS
'------------------------------------------------------------------------------

'------------------------------------------------------------------------------
'   ** Main Application Entry Point **
'------------------------------------------------------------------------------
FUNCTION PBMAIN()
  LOCAL lngResult AS LONG
  '
  PBFormsInitComCtls (%ICC_WIN95_CLASSES OR %ICC_DATE_CLASSES OR _
    %ICC_INTERNET_CLASSES)

  lngResult = ShowdlgLogin(%HWND_DESKTOP)
  '
  IF lngResult = %IDOK THEN
  ' user/password ok
   ' MSGBOX "Continue with app"
    ShowdlgContinue(%HWND_DESKTOP)

  ELSE
    MSGBOX "Exiting app"
  END IF
  '
END FUNCTION
'------------------------------------------------------------------------------

'------------------------------------------------------------------------------
'   ** CallBacks **
'------------------------------------------------------------------------------
CALLBACK FUNCTION ShowdlgLoginProc()
  LOCAL strUsername AS STRING
  LOCAL strPassword AS STRING
  '
  SELECT CASE AS LONG CB.MSG
    CASE %WM_INITDIALOG
      ' Initialization handler

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
        ' /* Inserted by PB/Forms 01-03-2022 10:47:07
        CASE %IDOK
          IF CB.CTLMSG = %BN_CLICKED OR CB.CTLMSG = 1 THEN
            ' user has clicked submit
            CONTROL GET TEXT CB.HNDL,%IDC_txtUserName TO strUsername
            CONTROL GET TEXT CB.HNDL,%IDC_txtPassword TO strPassword
            '
            IF ISTRUE funConfirmPassword(strUsername, _
                                         strPassword) THEN
            ' user/password is correct
              DIALOG END CB.HNDL, %IDOK
            '
            ELSE
            ' user password is false
              MSGBOX "User/Password is not valid",%MB_ICONERROR, _
                     "Invalid entry"

            '
            END IF
            '

          END IF

        CASE %IDABORT
          IF CB.CTLMSG = %BN_CLICKED OR CB.CTLMSG = 1 THEN
            DIALOG END CB.HNDL, %IDABORT
          END IF
        ' */

        CASE %IDC_txtUserName

        CASE %IDC_txtPassword

      END SELECT
  END SELECT
END FUNCTION
'------------------------------------------------------------------------------
FUNCTION funConfirmPassword(strUsername AS STRING, _
                            strPassword AS STRING) AS LONG
  FUNCTION = %TRUE
  '
END FUNCTION
'------------------------------------------------------------------------------
'   ** Dialogs **
'------------------------------------------------------------------------------
FUNCTION ShowdlgLogin(BYVAL hParent AS DWORD) AS LONG
  LOCAL lRslt AS LONG

#PBFORMS BEGIN DIALOG %IDD_dlgLogin->->
  LOCAL hDlg  AS DWORD

  DIALOG NEW hParent, "Login to System", 470, 239, 192, 107, %WS_POPUP OR _
    %WS_BORDER OR %WS_DLGFRAME OR %WS_CAPTION OR %WS_SYSMENU OR _
    %WS_CLIPSIBLINGS OR %WS_VISIBLE OR %DS_MODALFRAME OR %DS_CENTER OR _
    %DS_3DLOOK OR %DS_NOFAILCREATE OR %DS_SETFONT, %WS_EX_CONTROLPARENT OR _
    %WS_EX_LEFT OR %WS_EX_LTRREADING OR %WS_EX_RIGHTSCROLLBAR, TO hDlg
  CONTROL ADD TEXTBOX, hDlg, %IDC_txtUserName, "", 82, 14, 100, 14
  CONTROL ADD TEXTBOX, hDlg, %IDC_txtPassword, "", 82, 38, 100, 13, %WS_CHILD _
    OR %WS_VISIBLE OR %WS_TABSTOP OR %ES_LEFT OR %ES_PASSWORD OR _
    %ES_AUTOHSCROLL, %WS_EX_CLIENTEDGE OR %WS_EX_LEFT OR %WS_EX_LTRREADING _
    OR %WS_EX_RIGHTSCROLLBAR
  CONTROL ADD LABEL,   hDlg, %IDC_LABEL1, "Enter User name ", 5, 15, 75, 10
  CONTROL SET COLOR    hDlg, %IDC_LABEL1, %BLUE, -1
  CONTROL ADD LABEL,   hDlg, %IDC_LABEL2, "Enter Password", 5, 40, 65, 10
  CONTROL SET COLOR    hDlg, %IDC_LABEL2, %BLUE, -1
  CONTROL ADD BUTTON,  hDlg, %IDOK, "Submit", 130, 80, 50, 15
  DIALOG  SEND         hDlg, %DM_SETDEFID, %IDOK, 0
  CONTROL ADD BUTTON,  hDlg, %IDABORT, "Exit App", 5, 80, 50, 15
#PBFORMS END DIALOG

  DIALOG SHOW MODAL hDlg, CALL ShowdlgLoginProc TO lRslt
  '
  IF lRslt = %IDOK THEN
    MSGBOX "Submit pressed"
  ELSE
    MSGBOX "Exit Pressed"
  END IF

#PBFORMS BEGIN CLEANUP %IDD_dlgLogin
#PBFORMS END CLEANUP

  FUNCTION = lRslt
END FUNCTION
'------------------------------------------------------------------------------

'------------------------------------------------------------------------------
CALLBACK FUNCTION ShowdlgContinueProc()

  SELECT CASE AS LONG CB.MSG
    CASE %WM_INITDIALOG
      ' Initialization handler

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

      END SELECT
  END SELECT
END FUNCTION
'------------------------------------------------------------------------------

'------------------------------------------------------------------------------
FUNCTION ShowdlgContinue(BYVAL hParent AS DWORD) AS LONG
  LOCAL lRslt AS LONG

#PBFORMS BEGIN DIALOG %IDD_dlgContinue->->
  LOCAL hDlg  AS DWORD

  DIALOG NEW hParent, "2nd Dialog", 391, 198, 326, 206, %WS_POPUP OR _
    %WS_BORDER OR %WS_DLGFRAME OR %WS_CAPTION OR %WS_SYSMENU OR _
    %WS_CLIPSIBLINGS OR %WS_VISIBLE OR %DS_MODALFRAME OR %DS_CENTER OR _
    %DS_3DLOOK OR %DS_NOFAILCREATE OR %DS_SETFONT, %WS_EX_CONTROLPARENT OR _
    %WS_EX_LEFT OR %WS_EX_LTRREADING OR %WS_EX_RIGHTSCROLLBAR, TO hDlg
#PBFORMS END DIALOG

  DIALOG SHOW MODAL hDlg, CALL ShowdlgContinueProc TO lRslt

#PBFORMS BEGIN CLEANUP %IDD_dlgContinue
#PBFORMS END CLEANUP

  FUNCTION = lRslt
END FUNCTION
'------------------------------------------------------------------------------

#PBFORMS COPY
