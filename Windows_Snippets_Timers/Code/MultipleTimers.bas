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
#RESOURCE "MultipleTimers.pbr"
#INCLUDE ONCE "WIN32API.INC"
#INCLUDE ONCE "COMMCTRL.INC"
#INCLUDE ONCE "PBForms.INC"
#PBFORMS END INCLUDES
'------------------------------------------------------------------------------

'------------------------------------------------------------------------------
'   ** Constants **
'------------------------------------------------------------------------------
#PBFORMS BEGIN CONSTANTS
%IDD_dlgTimeDemo =  101
%IDABORT         =    3
%IDC_txtData     = 1001
%IDC_lblTime     = 1002
%IDC_lblData     = 1003
#PBFORMS END CONSTANTS
'------------------------------------------------------------------------------
%ID_TIMER1    = 2000    ' timers
%ID_TIMER2    = 2001
'------------------------------------------------------------------------------
'   ** Declarations **
'------------------------------------------------------------------------------
DECLARE CALLBACK FUNCTION ShowdlgTimeDemoProc()
DECLARE FUNCTION ShowdlgTimeDemo(BYVAL hParent AS DWORD) AS LONG
#PBFORMS DECLARATIONS
'------------------------------------------------------------------------------

'------------------------------------------------------------------------------
'   ** Main Application Entry Point **
'------------------------------------------------------------------------------
FUNCTION PBMAIN()
  PBFormsInitComCtls (%ICC_WIN95_CLASSES OR %ICC_DATE_CLASSES OR _
    %ICC_INTERNET_CLASSES)
  ' show the form
  ShowdlgTimeDemo %HWND_DESKTOP
END FUNCTION
'------------------------------------------------------------------------------

'------------------------------------------------------------------------------
'   ** CallBacks **
'------------------------------------------------------------------------------
CALLBACK FUNCTION ShowdlgTimeDemoProc()
  LOCAL strValue AS STRING
  LOCAL lngMinutes AS LONG
  STATIC lngCount AS LONG
  '
  SELECT CASE AS LONG CB.MSG
    CASE %WM_INITDIALOG
      ' Initialization handler
      ' Create WM_TIMER events with the SetTimer API
      SetTimer(CB.HNDL, %ID_TIMER1, _
               1000, BYVAL %NULL)
               '
      ' create the second timer
      SetTimer(CB.HNDL, %ID_TIMER2, _
               5000, BYVAL %NULL)
               '
    CASE %WM_TIMER
      SELECT CASE CB.WPARAM
        CASE %ID_TIMER1
        ' timer 1 is the clock
        ' update the field on screen
          funUpdateField(CB.HNDL, %IDC_lblTime, TIME$)
          '
        CASE %ID_TIMER2
        ' time 2 is the text field
          INCR lngCount ' advance the count
          '
          IF lngCount = 2 THEN
          ' if the count has reached 2 then stop the timer
            KillTimer(CB.HNDL, %ID_TIMER2)
            EXIT FUNCTION
          END IF
          ' pick up the number of minutes
          lngMinutes = VAL(RIGHT$(TIME$,2))
          '
          ' determine if it's odd or even
          IF lngMinutes MOD 2 = 0 THEN
            strValue = "EVEN"
          ELSE
            strValue = "ODD"
          END IF
          '
          ' update the field on screen
          funUpdateField(CB.HNDL,%IDC_lblData, strValue)
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
    '
    CASE %WM_DESTROY
    ' form is closing so kill off the timers
      KillTimer(CB.HNDL, %ID_TIMER1)
      ' timer2 has already been killed off
'      KillTimer(CB.HNDL, %ID_TIMER2)
    '
    CASE %WM_COMMAND
      ' Process control notifications
      SELECT CASE AS LONG CB.CTL
        CASE %IDABORT
          IF CB.CTLMSG = %BN_CLICKED OR CB.CTLMSG = 1 THEN
          ' end the dialog
            DIALOG END CB.HNDL
          END IF
          '
        CASE %IDC_txtData
        '
      END SELECT
  END SELECT
END FUNCTION
'------------------------------------------------------------------------------
FUNCTION funUpdateField(hDlg AS DWORD, _
                        lngField AS LONG, _
                        strValue AS STRING) AS LONG
' update the field on the dialog
  CONTROL SET TEXT hDlg,lngField, strValue
  '
END FUNCTION
'------------------------------------------------------------------------------
'   ** Dialogs **
'------------------------------------------------------------------------------
FUNCTION ShowdlgTimeDemo(BYVAL hParent AS DWORD) AS LONG
  LOCAL lRslt  AS LONG

#PBFORMS BEGIN DIALOG %IDD_dlgTimeDemo->->
  LOCAL hDlg   AS DWORD
  LOCAL hFont1 AS DWORD

  DIALOG NEW hParent, "Timer Demo", 343, 220, 688, 339, %WS_POPUP OR _
    %WS_BORDER OR %WS_DLGFRAME OR %WS_CAPTION OR %WS_SYSMENU OR _
    %WS_CLIPSIBLINGS OR %WS_VISIBLE OR %DS_MODALFRAME OR %DS_CENTER OR _
    %DS_3DLOOK OR %DS_NOFAILCREATE OR %DS_SETFONT, %WS_EX_CONTROLPARENT OR _
    %WS_EX_LEFT OR %WS_EX_LTRREADING OR %WS_EX_RIGHTSCROLLBAR, TO hDlg
  CONTROL ADD BUTTON,  hDlg, %IDABORT, "Exit", 560, 290, 60, 20
  CONTROL ADD TEXTBOX, hDlg, %IDC_txtData, "Ready", 50, 170, 570, 115
  CONTROL ADD LABEL,   hDlg, %IDC_lblTime, "00:00", 520, 20, 100, 30
  CONTROL SET COLOR    hDlg, %IDC_lblTime, %BLUE, -1
  CONTROL ADD LABEL,   hDlg, %IDC_lblData, "Blank", 520, 70, 100, 30
  CONTROL SET COLOR    hDlg, %IDC_lblData, %BLUE, -1

  FONT NEW "MS Sans Serif", 24, 0, %ANSI_CHARSET TO hFont1

  CONTROL SET FONT hDlg, %IDC_txtData, hFont1
  CONTROL SET FONT hDlg, %IDC_lblTime, hFont1
  CONTROL SET FONT hDlg, %IDC_lblData, hFont1
#PBFORMS END DIALOG

  DIALOG SHOW MODAL hDlg, CALL ShowdlgTimeDemoProc TO lRslt

#PBFORMS BEGIN CLEANUP %IDD_dlgTimeDemo
  FONT END hFont1
#PBFORMS END CLEANUP

  FUNCTION = lRslt
END FUNCTION
'------------------------------------------------------------------------------
