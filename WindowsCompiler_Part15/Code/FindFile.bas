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
#RESOURCE "FindFile.pbr"
%USEMACROS = 1
#INCLUDE ONCE "WIN32API.INC"
#INCLUDE ONCE "COMMCTRL.INC"
#INCLUDE ONCE "PBForms.INC"
#PBFORMS END INCLUDES
'------------------------------------------------------------------------------
#INCLUDE "RichEdit.inc"
#INCLUDE "..\Libraries\PB_Windows_Controls.inc"
'------------------------------------------------------------------------------
'   ** Constants **
'------------------------------------------------------------------------------
#PBFORMS BEGIN CONSTANTS
%IDD_dlgFindFiles  =  101
%IDC_STATUSBAR     = 1001
%IDC_cboFileType   = 1003
%IDC_lblFileType   = 1002
%IDC_chkSubFolders = 1004
%IDC_lblContaining = 1005
%IDC_txtContaining = 1006
%IDC_lblStartFrom  = 1007
%IDC_txtStartFrom  = 1008
%IDC_btnBrowse     = 1009
%IDC_Search        = 1010
%IDC_LISTVIEW      = 1011
%IDC_lblOutput     = 1012
#PBFORMS END CONSTANTS
'------------------------------------------------------------------------------
GLOBAL g_strStartPath AS STRING    ' global for the start path
GLOBAL g_strFileType AS STRING     ' global type of file to search for
GLOBAL g_hDlg AS DWORD             ' global for the handle to the main dialog
GLOBAL g_lngAbort AS LONG          ' global abort search flag
GLOBAL g_lngFileCount AS LONG      ' global Counter for files found
GLOBAL g_lngSearchedCount AS LONG  ' global Counter for files searched
GLOBAL g_strFiles() AS STRING      ' global string array to hold file details
GLOBAL g_lngSubFolders AS LONG     ' global boolean for recursive search
GLOBAL g_strSearchString AS STRING ' global text to search for
GLOBAL g_qTSize AS QUAD            ' for calculating found files total size
'
ENUM lv
  LEFT = 0
  RIGHT
  Center
END ENUM
'

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

  ShowdlgFindFiles %HWND_DESKTOP
END FUNCTION
'------------------------------------------------------------------------------

'------------------------------------------------------------------------------
'   ** CallBacks **
'------------------------------------------------------------------------------
CALLBACK FUNCTION ShowdlgFindFilesProc()
  LOCAL lngFlags AS LONG
  LOCAL strFolder AS STRING
  '
  SELECT CASE AS LONG CB.MSG
    CASE %WM_INITDIALOG
    ' Initialization handler
      g_strStartPath = "C:\"
      CONTROL SET TEXT CB.HNDL, %IDC_txtStartFrom,g_strStartPath
      ' populate the File type
      funPopulateTheFileType(CB.HNDL,%IDC_cboFileType)
      '
      CONTROL SET CHECK CB.HNDL, %IDC_chkSubFolders,1
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
        CASE %IDC_STATUSBAR

        CASE %IDC_cboFileType

        CASE %IDC_chkSubFolders

        CASE %IDC_txtContaining

        CASE %IDC_txtStartFrom

        CASE %IDC_btnBrowse
          IF CB.CTLMSG = %BN_CLICKED OR CB.CTLMSG = 1 THEN
            DISPLAY BROWSE CB.HNDL,,,"Select the folder to start at", _
              g_strStartPath, lngFlags TO strFolder
            IF strFolder <> "" THEN
              CONTROL SET TEXT CB.HNDL,%IDC_txtStartFrom, strFolder
            END IF
          END IF

        CASE %IDC_Search
          IF CB.CTLMSG = %BN_CLICKED OR CB.CTLMSG = 1 THEN
            subStartSearch()
          END IF

        CASE %IDC_LISTVIEW

      END SELECT
  END SELECT
END FUNCTION
'------------------------------------------------------------------------------
'   ** Dialogs **
'------------------------------------------------------------------------------
FUNCTION ShowdlgFindFiles(BYVAL hParent AS DWORD) AS LONG
  LOCAL lRslt AS LONG
  LOCAL lngLVWidth AS LONG
  LOCAL lngLVHeight AS LONG

