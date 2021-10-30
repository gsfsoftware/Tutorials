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
#DEBUG ERROR ON

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
GLOBAL g_lngTabcount AS LONG      ' total number of tabs
GLOBAL g_alngTabHandles() AS LONG ' array to hold tab handles
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
#INCLUDE "..\Libraries\Macros.inc"
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
%IDR_MENU1              =  102  '*
%IDR_ACCELERATOR1       =  103  '*
%IDM_EDIT_TESTMENU      = 1006
%IDC_lblTitle           = 1007
%IDC_txtTitle           = 1008
%IDC_lblWidth           = 1009
%IDC_txtWidth           = 1010
%IDC_LABEL1             = 1011  '*
%IDC_TEXTBOX1           = 1012  '*
%IDC_lblHeight          = 1013
%IDC_txtHeight          = 1014
%IDC_lblColourTester    = 1015
%IDC_lblBackground      = 1016
%IDC_TEXTBOX2           = 1017  '*
%IDC_TEXTBOX3           = 1018  '*
%IDC_txtColourStart     = 1019
%IDC_chkGradient        = 1021
%IDC_txtColourEnd       = 1020
%IDC_TAB1               = 1022
%IDC_lblColumns         = 1024
%IDC_txtColumns         = 1023
#PBFORMS END CONSTANTS

ENUM tabs SINGULAR
  ID_Tab1_lbColumn1 = 2000
  ID_Tab1_lbColumn2
  ID_Tab1_lbColumn3
  ID_Tab1_lbColumn4
  ID_Tab1_lbColumn5
  ID_Tab1_lbColumn6
  ID_Tab1_lbColumn7
  ID_Tab1_lbColumn8
  ID_Tab1_lbColumn9
END ENUM

%VAL_STRING = 1
%VAL_NUMBER = 2

%IDC_colTitleFG = 5000    ' handle of the chart title colour picker
%IDC_colTitleBK = 5001    ' handle for the colour picker for background
%IDC_fontTitle  = 5002    ' handle for the font picker
%IDC_fontTitlePicked = 5003 ' handle for the text box containing the
'                             font currently picked
%IDC_colColourStart = 5004 ' handle for the 1st background chart colour
%IDC_colColourEnd   = 5005 ' handle for the 2nd background chart colour
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
    funInitialiseFonts()
    ShowHTMLReporter %HWND_DESKTOP
END FUNCTION
'------------------------------------------------------------------------------

'------------------------------------------------------------------------------
'   ** CallBacks **
'------------------------------------------------------------------------------
CALLBACK FUNCTION funTabEventHandler()
' handle the events on the tab
  SELECT CASE AS LONG CB.MSG
    CASE %WM_COMMAND
      SELECT CASE AS LONG CB.CTL
      ' handle each control on the tab
      '
      END SELECT
  END SELECT
'
END FUNCTION

