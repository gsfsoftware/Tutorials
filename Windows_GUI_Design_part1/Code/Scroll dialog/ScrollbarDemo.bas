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
'
'
' Using the scroll bars on a Dialog
' Based on code provided  by Borje Hagsten,
' further amended by Maciej Neyman.
' Free to use by all PB programers.
'
'------------------------------------------------------------------------------

#COMPILE EXE
#DIM ALL

'------------------------------------------------------------------------------
'   ** Includes **
'------------------------------------------------------------------------------
#PBFORMS BEGIN INCLUDES
#RESOURCE "ScrollbarDemo.pbr"
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
%IDD_DIALOG1  =  101
%IDC_LABEL1   = 1005
%IDC_txt_1    = 1001
%IDC_txt_2    = 1002
%IDC_txt_3    = 1003
%IDC_txt_4    = 1004
%IDC_LABEL2   = 1006
%IDC_LABEL3   = 1007
%IDC_LABEL4   = 1008
%IDC_TEXTBOX1 = 1009
%IDC_LABEL5   = 1010
#PBFORMS END CONSTANTS
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
  LOCAL si AS SCROLLINFO  ' UDT for Scroll Information
  LOCAL lngW AS LONG      ' horizontal scroll value
  LOCAL lngH AS LONG      ' vertical scroll value
  LOCAL lngOldPos AS LONG ' stored previous position
  '
  LOCAL lngVt AS LONG     ' size of vertical scroll bar widget/thumb
  LOCAL lngHt AS LONG     ' size of horizontal scroll bar widget/thumb
  LOCAL lngHs AS LONG     ' horizontal scroll bar step
  LOCAL lngVs AS LONG     ' vertical scroll bar step
  '
'==================================================================
'HERE YOU WILL SETUP VALUES FOR THE CONSTANTS CONTROLING BEHAVIOUR
'OF THE SCROLL BARS:   (feel free to experiment with these values)
'==================================================================

  lngW = 600 'This is the number of dialog units by which the
             'Dialog's Window will scroll horizontaly if the
             'widget of the Scrolling Bar travels between its
             'extreme positions left and right
             'Reasonable (but not compulsory) value for it is
             'between 200 to 2000
             '
  lngH = 400 'This is the number of dialog units by which the
             'Dialog's Window will scroll verticaly if the
             'widget of the Scrolling Bar travels between its
             'extreme positions top and bottom
             'Reasonable (but not compulsory) value for it is
             'between 200 to 1600
             '
  lngHt = 50 'length of the horizontal scroling bar's widget,
             'this is also the amount of dialog units by which
             'the dialog will scroll horizontally if mouse is
             'clicked between the ends of the scroll bar and
             'the widget itself reasonable value for it is
             'between 10 and lngW/2
             '
  lngVt = 50 'length of the vertical scroll bar's widget, this
             'is also the amount of dialog units by which the
             'dialog will scroll verticaly if mouse is clicked
             'between the ends of the scroll bar and the widget
             'itself reasonable value for it is between 10 and
             'lngH/2
               '
  lngHs = 5  'number of dialog units by which the Dialog scrolls
             'horizontally when the small arrow on either end of
             'scroling bar is activated by mouse reasonable values
             'for it is between 1 and 30. Small value produces
             'smoother but slower scrolling, the higher value
             'is faster but more jerky - the Dialog scrolls by
             'steps determined by this value.

  lngVs = 5  'number of dialog units by which the Dialog scrolls
             'vertically when the small arrow on either end of
             'scroling bar is activated by mouse reasonable values
             'for it is between 1 and 30. Small value produces
             'smoother but slower scrolling, the higher value
             'is faster but more jerky - the Dialog scrolls by
             'steps determined by this value.
             '
