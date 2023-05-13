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
#RESOURCE "DynamicForms.pbr"
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
%IDR_IMGFILE1        =  102
%IDR_IMGFILE2        =  103 '*
%IDD_DlgDynamicForms =  101
%IDC_STATUSBAR1      = 1001
%IDABORT             =    3
%IDC_IMGBUTTON1      = 1015
%IDC_SCROLLBAR1      = 1016
#PBFORMS END CONSTANTS

%StartLabel = 4000
%StartText  = 4100
'------------------------------------------------------------------------------
'   ** Declarations **
'------------------------------------------------------------------------------
DECLARE CALLBACK FUNCTION ShowDlgDynamicFormsProc()
DECLARE FUNCTION ShowDlgDynamicForms(BYVAL hParent AS DWORD) AS LONG
#PBFORMS DECLARATIONS
'------------------------------------------------------------------------------

'------------------------------------------------------------------------------
'   ** Main Application Entry Point **
'------------------------------------------------------------------------------
FUNCTION PBMAIN()
  PBFormsInitComCtls (%ICC_WIN95_CLASSES OR %ICC_DATE_CLASSES OR _
    %ICC_INTERNET_CLASSES)

  ShowDlgDynamicForms %HWND_DESKTOP
END FUNCTION
'------------------------------------------------------------------------------
FUNCTION funDisplayFields(hDlg AS DWORD, _
                          lngField AS LONG, _
                          lngIncrement AS LONG) AS LONG
  ' add a label and text box to the form
  LOCAL lngOffset AS LONG
  '
  SELECT CASE lngIncrement
    CASE 1
    ' adding objects
    ' calculate the vertical position of the object
      lngOffset = 56 + ((lngField -1) * 15)
      '
      CONTROL ADD LABEL,  hDlg, %StartLabel + lngField, _
        "Field " & FORMAT$(lngField) , 25, lngOffset , 100, 10, _
        %WS_CHILD OR %WS_VISIBLE OR %SS_CENTER, %WS_EX_LEFT _
         OR %WS_EX_LTRREADING
      CONTROL SET COLOR    hDlg, %StartLabel+lngField, %BLUE, -1
      ' redraw the control to make the colour visible
      CONTROL REDRAW hDlg,%StartLabel+lngField
      CONTROL ADD TEXTBOX, hDlg, %StartText+lngField, "TextBox" & _
                          FORMAT$(lngField), _
                          130, lngOffset, 100, 13
    CASE -1
    ' removing objects
      CONTROL KILL hDlg,%StartLabel + lngField
      CONTROL KILL hDlg,%StartText + lngField
    '
  END SELECT

END FUNCTION
'------------------------------------------------------------------------------
'   ** CallBacks **
'------------------------------------------------------------------------------
CALLBACK FUNCTION ShowDlgDynamicFormsProc()
  LOCAL lngR AS LONG
  STATIC lngObjectCount AS LONG
  STATIC lngIncrement AS LONG
  STATIC lngField AS LONG
  '
  STATIC lngSBValue AS LONG
  STATIC lngSBPage AS LONG
  STATIC lngSBRange AS LONG
  '
  SELECT CASE AS LONG CB.MSG
    CASE %WM_INITDIALOG
    ' Initialization handler
      lngField = 1
      lngIncrement = 1   ' default to adding objects
      '
      lngSBValue = 1
      lngSBRange = 100
      lngSBPage = 10
      SCROLLBAR SET PAGESIZE CB.HNDL, %IDC_SCROLLBAR1, lngSBPage
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
    CASE %WM_VSCROLL
      SELECT CASE LOWRD(CB.WPARAM)
        CASE %SB_LINEUP
          lngSBValue = MAX(lngSBValue - 1,1)
        CASE %SB_LINEDOWN
          lngSBValue = MIN(lngSBValue + 1,lngSBRange)
        CASE %SB_PAGEDOWN
          lngSBValue = MIN(lngSBValue + lngSBPage,lngSBRange)
        CASE %SB_PAGEUP
          lngSBValue = MAX(lngSBValue - lngSBPage,1)
        CASE %SB_THUMBTRACK
          SCROLLBAR GET TRACKPOS CB.HNDL, %IDC_SCROLLBAR1 TO lngSBValue
        CASE %SB_TOP
        CASE %SB_BOTTOM
      END SELECT
      '
      SCROLLBAR SET POS CB.HNDL,%IDC_SCROLLBAR1, lngSBValue
      CONTROL SET TEXT CB.HNDL,%IDC_STATUSBAR1, FORMAT$(lngSBValue)
      '
      funReLabelObjects(CB.HNDL, lngSBValue, lngSBRange)
      '
    CASE %WM_COMMAND
      ' Process control notifications
      SELECT CASE AS LONG CB.CTL
        ' /* Inserted by PB/Forms 02-20-2021 13:41:18
        CASE %IDC_SCROLLBAR1


        ' */

        ' /* Inserted by PB/Forms 02-06-2021 15:03:49
        CASE %IDC_IMGBUTTON1
          IF CB.CTLMSG = %BN_CLICKED OR CB.CTLMSG = 1 THEN
          ' button has been pressed
            funDisplayFields(CB.HNDL, lngField, lngIncrement)
            lngField = lngField + lngIncrement
            SELECT CASE lngField
              CASE 11
              ' start removing objects
                lngIncrement = -1
              CASE 1
              ' start adding objects
                lngIncrement = 1
            END SELECT
            '
          END IF
        ' */

        CASE %IDC_STATUSBAR1

        CASE %IDABORT
          IF CB.CTLMSG = %BN_CLICKED OR CB.CTLMSG = 1 THEN
          ' exit the form
            DIALOG END CB.HNDL
          END IF

      END SELECT
  END SELECT
