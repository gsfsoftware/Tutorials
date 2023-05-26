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
#RESOURCE "ProjectCreator.pbr"
%USEMACROS = 1
#INCLUDE ONCE "WIN32API.INC"
#INCLUDE ONCE "COMMCTRL.INC"
#INCLUDE ONCE "PBForms.INC"
#PBFORMS END INCLUDES
'------------------------------------------------------------------------------
#INCLUDE ONCE "PB_Windows_Controls.inc"
'------------------------------------------------------------------------------
'   ** Constants **
'------------------------------------------------------------------------------
#PBFORMS BEGIN CONSTANTS
%IDD_dlgProjectCreator =  101
%IDC_STATUSBAR1        = 1001
%IDC_lblProjectName    = 1002
%IDC_txtProjectName    = 1003
%IDC_lblVideoType      = 1005
%IDC_cboVideoType      = 1004
%IDC_lblSelectTemplate = 1007
%IDC_cboSelectTemplate = 1006
%IDC_btnCreateProject  = 1008
%IDABORT               =    3
#PBFORMS END CONSTANTS
'------------------------------------------------------------------------------
$VideoVault = "H:\Youtube\"  ' set location of Video Vault
'------------------------------------------------------------------------------
'   ** Declarations **
'------------------------------------------------------------------------------
DECLARE CALLBACK FUNCTION ShowdlgProjectCreatorProc()
DECLARE FUNCTION SampleComboBox(BYVAL hDlg AS DWORD, BYVAL lID AS LONG, BYVAL _
  lCount AS LONG) AS LONG
DECLARE FUNCTION ShowdlgProjectCreator(BYVAL hParent AS DWORD) AS LONG
#PBFORMS DECLARATIONS
'------------------------------------------------------------------------------

'------------------------------------------------------------------------------
'   ** Main Application Entry Point **
'------------------------------------------------------------------------------
FUNCTION PBMAIN()
  PBFormsInitComCtls (%ICC_WIN95_CLASSES OR %ICC_DATE_CLASSES OR _
    %ICC_INTERNET_CLASSES)

  ShowdlgProjectCreator %HWND_DESKTOP
END FUNCTION
'------------------------------------------------------------------------------
FUNCTION funGetTemplates(BYREF a_strData() AS STRING, _
                         strVideoType AS STRING) AS LONG
                         '
  LOCAL strPath AS STRING
  LOCAL strFilename AS STRING
  LOCAL lngCounter AS LONG
  '
  ' first empty out the array
  IF strVideoType = "" THEN
    DIM a_strData() AS STRING
  ELSE
  '
    strPath = EXE.PATH$ & "..\Templates\" & strVideoType
    ' prepare an array to hold the filenames
    REDIM a_strData(1 TO 100) AS STRING
    ' get the first filename
    strFilename = DIR$(strPath & "\*.pptx")
    '
    WHILE strFileName <> ""
    ' loop and get all file names in the folder
      INCR lngCounter
      ' save into the next slot in the array
      a_strData(lngCounter) = strFilename
      strFilename = DIR$
    WEND
    ' shorten the array to just the elements you have populated
    REDIM PRESERVE a_strData(1 TO lngCounter) AS STRING
    FUNCTION = %TRUE
  '
  END IF
