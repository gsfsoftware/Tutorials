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
#RESOURCE "TextPrediction.pbr"
%USEMACROS = 1
#INCLUDE ONCE "WIN32API.INC"
#INCLUDE ONCE "COMMCTRL.INC"
#INCLUDE ONCE "PBForms.INC"
#PBFORMS END INCLUDES
'------------------------------------------------------------------------------
#INCLUDE "PB_ToolbarLIB.inc"
#INCLUDE "PB_FileHandlingRoutines.inc"
'------------------------------------------------------------------------------
'   ** Constants **
'------------------------------------------------------------------------------
#PBFORMS BEGIN CONSTANTS
%IDD_dlgTextPrediction =  101
%IDC_STATUSBAR1        = 1001
%IDC_txtTextInput      = 1002
%IDC_lstWordList       = 1003
%IDC_lblTextInput      = 1004
%IDC_lblWordList       = 1005
%MainToolbar           = 1006
%IDC_lblProgress       = 1008
%IDC_ProgressBar       = 1007
#PBFORMS END CONSTANTS
'------------------------------------------------------------------------------

'------------------------------------------------------------------------------
'   ** Declarations **
'------------------------------------------------------------------------------
DECLARE CALLBACK FUNCTION ShowdlgTextPredictionProc()
DECLARE FUNCTION SampleListBox(BYVAL hDlg AS DWORD, BYVAL lID AS LONG, BYVAL _
  lCount AS LONG) AS LONG
DECLARE FUNCTION ShowdlgTextPrediction(BYVAL hParent AS DWORD) AS LONG
#PBFORMS DECLARATIONS
'------------------------------------------------------------------------------
GLOBAL g_astrWordData() AS STRING
GLOBAL g_alngWordCount() AS LONG
%StartSize = 20000       ' start size of arrays
%ArrayBlock = 5000       ' number of elements to expand arrays by
'
' string constants to specify the names of output files
$WordDataArray    = "WordData.txt"
$WordCountArray   = "WordCount.txt"
$WordDataArrayCSV = "WordData.csv"
'
%WordResult = 10   ' maximum number of suggested words
'
'------------------------------------------------------------------------------
'   ** Main Application Entry Point **
'------------------------------------------------------------------------------
FUNCTION PBMAIN()
  PBFormsInitComCtls (%ICC_WIN95_CLASSES OR %ICC_DATE_CLASSES OR _
    %ICC_INTERNET_CLASSES)
  ' prpare the arrays
  REDIM g_astrWordData(1 TO %StartSize) AS STRING
  REDIM g_alngWordCount(1 TO %StartSize) AS LONG
  '
  ShowdlgTextPrediction %HWND_DESKTOP
END FUNCTION
'------------------------------------------------------------------------------

'------------------------------------------------------------------------------
'   ** CallBacks **
'------------------------------------------------------------------------------
CALLBACK FUNCTION ShowdlgTextPredictionProc()
  LOCAL strFile AS STRING    ' selected input file
  LOCAL lngFlags AS LONG     ' file selection flags
  LOCAL strError AS STRING   ' holds error when saving
  LOCAL lngFileCount AS LONG ' count of files selected
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
        CASE %IDC_STATUSBAR1

        CASE %IDC_txtTextInput
          IF CB.CTLMSG = %EN_CHANGE THEN
          ' data in text box has changed
            funProcessTextChange(CB.HNDL, _
                                 %IDC_txtTextInput, _
                                 %IDC_lstWordList)
          '
          END IF
          '
        CASE %IDC_lstWordList
        '
        CASE %ID_ADD
          IF CB.CTLMSG = %BN_CLICKED OR CB.CTLMSG = 1 THEN
          ' add button pressed
             lngFlags = %OFN_FILEMUSTEXIST OR %OFN_ALLOWMULTISELECT
            ' allow use to select one of more files
            DISPLAY OPENFILE CB.HNDL, ,, "Select File/s", EXE.PATH$, _
                             "Text" & CHR$(0) & "TextData_*.TXT" & _
                             CHR$(0),"","", _
                             lngFlags TO strFile,lngFileCount
                             '
            IF strFile <> "" THEN
            ' process the files selected
              funProcessFiles(strFile, CB.HNDL, %IDC_STATUSBAR1, _
                              lngFileCount, %IDC_ProgressBar)
            END IF
            '
          END IF
          '
        CASE %ID_Save
          IF CB.CTLMSG = %BN_CLICKED OR CB.CTLMSG = 1 THEN
          ' save the arrays to file
            IF ISFALSE funSaveArrays(strError) THEN
            ' report error
              MSGBOX strError, _
                     %MB_TASKMODAL OR %MB_ICONERROR, _
                     "Failure to save data " & strError
            ELSE
            ' saved successfully
              CONTROL SET TEXT CB.HNDL,%IDC_STATUSBAR1,"Files saved."
            '
            END IF
          '
          END IF
          '
        CASE %ID_Load
          IF CB.CTLMSG = %BN_CLICKED OR CB.CTLMSG = 1 THEN
          ' load the training data arrays
            IF ISTRUE funLoadArrays(strError) THEN
              CONTROL SET TEXT CB.HNDL,%IDC_STATUSBAR1,"Data Loaded."
            ELSE
              MSGBOX strError, _
                     %MB_TASKMODAL OR %MB_ICONERROR, _
                     "Failure to save data " & strError
            END IF
          '
          END IF
          '
      END SELECT
  END SELECT
