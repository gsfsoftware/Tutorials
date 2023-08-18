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
#RESOURCE "Windows_Listbox_pointers.pbr"
#INCLUDE ONCE "WIN32API.INC"
#INCLUDE ONCE "COMMCTRL.INC"
#INCLUDE ONCE "PBForms.INC"
#PBFORMS END INCLUDES
'
#INCLUDE "DateFunctions.inc"
'------------------------------------------------------------------------------
#RESOURCE BITMAP, greycross, "greyCross.bmp"
#RESOURCE BITMAP, greytick, "greyTick.bmp"
#RESOURCE BITMAP, 4000, "smallTick.bmp"
#RESOURCE BITMAP, 4001, "smallCross.bmp"
'
%smalltick  = 4000
%smallcross = 4001
'------------------------------------------------------------------------------
'   ** Constants **
'------------------------------------------------------------------------------
#PBFORMS BEGIN CONSTANTS
%IDD_dlgResults         = 101
%IDC_btnFinish          = 3501
%IDC_frmOutcome         = 3502
%IDC_txtOutcome         = 3503
%IDC_lblResTitle        = 3504
%IDC_statusbar          = 3505
%IDC_Listbox            = 3506
%IDC_IMGPartialSuccess  = 3507
%IDC_lbl_PartialSuccess = 3508
%IDC_imgOutcome         = 3509
%ID_TIMER1              = 3510
#PBFORMS END CONSTANTS
'
%BMPMARGIN  =  3                ' Left margin for bitmap
%TEXTMARGIN = 40                ' Left margin for text

'------------------------------------------------------------------------------
GLOBAL g_imgList AS DWORD     ' handle of the image list
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
  '
  RANDOMIZE TIMER
  '
  ShowdlgResults %HWND_DESKTOP
  '
END FUNCTION
'------------------------------------------------------------------------------

