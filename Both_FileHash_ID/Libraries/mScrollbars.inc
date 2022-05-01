' mScrollbars.inc
'
MACRO mScroll_Init_Vars
' initialise Variables
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
  ' mouse wheel scrolling variables
  STATIC lngD AS LONG  ' for the V/H scrolling change
  LOCAL lngM AS LONG   ' Movement flag for Vertical or Horizontal
  LOCAL lngK AS LONG   ' Used to change amount of movement -/+
  '
END MACRO
'
MACRO mScrollbar_init
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

END MACRO
'
MACRO mScrollbar_events
' set up the scroll bar events
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
  CASE %WM_MBUTTONDOWN
  ' Use of the Middle Mouse Button (under the wheel)
  ' click to toggle between horizontal and vertical
     IF lngD = 0 THEN
       lngD = 1
     END IF
     '
    lngD = lngD *(-1)
    '
  CASE %WM_MOUSEWHEEL
  ' mouse wheel movement
    IF lngD = -1 THEN
      lngM = %SB_VERT
    ELSE
      lngM = %SB_HORZ
    END IF
    '
    ' Changing scrolling direction V/H
    IF HIWRD(CB.WPARAM)> 50000 THEN
      lngK = 1
    ELSE
    ' setting scrolling movement Up/Down, Left/Right
      lngK = -1
    END IF
    '
    IF lngD = -1 THEN
      si.cbSize = SIZEOF(si)
      si.fMask  = %SIF_ALL
      GetScrollInfo CB.HNDL, %SB_VERT, si
      lngOldPos = si.nPos
      '
      ' multiplied by 3 here to increase speed of scrolling
      ' adjust if required
      si.nPos = si.nPos +lngVs*3*lngK
      '
      si.fMask = %SIF_POS
      SetScrollInfo CB.HNDL, %SB_VERT, si, 1
      ScrollWindow CB.HNDL, 0, lngOldPos - si.nPos, _
                   BYVAL %NULL, BYVAL %NULL
      FUNCTION = 1
      '
    ELSE
      si.cbSize = SIZEOF(si)
      si.fMask  = %SIF_ALL
      GetScrollInfo CB.HNDL, %SB_HORZ, si
      lngOldPos = si.nPos
      ' multiplied by 3 here to increase speed
      ' of scrolling - adjust if required
      si.nPos = si.nPos + lngHs*3*lngK

      si.fMask = %SIF_POS
      SetScrollInfo CB.HNDL, %SB_HORZ, si, 1
      ScrollWindow CB.HNDL, lngOldPos - si.nPos, 0, _
                   BYVAL %NULL, BYVAL %NULL
      FUNCTION = 1
    END IF
END MACRO