END FUNCTION
'------------------------------------------------------------------------------

'------------------------------------------------------------------------------
'   ** Dialogs **
'------------------------------------------------------------------------------
FUNCTION ShowDlgDynamicForms(BYVAL hParent AS DWORD) AS LONG
  LOCAL lRslt AS LONG

#PBFORMS BEGIN DIALOG %IDD_DlgDynamicForms->->
  LOCAL hDlg  AS DWORD

  DIALOG NEW hParent, "Dynamic forms", 279, 172, 451, 285, %WS_POPUP OR _
    %WS_BORDER OR %WS_DLGFRAME OR %WS_CAPTION OR %WS_SYSMENU OR _
    %WS_MINIMIZEBOX OR %WS_CLIPSIBLINGS OR %WS_VISIBLE OR %DS_MODALFRAME OR _
    %DS_CENTER OR %DS_3DLOOK OR %DS_NOFAILCREATE OR %DS_SETFONT, _
    %WS_EX_CONTROLPARENT OR %WS_EX_LEFT OR %WS_EX_LTRREADING OR _
    %WS_EX_RIGHTSCROLLBAR, TO hDlg
  CONTROL ADD STATUSBAR, hDlg, %IDC_STATUSBAR1, "", 0, 0, 0, 0
  CONTROL ADD BUTTON,    hDlg, %IDABORT, "Exit", 30, 245, 50, 15
  CONTROL ADD IMGBUTTON, hDlg, %IDC_IMGBUTTON1, "#" + FORMAT$(%IDR_IMGFILE1), _
    295, 50, 30, 30, %WS_CHILD OR %WS_VISIBLE OR %WS_TABSTOP OR %BS_ICON OR _
    %BS_PUSHBUTTON OR %BS_CENTER OR %BS_VCENTER OR %BS_TEXT, %WS_EX_LEFT OR _
    %WS_EX_LTRREADING
  CONTROL ADD SCROLLBAR, hDlg, %IDC_SCROLLBAR1, "ScrollBar1", 250, 50, 10, _
    165, %WS_CHILD OR %WS_VISIBLE OR %SBS_VERT
#PBFORMS END DIALOG

  DIALOG SHOW MODAL hDlg, CALL ShowDlgDynamicFormsProc TO lRslt

#PBFORMS BEGIN CLEANUP %IDD_DlgDynamicForms
#PBFORMS END CLEANUP

  FUNCTION = lRslt
END FUNCTION
'------------------------------------------------------------------------------
FUNCTION funReLabelObjects(hDlg AS DWORD, _
                           lngSBValue AS LONG, _
                           lngSBRange AS LONG) AS LONG
' relabel the objects
  LOCAL lngR AS LONG
  LOCAL lngFieldNumber AS LONG
  '
  FOR lngR = 1 TO 11
    lngFieldNumber = lngSBValue + lngR -1
    CONTROL SET TEXT hDlg,%StartLabel +lngR -1,"Field " & _
                     FORMAT$(lngFieldNumber)
    CONTROL SET TEXT hDlg,%StartText +lngR -1,"Field " & _
                     FORMAT$(lngFieldNumber)
  NEXT lngR

END FUNCTION
