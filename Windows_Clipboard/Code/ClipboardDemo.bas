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
#DEBUG ERROR ON
'------------------------------------------------------------------------------
'   ** Includes **
'------------------------------------------------------------------------------
#PBFORMS BEGIN INCLUDES
#RESOURCE "ClipboardDemo.pbr"
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
%IDD_dlgClipboardDemo     =  101
%IDC_txtData              = 1001
%IDC_btnCopyToClipboard   = 1002
%IDC_btnCopyFromClipboard = 1003
%IDC_GRAPHIC1             = 1004
%IDC_btnCopyImage         = 1005
#PBFORMS END CONSTANTS
'------------------------------------------------------------------------------

'------------------------------------------------------------------------------
'   ** Declarations **
'------------------------------------------------------------------------------
DECLARE CALLBACK FUNCTION ShowdlgClipboardDemoProc()
DECLARE FUNCTION ShowdlgClipboardDemo(BYVAL hParent AS DWORD) AS LONG
#PBFORMS DECLARATIONS
'------------------------------------------------------------------------------

'------------------------------------------------------------------------------
'   ** Main Application Entry Point **
'------------------------------------------------------------------------------
FUNCTION PBMAIN()
  PBFormsInitComCtls (%ICC_WIN95_CLASSES OR %ICC_DATE_CLASSES OR _
    %ICC_INTERNET_CLASSES)

  ShowdlgClipboardDemo %HWND_DESKTOP
END FUNCTION
'------------------------------------------------------------------------------

'------------------------------------------------------------------------------
'   ** CallBacks **
'------------------------------------------------------------------------------
CALLBACK FUNCTION ShowdlgClipboardDemoProc()
  LOCAL strText AS STRING
  LOCAL lngResult AS LONG
  LOCAL hBitmap AS LONG
  '
  SELECT CASE AS LONG CB.MSG
    CASE %WM_INITDIALOG
      ' Initialization handler

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
        ' /* Inserted by PB/Forms 08-08-2021 12:58:18
        CASE %IDC_btnCopyImage
          IF CB.CTLMSG = %BN_CLICKED OR CB.CTLMSG = 1 THEN
            CLIPBOARD RESET  ' empty the clipboard
            CONTROL HANDLE CB.HNDL, %IDC_GRAPHIC1 TO hBitmap
            CLIPBOARD SET BITMAP  hBitmap ,lngResult
            IF ISTRUE lngResult THEN
              MSGBOX "Copied to clipboard"
            ELSE
              MSGBOX "Unable to copy to clipboard"
            END IF
            '
          END IF
        ' */

        CASE %IDC_txtData

        CASE %IDC_btnCopyToClipboard
          IF CB.CTLMSG = %BN_CLICKED OR CB.CTLMSG = 1 THEN
          ' first get the text in the text box
            CONTROL GET TEXT CB.HNDL,%IDC_txtData TO strText
            '
            CLIPBOARD RESET  ' empty the clipboard
            ' and copy the text to the clipboard
            CLIPBOARD SET TEXT strText , lngResult
            '
            IF ISTRUE lngResult THEN
              MSGBOX "Copied to clipboard"
            ELSE
              MSGBOX "Unable to copy to clipboard"
            END IF
            '
          END IF

        CASE %IDC_btnCopyFromClipboard
          IF CB.CTLMSG = %BN_CLICKED OR CB.CTLMSG = 1 THEN
            CLIPBOARD GET TEXT strText , lngResult
            IF ISTRUE lngResult THEN
              CONTROL SET TEXT CB.HNDL,%IDC_txtData, strText
            ELSE
              MSGBOX "Unable to copy to clipboard"
            END IF
          END IF

      END SELECT
  END SELECT
END FUNCTION
'------------------------------------------------------------------------------

'------------------------------------------------------------------------------
'   ** Dialogs **
'------------------------------------------------------------------------------
FUNCTION ShowdlgClipboardDemo(BYVAL hParent AS DWORD) AS LONG
  LOCAL lRslt AS LONG

