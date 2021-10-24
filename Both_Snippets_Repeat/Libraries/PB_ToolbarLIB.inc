' PB_ToolbarLIB.inc
'
' This library loads the resources for your common toolbar
'
' Index to functions
' ------------------
' CreateToolbar(hDlg AS DWORD, _
'               BYVAL lngToolbar AS LONG) - create a Toolbar
'

' adding a toolbar to your form
' CONTROL ADD TOOLBAR, hDlg, %MainToolbar, "", 0, 0, 0, 0, _
'        %WS_CHILD OR %WS_VISIBLE OR %WS_TABSTOP OR %CCS_TOP OR _
'        %TBSTYLE_FLAT
' ' add the icons and buttons to the blank toolbar
'  CreateToolbar hDlg, %MainToolbar


' Toolbar event handles - these are used to define
' the events when a toolbar button is clicked
ENUM TB SINGULAR
  ID_ADD       = 4001          ' toolbar add user event
  ID_Save                      ' toolbar save event
  ID_Help                      ' toolbar help icon event
  ID_Reports                   ' toolbar reports event
END ENUM
'
' toolbar resources - load up the icons
#RESOURCE ICON, TB_ID_ADD, "..\Libraries\Graphics\add.ico"
#RESOURCE ICON, TB_ID_Save, "..\Libraries\Graphics\save.ico"
#RESOURCE ICON, TB_ID_Help, "..\Libraries\Graphics\Help_1.ico"
#RESOURCE ICON, TB_ID_Reports, "..\Libraries\Graphics\Reports.ico"
'
FUNCTION CreateToolbar(BYVAL hDlg AS DWORD, _
                       BYVAL lngToolbar AS LONG) AS LONG
' populate a toolbar with icons on specified toolbar
'
  LOCAL hImgList AS LONG                  ' handle for imagelist object
  LOCAL lngDepth,lngWidth,lngHeight,lngInitial AS LONG
  '
  lngDepth = 32     ' depth of colour e.g. 32bit - how many colours allowed
  lngWidth = 32     ' width of icon in pixels
  lngHeight = 32    ' height of icon in pixels
  lngInitial = 6    ' allocated space in imagelist object
                    ' to store buttons (increase as more are needed)
  ' create a new imagelist
  IMAGELIST NEW ICON lngDepth,lngWidth,lngHeight,lngInitial TO hImgList
  '
  PREFIX "IMAGELIST ADD ICON hImgList, "
    "TB_ID_ADD"
    "TB_ID_Save"
    "TB_ID_Reports"
    "TB_ID_Help"
  END PREFIX
  '
  ' set the imagelist against the toolbar
  TOOLBAR SET IMAGELIST hDlg, lngToolbar, hImgList, 0
  '
  ' add buttons and separators to the toolbar
  PREFIX "TOOLBAR ADD BUTTON hDlg, lngToolbar,"
    1,%ID_ADD, %TBSTYLE_BUTTON, "Add Item"
    2,%ID_Save, %TBSTYLE_BUTTON, "Save Changes"
    3,%ID_Reports,%TBSTYLE_BUTTON, "Reports"
    4,%ID_Help, %TBSTYLE_BUTTON, "Help"
  END PREFIX
  ' add a separator between buttons
  ' which is 20 pixels wide before the 4th button
  TOOLBAR ADD SEPARATOR hDlg, lngToolbar, 20 AT 4
  '
END FUNCTION
'
' sample code for events in dialog
'        CASE %ID_ADD
'          IF CB.CTLMSG = %BN_CLICKED OR CB.CTLMSG = 1 THEN
'          END IF
'
'        CASE %ID_Save
'          IF CB.CTLMSG = %BN_CLICKED OR CB.CTLMSG = 1 THEN
'          END IF
'
'        CASE %ID_Help
'          IF CB.CTLMSG = %BN_CLICKED OR CB.CTLMSG = 1 THEN
'          END IF
'
'        CASE %ID_Reports
'          IF CB.CTLMSG = %BN_CLICKED OR CB.CTLMSG = 1 THEN
'          END IF
