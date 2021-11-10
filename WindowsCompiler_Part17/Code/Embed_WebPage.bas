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

#COMPILE EXE "SVG_Charting.exe"
#DIM ALL

#RESOURCE VERSIONINFO
#RESOURCE FILEVERSION 1, 0, 0, 0
#RESOURCE PRODUCTVERSION 1, 0, 0, 0

#RESOURCE STRINGINFO "0409", "04B0"

#RESOURCE VERSION$ "CompanyName",      "GSF Software."
#RESOURCE VERSION$ "FileDescription",  "SVG Charting Utility"
#RESOURCE VERSION$ "FileVersion",      "01.00.0000"
#RESOURCE VERSION$ "InternalName",     "SVGChart"
#RESOURCE VERSION$ "OriginalFilename", "SVGChart.EXE"
#RESOURCE VERSION$ "LegalCopyright",   "Free for Use."
#RESOURCE VERSION$ "ProductName",      "SVGChart"
#RESOURCE VERSION$ "ProductVersion",   "01.00.0000"
#RESOURCE VERSION$ "Comments",         "This app allows you to create SVG Charts"

#RESOURCE ICON, MyAppIcon, "Pie Chart.ico"
%LoadApp = 4000
%SaveApp = 4001
%ExitApp = 4002

#RESOURCE ICON, 4000, "Load.ico"
#RESOURCE ICON, 4001, "Save.ico"
#RESOURCE ICON, 4002, "16_Cancel.ico"
'
GLOBAL g_hMenuPopup AS DWORD   ' menu globals
GLOBAL g_hMenu AS DWORD
'------------------------------------------------------------------------------
'   ** Includes **
'------------------------------------------------------------------------------
#PBFORMS BEGIN INCLUDES
#RESOURCE "Embed_WebPage.pbr"
%USEMACROS = 1
#INCLUDE ONCE "WIN32API.INC"
#INCLUDE ONCE "COMMCTRL.INC"
#INCLUDE ONCE "PBForms.INC"
#PBFORMS END INCLUDES
#INCLUDE ONCE "RichEdit.inc"
'------------------------------------------------------------------------------
#INCLUDE "..\Libraries\PB_HTML.inc"
#INCLUDE "..\Libraries\PB_Windows_Controls.inc"
#INCLUDE "..\Libraries\PB_FileHandlingRoutines.inc"
#INCLUDE "..\Libraries\PB_Common_Windows.inc"
#INCLUDE "..\Libraries\Menu.inc"
'------------------------------------------------------------------------------
'   ** Constants **
'------------------------------------------------------------------------------
#PBFORMS BEGIN CONSTANTS
%IDM_FILE_LOADTEMPLATE  = 1003
%IDM_FILE_SAVEATEMPLATE = 1004
%IDM_FILE_EXIT          = 1005
%IDD_dlgReporter        =  101
%IDABORT                =    3
%IDOK                   =    1
%IDC_btnBuildChart      = 1002
%IDR_MENU1              =  102
%IDR_ACCELERATOR1       =  103
%IDM_EDIT_TESTMENU      = 1006
#PBFORMS END CONSTANTS
'------------------------------------------------------------------------------
#RESOURCE RCDATA, 4000,"Demo.css"
'------------------------------------------------------------------------------
'   ** Declarations **
'------------------------------------------------------------------------------
DECLARE FUNCTION AttachMENU1(BYVAL hDlg AS DWORD) AS DWORD
DECLARE FUNCTION AttachACCELERATOR1(BYVAL hDlg AS DWORD) AS DWORD
DECLARE FUNCTION ASSIGNACCEL(tAccel AS ACCELAPI, BYVAL wKey AS WORD, BYVAL _
  wCmd AS WORD, BYVAL byFVirt AS BYTE) AS LONG
#PBFORMS DECLARATIONS
'------------------------------------------------------------------------------

'------------------------------------------------------------------------------
'   ** Main Application Entry Point **
'------------------------------------------------------------------------------
FUNCTION PBMAIN()
    PBFormsInitComCtls (%ICC_WIN95_CLASSES OR %ICC_DATE_CLASSES OR _
        %ICC_INTERNET_CLASSES)

    ShowHTMLReporter %HWND_DESKTOP
