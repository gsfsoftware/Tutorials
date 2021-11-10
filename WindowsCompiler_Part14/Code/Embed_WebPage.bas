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
#RESOURCE "Embed_WebPage.pbr"
%USEMACROS = 1
#INCLUDE ONCE "WIN32API.INC"
#INCLUDE ONCE "COMMCTRL.INC"
#INCLUDE ONCE "PBForms.INC"
#PBFORMS END INCLUDES
#INCLUDE ONCE "richedit.inc"
'------------------------------------------------------------------------------
#INCLUDE "..\Libraries\PB_HTML.inc"
#INCLUDE "..\Libraries\PB_Windows_Controls.inc"
#INCLUDE "..\Libraries\PB_FileHandlingRoutines.inc"
#INCLUDE "..\Libraries\PB_Common_Windows.inc"
'------------------------------------------------------------------------------
'   ** Constants **
'------------------------------------------------------------------------------
#PBFORMS BEGIN CONSTANTS
%IDR_IMGFILE1       =  102
%IDR_IMGFILE2       =  103
%IDR_IMGFILE3       =  104
%IDD_dlgReporter    =  101
%IDABORT            =    3
%IDOK               =    1
%IDC_txtURL         = 1001
%IDC_btnBuildReport = 1002
%IDC_lblURL         = 1003
%IDC_TOOLBAR1       = 1004
%IDD_dlgTestDates   =  105
%IDC_datStartDate   = 1005
%IDC_datEndDate     = 1006
%IDC_lblStartDate   = 1007
%IDC_lblEnddate     = 1008
#PBFORMS END CONSTANTS
'
%IDC_Richedit1      = 1500
' constants for Toolbar events
%IDC_TOOLBAR_Build   = 3000
%IDC_TOOLBAR_Help    = 3001
%IDC_TOOLBAR_Dates   = 3002
'------------------------------------------------------------------------------
#RESOURCE RCDATA, 4000,"Demo.css"
'------------------------------------------------------------------------------
'   ** Declarations **
'------------------------------------------------------------------------------
DECLARE CALLBACK FUNCTION ShowdlgTestDatesProc()
DECLARE FUNCTION ShowdlgTestDates(BYVAL hDlg AS DWORD) AS LONG
#PBFORMS DECLARATIONS
'------------------------------------------------------------------------------
' constants for icons
%IDR_BuildIcon = 2000
%IDR_HelpIcon  = 2001
%IDR_Dates     = 2002

#RESOURCE ICON, 2000,"Build.ico"
#RESOURCE ICON, 2001,"Help.ico"
#RESOURCE ICON, 2002,"Dates.ico"

GLOBAL hLib AS DWORD   ' used for library handle
GLOBAL hFont1 AS DWORD ' used for fonts
'------------------------------------------------------------------------------
'   ** Main Application Entry Point **
'------------------------------------------------------------------------------
FUNCTION PBMAIN()
    PBFormsInitComCtls (%ICC_WIN95_CLASSES OR %ICC_DATE_CLASSES OR _
        %ICC_INTERNET_CLASSES)
    funCreateFonts()
    ShowHTMLReporter %HWND_DESKTOP
    funDestroyFonts()
END FUNCTION
'------------------------------------------------------------------------------
FUNCTION funCreateFonts() AS LONG
  FONT NEW "Helvetica", 14, 0, %ANSI_CHARSET TO hFont1
END FUNCTION
'
FUNCTION funDestroyFonts() AS LONG
  FONT END hFont1
