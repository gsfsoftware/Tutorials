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
'#RESOURCE "PB_LiteBrowser.pbr"
#INCLUDE ONCE "WIN32API.INC"
#INCLUDE ONCE "COMMCTRL.INC"
#INCLUDE ONCE "PBForms.INC"
#PBFORMS END INCLUDES
'------------------------------------------------------------------------------
#INCLUDE ONCE "Tooltips.inc"
'
GLOBAL g_lngTabcount AS LONG      ' total number of tabs
GLOBAL g_alngTabHandles() AS LONG ' array to hold tab handles
'------------------------------------------------------------------------------
'   ** Constants **
'------------------------------------------------------------------------------
#PBFORMS BEGIN CONSTANTS
%IDD_dlgPBLiteBrowser =  101
%IDC_STATUSBAR1       = 1001
%IDC_TAB1             = 1002
%IDC_txtURL           = 1003
%IDC_IMGback          = 1004
%IDC_IMGForward       = 1005
%IDC_IMGReload        = 1006
%IDC_IMGHome          = 1007
%IDC_Graphic          = 1008
#PBFORMS END CONSTANTS
'------------------------------------------------------------------------------
' redraw section
%IdCol           = 1
%WidthCol        = 2
%HeightCol       = 3
%MinWindowHeight = 250        ' minimum size of the height - window will
                              ' not shrink below this value
%MaxWindowHeight = 99999      ' maximum size of the window height
%MinWindowWidth  = 480        ' minimum size of the width - window will
                              ' not shrink below this value
%MaxWindowWidth  = 99999      ' maximum size of the width
'
#INCLUDE ONCE "PB_Redraw.inc"
'
#RESOURCE MANIFEST 1,"XPTheme.xml"
#RESOURCE ICON 2000 "App.ico"
#RESOURCE ICON 2001 "BackButton.ico"
#RESOURCE ICON 2002 "NextButton.ico"
#RESOURCE ICON 2003 "SmallMagnify.ico"
'------------------------------------------------------------------------------
'   ** Declarations **
'------------------------------------------------------------------------------

#PBFORMS DECLARATIONS
'------------------------------------------------------------------------------
GLOBAL hFont AS DWORD   ' default font
'------------------------------------------------------------------------------
'   ** Main Application Entry Point **
'------------------------------------------------------------------------------
FUNCTION PBMAIN()
  PBFormsInitComCtls (%ICC_WIN95_CLASSES OR %ICC_DATE_CLASSES OR _
    %ICC_INTERNET_CLASSES)
    '
  LOCAL lngPoint AS LONG
  lngPoint = 12
  ' create a new font
  FONT NEW "Courier New",lngPoint TO hFont
  '
  ShowdlgPBLiteBrowser %HWND_DESKTOP
  ' tidy up font when app ending
  FONT END hFont
  '
END FUNCTION
'------------------------------------------------------------------------------

'------------------------------------------------------------------------------
'   ** CallBacks **
'------------------------------------------------------------------------------
CALLBACK FUNCTION ShowdlgPBLiteBrowserProc()
  LOCAL lngPageDlgVar AS LONG
  '
  SELECT CASE AS LONG CB.MSG
    CASE %WM_INITDIALOG
    ' Initialization handler
    ' insert a tab page
      TAB INSERT PAGE CB.HNDL, %IDC_TAB1, 1, 0, "Home" _
          TO lngPageDlgVar
          '
      ' store the tab handle
      REDIM g_alngTabHandles(1) AS LONG
      g_alngTabHandles(1) = lngPageDlgVar
      '
      ' add the tooltips
      PREFIX "CALL ToolTip_SetToolTip (GetDlgItem(CB.HNDL, "
        %IDC_txtURL),"Enter URL or file path to HTML site/file", %YELLOW, %BLUE)
        %IDC_IMGback),"Click to go back to previous page", %YELLOW, %BLUE)
        %IDC_IMGForward),"Click to go forward to next page", %YELLOW, %BLUE)
        %IDC_IMGHome),"Click to go to home page", %YELLOW, %BLUE)
        %IDC_IMGReload),"Click to reload current page", %YELLOW, %BLUE)
      END PREFIX
      '
      ' disable navigation until html page loaded
      PREFIX "Control Disable cb.hndl,"
        %IDC_IMGback
        %IDC_IMGForward
      END PREFIX
      '
      ' set focus to the text URL control
      CONTROL SET FOCUS CB.HNDL,%IDC_txtURL
      '
    CASE %WM_SIZE
    ' Dialog has been resized
      CONTROL SEND CB.HNDL, %IDC_STATUSBAR1, CB.MSG, CB.WPARAM, CB.LPARAM
      '
      IF ISTRUE isIconic(CB.HNDL) THEN EXIT FUNCTION  ' Exit if app is minimized
      '
      funResize CB.HNDL, 0, "Initialize"  ' Call this first
      ' now resize any controls
      funResizeControls(CB.HNDL)
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

      END SELECT
  END SELECT
