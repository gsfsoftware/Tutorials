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
#OPTIMIZE CODE ON
#COMPILE EXE
#DEBUG ERROR ON
#DIM ALL
'
'***POWERBASIC HEADER START***
' This is the header information section for this application which should give basic information on the use
' and purpose of the application.
' Name:ResourceManager.bas
' Description:This application takes no parameters and allows a team to set values for their
'             teams resource allocation and saves this to an html page.
'
'
'
'------------------------------------------------------------------------------
'   ** Includes **
'------------------------------------------------------------------------------
#PBFORMS BEGIN INCLUDES
#RESOURCE "ResourceManager.pbr"
%USEMACROS = 1
#INCLUDE ONCE "WIN32API.INC"
#INCLUDE ONCE "COMMCTRL.INC"
#INCLUDE ONCE "PBForms.INC"
#PBFORMS END INCLUDES
'------------------------------------------------------------------------------
%MLGSLL = 1
#INCLUDE "MLG.INC"
#LINK "MLG.SLL"
#LINK "zSpinPB10.sll"

#INCLUDE "ButtonPlus.bas"
#INCLUDE "Tooltips.inc"
#INCLUDE "htmlhelp.inc"
#INCLUDE "LMErr.inc"
#INCLUDE "LMApiBuf.inc"
'
%hiNum1 = 1
%loNum1 = 1
%hiNum2 = 1
%loNum2 = 4
#RESOURCE VERSIONINFO
#RESOURCE FILEVERSION %hiNum1, %loNum1, %hiNum2, %loNum2
'#RESOURCE PRODUCTVERSION %hiNum1, %loNum1, %hiNum2, %hiNum2
#RESOURCE STRINGINFO "0809", "0000"
#RESOURCE VERSION$ "Comments",         "Additional info"
#RESOURCE VERSION$ "CompanyName",      "GSF Software"
#RESOURCE VERSION$ "FileDescription",  "Allows inputting of Teams Resource management plans"
#RESOURCE VERSION$ "FileVersion",      "1.1.1.3"
#RESOURCE VERSION$ "InternalName",     "ResourceManager"
#RESOURCE VERSION$ "LegalCopyright",   "Freeware"
#RESOURCE VERSION$ "OriginalFilename", "ResourceManager.exe"
#RESOURCE VERSION$ "PrivateBuild",     "n/a"
#RESOURCE VERSION$ "ProductName",      "Resource Manager"
#RESOURCE VERSION$ "ProductVersion",   "1.001.001.0003"
#RESOURCE VERSION$ "SpecialBuild",     "n/a"

'------------------------------------------------------------------------------
'   ** Constants **
'------------------------------------------------------------------------------
#PBFORMS BEGIN CONSTANTS
%IDR_IMGFILE1                 =  102
%IDR_IMGFILE2                 =  103
%IDR_IMGFILE3                 =  104
%IDR_IMGFILE4                 =  105
%IDR_IMGFILE5                 =  106
%IDR_IMGFILE6                 =  109
%IDR_IMGFILE7                 =  111
%IDM_RESOURCE_ADDRESOURCE     = 2308
%IDM_RESOURCE_AMENDARESOURCE  = 2317
%IDM_RESOURCE_DELETEARESOURCE = 2318
%IDD_DIALOG1                  =  101
%IDABORT                      =    3
%IDC_txtTeamName              = 2000
%IDC_txtResource              = 2001
%IDC_GENERATE                 = 2002
%IDC_LOADDATA                 = 2003
%ID_OCX                       = 2004
%IDC_OPTION0                  = 2005
%IDC_OPTION10                 = 2015
%IDC_STATUSBAR1               = 2016
%IDC_Task0                    = 2100
%IDC_Task1                    = 2101
%IDC_Task2                    = 2102
%IDC_Task3                    = 2103
%IDC_Task4                    = 2104
%IDC_Task5                    = 2105
%IDC_Task6                    = 2106
%IDC_Task7                    = 2107
%IDC_Task8                    = 2108
%IDC_Task9                    = 2109
%IDC_Task10                   = 2110
%IDC_Task11                   = 2111
%IDC_Task12                   = 2112
%IDC_Tick0                    = 2200
%IDC_LABEL2                   = 2301
%IDC_staff                    = 2302
%IDC_TaskLabel                = 2303
%IDC_IMGNHS                   = 2304
%IDC_IMG_load                 = 2305
%IDC_IMG_save                 = 2306
%IDC_IMG_Exit                 = 2307
%IDR_MENU1                    =  107
%IDD_ADDANEWRESOURCEUNIT      =  108
%IDC_LABEL1                   = 2309
%IDC_txtResourceName          = 2310
%IDC_LABEL3                   = 2311
%IDC_STATUSBAR2               = 2312
%IDC_txtHeadcount             = 2313
%IDC_SAVE                     = 2315
%IDCANCEL                     =    2
%IDC_IMGOK                    = 2316
%IDD_DELETEARESOURCE          =  110
%IDC_STATUSBAR3               = 2321
%IDOK                         =    1
%IDC_IMGDB                    = 2322
%IDM_RESOURCE_HELP            = 2323
%IDD_AMENDARESOURCEINTHETEAM  =  112
%IDC_STATUSBAR4               = 2324
%IDM_RESOURCE_AmendSecurity   =  113
%IDD_AMENDPermissions         =  114
%IDC_TEAM                     = 2326
%IDC_TEAMNAME                 = 2325
%IDC_SAVEPermissions          = 2336
%IDC_OPTDetail                = 2337
%IDC_OPTSummary               = 2338
#PBFORMS END CONSTANTS
'
%IDC_MLGGRID1    = 3000
%IDC_MLGGRID2    = 3001
%IDC_MLGGRID3    = 3002
%IDC_MLGGRID4    = 3003
'
%MAX_TASKS       = 11
'
GLOBAL hGrid1 AS DWORD
GLOBAL hGrid2 AS DWORD
GLOBAL hGrid3 AS DWORD
GLOBAL hGrid4 AS DWORD
GLOBAL sheetIDM1 AS LONG
GLOBAL sheetIDM2 AS LONG
GLOBAL sheetIDM3 AS LONG
GLOBAL sheetIDM4 AS LONG
GLOBAL sheetIDM5 AS LONG
GLOBAL sheetIDM6 AS LONG
GLOBAL a_lngTaskColours() AS LONG   ' used to hold the colours for the tasks
GLOBAL a_strHTMLColours() AS STRING ' used to hold the colours of the HTML tasks
'
GLOBAL lngTaskSelected AS LONG    ' used for the currently selected task
GLOBAL glngGridRows AS LONG       ' used to hold the number of grid rows
GLOBAL g_strResourceName AS STRING    ' used to hold a new resource name
GLOBAL g_strResourceHeadCount AS STRING ' used to hold the headcount of a new resource
GLOBAL glngRowSelected AS LONG          ' used to hold value of the currently selected row
GLOBAL glngEndRowSelected AS LONG       ' end row selected
GLOBAL glngColSelected AS LONG          ' used to hold value of the currently selected column
GLOBAL glngEndColSelected AS LONG       ' end column selected

GLOBAL a_lngStaffChecked() AS LONG      ' used to hold check status for deletion of resources
GLOBAL g_lngDirtyFlag AS LONG           ' Dirty flag to indicate something needs to be saved
GLOBAL g_hMenu AS DWORD                 ' global handle for the menu structure
'
GLOBAL g_strOwner AS STRING             ' name of owner of a teams file
GLOBAL g_lngFullAccess AS LONG          ' %TRUE = full read/write access %FALSE = read only access
GLOBAL g_strTeamName AS STRING          ' used to hold the team name for htm access
'
' resizable code
%IdCol           = 1
%WidthCol        = 2
%HeightCol       = 3
%MinWindowHeight = 401        ' minimum size of the height - window will not shrink below this value
%MaxWindowHeight = 99999      ' maximum size of the window height
%MinWindowWidth  = 804        ' minimum size of the width - window will not shrink below this value
%MaxWindowWidth  = 99999      ' maximum size of the width
#INCLUDE "PB_Redraw.inc"

'
$RED   = "#FF0000"      ' html tag colours
$GREEN = "#00FF00"
'
TYPE USER_INFO_10
    usri10_name        AS DWORD  ' UnicodeZ ptr
    usri10_comment     AS DWORD  ' UnicodeZ ptr
    usri10_usr_comment AS DWORD  ' UnicodeZ ptr
    usri10_full_name   AS DWORD  ' UnicodeZ ptr
END TYPE

' for getting full user names
DECLARE FUNCTION NetGetDCName LIB "NETAPI32.DLL" ALIAS "NetGetDCName" _
        (BYVAL uServerName AS DWORD, BYVAL uDomainName AS DWORD, ServerInfoPointer AS DWORD)AS LONG
'
DECLARE FUNCTION NetUserGetInfo LIB "NETAPI32.DLL" ALIAS "NetUserGetInfo" _
        (BYVAL uServerName AS DWORD, BYVAL uUserName AS DWORD, BYVAL Level AS DWORD, SeverInfoPointer AS DWORD)AS LONG

DECLARE FUNCTION AtlAxWinInit LIB "ATL.DLL" ALIAS "AtlAxWinInit" () AS LONG
' *********************************************************************************************
  DECLARE FUNCTION AtlAxWinTerm () AS LONG
' *********************************************************************************************
  FUNCTION AtlAxWinTerm () AS LONG
    UnregisterClass ("AtlAxWin", GetModuleHandle(BYVAL %NULL))
  END FUNCTION
' *********************************************************************************************
' **********************************************************************************************
  DECLARE FUNCTION AtlAxGetControl LIB "ATL.DLL" ALIAS "AtlAxGetControl" _
     ( _
     BYVAL hWnd AS DWORD, _   ' [in] A handle to the window that is hosting the control.
     BYREF pp AS DWORD _      ' [out] The IUnknown of the control being hosted.
  ) AS DWORD
' *********************************************************************************************

' *********************************************************************************************
' Puts the address of an object in a variant and marks it as containing a dispatch variable
' *********************************************************************************************
FUNCTION IUnknown_AddRef (BYVAL pthis AS DWORD PTR) AS DWORD
    LOCAL DWRESULT AS DWORD
    IF ISFALSE pthis THEN EXIT FUNCTION
    CALL DWORD @@pthis[1] USING IUnknown_AddRef(pthis) TO DWRESULT
    FUNCTION = DWRESULT
END FUNCTION

SUB AtlMakeDispatch (BYVAL lpObj AS DWORD, BYREF vObj AS VARIANT) EXPORT
   LOCAL lpvObj AS VARIANTAPI PTR                 ' Pointer to a VARIANTAPI structure
   LET vObj = EMPTY                               ' Make sure is empty to avoid memory leaks
   lpvObj = VARPTR(vObj)                          ' Get the VARIANT address
   @lpvObj.vt = %VT_DISPATCH                      ' Mark it as containing a dispatch variable
   @lpvObj.pdispVal = lpObj                       ' Set the dispatch pointer address
   IUnknown_AddRef lpObj                          ' Increment the reference counter
END SUB

'------------------------------------------------------------------------------
GLOBAL g_strMonths AS STRING     ' | delimited string of months
GLOBAL g_strData AS STRING       ' | delimited string of % data
GLOBAL oOcx AS DISPATCH          ' for web page
GLOBAL hOcx AS DWORD             ' handle for web control
'------------------------------------------------------------------------------
'   ** Declarations **
'------------------------------------------------------------------------------
DECLARE CALLBACK FUNCTION ShowDIALOG1Proc()
DECLARE FUNCTION ShowDIALOG1(BYVAL hParent AS DWORD) AS LONG
DECLARE FUNCTION AttachMENU1(BYVAL hDlg AS DWORD) AS DWORD
DECLARE CALLBACK FUNCTION ShowADDANEWRESOURCEUNITProc()
DECLARE FUNCTION ShowADDANEWRESOURCEUNIT(BYVAL hDlg AS DWORD) AS LONG
DECLARE CALLBACK FUNCTION ShowDELETEARESOURCEProc()
DECLARE FUNCTION ShowDELETEARESOURCE(BYVAL hDlg AS DWORD) AS LONG
DECLARE CALLBACK FUNCTION ShowAMENDARESOURCEINTHETEAMProc()
DECLARE FUNCTION ShowAMENDARESOURCEINTHETEAM(BYVAL hDlg AS DWORD) AS LONG
#PBFORMS DECLARATIONS
'------------------------------------------------------------------------------

'------------------------------------------------------------------------------
'   ** Main Application Entry Point **
'------------------------------------------------------------------------------
FUNCTION PBMAIN()

    PBFormsInitComCtls (%ICC_WIN95_CLASSES OR %ICC_DATE_CLASSES OR _
        %ICC_INTERNET_CLASSES)
    glngGridRows = 1 ' start with default of 1 row
    REDIM a_lngStaffChecked(200) AS LONG
    funGenerateMonths()
    funPrepTaskColours()
    funPrepHTMLColours()
    ShowDIALOG1 %HWND_DESKTOP
END FUNCTION
'------------------------------------------------------------------------------

