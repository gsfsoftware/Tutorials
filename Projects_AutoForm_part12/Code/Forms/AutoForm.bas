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
' functions that need amended when you add a new control
' or a new feature
'
' funFillFormWithRecord
' funGetFormData
' funPopulateForm
' funResetForm
' funValidateForm
'
#COMPILE EXE
#DIM ALL
'
'------------------------------------------------------------------------------
'   ** Includes **
'------------------------------------------------------------------------------
#PBFORMS BEGIN INCLUDES
#RESOURCE "AutoForm.pbr"
%USEMACROS = 1
#INCLUDE ONCE "WIN32API.INC"
#INCLUDE ONCE "COMMCTRL.INC"
#INCLUDE ONCE "PBForms.INC"
#PBFORMS END INCLUDES
#INCLUDE ONCE "richedit.inc"
'------------------------------------------------------------------------------
#INCLUDE "PB_Common_Strings.inc"
#INCLUDE "PB_FileHandlingRoutines.inc"
#INCLUDE "Tooltips.inc"
#INCLUDE "PB_Windows_Controls.inc"
'
%MLGSLL = 1             ' set to use MLG as a SLL
#INCLUDE "MLG.INC"      ' include MLG library
#LINK "MLG.SLL"         ' link to SSL
'
' MLG Lite Utilities
#INCLUDE "MLG_Lite_Utilities.inc"
'
' one constant for each grid
%IDC_MLGGRID1   = 3000  ' dialog control handle for grid

' one global per grid in your application
GLOBAL hGrid1 AS LONG  ' Windows handle for grid
GLOBAL g_hLib AS DWORD ' handle for rich edit library
'------------------------------------------------------------------------------
'   ** Constants **
'------------------------------------------------------------------------------
#PBFORMS BEGIN CONSTANTS
%IDD_dlgMain       =  101
%IDC_STATUSBAR1    = 1001
%IDC_lblStatus     = 1002
%IDC_btnBack       = 1004
%IDC_btnNext       = 1003
%IDC_btnFirst      = 1005
%IDC_btnLast       = 1006
%IDC_lblFormNumber = 1007
%IDC_btnNew        = 1008
%IDC_btnGrid       = 1009
%IDD_dlgViewForms  =  102
#PBFORMS END CONSTANTS
%IDR_APPICON    = 1800
%IDR_IMGBack    = 1801
%IDR_IMGNext    = 1802
%IDR_IMGFirst   = 1803
%IDR_IMGLast    = 1804
%IDR_IMGNew     = 1805
%IDR_IMGGrid    = 1806
%IDR_IMGCancel  = 1807

'------------------------------------------------------------------------------
ENUM Refs SINGULAR
  Ref_Object = 1
  Ref_Text
  Ref_X
  Ref_Y
  Ref_Width
  Ref_Height
  Ref_ID
  Ref_Function
  Ref_Fieldname
  Ref_Mandatory
  Ref_CharLimit
  Ref_Tooltips
  Ref_DefaultValue
  Ref_Conditional
  Ref_Selection
