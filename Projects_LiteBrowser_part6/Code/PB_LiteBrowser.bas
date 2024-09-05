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
#RESOURCE "PB_LiteBrowser.pbr"
%USEMACROS = 1
#INCLUDE ONCE "WIN32API.INC"
#INCLUDE ONCE "COMMCTRL.INC"
#INCLUDE ONCE "PBForms.INC"
#PBFORMS END INCLUDES
'------------------------------------------------------------------------------
#INCLUDE ONCE "Tooltips.inc"
#INCLUDE ONCE "PB_Common_Strings.inc"
#INCLUDE ONCE "PB_FileHandlingRoutines.inc"
#INCLUDE ONCE "PB_GDIplus_startup.inc"
#INCLUDE ONCE "PB_LoadJPG_as_Bitmap.inc"
'
GLOBAL g_lngTabcount AS LONG      ' total number of tabs
GLOBAL g_alngTabHandles() AS LONG ' array to hold tab handles
GLOBAL g_astrURLS() AS STRING     ' array to hold urls of tabs
GLOBAL g_astrURLhistory() AS STRING ' URL history of all tabs
GLOBAL g_lngLatestSlot() AS LONG    ' array to hold latest slot for each tab
'
GLOBAL g_strHTML   AS STRING  ' holds the HTML to be viewed
GLOBAL g_strLcHTML AS STRING  ' holds a lower case version of the HTML to be viewed
'
GLOBAL OldGraphicProc AS DWORD
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
%IDD_dlgTabClick      =  102
%IDC_btnCloseTab      = 1009
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
'
%MAX_TABS = 11                  ' maximum number of tabs allowed
%MAX_HISTORY = 10               ' maximum history on each tab
GLOBAL g_lngTabSelected AS LONG ' number of currently selected tab
GLOBAL g_hDlg AS DWORD          ' global handle for main dialog
'
' print location
GLOBAL g_lngX, g_lngY AS LONG   ' Global X and Y print locations
'------------------------------------------------------------------------------
'   ** Main Application Entry Point **
'------------------------------------------------------------------------------
FUNCTION PBMAIN()
  PBFormsInitComCtls (%ICC_WIN95_CLASSES OR %ICC_DATE_CLASSES OR _
    %ICC_INTERNET_CLASSES)
    '
  funCreateFonts() ' create the fonts
  ' prepare the URLs arrays
  REDIM g_astrURLS(%MAX_TABS)       ' for current URL on each tab
  REDIM g_alngTabHandles(%MAX_TABS) ' for tab handles for each tab
  REDIM g_astrURLhistory(%MAX_TABS,%MAX_HISTORY) ' for history of all tabs
  REDIM g_lngLatestSlot(%MAX_TABS)  ' for latest slot for each tab
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
  LOCAL lngFileCount AS LONG     ' number of files being dropped
  LOCAL strFileName AS STRINGZ * %MAX_PATH   ' path/name of file
  LOCAL lngItem AS LONG          ' item number of dragged file
  '
  LOCAL ptnmhdr AS NMHDR PTR     ' information about a notification
  LOCAL lngPageNumber AS LONG    ' tab page number
  LOCAL lngTopPageNumber AS LONG ' maximum page number of tab
  LOCAL hMenuPopUp AS DWORD      ' handle for menu popup
  LOCAL strTabTitle AS STRING    ' the name on the selected tab
  LOCAL lngCurrentSlot AS LONG   ' currently selected history slot on the tab
  '
  SELECT CASE AS LONG CB.MSG
    CASE %WM_INITDIALOG
    ' Initialization handler
      STATIC hGraphic AS DWORD
      CONTROL HANDLE CB.HNDL, %IDC_GRAPHIC TO hGraphic
      OldGraphicProc = SetWindowLong(hGraphic, %GWL_WNDPROC, _
                       CODEPTR(GraphicProc))
      '
    ' insert a tab page
      TAB INSERT PAGE CB.HNDL, %IDC_TAB1, 1, 0, "Home" _
          TO lngPageDlgVar
          '
      ' store the tab handle
      g_alngTabHandles(1) = lngPageDlgVar
      '
      ' Add the + tab page
      TAB INSERT PAGE CB.HNDL, %IDC_TAB1, 2, 0, "+" _
          TO lngPageDlgVar
      g_alngTabHandles(2) = lngPageDlgVar
      '
      ' select Page 1
      g_lngTabSelected = 1
      TAB SELECT CB.HNDL, %IDC_TAB1, g_lngTabSelected
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
    CASE %WM_DESTROY     ' <- Sent when the dialog is about to be destroyed
      IF OldGraphicProc THEN
        SetWindowLong hGraphic, %GWL_WNDPROC, OldGraphicProc
      END IF
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
      funClearGraphicsControl()
      ' re-render the page content
      CONTROL GET TEXT CB.HNDL,%IDC_txtURL TO strURL
      funRenderTheHTML(strURL, CB.HNDL, %IDC_TAB1)
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
    CASE %WM_DROPFILES
    ' handle objects being dragged to the dialog
      lngFileCount = DragQueryFile(CB.WPARAM, -1, BYVAL 0, 0)
      '
      IF lngFileCount = 1 THEN
      ' get the path & filename - support only one file
        lngItem = 0  ' first item is always zero
        DragQueryFile CB.WPARAM, lngItem, strFileName, SIZEOF(strFileName)
      END IF
      '
      ' tell windows drag and drop has completed
      DragFinish CB.WPARAM
      '
      strURL = strFileName
      '
      ' store the URL in global array
      TAB GET SELECT CB.HNDL, %IDC_TAB1 TO lngPageNumber
      g_astrURLS(lngPageNumber) = strURL
      '
      ' advance latest slot for this tab
      INCR g_lngLatestSlot(lngPageNumber)
      '
      ' store the new URL as latest web page
      funStoreURLHistory(lngPageNumber, strURL)
      '
      funClearGraphicsControl()
      '
      ' now update the graphics control with single file
      CONTROL SET TEXT CB.HNDL, %IDC_txtURL, strURL
      funRenderTheHTML(strURL, CB.HNDL, %IDC_TAB1)
      '
    CASE %WM_NOTIFY
    ' handle notifications
      ptnmhdr = CB.LPARAM
      SELECT CASE @ptnmhdr.idfrom
      '
       CASE %IDC_TAB1
        ' it's the tab control
          SELECT CASE @ptnmhdr.code
            '
            CASE %TCN_SELCHANGE
            ' tab has been changed
            ' get the tab handle
              TAB GET SELECT CB.HNDL, %IDC_TAB1 TO lngPageNumber
              ' store selected tab number
              g_lngTabSelected = lngPageNumber
              ' get the name on the tab
              TAB GET TEXT CB.HNDL, %IDC_TAB1, g_lngTabSelected TO strTabTitle
              '
              IF strTabTitle = "+" THEN
              ' last tab has been selected
                IF lngPageNumber + 1 =< %MAX_TABS THEN
                ' only if < max tabs allowed
                ' advance the top page number
                  lngTopPageNumber = lngPageNumber + 1
                  ' add a new tab
                  TAB SET TEXT CB.HNDL, %IDC_TAB1, lngPageNumber, "NEW"
                  '
                  TAB INSERT PAGE CB.HNDL, %IDC_TAB1, _
                                           lngTopPageNumber , 0, "+" _
                                           TO lngPageDlgVar
                  '
                  g_alngTabHandles(lngTopPageNumber) = lngPageDlgVar
                  ' a new tab so clear the graphics control
                  funClearGraphicsControl()
                  CONTROL SET TEXT CB.HNDL, %IDC_txtURL, ""
                  '
                  ' clear the tabs history
                  funClearHistoryForTab(lngPageNumber)
                  '
                ELSE
                ' set focus to previous tab
                  g_lngTabSelected = lngPageNumber - 1
                  TAB SELECT CB.HNDL, %IDC_TAB1, g_lngTabSelected
                '
                END IF
                '
              ELSE
              ' some other tab selected
              ' pick up the URL
                lngCurrentSlot = g_lngLatestSlot(lngPageNumber)
                strURL = g_astrURLhistory(lngPageNumber,lngCurrentSlot)
                ' reset buttons
                funSetBackForwardButtons(lngPageNumber,lngCurrentSlot)
                '
                ' populate the text box with URL
                CONTROL SET TEXT CB.HNDL, %IDC_txtURL, strURL
                ' clear and rerender the web page
                funClearGraphicsControl()
                funRenderTheHTML(strURL, CB.HNDL, %IDC_TAB1)
              '
              END IF
              '
          END SELECT
      END SELECT
    '
    CASE %WM_COMMAND
      ' Process control notifications
      SELECT CASE AS LONG CB.CTL
        ' /* Inserted by PB/Forms 08-15-2024 14:36:33
        CASE %IDC_STATUSBAR1
        '
        CASE %IDC_IMGback
          IF CB.CTLMSG = %BN_CLICKED OR CB.CTLMSG = 1 THEN
          ' go back a page
            ' get the tab handle
            TAB GET SELECT CB.HNDL, %IDC_TAB1 TO lngPageNumber
            lngCurrentSlot = g_lngLatestSlot(lngPageNumber)
            DECR lngCurrentSlot
            ' get the URL
            strURL = g_astrURLhistory(lngPageNumber,lngCurrentSlot)
            IF strURL <> "" THEN
            ' render the page
              ' populate the text box with URL
              CONTROL SET TEXT CB.HNDL, %IDC_txtURL, strURL
              '
              funRenderTheHTML(strURL, CB.HNDL, %IDC_TAB1)
              '
              ' store current slot
              g_lngLatestSlot(lngPageNumber) = lngCurrentSlot
              CONTROL ENABLE CB.HNDL,%IDC_IMGForward
              '
            END IF
            '
          END IF
          '
        CASE %IDC_IMGForward
          IF CB.CTLMSG = %BN_CLICKED OR CB.CTLMSG = 1 THEN
          ' go forward a page
            TAB GET SELECT CB.HNDL, %IDC_TAB1 TO lngPageNumber
            lngCurrentSlot = g_lngLatestSlot(lngPageNumber)
            INCR lngCurrentSlot
            ' get the URL
            strURL = g_astrURLhistory(lngPageNumber,lngCurrentSlot)
            '
            IF strURL <> "" THEN
            ' render the page
            ' populate the text box with URL
              CONTROL SET TEXT CB.HNDL, %IDC_txtURL, strURL
              '
              funRenderTheHTML(strURL, CB.HNDL, %IDC_TAB1)
              '
              ' store current slot
              g_lngLatestSlot(lngPageNumber) = lngCurrentSlot
              '
              ' set display of back/forward buttons
              funSetBackForwardButtons(lngPageNumber,lngCurrentSlot)
              '
            END IF
          '
          END IF
          '
        CASE %IDC_IMGHome
          IF CB.CTLMSG = %BN_CLICKED OR CB.CTLMSG = 1 THEN
            TAB GET SELECT CB.HNDL, %IDC_TAB1 TO lngPageNumber
            funDisplayHistory(lngPageNumber)
          END IF
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
            '
            funClearGraphicsControl()
            '
            CONTROL GET TEXT CB.HNDL,%IDC_txtURL TO strURL
            funRenderTheHTML(strURL, CB.HNDL, %IDC_TAB1)
            '
            ' store the URL in global array
            TAB GET SELECT CB.HNDL, %IDC_TAB1 TO lngPageNumber
            g_astrURLS(lngPageNumber) = strURL
            '
            ' advance latest slot for this tab
            INCR g_lngLatestSlot(lngPageNumber)
            '
            ' store the new URL as latest web page
            funStoreURLHistory(lngPageNumber, strURL)
            '
            ' render the URL to the graphics control
            funRenderTheHTML(strURL, CB.HNDL, %IDC_TAB1)
            '
          END IF
          '
      END SELECT
  END SELECT