'
END FUNCTION
'------------------------------------------------------------------------------
'   ** CallBacks **
'------------------------------------------------------------------------------
CALLBACK FUNCTION ShowdlgProjectCreatorProc()
  '
  DIM a_strData() AS STRING
  LOCAL strVideoType AS STRING
  LOCAL strProjectName AS STRING
  LOCAL strSelectTemplate AS STRING
  '
  SELECT CASE AS LONG CB.MSG
    CASE %WM_INITDIALOG
      ' Initialization handler
      ' populate the combos
      ' set up the array with values
      REDIM a_strData(1 TO 2) AS STRING
      ARRAY ASSIGN a_strData() = "Hardware","PowerBasic"
      ' populate the first combo list
      funPopulateCombo(CB.HNDL, _
                       %IDC_cboVideoType, _
                       BYREF a_strData(), _
                       "PowerBasic")
                       '
      ' get the list of files in the selected template folder
      CONTROL GET TEXT CB.HNDL,%IDC_cboVideoType TO strVideoType
      funGetTemplates(a_strData(),strVideoType)
      ' now populate the combo list
      funPopulateCombo(CB.HNDL, _
                       %IDC_cboSelectTemplate, _
                       BYREF a_strData(), _
                       "PowerBasic")
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
        CASE %IDC_STATUSBAR1

        CASE %IDC_txtProjectName

        CASE %IDC_cboVideoType

        CASE %IDC_cboSelectTemplate

        CASE %IDC_btnCreateProject
          IF CB.CTLMSG = %BN_CLICKED OR CB.CTLMSG = 1 THEN
          ' button has been clicked
          ' gather data from screen
            PREFIX "control get text cb.hndl,"
              %IDC_txtProjectName TO strProjectName
              %IDC_cboVideoType TO strVideoType
              %IDC_cboSelectTemplate TO strSelectTemplate
            END PREFIX
            '
            ' now validate that mandatory fields have been filled in
            IF strProjectName = "" THEN
            ' field missed so highlight it
              CONTROL SET FOCUS CB.HNDL,%IDC_txtProjectName
              CONTROL SET TEXT CB.HNDL,%IDC_STATUSBAR1, _
                               "Selection missing"
              CONTROL SET COLOR CB.HNDL,%IDC_lblProjectname,%RED,-1
              CONTROL REDRAW CB.HNDL,%IDC_lblProjectname
              EXIT FUNCTION
            ELSE
            ' field not missed so set its colour back to blue
              CONTROL SET COLOR CB.HNDL,%IDC_lblProjectname,%BLUE,-1
              CONTROL REDRAW CB.HNDL,%IDC_lblProjectname
            END IF
            '
            IF strVideoType = "" THEN
              ' highlight the error using the library function
              funHighlightControl(CB.HNDL, _
                             %IDC_cboVideoType, _
                             %IDC_lblVideoType, _
                             %RED, _
                             %IDC_STATUSBAR1, _
                             "Selection missing")
              EXIT FUNCTION
            ELSE
              ' clear the highlight using the library function
              funClearHighlight(CB.HNDL, _
                           %IDC_lblVideoType, _
                           %BLUE, _
                           %IDC_STATUSBAR1, _
                           "Ready")
            END IF
            '
            IF strSelectTemplate = "" THEN
              ' highlight the error using the library function
              funHighlightControl(CB.HNDL, _
                             %IDC_cboSelectTemplate, _
                             %IDC_lblSelectTemplate, _
                             %RED, _
                             %IDC_STATUSBAR1, _
                             "Selection missing")
              EXIT FUNCTION
            ELSE
              ' clear the highlight using the library function
              funClearHighlight(CB.HNDL, _
                           %IDC_lblSelectTemplate, _
                           %BLUE, _
                           %IDC_STATUSBAR1, _
                           "Ready")
            END IF
            '
            ' now take the data and build the project folders
            IF ISTRUE funBuildProject(strProjectName, _
                                      strVideoType, _
                                      strSelectTemplate) THEN
              CONTROL SET TEXT CB.HNDL,%IDC_STATUSBAR1,"Build Successful"
            ELSE
              CONTROL SET TEXT CB.HNDL,%IDC_STATUSBAR1,"Build Unsuccessful"
            END IF
            '
          END IF

        CASE %IDABORT
          IF CB.CTLMSG = %BN_CLICKED OR CB.CTLMSG = 1 THEN
          ' exit the dialog
            DIALOG END CB.HNDL
          END IF
          '
      END SELECT
  END SELECT
END FUNCTION
'------------------------------------------------------------------------------

FUNCTION funBuildProject(strProjectName AS STRING, _
                         strVideoType AS STRING, _
                         strSelectTemplate AS STRING) AS LONG
' build the new project
  LOCAL strPath AS STRING
  LOCAL strNewSelectTemplate AS STRING
  LOCAL strSourcePath AS STRING
  '
  ' set the path to the project folder
  strPath = $VideoVault & strVideoType & "\" & strProjectName
  '
  IF ISTRUE ISFOLDER(strPath) THEN
  ' folder already exists
    MSGBOX "Project name already exists", _
            %MB_ICONERROR OR %MB_TASKMODAL, _
            "Project Error"
            '
    FUNCTION = %FALSE
  '
  ELSE
  ' folder does not exist - so continue
    ERRCLEAR
    TRY
    ' create the folder
      MKDIR strPath
      ' folder created
      TRY
        ' create the recordings folder
        MKDIR strPath & "\Recordings"
        ' now copy the templates
        strSourcePath = EXE.PATH$ & "..\Templates\" & _
                        strVideoType & "\" & strSelectTemplate
                        '
        ERRCLEAR
        ' copy the template file
        FILECOPY strSourcePath,strPath & "\" & strSelectTemplate
        '
        IF ERR = 0 THEN
        ' no error
          strNewSelectTemplate = strSelectTemplate
          ' set the new template name
          REPLACE "xxxx" WITH strProjectName IN strNewSelectTemplate
          ' now rename the file
          ERRCLEAR
          NAME strPath & "\" & strSelectTemplate AS _
               strPath & "\" & strNewSelectTemplate
               '
          IF ERR = 0 THEN
            FUNCTION = %TRUE
          ELSE
          ' failure to rename
            MSGBOX "Unable to rename Powerpoint file" & $CRLF & _
             ERROR$, _
            %MB_ICONERROR OR %MB_TASKMODAL, _
            "Project Error"
            FUNCTION = %FALSE
          '
          END IF
        '
        ELSE
        ' an error occurred
          MSGBOX "Unable to copy Powerpoint file" & $CRLF & _
             ERROR$, _
            %MB_ICONERROR OR %MB_TASKMODAL, _
            "Project Error"
          FUNCTION = %FALSE
        END IF
        '
      CATCH
        MSGBOX "Unable to create Recordings folder" & $CRLF & _
             ERROR$, _
            %MB_ICONERROR OR %MB_TASKMODAL, _
            "Project Error"
      FINALLY
      END TRY
      '
    CATCH
      MSGBOX "Unable to create Project folder" & $CRLF & _
             ERROR$, _
            %MB_ICONERROR OR %MB_TASKMODAL, _
            "Project Error"
    FINALLY
    END TRY
  '
  END IF
