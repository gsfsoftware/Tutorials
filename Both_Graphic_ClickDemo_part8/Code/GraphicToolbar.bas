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
#RESOURCE "GraphicToolbar.pbr"
%USEMACROS = 1
#INCLUDE ONCE "WIN32API.INC"
#INCLUDE ONCE "COMMCTRL.INC"
#INCLUDE ONCE "PBForms.INC"
#PBFORMS END INCLUDES
'------------------------------------------------------------------------------
#RESOURCE ICON APPICON,"Graphics\Start.ico"
'------------------------------------------------------------------------------
'   ** Constants **
'------------------------------------------------------------------------------
#PBFORMS BEGIN CONSTANTS
%IDD_dlgGraphicToolbar =  101
%IDC_graToolbar        = 1001
#PBFORMS END CONSTANTS
'------------------------------------------------------------------------------
%ToolBarHeight = 60 ' max height of the toolbar
'
TYPE ButtonData
  lngX AS LONG      ' position on Graphics Window
  lngY AS LONG
  lngWidth AS LONG  ' width of bmp
  lngHeight AS LONG ' height of bmp
  strName AS STRING * 100 ' name/path to button file
  lngCircle AS LONG ' %TRUE if button is a circle
  lngMasked AS LONG ' %TRUE if Button is masked render
  lngMask AS LONG   ' %TRUE is button is the mask
  strType AS STRING * 6 ' type of button e.g. "Start"
END TYPE
'
' enumeration of button states
ENUM ButtonNumber SINGULAR
  StartUp = 1
  StartDown
  StartInactive
  EndUp
  EndDown
  EndInactive
  FilesUp
  FileDown
  FileInactive
  ReportUp
  ReportDown
  ReportInactive
END ENUM
'
' array for buttons
GLOBAL g_aUButtons() AS ButtonData
GLOBAL g_hWin AS DWORD
'
%ID_TIMER1 = 100       ' Timer for clock
%ButtonArray = 12      ' number of images in array
%ImagesPerButton = 3   ' number of images per button
'
FUNCTION PBMAIN () AS LONG
  PBFormsInitComCtls (%ICC_WIN95_CLASSES OR %ICC_DATE_CLASSES OR _
    %ICC_INTERNET_CLASSES)
  '
  REDIM g_aUButtons(%ButtonArray) AS ButtonData
  '
  TXT.WINDOW("Debug", 50,400) TO g_hWin
  ShowdlgGraphicToolbar %HWND_DESKTOP
  TXT.END
  '
