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
#RESOURCE "WarpCore_Monitor.pbr"
%USEMACROS = 1
#INCLUDE ONCE "WIN32API.INC"
#INCLUDE ONCE "COMMCTRL.INC"
#INCLUDE ONCE "PBForms.INC"
#PBFORMS END INCLUDES
'------------------------------------------------------------------------------
' add the sql tools libraries
#INCLUDE "..\SQL_Libraries\SQLT3.INC"
#LINK "..\SQL_Libraries\SQLT3Pro.PBLIB"
'
' add the Generic SQL tools libraries
#INCLUDE "..\Libraries\PB_GenericSQLFunctions.inc"
'
#INCLUDE "..\Libraries\PB_xml.inc"
#INCLUDE "..\Libraries\PB_Processes.inc"
#INCLUDE "..\Libraries\PB_FileHandlingroutines.inc"
#INCLUDE "..\Libraries\DateFunctions.inc"
'------------------------------------------------------------------------------
'   ** Constants **
'------------------------------------------------------------------------------
#PBFORMS BEGIN CONSTANTS
%IDD_DIALOG1    =  101
%IDC_GRAPHIC1   = 1001
%IDC_STATUSBAR1 = 1002
%IDR_MENU1      =  102
%IDM_FILE_EXIT  = 1003
#PBFORMS END CONSTANTS
'------------------------------------------------------------------------------
%DB = 1   ' set the handle for the DB connection
GLOBAL g_strLogFile AS STRING
GLOBAL g_hFont1 AS DWORD
'
' new globals for the disk server location
GLOBAL g_strDiskServer AS STRING
GLOBAL g_strDriveLetter AS STRING
'------------------------------------------------------------------------------
'   ** Declarations **
'------------------------------------------------------------------------------
DECLARE FUNCTION AttachMENU1(BYVAL hDlg AS DWORD) AS DWORD
DECLARE CALLBACK FUNCTION ShowDIALOG1Proc()
DECLARE FUNCTION ShowDIALOG1(BYVAL hParent AS DWORD) AS LONG
#PBFORMS DECLARATIONS
'------------------------------------------------------------------------------

'------------------------------------------------------------------------------
'   ** Main Application Entry Point **
'------------------------------------------------------------------------------
FUNCTION PBMAIN()
  '
  PBFormsInitComCtls (%ICC_WIN95_CLASSES OR %ICC_DATE_CLASSES OR _
    %ICC_INTERNET_CLASSES)
  '
  RANDOMIZE TIMER
  '
  IF funProcessCount(EXE.NAMEX$)>1 THEN
  ' more than one version on this running ?
    EXIT FUNCTION
  END IF
  '
  g_strLogFile = EXE.PATH$ & EXE.NAME$ & "_log.txt"
  '
  IF SQL_Authorize(%MY_SQLT_AUTHCODE) <> %SUCCESS THEN
    funLog("SQL Licence problem")
    FUNCTION = %FALSE
    EXIT FUNCTION
  END IF
  '
  ' first initialise the SQL library
  CALL SQL_Init
  '
  FONT NEW "MS Sans Serif", 14, 0, %ANSI_CHARSET TO g_hFont1
  '
  ' now we can connect to a DB
  LOCAL strConnectionString AS STRING
  LOCAL lngResult AS LONG
  LOCAL strDBName AS STRING
  LOCAL strStatus AS STRING
  LOCAL strSQLUserName AS STRING
  LOCAL strPassword AS STRING
  '
  strSQLUserName = "Chronos"
  strPassword = "wombat123"
  '
  g_strDiskServer = "OCTAL002"
  g_strDriveLetter = "D"

  '
  REDIM g_astrDatabases(1)
  g_astrDatabases(%DB) = "Chronos"
  '
  strConnectionString = "DRIVER=SQL Server;" & _
                        "UID=" & strSQLUserName & ";" & _
                        "PWD=" & strPassword & ";" & _
                        "DATABASE=" & g_astrDatabases(%DB) & ";" & _
                        "SERVER=quad001\SqlExpress"
  '
  'strConnectionString = "DRIVER=SQL Server;" & _
  '                      "Trusted_Connection=Yes;" & _
  '                      "DATABASE=" & _
  '                      g_astrDatabases(%DB) & ";" & _
  '                      "SERVER=quad001\SqlExpress"
  '
  IF ISTRUE funUserOpenDB(%DB, _
                          strConnectionString, _
                          strStatus) THEN
  ' db opened ok
    funLog(strStatus)
    ' run the processing
    ShowDIALOG1 %HWND_DESKTOP
    ' close the db connect
    lngResult = funUserCloseDB(%DB, strStatus)
    funLog(strStatus)
  ELSE
  ' db didn't open ok
    funLog(strStatus)
  END IF
  '
  ' release memory for the font
  FONT END g_hFont1
  '

  ' shutdown the SQL library
  lngResult = SQL_Shutdown()
  IF lngResult = %SUCCESS THEN
    funLog("SQL library closed down")
  ELSE
    funLog("Unable to close SQL library down")
  END IF
  '
