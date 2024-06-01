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
#RESOURCE "CoutdownImages.pbr"
%USEMACROS = 1
#INCLUDE ONCE "WIN32API.INC"
#INCLUDE ONCE "COMMCTRL.INC"
#INCLUDE ONCE "PBForms.INC"
#PBFORMS END INCLUDES
'------------------------------------------------------------------------------
'
#INCLUDE "PB_GDIplus_startup.inc"
#INCLUDE "PB_LoadJPG_as_Bitmap.inc"
#INCLUDE "PB_SaveJPG_from_GraphicsControl.inc"
'------------------------------------------------------------------------------
'   ** Constants **
'------------------------------------------------------------------------------
#PBFORMS BEGIN CONSTANTS
%IDD_DIALOG1            =  101
%IDC_lblBackGroundImage = 1001
%IDC_cboBackGroundImage = 1002
%IDABORT                =    3
%IDC_btnCreateImage     = 1003
%IDC_graSelectedImage   = 1004
%IDC_STATUSBAR1         = 1005
%IDC_lblCountDown       = 1007
%IDC_SYSDATE_countdown  = 1006
%IDC_btnApplyToImage    = 1009
%IDC_lblTextColour      = 1012
%IDC_cboTextColour      = 1011
#PBFORMS END CONSTANTS
'------------------------------------------------------------------------------
$Output = "test.jpg"
'------------------------------------------------------------------------------
'   ** Declarations **
'------------------------------------------------------------------------------

#PBFORMS DECLARATIONS
'------------------------------------------------------------------------------
GLOBAL hFont AS DWORD  ' set up the font
'------------------------------------------------------------------------------
'   ** Main Application Entry Point **
'------------------------------------------------------------------------------
FUNCTION PBMAIN()
  PBFormsInitComCtls (%ICC_WIN95_CLASSES OR %ICC_DATE_CLASSES OR _
    %ICC_INTERNET_CLASSES)
  FONT NEW "Courier New",48,3,0 TO hFont
  ShowDIALOG1 %HWND_DESKTOP
  FONT END hFont
END FUNCTION
'------------------------------------------------------------------------------

