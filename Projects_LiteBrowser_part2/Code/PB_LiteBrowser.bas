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
#INCLUDE ONCE "PB_FileHandlingRoutines.inc"
'
GLOBAL g_lngTabcount AS LONG      ' total number of tabs
GLOBAL g_alngTabHandles() AS LONG ' array to hold tab handles
'
GLOBAL g_strHTML   AS STRING  ' holds the HTML to be viewed
GLOBAL g_strLcHTML AS STRING  ' holds a lower case version of the HTML to be viewed
'
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
GLOBAL hFont AS DWORD        ' default font
GLOBAL ga_hFonts() AS DWORD  ' array of fonts
'------------------------------------------------------------------------------
'   ** Main Application Entry Point **
'------------------------------------------------------------------------------
FUNCTION PBMAIN()
  PBFormsInitComCtls (%ICC_WIN95_CLASSES OR %ICC_DATE_CLASSES OR _
    %ICC_INTERNET_CLASSES)
    '
  funCreateFonts() ' create the fonts
  '
  ShowdlgPBLiteBrowser %HWND_DESKTOP
  ' tidy up fonts when app ending
  funUnloadFonts()
  '
END FUNCTION
'
FUNCTION funUnloadFonts() AS LONG
' unload all the fonts
  LOCAL lngF AS LONG
  '
  FONT END hFont
  ' end each of the fonts created
  FOR lngF = 1 TO 6
    FONT END ga_hFonts(lngF)
  NEXT lngF
  '
END FUNCTION
'------------------------------------------------------------------------------
FUNCTION funCreateFonts() AS LONG
' create all the fonts needed
  REDIM ga_hFonts(6) AS DWORD
  LOCAL lngF AS LONG
  LOCAL lngPoint AS LONG
  LOCAL lngStyle AS LONG
  '
  lngPoint = 12
  ' create a new font
  FONT NEW "Courier New",lngPoint TO hFont
  '
  lngPoint = 30 ' set starting font size
  lngStyle = 1  ' set to bold
  '
  ' create each of the fonts
  FOR lngF = 1 TO 6
    FONT NEW "Courier New",lngPoint,lngStyle TO ga_hFonts(lngF)
    lngPoint = lngPoint - 4
  NEXT lngF
  '
END FUNCTION
'------------------------------------------------------------------------------
'   ** CallBacks **
'------------------------------------------------------------------------------
CALLBACK FUNCTION ShowdlgPBLiteBrowserProc()
  LOCAL lngPageDlgVar AS LONG    ' holds tab handle
  LOCAL lngControl AS LONG       ' handle of a control
  LOCAL strURL AS STRING         ' URL entered by user
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
        CASE %IDC_txtURL
        '
        CASE %IDC_IMGReload
          IF CB.CTLMSG = %BN_CLICKED OR CB.CTLMSG = 1 THEN
          ' reload the page
            CONTROL GET TEXT CB.HNDL,%IDC_txtURL TO strURL
            funRenderTheHTML(strURL, CB.HNDL, %IDC_TAB1)
          END IF
          '
        CASE %IDOK
        ' return has been pressed
          ' get the field that last had focus
        ' and return the dialog handle of that control
          lngControl = getDlgCtrlID(GetFocus())
          '
          IF lngControl = %IDC_txtURL THEN
          ' return has been pressed on the text URL field
            ' msgbox "Return pressed on URL field"
            CONTROL GET TEXT CB.HNDL,%IDC_txtURL TO strURL
            funRenderTheHTML(strURL, CB.HNDL, %IDC_TAB1)
            '
          END IF
          '
      END SELECT
  END SELECT
END FUNCTION
'
FUNCTION funRenderTheHTML(strURL AS STRING, _
                          hDlg AS DWORD, _
                          lngTab AS LONG) AS LONG
' render the html to the graphics control
  LOCAL strHTML AS STRING         ' holds the html file
  LOCAL lngTabSelected AS LONG    ' tab number selected
  '
  ' exit immediately if no URL/PATH
  IF TRIM$(strURL) = "" THEN EXIT FUNCTION
  '
  GRAPHIC CLEAR %WHITE
  GRAPHIC COLOR %BLACK,%WHITE
  GRAPHIC SET FONT hFont ' set the default font
  GRAPHIC SET POS (1,1)
  GRAPHIC PRINT "Return pressed " & strURL
  GRAPHIC REDRAW
  '
  ' load the html file
  g_strHTML = funLoadHTMLPage(strURL)
  g_strLcHTML = LCASE$(g_strHTML)
  '
  IF g_strHTML <> "" THEN
  ' page has been loaded
    TAB GET SELECT hDlg, lngTab TO lngTabSelected
    TAB SET TEXT hDlg, lngTab, lngTabSelected, _
                       PARSE$(strURL,ANY "\/" ,-1)
  END IF
  '
  IF ISTRUE funValidateHTML() THEN
  ' is valid html
    GRAPHIC PRINT "HTML formatting ok"
    funRenderHTMLTags(hDlg,lngTab)
    '
  ELSE
  ' html formatting error
    GRAPHIC PRINT "Invalid HTML formatting"
    GRAPHIC PRINT g_strHTML
  END IF
  '
  GRAPHIC REDRAW
  '
END FUNCTION
'
FUNCTION funRenderHTMLTags(hDlg AS DWORD, _
                           lngTab AS LONG) AS LONG