END FUNCTION
'------------------------------------------------------------------------------
FUNCTION funLog(strData AS STRING)AS LONG
' output data to the log
  FUNCTION = funAppendToFile(g_strLogFile, strData)
'
END FUNCTION
'------------------------------------------------------------------------------
'   ** Menus **
'------------------------------------------------------------------------------
FUNCTION AttachMENU1(BYVAL hDlg AS DWORD) AS DWORD
#PBFORMS BEGIN MENU %IDR_MENU1->%IDD_DIALOG1
  LOCAL hMenu   AS DWORD
  LOCAL hPopUp1 AS DWORD

  MENU NEW BAR TO hMenu
  MENU NEW POPUP TO hPopUp1
  MENU ADD POPUP, hMenu, "File", hPopUp1, %MF_ENABLED
    MENU ADD STRING, hPopUp1, "Exit", %IDM_FILE_EXIT, %MF_ENABLED

  MENU ATTACH hMenu, hDlg
#PBFORMS END MENU
  FUNCTION = hMenu
END FUNCTION
'------------------------------------------------------------------------------

'------------------------------------------------------------------------------
'   ** CallBacks **
'------------------------------------------------------------------------------
CALLBACK FUNCTION ShowDIALOG1Proc()
  ' prepare a timer
  STATIC hTimer AS QUAD
  '
  SELECT CASE AS LONG CB.MSG
    CASE %WM_INITDIALOG
      ' Initialization handler
      hTimer = SetTimer(CB.HNDL, 1&, 60000&, BYVAL %NULL)
      ' display the status of each computer
      funPopulateWarpcores(CB.HNDL, %IDC_GRAPHIC1)
      '
    CASE %WM_TIMER
      ' Get Warpcore status and draw the graphic
      ' display the status of each computer
      funPopulateWarpcores(CB.HNDL, %IDC_GRAPHIC1)

    CASE %WM_MENUSELECT
      ' Update the status bar text
      STATIC szMenuPrompt AS ASCIIZ * %MAX_PATH
      IF ISFALSE LoadString(GetModuleHandle(BYVAL 0&), CB.CTL, szMenuPrompt, _
        SIZEOF(szMenuPrompt)) THEN
        szMenuPrompt = "Please choose from the menus above..."
      END IF
      CONTROL SEND CB.HNDL, %IDC_STATUSBAR1, %SB_SETTEXT, 0, _
        VARPTR(szMenuPrompt)
      FUNCTION = 1

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
        CASE %IDC_STATUSBAR1

        CASE %IDM_FILE_EXIT
          DIALOG END CB.HNDL

      END SELECT
  END SELECT
END FUNCTION
'------------------------------------------------------------------------------

'------------------------------------------------------------------------------
'   ** Dialogs **
'------------------------------------------------------------------------------
FUNCTION ShowDIALOG1(BYVAL hParent AS DWORD) AS LONG
  LOCAL lRslt AS LONG

#PBFORMS BEGIN DIALOG %IDD_DIALOG1->%IDR_MENU1->
  LOCAL hDlg  AS DWORD

  DIALOG NEW hParent, "WarpCore monitor", 76, 115, 708, 451, %WS_POPUP OR _
    %WS_BORDER OR %WS_DLGFRAME OR %WS_CAPTION OR %WS_SYSMENU OR _
    %WS_MINIMIZEBOX OR %WS_MAXIMIZEBOX OR %WS_CLIPSIBLINGS OR %WS_VISIBLE OR _
    %DS_MODALFRAME OR %DS_CENTER OR %DS_3DLOOK OR %DS_NOFAILCREATE OR _
    %DS_SETFONT, %WS_EX_CONTROLPARENT OR %WS_EX_LEFT OR %WS_EX_LTRREADING OR _
    %WS_EX_RIGHTSCROLLBAR, TO hDlg
  CONTROL ADD GRAPHIC,   hDlg, %IDC_GRAPHIC1, "", 0, 0, 705, 400
  GRAPHIC ATTACH hDlg, %IDC_GRAPHIC1
  GRAPHIC COLOR -1, %BLACK
  GRAPHIC CLEAR
  CONTROL ADD STATUSBAR, hDlg, %IDC_STATUSBAR1, "Monitoring ...", 0, 0, 0, 0

  AttachMENU1 hDlg
