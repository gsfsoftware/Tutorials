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
#RESOURCE "AutoForm.pbr"
%USEMACROS = 1
#INCLUDE ONCE "WIN32API.INC"
#INCLUDE ONCE "COMMCTRL.INC"
#INCLUDE ONCE "PBForms.INC"
#PBFORMS END INCLUDES
'------------------------------------------------------------------------------
#INCLUDE "PB_Common_Strings.inc"
#INCLUDE "PB_FileHandlingRoutines.inc"
#INCLUDE "Tooltips.inc"
'------------------------------------------------------------------------------
'   ** Constants **
'------------------------------------------------------------------------------
#PBFORMS BEGIN CONSTANTS
%IDD_dlgMain    =  101
%IDC_STATUSBAR1 = 1001
%IDC_lblStatus  = 1002
#PBFORMS END CONSTANTS
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
END ENUM
'------------------------------------------------------------------------------
'   ** Declarations **
'------------------------------------------------------------------------------
DECLARE CALLBACK FUNCTION ShowdlgMainProc()
DECLARE FUNCTION ShowdlgMain(BYVAL hParent AS DWORD) AS LONG
#PBFORMS DECLARATIONS
'------------------------------------------------------------------------------
GLOBAL ga_strConfig() AS STRING    ' the configuration file
GLOBAL g_hDlg AS DWORD             ' global for the current form
'
GLOBAL g_strConfigFolder AS STRING ' the folder holding the config data
'------------------------------------------------------------------------------
'   ** Main Application Entry Point **
'------------------------------------------------------------------------------
FUNCTION PBMAIN()
  LOCAL strConfigFile AS STRING
  '
  PBFormsInitComCtls (%ICC_WIN95_CLASSES OR %ICC_DATE_CLASSES OR _
    %ICC_INTERNET_CLASSES)
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
  ' set a default font for this application
  DIALOG DEFAULT FONT "MS Sans Serif", 14, 0, %ANSI_CHARSET
  '
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
      funPopulateForm()  ' populate the form from the config
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
      funRunControlProcess(CB.HNDL,CB.CTL,CB.CTLMSG)
      '
      SELECT CASE AS LONG CB.CTL
        CASE %IDC_STATUSBAR1

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

  FONT NEW "MS Sans Serif", 14, 0, %ANSI_CHARSET TO hFont1

  CONTROL SET FONT hDlg, %IDC_lblStatus, hFont1
#PBFORMS END DIALOG
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
  ' set focus to the first editable object?
  funSetFocusToStartOfForm()
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
        CASE "Button"
          IF lngMessage = %BN_CLICKED OR lngMessage = 1 THEN
          ' button has been clicked on
            SELECT CASE strObjectFunction
              CASE "SAVE"
              ' save data
                ' first validate data on form
                IF ISTRUE funValidateForm(strError, lngField) THEN
                  IF ISTRUE funSaveFormData(lngControl,"Fieldname") THEN
                  ' confirm to user then clear the form
                    CONTROL SET TEXT g_hDlg,%IDC_lblStatus,"Form Saved"
                    '
                    funResetForm()
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
  IF ISFALSE ISFILE(strOutput) THEN
  ' if no file exists output the headers to the file
    funAppendToFile(strOutput,funGetConfigHeaders())
  END IF
  '
  ' now get the data
  strData = funGetFormData()
  ' append to the file
  FUNCTION = funAppendToFile(strOutput, _
                             strData)
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
  ' get the column number the Object is in
  lngObjectColumn = funParseFind(ga_strConfig(0),"", "Object") '
  '
  ' get the column number the ID is in
  lngIDcolumn = funParseFind(ga_strConfig(0),"", "ID")
  '
  FOR lngR = 1 TO UBOUND(ga_strConfig)
  ' get the control ID
    lngControl = VAL(PARSE$(ga_strConfig(lngR),"",lngIDcolumn))
    '
    SELECT CASE PARSE$(ga_strConfig(lngR),"",lngObjectColumn)
      CASE "Text"
        ' wipe the text in the control
        CONTROL SET TEXT g_hDlg,lngControl,""
        '
      CASE "Dropdownlist"
      ' unselect the combobox
        COMBOBOX UNSELECT g_hDlg,lngControl
      CASE "Listbox"
      ' unselect the text in the control
        LISTBOX UNSELECT g_hDlg,lngControl
      '
      CASE ELSE
        ITERATE FOR
    END SELECT
    '
  NEXT lngR
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