END FUNCTION
'------------------------------------------------------------------------------
'   ** CallBacks **
'------------------------------------------------------------------------------
CALLBACK FUNCTION ShowHTMLReporterProc()
' https://www.gsfsoftware.co.uk/PBTutorials/Projects.htm
    LOCAL strURL AS STRING
    LOCAL lpNmhDRPrt AS NMHDR PTR
    '
    SELECT CASE AS LONG CB.MSG
      CASE %WM_INITDIALOG
      ' Initialization handler
        CONTROL HIDE CB.HNDL, %IDC_btnBuildReport
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
      CASE %WM_DESTROY
      ' form is being unloaded
        IF hLib <> 0 THEN
          FreeLibrary hLib
        END IF
      '
      CASE %WM_NOTIFY
      ' process notifications
        lpNmhDRPrt = CB.LPARAM ' get a pointer to the NMHDR structure
        IF @lpNmhDRPrt.idfrom = %IDC_RichEdit1 THEN
          SELECT CASE @lpNmhDRPrt.code
            CASE %EN_Link
              FUNCTION = funRichEd_HyperLink_HandleURL(CB.HNDL,CB.LPARAM,%IDC_RichEdit1)
              EXIT FUNCTION
          END SELECT
        END IF
        '
      CASE %WM_COMMAND
      ' Process control notifications
        SELECT CASE AS LONG CB.CTL
          CASE %IDABORT
            IF CB.CTLMSG = %BN_CLICKED OR CB.CTLMSG = 1 THEN
              DIALOG END CB.HNDL, %IDOK
            END IF

          CASE %IDOK
            IF CB.CTLMSG = %BN_CLICKED OR CB.CTLMSG = 1 THEN
              CONTROL GET TEXT CB.HNDL,%IDC_txtURL TO strURL
              IF TRIM$(strURL) <> "" THEN
                funPopulateHTML(CB.HNDL,strURL,%ID_OCX)
              END IF
            END IF
            '
          CASE %IDC_txtURL
          '
          CASE %IDC_TOOLBAR_Dates
            IF CB.CTLMSG = %BN_CLICKED OR CB.CTLMSG = 1 THEN
              ShowdlgTestDates CB.HNDL
            END IF
            '
          CASE %IDC_btnBuildReport, %IDC_TOOLBAR_Build
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
  LOCAL lngOffset AS LONG
  '
#PBFORMS BEGIN DIALOG %IDD_dlgReporter->->
  LOCAL hDlg  AS DWORD

  DIALOG NEW hParent, "HTML Reporter", 228, 98, 672, 461, %WS_POPUP OR _
    %WS_BORDER OR %WS_DLGFRAME OR %WS_CLIPSIBLINGS OR %WS_VISIBLE OR _
    %DS_MODALFRAME OR %DS_CENTER OR %DS_3DLOOK OR %DS_NOFAILCREATE OR _
    %DS_SETFONT, %WS_EX_CONTROLPARENT OR %WS_EX_LEFT OR %WS_EX_LTRREADING OR _
    %WS_EX_RIGHTSCROLLBAR, TO hDlg
  CONTROL ADD BUTTON,  hDlg, %IDABORT, "Exit", 590, 425, 50, 15
  CONTROL ADD BUTTON,  hDlg, %IDOK, "Display the HTML page", 515, 65, 110, 15
  DIALOG  SEND         hDlg, %DM_SETDEFID, %IDOK, 0
  CONTROL ADD TEXTBOX, hDlg, %IDC_txtURL, "", 160, 66, 330, 13
  CONTROL ADD BUTTON,  hDlg, %IDC_btnBuildReport, "Build A Report", 20, 66, _
    75, 15
  CONTROL ADD LABEL,   hDlg, %IDC_lblURL, "Enter URL here ", 160, 56, 295, 10
  CONTROL SET COLOR    hDlg, %IDC_lblURL, %BLUE, -1