'------------------------------------------------------------------------------
'   ** Menus **
'------------------------------------------------------------------------------
'   ** CallBacks **
'------------------------------------------------------------------------------
CALLBACK FUNCTION ShowDIALOG1Proc()
    LOCAL strtxtTeamName AS STRING
    LOCAL strtxtResource AS STRING
    LOCAL strData AS STRING
    LOCAL lngR AS LONG
    LOCAL strTemp AS STRING
    LOCAL lngFlags AS LONG
    LOCAL strOption AS STRING
    '
    LOCAL strURL AS STRING
    LOCAL vVar AS VARIANT
    LOCAL MLGN AS MyGridData PTR
    STATIC myrow AS LONG
    STATIC mycol AS LONG
    LOCAL s AS STRING
    LOCAL myitem AS LONG
    LOCAL fo AS FormatOverride
    LOCAL lngTask AS LONG
    LOCAL strTaskName AS STRING
    LOCAL a_strData() AS STRING
    IF glngGridRows = 1 THEN glngGridRows = 2
    REDIM a_strData(1 TO glngGridRows-1) AS STRING
    LOCAL lngCount AS LONG
    LOCAL strFolder AS STRING
    LOCAL lngC AS LONG
    LOCAL lngCellColor AS LONG
    LOCAL strResourceName AS STRING     ' used to hold the name of the resource being added
    LOCAL lngF AS LONG                  ' column variable
    LOCAL lngE AS LONG                  ' row variable
    LOCAL lngTemp AS LONG               ' work variable to calculate background colour of additional rows
    LOCAL mytotalrows AS LONG
    LOCAL mytotalcols AS LONG
    LOCAL lphi AS HELPINFO PTR
    LOCAL lngX AS LONG                  ' temp variables for recording selections
    LOCAL lngY AS LONG
    LOCAL lngResult AS LONG
    LOCAL lngRowEnd AS LONG
    '
    SELECT CASE AS LONG CB.MSG
      ' /* Inserted by PB/Forms 09-12-2011 13:36:21
      CASE %WM_HELP
      ' handle help calls
          lphi = CB.LPARAM
          funCallHelp(CB.HNDL , lphi)
          FUNCTION = 1: EXIT FUNCTION

      CASE %WM_MENUSELECT
          ' Update the status bar text
          STATIC szMenuPrompt AS ASCIIZ * %MAX_PATH
          IF ISFALSE LoadString(GetModuleHandle(BYVAL 0&), CB.CTL, _
              szMenuPrompt, SIZEOF(szMenuPrompt)) THEN
              szMenuPrompt = "Please choose from the menus above..."
          END IF
          CONTROL SEND CB.HNDL, %IDC_STATUSBAR1, %SB_SETTEXT, 0, _
              VARPTR(szMenuPrompt)
          FUNCTION = 1
      ' */
      CASE %WM_SYSCOMMAND
      IF (CB.WPARAM AND &HFFF0) = %SC_CLOSE THEN
        lngResult = MSGBOX("Are you sure you wish to exit this application", _
                    %MB_YESNO OR %MB_TASKMODAL,"Exit Application?")
        IF lngResult = %IDYES THEN
        ' exit application
          FUNCTION = 0
        ELSE
          FUNCTION = 1
        END IF
        '
      ELSE
        FUNCTION = 0
      END IF

      ' /* Inserted by PB/Forms 08-10-2011 10:32:52
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
      ' */
      CASE %WM_SIZE:  'Called when window changes size
      ' Dialog has been resized
        CONTROL SEND CB.HNDL, %IDC_STATUSBAR1, CB.MSG, CB.WPARAM, CB.LPARAM
        '
        funResize CB.HNDL, 0, "Initialize"  ' Must be called first
        IF ISTRUE isIconic(CB.HNDL) THEN EXIT FUNCTION  ' Exit if minimized
        '
        funResize CB.HNDL, %IDC_MLGGRID1, "Scale-H"
        funResize CB.HNDL, %ID_OCX , "Scale-H"
        funResize CB.HNDL, %ID_OCX , "Scale-V"
        funResize CB.HNDL, %IDABORT, "Move-V"
        funResize CB.HNDL, %IDABORT, "Move-H"
        funResize CB.HNDL, %IDC_GENERATE, "Move-V"
        '
        funResize CB.HNDL, 0, "Repaint"    ' Must be called last
        '
      CASE %WM_INITDIALOG
          ' Initialization handler
        CALL ToolTip_SetToolTip (GetDlgItem(CB.HNDL, %IDABORT), _
                                "Click to exit the application" )
        CALL ToolTip_SetToolTip (GetDlgItem(CB.HNDL, %IDC_LOADDATA), _
                                "Click to load a teams resource file" )
        CALL ToolTip_SetToolTip (GetDlgItem(CB.HNDL, %IDC_GENERATE), _
                                "Click to save a teams resource file and generate html" )
        CALL ToolTip_SetToolTip (GetDlgItem(CB.HNDL, %IDC_staff), _
                                "Developed by NISG Configuration Management Team" )
        CALL ToolTip_SetToolTip (GetDlgItem(CB.HNDL, %IDC_MLGGRID1), _
                                "Right click to assign task or sort column" )
        CALL ToolTip_SetToolTip (GetDlgItem(CB.HNDL, %IDC_TaskLabel), _
                                "Click checkbox to set task to assign" )
        '
        FOR lngR = %IDC_Task1 TO %IDC_Task1 + (%MAX_TASKS -1)
          CALL ToolTip_SetToolTip (GetDlgItem(CB.HNDL, lngR), _
                                "Type name of task to create new task" )
        NEXT lngR
        '
        CONTROL SET OPTION CB.HNDL,%IDC_OPTDetail,%IDC_OPTDetail,%IDC_OPTSummary
        '
      CASE %WM_NOTIFY
        MLGN=CB.LPARAM
        IF @MLGN.NMHeader.idFrom = %IDC_MLGGRID1 THEN
          SELECT CASE @MLGN.NMHeader.code
          '
            CASE %MLG_GETMULTICELLSELECTION

            CASE %MLGN_MULTICELLCHANGE
            ' multi cell select
              glngColSelected=@MLGN.Param2
              glngRowSelected=@MLGN.Param1
              glngEndRowSelected=@MLGN.Param3
              glngEndColSelected=@MLGN.Param4
              '
              ' test for upward selection
              IF glngEndRowSelected<>0 THEN
                IF glngRowSelected > glngEndRowSelected THEN
                  lngX = glngRowSelected
                  lngY = glngEndRowSelected
                  glngRowSelected = lngY
                  glngEndRowSelected = lngX
                END IF
              END IF
              '
              ' test for right to left selection
              IF glngEndColSelected<>0 THEN
                IF glngColSelected > glngEndColSelected THEN
                  lngX = glngColSelected
                  lngY = glngEndColSelected
                  glngColSelected = lngY
                  glngEndColSelected = lngX
                END IF
              END IF
              '
              IF glngColSelected<3 THEN glngColSelected = 3
              IF glngRowSelected<2 THEN glngRowSelected = 2

            CASE %MLGN_COLSELCHANGE
            ' column/s have been selected
              glngColSelected=@MLGN.Param1    ' start col
              glngEndColSelected=@MLGN.Param2 ' end col
              '
            CASE %MLGN_ROWSELCHANGE
            ' row/s have been selected
              glngRowSelected=@MLGN.Param1    'start row
              glngEndRowSelected=@MLGN.Param2 'end row
              'control set text cb.hndl, %IDC_STATUSBAR1, "End row = " & format$(glngEndRowSelected)

            CASE %MLGN_RCLICKMENU
              myitem=@MLGN.Param3  ' Menu Item
              mycol=@MLGN.Param2   ' Column of Mouse
              myrow=@MLGN.Param1   ' Row of Mouse
              '
              strTaskName = ""
              lngTask = funGetTask(CB.HNDL, strTaskName)
              '
              fo.CellFont=1
              '
              SELECT CASE myitem
                CASE 1
                ' set to unallocated
                  IF glngEndRowSelected = 0 THEN
                  ' has column been selected?
                    IF glngEndColSelected =0 THEN
                    ' do just the cell no row has been selected
                      IF mycol < 3 THEN EXIT FUNCTION
                      lngCellColor = 4 ' %GREEN
                      MLG_Put hGrid1,myrow,mycol,"Unallocated",0
                      SendMessage hGrid1 ,%MLG_SETFORMATOVERRIDEEX,MAKLNG(myrow,mycol),MAKLNG(%MLG_TYPE_BKGCOLOR,lngCellColor)
                      SendMessage(hGrid1, %MLG_REFRESH, 1, 0)
                      g_lngDirtyFlag = %TRUE
                    ELSE
                    ' column has been selected
                    ' so fill the column/s
                      FOR lngR = glngColSelected TO glngEndColSelected
                        IF lngR < 3 THEN ITERATE  ' ensure first two columns arent changed
                        FOR lngC = 2 TO glngGridRows
                          lngCellColor=4 ' %GREEN
                          MLG_Put hGrid1,lngC,lngR,"Unallocated",0
                          SendMessage hGrid1 ,%MLG_SETFORMATOVERRIDEEX,MAKLNG(lngC,lngR),MAKLNG(%MLG_TYPE_BKGCOLOR,lngCellColor)
                        NEXT lngC
                        SendMessage(hGrid1, %MLG_REFRESH, 1, 0)
                      NEXT lngR
                      g_lngDirtyFlag = %TRUE
                    '
                    END IF
                  ELSE
                  ' whole row has been selected
                  ' set to unallocated for all weeks
                    FOR lngR = glngRowSelected TO glngEndRowSelected
                      FOR lngC = glngColSelected TO glngEndColSelected
                        lngCellColor=4 ' %GREEN
                        MLG_Put hGrid1,lngR,lngC,"Unallocated",0
                        SendMessage hGrid1 ,%MLG_SETFORMATOVERRIDEEX,MAKLNG(lngR,lngC),MAKLNG(%MLG_TYPE_BKGCOLOR,lngCellColor)
                      NEXT lngC
                      SendMessage(hGrid1, %MLG_REFRESH, 1, 0)
                    NEXT lngR
                    g_lngDirtyFlag = %TRUE
                  '
                  END IF
                  '
                CASE 2
                ' set to task
                  IF glngEndRowSelected = 0 THEN
                  ' set to Task for this quarter
                  ' has column been selected?
                    IF glngEndColSelected =0 THEN
                    ' set the text
                      MLG_Put hGrid1,myrow,mycol,strTaskName,0
                      lngCellColor = funGetTheColour(lngTask) '%RGB_YELLOWGREEN
                      SendMessage hGrid1 ,%MLG_SETFORMATOVERRIDEEX,MAKLNG(myrow,mycol),MAKLNG(%MLG_TYPE_BKGCOLOR,lngCellColor)
                      SendMessage(hGrid1, %MLG_REFRESH, 1, 0)
                      g_lngDirtyFlag = %TRUE
                    ELSE
                    ' do all of the column/s
                      FOR lngR = glngColSelected TO glngEndColSelected
                        IF lngR < 3 THEN ITERATE  ' ensure first two columns arent changed
                        FOR lngC = 2 TO glngGridRows
                          MLG_Put hGrid1,lngC,lngR,strTaskName,0
                          lngCellColor = funGetTheColour(lngTask) '%RGB_YELLOWGREEN
                          SendMessage hGrid1 ,%MLG_SETFORMATOVERRIDEEX,MAKLNG(lngC,lngR),MAKLNG(%MLG_TYPE_BKGCOLOR,lngCellColor)
                        NEXT lngC
                        SendMessage(hGrid1, %MLG_REFRESH, 1, 0)
                      NEXT lngR
                      g_lngDirtyFlag = %TRUE
                    '
                    END IF
                    '
                  ELSE
                  ' set to Task for all weeks in this month
                  ' set the text
                    FOR lngR = glngRowSelected TO glngEndRowSelected
                      FOR lngC = glngColSelected TO glngEndColSelected
                        MLG_Put hGrid1,lngR,lngC,strTaskName,0
                        lngCellColor = funGetTheColour(lngTask) '%RGB_YELLOWGREEN
                        SendMessage hGrid1 ,%MLG_SETFORMATOVERRIDEEX,MAKLNG(lngR,lngC),MAKLNG(%MLG_TYPE_BKGCOLOR,lngCellColor)
                      NEXT lngC
                      SendMessage(hGrid1, %MLG_REFRESH, 1, 0)
                    NEXT lngR
                    g_lngDirtyFlag = %TRUE
                  END IF
                  '
                CASE 3
                ' sort the column
                ' first work out where we are
                ' get the data
                  IF mycol <3 THEN EXIT FUNCTION
                  '
                  FOR lngR = 2 TO glngGridRows
                     a_strData(lngR-1) = MLG_Get(hGrid1,lngR,mycol)
                  NEXT lngR
                  '
                  ' now sort array starting at lngR
                  IF ISFALSE funSortColumn(hGrid1,lngR,mycol, a_strData(), CB.HNDL) THEN
                  ' problem sorting?
                  END IF
                  '
                  SendMessage(hGrid1, %MLG_REFRESH, 1, 0)
                  g_lngDirtyFlag = %TRUE
                  '
                CASE 4
                ' sort all columns
                  FOR lngC = 3 TO 6
                    RESET a_strData()
                    FOR lngR = 2 TO glngGridRows
                       a_strData(lngR-1) = MLG_Get(hGrid1,lngR,lngC)
                    NEXT lngR
                    '
                    ' now sort array starting at lngR
                    IF ISFALSE funSortColumn(hGrid1,lngR,lngC, a_strData(), CB.HNDL) THEN
                    ' problem sorting?
                    END IF
                  NEXT lngC
                  SendMessage(hGrid1, %MLG_REFRESH, 1, 0)
                  g_lngDirtyFlag = %TRUE
                '
              END SELECT
              '
          END SELECT
        END IF
        '
      CASE %WM_NCACTIVATE
        '
        IF ISFALSE CB.WPARAM THEN
        ' Save control focus
          hWndSaveFocus = GetFocus()
        ELSEIF hWndSaveFocus THEN
        ' Restore control focus
          SetFocus(hWndSaveFocus)
          hWndSaveFocus = 0
        END IF
        '
      CASE %WM_COMMAND
          ' Process control notifications
        SELECT CASE AS LONG CB.CTL
        ' /* Inserted by PB/Forms 09-30-2011 11:41:31
          CASE %IDC_Task0 TO %IDC_Task10
          ' handle changes to the task names
            IF CB.CTLMSG = %EN_CHANGE THEN
              g_lngDirtyFlag = %TRUE
            END IF
            '
          CASE %IDM_RESOURCE_HELP
            lphi = CB.LPARAM
            funCallHelp(CB.HNDL , lphi)
            FUNCTION = 1: EXIT FUNCTION
            ' */
          CASE %IDM_RESOURCE_AmendSecurity
          ' amend the security of the team
            CONTROL GET TEXT CB.HNDL,%IDC_txtTeamName TO strtxtTeamName
            ' is this person the owner of the team?
            IF g_strOwner = funCurrentUser THEN
              ShowAmendPermissions(CB.HNDL,strtxtTeamName)
            ELSE
              MSGBOX "You cannot amend the security access as you are not the owner" & $CRLF & _
                     "Please contact the owner - " & g_strOwner, %MB_ICONERROR OR %MB_TASKMODAL, _
                     "Security Change Denied"
              '
              FUNCTION = 1: EXIT FUNCTION
            END IF

            ' /* Inserted by PB/Forms 09-21-2011 18:30:19
          CASE %IDM_RESOURCE_AMENDARESOURCE
            IF ISTRUE ShowAMENDARESOURCEINTHETEAM(CB.HNDL) THEN
              g_lngDirtyFlag = %TRUE
            END IF
            '
          CASE %IDM_RESOURCE_DELETEARESOURCE
            IF ISTRUE ShowDELETEARESOURCE(CB.HNDL) THEN
            ' team list has been updated so update the grid
              g_lngDirtyFlag = %TRUE
              '
            END IF
            ' */
            ' /* Inserted by PB/Forms 09-12-2011 13:38:03
          CASE %IDM_RESOURCE_ADDRESOURCE
          ' add a new resource
          ' prompt user for Resource name
            g_strResourceHeadCount = "0"
            g_strResourceName = ""
            IF ISTRUE ShowADDANEWRESOURCEUNIT(CB.HNDL) THEN
            ' resource has been input
            ' g_strResourceName has been populated
            ' g_strResourceHeadCount has been populated
              glngGridRows = glngGridRows +5
            'for each workbook
              FOR lngCount = 1 TO 6
              ' handle first resource
                SELECT CASE glngGridRows
                ' handle first resource
                  CASE 7
                    DECR glngGridRows
                END SELECT
                '
                ' select the work sheet
                SendMessage hGrid1, %MLG_SELECTSHEET, lngCount,0
                MLG_ArrayRedim(hGrid1, glngGridRows , 6, glngGridRows, 6)
                '
                ' set the quarter values
                FOR lngE = glngGridRows - 4 TO glngGridRows
                  FOR lngF = 1 TO 2
                  ' work out the background colour
                    lngTemp = glngGridRows -1
                    lngTemp = lngTemp \ 5
                    lngTemp = lngTemp MOD 2
                    SELECT CASE lngTemp
                      CASE 0
                      ' even number line - so make light grey
                        lngCellColor = 3
                      CASE ELSE
                      ' odd number line - so make dark grey
                        lngCellColor = 2
                    END SELECT
                    '
                    SELECT CASE lngF
                      CASE 1
                        MLG_Put hGrid1,lngE,lngF,g_strResourceName,0
                        SendMessage hGrid1 ,%MLG_SETFORMATOVERRIDEEX, _
                                            MAKLNG(lngE,lngF), _
                                            MAKLNG(%MLG_TYPE_BKGCOLOR,lngCellColor)
                      CASE 2
                        MLG_Put hGrid1,lngE,lngF,g_strResourceHeadCount,0
                        SendMessage hGrid1 ,%MLG_SETFORMATOVERRIDEEX,MAKLNG(lngE,lngF), _
                                            MAKLNG(%MLG_TYPE_BKGCOLOR,lngCellColor)
                    END SELECT
                    '
                  NEXT lngF
                  '
                  FOR lngF = 3 TO 6
                  ' handle data columns
                    lngCellColor = 4 ' set to green background
                    'fo.CellFont=1
                    MLG_Put hGrid1,lngE,lngF,"Unallocated",0
                    SendMessage hGrid1 ,%MLG_SETFORMATOVERRIDEEX, _
                                         MAKLNG(lngE,lngF), _
                                         MAKLNG(%MLG_TYPE_BKGCOLOR,lngCellColor)
                  NEXT lngF
                NEXT lngE
                '
              NEXT lngCount
              '
              ' return to work sheet 1
              SendMessage hGrid1, %MLG_SELECTSHEET, 1,0
              g_lngDirtyFlag = %TRUE
              '
            END IF
            '
          CASE %IDC_Tick0 TO %IDC_Tick0 + %MAX_TASKS
          ' lngTaskSelected
            IF CB.CTLMSG = %BN_CLICKED OR CB.CTLMSG = 1 THEN
            ' set lngTaskSelected to value of task
              lngTaskSelected = CB.CTL - %IDC_Tick0
              FOR lngR = %IDC_Tick0 TO %IDC_Tick0 + %MAX_TASKS
                IF lngR <> lngTaskSelected + %IDC_Tick0 THEN
                  CONTROL SET CHECK CB.HNDL,lngR,0
                END IF
              NEXT lngR
            END IF
            '
          CASE %IDC_LOADDATA
            IF CB.CTLMSG = %BN_CLICKED OR CB.CTLMSG = 1 THEN
            ' load the data based on the Team name
              lngFlags = %OFN_FILEMUSTEXIST OR %OFN_ENABLESIZING OR %OFN_NONETWORKBUTTON
              '
              strFolder = RTRIM$(EXE.PATH$ & "Data","\")
              '
              DISPLAY OPENFILE CB.HNDL,10,10,"Select Team file",strFolder, _
                "*.dat","*.dat","dat", _
              lngFlags TO strtxtTeamName
              '
              ' display the gear wheels to indicate app is busy
              CALL zSpinnerInit(CB.HNDL, EXE.PATH$ & "SpinFolder\Gear01.ski", 0)
              DIALOG DOEVENTS 0
              '
              strtxtTeamName = PARSE$(strtxtTeamName,"\",-1)
              REPLACE ".dat" WITH "" IN strtxtTeamName
              IF strtxtTeamName <> "" THEN
                IF ISFILE(EXE.PATH$ & "Data\" & strtxtTeamName & ".dat") THEN
                ' the file exists - so load the data ?
                ' first check the user has permission to access this file
                  IF ISFALSE funIsUserAllowedAccess(EXE.PATH$ & "Data\Levels\" & strtxtTeamName & ".ser") THEN
                  ' user is not allowed access to this file
                    CALL zSpinnerClose()  ' close the Gear wheels busy graphic
                    MSGBOX "You have no permissions to view this teams data" & $CRLF & _
                           "Contact " & g_strOwner & " for access", _
                           %MB_ICONWARNING OR %MB_TASKMODAL, "No Access to this Data"
                    EXIT FUNCTION
                  ELSE
                  ' set security states
                    IF ISFALSE g_lngFullAccess THEN
                    ' remind user that this is readonly team file
                      DIALOG SET TEXT CB.HNDL,"Resource Management - READ ONLY"
                      CONTROL DISABLE CB.HNDL, %IDC_GENERATE
                      MENU SET STATE g_hMenu, BYCMD %IDM_RESOURCE_AmendSecurity, %MFS_DISABLED
                    ELSE
                    ' full rights user so enable generate button & menu
                      CONTROL ENABLE CB.HNDL, %IDC_GENERATE
                      MENU SET STATE g_hMenu, BYCMD %IDM_RESOURCE_AmendSecurity, %MFS_ENABLED
                    END IF
                  END IF
                  '
                  ' load the data
                  funLoadData(CB.HNDL,strtxtTeamName)
                  g_lngDirtyFlag = %FALSE      ' set dirty flag to false - default nothing to save
                  '
                  ' store the team name
                  g_strTeamName = strtxtTeamName
                  '
                  ' determine if summary or detail file needed
                  CONTROL GET CHECK CB.HNDL, %IDC_OPTDetail TO lngResult
                  IF lngResult <> 0 THEN
                  ' detail html report requested
                    strURL = EXE.PATH$ & "Data\ResourceManager_" & strtxtTeamName & ".htm"
                  ELSE
                    strURL = EXE.PATH$ & "Data\ResourceManager_Summary_" & strtxtTeamName & ".htm"
                  END IF
                  '
                  ' launch the embedded browser control
                  vVar = strUrl
                  OBJECT CALL oOcx.Navigate(vVar)
                  '
                  CALL zSpinnerClose()  ' close the Gear wheels busy graphic
                  '
                END IF
              ELSE
              ' no file picked
                CALL zSpinnerClose()  ' close the Gear wheels busy graphic
              END IF
              '
            END IF
            ' */
          CASE %IDC_OPTDetail
          ' detail option picked
            IF CB.CTLMSG = %BN_CLICKED OR CB.CTLMSG = 1 THEN
              IF g_strTeamName <> "" THEN
                strURL = EXE.PATH$ & "Data\ResourceManager_" & _
                         g_strTeamName & ".htm"
                ' launch the embedded browser control
                vVar = strUrl
                OBJECT CALL oOcx.Navigate(vVar)
              ELSE
                CONTROL SET TEXT CB.HNDL, %IDC_STATUSBAR1, "Team not loaded yet"
              END IF
              '
            END IF
            '
          CASE %IDC_OPTSummary
          ' summary option picked
            IF CB.CTLMSG = %BN_CLICKED OR CB.CTLMSG = 1 THEN
              IF g_strTeamName <>"" THEN
                strURL = EXE.PATH$ & "Data\ResourceManager_Summary_" & _
                         g_strTeamName & ".htm"
                ' launch the embedded browser control
                vVar = strUrl
                OBJECT CALL oOcx.Navigate(vVar)
              ELSE
                CONTROL SET TEXT CB.HNDL, %IDC_STATUSBAR1, "Team not loaded yet"
              END IF
              '
            END IF
            '
          CASE %IDC_GENERATE
            IF CB.CTLMSG = %BN_CLICKED OR CB.CTLMSG = 1 THEN
            ' generate the html page
            ' get the screen values
              CONTROL SET TEXT CB.HNDL, %IDC_STATUSBAR1, "Saving Team data...."
              CONTROL GET TEXT CB.HNDL,%IDC_txtTeamName TO strtxtTeamName
              CONTROL GET TEXT CB.HNDL,%IDC_txtResource TO strtxtResource
              '
              ' first save the config date locally
              '
              ' display the gear wheels to indicate app is busy
              CALL zSpinnerInit(CB.HNDL, EXE.PATH$ & "SpinFolder\Gear01.ski", 0)
              '
              IF ISTRUE funSaveConfig(CB.HNDL,strtxtTeamName, strtxtResource) THEN
              ' save the config to disk
                IF ISTRUE funGeneratePage(CB.HNDL, strtxtTeamName, strtxtResource) THEN
                ' generate the HTML page
                  funLoadData(CB.HNDL,strtxtTeamName)
                  ' Recursive re-generate to pick up deleted resources
                  funGeneratePage(CB.HNDL, strtxtTeamName, strtxtResource)
                  funGenerateSummaryPage(CB.HNDL, strtxtTeamName, strtxtResource)
                  g_lngDirtyFlag = %FALSE      ' set dirty flag to false - default nothing to save
                  '
                  CONTROL GET CHECK CB.HNDL, %IDC_OPTDetail TO lngResult
                  IF lngResult <>0 THEN
                    strURL = EXE.PATH$ & "Data\ResourceManager_" & strtxtTeamName & ".htm"
                  ELSE
                    strURL = EXE.PATH$ & "Data\ResourceManager_Summary_" & strtxtTeamName & ".htm"
                  END IF
                  '
                  vVar = strUrl
                  OBJECT CALL oOcx.Navigate(vVar)
                  '
                  CONTROL SET TEXT CB.HNDL, %IDC_STATUSBAR1, "Team data saved"
                END IF
              END IF
              '
              CALL zSpinnerClose()  ' close the Gear wheels busy graphic
              '
            END IF
            ' */
          CASE %IDABORT
            IF CB.CTLMSG = %BN_CLICKED OR CB.CTLMSG = 1 THEN
              IF ISTRUE g_lngDirtyFlag AND ISTRUE g_lngFullAccess THEN
                lngResult = MSGBOX("Are you sure you wish to exit this application without saving?", _
                            %MB_YESNO OR %MB_TASKMODAL,"Exit Application?")
                IF lngResult = %IDYES THEN
                  DIALOG END CB.HNDL
                END IF
              ELSE
                DIALOG END CB.HNDL
              END IF
            END IF
        END SELECT
        '
    END SELECT
END FUNCTION
'------------------------------------------------------------------------------

'------------------------------------------------------------------------------
'   ** Dialogs **
'------------------------------------------------------------------------------
FUNCTION ShowDIALOG1(BYVAL hParent AS DWORD) AS LONG
    LOCAL lRslt AS LONG
    LOCAL lngR AS LONG
    LOCAL lngC AS LONG
    LOCAL lngD AS LONG
    LOCAL lngE AS LONG
    LOCAL lngF AS LONG
    LOCAL lngID AS LONG
    '
    LOCAL hInst AS DWORD
    LOCAL hr AS DWORD
    LOCAL OcxName AS ASCIIZ * 255
    LOCAL pUnk AS DWORD
    LOCAL vVar AS VARIANT
    LOCAL uMsg AS tagMsg
    LOCAL dwCookie AS DWORD
    LOCAL lngResult AS LONG
    LOCAL strValue AS STRING
    LOCAL lngRefresh AS LONG
    LOCAL lngCount AS LONG
    LOCAL z AS LONG
    LOCAL aTab  AS ASCIIZ * 255
    LOCAL strTasks AS STRING
    '
    LOCAL RC AS RowColDataType
    LOCAL mylist AS ASCIIZ * 256
    LOCAL sNumberformat AS SINGLE
    LOCAL lngCellColor AS LONG
    LOCAL strURL AS STRING
    '
    strTasks ="Set as Unallocated, Set to Task,Sort Column,Sort all Columns"

    OcxName = "Shell.Explorer"
    AtlAxWinInit   ' // Initializes ATL
    '
    MLG_Init  ' initialise the grid control
    '
#PBFORMS BEGIN DIALOG %IDD_DIALOG1->%IDR_MENU1->
    LOCAL hDlg   AS DWORD
    LOCAL hFont1 AS DWORD

    DIALOG NEW hParent, "Resource Management", 75, 64, 804, 434, %WS_POPUP OR _
        %WS_BORDER OR %WS_DLGFRAME OR %DS_CONTEXTHELP OR %WS_THICKFRAME OR _
        %WS_CAPTION OR %WS_SYSMENU OR %WS_MINIMIZEBOX OR %WS_MAXIMIZEBOX OR _
        %WS_CLIPSIBLINGS OR %WS_VISIBLE OR %DS_MODALFRAME OR _
        %DS_SETFOREGROUND OR %DS_CENTER OR %DS_3DLOOK OR %DS_NOFAILCREATE OR _
        %DS_SETFONT, %WS_EX_CONTROLPARENT OR %WS_EX_LEFT OR _
        %WS_EX_LTRREADING OR %WS_EX_RIGHTSCROLLBAR, TO hDlg
    CONTROL ADD BUTTON,    hDlg, %IDABORT, "Exit", 730, 385, 55, 15
    CONTROL ADD TEXTBOX,   hDlg, %IDC_txtTeamName, "TeamName", 10, 65, 100, _
        13
    CONTROL ADD TEXTBOX,   hDlg, %IDC_txtResource, "0 Resource units", 10, _
        80, 100, 13
    CONTROL ADD BUTTON,    hDlg, %IDC_GENERATE, "Save && Generate HTML", 10, _
        382, 125, 20, %BS_RIGHT OR %BS_VCENTER OR %BS_TEXT OR %WS_CHILD OR _
        %WS_VISIBLE, %WS_EX_LEFT OR %WS_EX_LTRREADING
    CONTROL ADD BUTTON,    hDlg, %IDC_LOADDATA, "Load Team Data", 10, 95, _
        125, 20
    CONTROL ADD STATUSBAR, hDlg, %IDC_STATUSBAR1, "", 0, 0, 0, 0
    CONTROL ADD TEXTBOX,   hDlg, %IDC_Task0, "Unallocated", 20, 150, 85, 13, _
        %WS_CHILD OR %WS_VISIBLE OR %ES_LEFT OR %ES_READONLY, _
        %WS_EX_CLIENTEDGE OR %WS_EX_LEFT OR %WS_EX_LTRREADING OR _
        %WS_EX_RIGHTSCROLLBAR
    CONTROL ADD IMAGE,     hDlg, %IDC_staff, "#" + FORMAT$(%IDR_IMGFILE1), _
        90, 18, 32, 30, %WS_CHILD OR %WS_VISIBLE OR %SS_ICON OR %SS_NOTIFY
    CONTROL ADD LABEL,     hDlg, %IDC_TaskLabel, "Tasks", 20, 135, 100, 10, _
        %WS_CHILD OR %WS_VISIBLE OR %SS_LEFT OR %SS_NOTIFY, %WS_EX_LEFT OR _
        %WS_EX_LTRREADING
    CONTROL SET COLOR      hDlg, %IDC_TaskLabel, %BLUE, -1
    CONTROL ADD CHECKBOX,  hDlg, %IDC_Tick0, "", 110, 152, 20, 10
    CONTROL ADD LABEL,     hDlg, %IDC_LABEL2, "Team Details", 10, 53, 100, 10
    CONTROL SET COLOR      hDlg, %IDC_LABEL2, %BLUE, -1
    CONTROL ADD IMAGE,     hDlg, %IDC_IMGNHS, "#" + FORMAT$(%IDR_IMGFILE2), _
        11, 10, 77, 36
    CONTROL ADD IMAGE,     hDlg, %IDC_IMG_load, "#" + FORMAT$(%IDR_IMGFILE3), _
        125, 170, 21, 20, %WS_CHILD OR %WS_VISIBLE OR %SS_ICON
    CONTROL ADD IMAGE,     hDlg, %IDC_IMG_save, "#" + FORMAT$(%IDR_IMGFILE4), _
        125, 190, 21, 19, %WS_CHILD OR %WS_VISIBLE OR %SS_ICON
    CONTROL ADD IMAGE,     hDlg, %IDC_IMG_Exit, "#" + FORMAT$(%IDR_IMGFILE5), _
        125, 210, 11, 10, %WS_CHILD OR %WS_VISIBLE OR %SS_ICON
    CONTROL ADD IMAGE,     hDlg, %IDC_IMGOK, "#" + FORMAT$(%IDR_IMGFILE6), _
        125, 220, 20, 20, %WS_CHILD OR %WS_VISIBLE OR %SS_ICON OR _
        %SS_CENTERIMAGE
    CONTROL ADD IMAGE,     hDlg, %IDC_IMGDB, "#" + FORMAT$(%IDR_IMGFILE7), _
        125, 245, 30, 25, %WS_CHILD OR %WS_VISIBLE OR %SS_ICON OR _
        %SS_CENTERIMAGE

    CONTROL ADD OPTION,    hDlg, %IDC_OPTDetail,"Detail",140,182,50,14

    CONTROL ADD OPTION,    hDlg, %IDC_OPTSummary,"Summary",200,182,50,14

    FONT NEW "MS Sans Serif", 12, 0, %ANSI_CHARSET TO hFont1

    CONTROL SET FONT hDlg, %IDC_TaskLabel, hFont1
    CONTROL SET FONT hDlg, %IDC_LABEL2, hFont1

    AttachMENU1 hDlg
#PBFORMS END DIALOG
    ' add graphics to buttons
    ButtonPlus hDlg, %IDABORT, %BP_TEXT_COLOR, %RED
    ButtonPlus hDlg, %IDABORT, %BP_ICON_ID, %IDR_IMGFILE5
    ButtonPlus hDlg, %IDABORT, %BP_ICON_WIDTH, 16
    ButtonPlus hDlg, %IDABORT, %BP_ICON_POS, %BS_LEFT
    '
    ButtonPlus hDlg, %IDC_GENERATE, %BP_TEXT_COLOR, %RED
    ButtonPlus hDlg, %IDC_GENERATE, %BP_ICON_ID, %IDR_IMGFILE4
    ButtonPlus hDlg, %IDC_GENERATE, %BP_ICON_WIDTH, 32
    ButtonPlus hDlg, %IDC_GENERATE, %BP_ICON_POS, %BS_LEFT
    '
    ButtonPlus hDlg, %IDC_LOADDATA, %BP_TEXT_COLOR, %RED
    ButtonPlus hDlg, %IDC_LOADDATA, %BP_ICON_ID, %IDR_IMGFILE3
    ButtonPlus hDlg, %IDC_LOADDATA, %BP_ICON_WIDTH, 32
    ButtonPlus hDlg, %IDC_LOADDATA, %BP_ICON_POS, %BS_LEFT

    ' hide icons
    CONTROL SHOW STATE hDlg, %IDC_IMG_load, %SW_HIDE
    CONTROL SHOW STATE hDlg, %IDC_IMG_save, %SW_HIDE
    CONTROL SHOW STATE hDlg, %IDC_IMG_Exit, %SW_HIDE
    CONTROL SHOW STATE hDlg, %IDC_IMGOK, %SW_HIDE
    CONTROL SHOW STATE hDlg, %IDC_IMGDB, %SW_HIDE
    '
    ' add the extra txt & check boxes
    CONTROL SET COLOR      hDlg, %IDC_Task0 ,-1, a_lngTaskColours(0)
    FOR lngR = 1 TO %MAX_TASKS
      CONTROL ADD CHECKBOX,  hDlg, %IDC_Tick0 + lngR, "", 110, 152 + (lngR*15), 20, 10
      CONTROL ADD TEXTBOX,   hDlg, %IDC_Task0 + lngR, "", 20, 150 + (lngR*15), 85, 13
      CONTROL SET COLOR      hDlg, %IDC_Task0 + lngR, -1, a_lngTaskColours(lngR)
    NEXT lngR
    '
    CONTROL SET CHECK hDlg, %IDC_Tick0,1
    'Switches
    'e3 means tell MLG to auto append a row if needed providing something is in the cell
    'r50 calls for 50 rows total
    'c8 calls for 8 columns
    'b3 means block selecting of rows, columns, and the entire grid is activated
    'm1 active the right click menu with the following comma delimited menu items

    CONTROL ADD "MYLITTLEGRID", hDlg, %IDC_MLGGRID1, _
          "x20,180,140,140,140,140,140,140/d-0/e1/r" & _
          FORMAT$(glngGridRows) & "/c6/a2/b3/y3/m1" & strTasks, _
          140, 10, 640, 158, %MLG_STYLE
    CONTROL HANDLE hDlg, %IDC_MLGGRID1 TO hGrid1
    ' set cell for licence
    SendMessage hGrid1,%MLG_SETCELL,0,0
    '
    SendMessage hGrid1, %MLG_SETHEADERCOLOR , %LTGRAY,0
    '
    ' add the embedded browser control
    CONTROL ADD "AtlAxWin", hDlg, %ID_OCX, OcxName, 140, 200, 640, 180, _
                            %WS_VISIBLE OR %WS_CHILD
    CONTROL HANDLE hDlg, %ID_OCX TO hOcx
    '
    AtlAxGetControl(hOcx, pUnk)
    AtlMakeDispatch(pUnk, vVar)
    SET oOcx = vVar
    '
    strURL = EXE.PATH$ & "Data\ResourceManager_Blank.htm"
    ' launch the embedded browser control
    vVar = strUrl  ' with the URL
    OBJECT CALL oOcx.Navigate(vVar)
    '
    ' finish up on the grid
    FOR lngCount = 1 TO 5
    ' add the worksheets
      z=SendMessage(hGrid1, %MLG_ADDSHEET, 0,0)
      IF z=0 THEN EXIT FOR
    NEXT lngCount
    ' store the ids of the work sheets
    sheetIDM1=SendMessage(hGrid1, %MLG_GETSHEETINFO, %MLG_SHEET_GETID,1)
    sheetIDM2=SendMessage(hGrid1, %MLG_GETSHEETINFO, %MLG_SHEET_GETID,2)
    sheetIDM3=SendMessage(hGrid1, %MLG_GETSHEETINFO, %MLG_SHEET_GETID,3)
    sheetIDM4=SendMessage(hGrid1, %MLG_GETSHEETINFO, %MLG_SHEET_GETID,4)
    sheetIDM5=SendMessage(hGrid1, %MLG_GETSHEETINFO, %MLG_SHEET_GETID,5)
    sheetIDM6=SendMessage(hGrid1, %MLG_GETSHEETINFO, %MLG_SHEET_GETID,6)

    ' name each work sheet
    FOR lngR = 1 TO 6
      aTab =  funGetMonth(lngR)
      SendMessage hGrid1, %MLG_NAMESHEET , lngR,VARPTR(aTab)
    NEXT lngR
    '
    ' display the tabs
    SendMessage hGrid1, %MLG_SHOWSHEETTABS,800,0
    '
    ' select the first tab
    SendMessage hGrid1, %MLG_SELECTSHEET, 1,0
    '
    LOCAL fo AS FormatOverride
    '
    FOR lngC = 1 TO 6
      SendMessage hGrid1, %MLG_SELECTSHEET, lngC,0
      '
      SendMessage hGrid1 ,%MLG_CREATEFORMATOVERRIDE,12,6 'set up a 12 row by 5 column array
      '
      MLG_FormatColEdit hGrid1,1,%MLG_NULL,%MLG_NULL,%MLG_JUST_CENTER,%BLUE, %MLG_LOCK
      MLG_FormatColNumber hGrid1,2,sNumberformat,%MLG_JUST_CENTER,%BLUE,%MLG_LOCK
      '
      ' lock the 3rd to 6th columns
      FOR lngCount=3 TO 6
        MLG_FormatColEdit hGrid1,lngCount,%MLG_NULL,%MLG_NULL,%MLG_JUST_CENTER,%BLUE,%MLG_LOCK
      NEXT lngcounter
      '
      ' populate the titles of each column in the grid
      MLG_Put hGrid1,0,1,"Team Resource " & funGetMonth(lngC) ,lngRefresh
      MLG_Put hGrid1,0,2,"Head Count",lngRefresh
      MLG_Put hGrid1,0,3,"Week 1",lngRefresh
      MLG_Put hGrid1,0,4,"Week 2",lngRefresh
      MLG_Put hGrid1,0,5,"Week 3",lngRefresh
      MLG_Put hGrid1,0,6,"Week 4",lngRefresh
      '
      ' set override slots for grey colours on name
      SendMessage hGrid1,%MLG_SETBKGNDCELLCOLOR,2, %RGB_SILVER
      SendMessage hGrid1,%MLG_SETBKGNDCELLCOLOR,3, %RGB_GAINSBORO
      '
      ' handle the setting up of the new color slots
      FOR lngE = 4 TO 15
        SendMessage hGrid1,%MLG_SETBKGNDCELLCOLOR,lngE, a_lngTaskColours(lngE-4)
      NEXT lngE
      '
      FOR lngE = 2 TO glngGridRows
        FOR lngF = 1 TO 2
        ' handle user columns
          IF lngE<=6 THEN
            lngCellColor=2
          ELSE
            lngCellColor=3
          END IF
          fo.CellFont=1
          MLG_Put hGrid1,lngE,lngF,"",0
          SendMessage hGrid1 ,%MLG_SETFORMATOVERRIDEEX, _
                              MAKLNG(lngE,lngF), _
                              MAKLNG(%MLG_TYPE_BKGCOLOR,lngCellColor)
        '
        NEXT lngF
        '
        FOR lngF = 3 TO 6
        ' handle data columns
          '%GREEN
          lngCellColor = 4
          fo.CellFont=1
          'Set text in cell
          MLG_Put hGrid1,lngE,lngF,"Unallocated",0
          SendMessage hGrid1 ,%MLG_SETFORMATOVERRIDEEX, _
                              MAKLNG(lngE,lngF), _
                              MAKLNG(%MLG_TYPE_BKGCOLOR,lngCellColor)
        NEXT lngF
      NEXT lngE
      '
    NEXT lngC
    '
    ' ensure first worksheet is selected and visible
    SendMessage hGrid1, %MLG_SELECTSHEET, 1,0
    ' set idon on dialog
    DIALOG SET ICON hDlg, "#" & FORMAT$(%IDR_IMGFILE1)
    ' show the dialog to user
    DIALOG SHOW MODAL hDlg, CALL ShowDIALOG1Proc TO lRslt
    '
#PBFORMS BEGIN CLEANUP %IDD_DIALOG1
    FONT END hFont1
#PBFORMS END CLEANUP
    '
    FUNCTION = lRslt
END FUNCTION
'------------------------------------------------------------------------------
FUNCTION funGetMonth(lngR AS LONG) AS STRING
' get the month name where lngR is 1-6
  '
  FUNCTION = " " & PARSE$(g_strMonths,"|", lngR) & " "
  '
END FUNCTION
'
FUNCTION funGenerateMonths() AS LONG
  LOCAL lngR AS LONG
  LOCAL strMonth AS STRING
  LOCAL lngMonth AS LONG
  LOCAL lngYear AS LONG
  LOCAL lngC AS LONG
  '
  g_strMonths = ""
  lngMonth = VAL(MID$(funUKDate(),4,2)) - 1
  lngYear = VAL(RIGHT$(funUKDate(),4))
  '
  FOR lngR = 1 TO 6
    INCR lngMonth
    IF lngMonth = 13 THEN
      lngMonth = 1
      INCR lngYear
    END IF
    g_strMonths = g_strMonths & funShortMonthName(FORMAT$(lngMonth)) & " " & FORMAT$(lngYear) & "|"
  NEXT lngR
  g_strMonths = RTRIM$(g_strMonths,"|")
  FUNCTION = %TRUE
  '
END FUNCTION
'
FUNCTION funGenerateSummaryPage((hDlg AS DWORD, strtxtTeamName AS STRING, strtxtResource AS STRING) AS LONG
' generate the html page
  LOCAL strHTML AS STRING
  LOCAL lngR AS LONG
  LOCAL lngC AS LONG
  LOCAL lngFile AS LONG
  LOCAL strLocalTeamname AS STRING
  LOCAL strData AS STRING
  DIM a_strGrid1(1 TO glngGridRows+2,1 TO 6) AS STRING  ' one array for each of the six months
  DIM a_strGrid2(1 TO glngGridRows+2,1 TO 6) AS STRING
  DIM a_strGrid3(1 TO glngGridRows+2,1 TO 6) AS STRING
  DIM a_strGrid4(1 TO glngGridRows+2,1 TO 6) AS STRING
  DIM a_strGrid5(1 TO glngGridRows+2,1 TO 6) AS STRING
  DIM a_strGrid6(1 TO glngGridRows+2,1 TO 6) AS STRING
  LOCAL lngSheet AS LONG
  LOCAL strColour AS STRING
  LOCAL lngCount AS LONG
  LOCAL strUserColour AS STRING
  LOCAL strUsername AS STRING
  '
  strLocalTeamname = strtxtTeamName
  ' remove the underscores
  REPLACE "_" WITH " " IN strLocalTeamname
  '
  strHTML = BUILD$("<!DOCTYPE HTML PUBLIC ""-//W3C//DTD HTML 4.0 Transitional//EN"">" , _
            "<html>" , _
            "<head>" , _
            "<title> Release Log Web site </title>" , _
            "</head>", _
            "<body bgcolor=""#C0C0C0"">")
            '
  strHTML = BUILD$(strHTML,"<table width=""100%"" cellspacing=""0"" cellpadding=""5"" border=1 bordercolor=black>", _
            "<tr>", _
            "<td rowspan=2>Team Resource</td>", _
            "<td rowspan=2>Name</td>", _
            "<td rowspan=2>Head<br>Count</td>")

            ' handle the month names - starting with this one
  FOR lngR = 1 TO 6
    strHTML = strHTML & "<td colspan=4>" & PARSE$(g_strMonths,"|",lngR) & "</td>" & $CRLF
  NEXT lngR
  '
  strHTML = strHTML & "</tr>" & $CRLF
  '
  FOR lngR = 1 TO 6
    strHTML = strHTML & "<td>1</td><td>2</td><td>3</td><td>4</td>" & $CRLF
  NEXT lngR
  strHTML = strHTML & "</tr>" & $CRLF
  '
  strHTML = strHTML & "<tr><td rowspan=" & FORMAT$(glngGridRows) & ">" & strLocalTeamname & "<BR> " & strtxtResource & "</td>"
  '
  ' draw the months
  ' first get the 6 arrays from the grid
  ' for each sheet - first select the sheet
    SendMessage(hGrid1, %MLG_SELECTSHEET, 1,0)
    MLG_GetEx hGrid1,a_strGrid1()
    '
    SendMessage(hGrid1, %MLG_SELECTSHEET, 2,0)
    MLG_GetEx hGrid1,a_strGrid2()
    '
    SendMessage(hGrid1, %MLG_SELECTSHEET, 3,0)
    MLG_GetEx hGrid1,a_strGrid3()
    '
    SendMessage(hGrid1, %MLG_SELECTSHEET, 4,0)
    MLG_GetEx hGrid1,a_strGrid4()
    '
    SendMessage(hGrid1, %MLG_SELECTSHEET, 5,0)
    MLG_GetEx hGrid1,a_strGrid5()
    '
    SendMessage(hGrid1, %MLG_SELECTSHEET, 6,0)
    MLG_GetEx hGrid1,a_strGrid6()
    ' draw the four quarters of each month
    ' first month
    lngCount = 0     ' set line counter
    strUserColour = "#B2B2B2"
    '
    FOR lngR = 2 TO glngGridRows
    ' for rows 2 to 11 (for 2 resources)
      INCR lngCount  ' advance line counter
      '
      ' do we need this data?
      IF strUsername = a_strGrid1(lngR,1) THEN
        ITERATE FOR ' skip till next user
      ELSE
      ' store the users name - so this data is the first of 5 lines of data
      ' for this user - so print a summary line only
        strUserName = a_strGrid1(lngR,1)
      END IF
      '
      IF lngCount = 6 THEN
        lngCount =1
        IF strUserColour = "#DADADA" THEN
          strUserColour = "#B2B2B2"
        ELSE
          strUserColour = "#DADADA"
        END IF
      END IF
      '
      strHTML = strHTML & "<tr>"
      ' get name
      strHTML = strHTML & "<td height=10 bgcolor=" & $DQ & strUserColour &$DQ & ">" & a_strGrid1(lngR,1) & "</td>"
      ' get head count
      strHTML = strHTML & "<td height=10 bgcolor=" & $DQ & strUserColour &$DQ & ">" & a_strGrid1(lngR,2) & "</td>"

      ' draw the boxes for each month
      ' first month
      FOR lngC = 3 TO 6
      ' for columns 3 to 6
        strColour = funGetTheSummaryColourFromTask(hDlg,BYREF a_strGrid1(),lngR,lngC)
        strHTML = strHTML & "<td height=10 bgcolor=" & $DQ & strColour & $DQ & "><br></td>"
      NEXT lngC
      '
      ' 2nd month
      FOR lngC = 3 TO 6
      ' for columns 3 to 6
        strColour = funGetTheSummaryColourFromTask(hDlg,BYREF a_strGrid2(),lngR,lngC)
        strHTML = strHTML & "<td height=10 bgcolor=" & $DQ & strColour & $DQ & "><br></td>"
      NEXT lngC
      '
      ' 3rd month
      FOR lngC = 3 TO 6
      ' for columns 3 to 6
        strColour = funGetTheSummaryColourFromTask(hDlg,BYREF a_strGrid3(),lngR,lngC)
        strHTML = strHTML & "<td height=10 bgcolor=" & $DQ & strColour & $DQ & "><br></td>"
      NEXT lngC
      '
      ' 4th month
      FOR lngC = 3 TO 6
      ' for columns 3 to 6
        strColour = funGetTheSummaryColourFromTask(hDlg,BYREF a_strGrid4(),lngR,lngC)
        strHTML = strHTML & "<td height=10 bgcolor=" & $DQ & strColour & $DQ & "><br></td>"
      NEXT lngC
      '
      ' 5th month
      FOR lngC = 3 TO 6
      ' for columns 3 to 6
        strColour = funGetTheSummaryColourFromTask(hDlg,BYREF a_strGrid5(),lngR,lngC)
        strHTML = strHTML & "<td height=10 bgcolor=" & $DQ & strColour & $DQ & "><br></td>"
      NEXT lngC
      '
      ' 6th month
      FOR lngC = 3 TO 6
      ' for columns 3 to 6
        strColour = funGetTheSummaryColourFromTask(hDlg,BYREF a_strGrid6(),lngR,lngC)
        strHTML = strHTML & "<td height=15 bgcolor=" & $DQ & strColour & $DQ & "><br></td>"
      NEXT lngC
      strHTML = strHTML & "</tr>" & $CRLF
    NEXT lngR
    '
    ' put back to original worksheet
    SendMessage(hGrid1, %MLG_SELECTSHEET, 1,0)
    strHTML = strHTML & "</table>" & $CRLF
    '
  ' now draw the key
  strHTML = strHTML & "<table><tr><td><B>KEY</B></td></tr>
  ' tasks

  strHTML = strHTML & "<tr><td bgcolor=" & $DQ & funGetHTMLColour(0) & $DQ & " >Unallocated</td></tr>" & $CRLF
  strHTML = strHTML & "<tr><td bgcolor=" & $DQ & funGetHTMLColour(3) & $DQ & " >Allocated</td></tr>" & $CRLF
  strHTML = strHTML & "</body></html>"
  '
  REPLACE " " WITH "_" IN strtxtTeamName
  SendStringToDiskAtLocation(strHTML, EXE.PATH$ & "Data\ResourceManager_Summary_" & strtxtTeamName & ".htm")
  '
  FUNCTION = %TRUE
  '
END FUNCTION
'
FUNCTION funGeneratePage(hDlg AS DWORD, strtxtTeamName AS STRING, strtxtResource AS STRING) AS LONG
' generate the html page
  LOCAL strHTML AS STRING
  LOCAL lngR AS LONG
  LOCAL lngC AS LONG
  LOCAL lngFile AS LONG
  LOCAL strLocalTeamname AS STRING
  LOCAL strData AS STRING
  DIM a_strGrid1(1 TO glngGridRows+2,1 TO 6) AS STRING  ' one array for each of the six months
  DIM a_strGrid2(1 TO glngGridRows+2,1 TO 6)  AS STRING
  DIM a_strGrid3(1 TO glngGridRows+2,1 TO 6) AS STRING
  DIM a_strGrid4(1 TO glngGridRows+2,1 TO 6) AS STRING
  DIM a_strGrid5(1 TO glngGridRows+2,1 TO 6) AS STRING
  DIM a_strGrid6(1 TO glngGridRows+2,1 TO 6) AS STRING
  LOCAL lngSheet AS LONG
  LOCAL strColour AS STRING
  LOCAL lngCount AS LONG
  LOCAL strUserColour AS STRING
  '
  strLocalTeamname = strtxtTeamName
  ' remove the underscores
  REPLACE "_" WITH " " IN strLocalTeamname
  '
  strHTML = BUILD$("<!DOCTYPE HTML PUBLIC ""-//W3C//DTD HTML 4.0 Transitional//EN"">" , _
            "<html>" , _
            "<head>" , _
            "<title> Release Log Web site </title>" , _
            "</head>", _
            "<body bgcolor=""#C0C0C0"">")
            '
  strHTML = BUILD$(strHTML,"<table width=""100%"" cellspacing=""0"" cellpadding=""5"" border=1 bordercolor=black>", _
            "<tr>", _
            "<td rowspan=2>Team Resource</td>", _
            "<td rowspan=2>Name</td>", _
            "<td rowspan=2>Head<br>Count</td>")

            ' handle the month names - starting with this one
  FOR lngR = 1 TO 6
    strHTML = strHTML & "<td colspan=4>" & PARSE$(g_strMonths,"|",lngR) & "</td>" & $CRLF
  NEXT lngR
  '
  strHTML = strHTML & "</tr>" & $CRLF
  '
  FOR lngR = 1 TO 6
    strHTML = strHTML & "<td>1</td><td>2</td><td>3</td><td>4</td>" & $CRLF
  NEXT lngR
  strHTML = strHTML & "</tr>" & $CRLF
  '
  strHTML = strHTML & "<tr><td rowspan=" & FORMAT$(glngGridRows) & ">" & strLocalTeamname & "<BR> " & strtxtResource & "</td>"
  '
  ' draw the months
  ' first get the 6 arrays from the grid
  ' for each sheet - first select the sheet
    SendMessage(hGrid1, %MLG_SELECTSHEET, 1,0)
    MLG_GetEx hGrid1,a_strGrid1()
    '
    SendMessage(hGrid1, %MLG_SELECTSHEET, 2,0)
    MLG_GetEx hGrid1,a_strGrid2()
    '
    SendMessage(hGrid1, %MLG_SELECTSHEET, 3,0)
    MLG_GetEx hGrid1,a_strGrid3()
    '
    SendMessage(hGrid1, %MLG_SELECTSHEET, 4,0)
    MLG_GetEx hGrid1,a_strGrid4()
    '
    SendMessage(hGrid1, %MLG_SELECTSHEET, 5,0)
    MLG_GetEx hGrid1,a_strGrid5()
    '
    SendMessage(hGrid1, %MLG_SELECTSHEET, 6,0)
    MLG_GetEx hGrid1,a_strGrid6()
    ' draw the four quarters of each month
    ' first month
    lngCount = 0     ' set line counter
    strUserColour = "#B2B2B2"
    '
    FOR lngR = 2 TO glngGridRows
    ' for rows 2 to 11
      INCR lngCount  ' advance line counter
      IF lngCount = 6 THEN
        lngCount =1
        IF strUserColour = "#DADADA" THEN
          strUserColour = "#B2B2B2"
        ELSE
          strUserColour = "#DADADA"
        END IF
      END IF
      '
      strHTML = strHTML & "<tr>"
      ' get name
      strHTML = strHTML & "<td height=10 bgcolor=" & $DQ & strUserColour &$DQ & ">" & a_strGrid1(lngR,1) & "</td>"
      ' get head count
      strHTML = strHTML & "<td height=10 bgcolor=" & $DQ & strUserColour &$DQ & ">" & a_strGrid1(lngR,2) & "</td>"
      ' first month
      FOR lngC = 3 TO 6
      ' for columns 3 to 6
        strColour = funGetTheHTMLColourFromTask(hDlg,a_strGrid1(lngR,lngC))
        strHTML = strHTML & "<td height=10 bgcolor=" & $DQ & strColour & $DQ & "><br></td>"
      NEXT lngC
      ' 2nd month
      FOR lngC = 3 TO 6
      ' for columns 3 to 6
        strColour = funGetTheHTMLColourFromTask(hDlg,a_strGrid2(lngR,lngC))
        strHTML = strHTML & "<td height=10 bgcolor=" & $DQ & strColour & $DQ & "><br></td>"
      NEXT lngC
      '
      ' 3rd month
      FOR lngC = 3 TO 6
      ' for columns 3 to 6
        strColour = funGetTheHTMLColourFromTask(hDlg,a_strGrid3(lngR,lngC))
        strHTML = strHTML & "<td height=10 bgcolor=" & $DQ & strColour & $DQ & "><br></td>"
      NEXT lngC
      '
      ' 4th month
      FOR lngC = 3 TO 6
      ' for columns 3 to 6
        strColour = funGetTheHTMLColourFromTask(hDlg,a_strGrid4(lngR,lngC))
        strHTML = strHTML & "<td height=10 bgcolor=" & $DQ & strColour & $DQ & "><br></td>"
      NEXT lngC
      '
      ' 5th month
      FOR lngC = 3 TO 6
      ' for columns 3 to 6
        strColour = funGetTheHTMLColourFromTask(hDlg,a_strGrid5(lngR,lngC))
        strHTML = strHTML & "<td height=10 bgcolor=" & $DQ & strColour & $DQ & "><br></td>"
      NEXT lngC
      '
      ' 6th month
      FOR lngC = 3 TO 6
      ' for columns 3 to 6
        strColour = funGetTheHTMLColourFromTask(hDlg,a_strGrid6(lngR,lngC))
        strHTML = strHTML & "<td height=15 bgcolor=" & $DQ & strColour & $DQ & "><br></td>"
      NEXT lngC
      strHTML = strHTML & "</tr>" & $CRLF
    NEXT lngR
    '
    ' put back to original worksheet
    SendMessage(hGrid1, %MLG_SELECTSHEET, 1,0)
    strHTML = strHTML & "</table>" & $CRLF
    '
  ' now draw the key
  strHTML = strHTML & "<table><tr><td><B>KEY</B></td></tr>
  ' tasks
  FOR lngR = %IDC_Task0 TO %IDC_Task0 + %MAX_TASKS
    CONTROL GET TEXT hDlg, lngR TO strData
    IF strData <> "" THEN
    ' ignore blank task names
      strHTML = strHTML & "<tr><td bgcolor=" & $DQ & funGetHTMLColour(lngR - %IDC_Task0) & $DQ & " >" & strData & "</td></tr>" & $CRLF
    END IF
  NEXT lngR
  strHTML = strHTML & "</body></html>"
  '
  REPLACE " " WITH "_" IN strtxtTeamName
  SendStringToDiskAtLocation(strHTML, EXE.PATH$ & "Data\ResourceManager_" & strtxtTeamName & ".htm")
  '
  FUNCTION = %TRUE
  '
END FUNCTION
'
FUNCTION funLoadData(hDlg AS DWORD, BYVAL strTeamName AS STRING) AS LONG
' load the data
  LOCAL lngFile AS LONG
  LOCAL strDates AS STRING
  LOCAL strData AS STRING
  LOCAL lngR AS LONG
  LOCAL lngC AS LONG
  LOCAL lngD AS LONG
  LOCAL strFirstMonth AS STRING
  LOCAL strTeamData AS STRING
  DIM a_strTasks(%MAX_TASKS) AS STRING
  LOCAL lngSheet AS LONG
  LOCAL strTemp AS STRING
  LOCAL strShortTemp AS STRING
  DIM a_strGrid(1 TO 1,1 TO 6) AS STRING
  DIM a_strNames(1 TO 1) AS STRING            ' used to hold names
  DIM a_strHeadCount(1 TO 1) AS STRING        ' used to hold headcount
  LOCAL lngMonthsToDelete AS LONG             ' used to the months to remove because the data is old
  LOCAL lngMonthDeleted AS LONG               ' boolean flag for recording data deleted
  LOCAL lngSheetCount AS LONG
  LOCAL lngTotalMonths AS LONG
  LOCAL strGlobalMonth AS STRING
  LOCAL strLocalMonth AS STRING
  LOCAL strFile AS STRING
  LOCAL lngCellColor AS LONG
  LOCAL lngCount AS LONG
  LOCAL lngTemp AS LONG
  LOCAL lngTotalMonthsToDelete AS LONG        ' number if months deleted
  '
  LOCAL fo AS FormatOverride
  '
  lngFile = FREEFILE
  strFile = EXE.PATH$ & "Data\" & strTeamName & ".dat"
  '
  ' first work out how many resource units or on sheet
  OPEN strFile FOR INPUT AS #lngFile
  ' read past the basic data
    LINE INPUT #lngFile,strTeamData
    LINE INPUT #lngFile,strDates
    FOR lngR = 0 TO %MAX_TASKS
      LINE INPUT #lngFile,a_strTasks(lngR)
    NEXT lngR
    '
    ' now count the resource units
    lngCount = 0
    WHILE ISFALSE EOF(#lngFile)
      LINE INPUT #lngFile,strTemp
      IF LEFT$(strTemp,3) = "#1*" THEN
        INCR lngCount
      END IF
    WEND
    '
  CLOSE #lngFile
  '
  glngGridRows = lngCount
  '
  ' redim the arrays
  REDIM a_strGrid(1 TO glngGridRows,1 TO 6) AS STRING
  REDIM a_strNames(1 TO glngGridRows) AS STRING
  REDIM a_strHeadCount( 1 TO glngGridRows) AS STRING
  '
  ' redim the grid
  FOR lngCount = 1 TO 6
  ' select the work sheet
    SendMessage hGrid1, %MLG_SELECTSHEET, lngCount,0
    MLG_ArrayRedim(hGrid1, glngGridRows , 6, glngGridRows, 6)
  NEXT lngCount
  '
  lngFile = FREEFILE
  OPEN strFile FOR INPUT AS #lngFile
    LINE INPUT #lngFile,strTeamData
    LINE INPUT #lngFile,strDates
    FOR lngR = 0 TO %MAX_TASKS
      LINE INPUT #lngFile,a_strTasks(lngR)
    NEXT lngR
    '
    CONTROL SET TEXT hDlg,%IDC_txtTeamName,PARSE$(strTeamData,"|",1)
    CONTROL SET TEXT hDlg,%IDC_txtResource,PARSE$(strTeamData,"|",2)
    '
    ' update the task list
    FOR lngR = %IDC_Task0 TO %IDC_Task0 + %MAX_TASKS
      CONTROL SET TEXT hDlg,lngR,a_strTasks(lngR - %IDC_Task0)
    NEXT lngR
    '
    lngTotalMonths = PARSECOUNT(strDates,"|")
    ' now check the dates
    IF strDates <> g_strMonths THEN
    ' stored dates do not match the actual dates
      strGlobalMonth = PARSE$(g_strMonths,"|",1)
      '
      FOR lngMonthsToDelete = 1 TO lngTotalMonths
      ' so find the start date
        strLocalMonth = PARSE$(strDates,"|",lngMonthsToDelete)
        '
        IF strLocalMonth = strGlobalMonth THEN
        ' match found so stop here
          EXIT FOR
        END IF
      NEXT lngMonthsToDelete
      '
      ' reduce count by 1 to have number of months to remove from display
      DECR lngMonthsToDelete
    '
    END IF
    '
    IF lngMonthsToDelete>0 THEN
    ' at least one month to delete so set the Dirty Flag
    ' to force a save to be performed
      g_lngDirtyFlag = %TRUE
      lngTotalMonthsToDelete = lngMonthsToDelete
      lngMonthDeleted = %TRUE
    ELSE
      lngMonthDeleted = %FALSE
    END IF
    '
    ' now handle the worksheets
    FOR lngSheet = 1 TO 6

      IF lngMonthsToDelete > 0 THEN
        ' there is at least one month to ignore
        ' so dont write to workbook
        FOR lngR = 1 TO glngGridRows
        ' read in data and ignore it
          LINE INPUT #lngFile,strTemp
          ' store staff names
          strTemp = MID$(strTemp,4) ' cut of sheet prefix
          strShortTemp = PARSE$(strTemp,"|",1)
          a_strNames(lngR) = strShortTemp  ' store the name
          a_strHeadCount(lngR) = PARSE$(strTemp,"|",2) ' store the headcount
        NEXT lngR
        DECR lngMonthsToDelete
        ITERATE FOR
      ELSE
      ' everything up to date
        INCR lngSheetCount
        ' set the workbook to write to
        SendMessage(hGrid1, %MLG_SELECTSHEET, lngSheetCount,0)
      END IF
      '
      FOR lngR = 1 TO glngGridRows
        LINE INPUT #lngFile,strTemp
        '
        strTemp = MID$(strTemp,4) ' cut of sheet prefix
        FOR lngC = 1 TO 6
          strShortTemp = PARSE$(strTemp,"|",lngC)
          SELECT CASE lngC
            CASE 1
            ' handle first column
              IF lngSheet = 1 THEN
              ' for first sheet
                a_strGrid(lngR,lngC) = strShortTemp
                a_strNames(lngR) = strShortTemp  ' store the name
              ELSE
              ' for all other sheets
                a_strGrid(lngR,lngC) = a_strNames(lngR)  ' use the stored name
              END IF
              '
              IF lngR > 1 THEN
              ' handle background colours only for rows after row 1
              ' work out the background colour
                lngTemp = lngR +5 -2
                lngTemp = lngTemp \ 5
                lngTemp = lngTemp MOD 2
                SELECT CASE lngTemp
                  CASE 0
                  ' even number line - so make light grey
                    lngCellColor = 3
                  CASE ELSE
                  ' odd number line - so make dark grey
                    lngCellColor = 2
                  END SELECT
                  SendMessage hGrid1 ,%MLG_SETFORMATOVERRIDEEX,MAKLNG(lngR,lngC), _
                                       MAKLNG(%MLG_TYPE_BKGCOLOR,lngCellColor)
                  SendMessage hGrid1 ,%MLG_SETFORMATOVERRIDEEX,MAKLNG(lngR,lngC+1), _
                                       MAKLNG(%MLG_TYPE_BKGCOLOR,lngCellColor)
              END IF
              '
            CASE ELSE
            ' handle all other columns
              a_strGrid(lngR,lngC) = strShortTemp
          END SELECT
          '
          IF lngC > 2 AND lngR>1 THEN
          ' handle everything after 2nd column
            lngCellColor = funGetTheColourFromTask(hDlg, strShortTemp)
            SendMessage hGrid1 ,%MLG_SETFORMATOVERRIDEEX,MAKLNG(lngR,lngC), _
                        MAKLNG(%MLG_TYPE_BKGCOLOR,lngCellColor)
          END IF
          '
        NEXT lngC
      NEXT lngR
      '
      ' put the data on the worksheet
      MLG_PutEx (hGrid1,a_strGrid(),4,0)
      '
    NEXT lngSheet
    '
    ' have we deleted one or more months?
    IF ISTRUE lngMonthDeleted THEN
    ' at least one month has been deleted
      FOR lngR = 1 TO lngTotalMonthsToDelete
      ' work out which sheet we are on
        lngSheet = 6 - lngR +1
        SendMessage(hGrid1, %MLG_SELECTSHEET, lngSheet,0)
        RESET a_strGrid()
        FOR lngC = 1 TO glngGridRows
        ' set the names
          a_strGrid(lngC,1) = a_strNames(lngC)
          a_strGrid(lngC,2) = a_strHeadCount(lngC)
          '
          FOR lngD = 1 TO 6
          ' for each column
            '
            IF lngC > 1 THEN
            ' handle background colours only for rows after row 1
              IF lngD > 2 THEN
              ' mark all column tasks as unallocated
                a_strGrid(lngC,lngD) = "Unallocated"
                SendMessage hGrid1 ,%MLG_SETFORMATOVERRIDEEX,MAKLNG(lngC,lngD), _
                                    MAKLNG(%MLG_TYPE_BKGCOLOR,lngCellColor)
              END IF
            ' work out the background colour
              lngTemp = lngC +5 -2
              lngTemp = lngTemp \ 5
              lngTemp = lngTemp MOD 2
              IF lngD <=2 THEN
                SELECT CASE lngTemp
                  CASE 0
                  ' even number line - so make light grey
                    lngCellColor = 3
                  CASE ELSE
                  ' odd number line - so make dark grey
                    lngCellColor = 2
                END SELECT
                SendMessage hGrid1 ,%MLG_SETFORMATOVERRIDEEX,MAKLNG(lngC,lngD), _
                                     MAKLNG(%MLG_TYPE_BKGCOLOR,lngCellColor)
              ELSE
                a_strGrid(lngC,lngD) = "Unallocated"
                lngCellColor = funGetTheColourFromTask(hDlg, "Unallocated")    ' set to green background
                SendMessage hGrid1 ,%MLG_SETFORMATOVERRIDEEX,MAKLNG(lngC,lngD), _
                                    MAKLNG(%MLG_TYPE_BKGCOLOR,lngCellColor)
              END IF
            END IF
          NEXT lngD
          '
        NEXT lngC
        '
        ' put the data on the worksheet
        MLG_PutEx (hGrid1,a_strGrid(),4,0)
      NEXT lngR
    '
    END IF
    ' refresh the grid
    SendMessage(hGrid1, %MLG_SELECTSHEET, 1,0)
    SendMessage(hGrid1, %MLG_REFRESH, 1, 0)
    '
  CLOSE #lngFile
  '
  EXIT FUNCTION

END FUNCTION
  '
SUB list(s AS STRING)
  LOCAL test AS ASCIIZ * 256
  STATIC COUNT AS LONG
  LOCAL s5 AS STRING * 5

  INCR COUNT
  s5 = STR$(COUNT)
  test="Notification # "+ s5 + ":" + s
  MSGBOX test
END SUB
'
FUNCTION funGetTheColourFromTask(hDlg AS DWORD, strTask AS STRING) AS LONG
' return the number of the colour given the name of the task
  LOCAL lngR AS LONG
  LOCAL strTaskName AS STRING
  '
  FOR lngR = %IDC_Task0 TO %IDC_Task0 + %MAX_TASKS
    CONTROL GET TEXT hDlg,lngR TO strTaskName
    IF strTaskName = strTask THEN
    ' return the colour slot number
      FUNCTION = (lngR - %IDC_Task0) + 4
      '
      EXIT FUNCTION
    END IF
  NEXT lngR
  '
END FUNCTION
'
FUNCTION funGetTheSummaryColourFromTask(hDlg AS DWORD,BYREF a_strGrid() AS STRING, _
                                        lngR AS LONG,lngC AS LONG) AS STRING
' return the number of the colour base on the five days
' if all are unallocated then return the Unallocated colour
  LOCAL lngRow AS LONG
  LOCAL strTask AS STRING
  '
  FOR lngRow = lngR TO lngR + 4
    strTask = a_strGrid(lngRow,lngC)
    IF strTask = "Unallocated" THEN
      ITERATE FOR
    ELSE
    ' no point in going further as this week has at least one day allocated
      FUNCTION = a_strHTMLColours(3) ' return Allocated colour
      EXIT FUNCTION
    END IF
  '
  NEXT lngR
  '
  FUNCTION = a_strHTMLColours(0) ' return unallocated colour
'
END FUNCTION
'
FUNCTION funGetTheHTMLColourFromTask(hDlg AS DWORD, strTask AS STRING) AS STRING
' return the number of the colour given the name of the task
  LOCAL lngR AS LONG
  LOCAL strTaskName AS STRING
  '
  FOR lngR = %IDC_Task0 TO %IDC_Task0 + %MAX_TASKS
    CONTROL GET TEXT hDlg,lngR TO strTaskName
    IF strTaskName = strTask THEN
      FUNCTION = a_strHTMLColours(lngR - %IDC_Task0)
      EXIT FUNCTION
    END IF
  NEXT lngR
  '
END FUNCTION

'
FUNCTION funGetTheColour(lngMyItem AS LONG) AS LONG
' return the colour based on the menu item
  LOCAL lngColour AS LONG
  LOCAL lngTask AS LONG
  '
  lngTask = lngMyItem - %IDC_Tick0
  '
  FUNCTION = lngTask +4
  '
END FUNCTION
'
FUNCTION funGetTask(hDlg AS DWORD, o_strTaskName AS STRING) AS LONG
' return the task number and name
  LOCAL lngR AS LONG
  LOCAL lngChecked AS LONG
  '
  ' first find the current tick location
  FOR lngR = %IDC_Tick0 TO %IDC_Tick0 + %MAX_TASKS
    CONTROL GET CHECK hDlg, lngR TO lngChecked
    IF ISTRUE lngChecked THEN
    ' found it
      EXIT FOR
    END IF
  NEXT lngR
  '
  CONTROL GET TEXT hDlg,(%IDC_Task0 + lngR - %IDC_Tick0) TO o_strTaskName
  FUNCTION = lngR
  '
END FUNCTION
'
FUNCTION funCurrentUser() AS STRING
' return the NT user signed on
  LOCAL zName AS ASCIIZ * %UNLEN + 1
  GetUserName zName, SIZEOF(zName)
  FUNCTION = zName
END FUNCTION

'
FUNCTION funCreateSecurityFile(strSecurityFile AS STRING) AS LONG
' create the security file with user info
  LOCAL lngFile AS LONG
  '
  lngFile = FREEFILE
  OPEN strSecurityFile FOR OUTPUT AS #lngfile
    PRINT#lngFile, "Owner=" & funCurrentUser
  CLOSE #lngFile
  '
END FUNCTION
'
FUNCTION funSaveConfig(hDlg AS DWORD, strtxtTeamName AS STRING, strtxtResource AS STRING) AS LONG
' save the config information
  LOCAL lngFile AS LONG
  LOCAL strLocalTeamName AS STRING
  LOCAL strData AS STRING
  LOCAL lngR AS LONG
  LOCAL lngC AS LONG
  LOCAL lngSheet AS LONG
  LOCAL strDateStamp AS STRING
  '
  DIM a_strGrid(1 TO glngGridRows,1 TO 6) AS STRING                'retrieved cell content string using an array
  '
  strLocalTeamName = strtxtTeamName
  REPLACE " " WITH "_" IN strtxtTeamName
  '
  ' first check if there is a Security file
  IF ISFALSE ISFILE(EXE.PATH$ & "Data\" & strtxtTeamName & ".ser") THEN
  ' if security file does not exists - create it with this user as the owner
    funCreateSecurityFile(EXE.PATH$ & "Data\Levels\" & strtxtTeamName & ".ser")
  '
  END IF
  '
  lngFile = FREEFILE
  OPEN EXE.PATH$ & "Data\" & strtxtTeamName & ".dat" FOR OUTPUT AS #lngfile
    PRINT#lngFile, strLocalTeamName & "|" & strtxtResource
    PRINT#lngFile, g_strMonths
    ' tasks
    FOR lngR = %IDC_Task0 TO %IDC_Task0 + %MAX_TASKS
      CONTROL GET TEXT hDlg, lngR TO strData
      PRINT#lngFile, strData
    NEXT lngR
    '
    FOR lngSheet = 1 TO 6
    ' for each sheet - first select the sheet
      SendMessage(hGrid1, %MLG_SELECTSHEET, lngSheet,0)
      ' now dump the grids
      MLG_GetEx hGrid1,a_strGrid()
      FOR lngR = 1 TO glngGridRows
        IF a_strGrid(lngR,1) <> "*Deleted*" THEN
        ' only if it has not been deleted
          strData = "#"& FORMAT$(lngSheet) & "*"
          FOR lngC = 1 TO 6
            strData = strData & a_strGrid(lngR,lngC) & "|"
          NEXT lngC
          strData = RTRIM$(strData,"|")
          PRINT#lngFile, strData
        END IF
      NEXT lngR
    NEXT lngSheet
    '
    ' set focus back to first worksheet
    SendMessage(hGrid1, %MLG_SELECTSHEET, 1,0)
  CLOSE #lngFile
  '
  ' now copy file to the DB_Processing folder
  IF ISFALSE ISFOLDER(EXE.PATH$ & "DB_Processing") THEN
    TRY
      MKDIR EXE.PATH$ & "DB_Processing"
    CATCH
    FINALLY
    END TRY
  END IF
  '
  TRY
    strDateStamp = funReverseDate(funUKDate) & "_" & TIME$
    REPLACE ":" WITH "" IN strDateStamp
    '
    FILECOPY EXE.PATH$ & "Data\" & strtxtTeamName & ".dat", EXE.PATH$ & _
                         "DB_Processing\" & strtxtTeamName & "_" & strDateStamp & ".dat"
  CATCH
  FINALLY
  END TRY
  ' set security menu to enabled
  MENU SET STATE g_hMenu, BYCMD %IDM_RESOURCE_AmendSecurity, %MFS_ENABLED
  '
  FUNCTION = %TRUE
  '
END FUNCTION
'
FUNCTION funPrepTaskColours() AS LONG
  REDIM a_lngTaskColours(%MAX_TASKS) AS LONG
  '
  ARRAY ASSIGN a_lngTaskColours()= %RGB_LIME,%RGB_YELLOWGREEN,%RGB_ORANGE,_
               %RGB_LIGHTBLUE,%RGB_DARKSEAGREEN, %RGB_DEEPSKYBLUE, %RGB_PLUM, _
               %RGB_BURLYWOOD, %RGB_LIGHTPINK, %RGB_TOMATO, %RGB_GOLD , _
               %RGB_PERU

END FUNCTION
'
FUNCTION funGetHTMLColour(lngR AS LONG) AS STRING
' return the html colour
  REDIM PRESERVE a_strHTMLColours(UBOUND(a_strHTMLColours)) AS STRING
  FUNCTION = a_strHTMLColours(lngR)
  '
END FUNCTION
'
FUNCTION funPrepHTMLColours() AS LONG
' prepare array of html colours
  REDIM a_strHTMLColours(%MAX_TASKS) AS STRING
  '
  ARRAY ASSIGN a_strHTMLColours()= "#00FF00","#99CC66","#FF9900","#A3D5E4","#669999", _
               "#55BBEA","#E88EEE","#DEB678","#EAA3BB","#F65F45","#E8FF5A" ,"#BF9223"
  '
END FUNCTION
'------------------------------------------------------------------------------
FUNCTION AttachMENU1(BYVAL hDlg AS DWORD) AS DWORD
#PBFORMS BEGIN MENU %IDR_MENU1->%IDD_DIALOG1
    LOCAL hMenu   AS DWORD
    LOCAL hPopUp1 AS DWORD

    MENU NEW BAR TO hMenu
    MENU NEW POPUP TO hPopUp1
    MENU ADD POPUP, hMenu, "File", hPopUp1, %MF_ENABLED
        MENU ADD STRING, hPopUp1, "Exit", %IDABORT, %MF_ENABLED
    MENU NEW POPUP TO hPopUp1
    MENU ADD POPUP, hMenu, "Resource", hPopUp1, %MF_ENABLED
        MENU ADD STRING, hPopUp1, "Add a New Resource", _
            %IDM_RESOURCE_ADDRESOURCE, %MF_ENABLED
        MENU ADD STRING, hPopUp1, "Amend an Existing Resource", _
            %IDM_RESOURCE_AMENDARESOURCE, %MF_ENABLED
        MENU ADD STRING, hPopUp1, "Delete a Resource", _
            %IDM_RESOURCE_DELETEARESOURCE, %MF_ENABLED
    MENU NEW POPUP TO hPopUp1
    MENU ADD POPUP, hMenu, "Security", hPopUp1, %MF_ENABLED
        MENU ADD STRING, hPopUp1, "Amend Security on this Team", _
            %IDM_RESOURCE_AmendSecurity, %MF_DISABLED
    MENU ADD STRING, hMenu, "Help", %IDM_RESOURCE_HELP, %MF_ENABLED


    MENU ATTACH hMenu, hDlg
#PBFORMS END MENU
' store the menu handle
    g_hMenu = hMenu
    FUNCTION = hMenu
END FUNCTION
'------------------------------------------------------------------------------
FUNCTION funSortColumn(hGrid AS DWORD,lngR AS LONG, mycol AS LONG, _
                       BYREF a_strData() AS STRING, hDlg AS DWORD) AS LONG
' ensure Unallocated remains at top for each set of 5 entries
' where 5 entries is one resource unit
'
  LOCAL lngCount AS LONG       ' count the unallocated entries for resource
  LOCAL lngResourceRow AS LONG ' the row being processed
  DIM a_strLocal(1 TO 5) AS STRING ' used to hold 5 slots for current resource
  LOCAL lngE AS LONG
  LOCAL lngCellColor AS LONG
  LOCAL lngStep AS LONG

  FOR lngResourceRow = 1 TO glngGridRows -1 STEP 5
  ' for each row of the resource
  ' first count the number of unallocated
    lngStep = 1
    lngCount = 0
    FOR lngE = lngResourceRow TO lngResourceRow + 4
      a_strLocal(lngStep) = ""
      IF a_strData(lngE) = "Unallocated" THEN
        INCR lngCount
      ELSE
        a_strLocal(lngStep)= a_strData(lngE)
      END IF
      INCR lngStep
    NEXT lngE
    ' sort ascending
    ARRAY SORT a_strLocal(), COLLATE UCASE, ASCEND
    FOR lngE = 1 TO lngCount
      a_strLocal(lngE) = "Unallocated"
    NEXT lngE
    '
    ' now slot these back into original array
    lngStep = 1
    FOR lngE = lngResourceRow TO lngResourceRow + 4
      a_strData(lngE) = a_strLocal(lngStep)
      INCR lngStep
    NEXT lngResourceRow
  '
  NEXT lngResourceRow
  '
  ' now put the data back in the grid
  FOR lngE = 1 TO glngGridRows -1
    MLG_Put hGrid1,lngE+1, mycol,a_strData(lngE),0
    ' now sort the colours
    lngCellColor = funGetTheColourFromTask(hDlg, a_strData(lngE)) '%RGB_YELLOWGREEN
    SendMessage hGrid ,%MLG_SETFORMATOVERRIDEEX,MAKLNG(lngE+1,mycol), _
                        MAKLNG(%MLG_TYPE_BKGCOLOR,lngCellColor)
  NEXT lngR
  '
END FUNCTION
'------------------------------------------------------------------------------
CALLBACK FUNCTION ShowADDANEWRESOURCEUNITProc()

    SELECT CASE AS LONG CB.MSG
        CASE %WM_INITDIALOG
            ' Initialization handler

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
                CASE %IDC_txtResourceName

                CASE %IDC_STATUSBAR2

                CASE %IDC_txtHeadcount

                CASE %IDCANCEL
                  IF CB.CTLMSG = %BN_CLICKED OR CB.CTLMSG = 1 THEN
                    DIALOG END CB.HNDL, 0
                  END IF

                CASE %IDC_SAVE
                  IF CB.CTLMSG = %BN_CLICKED OR CB.CTLMSG = 1 THEN
                  ' save the resource information
                    CONTROL GET TEXT CB.HNDL, %IDC_txtResourceName TO g_strResourceName
                    CONTROL GET TEXT CB.HNDL, %IDC_txtHeadcount TO g_strResourceHeadCount
                    DIALOG END CB.HNDL, 1
                  '
                  END IF

            END SELECT
    END SELECT
END FUNCTION
'------------------------------------------------------------------------------

'------------------------------------------------------------------------------
FUNCTION ShowADDANEWRESOURCEUNIT(BYVAL hParent AS DWORD) AS LONG
    LOCAL lRslt AS LONG

#PBFORMS BEGIN DIALOG %IDD_ADDANEWRESOURCEUNIT->->
    LOCAL hDlg  AS DWORD

    DIALOG NEW hParent, "Add a New Resource Unit", 70, 70, 330, 121, _
        %WS_POPUP OR %WS_BORDER OR %WS_DLGFRAME OR %WS_CLIPSIBLINGS OR _
        %WS_VISIBLE OR %DS_MODALFRAME OR %DS_CENTER OR %DS_3DLOOK OR _
        %DS_NOFAILCREATE OR %DS_SETFONT, %WS_EX_CONTROLPARENT OR %WS_EX_LEFT _
        OR %WS_EX_LTRREADING OR %WS_EX_RIGHTSCROLLBAR, TO hDlg
    CONTROL ADD LABEL,     hDlg, %IDC_LABEL1, "Enter Resource Unit name", 5, _
        5, 100, 10
    CONTROL SET COLOR      hDlg, %IDC_LABEL1, %BLUE, -1
    CONTROL ADD TEXTBOX,   hDlg, %IDC_txtResourceName, "", 105, 3, 215, 12
    CONTROL ADD LABEL,     hDlg, %IDC_LABEL3, "Enter HeadCount", 5, 42, 100, _
        10
    CONTROL SET COLOR      hDlg, %IDC_LABEL3, %BLUE, -1
    CONTROL ADD STATUSBAR, hDlg, %IDC_STATUSBAR2, "Ready", 0, 0, 0, 0
    CONTROL ADD TEXTBOX,   hDlg, %IDC_txtHeadcount, "1", 107, 40, 48, 15, _
        %WS_CHILD OR %WS_VISIBLE OR %WS_TABSTOP OR %ES_CENTER, _
        %WS_EX_CLIENTEDGE OR %WS_EX_LEFT OR %WS_EX_LTRREADING OR _
        %WS_EX_RIGHTSCROLLBAR
    CONTROL ADD BUTTON,    hDlg, %IDCANCEL, "Cancel", 10, 85, 50, 15, _
        %BS_RIGHT OR %BS_VCENTER OR %WS_TABSTOP OR %BS_TEXT OR %WS_CHILD OR _
        %WS_VISIBLE, %WS_EX_LEFT OR %WS_EX_LTRREADING
    CONTROL ADD BUTTON,    hDlg, %IDC_SAVE, "Save", 270, 85, 50, 15
#PBFORMS END DIALOG
     ' add graphics to buttons
    ButtonPlus hDlg, %IDCANCEL, %BP_TEXT_COLOR, %RED
    ButtonPlus hDlg, %IDCANCEL, %BP_ICON_ID, %IDR_IMGFILE5
    ButtonPlus hDlg, %IDCANCEL, %BP_ICON_WIDTH, 16
    ButtonPlus hDlg, %IDCANCEL, %BP_ICON_POS, %BS_LEFT
    '
    ButtonPlus hDlg, %IDC_SAVE, %BP_TEXT_COLOR, %RED
    ButtonPlus hDlg, %IDC_SAVE, %BP_ICON_ID, %IDR_IMGFILE6
    ButtonPlus hDlg, %IDC_SAVE, %BP_ICON_WIDTH, 16
    ButtonPlus hDlg, %IDC_SAVE, %BP_ICON_POS, %BS_LEFT

    DIALOG SHOW MODAL hDlg, CALL ShowADDANEWRESOURCEUNITProc TO lRslt

#PBFORMS BEGIN CLEANUP %IDD_ADDANEWRESOURCEUNIT
#PBFORMS END CLEANUP

    FUNCTION = lRslt
END FUNCTION
'------------------------------------------------------------------------------
'------------------------------------------------------------------------------
CALLBACK FUNCTION ShowDELETEARESOURCEProc()
    LOCAL MLGN AS MyGridData PTR
    LOCAL mychar AS LONG
    '
    SELECT CASE AS LONG CB.MSG
        CASE %WM_INITDIALOG
            ' Initialization handler
            ' big array to keep track of staff checked for deletion
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
        CASE %WM_NOTIFY
          MLGN=CB.LPARAM
          IF @MLGN.NMHeader.idFrom = %IDC_MLGGRID2 THEN
            SELECT CASE @MLGN.NMHeader.code
              CASE %MLGN_CHECKCHANGED
                mychar = @MLGN.Param3  'before toggle - if contained 255 then was unselected else should have contained 1 which was previously selected
                '@MLGN.Param2   ' Column of check change
                '@MLGN.Param1          ' Row of check change
                a_lngStaffChecked(@MLGN.Param1) = mychar
                '
            END SELECT
          END IF
          '
        CASE %WM_COMMAND
            ' Process control notifications
            SELECT CASE AS LONG CB.CTL
                CASE %IDOK
                    IF CB.CTLMSG = %BN_CLICKED OR CB.CTLMSG = 1 THEN
                    ' delete the resource from the grid
                      CONTROL SET TEXT CB.HNDL,%IDC_STATUSBAR3,"Deleting the resource"
                      funDeleteResource(CB.HNDL)
                      CONTROL SET TEXT CB.HNDL,%IDC_STATUSBAR3,"Operation completed"
                      DIALOG END CB.HNDL, %IDOK
                    END IF

                CASE %IDABORT
                    IF CB.CTLMSG = %BN_CLICKED OR CB.CTLMSG = 1 THEN
                      DIALOG END CB.HNDL, %FALSE
                    END IF

                CASE %IDC_STATUSBAR3

            END SELECT
    END SELECT
END FUNCTION
'------------------------------------------------------------------------------

'------------------------------------------------------------------------------
FUNCTION ShowDELETEARESOURCE(BYVAL hParent AS DWORD) AS LONG
    LOCAL lRslt AS LONG
    LOCAL lngGridRows AS LONG
    LOCAL lngRefresh AS LONG
    LOCAL a_strStaff() AS STRING
    LOCAL a_strHeadCount() AS STRING
    LOCAL lngR AS LONG
    LOCAL lngRow AS LONG
    '
    lngGridRows = 1
    lngRefresh = 0
    '
#PBFORMS BEGIN DIALOG %IDD_DELETEARESOURCE->->
    LOCAL hDlg  AS DWORD

    DIALOG NEW hParent, "Delete a Resource from the Team", 70, 70, 320, 206, _
        %WS_POPUP OR %WS_BORDER OR %WS_DLGFRAME OR %WS_CAPTION OR _
        %WS_SYSMENU OR %WS_MINIMIZEBOX OR %WS_CLIPSIBLINGS OR %WS_VISIBLE OR _
        %DS_MODALFRAME OR %DS_CENTER OR %DS_3DLOOK OR %DS_NOFAILCREATE OR _
        %DS_SETFONT, %WS_EX_CONTROLPARENT OR %WS_EX_LEFT OR _
        %WS_EX_LTRREADING OR %WS_EX_RIGHTSCROLLBAR, TO hDlg
    CONTROL ADD BUTTON,    hDlg, %IDOK, "Apply Changes", 10, 172, 80, 15
    DIALOG  SEND           hDlg, %DM_SETDEFID, %IDOK, 0
    CONTROL ADD BUTTON,    hDlg, %IDABORT, "Cancel", 247, 172, 65, 15
    CONTROL ADD STATUSBAR, hDlg, %IDC_STATUSBAR3, "", 0, 0, 0, 0
#PBFORMS END DIALOG
    ' add graphics to buttons
    ButtonPlus hDlg, %IDABORT, %BP_TEXT_COLOR, %RED
    ButtonPlus hDlg, %IDABORT, %BP_ICON_ID, %IDR_IMGFILE5
    ButtonPlus hDlg, %IDABORT, %BP_ICON_WIDTH, 16
    ButtonPlus hDlg, %IDABORT, %BP_ICON_POS, %BS_LEFT
    '
    ButtonPlus hDlg, %IDOK, %BP_TEXT_COLOR, %RED
    ButtonPlus hDlg, %IDOK, %BP_ICON_ID, %IDR_IMGFILE7
    ButtonPlus hDlg, %IDOK, %BP_ICON_WIDTH, 16
    ButtonPlus hDlg, %IDOK, %BP_ICON_POS, %BS_LEFT
    '
    CONTROL ADD "MYLITTLEGRID", hDlg, %IDC_MLGGRID2, _
          "x20,120,285/d-0/e1/w1/r" & FORMAT$(lngGridRows) & "/c2/a2/y3", _
          10, 10, 300, 158, %MLG_STYLE
    CONTROL HANDLE hDlg, %IDC_MLGGRID2 TO hGrid2
    ' set cell for licence
    SendMessage hGrid2,%MLG_SETCELL,0,0
    '
    SendMessage hGrid2, %MLG_SETHEADERCOLOR , %LTGRAY,0
    '
    MLG_Put hGrid2,0,1,"Select to Delete" ,lngRefresh
    MLG_Put hGrid2,0,2,"Staff Name",lngRefresh
    ' set first column as a check box
    MLG_FormatColCheck hGrid2,1
    '
    REDIM a_strStaff(1) AS STRING
    funGetStaffNames(a_strStaff(), a_strHeadCount())
    MLG_ArrayRedim(hGrid2, UBOUND(a_strStaff)-1, 2, UBOUND(a_strStaff)-1, 2)
    lngRow = 0
    FOR lngR = 2 TO UBOUND(a_strStaff)
      INCR lngRow
      MLG_Put hGrid2,lngRow,2,a_strStaff(lngR),lngRefresh
    NEXT lngR
    '
    DIALOG SET ICON hDlg, "#" & FORMAT$(%IDR_IMGFILE7)
    DIALOG SHOW MODAL hDlg, CALL ShowDELETEARESOURCEProc TO lRslt

#PBFORMS BEGIN CLEANUP %IDD_DELETEARESOURCE
#PBFORMS END CLEANUP

    FUNCTION = lRslt
END FUNCTION
'------------------------------------------------------------------------------
FUNCTION funGetStaffNames(BYREF a_strStaff() AS STRING, BYREF a_strHeadCount() AS STRING) AS LONG
' get the staff names and return in array
' look at the main grid
  LOCAL lngR AS LONG
  LOCAL lngSheet AS LONG
  '
  lngSheet = 1
  '
  'retrieved cells content string using an array
  DIM a_strGrid(1 TO glngGridRows,1 TO 6) AS STRING
  SendMessage(hGrid1, %MLG_SELECTSHEET, lngSheet,0)
  ' now dump the grid to array
  MLG_GetEx hGrid1,a_strGrid()
  '
  ' now work through the array to get the names
  FOR lngR = 2 TO glngGridRows STEP 5
    IF a_strGrid(lngR,1)<>"" THEN
      REDIM PRESERVE a_strStaff(UBOUND(a_strStaff) + 1) AS STRING
      a_strStaff(UBOUND(a_strStaff)) = a_strGrid(lngR,1)
      '
      REDIM PRESERVE a_strHeadCount(UBOUND(a_strHeadCount) +1) AS STRING
      a_strHeadCount(UBOUND(a_strHeadCount)) = a_strGrid(lngR,2)
    END IF
  NEXT lngR
  FUNCTION = %TRUE
  '
END FUNCTION

FUNCTION funCallHelp(hDlg AS DWORD,OPTIONAL BYVAL lphi AS HELPINFO PTR) AS LONG
' handle the calls to help
  LOCAL lngControl AS LONG
  LOCAL strPath AS STRING
  LOCAL strKeyword AS STRING
  '
  IF lphi >0  THEN
    lngControl = @lphi.iCtrlId
    '
    SELECT CASE lngControl
      CASE 3000
        strKeyword = "Monthly_Grid"
      CASE ELSE
        strKeyword = "Contents"
    END SELECT
  END IF
  '
  CONTROL SET TEXT hDlg,%IDC_STATUSBAR1 ,"Loading help - please wait..."
  '
  ExecuteHelp 0, EXE.PATH$ & "Resource Manager.chm"
  CONTROL SET TEXT hDlg,%IDC_STATUSBAR1,""
  '
END FUNCTION
'
SUB ExecuteHelp(BYVAL hParent AS DWORD, BYVAL sFile AS STRING, _
                OPTIONAL BYVAL sKeyword AS STRING, OPTIONAL BYVAL nType AS LONG)

  LOCAL dwProc AS DWORD, pszFile AS ASCIIZ PTR, uCommand AS DWORD, dwData AS DWORD

  STATIC hLib AS DWORD, zExt AS ASCIIZ * 16

  IF (LEN(sFile) <> 0) THEN

     IF (LEN(DIR$(sFile)) = 0) THEN
        ' Oh dear - no help file...
        MessageBox hParent, "The help file " + $DQ + MID$(sFile, INSTR(-1, sFile, ANY "\/")+1) + $DQ + _
                            " could not be found. Please check this program is installed " + _
                            "correctly and/or reinstall it.", "Help Error", %MB_ICONINFORMATION
        EXIT SUB
     ELSE

        ' Save extension for next time...
        zExt = UCASE$(MID$(sFile, INSTR(-1, sFile, ".")+1))
     END IF
  END IF

  SELECT CASE zExt

         CASE "CHM", "COL"
               ' Run a CHM (HTML Help) file...
               ' The .COL extension means a collection of CHM files, this is also valid.
               IF hLib = %NULL THEN hLib = LoadLibrary("hhctrl.ocx")
               IF hLib THEN
                  dwProc = GetProcAddress(hLib, "HtmlHelpA")
                  IF dwProc THEN
                     IF LEN(sFile) THEN
                        LOCAL hlk AS HH_AKLINK
                        hlk.cbStruct      = SIZEOF(hlk)
                        hlk.fReserved     = %FALSE
                        IF LEN(sKeyword) THEN hlk.pszKeywords = STRPTR(sKeyword)
                        hlk.pszUrl        = %NULL
                        hlk.pszMsgText    = %NULL
                        hlk.pszMsgTitle   = %NULL
                        hlk.pszWindow     = %NULL
                        hlk.fIndexOnFail  = %TRUE
                        pszFile = STRPTR(sFile)
                        dwData = VARPTR(hlk)
                        IF nType THEN uCommand = nType ELSE uCommand = %HH_DISPLAY_TOC 'KEYWORD_LOOKUP
                        ! push dwData
                        ! push uCommand
                        ! push pszFile
                        ! push hParent
                        ! call dwProc
                     ELSE
                        ' Close help window...
                        uCommand = %HH_CLOSE_ALL
                        ! push %NULL
                        ! push uCommand
                        ! push %NULL
                        ! push %NULL
                        ! call dwProc
                     END IF
                  END IF
               ELSE
                 IF LEN(sFile) = 0 THEN EXIT SUB
                 IF MessageBox(hParent, "This program uses HTML help for it's documentation. However, this is not supported on your system." + $CRLF + _
                                         "Please press OK visit Microsoft's website and install Internet Explorer to update your system.", _
                                         "HTML Help Error", %MB_ICONINFORMATION OR %MB_OKCANCEL) = %IDOK THEN
                 ' Visit Microsoft...
                   ShellExecute hParent, "", "http://www.microsoft.com/ie", "", "", %SW_SHOWNORMAL
                 END IF
               END IF
               '
         CASE "HLP"
           IF LEN(sFile) THEN
           ' Run a WinHelp file...
             WinHelp hParent, BYCOPY sFile, nType, STRPTR(sKeyword)
           ELSE
           ' Close help window...
             WinHelp hParent, BYVAL %NULL, %HELP_QUIT, %NULL
           END IF

         CASE ELSE
         ' Don't know what the file type is, so just try and run it with the shell...
           CALL ShellExecute(hParent, "open", BYCOPY sFile, "", "", %SW_SHOWNORMAL)
   END SELECT
END SUB
'
FUNCTION funDeleteResource(hDlg AS DWORD) AS LONG
' delete the specified resources
' first get the data from the grid
  DIM a_strStaff() AS STRING
  DIM a_strGrid() AS STRING
  DIM a_strHeadCount() AS STRING
  LOCAL lngR AS LONG
  LOCAL lngRows AS LONG
  LOCAL lngCount AS LONG
  LOCAL strUser AS STRING
  '
  REDIM a_strStaff(1) AS STRING
  funGetStaffNames(a_strStaff(), a_strHeadCount())
  REDIM a_strGrid(UBOUND(a_strStaff),2) AS STRING
  '
  REDIM PRESERVE a_lngStaffChecked(UBOUND(a_lngStaffChecked)) AS LONG
  MLG_GetEx hGrid2,a_strGrid()
  '
  FOR lngR = 1 TO UBOUND(a_strGrid)
    IF ISTRUE a_lngStaffChecked(lngR-1) THEN
    ' deleting a_strGrid(lngR,2)
    ' look at the grid and mark lines where needed
      FOR lngCount = 1 TO 6
      ' select the work sheet
        SendMessage hGrid1, %MLG_SELECTSHEET, lngCount,0
        FOR lngRows = 1 TO glngGridRows
          strUser = MLG_Get(hGrid1,lngRows,1)
          IF strUser = a_strStaff(lngR) THEN
            MLG_Put(hGrid1,lngRows,1, "*Deleted*",1)
          END IF
        NEXT lngRows
        '
      NEXT lngCount
    '
    END IF
  NEXT lngR
  '
  SendMessage hGrid1, %MLG_SELECTSHEET, 1,0
END FUNCTION
'------------------------------------------------------------------------------
CALLBACK FUNCTION ShowAMENDARESOURCEINTHETEAMProc()

    SELECT CASE AS LONG CB.MSG
        CASE %WM_INITDIALOG
            ' Initialization handler

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
                CASE %IDC_STATUSBAR4
                '
                CASE %IDOK
                    IF CB.CTLMSG = %BN_CLICKED OR CB.CTLMSG = 1 THEN
                    ' user has clicked to update the grids
                      CONTROL SET TEXT CB.HNDL,%IDC_STATUSBAR4,"Amending Resource"
                      funUpdateResource(CB.HNDL)
                      CONTROL SET TEXT CB.HNDL,%IDC_STATUSBAR4,"Operation completed"
                      DIALOG END CB.HNDL, %IDOK
                    END IF

                CASE %IDABORT
                    IF CB.CTLMSG = %BN_CLICKED OR CB.CTLMSG = 1 THEN
                      DIALOG END CB.HNDL, %IDABORT
                    END IF

            END SELECT
    END SELECT
END FUNCTION
'------------------------------------------------------------------------------

'------------------------------------------------------------------------------
FUNCTION ShowAMENDARESOURCEINTHETEAM(BYVAL hParent AS DWORD) AS LONG
    LOCAL lRslt AS LONG
    LOCAL lngGridRows AS LONG
    LOCAL lngRefresh AS LONG
    LOCAL lngR AS LONG
    LOCAL lngRow AS LONG
    LOCAL sNumberformat AS SINGLE
    '
    lngGridRows = 1
    lngRefresh = 0
    '
#PBFORMS BEGIN DIALOG %IDD_AMENDARESOURCEINTHETEAM->->
    LOCAL hDlg  AS DWORD

    DIALOG NEW hParent, "Amend a Resource in the Team", 70, 70, 320, 228, _
        %WS_POPUP OR %WS_BORDER OR %WS_DLGFRAME OR %WS_CAPTION OR _
        %WS_SYSMENU OR %WS_MINIMIZEBOX OR %WS_CLIPSIBLINGS OR %WS_VISIBLE OR _
        %DS_MODALFRAME OR %DS_CENTER OR %DS_3DLOOK OR %DS_NOFAILCREATE OR _
        %DS_SETFONT, %WS_EX_CONTROLPARENT OR %WS_EX_LEFT OR _
        %WS_EX_LTRREADING OR %WS_EX_RIGHTSCROLLBAR, TO hDlg
    CONTROL ADD STATUSBAR, hDlg, %IDC_STATUSBAR4, "", 0, 0, 0, 0
    CONTROL ADD BUTTON,    hDlg, %IDOK, "Save", 9, 190, 56, 15
    DIALOG  SEND           hDlg, %DM_SETDEFID, %IDOK, 0
    CONTROL ADD BUTTON,    hDlg, %IDABORT, "Cancel", 255, 190, 55, 15
#PBFORMS END DIALOG
    ButtonPlus hDlg, %IDABORT, %BP_TEXT_COLOR, %RED
    ButtonPlus hDlg, %IDABORT, %BP_ICON_ID, %IDR_IMGFILE5
    ButtonPlus hDlg, %IDABORT, %BP_ICON_WIDTH, 16
    ButtonPlus hDlg, %IDABORT, %BP_ICON_POS, %BS_LEFT
    '
    ButtonPlus hDlg, %IDOK, %BP_TEXT_COLOR, %RED
    ButtonPlus hDlg, %IDOK, %BP_ICON_ID, %IDR_IMGFILE7
    ButtonPlus hDlg, %IDOK, %BP_ICON_WIDTH, 16
    ButtonPlus hDlg, %IDOK, %BP_ICON_POS, %BS_LEFT
    '
    CONTROL ADD "MYLITTLEGRID", hDlg, %IDC_MLGGRID3, _
          "x20,285,120/d-0/e1/w1/r" & FORMAT$(lngGridRows) & "/c2/a2/y3", _
          10, 10, 300, 158, %MLG_STYLE
    CONTROL HANDLE hDlg, %IDC_MLGGRID3 TO hGrid3
    ' set cell for licence
    SendMessage hGrid3,%MLG_SETCELL,0,0
    '
    SendMessage hGrid3, %MLG_SETHEADERCOLOR , %LTGRAY,0
    '
    MLG_Put hGrid3,0,1,"Staff Name" ,lngRefresh
    MLG_Put hGrid3,0,2,"Head Count",lngRefresh
    MLG_FormatColNumber hGrid3,2,sNumberformat,%MLG_JUST_CENTER,%BLUE,%MLG_NOLOCK
    MLG_FormatColEdit hGrid3,1,%MLG_NULL,%MLG_NULL,%MLG_JUST_CENTER,%BLUE,%MLG_LOCK
    '
    REDIM a_strStaff(1) AS STRING
    REDIM a_strHeadcount(1) AS STRING
    funGetStaffNames(a_strStaff(), a_strHeadcount())
    MLG_ArrayRedim(hGrid3, UBOUND(a_strStaff)-1, 2, UBOUND(a_strStaff)-1, 2)
    lngRow = 0
    FOR lngR = 2 TO UBOUND(a_strStaff)
      INCR lngRow
      MLG_Put hGrid3,lngRow,1,a_strStaff(lngR),lngRefresh
      MLG_Put hGrid3, lngRow,2,a_strHeadCount(lngR),lngRefresh
    NEXT lngR
    '
    DIALOG SHOW MODAL hDlg, CALL ShowAMENDARESOURCEINTHETEAMProc TO lRslt

#PBFORMS BEGIN CLEANUP %IDD_AMENDARESOURCEINTHETEAM
#PBFORMS END CLEANUP

    FUNCTION = lRslt
END FUNCTION
'------------------------------------------------------------------------------
FUNCTION ShowAMENDPermissions(BYVAL hParent AS DWORD, strTeamname AS STRING) AS LONG
    LOCAL lRslt AS LONG
    LOCAL lngGridRows AS LONG
    LOCAL lngRefresh AS LONG
    LOCAL lngR AS LONG
    LOCAL lngRow AS LONG
    LOCAL sNumberformat AS SINGLE
    LOCAL lngTotalRows AS LONG
    '
    lngGridRows = 1
    lngRefresh = 0
    '
#PBFORMS BEGIN DIALOG %IDD_AMENDPermissions->->
    LOCAL hDlg  AS DWORD

    DIALOG NEW hParent, "Amend the permissions for this Team", 227, 116, 320, _
        228, %WS_POPUP OR %WS_BORDER OR %WS_DLGFRAME OR %WS_CAPTION OR _
        %WS_SYSMENU OR %WS_MINIMIZEBOX OR %WS_CLIPSIBLINGS OR %WS_VISIBLE OR _
        %DS_MODALFRAME OR %DS_CENTER OR %DS_3DLOOK OR %DS_NOFAILCREATE OR _
        %DS_SETFONT, %WS_EX_CONTROLPARENT OR %WS_EX_LEFT OR _
        %WS_EX_LTRREADING OR %WS_EX_RIGHTSCROLLBAR, TO hDlg
    CONTROL ADD STATUSBAR, hDlg, %IDC_STATUSBAR4, "", 0, 0, 0, 0
    CONTROL ADD BUTTON,    hDlg, %IDC_SAVEPermissions, "Save", 9, 190, 56, 15
  '  DIALOG  SEND           hDlg, %DM_SETDEFID, %IDOK, 0
    CONTROL ADD BUTTON,    hDlg, %IDABORT, "Cancel", 255, 190, 55, 15
    CONTROL ADD LABEL,     hDlg, %IDC_TEAMNAME, "TeamName", 45, 05, 100, 10
    CONTROL ADD LABEL,     hDlg, %IDC_TEAM, "Team", 10, 05, 35, 10
    CONTROL SET COLOR      hDlg, %IDC_TEAM, %BLUE, -1
#PBFORMS END DIALOG
    ButtonPlus hDlg, %IDABORT, %BP_TEXT_COLOR, %RED
    ButtonPlus hDlg, %IDABORT, %BP_ICON_ID, %IDR_IMGFILE5
    ButtonPlus hDlg, %IDABORT, %BP_ICON_WIDTH, 16
    ButtonPlus hDlg, %IDABORT, %BP_ICON_POS, %BS_LEFT
    '
    ButtonPlus hDlg, %IDC_SAVEPermissions, %BP_TEXT_COLOR, %RED
    ButtonPlus hDlg, %IDC_SAVEPermissions, %BP_ICON_ID, %IDR_IMGFILE7
    ButtonPlus hDlg, %IDC_SAVEPermissions, %BP_ICON_WIDTH, 16
    ButtonPlus hDlg, %IDC_SAVEPermissions, %BP_ICON_POS, %BS_LEFT
    '
    CONTROL SET TEXT hDlg, %IDC_TEAMNAME, strTeamName
    '
    CONTROL ADD "MYLITTLEGRID", hDlg, %IDC_MLGGRID4, _
          "x20,285,120/d-0/e1/t2/w1/r" & FORMAT$(lngGridRows) & "/c2/a2/y3", _
          10, 20, 300, 148, %MLG_STYLE
    CONTROL HANDLE hDlg, %IDC_MLGGRID4 TO hGrid4
    ' set cell for licence
    SendMessage hGrid4,%MLG_SETCELL,0,0
    '
    SendMessage hGrid4, %MLG_SETHEADERCOLOR , %LTGRAY,0
    '
    MLG_Put hGrid4,0,1,"Signon name" ,lngRefresh
    MLG_Put hGrid4,0,2,"Permission level",lngRefresh
    MLG_FormatColEdit hGrid4,1,%MLG_NULL,%MLG_NULL,%MLG_JUST_CENTER,%BLUE,%MLG_NOLOCK
    MLG_FormatColCombo hGrid4,2,"Owner,Read Only,Read Write",1
    '
    REDIM a_strStaff(1) AS STRING
    REDIM a_strPermission(1) AS STRING
    funGetPermissionStaffNames(strTeamName, a_strStaff(), a_strPermission())
    lngTotalRows = UBOUND(a_strStaff) +10
    REDIM PRESERVE a_strPermission(lngTotalRows) AS STRING
    REDIM PRESERVE a_staff(lngTotalRows) AS STRING
    '
    FOR lngR =1 TO lngTotalRows
      IF a_strPermission(lngR) = "" THEN
        a_strPermission(lngR) = "Read Only"
      END IF
    NEXT lngR
    '
    MLG_ArrayRedim(hGrid4, lngTotalRows, 2, lngTotalRows, 2)
    lngRow = 0
    FOR lngR = 1 TO lngTotalRows
      INCR lngRow
      MLG_Put hGrid4,lngRow,1,a_strStaff(lngR),lngRefresh
      MLG_Put hGrid4, lngRow,2,a_strPermission(lngR),lngRefresh
    NEXT lngR
    '
    DIALOG SHOW MODAL hDlg, CALL ShowAMENDPermissionsProc TO lRslt

#PBFORMS BEGIN CLEANUP %IDD_AMENDPermissions
#PBFORMS END CLEANUP

    FUNCTION = lRslt
END FUNCTION
'
CALLBACK FUNCTION ShowAMENDPermissionsProc()

  LOCAL strTeamname AS STRING

    SELECT CASE AS LONG CB.MSG
        CASE %WM_INITDIALOG
            ' Initialization handler

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
                CASE %IDC_STATUSBAR4
                '
                CASE %IDC_SAVEPermissions
                    IF CB.CTLMSG = %BN_CLICKED OR CB.CTLMSG = 1 THEN
                    ' user has clicked to update the grids
                      CONTROL SET TEXT CB.HNDL,%IDC_STATUSBAR4,"Amending Permissions"
                      CONTROL GET TEXT CB.HNDL,%IDC_TEAMNAME TO strTeamname
                      funUpdatePermissions(CB.HNDL, strTeamname)
                      CONTROL SET TEXT CB.HNDL,%IDC_STATUSBAR4,"Operation completed"
                      DIALOG END CB.HNDL, %IDOK
                    END IF
                    '
                CASE %IDABORT
                    IF CB.CTLMSG = %BN_CLICKED OR CB.CTLMSG = 1 THEN
                      DIALOG END CB.HNDL, %IDABORT
                    END IF
                    '
            END SELECT
    END SELECT
END FUNCTION
'
FUNCTION funUpdatePermissions(hDlg AS DWORD, BYVAL strTeamname AS STRING) AS LONG
' save the updated permissions
' get the grid from screen and save the results
  DIM a_strGrid() AS STRING
  REDIM a_strGrid(100,2) AS STRING
  LOCAL lngFile AS LONG
  LOCAL strFilename AS STRING
  LOCAL lngR AS LONG
  '
  ' get the grid to an array - then process
  MLG_GetEx hGrid4,a_strGrid()
  '
  REPLACE " " WITH "_" IN strTeamname
  '
  strFilename = EXE.PATH$ & "Data\Levels\" & strTeamName & ".ser"
  '
  lngFile = FREEFILE
  OPEN strFilename FOR OUTPUT AS #lngFile
  FOR lngR = 1 TO UBOUND(a_strGrid)
    IF a_strGrid(lngR,1) <> "" THEN
      PRINT#lngFile, a_strGrid(lngR,2) & "=" & a_strGrid(lngR,1)
    END IF
  NEXT lngR
  CLOSE #lngFile
  '
END FUNCTION
'
FUNCTION funGetPermissionStaffNames(BYVAL strTeamName AS STRING, BYREF a_strStaff() AS STRING, _
                                    BYREF a_strPermission() AS STRING) AS LONG
' get the permission names and levels
' and populate the arrays from the security file
  LOCAL strFilename AS STRING
  LOCAL lngFile AS LONG
  LOCAL strData AS STRING
  '
  REDIM a_strPermission(0) AS STRING
  REDIM a_strStaff(0) AS STRING
  '
  REPLACE " " WITH "_" IN strTeamname
  '
  strFilename = EXE.PATH$ & "Data\Levels\" & strTeamName & ".ser"
  lngFile = FREEFILE
  '
  OPEN strFilename FOR INPUT AS #lngFile
  WHILE ISFALSE(EOF(#lngFile))
    LINE INPUT #lngFile, strData
    REDIM PRESERVE a_strStaff(UBOUND(a_strStaff)+1) AS STRING
    a_strStaff(UBOUND(a_strStaff)) = PARSE$(strData,"=",2)
    REDIM PRESERVE a_strPermission(UBOUND(a_strPermission)+1) AS STRING
    a_strPermission(UBOUND(a_strPermission)) = PARSE$(strData,"=",1)
  WEND
  CLOSE #lngFile
'
END FUNCTION



FUNCTION funUpdateResource(hDlg AS DWORD) AS LONG
' update the specified resources
' first get the data from the grid
  DIM a_strStaff() AS STRING
  DIM a_strGrid() AS STRING
  DIM a_strHeadCount() AS STRING
  LOCAL lngR AS LONG
  LOCAL lngDB AS LONG
  LOCAL lngRows AS LONG
  LOCAL lngCount AS LONG
  LOCAL strUser AS STRING
  '
  REDIM a_strStaff(1) AS STRING
  REDIM a_strHeadCount(1) AS STRING
  '
  funGetStaffNames(a_strStaff(), a_strHeadCount())
  REDIM a_strGrid(UBOUND(a_strStaff),2) AS STRING
  '
  MLG_GetEx hGrid3,a_strGrid()
  '
  FOR lngR = 1 TO UBOUND(a_strGrid)
    'CONTROL SET TEXT hDlg,%IDC_STATUSBAR4,"Entry " & FORMAT$(lngR) & " of " & FORMAT$(UBOUND(a_strGrid))
    lngDB = lngR + 1
    IF a_strGrid(lngR,1) = a_strStaff(lngDB) AND _
                         VAL(a_strGrid(lngR,2)) <> VAL(a_strHeadCount(lngDB)) THEN
    ' staff member matched & change detected
    ' look at the grid and mark lines where needed
      FOR lngCount = 1 TO 6
      ' select the work sheet
        SendMessage hGrid1, %MLG_SELECTSHEET, lngCount,0
        FOR lngRows = 1 TO glngGridRows
          strUser = MLG_Get(hGrid1,lngRows,1)
          IF strUser = a_strStaff(lngDB) THEN
            MLG_Put(hGrid1,lngRows,2, a_strGrid(lngR,2),1)
          END IF
        NEXT lngRows
        '
      NEXT lngCount
    '
    END IF
    'CONTROL SET TEXT hDlg,%IDC_STATUSBAR4,"Completed " & FORMAT$(lngR) & " of " & FORMAT$(UBOUND(a_strGrid))
  NEXT lngR
  '
  SendMessage hGrid1, %MLG_SELECTSHEET, 1,0
  '
END FUNCTION
'
FUNCTION funUKDate AS STRING
' return the current date in dd/mm/yyyy format
  DIM strDate AS STRING
  '
  strDate= DATE$
  '
  FUNCTION = MID$(strDate,4,2) & "/" & LEFT$(strDate,2) & "/" & RIGHT$(strDate,4)
END FUNCTION
'
FUNCTION funShortMonthName(strMonthNumber AS STRING) AS STRING
' return the short month name for the month number given
  DIM intMonthNumber AS INTEGER
  '
  intMonthNumber = VAL(strMonthNumber)
  '
  SELECT CASE intMonthNumber
    CASE 1
      FUNCTION = "Jan"
    CASE 2
      FUNCTION = "Feb"
    CASE 3
      FUNCTION = "Mar"
    CASE 4
      FUNCTION = "Apr"
    CASE 5
      FUNCTION = "May"
    CASE 6
      FUNCTION = "Jun"
    CASE 7
      FUNCTION = "Jul"
    CASE 8
      FUNCTION = "Aug"
    CASE 9
      FUNCTION = "Sep"
    CASE 10
      FUNCTION = "Oct"
    CASE 11
      FUNCTION = "Nov"
    CASE 12
      FUNCTION = "Dec"
    CASE ELSE
      FUNCTION = ""
    END SELECT
    '
END FUNCTION
'
FUNCTION SendStringToDiskAtLocation(strString AS STRING, strLocation AS STRING)AS LONG
  ' send the specified string to disk to the specified location
  DIM intfile AS INTEGER
  '
  TRY
    KILL strLocation
  CATCH
  FINALLY
  END TRY
  '
  TRY
    intFile = FREEFILE
    OPEN strLocation FOR OUTPUT AS #intFile
    PRINT#intFile, strString
    FUNCTION = %TRUE
  CATCH
    FUNCTION = %FALSE
  FINALLY
    CLOSE #intFile
  END TRY
  '
END FUNCTION
'
FUNCTION funReverseDate(strDate AS STRING) AS STRING
' return the date as YYYYMMDD where input is in form DD/MM/YYYY
  FUNCTION = RIGHT$(strDate,4) & MID$(strDate, 4,2) & LEFT$(strDate,2)
'
END FUNCTION

FUNCTION funIsUserAllowedAccess(strSecurityFile AS STRING) AS LONG
' does this user have access to this teams data
' return false if no access
  LOCAL lngFile AS LONG
  LOCAL strData AS STRING
  LOCAL strUser AS STRING
  LOCAL strFulluserName AS STRING
  LOCAL strOwner AS STRING
  '
  IF ISFALSE ISFILE(strSecurityFile) THEN
  ' file doesnt exist yet so allow access
    FUNCTION = %TRUE
    EXIT FUNCTION
  END IF
  '
  strUser = funCurrentUser
  g_strOwner = ""
  g_lngFullAccess = %FALSE
  '
  ' open the file and read looking for user entry
  lngFile = FREEFILE
  OPEN strSecurityFile FOR INPUT AS #lngFile
  WHILE ISFALSE(EOF(#lngFile))
    LINE INPUT #lngFile,strData
    '
    IF LCASE$(PARSE$(strData,"=",1)) = "owner" THEN
      strOwner = TRIM$(PARSE$(strData,"=",2))
      g_strOwner = strOwner
    END IF
    '
    IF PARSE$(strData,"=",2) = strUser THEN
    ' user found
      SELECT CASE LCASE$(PARSE$(strData,"=",1))
      CASE "owner"
        g_lngFullAccess = %TRUE
      CASE "read write"
        g_lngFullAccess = %TRUE
      CASE ELSE
        g_lngFullAccess = %FALSE
      END SELECT
      '
      FUNCTION = %TRUE
      CLOSE #lngFile
      EXIT FUNCTION
    END IF
  WEND
  '
  CLOSE #lngFile
  ' user not found
  g_lngFullAccess = %FALSE
  FUNCTION = %FALSE
  '
END FUNCTION
'
FUNCTION GetPDCName( strDomainName AS STRING ) AS STRING
 LOCAL pstrBuffer AS ASCIIZ PTR
 LOCAL ustrDomainName AS STRING
 LOCAL ustrServerName AS STRING
 ustrServerName = ""
 ustrDomainName = UCODE$( strDomainName )
 IF NETGETDCNAME( BYVAL STRPTR( ustrServerName ), BYVAL STRPTR( ustrDomainName ), pstrBuffer ) = %NERR_SUCCESS THEN
  FUNCTION = libUnicode_UnicodePtrToStr( pstrBuffer )
  NETAPIBUFFERFREE pstrBuffer
 ELSE
  FUNCTION = ""
 END IF
END FUNCTION
'
FUNCTION libUnicode_UnicodePtrToStr( BYVAL dwdConvert AS DWORD ) EXPORT AS STRING
 LOCAL lngLength AS LONG
 LOCAL strBuffer AS STRING
 lngLength = LSTRLENW( BYVAL dwdConvert )
 strBuffer = SPACE$( lngLength )
 WIDECHARTOMULTIBYTE 0, %NULL, BYVAL dwdConvert, lngLength, BYVAL STRPTR( strBuffer ), LEN( strBuffer ), BYVAL %NULL, BYVAL %NULL
 FUNCTION = strBuffer
END FUNCTION
'
FUNCTION GetUserFullName( strDomainAndUserName AS STRING ) AS STRING
 LOCAL pstructUserInfo10 AS USER_INFO_10 PTR
 LOCAL ustrAccountName AS STRING
 LOCAL ustrServerName AS STRING
 LOCAL strUsername AS STRING
 '
 'Convert the fields to unicode
 ustrServerName = UCODE$( GetPDCName( PARSE$( strDomainAndUserName, "\", 1 )))
 ustrAccountName = UCODE$( PARSE$( strDomainAndUserName, "\", 2 ))
 'Get the information if possible
 IF NETUSERGETINFO( BYVAL STRPTR( ustrServerName ), BYVAL STRPTR( ustrAccountName ), 10, pstructUserInfo10 ) = %NERR_SUCCESS THEN
   strUsername = libUnicode_UnicodePtrToStr( @pstructUserInfo10.usri10_full_name )
   NETAPIBUFFERFREE @pstructUserInfo10
   FUNCTION = strUsername
 END IF
END FUNCTION
