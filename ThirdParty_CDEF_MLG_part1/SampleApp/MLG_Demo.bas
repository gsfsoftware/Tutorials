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
#RESOURCE "MLG_Demo.pbr"
%USEMACROS = 1
#INCLUDE ONCE "WIN32API.INC"
#INCLUDE ONCE "COMMCTRL.INC"
#INCLUDE ONCE "PBForms.INC"
#PBFORMS END INCLUDES
'------------------------------------------------------------------------------
%MLGSLL = 1
#INCLUDE "MLG.INC"
#LINK "MLG.SLL"
'
%max_cols = 50
%max_tabs = 5
%max_grids = 1
%Max_Forms = 10
'
#RESOURCE ICON, AppIcon, "..\Libraries\Graphics\Staff.ico"
'
'#INCLUDE "_PBCommon\SQLT_PRO.inc"
#INCLUDE ONCE "..\Libraries\PB_xml.inc"
#INCLUDE ONCE "DBServer.inc"

'#INCLUDE once "..\Libraries\PB_GenericSQLFunctions.inc"
#INCLUDE ONCE "..\Libraries\PB_Common_Windows.inc"
#INCLUDE ONCE "..\Libraries\PB_GenericCDEF_Functions.inc"
'
#INCLUDE ONCE "..\Libraries\PB_FileHandlingRoutines.inc"
' add the toolbars library
#INCLUDE ONCE "..\Libraries\PB_ToolbarLIB.inc"
' add the MLG macros
#INCLUDE ONCE "..\Libraries\macMLGevents.inc"
'------------------------------------------------------------------------------
'   ** Constants **
'------------------------------------------------------------------------------
#PBFORMS BEGIN CONSTANTS
%IDD_dlgDemoGrid        =  101
%IDC_lblRecordsReturned = 1001
#PBFORMS END CONSTANTS
'
%MainToolbar            = 2000    ' constant for main toolbar
'------------------------------------------------------------------------------
%AMR_UPDATED            = 99              ' row marker for updated record
%AMR_SAVED              = 0               ' row marker for saved record
#INCLUDE "..\Libraries\PB_MLG_Utilities.inc" '
'

%MAX_rows  = 6000     ' max number of rows for format override
#INCLUDE "..\Libraries\FormGridTab_Resource.inc"
'------------------------------------------------------------------------------
'   ** Declarations **
'------------------------------------------------------------------------------
DECLARE CALLBACK FUNCTION ShowdlgDemoGridProc()
DECLARE FUNCTION ShowdlgDemoGrid(BYVAL hParent AS DWORD) AS LONG
#PBFORMS DECLARATIONS
'------------------------------------------------------------------------------
%AMDB = 1
' grid constants and resources
%IDC_MLGGRID1  = 3000            ' control handle for grid 1 ' main screen
GLOBAL hGrid1 AS DWORD           ' grid handle for Search grid
GLOBAL sheetIDM1 AS LONG         ' tabbed grid handle
GLOBAL g_lngSorting AS LONG      ' sorting flag
GLOBAL g_lngRefreshing AS LONG   ' Refreshing flag
'------------------------------------------------------------------------------
'   ** Main Application Entry Point **
'------------------------------------------------------------------------------
FUNCTION PBMAIN()
  LOCAL strConnectionString AS STRING
  LOCAL lngResult AS LONG
  '
  PBFormsInitComCtls (%ICC_WIN95_CLASSES OR %ICC_DATE_CLASSES OR _
    %ICC_INTERNET_CLASSES)
  MLG_Init  ' initialise the grid control
  '
  IF ISFALSE funGetXMLValues() THEN
    ' unable to get the xml files
       MSGBOX "Unable to get the Configuration for this application", _
               %MB_ICONERROR, "Configuration error"
    EXIT FUNCTION
  END IF
  '
  IF SQL_Authorize(%MY_SQLT_AUTHCODE) <> %SUCCESS THEN
    FUNCTION = %FALSE
    EXIT FUNCTION
  END IF
  '
  ' first initialise the DLL
  CALL SQL_Init
  '
  strConnectionString =  "DRIVER=SQL Server;Trusted_Connection=Yes;" & _
                         "DATABASE=" & g_strDBDatabase & _
                         ";SERVER=" & g_strSQLServer

  IF ISFALSE funUserOpenDB(%AMDB, g_strSQLServer, g_strDBDatabase, strConnectionString) THEN
    MSGBOX "Unable to connect to the database" & $CRLF & "Please contact Support",%MB_ICONERROR OR %MB_TASKMODAL, "Connection Problem"
    lngResult = SQL_Shutdown()
    EXIT FUNCTION
  ELSE
    lngResult = SQL_SetOptionSInt(%OPT_TEXT_MAXLENGTH, 500)
  END IF
  '
  IF ISTRUE funReadAppFormGridDefinitions(EXE.NAMEX$) THEN
  '
    ShowdlgDemoGrid %HWND_DESKTOP
  ELSE
    MSGBOX "There are no Grid Definitions set up for this application " & _
            $CRLF & "Please contact Support " ,%MB_ICONERROR, _
            "Grid Definition Error"
  END IF
  '
END FUNCTION
'------------------------------------------------------------------------------

