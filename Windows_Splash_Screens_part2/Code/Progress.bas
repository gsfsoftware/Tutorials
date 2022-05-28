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
#RESOURCE "Progress.pbr"
#INCLUDE ONCE "WIN32API.INC"
#INCLUDE ONCE "COMMCTRL.INC"
#INCLUDE ONCE "PBForms.INC"
#PBFORMS END INCLUDES
'------------------------------------------------------------------------------
GLOBAL g_strLogFile AS STRING   ' name/path to apps log file
'------------------------------------------------------------------------------
'   ** Constants **
'------------------------------------------------------------------------------
#PBFORMS BEGIN CONSTANTS
%IDD_dlgProgressBar =  101
%IDABORT            =    3
%IDOK               =    1
%IDC_PROGRESSBAR1   = 1002
%IDC_lblInfo        = 1003
#PBFORMS END CONSTANTS
'------------------------------------------------------------------------------
' custom event for the progress bar updates
%Progress_Event     = %WM_USER + 1000
%Progress_Completed = %Progress_Event + 1
'
%TotalThreads = 1
GLOBAL g_idThread() AS LONG     ' array for thread handles
'------------------------------------------------------------------------------
'   ** Declarations **
'------------------------------------------------------------------------------
DECLARE CALLBACK FUNCTION ShowdlgProgressBarProc()
DECLARE FUNCTION SampleProgress(BYVAL hDlg AS DWORD, BYVAL lID AS LONG) AS _
  LONG
DECLARE FUNCTION ShowdlgProgressBar(BYVAL hParent AS DWORD) AS LONG
#PBFORMS DECLARATIONS
'------------------------------------------------------------------------------

'------------------------------------------------------------------------------
'   ** Main Application Entry Point **
'------------------------------------------------------------------------------
FUNCTION PBMAIN()
  PBFormsInitComCtls (%ICC_WIN95_CLASSES OR %ICC_DATE_CLASSES OR _
    %ICC_INTERNET_CLASSES)
  ' name the log file
  g_strLogFile = EXE.PATH$ & EXE.NAME$ & "_log.txt"
  '
  ' set up global array for thread handles
  DIM g_idThread(1 TO %TotalThreads) AS LONG
  '
  TRY
  ' wipe any copy of log file
    KILL g_strLogFile
  CATCH
  FINALLY
  END TRY
  '
  ShowdlgProgressBar %HWND_DESKTOP
END FUNCTION
'------------------------------------------------------------------------------

'------------------------------------------------------------------------------
'   ** CallBacks **
'------------------------------------------------------------------------------
CALLBACK FUNCTION ShowdlgProgressBarProc()
  LOCAL lngStatus AS LONG
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
      '
    CASE %Progress_Event
      ' advance the progress bar
      PROGRESSBAR SET POS CB.HNDL, %IDC_PROGRESSBAR1, CB.WPARAM
      '
    CASE %Progress_Completed
    ' thread has completed
      THREAD CLOSE g_idThread(1) TO lngStatus
      CONTROL SET TEXT CB.HNDL,%IDC_lblInfo, "Finished processing"
      funLog("Finished processing - " & TIME$)
      CONTROL ENABLE CB.HNDL, %IDOK
      '
    CASE %WM_COMMAND
      ' Process control notifications
      SELECT CASE AS LONG CB.CTL
        CASE %IDABORT
          IF CB.CTLMSG = %BN_CLICKED OR CB.CTLMSG = 1 THEN
            DIALOG END CB.HNDL
          END IF

        CASE %IDOK
          IF CB.CTLMSG = %BN_CLICKED OR CB.CTLMSG = 1 THEN
          ' start processing
            CONTROL DISABLE CB.HNDL, CB.CTL
            CONTROL SET TEXT CB.HNDL,%IDC_lblInfo, "Now Processing"
            funLog("Now Processing - " & TIME$)
            '
            'funStartProcessing(cb.hndl)
            THREAD CREATE funStartThreadProcessing(BYVAL CB.HNDL) _
                    TO g_idThread(1)
            '
            'control set text cb.hndl,%IDC_lblInfo, "Finished processing"
            'funLog("Finished processing - " & time$)
            'control enable cb.hndl, %IDOK
          '
          END IF

        CASE %IDC_PROGRESSBAR1

      END SELECT
  END SELECT
END FUNCTION
'------------------------------------------------------------------------------

'------------------------------------------------------------------------------
'   ** Sample Code **
'------------------------------------------------------------------------------
FUNCTION SampleProgress(BYVAL hDlg AS DWORD, BYVAL lID AS LONG) AS LONG
' set the range and value of the progress bar
' first set range between 0 and 100
  PROGRESSBAR SET RANGE hDlg, lID, 0, 100
' now set the value to 1
  PROGRESSBAR SET POS   hDlg, lID, 1
END FUNCTION
'------------------------------------------------------------------------------

