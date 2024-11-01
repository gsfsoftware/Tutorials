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
%StartSize = 10000       ' start size of arrays
%ArrayBlock = 1000       ' number of elements to expand arrays by
'
' string constants to specify the names of output files
$WordDataArray    = "WordData.txt"
$WordCountArray   = "WordCount.txt"
$WordDataArrayCSV = "WordData.csv"
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
                              lngFileCount)
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
                     "Failure to save data"
            ELSE
            ' saved successfully
              CONTROL SET TEXT CB.HNDL,%IDC_STATUSBAR1,"Files saved."
            '
            END IF
          '
          END IF
          '
      END SELECT
  END SELECT
END FUNCTION
'
FUNCTION funProcessFiles(strFiles AS STRING, _
                         hDlg AS DWORD, _
                         lngStatus AS LONG, _
                         lngFileCount AS LONG) AS LONG
' handle multiple files
  LOCAL strFile AS STRING
  LOCAL lngFile AS LONG
  LOCAL strFolder AS STRING
  '
  IF lngFileCount = 1 THEN
  ' single file
    strFile = PARSE$(strFiles,CHR$(0),1)
    ' process the file data into the arrays
    funProcessFile(strFile,hDlg,lngStatus)
    '
  ELSE
  ' multiple files
     ' get folder
    strFolder = PARSE$(strFiles,CHR$(0),1)
    FOR lngFile = 1 TO lngFileCount
      CONTROL SET TEXT hDlg,lngStatus,"Loading file " & _
                       FORMAT$(lngFile) & "..."
      strFile = strFolder & "\" & PARSE$(strFiles,CHR$(0),lngFile +1)
      ' process the file data into the arrays
      funProcessFile(strFile,hDlg,lngStatus)
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
  CONTROL SET TEXT hDlg,lngStatus,"Loading file..."
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
    %WS_CHILD OR %WS_VISIBLE OR %WS_TABSTOP OR %WS_VSCROLL OR %LBS_SORT OR _
    %LBS_NOTIFY OR %LBS_MULTICOLUMN, %WS_EX_CLIENTEDGE OR %WS_EX_LEFT OR _
    %WS_EX_LTRREADING OR %WS_EX_RIGHTSCROLLBAR
  CONTROL ADD LABEL,     hDlg, %IDC_lblTextInput, "Type Text", 15, 41, 375, _
    15
  CONTROL SET COLOR      hDlg, %IDC_lblTextInput, %BLUE, -1
  CONTROL ADD LABEL,     hDlg, %IDC_lblWordList, "Possible Words", 505, 41, _
    95, 15
  CONTROL SET COLOR      hDlg, %IDC_lblWordList, %BLUE, -1

  FONT NEW "MS Sans Serif", 18, 0, %ANSI_CHARSET TO hFont1
  FONT NEW "MS Sans Serif", 12, 1, %ANSI_CHARSET TO hFont2

  CONTROL SET FONT hDlg, %IDC_txtTextInput, hFont1
  CONTROL SET FONT hDlg, %IDC_lstWordList, hFont1
  CONTROL SET FONT hDlg, %IDC_lblTextInput, hFont2
  CONTROL SET FONT hDlg, %IDC_lblWordList, hFont2
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