END FUNCTION
'
FUNCTION funProcessTextChange(hDlg AS DWORD, _
                              lngTextInput AS LONG, _
                              lngWordList AS LONG) AS LONG
' process a text change
  LOCAL strText AS STRING
  LOCAL strFirstWord AS STRING
  LOCAL strSecondWord AS STRING
  LOCAL strPhrase AS STRING
  '
  ' get the text so far
  CONTROL GET TEXT hDlg,lngTextInput TO strText
  REPLACE $CRLF WITH " " IN strText
  '
  IF RIGHT$(strText,1) <> " " THEN
  ' ignore until word completed
    EXIT FUNCTION
  ELSE
  ' look for last two words
    strFirstWord = PARSE$(strText," ",-3)
    strSecondWord = PARSE$(strText," ",-2)
    '
    IF strFirstWord <> "" AND strSecondWord <> "" THEN
    ' we have two words - suggest possible next word
    ' build phrase to be searched for
      strPhrase = strFirstWord & " " & strSecondWord & " "
      funSuggestWord(hDlg,lngWordList, strPhrase)
    '
    END IF
    '
  END IF
  '
END FUNCTION
'
FUNCTION funSuggestWord(hDlg AS DWORD, _
                        lngWordList AS LONG, _
                        strPhrase AS STRING) AS LONG
