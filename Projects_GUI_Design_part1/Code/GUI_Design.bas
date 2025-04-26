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
#RESOURCE "GUI_Design.pbr"
%USEMACROS = 1
#INCLUDE ONCE "WIN32API.INC"
#INCLUDE ONCE "COMMCTRL.INC"
#INCLUDE ONCE "PBForms.INC"
#PBFORMS END INCLUDES
'------------------------------------------------------------------------------
%IdCol           = 1
%WidthCol        = 2
%HeightCol       = 3
%MinWindowHeight = 300        ' minimum size of the height - window will not shrink below this value
%MaxWindowHeight = 99999      ' maximum size of the window height
%MinWindowWidth  = 480        ' minimum size of the width - window will not shrink below this value
%MaxWindowWidth  = 99999      ' maximum size of the width

#INCLUDE "PB_Redraw.inc"
'------------------------------------------------------------------------------
'   ** Constants **
'------------------------------------------------------------------------------
#PBFORMS BEGIN CONSTANTS
%IDD_dlgMainDialog =  101
%IDC_GRAPHIC1      = 1001
#PBFORMS END CONSTANTS
'------------------------------------------------------------------------------

'------------------------------------------------------------------------------
'   ** Declarations **
'------------------------------------------------------------------------------
DECLARE CALLBACK FUNCTION ShowdlgMainDialogProc()
DECLARE FUNCTION ShowdlgMainDialog(BYVAL hParent AS DWORD) AS LONG
#PBFORMS DECLARATIONS
'------------------------------------------------------------------------------

'------------------------------------------------------------------------------
'   ** Main Application Entry Point **
'------------------------------------------------------------------------------
FUNCTION PBMAIN()
  PBFormsInitComCtls (%ICC_WIN95_CLASSES OR %ICC_DATE_CLASSES OR _
    %ICC_INTERNET_CLASSES)
  '
  ShowdlgMainDialog %HWND_DESKTOP
  '
END FUNCTION
'------------------------------------------------------------------------------

'------------------------------------------------------------------------------
'   ** CallBacks **
'------------------------------------------------------------------------------
CALLBACK FUNCTION ShowdlgMainDialogProc()
' callback function to handle all window events
'
  SELECT CASE AS LONG CB.MSG
    CASE %WM_INITDIALOG
      ' Initialization handler
      DIALOG MAXIMIZE CB.HNDL
      '
    CASE %WM_NCACTIVATE
      STATIC hWndSaveFocus AS DWORD
      IF ISFALSE CB.WPARAM THEN
        ' Save control focus
        hWndSaveFocus = GetFocus()
        '
      ELSEIF hWndSaveFocus THEN
        ' Restore control focus
        SetFocus(hWndSaveFocus)
        hWndSaveFocus = 0
      END IF
      '
    CASE %WM_PAINT
      ' fill with a gradient colour
      funGradientFillGraphicControl(CB.HNDL,%IDC_GRAPHIC1)
      '
    CASE %WM_SIZE
    ' form is resizing
      IF ISTRUE isIconic(CB.HNDL) THEN EXIT FUNCTION  ' Exit if app is minimized
      '
      funResize CB.HNDL, 0, "Initialize"  ' Must be called first
      ' now resize the graphic control
      funResizeGraphicControl(CB.HNDL,%IDC_GRAPHIC1)
      ' and repaint it
      DIALOG SEND CB.HNDL,%WM_PAINT,0,0
      '
    CASE %WM_COMMAND
      ' Process control notifications
      SELECT CASE AS LONG CB.CTL

      END SELECT
  END SELECT
END FUNCTION
'------------------------------------------------------------------------------

'------------------------------------------------------------------------------
'   ** Dialogs **
'------------------------------------------------------------------------------
FUNCTION ShowdlgMainDialog(BYVAL hParent AS DWORD) AS LONG
  LOCAL lRslt AS LONG

#PBFORMS BEGIN DIALOG %IDD_dlgMainDialog->->
  LOCAL hDlg  AS DWORD

  DIALOG NEW PIXELS, hParent, "Hex Dialog Demo", 205, 185, 688, 399, %WS_POPUP OR _
    %WS_BORDER OR %WS_DLGFRAME OR %WS_THICKFRAME OR %WS_CAPTION OR _
    %WS_SYSMENU OR %WS_MINIMIZEBOX OR %WS_MAXIMIZEBOX OR %WS_CLIPSIBLINGS OR _
    %WS_VISIBLE OR %DS_MODALFRAME OR %DS_CENTER OR %DS_3DLOOK OR _
    %DS_NOFAILCREATE OR %DS_SETFONT, %WS_EX_CONTROLPARENT OR %WS_EX_LEFT OR _
    %WS_EX_LTRREADING OR %WS_EX_RIGHTSCROLLBAR, TO hDlg
  CONTROL ADD GRAPHIC, hDlg, %IDC_GRAPHIC1, "", 0, 0, 445, 270
#PBFORMS END DIALOG
  ' prepare the graphic control
  GRAPHIC ATTACH hDlg, %IDC_GRAPHIC1
  'GRAPHIC COLOR -1, %BLACK
  GRAPHIC CLEAR
  '
  DIALOG SHOW MODAL hDlg, CALL ShowdlgMainDialogProc TO lRslt

#PBFORMS BEGIN CLEANUP %IDD_dlgMainDialog
#PBFORMS END CLEANUP

  FUNCTION = lRslt
END FUNCTION
'------------------------------------------------------------------------------
FUNCTION funGradientFillGraphicControl(hDlg AS DWORD, _
                                       lngGraphicCtl AS LONG) AS LONG
' fill the graphic with a gradient
  DIM V(1) AS TriVertex
  LOCAL w,h AS LONG     ' width and height of graphics control
  LOCAL hDC AS DWORD    ' device context handle
  LOCAL gRect AS Gradient_Rect
  '
  CONTROL GET CLIENT hDlg, lngGraphicCtl TO w,h
  '
  GRAPHIC GET DC TO hDC
  ' define the colours to be used
  V(0).x      = 0
  V(0).y      = 0
  V(0).Red    = MAK(WORD,0,255)  ' from RED
  V(0).Green  = 0
  V(0).Blue   = 0
  V(1).x      = w   '<--- not w-1
  V(1).y      = h   '<--- not h-1
  V(1).Red    = 0
  V(1).Green  = 0
  V(1).Blue   = MAK(WORD,0,255)  ' to BLUE
  '
  gRect.UpperLeft = 0
  gRect.LowerRight = 1
  '
  ' apply the gradient fill to the graphics control
  GradientFill hDC, V(0), 2, gRect, 1, %Gradient_Fill_Rect_H
  GRAPHIC REDRAW      ' now redraw the graphic control
'
END FUNCTION
'
FUNCTION funResizeGraphicControl(hDlg AS DWORD, _
                                 lngGraphicCtl AS LONG) AS LONG
' resize the graphic control
  LOCAL lngX, lngY AS LONG
  '
  ' get the client area
  DIALOG GET CLIENT hDlg TO lngX, lngY
  '
  ' set the graphic control to the same size
  GRAPHIC SET CLIENT lngX , lngY
  '
END FUNCTION
