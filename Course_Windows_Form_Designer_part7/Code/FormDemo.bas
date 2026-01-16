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
#INCLUDE ONCE "PB_Windows_Controls.inc"
#INCLUDE "DateFunctions.inc"
'------------------------------------------------------------------------------
'   ** Constants **
'------------------------------------------------------------------------------
#PBFORMS BEGIN CONSTANTS
%IDD_dlgGetTitle       =  101
%IDC_lblTitle          = 1001
%IDABORT               =    3
%IDC_txtTitle          = 1002
%IDC_lblName           = 1005
%IDC_lblAge            = 1006
%IDC_txtName           = 1003
%IDC_txtAge            = 1004
%IDC_SUBMIT            = 1007
%IDC_lblFeedBack       = 1008
%IDC_lblFeedBackOutput = 1009
%IDC_lblDepartment     = 1012
%IDC_cboDepartment     = 1011
%IDC_lblWorkingPattern = 1015
%IDC_lstWorkingPattern = 1014
%IDC_lblStartDate      = 1017
%IDC_datStartDate      = 1016
%IDR_MENU1             =  102
%IDM_FILE_EXIT         = 1018
%IDM_EDIT_TOGGLETEST   = 1019
%IDC_RICHEDIT1         = 1020
%IDD_dlgProcessing     =  103
%IDC_PROGRESSBAR1      = 1021
%IDC_lblProcessing     = 1022
#PBFORMS END CONSTANTS
'------------------------------------------------------------------------------
%ID_TIMER1    = 2000    ' timers
'
' custom events for the progress bar updates
%Progress_Event     = %WM_USER + 1000
%Progress_Completed = %Progress_Event + 1
'
%TotalThreads = 1
GLOBAL g_idThread() AS LONG     ' array for thread handles
'------------------------------------------------------------------------------
'   ** Declarations **
'------------------------------------------------------------------------------

