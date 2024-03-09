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

#include "ButtonPlus.inc"


function ButtonPlus ___________________________________________________________
                                                (hDialog_DW as dword,         _
                                                ButtonID_LG as dword,         _
                                                Property_LG as long,          _
                                          optional Value_LG as long           _
                                                          ) as dword
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

static s_ButtonStyle() as ButtonPlusType

local Index_LG as long
local hButton_DW as long
local OrigProc_DW as long
local Style_DW as dword
local VacantIndex_LG as long
local hWnd_DW as dword
local ControlID_LG as long
local Class_SZ as asciiz*80

if hDialog_DW = 0 then exit function
hWnd_DW = hDialog_DW
ControlID_LG = ButtonID_LG

if ButtonID_LG = 0 then
  hButton_DW = hDialog_DW
  ButtonID_LG = GetDlgCtrlID(hButton_DW)
  hDialog_DW = GetParent(hButton_DW)
  if hDialog_DW = 0 then
    hDialog_DW = hWnd_DW
    ButtonID_LG = ControlID_LG
    exit function
  end if
else
  hButton_DW = GetDlgItem(hDialog_DW, ButtonID_LG)
end if

if varptr(Value_LG) then
  if ubound(s_ButtonStyle) < 1 then
    redim s_ButtonStyle(1)
    s_ButtonStyle(1).hButton_DW = hButton_DW
    Index_LG = 1
  else
    for Index_LG = 1 to ubound(s_ButtonStyle)
      if s_ButtonStyle(Index_LG).hButton_DW = hButton_DW then
        exit for
      elseif s_ButtonStyle(Index_LG).hButton_DW = 0 then
        VacantIndex_LG = Index_LG
      end if
    next Index_LG
    if Index_LG > ubound(s_ButtonStyle) then 'New button:
      GetClassName hButton_DW, Class_SZ, sizeof(Class_SZ)
      if lcase$(Class_SZ) <> "button" then
        hDialog_DW = hWnd_DW
        ButtonID_LG = ControlID_LG
        exit function
      end if
      Style_DW = GetWindowLong(hButton_DW, %GWL_STYLE)
      if (Style_DW and &HF) > 1 then
        hDialog_DW = hWnd_DW
        ButtonID_LG = ControlID_LG
        exit function
      else
        if VacantIndex_LG = 0 then
          redim preserve s_ButtonStyle(Index_LG)
        else
          Index_LG = VacantIndex_LG
        end if
        s_ButtonStyle(Index_LG).hButton_DW = hButton_DW
      end if
    end if
  end if
  select case Property_LG
  case %BP_TEXT_COLOR
    s_ButtonStyle(Index_LG).TextColor_LG = Value_LG
  case %BP_ICON_ID
    s_ButtonStyle(Index_LG).IconID_LG = Value_LG
  case %BP_ICON_WIDTH
    s_ButtonStyle(Index_LG).IconWidth_LG = Value_LG
  case %BP_ICON_HEIGHT
    s_ButtonStyle(Index_LG).IconHeight_LG = Value_LG
  case %BP_ICON_POS
    s_ButtonStyle(Index_LG).IconPos_LG = Value_LG
  case %BP_FACE_COLOR
    s_ButtonStyle(Index_LG).FaceColor_LG = Value_LG
  case %BP_FACE_BLEND
    s_ButtonStyle(Index_LG).FaceBlend_LG = Value_LG and &HFF
  case %BP_SPOT_COLOR
    s_ButtonStyle(Index_LG).SpotColor_LG = Value_LG
  case %BP_SPOT_BLEND
    s_ButtonStyle(Index_LG).SpotBlend_LG = Value_LG and &HFF
  case %BP_SPOT_WIDTH
    s_ButtonStyle(Index_LG).SpotWidth_LG = Value_LG
  case %BP_SPOT_HEIGHT
    s_ButtonStyle(Index_LG).SpotHeight_LG = Value_LG
  case %BP_SPOT_POS
    s_ButtonStyle(Index_LG).SpotPos_LG = Value_LG
  case %BP_HOT
    s_ButtonStyle(Index_LG).Hot_LG = Value_LG
  case %BP_DEFAULT
    s_ButtonStyle(Index_LG).Default_LG = Value_LG
  end select
  Style_DW = GetWindowLong(hButton_DW, %GWL_STYLE)
  Style_DW = (Style_DW and &HFFFFFFF0) or %BS_OWNERDRAW
  SetWindowLong hButton_DW, %GWL_STYLE, Style_DW
  OrigProc_DW = GetWindowLong (hButton_DW, %GWL_USERDATA)
  if OrigProc_DW = 0 then
    SetWindowLong hButton_DW, %GWL_WNDPROC, codeptr(BPControlHook) to OrigProc_DW
    SetWindowLong hButton_DW, %GWL_USERDATA, OrigProc_DW
    OrigProc_DW = GetWindowLong (hDialog_DW, %GWL_USERDATA)
    if OrigProc_DW = 0 then
      SetWindowLong hDialog_DW, %GWL_WNDPROC, codeptr(BPDialogHook) to OrigProc_DW
      SetWindowLong hDialog_DW, %GWL_USERDATA, OrigProc_DW
      SendMessage hDialog_DW, %BP_INIT, 0, 0
    end if
  end if
else
  for Index_LG = ubound(s_ButtonStyle) to 1 step -1
    if s_ButtonStyle(Index_LG).hButton_DW = hButton_DW then
      exit for
    end if          'If handle is not found,
  next Index_LG     'Index_LG is zero
