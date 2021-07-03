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
#RESOURCE "CDEF_Config.pbr"
%USEMACROS = 1
#INCLUDE ONCE "WIN32API.INC"
#INCLUDE ONCE "COMMCTRL.INC"
#INCLUDE ONCE "PBForms.INC"
#PBFORMS END INCLUDES
'------------------------------------------------------------------------------
#INCLUDE ONCE "_PBCommon\Layout32_sll.inc"
#LINK "Layout32.sll"

%MLGSLL = 1
#INCLUDE "_PBCommon\MLG.INC"
#LINK "MLG.SLL"
#LINK "zSpinPB10.sll"
#INCLUDE "_PBCommon\ButtonPlus.bas"
#INCLUDE "_PBCommon\Tooltips.inc"
#INCLUDE "_PBCommon\SQLT_PRO.inc"
#INCLUDE "_PBCommon\PB_xml.inc"
#INCLUDE "_PBCommon\DBServer.inc"
#INCLUDE "_PBCommon\Encrypt.inc"
#INCLUDE "_PBCommon\cc6_PB_common.inc
#INCLUDE "_PBCommon\PB_GenericSQLFunctions.inc"

%AMR_UPDATED            = 99              ' row marker for updated record
%AMR_SAVED              = 0               ' row marker for saved record
%AMR_SHORTASSET_UPDATED = 100             ' used to mark an updated row for short assets
#INCLUDE "_PBCommon\PB_MLG_Utilities.inc"
#INCLUDE "htmlhelp.inc"

%max_cols = 50
%max_tabs = 5
%max_grids = 1
%Max_Forms = 10
%MAX_rows            = 6000               ' max number of rows for format override
#INCLUDE "_PBCommon\FormGridTab_Resource.inc"

%hiNum1 = 1
%loNum1 = 0
%hiNum2 = 1
%loNum2 = 1

#RESOURCE VERSIONINFO
#RESOURCE FILEVERSION %hiNum1, %loNum1, %hiNum2, %loNum2
'#RESOURCE PRODUCTVERSION %hiNum1, %loNum1, %hiNum2, %loNum2
#RESOURCE STRINGINFO "0809", "0000"
#RESOURCE VERSION$ "Comments",         "."
#RESOURCE VERSION$ "CompanyName",      "NHS Scotland"
#RESOURCE VERSION$ "FileDescription",  "Allows configuration of client grids in AM System"
#RESOURCE VERSION$ "InternalName",     "CDEF_Config"
#RESOURCE VERSION$ "LegalCopyright",   "Copyright 2015 NHS Scotland"
#RESOURCE VERSION$ "OriginalFilename", "CDEF_Config.exe"
#RESOURCE VERSION$ "PrivateBuild",     "n/a"
#RESOURCE VERSION$ "ProductName",      "AMR CDEF Configuration"
#RESOURCE VERSION$ "ProductVersion",   "1.0.1.1"
#RESOURCE VERSION$ "SpecialBuild",     "n/a"
'
#RESOURCE MANIFEST,     1, "XPTheme.XML"

'------------------------------------------------------------------------------
'   ** Constants **
'------------------------------------------------------------------------------
#PBFORMS BEGIN CONSTANTS
%IDD_dlgConfgGrids     =  101
%IDC_STATUSBAR1        = 1001
%IDC_COPYTOCLIPBOARD   = 1002
%IDABORT               =    3
%IDC_cboApplication    = 1003
%IDC_lblApplication    = 1004
%IDC_cboForm           = 1005
%IDC_cboGrid           = 1006
%IDC_cboTab            = 1007
%IDC_lblForm           = 1008
%IDC_lblGrid           = 1009
%IDC_lblTab            = 1010
%IDC_SEARCH            = 1011
%IDC_TOOLBAR           = 1012
%IDC_frmSearch         = 1013
%IDC_LBLRECORDS        = 1014
%IDC_IMAGEX1           = 1015
%IDC_systemMarker      = 1016
%IDC_lblExeVersion     = 1017
%IDD_ADDNEWITEMS       =  102
%IDC_LABEL1            = 1022
%IDC_LABEL2            = 1023
%IDC_LABEL3            = 1024
%IDC_LABEL4            = 1025
%IDC_cboAddApplication = 1003
%IDC_cboAddForm        = 1019
%IDC_cboAddGrid        = 1020
%IDC_cboAddTab         = 1021
%IDC_STATUSBAR2        = 1026
%IDOK                  =    1
%IDC_LABEL5            = 1027
#PBFORMS END CONSTANTS
'------------------------------------------------------------------------------
#RESOURCE ICON, 2001, "_PBCommon\Graphics\Grid.ico"
#RESOURCE ICON, 2002, "_PBCommon\Graphics\16_CANCEL.ico"
#RESOURCE ICON, 2003, "_PBCommon\Graphics\Help.ico"
#RESOURCE ICON, 2004, "_PBCommon\Graphics\save.ico"
#RESOURCE ICON, 2005, "_PBCommon\Graphics\Copy2Clipboard.ico"
#RESOURCE ICON, 2006, "_PBCommon\Graphics\Bigmagnify.ico"
'
#RESOURCE ICON, 2008, "_PBCommon\Graphics\add.ico"
#RESOURCE ICON, 2009, "_PBCommon\Graphics\BackButton.ico"

' store the animated loading screen
#RESOURCE RCDATA, 4000 ,"SpinFolder\loading.ski"

%IDR_Appicon             = 2001
%IDR_IMGExit             = 2002
%IDR_IMGHelp             = 2003
%IDR_Save                = 2004
%IDR_IMGCopyToClipboard  = 2005
%IDR_IMGSearch           = 2006
%IDR_IMGNHSLogo          = 2007
%IDR_IMGAdd              = 2008
%IDR_IMGBack             = 2009

%AMDB = 1

' handles for events when toolbar and other things are clicked
%ID_Help      = 4001                   ' toolbar help icon event
%ID_Save      = 4002                   ' toolbar save event
%ID_ADD       = 4003                   ' toolbar add event

' grid constants and resources
%IDC_MLGGRID1        = 3000            ' control handle for grid 1 ' main screen

GLOBAL hGrid1 AS DWORD                 ' grid handle for Search grid

GLOBAL sheetIDM1 AS LONG               ' tabbed grid handle
GLOBAL g_lngSorting AS LONG            ' sorting flag
GLOBAL g_lngRefreshing AS LONG         ' Refreshing flag

GLOBAL hFont1 AS DWORD                 ' used for larger fonts
GLOBAL hFont2 AS DWORD                 ' used for larger fonts
GLOBAL hFont3 AS DWORD                 ' used for larger fonts

'------------------------------------------------------------------------------
'   ** Declarations **
'------------------------------------------------------------------------------
DECLARE CALLBACK FUNCTION ShowdlgConfgGridsProc()
DECLARE FUNCTION ShowdlgConfgGrids(BYVAL hParent AS DWORD) AS LONG
DECLARE CALLBACK FUNCTION ShowADDNEWITEMSProc()
DECLARE FUNCTION ShowADDNEWITEMS(BYVAL hDlg AS DWORD) AS LONG
#PBFORMS DECLARATIONS
'------------------------------------------------------------------------------

