'******************************************************************************
' ButtonPlus - Enhanced Pushbuttons                                24-Oct-2008
'
' Open source freeware built on the shoulders of others    by Laurence Jackson
'
' Compiler: PB/Win 8.x - 9.x (26.5KB)                           BUTTONPLUS.BAS
'
'******************************************************************************
' Special acknowledgements to José Roca's XPBUTTON and GDI+ examples
' which were the starting point for much of what is here.
'******************************************************************************

#INCLUDE "..\_PBCommon\ButtonPlus.inc"


FUNCTION ButtonPlus ___________________________________________________________
                                                (hDialog_DW AS DWORD,         _
                                                ButtonID_LG AS DWORD,         _
                                                Property_LG AS LONG,          _
                                          OPTIONAL Value_LG AS LONG           _
                                                          ) AS DWORD
'------------------------------------------------------------------------------
'
' Stores or retrieves new or modified special button properties and subclasses
' the button and the button parent, if not already sub-classed.
'
' On first call of ButtonPlus, (Style and &H000F) must be equal to 0 or 1
' (%BS_PUSHBUTTON or %BS_DEFPUSHBUTTON/%BS_DEFAULT) or ownerdraw will not
' be initialized. Subsequent attempts to change the button type without
' first destroying the original control will not be effective (change
' suppressed in subclassing).
'
'------------------------------------------------------------------------------

STATIC s_ButtonStyle() AS ButtonPlusType

LOCAL Index_LG AS LONG
LOCAL hButton_DW AS LONG
LOCAL OrigProc_DW AS LONG
LOCAL Style_DW AS DWORD
LOCAL VacantIndex_LG AS LONG
LOCAL hWnd_DW AS DWORD
LOCAL ControlID_LG AS LONG
LOCAL Class_SZ AS ASCIIZ*80

IF hDialog_DW = 0 THEN EXIT FUNCTION
hWnd_DW = hDialog_DW
ControlID_LG = ButtonID_LG

IF ButtonID_LG = 0 THEN
  hButton_DW = hDialog_DW
  ButtonID_LG = GetDlgCtrlID(hButton_DW)
  hDialog_DW = GetParent(hButton_DW)
  IF hDialog_DW = 0 THEN
    hDialog_DW = hWnd_DW
    ButtonID_LG = ControlID_LG
    EXIT FUNCTION
  END IF
ELSE
  hButton_DW = GetDlgItem(hDialog_DW, ButtonID_LG)
END IF

IF VARPTR(Value_LG) THEN
  IF UBOUND(s_ButtonStyle) < 1 THEN
    REDIM s_ButtonStyle(1)
    s_ButtonStyle(1).hButton_DW = hButton_DW
    Index_LG = 1
  ELSE
    FOR Index_LG = 1 TO UBOUND(s_ButtonStyle)
      IF s_ButtonStyle(Index_LG).hButton_DW = hButton_DW THEN
        EXIT FOR
      ELSEIF s_ButtonStyle(Index_LG).hButton_DW = 0 THEN
        VacantIndex_LG = Index_LG
      END IF
    NEXT Index_LG
    IF Index_LG > UBOUND(s_ButtonStyle) THEN 'New button:
      GetClassName hButton_DW, Class_SZ, SIZEOF(Class_SZ)
      IF LCASE$(Class_SZ) <> "button" THEN
        hDialog_DW = hWnd_DW
        ButtonID_LG = ControlID_LG
        EXIT FUNCTION
      END IF
      Style_DW = GetWindowLong(hButton_DW, %GWL_STYLE)
      IF (Style_DW AND &HF) > 1 THEN
        hDialog_DW = hWnd_DW
        ButtonID_LG = ControlID_LG
        EXIT FUNCTION
      ELSE
        IF VacantIndex_LG = 0 THEN
          REDIM PRESERVE s_ButtonStyle(Index_LG)
        ELSE
          Index_LG = VacantIndex_LG
        END IF
        s_ButtonStyle(Index_LG).hButton_DW = hButton_DW
      END IF
    END IF
  END IF
  SELECT CASE Property_LG
  CASE %BP_TEXT_COLOR
    s_ButtonStyle(Index_LG).TextColor_LG = Value_LG
  CASE %BP_ICON_ID
    s_ButtonStyle(Index_LG).IconID_LG = Value_LG
  CASE %BP_ICON_WIDTH
    s_ButtonStyle(Index_LG).IconWidth_LG = Value_LG
  CASE %BP_ICON_HEIGHT
    s_ButtonStyle(Index_LG).IconHeight_LG = Value_LG
  CASE %BP_ICON_POS
    s_ButtonStyle(Index_LG).IconPos_LG = Value_LG
  CASE %BP_FACE_COLOR
    s_ButtonStyle(Index_LG).FaceColor_LG = Value_LG
  CASE %BP_FACE_BLEND
    s_ButtonStyle(Index_LG).FaceBlend_LG = Value_LG AND &HFF
  CASE %BP_SPOT_COLOR
    s_ButtonStyle(Index_LG).SpotColor_LG = Value_LG
  CASE %BP_SPOT_BLEND
    s_ButtonStyle(Index_LG).SpotBlend_LG = Value_LG AND &HFF
  CASE %BP_SPOT_WIDTH
    s_ButtonStyle(Index_LG).SpotWidth_LG = Value_LG
  CASE %BP_SPOT_HEIGHT
    s_ButtonStyle(Index_LG).SpotHeight_LG = Value_LG
  CASE %BP_SPOT_POS
    s_ButtonStyle(Index_LG).SpotPos_LG = Value_LG
  CASE %BP_HOT
    s_ButtonStyle(Index_LG).Hot_LG = Value_LG
  CASE %BP_DEFAULT
    s_ButtonStyle(Index_LG).Default_LG = Value_LG
  END SELECT
  Style_DW = GetWindowLong(hButton_DW, %GWL_STYLE)
  Style_DW = (Style_DW AND &HFFFFFFF0) OR %BS_OWNERDRAW
  SetWindowLong hButton_DW, %GWL_STYLE, Style_DW
  OrigProc_DW = GetWindowLong (hButton_DW, %GWL_USERDATA)
  IF OrigProc_DW = 0 THEN
    SetWindowLong hButton_DW, %GWL_WNDPROC, CODEPTR(BPControlHook) TO OrigProc_DW
    SetWindowLong hButton_DW, %GWL_USERDATA, OrigProc_DW
    OrigProc_DW = GetWindowLong (hDialog_DW, %GWL_USERDATA)
    IF OrigProc_DW = 0 THEN
      SetWindowLong hDialog_DW, %GWL_WNDPROC, CODEPTR(BPDialogHook) TO OrigProc_DW
      SetWindowLong hDialog_DW, %GWL_USERDATA, OrigProc_DW
      SendMessage hDialog_DW, %BP_INIT, 0, 0
    END IF
  END IF
