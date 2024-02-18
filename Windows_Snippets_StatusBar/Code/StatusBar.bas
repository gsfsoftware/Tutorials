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
#RESOURCE "StatusBar.pbr"
%USEMACROS = 1
#INCLUDE ONCE "WIN32API.INC"
#INCLUDE ONCE "COMMCTRL.INC"
#INCLUDE ONCE "PBForms.INC"
#PBFORMS END INCLUDES
'------------------------------------------------------------------------------
$DSK = CHR$(60)  ' Diskette img in Wingdings font..
'------------------------------------------------------------------------------
'   ** Constants **
'------------------------------------------------------------------------------
#PBFORMS BEGIN CONSTANTS
%IDD_DIALOG1   =  101
%IDC_STATUSBAR = 1001
#PBFORMS END CONSTANTS
%IDC_STATUSBAR2 = 1002  ' constant for 2nd status bar
'------------------------------------------------------------------------------

'------------------------------------------------------------------------------
'   ** Declarations **
'------------------------------------------------------------------------------
DECLARE CALLBACK FUNCTION ShowDIALOG1Proc()
DECLARE FUNCTION ShowDIALOG1(BYVAL hParent AS DWORD) AS LONG
#PBFORMS DECLARATIONS
'------------------------------------------------------------------------------

'------------------------------------------------------------------------------
'   ** Main Application Entry Point **
'------------------------------------------------------------------------------
FUNCTION PBMAIN()
  PBFormsInitComCtls (%ICC_WIN95_CLASSES OR %ICC_DATE_CLASSES OR _
    %ICC_INTERNET_CLASSES)

  ShowDIALOG1 %HWND_DESKTOP
END FUNCTION
'------------------------------------------------------------------------------

'------------------------------------------------------------------------------
'   ** CallBacks **
'------------------------------------------------------------------------------
CALLBACK FUNCTION ShowDIALOG1Proc()
  STATIC hFont AS LONG              ' Font handle
  LOCAL lpdis AS DRAWITEMSTRUCT PTR
  LOCAL nmm AS NMMOUSE PTR
  LOCAL pt AS POINTAPI
  STATIC lngDsc AS LONG
  '
  SELECT CASE AS LONG CB.MSG
    CASE %WM_INITDIALOG
      ' Initialization handler
      ' just set simple text on the status bar
      'control set text cb.hndl,%IDC_STATUSBAR,"Ready for Work"
      LOCAL strText AS STRING
      strText = "Ready for work"
      LOCAL lngItem AS LONG
      lngItem = 1
      LOCAL lngStyle AS LONG
      lngStyle = 0
      ' print plain text to the statusbar
      'statusbar set text CB.HNDL,%IDC_STATUSBAR, _
      '                   lngItem,lngStyle,strText
      '
      ' divide status bar into sections (max of 32)
      ' quantities are either pixels or dialog units
      ' depending on how your form has been created
      'STATUSBAR SET PARTS CB.HNDL, %IDC_STATUSBAR, 80, 50,100, 9999
      'prefix "STATUSBAR SET TEXT CB.HNDL, %IDC_STATUSBAR,"
      '   1, 0,"First"
      '   2, 0,"Second"
      '   3, 0,"Third"
      '   4, 0,"Last"
      'end prefix
      '
      ' create an icon on the status bar to allow user to
      ' click on it
      hFont = funMakeFontEx("Wingdings", 12, %FW_BOLD, 0, 0, 0)
       ' make use of Wingdings font
      STATUSBAR SET PARTS CB.HNDL, %IDC_STATUSBAR, 80, 16, 9999
      STATUSBAR SET TEXT CB.HNDL, %IDC_STATUSBAR, 1, 0, "Click Disk -->"
      STATUSBAR SET TEXT CB.HNDL, %IDC_STATUSBAR, 2, _
                                  %SBT_OWNERDRAW, $DSK

      '
    CASE %WM_DESTROY    ' Received at Exit - clean up time
      IF hFont THEN
        DeleteObject(hFont)
      END IF
      '
    CASE %WM_DRAWITEM  ' Draw ownerdrawn part(s)
      IF CB.WPARAM = %IDC_STATUSBAR THEN
        lpdis = CB.LPARAM ' Part count is 0-based, so item 1 = DDT part 2, etc.
        IF @lpdis.itemID = 1 THEN
        ' only triggers if Part 1 (second section) of the status bar clicked on
          hFont = SelectObject(@lpdis.hDC, hFont)  ' Use a Wingdings font
          ' set the text colour depending on value of lngDsk
          SetTextColor @lpdis.hDC, IIF(lngDsc, RGB(255, 0, 0), RGB(64, 64, 64))
          ' draw the 'text' on the statusbar
          DrawText @lpdis.hDC, BYCOPY $DSK, LEN($DSK), @lpdis.rcItem, _
                   %DT_CENTER OR %DT_SINGLELINE OR %DT_VCENTER
          hFont = SelectObject(@lpdis.hDC, hFont)
        END IF
        '
      END IF
      '
    CASE %WM_NOTIFY  ' Check for click in status bar parts
      nmm = CB.LPARAM
      '
      IF @nmm.hdr.idFrom = %IDC_STATUSBAR _
         AND @nmm.hdr.code = %NM_CLICK THEN
        IF @nmm.dwItemSpec = 1 THEN
          ' 0-based count
          '- item 1 = DDT item 2, etc...
          ' Toggle "Diskette" status
          lngDsc = 1 - lngDsc
          ' Redraw statusbar to see effect
          CONTROL REDRAW CB.HNDL, %IDC_STATUSBAR
          '
          ' insert your code here to trigger when icon is clicked
          SELECT CASE lngDsc
            CASE 1
              ' tell the user
              MSGBOX "Saving"
              SLEEP 2000
              ' Toggle "Diskette" status
              lngDsc = 1 - lngDsc
              ' Redraw statusbar to show grey icon
              CONTROL REDRAW CB.HNDL, %IDC_STATUSBAR
          END SELECT
          '
        END IF
        '
      END IF
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
        CASE %IDC_STATUSBAR

      END SELECT
  END SELECT