' render each of the tags by stepping through each
' tag in the strHTML
  '
  LOCAL lngStart, lngEnd AS LONG
  LOCAL lngHTMLPos AS LONG
  LOCAL strChar AS STRING
  LOCAL strCommand AS STRING
  LOCAL lngData AS STRING
  LOCAL strData AS STRING       ' data within a tag
  LOCAL lngInCommand AS LONG    ' true/false for in a command
  LOCAL lngExitCommand AS LONG
  LOCAL lngInBody AS LONG       ' true/false for inside body section
  LOCAL lngInHead AS LONG       ' true/false for inside head section
  LOCAL lngFont AS LONG         ' value of font selected
  LOCAL lngTabSelected AS LONG  ' currently selected tab
  LOCAL strTitle AS STRING      ' text for tab
  '
  FOR lngHTMLPos = 1 TO LEN(g_strLcHTML)
  ' step through each character
    strChar = MID$(g_strLcHTML,lngHTMLPos,1)
    '
    IF strChar = "<" THEN
    ' start of a tag - pick up the command
      lngStart = lngHTMLPos + 1
      lngEnd = INSTR(lngStart,g_strLcHTML,">")
      strCommand = MID$(g_strLcHTML,lngStart,lngEnd-lngStart)
      lngInCommand = %TRUE
      lngExitCommand = %FALSE
      '
    ELSEIF strChar = ">" THEN
    ' end of a tag
      lngInCommand = %FALSE
      lngExitCommand = %TRUE
      '
      ' now tag has ended what do we do with the data
      SELECT CASE strCommand
        CASE "html","/html"
        ' do nothing
        CASE "body"
        ' inside the body section
          lngInBody = %TRUE
        CASE "/body"
        ' end of body tag
          lngInBody = %FALSE
        CASE "head"
        ' heading section
          lngInHead = %TRUE
          strTitle = ""  ' ensure any title is blank
        CASE "/head"
        ' end of heading section
          lngInHead = %FALSE
        CASE "h1","h2","h3","h4","h5","h6"
        ' heading start
          ' determine which heading number
          lngFont = VAL(RIGHT$(strCommand,1))
          GRAPHIC SET FONT ga_hFonts(lngFont)
          '
        CASE "/h1","/h2","/h3","/h4","/h5","/h6"
        ' end of heading
          GRAPHIC SET FONT hFont
          '
        CASE "title"
        ' start of the title
          IF ISTRUE lngInHead THEN
          ' pick up the title
            lngStart = INSTR(lngStart,g_strLcHTML,">") +1
            lngEnd   = INSTR(lngStart,g_strLcHTML,"</title>")
            strTitle  = MID$(g_strHTML,lngStart,lngEnd-lngStart)
          END IF
          '
        CASE "/title"
        ' end of the title
          IF ISTRUE lngInHead THEN
          ' update the tab to show the name of the title
            TAB GET SELECT hDlg, lngTab TO lngTabSelected
            TAB SET TEXT hDlg, lngTab, lngTabSelected, strTitle
          END IF
          '
        CASE "p"
        ' paragraph start
          IF ISTRUE lngInBody THEN
          ' inside the body section
            lngStart = INSTR(lngStart,g_strLcHTML,">") +1
            lngEnd   = INSTR(lngStart,g_strLcHTML,"</p>")
            strData  = MID$(g_strHTML,lngStart,lngEnd-lngStart)
            'graphic print strData
            funPrintData(strData)
          END IF
          '
        CASE "/p"
        ' end of paragraph
          IF ISTRUE lngInBody THEN
            GRAPHIC PRINT "" ' move to next row
          END IF
          '
      END SELECT
      '
    END IF
    '
  NEXT lngHTMLPos
  '
END FUNCTION
'
FUNCTION funPrintData(strData AS STRING) AS LONG
' print the data string to the graphics control
  LOCAL lngPos AS LONG
  LOCAL strTempData AS STRING
  LOCAL lngBreaks AS LONG      ' number of line breaks
  LOCAL lngB AS LONG
  LOCAL strText AS STRING      ' string to print
  '
  strTempData = LCASE$(strData)
  '
  lngBreaks = PARSECOUNT(strTempData,"<br>")
  '
  IF lngBreaks > 1 THEN
  ' we have one or more embedded line breaks
    FOR lngB = 1 TO lngBreaks
    ' get the data
      strText = TRIM$(PARSE$(strData,"<br>",lngB))
      IF TRIM$(strData) <> "" THEN
      ' print if text is not blank
        GRAPHIC PRINT strText
      END IF
      '
    NEXT lngB
    '
  ELSE
  ' no line breaks
    GRAPHIC PRINT TRIM$(strData)
  '
  END IF
  '
END FUNCTION
'
FUNCTION funValidateHTML() AS LONG
' validate the html
  '
  IF INSTR(g_strLcHTML,"<html>") = 0 THEN
    FUNCTION = %FALSE:EXIT FUNCTION
    IF INSTR(g_strLcHTML,"</html>") = 0 THEN
      FUNCTION = %FALSE:EXIT FUNCTION
    ELSE
      IF INSTR(g_strLcHTML,"<body>") = 0 THEN
        FUNCTION = %FALSE:EXIT FUNCTION
      ELSE
        IF INSTR(g_strLcHTML,"</body>") = 0 THEN
          FUNCTION = %FALSE:EXIT FUNCTION
        END IF
      END IF
    END IF
  END IF
  '
  FUNCTION = %TRUE
  '
END FUNCTION
'
FUNCTION funLoadHTMLPage(strURL AS STRING) AS STRING
' determine if file or web page and return the content
' of the file
  LOCAL strHTML AS STRING
  ' read in the html data trimming out leading
  ' and trailing spaces
  strHTML = TRIM$(funBinaryFileAsString(strURL))
  ' remove any CR/LF
  strHTML = REMOVE$(strHTML, ANY $CRLF)
  '
  FUNCTION = strHTML
  '
END FUNCTION
'
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
  GRAPHIC CLEAR %RGB_WHITE ,0
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
  GRAPHIC CLEAR %RGB_WHITE ,0
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