end if
select case Property_LG
case %BP_TEXT_COLOR
  ButtonPlus = s_ButtonStyle(Index_LG).TextColor_LG
case %BP_ICON_ID
  ButtonPlus = s_ButtonStyle(Index_LG).IconID_LG
case %BP_ICON_WIDTH
  ButtonPlus = s_ButtonStyle(Index_LG).IconWidth_LG
case %BP_ICON_HEIGHT
  ButtonPlus = s_ButtonStyle(Index_LG).IconHeight_LG
case %BP_ICON_POS
  ButtonPlus = s_ButtonStyle(Index_LG).IconPos_LG
case %BP_FACE_COLOR
  ButtonPlus = s_ButtonStyle(Index_LG).FaceColor_LG
case %BP_FACE_BLEND
  ButtonPlus = s_ButtonStyle(Index_LG).FaceBlend_LG
case %BP_SPOT_COLOR
  ButtonPlus = s_ButtonStyle(Index_LG).SpotColor_LG
case %BP_SPOT_BLEND
  ButtonPlus = s_ButtonStyle(Index_LG).SpotBlend_LG
case %BP_SPOT_WIDTH
  ButtonPlus = s_ButtonStyle(Index_LG).SpotWidth_LG
case %BP_SPOT_HEIGHT
  ButtonPlus = s_ButtonStyle(Index_LG).SpotHeight_LG
case %BP_SPOT_POS
  ButtonPlus = s_ButtonStyle(Index_LG).SpotPos_LG
case %BP_HOT
  ButtonPlus = s_ButtonStyle(Index_LG).Hot_LG
case %BP_DEFAULT
  ButtonPlus = s_ButtonStyle(Index_LG).Default_LG
case %BP_DESTROY
  OrigProc_DW = GetWindowLong (hButton_DW, %GWL_USERDATA)
  if OrigProc_DW then
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
  end if
case %BP_INIT
  if Index_LG then
    ButtonPlus = %TRUE
  end if
end select

hDialog_DW = hWnd_DW
ButtonID_LG = ControlID_LG

end function


function BPControlHook ________________________________________________________
                                          (byval hButton_DW as dword,         _
                                               byval Msg_LG as long,          _
                                           byval Wparam_DW as dword,          _
                                            byval Lparam_LG as long           _
                                                          ) as long
'------------------------------------------------------------------------------
'
' CONTROL subclassing procedure.
'
'------------------------------------------------------------------------------

local ButtonID_LG as long
local hDialog_DW as dword
local OrigProc_DW as dword
local Style_DW as dword
local TrackMouse as TRACKMOUSEEVENTAPI

if Msg_LG = %BM_SETSTYLE then
  if (Wparam_DW and &HFFFFFFFE) = 0 then
    ButtonPlus hButton_DW, %NULL, %BP_DEFAULT, %FALSE
  end if
  Wparam_DW = (Wparam_DW and &HFFFFFFF0) or %BS_OWNERDRAW
end if

OrigProc_DW = GetWindowLong (hButton_DW, %GWL_USERDATA)
BPControlHook = CallWindowProc (OrigProc_DW _
,hButton_DW, Msg_LG, Wparam_DW, Lparam_LG)

select case Msg_LG
case %WM_MOUSEMOVE
  if isfalse ButtonPlus(hButton_DW, %NULL, %BP_HOT) then
    TrackMouse.cbSize = sizeof(TrackMouse)
    TrackMouse.dwFlags = %TME_LEAVE
    TrackMouse.hwndTrack = hButton_DW
    TrackMouse.dwHoverTime = 1
    TrackMouseEvent(TrackMouse)
    ButtonPlus hButton_DW, %NULL, %BP_HOT, %TRUE
    InvalidateRect hButton_DW, byval %NULL, 0
    UpdateWindow hButton_DW
  end if
case %WM_MOUSELEAVE
  ButtonPlus hButton_DW, %NULL, %BP_HOT, %FALSE
  InvalidateRect hButton_DW, BYVAL %NULL, 0
  UpdateWindow hButton_DW
case %WM_DESTROY
  ButtonPlus hButton_DW, %NULL, %BP_DESTROY
end select

end function


function BPDialogHook _________________________________________________________
                                          (byval hDialog_DW as dword,         _
                                               byval Msg_LG as long,          _
                                            byval Wparam_DW as dword,         _
                                            byval Lparam_LG as long           _
                                                          ) as long
'------------------------------------------------------------------------------
'
' DIALOG subclassing procedure.
'
' The WM_DRAWITEM message is only sent for buttons, comboboxes, listboxes or
' menus with the OWNERDRAW style. The message is sent to the parent of the
' control, hence the procedure for the parent dialog is hooked.
'
'------------------------------------------------------------------------------

static s_Token_DW as dword
static s_hStartup_DW as dword
static s_Focus() as FocusType

local StartupInput as GdiplusStartupInput
local DrawItemPtr as DRAWITEMSTRUCT ptr

local ButtonRect as RECT
local FaceRect as RECT
local TextRect as RECT
local LeftRect as RECT
local UpperRect as RECT
local RightRect as RECT
local LowerRect as RECT

local Caption as SIZEL
local Caption_SZ as asciiz*255
local Caption_ST() as string
redim Caption_ST(1 to 10)
local Class_ST as string