END FUNCTION
'
'------------------------------------------------------------------------------
'   ** CallBacks **
'------------------------------------------------------------------------------
CALLBACK FUNCTION ShowdlgGraphicToolbarProc()
  LOCAL lngMx,lngMy AS LONG    ' Mouse x and y
  LOCAL lngButton AS LONG      ' button number clicked on
  STATIC strTime AS STRING     ' Time elapsed
  STATIC lngRunClock AS LONG   ' %true/%false if clock running
  LOCAL lngC AS LONG           ' clock digit
  LOCAL lngAc AS LONG          ' Ascii value of digit
  LOCAL lngXpos AS LONG        ' position to get number
  LOCAL lngXtarget AS LONG     ' position to put number
  '
  SELECT CASE AS LONG CB.MSG
    CASE %WM_INITDIALOG
      ' Initialization handler
      STATIC idEvent AS LONG
      STATIC hBmp AS DWORD
      ' initialise the timer
      idEvent = SetTimer(CB.HNDL, %ID_TIMER1,1000, BYVAL %NULL)
      ' and load the bitmap
      GRAPHIC BITMAP LOAD "Graphics\BIG_Digits.bmp", _
                          840,55 TO hBmp
      DIALOG POST CB.HNDL, %WM_TIMER,%ID_TIMER1,0 ' force the event
      '
      funPrepGraphicToolbar(CB.HNDL,%IDC_graToolbar)
      '
    CASE %WM_TIMER
     ' timer events
      IF CB.WPARAM = %ID_TIMER1 THEN
       ' is clock running?
        IF ISTRUE lngRunClock THEN
          ' advance the time
          strTime = funGetTime(strTime)
          TXT.PRINT strTime
          ' display time digits on toolbar
          FOR lngC = 1 TO LEN(strTime)
            lngAc = ASC(strTime,lngC)
            SELECT CASE AS LONG lngAc
              CASE 48 TO 57
              ' handle numbers
                lngAc = lngAc - 48
                lngXpos = (lngAc * 60)
                lngXtarget = ((lngC-1)* 60) + 450
                GRAPHIC COPY hBmp,0,(lngXpos,0)-(lngAc * 60+58,60) _
                        TO (lngXtarget,5)
              CASE ELSE
              ' and the colon :
                lngAc = 12
                lngXpos = (lngAc * 60)
                lngXtarget = ((lngC-1)* 60) + 450
                GRAPHIC COPY hBmp,0,(lngXpos,0)-(lngAc * 60+58,60) _
                        TO (lngXtarget,5)
            END SELECT
          NEXT lngC
          '
          GRAPHIC REDRAW
        END IF
      END IF
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
    CASE %WM_DESTROY
      TXT.END
      ' stop the timer and close off the bitmap
      IF idEvent THEN
        KillTimer CB.HNDL,idEvent
      END IF
      '
      GRAPHIC ATTACH hBmp,0
      GRAPHIC BITMAP END
      '
    CASE %WM_LBUTTONDOWN
    ' left button pressed
      lngMx=LO(WORD,CB.LPARAM): lngMy=HI(WORD,CB.LPARAM)
      '
      IF lngMy < %ToolBarHeight THEN
      ' click on the toolbar
         TXT.PRINT "Toolbar click " & _
                  FORMAT$(lngMx) & " " & FORMAT$(lngMy)
         ' but which button?
        lngButton = funDetermineButton(lngMx,lngMy)
        TXT.PRINT "Button clicked on = " & FORMAT$(lngButton)
        '
        SELECT CASE lngButton
          CASE %StartUp
            IF ISFALSE lngRunClock THEN
            ' only if clock is not running
            ' draw down button for 200ms
              funDrawToolbarButton(lngButton,lngButton + 1,200,%FALSE)
              lngRunClock = %TRUE
              '
              ' enable End button
              funDrawToolbarButton(lngButton + %ImagesPerButton, _
                                   lngButton + %ImagesPerButton,200,%TRUE)
                                   '
              ' disable Start button
              funDrawToolbarButton(lngButton,lngButton + 2,200,%TRUE)
            END IF
            '
          CASE %EndUp
            IF ISTRUE lngRunClock THEN
              funDrawToolbarButton(lngButton,lngButton + 1,200,%FALSE)
              ' reset the time
              lngRunClock = %FALSE
              strTime = ""
              '
              ' enable start button
              funDrawToolbarButton(lngButton - %ImagesPerButton, _
                                   lngButton - %ImagesPerButton,200,%TRUE)
              '
              ' disable end button
              funDrawToolbarButton(lngButton,lngButton + 2,200,%TRUE)
              '
            END IF
            '
          CASE %FilesUp
            funDrawToolbarButton(lngButton,lngButton +1,200,%TRUE)
            ShowdlgFILESDIALOG CB.HNDL, lngMx, lngMy
            funDrawToolbarButton(lngButton,lngButton,0,%FALSE)
            '
          CASE %ReportUp
            funDrawToolbarButton(lngButton,lngButton + 1,200,%FALSE)
            '
        END SELECT
        '
      ELSE
        TXT.PRINT "left Button Press " & _
                  FORMAT$(lngMx) & " " & FORMAT$(lngMy)
      END IF
      '
    CASE %WM_COMMAND
      ' Process control notifications
      SELECT CASE AS LONG CB.CTL

      END SELECT
  END SELECT
  '