END FUNCTION
'
FUNCTION funSetBackForwardButtons(lngPageNumber AS LONG, _
                                  lngCurrentSlot AS LONG) AS LONG
' display/hide buttons based on page and slot
  IF g_astrURLhistory(lngPageNumber,lngCurrentSlot + 1) = "" THEN
  ' if next slot is blank - turn off forward button
    CONTROL DISABLE g_hDlg,%IDC_IMGForward
  ELSE
    CONTROL ENABLE g_hDlg,%IDC_IMGForward
  END IF
  '
  IF lngCurrentSlot = 1 THEN
  ' only one slot so turn of back button
    CONTROL DISABLE g_hDlg,%IDC_IMGBack
  ELSE
    CONTROL ENABLE g_hDlg,%IDC_IMGBack
  END IF
  '
END FUNCTION
'
FUNCTION funClearHistoryForTab(lngPageNumber AS LONG) AS LONG
' clear the history for the tab
  LOCAL lngR AS LONG
  '
  FOR lngR = 1 TO %MAX_HISTORY
    g_astrURLhistory(lngPageNumber, lngR) = ""
  NEXT lngR
  '
  ' set current slot to 0
  g_lngLatestSlot(lngPageNumber) = 0
  '
  PREFIX "CONTROL DISABLE g_hDlg,"
    %IDC_IMGback
    %IDC_IMGForward
  END PREFIX