ELSE
  FOR Index_LG = UBOUND(s_ButtonStyle) TO 1 STEP -1
    IF s_ButtonStyle(Index_LG).hButton_DW = hButton_DW THEN
      EXIT FOR
    END IF          'If handle is not found,
  NEXT Index_LG     'Index_LG is zero
END IF
SELECT CASE Property_LG
CASE %BP_TEXT_COLOR
  ButtonPlus = s_ButtonStyle(Index_LG).TextColor_LG
CASE %BP_ICON_ID
  ButtonPlus = s_ButtonStyle(Index_LG).IconID_LG
CASE %BP_ICON_WIDTH
  ButtonPlus = s_ButtonStyle(Index_LG).IconWidth_LG
CASE %BP_ICON_HEIGHT
  ButtonPlus = s_ButtonStyle(Index_LG).IconHeight_LG
CASE %BP_ICON_POS
  ButtonPlus = s_ButtonStyle(Index_LG).IconPos_LG
CASE %BP_FACE_COLOR
  ButtonPlus = s_ButtonStyle(Index_LG).FaceColor_LG
CASE %BP_FACE_BLEND
  ButtonPlus = s_ButtonStyle(Index_LG).FaceBlend_LG
CASE %BP_SPOT_COLOR
  ButtonPlus = s_ButtonStyle(Index_LG).SpotColor_LG
CASE %BP_SPOT_BLEND
  ButtonPlus = s_ButtonStyle(Index_LG).SpotBlend_LG
CASE %BP_SPOT_WIDTH
  ButtonPlus = s_ButtonStyle(Index_LG).SpotWidth_LG
CASE %BP_SPOT_HEIGHT
  ButtonPlus = s_ButtonStyle(Index_LG).SpotHeight_LG
CASE %BP_SPOT_POS
  ButtonPlus = s_ButtonStyle(Index_LG).SpotPos_LG
CASE %BP_HOT
  ButtonPlus = s_ButtonStyle(Index_LG).Hot_LG
CASE %BP_DEFAULT
  ButtonPlus = s_ButtonStyle(Index_LG).Default_LG
CASE %BP_DESTROY
  OrigProc_DW = GetWindowLong (hButton_DW, %GWL_USERDATA)
  IF OrigProc_DW THEN
    SetWindowLong hButton_DW, %GWL_WNDPROC, OrigProc_DW
    SetWindowLong hButton_DW, %GWL_USERDATA, 0
    s_ButtonStyle(Index_LG).hButton_DW = 0
    s_ButtonStyle(Index_LG).TextColor_LG = 0
    s_ButtonStyle(Index_LG).IconID_LG = 0
    s_ButtonStyle(Index_LG).IconWidth_LG = 0
    s_ButtonStyle(Index_LG).IconHeight_LG = 0
    s_ButtonStyle(Index_LG).IconPos_LG = 0
    s_ButtonStyle(Index_LG).FaceColor_LG = 0
    s_ButtonStyle(Index_LG).FaceBlend_LG = 0
    s_ButtonStyle(Index_LG).SpotColor_LG = 0
    s_ButtonStyle(Index_LG).SpotBlend_LG = 0
    s_ButtonStyle(Index_LG).SpotWidth_LG = 0
    s_ButtonStyle(Index_LG).SpotHeight_LG = 0
    s_ButtonStyle(Index_LG).SpotPos_LG = 0
    s_ButtonStyle(Index_LG).Hot_LG = 0
    s_ButtonStyle(Index_LG).Default_LG = 0
  END IF
CASE %BP_INIT
  IF Index_LG THEN
    ButtonPlus = %TRUE
  END IF
END SELECT

hDialog_DW = hWnd_DW
ButtonID_LG = ControlID_LG

END FUNCTION


FUNCTION BPControlHook ________________________________________________________
                                          (BYVAL hButton_DW AS DWORD,         _
                                               BYVAL Msg_LG AS LONG,          _
                                           BYVAL Wparam_DW AS DWORD,          _
                                            BYVAL Lparam_LG AS LONG           _
                                                          ) AS LONG
'------------------------------------------------------------------------------
'
' CONTROL subclassing procedure.
'
'------------------------------------------------------------------------------

LOCAL ButtonID_LG AS LONG
LOCAL hDialog_DW AS DWORD
LOCAL OrigProc_DW AS DWORD
LOCAL Style_DW AS DWORD
LOCAL TrackMouse AS TRACKMOUSEEVENTAPI

IF Msg_LG = %BM_SETSTYLE THEN
  IF (Wparam_DW AND &HFFFFFFFE) = 0 THEN
    ButtonPlus hButton_DW, %NULL, %BP_DEFAULT, %FALSE
  END IF
  Wparam_DW = (Wparam_DW AND &HFFFFFFF0) OR %BS_OWNERDRAW
END IF

OrigProc_DW = GetWindowLong (hButton_DW, %GWL_USERDATA)
BPControlHook = CallWindowProc (OrigProc_DW _
,hButton_DW, Msg_LG, Wparam_DW, Lparam_LG)

SELECT CASE Msg_LG
CASE %WM_MOUSEMOVE
  IF ISFALSE ButtonPlus(hButton_DW, %NULL, %BP_HOT) THEN
    TrackMouse.cbSize = SIZEOF(TrackMouse)
    TrackMouse.dwFlags = %TME_LEAVE
    TrackMouse.hwndTrack = hButton_DW
    TrackMouse.dwHoverTime = 1
    TrackMouseEvent(TrackMouse)
    ButtonPlus hButton_DW, %NULL, %BP_HOT, %TRUE
    InvalidateRect hButton_DW, BYVAL %NULL, 0
    UpdateWindow hButton_DW
  END IF
CASE %WM_MOUSELEAVE
  ButtonPlus hButton_DW, %NULL, %BP_HOT, %FALSE
  InvalidateRect hButton_DW, BYVAL %NULL, 0
  UpdateWindow hButton_DW