local TextLines_LG as long
local CharPtr_LG as long
local LongestLine_LG as long
local Section_LG as long

local OrigProc_DW as dword
local hButton_DW as dword
local ButtonID_LG as long
local Index_LG as long
local VacantIndex_LG as long

local ButtonDC_DW as dword
local Color_DW as dword
local Alpha_DW as dword
local Graphics_DW as dword
local hBrush_DW as dword
local hTheme_DW as dword
local hFont_DW as dword
local hIcon_DW as dword

local State_LG as long
local Pressed_LG as integer
local PrevBkMode_LG as long
local Focused_LG as long
local Disabled_LG as long
local ThemeActive_LG as long
local ButtonW_LG as long
local ButtonH_LG as long
local IconX_LG as long
local IconY_LG as long
local Flags_LG as long
local IconID_LG as long
local IconPos_LG as long
local IconWidth_LG as long
local IconHeight_LG as long
local Style_LG as long
local SpotWidth_LG as long
local SpotHeight_LG as long
local SpotPos_LG as long
local SpotX_LG as long
local SpotY_LG as long

if Msg_LG <> %WM_DRAWITEM then
  OrigProc_DW = GetWindowLong (hDialog_DW, %GWL_USERDATA)
  if Msg_LG = %WM_DESTROY then
    if OrigProc_DW then
      SetWindowLong hDialog_DW, %GWL_WNDPROC, OrigProc_DW
      SetWindowLong hDialog_DW, %GWL_USERDATA, 0
    end if
    if hDialog_DW = s_hStartup_DW then
      GdiplusShutdown s_Token_DW
      s_Token_DW = 0
    end if
    if ubound(s_Focus) > 0 then
      for Index_LG = 1 to ubound(s_Focus)
        if s_Focus(Index_LG).hDialog_DW = hDialog_DW then exit for
      next Index_LG
      if Index_LG <= ubound(s_Focus) then
        s_Focus(Index_LG).hDialog_DW = 0
      end if
    end if
  elseif Msg_LG = %BP_INIT then
    if s_Token_DW = 0 then
      StartupInput.GdiplusVersion = 1
      GdiplusStartup(s_Token_DW, StartupInput, byval %NULL)
      s_hStartup_DW = hDialog_DW
    end if
  elseif Msg_LG = %WM_NCACTIVATE then
    if ubound(s_Focus) < 1 then
      redim s_Focus(1)
      Index_LG = 1
      s_Focus(Index_LG).hDialog_DW = hDialog_DW
      s_Focus(Index_LG).hControl_DW = GetFocus()
    else
      for Index_LG = 1 to ubound(s_Focus)
        if s_Focus(Index_LG).hDialog_DW = hDialog_DW then exit for
        if s_Focus(Index_LG).hDialog_DW = 0 then
          VacantIndex_LG = Index_LG
        end if
      next Index_LG
      if Index_LG > ubound(s_Focus) then
        if VacantIndex_LG then
          Index_LG = VacantIndex_LG
        else
          redim preserve s_Focus(Index_LG)
        end if
        s_Focus(Index_LG).hDialog_DW = hDialog_DW
        s_Focus(Index_LG).hControl_DW = GetFocus()
      end if
    end if
    if Wparam_DW then 'Dialog activate:
      if ButtonPlus(s_Focus(Index_LG).hControl_DW, %NULL, %BP_INIT) then
        ButtonPlus s_Focus(Index_LG).hControl_DW, %NULL, %BP_DEFAULT, %FALSE
      end if
      SetFocus(s_Focus(Index_LG).hControl_DW)
    else 'Dialog de-activate:
      s_Focus(Index_LG).hControl_DW = GetFocus()
      if ButtonPlus(s_Focus(Index_LG).hControl_DW, %NULL, %BP_INIT) then
        ButtonPlus s_Focus(Index_LG).hControl_DW, %NULL, %BP_DEFAULT, %TRUE
      end if
    end if
  end if
  BPDialogHook = CallWindowProc (OrigProc_DW _
  , hDialog_DW, Msg_LG, Wparam_DW, Lparam_LG)
  exit function
end if

DrawItemPtr  = Lparam_LG
ButtonDC_DW = @DrawItemPtr.hDC
ButtonRect = @DrawItemPtr.rcItem
ButtonID_LG = @DrawItemPtr.CtlID

if @DrawItemPtr.CtlType <> %ODT_BUTTON then
  OrigProc_DW = GetWindowLong (hDialog_DW, %GWL_USERDATA)
  BPDialogHook = CallWindowProc (OrigProc_DW _
  , hDialog_DW, Msg_LG, Wparam_DW, Lparam_LG)
  exit function
elseif isfalse ButtonPlus(hDialog_DW, ButtonID_LG, %BP_INIT) then
  OrigProc_DW = GetWindowLong (hDialog_DW, %GWL_USERDATA)
  BPDialogHook = CallWindowProc (OrigProc_DW _
  , hDialog_DW, Msg_LG, Wparam_DW, Lparam_LG)
  exit function
end if