'
END FUNCTION
'
FUNCTION funDisplayHistory(lngPageNumber AS LONG) AS LONG
' debug display tabs history
  LOCAL lngR AS LONG
  STATIC hWin AS DWORD
  '
  IF hWin = 0 THEN
    TXT.WINDOW("URL History",0,0) TO hWin
  ELSE
    TXT.CLS
  END IF
  '
  TXT.PRINT "Tab = ";lngPageNumber
  FOR lngR = 1 TO %MAX_HISTORY
    TXT.PRINT lngR;"  ";g_astrURLhistory(lngPageNumber, lngR)
  NEXT lngR
  '
END FUNCTION
'
FUNCTION funStoreURLHistory(lngPageNumber AS LONG, _
                            strURL AS STRING) AS LONG
' store the URL in the history
  LOCAL lngR AS LONG
  LOCAL lngCurrentSlot AS LONG
  '
  ' store in current slot
  lngCurrentSlot = g_lngLatestSlot(lngPageNumber)
  g_astrURLhistory(lngPageNumber,lngCurrentSlot) = strURL
  '
  ' blank all slots above this
  FOR lngR = lngCurrentSlot+1 TO %MAX_HISTORY
    g_astrURLhistory(lngPageNumber, lngR) = ""
  NEXT lngR
  ' set back forward buttons
  funSetBackForwardButtons(lngPageNumber,lngCurrentSlot)
  '