#PBFORMS BEGIN DIALOG %IDD_dlgClipboardDemo->->
  LOCAL hDlg  AS DWORD

  DIALOG NEW hParent, "Demo for Clipboard", 357, 182, 543, 306, %WS_POPUP OR _
    %WS_BORDER OR %WS_DLGFRAME OR %WS_CAPTION OR %WS_SYSMENU OR _
    %WS_CLIPSIBLINGS OR %WS_VISIBLE OR %DS_MODALFRAME OR %DS_CENTER OR _
    %DS_3DLOOK OR %DS_NOFAILCREATE OR %DS_SETFONT, %WS_EX_CONTROLPARENT OR _
    %WS_EX_LEFT OR %WS_EX_LTRREADING OR %WS_EX_RIGHTSCROLLBAR, TO hDlg
  CONTROL ADD TEXTBOX, hDlg, %IDC_txtData, "", 25, 40, 240, 85, %WS_CHILD OR _
    %WS_VISIBLE OR %WS_TABSTOP OR %WS_VSCROLL OR %ES_LEFT OR %ES_MULTILINE _
    OR %ES_AUTOHSCROLL OR %ES_AUTOVSCROLL OR %ES_WANTRETURN, _
    %WS_EX_CLIENTEDGE OR %WS_EX_LEFT OR %WS_EX_LTRREADING OR _
    %WS_EX_RIGHTSCROLLBAR
  CONTROL ADD BUTTON,  hDlg, %IDC_btnCopyToClipboard, "Copy to Clipboard", _
    290, 40, 125, 15
  CONTROL ADD BUTTON,  hDlg, %IDC_btnCopyFromClipboard, "Copy Clipboard to " + _
    "Text box", 290, 110, 125, 15
  CONTROL ADD GRAPHIC, hDlg, %IDC_GRAPHIC1, "", 25, 145, 240, 105
  CONTROL ADD BUTTON,  hDlg, %IDC_btnCopyImage, "Copy Graphic to Clipboard", _
    290, 185, 125, 15
#PBFORMS END DIALOG
  ' attach the graphic control
  GRAPHIC ATTACH hDlg, %IDC_GRAPHIC1, REDRAW
  GRAPHIC CLEAR %RGB_WHITE,0
  '
  IF ISTRUE funLoadGraphic("Capture.bmp",%IDC_GRAPHIC1) THEN
    ' now draw on graphic
    GRAPHIC SET POS (10,90)
    GRAPHIC COLOR %BLACK , %WHITE
    GRAPHIC PRINT "Created at " & TIME$
    GRAPHIC BOX (170, 65) - (210, 95), 20, %BLUE, RGB(191,191,191), 0
    GRAPHIC REDRAW
  END IF
  '
  DIALOG SHOW MODAL hDlg, CALL ShowdlgClipboardDemoProc TO lRslt

#PBFORMS BEGIN CLEANUP %IDD_dlgClipboardDemo
#PBFORMS END CLEANUP

  FUNCTION = lRslt
END FUNCTION
'------------------------------------------------------------------------------
FUNCTION funLoadGraphic(strFile AS STRING, _
                        lngGraphic AS LONG) AS LONG
' load the image
  LOCAL lngFile AS LONG
  LOCAL lngWidth AS LONG
  LOCAL lngHeight AS LONG
  LOCAL hBmp AS LONG
  '
  IF ISFALSE ISFILE(strFile) THEN EXIT FUNCTION
  '
  lngFile = FREEFILE
  OPEN strFile FOR BINARY AS lngFile
  GET #lngFile, 19, lngWidth
  GET #lngFile, 23, lngHeight
  CLOSE lngFile
  '
  GRAPHIC BITMAP LOAD strFile, lngWidth , lngHeight , _
                      %HALFTONE TO hBmp
  GRAPHIC COPY hBmp, lngGraphic
  GRAPHIC BITMAP END
  GRAPHIC REDRAW
  FUNCTION = %TRUE
'
END FUNCTION