END FUNCTION
'
FUNCTION funGetTime(strTime AS STRING) AS STRING
' get the time
  LOCAL lngMinutes AS LONG
  LOCAL lngSeconds AS LONG
  '
  IF strTime = "" THEN
    strTime = "00:00"
  ELSE
    lngMinutes = VAL(LEFT$(strTime,2))
    lngSeconds = VAL(RIGHT$(strTime,2))
    '
    INCR lngSeconds
    '
    IF lngSeconds = 60 THEN
      INCR lngMinutes
      lngSeconds = 0
    END IF
    '
    strTime = RIGHT$("00" & FORMAT$(lngMinutes),2)
    strTime = strTime & ":" & _
              RIGHT$("00" & FORMAT$(lngSeconds),2)
    '
  END IF
  '
  FUNCTION = strTime
  '
END FUNCTION
'
FUNCTION funPrepGraphicToolbar(hDlg AS DWORD, _
                               lngGraphic AS LONG) AS LONG
' prepare the graphic toolbar
  LOCAL lngX , lngY, lngWidth, lngHeight AS LONG
  LOCAL lngB AS LONG
  LOCAL strName AS STRING
  LOCAL lngXOffSet AS LONG
  LOCAL lngXPosition AS LONG  ' next available slot position
  LOCAL lngGap AS LONG        ' gap between bitmaps
  '
  lngGap = 10
  '
  ' start button images
  PREFIX "g_aUButtons(1)."
    strName = "Graphics\Start_1.bmp"
    lngY = 5
    lngCircle = %TRUE
    strType = "START"
  END PREFIX
  '
  PREFIX "g_aUButtons(2)."
    strName = "Graphics\Start_1d.bmp"
    lngY = 5
    lngCircle = %TRUE
    strType = "START"
  END PREFIX
  '
  PREFIX "g_aUButtons(3)."
    strName = "Graphics\Start_1dim.bmp"
    lngY = 5
    lngCircle = %TRUE
    strType = "START"
  END PREFIX
  '
  ' end button images
  PREFIX "g_aUButtons(4)."
    strName = "Graphics\End_1.bmp"
    lngY = 5
    lngCircle = %TRUE
    strType = "END"
  END PREFIX
  '
  PREFIX "g_aUButtons(5)."
    strName = "Graphics\End_1d.bmp"
    lngY = 5
    lngCircle = %TRUE
    strType = "END"
  END PREFIX
  '
  PREFIX "g_aUButtons(6)."
    strName = "Graphics\End_1dim.bmp"
    lngY = 5
    lngCircle = %TRUE
    strType = "END"
  END PREFIX
  '
  ' file button
  PREFIX "g_aUButtons(7)."
    strName = "Graphics\File_1.bmp"
    lngY = 5
    lngCircle = %FALSE
    strType = "FILE"
  END PREFIX
  '
  PREFIX "g_aUButtons(8)."
    strName = "Graphics\File_1d.bmp"
    lngY = 5
    lngCircle = %FALSE
    strType = "FILE"
  END PREFIX
  '
  PREFIX "g_aUButtons(9)."
    strName = ""
    lngY = 5
    lngCircle = %FALSE
    strType = "FILE"
  END PREFIX
  '
  ' report button
  PREFIX "g_aUButtons(10)."
    strName = "Graphics\Report_1.bmp"
    lngY = 5
    lngCircle = %TRUE
    strType = "REPORT"
  END PREFIX
  '
  PREFIX "g_aUButtons(11)."
    strName = "Graphics\Report_1d.bmp"
    lngY = 5
    lngCircle = %TRUE
    strType = "REPORT"
  END PREFIX
  '
  PREFIX "g_aUButtons(12)."
    strName = ""
    lngY = 5
    lngCircle = %TRUE
    strType = "REPORT"
  END PREFIX
  '
  ' work out the individual height and width
  ' of each bitmap
  '
  GRAPHIC ATTACH hDlg, lngGraphic, REDRAW
  GRAPHIC CLEAR %RGB_LIGHTGRAY,0
  '
  lngXPosition = 0
  '
  FOR lngB = 1 TO UBOUND(g_aUButtons) STEP %ImagesPerButton
  ' work out the individual height and width
  ' of each bitmap
    IF TRIM$(g_aUButtons(lngB).strType) = "END" THEN
    ' special handling for end button - grey it out
      strName = TRIM$(g_aUButtons(lngB+2).strName)
    ELSE
      strName = TRIM$(g_aUButtons(lngB).strName)
    END IF
    '
    funGetBitmapData(strName, lngWidth,lngHeight)
    ' work out new starting position
    lngXOffSet = lngXPosition + _
                 g_aUButtons(lngB-%ImagesPerButton).lngWidth + lngGap
    ' store it
    lngXPosition = lngXOffSet
    '
    lngX = lngXOffSet
    lngY = g_aUButtons(lngB).lngY
    '
    IF ISTRUE g_aUButtons(lngB).lngCircle THEN
    ' only for circular buttons
    lngWidth = MIN(lngWidth,50)
    END IF
    '
    lngHeight = MIN(lngHeight,50)
    '
    ' store the X & Y , width and height
    PREFIX "g_aUButtons(lngB)."
      lngX = lngX
      lngY = lngY
      lngWidth = lngWidth
      lngHeight = lngHeight
    END PREFIX
    '
    GRAPHIC RENDER BITMAP strName, (lngX, lngY)- _
                                   (lngX +lngWidth,lngY+lngHeight)
                                   '
  NEXT lngB
  '
  GRAPHIC REDRAW
  '
