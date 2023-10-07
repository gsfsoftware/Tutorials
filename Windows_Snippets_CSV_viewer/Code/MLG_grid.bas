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

#COMPILE EXE "View_CSV_File.exe"
#DIM ALL
#DEBUG ERROR ON
'------------------------------------------------------------------------------
'   ** Includes **
'------------------------------------------------------------------------------
#PBFORMS BEGIN INCLUDES
#RESOURCE "MLG_grid.pbr"
%USEMACROS = 1
#INCLUDE ONCE "WIN32API.INC"
#INCLUDE ONCE "COMMCTRL.INC"
#INCLUDE ONCE "PBForms.INC"
#PBFORMS END INCLUDES
'------------------------------------------------------------------------------
%MLGSLL = 1
#INCLUDE "MLG.INC"
#LINK "MLG.SLL"
'
#INCLUDE "Libraries/PB_MLG_Utilities.inc"
#INCLUDE "Libraries/PB_FileHandlingRoutines.inc"
#INCLUDE "Libraries/Macros.inc"
'
%LAYOUT32 = 1        ' used to set layout32 logic
'                      comment above line out
'                      to not use Layout32 SLL
#IF %DEF(%LAYOUT32)
  #INCLUDE ONCE "Layout32_lib/Layout32_sll.inc"
  #LINK "Layout32_lib/Layout32.sll"
#ENDIF
'
%IDC_GRID1 = 2000
GLOBAL hGrid1 AS DWORD
'------------------------------------------------------------------------------
'   ** Constants **
'------------------------------------------------------------------------------
#PBFORMS BEGIN CONSTANTS
%IDR_IMGFILE1          =  102
%IDR_IMGFILE2          =  103
%IDR_IMGFILE3          =  104
%IDD_dlgDisplayCSVFile =  101
%IDABORT               =    3
%IDC_TOOLBAR1          = 1001
%IDC_TOOLBAR_NEW1      = 1002
%IDC_TOOLBAR_OPEN1     = 1003
%IDC_TOOLBAR_SAVE1     = 1004
%IDC_lblRecordcount    = 1005
#PBFORMS END CONSTANTS
'------------------------------------------------------------------------------

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
  LOCAL strFile AS STRING
  LOCAL lngFlags AS LONG
  LOCAL strPath AS STRING
  LOCAL strCommand AS STRING
  '
  strCommand = COMMAND$(1)
  REPLACE $DQ WITH "" IN strCommand
  '
  IF strCommand <> "" THEN
    IF ISFALSE ISFILE(strCommand) THEN
      MSGBOX "Passed file cannot be accessed",0,"Load Error"
      strFile = ""
    ELSE
      strFile = strCommand
    END IF
  ELSE
    strFile = ""
  END IF
  '
  IF strFile = "" THEN
  '
    strPath = EXE.PATH$
    '
    lngFlags = %OFN_FILEMUSTEXIST OR %OFN_PATHMUSTEXIST
    DISPLAY OPENFILE %HWND_DESKTOP,,,"Select CSV file to load", _
            EXE.PATH$, CHR$("CSV",0,"*.CSV",0), _
            "","CSV",lngFlags TO strFile
  END IF
  '
  IF strFile <> "" THEN
    ShowdlgDisplayCSVFile %HWND_DESKTOP,strFile
  END IF
  '
END FUNCTION
'------------------------------------------------------------------------------