hButton_DW = GetDlgItem(hDialog_DW, ButtonID_LG)
ThemeActive_LG = (IsThemeActive and IsThemeDialogTextureEnabled(hDialog_DW))
Pressed_LG = SendDlgItemMessage(hDialog_DW, ButtonID_LG, %BM_GETSTATE, 0, 0)
Pressed_LG = Pressed_LG and %BST_PUSHED
'
' Draw the button without caption
'
if isfalse ThemeActive_LG then 'Classic button:
  if (GetWindowLong(hButton_DW, %GWL_STYLE) and %BS_FLAT) = %BS_FLAT then
    State_LG = %DFCS_BUTTONPUSH or %DFCS_MONO
  else
    State_LG = %DFCS_BUTTONPUSH
  end if
  if (@DrawItemPtr.itemState and %ODS_FOCUS) = %ODS_FOCUS then
    Focused_LG = %TRUE
  else
    Focused_LG = ButtonPlus(hButton_DW, %NULL, %BP_DEFAULT)
  end if
  if Focused_LG then
    if isfalse Pressed_LG then
      FrameRect ButtonDC_DW, ButtonRect, GetSysColorBrush(%COLOR_WINDOWTEXT)
    end if
    InflateRect ButtonRect, -1, -1
  end if
  hBrush_DW = CreateSolidBrush(GetSysColor(%COLOR_BTNFACE))
  if Pressed_LG then
    if (State_LG and %DFCS_MONO) = 0 then
      FillRect ButtonDC_DW, ButtonRect, hBrush_DW
      FrameRect ButtonDC_DW, ButtonRect, GetSysColorBrush(%COLOR_BTNSHADOW)
    else
      DrawFrameControl ButtonDC_DW, ButtonRect, %DFC_BUTTON, State_LG
      FrameRect ButtonDC_DW, ButtonRect, GetSysColorBrush(%COLOR_3DDKSHADOW)
      InflateRect ButtonRect, -2, -2
      FillRect ButtonDC_DW, ButtonRect, hBrush_DW
      InflateRect ButtonRect, +2, +2
    end if
    if Focused_LG then
      if (@DrawItemPtr.itemState and %ODS_NOFOCUSRECT) = 0 then
        InflateRect ButtonRect, -3, -3
        DrawFocusRect ButtonDC_DW, ButtonRect
      end if
    end if
  else
    DrawFrameControl ButtonDC_DW, ButtonRect, %DFC_BUTTON, State_LG
    if (State_LG and %DFCS_MONO) = 0 then
      OffsetRect ButtonRect, 1, 1
      ButtonRect.nRight = ButtonRect.nRight - 3
      ButtonRect.nBottom = ButtonRect.nBottom - 3
      FillRect ButtonDC_DW, ButtonRect, hBrush_DW
      ButtonRect.nRight = ButtonRect.nRight + 3
      ButtonRect.nBottom = ButtonRect.nBottom + 3
      OffsetRect ButtonRect, -1, -1
    else
      InflateRect ButtonRect, -2, -2
      FillRect ButtonDC_DW, ButtonRect, hBrush_DW
      InflateRect ButtonRect, +2, +2
    end if
    if (@DrawItemPtr.itemState and %ODS_FOCUS) = %ODS_FOCUS then
      if (@DrawItemPtr.itemState and %ODS_NOFOCUSRECT) = 0 then
        InflateRect ButtonRect, -3, -3
        DrawFocusRect ButtonDC_DW, ButtonRect
      end if
    end if
  end if
  DeleteObject hBrush_DW
  GetClientRect hButton_DW, FaceRect
  FaceRect.nLeft = FaceRect.nLeft + 1
  FaceRect.nTop = FaceRect.nTop + 1
  FaceRect.nRight = FaceRect.nRight - 2
  FaceRect.nBottom = FaceRect.nBottom - 2
  Color_DW = ButtonPlus(hButton_DW, %NULL, %BP_FACE_COLOR)
  if Color_DW then
    Color_DW = bgr(Color_DW)
    Alpha_DW = ButtonPlus(hButton_DW, %NULL, %BP_FACE_BLEND)
    if Alpha_DW then
      shift left Alpha_DW, 24
      Color_DW = Color_DW or Alpha_DW
    else
      Color_DW = Color_DW or &H7F000000
    end if
    GdipCreateFromHDC(ButtonDC_DW, Graphics_DW)
    GdipCreateSolidFill Color_DW, hBrush_DW
    GdipSetSmoothingMode Graphics_DW, %ANTIALIAS
    GdipFillRectangleI Graphics_DW, hBrush_DW _
    , FaceRect.nLeft, FaceRect.nTop _
    , FaceRect.nRight - FaceRect.nLeft _
    , FaceRect.nBottom - FaceRect.nTop
    GdipDeleteBrush hBrush_DW
    GdipDeleteGraphics Graphics_DW
  end if
  ButtonRect = FaceRect
  ButtonRect.nLeft = ButtonRect.nLeft + 1
  ButtonRect.nRight = ButtonRect.nRight + 1