END FUNCTION
'------------------------------------------------------------------------------

'------------------------------------------------------------------------------
'   ** CallBacks **
'------------------------------------------------------------------------------
CALLBACK FUNCTION ShowHTMLReporterProc()
' https://www.gsfsoftware.co.uk/PBTutorials/Projects.htm
    LOCAL strURL AS STRING
    LOCAL lngMenuState AS LONG
    '
    SELECT CASE AS LONG CB.MSG
      CASE %WM_INITDIALOG
      ' Initialization handler
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
      CASE %WM_SYSCOMMAND
        IF (CB.WPARAM AND &HFFF0) = %SC_CLOSE THEN
          IF MSGBOX("Are you sure you wish to exit?" , _
                  %MB_YESNO,"Exit Application?") = %IDYES THEN
            FUNCTION = 0
            PostQuitMessage 0
          ELSE
            FUNCTION = 1
          END IF
        END IF
      '
      CASE %WM_COMMAND
      ' Process control notifications
        SELECT CASE AS LONG CB.CTL
          CASE %IDM_EDIT_TESTMENU
            IF CB.CTLMSG = %BN_CLICKED OR CB.CTLMSG = 1 THEN
              MENU GET STATE g_hMenu, BYCMD %IDM_EDIT_TESTMENU TO _
                 lngMenuState
              IF lngMenuState = %MFS_CHECKED THEN
                MENU SET STATE g_hMenu, BYCMD %IDM_EDIT_TESTMENU, _
                  %MFS_UNCHECKED
              ELSE
                MENU SET STATE g_hMenu, BYCMD %IDM_EDIT_TESTMENU, _
                  %MFS_CHECKED
              END IF
              '
            END IF
            '
          CASE %IDM_FILE_LOADTEMPLATE
            IF CB.CTLMSG = %BN_CLICKED OR CB.CTLMSG = 1 THEN
              MSGBOX "Loading",0 ,"Load menu"
            END IF
            '
          CASE %IDM_FILE_SAVEATEMPLATE
            IF CB.CTLMSG = %BN_CLICKED OR CB.CTLMSG = 1 THEN
              MSGBOX "Saving",0, "Save menu"
            END IF
            '

          CASE %IDABORT, %IDM_FILE_EXIT
            IF CB.CTLMSG = %BN_CLICKED OR CB.CTLMSG = 1 THEN
              IF MSGBOX("Are you sure you wish to exit?" , _
                  %MB_YESNO,"Exit Application?") = %IDYES THEN
                DIALOG END CB.HNDL, %IDOK
              END IF
            END IF
          '
          CASE %IDC_btnBuildChart
            IF CB.CTLMSG = %BN_CLICKED OR CB.CTLMSG = 1 THEN
              strURL = funTempDirectory & "Report.html"
              funBuildReport(strURL)
              IF ISTRUE funSaveCSS(funTempDirectory & "Demo.css") THEN
                funPopulateHTML(CB.HNDL,strURL,%ID_OCX)
              ELSE
                MSGBOX "Unable to show HTML - CSS problem",0, "CSS issue"
              END IF
            END IF
            '
       END SELECT
    END SELECT
END FUNCTION
'------------------------------------------------------------------------------
FUNCTION funSaveCSS(strFile AS STRING) AS LONG
' save the CSS file to the specified directory
  LOCAL strCSS AS STRING
  LOCAL lngFile AS LONG
  '
  TRY
    strCSS = RESOURCE$(RCDATA,4000)
    lngFile = FREEFILE
    OPEN strFile FOR OUTPUT AS lngFile
    PRINT #lngFile, strCSS;
    FUNCTION = %TRUE
  CATCH
    FUNCTION = %FALSE
  FINALLY
    CLOSE #lngFile
  END TRY
  '
