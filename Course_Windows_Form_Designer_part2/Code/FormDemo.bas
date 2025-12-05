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
%IDD_dlgGetTitle =  101
%IDC_lblTitle    = 1001
%IDABORT         =    3
%IDC_txtTitle    = 1002
%IDC_lblName     = 1005
%IDC_lblAge      = 1006
%IDC_txtName     = 1003
%IDC_txtAge      = 1004
%IDC_SUBMIT            = 1007
%IDC_lblFeedBack       = 1008
%IDC_lblFeedBackOutput = 1009
#PBFORMS END CONSTANTS
'------------------------------------------------------------------------------

'------------------------------------------------------------------------------
'   ** Declarations **
'------------------------------------------------------------------------------

#PBFORMS DECLARATIONS
'------------------------------------------------------------------------------
GLOBAL g_hFont1 AS DWORD ' used for large fonts
'------------------------------------------------------------------------------
'   ** Main Application Entry Point **
'------------------------------------------------------------------------------
FUNCTION PBMAIN()
  PBFormsInitComCtls (%ICC_WIN95_CLASSES OR %ICC_DATE_CLASSES OR _
    %ICC_INTERNET_CLASSES)
   ' set up global font for large text
  FONT NEW "MS Sans Serif", 18, 0, %ANSI_CHARSET TO g_hFont1
  DIALOG DEFAULT FONT "MS Sans Serif", 10, 0, %ANSI_CHARSET
  '
  ShowTitle %HWND_DESKTOP
  '
  FONT END g_hFont1
  '
END FUNCTION
'------------------------------------------------------------------------------

'------------------------------------------------------------------------------
'   ** CallBacks **
'------------------------------------------------------------------------------
CALLBACK FUNCTION ShowTitleProc()

  SELECT CASE AS LONG CB.MSG
    CASE %WM_INITDIALOG
    ' Initialization handler
       ' set the font for each control
      PREFIX "CONTROL SET FONT CB.HNDL, "
        %IDC_lblTitle,g_hFont1
        %IDC_lblName,g_hFont1
        %IDC_lblAge,g_hFont1
        %IDC_lblFeedbackOutput,g_hFont1
      END PREFIX
      ' set focus to the first control
      ' you wish user to access
      CONTROL SET FOCUS CB.HNDL,%IDC_txtTitle
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
        CASE %IDABORT
          IF CB.CTLMSG = %BN_CLICKED OR CB.CTLMSG = 1 THEN
            DIALOG END CB.HNDL
          END IF

        CASE %IDC_txtTitle
        '
        CASE %IDC_txtAge
        ' events for Age field
          SELECT CASE CB.CTLMSG
            CASE %EN_SETFOCUS
            ' field has focus so preselect the field
              CONTROL SEND CB.HNDL, %IDC_txtAge, %EM_SetSel, 0, -1
          END SELECT
          '
        CASE %IDC_Submit
          IF CB.CTLMSG = %BN_CLICKED OR CB.CTLMSG = 1 THEN
          ' submit button has been pressed
          ' so validate input
            IF ISTRUE funValidateForm(CB.HNDL) THEN
            ' and confirm to user
            '
            END IF
          '
          END IF
      END SELECT
  END SELECT
END FUNCTION
'------------------------------------------------------------------------------
FUNCTION funValidateForm(hDlg AS DWORD) AS LONG
' validate the form
  LOCAL strTitle AS STRING    ' title value
  LOCAL strName AS STRING     ' name value
  LOCAL strAge AS STRING      ' age value
  LOCAL strOutput AS STRING   ' output text
  '
  PREFIX "control get text hDlg,"
    %IDC_txtTitle TO strTitle
    %IDC_txtName TO strName
    %IDC_txtAge TO strAge
  END PREFIX
  '
  IF TRIM$(strTitle) = "" THEN
  ' no title
  ' highlight an error
    macErrorHighlight(hDlg,%IDC_lblFeedbackOutput, _
                      "No Title entered", %IDC_lblTitle, _
                      %IDC_txtTitle)
    EXIT FUNCTION
  ELSE
  ' clear any error
    macClearHighlight(hDlg,%IDC_lblFeedbackOutput, _
                      %IDC_lblTitle)
  END IF
  '
  IF TRIM$(strName) = "" THEN
  ' no name
    macErrorHighlight(hDlg,%IDC_lblFeedbackOutput, _
                      "No Name entered", %IDC_lblName, _
                      %IDC_txtName)
    EXIT FUNCTION
  ELSE
    ' clear any error
    macClearHighlight(hDlg,%IDC_lblFeedbackOutput, _
                      %IDC_lblName)
  END IF
  '
  IF VAL(strAge) > 99 OR VAL(strAge) < 18 THEN
  ' invalid age
    macErrorHighlight(hDlg, _
                      %IDC_lblFeedbackOutput, _
                      "Age is too young, old or missing", _
                      %IDC_lblAge, _
                      %IDC_txtAge)
    EXIT FUNCTION
    '
  ELSE
    macClearHighlight(hDlg, _
                      %IDC_lblFeedbackOutput, _
                      %IDC_lblAge)
  END IF
  '
  ' all tests pass - validate data to user
  strOutput = TRIM$(strTitle) & " " & TRIM$(strName) & $CRLF & _
             "Age = " & strAge
             '
  CONTROL SET TEXT hDlg, %IDC_lblFeedbackOutput, strOutput
  FUNCTION = %TRUE
  '