'------------------------------------------------------------------------------
'   ** CallBacks **
'------------------------------------------------------------------------------
CALLBACK FUNCTION ShowdlgDisplayCSVFileProc()
  '
  LOCAL strFile AS STRING
  LOCAL lngFlags AS LONG
  DIM a_strWork() AS STRING
  LOCAL lngRows AS LONG
  LOCAL lngColumns AS LONG
  LOCAL MLGN AS MyGridData PTR
  LOCAL myitem AS LONG
  LOCAL mycol AS LONG
  LOCAL myrow AS LONG
  LOCAL strText AS STRING
  LOCAL lngClipResult AS LONG
  STATIC lngSorting AS LONG
  '
  #IF NOT %DEF(%LAYOUT32)
  ' to be used when layout32 is not used
    LOCAL lngX , lngY AS LONG
    LOCAL lngWide, lngHigh  AS LONG
    LOCAL lngObjWide, lngObjHigh AS LONG
    LOCAL lngCurrentX, lngCurrentY AS LONG ' current size of the dialog
    LOCAL lngDlgMinX, lngDlgMinY AS LONG   ' minimum sizes for Dialog
    lngDlgMinX =  545
    lngDlgMinY =  249
  #ENDIF
  '
  SELECT CASE AS LONG CB.MSG
    CASE %WM_INITDIALOG
      ' Initialization handler
      DIALOG MAXIMIZE CB.HNDL
      '
    CASE %WM_SIZE:  'Called when window changes size
      ' Dialog has been resized
      '
      IF ISTRUE isIconic(CB.HNDL) THEN EXIT FUNCTION  ' Exit if app is minimized
      '
      #IF NOT %DEF(%LAYOUT32)
      ' perform relocation of grid and button objects
      ' work out size of client area and position button
      ' at bottom left
        DIALOG GET CLIENT CB.HNDL TO lngWide, lngHigh
        DIALOG GET SIZE CB.HNDL TO lngCurrentX, lngCurrentY
        '
        IF lngCurrentX < lngDlgMinX OR lngCurrentY < lngDlgMinY THEN
        ' handle min size - do not allow dialog to get smaller
          DIALOG SET SIZE CB.HNDL, lngDlgMinX,lngDlgMinY
          EXIT FUNCTION
        END IF
        ' get size of the exit button
        CONTROL GET SIZE CB.HNDL, %IDABORT TO lngObjWide, lngObjHigh
        ' work out new position of exit button
        lngX = lngWide - (lngObjWide * 2)
        lngY = lngHigh - (lngObjHigh * 2)
        CONTROL SET LOC CB.HNDL, %IDABORT, lngX, lngY
        ' get the size of the grid
        CONTROL GET SIZE CB.HNDL, %IDC_GRID1 TO lngObjWide, lngObjHigh
        ' work out new size of the grid
        lngX = lngWide -  50
        lngY = lngHigh -  100
        CONTROL SET SIZE CB.HNDL, %IDC_GRID1, lngX, lngY

        ' now redraw the dialog
        DIALOG REDRAW CB.HNDL
        '
      #ENDIF
      ' refresh the grid display
      funGridRefresh(hGrid1)
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
    CASE %WM_NOTIFY
      MLGN=CB.LPARAM
      SELECT CASE @MLGN.NMHeader.idFrom
        CASE %IDC_GRID1
          SELECT CASE @MLGN.NMHeader.code
            CASE %MLGN_RCLICKMENU
              myitem=@MLGN.Param3  ' Menu Item . 1 = Copy to clipboard
              mycol=@MLGN.Param2   ' Column of Mouse
              myrow=@MLGN.Param1   ' current row
              SELECT CASE myitem
                CASE 1
                ' copy to clipboard
                  strText = MLG_Get(hGrid1,myrow,mycol)
                  CLIPBOARD RESET
                  CLIPBOARD SET TEXT strText, lngClipResult
                  '
                CASE 2
                ' sort A-Z by column picked
                  lngSorting = %TRUE
                  SendMessage(hGrid1, %MLG_SORT,%MLG_ASCEND ,mycol)
                  funGridRefresh(hGrid1)
                  lngSorting = %FALSE
                '
                CASE 3
                ' sort Z-A by column picked
                  lngSorting = %TRUE
                  SendMessage( hGrid1, %MLG_SORT,%MLG_DESCEND ,mycol)
                  funGridRefresh(hGrid1)
                  lngSorting = %FALSE
                '
              END SELECT
              '
          END SELECT
      END SELECT
      '
    CASE %WM_PAINT
    ' handle repaints
      CONTROL REDRAW CB.HNDL, %IDC_GRID1
      '
    CASE %WM_COMMAND
      ' Process control notifications
      SELECT CASE AS LONG CB.CTL
        ' /* Inserted by PB/Forms 07-12-2020 14:56:55

        CASE %IDC_TOOLBAR_OPEN1
          IF CB.CTLMSG = %BN_CLICKED OR CB.CTLMSG = 1 THEN
          ' load the new csv file
            lngFlags = %OFN_FILEMUSTEXIST OR %OFN_PATHMUSTEXIST
            DISPLAY OPENFILE %HWND_DESKTOP,,,"Select CSV file to load", _
                  "", CHR$("CSV",0,"*.CSV",0), _
                  "","CSV",lngFlags TO strFile
                  '
            IF strFile <> "" THEN
            ' new file has been selected
              funGridClear(hGrid1)
              '
              IF ISTRUE funReadTheCSVFileIntoAnArray(strFile, _
                                      BYREF a_strWork()) THEN
              ' if file is loaded then put it in grid
                lngRows = UBOUND(a_strWork,1)
                lngColumns = UBOUND(a_strWork,2)
                '
                MLG_ArrayRedim(hGrid1, lngRows , lngColumns, _
                               lngRows+10, lngColumns+2)
                MLG_PutEx(hGrid1,a_strWork(),1,1)
                '
                CONTROL SET TEXT CB.HNDL,%IDC_lblRecordcount, _
                     FORMAT$(lngRows) & " records returned"
                '
                funWidenColumnsInGrid(hGrid1)
                funColourBankGridRows(hGrid1)
                '
                funGridRefresh(hGrid1)
              '
              END IF
            '
            END IF
          '
          END IF
          '