CALLBACK FUNCTION ShowHTMLReporterProc()
' https://www.gsfsoftware.co.uk/PBTutorials/Projects.htm
    LOCAL strURL AS STRING
    LOCAL lngMenuState AS LONG
    LOCAL hFocusID AS LONG
    LOCAL strMacError AS STRING
    LOCAL lngState AS LONG
    LOCAL lngPageDlgVar AS LONG
    LOCAL lngTabs AS LONG
    LOCAL lngTab AS LONG
    LOCAL strTabs AS STRING
    LOCAL lngTotalTabs AS LONG
    '
    SELECT CASE AS LONG CB.MSG
      CASE %WM_INITDIALOG
      ' Initialization handler
        PREFIX "control hide cb.hndl,"
          %IDC_txtColourEnd
          %IDC_colColourEnd
        END PREFIX
        '
        mSetTextLimit(%IDC_txtColumns,1)
        '
        TAB INSERT PAGE CB.HNDL, %IDC_TAB1, 1, 0, "Column 1" _
          TO lngPageDlgVar
          '
          REDIM g_alngTabHandles(1) AS LONG
          g_alngTabHandles(1) = lngPageDlgVar
          '
          funInsertTabControls(CB.HNDL,%IDC_TAB1,1)
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
          CASE %IDC_txtColumns
          ' number of columns needed
            IF CB.CTLMSG = %EN_CHANGE THEN
            ' value has changed update tab array and tabs
            ' in g_alngTabHandles
            ' pick up the tabs value
              CONTROL GET TEXT CB.HNDL,%IDC_txtColumns TO strTabs
              lngTabs = VAL(strTabs)
              IF lngTabs = 0 THEN
              ' inform the user tabs must be >0
              '
              ELSE
                g_lngTabcount = UBOUND(g_alngTabHandles)
                '
                IF lngTabs < g_lngTabcount THEN
                ' reduction in tab count
                  FOR lngTab = g_lngTabcount TO lngTabs + 1 STEP -1
                    TAB DELETE CB.HNDL, %IDC_TAB1, lngTab
                  NEXT lngTab
                  '
                  REDIM PRESERVE g_alngTabHandles(lngTabs) AS LONG
                  g_lngTabcount = lngTabs
                '
                ELSE
                '
                  REDIM PRESERVE g_alngTabHandles(lngTabs) AS LONG
                  '
                  FOR lngTab = g_lngTabcount + 1 TO lngTabs
                  ' for each additional tab
                    TAB INSERT PAGE CB.HNDL, %IDC_TAB1, lngTab, 0, _
                       "Column " & FORMAT$(lngTab) _
                       TO lngPageDlgVar
                    '
                    g_alngTabHandles(lngTab) = lngPageDlgVar
                    '
                    funInsertTabControls(CB.HNDL,%IDC_TAB1,lngTab)
                  NEXT lngR
                END IF
              END IF
            '
            END IF
          '
          CASE %IDC_chkGradient
           IF CB.CTLMSG = %BN_CLICKED OR CB.CTLMSG = 1 THEN
             CONTROL GET CHECK CB.HNDL, CB.CTL TO lngState
             '
             SELECT CASE lngState
               CASE 0
               ' gradient is turned off
                 PREFIX "control hide cb.hndl,"
                   %IDC_txtColourEnd
                   %IDC_colColourEnd
                 END PREFIX
               CASE 1
               ' gradient is turned on
                 PREFIX "control normalize cb.hndl,"
                   %IDC_txtColourEnd
                   %IDC_colColourEnd
                 END PREFIX
             END SELECT
           END IF
           '
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
              hFocusID = 0
              IF ISTRUE funValidateForm(CB.HNDL, hFocusID, _
                        strMacError) THEN
                ' now build the chart
                strURL = funTempDirectory & "Report.html"
                funBuildChart(CB.HNDL, strURL)
                IF ISTRUE funSaveCSS(funTempDirectory & "Demo.css") THEN
                END IF
                '
                ' now show the web page
                ShellExecute 0, "open",funTempDirectory & "Report.html","","",%SW_SHOW


                ' test the colour picker
'                CONTROL SET COLOR CB.HNDL, %IDC_lblColourTester, _
'                    funGetColourPickerColour(CB.HNDL,%IDC_colTitle), -1
'                CONTROL REDRAW CB.HNDL,%IDC_lblColourTester
              '

              ELSE
              ' validation has failed
                macValidationWarning(strMacError)
                IF hFocusID <>0 THEN
                  CONTROL SET FOCUS CB.HNDL, hfocusID
                END IF
              '
              END IF
              '
            END IF
            '
       END SELECT
    END SELECT
END FUNCTION
'
MACRO macValidationWarning(strError)
  MSGBOX "Unfortunately validation has failed on this form with '" & _
         strError & "'." & $CRLF & _
         "The field that has failed validation will be indicated in RED" & _
         $CRLF & "Now click OK",%MB_ICONERROR OR %MB_TASKMODAL, _
         "Validation Error"
END MACRO
'
FUNCTION funValidateForm(hDlg AS DWORD, hFocusID AS LONG, _
                         strMacError AS STRING) AS LONG