else 'Themed button:
  Class_ST = ucode$("Button" + $NUL)
  hTheme_DW = OpenThemeData(hButton_DW, strptr(Class_ST))
  if hTheme_DW then
    if hButton_DW = GetFocus then
      Focused_LG = %TRUE
    else
      Focused_LG = ButtonPlus(hButton_DW, %NULL, %BP_DEFAULT)
    end if
    if (SendMessage(hButton_DW, %BM_GETSTATE, 0, 0) and %BST_PUSHED) = %BST_PUSHED then
      Pressed_LG = %TRUE
    end if
    if isfalse IsWindowEnabled(hButton_DW) then Disabled_LG = %TRUE
    State_LG = %PBS_NORMAL
    if istrue Pressed_LG then State_LG = %PBS_PRESSED
    if istrue Disabled_LG then State_LG = %PBS_DISABLED
    if State_LG = %PBS_NORMAL then
      if istrue Focused_LG then State_LG = %PBS_DEFAULTED
      if istrue ButtonPlus(hButton_DW, %NULL, %BP_HOT) then State_LG = %PBS_HOT
    end if
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
    if (@DrawItemPtr.itemState and %ODS_FOCUS) = %ODS_FOCUS then
      if (@DrawItemPtr.itemState and %ODS_NOFOCUSRECT) = 0 then
        DrawFocusRect ButtonDC_DW, FaceRect
      end if
    end if
    Color_DW = ButtonPlus(hButton_DW, %NULL, %BP_FACE_COLOR)
    if Color_DW then
      Color_DW = bgr(Color_DW)
      Alpha_DW = ButtonPlus(hButton_DW, %NULL, %BP_FACE_BLEND)
      if Alpha_DW then
        shift left Alpha_DW, 24
        Color_DW = Color_DW or Alpha_DW
      else
        Color_DW = Color_DW or &H7F000000
      end if
      GdipCreateFromHDC(ButtonDC_DW, Graphics_DW)
      GdipCreateSolidFill Color_DW, hBrush_DW
      GdipSetSmoothingMode Graphics_DW, %ANTIALIAS
      GdipFillRectangleI Graphics_DW, hBrush_DW _
      , FaceRect.nLeft, FaceRect.nTop _
      , FaceRect.nRight - FaceRect.nLeft _
      , FaceRect.nBottom - FaceRect.nTop
      GdipDeleteBrush hBrush_DW
      GdipDeleteGraphics Graphics_DW
    end if
  end if
end if
'
' Adjust button rectangle for pushed state if necessary
'
if isfalse ThemeActive_LG then
  if (SendMessage(hButton_DW, %BM_GETSTATE, 0, 0) and %BST_PUSHED) then
    OffsetRect ButtonRect, 1, 1
  end if
end if
'
' Get button face width and height
'
ButtonW_LG = ButtonRect.nRight - ButtonRect.nLeft
ButtonH_LG = ButtonRect.nBottom - ButtonRect.nTop
'
' Get icon handle and dimensions
'
IconID_LG = ButtonPlus(hButton_DW, %NULL, %BP_ICON_ID)
if IconID_LG then
  IconWidth_LG = ButtonPlus(hButton_DW, %NULL, %BP_ICON_WIDTH)
  if IconWidth_LG = 0 then
    IconWidth_LG = ButtonPlus(hButton_DW, %NULL, %BP_ICON_HEIGHT)
    if IconWidth_LG = 0 then
      IconWidth_LG = GetSystemMetrics(%SM_CXICON)
    end if
    ButtonPlus hButton_DW, %NULL, %BP_ICON_WIDTH, IconWidth_LG
  end if
  IconHeight_LG = ButtonPlus(hButton_DW, %NULL, %BP_ICON_HEIGHT)
  if IconHeight_LG = 0 then
    IconHeight_LG = ButtonPlus(hButton_DW, %NULL, %BP_ICON_WIDTH)
    if IconHeight_LG = 0 then
      IconHeight_LG = GetSystemMetrics(%SM_CYICON)
    end if
    ButtonPlus hButton_DW, %NULL, %BP_ICON_HEIGHT, IconHeight_LG
  end if
  if IconID_LG < 32512 then
    hIcon_DW = LoadImage(GetModuleHandle ("") _
    , byval IconID_LG _
    , %IMAGE_ICON _
    , IconWidth_LG _
    , IconHeight_LG _
    , %LR_SHARED)
  else
    hIcon_DW = LoadImage(%NULL _
    , byval IconID_LG _
    , %IMAGE_ICON _
    , IconWidth_LG _
    , IconHeight_LG _
    , %LR_SHARED)
    IconWidth_LG = GetSystemMetrics(%SM_CXICON)
    ButtonPlus hButton_DW, %NULL, %BP_ICON_WIDTH, IconWidth_LG
    IconHeight_LG = GetSystemMetrics(%SM_CYICON)
    ButtonPlus hButton_DW, %NULL, %BP_ICON_HEIGHT, IconHeight_LG
  end if
  if hIcon_DW = 0 then
    IconID_LG = %NULL
    ButtonPlus hButton_DW, %NULL, %BP_ICON_ID, IconID_LG
    IconWidth_LG = 0
    IconHeight_LG = 0
  end if
else
  IconWidth_LG = 0
  IconHeight_LG = 0
end if
'
' Get or set spot dimensions
'
Color_DW = ButtonPlus(hButton_DW, %NULL, %BP_SPOT_COLOR)
if Color_DW then
  SpotWidth_LG = ButtonPlus(hButton_DW, %NULL, %BP_SPOT_WIDTH)
  if SpotWidth_LG = 0 then
    if isfalse ThemeActive_LG then
      SpotWidth_LG = ButtonW_LG - 8
    else
      SpotWidth_LG = ButtonW_LG - 4
    end if
  end if
  SpotHeight_LG = ButtonPlus(hButton_DW, %NULL, %BP_SPOT_HEIGHT)
  if SpotHeight_LG = 0 then
    if isfalse ThemeActive_LG then
      SpotHeight_LG = ButtonH_LG - 8
    else
      SpotHeight_LG = ButtonH_LG - 4
    end if
  end if