CASE %WM_DESTROY
  ButtonPlus hButton_DW, %NULL, %BP_DESTROY
END SELECT

END FUNCTION


FUNCTION BPDialogHook _________________________________________________________
                                          (BYVAL hDialog_DW AS DWORD,         _
                                               BYVAL Msg_LG AS LONG,          _
                                            BYVAL Wparam_DW AS DWORD,         _
                                            BYVAL Lparam_LG AS LONG           _
                                                          ) AS LONG
'------------------------------------------------------------------------------
'
' DIALOG subclassing procedure.
'
' The WM_DRAWITEM message is only sent for buttons, comboboxes, listboxes or
' menus with the OWNERDRAW style. The message is sent to the parent of the
' control, hence the procedure for the parent dialog is hooked.
'
'------------------------------------------------------------------------------

STATIC s_Token_DW AS DWORD
STATIC s_hStartup_DW AS DWORD
STATIC s_Focus() AS FocusType

LOCAL StartupInput AS GdiplusStartupInput
LOCAL DrawItemPtr AS DRAWITEMSTRUCT PTR

LOCAL ButtonRect AS RECT
LOCAL FaceRect AS RECT
LOCAL TextRect AS RECT
LOCAL LeftRect AS RECT
LOCAL UpperRect AS RECT
LOCAL RightRect AS RECT
LOCAL LowerRect AS RECT

LOCAL CAPTION AS SIZEL
LOCAL Caption_SZ AS ASCIIZ*255
LOCAL Caption_ST() AS STRING
REDIM Caption_ST(1 TO 10)
LOCAL Class_ST AS STRING

LOCAL TextLines_LG AS LONG
LOCAL CharPtr_LG AS LONG
LOCAL LongestLine_LG AS LONG
LOCAL Section_LG AS LONG

LOCAL OrigProc_DW AS DWORD
LOCAL hButton_DW AS DWORD
LOCAL ButtonID_LG AS LONG
LOCAL Index_LG AS LONG
LOCAL VacantIndex_LG AS LONG

LOCAL ButtonDC_DW AS DWORD
LOCAL Color_DW AS DWORD
LOCAL Alpha_DW AS DWORD
LOCAL Graphics_DW AS DWORD
LOCAL hBrush_DW AS DWORD
LOCAL hTheme_DW AS DWORD
LOCAL hFont_DW AS DWORD
LOCAL hIcon_DW AS DWORD

LOCAL State_LG AS LONG
LOCAL Pressed_LG AS INTEGER
LOCAL PrevBkMode_LG AS LONG
LOCAL Focused_LG AS LONG
LOCAL Disabled_LG AS LONG
LOCAL ThemeActive_LG AS LONG
LOCAL ButtonW_LG AS LONG
LOCAL ButtonH_LG AS LONG
LOCAL IconX_LG AS LONG
LOCAL IconY_LG AS LONG
LOCAL Flags_LG AS LONG
LOCAL IconID_LG AS LONG
LOCAL IconPos_LG AS LONG
LOCAL IconWidth_LG AS LONG
LOCAL IconHeight_LG AS LONG
LOCAL Style_LG AS LONG
LOCAL SpotWidth_LG AS LONG
LOCAL SpotHeight_LG AS LONG
LOCAL SpotPos_LG AS LONG
LOCAL SpotX_LG AS LONG
LOCAL SpotY_LG AS LONG

IF Msg_LG <> %WM_DRAWITEM THEN
  OrigProc_DW = GetWindowLong (hDialog_DW, %GWL_USERDATA)
  IF Msg_LG = %WM_DESTROY THEN
    IF OrigProc_DW THEN
      SetWindowLong hDialog_DW, %GWL_WNDPROC, OrigProc_DW
      SetWindowLong hDialog_DW, %GWL_USERDATA, 0
    END IF
    IF hDialog_DW = s_hStartup_DW THEN
      GdiplusShutdown s_Token_DW
      s_Token_DW = 0
    END IF
    IF UBOUND(s_Focus) > 0 THEN
      FOR Index_LG = 1 TO UBOUND(s_Focus)
        IF s_Focus(Index_LG).hDialog_DW = hDialog_DW THEN EXIT FOR
      NEXT Index_LG
      IF Index_LG <= UBOUND(s_Focus) THEN
        s_Focus(Index_LG).hDialog_DW = 0
      END IF
    END IF
  ELSEIF Msg_LG = %BP_INIT THEN
    IF s_Token_DW = 0 THEN
      StartupInput.GdiplusVersion = 1
      GdiplusStartup(s_Token_DW, StartupInput, BYVAL %NULL)
      s_hStartup_DW = hDialog_DW
    END IF
  ELSEIF Msg_LG = %WM_NCACTIVATE THEN
    IF UBOUND(s_Focus) < 1 THEN
      REDIM s_Focus(1)
      Index_LG = 1
      s_Focus(Index_LG).hDialog_DW = hDialog_DW
      s_Focus(Index_LG).hControl_DW = GetFocus()
    ELSE
      FOR Index_LG = 1 TO UBOUND(s_Focus)
        IF s_Focus(Index_LG).hDialog_DW = hDialog_DW THEN EXIT FOR
        IF s_Focus(Index_LG).hDialog_DW = 0 THEN
          VacantIndex_LG = Index_LG
        END IF
      NEXT Index_LG
      IF Index_LG > UBOUND(s_Focus) THEN
        IF VacantIndex_LG THEN
          Index_LG = VacantIndex_LG
        ELSE
          REDIM PRESERVE s_Focus(Index_LG)
        END IF
        s_Focus(Index_LG).hDialog_DW = hDialog_DW
        s_Focus(Index_LG).hControl_DW = GetFocus()
      END IF
    END IF
    IF Wparam_DW THEN 'Dialog activate:
      IF ButtonPlus(s_Focus(Index_LG).hControl_DW, %NULL, %BP_INIT) THEN
        ButtonPlus s_Focus(Index_LG).hControl_DW, %NULL, %BP_DEFAULT, %FALSE
      END IF
      SetFocus(s_Focus(Index_LG).hControl_DW)
    ELSE 'Dialog de-activate:
      s_Focus(Index_LG).hControl_DW = GetFocus()
      IF ButtonPlus(s_Focus(Index_LG).hControl_DW, %NULL, %BP_INIT) THEN
        ButtonPlus s_Focus(Index_LG).hControl_DW, %NULL, %BP_DEFAULT, %TRUE
      END IF
    END IF
  END IF
  BPDialogHook = CallWindowProc (OrigProc_DW _
  , hDialog_DW, Msg_LG, Wparam_DW, Lparam_LG)
  EXIT FUNCTION
