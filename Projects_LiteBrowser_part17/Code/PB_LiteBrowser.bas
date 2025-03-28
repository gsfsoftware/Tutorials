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
DECLARE FUNCTION DeleteUrlCacheEntryA IMPORT "WININET.DLL" ALIAS "DeleteUrlCacheEntryA" ( _
   BYREF lpszUrlName AS ASCIIZ _                        ' __in LPCSTR lpszUrlName
 ) AS LONG                                              ' BOOL
'
DECLARE FUNCTION DeleteUrlCacheEntryW IMPORT "WININET.DLL" ALIAS "DeleteUrlCacheEntryW" ( _
   BYREF lpszUrlName AS WSTRINGZ _                      ' __in LPCWSTR lpszUrlName
 ) AS LONG                                              ' BOOL

#IF %DEF(%UNICODE)
   MACRO DeleteUrlCacheEntry = DeleteUrlCacheEntryW
#ELSE
   MACRO DeleteUrlCacheEntry = DeleteUrlCacheEntryA
#ENDIF


'
GLOBAL g_lngTabcount AS LONG      ' total number of tabs
GLOBAL g_alngTabHandles() AS LONG ' array to hold tab handles
GLOBAL g_astrURLS() AS STRING     ' array to hold urls of tabs
GLOBAL g_astrTargetNames() AS STRING ' array of tab target names
GLOBAL g_astrURLhistory() AS STRING ' URL history of all tabs
GLOBAL g_lngLatestSlot() AS LONG    ' array to hold latest slot for each tab
GLOBAL g_astrGraphicCache() AS STRING ' array to hold graphic cache string
'
TYPE udtImgTag      ' type for top left and bottom right coords
  lngTopX AS LONG   ' of an image
  lngTopY AS LONG
  lngBottomX AS LONG
  lngBottomY AS LONG
  strURL AS STRING * 1024       ' url of the page
  strTarget AS STRING * 1024    ' optional target page
END TYPE
'
GLOBAL g_uURLs() AS udtImgTag       ' array for URL links
'
TYPE udtObject                  ' type for start and
  lngStart AS POINT             ' end locations of objects
  lngEnd AS POINT
END TYPE
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
%WidthMultiplier  = 3         ' used to set width of virtual graphic control
%HeightMultiplier = 3         ' used to set height of virtual graphic control
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
GLOBAL g_hFont AS DWORD        ' default font
GLOBAL g_hUFont AS DWORD       ' default underlined font
GLOBAL ga_hFonts() AS DWORD  ' array of fonts
GLOBAL ga_hUFonts() AS DWORD   ' array of underlined fonts
'
%BOLDFONT = 5                  ' element of ga_hFonts that is
                               ' 12 point bold
'
%MAX_TABS = 16                  ' maximum number of tabs allowed
%MAX_HISTORY = 10               ' maximum history on each tab
%MAX_URLS = 100                 ' maximum urls per page
GLOBAL g_lngTabSelected AS LONG ' number of currently selected tab
GLOBAL g_hDlg AS DWORD          ' global handle for main dialog
'
' print location
GLOBAL g_lngX, g_lngY AS LONG   ' Global X and Y print locations
'
$CacheFolder = "Cache"          ' name of the html and img file cache folder
'------------------------------------------------------------------------------
'   ** Main Application Entry Point **
'------------------------------------------------------------------------------
FUNCTION PBMAIN()
  PBFormsInitComCtls (%ICC_WIN95_CLASSES OR %ICC_DATE_CLASSES OR _
    %ICC_INTERNET_CLASSES)
    '
  funCreateFonts() ' create the fonts
  '
  ' test for Cache folder
  IF ISFALSE ISFOLDER(EXE.PATH$ & $CacheFolder) THEN
  ' create cache folder
    MKDIR EXE.PATH$ & $CacheFolder
  END IF
  '
  ' prepare the URLs arrays
  REDIM g_astrURLS(%MAX_TABS)       ' for current URL on each tab
  REDIM g_alngTabHandles(%MAX_TABS) ' for tab handles for each tab
  REDIM g_astrURLhistory(%MAX_TABS,%MAX_HISTORY) ' for history of all tabs
  REDIM g_lngLatestSlot(%MAX_TABS)  ' for latest slot for each tab
  REDIM g_uURLs(%MAX_TABS,%MAX_URLS) ' for URL links per tab
  REDIM g_astrTargetNames(%MAX_TABS) ' for names of the tabs
  REDIM g_astrGraphicCache(%MAX_TABS) ' for graphic page caches
  '
  ShowdlgPBLiteBrowser %HWND_DESKTOP
  ' tidy up fonts when app ending
  funUnloadFonts()
  '
END FUNCTION
'
FUNCTION funHexToRGB(BYVAL strHexColor AS STRING) AS STRING
  LOCAL lngR AS LONG
  LOCAL lngG AS LONG
  LOCAL lngB AS LONG

  ' Remove the hash (#) if present
  IF LEFT$(strHexColor, 1) = "#" THEN
    strHexColor = MID$(strHexColor, 2)
  END IF
  ' Convert hex to RGB
  lngR = VAL("&H" & MID$(strHexColor, 1, 2))
  lngG = VAL("&H" & MID$(strHexColor, 3, 2))
  lngB = VAL("&H" & MID$(strHexColor, 5, 2))
  '
  ' Return the RGB values as a delimted string
  FUNCTION = FORMAT$(lngR) & "," & _
             FORMAT$(lngG) & "," & _
             FORMAT$(lngB)
  '
END FUNCTION
'
FUNCTION funUnloadFonts() AS LONG
' unload all the fonts
  LOCAL lngF AS LONG
  '
  FONT END g_hFont
  FONT END g_hUFont
  ' end each of the fonts created
  FOR lngF = 1 TO 6
    FONT END ga_hFonts(lngF)
    FONT END ga_hUFonts(lngF)
  NEXT lngF
  '
END FUNCTION
'------------------------------------------------------------------------------
FUNCTION funCreateFonts() AS LONG
' create all the fonts needed
  REDIM ga_hFonts(6) AS DWORD  ' array for fonts
  REDIM ga_hUFonts(6) AS DWORD ' array for underlined fonts
  LOCAL lngF AS LONG
  LOCAL lngPoint AS LONG
  LOCAL lngStyle AS LONG
  LOCAL lngUnderlined AS LONG
  '
  lngPoint = 12
  ' create a new font
  FONT NEW "Courier New",lngPoint TO g_hFont
  ' create the underlined version
  FONT NEW "Courier New",lngPoint,5,0,0,0 TO g_hUFont
  '
  lngPoint = 30 ' set starting font size
  lngStyle = 1  ' set to bold
  lngUnderlined = 5 ' set to underlined (bold + underlined)
  '
  ' create each of the fonts
  FOR lngF = 1 TO 6
    FONT NEW "Courier New",lngPoint,lngStyle TO ga_hFonts(lngF)
    ' now create the underlined versions
    FONT NEW "Courier New",lngPoint,lngUnderlined TO ga_hUFonts(lngF)
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
      g_astrTargetNames(1) = "Home"
          '
      ' store the tab handle
      g_alngTabHandles(1) = lngPageDlgVar
      '
      ' Add the + tab page
      TAB INSERT PAGE CB.HNDL, %IDC_TAB1, 2, 0, "+" _
          TO lngPageDlgVar
      g_alngTabHandles(2) = lngPageDlgVar
      g_astrTargetNames(2) = "+"
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
      '
      ' get the tab currently selected
      TAB GET SELECT CB.HNDL, %IDC_TAB1 TO g_lngTabSelected
      ' render the graphic control from the stored cache
      GRAPHIC SET BITS g_astrGraphicCache(g_lngTabSelected)
      GRAPHIC REDRAW
      'funRenderTheHTML(strURL, CB.HNDL, %IDC_TAB1)
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
                GRAPHIC SET BITS g_astrGraphicCache(lngPageNumber)
                GRAPHIC REDRAW
                'funRenderTheHTML(strURL, CB.HNDL, %IDC_TAB1)
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
            'funRenderTheHTML(strURL, CB.HNDL, %IDC_TAB1)
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
FUNCTION funProcess_a_URL(strURL AS STRING, _
                          strTarget AS STRING) AS LONG