END FUNCTION
'
FUNCTION GraphicProc (BYVAL hWnd AS DWORD, BYVAL wMsg AS DWORD, _
                      BYVAL wParam AS DWORD, BYVAL lParam AS LONG) AS LONG
'--------------------------------------------------------------------
  ' Subclass procedure
  '------------------------------------------------------------------
  LOCAL lngX, lngY AS LONG
  LOCAL lngTabSelected AS LONG

  '
  SELECT CASE wMsg
    '
    CASE %WM_RBUTTONUP
    ' get mouse co-ords and show popup dialog
      lngX = LO(INTEGER, lParam)
      lngY = HI(INTEGER, lParam)
      '
      IF g_lngTabSelected > 1 THEN
      ' only for tabs other than first tab
        ShowdlgTabClick hWnd , lngX, lngY
      END IF
      '
  END SELECT
  '
  FUNCTION = CallWindowProc (OldGraphicProc, hWnd, wMsg, wParam, lParam)
  '
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
  'GRAPHIC PRINT "Return pressed " & strURL
  GRAPHIC REDRAW
  '
  funClearGraphicsControl()
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
    'GRAPHIC PRINT "HTML formatting ok"
    funRenderHTMLTags(hDlg,lngTab)
    '
  ELSE
  ' html formatting error
    GRAPHIC ATTACH hDlg,%IDC_Graphic , REDRAW
    GRAPHIC PRINT "Invalid HTML formatting"
    'GRAPHIC PRINT g_strHTML
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
  LOCAL lngAttribute AS LONG    ' start of attribute command
  LOCAL strAttributes AS STRING ' attributes of the command
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
      '
       ' capture attributes
      ' e.g. strCommand = "p align=center"
      ' get position of first space
      lngAttribute = INSTR(strCommand," ")
      IF lngAttribute > 0 THEN
        strAttributes = TRIM$(MID$(strCommand,lngAttribute))
      ELSE
        strAttributes = ""
      END IF
      '
      ' trim command to remove attributes
      strCommand = PARSE$(strCommand," ",1)
      '
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
            strTitle = funGetTagValue(lngStart, "</title>")
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
            strData = funGetTagValue(lngStart, "</p>")
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
        CASE "img"
        ' start of image tag
          IF ISTRUE lngInBody THEN
          ' strAttributes should hold any attributes
            TAB GET SELECT hDlg, lngTab TO lngTabSelected
            funDisplayImage(hDlg, strAttributes,lngTabSelected)
          '
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
FUNCTION funDisplayImage(hDlg AS DWORD, _
                         strAttributes AS STRING, _
                         lngTabSelected AS LONG) AS LONG