' test for validation
  DIM a_lngText(3,2) AS LONG
  LOCAL lngR AS LONG
  LOCAL strValue AS STRING
  '
  a_lngText(1,0) = %IDC_txtTitle  ' field to be validated
  a_lngText(1,1) = %IDC_lblTitle  ' field to display colour error
  a_lngText(1,2) = %VAL_STRING    ' field is a string
  '
  a_lngText(2,0) = %IDC_txtWidth  ' field to be validated
  a_lngText(2,1) = %IDC_lblWidth  ' field to display colour error
  a_lngText(2,2) = %VAL_NUMBER    ' field is a string
  '
  a_lngText(3,0) = %IDC_txtHeight  ' field to be validated
  a_lngText(3,1) = %IDC_lblHeight  ' field to display colour error
  a_lngText(3,2) = %VAL_NUMBER    ' field is a string


  '
  FOR lngR = 1 TO UBOUND(a_lngText)
    CONTROL GET TEXT hDlg,a_lngText(lngR,0) TO strValue
    '
    SELECT CASE a_lngText(lngR,2)
      CASE %VAL_STRING
      ' string validation
        IF TRIM$(strValue) = "" THEN
        ' field is blank
          strMacError = "Mandatory item is empty"
          CONTROL SET COLOR hDlg,a_lngText(lngR,1),%RED,-1
          CONTROL REDRAW hDlg,a_lngText(lngR,1)
          hFocusID = a_lngText(lngR,0)
          FUNCTION = %FALSE
          EXIT FUNCTION
        ELSE
        ' field is populated
          CONTROL SET COLOR hDlg,a_lngText(lngR,1),%BLUE,-1
          CONTROL REDRAW hDlg,a_lngText(lngR,1)
        END IF
        '
      CASE %VAL_NUMBER
      ' its a number
        IF VAL(strValue) = 0 THEN
        ' field is zero
          strMacError = "Mandatory item is zero"
          CONTROL SET COLOR hDlg,a_lngText(lngR,1),%RED,-1
          CONTROL REDRAW hDlg,a_lngText(lngR,1)
          hFocusID = a_lngText(lngR,0)
          FUNCTION = %FALSE
          EXIT FUNCTION
        ELSE
        ' field is no zero
          CONTROL SET COLOR hDlg,a_lngText(lngR,1),%BLUE,-1
          CONTROL REDRAW hDlg,a_lngText(lngR,1)
        END IF
    END SELECT
  NEXT lngR
  '
  FUNCTION = %TRUE
  '
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
  LOCAL lngPageDlgVar AS LONG
  '