'        CASE %IDC_TOOLBAR_SAVE1
'          IF CB.CTLMSG = %BN_CLICKED OR CB.CTLMSG = 1 THEN
'            MSGBOX "%IDC_TOOLBAR_SAVE1=" + FORMAT$(%IDC_TOOLBAR_SAVE1), _
'              %MB_TASKMODAL
'          END IF
        ' */
        '
        CASE %IDABORT
          IF CB.CTLMSG = %BN_CLICKED OR CB.CTLMSG = 1 THEN
            DIALOG END CB.HNDL
          END IF
          '
      END SELECT
  END SELECT
END FUNCTION
'------------------------------------------------------------------------------

'------------------------------------------------------------------------------
'   ** Dialogs **
'------------------------------------------------------------------------------
FUNCTION ShowdlgDisplayCSVFile(BYVAL hParent AS DWORD, _
                               strFile AS STRING) AS LONG
  LOCAL lRslt AS LONG
  DIM a_strWork() AS STRING
  LOCAL lngRows AS LONG
  LOCAL lngColumns AS LONG
  LOCAL strRightClickMenu AS STRING
  '
#PBFORMS BEGIN DIALOG %IDD_dlgDisplayCSVFile->->
  LOCAL hDlg  AS DWORD

  DIALOG NEW hParent, "Display CSV files", 287, 206, 545, 249, %WS_POPUP _
    OR %WS_BORDER OR %WS_DLGFRAME OR %WS_THICKFRAME OR %WS_CAPTION OR _
    %WS_SYSMENU OR %WS_MINIMIZEBOX OR %WS_MAXIMIZEBOX OR %WS_CLIPSIBLINGS OR _
    %WS_VISIBLE OR %DS_MODALFRAME OR %DS_CENTER OR %DS_3DLOOK OR _
    %DS_NOFAILCREATE OR %DS_SETFONT, %WS_EX_CONTROLPARENT OR %WS_EX_LEFT OR _
    %WS_EX_LTRREADING OR %WS_EX_RIGHTSCROLLBAR, TO hDlg
  CONTROL ADD BUTTON,  hDlg, %IDABORT, "Exit", 450, 215, 50, 15
  CONTROL ADD TOOLBAR, hDlg, %IDC_TOOLBAR1, "", 10, 0, 0, 0
  CONTROL ADD LABEL,   hDlg, %IDC_lblRecordcount, "0", 15, 45, 100, 10
  CONTROL SET COLOR    hDlg, %IDC_lblRecordcount, %BLUE, -1