END IF

DrawItemPtr  = Lparam_LG
ButtonDC_DW = @DrawItemPtr.hDC
ButtonRect = @DrawItemPtr.rcItem
ButtonID_LG = @DrawItemPtr.CtlID

IF @DrawItemPtr.CtlType <> %ODT_BUTTON THEN
  OrigProc_DW = GetWindowLong (hDialog_DW, %GWL_USERDATA)
  BPDialogHook = CallWindowProc (OrigProc_DW _
  , hDialog_DW, Msg_LG, Wparam_DW, Lparam_LG)
  EXIT FUNCTION
ELSEIF ISFALSE ButtonPlus(hDialog_DW, ButtonID_LG, %BP_INIT) THEN
  OrigProc_DW = GetWindowLong (hDialog_DW, %GWL_USERDATA)
  BPDialogHook = CallWindowProc (OrigProc_DW _
  , hDialog_DW, Msg_LG, Wparam_DW, Lparam_LG)
  EXIT FUNCTION
END IF

hButton_DW = GetDlgItem(hDialog_DW, ButtonID_LG)
ThemeActive_LG = (IsThemeActive AND IsThemeDialogTextureEnabled(hDialog_DW))
Pressed_LG = SendDlgItemMessage(hDialog_DW, ButtonID_LG, %BM_GETSTATE, 0, 0)
Pressed_LG = Pressed_LG AND %BST_PUSHED
'
' Draw the button without caption
'
IF ISFALSE ThemeActive_LG THEN 'Classic button:
  IF (GetWindowLong(hButton_DW, %GWL_STYLE) AND %BS_FLAT) = %BS_FLAT THEN
    State_LG = %DFCS_BUTTONPUSH OR %DFCS_MONO
  ELSE
    State_LG = %DFCS_BUTTONPUSH
  END IF
  IF (@DrawItemPtr.itemState AND %ODS_FOCUS) = %ODS_FOCUS THEN
    Focused_LG = %TRUE
  ELSE
    Focused_LG = ButtonPlus(hButton_DW, %NULL, %BP_DEFAULT)
  END IF
  IF Focused_LG THEN
    IF ISFALSE Pressed_LG THEN
      FrameRect ButtonDC_DW, ButtonRect, GetSysColorBrush(%COLOR_WINDOWTEXT)
    END IF
    InflateRect ButtonRect, -1, -1
  END IF
  hBrush_DW = CreateSolidBrush(GetSysColor(%COLOR_BTNFACE))
  IF Pressed_LG THEN
    IF (State_LG AND %DFCS_MONO) = 0 THEN
      FillRect ButtonDC_DW, ButtonRect, hBrush_DW
      FrameRect ButtonDC_DW, ButtonRect, GetSysColorBrush(%COLOR_BTNSHADOW)
    ELSE
      DrawFrameControl ButtonDC_DW, ButtonRect, %DFC_BUTTON, State_LG
      FrameRect ButtonDC_DW, ButtonRect, GetSysColorBrush(%COLOR_3DDKSHADOW)
      InflateRect ButtonRect, -2, -2
      FillRect ButtonDC_DW, ButtonRect, hBrush_DW
      InflateRect ButtonRect, +2, +2
    END IF
    IF Focused_LG THEN
      IF (@DrawItemPtr.itemState AND %ODS_NOFOCUSRECT) = 0 THEN
        InflateRect ButtonRect, -3, -3
        DrawFocusRect ButtonDC_DW, ButtonRect
      END IF
    END IF
  ELSE
    DrawFrameControl ButtonDC_DW, ButtonRect, %DFC_BUTTON, State_LG
    IF (State_LG AND %DFCS_MONO) = 0 THEN
      OffsetRect ButtonRect, 1, 1
      ButtonRect.nRight = ButtonRect.nRight - 3
      ButtonRect.nBottom = ButtonRect.nBottom - 3
      FillRect ButtonDC_DW, ButtonRect, hBrush_DW
      ButtonRect.nRight = ButtonRect.nRight + 3
      ButtonRect.nBottom = ButtonRect.nBottom + 3
      OffsetRect ButtonRect, -1, -1
    ELSE
      InflateRect ButtonRect, -2, -2
      FillRect ButtonDC_DW, ButtonRect, hBrush_DW
      InflateRect ButtonRect, +2, +2
    END IF
    IF (@DrawItemPtr.itemState AND %ODS_FOCUS) = %ODS_FOCUS THEN
      IF (@DrawItemPtr.itemState AND %ODS_NOFOCUSRECT) = 0 THEN
        InflateRect ButtonRect, -3, -3
        DrawFocusRect ButtonDC_DW, ButtonRect
      END IF
    END IF
  END IF
  DeleteObject hBrush_DW
  GetClientRect hButton_DW, FaceRect
  FaceRect.nLeft = FaceRect.nLeft + 1
  FaceRect.nTop = FaceRect.nTop + 1
  FaceRect.nRight = FaceRect.nRight - 2
  FaceRect.nBottom = FaceRect.nBottom - 2
  Color_DW = ButtonPlus(hButton_DW, %NULL, %BP_FACE_COLOR)
  IF Color_DW THEN
    Color_DW = BGR(Color_DW)
    Alpha_DW = ButtonPlus(hButton_DW, %NULL, %BP_FACE_BLEND)
    IF Alpha_DW THEN
      SHIFT LEFT Alpha_DW, 24
      Color_DW = Color_DW OR Alpha_DW
    ELSE
      Color_DW = Color_DW OR &H7F000000
    END IF
    GdipCreateFromHDC(ButtonDC_DW, Graphics_DW)
    GdipCreateSolidFill Color_DW, hBrush_DW
    GdipSetSmoothingMode Graphics_DW, %ANTIALIAS
    GdipFillRectangleI Graphics_DW, hBrush_DW _
    , FaceRect.nLeft, FaceRect.nTop _
    , FaceRect.nRight - FaceRect.nLeft _
    , FaceRect.nBottom - FaceRect.nTop
    GdipDeleteBrush hBrush_DW
    GdipDeleteGraphics Graphics_DW
  END IF
  ButtonRect = FaceRect
  ButtonRect.nLeft = ButtonRect.nLeft + 1
  ButtonRect.nRight = ButtonRect.nRight + 1