'------------------------------------------------------------------------------
'   ** CallBacks **
'------------------------------------------------------------------------------
CALLBACK FUNCTION ShowDIALOG1Proc()
  '
  LOCAL strImage AS STRING   ' name of file to load
  LOCAL hBMP AS DWORD        ' handle of bitmap
  LOCAL lng_imgW, lng_imgH AS LONG  ' width and height of img file
  '
  STATIC strEndDate AS STRING
  LOCAL ptnmhdr AS NMHDR PTR            ' information about a notification
  LOCAL ptnmdtc AS NMDATETIMECHANGE PTR ' date time information
  '
  LOCAL lngItem AS LONG                 ' item selected from combobox
  LOCAL lngTextColour AS LONG           ' selected text colour
  DIM a_strTextColour() AS STRING       ' names of text colours
  DIM a_lngTextColour() AS LONG         ' values of text colours
  LOCAL lngR AS LONG                    ' used to cycle through colours
  '
  SELECT CASE AS LONG CB.MSG
    ' /* Inserted by PB/Forms 05-31-2024 15:07:20
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
    ' */

    CASE %WM_INITDIALOG
      ' Initialization handler
      ' load the image combo with all images
      funLoadImageList(CB.HNDL,%IDC_cboBackGroundImage)
      '
      ' set date
      strEndDate = funUKDate()
      funSetaDate(CB.HNDL, %IDC_SYSDATE_countdown, strEndDate)
      '
      ' add text colour options
      REDIM a_strTextColour(1 TO 4)
      REDIM a_lngTextColour(1 TO 4)
      '
      ARRAY ASSIGN a_strTextColour() = "Red","White","Blue","Green"
      ARRAY ASSIGN a_lngTextColour() = %RED,%WHITE,%BLUE,%GREEN
      '
      FOR lngR = 1 TO UBOUND(a_strTextColour)
        COMBOBOX ADD CB.HNDL, %IDC_cboTextColour, _
                              a_strTextColour(lngR) TO lngItem
        COMBOBOX SET USER CB.HNDL,%IDC_cboTextColour, _
                                  lngItem, a_lngTextColour(lngR)
      NEXT lngR
      '
    CASE %WM_NOTIFY
      ptnmhdr = CB.LPARAM
      SELECT CASE @ptnmhdr.idfrom
        CASE %IDC_SYSDATE_countdown
          SELECT CASE @ptnmhdr.code
            CASE %DTN_DATETIMECHANGE
              ptnmdtc = CB.LPARAM
              strEndDate = RIGHT$("00" & FORMAT$(@ptnmdtc.st.wDay),2) & "/" & _
                           RIGHT$("00" & FORMAT$(@ptnmdtc.st.wMonth),2) & "/" & _
                           FORMAT$(@ptnmdtc.st.wYear)
              CONTROL SET TEXT CB.HNDL,%IDC_STATUSBAR1,""
          END SELECT
          '
      END SELECT
      '
    CASE %WM_COMMAND
      ' Process control notifications
      SELECT CASE AS LONG CB.CTL
        ' /* Inserted by PB/Forms 06-01-2024 10:37:27
        CASE %IDC_cboTextColour
        ' */

        ' /* Inserted by PB/Forms 05-31-2024 15:07:20
        CASE %IDC_btnApplyToImage
          IF CB.CTLMSG = %BN_CLICKED OR CB.CTLMSG = 1 THEN
            ' add the countdown to the image
            CONTROL GET TEXT CB.HNDL,%IDC_cboBackGroundImage TO strImage
            '
            ' reload the image from disk
            IF ISTRUE funLoadImageFile(EXE.PATH$ & strImage, _
                                       lng_imgW, _
                                       lng_imgH, _
                                       hBMP ) THEN
              GRAPHIC ATTACH CB.HNDL,%IDC_graSelectedImage, REDRAW
              '
              GRAPHIC COPY hBmp,0
              GRAPHIC BITMAP END
              ' resize the bitmap to fit the graphics control
              GRAPHIC STRETCH PAGE hBmp,%IDC_graSelectedImage, _
                                   %MIX_COPYSRC, %HALFTONE
              ' redraw to the user
              GRAPHIC REDRAW
              '
              CONTROL SET TEXT CB.HNDL,%IDC_STATUSBAR1,""
              '
            END IF
            '
            COMBOBOX GET SELECT CB.HNDL, %IDC_cboTextColour TO lngItem
            IF lngItem = 0 THEN lngItem = 1 ' default to first item
            '
            COMBOBOX GET USER CB.HNDL, %IDC_cboTextColour, lngItem _
                         TO lngTextColour
            '
            funApplyCountDownText(CB.HNDL,%IDC_cboBackGroundImage, _
                                  strEndDate, lngTextColour)
          END IF
        ' */

        ' /* Inserted by PB/Forms 05-31-2024 14:49:20
        CASE %IDC_SYSDATE_countdown
        ' */

        CASE %IDC_cboBackGroundImage
          IF CB.CTLMSG = %BN_CLICKED OR CB.CTLMSG = 1 THEN
            CONTROL GET TEXT CB.HNDL,CB.CTL TO strImage
            IF ISTRUE funLoadImageFile(EXE.PATH$ & strImage, _
                                       lng_imgW, _
                                       lng_imgH, _
                                       hBMP ) THEN
            ' bitmap loaded
              GRAPHIC ATTACH CB.HNDL,%IDC_graSelectedImage, REDRAW
              '
              GRAPHIC COPY hBmp,0
              GRAPHIC BITMAP END
              ' resize the bitmap to fit the graphics control
              GRAPHIC STRETCH PAGE hBmp,%IDC_graSelectedImage, _
                                   %MIX_COPYSRC, %HALFTONE
              '
              ' redraw to the user
              GRAPHIC REDRAW
              CONTROL SET TEXT CB.HNDL,%IDC_STATUSBAR1,"Loaded"
            '
            END IF
          END IF
          '
        CASE %IDABORT
          IF CB.CTLMSG = %BN_CLICKED OR CB.CTLMSG = 1 THEN
            DIALOG END CB.HNDL
          END IF

        CASE %IDC_btnCreateImage
          IF CB.CTLMSG = %BN_CLICKED OR CB.CTLMSG = 1 THEN
            IF ISTRUE funSaveGraphicControl(CB.HNDL, _
                                            %IDC_graSelectedImage, _
                                            EXE.PATH$ & $Output) THEN
            ' saved successfully
              CONTROL SET TEXT CB.HNDL,%IDC_STATUSBAR1,"Saved file"
            '
            END IF
          END IF

        CASE %IDC_STATUSBAR1

      END SELECT
  END SELECT
