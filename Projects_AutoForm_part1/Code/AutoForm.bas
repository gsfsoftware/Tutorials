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
#INCLUDE "PB_FileHandlingRoutines.inc"
'------------------------------------------------------------------------------
'   ** Constants **
'------------------------------------------------------------------------------
#PBFORMS BEGIN CONSTANTS
%IDD_dlgMain    =  101
%IDC_STATUSBAR1 = 1001
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

  DIALOG NEW hParent, "Title", 125, 76, 957, 507, %WS_POPUP OR %WS_BORDER OR _
    %WS_DLGFRAME OR %WS_CAPTION OR %WS_SYSMENU OR %WS_MINIMIZEBOX OR _
    %WS_MAXIMIZEBOX OR %WS_CLIPSIBLINGS OR %WS_VISIBLE OR %DS_MODALFRAME OR _
    %DS_CENTER OR %DS_3DLOOK OR %DS_NOFAILCREATE OR %DS_SETFONT, _
    %WS_EX_CONTROLPARENT OR %WS_EX_LEFT OR %WS_EX_LTRREADING OR _
    %WS_EX_RIGHTSCROLLBAR, TO hDlg
  CONTROL ADD STATUSBAR, hDlg, %IDC_STATUSBAR1, "", 0, 0, 0, 0
#PBFORMS END DIALOG
  g_hDlg = hDlg ' store the handle of the dialog
  DIALOG SHOW MODAL hDlg, CALL ShowdlgMainProc TO lRslt

#PBFORMS BEGIN CLEANUP %IDD_dlgMain
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
  strHeaders = ga_strConfig(0) ' store headers
  '
  FOR lngR = 1 TO UBOUND(ga_strConfig)
    IF ga_strConfig(lngR) = "" THEN ITERATE
    strData = ga_strConfig(lngR)
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
        CONTROL ADD BUTTON, g_hDlg,VAL(PARSE$(strData,"",%Ref_ID)), _
                                  PARSE$(strData,"",%Ref_Text), _
                                  VAL(PARSE$(strData,"",%Ref_X)), _
                                  VAL(PARSE$(strData,"",%Ref_Y)), _
                                  VAL(PARSE$(strData,"",%Ref_Width)), _
                                  VAL(PARSE$(strData,"",%Ref_Height))
      '
      CASE "Label"
        CONTROL ADD LABEL,g_hDlg,VAL(PARSE$(strData,"",%Ref_ID)), _
                                  PARSE$(strData,"",%Ref_Text), _
                                  VAL(PARSE$(strData,"",%Ref_X)), _
                                  VAL(PARSE$(strData,"",%Ref_Y)), _
                                  VAL(PARSE$(strData,"",%Ref_Width)), _
                                  VAL(PARSE$(strData,"",%Ref_Height))
        CONTROL SET COLOR g_hDlg,VAL(PARSE$(strData,"",%Ref_ID)),%BLUE,-1
      '
      CASE "Text"
        CONTROL ADD TEXTBOX,g_hDlg,VAL(PARSE$(strData,"",%Ref_ID)), _
                                  PARSE$(strData,"",%Ref_Text), _
                                  VAL(PARSE$(strData,"",%Ref_X)), _
                                  VAL(PARSE$(strData,"",%Ref_Y)), _
                                  VAL(PARSE$(strData,"",%Ref_Width)), _
                                  VAL(PARSE$(strData,"",%Ref_Height))

    END SELECT
  NEXT lngR
  '
  ' set focus to the first editable object?
  FOR lngR = 1 TO UBOUND(ga_strConfig)
    strData = ga_strConfig(lngR)
    '
    SELECT CASE PARSE$(strData,"",%REF_Object)
      CASE "Text"
        lngControl = VAL(PARSE$(strData,"",%Ref_ID))
        CONTROL SET FOCUS g_hDlg,lngControl
        EXIT FOR
    END SELECT
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