' If scrolling by dialog units and not by pixels is giving you issues
' remove REM from the next line.

  REM DIALOG UNITS CB.HNDL, w, h TO PIXELS w, h
  '
  SELECT CASE AS LONG CB.MSG
    CASE %WM_INITDIALOG
    ' Initialization handler
      '
      ' initialize scrollbars here
      '----------------------------------------
      ' get place holders for the si parameters
      si.cbSize = LEN(si)
      ' setting the topological space for the scroll bars
      si.fMask  = %SIF_ALL
      ' set min scroll pos
      si.nMin   = 0
      ' set max scroll pos
      si.nMax   = lngH
      ' length of the vertical scroll bar's widget
      si.nPage  = lngVt
      ' initial setup of the vertical scrollbar, "1" represents
      ' "TRUE" and causes redraw of the scroll bar
      SetScrollInfo CB.HNDL, %SB_VERT, si, 1
      '
      ' set min scroll pos
      si.nMin   = 0

      ' max scroll pos
      si.nMax   = lngW

      ' width of the horizontal scroll bar widget
      si.nPage  = lngHt

      ' initial position of the widgets
      si.nPos   = 0

      ' initial setup of the horizontal scrollbar,
      ' "1" represents "TRUE" and causes redraw
      ' of the scroll bar
      SetScrollInfo CB.HNDL, %SB_HORZ, si, 1
      '
    CASE %WM_HSCROLL  ' call from the horizontal scroll bar
      si.cbSize = SIZEOF(si)
      si.fMask  = %SIF_ALL
      ' get the scroll bar UDT
      GetScrollInfo CB.HNDL, %SB_HORZ, si
      lngOldPos = si.nPos
      '
      SELECT CASE LOWRD(CB.WPARAM)
        CASE %SB_LINELEFT
        ' small movement left
          si.nPos = si.nPos - lngHs
        CASE %SB_PAGELEFT
        ' large movement left
          si.nPos = si.nPos - si.nPage
        CASE %SB_LINERIGHT
          si.nPos = si.nPos + lngHs
        CASE %SB_PAGERIGHT
          si.nPos = si.nPos + si.nPage
        CASE %SB_THUMBTRACK
        ' moving using widget/thumb
          si.nPos = HIWRD(CB.WPARAM)
        CASE ELSE
          EXIT FUNCTION
      END SELECT
      '
      'To limit scroling range remove keep the next line of code
      'If you don't then you can keep scrolling
      'by using small arrows on the end of the scroll bar.
      si.nPos = MAX&(si.nMin, MIN&(si.nPos, si.nMax - si.nPage))
      '
      ' Update the scroll bar and scroll the client area
      si.fMask  = %SIF_POS
      'remember new geometry of the horizontal scroll bar
      SetScrollInfo CB.HNDL, %SB_HORZ, si, 1
      ' scroll the dialog
      ScrollWindow CB.HNDL, lngOldPos - si.nPos, 0, _
                   BYVAL %NULL, BYVAL %NULL
      FUNCTION = 1
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
    CASE %WM_VSCROLL  'call from the vertical scroll bar
      si.cbSize = SIZEOF(si)
      si.fMask  = %SIF_ALL
      ' get vertical scrollbar UDT
      GetScrollInfo CB.HNDL, %SB_VERT, si
      lngOldPos = si.nPos
      '
      SELECT CASE LOWRD(CB.WPARAM)
        CASE %SB_LINEUP
          si.nPos = si.nPos - lngVs
        CASE %SB_PAGEUP
          si.nPos = si.nPos - si.nPage
        CASE %SB_LINEDOWN
          si.nPos = si.nPos + lngVs
        CASE %SB_PAGEDOWN
          si.nPos = si.nPos + si.nPage
        CASE %SB_THUMBTRACK
          si.nPos = HIWRD(CB.WPARAM)
        CASE ELSE
          EXIT FUNCTION
      END SELECT
      '
      'To limit scroling range keep the next line of code
      'If you don't then you can keep scrolling indefinitely
      'by using small arrows on the end of the scroll bar.

      si.nPos = MAX&(si.nMin, MIN&(si.nPos, si.nMax - si.nPage + 1))
      '
      ' Now update the scroll bar and scroll the client area

      si.fMask = %SIF_POS
      'remember new geometry of the vertical scroll bar
      SetScrollInfo CB.HNDL, %SB_VERT, si, 1
      '
      ' scroll the dialog
      ScrollWindow CB.HNDL, 0, lngOldPos - si.nPos, _
                   BYVAL %NULL, BYVAL %NULL
      FUNCTION = 1
      '
    CASE %WM_COMMAND
      ' Process control notifications
      SELECT CASE AS LONG CB.CTL
        ' /* Inserted by PB/Forms 02-19-2022 10:08:25
        CASE %IDC_TEXTBOX1
        ' */

        CASE %IDC_txt_1

        CASE %IDC_txt_2

        CASE %IDC_txt_3

        CASE %IDC_txt_4

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

  DIALOG NEW hParent, "Scrollbar demo", 187, 108, 760, 455, %WS_POPUP OR _
    %WS_BORDER OR %WS_DLGFRAME OR %WS_CAPTION OR %WS_SYSMENU OR _
    %WS_CLIPSIBLINGS OR %WS_VSCROLL OR %WS_VISIBLE OR %DS_MODALFRAME OR _
    %DS_CENTER OR %DS_3DLOOK OR %DS_NOFAILCREATE OR %DS_SETFONT, _
    %WS_EX_CONTROLPARENT OR %WS_EX_LEFT OR %WS_EX_LTRREADING OR _
    %WS_EX_RIGHTSCROLLBAR, TO hDlg
  CONTROL ADD TEXTBOX, hDlg, %IDC_txt_1, "", 340, 40, 280, 80, %WS_CHILD OR _
    %WS_VISIBLE OR %WS_TABSTOP OR %WS_VSCROLL OR %ES_LEFT OR %ES_MULTILINE _
    OR %ES_AUTOHSCROLL OR %ES_WANTRETURN, %WS_EX_CLIENTEDGE OR %WS_EX_LEFT _
    OR %WS_EX_LTRREADING OR %WS_EX_RIGHTSCROLLBAR
  CONTROL ADD TEXTBOX, hDlg, %IDC_txt_2, "", 340, 130, 280, 80, %WS_CHILD OR _
    %WS_VISIBLE OR %WS_TABSTOP OR %WS_VSCROLL OR %ES_LEFT OR %ES_MULTILINE _
    OR %ES_AUTOHSCROLL OR %ES_WANTRETURN, %WS_EX_CLIENTEDGE OR %WS_EX_LEFT _
    OR %WS_EX_LTRREADING OR %WS_EX_RIGHTSCROLLBAR
  CONTROL ADD TEXTBOX, hDlg, %IDC_txt_3, "", 340, 220, 280, 80, %WS_CHILD OR _
    %WS_VISIBLE OR %WS_TABSTOP OR %WS_VSCROLL OR %ES_LEFT OR %ES_MULTILINE _
    OR %ES_AUTOHSCROLL OR %ES_WANTRETURN, %WS_EX_CLIENTEDGE OR %WS_EX_LEFT _
    OR %WS_EX_LTRREADING OR %WS_EX_RIGHTSCROLLBAR
  CONTROL ADD TEXTBOX, hDlg, %IDC_txt_4, "", 340, 310, 280, 80, %WS_CHILD OR _
    %WS_VISIBLE OR %WS_TABSTOP OR %WS_VSCROLL OR %ES_LEFT OR %ES_MULTILINE _
    OR %ES_AUTOHSCROLL OR %ES_WANTRETURN, %WS_EX_CLIENTEDGE OR %WS_EX_LEFT _
    OR %WS_EX_LTRREADING OR %WS_EX_RIGHTSCROLLBAR
  CONTROL ADD LABEL,   hDlg, %IDC_LABEL1, "Label", 230, 75, 100, 10
  CONTROL ADD LABEL,   hDlg, %IDC_LABEL2, "Label", 225, 170, 100, 10
  CONTROL ADD LABEL,   hDlg, %IDC_LABEL3, "Label", 225, 265, 100, 10
  CONTROL ADD LABEL,   hDlg, %IDC_LABEL4, "Label", 225, 345, 100, 10
  CONTROL ADD TEXTBOX, hDlg, %IDC_TEXTBOX1, "", 340, 405, 280, 80, %WS_CHILD _
    OR %WS_VISIBLE OR %WS_TABSTOP OR %WS_VSCROLL OR %ES_LEFT OR _
    %ES_MULTILINE OR %ES_AUTOHSCROLL OR %ES_WANTRETURN, %WS_EX_CLIENTEDGE OR _
    %WS_EX_LEFT OR %WS_EX_LTRREADING OR %WS_EX_RIGHTSCROLLBAR
  CONTROL ADD LABEL,   hDlg, %IDC_LABEL5, "Label", 225, 435, 100, 10
#PBFORMS END DIALOG

  DIALOG SHOW MODAL hDlg, CALL ShowDIALOG1Proc TO lRslt

#PBFORMS BEGIN CLEANUP %IDD_DIALOG1
#PBFORMS END CLEANUP

  FUNCTION = lRslt
END FUNCTION
'------------------------------------------------------------------------------
