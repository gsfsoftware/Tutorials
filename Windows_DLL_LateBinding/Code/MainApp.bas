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
#RESOURCE "MainApp.pbr"
%USEMACROS = 1
#INCLUDE ONCE "WIN32API.INC"
#INCLUDE ONCE "COMMCTRL.INC"
#INCLUDE ONCE "PBForms.INC"
#PBFORMS END INCLUDES
'------------------------------------------------------------------------------
' test declare
' DECLARE FUNCTION funTest LIB "test.dll" ALIAS "funTest"() AS STRING
'------------------------------------------------------------------------------
'   ** Constants **
'------------------------------------------------------------------------------
#PBFORMS BEGIN CONSTANTS
%IDR_IMGFILE1       =  102
%IDR_IMGFILE2       =  103
%IDR_IMGFILE3       =  104
%IDD_dlgCountry     =  101
%IDC_imgFrance      = 1001
%IDC_imgNetherlands = 1002
%IDC_imgUK          = 1003
%IDC_lblGreeting    = 1005
%IDD_dlgGoodBye     =  105
%IDC_lblGoodbye     = 1006
#PBFORMS END CONSTANTS
'------------------------------------------------------------------------------
GLOBAL g_hLib AS DWORD   ' used for library handle
'
' declare the function we are going to user in the DLL library
DECLARE FUNCTION funGetPhrase() AS STRING
'------------------------------------------------------------------------------
'   ** Declarations **
'------------------------------------------------------------------------------
DECLARE CALLBACK FUNCTION ShowdlgCountryProc()
DECLARE FUNCTION ShowdlgCountry(BYVAL hParent AS DWORD) AS LONG
#PBFORMS DECLARATIONS
'------------------------------------------------------------------------------

'------------------------------------------------------------------------------
'   ** Main Application Entry Point **
'------------------------------------------------------------------------------
FUNCTION PBMAIN()
  PBFormsInitComCtls (%ICC_WIN95_CLASSES OR %ICC_DATE_CLASSES OR _
    %ICC_INTERNET_CLASSES)
  '
  ' try to call a function in a library that doesn't exist
  ' funTest()
  '
  ShowdlgCountry %HWND_DESKTOP
END FUNCTION
'------------------------------------------------------------------------------

'------------------------------------------------------------------------------
'   ** CallBacks **
'------------------------------------------------------------------------------
CALLBACK FUNCTION ShowdlgCountryProc()
  '

  '
  SELECT CASE AS LONG CB.MSG
    CASE %WM_INITDIALOG
    ' Initialization handler
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
    CASE %WM_DESTROY
    ' form is being unloaded
      ' so free up the library
      '
      ShowGoodBye CB.HNDL
      '
      IF g_hLib <> 0 THEN
        FreeLibrary g_hLib
      END IF
      '
    CASE %WM_COMMAND
      ' Process control notifications
      SELECT CASE AS LONG CB.CTL
        CASE %IDC_imgFrance
          IF CB.CTLMSG = %BN_CLICKED OR CB.CTLMSG = 1 THEN
            g_hLib = LoadLibrary("libFrench.dll")
          END IF

        CASE %IDC_imgNetherlands
          IF CB.CTLMSG = %BN_CLICKED OR CB.CTLMSG = 1 THEN
            g_hLib = LoadLibrary("libDutch.dll")
          END IF

        CASE %IDC_imgUK
          IF CB.CTLMSG = %BN_CLICKED OR CB.CTLMSG = 1 THEN
            g_hLib = LoadLibrary("libEnglish.dll")
          END IF

      END SELECT
      '
      IF g_hLib = 0 THEN
      ' cannot load the library
         MSGBOX "Unable to load the language library", _
                %MB_ICONERROR OR %MB_TASKMODAL
      ELSE
        CONTROL SET TEXT CB.HNDL,%IDC_lblGreeting, _
                         funGetText("funReturnGreeting")

      END IF
      '
  END SELECT
      '
END FUNCTION
'------------------------------------------------------------------------------
FUNCTION funGetText(BYVAL strPhrase AS ASCIIZ * 100) AS STRING
' return the phrase needed
  LOCAL hProc AS DWORD
  LOCAL strText AS STRING
  '
  hProc = GetProcAddress(g_hLib, strPhrase)
  IF hProc <> 0 THEN
    CALL DWORD hProc USING funGetPhrase() TO strText
    FUNCTION = strText
  ELSE
    FUNCTION = ""
  END IF
  '
END FUNCTION
'------------------------------------------------------------------------------
'   ** Dialogs **
'------------------------------------------------------------------------------
FUNCTION ShowdlgCountry(BYVAL hParent AS DWORD) AS LONG
  LOCAL lRslt  AS LONG