'------------------------------------------------------------------------------
'   ** Dialogs **
'------------------------------------------------------------------------------
FUNCTION ShowdlgProgressBar(BYVAL hParent AS DWORD) AS LONG
  LOCAL lRslt  AS LONG

#PBFORMS BEGIN DIALOG %IDD_dlgProgressBar->->
  LOCAL hDlg   AS DWORD
  LOCAL hFont1 AS DWORD

  DIALOG NEW hParent, "Progressbar Demo", 352, 185, 627, 196, %WS_POPUP OR _
    %WS_BORDER OR %WS_DLGFRAME OR %WS_CAPTION OR %WS_SYSMENU OR _
    %WS_MINIMIZEBOX OR %WS_CLIPSIBLINGS OR %WS_VISIBLE OR %DS_MODALFRAME OR _
    %DS_CENTER OR %DS_3DLOOK OR %DS_NOFAILCREATE OR %DS_SETFONT, _
    %WS_EX_CONTROLPARENT OR %WS_EX_LEFT OR %WS_EX_LTRREADING OR _
    %WS_EX_RIGHTSCROLLBAR, TO hDlg
  CONTROL ADD BUTTON,      hDlg, %IDABORT, "Exit", 40, 165, 50, 15
  CONTROL ADD BUTTON,      hDlg, %IDOK, "Start", 535, 165, 50, 15
  DIALOG  SEND             hDlg, %DM_SETDEFID, %IDOK, 0
  CONTROL ADD PROGRESSBAR, hDlg, %IDC_PROGRESSBAR1, "ProgressBar1", 115, 150, _
    385, 30
  CONTROL ADD LABEL,       hDlg, %IDC_lblInfo, "Not Started", 115, 35, 380, _
    55
  CONTROL SET COLOR        hDlg, %IDC_lblInfo, %BLUE, -1

  FONT NEW "MS Sans Serif", 18, 0, %ANSI_CHARSET TO hFont1

  CONTROL SET FONT hDlg, %IDC_lblInfo, hFont1
#PBFORMS END DIALOG

  SampleProgress hDlg, %IDC_PROGRESSBAR1

  DIALOG SHOW MODAL hDlg, CALL ShowdlgProgressBarProc TO lRslt

#PBFORMS BEGIN CLEANUP %IDD_dlgProgressBar
  FONT END hFont1
#PBFORMS END CLEANUP

  FUNCTION = lRslt
END FUNCTION
'------------------------------------------------------------------------------
THREAD FUNCTION funStartThreadProcessing(BYVAL hDlg AS DWORD) AS DWORD
' start the thread function
  LOCAL lngR AS LONG
  LOCAL lngC AS LONG
  LOCAL lngPercent AS LONG
  LOCAL lngValue AS LONG
  LOCAL lngMax AS LONG
  LOCAL lngStep AS LONG
  '
  lngMax = 200000
  lngStep = lngMax \ 100
  '
  FOR lngR = 1 TO lngMax
    FOR lngC = 1 TO 5000
      lngValue = RND(0,4000)
    NEXT lngC
    '
    IF lngR MOD lngStep = 0 THEN
    ' made 1% progress - so update the progress bar
      lngPercent = lngR \ lngStep
      DIALOG POST hDlg, %Progress_Event,lngPercent,0
      funLog(FORMAT$(lngPercent) & "%")
    END IF
    '
  NEXT lngR
  '
  DIALOG POST hDlg, %Progress_Completed,0,0
  '
END FUNCTION

FUNCTION funStartProcessing(hDlg AS DWORD) AS LONG
' now start doing some processing
'
  LOCAL lngR AS LONG
  LOCAL lngC AS LONG
  LOCAL lngPercent AS LONG
  LOCAL lngValue AS LONG
  LOCAL lngMax AS LONG
  LOCAL lngStep AS LONG
  '
  lngMax = 200000
  lngStep = lngMax \ 100

  '
  FOR lngR = 1 TO lngMax
    FOR lngC = 1 TO 5000
      lngValue = RND(0,4000)
    NEXT lngC
    '
    IF lngR MOD lngStep = 0 THEN
    ' made 1% progress
      lngPercent = lngR \ lngStep
      PROGRESSBAR SET POS   hDlg, %IDC_PROGRESSBAR1, lngPercent
      funLog(FORMAT$(lngPercent) & "%")
    END IF
    '
  NEXT lngR
'
END FUNCTION
'
FUNCTION funLog(strData AS STRING) AS LONG
' log information to a log file
  STATIC lngFile AS LONG  ' handle for log file
  '
  IF lngFile = 0 THEN
  ' file is not opened yet
    lngFile = FREEFILE
    OPEN g_strLogFile FOR OUTPUT AS #lngFile
  ELSE
  ' file has already been opened
    OPEN g_strLogFile FOR APPEND AS #lngFile
  END IF
  '
  PRINT #lngFile, strData
  CLOSE #lngFile
  '
END FUNCTION