' suggest a word based on the phrase given
' sweep through the array looking for matches
'
  LOCAL lngRow AS LONG         ' row in results arrays
  LOCAL lngMatch AS LONG       ' index of matched phrase
  LOCAL lngPrevmatch AS LONG   ' index of previous matched phrase
  LOCAL lngCount AS LONG       ' number of matches found
  LOCAL strWord AS STRING      ' word found
  LOCAL lngWordCount AS LONG   ' count of word
  '
  LOCAL lngStart , lngEnd AS LONG ' start and end positions to scan
  lngStart = 1                    ' set the values
  lngEnd = LEN(strPhrase)
  '
  DIM a_strWord(1 TO %WordResult) AS STRING    ' arrays used to hold
  DIM a_lngWordCount(1 TO %WordResult) AS LONG ' the results of the search
  '
  ARRAY SCAN g_astrWordData(), _
             FROM lngStart TO lngEnd, _
             COLLATE UCASE, = UCASE$(strPhrase), _
             TO lngMatch
  '
  IF lngMatch = 0 THEN
  ' no matches found at all
    EXIT FUNCTION
  ELSE
  ' first match found
    LISTBOX RESET hDlg,lngWordList
    '
    ' add the first result to array
    INCR lngCount
    ' get the word
    strWord = PARSE$(g_astrWordData(lngMatch)," ",-1)
    ' get the word count
    lngWordCount = g_alngWordCount(lngMatch)
    '
    ' add to arrays
    funAddToWordData(strWord,lngWordCount, _
                     a_strWord(),a_lngWordCount())
                     '
    ' find more matches
    lngPrevmatch = lngMatch +1
    WHILE lngPrevmatch <= UBOUND(g_astrWordData)
    ' ensure we look though all the data
    ' search for another match
      ARRAY SCAN g_astrWordData(lngPrevmatch), _
             FROM lngStart TO lngEnd, _
             COLLATE UCASE, = UCASE$(strPhrase), _
             TO lngMatch
             '
      IF lngMatch = 0 THEN
      ' no more matches
        EXIT LOOP
      ELSE
      ' record it
        ' add the result to array
        lngMatch = lngMatch + lngPrevmatch -1 ' set the array index
        '
         ' get the word
        strWord = PARSE$(g_astrWordData(lngMatch)," ",-1)
        ' get the word count
        lngWordCount = g_alngWordCount(lngMatch)
        ' add to arrays
        funAddToWordData(strWord,lngWordCount, _
                         a_strWord(),a_lngWordCount())
        '
        lngPrevmatch = lngMatch +1
        '
      END IF
      '
    WEND
    '
    ' now add results to list box
    FOR lngRow = 1 TO %WordResult
      IF a_strWord(lngRow) <> "" THEN
      ' only where word in not blank
        LISTBOX ADD hDlg,lngWordList,a_strWord(lngRow)
      END IF
    NEXT lngRow
    '
  END IF
  '
END FUNCTION
'
FUNCTION funAddToWordData(strWord AS STRING, _
                          lngWordCount AS LONG, _
                          BYREF a_strWord() AS STRING, _
                          BYREF a_lngWordCount() AS LONG) AS LONG
' add to the word found arrays
' is there space for thee new word?
  LOCAL lngSlot AS LONG
  '
  ' has array already been filled?
  IF a_lngWordCount(%WordResult) >= lngWordCount THEN
  ' array is full and this word count is not greater
    EXIT FUNCTION
  END IF
  '
  ' look for slot
  FOR lngSlot = 1 TO %WordResult
  ' check word counts
    ' if current slot has greater value skip over
    IF a_lngWordCount(lngSlot) > lngWordCount THEN ITERATE
    '
    IF a_lngWordCount(lngSlot) = 0 THEN
    ' empty slot - so update the result arrays
      a_lngWordCount(lngSlot) = lngWordCount
      a_strWord(lngSlot)      = strWord
      EXIT FUNCTION
      '
    ELSEIF a_lngWordCount(lngSlot) <= lngWordCount THEN
    ' slot word count is equal to or less than this word count
    ' so insert it here in the result arrays
      ARRAY INSERT a_lngWordCount(lngSlot),lngWordCount
      ARRAY INSERT a_strWord(lngSlot), strWord
      EXIT FUNCTION
    '
    END IF
  '
  NEXT lngSlot
  '
END FUNCTION
'
FUNCTION funProcessFiles(strFiles AS STRING, _
                         hDlg AS DWORD, _
                         lngStatus AS LONG, _
                         lngFileCount AS LONG, _
                         lngProgressBar AS LONG) AS LONG
' handle multiple files
  LOCAL strFile AS STRING
  LOCAL lngFile AS LONG
  LOCAL strFolder AS STRING
  '
  IF lngFileCount = 1 THEN
  ' single file
    strFile = PARSE$(strFiles,CHR$(0),1)
    ' process the file data into the arrays
    PROGRESSBAR SET RANGE hDlg, lngProgressBar, 0, 1
    funProcessFile(strFile,hDlg,lngStatus)
    PROGRESSBAR SET POS hDlg, lngProgressBar,1
    '
  ELSE
  ' multiple files
     ' get folder
    strFolder = PARSE$(strFiles,CHR$(0),1)
    '
    PROGRESSBAR SET RANGE hDlg, lngProgressBar, 0, lngFileCount
    '
    FOR lngFile = 1 TO lngFileCount
      CONTROL SET TEXT hDlg,lngStatus,"Loading file " & _
                       FORMAT$(lngFile) & "..." & _
                       "Records Space = " & FORMAT$(UBOUND(g_astrWordData))
                       '
      strFile = strFolder & "\" & PARSE$(strFiles,CHR$(0),lngFile +1)
      ' process the file data into the arrays
      funProcessFile(strFile,hDlg,lngStatus)
      '
      PROGRESSBAR SET POS hDlg, lngProgressBar, lngFile
      DIALOG REDRAW hDlg
      '
    NEXT lngFile
    '
  END IF
  '
  CONTROL SET TEXT hDlg,lngStatus,"File/s loaded."
  '