#PBFORMS BEGIN DIALOG %IDD_dlgFindFiles->->
  LOCAL hDlg  AS DWORD

  DIALOG NEW hParent, "Find Files", 148, 124, 668, 325, %WS_POPUP OR _
    %WS_BORDER OR %WS_DLGFRAME OR %WS_CAPTION OR %WS_SYSMENU OR _
    %WS_MINIMIZEBOX OR %WS_CLIPSIBLINGS OR %WS_VISIBLE OR %DS_MODALFRAME OR _
    %DS_CENTER OR %DS_3DLOOK OR %DS_NOFAILCREATE OR %DS_SETFONT, _
    %WS_EX_CONTROLPARENT OR %WS_EX_LEFT OR %WS_EX_LTRREADING OR _
    %WS_EX_RIGHTSCROLLBAR, TO hDlg
  CONTROL ADD STATUSBAR, hDlg, %IDC_STATUSBAR, "Ready", 0, 0, 0, 0
  CONTROL ADD LABEL,     hDlg, %IDC_lblFileType, "File Type", 5, 5, 100, 10
  CONTROL SET COLOR      hDlg, %IDC_lblFileType, %BLUE, -1
  CONTROL ADD COMBOBOX,  hDlg, %IDC_cboFileType, , 5, 15, 100, 40, %WS_CHILD _
    OR %WS_VISIBLE OR %WS_TABSTOP OR %CBS_DROPDOWN, %WS_EX_LEFT OR _
    %WS_EX_LTRREADING OR %WS_EX_RIGHTSCROLLBAR
  CONTROL ADD CHECKBOX,  hDlg, %IDC_chkSubFolders, "Include sub-folders", _
    115, 15, 100, 10
  CONTROL ADD LABEL,     hDlg, %IDC_lblContaining, "Files containing", 220, _
    5, 100, 10
  CONTROL SET COLOR      hDlg, %IDC_lblContaining, %BLUE, -1
  CONTROL ADD TEXTBOX,   hDlg, %IDC_txtContaining, "", 220, 15, 155, 13
  CONTROL ADD LABEL,     hDlg, %IDC_lblStartFrom, "Start from", 385, 5, 100, _
    10
  CONTROL SET COLOR      hDlg, %IDC_lblStartFrom, %BLUE, -1
  CONTROL ADD TEXTBOX,   hDlg, %IDC_txtStartFrom, "", 385, 15, 130, 13
  CONTROL ADD BUTTON,    hDlg, %IDC_btnBrowse, "Browse", 525, 14, 50, 16
  CONTROL ADD BUTTON,    hDlg, %IDC_Search, "Search", 600, 15, 50, 15
  CONTROL ADD LABEL,     hDlg, %IDC_lblOutput, "", 0, 295, 665, 15
#PBFORMS END DIALOG
  ' prepare the listview with its columns
  CONTROL ADD LISTVIEW,  hDlg, %IDC_LISTVIEW, "", 5, 45, 645, 240
  CONTROL GET SIZE hDlg,%IDC_LISTVIEW TO lngLVWidth , lngLVHeight
  '
  LISTVIEW SET STYLEXX hDlg, %IDC_LISTVIEW, _
                         %LVS_EX_GRIDLINES OR %LVS_EX_FULLROWSELECT
  PREFIX "LISTVIEW INSERT COLUMN hDlg, %IDC_LISTVIEW, "
    1, "Name",lngLVWidth * 0.25,%lv.Center
    2, "Folder",lngLVWidth * 0.40,%lv.Left
    3, "Size",lngLVWidth * 0.15,%lv.Center
    4, "Modified",lngLVWidth * 0.18,%lv.Center
  END PREFIX
  '
  g_hDlg = hDlg ' store the dialog handle
  '
  DIALOG SHOW MODAL hDlg, CALL ShowdlgFindFilesProc TO lRslt

#PBFORMS BEGIN CLEANUP %IDD_dlgFindFiles
#PBFORMS END CLEANUP

  FUNCTION = lRslt
END FUNCTION
'------------------------------------------------------------------------------
'
FUNCTION funPopulateTheFileType(hDlg AS DWORD, lngCombo AS LONG) AS LONG
' populate the file type combo
  DIM a_strData(1 TO 10) AS STRING '
  ARRAY ASSIGN a_strData() = "*.*", "*.BAS","*.BAT", _
                             "*.INC","*.PBR","*.RC", _
                             "*.RES","*.TXT","*.DOC", _
                             "*.SQL"
                             '
 FUNCTION = funPopulateCombo(hDlg,lngCombo, _
                             BYREF a_strData() , _
                             "")