END FUNCTION
'
'------------------------------------------------------------------------------
'   ** Dialogs **
'------------------------------------------------------------------------------
FUNCTION ShowDIALOG1(BYVAL hParent AS DWORD) AS LONG
  LOCAL lRslt AS LONG

#PBFORMS BEGIN DIALOG %IDD_DIALOG1->->
  LOCAL hDlg  AS DWORD

  DIALOG NEW PIXELS, hParent, "Create a countdown Image", 309, 348, 1254, _
    744, %WS_POPUP OR %WS_BORDER OR %WS_DLGFRAME OR %WS_CAPTION OR _
    %WS_SYSMENU OR %WS_MINIMIZEBOX OR %WS_CLIPSIBLINGS OR %WS_VISIBLE OR _
    %DS_MODALFRAME OR %DS_CENTER OR %DS_3DLOOK OR %DS_NOFAILCREATE OR _
    %DS_SETFONT, %WS_EX_CONTROLPARENT OR %WS_EX_LEFT OR %WS_EX_LTRREADING OR _
    %WS_EX_RIGHTSCROLLBAR, TO hDlg
  CONTROL ADD LABEL,     hDlg, %IDC_lblBackGroundImage, "Select the " + _
    "background Image", 22, 32, 150, 17
  CONTROL SET COLOR      hDlg, %IDC_lblBackGroundImage, %BLUE, -1
  CONTROL ADD COMBOBOX,  hDlg, %IDC_cboBackGroundImage, , 22, 49, 196, 130, _
    %WS_CHILD OR %WS_VISIBLE OR %WS_TABSTOP OR %CBS_DROPDOWNLIST OR _
    %CBS_SORT, %WS_EX_LEFT OR %WS_EX_LTRREADING OR %WS_EX_RIGHTSCROLLBAR
  CONTROL ADD BUTTON,    hDlg, %IDABORT, "Exit", 48, 672, 74, 25
  CONTROL ADD BUTTON,    hDlg, %IDC_btnCreateImage, "Save Image", 768, 656, _
    150, 41
  CONTROL ADD GRAPHIC,   hDlg, %IDC_graSelectedImage, "", 624, 24, 584, 544, _
    %WS_CHILD OR %WS_VISIBLE OR %SS_SUNKEN
  CONTROL ADD STATUSBAR, hDlg, %IDC_STATUSBAR1, "Ready", 0, 0, 0, 0
  CONTROL ADD "SysDateTimePick32", hDlg, %IDC_SYSDATE_countdown, _
    "SysDateTimePick32_1", 24, 144, 184, 24, %WS_CHILD OR %WS_VISIBLE OR _
    %WS_TABSTOP OR %DTS_SHORTDATEFORMAT, %WS_EX_CLIENTEDGE OR %WS_EX_LEFT OR _
    %WS_EX_LTRREADING OR %WS_EX_RIGHTSCROLLBAR
  CONTROL ADD LABEL,     hDlg, %IDC_lblCountDown, "Select the Date to count " + _
    "down to", 24, 126, 150, 17
  CONTROL SET COLOR      hDlg, %IDC_lblCountDown, %BLUE, -1
  CONTROL ADD BUTTON,    hDlg, %IDC_btnApplyToImage, "Apply to Image", 24, _
    208, 184, 32
  CONTROL ADD COMBOBOX,  hDlg, %IDC_cboTextColour, , 272, 144, 150, 65, _
    %WS_CHILD OR %WS_VISIBLE OR %WS_TABSTOP OR %CBS_DROPDOWNLIST OR _
    %CBS_SORT, %WS_EX_LEFT OR %WS_EX_LTRREADING OR %WS_EX_RIGHTSCROLLBAR
  CONTROL ADD LABEL,     hDlg, %IDC_lblTextColour, "Select the Text Colour", _
    272, 126, 150, 17
  CONTROL SET COLOR      hDlg, %IDC_lblTextColour, %BLUE, -1