'------------------------------------------------------------------------------
'   ** CallBacks **
'------------------------------------------------------------------------------
CALLBACK FUNCTION ShowdlgDemoGridProc()
   STATIC strFormName AS STRING
   STATIC strGridName AS STRING
   STATIC strTabName AS STRING
   LOCAL strSQL AS STRING
   '
   mGridEventsHeader            ' set up grid events variables
    '
  SELECT CASE AS LONG CB.MSG
    CASE %WM_INITDIALOG
    ' Initialization handler
    ' define the grid to be amended
      strFormName = "MainForm"
      strGridName = "FirstGrid"
      strTabName  = "Data"
      ' define the sql to populate the form
      strSQL = "EXEC dbo.spr_GetUserlist"
      ' auto populate the grid based on the grid configuration
      funGenericPopulateGrid(strFormName , strGridName, strTabName ,_
                             strSQL, hGrid1 , %AMDB)
                             '
      SendMessage hGrid1, %MLG_SELECTSHEET, 1,0
      CONTROL SET TEXT CB.HNDL, %IDC_lblRecordsReturned, _
                                 "Records returned = " & _
                                 FORMAT$(funGetRowsInGrid(hGrid1))
                                 '
      ' auto populate the Department Tab
      strSQL = "EXEC dbo.spr_GetDepartmentsList"
      funGenericPopulateGrid(strFormName , strGridName, "Departments" ,_
                             strSQL, hGrid1 , %AMDB)
                             '
      'switch back to first tab
      SendMessage hGrid1, %MLG_SELECTSHEET, 1,0
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
     ' handle grid events
    CASE %WM_NOTIFY
      mGridEventsBody  ' start the select for grid events
      CASE %IDC_MLGGRID1
        SELECT CASE @MLGN.NMHeader.code
          CASE %MLGN_RCLICKMENU
            myitem =@MLGN.Param3  ' Menu Item picked
            mycol  =@MLGN.Param2  ' Column of Mouse click
            myrow  =@MLGN.Param1  ' current row
            '
            SELECT CASE myItem
              CASE 1
              ' copy to clipboard
                strText = MLG_Get(hGrid1,myrow,mycol)
                CLIPBOARD RESET
                CLIPBOARD SET TEXT strText, lngClipResult
              CASE 2
              ' sort column
                SendMessage hGrid1, %MLG_SORT, %MLG_ASCEND ,mycol
                funGridRefresh(hGrid1)
            END SELECT
         END SELECT
      END SELECT
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
FUNCTION ShowdlgDemoGrid(BYVAL hParent AS DWORD) AS LONG
  LOCAL lRslt AS LONG
  '
  ' Form/grid/tab values
    LOCAL strFormName AS STRING
    LOCAL strGridName AS STRING
    LOCAL strTabName AS STRING
    LOCAL strUserAccess AS STRING
    strFormName = "MainForm"
    strGridName = "FirstGrid"
    strTabName  = "Data"
    '
    LOCAL strSorting AS STRING
  '
#PBFORMS BEGIN DIALOG %IDD_dlgDemoGrid->->
  LOCAL hDlg  AS DWORD

  DIALOG NEW hParent, "Demo Grid", 251, 141, 950, 540, %WS_POPUP OR _
    %WS_BORDER OR %WS_DLGFRAME OR %WS_CAPTION OR %WS_SYSMENU OR _
    %WS_MINIMIZEBOX OR %WS_MAXIMIZEBOX OR %WS_CLIPSIBLINGS OR %WS_VISIBLE OR _
    %DS_MODALFRAME OR %DS_CENTER OR %DS_3DLOOK OR %DS_NOFAILCREATE OR _
    %DS_SETFONT, %WS_EX_CONTROLPARENT OR %WS_EX_LEFT OR %WS_EX_LTRREADING OR _
    %WS_EX_RIGHTSCROLLBAR, TO hDlg
  CONTROL ADD LABEL, hDlg, %IDC_lblRecordsReturned, "Records returned", 10, _
    100, 100, 10
  CONTROL SET COLOR  hDlg, %IDC_lblRecordsReturned, %BLUE, -1
#PBFORMS END DIALOG
'
  ' adding a toolbar to your form
  CONTROL ADD TOOLBAR, hDlg, %MainToolbar, "", 0, 0, 0, 0, _
        %WS_CHILD OR %WS_VISIBLE OR %WS_TABSTOP OR %CCS_TOP OR _
        %TBSTYLE_FLAT
        '
  ' add the icons and buttons to the blank toolbar
  CreateToolbar hDlg, %MainToolbar
  '
  ' place the grid on the form
  strUserAccess = "Read Only"
  strSorting = "/m1Copy Cell,Sort,Revoke Change"
  IF ISTRUE funPlaceGrid(hDlg,%IDC_MLGGRID1,strSorting,hGrid1, _
                         strFormName,strGridName, _
                         10, 125, 900, 380,sheetIDM1, _
                         strUserAccess) THEN
  END IF
  '
  DIALOG SHOW MODAL hDlg, CALL ShowdlgDemoGridProc TO lRslt

#PBFORMS BEGIN CLEANUP %IDD_dlgDemoGrid
#PBFORMS END CLEANUP

  FUNCTION = lRslt
END FUNCTION
'------------------------------------------------------------------------------