'
END FUNCTION

'------------------------------------------------------------------------------
'   ** Dialogs **
'------------------------------------------------------------------------------
FUNCTION ShowdlgProjectCreator(BYVAL hParent AS DWORD) AS LONG
  LOCAL lRslt AS LONG

#PBFORMS BEGIN DIALOG %IDD_dlgProjectCreator->->
  LOCAL hDlg  AS DWORD

  DIALOG NEW hParent, "Project Creator", 210, 136, 641, 335, %WS_POPUP OR _
    %WS_BORDER OR %WS_DLGFRAME OR %WS_CAPTION OR %WS_SYSMENU OR _
    %WS_MINIMIZEBOX OR %WS_CLIPSIBLINGS OR %WS_VISIBLE OR %DS_MODALFRAME OR _
    %DS_CENTER OR %DS_3DLOOK OR %DS_NOFAILCREATE OR %DS_SETFONT, _
    %WS_EX_CONTROLPARENT OR %WS_EX_LEFT OR %WS_EX_LTRREADING OR _
    %WS_EX_RIGHTSCROLLBAR, TO hDlg
  CONTROL ADD STATUSBAR, hDlg, %IDC_STATUSBAR1, "Ready", 0, 0, 0, 0
  CONTROL ADD LABEL,     hDlg, %IDC_lblProjectName, "Enter Project name", 40, _
    25, 100, 10
  CONTROL SET COLOR      hDlg, %IDC_lblProjectName, %BLUE, -1
  CONTROL ADD TEXTBOX,   hDlg, %IDC_txtProjectName, "", 40, 35, 215, 15
  CONTROL ADD COMBOBOX,  hDlg, %IDC_cboVideoType, , 285, 35, 175, 40, _
    %WS_CHILD OR %WS_VISIBLE OR %WS_TABSTOP OR %CBS_DROPDOWNLIST OR _
    %CBS_SORT, %WS_EX_LEFT OR %WS_EX_LTRREADING OR %WS_EX_RIGHTSCROLLBAR
  CONTROL ADD LABEL,     hDlg, %IDC_lblVideoType, "Select Video Type", 285, _
    25, 100, 10
  CONTROL SET COLOR      hDlg, %IDC_lblVideoType, %BLUE, -1
  CONTROL ADD COMBOBOX,  hDlg, %IDC_cboSelectTemplate, , 285, 85, 175, 40, _
    %WS_CHILD OR %WS_VISIBLE OR %WS_TABSTOP OR %CBS_DROPDOWNLIST OR _
    %CBS_SORT, %WS_EX_LEFT OR %WS_EX_LTRREADING OR %WS_EX_RIGHTSCROLLBAR
  CONTROL ADD LABEL,     hDlg, %IDC_lblSelectTemplate, "Select Template", _
    285, 75, 100, 10
  CONTROL SET COLOR      hDlg, %IDC_lblSelectTemplate, %BLUE, -1
  CONTROL ADD BUTTON,    hDlg, %IDC_btnCreateProject, "Create Project", 495, _
    280, 85, 20
  CONTROL ADD BUTTON,    hDlg, %IDABORT, "Exit", 35, 285, 50, 15
#PBFORMS END DIALOG

  DIALOG SHOW MODAL hDlg, CALL ShowdlgProjectCreatorProc TO lRslt

#PBFORMS BEGIN CLEANUP %IDD_dlgProjectCreator
#PBFORMS END CLEANUP

  FUNCTION = lRslt
END FUNCTION
'------------------------------------------------------------------------------