DECLARE FUNCTION AttachMENU1(BYVAL hDlg AS DWORD) AS DWORD
DECLARE CALLBACK FUNCTION ShowdlgProcessingProc()
DECLARE FUNCTION ShowdlgProcessing(BYVAL hDlg AS DWORD) AS LONG
#PBFORMS DECLARATIONS
'------------------------------------------------------------------------------
GLOBAL g_hFont1 AS DWORD ' used for large fonts
%StarterBuffer = 7       ' number of days buffer for new starters
'
GLOBAL g_hMenu AS DWORD  ' used for menu handle
GLOBAL g_hLib AS DWORD   ' used for library handle
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
   ' set up global array for thread handles
  DIM g_idThread(1 TO %TotalThreads) AS LONG
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
  LOCAL strDepartment AS STRING  ' Department selected
  STATIC strStartDate AS STRING  ' start date for new user
  '
  LOCAL ptnmhdr AS NMHDR PTR            ' information about a notification
  LOCAL ptnmdtc AS NMDATETIMECHANGE PTR ' date time information
  '
  LOCAL lngMenuState AS LONG     ' used to hold state of the toggle menu
  '
  SELECT CASE AS LONG CB.MSG
    CASE %WM_INITDIALOG
    ' Initialization handler
       ' set the font for each control
      PREFIX "CONTROL SET FONT CB.HNDL, "
        %IDC_lblTitle,g_hFont1
        %IDC_lblName,g_hFont1
        %IDC_lblAge,g_hFont1
        %IDC_lblFeedbackOutput,g_hFont1
        %IDC_lblDepartment, g_hFont1
        %IDC_lblWorkingPattern, g_hFont1
        %IDC_lblStartDate, g_hFont1
      END PREFIX
      ' set focus to the first control
      ' you wish user to access
      CONTROL SET FOCUS CB.HNDL,%IDC_txtTitle
      '
      ' populate the departments list
      funPopulateDepartments(CB.HNDL,%IDC_cboDepartment)
      '
      ' populate the working patterns
      funPopulateWorkingPatterns(CB.HNDL,%IDC_LstWorkingPattern)
      '
      ' set the start date
      LOCAL iptDay AS IPOWERTIME
      LET iptDay = CLASS "PowerTime"
      iptDay.Today   ' pick up today as a date
      ' populate static variable with that date
      strStartDate = iptDay.DateString
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
      IF g_hLib <> 0 THEN
        FreeLibrary g_hLib
      END IF
    '
    CASE %WM_NOTIFY
      ptnmhdr = CB.LPARAM
      SELECT CASE @ptnmhdr.idfrom
        CASE %IDC_RichEdit1
        ' handle rich edit control
          SELECT CASE @ptnmhdr.code
            CASE %EN_Link
              FUNCTION = funRichEd_HyperLink_HandleURL _
                        (CB.HNDL,CB.LPARAM,%IDC_RichEdit1)
              EXIT FUNCTION
          END SELECT
        '
        CASE %IDC_datStartDate
          SELECT CASE @ptnmhdr.code
            CASE %DTN_DATETIMECHANGE
              ptnmdtc = CB.LPARAM
              strStartDate = RIGHT$("00" & FORMAT$(@ptnmdtc.st.wDay),2) _
                             & "/" & _
                             RIGHT$("00" & FORMAT$(@ptnmdtc.st.wMonth),2) _
                             & "/" & _
                             FORMAT$(@ptnmdtc.st.wYear)
         END SELECT
      END SELECT
      '
    CASE %WM_SYSCOMMAND
      IF (CB.WPARAM AND &HFFF0) = %SC_CLOSE THEN
        IF MSGBOX("Are you sure you wish to exit?" , _
                  %MB_YESNO,"Exit Application?") = %IDYES THEN
        FUNCTION = 0
          DIALOG END CB.HNDL
        ELSE
          FUNCTION = 1
        END IF
      END IF
      '
    CASE %WM_COMMAND
      ' Process control notifications
      SELECT CASE AS LONG CB.CTL
        CASE %IDM_EDIT_TOGGLETEST
        ' handle toggle test
          IF CB.CTLMSG = %BN_CLICKED OR CB.CTLMSG = 1 THEN
            MENU GET STATE g_hMenu, BYCMD %IDM_EDIT_TOGGLETEST TO _
                           lngMenuState
                           '
            IF lngMenuState = %MFS_CHECKED THEN
            ' if checked then uncheck
              MENU SET STATE g_hMenu, BYCMD %IDM_EDIT_TOGGLETEST, _
                             %MFS_UNCHECKED
            ELSE
            ' otherwise check it
              MENU SET STATE g_hMenu, BYCMD %IDM_EDIT_TOGGLETEST, _
                             %MFS_CHECKED
            END IF
            '
          END IF
        '
        CASE %IDABORT,%IDM_FILE_EXIT
          IF CB.CTLMSG = %BN_CLICKED OR CB.CTLMSG = 1 THEN
            IF MSGBOX("Are you sure you wish to exit?" , _
                  %MB_YESNO,"Exit Application?") = %IDYES THEN
              FUNCTION = 0
              DIALOG END CB.HNDL
            ELSE
              FUNCTION = 1
            END IF
          END IF
          '
        CASE %IDC_cboDepartment
        ' handle events for the Department combobox
          IF CB.CTLMSG = %BN_CLICKED OR CB.CTLMSG = 1 THEN
            ' selection has been made
            CONTROL GET TEXT CB.HNDL,%IDC_cboDepartment TO strDepartment
            '
            IF strDepartment = "HR" THEN
            ' HR selected
            ' so hide the shift options
              PREFIX "control hide cb.hndl,"
                %IDC_lblWorkingPattern
                %IDC_lstWorkingPattern
              END PREFIX
              '
            ELSE
            ' some other department selected
              PREFIX "control normalize cb.hndl,"
                %IDC_lblWorkingPattern
                %IDC_lstWorkingPattern
              END PREFIX
              '
            END IF
            '
          END IF
          '
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
            IF ISTRUE funValidateForm(CB.HNDL, strStartDate) THEN
            ' and confirm to user
              ShowdlgProcessing CB.HNDL
            '
            END IF
          '
          END IF
      END SELECT
  END SELECT