'------------------------------------------------------------------------------
'   ** CallBacks **
'------------------------------------------------------------------------------
CALLBACK FUNCTION ShowdlgResultsProc()
  '
  LOCAL i     AS LONG
  LOCAL itd   AS LONG
  LOCAL rc    AS RECT
  LOCAL lpdis AS DRAWITEMSTRUCT PTR
  LOCAL szTxt AS ASCIIZ * 300
  '
  SELECT CASE AS LONG CB.MSG
    CASE %WM_INITDIALOG
      ' Initialization handler
      ' Create WM_TIMER events with the SetTimer API
      SetTimer(CB.HNDL, %ID_TIMER1, _
               2000, BYVAL %NULL)
      '
      PREFIX "control hide cb.hndl,"
        %IDC_lbl_PartialSuccess
        %IDC_IMGPartialSuccess
        %IDC_imgOutcome
      END PREFIX

    CASE %WM_TIMER
      ' now handle the task of silent running
      SELECT CASE CB.WPARAM
        CASE %ID_TIMER1
        ' delete the timer
          KillTimer CB.HNDL, %ID_TIMER1
          ' display the result to the user
          funDisplayResult(CB.HNDL,%IDC_Listbox)
          '
      END SELECT
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
    CASE %WM_DRAWITEM                   ' draw items in ownerdrawn control
      IF CB.WPARAM = %IDC_Listbox THEN  ' CB.WPARAM holds control's ID
      ' CB.LPARAM points to a DRAWITEMSTRUCT structure
        lpdis = CB.LPARAM
        IF @lpdis.itemID = &HFFFFFFFF THEN
          EXIT FUNCTION 'if list is empty
        ELSE
          rc = @lpdis.rcItem
          '
          SELECT CASE @lpdis.itemAction
            CASE %ODA_DRAWENTIRE, %ODA_SELECT
              IF (@lpdis.itemState AND %ODS_SELECTED) = 0 THEN
              ' Not selected
              ' Clear background
                FillRect @lpdis.hDC, rc, GetSysColorBrush(%COLOR_WINDOW)
              ' Text background
                SetBkColor @lpdis.hDC, GetSysColor(%COLOR_WINDOW)
                '
                ' highlight alternate rows
                IF @lpdis.itemID MOD 2 <> 0 THEN
                ' Adjust right side of rect
                  rc.nRight = %TEXTMARGIN - 2
                  ' Bitmap background
                  FillRect @lpdis.hDC, rc, GetSysColorBrush(%COLOR_3DFACE)
                  ' Adjust left side of rect
                  rc.nLeft = %TEXTMARGIN - 2
                  rc.nRight = @lpdis.rcItem.nRight
                  FillRect @lpdis.hDC, rc, GetSysColorBrush(%COLOR_3DFACE)
                END IF
              '
              ELSE
              ' selected by user
              ' Adjust right side of rect
                rc.nRight = %TEXTMARGIN - 2
                ' Bitmap background
                FillRect @lpdis.hDC, rc, GetSysColorBrush(%COLOR_3DFACE)
                ' Adjust left side of rect
                rc.nLeft = %TEXTMARGIN - 2
                ' And right side of rect
                rc.nRight = @lpdis.rcItem.nRight
                ' "Selected" background
                FillRect @lpdis.hDC, rc, GetSysColorBrush(%COLOR_HIGHLIGHT)
                ' Text background
                SetBkColor @lpdis.hDC, GetSysColor(%COLOR_HIGHLIGHT)
                ' Text color
                SetTextColor @lpdis.hDC, GetSysColor(%COLOR_HIGHLIGHTTEXT)
              END IF
              '
              ' Get/Draw current item's text
              CONTROL SEND CB.HNDL, %IDC_Listbox, %LB_GETTEXT, _
                                    @lpdis.itemID, VARPTR(szTxt)
                                    '
              ' Adjust text position slightly
              INCR rc.nTop
              rc.nLeft = %TEXTMARGIN
              ' draw the text
              DrawText @lpdis.hDC, szTxt, LEN(szTxt), rc, _
                       %DT_SINGLELINE OR %DT_LEFT OR %DT_VCENTER
              '
              ' Get current item's bitmap
              CONTROL SEND CB.HNDL, %IDC_Listbox, %LB_GETITEMDATA, _
                                    @lpdis.itemID, 0, TO itd
                                    '
              ' Draw current item's bitmap
              IF itd THEN
                DrawState @lpdis.hDC, 0&, 0&, itd, 0&, %BMPMARGIN, _
                          rc.nTop + 2, 0, 0, %DST_BITMAP
              END IF
              '
              FUNCTION = %TRUE
              EXIT FUNCTION
              '
          END SELECT
          '
        END IF
        '
      END IF
    '
    CASE %WM_COMMAND
      ' Process control notifications
      SELECT CASE AS LONG CB.CTL
        CASE %IDC_btnFinish
          IF CB.CTLMSG = %BN_CLICKED OR CB.CTLMSG = 1 THEN
            DIALOG END CB.HNDL
          END IF
      END SELECT
  END SELECT
END FUNCTION
'------------------------------------------------------------------------------

'------------------------------------------------------------------------------
'   ** Dialogs **
'------------------------------------------------------------------------------
FUNCTION ShowdlgResults(BYVAL hParent AS DWORD) AS LONG
  LOCAL lRslt AS LONG
  LOCAL hFont1 AS DWORD
  LOCAL hFont2 AS DWORD