END FUNCTION
'
FUNCTION funGetBitmapData(strBitmap AS STRING, _
                          o_lngWidth AS LONG, _
                          o_lngHeight AS LONG) AS LONG
  ' return the width and height of bitmap
  LOCAL lngFile AS LONG
  lngFile = FREEFILE
  OPEN strBitmap FOR BINARY AS lngFile
  GET #lngFile, 19, o_lngWidth
  GET #lngFile, 23, o_lngHeight
  CLOSE #lngFile
  '
END FUNCTION
'
FUNCTION funDetermineButton(lngMx AS LONG, _
                            lngMy AS LONG) AS LONG
' work out which toolbar button has been clicked on
  LOCAL lngB AS LONG          ' button index
  LOCAL lngCx, lngCy AS LONG  ' centre of image
  LOCAL lngBx, lngBy, lngBw, lngBh AS LONG
  LOCAL lngDistance AS LONG   ' distance to centre of bitmap
  '
  FOR lngB = 1 TO UBOUND(g_aUButtons) STEP %ImagesPerButton
  ' step through each button and return index of button
    lngBx = g_aUButtons(lngB).lngX  ' top left corner of image
    lngBy = g_aUButtons(lngB).lngY  '
    lngBw = g_aUButtons(lngB).lngWidth  ' width of image
    lngBh = g_aUButtons(lngB).lngHeight ' height of image
    '
    lngCx = lngBx + (lngBw / 2)   ' work out centre of image
    lngCy = lngBy + (lngBh / 2)
    '
    lngDistance = SQR((lngMx - lngCx)^2 + _
                      (lngMy - lngCy)^2)
    IF lngDistance <= (lngBw / 2) THEN
    ' found the button
      FUNCTION = lngB
      EXIT FUNCTION
    '
    END IF
    '
  NEXT lngB
  '
  ' did not find the button
  FUNCTION = 0
  '
END FUNCTION
'
FUNCTION funDrawToolbarButton(lngButtonLoc AS LONG, _
                              lngButtonImage AS LONG, _
                              lngDelay AS LONG, _
                              lngToggle AS LONG) AS LONG