else
  SpotWidth_LG = 0
  SpotHeight_LG = 0
end if
'
' Initialize text position rectangles
'
LeftRect.nLeft = 6
LeftRect.nTop = 3
LeftRect.nRight = ButtonW_LG - 6
LeftRect.nBottom = ButtonH_LG - 3
if ThemeActive_LG then
  LeftRect.nLeft = LeftRect.nLeft + 2
  LeftRect.nTop = LeftRect.nTop + 1
else
  LeftRect.nLeft = LeftRect.nLeft + 1
end if
RightRect = LeftRect
UpperRect = LeftRect
LowerRect = LeftRect
'
' Set offset position of icon
'
if IconID_LG then
  IconPos_LG = ButtonPlus(hButton_DW, %NULL, %BP_ICON_POS)
  IconX_LG = (ButtonW_LG - IconWidth_LG) \ 2  'Default centered X position
  IconY_LG = (ButtonH_LG - IconHeight_LG) \ 2 'Default centered Y position
  IconX_LG = (ButtonW_LG - IconWidth_LG) \ 2
  IconY_LG = (ButtonH_LG - IconHeight_LG) \ 2
  if IconPos_LG then 'A non-centered icon is specified:
    if (IconPos_LG and %BS_CENTER) = %BS_LEFT then
      if ButtonW_LG > ((IconWidth_LG * 5) \ 3) then
        IconX_LG = IconWidth_LG \ 3
      end if
      RightRect.nLeft = IconX_LG + IconWidth_LG
      RightRect.nRight = ButtonW_LG
    elseif (IconPos_LG and %BS_CENTER) = %BS_RIGHT then
      if ButtonW_LG > ((IconWidth_LG * 5) \ 3) then
        IconX_LG = ButtonW_LG - IconWidth_LG - (IconWidth_LG \ 3)
      end if
      LeftRect.nLeft = 0
      LeftRect.nRight = IconX_LG
    end if
    if (IconPos_LG and %BS_VCENTER) = %BS_TOP then
      if ButtonH_LG > ((IconHeight_LG * 5) \ 3) then
        IconY_LG = (IconHeight_LG \ 3)
      end if
      LowerRect.nTop = IconY_LG + IconHeight_LG
      LowerRect.nBottom = ButtonH_LG
    elseif (IconPos_LG and %BS_VCENTER) = %BS_BOTTOM then
      if ButtonH_LG >= (IconHeight_LG * 2) then
        IconY_LG = (ButtonH_LG - IconHeight_LG - (IconHeight_LG \ 3))
      end if
      UpperRect.nTop = 0
      UpperRect.nBottom = IconY_LG
    end if
  end if
end if
'
' Set offset position of spot
'
Color_DW = ButtonPlus(hButton_DW, %NULL, %BP_SPOT_COLOR)
if Color_DW then
  SpotPos_LG = ButtonPlus(hButton_DW, %NULL, %BP_SPOT_POS)
  SpotX_LG = (ButtonW_LG - SpotWidth_LG) \ 2
  SpotY_LG = (ButtonH_LG - SpotHeight_LG) \ 2
  if SpotPos_LG then 'A non-centered spot is specified:
    if (SpotPos_LG and %BS_CENTER) = %BS_LEFT then
      SpotX_LG = SpotWidth_LG * 5 / 6 'Center
      if (SpotX_LG > (ButtonW_LG \ 3)) or (SpotX_LG < 16) then
        SpotX_LG = 16
        if SpotX_LG > (ButtonW_LG \ 4) then
          SpotX_LG = ButtonW_LG \ 4
        end if
      end if
      SpotX_LG = SpotX_LG - (SpotWidth_LG \ 2)
      if SpotX_LG > 0 then
        if IconID_LG = 0 then
          RightRect.nLeft = SpotX_LG + SpotWidth_LG
          RightRect.nRight = ButtonW_LG
        end if
      end if
    elseif (SpotPos_LG and %BS_CENTER) = %BS_RIGHT then
      SpotX_LG = ButtonW_LG - (SpotWidth_LG * 5 / 6) 'Center
      if (SpotX_LG < ((ButtonW_LG \ 3) * 2)) or (SpotX_LG > (ButtonW_LG - 16)) then
        SpotX_LG = ButtonW_LG - 16
        if SpotX_LG < ((ButtonW_LG \ 4) * 3) then
          SpotX_LG = (ButtonW_LG \ 4) * 3
        end if
      end if
      SpotX_LG = SpotX_LG - (SpotWidth_LG \ 2)
      if (SpotX_LG + SpotWidth_LG) < ButtonW_LG then
        if IconID_LG = 0 then
          LeftRect.nLeft = 0
          LeftRect.nRight = SpotX_LG
        end if
      end if
    end if
    if (SpotPos_LG and %BS_VCENTER) = %BS_TOP then
      SpotY_LG = SpotHeight_LG * 5 / 6 'Center
      if (SpotY_LG > (ButtonH_LG \ 3)) or (SpotY_LG < 16) then
        SpotY_LG = 16
        if SpotY_LG > (ButtonH_LG \ 4) then
          SpotY_LG = ButtonH_LG \ 4
        end if
      end if
      SpotY_LG = SpotY_LG - (SpotHeight_LG \ 2)
      if SpotY_LG > 0 then
        if IconID_LG = 0 then
          LowerRect.nTop = SpotY_LG + SpotHeight_LG
          LowerRect.nBottom = ButtonH_LG
        end if
      end if
    elseif (SpotPos_LG and %BS_VCENTER) = %BS_BOTTOM then
      SpotY_LG = ButtonH_LG - (SpotHeight_LG * 5 / 6) 'Center
      if (SpotY_LG < (ButtonH_LG \ 2)) or (SpotY_LG > (ButtonH_LG - 16))  then
        SpotY_LG = ButtonH_LG - 16
        if SpotY_LG < ((ButtonH_LG \ 4) * 3) then
          SpotY_LG = (ButtonH_LG \ 4) * 3
        end if
      end if
      SpotY_LG = SpotY_LG - (SpotHeight_LG \ 2)
      if (SpotY_LG + SpotHeight_LG) < ButtonH_LG then
        if IconID_LG = 0 then
          UpperRect.nTop = 0
          UpperRect.nBottom = SpotY_LG
        end if
      end if
    end if
  end if
  if SpotY_LG = ((ButtonH_LG - SpotHeight_LG) \ 2) then
    if ((ButtonH_LG - SpotHeight_LG) mod 2) = 0 then
      SpotHeight_LG = SpotHeight_LG - 1
    end if
  end if
  if SpotX_LG = ((ButtonW_LG - SpotWidth_LG) \ 2) then
    if ((ButtonW_LG - SpotWidth_LG) mod 2) = 0 then
      SpotWidth_LG = SpotWidth_LG - 1
    end if
  end if
  if isfalse ThemeActive_LG then SpotX_LG = SpotX_LG - 1
  SpotX_LG = SpotX_LG + ButtonRect.nLeft
  SpotY_LG = SpotY_LG + ButtonRect.nTop