ELSE 'Themed button:
  Class_ST = UCODE$("Button" + $NUL)
  hTheme_DW = OpenThemeData(hButton_DW, STRPTR(Class_ST))
  IF hTheme_DW THEN
    IF hButton_DW = GetFocus THEN
      Focused_LG = %TRUE
    ELSE
      Focused_LG = ButtonPlus(hButton_DW, %NULL, %BP_DEFAULT)
    END IF
    IF (SendMessage(hButton_DW, %BM_GETSTATE, 0, 0) AND %BST_PUSHED) = %BST_PUSHED THEN
      Pressed_LG = %TRUE
    END IF
    IF ISFALSE IsWindowEnabled(hButton_DW) THEN Disabled_LG = %TRUE
    State_LG = %PBS_NORMAL
    IF ISTRUE Pressed_LG THEN State_LG = %PBS_PRESSED
    IF ISTRUE Disabled_LG THEN State_LG = %PBS_DISABLED
    IF State_LG = %PBS_NORMAL THEN
      IF ISTRUE Focused_LG THEN State_LG = %PBS_DEFAULTED
      IF ISTRUE ButtonPlus(hButton_DW, %NULL, %BP_HOT) THEN State_LG = %PBS_HOT
    END IF
    FaceRect = ButtonRect
    InflateRect FaceRect, -1, -1
    DrawThemeBackground (hTheme_DW _
    , ButtonDC_DW _
    , %BP_PUSHBUTTON _
    , State_LG _
    , ButtonRect _
    , FaceRect)
    GetThemeBackgroundContentRect (hTheme_DW _
    , ButtonDC_DW _
    , %BP_PUSHBUTTON _
    , State_LG _
    , ButtonRect _
    , FaceRect)
    ButtonRect = FaceRect
    IF (@DrawItemPtr.itemState AND %ODS_FOCUS) = %ODS_FOCUS THEN
      IF (@DrawItemPtr.itemState AND %ODS_NOFOCUSRECT) = 0 THEN
        DrawFocusRect ButtonDC_DW, FaceRect
      END IF
    END IF
    Color_DW = ButtonPlus(hButton_DW, %NULL, %BP_FACE_COLOR)
    IF Color_DW THEN
      Color_DW = BGR(Color_DW)
      Alpha_DW = ButtonPlus(hButton_DW, %NULL, %BP_FACE_BLEND)
      IF Alpha_DW THEN
        SHIFT LEFT Alpha_DW, 24
        Color_DW = Color_DW OR Alpha_DW
      ELSE
        Color_DW = Color_DW OR &H7F000000
      END IF
      GdipCreateFromHDC(ButtonDC_DW, Graphics_DW)
      GdipCreateSolidFill Color_DW, hBrush_DW
      GdipSetSmoothingMode Graphics_DW, %ANTIALIAS
      GdipFillRectangleI Graphics_DW, hBrush_DW _
      , FaceRect.nLeft, FaceRect.nTop _
      , FaceRect.nRight - FaceRect.nLeft _
      , FaceRect.nBottom - FaceRect.nTop
      GdipDeleteBrush hBrush_DW
      GdipDeleteGraphics Graphics_DW
    END IF
  END IF
END IF
'
' Adjust button rectangle for pushed state if necessary
'
IF ISFALSE ThemeActive_LG THEN
  IF (SendMessage(hButton_DW, %BM_GETSTATE, 0, 0) AND %BST_PUSHED) THEN
    OffsetRect ButtonRect, 1, 1
  END IF
END IF
'
' Get button face width and height
'
ButtonW_LG = ButtonRect.nRight - ButtonRect.nLeft
ButtonH_LG = ButtonRect.nBottom - ButtonRect.nTop
'
' Get icon handle and dimensions
'
IconID_LG = ButtonPlus(hButton_DW, %NULL, %BP_ICON_ID)
IF IconID_LG THEN
  IconWidth_LG = ButtonPlus(hButton_DW, %NULL, %BP_ICON_WIDTH)
  IF IconWidth_LG = 0 THEN
    IconWidth_LG = ButtonPlus(hButton_DW, %NULL, %BP_ICON_HEIGHT)
    IF IconWidth_LG = 0 THEN
      IconWidth_LG = GetSystemMetrics(%SM_CXICON)
    END IF
    ButtonPlus hButton_DW, %NULL, %BP_ICON_WIDTH, IconWidth_LG
  END IF
  IconHeight_LG = ButtonPlus(hButton_DW, %NULL, %BP_ICON_HEIGHT)
  IF IconHeight_LG = 0 THEN
    IconHeight_LG = ButtonPlus(hButton_DW, %NULL, %BP_ICON_WIDTH)
    IF IconHeight_LG = 0 THEN
      IconHeight_LG = GetSystemMetrics(%SM_CYICON)
    END IF
    ButtonPlus hButton_DW, %NULL, %BP_ICON_HEIGHT, IconHeight_LG
  END IF
  IF IconID_LG < 32512 THEN
    hIcon_DW = LoadImage(GetModuleHandle ("") _
    , BYVAL IconID_LG _
    , %IMAGE_ICON _
    , IconWidth_LG _
    , IconHeight_LG _
    , %LR_SHARED)
  ELSE
    hIcon_DW = LoadImage(%NULL _
    , BYVAL IconID_LG _
    , %IMAGE_ICON _
    , IconWidth_LG _
    , IconHeight_LG _
    , %LR_SHARED)
    IconWidth_LG = GetSystemMetrics(%SM_CXICON)
    ButtonPlus hButton_DW, %NULL, %BP_ICON_WIDTH, IconWidth_LG
    IconHeight_LG = GetSystemMetrics(%SM_CYICON)
    ButtonPlus hButton_DW, %NULL, %BP_ICON_HEIGHT, IconHeight_LG
  END IF
  IF hIcon_DW = 0 THEN
    IconID_LG = %NULL
    ButtonPlus hButton_DW, %NULL, %BP_ICON_ID, IconID_LG
    IconWidth_LG = 0
    IconHeight_LG = 0
  END IF