#PBFORMS BEGIN DIALOG %IDD_dlgReporter->->
  LOCAL hDlg  AS DWORD

  DIALOG NEW hParent, "HTML Charting", 210, 95, 685, 406, %WS_POPUP OR _
    %WS_BORDER OR %WS_DLGFRAME OR %WS_CAPTION OR %WS_SYSMENU OR _
    %WS_MINIMIZEBOX OR %WS_CLIPSIBLINGS OR %WS_VISIBLE OR %DS_MODALFRAME OR _
    %DS_CENTER OR %DS_3DLOOK OR %DS_NOFAILCREATE OR %DS_SETFONT, _
    %WS_EX_CONTROLPARENT OR %WS_EX_LEFT OR %WS_EX_LTRREADING OR _
    %WS_EX_RIGHTSCROLLBAR, TO hDlg
  CONTROL ADD TEXTBOX,  hDlg, %IDC_txtTitle, "", 20, 25, 100, 13
  CONTROL ADD TEXTBOX,  hDlg, %IDC_txtWidth, "0", 20, 60, 45, 13, %WS_CHILD _
    OR %WS_VISIBLE OR %WS_TABSTOP OR %ES_CENTER OR %ES_AUTOHSCROLL OR _
    %ES_NUMBER, %WS_EX_CLIENTEDGE OR %WS_EX_LEFT OR %WS_EX_LTRREADING OR _
    %WS_EX_RIGHTSCROLLBAR
  CONTROL ADD TEXTBOX,  hDlg, %IDC_txtHeight, "0", 75, 60, 45, 13, %WS_CHILD _
    OR %WS_VISIBLE OR %WS_TABSTOP OR %ES_CENTER OR %ES_AUTOHSCROLL OR _
    %ES_NUMBER, %WS_EX_CLIENTEDGE OR %WS_EX_LEFT OR %WS_EX_LTRREADING OR _
    %WS_EX_RIGHTSCROLLBAR
  CONTROL ADD BUTTON,   hDlg, %IDC_btnBuildChart, "Build A Chart", 10, 350, _
    75, 15
  CONTROL ADD BUTTON,   hDlg, %IDABORT, "Exit", 615, 350, 50, 15
  CONTROL ADD LABEL,    hDlg, %IDC_lblTitle, "Enter Title of the Chart", 20, _
    15, 100, 10
  CONTROL SET COLOR     hDlg, %IDC_lblTitle, %BLUE, -1
  CONTROL ADD LABEL,    hDlg, %IDC_lblWidth, "Chart Width", 20, 50, 50, 10
  CONTROL SET COLOR     hDlg, %IDC_lblWidth, %BLUE, -1
  CONTROL ADD LABEL,    hDlg, %IDC_lblHeight, "Chart Height", 75, 50, 50, 10
  CONTROL SET COLOR     hDlg, %IDC_lblHeight, %BLUE, -1
  CONTROL ADD LABEL,    hDlg, %IDC_lblBackground, "Chart Background Colour", _
    20, 90, 100, 10
  CONTROL SET COLOR     hDlg, %IDC_lblBackground, %BLUE, -1
  CONTROL ADD TEXTBOX,  hDlg, %IDC_txtColourStart, "", 20, 100, 25, 13, _
    %WS_CHILD OR %WS_VISIBLE OR %ES_LEFT OR %ES_AUTOHSCROLL OR %ES_READONLY, _
    %WS_EX_CLIENTEDGE OR %WS_EX_LEFT OR %WS_EX_LTRREADING OR _
    %WS_EX_RIGHTSCROLLBAR
  CONTROL SET COLOR     hDlg, %IDC_txtColourStart, -1, %WHITE
  CONTROL ADD TEXTBOX,  hDlg, %IDC_txtColourEnd, "", 135, 100, 25, 13, _
    %WS_CHILD OR %WS_VISIBLE OR %ES_LEFT OR %ES_AUTOHSCROLL OR %ES_READONLY, _
    %WS_EX_CLIENTEDGE OR %WS_EX_LEFT OR %WS_EX_LTRREADING OR _
    %WS_EX_RIGHTSCROLLBAR
  CONTROL SET COLOR     hDlg, %IDC_txtColourEnd, -1, %WHITE
  CONTROL ADD CHECKBOX, hDlg, %IDC_chkGradient, "Gradient fill", 70, 103, 55, _
    11
  CONTROL ADD TAB,      hDlg, %IDC_TAB1, "Tab1", 20, 135, 645, 205, %WS_CHILD _
    OR %WS_VISIBLE OR %WS_TABSTOP OR %TCS_TABS OR %TCS_FIXEDWIDTH, _
    %WS_EX_LEFT
  CONTROL ADD TEXTBOX,  hDlg, %IDC_txtColumns, "1", 285, 100, 50, 15, _
    %WS_CHILD OR %WS_VISIBLE OR %WS_TABSTOP OR %ES_CENTER OR %ES_AUTOHSCROLL _
    OR %ES_NUMBER, %WS_EX_CLIENTEDGE OR %WS_EX_LEFT OR %WS_EX_LTRREADING OR _
    %WS_EX_RIGHTSCROLLBAR
  CONTROL ADD LABEL,    hDlg, %IDC_lblColumns, "How Many Columns are there to " + _
    "be?", 255, 90, 120, 10
  CONTROL SET COLOR     hDlg, %IDC_lblColumns, %BLUE, -1
