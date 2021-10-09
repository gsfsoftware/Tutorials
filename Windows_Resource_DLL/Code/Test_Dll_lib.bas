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

'#RESOURCE ICON, icoBuild, "..\Libraries\Graphics\Build.ico"
'#RESOURCE ICON, icoAdd, "..\Libraries\Graphics\add.ico"

'
'------------------------------------------------------------------------------
'   ** Includes **
'------------------------------------------------------------------------------
#PBFORMS BEGIN INCLUDES
#RESOURCE "Test_Dll_lib.pbr"
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
%IDD_DIALOG1 =  101
%IDC_IMAGE1  = 1001
%IDC_IMAGE2  = 1002
#PBFORMS END CONSTANTS
'------------------------------------------------------------------------------

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

      END SELECT
  END SELECT
END FUNCTION
'------------------------------------------------------------------------------

'------------------------------------------------------------------------------
'   ** Dialogs **
'------------------------------------------------------------------------------
FUNCTION ShowDIALOG1(BYVAL hParent AS DWORD) AS LONG
  LOCAL lRslt AS LONG
  '
  LOCAL hLib AS DWORD
  LOCAL hIcon AS DWORD

#PBFORMS BEGIN DIALOG %IDD_DIALOG1->->
  LOCAL hDlg  AS DWORD

  DIALOG NEW hParent, "Load Icon from DLL", 337, 197, 396, 237, %WS_POPUP OR _
    %WS_BORDER OR %WS_DLGFRAME OR %WS_CAPTION OR %WS_SYSMENU OR _
    %WS_MINIMIZEBOX OR %WS_CLIPSIBLINGS OR %WS_VISIBLE OR %DS_MODALFRAME OR _
    %DS_CENTER OR %DS_3DLOOK OR %DS_NOFAILCREATE OR %DS_SETFONT, _
    %WS_EX_CONTROLPARENT OR %WS_EX_LEFT OR %WS_EX_LTRREADING OR _
    %WS_EX_RIGHTSCROLLBAR, TO hDlg
  CONTROL ADD IMAGE, hDlg, %IDC_IMAGE1, "", 75, 45, 45, 35, %WS_CHILD OR _
    %WS_VISIBLE OR %SS_BITMAP OR %SS_CENTERIMAGE
  CONTROL ADD IMAGE, hDlg, %IDC_IMAGE2, "", 75, 80, 45, 35, %WS_CHILD OR _
    %WS_VISIBLE OR %SS_BITMAP OR %SS_CENTERIMAGE
#PBFORMS END DIALOG
  '
  ' now load the icon
  'CONTROL SET IMAGE hDlg, %IDC_IMAGE1, "icoBuild"
  'CONTROL SET IMAGE hDlg, %IDC_IMAGE2, "icoAdd"
  '
  ' first load the library
'  hLib = LoadLibrary("WinResources.DLL")
'  if hLib > 0 then
'  ' library has been loaded
'    hIcon = LoadIcon(hLib, "icoBuild")
'    if hIcon > 0 then
'      SendDlgItemMessage hDlg, %IDC_IMAGE1, _
'                         %STM_SETIMAGE, %IMAGE_ICON, hIcon
'    end if
'    '
'    hIcon = LoadIcon(hLib, "icoAdd")
'    IF hIcon > 0 THEN
'      SendDlgItemMessage hDlg, %IDC_IMAGE2, _
'                         %STM_SETIMAGE, %IMAGE_ICON, hIcon
'    END IF
    '
'    freelibrary hLib
  '
'  end if
  '
  ' load each of the icons to the image controls
  funAddIcon("icoBuild",%IDC_IMAGE1, hDlg)
  funAddIcon("icoAdd",%IDC_IMAGE2, hDlg)
  '
  DIALOG SHOW MODAL hDlg, CALL ShowDIALOG1Proc TO lRslt

#PBFORMS BEGIN CLEANUP %IDD_DIALOG1
#PBFORMS END CLEANUP

  FUNCTION = lRslt
END FUNCTION
'------------------------------------------------------------------------------
'
FUNCTION funAddIcon(ascIconName AS ASCIIZ * 20 , _
                    lngControl AS LONG, _
                    hDlg AS DWORD) AS LONG
                    '
  ' add an icon to an image control on a dialog
  ' from the WinResources.DLL
  LOCAL hLib AS DWORD
  LOCAL hIcon AS DWORD
  '
  ' first load the library
  hLib = LoadLibrary("WinResources.DLL")
  IF hLib > 0 THEN
  ' library has been loaded
    hIcon = LoadIcon(hLib, ascIconName)
    IF hIcon > 0 THEN
      SendDlgItemMessage hDlg, lngControl, _
                         %STM_SETIMAGE, %IMAGE_ICON, hIcon
    END IF
    '
    freelibrary hLib
  END IF
  '
END FUNCTION