END FUNCTION
'
FUNCTION funPopulateDepartments(hDlg AS DWORD, _
                                lngCombo AS LONG) AS LONG
' populate the departments list
  DIM a_strDepartments(1 TO 5) AS STRING
  'LOCAL lngR AS LONG
  '
  ARRAY ASSIGN a_strDepartments() = "Marketing","Finance", _
                                    "HR","Facilities", _
                                    "IT"
  funPopulateCombo(hDlg,lngCombo,a_strDepartments(),"")
  '
END FUNCTION
'
FUNCTION funPopulateWorkingPatterns(hDlg AS DWORD, _
                                    lnglistbox AS LONG) AS LONG
' populate the working patterns list
  DIM a_strWorkingPatterns(1 TO 3) AS STRING
  '
  ARRAY ASSIGN a_strWorkingPatterns() = "Shift 3", _
                                        "Shift 2", _
                                        "Shift 1"
  '
  funPopulateListBox(hDlg,lnglistbox,a_strWorkingPatterns())
  '
END FUNCTION
'
FUNCTION funPopulateListbox(hDlg AS DWORD, _
                          lnglistbox AS LONG, _
                          BYREF a_strArray() AS STRING) AS LONG
' populate listboxfrom array
  LOCAL lngR AS LONG
  '
  LISTBOX RESET hDlg,lnglistbox
  FOR lngR = 1 TO UBOUND(a_strArray)
    LISTBOX ADD hDlg,lnglistbox,a_strArray(lngR)
  NEXT lngR
'
END FUNCTION
'
'------------------------------------------------------------------------------
FUNCTION funValidateForm(hDlg AS DWORD, _
                         strStartDate AS STRING) AS LONG
' validate the form
  LOCAL strTitle AS STRING    ' title value
  LOCAL strName AS STRING     ' name value
  LOCAL strAge AS STRING      ' age value
  LOCAL strOutput AS STRING   ' output text
  LOCAL strDepartment AS STRING     ' department value
  LOCAL strWorkingPattern AS STRING ' working pattern value
  '
  PREFIX "control get text hDlg,"
    %IDC_txtTitle TO strTitle
    %IDC_txtName TO strName
    %IDC_txtAge TO strAge
    %IDC_cboDepartment TO strDepartment
  END PREFIX
  '
  strWorkingPattern = funGetLBvalues(hDlg,%IDC_LstWorkingPattern)
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
  IF strDepartment = "" THEN
  ' no department picked
    macErrorHighlight(hDlg, _
                      %IDC_lblFeedbackOutput, _
                      "No department picked", _
                      %IDC_lblDepartment, _
                      %IDC_cboDepartment)
    EXIT FUNCTION
  '
  ELSE
    macClearHighlight(hDlg, _
                      %IDC_lblFeedbackOutput, _
                      %IDC_lblDepartment)
  END IF
  '
  ' working pattern does not apply to HR department
  IF strDepartment = "HR" THEN
    strWorkingPattern = "HR Full time"
    macClearHighlight(hDlg, _
                      %IDC_lblFeedbackOutput, _
                      %IDC_lblWorkingPattern)
  ELSE
  ' all other departments
    IF strWorkingPattern = "" THEN
      macErrorHighlight(hDlg, _
                      %IDC_lblFeedbackOutput, _
                      "No working pattern picked", _
                      %IDC_lblWorkingPattern, _
                      %IDC_lstWorkingPattern)
      EXIT FUNCTION
    ELSE
      macClearHighlight(hDlg, _
                      %IDC_lblFeedbackOutput, _
                      %IDC_lblWorkingPattern)
    END IF
  '
  END IF
  '
  ' check the start date
  ' is start date before today?
  LOCAL strError AS STRING    ' error msg to show to user
  LOCAL lngError AS LONG      ' true/false for error
  LOCAL strNewDate AS STRING  ' start date plus starter buffer
  ' add days to UK format date
  strNewDate = funAddDays(funUKdate, %StarterBuffer,"UK")
  '
  IF funDateNumberUK(strStartDate) < funDateNumberUK(funUKdate) THEN
  ' start date is in the past
    strError = "Start date is in the past"
    lngError = %TRUE
  ELSEIF funDateNumberUK(strStartDate) < _
          funDateNumberUK(strNewDate) THEN
  ' start date is less than 7 days away
    strError = "Start date is less than 7 days away"
    lngError = %TRUE
  END IF
  '
  IF ISTRUE lngError THEN
    macErrorHighlight(hDlg, _
                        %IDC_lblFeedbackOutput, _
                        strError, _
                        %IDC_lblStartDate, _
                        %IDC_datStartDate)
    EXIT FUNCTION
  ELSE
    macClearHighlight(hDlg, _
                        %IDC_lblFeedbackOutput, _
                        %IDC_lblStartDate)
  '
  END IF
  ' all tests pass - validate data to user
  strOutput = TRIM$(strTitle) & " " & TRIM$(strName) & $CRLF & _
             "Age = " & strAge & $CRLF & _
             "Department = " & strDepartment & $CRLF & _
             "Working pattern = " & strWorkingPattern & $CRLF & _
             "Start Date = " & strStartDate
             '
  CONTROL SET TEXT hDlg, %IDC_lblFeedbackOutput, strOutput
  FUNCTION = %TRUE
  '