#PBFORMS END DIALOG
  '


  '
  AttachMENU1 hDlg
  AttachACCELERATOR1 hDlg
  '
  ' create and set the foreground colour picker
  LOCAL u_ctlColourParams AS ctlColourParams
  PREFIX "u_ctlColourParams."
    hDlg = hDlg
    lngRootControlHandle = %IDC_txtTitle
    lngPaintHandle = %IDC_txtTitle
    lngCtlHandle = %IDC_colTitleFG
    lngColourZone = %ctlForeGroundColour
  END PREFIX
  funPlaceColourPicker(u_ctlColourParams)
  '
  ' now create the background colour picker
  PREFIX "u_ctlColourParams."
    hDlg = hDlg
    lngRootControlHandle = %IDC_colTitleFG
    lngPaintHandle = %IDC_txtTitle
    lngCtlHandle = %IDC_colTitleBK
    lngColourZone = %ctlBackGroundColour
  END PREFIX
  funPlaceColourPicker(u_ctlColourParams)
  '
  ' now create the font picker
  LOCAL u_ctlFontParams AS ctlFontParams
  PREFIX "u_ctlFontParams."
    hDlg = hDlg
    lngRootControlHandle = %IDC_colTitleBK
    lngPaintHandle = %IDC_txtTitle
    lngCtlHandle = %IDC_fontTitle
    lngFontNumber = 1
    lngFontPicked = %IDC_fontTitlePicked
  END PREFIX
  funPlaceFontPicker(u_ctlFontParams)
  '
  ' place the colour picker for the gradient start
  PREFIX "u_ctlColourParams."
    hDlg = hDlg
    lngRootControlHandle = %IDC_txtColourStart
    lngPaintHandle = %IDC_txtColourStart
    lngCtlHandle = %IDC_colColourStart
    lngColourZone = %ctlBackGroundColour
  END PREFIX
  funPlaceColourPicker(u_ctlColourParams)
  '
  ' place the colour picker for the gradient end
  PREFIX "u_ctlColourParams."
    hDlg = hDlg
    lngRootControlHandle = %IDC_txtColourEnd
    lngPaintHandle = %IDC_txtColourEnd
    lngCtlHandle = %IDC_colColourEnd
    lngColourZone = %ctlBackGroundColour
  END PREFIX
  funPlaceColourPicker(u_ctlColourParams)




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
'  LOCAL lngHeight AS LONG
'  LOCAL lngWidth AS LONG
'  LOCAL lngXstart AS LONG
'  LOCAL lngYstart AS LONG
'  '
'  DIALOG GET SIZE hDlg TO lngWidth, lngHeight
'  '
'  lngXstart = 160 : lngYStart = 10
'  lngHeight = lngHeight - lngYstart -70
'  lngWidth = lngWidth - 200
'  '
'  mPrepHTML(hDlg, lngXstart, lngYstart, lngHeight, lngWidth)
  '
  DIALOG SET ICON hDlg, "MyAppIcon"
  DIALOG SHOW MODAL hDlg, CALL ShowHTMLReporterProc TO lRslt

#PBFORMS BEGIN CLEANUP %IDD_dlgReporter
#PBFORMS END CLEANUP

    FUNCTION = lRslt
END FUNCTION
'------------------------------------------------------------------------------
FUNCTION funBuildChart(hDlg AS DWORD, _
                       strFile AS STRING) AS LONG