end if
'
' Process multi-line caption text
'
SendMessage hButton_DW, %WM_GETTEXT, 255, varptr(Caption_SZ)
if len(Caption_SZ) then
  Style_LG = GetWindowLong(hButton_DW, %GWL_STYLE)
  if instr(Caption_SZ, $CR) then Style_LG = (Style_LG or %BS_MULTILINE)
  if (Style_LG and %BS_MULTILINE) then
    Caption_ST(1) = Caption_SZ
    replace $LF with "" in Caption_ST(1)
    TextLines_LG = 1
    do
      CharPtr_LG = instr(Caption_ST(TextLines_LG), $CR)
      if CharPtr_LG then
        Caption_ST(TextLines_LG + 1) = mid$(Caption_ST(TextLines_LG), CharPtr_LG + 1)
        Caption_ST(TextLines_LG) = left$(Caption_ST(TextLines_LG), CharPtr_LG - 1)
        TextLines_LG = TextLines_LG + 1
      end if
    loop while CharPtr_LG
    for Index_LG = 1 to TextLines_LG
      Caption_SZ = Caption_ST(Index_LG)
      GetTextExtentPoint32 ButtonDC_DW, Caption_SZ, len(Caption_SZ), Caption
      if Caption.cx > LongestLine_LG then
        LongestLine_LG = Caption.cx
      end if
    next Index_LG
    if LongestLine_LG > (ButtonW_LG - 20) then
      Index_LG = 1
      do
        Caption_SZ = Caption_ST(Index_LG)
        GetTextExtentPoint32 ButtonDC_DW, Caption_SZ, len(Caption_SZ), Caption
        if Caption.cx > (ButtonW_LG - 20) then
          CharPtr_LG = len(Caption_ST(Index_LG)) + 1
          do
            CharPtr_LG = CharPtr_LG - (len(Caption_ST(Index_LG)) + 2)
            CharPtr_LG = instr(CharPtr_LG, Caption_ST(Index_LG), " ")
            if CharPtr_LG then
              Caption_SZ = left$(Caption_ST(Index_LG), CharPtr_LG - 1)
              GetTextExtentPoint32 ButtonDC_DW, Caption_SZ, len(Caption_SZ), Caption
            else
              exit do
            end if
          loop while Caption.cx > (ButtonW_LG - 20)
          if CharPtr_LG then
            for Section_LG = TextLines_LG to Index_LG + 1 step -1
              Caption_ST(Section_LG + 1) = Caption_ST(Section_LG)
            next Section_LG
            Caption_ST(Index_LG + 1) = mid$(Caption_ST(Index_LG), CharPtr_LG + 1)
            Caption_ST(Index_LG) = left$(Caption_ST(Index_LG), CharPtr_LG - 1)
            TextLines_LG = TextLines_LG + 1
          end if
        end if
        Index_LG = Index_LG + 1
      loop until Index_LG > TextLines_LG
      LongestLine_LG = 0
      for Index_LG = 1 to TextLines_LG
        Caption_SZ = Caption_ST(Index_LG)
        GetTextExtentPoint32 ButtonDC_DW, Caption_SZ, len(Caption_SZ), Caption
        if Caption.cx > LongestLine_LG then
          LongestLine_LG = Caption.cx
        end if
      next Index_LG
    end if
  else
    GetTextExtentPoint32 ButtonDC_DW, Caption_SZ, len(Caption_SZ), Caption
    LongestLine_LG = Caption.cx
    TextLines_LG = 1
    Caption_ST(1) = Caption_SZ
  end if
  if UpperRect.nTop = 0 then
    UpperRect.nTop = (UpperRect.nBottom - (Caption.cy * TextLines_LG)) \ 2
    UpperRect.nBottom = UpperRect.nTop + (Caption.cy * TextLines_LG)
  end if
  if LowerRect.nBottom = ButtonH_LG then
    LowerRect.nTop = ButtonH_LG - LowerRect.nTop 'Rectangle height
    LowerRect.nBottom = (LowerRect.nBottom - (LowerRect.nTop - (Caption.cy * TextLines_LG)) \ 2)
    LowerRect.nTop = LowerRect.nBottom - (Caption.cy * TextLines_LG)
  else
    LowerRect.nTop = LowerRect.nBottom - (Caption.cy * TextLines_LG)
  end if