END ENUM
'
#RESOURCE ICON, 1800,"Reports.ico"
#RESOURCE ICON, 1801,"BackButton2.ico"
#RESOURCE ICON, 1802,"NextButton2.ico"
#RESOURCE ICON, 1803,"FirstButton.ico"
#RESOURCE ICON, 1804,"LastButton.ico"
#RESOURCE ICON, 1805,"Add.ico"
#RESOURCE ICON, 1806,"Grid.ico"
#RESOURCE ICON, 1807,"16_CANCEL.ico"
'
#INCLUDE ONCE "ButtonPlus.bas"
'
'------------------------------------------------------------------------------
'   ** Declarations **
'------------------------------------------------------------------------------
DECLARE CALLBACK FUNCTION ShowdlgMainProc()
DECLARE FUNCTION ShowdlgMain(BYVAL hParent AS DWORD) AS LONG
DECLARE CALLBACK FUNCTION ShowdlgViewFormsProc()
DECLARE FUNCTION ShowdlgViewForms(BYVAL hDlg AS DWORD) AS LONG
#PBFORMS DECLARATIONS
'------------------------------------------------------------------------------
GLOBAL ga_strConfig() AS STRING    ' the configuration file
GLOBAL g_hDlg AS DWORD             ' global for the current form
'
GLOBAL g_strConfigFolder AS STRING ' the folder holding the config data
'
GLOBAL g_lngFormNumber AS LONG   ' holds current form number
GLOBAL g_strFormData() AS STRING ' holds details of all forms
'
'------------------------------------------------------------------------------
'   ** Main Application Entry Point **
'------------------------------------------------------------------------------
FUNCTION PBMAIN()
  LOCAL strConfigFile AS STRING
  '
  PBFormsInitComCtls (%ICC_WIN95_CLASSES OR %ICC_DATE_CLASSES OR _
    %ICC_INTERNET_CLASSES)
  '
  MLG_Init  ' initialise the grid control
  '
  strConfigFile = EXE.PATH$ & COMMAND$
  '
  IF ISFALSE ISFILE(strConfigFile) THEN
  ' no config file?
    MSGBOX "No specified configuration file", _
           %MB_ICONERROR OR %MB_TASKMODAL,"Config Error"
    EXIT FUNCTION
  '
  ELSE
  ' store path to config folder
    g_strConfigFolder = funStartRangeParse(strConfigFile, _
                        "\", PARSECOUNT(strConfigFile,"\")-1) & "\"
  '
  END IF
  '
  ' load the config file
  funReadTheFileIntoAnArray(strConfigFile,ga_strConfig())
  '
  IF ISTRUE funPopulateTheFormArray() THEN ' file the form array with form data
  ' set the current form number to the end of the array
    g_lngFormNumber = UBOUND(g_strFormData)
    ' is last record blank?
    IF g_strFormData(g_lngFormNumber) <> "" THEN
    ' add a blank record to the end of the array - if needed
      INCR g_lngFormNumber
      REDIM PRESERVE g_strFormData(g_lngFormNumber)
    END IF
  ELSE
  ' output form not created yet
    funCreateOutputFormData()
  '
  END IF
  '
  ' set a default font for this application
  DIALOG DEFAULT FONT "MS Sans Serif", 14, 0, %ANSI_CHARSET
  '
  ShowdlgMain %HWND_DESKTOP
END FUNCTION
'
FUNCTION funCreateOutputFormData() AS LONG
' create a blank output form
  LOCAL strOutput AS STRING
  LOCAL strHeaders AS STRING
  '
  ' get the output file name
  strOutput = EXE.PATH$ & funReturnSaveFileValue()
  '
  strHeaders = funGetColumnNames()
  '
  REDIM g_strFormData(1) AS STRING
  g_strFormData(0) = LTRIM$(funEndRangeParse(strHeaders,",",2),",")
  '
  FUNCTION = funArrayDump(strOutput,BYREF g_strFormData(),%TRUE )
'
END FUNCTION
'------------------------------------------------------------------------------
FUNCTION funPopulateTheFormArray() AS LONG
' fill the form array with form data
  LOCAL strInput AS STRING
  g_lngFormNumber = 1
  '
  ' find the filename in the config file
  ' get the input file name
  strInput = EXE.PATH$ & funReturnSaveFileValue()
  '
  IF ISTRUE ISFILE(strInput) THEN
  ' file has been found
    FUNCTION = funReadTheFileIntoAnArray(strInput,g_strFormData())
  '
  ELSE
    FUNCTION = %FALSE
  END IF
'
END FUNCTION
'
FUNCTION funReturnSaveFileValue() AS STRING
' find the button whose function is SAVE and
' return the value in the Fieldname column
  LOCAL lngR AS LONG
  LOCAL lngObjectColumn AS LONG
  LOCAL lngFieldNameColumn AS LONG
  LOCAL lngFunctionColumn AS LONG
  '
  lngObjectColumn = funParseFind(ga_strConfig(0),"", "Object")
  lngFunctionColumn = funParseFind(ga_strConfig(0),"", "function")
  lngFieldNameColumn = funParseFind(ga_strConfig(0),"", "Fieldname")
  '
  FOR lngR = 1 TO UBOUND(ga_strConfig)
    IF PARSE$(ga_strConfig(lngR),"",lngObjectColumn) = "Button" AND _
       PARSE$(ga_strConfig(lngR),"",lngFunctionColumn) = "SAVE" THEN
      ' found the data line - so return the string in Fieldname column
      FUNCTION = PARSE$(ga_strConfig(lngR),"",lngFieldNameColumn)
      EXIT FUNCTION
    END IF
  NEXT lngR
  ' no entry found
  FUNCTION = "No_File"
  '
END FUNCTION
'
'------------------------------------------------------------------------------
'   ** CallBacks **
'------------------------------------------------------------------------------
CALLBACK FUNCTION ShowdlgMainProc()

  SELECT CASE AS LONG CB.MSG
    CASE %WM_INITDIALOG
      ' Initialization handler
      funPopulateForm()  ' populate the form from the config
      '
      funFillFormWithRecord(CB.HNDL,%IDC_lblFormNumber, g_lngFormNumber)
      '
      CALL ToolTip_SetToolTip (GetDlgItem(CB.HNDL,%IDC_btnGrid), _
                                "View all forms", _
                                %YELLOW, _
                                %BLACK)
                                '
      CALL ToolTip_SetToolTip (GetDlgItem(CB.HNDL,%IDC_btnBack), _
                                "Previous Form", _
                                %YELLOW, _
                                %BLACK)
                                '
      CALL ToolTip_SetToolTip (GetDlgItem(CB.HNDL,%IDC_btnNext), _
                                "Next Form", _
                                %YELLOW, _
                                %BLACK)
                                '
      CALL ToolTip_SetToolTip (GetDlgItem(CB.HNDL,%IDC_btnFirst), _
                                "First Form", _
                                %YELLOW, _
                                %BLACK)
                                '
      CALL ToolTip_SetToolTip (GetDlgItem(CB.HNDL,%IDC_btnLast), _
                                "Last Form", _
                                %YELLOW, _
                                %BLACK)
                                '
      CALL ToolTip_SetToolTip (GetDlgItem(CB.HNDL,%IDC_btnNew), _
                                "New Form", _
                                %YELLOW, _
                                %BLACK)
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
     CASE %WM_NOTIFY
    ' process notifications
      funRunNotifyProcesses(CB.HNDL,CB.CTL,CB.LPARAM)
      '
    CASE %WM_COMMAND
      ' Process control notifications
      funRunControlProcess(CB.HNDL,CB.CTL,CB.CTLMSG)
      '
      SELECT CASE AS LONG CB.CTL
        ' /* Inserted by PB/Forms 12-04-2023 19:27:54
        CASE %IDC_btnGrid
          IF CB.CTLMSG = %BN_CLICKED OR CB.CTLMSG = 1 THEN
            ' show all the forms on a grid
            ShowDlgViewForms CB.HNDL
          END IF
        ' */

        CASE %IDC_STATUSBAR1
          '
        CASE %IDC_btnNew
          IF CB.CTLMSG = %BN_CLICKED OR CB.CTLMSG = 1 THEN
            g_lngFormNumber = UBOUND(g_strFormData) +1
            REDIM PRESERVE g_strFormData(g_lngFormNumber)
            funFillFormWithRecord(CB.HNDL, _
                                  %IDC_lblFormNumber, _
                                  g_lngFormNumber)
          END IF
          '
          CASE %IDC_btnFirst
            IF CB.CTLMSG = %BN_CLICKED OR CB.CTLMSG = 1 THEN
            ' go to first form
              g_lngFormNumber = 1
              funFillFormWithRecord(CB.HNDL, _
                                  %IDC_lblFormNumber, _
                                  g_lngFormNumber)
            END IF
          '
          CASE %IDC_btnLast
            IF CB.CTLMSG = %BN_CLICKED OR CB.CTLMSG = 1 THEN
          ' go to last form
            g_lngFormNumber = UBOUND(g_strFormData)
            funFillFormWithRecord(CB.HNDL, _
                                  %IDC_lblFormNumber, _
                                  g_lngFormNumber)
            END IF
            '
          CASE %IDC_btnNext
            IF CB.CTLMSG = %BN_CLICKED OR CB.CTLMSG = 1 THEN
            ' move to next form
              IF g_lngFormNumber = UBOUND(g_strFormData) THEN
              ' do nothing as already on last form
              ELSE
                INCR g_lngFormNumber
              END IF
              '
              funFillFormWithRecord(CB.HNDL, _
                                  %IDC_lblFormNumber, _
                                  g_lngFormNumber)
            END IF
            '
          CASE %IDC_btnBack
            IF CB.CTLMSG = %BN_CLICKED OR CB.CTLMSG = 1 THEN
            ' move to previous form
              IF g_lngFormNumber > 1 THEN
                DECR g_lngFormNumber
              END IF
              '
              funFillFormWithRecord(CB.HNDL, _
                                  %IDC_lblFormNumber, _
                                  g_lngFormNumber)
            END IF
          '
      END SELECT
      '
  END SELECT
END FUNCTION
'------------------------------------------------------------------------------

'------------------------------------------------------------------------------
'   ** Dialogs **
'------------------------------------------------------------------------------
FUNCTION ShowdlgMain(BYVAL hParent AS DWORD) AS LONG
  LOCAL lRslt AS LONG

#PBFORMS BEGIN DIALOG %IDD_dlgMain->->
  LOCAL hDlg   AS DWORD
  LOCAL hFont1 AS DWORD

  DIALOG NEW hParent, "Title", 125, 76, 500, 300, %WS_POPUP OR %WS_BORDER OR _
    %WS_DLGFRAME OR %WS_CAPTION OR %WS_SYSMENU OR %WS_MINIMIZEBOX OR _
    %WS_MAXIMIZEBOX OR %WS_CLIPSIBLINGS OR %WS_VISIBLE OR %DS_MODALFRAME OR _
    %DS_CENTER OR %DS_3DLOOK OR %DS_NOFAILCREATE OR %DS_SETFONT, _
    %WS_EX_CONTROLPARENT OR %WS_EX_LEFT OR %WS_EX_LTRREADING OR _
    %WS_EX_RIGHTSCROLLBAR, TO hDlg
  CONTROL ADD STATUSBAR, hDlg, %IDC_STATUSBAR1, "", 0, 0, 0, 0
  CONTROL ADD LABEL,     hDlg, %IDC_lblStatus, "Ready", 145, 260, 175, 25, _
    %WS_CHILD OR %WS_VISIBLE OR %SS_CENTER, %WS_EX_LEFT OR %WS_EX_LTRREADING
  CONTROL SET COLOR      hDlg, %IDC_lblStatus, %BLUE, -1
  CONTROL ADD BUTTON,    hDlg, %IDC_btnGrid, "", 372, 0, 16, 16
  CONTROL ADD BUTTON,    hDlg, %IDC_btnBack, "", 416, 0, 16, 16
  CONTROL ADD BUTTON,    hDlg, %IDC_btnNext, "", 438, 0, 16, 16
  CONTROL ADD BUTTON,    hDlg, %IDC_btnFirst, "", 394, 0, 16, 16
  CONTROL ADD BUTTON,    hDlg, %IDC_btnLast, "", 459, 0, 16, 16
  CONTROL ADD BUTTON,    hDlg, %IDC_btnNew, "", 480, 0, 17, 16
  CONTROL ADD LABEL,     hDlg, %IDC_lblFormNumber, "Form X", 399, 17, 85, 18, _
    %WS_CHILD OR %WS_VISIBLE OR %SS_CENTER, %WS_EX_LEFT OR %WS_EX_LTRREADING
  CONTROL SET COLOR      hDlg, %IDC_lblFormNumber, %BLUE, -1

  FONT NEW "MS Sans Serif", 14, 0, %ANSI_CHARSET TO hFont1

  CONTROL SET FONT hDlg, %IDC_lblStatus, hFont1
#PBFORMS END DIALOG
  '
  PREFIX "ButtonPlus hDlg, %IDC_btnGrid, "
    %BP_ICON_ID, %IDR_IMGGrid
    %BP_ICON_WIDTH, 48
  END PREFIX
  '
  PREFIX "ButtonPlus hDlg, %IDC_btnNext, "
    %BP_ICON_ID, %IDR_IMGNext
    %BP_ICON_WIDTH, 48
  END PREFIX
  '
  PREFIX "ButtonPlus hDlg, %IDC_btnBack, "
    %BP_ICON_ID, %IDR_IMGBack
    %BP_ICON_WIDTH, 48
  END PREFIX
  '
  PREFIX "ButtonPlus hDlg, %IDC_btnLast, "
    %BP_ICON_ID, %IDR_IMGLast
    %BP_ICON_WIDTH, 48
  END PREFIX
  '
  PREFIX "ButtonPlus hDlg, %IDC_btnFirst, "
    %BP_ICON_ID, %IDR_IMGFirst
    %BP_ICON_WIDTH, 48
  END PREFIX
  '
  PREFIX "ButtonPlus hDlg, %IDC_btnNew, "
    %BP_ICON_ID, %IDR_IMGNew
    %BP_ICON_WIDTH, 48
  END PREFIX
  '
  DIALOG SET ICON hDlg,"#" & FORMAT$(%IDR_APPICON)
  '
  g_hDlg = hDlg ' store the handle of the dialog
  DIALOG SHOW MODAL hDlg, CALL ShowdlgMainProc TO lRslt

#PBFORMS BEGIN CLEANUP %IDD_dlgMain
  FONT END hFont1
#PBFORMS END CLEANUP

  FUNCTION = lRslt
END FUNCTION
'------------------------------------------------------------------------------
FUNCTION funPopulateForm() AS LONG
' populate the form based on the ga_strConfig() array
  LOCAL lngR AS LONG
  LOCAL strHeaders AS STRING
  LOCAL strData AS STRING
  LOCAL lngControl AS LONG
  '
  DIM a_strData() AS STRING
  LOCAL lngStyle AS LONG
  LOCAL lngExStyle AS LONG
  LOCAL strFile AS STRING
  '
  LOCAL lngCharLimit AS LONG
  '
  LOCAL strToolTip AS STRING
  LOCAL lngBkgColour AS LONG  ' colour of the background tooltip
  LOCAL lngTxtColour AS LONG  ' colour of the text on the tooltip
  '
  '
  strHeaders = ga_strConfig(0) ' store headers
  '
  FOR lngR = 1 TO UBOUND(ga_strConfig)
    IF ga_strConfig(lngR) = "" THEN ITERATE
    strData = ga_strConfig(lngR)
    ' pick up the control ID
    lngControl = VAL(PARSE$(strData,"",%Ref_ID))
    '
    SELECT CASE MCASE$(PARSE$(strData,"",%REF_Object))
      CASE "Title"
      ' dialog title
        DIALOG SET TEXT g_hDlg,PARSE$(strData,"",%Ref_Text)
        DIALOG SET SIZE g_hDlg,VAL(PARSE$(strData,"",%Ref_Width)), _
                               VAL(PARSE$(strData,"",%Ref_Height))
                               '
        IF PARSE$(strData,"",%Ref_Function) = "CENTER" THEN
        ' center the form on screen
          subCentreWindow g_hDlg
        '
        END IF
        '
      CASE "Button"
        CONTROL ADD BUTTON, g_hDlg,lngControl, _
                                  PARSE$(strData,"",%Ref_Text), _
                                  VAL(PARSE$(strData,"",%Ref_X)), _
                                  VAL(PARSE$(strData,"",%Ref_Y)), _
                                  VAL(PARSE$(strData,"",%Ref_Width)), _
                                  VAL(PARSE$(strData,"",%Ref_Height))
      '
      CASE "Label"
        CONTROL ADD LABEL,g_hDlg,lngControl, _
                                  PARSE$(strData,"",%Ref_Text), _
                                  VAL(PARSE$(strData,"",%Ref_X)), _
                                  VAL(PARSE$(strData,"",%Ref_Y)), _
                                  VAL(PARSE$(strData,"",%Ref_Width)), _
                                  VAL(PARSE$(strData,"",%Ref_Height))
        CONTROL SET COLOR g_hDlg,VAL(PARSE$(strData,"",%Ref_ID)),%BLUE,-1
      '
      CASE "Text"
        '
        lngStyle = %WS_CHILD OR %WS_VISIBLE OR %WS_TABSTOP OR _
                   %ES_LEFT OR %ES_AUTOHSCROLL
        lngExStyle = %WS_EX_CLIENTEDGE OR %WS_EX_LEFT OR _
                     %WS_EX_LTRREADING OR %WS_EX_RIGHTSCROLLBAR
                     '
        IF PARSE$(strData,"",%Ref_Function) = "NUMBERONLY" THEN
          lngStyle = lngStyle OR %ES_NUMBER
        END IF
        '
        CONTROL ADD TEXTBOX,g_hDlg,lngControl, _
                                  PARSE$(strData,"",%Ref_Text), _
                                  VAL(PARSE$(strData,"",%Ref_X)), _
                                  VAL(PARSE$(strData,"",%Ref_Y)), _
                                  VAL(PARSE$(strData,"",%Ref_Width)), _
                                  VAL(PARSE$(strData,"",%Ref_Height)), _
                                  lngStyle,lngExStyle
                                  '
         ' pick up any limit to number of characters
        lngCharLimit = VAL(PARSE$(strData,"",%Ref_CharLimit))
        '
        IF lngCharLimit > 0 THEN
        ' limit the text box to this number of characters
          CONTROL POST g_hDlg,lngControl, %EM_SETLIMITTEXT,lngCharLimit, 0
        END IF
        '
     CASE "Dropdownlist"
        ' define the styles for the combobox
        lngStyle = %WS_CHILD OR %WS_VISIBLE OR %WS_TABSTOP OR %CBS_DROPDOWNLIST
        lngExStyle = %WS_EX_LEFT OR %WS_EX_LTRREADING OR %WS_EX_RIGHTSCROLLBAR
        '
        IF PARSE$(ga_strConfig(lngR),"",%Ref_Function) = "SORT" THEN
        ' sort the combobox
          lngStyle = lngStyle OR %CBS_SORT
        END IF
        '
        ' pick up a data file (if exists) in the config file for this
        ' object
        strFile = g_strConfigFolder & PARSE$(strData,"",%Ref_Text)
        '
        IF ISTRUE ISFILE(strFile) THEN
        ' test for file and load it into the array
          funReadTheFileIntoAnArray(strFile,a_strData())
        END IF
        '
        CONTROL ADD COMBOBOX,g_hDlg,lngControl, _
                             a_strData(), _
                             VAL(PARSE$(strData,"",%Ref_X)), _
                             VAL(PARSE$(strData,"",%Ref_Y)), _
                             VAL(PARSE$(strData,"",%Ref_Width)), _
                             VAL(PARSE$(strData,"",%Ref_Height)), _
                             lngStyle,lngExStyle
    '
      CASE "Listbox"
        ' define the styles for the listbox
        lngStyle = %WS_CHILD OR %WS_VISIBLE OR %WS_TABSTOP _
                   OR %WS_VSCROLL OR %WS_BORDER
        lngExStyle = %WS_EX_LEFT OR %WS_EX_LTRREADING OR %WS_EX_RIGHTSCROLLBAR
        '
        IF PARSE$(ga_strConfig(lngR),"",%Ref_Function) = "SORT" THEN
        ' sort the listbox
          lngStyle = lngStyle OR %LBS_SORT
        END IF
        '
         ' pick up a data file (if exists) in the config file for this
        ' object
        strFile = g_strConfigFolder & PARSE$(strData,"",%Ref_Text)
        IF ISTRUE ISFILE(strFile) THEN
        ' test for file and load it into the array
          funReadTheFileIntoAnArray(strFile,a_strData())
        END IF
        '
        CONTROL ADD LISTBOX,g_hDlg,lngControl, _
                             a_strData(), _
                             VAL(PARSE$(strData,"",%Ref_X)), _
                             VAL(PARSE$(strData,"",%Ref_Y)), _
                             VAL(PARSE$(strData,"",%Ref_Width)), _
                             VAL(PARSE$(strData,"",%Ref_Height)), _
                             lngStyle,lngExStyle
      '
       CASE "Date"
       ' define the styles for the date control
        lngStyle = %WS_CHILD OR %WS_VISIBLE OR _
                   %WS_TABSTOP OR %DTS_SHORTDATECENTURYFORMAT
        lngExStyle = %WS_EX_CLIENTEDGE OR _
                     %WS_EX_LEFT OR %WS_EX_LTRREADING OR _
                     %WS_EX_RIGHTSCROLLBAR
                     '
         CONTROL ADD "SysDateTimePick32",g_hDlg,lngControl, _
                    "", VAL(PARSE$(strData,"",%Ref_X)), _
                        VAL(PARSE$(strData,"",%Ref_Y)), _
                        VAL(PARSE$(strData,"",%Ref_Width)), _
                        VAL(PARSE$(strData,"",%Ref_Height)), _
                        lngStyle,lngExStyle
                        '
       CASE "Tickbox"
       ' define the styles for the tickbox
         lngStyle = %BS_LEFT OR %BS_VCENTER OR %WS_TABSTOP
         lngExStyle = %WS_EX_LEFT
         '
         CONTROL ADD CHECKBOX,g_hDlg,lngControl, _
                     "", VAL(PARSE$(strData,"",%Ref_X)), _
                        VAL(PARSE$(strData,"",%Ref_Y)), _
                        VAL(PARSE$(strData,"",%Ref_Width)), _
                        VAL(PARSE$(strData,"",%Ref_Height)), _
                        lngStyle,lngExStyle
                        '
       CASE "Url"
       ' define the styles for the rich edit control

         IF g_hLib = 0 THEN
         ' library not loaded yet
           g_hLib = LoadLibrary("riched20.dll") :InitCommonControls
         END IF
         '
         lngStyle = %WS_CHILD OR %WS_VISIBLE OR %WS_TABSTOP OR %ES_LEFT OR _
                    %ES_MULTILINE OR %ES_READONLY OR %ES_WANTRETURN
         lngExStyle = %WS_EX_LEFT OR _
                      %WS_EX_LTRREADING OR %WS_EX_RIGHTSCROLLBAR
                      '
         CONTROL ADD "RichEdit20A" , g_hDlg,lngControl,_
                        "", VAL(PARSE$(strData,"",%Ref_X)), _
                        VAL(PARSE$(strData,"",%Ref_Y)), _
                        VAL(PARSE$(strData,"",%Ref_Width)), _
                        VAL(PARSE$(strData,"",%Ref_Height)), _
                        lngStyle,lngExStyle
                        '
          ' set the background color
         CONTROL SEND g_hDlg,lngControl, %EM_SETBKGNDCOLOR, 0, _
                            RGB(239,239,239)
                            '
          ' auto detect the URL
         CONTROL SEND g_hDlg,lngControl, %EM_AutoUrlDetect, %TRUE,0
         '
          ' get ready to handle events
         CONTROL SEND g_hDlg,lngControl, %EM_SETEventMask,0,%ENM_LINK
         '
         CONTROL SET TEXT g_hDlg,lngControl,"" & _
                          PARSE$(strData,"",%Ref_Text)
         '
    END SELECT
    '
    ' look for tooltips
    strToolTip = PARSE$(strData,"",%Ref_Tooltips)
    ' set the background and text colours for the tooltip
    lngBkgColour = %YELLOW
    lngTxtColour = %BLACK
    '
    IF strToolTip <> "" THEN
    ' tooltip has been specified
      CALL ToolTip_SetToolTip (GetDlgItem(g_hDlg,lngControl), _
                                strToolTip, _
                                lngBkgColour, _
                                lngTxtColour)
    END IF
    '
  NEXT lngR
  '
  ' mark some objects as hidden?
  funHideObjects()
  '
  ' set focus to the first editable object?
  funSetFocusToStartOfForm()
  '
END FUNCTION
'
FUNCTION funHideObjects() AS LONG
' mark some objects as hidden?
  LOCAL lngR AS LONG
  LOCAL lngControl AS LONG
  LOCAL strData AS STRING
  LOCAL lngConditionalControl AS LONG
  LOCAL strSelection AS STRING
  LOCAL strDefaultSelected AS STRING
  '
  FOR lngR = 1 TO UBOUND(ga_strConfig)
    IF ga_strConfig(lngR) = "" THEN ITERATE
    strData = ga_strConfig(lngR)
     ' pick up the control ID
    lngControl = VAL(PARSE$(strData,"",%Ref_ID))
    lngConditionalControl = VAL(PARSE$(strData,"",%Ref_Conditional))
    strSelection = PARSE$(strData,"",%Ref_Selection)
    '
    IF lngConditionalControl > 0 THEN
    ' this object is conditionally visible
    ' should we show this control?
      strDefaultSelected = _
                   funReturnFieldValue(lngConditionalControl,"Defaults")
      IF strSelection <> strDefaultSelected THEN
      ' hide the control
        CONTROL HIDE g_hDlg,lngControl
      END IF
      '
    END IF
    '
  NEXT lngR
  '
END FUNCTION
'
SUB subCentreWindow(BYVAL hWnd AS DWORD)
' centre the window or dialog given its handle
  LOCAL WndRect AS RECT
  LOCAL x       AS LONG
  LOCAL y       AS LONG

  GetWindowRect hWnd, WndRect   ' get the size of the window or dialog in WndRect structure
  ' work out the screen size , the window size and where it should be positioned
  x = (GetSystemMetrics(%SM_CXSCREEN)-(WndRect.nRight-WndRect.nLeft))\2
  y = (GetSystemMetrics(%SM_CYSCREEN)-(WndRect.nBottom-WndRect.nTop+GetSystemMetrics(%SM_CYCAPTION)))\2

  SetWindowPos hWnd, %NULL, x, y, 0, 0, %SWP_NOSIZE OR %SWP_NOZORDER    ' move the window or dialog into position

END SUB
'
FUNCTION funRunNotifyProcesses(hDlg AS DWORD, _
                               lngControl AS LONG, _
                               dwLparam AS DWORD) AS LONG
' perform the notify process this control needs to do
' first find the object in the global array
  LOCAL strURL AS STRING
  LOCAL lpNmhDRPrt AS NMHDR PTR
  LOCAL lngR AS LONG
  LOCAL lngObject AS LONG
  LOCAL strObjectType AS STRING
  LOCAL strObjectFunction AS STRING
  '
   FOR lngR = 1 TO UBOUND(ga_strConfig)
    lngObject = VAL(PARSE$(ga_strConfig(lngR),"",%Ref_ID))
    IF lngControl = lngObject THEN
    ' found the object - determine the type
      strObjectType = PARSE$(ga_strConfig(lngR),%Ref_Object)
      strObjectFunction = PARSE$(ga_strConfig(lngR),"",%Ref_Function)
      '
      SELECT CASE strObjectType
        CASE "URL"
        ' hyperlink
          lpNmhDRPrt = dwLparam ' get a pointer to the NMHDR structure
          IF @lpNmhDRPrt.idfrom = lngControl THEN
          '
          SELECT CASE @lpNmhDRPrt.code
              CASE %EN_Link
                ' call the function in the
                ' PB_Windows_Controls.inc include file
                ' that handles clicking on Rich edit URL
                FUNCTION = funRichEd_HyperLink_HandleURL(hDlg, _
                                           dwLparam,lngControl)
                EXIT FUNCTION
            END SELECT
          END IF
        '
      END SELECT
      '
    END IF
    '
  NEXT lngR
  '
END FUNCTION
'
FUNCTION funRunControlProcess(hDlg AS DWORD, _
                              lngControl AS LONG, _
                              lngMessage AS LONG) AS LONG
' perform the function this control needs to do
' first find the object in the global array
  LOCAL lngR AS LONG
  LOCAL lngObject AS LONG
  LOCAL strObjectType AS STRING
  LOCAL strObjectFunction AS STRING
  '
  LOCAL strError AS STRING
  LOCAL lngField AS LONG
  LOCAL strData AS STRING
  LOCAL lngResult AS LONG
  '
  FOR lngR = 1 TO UBOUND(ga_strConfig)
    lngObject = VAL(PARSE$(ga_strConfig(lngR),"",%Ref_ID))
    '
    IF lngControl = lngObject THEN
    ' found the object - determine the type
      strObjectType = PARSE$(ga_strConfig(lngR),%Ref_Object)
      strObjectFunction = PARSE$(ga_strConfig(lngR),"",%Ref_Function)
      '
      SELECT CASE strObjectType
        CASE "Text"
        ' event for a text box
          IF lngMessage = %EN_CHANGE THEN
          ' value has changed
            CONTROL GET TEXT hDlg,lngControl TO strData
            IF ISTRUE funHasDependantControl(lngControl, _
                                             strData) THEN
            END IF
          '
          END IF
        '
        CASE "Dropdownlist"
        ' event for a dropdown list (single select only)
          IF lngMessage = %BN_CLICKED OR lngMessage = 1 THEN
          ' item has been selected
            CONTROL GET TEXT hDlg,lngControl TO strData
            IF ISTRUE funHasDependantControl(lngControl, _
                                             strData) THEN
            END IF
            '
          END IF
        '
        CASE "Tickbox"
          IF lngMessage = %BN_CLICKED OR lngMessage = 1 THEN
          ' item has been selected/unselected
            CONTROL GET CHECK hDlg, lngControl TO lngResult
            IF ISTRUE funHasDependantControl(lngControl, _
                                             FORMAT$(lngResult)) THEN
            END IF
          END IF
          '
        CASE "Button"
          IF lngMessage = %BN_CLICKED OR lngMessage = 1 THEN
          ' button has been clicked on
            SELECT CASE strObjectFunction
              '
              CASE "SAVE"
              ' save data
                ' first validate data on form
                IF ISTRUE funValidateForm(strError, lngField) THEN
                  IF ISTRUE funSaveFormData(lngControl,"Fieldname") THEN
                  ' confirm to user then clear the form
                    CONTROL SET TEXT g_hDlg,%IDC_lblStatus,"Form Saved"
                    '
                    ' are we on the last form?
                    IF g_lngFormNumber = UBOUND(g_strFormData) THEN
                      INCR g_lngFormNumber
                      REDIM PRESERVE g_strFormData(g_lngFormNumber)
                      '
                      CONTROL SET TEXT g_hDlg,%IDC_lblFormNumber,"Form " & _
                                       FORMAT$(g_lngFormNumber)
                        '
                      funResetForm()
                      '
                    END IF
                    ' set focus to the start of form
                    funSetFocusToStartOfForm()
                    '
                  ELSE
                    CONTROL SET TEXT g_hDlg,%IDC_lblStatus,"Form NOT Saved"
                  END IF
                ELSE
                 ' form fails validation
                  CONTROL SET TEXT g_hDlg,%IDC_lblStatus,strError
                  CONTROL SET FOCUS g_hDlg,lngField
                  EXIT FUNCTION
                  '
                END IF
              '
              CASE "EXIT"
                ' form is being unloaded
                IF g_hLib <> 0 THEN
                ' if richedit library loaded then unload it now
                  FreeLibrary g_hLib
                END IF
                '
                ' exit application
                DIALOG END hDlg
              '
            END SELECT
          END IF
      END SELECT
      '
      '
    END IF
    '
  NEXT lngR

END FUNCTION
'
FUNCTION funHasDependantControl(lngControl AS LONG, _
                                strData AS STRING) AS LONG
' look for other controls that have this as a parent
  LOCAL lngR AS LONG
  LOCAL lngObject AS LONG
  LOCAL strObjectType AS STRING
  LOCAL lngParent AS LONG
  LOCAL strSelection AS STRING
  '
  FOR lngR = 1 TO UBOUND(ga_strConfig)
    lngObject = VAL(PARSE$(ga_strConfig(lngR),"",%Ref_ID))
    lngParent = VAL(PARSE$(ga_strConfig(lngR),"",%Ref_Conditional))
    strObjectType = PARSE$(ga_strConfig(lngR),"",%Ref_Object)
    '
    IF lngParent = lngControl THEN
    ' found a control that has this control as a parent
      strSelection = PARSE$(ga_strConfig(lngR),"",%Ref_Selection)
      IF strSelection = strData THEN
      ' show the control
        CONTROL NORMALIZE g_hDlg, lngObject
        FUNCTION = %TRUE
      ELSE
      ' hide the control
        CONTROL HIDE g_hDlg,lngObject
       ' blank out the data or unselect
        funBlankControl(g_hDlg,lngObject,strObjectType)
        FUNCTION = %TRUE
      END IF
    '
    END IF
    '
  NEXT lngR
  '
END FUNCTION
'
FUNCTION funBlankControl(hDlg AS DWORD, _
                         lngObject AS LONG, _
                         strObjectType AS STRING) AS LONG
' blank out the entered data in the control
  SELECT CASE strObjectType
    CASE "Text"
      CONTROL SET TEXT hDlg,lngObject,""
    CASE "Tickbox"
      CONTROL SET CHECK hDlg,lngObject,0
    CASE "Dropdownlist"
      COMBOBOX UNSELECT hDlg, lngObject
  END SELECT
  '
END FUNCTION
'
FUNCTION funSaveFormData(lngControl AS LONG, _
                         strFieldname AS STRING) AS LONG
' save the data to the file specified in the OK button
' where lngControl is the ID of the button object
'
' first determine where to save the data
  LOCAL strOutput AS STRING
  LOCAL lngR AS LONG
  LOCAL strData AS STRING    ' data to save to the file
  '
    ' get the output file name
  strOutput = EXE.PATH$ & funReturnFieldValue(lngControl,strFieldname)
  '
  ' first save the form to the global array  g_strFormData(g_lngFormNumber)
  strData = funGetFormData()  ' get the data from the screen
  '
  IF ISTRUE funInsertToArray(strData,g_lngFormNumber, _
                             g_strFormData() ) THEN
  ' data inserted to array successfully
  ' so save to file
    FUNCTION = funArrayDump(strOutput,BYREF g_strFormData(),%TRUE )
    '
  ELSE
  ' unable to insert to array?
  END IF
  '
END FUNCTION
'
FUNCTION funReturnFieldValue(lngControl AS LONG, _
                             strFieldname AS STRING) AS STRING
' return the value in a specified field given the control ID
  LOCAL lngR AS LONG
  LOCAL lngIDcolumn AS LONG
  LOCAL lngFieldColumn AS LONG
  '
   ' get the column number the ID is in
  lngIDcolumn = funParseFind(ga_strConfig(0),"", "ID")
  '
  ' get the column number the required field is in
  lngFieldColumn = funParseFind(ga_strConfig(0),"", strFieldname)
  '
  FOR lngR = 1 TO UBOUND(ga_strConfig)
    IF VAL(PARSE$(ga_strConfig(lngR),"",lngIDcolumn)) = lngControl THEN
    ' we've found the data line
      FUNCTION = PARSE$(ga_strConfig(lngR),"",lngFieldColumn)
      EXIT FUNCTION
    END IF
  NEXT lngR
  ' nothing found?
  FUNCTION = ""
  '
END FUNCTION
'
FUNCTION funGetConfigHeaders() AS STRING
' read the config file and determine the config headers
  LOCAL lngR AS LONG
  LOCAL lngObjectColumn AS LONG
  LOCAL lngFieldColumn AS LONG
  LOCAL strHeader AS STRING
  LOCAL strColumn AS STRING
  LOCAL strObject AS STRING
  '
  ' get the column number the Object is in
  lngObjectColumn = funParseFind(ga_strConfig(0),"", "Object")
  '
  ' get the column number the fieldname is in
  lngFieldColumn = funParseFind(ga_strConfig(0),"", "Fieldname")
  '
  FOR lngR = 1 TO UBOUND(ga_strConfig)
    strObject = PARSE$(ga_strConfig(lngR),"",lngObjectColumn)
    SELECT CASE strObject
      CASE "Text","Dropdownlist","Listbox"
        strColumn = PARSE$(ga_strConfig(lngR),"",lngFieldColumn)
        strHeader = strHeader & $DQ & strColumn & $DQ & ","
    END SELECT
  NEXT lngR
  '
  ' trim off any trailing commas
  strHeader = RTRIM$(strHeader,",")
  '
  FUNCTION = strHeader
  '
END FUNCTION
'
FUNCTION funGetFormData() AS STRING
' get the data from the form objects
  LOCAL lngR AS LONG
  LOCAL lngObjectColumn AS LONG
  LOCAL lngIDcolumn AS LONG
  LOCAL lngControl AS LONG
  LOCAL strData AS STRING
  LOCAL lngData AS LONG
  LOCAL strRowData AS STRING
  '
  ' get the column number the Object is in
  lngObjectColumn = funParseFind(ga_strConfig(0),"", "Object") '
  '
  ' get the column number the ID is in
  lngIDcolumn = funParseFind(ga_strConfig(0),"", "ID")
  '
  FOR lngR = 1 TO UBOUND(ga_strConfig)
  ' get the control ID
    lngControl = VAL(PARSE$(ga_strConfig(lngR),"",lngIDcolumn))
    strData = ""
    '
    SELECT CASE PARSE$(ga_strConfig(lngR),"",lngObjectColumn)
      CASE "Text","Dropdownlist"
        ' get the text in the control
        CONTROL GET TEXT g_hDlg,lngControl TO strData
        '
      CASE "Listbox"
      ' get the text in the control (assumes single item select)
        LISTBOX GET TEXT g_hDlg,lngControl TO strData
      '
      CASE "Date"
      ' get the date from the date control
        strData = funGetaDate(g_hDlg,lngControl)
      '
      CASE "Tickbox"
      ' get the value of the tickbox
        CONTROL GET CHECK g_hDlg, lngControl TO lngData
        IF lngData = 1 THEN
          strData = "1"
        ELSE
          strData = ""
        END IF
      '
      CASE ELSE
        ITERATE FOR
    END SELECT
    '
    ' add column data to row variable
    strRowData = strRowData & $DQ & strData & $DQ & ","
    '
  NEXT lngR
  '
  ' trim off any trailing commas
  strRowData = RTRIM$(strRowData,",")
  '
  FUNCTION = strRowData
  '
END FUNCTION
'
FUNCTION funResetForm() AS LONG
' clear all the fields on the form
  LOCAL lngR AS LONG
  LOCAL lngObjectColumn AS LONG
  LOCAL lngIDcolumn AS LONG
  LOCAL lngControl AS LONG
  '
  LOCAL lngDefaultsColumn AS LONG ' the column number of the default column
  LOCAL strDefault AS STRING      ' the value in the default column
  '
  ' get the column number the Object is in
  lngObjectColumn = funParseFind(ga_strConfig(0),"", "Object") '
  '
  ' get the column number the ID is in
  lngIDcolumn = funParseFind(ga_strConfig(0),"", "ID")
  '
  ' get the column number of the defaults column
  lngDefaultsColumn = funParseFind(ga_strConfig(0),"", "Defaults")
  '
  FOR lngR = 1 TO UBOUND(ga_strConfig)
  ' get the control ID
    lngControl = VAL(PARSE$(ga_strConfig(lngR),"",lngIDcolumn))
    '
    ' get the default value - if any
    strDefault = PARSE$(ga_strConfig(lngR),"", _
                        lngDefaultsColumn)
    '
    SELECT CASE PARSE$(ga_strConfig(lngR),"",lngObjectColumn)
      CASE "Text"
        ' wipe the text in the control
        CONTROL SET TEXT g_hDlg,lngControl,strDefault
        '
      CASE "Dropdownlist"
      ' unselect the combobox
        IF strDefault = "" THEN
        COMBOBOX UNSELECT g_hDlg,lngControl
        ELSE
        ' pick the default
          funSelectCombo(g_hDlg,lngControl, strDefault)
        END IF
        '
      CASE "Listbox"
      ' unselect the text in the control
        IF strDefault = "" THEN
        LISTBOX UNSELECT g_hDlg,lngControl
        ELSE
        ' set the default
          funSelectListbox(g_hDlg,lngControl, strDefault)
        END IF
      '
      CASE "Date"
      ' set any date control to today
        IF strDefault = "" THEN
        funSetaDate(g_hDlg,lngControl,funUKDate())
        ELSE
        ' set the default
          funSetaDate(g_hDlg,lngControl,strDefault)
        END IF
        '
      CASE "Tickbox"
      ' set any checkbox to blank
        IF strDefault = "" THEN
        CONTROL SET CHECK g_hDlg,lngControl,0
        ELSE
        ' set the default
          CONTROL SET CHECK g_hDlg,lngControl,VAL(strDefault)
        END IF
        '
      CASE ELSE
        ITERATE FOR
    END SELECT
    '
  NEXT lngR
  '
  ' mark some objects as hidden?
  funHideObjects()
  '
END FUNCTION
'
FUNCTION funSetFocusToStartOfForm() AS LONG
' set the focus to the first editable object
  LOCAL lngR AS LONG
  LOCAL lngControl AS LONG
  LOCAL strData AS STRING
  '
  FOR lngR = 1 TO UBOUND(ga_strConfig)
    strData = ga_strConfig(lngR)
    '
    SELECT CASE PARSE$(strData,"",%REF_Object)
      CASE "Text","Dropdownlist","Listbox"
        lngControl = VAL(PARSE$(strData,"",%Ref_ID))
        CONTROL SET FOCUS g_hDlg,lngControl
        EXIT FOR
    END SELECT
    '
  NEXT lngR
'
END FUNCTION
'
'
FUNCTION funValidateForm(o_strError AS STRING, _
                         o_lngField AS LONG) AS LONG
  LOCAL lngR AS LONG           ' loop counter
  LOCAL lngIDcolumn AS LONG    ' column number of ID column
  LOCAL strObject AS STRING    ' type of object
  LOCAL lngObject AS LONG      ' column number of object column
  LOCAL strData AS STRING      ' holds field data from form
  LOCAL lngData AS LONG        ' holds numeric data from form
  LOCAL lngMandatory AS LONG   ' column number of mandatory column
  LOCAL lngControl AS LONG     ' handle of the control on dialog
  LOCAL strFieldname AS STRING ' name of the field that has failed
                               ' validation
                               '
  ' get the column number the ID is in
  lngObject    = funParseFind(ga_strConfig(0),"", "Object")
  lngIDcolumn  = funParseFind(ga_strConfig(0),"", "ID")
  lngMandatory = funParseFind(ga_strConfig(0),"", "Mandatory")
  '
  FOR lngR = 1 TO UBOUND(ga_strConfig)
  ' get the control ID of each screen object
    strObject = PARSE$(ga_strConfig(lngR),"",lngObject)
    strData = "" ' blank out the variable
    '
     SELECT CASE strObject
      CASE "Text","Dropdownlist","Listbox"
      ' only interested in these objects
      ' get the objects dialog handle
        lngControl = VAL(PARSE$(ga_strConfig(lngR),"",lngIDcolumn))
        '
         ' is this a mandatory field?
        IF PARSE$(ga_strConfig(lngR),"",lngMandatory) = "Yes" THEN
          ' now check if the field is populated
          SELECT CASE PARSE$(ga_strConfig(lngR),"",lngObject)
            CASE "Text","Dropdownlist"
            ' get the text in the control
              CONTROL GET TEXT g_hDlg,lngControl TO strData
            '
            CASE "Listbox"
            ' get the text in the control (assumes single item select)
              LISTBOX GET TEXT g_hDlg,lngControl TO strData
            '
            CASE "Tickbox"
              CONTROL GET CHECK g_hDlg,lngControl TO lngData
              IF lngData = 0 THEN
                strData = ""
              ELSE
                strData = "1"
              END IF
              '
          END SELECT
          '
          IF strData = "" THEN
            FUNCTION = %FALSE
            ' validation has failed so mark this field
            strFieldname = funReturnFieldValue(lngControl,"Fieldname")
            '
            ' and set the error message
            o_lngField = lngControl ' output the field handle
            o_strError = "Mandatory field empty - " & strFieldname
            EXIT FUNCTION
            '
          END IF
          '
        END IF
        '
     END SELECT

  NEXT lngR
  '
  FUNCTION = %TRUE
  '
END FUNCTION
'
FUNCTION funFillFormWithRecord(hDlg AS DWORD, _
                               lngFormNumberControl AS LONG, _
                               lngRecord AS LONG) AS LONG
' fill the form with data from the form data array
  LOCAL lngColumn AS LONG     ' column number
  LOCAL strData AS STRING     ' form data record
  LOCAL strHeaders AS STRING  ' all column headers
  LOCAL strColumn AS STRING   ' column title
  LOCAL lngFieldNameColumn AS LONG ' column number of Fieldname
  LOCAL lngIDcolumn AS LONG   ' column number of ID
  LOCAL lngConfigRow AS LONG  ' row counter in the config array
  LOCAL lngControl AS LONG    ' handle of the control
  LOCAL lngObjectColumn AS LONG ' column number of object type of the control
  LOCAL strObject AS STRING     ' object type of the control
  LOCAL strValue AS STRING      ' value to be put in field
  '
  LOCAL lngDefaultsColumn AS LONG ' the column number of the default column
  LOCAL strDefault AS STRING      ' the value in the default column
  LOCAL strData_no_delimiters AS STRING ' the strData without any commas
  '
  strHeaders = g_strFormData(0)
  '
  IF lngRecord > UBOUND(g_strFormData) THEN
  ' have we reached the end of the forms?
    strData = ""
    strData_no_delimiters = strData
  ELSE
  ' store the data from the form
    strData = g_strFormData(lngRecord)
    strData_no_delimiters = strData
    REPLACE "," WITH "" IN strData_no_delimiters
  END IF
  '
  ' get the column number the Fieldname is in
  lngFieldNameColumn = funParseFind(ga_strConfig(0),"", "Fieldname")
  ' get the column number the ID is in
  lngIDcolumn = funParseFind(ga_strConfig(0),"", "ID")
  ' get the column number of the Object
  lngObjectColumn = funParseFind(ga_strConfig(0),"", "Object")
  '
  ' get the column number of the defaults column
  lngDefaultsColumn = funParseFind(ga_strConfig(0),"", "Defaults")
  '
  '
  FOR lngColumn = 1 TO PARSECOUNT(strHeaders,"")
    ' get the header for the data column
    strColumn = PARSE$(strHeaders,"",lngColumn)
    ' now find it in the Config file
    lngControl = 0
    '
    FOR lngConfigRow = 1 TO UBOUND(ga_strConfig)
      IF PARSE$(ga_strConfig(lngConfigRow),"",lngFieldNameColumn) = strColumn THEN
      ' found the match - so get the control ID
        lngControl = VAL(PARSE$(ga_strConfig(lngConfigRow),"", _
                     lngIDcolumn))
        strObject =  PARSE$(ga_strConfig(lngConfigRow),"", _
                     lngObjectColumn)
                     '
        ' get the default value - if any
        strDefault = PARSE$(ga_strConfig(lngConfigRow),"", _
                     lngDefaultsColumn)
                     '
        '
        EXIT FOR
      END IF
      '
    NEXT lngConfigRow
    '
    IF lngControl > 0 THEN
    ' control has been identified so populate it with data
    ' get the value in the column
      strValue = PARSE$(strData,"", lngColumn)
      '
      IF strData_no_delimiters = "" THEN
      ' new form so set the defaults
        strValue = strDefault
      '
      END IF
      '
      SELECT CASE strObject
        CASE "Text"
        ' populate the text box
          CONTROL SET TEXT g_hDlg,lngControl, strValue
          '
        CASE "Dropdownlist"
        ' populate the combo
          funSelectCombo(g_hDlg,lngControl, strValue)
          '
        CASE "Listbox"
        ' populate the listbox
          funSelectListbox(g_hDlg,lngControl, strValue)
          '
        CASE "Date"
        ' populate the date control
          IF strValue = "" THEN
          ' if no date set default to Today
            strValue = funUKDate()
          END IF
          '
          funSetaDate(g_hDlg,lngControl,strValue)
          '
        CASE "Tickbox"
        ' populate the tickbox
          IF strValue = "1" THEN
            CONTROL SET CHECK g_hDlg,lngControl,1
          ELSE
            CONTROL SET CHECK g_hDlg,lngControl,0
          END IF
        '
      END SELECT
      '
    END IF
    '
  NEXT lngColumn
  '
  ' update the form number display
  CONTROL SET TEXT hDlg,lngFormNumberControl,"Form " & _
                        FORMAT$(g_lngFormNumber)
                        '
  CONTROL SET TEXT hDlg,%IDC_lblStatus,"Form Loaded"
  '
END FUNCTION
'
FUNCTION funInsertToArray(strData AS STRING, _
                          lngFormNumber AS LONG, _
                          g_strFormData() AS STRING) AS LONG
' insert the data into the array
  IF lngFormNumber > UBOUND(g_strFormData) THEN
  ' make the array larger if needed
    REDIM PRESERVE g_strFormData(UBOUND(g_strFormData)+1)
  END IF
  '
  g_strFormData(lngFormNumber) = strData
  '
  FUNCTION = %TRUE
  '
END FUNCTION
'
FUNCTION funSetaDate(hDlg AS DWORD, _
                     lngDate AS LONG, _
                     strDate AS STRING) AS LONG
' set a date control to the date passed - dd/mm/yyyy format assumed
  LOCAL uDT AS SystemTime
  LOCAL hCalendar AS DWORD
  '
  CONTROL HANDLE hDlg, lngDate TO hCalendar
  '
  uDT.wMonth = VAL(MID$(strDate,4,2))
  uDT.wDay   = VAL(MID$(strDate,1,2))
  uDT.wYear  = VAL(RIGHT$(strDate,4))
  '
  FUNCTION = DateTime_SetSystemTime(hCalendar, %GDT_Valid, uDT)
  '
END FUNCTION
'
FUNCTION funGetaDate(hDlg AS DWORD, _
                     lngDate AS LONG) AS STRING
' get the date on the date control - dd/mm/yyyy format assumed
  LOCAL uDT AS SystemTime    ' udt to hold system time data
  LOCAL hCalendar AS DWORD   ' windows handle of date control
  LOCAL strDate AS STRING    ' string to hold date returned
  '
  CONTROL HANDLE hDlg, lngDate TO hCalendar
  '
  IF DateTime_GetSystemtime(hCalendar, uDT) = %GDT_VALID THEN
    strDate = RIGHT$("00" & FORMAT$(uDT.wDay),2) & "/" & _
              RIGHT$("00" & FORMAT$(uDT.wMonth),2) & "/" & _
              FORMAT$(uDT.wYear)
  ELSE
    strDate = ""
  END IF
  '
  FUNCTION = strDate
  '
END FUNCTION
'
FUNCTION funUKDate AS STRING
' return the current date in dd/mm/yyyy UK format
  DIM strDate AS STRING
  '
  strDate= DATE$
  '
  FUNCTION = MID$(strDate,4,2) & "/" & _
             LEFT$(strDate,2) & "/" & _
             RIGHT$(strDate,4)
END FUNCTION
'------------------------------------------------------------------------------
CALLBACK FUNCTION ShowdlgViewFormsProc()
  '
  LOCAL lngRefresh AS LONG
  DIM a_strGridData() AS STRING
  LOCAL lngExcludeColumn AS LONG
  '
  SELECT CASE AS LONG CB.MSG
    CASE %WM_INITDIALOG
      ' Initialization handler
      ' fill the grid with data in g_strFormData()
        funPopulate_the_grid_array(hGrid1,a_strGridData())
        ' push the array into the grid
        MLG_PutEx(hGrid1,a_strGridData(),4, lngRefresh)
        '
        ' set the width of each column(except column 1)
        ' to the width of the data or column header
        lngExcludeColumn = 1
        funWidenColumnsInGrid(hGrid1,lngExcludeColumn)
        ' mark the whole grid as read only
        funMarkGridasReadOnly(hGrid1)
        ' display the finished grid to the user
        funGridRefresh(hGrid1)
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
          ' exit the dialog
            DIALOG END CB.HNDL
          END IF
      END SELECT
  END SELECT
END FUNCTION
'------------------------------------------------------------------------------

'------------------------------------------------------------------------------
FUNCTION ShowdlgViewForms(BYVAL hParent AS DWORD) AS LONG
  LOCAL lRslt AS LONG
  LOCAL strColumnHeaders AS STRING
  LOCAL lngColumns AS LONG
  LOCAL lngRows AS LONG
  '
  strColumnHeaders = funGetColumnNames()
  lngColumns = PARSECOUNT(strColumnHeaders,",")
  lngRows = UBOUND(g_strFormData)
  '
#PBFORMS BEGIN DIALOG %IDD_dlgViewForms->->
  LOCAL hDlg  AS DWORD

  DIALOG NEW hParent, "View Forms", 125, 76, 500, 300, %WS_POPUP OR %WS_BORDER _
    OR %WS_DLGFRAME OR %WS_CAPTION OR %WS_SYSMENU OR %WS_MINIMIZEBOX OR _
    %WS_MAXIMIZEBOX OR %WS_CLIPSIBLINGS OR %WS_VISIBLE OR %DS_MODALFRAME OR _
    %DS_CENTER OR %DS_3DLOOK OR %DS_NOFAILCREATE OR %DS_SETFONT, _
    %WS_EX_CONTROLPARENT OR %WS_EX_LEFT OR %WS_EX_LTRREADING OR _
    %WS_EX_RIGHTSCROLLBAR, TO hDlg
  CONTROL ADD BUTTON, hDlg, %IDABORT, "Close Grid", 20, 280, 65, 15, _
    %WS_CHILD OR %WS_VISIBLE OR %WS_TABSTOP OR %BS_TEXT OR %BS_PUSHBUTTON OR _
    %BS_RIGHT OR %BS_VCENTER, %WS_EX_LEFT OR %WS_EX_LTRREADING
#PBFORMS END DIALOG
'
  DIALOG SET ICON hDlg,"#" & FORMAT$(%IDR_IMGGrid)
  '
  PREFIX "ButtonPlus hDlg, %IDABORT, "
    %BP_ICON_ID, %IDR_IMGCancel
    %BP_ICON_WIDTH, 48
    %BP_ICON_POS, %BS_LEFT
  END PREFIX
 '
  ' Set the dimensions of the grid
  LOCAL lngGridX, lngGridY AS LONG
  LOCAL lngGridWidth, lngGridHeight AS LONG
  lngGridX = 10
  lngGridY = 20
  lngGridWidth = 470
  lngGridHeight = 250
'
' Set the options in the right click menu for the grid
  LOCAL strMenu AS STRING
  strMenu = ""
  ' add the grid control
  CONTROL ADD "MYLITTLEGRID", hDlg, %IDC_MLGGRID1, _
          "x20" & "/d-0/e1/r" & FORMAT$(lngRows) & _
          strMenu & "/c" & _
          FORMAT$(lngColumns) & "/a2/y3", _
          lngGridX, lngGridY, lngGridWidth, lngGridHeight, %MLG_STYLE
  '
   '
  ' capture the windows handle to the grid
  CONTROL HANDLE hDlg, %IDC_MLGGRID1 TO hGrid1
  '
  ' prepare the grid with tab/sheet number 1 with form title
  mPrepGrid(hGrid1,lngRows,lngColumns," " & funGetFormTitle & " ", 1)
  '
  ' set the names of each column
  funSetColumnNames(hGrid1,strColumnHeaders)
  '
  ' set any tickbox/checkbox columns
  funSetGridTickboxes(hGrid1,strColumnHeaders)
  '
  ' colour alternate rows for readability
  funColourBankGridRows(hGrid1,%RGB_LIGHTGREEN)
  '
  ' refresh the grid on screen
  funGridRefresh(hGrid1)
  '
  DIALOG SHOW MODAL hDlg, CALL ShowdlgViewFormsProc TO lRslt

#PBFORMS BEGIN CLEANUP %IDD_dlgViewForms
#PBFORMS END CLEANUP

  FUNCTION = lRslt
END FUNCTION
'------------------------------------------------------------------------------
FUNCTION funGetFormTitle() AS STRING
' return the name of the form
  LOCAL lngObjectColumn AS LONG
  LOCAL strObject AS STRING
  LOCAL lngR AS LONG
  LOCAL strTitle AS STRING
  LOCAL lngTextColumn AS LONG
  '
  ' get the column number the Object is in
  lngObjectColumn = funParseFind(ga_strConfig(0),"", "Object")
  ' get the column number the Text is in
  lngTextColumn = funParseFind(ga_strConfig(0),"", "Text")
  '
  FOR lngR = 1 TO UBOUND(ga_strConfig)
    strObject = PARSE$(ga_strConfig(lngR),"",lngObjectColumn)
    IF strObject = "Title" THEN
      ' get the title of the form
      strTitle = PARSE$(ga_strConfig(lngR),"",lngTextColumn)
      EXIT FOR
    END IF
  NEXT lngR
  '
  FUNCTION = strTitle
  '
END FUNCTION
'
FUNCTION funGetColumnNames() AS STRING
' return the column headings
  LOCAL lngR AS LONG
  LOCAL lngFieldNameColumn AS LONG
  LOCAL lngObjectColumn AS LONG
  LOCAL strObject AS STRING
  LOCAL strFieldName AS STRING
  LOCAL strHeaders AS STRING
  '
  ' get the column number the Object is in
  lngFieldNameColumn = funParseFind(ga_strConfig(0),"", "Fieldname")
  '
  ' get the column number the Object is in
  lngObjectColumn = funParseFind(ga_strConfig(0),"", "Object")
  '
  strHeaders = "ID,"
  '
  FOR lngR = 1 TO UBOUND(ga_strConfig)
    strObject = PARSE$(ga_strConfig(lngR),"",lngObjectColumn)
    IF strObject <> "Button" THEN
    ' dont look at buttons
      strFieldname = PARSE$(ga_strConfig(lngR),"",lngFieldNameColumn)
      ' pick up the value in fieldname column
      IF strFieldname <> "" THEN
      ' add to the headers
        strHeaders = strHeaders & strFieldname & ","
      END IF
      '
    END IF
  NEXT lngR
  ' return the column headers
  strHeaders = RTRIM$(strHeaders,",")
  '
  FUNCTION = strHeaders
  '
END FUNCTION
'
FUNCTION funPopulate_the_grid_array(hGrid1 AS DWORD, _
                                    BYREF a_strGridData() AS STRING) AS LONG
' populate the 2 dimensional array for the grid
  LOCAL lngColumns AS LONG
  LOCAL lngRows AS LONG
  LOCAL lngR AS LONG
  LOCAL lngC AS LONG
  LOCAL strData AS STRING
  '
  lngRows = UBOUND(g_strFormData)
  lngColumns = PARSECOUNT(g_strFormData(0),"")
  '
  REDIM a_strGridData(lngRows,lngColumns + 1)
  '
  FOR lngR = 1 TO lngRows
    ' add the ID column data
    a_strGridData(lngR,1) = FORMAT$(lngR)
    '
    FOR lngC = 1 TO lngColumns
    ' pick up the data for each column
      strData = PARSE$(g_strFormData(lngR),"",lngC)
      a_strGridData(lngR,lngC + 1) = strData
    NEXT lngC
  NEXT lngR
  '
END FUNCTION
'
FUNCTION funSetGridTickboxes(hGrid1 AS DWORD, _
                             strColumnHeaders AS STRING) AS LONG
' look for tickboxes/checkboxes in config file
  LOCAL lngR AS LONG                ' used for each header
  LOCAL lngC AS LONG                ' row in the config array
  LOCAL lngFieldNameColumn AS LONG  ' field name column
  LOCAL lngObjectColumn AS LONG     ' object name column
  LOCAL strObject AS STRING         ' object name
  LOCAL strHeader AS STRING         ' header column name
  '
  ' get the column number the Object is in
  lngFieldNameColumn = funParseFind(ga_strConfig(0),"", "Fieldname")
  ' get the column number the Object is in
  lngObjectColumn = funParseFind(ga_strConfig(0),"", "Object")
  '
  FOR lngR = 1 TO PARSECOUNT(strColumnHeaders,",")
  ' check each column header for matches in the config file
    strHeader = PARSE$(strColumnHeaders,",",lngR)
    '
    FOR lngC = 1 TO UBOUND(ga_strConfig)
      IF PARSE$(ga_strConfig(lngC),"",lngFieldNameColumn) = strHeader THEN
      ' found the field we are looking for
        IF PARSE$(ga_strConfig(lngC),"",lngObjectColumn) = "Tickbox" THEN
        ' its a tickbox/checkbox
          MLG_FormatColCheck hGrid1,lngR  ' set column to be checkbox
          ' move to next header
          ITERATE FOR
          '
        ELSE
          ' move to next header
          ITERATE FOR
        END IF
        '
      END IF
    NEXT lngC
    '
  NEXT lngR
  '
END FUNCTION
