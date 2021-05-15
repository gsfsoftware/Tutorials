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
#RESOURCE "CustomControl.pbr"
%USEMACROS = 1
#INCLUDE ONCE "WIN32API.INC"
#INCLUDE ONCE "COMMCTRL.INC"
#INCLUDE ONCE "PBForms.INC"
#PBFORMS END INCLUDES
'------------------------------------------------------------------------------
#INCLUDE "..\Libraries\PB_VersionInfo.inc"
'------------------------------------------------------------------------------
'   ** Constants **
'------------------------------------------------------------------------------
#PBFORMS BEGIN CONSTANTS
%IDD_DIALOG1         =  101
%IDABORT             =    3
%IDC_lblTitle        = 1001
%IDC_txtTitle        = 1002
%IDC_lblDescription  = 1003
%IDC_txtDescription  = 1004
%IDC_CUSTOMCONTROL_1 = 1005
#PBFORMS END CONSTANTS
'------------------------------------------------------------------------------
%hiNum1 = 1
%loNum1 = 4
%hiNum2 = 9
%loNum2 = 7
'
#RESOURCE VERSIONINFO
#RESOURCE FILEVERSION %hiNum1, %loNum1, %hiNum2, %loNum2
'#RESOURCE PRODUCTVERSION %hiNum1, %loNum1, %hiNum2, %loNum2
#RESOURCE STRINGINFO "0809", "0000"
#RESOURCE VERSION$ "Comments",         "."
#RESOURCE VERSION$ "CompanyName",      "Company name here"
#RESOURCE VERSION$ "FileDescription",  "Demo for custom controls"
#RESOURCE VERSION$ "InternalName",     "CustomControl"
#RESOURCE VERSION$ "LegalCopyright",   "Copyright 2021 My Company"
#RESOURCE VERSION$ "OriginalFilename", "CustomControl.exe"
#RESOURCE VERSION$ "PrivateBuild",     "n/a"
#RESOURCE VERSION$ "ProductName",      "Custom Control Demo"
#RESOURCE VERSION$ "ProductVersion",   "1.4.9.7"
#RESOURCE VERSION$ "SpecialBuild",     "n/a"
'------------------------------------------------------------------------------
'   ** Declarations **
'------------------------------------------------------------------------------
DECLARE CALLBACK FUNCTION ShowDIALOG1Proc()
DECLARE FUNCTION ShowDIALOG1(BYVAL hParent AS DWORD) AS LONG
#PBFORMS DECLARATIONS
'------------------------------------------------------------------------------

'------------------------------------------------------------------------------
'   ** Main Application Entry Point **
'------------------------------------------------------------------------------
FUNCTION PBMAIN()
  PBFormsInitComCtls (%ICC_WIN95_CLASSES OR %ICC_DATE_CLASSES OR _
    %ICC_INTERNET_CLASSES)
  funInitExeVersionControl
  ShowDIALOG1 %HWND_DESKTOP
END FUNCTION
'------------------------------------------------------------------------------

'------------------------------------------------------------------------------
'   ** CallBacks **
'------------------------------------------------------------------------------
CALLBACK FUNCTION ShowDIALOG1Proc()

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
        ' /* Inserted by PB/Forms 05-15-2021 09:24:47
        CASE %IDC_CUSTOMCONTROL_1
        ' */

        CASE %IDABORT
          IF CB.CTLMSG = %BN_CLICKED OR CB.CTLMSG = 1 THEN
            DIALOG END CB.HNDL
          END IF

        CASE %IDC_txtTitle

        CASE %IDC_txtDescription

      END SELECT
  END SELECT
END FUNCTION
'------------------------------------------------------------------------------

'------------------------------------------------------------------------------
'   ** Dialogs **
'------------------------------------------------------------------------------
FUNCTION ShowDIALOG1(BYVAL hParent AS DWORD) AS LONG
  LOCAL lRslt AS LONG

#PBFORMS BEGIN DIALOG %IDD_DIALOG1->->
  LOCAL hDlg  AS DWORD

  DIALOG NEW hParent, "Main form", 403, 206, 513, 291, %WS_POPUP OR _
    %WS_BORDER OR %WS_DLGFRAME OR %WS_CAPTION OR %WS_SYSMENU OR _
    %WS_CLIPSIBLINGS OR %WS_VISIBLE OR %DS_MODALFRAME OR %DS_CENTER OR _
    %DS_3DLOOK OR %DS_NOFAILCREATE OR %DS_SETFONT, %WS_EX_CONTROLPARENT OR _
    %WS_EX_LEFT OR %WS_EX_LTRREADING OR %WS_EX_RIGHTSCROLLBAR, TO hDlg
  CONTROL ADD BUTTON,  hDlg, %IDABORT, "Exit", 440, 250, 50, 15
  CONTROL ADD LABEL,   hDlg, %IDC_lblTitle, "Title", 25, 60, 100, 10
  CONTROL SET COLOR    hDlg, %IDC_lblTitle, %BLUE, -1
  CONTROL ADD TEXTBOX, hDlg, %IDC_txtTitle, "", 25, 70, 180, 15
  CONTROL ADD LABEL,   hDlg, %IDC_lblDescription, "Description", 25, 130, _
    100, 10
  CONTROL SET COLOR    hDlg, %IDC_lblDescription, %BLUE, -1
  CONTROL ADD TEXTBOX, hDlg, %IDC_txtDescription, "", 25, 140, 465, 65
  CONTROL ADD "PbCustomExeLabel", hDlg, %IDC_CUSTOMCONTROL_1, "", 235, 20, 265, 45, %WS_CHILD _
    OR %WS_VISIBLE, %WS_EX_LEFT OR %WS_EX_LTRREADING OR _
    %WS_EX_RIGHTSCROLLBAR
#PBFORMS END DIALOG

  DIALOG SHOW MODAL hDlg, CALL ShowDIALOG1Proc TO lRslt

#PBFORMS BEGIN CLEANUP %IDD_DIALOG1
#PBFORMS END CLEANUP

  FUNCTION = lRslt
END FUNCTION
'------------------------------------------------------------------------------