' display the image on the graphics control
  LOCAL lngStartPosition AS LONG
  LOCAL strTemp AS STRING
  LOCAL strSource AS STRING
  LOCAL lng_imgW, lng_imgH AS LONG ' width and height of returned bitmap
  LOCAL hBMP AS DWORD              ' handle of the bitmap
  LOCAL strFullHTMLPath AS STRING  ' full path to the html
  LOCAL strPath AS STRING
  LOCAL lngEndElement AS LONG
  LOCAL lngX, lngY AS LONG         ' current position of cursor
  '
  lngStartPosition = INSTR(strAttributes,"src=") + LEN("src=")
  strTemp = MID$(strAttributes,lngStartPosition)
  strSource = PARSE$(strTemp,$DQ,2)
  '
  ' image path may be relative to html page
  strFullHTMLPath = g_astrURLS(lngTabSelected)
  lngEndElement = PARSECOUNT(strFullHTMLPath,"\")
  DECR lngEndElement
  strPath = funStartRangeParse(strFullHTMLPath,"\",lngEndElement)
  '
  IF ISTRUE funLoadImageFile(strPath & strSource, _
                             lng_imgW, _
                             lng_imgH, _
                             hBMP ) THEN
  ' reattach to graphics control
    GRAPHIC ATTACH hDlg, %IDC_Graphic
    ' copy bitmap
    GRAPHIC COPY hBmp,0 TO (g_lngX,g_lngY)
    ' now update global position
    GRAPHIC GET POS TO g_lngX, g_lngY
    g_lngY = g_lngY + lng_imgH
    '
    GRAPHIC BITMAP END
    ' redraw for user
    GRAPHIC REDRAW
    '
  END IF
END FUNCTION
'
FUNCTION funGetTagValue(lngStartPosition AS LONG, _
                        strTagEnd AS STRING) AS STRING
' return the content of the tag
  LOCAL lngEnd AS LONG
  '
  lngStartPosition = INSTR(lngStartPosition,g_strLcHTML,">") +1
  lngEnd   = INSTR(lngStartPosition,g_strLcHTML,strTagEnd)
  FUNCTION = MID$(g_strHTML,lngStartPosition,lngEnd-lngStartPosition)
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
        GRAPHIC SET POS (g_lngX, g_lngY)
        GRAPHIC PRINT strText
        GRAPHIC GET POS TO g_lngX, g_lngY
      END IF
      '
    NEXT lngB
    '
  ELSE
  ' no line breaks
    GRAPHIC SET POS (g_lngX, g_lngY)
    GRAPHIC PRINT TRIM$(strData)
    GRAPHIC GET POS TO g_lngX, g_lngY
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
FUNCTION funClearGraphicsControl() AS LONG
' repaint the graphics control
  ' reset the co-ords
  g_lngX = 0 : g_lngY = 0
  GRAPHIC CLEAR %RGB_WHITE ,0
  GRAPHIC REDRAW
  '
END FUNCTION
'------------------------------------------------------------------------------
FUNCTION funResizeControls(hDlg AS DWORD) AS LONG
' resize the windows controls
'
  LOCAL lngWide, lngHigh AS LONG
' return to fixed size to avoid resize issues
  GRAPHIC SET FIXED
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
  ' get the current size of the graphics window
  GRAPHIC GET SIZE TO lngWide, lngHigh
  '
  ' set the size of a virtual graphics control
  GRAPHIC SET VIRTUAL  lngWide-5, lngHigh * 3
  '
  GRAPHIC REDRAW
  '
END FUNCTION

'------------------------------------------------------------------------------
'   ** Dialogs **
'------------------------------------------------------------------------------
FUNCTION ShowdlgPBLiteBrowser(BYVAL hParent AS DWORD) AS LONG
  LOCAL lngResult AS LONG
  LOCAL lngWide AS LONG     ' width of the graphics control
  LOCAL lngHigh AS LONG     ' height of the graphics control

#PBFORMS BEGIN DIALOG %IDD_dlgPBLiteBrowser->->
  LOCAL hDlg  AS DWORD

  DIALOG NEW hParent, "PB Lite Browser", 229, 201, 611, 324, %WS_POPUP OR _
    %WS_BORDER OR %WS_DLGFRAME OR %WS_CAPTION OR %WS_SYSMENU OR _
    %WS_MINIMIZEBOX OR %WS_MAXIMIZEBOX OR %WS_CLIPSIBLINGS OR %WS_VISIBLE OR _
    %WS_THICKFRAME OR %DS_MODALFRAME OR %DS_3DLOOK OR %DS_NOFAILCREATE OR _
    %DS_SETFONT, %WS_EX_CONTROLPARENT OR %WS_EX_LEFT OR %WS_EX_LTRREADING OR _
    %WS_EX_RIGHTSCROLLBAR, TO hDlg
  CONTROL ADD STATUSBAR, hDlg, %IDC_STATUSBAR1, "", 0, 0, 0, 0
  CONTROL ADD TEXTBOX,   hDlg, %IDC_txtURL, "", 135, 5, 475, 20
  CONTROL ADD IMGBUTTON, hDlg, %IDC_IMGback, "", 0, 0, 32, 32
  CONTROL ADD IMGBUTTON, hDlg, %IDC_IMGForward, "", 33, 0, 32, 32
  CONTROL ADD IMGBUTTON, hDlg, %IDC_IMGReload, "", 66, 0, 32, 32
  CONTROL ADD IMGBUTTONX, hDlg, %IDC_IMGHome, "", 99, 0, 32, 32
  CONTROL ADD TAB,       hDlg, %IDC_TAB1, "Tab1", 0, 35, 610, 20
#PBFORMS END DIALOG
  lngWide = 600
  lngHigh = 250
  CONTROL ADD GRAPHIC, hDlg, %IDC_Graphic, "", 5, 56, lngWide, lngHigh, _
                       %SS_NOTIFY OR %SS_SUNKEN
                       '
  ' attach to the graphics control
  GRAPHIC ATTACH hDlg,%IDC_Graphic , REDRAW
  ' clear the control and fill it with solid white colour
  GRAPHIC CLEAR %RGB_WHITE ,0
  '
  ' turn on the graphics wrap
  GRAPHIC SET WORDWRAP %TRUE
  '
  ' set the size of a virtual graphics control
  GRAPHIC SET VIRTUAL  lngWide, lngHigh * 3

  ' redraw the screen for the user
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
  ' set dialog to accept drag and drop
  DragAcceptFiles hDlg, %TRUE
  '
  ' set the icon for the dialog
  DIALOG SET ICON hDlg, "#2000"
  '
  ' store the global handle for this dialog
  g_hDlg = hDlg
  '
  DIALOG SHOW MODAL hDlg, CALL ShowdlgPBLiteBrowserProc TO lngResult
  '
  FUNCTION = lngResult
  '
END FUNCTION
'------------------------------------------------------------------------------
'------------------------------------------------------------------------------
CALLBACK FUNCTION ShowdlgTabClickProc()
  LOCAL lngPageNumber AS LONG
  LOCAL hParent AS LONG
  LOCAL lngTabSelected AS LONG
  '
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
        CASE %IDC_btnCloseTab
          IF CB.CTLMSG = %BN_CLICKED OR CB.CTLMSG = 1 THEN
          ' close the current tab
            IF g_lngTabSelected <= %MAX_TABS THEN
            ' ensure tab is not beyond last element of array
              TAB DELETE g_hDlg, %IDC_TAB1, g_lngTabSelected
              '
              ' remove details of tab history
              funRemoveTabHistory(g_lngTabSelected)
              '
              ' reduce current selected tab number by 1
              DECR g_lngTabSelected
              '
                ' reset to new focused tab
              TAB SELECT g_hDlg, %IDC_TAB1, g_lngTabSelected
              CONTROL SET TEXT g_hDlg,%IDC_txtURL, _
                               g_astrURLS(g_lngTabSelected)
                 ' clear and rerender the web page
              funClearGraphicsControl()
              '
              funRenderTheHTML(g_astrURLS(g_lngTabSelected), _
                               g_hDlg, %IDC_TAB1)
            END IF
            DIALOG END CB.HNDL
          END IF
          '
      END SELECT
  END SELECT
END FUNCTION
'------------------------------------------------------------------------------
FUNCTION funRemoveTabHistory(lngTabSelected AS LONG) AS LONG
' tab has been deleted so remove it's history
  LOCAL lngR AS LONG
  LOCAL lngT AS LONG
  '
  ' first delete the current URL from the array
  ' and move all tabs URLs above it down by one
  ARRAY DELETE g_astrURLS(lngTabSelected)
  '
  ' now purge the history
  ARRAY DELETE g_lngLatestSlot(lngTabSelected)
  '
  FOR lngT = lngTabSelected TO %MAX_TABS -1
    FOR lngR = 1 TO %MAX_HISTORY
    ' copy tab above down
      g_astrURLhistory(lngT,lngR) = _
                       g_astrURLhistory(lngT +1,lngR)
    NEXT lngR
  NEXT lngT
  '
  ' now purge last tab
  FOR lngR = 1 TO %MAX_HISTORY
   g_astrURLhistory(%MAX_TABS,lngR) = ""
  NEXT lngR
  '
END FUNCTION
'------------------------------------------------------------------------------
FUNCTION ShowdlgTabClick(BYVAL hParent AS DWORD, _
                         lngX AS LONG, lngY AS LONG) AS LONG
  LOCAL lRslt AS LONG
  LOCAL lngPX , lngPY AS LONG ' parent dialog location
  '
#PBFORMS BEGIN DIALOG %IDD_dlgTabClick->->
  LOCAL hDlg  AS DWORD

  DIALOG NEW hParent, "", 268, 273, 80, 20, %WS_POPUP OR %WS_CLIPSIBLINGS OR _
    %WS_VISIBLE OR %DS_MODALFRAME OR %DS_3DLOOK OR %DS_NOFAILCREATE OR _
    %DS_SETFONT, %WS_EX_CONTROLPARENT OR %WS_EX_LEFT OR %WS_EX_LTRREADING OR _
    %WS_EX_RIGHTSCROLLBAR, TO hDlg
  CONTROL ADD BUTTON, hDlg, %IDC_btnCloseTab, "Close Tab", 0, 0, 80, 15
#PBFORMS END DIALOG
  '
  ' get location of parent
  DIALOG GET LOC hParent TO lngPX, lngPY
  ' set this dialogs location
  DIALOG SET LOC hDlg, lngPX,lngPY
  '
  DIALOG SHOW MODAL hDlg, CALL ShowdlgTabClickProc TO lRslt
  '
#PBFORMS BEGIN CLEANUP %IDD_dlgTabClick
#PBFORMS END CLEANUP
  '
  FUNCTION = lRslt
END FUNCTION
'------------------------------------------------------------------------------