' build a local html report
  LOCAL strHTML AS STRING
  '
  LOCAL strHeight AS STRING
  LOCAL strWidth AS STRING
  LOCAL strTitle AS STRING
  LOCAL strTitleFont AS STRING
  LOCAL strTitleFontSize AS STRING
  LOCAL strTitleX AS STRING
  LOCAL strTitleY AS STRING
  '
  LOCAL strTemp AS STRING
  '
  LOCAL x1 AS LONG
  LOCAL y1 AS LONG
  LOCAL x2 AS LONG
  LOCAL y2 AS LONG
  LOCAL lngWidth AS LONG
  LOCAL lngHeight AS LONG
  '
  LOCAL lngTopMargin AS LONG
  LOCAL lngLeftMargin AS LONG
  LOCAL lngBottomMargin AS LONG
  LOCAL lngRightMargin AS LONG
  LOCAL lngLineWidth AS LONG
  '
  LOCAL strTitleColour AS STRING
  LOCAL lngTitleColour AS LONG
  '
  LOCAL lngStartColour AS LONG
  LOCAL lngEndColour AS LONG
  '
  lngTopMargin = 60
  lngLeftMargin = 40
  lngBottomMargin = 25
  lngRightMargin = 25
  lngLineWidth = 4
  '
  ' get the values
  strHeight = funGetTextValue(hDlg,%IDC_txtHeight)  '   "200"
  strWidth  = funGetTextValue(hDlg,%IDC_txtWidth)  '"500"
  strTitle  = funGetTextValue(hDlg,%IDC_txtTitle)  '"This is the title"
  ' now get the font details - {Verdana. Regular. 12pt.}
  strTemp = funGetTextValue(hDlg,%IDC_fontTitlePicked)
  strTitleFont = PARSE$(strTemp,".",1)   '"Verdana"
  strTitleFontSize = PARSE$(strTemp,".",3)  '"48"
  strTitleX = "50"
  strTitleY = "50"
  '
  strHTML = "<html>" & _
            "<head><link href=" & $DQ & "Demo.css" & $DQ & _
            " rel= " & $DQ & "stylesheet" & $DQ & "></head>" & _
            "<body>"
            '
  strHTML = strHTML & "<svg height=" & $DQ & strHeight & $DQ & _
                          " width=" & $DQ & strWidth & $DQ & ">"
  ' set the gradients
  lngStartColour = funGetColourPickerColour(hDlg,%IDC_colColourStart, _
                                            %ctlBackgroundColour)
  lngEndColour   = funGetColourPickerColour(hDlg,%IDC_colColourEnd, _
                                            %ctlBackgroundColour)
  '
  strHTML = strHTML & "<defs>" & _
                      funSetGradients(lngStartColour, lngEndColour) & _
                      "</defs>"
  '
  lngTitleColour = funGetColourPickerColour(hDlg,%IDC_colTitleFG, _
                                            %ctlForegroundColour)
  strTitleColour = HEX$(BGR(lngTitleColour),6)
  '
  strHTML = strHTML & "<text font-size=" & $DQ & strTitleFontSize & $DQ & _
                      " fill=" & $DQ & "#" & strTitleColour & $DQ & _
                      " font-family=" & $DQ & strTitleFont & $DQ & _
                      " x=" & $DQ & strTitleX & $DQ & _
                      " y=" & $DQ & strTitleY & $DQ & _
                      ">" & strTitle & "</text>"
                      '
  ' place the body of the grid
  ' draw the background
 x1 = lngLeftMargin
 y1 = lngTopMargin
 lngWidth = VAL(strWidth) - lngRightMargin - lngLeftMargin
 lngHeight = VAL(strHeight) - lngBottomMargin - lngTopMargin
 '
 strHTML = strHTML & funDrawBox(x1,y1,lngWidth, lngHeight,"grad1")
 '
 ' draw the axis
 ' first the horizontal
 x1 = lngLeftMargin
 y1 = VAL(strHeight) - lngBottomMargin
 x2 = VAL(strWidth) - lngRightMargin
 y2 = VAL(strHeight) - lngBottomMargin
 strHTML = strHTML & funDrawLine(x1,y1,x2,y2,lngLineWidth)
 ' then the vertical
 x1 = lngLeftMargin
 y1 = VAL(strHeight) - lngBottomMargin + (lngLineWidth/2)
 x2 = lngLeftMargin
 y2 = lngTopMargin
 strHTML = strHTML & funDrawLine(x1,y1,x2,y2,lngLineWidth)
 '
 strHTML = strHTML & "sorry your browser does not support inline SVG." & _
                     "</svg>" & _
                     "</body></html>"
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
END FUNCTION
'
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

  LOCAL hMenu   AS DWORD
  LOCAL hPopUp1 AS DWORD
  LOCAL hPopUp2 AS DWORD

  MENU NEW BAR TO hMenu
  MENU NEW POPUP TO hPopUp1
  MENU ADD POPUP, hMenu, "File", hPopUp1, %MF_ENABLED
    MENU ADD STRING, hPopUp1, "Load Template" & $TAB & "Ctrl+L", _
      %IDM_FILE_LOADTEMPLATE, %MF_ENABLED
    MENU ADD STRING, hPopUp1, "Save a Template" & $TAB & "Ctrl+S", _
      %IDM_FILE_SAVEATEMPLATE, %MF_ENABLED
    MENU ADD STRING, hPopUp1, "-", 0, 0
    MENU ADD STRING, hPopUp1, "Exit", %IDM_FILE_EXIT, %MF_ENABLED
  MENU NEW POPUP TO hPopUp2
  MENU ADD POPUP, hMenu, "Edit", hPopUp2, %MF_ENABLED
      MENU ADD STRING, hPopUp2, "Test Menu", %IDM_EDIT_TESTMENU, %MF_CHECKED

  MENU ATTACH hMenu, hDlg

  '
  g_hMenu = hMenu
  g_hMenuPopup = hPopUp1
  '
  FUNCTION = hMenu
END FUNCTION
'------------------------------------------------------------------------------