ELSE
  IconWidth_LG = 0
  IconHeight_LG = 0
END IF
'
' Get or set spot dimensions
'
Color_DW = ButtonPlus(hButton_DW, %NULL, %BP_SPOT_COLOR)
IF Color_DW THEN
  SpotWidth_LG = ButtonPlus(hButton_DW, %NULL, %BP_SPOT_WIDTH)
  IF SpotWidth_LG = 0 THEN
    IF ISFALSE ThemeActive_LG THEN
      SpotWidth_LG = ButtonW_LG - 8
    ELSE
      SpotWidth_LG = ButtonW_LG - 4
    END IF
  END IF
  SpotHeight_LG = ButtonPlus(hButton_DW, %NULL, %BP_SPOT_HEIGHT)
  IF SpotHeight_LG = 0 THEN
    IF ISFALSE ThemeActive_LG THEN
      SpotHeight_LG = ButtonH_LG - 8
    ELSE
      SpotHeight_LG = ButtonH_LG - 4
    END IF
  END IF
ELSE
  SpotWidth_LG = 0
  SpotHeight_LG = 0
END IF
'
' Initialize text position rectangles
'
LeftRect.nLeft = 6
LeftRect.nTop = 3
LeftRect.nRight = ButtonW_LG - 6
LeftRect.nBottom = ButtonH_LG - 3
IF ThemeActive_LG THEN
  LeftRect.nLeft = LeftRect.nLeft + 2
  LeftRect.nTop = LeftRect.nTop + 1
ELSE
  LeftRect.nLeft = LeftRect.nLeft + 1
END IF
RightRect = LeftRect
UpperRect = LeftRect
LowerRect = LeftRect
'
' Set offset position of icon
'
IF IconID_LG THEN
  IconPos_LG = ButtonPlus(hButton_DW, %NULL, %BP_ICON_POS)
  IconX_LG = (ButtonW_LG - IconWidth_LG) \ 2  'Default centered X position
  IconY_LG = (ButtonH_LG - IconHeight_LG) \ 2 'Default centered Y position
  IconX_LG = (ButtonW_LG - IconWidth_LG) \ 2
  IconY_LG = (ButtonH_LG - IconHeight_LG) \ 2
  IF IconPos_LG THEN 'A non-centered icon is specified:
    IF (IconPos_LG AND %BS_CENTER) = %BS_LEFT THEN
      IF ButtonW_LG > ((IconWidth_LG * 5) \ 3) THEN
        IconX_LG = IconWidth_LG \ 3
      END IF
      RightRect.nLeft = IconX_LG + IconWidth_LG
      RightRect.nRight = ButtonW_LG
    ELSEIF (IconPos_LG AND %BS_CENTER) = %BS_RIGHT THEN
      IF ButtonW_LG > ((IconWidth_LG * 5) \ 3) THEN
        IconX_LG = ButtonW_LG - IconWidth_LG - (IconWidth_LG \ 3)
      END IF
      LeftRect.nLeft = 0
      LeftRect.nRight = IconX_LG
    END IF
    IF (IconPos_LG AND %BS_VCENTER) = %BS_TOP THEN
      IF ButtonH_LG > ((IconHeight_LG * 5) \ 3) THEN
        IconY_LG = (IconHeight_LG \ 3)
      END IF
      LowerRect.nTop = IconY_LG + IconHeight_LG
      LowerRect.nBottom = ButtonH_LG
    ELSEIF (IconPos_LG AND %BS_VCENTER) = %BS_BOTTOM THEN
      IF ButtonH_LG >= (IconHeight_LG * 2) THEN
        IconY_LG = (ButtonH_LG - IconHeight_LG - (IconHeight_LG \ 3))
      END IF
      UpperRect.nTop = 0
      UpperRect.nBottom = IconY_LG
    END IF
  END IF
END IF
'
' Set offset position of spot
'
Color_DW = ButtonPlus(hButton_DW, %NULL, %BP_SPOT_COLOR)
IF Color_DW THEN
  SpotPos_LG = ButtonPlus(hButton_DW, %NULL, %BP_SPOT_POS)
  SpotX_LG = (ButtonW_LG - SpotWidth_LG) \ 2
  SpotY_LG = (ButtonH_LG - SpotHeight_LG) \ 2
  IF SpotPos_LG THEN 'A non-centered spot is specified:
    IF (SpotPos_LG AND %BS_CENTER) = %BS_LEFT THEN
      SpotX_LG = SpotWidth_LG * 5 / 6 'Center
      IF (SpotX_LG > (ButtonW_LG \ 3)) OR (SpotX_LG < 16) THEN
        SpotX_LG = 16
        IF SpotX_LG > (ButtonW_LG \ 4) THEN
          SpotX_LG = ButtonW_LG \ 4
        END IF
      END IF
      SpotX_LG = SpotX_LG - (SpotWidth_LG \ 2)
      IF SpotX_LG > 0 THEN
        IF IconID_LG = 0 THEN
          RightRect.nLeft = SpotX_LG + SpotWidth_LG
          RightRect.nRight = ButtonW_LG
        END IF
      END IF
    ELSEIF (SpotPos_LG AND %BS_CENTER) = %BS_RIGHT THEN
      SpotX_LG = ButtonW_LG - (SpotWidth_LG * 5 / 6) 'Center
      IF (SpotX_LG < ((ButtonW_LG \ 3) * 2)) OR (SpotX_LG > (ButtonW_LG - 16)) THEN
        SpotX_LG = ButtonW_LG - 16
        IF SpotX_LG < ((ButtonW_LG \ 4) * 3) THEN
          SpotX_LG = (ButtonW_LG \ 4) * 3
        END IF
      END IF
      SpotX_LG = SpotX_LG - (SpotWidth_LG \ 2)
      IF (SpotX_LG + SpotWidth_LG) < ButtonW_LG THEN
        IF IconID_LG = 0 THEN
          LeftRect.nLeft = 0
          LeftRect.nRight = SpotX_LG
        END IF
      END IF
    END IF
    IF (SpotPos_LG AND %BS_VCENTER) = %BS_TOP THEN
      SpotY_LG = SpotHeight_LG * 5 / 6 'Center
      IF (SpotY_LG > (ButtonH_LG \ 3)) OR (SpotY_LG < 16) THEN
        SpotY_LG = 16
        IF SpotY_LG > (ButtonH_LG \ 4) THEN
          SpotY_LG = ButtonH_LG \ 4
        END IF
      END IF
      SpotY_LG = SpotY_LG - (SpotHeight_LG \ 2)
      IF SpotY_LG > 0 THEN
        IF IconID_LG = 0 THEN
          LowerRect.nTop = SpotY_LG + SpotHeight_LG
          LowerRect.nBottom = ButtonH_LG
        END IF
      END IF
    ELSEIF (SpotPos_LG AND %BS_VCENTER) = %BS_BOTTOM THEN
      SpotY_LG = ButtonH_LG - (SpotHeight_LG * 5 / 6) 'Center
      IF (SpotY_LG < (ButtonH_LG \ 2)) OR (SpotY_LG > (ButtonH_LG - 16))  THEN
        SpotY_LG = ButtonH_LG - 16
        IF SpotY_LG < ((ButtonH_LG \ 4) * 3) THEN
          SpotY_LG = (ButtonH_LG \ 4) * 3
        END IF
      END IF
      SpotY_LG = SpotY_LG - (SpotHeight_LG \ 2)
      IF (SpotY_LG + SpotHeight_LG) < ButtonH_LG THEN
        IF IconID_LG = 0 THEN
          UpperRect.nTop = 0
          UpperRect.nBottom = SpotY_LG
        END IF
      END IF
    END IF
  END IF
  IF SpotY_LG = ((ButtonH_LG - SpotHeight_LG) \ 2) THEN
    IF ((ButtonH_LG - SpotHeight_LG) MOD 2) = 0 THEN
      SpotHeight_LG = SpotHeight_LG - 1
    END IF
  END IF
  IF SpotX_LG = ((ButtonW_LG - SpotWidth_LG) \ 2) THEN
    IF ((ButtonW_LG - SpotWidth_LG) MOD 2) = 0 THEN
      SpotWidth_LG = SpotWidth_LG - 1
    END IF
  END IF
  IF ISFALSE ThemeActive_LG THEN SpotX_LG = SpotX_LG - 1
  SpotX_LG = SpotX_LG + ButtonRect.nLeft
  SpotY_LG = SpotY_LG + ButtonRect.nTop