END FUNCTION
'
FUNCTION funGetLBvalues(hDlg AS DWORD, _
                        lngListBox AS LONG) AS STRING
' return all selected values in a listbox
  LOCAL lngCountSelected AS LONG    ' number of items selected
  LOCAL lngItemSelected AS LONG     ' item number of selected
  LOCAL strListOfSelected AS STRING ' string of selected items
  LOCAL strText AS STRING           ' text on selected item
  '
  LISTBOX GET SELCOUNT hDlg, lngListBox TO lngCountSelected
  '
  IF lngCountSelected = 0 THEN
  ' nothing selected
    FUNCTION = ""
  ELSE
    LISTBOX GET SELECT hDlg, lngListBox ,1 TO lngItemSelected
    WHILE lngItemSelected > 0
      LISTBOX GET TEXT hDlg, lngListBox ,lngItemSelected _
                             TO strText
      ' add on to the running list
      strListOfSelected = strListOfSelected & strText & ","
      INCR lngItemSelected
      LISTBOX GET SELECT hDlg, lngListBox ,lngItemSelected _
                               TO lngItemSelected
    WEND
    ' trim off last comma
    strListOfSelected = RTRIM$(strListOfSelected,",")
    FUNCTION = strListOfSelected
    '
  END IF
  '
END FUNCTION
'
MACRO macClearHighlight(hDlg,lngFeedbackOutput, _
                        lngLabel)
  CONTROL SET COLOR hDlg,lngLabel, %BLUE,-1
  CONTROL REDRAW hDlg,lngLabel
  CONTROL SET TEXT hDlg,lngFeedbackOutput,""
  CONTROL REDRAW hDlg,lngFeedbackOutput
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
  LOCAL lngOffset AS LONG