#PBFORMS END DIALOG

  SampleToolbar  hDlg, %IDC_TOOLBAR1
  '
  IF ISTRUE funReadTheCSVFileIntoAnArray(strFile, BYREF a_strWork()) THEN

  '
  ' f = font
  ' s = font size
  ' r = rows
  ' c = columns
  ' z1 = create an array to allow individual cell formatting
  ' b = block selection 1 -> rows. 2-> columns. 3-> rows and columns
  ' x = column widths
  ' e = 1-> return key action 3-> add new row
  ' d = scroll bar
  ' a = row numbering defaults to numbered
  ' y = add extra pixels to row height - needed for some fonts
  '
    MLG_Init ' initialise the grid
    '
    lngRows = UBOUND(a_strWork,1)
    lngColumns = UBOUND(a_strWork,2)
    strRightClickMenu = "/m1Copy Cell,Sort A-Z,Sort Z-A"
    '
    CONTROL ADD "MYLITTLEGRID", hDlg, %IDC_GRID1, _
        "x20/a2/f3/s10/r" & FORMAT$(lngRows) & "/c" & _
        FORMAT$(lngColumns) & "/z1/e1/d-0/y3" & _
        strRightClickMenu , 5,60, 530, _
        120, %WS_CHILD OR %WS_VISIBLE OR %WS_BORDER, _
        %WS_EX_LEFT OR %WS_EX_LTRREADING
    CONTROL HANDLE hDlg, %IDC_Grid1 TO hGrid1
    '
    SendMessage hGrid1,%MLG_SETCELL,0,0
    '
    ' rename the tab
    funRenameTab(hGrid1,1,"CSV file")
    '
    MLG_PutEx(hGrid1,a_strWork(),1,1)
    '
    CONTROL SET TEXT hDlg,%IDC_lblRecordcount, _
                     FORMAT$(lngRows) & " records returned"
    '
    funWidenColumnsInGrid(hGrid1)
    funColourBankGridRows(hGrid1)
    '
    funGridRefresh(hGrid1)
    '
  ELSE
  '
    MLG_Init ' initialise the grid
    '
    lngRows = 1 ' UBOUND(a_strWork,1)
    lngColumns = 1' UBOUND(a_strWork,2)
    '
    CONTROL ADD "MYLITTLEGRID", hDlg, %IDC_GRID1, _
        "x20/a2/f3/s10/r" & FORMAT$(lngRows) & "/c" & _
        FORMAT$(lngColumns) & "/z1/e1/d-0/y3/m1Copy Cell", 5,60, 530, _
        120, %WS_CHILD OR %WS_VISIBLE OR %WS_BORDER, _
        %WS_EX_LEFT OR %WS_EX_LTRREADING
    CONTROL HANDLE hDlg, %IDC_Grid1 TO hGrid1
    '
    SendMessage hGrid1,%MLG_SETCELL,0,0
    '
    ' rename the tab
    funRenameTab(hGrid1,1,"CSV file")
    '
    'MLG_PutEx(hGrid1,a_strWork(),1,1)
    '
    CONTROL SET TEXT hDlg,%IDC_lblRecordcount, _
                     FORMAT$(lngRows) & " records returned"
    '
    funWidenColumnsInGrid(hGrid1)
    funColourBankGridRows(hGrid1)
    '
    funGridRefresh(hGrid1)
  '
  END IF
  '
  #IF %DEF(%LAYOUT32)
  ' RESIZE RULES
    Layout_AddRule hDlg, %Stretch, %Right, %IDC_GRID1, %Right
    Layout_AddRule hDlg, %Stretch, %Bottom, %IDC_GRID1, %Bottom
    Layout_AddRule hDlg, %Move, %Bottom, %IDABORT, %Bottom
    Layout_AddRule hDlg, %Move, %Right, %IDABORT, %Right

    ' Limits
    macDialogToPixels(hDlg, 545, 249)
    Layout_AddLimit hDlg, %Form, xx&, yy&
  #ENDIF
  '
  DIALOG SHOW MODAL hDlg, CALL ShowdlgDisplayCSVFileProc TO lRslt

#PBFORMS BEGIN CLEANUP %IDD_dlgDisplayCSVFile
#PBFORMS END CLEANUP

  FUNCTION = lRslt