'------------------------------------------------------------------------------
'   ** Main Application Entry Point **
'------------------------------------------------------------------------------
FUNCTION PBMAIN()
  LOCAL strPassword AS STRING
  LOCAL strConnectionString AS STRING
  LOCAL lngResult AS LONG
  '
    PBFormsInitComCtls (%ICC_WIN95_CLASSES OR %ICC_DATE_CLASSES OR _
        %ICC_INTERNET_CLASSES)
        '
    FONT NEW "MS Sans Serif", 14, 0, %ANSI_CHARSET TO hFont1
    FONT NEW "MS Sans Serif", 24, 0, %ANSI_CHARSET TO hFont2
    FONT NEW "MS Sans Serif", 18, 0, %ANSI_CHARSET TO hFont3

    MLG_Init  ' initialise the grid control
    ' save the spinner file
    funSaveSpinner()
    '
    CALL zSpinnerInit(0, funTempDirectory & "loading.ski", 0)
    DIALOG DOEVENTS 0
    '
    ' get the xml values
    IF ISFALSE funGetXMLValues() THEN
    ' unable to get the xml files
       MSGBOX "Unable to get the Configuration for this application",%MB_ICONERROR, "Configuration error"
       FONT END hFont1
       FONT END hFont2
       FONT END hFont3
       EXIT FUNCTION
    END IF
    '
    IF ISFALSE g_lngSystemActive THEN
      CALL zSpinnerClose()  ' close the busy graphic
      MSGBOX "The Management system is not currently available. " & $CRLF & "Please try later", _
             %MB_ICONERROR OR %MB_SYSTEMMODAL, "System Offline"
      FONT END hFont1
      FONT END hFont2
      FONT END hFont3
      EXIT FUNCTION
    END IF
    '
    IF g_strSQLServer = "" OR g_strDBDatabase = "" THEN
      CALL zSpinnerClose()  ' close the busy graphic
      MSGBOX "Unable to connect to the database. " & $CRLF & "Please contact Support",%MB_ICONERROR OR %MB_TASKMODAL, "XML Config missing data"
      FONT END hFont1
      FONT END hFont2
      FONT END hFont3
      EXIT FUNCTION
    END IF
    '
    ' check authorization to use SQLPro.dll
    IF SQL_Authorize(%MY_SQLT_AUTHCODE) <> %SUCCESS THEN
      FUNCTION = %FALSE
      FONT END hFont1
      FONT END hFont2
      FONT END hFont3
      EXIT FUNCTION
    END IF
    '
    ' first initialise the DLL
    CALL SQL_Init
    '
    'strPassword = g_strEnc_CronosAdminPSW 'funEncapsulateDecrypt(g_strEnc_ComputerOwnersAdminPSW)
    '
    'strConnectionString =  "DRIVER=SQL Server;UID=ChronosAdmin;PWD=" & strPassword & ";" & _
    '                     "DATABASE=" & g_strDBDatabase & ";SERVER=" & g_strSQLServer
    '
    strConnectionString =  "DRIVER=SQL Server;Trusted_Connection=Yes;" & _
                           "DATABASE=" & g_strDBDatabase & ";SERVER=" & g_strSQLServer

    IF ISFALSE funUserOpenDB(%AMDB, g_strSQLServer, g_strDBDatabase, strConnectionString) THEN
      CALL zSpinnerClose()  ' close the busy graphic
      MSGBOX "Unable to connect to the database" & $CRLF & "Please contact Support",%MB_ICONERROR OR %MB_TASKMODAL, "Connection Problem"
      lngResult = SQL_Shutdown()
      FONT END hFont1
      FONT END hFont2
      FONT END hFont3
      EXIT FUNCTION
    ELSE
      lngResult = SQL_SetOptionSInt(%OPT_TEXT_MAXLENGTH, 500)
    END IF
    '
    IF ISTRUE funReadAppFormGridDefinitions(EXE.NAMEX$) THEN
      ' read the formGrid definitions for this app
      ShowdlgConfgGrids %HWND_DESKTOP
    ELSE
      CALL zSpinnerClose()  ' close the busy graphic
      MSGBOX "There are no Grid Definitions set up for this application " & $CRLF & _
             "Please contact the CR Management Team " ,%MB_ICONERROR, "Grid Definition Error"
      FONT END hFont1
      FONT END hFont2
      FONT END hFont3
    END IF
    '
    FONT END hFont1
    FONT END hFont2
    FONT END hFont3
    '
END FUNCTION
'------------------------------------------------------------------------------
FUNCTION funPopulateApps(hDlg AS DWORD, lngCBO AS LONG) AS LONG
  DIM a_strData() AS STRING
  LOCAL strSQL AS STRING
  '
  strSQL = "EXEC dbo.CDEF_sprGetAllApplications"
  IF ISTRUE funGetGenericData(strSQL, a_strData(), %AMDB) THEN
    FUNCTION = funPopulateGenericCombo(hDlg,lngCBO,a_strData(),"")
    COMBOBOX RESET hDlg,%IDC_cboForm
    COMBOBOX RESET hDlg,%IDC_cboGrid
    COMBOBOX RESET hDlg,%IDC_cboTab
    CONTROL DISABLE hDlg,%IDC_SEARCH
  END IF
  '
END FUNCTION
'
FUNCTION funPopulateGenericCombo(hDlg AS DWORD, lngCBO AS LONG, BYREF a_strData() AS STRING, _
                          strSelection AS STRING) AS LONG
' populate the combo with whats in an array
' where array is in format of
' long | string        putting the long into the user section of the combo
'
  LOCAL lngR AS LONG
  LOCAL dataV&
  '
  COMBOBOX RESET hDlg, lngCBO
  '
  FOR lngR = 1 TO UBOUND(a_strData)
    COMBOBOX ADD hDlg, lngCBO, PARSE$(a_strData(lngR),"|",2) TO dataV&
    COMBOBOX SET USER hDlg, lngCBO, dataV&, VAL(PARSE$(a_strData(lngR),"|",1))
  NEXT lngR
  '
  IF strSelection <>"" THEN
    COMBOBOX FIND EXACT hDlg, lngCBO, 1, strSelection TO datav&
    COMBOBOX SELECT hDlg, lngCBO, datav&
  END IF
  '
END FUNCTION
'
FUNCTION funPopulateForms(hDlg AS DWORD,lngCBO AS LONG,lngCBOValue AS LONG) AS LONG
  DIM a_strData() AS STRING
  LOCAL strSQL AS STRING
  '
  strSQL = "EXEC dbo.CDEF_sprGetAllFormsInApp " & FORMAT$(lngCBOValue)
  IF ISTRUE funGetGenericData(strSQL, a_strData(), %AMDB) THEN
    FUNCTION = funPopulateGenericCombo(hDlg,lngCBO,a_strData(),"")
    COMBOBOX RESET hDlg,%IDC_cboGrid
    COMBOBOX RESET hDlg,%IDC_cboTab
    CONTROL DISABLE hDlg,%IDC_SEARCH
  END IF
END FUNCTION
'
FUNCTION funPopulateGrids(hDlg AS DWORD,lngCBO AS LONG,lngCBOAppSelected AS LONG, lngCBOFormSelected AS LONG) AS LONG
  DIM a_strData() AS STRING
  LOCAL strSQL AS STRING
  '
  strSQL = "EXEC dbo.CDEF_sprGetAllGridsInForm " & FORMAT$(lngCBOAppSelected) & "," & FORMAT$(lngCBOFormSelected)
  IF ISTRUE funGetGenericData(strSQL, a_strData(), %AMDB) THEN
    FUNCTION = funPopulateGenericCombo(hDlg,lngCBO,a_strData(),"")
    COMBOBOX RESET hDlg,%IDC_cboTab
    CONTROL DISABLE hDlg,%IDC_SEARCH
  END IF

END FUNCTION
'
FUNCTION funPopulateTabs(hDlg AS DWORD,lngCBO AS LONG,lngCBOAppSelected AS LONG, lngCBOFormSelected AS LONG _
                         , lngCBOGridSelected AS LONG) AS LONG
  DIM a_strData() AS STRING
  LOCAL strSQL AS STRING
  '
  strSQL = "EXEC dbo.CDEF_sprGetAllTabsInGrid " & FORMAT$(lngCBOAppSelected) & "," & FORMAT$(lngCBOFormSelected) & _
           "," & FORMAT$(lngCBOGridSelected)
  IF ISTRUE funGetGenericData(strSQL, a_strData(), %AMDB) THEN
    FUNCTION = funPopulateGenericCombo(hDlg,lngCBO,a_strData(),"")
    CONTROL DISABLE hDlg,%IDC_SEARCH
  END IF
END FUNCTION
'
FUNCTION funSearchDB(hDlg AS DWORD,hGrid AS DWORD,lngCBOAppSelected AS LONG,lngCBOFormSelected AS LONG, _
                     lngCBOGridSelected AS LONG,lngCBOTabSelected AS LONG) AS LONG
' search the database based on the selections
    ' Form/grid/tab values
    LOCAL lngR AS LONG
    LOCAL lngC AS LONG
     ' Form/grid/tab values
    LOCAL strForm AS STRING
    LOCAL strGrid AS STRING
    LOCAL strTab AS STRING
    LOCAL strSQL AS STRING
    LOCAL lngFeedID AS LONG
    strForm = "CDEF Config View"
    strGrid = "ConfigView"
    strTab  = "Configurations"
    LOCAL lngForm AS LONG
    LOCAL lngGrid AS LONG
    LOCAL lngTab AS LONG
    LOCAL lngUDT AS LONG
    LOCAL strGridColumnName AS STRING
    '
    ' pick up the form and grid pointers
    lngForm = funGetFormNumber(strForm)
    lngGrid = funGetGridNumber(lngForm,strGrid)
    lngTab = funGetTabNumber(lngForm,lngGrid,strTab)
    '
    DIALOG GET USER hDlg, 1 TO lngFeedID
    strSQL =  "EXEC dbo.CDEF_sprGetTabRefs " & FORMAT$(lngCBOAppSelected) & "," & _
                                               FORMAT$(lngCBOFormSelected) & "," & _
                                               FORMAT$(lngCBOGridSelected) & "," & _
                                               FORMAT$(lngCBOTabSelected)

    FUNCTION = funGenericPopulateGrid(strForm, strGrid, strTab, strSQL, hGrid, %AMDB)
    CONTROL SET TEXT hDlg,%IDC_LBLRECORDS, FORMAT$(funGetRowsInGrid(hGrid)) & " rows returned"
    '
    funMarkWholeGridAsSaved(hGrid)
    funGridRefresh(hGrid)
    '