END FUNCTION
'------------------------------------------------------------------------------
'   ** Dialogs **
'------------------------------------------------------------------------------
FUNCTION ShowHTMLReporter(BYVAL hParent AS DWORD) AS LONG
  LOCAL lRslt AS LONG
  '
#PBFORMS BEGIN DIALOG %IDD_dlgReporter->%IDR_MENU1->%IDR_ACCELERATOR1
  LOCAL hDlg  AS DWORD

  DIALOG NEW hParent, "HTML Charting", 212, 94, 843, 453, %WS_POPUP OR _
    %WS_BORDER OR %WS_DLGFRAME OR %WS_CAPTION OR %WS_SYSMENU OR _
    %WS_MINIMIZEBOX OR %WS_CLIPSIBLINGS OR %WS_VISIBLE OR %DS_MODALFRAME OR _
    %DS_CENTER OR %DS_3DLOOK OR %DS_NOFAILCREATE OR %DS_SETFONT, _
    %WS_EX_CONTROLPARENT OR %WS_EX_LEFT OR %WS_EX_LTRREADING OR _
    %WS_EX_RIGHTSCROLLBAR, TO hDlg
  CONTROL ADD BUTTON, hDlg, %IDABORT, "Exit", 745, 405, 50, 15
  CONTROL ADD BUTTON, hDlg, %IDC_btnBuildChart, "Build A Chart", 20, 405, 75, _
    15

  AttachMENU1 hDlg

  AttachACCELERATOR1 hDlg
#PBFORMS END DIALOG
  '
  LOCAL lngMenuItem AS LONG
  LOCAL lngIconNumber AS LONG
  LOCAL lngBitmapSize AS LONG
  lngBitmapSize = 16
  '
  lngIconNumber = 1
  lngMenuItem   = 0
  funSetMenuIcon(hDlg, g_hMenuPopup, lngMenuItem, lngIconNumber,lngBitmapSize)
  '
  lngIconNumber = 2
  lngMenuItem   = 1
  funSetMenuIcon(hDlg, g_hMenuPopup, lngMenuItem, lngIconNumber,lngBitmapSize)
  '
  lngIconNumber = 3
  lngMenuItem   = 3
  funSetMenuIcon(hDlg, g_hMenuPopup, lngMenuItem, lngIconNumber,lngBitmapSize)


  '
  LOCAL lngHeight AS LONG
  LOCAL lngWidth AS LONG
  LOCAL lngXstart AS LONG
  LOCAL lngYstart AS LONG
  '
  DIALOG GET SIZE hDlg TO lngWidth, lngHeight
  '
  lngXstart = 160 : lngYStart = 10
  lngHeight = lngHeight - lngYstart -70
  lngWidth = lngWidth - 200
  '
  mPrepHTML(hDlg, lngXstart, lngYstart, lngHeight, lngWidth)
  '
  DIALOG SET ICON hDlg, "MyAppIcon"
  DIALOG SHOW MODAL hDlg, CALL ShowHTMLReporterProc TO lRslt

#PBFORMS BEGIN CLEANUP %IDD_dlgReporter
#PBFORMS END CLEANUP

    FUNCTION = lRslt
END FUNCTION
'------------------------------------------------------------------------------
FUNCTION funBuildReport(strFile AS STRING) AS LONG
' build a local html report
  LOCAL strHTML AS STRING
  LOCAL strData AS STRING
  LOCAL strFilename AS STRING
  DIM a_strData() AS STRING
  LOCAL lngR AS LONG
  LOCAL lngC AS LONG
  '
  strFilename = EXE.PATH$ & "MyLargeFile.txt"
  '
  strHTML = "<html>" & _
            "<head><link href=" & $DQ & "Demo.css" & $DQ & _
            " rel= " & $DQ & "stylesheet" & $DQ & "></head>" & _
            "<body><table border=1>"
  '
  IF ISTRUE funReadTheFileIntoAnArray(strFilename, _
                               BYREF a_strData()) THEN
    FOR lngR = 0 TO UBOUND(a_strData)
      strData = a_strData(lngR)
      IF lngR = 0 THEN
        strHTML = strHTML & "<tr class=""AListHeader"">"
      ELSE
        IF lngR MOD 2 THEN
          strHTML = strHTML & "<tr class=""NewBandingEven"">"
        ELSE
          strHTML = strHTML & "<tr class=""NewBandingOdd"">"
        END IF
      END IF
      '
      FOR lngC = 1 TO PARSECOUNT(strData,$TAB)
        strHTML = strHTML & "<td>" & _
                  PARSE$(strData,$TAB,lngC) & _
                  "</td>"
      NEXT lngC
      '
      strHTML = strHTML & "</tr>" & $CRLF
    NEXT lngR
    '
    strHTML = strHTML & "</table></body></html>"
    '
    TRY
      KILL strFile
    CATCH
    FINALLY
    END TRY
    '
    funAppendToFile(strFile, strHTML)
    FUNCTION = %TRUE
    '
  ELSE
    FUNCTION = %FALSE
  END IF
  '