#PBFORMS END DIALOG
  '
  DIALOG SHOW MODAL hDlg, CALL ShowDIALOG1Proc TO lRslt

#PBFORMS BEGIN CLEANUP %IDD_DIALOG1
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
'
FUNCTION funLoadImageList(hDlg AS DWORD, _
                          lngCombo AS LONG) AS LONG
' load the list of JPGs found into the combo control
  ' first reset the combo
  LOCAL strFile AS STRING
  '
  COMBOBOX RESET hDlg,lngCombo
  '
  strFile = DIR$(EXE.PATH$ & "*.jpeg")
  WHILE strFile <> ""
    COMBOBOX ADD hDlg, lngCombo, strFile
    strFile = DIR$
  WEND
  '
END FUNCTION
'
FUNCTION funApplyCountDownText(hDlg AS DWORD, _
                               lngControl AS LONG, _
                               strEndDate AS STRING, _
                               lngTextColour AS LONG) AS LONG
' work out the days left - where strEndDate = "dd/MM/yyyy" format
' and display on graphics control
  LOCAL lngDaysLeft AS LONG
  LOCAL lngDay1 AS IPOWERTIME
  LET lngDay1 = CLASS "PowerTime"
  LOCAL lngDay2 AS IPOWERTIME
  LET lngDay2 = CLASS "PowerTime
  LOCAL lngSign AS LONG
  LOCAL strText AS STRING
  LOCAL lngControlWidth AS LONG
  LOCAL lngTextWidth AS LONG
  LOCAL lngXPos AS LONG
  '
  LOCAL lngYear, lngMonth, lngDay AS LONG
  LOCAL lngDays AS LONG
  '
  lngYear = VAL(RIGHT$(strEndDate,4))
  lngMonth = VAL(MID$(strEndDate,4,2))
  lngDay = VAL(LEFT$(strEndDate,2))
  '
  lngDay1.Today   ' pick up today
  lngDay2.NewDate(lngYear,lngMonth,lngDay)
  '
  lngDay1.TimeDiff(lngDay2, lngSign,lngDays)
  '
  ' lngDays now has number of days left
  GRAPHIC ATTACH hDlg,%IDC_graSelectedImage, REDRAW
  GRAPHIC SET FONT hFont
  GRAPHIC COLOR lngTextColour,-2 '
  '
  strText = FORMAT$(lngDays) & " Days left "
  '
  ' work out width size of text
  lngTextWidth  = GRAPHIC(TEXT.SIZE.X, strText)
  ' work out width size of control
  lngControlWidth = GRAPHIC(SIZE.X)
  '
  ' calc position to centre text on control
  lngXPos = (lngControlWidth - lngTextWidth) \2
  '
  ' set starting position
  GRAPHIC SET POS  (lngXPos, 10)
  ' print the text
  GRAPHIC PRINT strText
  GRAPHIC REDRAW
  '
END FUNCTION