END IF
'
' Process multi-line caption text
'
SendMessage hButton_DW, %WM_GETTEXT, 255, VARPTR(Caption_SZ)
IF LEN(Caption_SZ) THEN
  Style_LG = GetWindowLong(hButton_DW, %GWL_STYLE)
  IF INSTR(Caption_SZ, $CR) THEN Style_LG = (Style_LG OR %BS_MULTILINE)
  IF (Style_LG AND %BS_MULTILINE) THEN
    Caption_ST(1) = Caption_SZ
    REPLACE $LF WITH "" IN Caption_ST(1)
    TextLines_LG = 1
    DO
      CharPtr_LG = INSTR(Caption_ST(TextLines_LG), $CR)
      IF CharPtr_LG THEN
        Caption_ST(TextLines_LG + 1) = MID$(Caption_ST(TextLines_LG), CharPtr_LG + 1)
        Caption_ST(TextLines_LG) = LEFT$(Caption_ST(TextLines_LG), CharPtr_LG - 1)
        TextLines_LG = TextLines_LG + 1
      END IF
    LOOP WHILE CharPtr_LG
    FOR Index_LG = 1 TO TextLines_LG
      Caption_SZ = Caption_ST(Index_LG)
      GetTextExtentPoint32 ButtonDC_DW, Caption_SZ, LEN(Caption_SZ), CAPTION
      IF Caption.cx > LongestLine_LG THEN
        LongestLine_LG = Caption.cx
      END IF
    NEXT Index_LG
    IF LongestLine_LG > (ButtonW_LG - 20) THEN
      Index_LG = 1
      DO
        Caption_SZ = Caption_ST(Index_LG)
        GetTextExtentPoint32 ButtonDC_DW, Caption_SZ, LEN(Caption_SZ), CAPTION
        IF Caption.cx > (ButtonW_LG - 20) THEN
          CharPtr_LG = LEN(Caption_ST(Index_LG)) + 1
          DO
            CharPtr_LG = CharPtr_LG - (LEN(Caption_ST(Index_LG)) + 2)
            CharPtr_LG = INSTR(CharPtr_LG, Caption_ST(Index_LG), " ")
            IF CharPtr_LG THEN
              Caption_SZ = LEFT$(Caption_ST(Index_LG), CharPtr_LG - 1)
              GetTextExtentPoint32 ButtonDC_DW, Caption_SZ, LEN(Caption_SZ), CAPTION
            ELSE
              EXIT DO
            END IF
          LOOP WHILE Caption.cx > (ButtonW_LG - 20)
          IF CharPtr_LG THEN
            FOR Section_LG = TextLines_LG TO Index_LG + 1 STEP -1
              Caption_ST(Section_LG + 1) = Caption_ST(Section_LG)
            NEXT Section_LG
            Caption_ST(Index_LG + 1) = MID$(Caption_ST(Index_LG), CharPtr_LG + 1)
            Caption_ST(Index_LG) = LEFT$(Caption_ST(Index_LG), CharPtr_LG - 1)
            TextLines_LG = TextLines_LG + 1
          END IF
        END IF
        Index_LG = Index_LG + 1
      LOOP UNTIL Index_LG > TextLines_LG
      LongestLine_LG = 0
      FOR Index_LG = 1 TO TextLines_LG
        Caption_SZ = Caption_ST(Index_LG)
        GetTextExtentPoint32 ButtonDC_DW, Caption_SZ, LEN(Caption_SZ), CAPTION
        IF Caption.cx > LongestLine_LG THEN
          LongestLine_LG = Caption.cx
        END IF
      NEXT Index_LG
    END IF
  ELSE
    GetTextExtentPoint32 ButtonDC_DW, Caption_SZ, LEN(Caption_SZ), CAPTION
    LongestLine_LG = Caption.cx
    TextLines_LG = 1
    Caption_ST(1) = Caption_SZ
  END IF
  IF UpperRect.nTop = 0 THEN
    UpperRect.nTop = (UpperRect.nBottom - (Caption.cy * TextLines_LG)) \ 2
    UpperRect.nBottom = UpperRect.nTop + (Caption.cy * TextLines_LG)
  END IF
  IF LowerRect.nBottom = ButtonH_LG THEN
    LowerRect.nTop = ButtonH_LG - LowerRect.nTop 'Rectangle height
    LowerRect.nBottom = (LowerRect.nBottom - (LowerRect.nTop - (Caption.cy * TextLines_LG)) \ 2)
    LowerRect.nTop = LowerRect.nBottom - (Caption.cy * TextLines_LG)
  ELSE
    LowerRect.nTop = LowerRect.nBottom - (Caption.cy * TextLines_LG)
  END IF