END FUNCTION
'
MACRO macClearHighlight(hDlg,lngFeedbackOutput, _
                        lngLabel)
  CONTROL SET COLOR hDlg,lngLabel, %BLUE,-1
  CONTROL REDRAW hDlg,lngLabel
  CONTROL SET TEXT hDlg,lngFeedbackOutput,""
END MACRO
'
MACRO macErrorHighlight(hDlg,lngFeedbackOutput, _
                        strText, lngLabel, _
                        lngText)
   CONTROL SET TEXT hDlg,lngFeedbackOutput,strText
   CONTROL SET COLOR hDlg,lngLabel, %RED,-1
   CONTROL REDRAW hDlg,lngLabel
   CONTROL SET FOCUS hDlg,lngText
END MACRO
'------------------------------------------------------------------------------
'   ** Dialogs **
'------------------------------------------------------------------------------
FUNCTION ShowTitle(BYVAL hParent AS DWORD) AS LONG
  LOCAL lRslt  AS LONG

#PBFORMS BEGIN DIALOG %IDD_dlgGetTitle->->
  LOCAL hDlg  AS DWORD

  DIALOG NEW hParent, "Enter the Title", 286, 172, 653, 278, %WS_POPUP OR _
    %WS_BORDER OR %WS_DLGFRAME OR %WS_CAPTION OR %WS_SYSMENU OR _
    %WS_MINIMIZEBOX OR %WS_MAXIMIZEBOX OR %WS_CLIPSIBLINGS OR %WS_VISIBLE OR _
    %DS_MODALFRAME OR %DS_CENTER OR %DS_3DLOOK OR %DS_NOFAILCREATE OR _
    %DS_SETFONT, %WS_EX_CONTROLPARENT OR %WS_EX_LEFT OR %WS_EX_LTRREADING OR _
    %WS_EX_RIGHTSCROLLBAR, TO hDlg
  CONTROL ADD LABEL,   hDlg, %IDC_lblTitle, "Title goes here", 45, 35, 165, _
    15
  CONTROL SET COLOR    hDlg, %IDC_lblTitle, %BLUE, -1
  CONTROL ADD BUTTON,  hDlg, %IDABORT, "Exit", 595, 250, 50, 15
  CONTROL ADD TEXTBOX, hDlg, %IDC_txtTitle, "", 45, 50, 165, 15
  CONTROL ADD TEXTBOX, hDlg, %IDC_txtName, "", 45, 95, 165, 15
  CONTROL ADD LABEL,   hDlg, %IDC_lblName, "Name goes here", 45, 80, 165, 15
  CONTROL SET COLOR    hDlg, %IDC_lblName, %BLUE, -1
  CONTROL ADD TEXTBOX, hDlg, %IDC_txtAge, "", 45, 135, 50, 15, %WS_CHILD OR _
    %WS_VISIBLE OR %WS_TABSTOP OR %ES_CENTER OR %ES_AUTOHSCROLL OR _
    %ES_NUMBER, %WS_EX_CLIENTEDGE OR %WS_EX_LEFT OR %WS_EX_LTRREADING OR _
    %WS_EX_RIGHTSCROLLBAR
  CONTROL ADD LABEL,   hDlg, %IDC_lblAge, "Age goes here", 45, 120, 165, 15
  CONTROL SET COLOR    hDlg, %IDC_lblAge, %BLUE, -1
  CONTROL ADD BUTTON,  hDlg, %IDC_SUBMIT, "Submit", 160, 165, 50, 15
  CONTROL ADD LABEL,   hDlg, %IDC_lblFeedBackOutput, "", 325, 50, 265, 160, _
    %WS_CHILD OR %WS_VISIBLE OR %SS_LEFT, %WS_EX_CLIENTEDGE OR %WS_EX_LEFT _
    OR %WS_EX_LTRREADING
  CONTROL ADD LABEL,   hDlg, %IDC_lblFeedBack, "Form Feedback", 325, 35, 165, _
    15
  CONTROL SET COLOR    hDlg, %IDC_lblFeedBack, %BLUE, -1
#PBFORMS END DIALOG
  '
  ' your code goes here
  '
  DIALOG SHOW MODAL hDlg, CALL ShowTitleProc TO lRslt

#PBFORMS BEGIN CLEANUP %IDD_dlgGetTitle
#PBFORMS END CLEANUP

  FUNCTION = lRslt
END FUNCTION
'------------------------------------------------------------------------------
