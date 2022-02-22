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
'
'
' Using the scroll bars on a Dialog
' Based on code provided  by Borje Hagsten,
' further amended by Maciej Neyman.
' Free to use by all PB programers.
'
'------------------------------------------------------------------------------

#COMPILE EXE
#DIM ALL

'------------------------------------------------------------------------------
'   ** Includes **
'------------------------------------------------------------------------------
#PBFORMS BEGIN INCLUDES
#RESOURCE "ScrollbarDemo.pbr"
%USEMACROS = 1
#INCLUDE ONCE "WIN32API.INC"
#INCLUDE ONCE "COMMCTRL.INC"
#INCLUDE ONCE "PBForms.INC"
#PBFORMS END INCLUDES
'------------------------------------------------------------------------------
#INCLUDE "..\Libraries\mScrollbars.inc"
'------------------------------------------------------------------------------
'   ** Constants **
'------------------------------------------------------------------------------
#PBFORMS BEGIN CONSTANTS
%IDD_DIALOG1  =  101
%IDC_LABEL1   = 1005
%IDC_txt_1    = 1001
%IDC_txt_2    = 1002
%IDC_txt_3    = 1003
%IDC_txt_4    = 1004
%IDC_LABEL2   = 1006
%IDC_LABEL3   = 1007
%IDC_LABEL4   = 1008
%IDC_TEXTBOX1 = 1009
%IDC_LABEL5   = 1010
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
  '
  mScroll_Init_Vars
  '
  SELECT CASE AS LONG CB.MSG
    CASE %WM_INITDIALOG
    ' Initialization handler
      '
      mScrollbar_init
      '
      mScrollbar_events
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
    CASE %WM_COMMAND
      ' Process control notifications
      SELECT CASE AS LONG CB.CTL
        ' /* Inserted by PB/Forms 02-19-2022 10:08:25
        CASE %IDC_TEXTBOX1
        ' */

        CASE %IDC_txt_1

        CASE %IDC_txt_2

        CASE %IDC_txt_3

        CASE %IDC_txt_4

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

  DIALOG NEW hParent, "Scrollbar demo", 187, 108, 760, 455, %WS_POPUP OR _
    %WS_BORDER OR %WS_DLGFRAME OR %WS_CAPTION OR %WS_SYSMENU OR _
    %WS_CLIPSIBLINGS OR %WS_VSCROLL OR %WS_VISIBLE OR %DS_MODALFRAME OR _
    %DS_CENTER OR %DS_3DLOOK OR %DS_NOFAILCREATE OR %DS_SETFONT, _
    %WS_EX_CONTROLPARENT OR %WS_EX_LEFT OR %WS_EX_LTRREADING OR _
    %WS_EX_RIGHTSCROLLBAR, TO hDlg
  CONTROL ADD TEXTBOX, hDlg, %IDC_txt_1, "", 340, 40, 280, 80, %WS_CHILD OR _
    %WS_VISIBLE OR %WS_TABSTOP OR %WS_VSCROLL OR %ES_LEFT OR %ES_MULTILINE _
    OR %ES_AUTOHSCROLL OR %ES_WANTRETURN, %WS_EX_CLIENTEDGE OR %WS_EX_LEFT _
    OR %WS_EX_LTRREADING OR %WS_EX_RIGHTSCROLLBAR
  CONTROL ADD TEXTBOX, hDlg, %IDC_txt_2, "", 340, 130, 280, 80, %WS_CHILD OR _
    %WS_VISIBLE OR %WS_TABSTOP OR %WS_VSCROLL OR %ES_LEFT OR %ES_MULTILINE _
    OR %ES_AUTOHSCROLL OR %ES_WANTRETURN, %WS_EX_CLIENTEDGE OR %WS_EX_LEFT _
    OR %WS_EX_LTRREADING OR %WS_EX_RIGHTSCROLLBAR
  CONTROL ADD TEXTBOX, hDlg, %IDC_txt_3, "", 340, 220, 280, 80, %WS_CHILD OR _
    %WS_VISIBLE OR %WS_TABSTOP OR %WS_VSCROLL OR %ES_LEFT OR %ES_MULTILINE _
    OR %ES_AUTOHSCROLL OR %ES_WANTRETURN, %WS_EX_CLIENTEDGE OR %WS_EX_LEFT _
    OR %WS_EX_LTRREADING OR %WS_EX_RIGHTSCROLLBAR
  CONTROL ADD TEXTBOX, hDlg, %IDC_txt_4, "", 340, 310, 280, 80, %WS_CHILD OR _
    %WS_VISIBLE OR %WS_TABSTOP OR %WS_VSCROLL OR %ES_LEFT OR %ES_MULTILINE _
    OR %ES_AUTOHSCROLL OR %ES_WANTRETURN, %WS_EX_CLIENTEDGE OR %WS_EX_LEFT _
    OR %WS_EX_LTRREADING OR %WS_EX_RIGHTSCROLLBAR
  CONTROL ADD LABEL,   hDlg, %IDC_LABEL1, "Label", 230, 75, 100, 10
  CONTROL ADD LABEL,   hDlg, %IDC_LABEL2, "Label", 225, 170, 100, 10
  CONTROL ADD LABEL,   hDlg, %IDC_LABEL3, "Label", 225, 265, 100, 10
  CONTROL ADD LABEL,   hDlg, %IDC_LABEL4, "Label", 225, 345, 100, 10
  CONTROL ADD TEXTBOX, hDlg, %IDC_TEXTBOX1, "", 340, 405, 280, 80, %WS_CHILD _
    OR %WS_VISIBLE OR %WS_TABSTOP OR %WS_VSCROLL OR %ES_LEFT OR _
    %ES_MULTILINE OR %ES_AUTOHSCROLL OR %ES_WANTRETURN, %WS_EX_CLIENTEDGE OR _
    %WS_EX_LEFT OR %WS_EX_LTRREADING OR %WS_EX_RIGHTSCROLLBAR
  CONTROL ADD LABEL,   hDlg, %IDC_LABEL5, "Label", 225, 435, 100, 10
#PBFORMS END DIALOG

  DIALOG SHOW MODAL hDlg, CALL ShowDIALOG1Proc TO lRslt

#PBFORMS BEGIN CLEANUP %IDD_DIALOG1
#PBFORMS END CLEANUP

  FUNCTION = lRslt
END FUNCTION
'------------------------------------------------------------------------------