END IF
'
PrevBkMode_LG = SetBkMode (ButtonDC_DW, %TRANSPARENT)
'
' Draw spot
'
IF Color_DW THEN
  Color_DW = BGR(Color_DW)
  Alpha_DW = ButtonPlus(hButton_DW, %NULL, %BP_SPOT_BLEND)
  IF Alpha_DW = 0 THEN
    Alpha_DW = &H7F
  END IF
  IF ISFALSE IsWindowEnabled(hButton_DW) THEN
    Alpha_DW = Alpha_DW \ 3
  END IF
  SHIFT LEFT Alpha_DW, 24
  Color_DW = Color_DW OR Alpha_DW
  GdipCreateFromHDC(ButtonDC_DW, Graphics_DW)
  GdipCreateSolidFill Color_DW, hBrush_DW
  GdipSetClipRectI Graphics_DW _
  , FaceRect.nLeft, FaceRect.nTop _
  , FaceRect.nRight - FaceRect.nLeft _
  , FaceRect.nBottom - FaceRect.nTop, %NULL
  GdipSetSmoothingMode Graphics_DW, %ANTIALIAS
  GdipFillEllipseI Graphics_DW, hBrush_DW _
  , SpotX_LG, SpotY_LG, SpotWidth_LG, SpotHeight_LG
  GdipDeleteBrush hBrush_DW
  GdipDeleteGraphics Graphics_DW
END IF
'
' Draw icon
'
IF IconWidth_LG THEN
  IconX_LG = ButtonRect.nLeft + IconX_LG
  IconY_LG = ButtonRect.nTop + IconY_LG
  IF IsWindowEnabled(hButton_DW) THEN
    Flags_LG = %DST_ICON
  ELSE
    Flags_LG = %DST_ICON + %DSS_DISABLED
  END IF
  DrawState ButtonDC_DW, 0, 0 _
  , hIcon_DW, 0 _
  , IconX_LG _
  , IconY_LG _
  , 0, 0 _
  , Flags_LG
END IF
'
' Draw caption text
'
IF LEN(Caption_SZ) THEN
  SetTextColor ButtonDC_DW, ButtonPlus(hButton_DW, %NULL, %BP_TEXT_COLOR)
  hFont_DW = SendMessage (hButton_DW, %WM_GETFONT, 0, 0)
  SelectObject ButtonDC_DW, hFont_DW
  IF IsWindowEnabled(hButton_DW) THEN
    Flags_LG = %DST_PREFIXTEXT
  ELSE
    IF ThemeActive_LG THEN
      Flags_LG = %DST_PREFIXTEXT + %DSS_MONO
      hBrush_DW = GetSysColorBrush(%COLOR_GRAYTEXT)
    ELSE
      Flags_LG = %DST_PREFIXTEXT + %DSS_DISABLED
      hBrush_DW = %NULL
    END IF
  END IF
  FOR Index_LG = 1 TO TextLines_LG
    Caption_SZ = Caption_ST(Index_LG)
    GetTextExtentPoint32 ButtonDC_DW, Caption_SZ, LEN(Caption_SZ), CAPTION
    IF (Style_LG AND %BS_CENTER) = %BS_LEFT THEN
      IF LeftRect.nLeft = 0 THEN
        TextRect.nLeft = (LeftRect.nRight - Caption.cx) \ 2
      ELSE
        TextRect.nLeft = LeftRect.nLeft
      END IF
    ELSEIF (Style_LG AND %BS_CENTER) = %BS_RIGHT THEN
      IF RightRect.nRight = ButtonW_LG THEN
        TextRect.nLeft = ButtonW_LG - RightRect.nLeft 'Rectangle width
        TextRect.nRight = ButtonW_LG - ((TextRect.nLeft - Caption.cx) \ 2)
        TextRect.nLeft = TextRect.nRight - Caption.cx
      ELSE
        TextRect.nLeft = RightRect.nRight - Caption.cx
      END IF
    ELSE
      TextRect.nLeft = (ButtonW_LG - Caption.cx) \ 2
      IF ThemeActive_LG THEN
        IF ((ButtonW_LG - LongestLine_LG) MOD 2) THEN TextRect.nLeft = TextRect.nLeft - 1
      ELSE
        IF ((ButtonW_LG - LongestLine_LG) MOD 2) = 0 THEN TextRect.nLeft = TextRect.nLeft - 1
      END IF
    END IF
    TextRect.nRight = TextRect.nLeft + Caption.cx
    IF (Style_LG AND %BS_VCENTER) = %BS_TOP THEN
      TextRect.nTop = UpperRect.nTop + (Caption.cy * (Index_LG - 1))
    ELSEIF (Style_LG AND %BS_VCENTER) = %BS_BOTTOM THEN
      TextRect.nTop = LowerRect.nTop + (Caption.cy * (Index_LG - 1))
    ELSE
      TextRect.nTop = (ButtonH_LG - (Caption.cy * TextLines_LG)) \ 2
      TextRect.nTop = TextRect.nTop + (Caption.cy * (Index_LG - 1))
    END IF
    TextRect.nBottom = TextRect.nTop + Caption.cy
    TextRect.nLeft = TextRect.nLeft + ButtonRect.nLeft
    TextRect.nRight = TextRect.nRight + ButtonRect.nLeft
    TextRect.nTop = TextRect.nTop + ButtonRect.nTop
    TextRect.nBottom = TextRect.nBottom + ButtonRect.nTop
    DrawState ButtonDC_DW _
    , hBrush_DW, 0 _
    , VARPTR(Caption_SZ) _
    , LEN(Caption_SZ) _
    , TextRect.nLeft _
    , TextRect.nTop _
    , TextRect.nRight _
    , TextRect.nbottom _
    , Flags_LG
  NEXT Index
END IF
'
SetBkMode ButtonDC_DW, PrevBkMode_LG

END FUNCTION

'------------------------------------------------------------------------------