' draw the down button
  LOCAL strName AS STRING
  LOCAL lngX, lngY AS LONG
  LOCAL lngWidth, lngHeight AS LONG
  '
  strName = TRIM$(g_aUButtons(lngButtonImage).strName)
  lngX = g_aUButtons(lngButtonLoc).lngX
  lngY = g_aUButtons(lngButtonLoc).lngY
  lngWidth = g_aUButtons(lngButtonLoc).lngWidth
  lngHeight = g_aUButtons(lngButtonLoc).lngHeight
  '
  GRAPHIC RENDER BITMAP strName, (lngX, lngY)- _
                                 (lngX +lngWidth,lngY+lngHeight)
  GRAPHIC REDRAW
  '
  IF ISTRUE lngToggle THEN
  ' keep the button state
  ' exit immediately
  ELSE
    SLEEP lngDelay
    strName = TRIM$(g_aUButtons(lngButtonLoc).strName)
    GRAPHIC RENDER BITMAP strName, (lngX, lngY)- _
                                   (lngX +lngWidth,lngY+lngHeight)
    GRAPHIC REDRAW
  END IF
  '
END FUNCTION
'------------------------------------------------------------------------------
'   ** Dialogs **
'------------------------------------------------------------------------------
FUNCTION ShowdlgGraphicToolbar(BYVAL hParent AS DWORD) AS LONG
  LOCAL lRslt AS LONG

#PBFORMS BEGIN DIALOG %IDD_dlgGraphicToolbar->->
  LOCAL hDlg  AS DWORD

  DIALOG NEW PIXELS, hParent, "Graphic Toolbar", 348, 344, 800, 288, _
    %WS_POPUP OR %WS_BORDER OR %WS_DLGFRAME OR %WS_CAPTION OR %WS_SYSMENU OR _
    %WS_MINIMIZEBOX OR %WS_CLIPSIBLINGS OR %WS_VISIBLE OR %DS_MODALFRAME OR _
    %DS_CENTER OR %DS_3DLOOK OR %DS_NOFAILCREATE OR %DS_SETFONT, _
    %WS_EX_CONTROLPARENT OR %WS_EX_LEFT OR %WS_EX_LTRREADING OR _
    %WS_EX_RIGHTSCROLLBAR, TO hDlg
  CONTROL ADD GRAPHIC, hDlg, %IDC_graToolbar, "", 0, 0, 800, 50
#PBFORMS END DIALOG
  ' set size of the toolbar
  CONTROL SET SIZE hDlg, %IDC_graToolbar, 800, %ToolBarHeight
  ' and the dialog
  DIALOG SET SIZE hDlg, 800,%ToolBarHeight + METRICS(CAPTION) +5
  DIALOG SET ICON hDlg, "APPICON"
  '
  DIALOG SHOW MODAL hDlg, CALL ShowdlgGraphicToolbarProc TO lRslt

#PBFORMS BEGIN CLEANUP %IDD_dlgGraphicToolbar
#PBFORMS END CLEANUP

  FUNCTION = lRslt
END FUNCTION
'
FUNCTION ShowdlgFILESDIALOG(BYVAL hParent AS DWORD, _
                            lngMx AS LONG, _
                            lngMy AS LONG) AS LONG
  LOCAL lRslt AS LONG

#PBFORMS BEGIN DIALOG %IDD_dlgFILESDIALOG->->
  LOCAL hDlg  AS DWORD

  DIALOG NEW hParent, "Files dialog", 461, 242, 201, 121, %WS_POPUP OR _
    %WS_BORDER OR %WS_DLGFRAME OR %WS_CAPTION OR %WS_SYSMENU OR _
    %WS_CLIPSIBLINGS OR %WS_VISIBLE OR %DS_MODALFRAME OR _
    %DS_3DLOOK OR %DS_NOFAILCREATE OR %DS_SETFONT, %WS_EX_CONTROLPARENT OR _
    %WS_EX_LEFT OR %WS_EX_LTRREADING OR %WS_EX_RIGHTSCROLLBAR, TO hDlg
#PBFORMS END DIALOG
  DIALOG SET LOC hDlg,lngMx,lngMy
  DIALOG SHOW MODAL hDlg, CALL ShowdlgFILESDIALOGProc TO lRslt

#PBFORMS BEGIN CLEANUP %IDD_dlgFILESDIALOG
#PBFORMS END CLEANUP

  FUNCTION = lRslt
END FUNCTION
'
CALLBACK FUNCTION ShowdlgFILESDIALOGProc()

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

      END SELECT
  END SELECT
END FUNCTION
