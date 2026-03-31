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
#RESOURCE "FormRunner.pbr"
%USEMACROS = 1
#INCLUDE ONCE "WIN32API.INC"
#INCLUDE ONCE "COMMCTRL.INC"
#INCLUDE ONCE "PBForms.INC"
#PBFORMS END INCLUDES

'------------------------------------------------------------------------------
$FormFolder    = "Forms\"
$ConfigsFolder = "Configs\
$FormApp       = "Forms\AutoForm.exe"
'------------------------------------------------------------------------------
'   ** Constants **
'------------------------------------------------------------------------------
#PBFORMS BEGIN CONSTANTS
%IDD_dlgFormRunner    =  101
%IDC_STATUSBAR1       = 1001
%IDC_lblSelect_a_form = 1002
%IDC_RUNFORM          = 1005
%IDABORT              =    3
%IDC_LISTBOX          = 1006
#PBFORMS END CONSTANTS
'------------------------------------------------------------------------------

'------------------------------------------------------------------------------
'   ** Declarations **
'------------------------------------------------------------------------------
DECLARE CALLBACK FUNCTION ShowdlgFormRunnerProc()
DECLARE FUNCTION SampleListView(BYVAL hDlg AS DWORD, BYVAL lID AS LONG, BYVAL _
  lColCnt AS LONG, BYVAL lRowCnt AS LONG) AS LONG
DECLARE FUNCTION ShowdlgFormRunner(BYVAL hParent AS DWORD) AS LONG
#PBFORMS DECLARATIONS
'------------------------------------------------------------------------------

'------------------------------------------------------------------------------
'   ** Main Application Entry Point **
'------------------------------------------------------------------------------
FUNCTION PBMAIN()
  PBFormsInitComCtls (%ICC_WIN95_CLASSES OR %ICC_DATE_CLASSES OR _
    %ICC_INTERNET_CLASSES)

  ShowdlgFormRunner %HWND_DESKTOP
END FUNCTION
'------------------------------------------------------------------------------

'------------------------------------------------------------------------------
'   ** CallBacks **
'------------------------------------------------------------------------------
CALLBACK FUNCTION ShowdlgFormRunnerProc()
  LOCAL strForm AS STRING
  '
  SELECT CASE AS LONG CB.MSG
    CASE %WM_INITDIALOG
    ' Initialization handler
      funPopulateList(CB.HNDL,%IDC_LISTBOX)
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
        ' /* Inserted by PB/Forms 09-01-2023 08:18:41
        ' */

        CASE %IDC_STATUSBAR1

        CASE %IDABORT
          IF CB.CTLMSG = %BN_CLICKED OR CB.CTLMSG = 1 THEN
            DIALOG END CB.HNDL
          END IF

        CASE %IDC_RUNFORM
          IF CB.CTLMSG = %BN_CLICKED OR CB.CTLMSG = 1 THEN
          ' run the form selected
            ' get the name of the selected form
            LISTBOX GET TEXT CB.HNDL, %IDC_LISTBOX TO strForm
            IF strForm <> "" THEN
              strForm = PARSE$(strForm,ANY "()",2)
              ' now run the form
              SHELL EXE.PATH$ & $FormApp & " " & _
                                $ConfigsFolder & _
                                strForm
            END IF
          '
          END IF

      END SELECT
  END SELECT
END FUNCTION
'------------------------------------------------------------------------------


'------------------------------------------------------------------------------
'   ** Dialogs **
'------------------------------------------------------------------------------
FUNCTION ShowdlgFormRunner(BYVAL hParent AS DWORD) AS LONG
  LOCAL lRslt  AS LONG