#PBFORMS BEGIN DIALOG %IDD_dlgGetTitle->%IDR_MENU1->
  LOCAL hDlg  AS DWORD

  DIALOG NEW hParent, "Enter the Title", 286, 122, 653, 352, %WS_POPUP OR _
    %WS_BORDER OR %WS_DLGFRAME OR %WS_CAPTION OR %WS_SYSMENU OR _
    %WS_MINIMIZEBOX OR %WS_MAXIMIZEBOX OR %WS_CLIPSIBLINGS OR %WS_VISIBLE OR _
    %DS_MODALFRAME OR %DS_CENTER OR %DS_3DLOOK OR %DS_NOFAILCREATE OR _
    %DS_SETFONT, %WS_EX_CONTROLPARENT OR %WS_EX_LEFT OR %WS_EX_LTRREADING OR _
    %WS_EX_RIGHTSCROLLBAR, TO hDlg
  CONTROL ADD TEXTBOX,  hDlg, %IDC_txtTitle, "", 45, 50, 165, 15
  CONTROL ADD TEXTBOX,  hDlg, %IDC_txtName, "", 45, 95, 165, 15
  CONTROL ADD TEXTBOX,  hDlg, %IDC_txtAge, "", 45, 135, 50, 15, %WS_CHILD OR _
    %WS_VISIBLE OR %WS_TABSTOP OR %ES_CENTER OR %ES_AUTOHSCROLL OR _
    %ES_NUMBER, %WS_EX_CLIENTEDGE OR %WS_EX_LEFT OR %WS_EX_LTRREADING OR _
    %WS_EX_RIGHTSCROLLBAR
  CONTROL ADD COMBOBOX, hDlg, %IDC_cboDepartment, , 45, 175, 160, 40, _
    %WS_CHILD OR %WS_VISIBLE OR %WS_TABSTOP OR %CBS_DROPDOWNLIST OR _
    %CBS_SORT, %WS_EX_LEFT OR %WS_EX_LTRREADING OR %WS_EX_RIGHTSCROLLBAR
  CONTROL ADD LISTBOX,  hDlg, %IDC_lstWorkingPattern, , 45, 210, 100, 50, _
    %WS_CHILD OR %WS_VISIBLE OR %WS_TABSTOP OR %WS_VSCROLL OR _
    %LBS_MULTIPLESEL OR %LBS_SORT OR %LBS_NOTIFY, %WS_EX_CLIENTEDGE OR _
    %WS_EX_LEFT OR %WS_EX_LTRREADING OR %WS_EX_RIGHTSCROLLBAR
  CONTROL ADD "SysDateTimePick32", hDlg, %IDC_datStartDate, _
    "SysDateTimePick32_1", 240, 51, 100, 13, %WS_CHILD OR %WS_VISIBLE OR _
    %WS_TABSTOP OR %DTS_SHORTDATEFORMAT, %WS_EX_CLIENTEDGE OR %WS_EX_LEFT OR _
    %WS_EX_LTRREADING OR %WS_EX_RIGHTSCROLLBAR
  CONTROL ADD BUTTON,   hDlg, %IDC_SUBMIT, "Submit", 255, 250, 50, 15
  CONTROL ADD BUTTON,   hDlg, %IDABORT, "Exit", 595, 250, 50, 15
  CONTROL ADD LABEL,    hDlg, %IDC_lblTitle, "Title goes here", 45, 35, 165, _
    15
  CONTROL SET COLOR     hDlg, %IDC_lblTitle, %BLUE, -1
  CONTROL ADD LABEL,    hDlg, %IDC_lblName, "Name goes here", 45, 80, 165, 15
  CONTROL SET COLOR     hDlg, %IDC_lblName, %BLUE, -1
  CONTROL ADD LABEL,    hDlg, %IDC_lblAge, "Age goes here", 45, 120, 165, 15
  CONTROL SET COLOR     hDlg, %IDC_lblAge, %BLUE, -1
  CONTROL ADD LABEL,    hDlg, %IDC_lblFeedBackOutput, "", 430, 50, 200, 160, _
    %WS_CHILD OR %WS_VISIBLE OR %SS_LEFT, %WS_EX_CLIENTEDGE OR %WS_EX_LEFT _
    OR %WS_EX_LTRREADING
  CONTROL ADD LABEL,    hDlg, %IDC_lblFeedBack, "Form Feedback", 430, 35, _
    165, 15
  CONTROL SET COLOR     hDlg, %IDC_lblFeedBack, %BLUE, -1
  CONTROL ADD LABEL,    hDlg, %IDC_lblDepartment, "Department goes here", 45, _
    160, 165, 15
  CONTROL SET COLOR     hDlg, %IDC_lblDepartment, %BLUE, -1
  CONTROL ADD LABEL,    hDlg, %IDC_lblWorkingPattern, "Working Pattern goes " + _
    "here", 45, 195, 165, 15
  CONTROL SET COLOR     hDlg, %IDC_lblWorkingPattern, %BLUE, -1
  CONTROL ADD LABEL,    hDlg, %IDC_lblStartDate, "Start Date goes here", 240, _
    37, 165, 15
  CONTROL SET COLOR     hDlg, %IDC_lblStartDate, %BLUE, -1

  AttachMENU1 hDlg