'------------------------------------------------------------------------------
FUNCTION AttachACCELERATOR1(BYVAL hDlg AS DWORD) AS DWORD

  LOCAL hAccel   AS DWORD
  LOCAL tAccel() AS ACCELAPI
  DIM   tAccel(1 TO 2) AS ACCELAPI

  ASSIGNACCEL tAccel(1), ASC("L"), %IDM_FILE_LOADTEMPLATE, %FVIRTKEY OR _
    %FNOINVERT OR %FCONTROL
  ASSIGNACCEL tAccel(2), ASC("S"), %IDM_FILE_SAVEATEMPLATE, %FVIRTKEY OR _
    %FNOINVERT OR %FCONTROL

  ACCEL ATTACH hDlg, tAccel() TO hAccel

  FUNCTION = hAccel
END FUNCTION
'------------------------------------------------------------------------------

'------------------------------------------------------------------------------

FUNCTION ASSIGNACCEL(tAccel AS ACCELAPI, BYVAL wKey AS WORD, BYVAL wCmd AS _
  WORD, BYVAL byFVirt AS BYTE) AS LONG
  tAccel.fVirt = byFVirt
  tAccel.key   = wKey
  tAccel.cmd   = wCmd
END FUNCTION

'------------------------------------------------------------------------------
FUNCTION funSetGradients(lngStartColour AS LONG, _
                         lngEndColour AS LONG ) AS STRING
' define the SVG gradients
  LOCAL strGradient AS STRING
  '
  LOCAL strHexStart AS STRING
  LOCAL strHexEnd AS STRING
  '
  strHexStart =  HEX$(BGR(lngStartColour),6)
  strHexEnd   =  HEX$(BGR(lngEndColour),6)
  '
  strGradient = "<linearGradient id=""grad1"" x1=""0%"" y1=""0%"" x2=""100%"" y2=""0%"">" & _
      "<stop offset=""0%"" style=""stop-color:" & _
      "#" & strHexStart & ";stop-opacity:0.2"" />" & _
      "<stop offset=""100%"" style=""stop-color:" & _
      "#" & strHexEnd & ";stop-opacity:0.2"" />" & _
      "</linearGradient>"
  FUNCTION = strGradient
  '
END FUNCTION
'
FUNCTION funDrawBox(x1 AS LONG,y1 AS LONG _
                   ,lngWidth AS LONG, _
                    lngHeight AS LONG ,_
                    strGradient AS STRING) AS STRING

' draw a filled box
  LOCAL strBox AS STRING
  '
  strBox = "<rect x= " & $DQ & FORMAT$(x1) & $DQ & _
                " y=" & $DQ & FORMAT$(y1) & $DQ & _
                " rx=""0"" ry=""0"" " & _
                " width=" & $DQ & FORMAT$(lngWidth) & $DQ & _
                " height=" & $DQ & FORMAT$(lngHeight) & $DQ & _
                " fill=""url(#" & strGradient & ")"" />"
  FUNCTION = strBox
  '
END FUNCTION
'
FUNCTION funDrawLine(x1 AS LONG ,y1 AS LONG , _
                     x2 AS LONG ,y2 AS LONG , _
                     lngLineWidth AS LONG) AS STRING
' draw a line
  LOCAL strLine AS STRING
  '
  strLine = "<line x1=" & $DQ & FORMAT$(x1) & $DQ & _
                 " y1=" & $DQ & FORMAT$(y1) & $DQ & _
                 " x2=" & $DQ & FORMAT$(x2) & $DQ & _
                 " y2=" & $DQ & FORMAT$(y2) & $DQ & _
                 " style=" & $DQ & "stroke:#0074d9; stroke-width:" & _
                 FORMAT$(lngLineWidth) & $DQ & "/>"
  FUNCTION = strLine

END FUNCTION
'
FUNCTION funInsertTabControls(hDlg AS DWORD, _
                              lngTabControl AS LONG, _
                              lngPage AS LONG) AS LONG
' add controls to the tab
  LOCAL lngTabHandle AS LONG
  lngTabHandle = g_alngTabHandles(lngPage)
  LOCAL lngTabLabel AS LONG
  '
  lngTabLabel = %ID_Tab1_lbColumn1 + lngPage -1
  '
  CONTROL ADD LABEL, lngTabHandle ,lngTabLabel, "Enter the name for column " & _
             FORMAT$(lngPage)  _
             ,10,20,100,12
  CONTROL SET COLOR lngTabHandle , lngTabLabel, %BLUE,-1

'
END FUNCTION

              