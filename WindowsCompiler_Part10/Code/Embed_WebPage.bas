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
'------------------------------------------------------------------------------
#INCLUDE "..\Libraries\PB_HTML.inc"
#INCLUDE "..\Libraries\PB_Windows_Controls.inc"
#INCLUDE "..\Libraries\PB_FileHandlingRoutines.inc"
#INCLUDE "..\Libraries\PB_Common_Windows.inc"
'------------------------------------------------------------------------------
'   ** Constants **
'------------------------------------------------------------------------------
#PBFORMS BEGIN CONSTANTS
%IDD_dlgReporter    =  101
%IDABORT            =    3
%IDOK               =    1
%IDC_txtURL         = 1001
%IDC_btnBuildReport = 1002
%IDC_lblURL         = 1003
#PBFORMS END CONSTANTS
'------------------------------------------------------------------------------
#RESOURCE RCDATA, 4000,"Demo.css"
'------------------------------------------------------------------------------
'   ** Declarations **
'------------------------------------------------------------------------------
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
          CASE %IDC_btnBuildReport
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
#PBFORMS BEGIN DIALOG %IDD_dlgReporter->->
  LOCAL hDlg  AS DWORD

  DIALOG NEW hParent, "HTML Reporter", 228, 98, 672, 405, %WS_POPUP OR _
    %WS_BORDER OR %WS_DLGFRAME OR %WS_CLIPSIBLINGS OR %WS_VISIBLE OR _
    %DS_MODALFRAME OR %DS_CENTER OR %DS_3DLOOK OR %DS_NOFAILCREATE OR _
    %DS_SETFONT, %WS_EX_CONTROLPARENT OR %WS_EX_LEFT OR %WS_EX_LTRREADING OR _
    %WS_EX_RIGHTSCROLLBAR, TO hDlg
  CONTROL ADD BUTTON,  hDlg, %IDABORT, "Exit", 590, 370, 50, 15
  CONTROL ADD BUTTON,  hDlg, %IDOK, "Display the HTML page", 520, 19, 110, 15
  DIALOG  SEND         hDlg, %DM_SETDEFID, %IDOK, 0
  CONTROL ADD TEXTBOX, hDlg, %IDC_txtURL, "", 165, 20, 330, 13
  CONTROL ADD BUTTON,  hDlg, %IDC_btnBuildReport, "Build A Report", 25, 20, _
    75, 15
  CONTROL ADD LABEL,   hDlg, %IDC_lblURL, "Enter URL here ", 165, 10, 295, 10
  CONTROL SET COLOR    hDlg, %IDC_lblURL, %BLUE, -1
#PBFORMS END DIALOG
  '
  LOCAL lngHeight AS LONG
  LOCAL lngWidth AS LONG
  LOCAL lngXstart AS LONG
  LOCAL lngYstart AS LONG
  '
  DIALOG GET SIZE hDlg TO lngWidth, lngHeight
  '
  lngXstart = 10 : lngYStart = 50
  lngHeight = lngHeight - lngYstart -60
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