#PBFORMS END DIALOG
  '
  ' your code goes here
  g_hLib = LoadLibrary("riched20.dll") :InitCommonControls
  IF g_hLib = 0 THEN
  ' cannot load the library
    MSGBOX "Unable to load the Richedit library", _
            %MB_ICONERROR OR %MB_TASKMODAL
  END IF
  '
  CONTROL ADD "RichEdit20A", hDlg, %IDC_RICHEDIT1, "RichEdit1", 45, 10, _
    585, 15, %WS_CHILD OR %WS_VISIBLE OR %ES_LEFT OR %ES_READONLY, _
    %WS_EX_LEFT OR %WS_EX_LTRREADING OR %WS_EX_RIGHTSCROLLBAR
    '
  ' set the background color
  CONTROL SEND hDlg,%IDC_Richedit1, %EM_SETBKGNDCOLOR, 0, _
               RGB(239,239,239)
               '
   ' auto detect the URL
  CONTROL SEND hDlg,%IDC_Richedit1, %EM_AutoUrlDetect, %TRUE,0
  '
   ' get ready to handle events
  CONTROL SEND hDlg,%IDC_Richedit1, %EM_SETEventMask,0,%ENM_LINK
  '
  ' populate the text in the rich edit control
  CONTROL SET TEXT hDlg,%IDC_Richedit1,"To view all projects " & _
    "available click on " & _
    "our website link " & _
    "https:/www.gsfsoftware.co.uk/PBTutorials/Projects.htm " & _
    "or Phone Ext 1234 for more details"
    '
  ' set the colours of text within the rich edit control
  lngOffset = 1        ' set offset to begining of text
  funSetRTcolour(hDlg,%IDC_Richedit1,"Phone Ext 1234", _
                 %RED, lngOffset)
                 '
  funSetRTcolour(hDlg,%IDC_Richedit1,"details", _
                 %RGB_FORESTGREEN, lngOffset)
  '
  DIALOG SHOW MODAL hDlg, CALL ShowTitleProc TO lRslt

#PBFORMS BEGIN CLEANUP %IDD_dlgGetTitle
#PBFORMS END CLEANUP

  FUNCTION = lRslt
END FUNCTION
'------------------------------------------------------------------------------
'------------------------------------------------------------------------------
FUNCTION AttachMENU1(BYVAL hDlg AS DWORD) AS DWORD
#PBFORMS BEGIN MENU %IDR_MENU1->%IDD_dlgGetTitle
  LOCAL hMenu   AS DWORD
  LOCAL hPopUp1 AS DWORD

  MENU NEW BAR TO hMenu
  MENU NEW POPUP TO hPopUp1
  MENU ADD POPUP, hMenu, "File", hPopUp1, %MF_ENABLED
    MENU ADD STRING, hPopUp1, "Exit", %IDM_FILE_EXIT, %MF_ENABLED
  MENU NEW POPUP TO hPopUp1
  MENU ADD POPUP, hMenu, "Edit", hPopUp1, %MF_ENABLED
    MENU ADD STRING, hPopUp1, "ToggleTest", %IDM_EDIT_TOGGLETEST, %MF_CHECKED

  MENU ATTACH hMenu, hDlg
#PBFORMS END MENU
  g_hMenu = hMenu
  FUNCTION = hMenu