END FUNCTION
'
FUNCTION funRevokeChanges(hGrid AS DWORD,lngRow AS LONG, lngForm AS LONG, lngGrid AS LONG, lngTab AS LONG) AS LONG
' revoke changes to this row back to the values in the database
  LOCAL strSQL AS STRING
  LOCAL strRefID AS STRING
  DIM a_strData() AS STRING
  '
  LOCAL strForm AS STRING
  LOCAL strGrid AS STRING
  LOCAL strTab AS STRING
  strForm = "CDEF Config View"
  strGrid = "ConfigView"
  strTab  = "Configurations"
  '
  ' first get the value of the primary column on this row
  strRefID = funGetValueOfPrimaryColumn(lngForm, lngGrid, lngTab,hGrid, lngRow)
  ' now run query
  strSQL = "EXEC dbo.CDEF_sprGetTabRefsByRef " & strRefID
  IF ISTRUE funGetGenericData(strSQL, a_strData(), %AMDB) THEN
  ' and if we get data repopulate the grid row
    IF ISTRUE funGenericPopulateGridRow(strForm, strGrid, strTab, lngRow, hGrid, a_strData(1), a_strData(0)) THEN
    ' remove the marking
      funUnMarkGridRow(hGrid, lngRow)
      ' and set as saved
      MLG_SetRowRecNo(hGrid,lngRow,%AMR_SAVED)
    END IF
  END IF
  funGridRefresh(hGrid)
  '
END FUNCTION
'
FUNCTION funSaveRecord(hGrid AS DWORD, BYREF a_strWork() AS STRING,lngRow AS LONG, strError AS STRING) AS LONG
' save the individual record to db
' where lngRow points to the record within the a_strWork() array
  LOCAL strSQL AS STRING
  LOCAL lngC AS LONG
  LOCAL strValue AS STRING
  LOCAL lngColumns AS LONG
  LOCAL strField AS STRING
  LOCAL strSQLParameters AS STRING
  LOCAL lngColumn AS LONG
  LOCAL strColumnHeader AS STRING
  DIM a_strData() AS STRING

  '
  LOCAL strForm AS STRING
  LOCAL strGrid AS STRING
  LOCAL strTab AS STRING
  LOCAL lngForm AS LONG
  LOCAL lngGrid AS LONG
  LOCAL lngTab AS LONG
  '
  strForm = "CDEF Config View"
  strGrid = "ConfigView"
  strTab  = "Configurations"
  '
  ' get the form/grid/tab info
  lngForm = funGetFormNumber(strForm)
  lngGrid = funGetGridNumber(lngForm,strGrid)
  lngTab  = funGetTabNumber(lngForm, lngGrid,strTab)
  '
  lngColumns = funGetColumnsInGrid(hGrid)

  DIM lngColumnIDs(lngColumns) AS LONG ' prep an array to hold column IDs
  FOR lngColumn = 1 TO lngColumns
    ' get the grid name for the column
    strColumnHeader = MLG_Get(hGrid,0,lngColumn)
    ' get the column in the UDT
    lngColumnIDs(lngColumn) =  funGetUdtColumnPositionFromGrid(lngForm,lngGrid,lngTab,strColumnHeader)
  NEXT lngColumn

  ' get the data from the a_strWork() array
  FOR lngC = 1 TO lngColumns
  ' for each column in the array - pick up the value
    strValue = funEscapeApostrophe(a_strWork(lngRow,lngC))
    IF ISTRUE VAL(funGetProperty(lngForm, lngGrid, lngTab,lngColumnIDs(lngC), "ColumnCheckBox")) THEN
    ' its a checkbox
      IF ISTRUE MLG_GetChecked(hGrid, lngRow, lngC) THEN
        strValue = "1"
      ELSE
        strValue = "0"
      END IF
    END IF
    '
    ' form up the sql parameters
    strField = funGetProperty(lngForm, lngGrid, lngTab,lngColumnIDs(lngC), "ResultName")
    IF TRIM$(strField) <>"" AND LEFT$(strField,6) <> "unused" THEN
      strSQLParameters = strSQLParameters & "@" & strField & "='" & strValue & "',"
    END IF
    '
  NEXT lngC
  '
  strSQLParameters = TRIM$(strSQLParameters,",")   ' trim last comma

  strSQL = "EXEC dbo.CDEF_sprUpdateTabRefs " & strSQLParameters
  'funAppendToFile("log.txt", strSQL)
  '
  ' run the sql and check if it saves
  IF ISTRUE funRunSQL(strSQL, strError,%AMDB) THEN
    FUNCTION = %TRUE
  ELSE
    FUNCTION = %FALSE
  END IF
  '
END FUNCTION
'
FUNCTION funSaveTheChanges(BYREF hGrid AS DWORD, lngRecordsFailedValidation AS LONG) AS LONG
' save the changes to DB
  LOCAL lngNeedsSaved AS LONG
  LOCAL lngRow AS LONG
  LOCAL a_strWork() AS STRING
  LOCAL lngE AS LONG
  LOCAL lngColour AS LONG
  LOCAL lngRuleID AS LONG
  '
  LOCAL I AS LONG
  LOCAL lngRows AS LONG
  LOCAL lngColumns AS LONG
  LOCAL o_lngRef AS LONG
  LOCAL lngGridRows AS LONG
  LOCAL strError AS STRING
  '
  ' determine the size of the grid
  lngRows = funGetRowsInGrid(hGrid)
  lngColumns = funGetColumnsInGrid(hGrid)
  '
  lngGridRows = lngRows
  '
  ' first capture the whole grid into an array
  REDIM a_strWork(lngGridRows,lngColumns) AS STRING
  ' get the grid
  MLG_GetEx (hGrid,a_strWork())
  FOR lngRow = 1 TO UBOUND(a_strWork)
    ' get the updated marker
    lngNeedsSaved = MLG_GetRowRecNo(hGrid ,lngROW)
    IF lngNeedsSaved = %AMR_UPDATED THEN
      '
      lngRuleID = funSaveRecord(hGrid,a_strWork(),lngRow, strError)
      IF lngRuleID = 0 THEN
      ' unable to save the record?
        MSGBOX strError,0,"Error Saving"
        INCR lngRecordsFailedValidation
      ELSE
        '
        ' set grid to record that the record has been saved
        MLG_SetRowRecNo(hGrid,lngRow,%AMR_SAVED)
        '
        funUnMarkGridRow(hGrid,lngRow)
        '
      END IF
    '
    END IF
  NEXT lngRow
  '
  funGridRefresh(hGrid)
  FUNCTION = %TRUE
  '