#PBFORMS BEGIN DIALOG %IDD_dlgFormRunner->->
  LOCAL hDlg   AS DWORD
  LOCAL hFont1 AS DWORD

  DIALOG NEW hParent, "Select a Form", 261, 130, 400, 255, %WS_POPUP OR _
    %WS_BORDER OR %WS_DLGFRAME OR %WS_CAPTION OR %WS_SYSMENU OR _
    %WS_MINIMIZEBOX OR %WS_CLIPSIBLINGS OR %WS_VISIBLE OR %DS_MODALFRAME OR _
    %DS_CENTER OR %DS_3DLOOK OR %DS_NOFAILCREATE OR %DS_SETFONT, _
    %WS_EX_CONTROLPARENT OR %WS_EX_LEFT OR %WS_EX_LTRREADING OR _
    %WS_EX_RIGHTSCROLLBAR, TO hDlg
  CONTROL ADD STATUSBAR, hDlg, %IDC_STATUSBAR1, "Ready", 0, 0, 0, 0
  CONTROL ADD LABEL,     hDlg, %IDC_lblSelect_a_form, "Select a Form to Run", _
    20, 10, 220, 20
  CONTROL SET COLOR      hDlg, %IDC_lblSelect_a_form, %BLUE, -1
  CONTROL ADD BUTTON,    hDlg, %IDABORT, "Exit", 20, 210, 50, 15
  CONTROL ADD BUTTON,    hDlg, %IDC_RUNFORM, "Run Form", 315, 210, 50, 15
  CONTROL ADD LISTBOX,   hDlg, %IDC_LISTBOX, , 20, 30, 345, 170

  FONT NEW "MS Sans Serif", 14, 0, %ANSI_CHARSET TO hFont1

  CONTROL SET FONT hDlg, %IDC_lblSelect_a_form, hFont1
  CONTROL SET FONT hDlg, %IDC_LISTBOX, hFont1
#PBFORMS END DIALOG

  DIALOG SHOW MODAL hDlg, CALL ShowdlgFormRunnerProc TO lRslt

#PBFORMS BEGIN CLEANUP %IDD_dlgFormRunner
  FONT END hFont1
#PBFORMS END CLEANUP

  FUNCTION = lRslt
END FUNCTION
'------------------------------------------------------------------------------
FUNCTION funPopulateList(hDlg AS DWORD, _
                         lID AS LONG) AS LONG
  LOCAL lngRow   AS LONG
  LOCAL a_strForms() AS STRING
  '
  ' get the title of the available forms
  IF ISTRUE funGetFormList(a_strForms()) THEN
    ' get the list of forms available
    ' populate list with data
    FOR lngRow = 1 TO UBOUND(a_strForms)
      LISTBOX ADD hDlg, lID, a_strForms(lngRow)
    NEXT lngRow
    '
  END IF
  '
END FUNCTION
'
FUNCTION funGetFormList(BYREF a_strForms() AS STRING) AS LONG
' return the list of forms
  LOCAL strFolder AS STRING
  LOCAL strFileName AS STRING
  LOCAL lngCount AS LONG
  LOCAL lngFile AS LONG
  LOCAL strField AS STRING
  '
  strFolder = EXE.PATH$ & $FormFolder & _
                          $ConfigsFolder
                          '
  REDIM a_strForms(1 TO 100) AS STRING
  '
  strFileName = DIR$(strFolder & "*.csv")
  '
  WHILE strFileName <> ""
    INCR lngCount ' advance the file counter
    ' found a file - open it and read title
    lngFile = FREEFILE
    '
    TRY
      OPEN strFolder & strFileName FOR INPUT AS #lngFile
      '
      IF lngCount > UBOUND(a_strForms) THEN
      ' increase array size when needed
        REDIM PRESERVE a_strForms(1 TO lngCount+100)
      END IF
      '
      LINE INPUT #lngFile, strField
      DO UNTIL PARSE$(strField,"",1) = "Title" OR ISTRUE EOF(#lngFile)
      ' read rows until title row is found
        LINE INPUT #lngFile, strField
      LOOP
      '
      IF ISFALSE EOF(#lngFile) THEN
      ' store title and name of form file
        a_strForms(lngCount) = PARSE$(strField,"",2) & _
                               " (" & strFileName & ")"
      END IF
      '
    CATCH
    ' catch the error
      FUNCTION = %FALSE
    '
    FINALLY
      CLOSE #lngFile
    END TRY
    '
    strFileName = DIR$ ' get the next file
  WEND
  '
  IF lngCount > 0 THEN
    REDIM PRESERVE a_strForms(1 TO lngCount)
    FUNCTION = %TRUE
  ELSE
    FUNCTION = %FALSE
  END IF
  '
END FUNCTION