' process a new URL into the current tab
' or if a target into an existing tab
' or a new tab
  LOCAL lngPageNumber AS LONG
  LOCAL strPath AS STRING
  LOCAL strDelimeter AS STRING
  LOCAL lngEndElement AS LONG
  '
  LOCAL lngTabNumber AS LONG
  LOCAL lngPageDlgVar AS LONG
  '
  ' first get the existing path
  CONTROL GET TEXT g_hDlg,%IDC_txtURL TO strPath
  '
  IF INSTR(strURL,ANY "/\") = 0 THEN
  ' this is relative path to wherever the existing URL is
    IF INSTR(strPath,"\") > 0 THEN
    ' determine delimiter
      strDelimeter = "\"
    ELSE
      strDelimeter = "/"
    END IF
    '
    ' if path is h:\html\index.html
    lngEndElement = PARSECOUNT(strPath,strDelimeter) -1
    ' lngEndElement will now be 2
    strPath = funStartRangeParse(strPath, _
                                 strDelimeter, _
                                 lngEndElement)
    ' and path will now be h:\html\
    ' now add the URL to the path
    strURL = strPath & strURL
  '
  ELSE
  ' new path?
  END IF
  '
  funClearGraphicsControl()
  '
  CONTROL SET TEXT g_hDlg,%IDC_txtURL, strURL
  '
  ' is there a Target set?
  IF strTarget <> "" THEN
  ' does the target already exist?
    lngPageNumber = funFindTargetTAB(strTarget)
   '
    IF lngPageNumber = 0 THEN
    ' no existing tab found - so create a new one
      lngTabNumber = funGetNextTab()
      ' Add the new tab
      TAB INSERT PAGE g_hDlg, %IDC_TAB1, lngTabNumber, 0, strTarget _
          TO lngPageDlgVar
      '
       ' insert new Array entries
      funInsertNewArrayEntries(lngTabNumber)
          '
      g_alngTabHandles(lngTabNumber) = lngPageDlgVar
      g_astrURLS(lngTabNumber) = strURL
      g_astrTargetNames(lngTabNumber) = strTarget
      '
       ' select Page
      g_lngTabSelected = lngTabNumber
      TAB SELECT g_hDlg, %IDC_TAB1, g_lngTabSelected
      lngPageNumber = lngTabNumber
      '
      ' advance latest slot for this tab
      INCR g_lngLatestSlot(lngPageNumber)
      '
    ELSE
    ' existing tab found
      lngTabNumber = lngPageNumber
      g_lngTabSelected = lngTabNumber
      TAB SELECT g_hDlg, %IDC_TAB1, g_lngTabSelected
      ' store the url
      g_astrURLS(lngTabNumber) = strURL
    END IF
  '
  ELSE
  ' no target specified
  ' store the URL in global array
    TAB GET SELECT g_hDLG, %IDC_TAB1 TO lngPageNumber
    g_astrURLS(lngPageNumber) = strURL
    g_astrTargetNames(lngTabNumber) = "" ' no target set
  '
    ' advance latest slot for this tab
    INCR g_lngLatestSlot(lngPageNumber)
  END IF
  '
  ' store the new URL as latest web page
  funStoreURLHistory(lngPageNumber, strURL)
  '
  ' render the URL to the graphics control
  funRenderTheHTML(strURL, g_hDLG, %IDC_TAB1)
  '
END FUNCTION
'
FUNCTION funGetNextTab() AS LONG
' get the next tab available
  LOCAL lngTab AS LONG
  '
  FOR lngTab = 1 TO %MAX_TABS
    IF g_alngTabHandles(lngTab) = 0 THEN
      FUNCTION = lngTab -1
      EXIT FUNCTION
    END IF
  NEXT lngTab
  '
  FUNCTION = 0   ' no tabs available
  '
END FUNCTION
'
FUNCTION funFindTargetTAB(strTarget AS STRING) AS LONG
' find if there is an existing TAB with this target name
  LOCAL lngPageNumber AS LONG
  '
  FOR lngPageNumber = 1 TO UBOUND(g_astrURLS)
    IF g_astrTargetNames(lngPageNumber) = strTarget THEN
      FUNCTION = lngPageNumber ' found strTarget
      EXIT FUNCTION
    END IF
  NEXT lngPageNumber
  '
  FUNCTION = %FALSE ' not found
  '
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
  LOCAL strURL AS STRING                  ' url of page
  LOCAL strTarget AS STRING               ' optional target of page
  LOCAL lngWidthVar, lngHeightVar AS LONG ' position of the graphic view
  '
  STATIC hHand AS DWORD         ' handle for the mouse cursor
  '
  SELECT CASE wMsg
    '
    CASE %WM_MOUSEMOVE
    ' mouse has moved
      lngX = LO(INTEGER, lParam)
      lngY = HI(INTEGER, lParam)
      '
      ' since we are using a virtual window
      ' get the begining of this window
      GRAPHIC GET VIEW TO lngWidthVar, lngHeightVar
      lngX = lngX + lngWidthVar
      lngY = lngY + lngHeightVar
      '
      ' determine if click is on a link area
      strURL = ""    ' url value
      strTarget = "" ' optional target value
      IF ISTRUE funIsLink(lngX,lngY,strURL, strTarget) THEN
      ' zone under cursor has hyperlink
      ' so set cursor
        IF hHand = 0 THEN
        ' cursor not yet loaded
          hHand = LoadCursor(%Null, BYVAL %IDC_HAND)
        END IF
        SetCursor hHand
      END IF
    '
    CASE %WM_LBUTTONUP
      ' get mouse co-ords
      lngX = LO(INTEGER, lParam)
      lngY = HI(INTEGER, lParam)
      '
      ' since we are using a virtual window
      ' get the begining of this window
      GRAPHIC GET VIEW TO lngWidthVar, lngHeightVar
      lngX = lngX + lngWidthVar
      lngY = lngY + lngHeightVar

       ' determine if click is on a link area
      strURL = ""    ' blank out URL
      strTarget = "" ' and optional target page
      IF ISTRUE funIsLink(lngX,lngY,strURL, strTarget) THEN
      ' have we clicked on a link area?
      '  msgbox "YES"
      ' link to the new URL
        funProcess_a_URL(strURL,strTarget)
      '
      END IF
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
FUNCTION funIsLink(lngX AS LONG, _
                   lngY AS LONG, _
                   strURL AS STRING, _
                   strTarget AS STRING) AS LONG
' determine if the area clicked on is within
' a link area
'
  LOCAL lngR AS LONG
  ' check the uURLs array
  FOR lngR = 1 TO %MAX_URLS
  ' sweep through all possible stored hyperlinks
    IF lngX > g_uURLs(g_lngTabSelected,lngR).lngTopX AND _
       lngX < g_uURLs(g_lngTabSelected,lngR).lngBottomX AND _
       lngY > g_uURLs(g_lngTabSelected,lngR).lngTopY AND _
       lngY < g_uURLs(g_lngTabSelected,lngR).lngBottomY THEN
    ' this is a link area
      ' return the URL & target values
      strURL = TRIM$(g_uURLs(g_lngTabSelected,lngR).strURL)
      strTarget = TRIM$(g_uURLs(g_lngTabSelected,lngR).strTarget)
      FUNCTION = %TRUE
      EXIT FUNCTION
    END IF
  NEXT lngR
  '
  FUNCTION = %FALSE
  '
END FUNCTION
'
FUNCTION funRenderTheHTML(strURL AS STRING, _
                          hDlg AS DWORD, _
                          lngTab AS LONG) AS LONG
' render the html to the graphics control
  LOCAL strHTML AS STRING         ' holds the html file
  LOCAL lngTabSelected AS LONG    ' tab number selected
  LOCAL strTabName AS STRING      ' name of the tab
  '
  LOCAL lngIsWebPage AS LONG      ' true if URL is web site
                                  ' false if local file
  '
  ' exit immediately if no URL/PATH
  IF TRIM$(strURL) = "" THEN EXIT FUNCTION
  '
  GRAPHIC CLEAR %WHITE
  GRAPHIC COLOR %BLACK,%WHITE
  GRAPHIC SET FONT g_hFont ' set the default font
  GRAPHIC SET POS (1,1)
  '
  ' set the virtual page back to the start
  GRAPHIC SET VIEW 0,0
  GRAPHIC REDRAW
  '
  funClearGraphicsControl()
  '
  ' load the html file
  g_strHTML = funLoadHTMLPage(strURL, lngIsWebPage)
  g_strLcHTML = LCASE$(g_strHTML)
  '
  IF g_strHTML <> "" THEN
  ' page has been loaded
    strTabName = PARSE$(strURL,ANY "\/" ,-1)
    TAB GET SELECT hDlg, lngTab TO lngTabSelected
    TAB SET TEXT hDlg, lngTab, lngTabSelected, _
                       TRIM$(strTabName)
   '
  END IF
  '
  IF ISTRUE funValidateHTML() THEN
  ' is valid html
    'GRAPHIC PRINT "HTML formatting ok"
    funRenderHTMLTags(hDlg,lngTab, lngIsWebPage)
    '
  ELSE
  ' html formatting error
    GRAPHIC ATTACH hDlg,%IDC_Graphic , REDRAW
    GRAPHIC PRINT "Invalid HTML formatting"
    'GRAPHIC PRINT g_strHTML
  END IF
  '
  GRAPHIC REDRAW
  ' store the graphic image
  GRAPHIC GET BITS TO g_astrGraphicCache(lngTabSelected)
  '
END FUNCTION
'
FUNCTION funResetURLs(lngTab AS LONG) AS LONG
' reset the urls for the current tab
  LOCAL lngR AS LONG
  '
  FOR lngR = 1 TO %MAX_URLS
    PREFIX "g_uURLs(lngTab,lngR)."
      lngTopX = 0      ' top left of an image
      lngTopY = 0
      lngBottomX = 0
      lngBottomY = 0
      strURL = ""      ' url of the page
      strTarget = ""   ' optional target page
    END PREFIX
  NEXT lngR
  '
END FUNCTION
'
FUNCTION funRenderHTMLTags(hDlg AS DWORD, _
                           lngTab AS LONG, _
                           lngIsWebPage AS LONG) AS LONG
' render each of the tags by stepping through each
' tag in the strHTML
  '
  LOCAL lngStart, lngEnd AS LONG
  LOCAL lngHTMLPos AS LONG
  LOCAL strChar AS STRING
  LOCAL strCommand AS STRING    ' current command
  LOCAL strLastCommand AS STRING ' last command executed
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
  LOCAL lngRefTag AS LONG       ' true/false for inside a ref tag
  LOCAL uImgTag AS udtImgTag    ' type for link co-ords
  LOCAL strURL AS STRING        ' URL in a link
  LOCAL lngURL AS LONG          ' last populated URL
  LOCAL lngInParagraph AS LONG  ' true/false is inside a paragraph tag
  LOCAL lngImage AS LONG        ' true/false if <a> tag contains an image
  LOCAL strTarget AS STRING     ' string for TARGET option
  '
  LOCAL lngInTable AS LONG      ' true/false if inside table
  '
  ' as this is a new page reset all the click zones for this page
  TAB GET SELECT hDlg, lngTab TO lngTabSelected
  funResetURLs(lngTabSelected) ' g_uURLs()
  '
  FOR lngHTMLPos = 1 TO LEN(g_strLcHTML)
  ' step through each character
    strChar = MID$(g_strLcHTML,lngHTMLPos,1)
    '
    IF strChar = "<" THEN
    ' start of a tag - pick up the command
      strLastCommand = strCommand  ' store last command
      '
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
          GRAPHIC SET FONT g_hFont
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
            lngInParagraph = %TRUE ' inside a paragraph
            '
            strData = funGetTagValue(lngStart, "</p>")
            'graphic print strData
            funPrintData(strData,lngRefTag,uImgTag)
          END IF
          '
        CASE "/p"
        ' end of paragraph
          IF ISTRUE lngInBody THEN
            lngInParagraph = %FALSE ' outside a paragraph
            IF strLastCommand = "/a" AND ISTRUE lngImage THEN
            ' last command was an <a> tag and contained an image
              g_lngX = 0
              g_lngY = g_lngY + uImgTag.lngBottomY - uImgTag.lngTopY
              GRAPHIC SET POS (g_lngX, g_lngY)
            '
              funPrintBlankLine()
            '
            ELSE
            ' handle the end of paragraphs for text
              funPrintBlankLine()
              funPrintBlankLine()
            END IF
            '
          END IF
          '
        CASE "img"
        ' start of image tag
           IF ISTRUE lngInBody AND ISFALSE lngInTable THEN
           ' inside body of html and not inside a table
           ' strAttributes should hold any attributes
            TAB GET SELECT hDlg, lngTab TO lngTabSelected
            '
            RESET uImgTag    ' blank out the UDT for tag
            '
            ' handle displaying of image and store location
            ' in uImgTag
            funDisplayImage(hDlg, strAttributes,lngTabSelected,_
                            uImgTag,lngInParagraph, lngIsWebPage)
            '
            IF ISTRUE lngRefTag THEN
            ' we are inside a ref tag - so store the link
            ' strURL & strTarget are already populated
            ' advance the current URL
              INCR lngURL
              ' populate the link
              PREFIX "uImgTag."
                strURL = strURL        ' URL of page
                strTarget = strTarget  ' optional target
              END PREFIX
              ' save the udt into the global array
              g_uURLs(lngTabSelected,lngURL) = uImgTag
            '
            END IF
          '
          END IF
          '
        CASE "a"
        ' start of a ref tag
          lngRefTag = %TRUE
          ' amend to handle possible TARGET option
          strURL = TRIM$(PARSE$(strAttributes,ANY "=""",3),$DQ)
          '
          ' pick up target
          IF INSTR(strAttributes,"target=") >0 THEN
            strTarget = TRIM$(PARSE$(strAttributes,"target=",2),$DQ)
          ELSE
            strTarget = ""
          END IF
          '
          ' get the data
          strData = funGetTagValue(lngStart, "</a>")
          '
          IF INSTR(strData,"=") = 0 THEN
          ' not an image source but plain text
            lngImage = %FALSE
            RESET uImgTag    ' blank out the UDT for tag
            ' we are inside a ref tag - so store the link
            ' strURL already populated
            ' advance the current URL
            INCR lngURL
            ' populate the link
            PREFIX "uImgTag."
              strURL = strURL
              strTarget = strTarget
            END PREFIX
            '
            funPrintData(strData,lngRefTag,uImgTag)
            '
            TAB GET SELECT hDlg, lngTab TO lngTabSelected
            ' save the udt into the global array
            g_uURLs(lngTabSelected,lngURL) = uImgTag
          '
          ELSE
          ' this is an image link
            lngImage = %TRUE
          END IF
        '
        CASE "/a"
        ' end of ref tag
          lngRefTag = %FALSE
          '
        CASE "u"
        ' underline
          GRAPHIC SET FONT g_hUFont
          ' get the data
          strData = funGetTagValue(lngStart, "</u>")
          funPrintData(strData,lngRefTag,uImgTag)
        '
        CASE "/u"
        ' end of underline
          GRAPHIC SET FONT g_hFont
          '
          IF ISTRUE lngInParagraph THEN
          ' inside a paragraph
            strData = funGetTagValue(lngStart, "</p>")
            funPrintData(strData,lngRefTag,uImgTag)
          END IF
          '
        CASE "table"
        ' handle tables
          lngInTable = %TRUE
          funBuildTable(lngStart, strAttributes, _
                        hDlg, lngTab, lngIsWebPage)
          '
        CASE "/table"
        ' reached end of table
          lngInTable = %FALSE
          '
        CASE ELSE
        ' handle anything else

      END SELECT
      '
    END IF
    '
  NEXT lngHTMLPos
  '
END FUNCTION
'
FUNCTION funBuildTable(lngStart AS LONG, _
                       strTableAttributes AS STRING, _
                       hDlg AS DWORD, _
                       lngTab AS LONG, _
                       lngIsWebPage AS LONG) AS LONG
' build a table structure
  LOCAL strData AS STRING     ' characters in the table
  LOCAL strLcData AS STRING   ' lower case characters in the table
  LOCAL lngT AS LONG              ' character position
  LOCAL strChar AS STRING         ' character being processed
  LOCAL strLastCommand AS STRING  ' last command
  LOCAL strCommand AS STRING      ' current command
  LOCAL lngTStart AS LONG         ' start of command
  LOCAL lngTEnd AS LONG           ' end of command
  LOCAL lngAttribute AS LONG      ' attribute flag
  LOCAL strAttributes AS STRING   ' attribute text
  LOCAL lngInCommand AS LONG      ' in command flag
  LOCAL lngExitCommand AS LONG    ' exit command flag
  '
  LOCAL lngHeaderColumns AS LONG  ' no. of header columns
  LOCAL lngDataColumns AS LONG    ' no. of data columns
  LOCAL lngRowCount AS LONG       ' rows in the array
  LOCAL lngColumnCount AS LONG    ' columns in the array
  LOCAL lngRow AS LONG            ' array row number
  LOCAL lngColumn AS LONG         ' array column number
  '
  LOCAL strColumnData AS STRING   ' data for column
  LOCAL strCaption AS STRING      ' caption for the table
  '
  LOCAL lngHeader AS LONG         ' true/false for header in table
  LOCAL lngTabC AS LONG           ' table column counter for Table
                                  ' Colour array
  LOCAL strColour AS STRING       ' Background Colour for cell
  '
  LOCAL lngTabSelected AS LONG    ' tab that has been selected
  LOCAL lngInParagraph AS LONG    ' true/false is inside a paragraph tag
  LOCAL uImgTag AS udtImgTag      ' type for link co-ords
  '
  ' get all the table data
  strData = funGetTagValue(lngStart, "</table>")
  strLcData = LCASE$(strData)
  '
  ' count the headers and columns
  lngHeaderColumns = TALLY(strLcData,"<th")
  lngDataColumns   = TALLY(strLcData,"<td")
  lngRowCount = TALLY(strLcData,"<tr")
  '
   ' get the largest column count
  lngColumnCount = MAX(lngHeaderColumns,lngDataColumns)
  '
  IF lngHeaderColumns > 0 AND lngRowCount > 2 THEN
  ' handle multiple rows
    lngColumnCount = lngDataColumns/(lngRowCount-1)
  END IF
  '
  ' prep the table array to hold data
  DIM a_strTable(1 TO lngRowCount,1 TO lngColumnCount) AS STRING
  ' prep the table colours array to hold data
  DIM a_strTableColours(1 TO lngRowCount,1 TO lngColumnCount) AS STRING
  '
  WHILE lngT < LEN(strData)
    INCR lngT
    strChar = MID$(strLcData,lngT,1)
    '
    IF strChar = "<" THEN
    ' start of a tag - pick up the command
      strLastCommand = strCommand  ' store last command
      '
      lngTStart = lngT + 1
      lngTEnd = INSTR(lngTStart,strData,">")
      strCommand = MID$(strLcData,lngTStart,lngTEnd-lngTStart)
      '
       ' capture attributes
      ' e.g. strCommand = "tr align=center"
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
      ' pick up the Tag value of the command
      SELECT CASE strCommand
        CASE "caption"
        ' caption of the table - store the value
          strCaption = funGetTableTagValue(lngT, "</caption>", _
                                           strData,strLcData)
                                           '
          ' advance pointer
          lngT = lngTEnd + LEN(strCaption) + LEN("</caption>")
          '
        CASE "tr"
        ' new row
          INCR lngRow
            '
          ' handle attributes
          IF INSTR(strAttributes,"background-color:") > 0 THEN
          ' there is a background colour for this row
          ' store it in the Table colour array for each cell
            strColour = PARSE$(strAttributes,"background-color:",2)
            strColour = PARSE$(strColour,$DQ,1)
            '
            FOR lngTabC = 1 TO lngColumnCount
              a_strTableColours(lngRow,lngTabC) = funHexToRGB(strColour)
            NEXT lngTabC
          '
          END IF
          '
          lngT = lngT + LEN("tr>") + LEN(strAttributes)
          '
         CASE "/tr"
        ' end of row
          lngColumn = 0
          ' advance pointer
          lngT = lngT + LEN("tr>")
          '
        CASE "th"
        ' start of header column
          INCR lngColumn
          ' get the data
          strColumnData = funGetTableTagValue(lngT, "</th>", _
                                         strData,strLcData)
          ' store the data in the array
          a_strTable(lngRow,lngColumn) = strColumnData
          '
          lngHeader = %TRUE
          ' advance pointer
          lngT = lngT + LEN(strColumnData) + LEN("</th>")
          '
        CASE "td"
         ' start of data column
          INCR lngColumn
          ' get the data
          strColumnData = funGetTableTagValue(lngT, "</td>", _
                                         strData,strLcData)
                                         '
          ' store the data in the array
          a_strTable(lngRow,lngColumn) = strColumnData
          '
          lngT = lngT + LEN(strColumnData) + LEN("</td>")
          '
      END SELECT
      '
    END IF
    '
  WEND
  '
  ' reached the end of the table details
  ' end of table - so display it on graphics control
  ' pick up the tab selected
  TAB GET SELECT hDlg, lngTab TO lngTabSelected
  '
  ' display the table on the graphics control
  funDisplayTable(a_strTable(), strCaption, _
                  lngHeader, LCASE$(strTableAttributes), _
                  a_strTableColours(), _
                  hDlg,lngTabSelected, _
                  lngInParagraph, lngIsWebPage)
  '
END FUNCTION
'
FUNCTION funDisplayTable(BYREF a_strTable() AS STRING, _
                         strCaption AS STRING, _
                         lngHeader AS LONG, _
                         strTableAttributes AS STRING, _
                         BYREF a_strTableColours() AS STRING, _
                         hDlg AS DWORD,lngTabSelected AS LONG, _
                         lngInParagraph AS LONG, _
                         lngIsWebPage AS LONG) AS LONG
' display the table on the graphics control
  '
  LOCAL lng_imgW, lng_imgH AS LONG  ' width and height of one character
  LOCAL lngCaptionWidth AS LONG     ' width of the caption
  LOCAL lngTableWidth AS LONG       ' width of the whole table
  LOCAL lngColumns AS LONG          ' number of columns in table
  LOCAL lngCaptionOffset AS LONG    ' Offset used to position Caption
  '
  LOCAL lngColumn AS LONG           ' column counter
  LOCAL lngRow AS LONG              ' row counter
  LOCAL lngRows AS LONG             ' total rows
  '
  LOCAL lngTableBorder AS LONG      ' true/false for table having a border
  LOCAL uTable AS udtObject         ' used for start and end locations of table
  LOCAL uTempPosition AS udtObject  ' used for temp storage of position
  LOCAL uVerticalLines AS udtObject ' used for tabels vertical lines
  '
  LOCAL uTableColours AS udtObject  ' used for table background colour positions
  '
  LOCAL strTableWidthAmount AS STRING ' % or pixel size of table
  '
  LOCAL lngXOffset AS LONG            ' offset for each column
  LOCAL strColour AS STRING           ' background colour of the cell
  LOCAL lngTX, lngTY AS LONG          ' positions for background colour
  '
  LOCAL uImgTag AS udtImgTag          ' type for link co-ords
  LOCAL strCellContents AS STRING     ' what is in the table cell
  '
  IF INSTR(strTableAttributes,"border=1")> 0 THEN
  ' table is to have border
    lngTableBorder = %TRUE
  END IF
  '
  IF INSTR(strTableAttributes,"width=")> 0 THEN
  ' table has width setting
    strTableWidthAmount = PARSE$(strTableAttributes,"width=",2)
    strTableWidthAmount = PARSE$(strTableWidthAmount," ",1)
  '
  END IF
  '
  ' set foreground and background colors
  ' foreground unchanged   (-3)
  ' background transparent (-2)
  GRAPHIC COLOR -3,-2
  '
  ' get the number of columns in the array
  lngColumns = UBOUND(a_strTable(),2)
  '
  DIM a_lngTableColumns(1 TO lngColumns) AS LONG
  '
  ' get the size of one character
  GRAPHIC CELL SIZE TO lng_imgW, lng_imgH
  ' get the width of the table and each column in array
  lngTableWidth = funWidthOfTable(a_strTable(),lng_imgW, _
                                  lng_imgH,a_lngTableColumns(), _
                                  strTableWidthAmount, _
                                  lngHeader)
  '
  IF strCaption <> "" THEN
  ' there is a caption
  ' calculate the width of all characters in the caption
    lngCaptionWidth = LEN(strCaption) * lng_imgW
    '
    IF lngCaptionWidth < lngTableWidth THEN
    ' caption is smaller width than table
      lngCaptionOffset = (lngTableWidth - lngCaptionWidth) \ 2
      ' set the starting print position
      g_lngX = g_lngX + lngCaptionOffset
    END IF
    '
    ' print the caption
    GRAPHIC SET POS (g_lngX, g_lngY)
    GRAPHIC PRINT strCaption
    GRAPHIC GET POS TO g_lngX, g_lngY
    '
  END IF
  '
  ' now we know the width of each column we can print
  ' the data to the graphics control
  GRAPHIC GET POS TO g_lngX, g_lngY
  '
  ' store starting position
  PREFIX "uTable."
    lngStart.X = g_lngX + (lng_imgW\3)
    lngStart.Y = g_lngY
  END PREFIX
  '
  lngRows = UBOUND(a_strTable,1)
  '
  FOR lngRow = 1 TO lngRows
    '
    IF lngRow = 1 AND lngHeader = %TRUE THEN
    ' first row header should be bold
      GRAPHIC SET FONT ga_hFonts(%BOLDFONT)
    END IF
    '
    FOR lngColumn = 1 TO lngColumns
    ' print the column data
      GRAPHIC SET POS (g_lngX, g_lngY)
      '
      ' background colour?
      strColour = a_strTableColours(lngRow,lngColumn)
      '
      IF lngColumn = 1 THEN
      ' print padding before first column
        ' add on a one character padding
        '
        g_lngX = g_lngX + lng_imgW
        GRAPHIC SET POS (g_lngX, g_lngY)
        '
        IF strColour <> "" THEN
          PREFIX "uTableColours."
            lngStart.X = uTable.lngStart.X
            lngStart.Y = g_lngY
            lngEnd.X = a_lngTableColumns(lngColumn) - (lng_imgW*0.6)
            lngEnd.Y = g_lngY + (lng_imgH *1.3)
          END PREFIX
          '
        END IF
        '
      ELSE
      ' for remainder of columns
      ' add on width of previous column
        g_lngX = funGetPreviousColumnsWidth(a_lngTableColumns(),lngColumn)
        GRAPHIC SET POS (g_lngX, g_lngY)
        '
        '
        PREFIX "uTableColours."
          lngStart.X = uTableColours.lngEnd.X -1
          lngStart.Y = g_lngY
          lngEnd.X = uTableColours.lngStart.X + a_lngTableColumns(lngColumn) - (lng_imgW*0.6)
          lngEnd.Y = g_lngY + (lng_imgH *1.3)
        END PREFIX
        '
        IF lngColumn = lngColumns THEN
        ' handle last column
          uTableColours.lngEnd.X = lngTableWidth
        '
        END IF
        '
      END IF
      '
      IF lngRow > 1 THEN
      ' add on extra fill height for all other rows
        uTableColours.lngStart.Y = uTableColours.lngStart.Y - (lng_imgH *0.3)
      '
      END IF
      ' get the cell contents
      strCellContents = a_strTable(lngRow,lngColumn)
      '
      IF strColour <> ""  THEN
        GRAPHIC BOX (uTableColours.lngStart.X,uTableColours.lngStart.Y) - _
                    (uTableColours.lngEnd.X ,uTableColours.lngEnd.Y),0,%WHITE, _
                    funRGBColour(strColour),0
                    '
        GRAPHIC PRINT strCellContents;
        '
      ELSE
      ' no background colour
      ' is this text or image?
        IF INSTR(strCellContents,"<img src") > 0 THEN
        ' contains an image file
          funDisplayImage(hDlg, strCellContents,lngTabSelected,_
                                uImgTag,lngInParagraph, lngIsWebPage)
        '
        ELSE
          GRAPHIC PRINT strCellContents;
        END IF
        '
      END IF
      '
    NEXT lngColumn
    '
    IF lngRow = 1 AND lngHeader = %TRUE THEN
    ' reset the font to normal
      GRAPHIC SET FONT g_hFont
    END IF
    '
    GRAPHIC PRINT ""
    GRAPHIC GET POS TO g_lngX, g_lngY
    ' move half a character line downwards
    g_lngY = g_lngY + (lng_imgH\2)
    '
    IF ISTRUE lngTableBorder  AND lngRow <> lngRows THEN
    ' draw horizontal line - except for last row
      GRAPHIC LINE (uTable.lngStart.X,g_lngY - (lng_imgH\3) ) - _
                   (lngTableWidth,g_lngY - (lng_imgH\3)), _
                   %BLACK
    END IF
    '
  NEXT lngRow
  '
  '
   ' store ending position
  PREFIX "uTable."
    lngEnd.X = lngTableWidth
    lngEnd.Y = g_lngY - (lng_imgH\3)
  END PREFIX
  '
  IF ISTRUE lngTableBorder THEN
    GRAPHIC BOX (uTable.lngStart.X  ,uTable.lngStart.Y) - _
                (uTable.lngEnd.X,uTable.lngEnd.Y),0,%BLACK
    '
    FOR lngColumn = 1 TO lngColumns -1
    ' draw vertical lines
      PREFIX "uVerticalLines."
        lngStart.X = lngXOffset + uTable.lngStart.X + a_lngTableColumns(lngColumn) - lng_imgW
        lngStart.Y = uTable.lngStart.Y
        lngEnd.X   = uVerticalLines.lngStart.X
        lngEnd.Y   = uTable.lngEnd.Y
      END PREFIX
      ' store offset for next column
      lngXOffset = uVerticalLines.lngStart.X
      '
      GRAPHIC LINE (uVerticalLines.lngStart.X,uVerticalLines.lngStart.Y) - _
                   (uVerticalLines.lngEnd.X,uVerticalLines.lngEnd.Y),%BLACK
      '
    NEXT lngColumn
    '
  END IF
  '
END FUNCTION
'
FUNCTION funRGBColour(strColour AS STRING) AS LONG
' return the RGB colour
  LOCAL lngR, lngG, lngB AS LONG
  '
  lngR = VAL(PARSE$(strColour,",",1))
  lngG = VAL(PARSE$(strColour,",",2))
  lngB = VAL(PARSE$(strColour,",",3))
  '
  FUNCTION = RGB(lngR,lngG,lngB)
  '
END FUNCTION
'
FUNCTION funGetPreviousColumnsWidth(BYREF a_lngTableColumns() AS LONG, _
                                    lngColumn AS LONG) AS LONG
' return the widths of the previous column
  LOCAL lngPColumn AS LONG    ' previous columns
  LOCAL lngWidth AS LONG      ' Cumulative width
  '
  FOR lngPColumn = 1 TO lngColumn - 1
    lngWidth = lngWidth + a_lngTableColumns(lngPColumn)
  NEXT lngPColumn
  '
  FUNCTION = lngWidth
  '
END FUNCTION
'
FUNCTION funGetControlSize() AS LONG
' return the width of the graphics control
  FUNCTION = GRAPHIC(SIZE.X)
'
END FUNCTION
'
FUNCTION funWidthOfTable(BYREF a_strTable() AS STRING, _
                         lng_imgW AS LONG, _
                         lng_imgH AS LONG, _
                         BYREF a_lngTableColumns() AS LONG, _
                         strTableWidthAmount AS STRING, _
                         lngHeader AS LONG) AS LONG
' work out width of a table for each column
'
  LOCAL lngColumn AS LONG           ' column counter
  LOCAL lngColumns AS LONG          ' total number of columns
  LOCAL lngRow AS LONG              ' row counter
  LOCAL lngRows AS LONG             ' total number of rows
  LOCAL lngTotalWidth AS LONG       ' total width of the table
  LOCAL lngScaled AS LONG           ' table is scaled i.e. width preset
  '
  lngColumns = UBOUND(a_lngTableColumns)
  lngRows = UBOUND(a_strTable,1)
  '
  IF strTableWidthAmount <> "" THEN
  ' table is set for fixed width
    lngScaled = %TRUE
    IF RIGHT$(strTableWidthAmount,1) = "%" THEN
      lngTotalWidth = funGetControlSize() * _
                      (VAL(strTableWidthAmount)/100)
    ELSE
    ' width set in pixels
      lngTotalWidth = VAL(strTableWidthAmount)
    END IF
    '
  ELSE
    lngScaled = %FALSE
  END IF
  '
  FOR lngColumn = 1 TO lngColumns
  ' look through each column
    IF ISTRUE lngScaled THEN
    ' this table is scaled in width
      a_lngTableColumns(lngColumn) = lngTotalWidth \ lngColumns
      '
    ELSE
    ' this table is dynamic
    FOR lngRow = 1 TO lngRows
    ' and get max length of text in each row
    ' of that column
       IF lngRow = 1 AND ISTRUE lngHeader THEN
       ' its the first row and header is present
         a_strTable(lngRow,lngColumn) = _
         a_strTable(lngRow,lngColumn) & SPACE$(2)
       '
       ELSE
         a_lngTableColumns(lngColumn) = _
                           MAX(LEN(a_strTable(lngRow,lngColumn)), _
                           LEN(a_strTable(lngRow -1,lngColumn)))
       ' store width plus 2 padding characters
         a_lngTableColumns(lngColumn) = _
                          (a_lngTableColumns(lngColumn) * lng_imgW) + _
                          (2 * lng_imgW)
       END IF
    NEXT lngRow
    END IF
    '
  NEXT lngColumn
  '
  IF ISFALSE lngScaled THEN
  ' return the total width of the table
    FOR lngColumn = 1 TO UBOUND(a_lngTableColumns)
      lngTotalWidth = lngTotalWidth + a_lngTableColumns(lngColumn)
    NEXT lngColumn
    '
    ' add on a gap between first and last columns
    lngTotalWidth = lngTotalWidth + (2 * lng_imgW)
  '
  END IF
  '
  FUNCTION = lngTotalWidth
  '
END FUNCTION
'
FUNCTION funDisplayImage(hDlg AS DWORD, _
                         strAttributes AS STRING, _
                         lngTabSelected AS LONG, _
                         uImgTag AS udtImgTag, _
                         lngInParagraph AS LONG, _
                         lngIsWebPage AS LONG) AS LONG
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
  LOCAL lngImageLoaded AS LONG     ' true if image loaded successfully
  '
  lngStartPosition = INSTR(strAttributes,"src=") + LEN("src=")
  strTemp = MID$(strAttributes,lngStartPosition)
  strSource = PARSE$(strTemp,$DQ,2)
  '

  '
  ' is this web file or local file
  IF ISTRUE lngIsWebPage THEN
  ' coming from a web site - get file and save to cache
    strFullHTMLPath = g_astrURLS(lngTabSelected)
    lngEndElement = PARSECOUNT(strFullHTMLPath,"/")
    DECR lngEndElement
    strPath = funStartRangeParse(strFullHTMLPath,"/",lngEndElement)
    '
    funLoadIMG_from_web_to_Cache(strPath,strSource)
    '
    strPath = EXE.PATH$ & $CacheFolder & "\"
    '
  ELSE
  ' image path may be relative to html page
  strFullHTMLPath = g_astrURLS(lngTabSelected)
  lngEndElement = PARSECOUNT(strFullHTMLPath,"\")
  DECR lngEndElement
  strPath = funStartRangeParse(strFullHTMLPath,"\",lngEndElement)
  '
  END IF
  '
  ' test for image loaded
  lngImageLoaded = funLoadImageFile(strPath & strSource, _
                             lng_imgW, _
                             lng_imgH, _
                                    hBMP )
  IF ISTRUE lngImageLoaded THEN
    ' image loaded successfully
  ' reattach to graphics control
    GRAPHIC ATTACH hDlg, %IDC_Graphic
    ' copy bitmap
    GRAPHIC COPY hBmp,0 TO (g_lngX,g_lngY)
    '
    ' store the location
    PREFIX "uImgTag."
      lngTopX = g_lngX
      lngTopY = g_lngY
      lngBottomX = g_lngX + lng_imgW
      lngBottomY = g_lngY + lng_imgH
    END PREFIX
    '
    ' now update global position
    '
    IF ISTRUE lngInParagraph THEN
    ' we are inside a paragraph tag
      g_lngX = g_lngX + lng_imgW
    ELSE
    ' outside a paragraph tag
      g_lngX = 0
      g_lngY = g_lngY + lng_imgH
    END IF
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
FUNCTION funGetTableTagValue(BYVAL lngStartPosition AS LONG, _
                             strTagEnd AS STRING, _
                             strData AS STRING, _
                             strLcData AS STRING) AS STRING
' return the content of the Table tag
  LOCAL lngEnd AS LONG
  '
  lngStartPosition = INSTR(lngStartPosition,strData,">") +1
  lngEnd   = INSTR(lngStartPosition,strLcData,strTagEnd)
  FUNCTION = MID$(strData,lngStartPosition,lngEnd-lngStartPosition)
  '
END FUNCTION
'
FUNCTION funPrintData(strData AS STRING, _
                      lngRefTag AS LONG, _
                      uImgTag AS udtImgTag) AS LONG
' print the data string to the graphics control
  LOCAL lngPos AS LONG
  LOCAL strTempData AS STRING
  LOCAL lngBreaks AS LONG      ' number of line breaks
  LOCAL lngB AS LONG
  LOCAL strText AS STRING      ' string to print
  '
  LOCAL lng_imgW, lng_imgH AS LONG ' width and height of
  '                                  the hyperlink
  '
  LOCAL lngWidthVar AS LONG         ' standard width of char set
  LOCAL lngHeightVar AS LONG        ' standard height of char set
  LOCAL lngPageWidthVar AS LONG     ' page width
  LOCAL lngPageHeightVar AS LONG    ' page height
  LOCAL lngMaxCharsPerLine AS LONG  ' maximum characters per line
  LOCAL lngInsert AS LONG           ' number of <br> to insert
  LOCAL strNewData AS STRING        ' strData with <br> added
  LOCAL strPrintData AS STRING      ' data that can be printed
  LOCAL strOverflow AS STRING       ' overflow data for next line
  '
  strTempData = LCASE$(strData)
  '
  IF ISTRUE lngRefTag AND TRIM$(strData) <> "" THEN
  ' work out the height and width of the
  ' text for one character
    GRAPHIC CELL SIZE TO lng_imgW, lng_imgH
    ' calculate the width of all characters
    lng_imgW = LEN(strData) * lng_imgW
    ' add a little to height
    lng_imgH = lng_imgH +4
    '
  ' store the location
    PREFIX "uImgTag."
      lngTopX = g_lngX
      lngTopY = g_lngY
      lngBottomX = g_lngX + lng_imgW
      lngBottomY = g_lngY + lng_imgH
    END PREFIX
    ' set the font to be underlined
    GRAPHIC COLOR %BLUE,%WHITE
    GRAPHIC SET FONT g_hUFont
    '
  END IF
  '
  ' test for embedded link?
  IF INSTR(strTempData,"a href=") > 0 THEN
  ' embedded image or hyperlink
   '
    EXIT FUNCTION
    '
  ELSEIF INSTR(strTempData,"<u>") > 0 THEN
  ' embedded <u> tag
    '
    EXIT FUNCTION
  END IF
  '
  lngBreaks = PARSECOUNT(strTempData,"<br>")
  '
  IF lngBreaks = 1 THEN
  ' no line breaks

    ' is text wider than the graphics control?
     ' get the size taken up by one character
    GRAPHIC CELL SIZE TO lngWidthVar, lngHeightVar
    ' get the size of the visible client area
    GRAPHIC GET CLIENT TO lngPageWidthVar, lngPageHeightVar
    '
    lngMaxCharsPerLine = lngPageWidthVar \ lngWidthVar
    '
    IF LEN(strData) > lngMaxCharsPerLine THEN
    ' too many characters for 1 line
      lngBreaks = 1
      strNewData = ""
      '
      DO
      ' work out how much text will fit on the line
      ' putting the overflow in strOverflow variable
        GRAPHIC SPLIT WORD strData, lngPageWidthVar _
                      TO strPrintData, strOverflow
          ' build up new data and add on a <br>
        strNewData = strNewData & strPrintData & "<br>"
        INCR lngBreaks
        ' keep what remains
        strData = strOverflow
        '
      LOOP UNTIL strOverflow = ""
      '
       ' repopulate the strData variable ready to print
      strData = strNewData
      '
    END IF
    '
  END IF
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
    GRAPHIC PRINT strData;
    GRAPHIC GET POS TO g_lngX, g_lngY
  '
    IF ISTRUE lngRefTag THEN
    ' reset default font and colour
      GRAPHIC COLOR %BLACK,%WHITE
      GRAPHIC SET FONT g_hFont
    END IF
    '
  END IF
  '
END FUNCTION
'
FUNCTION funPrintBlankLine() AS LONG
' print a blank line on the graphics control
  GRAPHIC SET POS (g_lngX, g_lngY)
  GRAPHIC PRINT ""
  GRAPHIC GET POS TO g_lngX, g_lngY
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
FUNCTION funLoadHTMLPage(strURL AS STRING, _
                         lngIsWebPage AS LONG) AS STRING
' determine if file or web page and return the content
' of the file
  LOCAL strHTML AS STRING
  ' read in the html data trimming out leading
  ' and trailing spaces
  '
  IF LCASE$(LEFT$(strURL,4)) = "http" THEN
  ' load from web server
    strHTML = funGetWebPage(strURL)
    ' remove any CR/LF
    strHTML = REMOVE$(strHTML, ANY $CRLF)
    lngIsWebPage = %TRUE
  '
  ELSE
  ' load an html file
    strHTML = TRIM$(funBinaryFileAsString(strURL))
    ' remove any CR/LF
    strHTML = REMOVE$(strHTML, ANY $CRLF)
    '
    lngIsWebPage = %FALSE
  '
  END IF
  '
  FUNCTION = strHTML
  '
END FUNCTION
'
FUNCTION funLoadIMG_from_web_to_Cache(BYVAL strURLSite AS STRING, _
                                      strFileName AS STRING) AS LONG
' load a file from the web to the cache folder
  LOCAL strLocalFilePath AS STRING
  LOCAL strLocalFilePathZ AS ASCIIZ * %MAX_PATH
  LOCAL hFile AS LONG
  LOCAL strBuffer AS STRING
  LOCAL strURL AS STRING
  LOCAL strHTML AS STRING
  '
  ' get the site & file to load
  strURL = strURLSite & strFileName
  strURLSite = PARSE$(strURLSite,"/",3) 'get site
  '
  ' location to put file on local PC
  strLocalFilePath = EXE.PATH$ & $CacheFolder & "\" & strFileName
  ' one of the API requires an AsciiZ version of the LocalFilePath
  strLocalFilePathZ = strLocalFilePath
  '
  ' clear the cache of the file
  DeleteURLCacheEntry(strLocalFilePathZ)  '1 = success  clear the cache
  '
  ' before downloading, remove existing version, if it exists
  IF ISFILE(strLocalFilePath) THEN
    KILL strLocalFilePath
  END IF
  '
  ' Download the file
  hFile = FREEFILE
  ' connect to web site
  TCP OPEN "http" AT strURLSite AS #hFile TIMEOUT 60000
  IF ERR THEN
    BEEP
    MSGBOX ERROR$
    EXIT FUNCTION
  END IF
  ' send the GET request
  TCP PRINT #hFile, "GET " & strURL & " HTTP/1.0"
  TCP PRINT #hFile, ""
  DO
  ' receive data blocks until no more available
    TCP RECV #hFile, 4096, strBuffer
    strHTML = strHTML + strBuffer
    '
  LOOP WHILE ISTRUE LEN(strBuffer) AND ISFALSE ERR
  TCP CLOSE #hFile  ' now close down the connection
  '
  ' Save the file, but first take off the
  ' HTTP header from the received bytes
  strHTML  = REMAIN$(strHTML, $CRLF & $CRLF)
  hFile = FREEFILE
  OPEN strLocalFilePath FOR BINARY AS hFile
  PUT$ hFile,strHTML
  CLOSE hFile
  '
END FUNCTION
'
FUNCTION funGetWebPage(strURL AS STRING) AS STRING
' download a web page
  LOCAL strLocalFilePath AS STRING
  LOCAL strLocalFilePathZ AS ASCIIZ * %MAX_PATH
  LOCAL strFilename AS STRING
  LOCAL hFile AS LONG
  'LOCAL lngServerFileSize AS LONG
  LOCAL strBuffer AS STRING
  LOCAL strHTML AS STRING
  LOCAL strURLSite AS STRING
  '
  strURLSite = PARSE$(strURL,"/",3) 'get site
  strFileName = PARSE$(strURL,"/",-1)
  '
  ' location to put file on local PC
  strLocalFilePath = EXE.PATH$ & $CacheFolder & "\" & strFileName
  ' one of the API requires an AsciiZ version of the LocalFilePath
  strLocalFilePathZ = strLocalFilePath
  '
  ' clear the cache of the file
  DeleteURLCacheEntry(strLocalFilePathZ)  '1 = success  clear the cache
  '
  ' before downloading, remove existing version, if it exists
  IF ISFILE(strLocalFilePath) THEN
    KILL strLocalFilePath
  END IF
  '
  ' Download the file
  hFile = FREEFILE
  ' connect to web site
  TCP OPEN "http" AT strURLSite AS #hFile TIMEOUT 60000
  IF ERR THEN BEEP : EXIT FUNCTION
  ' send the GET request
  TCP PRINT #hFile, "GET " & strURL & " HTTP/1.0"
  TCP PRINT #hFile, ""
  DO
  ' receive data blocks until no more available
    TCP RECV #hFile, 4096, strBuffer
    strHTML = strHTML + strBuffer
    '
  LOOP WHILE ISTRUE LEN(strBuffer) AND ISFALSE ERR
  TCP CLOSE #hFile  ' now close down the connection
  '
  ' Save the file, but first take off the
  ' HTTP header from the received bytes
  strHTML  = REMAIN$(strHTML, $CRLF & $CRLF)
  hFile = FREEFILE
  OPEN strLocalFilePath FOR BINARY AS hFile
  PUT$ hFile,strHTML
  CLOSE hFile
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
  GRAPHIC SET VIRTUAL  (lngWide * %WidthMultiplier)-5, _
                        lngHigh * %HeightMultiplier
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

  DIALOG NEW PIXELS, hParent, "PB Lite Browser", 229, 201, 850, 550, %WS_POPUP OR _
    %WS_BORDER OR %WS_DLGFRAME OR %WS_CAPTION OR %WS_SYSMENU OR _
    %WS_MINIMIZEBOX OR %WS_MAXIMIZEBOX OR %WS_CLIPSIBLINGS OR %WS_VISIBLE OR _
    %WS_THICKFRAME OR %DS_MODALFRAME OR %DS_3DLOOK OR %DS_NOFAILCREATE OR _
    %DS_SETFONT, %WS_EX_CONTROLPARENT OR %WS_EX_LEFT OR %WS_EX_LTRREADING OR _
    %WS_EX_RIGHTSCROLLBAR, TO hDlg
  CONTROL ADD STATUSBAR, hDlg, %IDC_STATUSBAR1, "", 0, 0, 0, 0
  CONTROL ADD TEXTBOX,   hDlg, %IDC_txtURL, "", 135, 3, 475, 25
  CONTROL ADD IMGBUTTON, hDlg, %IDC_IMGback, "", 0, 0, 32, 32
  CONTROL ADD IMGBUTTON, hDlg, %IDC_IMGForward, "", 33, 0, 32, 32
  CONTROL ADD IMGBUTTON, hDlg, %IDC_IMGReload, "", 66, 0, 32, 32
  CONTROL ADD IMGBUTTONX, hDlg, %IDC_IMGHome, "", 99, 0, 32, 32
#PBFORMS END DIALOG
  lngWide = 835
  lngHigh = 450
  CONTROL ADD TAB,hDlg, %IDC_TAB1, "Tab1", 0, 35, 610 * %WidthMultiplier, 25
  CONTROL ADD GRAPHIC, hDlg, %IDC_Graphic, "", 5, 60, lngWide, lngHigh, _
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
  GRAPHIC SET VIRTUAL  lngWide * %WidthMultiplier, _
                       lngHigh * %HeightMultiplier

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
  CONTROL SET FONT hDlg,%IDC_txtURL, g_hFont
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
              'funRenderTheHTML(g_astrURLS(g_lngTabSelected), _
              '                 g_hDlg, %IDC_TAB1)
              ' render the graphic control from the stored cache
              GRAPHIC SET BITS g_astrGraphicCache(g_lngTabSelected)
              GRAPHIC REDRAW
              '
            END IF
            DIALOG END CB.HNDL
          END IF
          '
      END SELECT
  END SELECT
END FUNCTION
'------------------------------------------------------------------------------
FUNCTION funInsertNewArrayEntries(lngTabSelected AS LONG) AS LONG
' tab has been inserted so add new array entries
  LOCAL lngR AS LONG
  LOCAL lngT AS LONG
  '
  PREFIX "ARRAY insert "
    g_astrURLS(lngTabSelected)
    g_astrTargetNames(lngTabSelected)
    g_lngLatestSlot(lngTabSelected)
    g_alngTabHandles(lngTabSelected)
    g_astrGraphicCache(lngTabSelected)
  END PREFIX
  '
  ' handle history insert
  FOR lngT = %MAX_TABS TO lngTabSelected STEP -1
    FOR lngR = 1 TO %MAX_HISTORY
    ' copy tab up
      g_astrURLhistory(lngT,lngR) = _
                       g_astrURLhistory(lngT -1,lngR)
    NEXT lngR
  NEXT lngT
  '
  ' now purge current tab
  FOR lngR = 1 TO %MAX_HISTORY
   g_astrURLhistory(lngTabSelected,lngR) = ""
  NEXT lngR
  '
END FUNCTION
'
FUNCTION funRemoveTabHistory(lngTabSelected AS LONG) AS LONG
' tab has been deleted so remove it's history
  LOCAL lngR AS LONG
  LOCAL lngT AS LONG
  '
  ' first delete the current URL from the array
  ' and move all tabs URLs above it down by one
  PREFIX "ARRAY DELETE "
    g_astrURLS(lngTabSelected)
    g_astrTargetNames(lngTabSelected)
    g_alngTabHandles(lngTabSelected)
    g_astrGraphicCache(lngTabSelected)
  END PREFIX
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