END FUNCTION
'------------------------------------------------------------------------------
'------------------------------------------------------------------------------
CALLBACK FUNCTION ShowdlgProcessingProc()
  LOCAL lngPosition AS LONG ' value in progress bar
  LOCAL lngStatus AS LONG   ' value of the status when thread closed
  '
  SELECT CASE AS LONG CB.MSG
    CASE %WM_INITDIALOG
    ' Initialization handler
      PREFIX "CONTROL SET FONT CB.HNDL, "
        %IDC_lblProcessing, g_hFont1
      END PREFIX
      '
      CONTROL SET TEXT CB.HNDL,%IDC_lblProcessing,"Started Processing"
      '
       ' set the range of the progress bar
      ' default is 0->100
      PROGRESSBAR SET RANGE CB.HNDL, %IDC_PROGRESSBAR1, 0, 100
      '
        ' set the step. The default is 10
      PROGRESSBAR SET STEP CB.HNDL, %IDC_PROGRESSBAR1, 10
      '
      ' Create WM_TIMER events with the SetTimer API
      ' to trigger after 500ms
      SetTimer(CB.HNDL, %ID_TIMER1, _
               500, BYVAL %NULL)
               '
     CASE %Progress_Event
     ' advance the progress bar
       PROGRESSBAR SET POS CB.HNDL, %IDC_PROGRESSBAR1, CB.WPARAM
       '
     CASE %Progress_Completed
     ' thread has completed
      THREAD CLOSE g_idThread(1) TO lngStatus
      DIALOG REDRAW CB.HNDL
      '
      SLEEP 1000
      DIALOG END CB.HNDL
      '
    CASE %WM_TIMER
      SELECT CASE CB.WPARAM
        CASE %ID_TIMER1
        ' timer 1 is the clock - close it now
          KillTimer(CB.HNDL, %ID_TIMER1)
          ' start the thread
          THREAD CREATE funStartThreadProcessing(BYVAL CB.HNDL) _
                    TO g_idThread(1)
          '
      END SELECT
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
        CASE %IDC_PROGRESSBAR1

      END SELECT
  END SELECT
END FUNCTION
'------------------------------------------------------------------------------

THREAD FUNCTION funStartThreadProcessing(BYVAL hDlg AS DWORD) AS DWORD
' start the thread
  LOCAL lngPercent AS LONG
  '
  FOR lngPercent = 1 TO 100 STEP 10
    DIALOG POST hDlg, %Progress_Event,lngPercent,0
    ' wait a bit to simulate processing
    SLEEP 500
  NEXT lngPercent
  '
  ' thread ending
  DIALOG POST hDlg, %Progress_Event,100,0
  DIALOG POST hDlg, %Progress_Completed,0,0
  '
END FUNCTION
'------------------------------------------------------------------------------
FUNCTION ShowdlgProcessing(BYVAL hParent AS DWORD) AS LONG
  LOCAL lRslt AS LONG

#PBFORMS BEGIN DIALOG %IDD_dlgProcessing->->
  LOCAL hDlg  AS DWORD

  DIALOG NEW hParent, "Processing Progress", 344, 229, 547, 175, %WS_POPUP OR _
    %WS_BORDER OR %WS_DLGFRAME OR %WS_CAPTION OR %WS_SYSMENU OR _
    %WS_CLIPSIBLINGS OR %WS_VISIBLE OR %DS_MODALFRAME OR %DS_CENTER OR _
    %DS_3DLOOK OR %DS_NOFAILCREATE OR %DS_SETFONT, %WS_EX_CONTROLPARENT OR _
    %WS_EX_LEFT OR %WS_EX_LTRREADING OR %WS_EX_RIGHTSCROLLBAR, TO hDlg
  CONTROL ADD PROGRESSBAR, hDlg, %IDC_PROGRESSBAR1, "ProgressBar1", 15, 120, _
    510, 25
  CONTROL ADD LABEL,       hDlg, %IDC_lblProcessing, "", 15, 70, 510, 40
  CONTROL SET COLOR        hDlg, %IDC_lblProcessing, %BLUE, -1
#PBFORMS END DIALOG

  DIALOG SHOW MODAL hDlg, CALL ShowdlgProcessingProc TO lRslt

#PBFORMS BEGIN CLEANUP %IDD_dlgProcessing
#PBFORMS END CLEANUP

  FUNCTION = lRslt
END FUNCTION
'------------------------------------------------------------------------------