#PBFORMS END DIALOG
  '
  CONTROL ADD TOOLBAR, hDlg, %IDC_TOOLBAR1, "ToolBar1", 0, 0, 0, 0, %WS_CHILD _
    OR %WS_VISIBLE OR %WS_TABSTOP OR %CCS_TOP OR %TBSTYLE_FLAT
  '
  hLib = LoadLibrary("riched20.dll") :InitCommonControls
  IF hLib = 0 THEN
  ' cannot load the library
    MSGBOX "Unable to load the Richedit library", _
            %MB_ICONERROR OR %MB_TASKMODAL
  END IF
  '
  CONTROL ADD "RichEdit20A" , hDlg, %IDC_Richedit1,"",29,35,605,30, _
    %WS_CHILD OR %WS_VISIBLE OR %WS_TABSTOP OR %ES_LEFT OR _
    %ES_MULTILINE OR %ES_READONLY OR %ES_WANTRETURN, %WS_EX_LEFT OR _
    %WS_EX_LTRREADING OR %WS_EX_RIGHTSCROLLBAR
  ' give us a bigger font
  CONTROL SET FONT hDlg,%IDC_Richedit1, hFont1
  ' set the background color
  CONTROL SEND hDlg,%IDC_Richedit1, %EM_SETBKGNDCOLOR, 0, _
               RGB(239,239,239)
  ' auto detect the URL
  CONTROL SEND hDlg,%IDC_Richedit1, %EM_AutoUrlDetect, %TRUE,0
  ' get read to handle events
  CONTROL SEND hDlg,%IDC_Richedit1, %EM_SETEventMask,0,%ENM_LINK
  '
  CONTROL SET TEXT hDlg,%IDC_Richedit1,"To view all projects " & _
    "available click on " & _
    "our website link " & _
    "https:/www.gsfsoftware.co.uk/PBTutorials/Projects.htm " & _
    "or Phone Ext 1234 for more details"
    '
  lngOffset = 1
  funSetRTcolour(hDlg,%IDC_Richedit1,"Phone Ext 1234",%RED, lngOffset)
  funSetRTcolour(hDlg,%IDC_Richedit1,"details",%RGB_FORESTGREEN, lngOffset)
  '
  '
  funCreateToolbar  hDlg, %IDC_TOOLBAR1
  '
  LOCAL lngHeight AS LONG
  LOCAL lngWidth AS LONG
  LOCAL lngXstart AS LONG
  LOCAL lngYstart AS LONG
  '
  DIALOG GET SIZE hDlg TO lngWidth, lngHeight
  '
  lngXstart = 10 : lngYStart = 95
  lngHeight = lngHeight - lngYstart -105
  lngWidth = lngWidth -(lngXstart * 3)
  '
  mPrepHTML(hDlg, lngXstart, lngYstart, lngHeight, lngWidth)
  '
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
FUNCTION funCreateToolbar(BYVAL hDlg AS DWORD, BYVAL lID AS LONG) AS LONG
'
  LOCAL hImgList AS LONG
  LOCAL depth&,nWidth&,nHeight&,initial&  ' local variables - see below
  '
  depth& = 32     ' depth of colour e.g. 32bit - how many colours allowed
  nWidth& = 32    ' width of icon in pixels
  nHeight& = 32   ' height of icon in pixels
  initial& = 6    ' allocated space in imagelist object to store buttons (increase as more are needed)
  IMAGELIST NEW ICON depth&, nWidth&, nHeight&, initial& TO hImgList
  IMAGELIST ADD ICON hImgList, "#" + FORMAT$(%IDR_BuildIcon)
  IMAGELIST ADD ICON hImgList, "#" + FORMAT$(%IDR_HelpIcon)
  IMAGELIST ADD ICON hImgList, "#" + FORMAT$(%IDR_Dates)
  TOOLBAR SET IMAGELIST hDlg, lID, hImgList, 0
  '
  TOOLBAR ADD BUTTON hDlg, lID, 1, %IDC_TOOLBAR_Build, _
                     %TBSTYLE_BUTTON, "Build Report"
  TOOLBAR ADD BUTTON hDlg, lID, 3, %IDC_TOOLBAR_Dates, _
                     %TBSTYLE_BUTTON, "Test Dates"
                     '
  TOOLBAR ADD SEPARATOR hDlg,lID,32
  TOOLBAR ADD BUTTON hDlg, lID, 2, %IDC_TOOLBAR_Help, _
                     %TBSTYLE_BUTTON, "Help"

END FUNCTION
'------------------------------------------------------------------------------
'------------------------------------------------------------------------------
CALLBACK FUNCTION ShowdlgTestDatesProc()
  '
  STATIC strStartDate AS STRING
  STATIC strEndDate AS STRING
  LOCAL ptnmhdr AS NMHDR PTR            ' information about a notification
  LOCAL ptnmdtc AS NMDATETIMECHANGE PTR ' date time information
  '
  SELECT CASE AS LONG CB.MSG
    CASE %WM_INITDIALOG
    ' Initialization handler
      strStartDate = "25/12/2019"
      strEndDate   = funUKDate()
      '
      funSetaDate(CB.HNDL, %IDC_datStartDate, strStartDate)
      funSetaDate(CB.HNDL, %IDC_datEndDate, strEndDate)

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
    CASE %WM_NOTIFY
      ptnmhdr = CB.LPARAM
      SELECT CASE @ptnmhdr.idfrom
        CASE %IDC_datStartDate
          SELECT CASE @ptnmhdr.code
            CASE %DTN_DATETIMECHANGE
              ptnmdtc = CB.LPARAM
              strStartDate = RIGHT$("00" & FORMAT$(@ptnmdtc.st.wDay),2) & "/" & _
                             RIGHT$("00" & FORMAT$(@ptnmdtc.st.wMonth),2) & "/" & _
                             FORMAT$(@ptnmdtc.st.wYear)
          END SELECT
          '
        CASE %IDC_datEndDate
          SELECT CASE @ptnmhdr.code
            CASE %DTN_DATETIMECHANGE
              ptnmdtc = CB.LPARAM
              strEndDate = RIGHT$("00" & FORMAT$(@ptnmdtc.st.wDay),2) & "/" & _
                             RIGHT$("00" & FORMAT$(@ptnmdtc.st.wMonth),2) & "/" & _
                             FORMAT$(@ptnmdtc.st.wYear)
          END SELECT

      END SELECT

    CASE %WM_COMMAND
      ' Process control notifications
      SELECT CASE AS LONG CB.CTL
        CASE %IDC_datStartDate

        CASE %IDC_datEndDate

        CASE %IDOK
          IF CB.CTLMSG = %BN_CLICKED OR CB.CTLMSG = 1 THEN
            MSGBOX "Start date = " & strStartDate & $CRLF & _
                   "End date   = " & strEndDate , 0,"These are the dates"
          END IF

      END SELECT
  END SELECT