#PBFORMS BEGIN DIALOG %IDD_dlgCountry->->
  LOCAL hDlg   AS DWORD
  LOCAL hFont1 AS DWORD

  DIALOG NEW hParent, "Main app Country Selection", 328, 209, 467, 255, _
    %WS_POPUP OR %WS_BORDER OR %WS_DLGFRAME OR %WS_CAPTION OR %WS_SYSMENU OR _
    %WS_CLIPSIBLINGS OR %WS_VISIBLE OR %DS_MODALFRAME OR %DS_CENTER OR _
    %DS_3DLOOK OR %DS_NOFAILCREATE OR %DS_SETFONT, %WS_EX_CONTROLPARENT OR _
    %WS_EX_LEFT OR %WS_EX_LTRREADING OR %WS_EX_RIGHTSCROLLBAR, TO hDlg
  CONTROL ADD IMGBUTTONX, hDlg, %IDC_imgFrance, "#" + FORMAT$(%IDR_IMGFILE1), _
    105, 80, 50, 50, %WS_CHILD OR %WS_VISIBLE OR %WS_TABSTOP OR %BS_ICON OR _
    %BS_PUSHLIKE OR %BS_PUSHBUTTON, %WS_EX_LEFT OR %WS_EX_LTRREADING
  CONTROL ADD IMGBUTTONX, hDlg, %IDC_imgNetherlands, "#" + _
    FORMAT$(%IDR_IMGFILE2), 180, 80, 50, 50, %WS_CHILD OR %WS_VISIBLE OR _
    %WS_TABSTOP OR %BS_ICON OR %BS_PUSHLIKE OR %BS_PUSHBUTTON, %WS_EX_LEFT _
    OR %WS_EX_LTRREADING
  CONTROL ADD IMGBUTTONX, hDlg, %IDC_imgUK, "#" + FORMAT$(%IDR_IMGFILE3), _
    255, 80, 50, 50, %WS_CHILD OR %WS_VISIBLE OR %WS_TABSTOP OR %BS_ICON OR _
    %BS_PUSHLIKE OR %BS_PUSHBUTTON, %WS_EX_LEFT OR %WS_EX_LTRREADING
  CONTROL ADD LABEL,      hDlg, %IDC_lblGreeting, "", 105, 155, 200, 40, %WS_CHILD _
    OR %WS_VISIBLE OR %SS_CENTER, %WS_EX_LEFT OR %WS_EX_LTRREADING
  CONTROL SET COLOR       hDlg, %IDC_lblGreeting, %BLUE, -1

  FONT NEW "MS Sans Serif", 18, 0, %ANSI_CHARSET TO hFont1

  CONTROL SET FONT hDlg, %IDC_lblGreeting, hFont1
#PBFORMS END DIALOG

  DIALOG SHOW MODAL hDlg, CALL ShowdlgCountryProc TO lRslt

#PBFORMS BEGIN CLEANUP %IDD_dlgCountry
  FONT END hFont1
#PBFORMS END CLEANUP

  FUNCTION = lRslt
END FUNCTION
'------------------------------------------------------------------------------
FUNCTION ShowGoodBye(BYVAL hParent AS DWORD) AS LONG
  LOCAL lRslt  AS LONG
  LOCAL strText AS STRING

#PBFORMS BEGIN DIALOG %IDD_dlgGoodBye->->
  LOCAL hDlg   AS DWORD
  LOCAL hFont1 AS DWORD

  DIALOG NEW hParent, "", 388, 275, 305, 50, %WS_POPUP OR %WS_BORDER _
    OR %WS_CLIPSIBLINGS OR %WS_VISIBLE OR %DS_CENTER OR %DS_3DLOOK OR _
    %DS_NOFAILCREATE OR %DS_SETFONT, %WS_EX_CONTROLPARENT OR %WS_EX_LEFT OR _
    %WS_EX_LTRREADING OR %WS_EX_RIGHTSCROLLBAR, TO hDlg
  CONTROL ADD LABEL, hDlg, %IDC_lblGoodbye, "Label1", 30, 12, 245, 25, _
    %WS_CHILD OR %WS_VISIBLE OR %SS_CENTER, %WS_EX_LEFT OR %WS_EX_LTRREADING
  CONTROL SET COLOR  hDlg, %IDC_lblGoodbye, %BLUE, -1

  FONT NEW "MS Sans Serif", 24, 0, %ANSI_CHARSET TO hFont1

  CONTROL SET FONT hDlg, %IDC_lblGoodbye, hFont1
#PBFORMS END DIALOG
  strText = funGetText("funSayGoodbye")
  IF strText = "" THEN strText = "Goodbye"
  CONTROL SET TEXT hDlg,%IDC_lblGoodbye,strText
  '
  DIALOG SHOW MODELESS hDlg TO lRslt
  SLEEP 2000
#PBFORMS BEGIN CLEANUP %IDD_dlgGoodBye
  FONT END hFont1
#PBFORMS END CLEANUP

  FUNCTION = lRslt
END FUNCTION
