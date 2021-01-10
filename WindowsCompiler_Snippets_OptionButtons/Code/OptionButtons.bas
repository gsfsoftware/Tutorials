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
#RESOURCE "OptionButtons.pbr"
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
%IDD_DIALOG1    =  101
%IDC_OPTION1    = 1001
%IDC_OPTION2    = 1002
%IDC_OPTION3    = 1003
%IDC_OPTION4    = 1004
%IDC_OPTION5    = 1005
%IDC_OPTION6    = 1006
%IDC_BUTTON1    = 1007
%IDC_BUTTON2    = 1008
%IDC_BUTTON3    = 1009
%IDC_BUTTON4    = 1010
%IDC_STATUSBAR1 = 1011
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
  LOCAL strSelection AS STRING
  '
  SELECT CASE AS LONG CB.MSG
    CASE %WM_INITDIALOG
    ' Initialization handler
      PREFIX "Control set option cb.hndl,"
        %IDC_OPTION1,%IDC_OPTION1,%IDC_OPTION3
        %IDC_OPTION4,%IDC_OPTION4,%IDC_OPTION6
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
        ' /* Inserted by PB/Forms 05-24-2020 11:58:47
        CASE %IDC_OPTION1

        CASE %IDC_OPTION2

        CASE %IDC_OPTION3

        CASE %IDC_OPTION4

        CASE %IDC_OPTION5

        CASE %IDC_OPTION6

        CASE %IDC_BUTTON1
          IF CB.CTLMSG = %BN_CLICKED OR CB.CTLMSG = 1 THEN
            CONTROL SET OPTION CB.HNDL,%IDC_OPTION3,%IDC_OPTION1,%IDC_OPTION3
          END IF

        CASE %IDC_BUTTON2
          IF CB.CTLMSG = %BN_CLICKED OR CB.CTLMSG = 1 THEN
          ' read settings
            strSelection = funGetOptionSelected(CB.HNDL, _
                                                %IDC_OPTION1, _
                                                %IDC_OPTION3)
            CONTROL SET TEXT CB.HNDL,%IDC_STATUSBAR1, _
                                      strSelection & " selected"
          '
          END IF

        CASE %IDC_BUTTON3
          IF CB.CTLMSG = %BN_CLICKED OR CB.CTLMSG = 1 THEN
            CONTROL SET OPTION CB.HNDL,%IDC_OPTION4,%IDC_OPTION4,%IDC_OPTION6
          END IF

        CASE %IDC_BUTTON4
          IF CB.CTLMSG = %BN_CLICKED OR CB.CTLMSG = 1 THEN
          ' read settings
            strSelection = funGetOptionSelected(CB.HNDL, _
                                                %IDC_OPTION4, _
                                                %IDC_OPTION6)
            CONTROL SET TEXT CB.HNDL,%IDC_STATUSBAR1, _
                                      strSelection & " selected"
          END IF
        CASE %IDC_STATUSBAR1
        ' */


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

  DIALOG NEW hParent, "Option buttons", 339, 217, 424, 232, %WS_POPUP OR _
    %WS_BORDER OR %WS_DLGFRAME OR %WS_CAPTION OR %WS_SYSMENU OR _
    %WS_MINIMIZEBOX OR %WS_CLIPSIBLINGS OR %WS_VISIBLE OR %DS_MODALFRAME OR _
    %DS_CENTER OR %DS_3DLOOK OR %DS_NOFAILCREATE OR %DS_SETFONT, _
    %WS_EX_CONTROLPARENT OR %WS_EX_LEFT OR %WS_EX_LTRREADING OR _
    %WS_EX_RIGHTSCROLLBAR, TO hDlg
  ' %WS_GROUP...
  CONTROL ADD OPTION,    hDlg, %IDC_OPTION1, "Option1", 65, 60, 100, 10, _
    %WS_CHILD OR %WS_VISIBLE OR %WS_GROUP OR %WS_TABSTOP OR %BS_TEXT OR _
    %BS_AUTORADIOBUTTON OR %BS_LEFT OR %BS_VCENTER, %WS_EX_LEFT OR _
    %WS_EX_LTRREADING
  CONTROL ADD OPTION,    hDlg, %IDC_OPTION2, "Option2", 65, 70, 100, 10
  CONTROL ADD OPTION,    hDlg, %IDC_OPTION3, "Option3", 65, 80, 100, 10
  ' %WS_GROUP...
  CONTROL ADD OPTION,    hDlg, %IDC_OPTION4, "Option4", 240, 60, 100, 10, _
    %WS_CHILD OR %WS_VISIBLE OR %WS_GROUP OR %WS_TABSTOP OR %BS_TEXT OR _
    %BS_AUTORADIOBUTTON OR %BS_LEFT OR %BS_VCENTER, %WS_EX_LEFT OR _
    %WS_EX_LTRREADING
  CONTROL ADD OPTION,    hDlg, %IDC_OPTION5, "Option5", 240, 70, 100, 10
  CONTROL ADD OPTION,    hDlg, %IDC_OPTION6, "Option6", 240, 80, 100, 10
  CONTROL ADD BUTTON,    hDlg, %IDC_BUTTON1, "Set Option 3", 65, 110, 50, 15
  CONTROL ADD BUTTON,    hDlg, %IDC_BUTTON2, "Read option", 65, 135, 50, 15
  CONTROL ADD BUTTON,    hDlg, %IDC_BUTTON3, "Set option 4", 240, 110, 50, 15
  CONTROL ADD BUTTON,    hDlg, %IDC_BUTTON4, "Read option", 240, 135, 50, 15
  CONTROL ADD STATUSBAR, hDlg, %IDC_STATUSBAR1, "", 0, 0, 0, 0
#PBFORMS END DIALOG

  DIALOG SHOW MODAL hDlg, CALL ShowDIALOG1Proc TO lRslt

#PBFORMS BEGIN CLEANUP %IDD_DIALOG1
#PBFORMS END CLEANUP

  FUNCTION = lRslt
END FUNCTION
'------------------------------------------------------------------------------


FUNCTION funGetOptionSelected(hDlg AS DWORD, _
                             lngStart AS LONG, _
                             lngEnd AS LONG) AS STRING
  LOCAL lngR AS LONG
  LOCAL lngState AS LONG
  LOCAL strSelected AS STRING
  '
  FOR lngR = lngStart TO lngEnd
    CONTROL GET CHECK hDlg,lngR TO lngState
    IF lngState = 1 THEN
      CONTROL GET TEXT hDlg, lngR TO strSelected
      FUNCTION = strSelected
      EXIT FUNCTION
    END IF
  NEXT lngR
  '
  FUNCTION = "No Selection"
  '
END FUNCTION