end if
'
PrevBkMode_LG = SetBkMode (ButtonDC_DW, %TRANSPARENT)
'
' Draw spot
'
if Color_DW then
  Color_DW = bgr(Color_DW)
  Alpha_DW = ButtonPlus(hButton_DW, %NULL, %BP_SPOT_BLEND)
  if Alpha_DW = 0 then
    Alpha_DW = &H7F
  end if
  if isfalse IsWindowEnabled(hButton_DW) then
    Alpha_DW = Alpha_DW \ 3
  end if
  shift left Alpha_DW, 24
  Color_DW = Color_DW or Alpha_DW
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
end if
'
' Draw icon
'
if IconWidth_LG then
  IconX_LG = ButtonRect.nLeft + IconX_LG
  IconY_LG = ButtonRect.nTop + IconY_LG
  if IsWindowEnabled(hButton_DW) then
    Flags_LG = %DST_ICON
  else
    Flags_LG = %DST_ICON + %DSS_DISABLED
  end if
  DrawState ButtonDC_DW, 0, 0 _
  , hIcon_DW, 0 _
  , IconX_LG _
  , IconY_LG _
  , 0, 0 _
  , Flags_LG
end if
'
' Draw caption text
'
if len(Caption_SZ) then
  SetTextColor ButtonDC_DW, ButtonPlus(hButton_DW, %NULL, %BP_TEXT_COLOR)
  hFont_DW = SendMessage (hButton_DW, %WM_GETFONT, 0, 0)
  SelectObject ButtonDC_DW, hFont_DW
  if IsWindowEnabled(hButton_DW) then
    Flags_LG = %DST_PREFIXTEXT
  else
    if ThemeActive_LG then
      Flags_LG = %DST_PREFIXTEXT + %DSS_MONO
      hBrush_DW = GetSysColorBrush(%COLOR_GRAYTEXT)
    else
      Flags_LG = %DST_PREFIXTEXT + %DSS_DISABLED
      hBrush_DW = %NULL
    end if
  end if
  for Index_LG = 1 to TextLines_LG
    Caption_SZ = Caption_ST(Index_LG)
    GetTextExtentPoint32 ButtonDC_DW, Caption_SZ, len(Caption_SZ), Caption
    if (Style_LG and %BS_CENTER) = %BS_LEFT then
      if LeftRect.nLeft = 0 then
        TextRect.nLeft = (LeftRect.nRight - Caption.cx) \ 2
      else
        TextRect.nLeft = LeftRect.nLeft
      end if
    elseif (Style_LG and %BS_CENTER) = %BS_RIGHT then
      if RightRect.nRight = ButtonW_LG then
        TextRect.nLeft = ButtonW_LG - RightRect.nLeft 'Rectangle width
        TextRect.nRight = ButtonW_LG - ((TextRect.nLeft - Caption.cx) \ 2)
        TextRect.nLeft = TextRect.nRight - Caption.cx
      else
        TextRect.nLeft = RightRect.nRight - Caption.cx
      end if
    else
      TextRect.nLeft = (ButtonW_LG - Caption.cx) \ 2
      if ThemeActive_LG then
        if ((ButtonW_LG - LongestLine_LG) mod 2) then TextRect.nLeft = TextRect.nLeft - 1
      else
        if ((ButtonW_LG - LongestLine_LG) mod 2) = 0 then TextRect.nLeft = TextRect.nLeft - 1
      end if
    end if
    TextRect.nRight = TextRect.nLeft + Caption.cx
    if (Style_LG and %BS_VCENTER) = %BS_TOP then
      TextRect.nTop = UpperRect.nTop + (Caption.cy * (Index_LG - 1))
    elseif (Style_LG and %BS_VCENTER) = %BS_BOTTOM then
      TextRect.nTop = LowerRect.nTop + (Caption.cy * (Index_LG - 1))
    else
      TextRect.nTop = (ButtonH_LG - (Caption.cy * TextLines_LG)) \ 2
      TextRect.nTop = TextRect.nTop + (Caption.cy * (Index_LG - 1))
    end if
    TextRect.nBottom = TextRect.nTop + Caption.cy
    TextRect.nLeft = TextRect.nLeft + ButtonRect.nLeft
    TextRect.nRight = TextRect.nRight + ButtonRect.nLeft
    TextRect.nTop = TextRect.nTop + ButtonRect.nTop
    TextRect.nBottom = TextRect.nBottom + ButtonRect.nTop
    DrawState ButtonDC_DW _
    , hBrush_DW, 0 _
    , varptr(Caption_SZ) _
    , len(Caption_SZ) _
    , TextRect.nLeft _
    , TextRect.nTop _
    , TextRect.nRight _
    , TextRect.nbottom _
    , Flags_LG
  next Index
end if
'
SetBkMode ButtonDC_DW, PrevBkMode_LG

end function

'------------------------------------------------------------------------------