END FUNCTION
'
'------------------------------------------------------------------------------
'   ** CallBacks **
'------------------------------------------------------------------------------
CALLBACK FUNCTION ShowdlgConfgGridsProc()
    LOCAL lngCBOAppSelected AS LONG
    LOCAL lngCBOFormSelected AS LONG
    LOCAL lngCBOGridSelected AS LONG
    LOCAL lngCBOTabSelected AS LONG
    LOCAL datav&
    LOCAL MLGN AS MyGridData PTR
    LOCAL lphi AS HELPINFO PTR
    LOCAL strText AS STRING
    LOCAL mycol AS LONG
    LOCAL myrow AS LONG
    LOCAL myitem AS LONG
    LOCAL lngClipResult AS LONG
    LOCAL lngState AS LONG
    LOCAL strGridColumnName AS STRING
    LOCAL lngUDT AS LONG
    '
    LOCAL strFormName AS STRING
    LOCAL strGridName AS STRING
    LOCAL strTabName AS STRING
    LOCAL strUserAccess AS STRING
    STATIC lngForm AS LONG
    STATIC lngGrid AS LONG
    STATIC lngTab AS LONG
    '
    LOCAL lngRecordsFailedValidation AS LONG
    LOCAL lngResult AS LONG

    '
    SELECT CASE AS LONG CB.MSG
        CASE %WM_INITDIALOG
          ' Initialization handler
          g_lngRefreshing = %TRUE
          funPopulateApps(CB.HNDL,%IDC_cboApplication )
          g_lngRefreshing = %FALSE
          '
          ' pick up the form and grid pointers
          strFormName = "CDEF Config View"
          strGridName = "ConfigView"
          strTabName  = "Configurations"
          lngForm = funGetFormNumber(strFormName)
          lngGrid = funGetGridNumber(lngForm,strGridName)
          lngTab = funGetTabNumber(lngForm,lngGrid,strTabName)
          '
          IF LCASE$(g_strSQLServer) = g_strLiveSQLServerName THEN
          ' running on live system
            CONTROL SET TEXT CB.HNDL, %IDC_systemMarker, "LIVE System"
          ELSE
            CONTROL SET TEXT CB.HNDL, %IDC_systemMarker, "TEST System"
          END IF
          '
          CONTROL SET TEXT CB.HNDL, %IDC_lblExeVersion, "Exe Version " & funGetEXEVersion
          '
          TOOLBAR SET STATE CB.HNDL, %IDC_TOOLBAR, BYCMD %ID_Save, %TBSTATE_DISABLED
          DIALOG MAXIMIZE CB.HNDL
          CALL zSpinnerClose()  ' close the busy graphic
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
        CASE %WM_SIZE:  'Called when window changes size
        ' Dialog has been resized
          CONTROL SEND CB.HNDL, %IDC_STATUSBAR1, CB.MSG, CB.WPARAM, CB.LPARAM
          '
          IF ISTRUE isIconic(CB.HNDL) THEN EXIT FUNCTION  ' Exit if app is minimized
          '
          ' refresh the grid display
          funGridRefresh(hGrid1)
          '
        CASE %WM_NOTIFY
          MLGN=CB.LPARAM
          '
          SELECT CASE @MLGN.NMHeader.idFrom
            CASE %IDC_MLGGRID1
              SELECT CASE @MLGN.NMHeader.code
                CASE %MLGN_CELLALTERED
                ' cell has changed
                  myrow=@MLGN.Param1 'current row
                  mycol=@MLGN.Param2 'current col
                  IF ISFALSE g_lngRefreshing AND ISFALSE g_lngSorting THEN
                  ' only if grid is not being refreshed

                    strGridColumnName = MLG_Get(hGrid1,0,mycol)
                    lngUDT = funGetUdtColumnPositionFromGrid(lngForm,lngGrid,lngTab, strGridColumnName)
                    IF ISTRUE VAL(funGetProperty(lngForm, lngGrid, lngTab,lngUDT,"ColumnLock")) THEN
                      EXIT FUNCTION
                    END IF
                    '
                    IF ISFALSE VAL(funGetProperty(lngForm, lngGrid, lngTab,lngUDT,"ColumnPrimary")) THEN
                      TOOLBAR SET STATE CB.HNDL, %IDC_TOOLBAR, BYCMD %ID_Save, %TBSTATE_ENABLED
                      MLG_SetRowRecNo(hGrid1,myrow,%AMR_UPDATED)
                      funMarkGridCell(hGrid1,myrow,mycol)
                    END IF
                  END IF

                CASE %MLGN_RCLICKMENU
                  myitem=@MLGN.Param3  ' Menu Item . 1 = Copy to clipboard. 2 = Sort. 3= Revoke changes
                  mycol=@MLGN.Param2   ' Column of Mouse
                  myrow=@MLGN.Param1   ' current row
                  '
                  SELECT CASE myitem
                    CASE 1
                    ' copy to clipboard
                      strText = MLG_Get(hGrid1,myrow,mycol)
                      CLIPBOARD RESET
                      CLIPBOARD SET TEXT strText, lngClipResult
                    CASE 2
                    ' sort on this column
                      TOOLBAR GET STATE CB.HNDL,%IDC_TOOLBAR, BYCMD %ID_Save TO lngState
                      IF lngState = %TBSTATE_ENABLED THEN
                      ' there are unsaved changes
                      '
                        MSGBOX "There are unsaved changes on this worksheet" & _
                               $CRLF & "Please save them before sorting",%MB_ICONWARNING,"Unsaved changes"
                        EXIT FUNCTION
                      ELSE
                      ' no pending changes
                         g_lngSorting = %TRUE
                         SendMessage hGrid1,%MLG_SORT, %MLG_ASCEND , mycol
                         ' refresh the grid display
                         funGridRefresh(hGrid1)
                         g_lngSorting = %FALSE
                      '
                      END IF
                      '
                    CASE 3
                    ' revoke changes
                     g_lngRefreshing = %TRUE
                     funRevokeChanges(hGrid1,myRow, lngForm, lngGrid, lngTab)
                     IF funCountChanges(hGrid1) = 0 THEN
                       TOOLBAR SET STATE CB.HNDL, %IDC_TOOLBAR, BYCMD %ID_Save, %TBSTATE_DISABLED
                     END IF
                     g_lngRefreshing = %FALSE
                  END SELECT
                  '
                CASE %MLGN_CHECKCHANGED
                  mycol=@MLGN.Param2   'column of check change
                  myrow=@MLGN.Param1
                  IF ISFALSE g_lngRefreshing AND ISFALSE g_lngSorting THEN
                  ' get the name of the column
                    '
                    TOOLBAR SET STATE CB.HNDL, %IDC_TOOLBAR, BYCMD %ID_Save, %TBSTATE_ENABLED
                    MLG_SetRowRecNo(hGrid1,myrow,%AMR_UPDATED)
                    funMarkGridCell(hGrid1,myrow,mycol)
                  END IF
              END SELECT
          END SELECT
          '
        CASE %WM_COMMAND
            ' Process control notifications
          SELECT CASE AS LONG CB.CTL
              ' /* Inserted by PB/Forms 04-13-2015 14:49:07
            CASE %ID_ADD
            ' add something new
              ShowADDNEWITEMS CB.HNDL
            '
            CASE %ID_Save
              IF CB.CTLMSG = %BN_CLICKED OR CB.CTLMSG = 1 THEN
              ' save toolbar button has been clicked
                lngRecordsFailedValidation = 0
                '
                g_lngRefreshing = %TRUE
                '
                IF ISTRUE funSaveTheChanges(hGrid1, lngRecordsFailedValidation) THEN
                  IF lngRecordsFailedValidation > 0 THEN
                  ' some records have not been saved
                    MSGBOX FORMAT$(lngRecordsFailedValidation) & " record(s) have not been saved" _
                           ,%MB_ICONERROR,"Saving partially completed"
                    '
                  ELSE
                  ' disable toolbar as there is nothing to save
                    TOOLBAR SET STATE CB.HNDL, %IDC_TOOLBAR, BYCMD %ID_Save, %TBSTATE_DISABLED
                  END IF
                END IF
                g_lngRefreshing = %FALSE
              END IF
              '
            CASE %IDC_COPYTOCLIPBOARD
              IF CB.CTLMSG = %BN_CLICKED OR CB.CTLMSG = 1 THEN
              ' first reset the clipboard
                CLIPBOARD RESET
                '
                SubCopyRowWholeGridToClipBoard(hGrid1)
                CONTROL SET TEXT CB.HNDL, %IDC_STATUSBAR1,"Data copied to Clipboard"
              END IF
              '
            CASE %IDC_cboApplication
              IF CB.CTLMSG = %BN_CLICKED OR CB.CTLMSG = 1 THEN
              ' Application has been picked
                COMBOBOX GET SELECT CB.HNDL, %IDC_cboApplication TO datav&
                COMBOBOX GET USER CB.HNDL, %IDC_cboApplication, datav& TO lngCBOAppSelected
                funPopulateForms(CB.HNDL,%IDC_cboForm,lngCBOAppSelected)
              END IF
              '
            CASE %IDC_cboForm
              IF CB.CTLMSG = %BN_CLICKED OR CB.CTLMSG = 1 THEN
              ' form has been picked
                COMBOBOX GET SELECT CB.HNDL, %IDC_cboApplication TO datav&
                COMBOBOX GET USER CB.HNDL, %IDC_cboApplication, datav& TO lngCBOAppSelected
                '
                COMBOBOX GET SELECT CB.HNDL, %IDC_cboForm TO datav&
                COMBOBOX GET USER CB.HNDL, %IDC_cboForm, datav& TO lngCBOFormSelected
                '
                funPopulateGrids(CB.HNDL,%IDC_cboGrid,lngCBOAppSelected, lngCBOFormSelected)
              '
              END IF
              '
            CASE %IDC_cboGrid
              IF CB.CTLMSG = %BN_CLICKED OR CB.CTLMSG = 1 THEN
              ' grid has been picked
                COMBOBOX GET SELECT CB.HNDL, %IDC_cboApplication TO datav&
                COMBOBOX GET USER CB.HNDL, %IDC_cboApplication, datav& TO lngCBOAppSelected
                '
                COMBOBOX GET SELECT CB.HNDL, %IDC_cboForm TO datav&
                COMBOBOX GET USER CB.HNDL, %IDC_cboForm, datav& TO lngCBOFormSelected
                '
                COMBOBOX GET SELECT CB.HNDL, %IDC_cboGrid TO datav&
                COMBOBOX GET USER CB.HNDL, %IDC_cboGrid, datav& TO lngCBOGridSelected
                '
                funPopulateTabs(CB.HNDL,%IDC_cboTab,lngCBOAppSelected, lngCBOFormSelected, lngCBOGridSelected)
              '
              END IF
              '
            CASE %IDC_cboTab
              IF CB.CTLMSG = %BN_CLICKED OR CB.CTLMSG = 1 THEN
              ' tab has been picked
                CONTROL ENABLE CB.HNDL,%IDC_SEARCH
              '
              END IF

            CASE %IDC_SEARCH
              IF CB.CTLMSG = %BN_CLICKED OR CB.CTLMSG = 1 THEN
              ' populate the grid
                COMBOBOX GET SELECT CB.HNDL, %IDC_cboApplication TO datav&
                COMBOBOX GET USER CB.HNDL, %IDC_cboApplication, datav& TO lngCBOAppSelected
                '
                COMBOBOX GET SELECT CB.HNDL, %IDC_cboForm TO datav&
                COMBOBOX GET USER CB.HNDL, %IDC_cboForm, datav& TO lngCBOFormSelected
                '
                COMBOBOX GET SELECT CB.HNDL, %IDC_cboGrid TO datav&
                COMBOBOX GET USER CB.HNDL, %IDC_cboGrid, datav& TO lngCBOGridSelected
                '
                COMBOBOX GET SELECT CB.HNDL, %IDC_cboTab TO datav&
                COMBOBOX GET USER CB.HNDL, %IDC_cboTab, datav& TO lngCBOTabSelected
                '
                g_lngRefreshing = %TRUE
                funSearchDB(CB.HNDL,hGrid1,lngCBOAppSelected,lngCBOFormSelected,lngCBOGridSelected,lngCBOTabSelected)
                g_lngRefreshing = %FALSE
                TOOLBAR SET STATE CB.HNDL, %IDC_TOOLBAR, BYCMD %ID_Save, %TBSTATE_DISABLED
              '
              END IF
            ' */

            CASE %IDC_STATUSBAR1

            CASE %IDABORT
              IF CB.CTLMSG = %BN_CLICKED OR CB.CTLMSG = 1 THEN
                TOOLBAR GET STATE CB.HNDL,%IDC_TOOLBAR, BYCMD %ID_Save TO lngState
                IF lngState = %TBSTATE_ENABLED THEN
               ' there are unsaved changes
                 '
                 lngResult = MSGBOX("There are unsaved changes on this worksheet" & _
                             $CRLF & "are you sure you wish to leave?",%MB_ICONWARNING OR %MB_YESNO _
                             ,"Leave application without saving?")
                 IF lngResult = %IDYES THEN
                   DIALOG END CB.HNDL
                 ELSE
                   EXIT FUNCTION
                 END IF
                 '
                ELSE
                  DIALOG END CB.HNDL
                END IF
              END IF

          END SELECT
    END SELECT