END FUNCTION
'------------------------------------------------------------------------------

'------------------------------------------------------------------------------
FUNCTION ShowdlgTestDates(BYVAL hParent AS DWORD) AS LONG
  LOCAL lRslt AS LONG

#PBFORMS BEGIN DIALOG %IDD_dlgTestDates->->
  LOCAL hDlg  AS DWORD

  DIALOG NEW hParent, "Test Dialogs", 248, 120, 406, 245, %WS_POPUP OR _
    %WS_BORDER OR %WS_DLGFRAME OR %WS_CAPTION OR %WS_SYSMENU OR _
    %WS_CLIPSIBLINGS OR %WS_VISIBLE OR %DS_MODALFRAME OR %DS_CENTER OR _
    %DS_3DLOOK OR %DS_NOFAILCREATE OR %DS_SETFONT, %WS_EX_CONTROLPARENT OR _
    %WS_EX_LEFT OR %WS_EX_LTRREADING OR %WS_EX_RIGHTSCROLLBAR, TO hDlg
  CONTROL ADD "SysDateTimePick32", hDlg, %IDC_datStartDate, _
    "SysDateTimePick32_1", 40, 50, 100, 13, %WS_CHILD OR %WS_VISIBLE OR _
    %WS_TABSTOP OR %DTS_SHORTDATECENTURYFORMAT, %WS_EX_CLIENTEDGE OR _
    %WS_EX_LEFT OR %WS_EX_LTRREADING OR %WS_EX_RIGHTSCROLLBAR
  CONTROL ADD "SysDateTimePick32", hDlg, %IDC_datEndDate, _
    "SysDateTimePick32_2", 215, 50, 100, 13, %WS_CHILD OR %WS_VISIBLE OR _
    %WS_TABSTOP OR %DTS_SHORTDATECENTURYFORMAT, %WS_EX_CLIENTEDGE OR _
    %WS_EX_LEFT OR %WS_EX_LTRREADING OR %WS_EX_RIGHTSCROLLBAR
  CONTROL ADD BUTTON, hDlg, %IDOK, "Show Dates", 25, 210, 120, 15
  DIALOG  SEND        hDlg, %DM_SETDEFID, %IDOK, 0
  CONTROL ADD LABEL,  hDlg, %IDC_lblStartDate, "Enter Start date", 40, 40, _
    100, 10
  CONTROL SET COLOR   hDlg, %IDC_lblStartDate, %BLUE, -1
  CONTROL ADD LABEL,  hDlg, %IDC_lblEnddate, "Enter Enddate", 215, 40, 100, _
    10
  CONTROL SET COLOR   hDlg, %IDC_lblEnddate, %BLUE, -1
#PBFORMS END DIALOG

  DIALOG SHOW MODAL hDlg, CALL ShowdlgTestDatesProc TO lRslt

#PBFORMS BEGIN CLEANUP %IDD_dlgTestDates
#PBFORMS END CLEANUP

  FUNCTION = lRslt
END FUNCTION
'------------------------------------------------------------------------------
FUNCTION funUKDate() AS STRING
  LOCAL strDate AS STRING
  strDate = DATE$
  FUNCTION = MID$(strDate,4,2) & "/" & _
             LEFT$(strDate,2) & "/" & _
             RIGHT$(strDate,4)
END FUNCTION
'
FUNCTION funSetaDate(hDlg AS DWORD, lngDate AS LONG, _
                     strDate AS STRING) AS LONG
' set a date control to the date passed - dd/mm/yyy format assumed
  LOCAL DT AS SystemTime
  LOCAL hCalendar AS DWORD
  '
  CONTROL HANDLE hDlg, lngDate TO hCalendar
  '
  DT.wMonth = VAL(MID$(strDate,4,2))
  DT.wDay   = VAL(MID$(strDate,1,2))
  DT.wYear  = VAL(RIGHT$(strDate,4))
  '
  FUNCTION = DateTime_SetSystemTime(hCalendar, %GDT_Valid, DT)
  '
END FUNCTION
