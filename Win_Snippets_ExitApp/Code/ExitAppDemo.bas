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
#RESOURCE "ExitAppDemo.pbr"
%USEMACROS = 1
#INCLUDE ONCE "WIN32API.INC"
#INCLUDE ONCE "COMMCTRL.INC"
#INCLUDE ONCE "PBForms.INC"
#PBFORMS END INCLUDES
'------------------------------------------------------------------------------
#RESOURCE ICON MainApp "add.ico"
'------------------------------------------------------------------------------
'   ** Constants **
'------------------------------------------------------------------------------
#PBFORMS BEGIN CONSTANTS
%IDD_dlgMain =  101
%IDABORT     =    3
%IDC_btnNext = 1001
#PBFORMS END CONSTANTS
'------------------------------------------------------------------------------

'------------------------------------------------------------------------------
'   ** Declarations **
'------------------------------------------------------------------------------
DECLARE CALLBACK FUNCTION ShowdlgMainProc()
DECLARE FUNCTION ShowdlgMain(BYVAL hParent AS DWORD) AS LONG
#PBFORMS DECLARATIONS
'------------------------------------------------------------------------------

'------------------------------------------------------------------------------
'   ** Main Application Entry Point **
'------------------------------------------------------------------------------
FUNCTION PBMAIN()
  PBFormsInitComCtls (%ICC_WIN95_CLASSES OR %ICC_DATE_CLASSES OR _
    %ICC_INTERNET_CLASSES)

  ShowdlgMain %HWND_DESKTOP
END FUNCTION
'------------------------------------------------------------------------------

'------------------------------------------------------------------------------
'   ** CallBacks **
'------------------------------------------------------------------------------
CALLBACK FUNCTION ShowdlgMainProc()

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
    '
    CASE %WM_SYSCOMMAND
    ' user has clicked on dialog X widget
      IF (CB.WPARAM AND &HFFF0) = %SC_CLOSE THEN
        IF MSGBOX("Are you sure you wish to exit the app?" _
                      , %MB_YESNO OR %MB_TASKMODAL _
                      OR %MB_ICONQUESTION _
                      , "Exiting Application?") = %IDNO THEN
        ' user has answered no so exit the function
          FUNCTION = 1
          EXIT FUNCTION
        '
        ELSE
        ' user has answered yes so exit the dialog and app
          FUNCTION = 0
          PostQuitMessage 0
        END IF
      END IF
    '
    CASE %WM_COMMAND
      ' Process control notifications
      SELECT CASE AS LONG CB.CTL
        CASE %IDC_btnNext
          IF CB.CTLMSG = %BN_CLICKED OR CB.CTLMSG = 1 THEN
          ' go to next screen
          '
          END IF

        CASE %IDABORT
          IF CB.CTLMSG = %BN_CLICKED OR CB.CTLMSG = 1 THEN
          ' exit the dialog and the application
            IF MSGBOX("Are you sure you wish to exit the app?" _
                , %MB_YESNO OR %MB_TASKMODAL _
                OR %MB_ICONQUESTION _
                , "Exiting Application?") = %IDNO THEN
            ' user has answered no so exit the function
              FUNCTION = 1
              EXIT FUNCTION
            ELSE
            ' user has answered yes so exit the dialog and app
              DIALOG END CB.HNDL
            END IF
            '
          END IF

      END SELECT
  END SELECT
END FUNCTION
'------------------------------------------------------------------------------

'------------------------------------------------------------------------------
'   ** Dialogs **
'------------------------------------------------------------------------------
FUNCTION ShowdlgMain(BYVAL hParent AS DWORD) AS LONG
  LOCAL lRslt AS LONG

#PBFORMS BEGIN DIALOG %IDD_dlgMain->->
  LOCAL hDlg  AS DWORD

  DIALOG NEW hParent, "Exit App demo", 209, 155, 501, 270, %WS_POPUP OR _
    %WS_BORDER OR %WS_DLGFRAME OR %WS_CAPTION OR %WS_SYSMENU OR _
    %WS_MINIMIZEBOX OR %WS_CLIPSIBLINGS OR %WS_VISIBLE OR %DS_MODALFRAME OR _
    %DS_CENTER OR %DS_3DLOOK OR %DS_NOFAILCREATE OR %DS_SETFONT, _
    %WS_EX_CONTROLPARENT OR %WS_EX_LEFT OR %WS_EX_LTRREADING OR _
    %WS_EX_RIGHTSCROLLBAR, TO hDlg
  CONTROL ADD BUTTON, hDlg, %IDC_btnNext, "Next", 404, 230, 55, 20
  CONTROL ADD BUTTON, hDlg, %IDABORT, "Exit", 40, 230, 55, 20
#PBFORMS END DIALOG
  DIALOG SET ICON hDlg, "MainApp"
  'DIALOG STABILIZE hDlg  ' disable the system menu and close X
  DIALOG SHOW MODAL hDlg, CALL ShowdlgMainProc TO lRslt

#PBFORMS BEGIN CLEANUP %IDD_dlgMain
#PBFORMS END CLEANUP

  FUNCTION = lRslt
END FUNCTION
'------------------------------------------------------------------------------