END FUNCTION
'------------------------------------------------------------------------------

'------------------------------------------------------------------------------
'   ** Dialogs **
'------------------------------------------------------------------------------
FUNCTION ShowdlgConfgGrids(BYVAL hParent AS DWORD) AS LONG
    LOCAL lRslt AS LONG
     ' Form/grid/tab values
    LOCAL strFormName AS STRING
    LOCAL strGridName AS STRING
    LOCAL strTabName AS STRING
    LOCAL strUserAccess AS STRING
    strFormName = "CDEF Config View"
    strGridName = "ConfigView"
    strTabName  = "Configurations"
    '
    LOCAL strSorting AS STRING
    '
#PBFORMS BEGIN DIALOG %IDD_dlgConfgGrids->->
    LOCAL hDlg  AS DWORD

    DIALOG NEW hParent, "Configure AM System Form Grids", 70, 70, 728, 357, _
        %WS_POPUP OR %WS_BORDER OR %WS_DLGFRAME OR %WS_THICKFRAME OR _
        %WS_CAPTION OR %WS_SYSMENU OR %WS_MINIMIZEBOX OR %WS_MAXIMIZEBOX OR _
        %WS_CLIPSIBLINGS OR %WS_VISIBLE OR %DS_MODALFRAME OR %DS_CENTER OR _
        %DS_3DLOOK OR %DS_NOFAILCREATE OR %DS_SETFONT, %WS_EX_CONTROLPARENT _
        OR %WS_EX_LEFT OR %WS_EX_LTRREADING OR %WS_EX_RIGHTSCROLLBAR, TO _
        hDlg
    CONTROL ADD STATUSBAR, hDlg, %IDC_STATUSBAR1, "Ready", 0, 0, 0, 0
    CONTROL ADD BUTTON,    hDlg, %IDABORT, "Exit", 640, 320, 50, 15
    CONTROL ADD BUTTON,    hDlg, %IDC_COPYTOCLIPBOARD, "Copy to Clipboard", _
        30, 310, 110, 25, %WS_CHILD OR %WS_VISIBLE OR %WS_TABSTOP OR _
        %BS_TEXT OR %BS_PUSHBUTTON OR %BS_RIGHT OR %BS_VCENTER, %WS_EX_LEFT _
        OR %WS_EX_LTRREADING
    CONTROL ADD COMBOBOX,  hDlg, %IDC_cboApplication, , 25, 57, 120, 40, _
        %WS_CHILD OR %WS_VISIBLE OR %WS_TABSTOP OR %WS_VSCROLL OR _
        %CBS_DROPDOWNLIST OR %CBS_SORT, %WS_EX_LEFT OR %WS_EX_LTRREADING OR _
        %WS_EX_RIGHTSCROLLBAR
    CONTROL ADD LABEL,     hDlg, %IDC_lblApplication, "Application", 25, 47, _
        100, 10
    CONTROL SET COLOR      hDlg, %IDC_lblApplication, %BLUE, -1
    CONTROL ADD COMBOBOX,  hDlg, %IDC_cboForm, , 160, 57, 120, 40, %WS_CHILD _
        OR %WS_VISIBLE OR %WS_TABSTOP OR %WS_VSCROLL OR %CBS_DROPDOWNLIST OR _
        %CBS_SORT, %WS_EX_LEFT OR %WS_EX_LTRREADING OR %WS_EX_RIGHTSCROLLBAR
    CONTROL ADD COMBOBOX,  hDlg, %IDC_cboGrid, , 295, 57, 120, 40, %WS_CHILD _
        OR %WS_VISIBLE OR %WS_TABSTOP OR %WS_VSCROLL OR %CBS_DROPDOWNLIST OR _
        %CBS_SORT, %WS_EX_LEFT OR %WS_EX_LTRREADING OR %WS_EX_RIGHTSCROLLBAR
    CONTROL ADD COMBOBOX,  hDlg, %IDC_cboTab, , 430, 57, 120, 40, %WS_CHILD _
        OR %WS_VISIBLE OR %WS_TABSTOP OR %WS_VSCROLL OR %CBS_DROPDOWNLIST OR _
        %CBS_SORT, %WS_EX_LEFT OR %WS_EX_LTRREADING OR %WS_EX_RIGHTSCROLLBAR
    CONTROL ADD LABEL,     hDlg, %IDC_lblForm, "Form", 160, 47, 100, 10
    CONTROL SET COLOR      hDlg, %IDC_lblForm, %BLUE, -1
    CONTROL ADD LABEL,     hDlg, %IDC_lblGrid, "Grid", 295, 47, 100, 10
    CONTROL SET COLOR      hDlg, %IDC_lblGrid, %BLUE, -1
    CONTROL ADD LABEL,     hDlg, %IDC_lblTab, "Tab", 430, 47, 100, 10
    CONTROL SET COLOR      hDlg, %IDC_lblTab, %BLUE, -1
    CONTROL ADD BUTTON,    hDlg, %IDC_SEARCH, "Search", 595, 52, 75, 25, _
        %WS_CHILD OR %WS_VISIBLE OR %WS_TABSTOP OR %BS_TEXT OR _
        %BS_PUSHBUTTON OR %BS_RIGHT OR %BS_VCENTER, %WS_EX_LEFT OR _
        %WS_EX_LTRREADING
    CONTROL ADD FRAME,     hDlg, %IDC_frmSearch, "Search", 10, 35, 685, 70
    CONTROL ADD LABEL,     hDlg, %IDC_LBLRECORDS, "0 Records returned", 20, _
        115, 585, 10
    CONTROL ADD LABEL,     hDlg, %IDC_systemMarker, "TEST System", 725, 100, _
        120, 25
    CONTROL SET COLOR      hDlg, %IDC_systemMarker, %BLUE, -1
    CONTROL ADD LABEL,     hDlg, %IDC_lblExeVersion, "Label13", 610, 110, _
        100, 10
    CONTROL SET COLOR      hDlg, %IDC_lblExeVersion, %GRAY, -1