#PBFORMS END DIALOG

  DIALOG SHOW MODAL hDlg, CALL ShowDIALOG1Proc TO lRslt

#PBFORMS BEGIN CLEANUP %IDD_DIALOG1
#PBFORMS END CLEANUP

  FUNCTION = lRslt
END FUNCTION
'------------------------------------------------------------------------------
FUNCTION funPopulateWarpcores(hDlg AS DWORD, _
                              lngGraphic AS LONG) AS LONG
  ' populate the graphic control
  LOCAL lngRow AS LONG
  DIM a_strData() AS STRING
  LOCAL strSQL AS STRING
  LOCAL strError AS STRING
  LOCAL lngR AS LONG
  LOCAL lngROffset AS LONG
  LOCAL lngCell AS LONG
  LOCAL lngDiskUsed AS LONG
  LOCAL lngDiskFree AS LONG
  LOCAL lngTotalDisk AS LONG
  LOCAL strTemp AS STRING
  LOCAL strComputer AS STRING
  LOCAL strDMDiskFree AS STRING
  LOCAL strDMTotalDisk AS STRING
  '
  GRAPHIC COLOR %GREEN,%BLACK
  GRAPHIC SET LOC 10,10
  GRAPHIC SET FONT g_hFont1
  GRAPHIC SET CLIP 10, 10,10,10
  '
  GRAPHIC CLEAR
  INCR lngRow
  GRAPHIC ROW TO lngRow
  '
  strSQL = "EXEC dbo.sprGetWarpCoreStatus"
  IF ISTRUE funGetGenericSQLData(strSQL,a_strData(), _
            %DB, strError) THEN
  '
    GRAPHIC PRINT "WarpCore Monitor " & TIME$ & "  " & funUKDate()
    INCR lngRow
    GRAPHIC PRINT "Computer","Status";"           Disk Usage","Time Slots","Log Storage"
    INCR lngRow
    '
    GRAPHIC ROW TO lngRow
    FOR lngR = 1 TO UBOUND(a_strData)
      ' Print computer name
      strComputer = PARSE$(a_strData(lngR),"|",2)
      GRAPHIC PRINT strComputer,
      ' is status inactive?
      IF PARSE$(a_strData(lngR),"|",6) = "Inactive" THEN
      ' set active status to Red
        GRAPHIC COLOR %RED
      ELSE
        GRAPHIC COLOR %GREEN
      END IF
      '
      ' print the status
      GRAPHIC PRINT PARSE$(a_strData(lngR),"|",6) POS(390);
      GRAPHIC COLOR %GREEN
      '
      ' print the Time slots
      GRAPHIC PRINT PARSE$(a_strData(lngR),"|",7) POS(520);
      '
      IF UCASE$(strComputer) = UCASE$(g_strDiskServer) THEN
        ' its the disk computer
        strDMDiskFree = PARSE$(a_strData(lngR),"|",8)
        strDMTotalDisk = PARSE$(a_strData(lngR),"|",9)
        GRAPHIC PRINT FORMAT$(VAL(strDMTotalDisk) - VAL(strDMDiskFree)) & _
                                   "/" & strDMTotalDisk & " GB"
      ELSE
        ' its not
        GRAPHIC PRINT ""
      END IF
      '
      lngDiskFree = VAL(PARSE$(a_strData(lngR),"|",4))
      lngTotalDisk = VAL(PARSE$(a_strData(lngR),"|",5))
      lngDiskUsed =  100-ROUND((lngDiskFree/lngTotalDisk) * 100,0)
      '
      lngROffset = lngR +1
      ' draw total disk space background i.e. 100% in green
      GRAPHIC BOX (230,(lngROffset*24)+4) - _
                  (330,(lngROffset*24)+23),,%GREEN,%GREEN
      ' draw disk space used in red
      GRAPHIC BOX (230,(lngROffset*24)+6) - _
                  (230 +lngDiskUsed,(lngROffset*24)+21),,%RED,%RED
      '
    NEXT lngR
  '
  ELSE
  ' error
    funLog("SQL error " & $CRLF & strSQL & $CRLF & strError)
  END IF
  '
END FUNCTION