END FUNCTION
'------------------------------------------------------------------------------
FUNCTION funResizeControls(hDlg AS DWORD) AS LONG
' resize the windows controls
'
  funResize hDlg, %IDC_txtURL, "Scale-H"
  funResize hDlg, %IDC_TAB1,   "Scale-H"
  funResize hDlg, %IDC_Graphic,"Scale-H"
  funResize hDlg, %IDC_Graphic,"Scale-V"
  '
  ' repaint the form
  funResize hDlg, 0, "Repaint"
  '
  ' repaint the graphics control
  GRAPHIC CLEAR %RGB_BLACK ,0
  GRAPHIC REDRAW
  '
END FUNCTION

'------------------------------------------------------------------------------
'   ** Dialogs **
'------------------------------------------------------------------------------
FUNCTION ShowdlgPBLiteBrowser(BYVAL hParent AS DWORD) AS LONG
  LOCAL lRslt AS LONG

#PBFORMS BEGIN DIALOG %IDD_dlgPBLiteBrowser->->
  LOCAL hDlg  AS DWORD      ' handle of the dialog
  LOCAL lngWide AS LONG     ' width of the gparhics control
  LOCAL lngHigh AS LONG     ' height of the graphics control
  '
  DIALOG NEW hParent, "PB Lite Browser", 229, 201, 611, 324, %WS_POPUP OR _
    %WS_BORDER OR %WS_DLGFRAME OR %WS_CAPTION OR %WS_SYSMENU OR _
    %WS_MINIMIZEBOX OR %WS_MAXIMIZEBOX OR %WS_CLIPSIBLINGS OR %WS_VISIBLE OR _
    %WS_THICKFRAME OR _
    %DS_MODALFRAME OR %DS_3DLOOK OR %DS_NOFAILCREATE OR %DS_SETFONT, _
    %WS_EX_CONTROLPARENT OR %WS_EX_LEFT OR %WS_EX_LTRREADING OR _
    %WS_EX_RIGHTSCROLLBAR, TO hDlg
  CONTROL ADD STATUSBAR, hDlg, %IDC_STATUSBAR1, "", 0, 0, 0, 0
  CONTROL ADD TEXTBOX,   hDlg, %IDC_txtURL, "", 135, 5, 475, 20
  CONTROL ADD IMGBUTTON, hDlg, %IDC_IMGback, "", 0, 0, 32, 32
  CONTROL ADD IMGBUTTON, hDlg, %IDC_IMGForward, "", 33, 0, 32, 32
  CONTROL ADD IMGBUTTON, hDlg, %IDC_IMGReload, "", 66, 0, 32, 32
  CONTROL ADD IMGBUTTONX,hDlg, %IDC_IMGHome, "", 99, 0, 32, 32
  CONTROL ADD TAB,       hDlg, %IDC_TAB1, "Tab1", 0, 35, 610, 20
#PBFORMS END DIALOG
  lngWide = 600
  lngHigh = 250
  CONTROL ADD GRAPHIC, hDlg, %IDC_Graphic, "", 5, 56, lngWide, lngHigh, _
                       %SS_NOTIFY OR %SS_SUNKEN
                       '
  GRAPHIC ATTACH hDlg,%IDC_Graphic , REDRAW
  '
  GRAPHIC CLEAR %RGB_BLACK ,0
  GRAPHIC REDRAW
  '
  ' set the images on controls
  PREFIX "CONTROL SET IMGBUTTON hDlg,"
    %IDC_IMGback,   "#2001"
    %IDC_IMGForward,"#2002"
    %IDC_IMGReload, "#2003"
  END PREFIX
  ' load the Home button icon
  CONTROL SET IMGBUTTONX hDlg,%IDC_IMGHome,"#2000"
  '
  ' set the font on the URL text box
  CONTROL SET FONT hDlg,%IDC_txtURL, hFont
  '
  ' set the icon for the dialog
  DIALOG SET ICON hDlg, "#2000"
  '
  DIALOG SHOW MODAL hDlg, CALL ShowdlgPBLiteBrowserProc TO lRslt
  '
#PBFORMS BEGIN CLEANUP %IDD_DIALOG1
#PBFORMS END CLEANUP

  FUNCTION = lRslt
END FUNCTION
'------------------------------------------------------------------------------