#PBFORMS END DIALOG
    '
    CONTROL SET FONT hDlg, %IDC_systemMarker, hFont3
    CONTROL ADD IMAGEX,    hDlg, %IDC_IMAGEX1,"#" & FORMAT$(%IDR_IMGNHSLogo), 725, 40, 100, 50
    '
    CONTROL ADD TOOLBAR,   hDlg, %IDC_TOOLBAR, "", 0, 0, 0, 0, _
        %WS_CHILD OR %WS_VISIBLE OR %WS_TABSTOP OR %CCS_TOP OR %TBSTYLE_FLAT

    CreateMainToolbar  hDlg, %IDC_TOOLBAR,1 ' create toolbar with text
    '
    strUserAccess = "Read Only"
    strSorting = "/m1Copy Cell,Sort,Revoke Change"
    IF ISTRUE funPlaceGrid(hDlg,%IDC_MLGGRID1,strSorting,hGrid1,strFormName,strGridName, _
                            10, 125, 700, 180,sheetIDM1, strUserAccess) THEN
    END IF
    '
    ButtonPlus hDlg, %IDABORT, %BP_TEXT_COLOR, %RED
    ButtonPlus hDlg, %IDABORT, %BP_ICON_ID, %IDR_IMGExit
    ButtonPlus hDlg, %IDABORT, %BP_ICON_WIDTH, 16
    ButtonPlus hDlg, %IDABORT, %BP_ICON_POS, %BS_LEFT
    '
    ButtonPlus hDlg, %IDC_COPYTOCLIPBOARD, %BP_TEXT_COLOR, %BLUE
    ButtonPlus hDlg, %IDC_COPYTOCLIPBOARD, %BP_ICON_ID, %IDR_IMGCopyToClipboard
    ButtonPlus hDlg, %IDC_COPYTOCLIPBOARD, %BP_ICON_WIDTH, 32
    ButtonPlus hDlg, %IDC_COPYTOCLIPBOARD, %BP_ICON_POS, %BS_LEFT
    '
    ButtonPlus hDlg, %IDC_SEARCH, %BP_TEXT_COLOR, %BLUE
    ButtonPlus hDlg, %IDC_SEARCH, %BP_ICON_ID, %IDR_IMGSearch
    ButtonPlus hDlg, %IDC_SEARCH, %BP_ICON_WIDTH, 32
    ButtonPlus hDlg, %IDC_SEARCH, %BP_ICON_POS, %BS_LEFT
    '
     ' RESIZE RULES
    Layout_AddRule hDlg, %Stretch, %Right, %IDC_MLGGRID1, %Right
    Layout_AddRule hDlg, %Stretch, %Bottom, %IDC_MLGGRID1, %Bottom
    Layout_AddRule hDlg, %Move, %Bottom, %IDABORT, %Bottom
    Layout_AddRule hDlg, %Move, %Right, %IDABORT, %Right
    Layout_AddRule hDlg, %Move, %Bottom, %IDC_COPYTOCLIPBOARD, %Bottom
    ' Limits
    LOCAL xx&, yy&
    DIALOG UNITS hDlg, 728, 357 TO PIXELS yy&, xx&
    'macDialogToPixels(hDlg, 728, 357)
    Layout_AddLimit hDlg, %Form, xx&, yy&
    '
    DIALOG SET ICON hDlg, "#" & FORMAT$(%IDR_Appicon)
    DIALOG SHOW MODAL hDlg, CALL ShowdlgConfgGridsProc TO lRslt

#PBFORMS BEGIN CLEANUP %IDD_dlgConfgGrids
#PBFORMS END CLEANUP

    FUNCTION = lRslt
END FUNCTION
'------------------------------------------------------------------------------
FUNCTION funSaveSpinner() AS LONG
' test for existing Temp folder
  LOCAL lFreeFile AS LONG
  LOCAL strSpin AS STRING
  '
  ' save current spinner
  strSpin  = RESOURCE$(RCDATA, 4000)
  lFreeFile = FREEFILE
  OPEN funTempDirectory & "loading.ski" FOR OUTPUT AS lFreeFile
  PRINT# lFreeFile, strSpin  ;
  CLOSE lFreeFile
  '
END FUNCTION
'
FUNCTION CreateMainToolbar(BYVAL hDlg AS DWORD, BYVAL lID AS LONG, lngTextNames AS LONG) AS LONG
    '
    LOCAL hImgList AS LONG                  ' handle for imagelist object
    LOCAL depth&,nWidth&,nHeight&,initial&  ' local variables - see below
    DIM a_strButtonText(20) AS STRING
    '
    IF ISTRUE lngTextNames THEN
      a_strButtonText(1) = "Save"
      a_strButtonText(2) = "Help"
      a_strButtonText(3) = "Add"
    END IF
    '
    ' set up the imagelist
    depth& = 32     ' depth of colour e.g. 32bit - how many colours allowed
    nWidth& = 32    ' width of icon in pixels
    nHeight& = 32   ' height of icon in pixels
    initial& = 16   ' allocated space in imagelist object to store buttons (increase as more are needed)
    IMAGELIST NEW ICON depth&,nWidth&,nHeight&,initial& TO hImgList
    IMAGELIST ADD ICON hImgList, "#" & FORMAT$(%IDR_Save)
    IMAGELIST ADD ICON hImgList, "#" & FORMAT$(%IDR_IMGHelp)
    IMAGELIST ADD ICON hImgList, "#" & FORMAT$(%IDR_IMGAdd)
    '
    ' set the imagelist against the toolbar
    TOOLBAR SET IMAGELIST hDlg, lID, hImgList, 0
    ' add buttons and separators to the toolbar
    ' add imagelist item 1 to the toolbar
    TOOLBAR ADD BUTTON hDlg, lID, 3, %ID_ADD , %TBSTYLE_BUTTON, a_strButtonText(3)
    TOOLBAR ADD BUTTON hDlg, lID, 1,%ID_SAVE , %TBSTYLE_BUTTON, a_strButtonText(1)
    TOOLBAR ADD SEPARATOR hDlg, lID, 16
    TOOLBAR ADD BUTTON hDlg, lID, 2,%ID_HELP , %TBSTYLE_BUTTON, a_strButtonText(2)

END FUNCTION
'
FUNCTION funGetEXEVersion(OPTIONAL BYVAL strAltPath AS STRING) AS STRING
' return the version of this exe
  DIM strFile AS ASCIIZ * %MAX_PATH
  '
  IF strAltPath <>"" THEN
  ' use the optional path to the exe or dll
    strFile = strAltPath
  ELSE
  ' default to this executable
    strFile =  EXE.FULL$
  END IF
  '
  FUNCTION = GetVersionInfo(strFile,"")