END FUNCTION
'------------------------------------------------------------------------------
'FUNCTION funCustomColourBank(hGrid AS DWORD) AS LONG
'' custom colour the cells
'
'  LOCAL I AS LONG
'  LOCAL lngRows AS LONG
'  LOCAL lngColumns AS LONG
'  LOCAL lngR AS LONG
'  LOCAL lngC AS LONG
'  LOCAL lngColour AS LONG
'  LOCAL strStatus AS STRING
'  '
'  '%CELLCOLORRED   = 2
'  '%CELLCOLORGREEN = 4
'  '%CELLCOLORYELLOW = 14
'  '
'  ' determine the size of the grid
'  I= SendMessage(hGrid, %MLG_GETROWCOLTOT, 0, 0)
'  lngRows = LO(INTEGER, I)
'  lngColumns = HI(INTEGER,I)
'  '
'  ' change the colour slot to a different colour
'  SendMessage hGrid,%MLG_SETBKGNDCELLCOLOR,4,%RGB_AQUAMARINE
'  '
'  ' sweep through the grid and change the background
'  ' colour of each cell
'  FOR lngR = 1 TO lngRows
'    strStatus = ""
'    FOR lngC = 13 TO lngColumns
'      strStatus = strStatus & MLG_Get(hGrid,lngR,lngC) & ","
'    NEXT lngC
'    '
'    strStatus = TRIM$(strStatus,",")
'    '
'    SELECT CASE strStatus
'      CASE "yes,.,.,.,.,.,.,.","yes,.,.,.,.,yes,yes,yes"
'      ' yellow
'        lngColour = 14
'      CASE ".,yes,.,.,.,.,.,.",".,.,yes,.,.,.,.,.",".,.,.,yes,.,.,.,.", "yes,.,.,.,yes,yes,yes,yes", "yes,.,.,.,yes,yes,yes,."
'      ' red
'        lngColour = 2
'      CASE ELSE
'      ' normal
'        lngColour = 0
'        '
'    END SELECT
'    '
'    ' handle high priority fields
'    IF PARSE$(strStatus,",",2) = "yes" THEN lngColour = 2
'    IF PARSE$(strStatus,",",3) = "yes" THEN lngColour = 2
'    IF PARSE$(strStatus,",",4) = "yes" THEN lngColour = 2
'    '
'    IF lngColour = 0 THEN
'      IF PARSE$(strStatus,",",1) = "yes" THEN lngColour = 14
'    END IF
'    '
'    FOR lngC = 13 TO lngColumns
'    ' set the background colour to slot 0 (white)
'      IF lngColour <> 0 THEN
'         SendMessage hGrid,%MLG_SETFORMATOVERRIDEEX, _
'                   MAKLNG(lngR,lngC), _
'                   MAKLNG(%MLG_TYPE_BKGCOLOR,lngColour)
'      END IF
'    NEXT lngC
'
'  NEXT lngR
'  '
'END FUNCTION
'------------------------------------------------------------------------------
FUNCTION SampleToolbar(BYVAL hDlg AS DWORD, BYVAL lID AS LONG) AS LONG
#PBFORMS BEGIN TOOLBARIMAGES %IDR_IMGFILE1->%IDR_IMGFILE2->%IDR_IMGFILE3->->
  LOCAL hImgList AS LONG

  IMAGELIST NEW ICON 16, 16, 32, 3 TO hImgList
  IMAGELIST ADD ICON hImgList, "#" + FORMAT$(%IDR_IMGFILE1)
  IMAGELIST ADD ICON hImgList, "#" + FORMAT$(%IDR_IMGFILE2)
  IMAGELIST ADD ICON hImgList, "#" + FORMAT$(%IDR_IMGFILE3)
  TOOLBAR SET IMAGELIST hDlg, lID, hImgList, 0
#PBFORMS END TOOLBARIMAGES

#PBFORMS BEGIN TOOLBARBUTTONS %IDC_TOOLBAR_NEW1->%IDC_TOOLBAR_OPEN1->%IDC_TOOLBAR_SAVE1->->
 ' TOOLBAR ADD BUTTON hDlg, lID, 1, %IDC_TOOLBAR_NEW1, %TBSTYLE_BUTTON, "New"
  TOOLBAR ADD BUTTON hDlg, lID, 2, %IDC_TOOLBAR_OPEN1, %TBSTYLE_BUTTON, _
    "Open"
 ' TOOLBAR ADD BUTTON hDlg, lID, 3, %IDC_TOOLBAR_SAVE1, %TBSTYLE_BUTTON, _
 '   "Save"
#PBFORMS END TOOLBARBUTTONS
END FUNCTION
'------------------------------------------------------------------------------