END FUNCTION
'
FUNCTION funProcessFile(strFile AS STRING, _
                        hDlg AS DWORD, _
                        lngStatus AS LONG) AS LONG
' process the selected file
  LOCAL strData AS STRING
  LOCAL lngElements AS LONG
  LOCAL lngWord AS LONG
  LOCAL strWord AS STRING
  LOCAL strSecondWord AS STRING
  LOCAL strThirdWord AS STRING
  '
  'CONTROL SET TEXT hDlg,lngStatus,"Loading file..."
  '
  ' load the file into a string
  strData = funBinaryFileAsString(strFile)
  '
  lngElements = PARSECOUNT(strData," ")
  '
  FOR lngWord = 1 TO lngElements
  ' for each word in the data
    strWord = PARSE$(strData," ",lngWord)
    '
    SELECT CASE RIGHT$(strWord,1)
      CASE ".", ","
      ' ignore these words
      CASE ELSE
      ' handle everything else
      ' get the next two words
        strSecondWord = PARSE$(strData," ",lngWord +1)
        '
        ' if second word is last in a sentence
        IF RIGHT$(strSecondWord,1) = "." THEN ITERATE
        '
        strThirdWord = TRIM$(PARSE$(strData," ",lngWord +2), ANY ".,")
        '
        IF strSecondWord <> "" AND strThirdWord <> "" THEN
        ' we have three words so add to the arrays
          funAddToData(strWord,strSecondWord,strThirdWord)
        '
        END IF
        '
    END SELECT
    '
  NEXT lngWord
  '
END FUNCTION
'
FUNCTION funLoadArrays(strError AS STRING) AS LONG
' load the arrays from file
  LOCAL lngFile AS LONG
  LOCAL lngRecords AS LONG
  LOCAL strFileName AS STRING
  LOCAL lngRow AS LONG
  '
  ' first load the word data array
  strFileName = EXE.PATH$ & "Data\" & $WordDataArray
  '
  lngFile = FREEFILE
  TRY
    OPEN strFileName FOR INPUT AS #lngFile
    FILESCAN #lngFile, RECORDS TO lngRecords
    REDIM g_astrWordData(1 TO lngRecords) AS STRING
    LINE INPUT #lngFile,g_astrWordData()
    FUNCTION = %TRUE
  CATCH
  ' failure to load?
    strError = "Unable to load word data array " & ERROR$
    FUNCTION = %FALSE
  FINALLY
    CLOSE #lngFile
  END TRY
  '
   ' now load word count array
  strFileName = EXE.PATH$ & "Data\" & $WordCountArray
  TRY
    OPEN strFileName FOR INPUT AS #lngFile
    FILESCAN #lngFile, RECORDS TO lngRecords
    REDIM g_alngWordCount(1 TO lngRecords) AS LONG
    FOR lngRow = 1 TO lngRecords
      INPUT #lngFile,g_alngWordCount(lngRow)
    NEXT lngRow
    FUNCTION = %TRUE
  CATCH
    strError = "Unable to load word data array " & ERROR$
    FUNCTION = %FALSE
  FINALLY
    CLOSE #lngFile
  END TRY
  '