'
END FUNCTION
'
FUNCTION GetVersionInfo(BYVAL sFile AS STRING, BYVAL sItem AS STRING) AS STRING
  LOCAL pLang AS LONG PTR, sLangID AS STRING, fvTail AS STRING, pvTail AS STRING, sBuf AS STRING
  LOCAL bSize AS LONG, prtValue AS ASCIIZ PTR, dwDummy AS DWORD, ffi AS VS_FIXEDFILEINFO PTR
  DIM strMajor AS STRING
  DIM strMinor AS STRING
  DIM strRevision AS STRING
  DIM strBuild AS STRING
  '
  ' Obtain the version block
  bSize = GetFileVersionInfoSize(BYCOPY sFile, dwDummy)
  IF ISFALSE bSize THEN EXIT FUNCTION
  sBuf = SPACE$(bSize)
  IF ISFALSE GetFileVersionInfo(BYCOPY sFile, 0, bSize, BYVAL STRPTR(sBuf)) THEN EXIT FUNCTION
  ' If string item was specified, attempt to obtain it
  IF LEN(sItem) THEN
     ' Check language id - default to American English if not found
     IF ISFALSE VerQueryValue(BYVAL STRPTR(sBuf), "\VarFileInfo\Translation", pLang, dwDummy) THEN
        sLangID = "040904E4" ' American English/ANSI
     ELSE
        sLangID = HEX$(LOWRD(@pLang), 4) + HEX$(HIWRD(@pLang), 4)
     END IF
     ' Get the string information from the resource and return it
     IF VerQueryValue(BYVAL STRPTR(sBuf), "\StringFileInfo\" + sLangID + "\" + sItem, prtValue, dwDummy) THEN FUNCTION = @prtValue
  ELSE
     ' Otherwise, query the numeric version value
     IF VerQueryValue(BYVAL STRPTR(sBuf), "\", BYVAL VARPTR(ffi), dwDummy) THEN
        fvTail = FORMAT$(LOWRD(@ffi.dwFileVersionLS), "00")
        pvTail = FORMAT$(LOWRD(@ffi.dwProductVersionLS), "00")
        IF HIWRD(@ffi.dwFileversionLS) THEN fvTail = FORMAT$(HIWRD(@ffi.dwFileVersionLS), "00") + fvTail
        IF HIWRD(@ffi.dwProductVersionLS) THEN pvTail = FORMAT$(HIWRD(@ffi.dwProductVersionLS), "00") + pvTail
        strMajor = FORMAT$(HIWRD(@ffi.dwFileVersionMS))
        strMinor = FORMAT$(LOWRD(@ffi.dwFileVersionMS))
        strRevision = FORMAT$(HIWRD(@ffi.dwFileVersionLS))
        strBuild = FORMAT$(LOWRD(@ffi.dwFileVersionLS))
        FUNCTION =   strMajor & "." & strMinor & "." & strRevision & "." & strBuild '   FORMAT$(HIWRD(@ffi.dwFileVersionMS)) + "." + FORMAT$(LOWRD(@ffi.dwFileVersionMS), "00") + "." + fvTail
     END IF
  END IF
END FUNCTION
'------------------------------------------------------------------------------
CALLBACK FUNCTION ShowADDNEWITEMSProc()
    LOCAL lngCBOAppSelected AS LONG
    LOCAL lngCBOFormSelected AS LONG
    LOCAL lngCBOGridSelected AS LONG
    LOCAL lngCBOTabSelected AS LONG
    LOCAL strApplication AS STRING
    LOCAL strForm AS STRING
    LOCAL strGrid AS STRING
    LOCAL strTab AS STRING
    '
    LOCAL datav&
    LOCAL MLGN AS MyGridData PTR
    LOCAL lphi AS HELPINFO PTR
    LOCAL strText AS STRING
    LOCAL mycol AS LONG
    LOCAL myrow AS LONG
    LOCAL myitem AS LONG
    LOCAL lngClipResult AS LONG
    LOCAL lngState AS LONG
    LOCAL strGridColumnName AS STRING
    LOCAL lngUDT AS LONG
    '
    SELECT CASE AS LONG CB.MSG
        CASE %WM_INITDIALOG
          ' Initialization handler
          funPopulateApps(CB.HNDL,%IDC_cboAddApplication )

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
                ' /* Inserted by PB/Forms 03-14-2016 14:15:01
                CASE %IDC_cboAddTab
                ' */

                ' /* Inserted by PB/Forms 08-27-2015 11:10:54


                CASE %IDC_cboAddApplication
                  IF CB.CTLMSG = %BN_CLICKED OR CB.CTLMSG = 1 THEN
                  ' Application has been picked
                    COMBOBOX GET SELECT CB.HNDL, %IDC_cboAddApplication TO datav&
                    COMBOBOX GET USER CB.HNDL, %IDC_cboAddApplication, datav& TO lngCBOAppSelected
                    ' blank out the other values
                    lngCBOFormSelected = 0
                    lngCBOGridSelected = 0
                    lngCBOTabSelected = 0
                    funPopulateForms(CB.HNDL,%IDC_cboAddForm,lngCBOAppSelected)
                  END IF
                '
                CASE %IDC_cboAddForm
                  IF CB.CTLMSG = %BN_CLICKED OR CB.CTLMSG = 1 THEN
                  ' form has been picked
                    COMBOBOX GET SELECT CB.HNDL, %IDC_cboAddApplication TO datav&
                    COMBOBOX GET USER CB.HNDL, %IDC_cboAddApplication, datav& TO lngCBOAppSelected
                    '
                    COMBOBOX GET SELECT CB.HNDL, %IDC_cboAddForm TO datav&
                    COMBOBOX GET USER CB.HNDL, %IDC_cboAddForm, datav& TO lngCBOFormSelected
                    '
                    lngCBOGridSelected = 0
                    lngCBOTabSelected = 0
                    funPopulateGrids(CB.HNDL,%IDC_cboAddGrid,lngCBOAppSelected, lngCBOFormSelected)
                  '
                  END IF
                  '
                CASE %IDC_cboADDGrid
                  IF CB.CTLMSG = %BN_CLICKED OR CB.CTLMSG = 1 THEN
                  ' grid has been picked
                    COMBOBOX GET SELECT CB.HNDL, %IDC_cboAddApplication TO datav&
                    COMBOBOX GET USER CB.HNDL, %IDC_cboAddApplication, datav& TO lngCBOAppSelected
                    '
                    COMBOBOX GET SELECT CB.HNDL, %IDC_cboAddForm TO datav&
                    COMBOBOX GET USER CB.HNDL, %IDC_cboAddForm, datav& TO lngCBOFormSelected
                    '
                    COMBOBOX GET SELECT CB.HNDL, %IDC_cboAddGrid TO datav&
                    COMBOBOX GET USER CB.HNDL, %IDC_cboAddGrid, datav& TO lngCBOGridSelected
                    '
                    lngCBOTabSelected = 0
                    funPopulateTabs(CB.HNDL,%IDC_cboAddTab,lngCBOAppSelected, lngCBOFormSelected, lngCBOGridSelected)
                  '
                  END IF
                  '


                CASE %IDC_STATUSBAR2

                CASE %IDOK
                  IF CB.CTLMSG = %BN_CLICKED OR CB.CTLMSG = 1 THEN
                  ' save the changes
                    CONTROL GET TEXT CB.HNDL, %IDC_cboAddApplication TO strApplication
                    CONTROL GET TEXT CB.HNDL, %IDC_cboAddForm TO strForm
                    CONTROL GET TEXT CB.HNDL, %IDC_cboADDGrid TO strGrid
                    CONTROL GET TEXT CB.HNDL, %IDC_cboAddTab TO strTab
                    '
                    IF strApplication = "" OR strForm = "" OR strGrid = "" OR strTab = "" THEN
                      MSGBOX "All drop downs need populated",%MB_ICONINFORMATION, "Missing Inormation"
                    ELSE
                      IF ISTRUE funSaveChanges(CB.HNDL,%IDC_STATUSBAR2, strApplication,strForm,strGrid , strTab) THEN
                        CONTROL SET TEXT CB.HNDL,%IDC_STATUSBAR2,"Saved successfully"
                      END IF
                    END IF
                    '
                  END IF

                CASE %IDABORT
                  IF CB.CTLMSG = %BN_CLICKED OR CB.CTLMSG = 1 THEN
                    DIALOG END CB.HNDL
                  END IF
                  '
            END SELECT
    END SELECT
END FUNCTION
'------------------------------------------------------------------------------

'------------------------------------------------------------------------------
FUNCTION ShowADDNEWITEMS(BYVAL hParent AS DWORD) AS LONG
    LOCAL lRslt AS LONG

#PBFORMS BEGIN DIALOG %IDD_ADDNEWITEMS->->
    LOCAL hDlg  AS DWORD

    DIALOG NEW hParent, "Add new Items", 41, 129, 656, 278, %WS_POPUP OR _
        %WS_BORDER OR %WS_DLGFRAME OR %WS_CAPTION OR %WS_SYSMENU OR _
        %WS_CLIPSIBLINGS OR %WS_VISIBLE OR %DS_MODALFRAME OR %DS_CENTER OR _
        %DS_3DLOOK OR %DS_NOFAILCREATE OR %DS_SETFONT, %WS_EX_CONTROLPARENT _
        OR %WS_EX_LEFT OR %WS_EX_LTRREADING OR %WS_EX_RIGHTSCROLLBAR, TO _
        hDlg
    CONTROL ADD COMBOBOX,  hDlg, %IDC_cboAddApplication, , 20, 45, 120, 40, _
        %WS_CHILD OR %WS_VISIBLE OR %WS_TABSTOP OR %WS_VSCROLL OR _
        %CBS_DROPDOWN OR %CBS_SORT, %WS_EX_LEFT OR %WS_EX_LTRREADING OR _
        %WS_EX_RIGHTSCROLLBAR
    CONTROL ADD COMBOBOX,  hDlg, %IDC_cboAddForm, , 155, 45, 120, 40, _
        %WS_CHILD OR %WS_VISIBLE OR %WS_TABSTOP OR %WS_VSCROLL OR _
        %CBS_DROPDOWN OR %CBS_SORT, %WS_EX_LEFT OR %WS_EX_LTRREADING OR _
        %WS_EX_RIGHTSCROLLBAR
    CONTROL ADD COMBOBOX,  hDlg, %IDC_cboAddGrid, , 290, 45, 120, 40, _
        %WS_CHILD OR %WS_VISIBLE OR %WS_TABSTOP OR %WS_VSCROLL OR _
        %CBS_DROPDOWN OR %CBS_SORT, %WS_EX_LEFT OR %WS_EX_LTRREADING OR _
        %WS_EX_RIGHTSCROLLBAR
    CONTROL ADD COMBOBOX,  hDlg, %IDC_cboAddTab, , 425, 45, 120, 40, _
        %WS_CHILD OR %WS_VISIBLE OR %WS_TABSTOP OR %WS_VSCROLL OR _
        %CBS_DROPDOWN OR %CBS_SORT, %WS_EX_LEFT OR %WS_EX_LTRREADING OR _
        %WS_EX_RIGHTSCROLLBAR
    CONTROL ADD LABEL,     hDlg, %IDC_LABEL1, "Tab", 425, 35, 100, 10
    CONTROL SET COLOR      hDlg, %IDC_LABEL1, %BLUE, -1
    CONTROL ADD LABEL,     hDlg, %IDC_LABEL2, "Grid", 290, 35, 100, 10
    CONTROL SET COLOR      hDlg, %IDC_LABEL2, %BLUE, -1
    CONTROL ADD LABEL,     hDlg, %IDC_LABEL3, "Form", 155, 35, 100, 10
    CONTROL SET COLOR      hDlg, %IDC_LABEL3, %BLUE, -1
    CONTROL ADD LABEL,     hDlg, %IDC_LABEL4, "Application", 20, 35, 100, 10
    CONTROL SET COLOR      hDlg, %IDC_LABEL4, %BLUE, -1
    CONTROL ADD STATUSBAR, hDlg, %IDC_STATUSBAR2, "", 0, 0, 0, 0
    CONTROL ADD BUTTON,    hDlg, %IDOK, "Apply Changes", 555, 40, 90, 20, _
        %WS_CHILD OR %WS_VISIBLE OR %WS_TABSTOP OR %BS_TEXT OR _
        %BS_PUSHBUTTON OR %BS_RIGHT OR %BS_VCENTER, %WS_EX_LEFT OR _
        %WS_EX_LTRREADING
    DIALOG  SEND           hDlg, %DM_SETDEFID, %IDOK, 0
    CONTROL ADD BUTTON,    hDlg, %IDABORT, "Back", 560, 230, 50, 15, _
        %WS_CHILD OR %WS_VISIBLE OR %WS_TABSTOP OR %BS_TEXT OR _
        %BS_PUSHBUTTON OR %BS_RIGHT OR %BS_VCENTER, %WS_EX_LEFT OR _
        %WS_EX_LTRREADING
    CONTROL ADD LABEL,     hDlg, %IDC_LABEL5, "New Items are padded out to 50 " + _
        "fields all marked as hidden", 20, 10, 220, 10
    CONTROL SET COLOR      hDlg, %IDC_LABEL5, %BLUE, -1
#PBFORMS END DIALOG
    '
    ButtonPlus hDlg, %IDABORT, %BP_TEXT_COLOR, %RED
    ButtonPlus hDlg, %IDABORT, %BP_ICON_ID, %IDR_IMGBack
    ButtonPlus hDlg, %IDABORT, %BP_ICON_WIDTH, 16
    ButtonPlus hDlg, %IDABORT, %BP_ICON_POS, %BS_LEFT
    '
    ButtonPlus hDlg, %IDOK, %BP_TEXT_COLOR, %BLUE
    ButtonPlus hDlg, %IDOK, %BP_ICON_ID, %IDR_Save
    ButtonPlus hDlg, %IDOK, %BP_ICON_WIDTH, 32
    ButtonPlus hDlg, %IDOK, %BP_ICON_POS, %BS_LEFT
    '

    DIALOG SHOW MODAL hDlg, CALL ShowADDNEWITEMSProc TO lRslt

#PBFORMS BEGIN CLEANUP %IDD_ADDNEWITEMS
#PBFORMS END CLEANUP

    FUNCTION = lRslt
END FUNCTION
'------------------------------------------------------------------------------

FUNCTION funSaveChanges(hDlg AS DWORD, lngStatus AS LONG, strApplication AS STRING _
                        ,strForm AS STRING, strGrid AS STRING, strTab AS STRING) AS LONG
' save the changes to the objects selected
  LOCAL strSQL AS STRING
  LOCAL strError AS STRING
  DIM a_strData() AS STRING
  LOCAL strApplicationID AS STRING
  LOCAL strFormID AS STRING
  LOCAL strGridID AS STRING
  LOCAL strTabID AS STRING
  LOCAL lngR AS LONG
  LOCAL lngColumnCount AS LONG
  '
  CONTROL SET TEXT hDlg,lngStatus, "Saving..."
  '
  ' first check if the application exists
  strSQL = "EXEC dbo.CDEF_sprGetApplicationID '" & strApplication & "'"
  IF ISTRUE funGetGenericData(strSQL,BYREF a_strData() , %AMDB ,strError) THEN
    strApplicationID = PARSE$(a_strData(1),"|",1)
    CONTROL SET TEXT hDlg,lngStatus, "Saved Application..."
    '
    strSQL = "EXEC dbo.CDEF_sprGetFormID '" & strForm & "'," & strApplicationID
    IF ISTRUE funGetGenericData(strSQL,BYREF a_strData() , %AMDB ,strError) THEN
      strFormID = PARSE$(a_strData(1),"|",1)
      CONTROL SET TEXT hDlg,lngStatus, "Saved Form..."
      '
      strSQL = "EXEC dbo.CDEF_sprGetGridID '" & strGrid & "'," & strApplicationID & _
               "," & strFormID
      IF ISTRUE funGetGenericData(strSQL,BYREF a_strData() , %AMDB ,strError) THEN
        strGridID = PARSE$(a_strData(1),"|",1)
        CONTROL SET TEXT hDlg,lngStatus, "Saved Grid..."
        '
        strSQL = "EXEC dbo.CDEF_sprGetTabID '" & strTab & "'," & strApplicationID & _
               "," & strFormID & "," & strGridID
        IF ISTRUE funGetGenericData(strSQL,BYREF a_strData() , %AMDB ,strError) THEN
          strTabID = PARSE$(a_strData(1),"|",1)
          CONTROL SET TEXT hDlg,lngStatus, "Saved Tab..."
          '
          ' got all IDs now
          strSQL = "EXEC dbo.CDEF_sprCountTabRefs " & strApplicationID & "," & strFormID & "," _
                   & strGridID & "," & strTabID
          IF ISTRUE funGetGenericData(strSQL,BYREF a_strData() , %AMDB ,strError) THEN
            lngColumnCount = VAL(PARSE$(a_strData(1),"|",1))
            IF lngColumnCount < 50 THEN
              FOR lngR = lngColumnCount +1 TO 50
              ' add an 'unused' and hidden column for each missing column
                strSQL = "EXEC dbo.CDEF_sprAddHiddenColumn " & strApplicationID & "," & strFormID & "," _
                   & strGridID & "," & strTabID & "," & FORMAT$(lngR) & ",'unused" & FORMAT$(lngR) & "'"
                IF ISFALSE funRunSQL(strSQL,strError, %AMDB) THEN
                  CONTROL SET TEXT hDlg,lngStatus, "Unable to add hidden columns ..."
                  EXIT FUNCTION
                END IF
              '
              NEXT lngR
              '
              CONTROL SET TEXT hDlg,lngStatus, "Saved Tab..."
              FUNCTION = %TRUE
              '
            ELSE
            ' nothing to do
              CONTROL SET TEXT hDlg,lngStatus, "Nothing needing saved.."
              FUNCTION = %TRUE
            END IF
          ELSE
            CONTROL SET TEXT hDlg,lngStatus,"Unable to count Columns"
          END IF
          '
        ELSE
          CONTROL SET TEXT hDlg,lngStatus,"Unable to get Tab ID"
          FUNCTION = %False
        END IF
      ELSE
        CONTROL SET TEXT hDlg,lngStatus,"Unable to get Grid ID"
        FUNCTION = %False
      END IF
      '
    ELSE
      CONTROL SET TEXT hDlg,lngStatus,"Unable to get Form ID"
      FUNCTION = %False
    END IF
    '
  ELSE
  ' opps cant get app id
    CONTROL SET TEXT hDlg,lngStatus,"Unable to get App ID"
    FUNCTION = %False
  END IF
  '
END FUNCTION
'