#PBFORMS BEGIN DIALOG %IDD_dlgResults->->
  LOCAL hDlg  AS DWORD

  DIALOG NEW hParent, "Results Page", 53, 55, 564, 340, %WS_POPUP OR %WS_BORDER OR _
    %WS_DLGFRAME OR %WS_CAPTION OR %WS_SYSMENU OR %WS_MINIMIZEBOX OR _
    %WS_CLIPSIBLINGS OR %WS_VISIBLE OR %DS_MODALFRAME OR %DS_CENTER OR _
    %DS_3DLOOK OR %DS_NOFAILCREATE OR %DS_SETFONT, %WS_EX_CONTROLPARENT OR _
    %WS_EX_LEFT OR %WS_EX_LTRREADING OR %WS_EX_TOPMOST OR %WS_EX_RIGHTSCROLLBAR, TO hDlg
  CONTROL ADD BUTTON,    hDlg, %IDC_btnFinish, "Finish", 500, 305, 50, 15
  CONTROL ADD TEXTBOX,   hDlg, %IDC_txtOutcome, "Processing...", 50, 20, 295, 20, _
    %WS_CHILD OR %WS_VISIBLE OR %WS_TABSTOP OR %ES_LEFT OR %ES_AUTOHSCROLL _
    OR %ES_READONLY, %WS_EX_LEFT OR %WS_EX_LTRREADING OR _
    %WS_EX_RIGHTSCROLLBAR
  CONTROL SET COLOR hDlg, %IDC_txtOutcome, RGB(0, 128, 0), -1
  '
  CONTROL ADD LISTBOX,   hDlg, %IDC_Listbox, , 10, 95, 540, 205, %WS_CHILD OR _
    %WS_VISIBLE OR %LBS_OWNERDRAWFIXED OR %LBS_HASSTRINGS OR %LBS_NOTIFY OR _
    %WS_TABSTOP OR %WS_VSCROLL, %WS_EX_CLIENTEDGE
  '
  CONTROL ADD FRAME,hDlg, %IDC_frmOutcome, "Overall Outcome of Process", _
    10, 5, 540, 65
  CONTROL ADD LABEL,hDlg, %IDC_lblResTitle, "Results of the tasks", _
    10, 80, 335, 12
  CONTROL SET COLOR hDlg, %IDC_lblResTitle, %BLUE, -1
  CONTROL ADD STATUSBAR,hDlg,%IDC_statusbar,"",0,0,0,0
  '
  CONTROL ADD IMAGE,     hDlg, %IDC_imgOutcome, _
    "greytick", 25, 20, 22, 19
    '
  CONTROL ADD IMAGE, hDlg, %IDC_IMGPartialSuccess, _
    "#" & FORMAT$(%smallcross), 55, 45, 15, 14
    '
  CONTROL ADD LABEL,     hDlg, %IDC_lbl_PartialSuccess, "One or more of the " + _
    "non critical tasks has not worked.", 75, 45, 265, 20
#PBFORMS END DIALOG
  FONT NEW "MS Sans Serif", 12,1,0,0,0 TO hFont1
  FONT NEW "MS Sans Serif", 14,1,0,0,0 TO hFont2
  '
  ' set the row size to accomodate the bitmaps
  CONTROL SEND hDlg, %IDC_Listbox, %LB_SETITEMHEIGHT, 0, 22
  '
  PREFIX "CONTROL set font hDlg, "
    %IDC_txtOutcome, hFont2
    %IDC_lblResTitle,hFont1
    %IDC_Listbox,hFont1
  END PREFIX
  '
  DIALOG SHOW MODAL hDlg, CALL ShowdlgResultsProc TO lRslt

#PBFORMS BEGIN CLEANUP %IDD_dlgResults
#PBFORMS END CLEANUP
  ' clean up fonts
  FONT END hFont1
  FONT END hFont2

  FUNCTION = lRslt