END FUNCTION
'------------------------------------------------------------------------------
FUNCTION AttachMENU1(BYVAL hDlg AS DWORD) AS DWORD
#PBFORMS BEGIN MENU %IDR_MENU1->%IDD_dlgReporter
  LOCAL hMenu   AS DWORD
  LOCAL hPopUp1 AS DWORD
  LOCAL hPopUp2 AS DWORD

  MENU NEW BAR TO hMenu
  MENU NEW POPUP TO hPopUp1
  MENU ADD POPUP, hMenu, "File", hPopUp1, %MF_ENABLED
    MENU ADD STRING, hPopUp1, "Load Template" & $TAB & "L", _
      %IDM_FILE_LOADTEMPLATE, %MF_ENABLED
    MENU ADD STRING, hPopUp1, "Save a Template" & $TAB & "S", _
      %IDM_FILE_SAVEATEMPLATE, %MF_ENABLED
    MENU ADD STRING, hPopUp1, "-", 0, 0
    MENU ADD STRING, hPopUp1, "Exit", %IDM_FILE_EXIT, %MF_ENABLED
  MENU NEW POPUP TO hPopUp2
  MENU ADD POPUP, hMenu, "Edit", hPopUp2, %MF_ENABLED
      MENU ADD STRING, hPopUp2, "Test Menu", %IDM_EDIT_TESTMENU, %MF_CHECKED

  MENU ATTACH hMenu, hDlg
#PBFORMS END MENU
  '
  g_hMenu = hMenu
  g_hMenuPopup = hPopUp1
  '
  FUNCTION = hMenu
END FUNCTION
'------------------------------------------------------------------------------

'------------------------------------------------------------------------------
FUNCTION AttachACCELERATOR1(BYVAL hDlg AS DWORD) AS DWORD
#PBFORMS BEGIN ACCEL %IDR_ACCELERATOR1->%IDD_dlgReporter
  LOCAL hAccel   AS DWORD
  LOCAL tAccel() AS ACCELAPI
  DIM   tAccel(1 TO 2) AS ACCELAPI

  ASSIGNACCEL tAccel(1), ASC("L"), %IDM_FILE_LOADTEMPLATE, %FVIRTKEY OR _
    %FNOINVERT
  ASSIGNACCEL tAccel(2), ASC("S"), %IDM_FILE_SAVEATEMPLATE, %FVIRTKEY OR _
    %FNOINVERT

  ACCEL ATTACH hDlg, tAccel() TO hAccel
#PBFORMS END ACCEL
  FUNCTION = hAccel
END FUNCTION
'------------------------------------------------------------------------------

'------------------------------------------------------------------------------
#PBFORMS BEGIN ASSIGNACCEL
FUNCTION ASSIGNACCEL(tAccel AS ACCELAPI, BYVAL wKey AS WORD, BYVAL wCmd AS _
  WORD, BYVAL byFVirt AS BYTE) AS LONG
  tAccel.fVirt = byFVirt
  tAccel.key   = wKey
  tAccel.cmd   = wCmd
END FUNCTION
#PBFORMS END ASSIGNACCEL
'------------------------------------------------------------------------------