END FUNCTION
'
FUNCTION funSaveArrays(strError AS STRING) AS LONG
' save the arrays to file
  LOCAL strFile AS STRING
  '
  strFile = EXE.PATH$ & "Data\" & $WordDataArray
  '
  IF ISTRUE funArrayDump(strFile, _
                         g_astrWordData()) THEN
  ' word data saved ok
    strFile = EXE.PATH$ & "Data\" & $WordCountArray
    '
    IF ISFALSE funArrayDumpLong_1D(strFile, _
                                   g_alngWordCount(), _
                                   strError) THEN
      strError = "Word Count array failure " & ERROR$
    ELSE
    ' dump combined CSV file
      strFile = EXE.PATH$ & "Data\" & $WordDataArrayCSV
      FUNCTION = funDumpCSVFile(strFile, strError)
    END IF
    '
  ELSE
    strError = "Word Data array failure " & ERROR$
  END IF
  '
END FUNCTION
'
FUNCTION funDumpCSVFile(strFile AS STRING, _
                        strError AS STRING) AS LONG
' dump both files together as a CSV
  LOCAL lngR AS LONG
  LOCAL lngFileOut AS LONG
  '
  lngFileOut = FREEFILE
  '
  TRY
    OPEN strFile FOR OUTPUT AS #lngFileOut
    ' output the file headers
    PRINT #lngFileOut, $DQ & "Phrase" & $QCQ & "Count" & $DQ
    FOR lngR = 1 TO UBOUND(g_astrWordData)
    ' output each record - unless it is blank
      IF g_astrWordData(lngR) = "" THEN ITERATE
      '
      PRINT #lngFileOut, $DQ & g_astrWordData(lngR) & $DQ & "," & _
                       FORMAT$(g_alngWordCount(lngR))
    NEXT lngR
    '
    FUNCTION = %TRUE
    '
  CATCH
  ' store error message
    strError = ERROR$
  FINALLY
    CLOSE #lngFileOut
  END TRY
  '
END FUNCTION
'
'------------------------------------------------------------------------------
FUNCTION funAddToData(strWord AS STRING, _
                      strSecondWord AS STRING, _
                      strThirdWord AS STRING) AS LONG
' add or increment this combination in the data
  LOCAL lngI AS LONG
  LOCAL strPhrase AS STRING
  ' form phrase
  strPhrase = strWord & " " & _
              strSecondWord & " " & _
              strThirdWord
              '
  ' handle double quotes and $crlf
  REPLACE $DQ WITH "'" IN strPhrase
  REPLACE $CRLF WITH "" IN strPhrase
  '
  ' scan for phrase
  ARRAY SCAN g_astrWordData(), COLLATE UCASE, = strPhrase, TO lngI
  '
  IF lngI = 0 THEN
  ' not in the array
  ' so add it
    funAddToDataSlot(strPhrase)
  '
  ELSE
  ' already in the array so increment the count
    INCR g_alngWordCount(lngI)
  '
  END IF
  '
END FUNCTION
'
FUNCTION funAddToDataSlot(strPhrase AS STRING) AS LONG
' find an empty slot for this phrase
  LOCAL lngI AS LONG   ' index variable
  LOCAL lngMax AS LONG ' max entries in array
  '
  ' exit if there is no phrase
  IF strPhrase = "" THEN EXIT FUNCTION
  '
  lngMax = UBOUND(g_astrWordData)
  '
  FOR lngI = 1 TO lngMax
    IF g_astrWordData(lngI) = "" THEN
    ' empty slot found
    ' add the phrase
      g_astrWordData(lngI) = strPhrase
      ' and set count to 1
      g_alngWordCount(lngI) = 1
      EXIT FUNCTION
      '
    END IF
  NEXT lngI
  '
   ' no empty slots - expand the array
  REDIM PRESERVE g_astrWordData(1 TO lngMax + %ARRAYBLOCK)
  REDIM PRESERVE g_alngWordCount(1 TO lngMax + %ARRAYBLOCK)
  '
  INCR lngMax ' advance to next slot
  ' update the arrays with data
  g_astrWordData(lngMax) = strPhrase
  g_alngWordCount(lngMax) = 1
  '
END FUNCTION
'------------------------------------------------------------------------------
'   ** Dialogs **
'------------------------------------------------------------------------------
FUNCTION ShowdlgTextPrediction(BYVAL hParent AS DWORD) AS LONG
  LOCAL lRslt  AS LONG