END FUNCTION
'------------------------------------------------------------------------------
FUNCTION funDisplayResult(hDlg AS DWORD, lngListBox AS LONG) AS LONG
' display the results to the user
  LOCAL lngR AS LONG
  LOCAL strUpgradeOutcome AS STRING
  LOCAL strText AS STRING
  LOCAL lngMaxTasks AS LONG
  LOCAL strTaskResult AS STRING
  LOCAL strBitmap AS STRING
  LOCAL lngBitmapID AS LONG
  LOCAL lngFlagPartialsuccess AS LONG
  LOCAL strTextResult AS STRING
  '
  lngMaxTasks = 10
  '
  strUpgradeOutcome = "SUCCESS - All tasks completed" ' assume success
  '
  LISTBOX RESET hDlg, lngListBox

  '
  FOR lngR = 1 TO lngMaxTasks
    strText = "Task " & FORMAT$(lngR)
    '
    SELECT CASE funResult(lngR)
      CASE "0"
      ' task failure
        lngBitmapID = %smallcross
        strUpgradeOutcome = "FAILURE"
        strTaskResult = "FAILURE"
        '
      CASE "1"
      ' task success
        lngBitmapID = %smalltick
        strTaskResult = "SUCCESS"
      CASE "2"
        lngBitmapID = %smallcross
        strTaskResult = "Failure but acceptable"
        lngFlagPartialsuccess = %TRUE
        '
    END SELECT
    '
      ' load text and bitmaps in the resource
    subAddBitMapToList hDlg, lngListBox, strText & " - " & _
                       strTaskResult, "",lngBitmapID
    '
  NEXT lngR
  '
  CONTROL SET TEXT hDlg, %IDC_txtOutcome, strUpgradeOutcome

  SELECT CASE strUpgradeOutcome
    CASE "FAILURE"
    ' set colour of text on screen
      CONTROL SET COLOR      hDlg, %IDC_txtOutcome, RGB(128, 0, 0), -1
    CASE ELSE
      CONTROL SET COLOR      hDlg, %IDC_txtOutcome, RGB(0, 128, 0), -1
  END SELECT
  '
  IF strUpgradeOutcome = "SUCCESS - All tasks completed" THEN
  ' Handle success reporting
    CONTROL SET IMAGE hDlg, %IDC_imgOutcome, "greytick"
    strTextResult = "All tasks successfully completed on " & funUKDate() & " at " & TIME$
  ELSE
    CONTROL SET IMAGE hDlg, %IDC_imgOutcome, "greycross"
    strTextResult = "All tasks unsuccessfully completed on " & funUKDate() & " at " & TIME$
  END IF
  '
  IF ISTRUE lngFlagPartialsuccess THEN
  ' turn on the partial success button and label
    PREFIX "CONTROL normalize hDlg,"
       %IDC_lbl_PartialSuccess
       %IDC_IMGPartialSuccess
    END PREFIX
    '
  ELSE
    ' hide the partial success button and label
    PREFIX "CONTROL hide hDlg, "
      %IDC_lbl_PartialSuccess
      %IDC_IMGPartialSuccess
    END PREFIX
    '
  END IF
  '
  CONTROL NORMALIZE hDlg,%IDC_imgOutcome
  '
END FUNCTION
'
FUNCTION funResult(lngR AS LONG) AS STRING
' return a random result
' 0 = failure
' 1 = success
' 2 = non critical failure
'
' generate one of the above numbers randomly
  FUNCTION = FORMAT$(RND(1,2))
'
END FUNCTION
'
SUB subAddBitMapToList(BYVAL hDlg AS DWORD, _
                       BYVAL lngID AS LONG, _
                       BYVAL strText AS STRING, _
                       BYVAL bmpFile AS STRING, _
                       BYVAL bmpID AS LONG)
' load the bitmap to the listbox
  LOCAL lRes AS LONG
  LOCAL hBmp AS DWORD
  '
  IF bmpFile <>"" THEN
    hBmp = LoadImage(0, BYVAL STRPTR(bmpFile), _
                     %IMAGE_BITMAP, 0, 0, _
                     %LR_LOADFROMFILE)
  ELSE
    hBmp = LoadImage(GetModuleHandle(BYVAL %NULL), _
                     BYVAL bmpID, %IMAGE_BITMAP, _
                     0, 0, %LR_DEFAULTCOLOR)
  END IF
  '
  ' set item text
  CONTROL SEND hDlg, lngID, %LB_ADDSTRING, 0, _
               STRPTR(strText), TO lRes
  '
  ' store bitmap handle
  CONTROL SEND hDlg, lngID, %LB_SETITEMDATA, lRes, hBmp
  '
END SUB