'
END FUNCTION
'
SUB subStartSearch()
' start the search
  LOCAL strText AS STRING
  LOCAL dTimer AS DOUBLE
  '
  DIALOG DOEVENTS
  '
  CONTROL GET TEXT g_hDlg , %IDC_Search TO strText
  '
  IF strText = "Cancel" THEN
  ' user has pressed the cancel button
    IF MSGBOX("Abort the search?", _
              %MB_YESNO OR %MB_ICONQUESTION, _
              "PB Find file") = %IDYES THEN
              g_lngAbort = %TRUE
              DIALOG DOEVENTS
    END IF
  ELSE
  ' start the search
    dTimer = TIMER
    g_lngAbort = %FALSE
    g_lngFileCount = 0
    g_lngSearchedCount = 0
    REDIM g_strFiles(0) AS GLOBAL STRING ' Clear array
    '
    LISTVIEW RESET g_hDlg, %IDC_LISTVIEW ' clear the data
    '
    ' update the status bar
    CONTROL SET TEXT  g_hDlg, %IDC_STATUSBAR, "0 files found"
    ' Get type of file to search for
    CONTROL GET TEXT  g_hDlg, %IDC_cboFileType TO g_strFileType
    ' Get path to start from
    CONTROL GET TEXT  g_hDlg, %IDC_txtStartFrom TO g_strStartPath
    ' include sub-folders in search?
    CONTROL GET CHECK g_hDlg, %IDC_chkSubFolders TO g_lngSubFolders
    ' what content in the file are we looking for?
    CONTROL GET TEXT  g_hDlg, %IDC_txtContaining TO g_strSearchString
    '
    CONTROL SET TEXT g_hDlg, %IDC_Search,"Cancel"
    '
    ' clear the output
    CONTROL SET TEXT g_hDlg, %IDC_lblOutput, "Ready to Start"
    ' Disable other controls
    PREFIX "CONTROL DISABLE g_hDlg, "
      %IDC_cboFileType
      %IDC_txtStartFrom
      %IDC_chkSubFolders
      %IDC_txtContaining
    END PREFIX
    DIALOG DOEVENTS
    '
    ' Reset total file size counter
    g_qTSize = 0
    '
    ' ensure ends in backslash
    g_strStartPath = RTRIM$(g_strStartPath ,"\") & "\"
    '
    ' call the recursive search procedure
    CALL subReadFolders(g_strStartPath)
    CONTROL SET TEXT g_hDlg, %IDC_STATUSBAR, _
       "Files found = " & FORMAT$(g_lngFileCount)
       '
    ' Enable other controls
    PREFIX "CONTROL Enable g_hDlg, "
      %IDC_cboFileType
      %IDC_txtStartFrom
      %IDC_chkSubFolders
      %IDC_txtContaining
    END PREFIX
    '
    ' feedback results to user
    ' with Time taken
    dTimer = TIMER - dTimer
    strText = FORMAT$(g_lngFileCount) & " " & _
              g_strFileType & " in " & _
              FORMAT$(dTimer, "0.000") & " sec." & _
              " with a total size of " & _
              FORMAT$(g_qTSize, "#,###") & " bytes." & $CRLF & _
              "Total files searched = " & FORMAT$(g_lngSearchedCount)
    CONTROL SET TEXT g_hDlg, %IDC_lblOutput, "Found: " & strText
    CONTROL SET TEXT g_hDlg, %IDC_Search,"Search"

  '
  END IF
'
END SUB
'
SUB subReadFolders(BYVAL strPath AS STRING)
' recursive search folders routine
  LOCAL hSearch AS DWORD               ' Search handle
  LOCAL tmpSize AS QUAD                ' QUAD, in case of huge files...
  LOCAL WFD     AS WIN32_FIND_DATA     ' FindFirstFile structure
  LOCAL curpath AS ASCIIZ * %MAX_PATH  ' What to search for
  LOCAL strFilePath AS STRING
  '
  ' for performance update screen only if strPath is short
  IF TALLY(strPath,"\") < 4 THEN
    CONTROL SET TEXT g_hDlg, %IDC_lblOutput,"Searching: " & _
            strPath & "..."
  END IF
  '
  ' Wildcard of what we want to find
  curpath = strPath & g_strFileType
  ' get search handle
  hSearch = FindFirstFile(curpath, WFD)
  '
  IF hSearch <> %INVALID_HANDLE_VALUE THEN
    DO
      IF (WFD.dwFileAttributes AND %FILE_ATTRIBUTE_DIRECTORY) _
                <> %FILE_ATTRIBUTE_DIRECTORY THEN
      ' handle files only
      '------------------------------------------------------------------
      ' Store the info in tab-delimited array, for list view control.
      ' This is where we can use these data for filtering (IF/THEN)
      ' and/or add code for searching the found file for a string, etc.
        tmpSize = WFD.nFileSizeHigh * (%MAXDWORD + 1) + WFD.nFileSizeLow
        g_qTSize = g_qTSize + tmpSize
        ' add to files found
        INCR g_lngSearchedCount
        '
        ' check if search criteria is needed
        IF g_strSearchString <> "" THEN
        ' filter by search criteria
          strFilePath = strPath & WFD.cFileName
          IF ISTRUE funFoundCriteria(strFilePath, g_strSearchString) THEN
          ' found what we are looking for
            LISTVIEW INSERT ITEM g_hDlg,%IDC_LISTVIEW, _
                   g_lngFileCount+1, 0, WFD.cFileName
            PREFIX "LISTVIEW SET TEXT g_hDlg,%IDC_LISTVIEW, g_lngFileCount+1,"
              2, strPath
              3, FORMAT$(tmpSize, "* #######,")
              4, GetFileDateTime(WFD.ftLastWriteTime)
            END PREFIX
            '
            INCR g_lngFileCount
          END IF
        ELSE
        ' add details
          LISTVIEW INSERT ITEM g_hDlg,%IDC_LISTVIEW, _
                 g_lngFileCount, 0, WFD.cFileName
          PREFIX "LISTVIEW SET TEXT g_hDlg,%IDC_LISTVIEW, g_lngFileCount,"
            2, strPath
            3, FORMAT$(tmpSize, "* #######,")
            4, GetFileDateTime(WFD.ftLastWriteTime)
          END PREFIX
          '
          INCR g_lngFileCount
        END IF
        '
        ' now feedback to the user
        IF g_lngFileCount < 20 THEN
        ' while less than 20 update every time
          CONTROL SET TEXT g_hDlg, %IDC_statusbar, _
             "Files found = " & FORMAT$(g_lngFileCount)
        ELSE
        ' reduce updates to every 10 files
          IF g_lngFileCount MOD 10 = 0 THEN
            CONTROL SET TEXT g_hDlg, %IDC_STATUSBAR, _
             "Files found = " & FORMAT$(g_lngFileCount)
          END IF
        END IF
      END IF
    LOOP WHILE FindNextFile(hSearch, WFD)
    CALL FindClose(hSearch)
  END IF
  '
  IF ISTRUE g_lngSubfolders THEN
  ' search in sub folders?
    curpath = strPath & "*"
    hSearch = FindFirstFile(curpath, WFD)
    IF hSearch <> %INVALID_HANDLE_VALUE THEN
      DO
        IF (WFD.dwFileAttributes AND _
          %FILE_ATTRIBUTE_DIRECTORY) = %FILE_ATTRIBUTE_DIRECTORY _
          AND (WFD.dwFileAttributes AND %FILE_ATTRIBUTE_HIDDEN) = 0 THEN
          ' If folder, but not hidden..
          IF WFD.cFileName <> "." AND WFD.cFileName <> ".." THEN
          ' ignore these
            DIALOG DOEVENTS
            IF g_lngAbort THEN EXIT DO
            ' recursively call this routine
            ' and let the Stack keep track of call
              CALL subReadFolders(strPath & _
                  RTRIM$(WFD.cFileName, CHR$(0)) & "\")
          END IF
        END IF
      LOOP WHILE FindNextFile(hSearch, WFD)
      ' close off search
      CALL FindClose(hSearch)
    END IF
  END IF
  '
END SUB
'
FUNCTION funFoundCriteria(strFilePath AS STRING, _
                          strSearchString AS STRING) AS LONG
' does this file contain what we are looking for?
  LOCAL strFile AS STRING
  '
  strFile = funBinaryFileAsString(strFilePath)
  '
  IF INSTR(LCASE$(strFile), LCASE$(strSearchString)) > 0 THEN
    FUNCTION = %TRUE
  ELSE
   FUNCTION = %FALSE
 END IF
 '
END FUNCTION
'
FUNCTION funBinaryFileAsString(strFile AS STRING) AS STRING
' return a file as a string
  LOCAL lngFile AS LONG
  LOCAL strFileString AS STRING
  LOCAL lngSize AS LONG
  '
  TRY
    lngFile = FREEFILE
    OPEN strFile FOR BINARY LOCK SHARED AS #lngFile
    lngSize = LOF(lngFile)
    GET$ lngFile, lngSize, strFileString
    FUNCTION = strFileString
  CATCH
    FUNCTION = ""
  FINALLY
    CLOSE #lngFile
  END TRY
'
END FUNCTION
'
FUNCTION GetFileDateTime(DT AS FILETIME) AS STRING
' get the date and time stamp on a file
  LOCAL lpsystime AS SYSTEMTIME
  LOCAL szDate    AS ASCIIZ * 64 ' date buffer, %LDT_SIZE = 64 bytes
  LOCAL szTime    AS ASCIIZ * 64 ' time buffer, %LDT_SIZE = 64 bytes

  'convert given date to correct format
  CALL FileTimeToLocalFileTime(dt, dt)
  CALL FileTimeToSystemTime(dt, lpsystime)

  CALL GetDateFormat (%LOCALE_USER_DEFAULT, %DATE_SHORTDATE, _
      BYVAL VARPTR(lpsystime), BYVAL %NULL, szDate, SIZEOF(szDate))

  CALL GetTimeFormat (%LOCALE_USER_DEFAULT, %TIME_FORCE24HOURFORMAT OR _
      %TIME_NOSECONDS, BYVAL VARPTR(lpsystime), BYVAL %NULL, szTime, SIZEOF(szTime))

  FUNCTION = szDate & "  " & szTime

END FUNCTION
