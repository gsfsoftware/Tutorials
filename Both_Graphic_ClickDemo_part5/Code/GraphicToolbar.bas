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
END TYPE
'
' enumeration of button states
ENUM ButtonNumber SINGULAR
  StartUp = 1
  StartDown
  EndUp
  EndDown
  FilesUp
  FileDown
  ReportUp
  ReportDown
END ENUM
'
GLOBAL g_aUButtons() AS ButtonData
GLOBAL g_hWin AS DWORD
'
FUNCTION PBMAIN () AS LONG
  PBFormsInitComCtls (%ICC_WIN95_CLASSES OR %ICC_DATE_CLASSES OR _
    %ICC_INTERNET_CLASSES)
  '
  REDIM g_aUButtons(8) AS ButtonData
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
  '
  SELECT CASE AS LONG CB.MSG
    CASE %WM_INITDIALOG
      ' Initialization handler
      funPrepGraphicToolbar(CB.HNDL,%IDC_graToolbar)
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
          ' draw down button for 200ms
            funDrawToolbarButton(lngButton,lngButton + 1,200,%FALSE)
          CASE %EndUp
            funDrawToolbarButton(lngButton,lngButton + 1,200,%FALSE)
          CASE %FilesUp
            funDrawToolbarButton(lngButton,lngButton +1,200,%TRUE)
            ShowdlgFILESDIALOG CB.HNDL
            funDrawToolbarButton(lngButton,lngButton,0,%FALSE)
          CASE %ReportUp
            funDrawToolbarButton(lngButton,lngButton + 1,200,%FALSE)
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
FUNCTION funPrepGraphicToolbar(hDlg AS DWORD, _
                               lngGraphic AS LONG) AS LONG
' prepare the graphic toolbar
  LOCAL lngX , lngY, lngWidth, lngHeight AS LONG
  LOCAL lngB AS LONG
  LOCAL strName AS STRING
  LOCAL lngXOffSet AS LONG
  LOCAL lngSlot AS LONG
  '
  PREFIX "g_aUButtons(1)."
    strName = "Graphics\Start_1.bmp"
    lngY = 5
  END PREFIX
  '
  PREFIX "g_aUButtons(2)."
    strName = "Graphics\Start_1d.bmp"
    lngY = 5
  END PREFIX
  '
  PREFIX "g_aUButtons(3)."
    strName = "Graphics\End_1.bmp"
    lngY = 5
  END PREFIX
  '
  PREFIX "g_aUButtons(4)."
    strName = "Graphics\End_1d.bmp"
    lngY = 5
  END PREFIX
  '
  PREFIX "g_aUButtons(5)."
    strName = "Graphics\Files_1.bmp"
    lngY = 5
  END PREFIX
  '
  PREFIX "g_aUButtons(6)."
    strName = "Graphics\Files_1d.bmp"
    lngY = 5
  END PREFIX
  '
  PREFIX "g_aUButtons(7)."
    strName = "Graphics\Report_1.bmp"
    lngY = 5
  END PREFIX
  '
  PREFIX "g_aUButtons(8)."
    strName = "Graphics\Report_1d.bmp"
    lngY = 5
  END PREFIX
  '
  GRAPHIC ATTACH hDlg, lngGraphic, REDRAW
  GRAPHIC CLEAR %RGB_LIGHTGRAY,0
  '
  FOR lngB = 1 TO UBOUND(g_aUButtons) STEP 2
    strName = TRIM$(g_aUButtons(lngB).strName)
    lngXOffSet = lngSlot * (g_aUButtons(1).lngWidth +10)
    '
    lngX = g_aUButtons(lngB).lngX + lngXOffSet
    lngY = g_aUButtons(lngB).lngY
    '
    funGetBitmapData(strName, lngWidth,lngHeight)
    lngWidth = MIN(lngWidth,50)
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
    INCR lngSlot ' advance the slot
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
  FOR lngB = 1 TO UBOUND(g_aUButtons) STEP 2
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
  ' keep the button down
  ' immediately
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
  CONTROL SET SIZE hDlg, %IDC_graToolbar, 800, %ToolBarHeight


  DIALOG SHOW MODAL hDlg, CALL ShowdlgGraphicToolbarProc TO lRslt

#PBFORMS BEGIN CLEANUP %IDD_dlgGraphicToolbar
#PBFORMS END CLEANUP

  FUNCTION = lRslt
END FUNCTION
'
FUNCTION ShowdlgFILESDIALOG(BYVAL hParent AS DWORD) AS LONG
  LOCAL lRslt AS LONG

#PBFORMS BEGIN DIALOG %IDD_dlgFILESDIALOG->->
  LOCAL hDlg  AS DWORD

  DIALOG NEW hParent, "Files dialog", 461, 242, 201, 121, %WS_POPUP OR _
    %WS_BORDER OR %WS_DLGFRAME OR %WS_CAPTION OR %WS_SYSMENU OR _
    %WS_CLIPSIBLINGS OR %WS_VISIBLE OR %DS_MODALFRAME OR %DS_CENTER OR _
    %DS_3DLOOK OR %DS_NOFAILCREATE OR %DS_SETFONT, %WS_EX_CONTROLPARENT OR _
    %WS_EX_LEFT OR %WS_EX_LTRREADING OR %WS_EX_RIGHTSCROLLBAR, TO hDlg
#PBFORMS END DIALOG

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