END FUNCTION
'------------------------------------------------------------------------------

'------------------------------------------------------------------------------
'   ** Dialogs **
'------------------------------------------------------------------------------
FUNCTION ShowDIALOG1(BYVAL hParent AS DWORD) AS LONG
  LOCAL lRslt AS LONG

#PBFORMS BEGIN DIALOG %IDD_DIALOG1->->
  LOCAL hDlg  AS DWORD

  DIALOG NEW hParent, "Status Bar Demo", 120, 157, 443, 251, %WS_POPUP OR _
    %WS_BORDER OR %WS_DLGFRAME OR %WS_CAPTION OR %WS_SYSMENU OR _
    %WS_MINIMIZEBOX OR %WS_CLIPSIBLINGS OR %WS_VISIBLE OR %DS_MODALFRAME OR _
    %DS_CENTER OR %DS_3DLOOK OR %DS_NOFAILCREATE OR %DS_SETFONT, _
    %WS_EX_CONTROLPARENT OR %WS_EX_LEFT OR %WS_EX_LTRREADING OR _
    %WS_EX_RIGHTSCROLLBAR, TO hDlg
  CONTROL ADD STATUSBAR, hDlg, %IDC_STATUSBAR, "StatusBar", 0, 0, 0, 0, _
    %WS_CHILD OR %WS_VISIBLE, %WS_EX_CLIENTEDGE OR %WS_EX_STATICEDGE OR _
    %WS_EX_LEFT OR %WS_EX_LTRREADING OR %WS_EX_RIGHTSCROLLBAR
#PBFORMS END DIALOG
  ' add the 2nd status bar at top of dialog
  CONTROL ADD STATUSBAR, hDlg,%IDC_STATUSBAR2,"StatusBar2", 0, 0, 0, 0, _
                         %CCS_TOP, %WS_EX_CLIENTEDGE OR %WS_EX_STATICEDGE
                         '
  DIALOG SHOW MODAL hDlg, CALL ShowDIALOG1Proc TO lRslt

#PBFORMS BEGIN CLEANUP %IDD_DIALOG1
#PBFORMS END CLEANUP

  FUNCTION = lRslt
END FUNCTION
'------------------------------------------------------------------------------
FUNCTION funMakeFontEx(BYVAL sFont AS STRING, _
                       BYVAL PointSize AS LONG, _
                       BYVAL fBold AS LONG,_
                       BYVAL fItalic AS LONG, _
                       BYVAL fUnderline AS LONG, _
                       BYVAL StrikeThru AS LONG) AS DWORD
                       '
  LOCAL hDC AS DWORD, CharSet AS LONG, CyPixels AS LONG
  ' create the ref to the new font
  hDC = GetDC(%HWND_DESKTOP)
  CyPixels  = GetDeviceCaps(hDC, %LOGPIXELSY)
  EnumFontFamilies hDC, BYVAL STRPTR(sFont), _
                   CODEPTR(funEnumCharSet), _
                   BYVAL VARPTR(CharSet)
                   '
  ReleaseDC %HWND_DESKTOP, hDC
  PointSize = 0 - (PointSize * CyPixels) \ 72
  '
  FUNCTION = CreateFont(PointSize, 0, _  'height, width(default=0)
             0, 0, _                     'escapement(angle), orientation
             fBold, _                    'weight (%FW_DONTCARE = 0, %FW_NORMAL = 400, %FW_BOLD = 700)
             fItalic, _                  'Italic
             fUnderline, _               'Underline
             StrikeThru, _               'StrikeThru
             CharSet, %OUT_TT_PRECIS, _
             %CLIP_DEFAULT_PRECIS, %DEFAULT_QUALITY, _
             %FF_DONTCARE , BYCOPY sFont)

END FUNCTION
'
'====================================================================
' Get type of character set - ansi, symbol.. a must for some fonts.
'--------------------------------------------------------------------
FUNCTION funEnumCharSet (elf AS ENUMLOGFONT, _
                         ntm AS NEWTEXTMETRIC, _
                         BYVAL FontType AS LONG, _
                         CharSet AS LONG) AS LONG
  CharSet = elf.elfLogFont.lfCharSet
END FUNCTION