#PBFORMS BEGIN DIALOG %IDD_dlgTextPrediction->->
  LOCAL hDlg   AS DWORD
  LOCAL hFont1 AS DWORD
  LOCAL hFont2 AS DWORD

  DIALOG NEW hParent, "Text Prediction", 340, 195, 723, 356, %WS_POPUP OR _
    %WS_BORDER OR %WS_DLGFRAME OR %WS_CAPTION OR %WS_SYSMENU OR _
    %WS_MINIMIZEBOX OR %WS_CLIPSIBLINGS OR %WS_VISIBLE OR %DS_MODALFRAME OR _
    %DS_CENTER OR %DS_3DLOOK OR %DS_NOFAILCREATE OR %DS_SETFONT, _
    %WS_EX_CONTROLPARENT OR %WS_EX_LEFT OR %WS_EX_LTRREADING OR _
    %WS_EX_RIGHTSCROLLBAR, TO hDlg
  CONTROL ADD STATUSBAR, hDlg, %IDC_STATUSBAR1, "Ready", 0, 0, 0, 0
  CONTROL ADD TEXTBOX,   hDlg, %IDC_txtTextInput, "", 15, 59, 485, 205, _
    %WS_CHILD OR %WS_VISIBLE OR %WS_TABSTOP OR %WS_HSCROLL OR %WS_VSCROLL OR _
    %ES_LEFT OR %ES_MULTILINE OR %ES_AUTOHSCROLL OR %ES_WANTRETURN, _
    %WS_EX_CLIENTEDGE OR %WS_EX_LEFT OR %WS_EX_LTRREADING OR _
    %WS_EX_RIGHTSCROLLBAR
  CONTROL ADD LISTBOX,   hDlg, %IDC_lstWordList, , 505, 59, 165, 218, _
    %WS_CHILD OR %WS_VISIBLE OR %WS_TABSTOP OR %WS_VSCROLL OR _
    %LBS_NOTIFY , %WS_EX_CLIENTEDGE OR %WS_EX_LEFT OR _
    %WS_EX_LTRREADING OR %WS_EX_RIGHTSCROLLBAR
  CONTROL ADD LABEL,     hDlg, %IDC_lblTextInput, "Type Text", 15, 41, 375, _
    15
  CONTROL SET COLOR      hDlg, %IDC_lblTextInput, %BLUE, -1
  CONTROL ADD LABEL,     hDlg, %IDC_lblWordList, "Possible Words", 505, 41, _
    95, 15
  CONTROL SET COLOR      hDlg, %IDC_lblWordList, %BLUE, -1
  CONTROL ADD PROGRESSBAR, hDlg, %IDC_ProgressBar, "", 15, 305, 485, 15, _
    %WS_CHILD OR %WS_VISIBLE OR %PBS_SMOOTH
  CONTROL ADD LABEL,       hDlg, %IDC_lblProgress, "Progress", 15, 290, 100, _
    15
  CONTROL SET COLOR        hDlg, %IDC_lblProgress, %BLUE, -1

  FONT NEW "MS Sans Serif", 18, 0, %ANSI_CHARSET TO hFont1
  FONT NEW "MS Sans Serif", 12, 1, %ANSI_CHARSET TO hFont2

  CONTROL SET FONT hDlg, %IDC_txtTextInput, hFont1
  CONTROL SET FONT hDlg, %IDC_lstWordList, hFont1
  CONTROL SET FONT hDlg, %IDC_lblTextInput, hFont2
  CONTROL SET FONT hDlg, %IDC_lblWordList, hFont2
  CONTROL SET FONT hDlg, %IDC_lblProgress, hFont2
#PBFORMS END DIALOG
  CONTROL ADD TOOLBAR,   hDlg, %MainToolbar, "", 10, 0, 0, 0
  CreateToolbar hDlg, %MainToolbar

  DIALOG SET ICON hDlg, "APP_ICO"

  DIALOG SHOW MODAL hDlg, CALL ShowdlgTextPredictionProc TO lRslt

#PBFORMS BEGIN CLEANUP %IDD_dlgTextPrediction
  FONT END hFont1
  FONT END hFont2
#PBFORMS END CLEANUP

  FUNCTION = lRslt
END FUNCTION
'
