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
#RESOURCE "MLG_CodeLibrary.pbr"
%USEMACROS = 1
#INCLUDE ONCE "WIN32API.INC"
#INCLUDE ONCE "COMMCTRL.INC"
#INCLUDE ONCE "PBForms.INC"
#PBFORMS END INCLUDES
'------------------------------------------------------------------------------
%MLGSLL = 1             ' set to use MLG as a SLL
#INCLUDE "MLG.INC"      ' include MLG library
#LINK "MLG.SLL"         ' link to SSL
'
' MLG Lite Utilities
#INCLUDE "MLG_Lite_Utilities.inc"
#INCLUDE "..\Libraries\PB_FileHandlingRoutines.inc"
#INCLUDE "PB_ToolbarLIB.inc"
'------------------------------------------------------------------------------
'   ** Constants **
'------------------------------------------------------------------------------
#PBFORMS BEGIN CONSTANTS
%IDD_dlgMLG_lite = 101
%IDABORT         =   3
#PBFORMS END CONSTANTS
%MainToolbar     = 1001
'
%Max_Libraries = 2000
'
'------------------------------------------------------------------------------
' grid constants & Globals
%MaxGridColumns = 5     ' set starter number of columns in grid
%MaxGridRows    = 350   ' set starter number of rows in grid
' define the column widths
$ColumnWidths   = "x20,80,230,80,200,400"
' define the column names
$ColumnNames    = "Type,Routine,Line,Library,Description"
'
' one constant for each grid
%IDC_MLGGRID1   = 3000  ' dialog control handle for grid

' one global per grid in your application
GLOBAL hGrid1 AS LONG  ' Windows handle for grid
'

'------------------------------------------------------------------------------
'   ** Declarations **
'------------------------------------------------------------------------------
DECLARE CALLBACK FUNCTION ShowdlgMLG_liteProc()
DECLARE FUNCTION ShowdlgMLG_lite(BYVAL hParent AS DWORD) AS LONG
#PBFORMS DECLARATIONS
'------------------------------------------------------------------------------

'------------------------------------------------------------------------------
'   ** Main Application Entry Point **
'------------------------------------------------------------------------------
FUNCTION PBMAIN()
  PBFormsInitComCtls (%ICC_WIN95_CLASSES OR %ICC_DATE_CLASSES OR _
    %ICC_INTERNET_CLASSES)

  MLG_Init  ' initialise the grid control

  ShowdlgMLG_lite %HWND_DESKTOP
END FUNCTION
'------------------------------------------------------------------------------

'------------------------------------------------------------------------------
'   ** CallBacks **
'------------------------------------------------------------------------------
CALLBACK FUNCTION ShowdlgMLG_liteProc()
'
  LOCAL MLGN AS MyGridData PTR     ' set up the grid pointer
  LOCAL mycol AS LONG              ' grid column number
  LOCAL myrow AS LONG              ' grid row number
  LOCAL strText AS STRING          ' generic text string
  LOCAL myitem AS LONG             ' number of menu item clicked
  LOCAL lngClipResult AS LONG      ' result of copying to the clipboard
  LOCAL lngSourceColumn AS LONG    ' source column for conditional user buttons
  LOCAL lngColumn AS LONG          ' target column for conditional user buttons
  '
  LOCAL lngRows AS LONG            ' total rows in grid
  LOCAL strFolder AS STRING        ' folder selected to load
  LOCAL lngFlags AS LONG           ' Flags for folder browse
  '
  SELECT CASE AS LONG CB.MSG
    ' /* Inserted by PB/Forms 03-18-2022 22:21:41
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
    '
      lngRows = funGetRowsInGrid(hGrid1)
      FOR myRow = 1 TO lngRows
        funSetRowHeight(hGrid1,myRow,50)
      NEXT myRow
      '
    CASE %WM_NOTIFY
      MLGN = CB.LPARAM   ' pick up msg dependant value
      SELECT CASE @MLGN.NMHeader.idFrom
      ' which dialog control did this notification
      ' come from?
        CASE %IDC_MLGGRID1
        ' if it's the grid
          SELECT CASE @MLGN.NMHeader.code
          ' which grid event has happened?
            CASE %MLGN_USERBUTTON
            ' a user button has been clicked
            ' pick up the row and column that
            ' has been clicked on
              mycol=@MLGN.Param2
              myrow=@MLGN.Param1
              strText = MLG_Get(hGrid1,myrow,mycol)
              '
              MSGBOX "You have clicked on " & $CRLF & _
                     "Row " & FORMAT$(myrow) & $CRLF & _
                     "Column " & FORMAT$(mycol) & $CRLF & _
                     "Text is " & strText, _
                     %MB_ICONINFORMATION OR %MB_TASKMODAL , _
                     "User Button Info"
            '
            CASE %MLGN_RCLICKMENU
            ' user has right clicked and opened a menu
              myitem=@MLGN.Param3  ' Menu Item number
              mycol=@MLGN.Param2   ' column number
              myrow=@MLGN.Param1   ' row number
              '
              SELECT CASE myitem
                CASE 1
                ' Sort by column ascending
                  SendMessage hGrid1,%MLG_SORT, %MLG_ASCEND , mycol
                  funGridRefresh(hGrid1)
                  '
                CASE 2
                ' Sort by column descending
                  SendMessage hGrid1,%MLG_SORT, %MLG_DESCEND , mycol
                  funGridRefresh(hGrid1)
                  '
                CASE 3
                ' this is the divider bar
                CASE 4
                ' copy cell to the clipboard
                  strText = MLG_Get(hGrid1,myrow,mycol)
                  CLIPBOARD RESET
                  CLIPBOARD SET TEXT strText, lngClipResult
                  '
              END SELECT
              '
          END SELECT
      END SELECT
    '
    CASE %WM_COMMAND
      ' Process control notifications
      SELECT CASE AS LONG CB.CTL
        CASE %IDABORT
          IF CB.CTLMSG = %BN_CLICKED OR CB.CTLMSG = 1 THEN
          ' exit application
            DIALOG END CB.HNDL
          END IF
          '
        CASE %ID_Load
        ' loading libraries
          lngFlags = %BIF_NONEWFOLDERBUTTON
          DISPLAY BROWSE CB.HNDL, , , "Select the folder to search", _
                                 EXE.PATH$, lngFlags _
                                 TO strFolder
          IF strFolder <> "" THEN
          ' folder has been selected
            funLoadLibraries(strFolder, hGrid1)
          END IF
        '
      END SELECT
  END SELECT
END FUNCTION
'------------------------------------------------------------------------------
FUNCTION funLoadLibraries(strFolder AS STRING, _
                          hGrid AS DWORD) AS LONG
' search for INC files in this folder
  DIM a_strLibraries(1 TO %Max_Libraries) AS DIRDATA
  DIM a_strFile() AS STRING
  '
  LOCAL lngX AS LONG
  LOCAL lngR AS LONG
  LOCAL lngC AS LONG
  LOCAL lngLine AS LONG
  LOCAL strFilename AS STRING
  LOCAL strData AS STRING
  LOCAL strType AS STRING          ' type Function or Sub
  LOCAL strName AS STRING          ' name of func or sub
  '
  LOCAL strDescription AS STRING   ' description of routine
  LOCAL lngCount AS LONG
  DIM a_strGrid(1000,5) AS STRING  ' data to update on grid
  DIM a_strGridOutput() AS STRING  ' Grid for output
  '
  lngX = 1
  '
  strFilename = DIR$(strFolder & "\*.INC", TO a_strLibraries(lngX))
  WHILE LEN(strFilename) AND lngX < %Max_Libraries
    INCR lngX
    strFilename = DIR$(NEXT, TO a_strLibraries(lngX) )
  WEND
  '
  ' Array now holds the list
  FOR lngX = 1 TO UBOUND(a_strLibraries)
  ' load each file
    strFilename = a_strLibraries(lngX).FileName
    IF ISTRUE funReadTheFileIntoAnArray(strFolder & "\" & strFilename, _
                                   BYREF a_strFile()) THEN
      ' Look at each row in the file
      FOR lngR = 0 TO UBOUND(a_strFile)
      ' for each data row in the file
      ' pick up the row
        strData = TRIM$(a_strFile(lngR))
        ' if it's a comment just skip past it
        IF LEFT$(strData,1) = "'" THEN ITERATE
        '
        ' look for Functions and Subroutines and Macros
        IF LEFT$(strData,9) = "FUNCTION " OR _
           LEFT$(strData,4) = "SUB " OR _
           LEFT$(strData,6) = "MACRO " THEN
        ' found a data line
        '
          ' check for function return and skip past
          IF INSTR(strData,"=") > 0 THEN ITERATE
          '
          ' pick up the type of routine and name
          strType = PARSE$(strData," ",1)
          strName = PARSE$(strData,ANY " (",2)
          '
          ' is there a description?
          ' look for next comment
          strDescription = ""
          FOR lngLine = 1 TO 10
          ' look for a description somewhere
          ' in the next 10 lines of code
            IF LEFT$(TRIM$(a_strFile(lngR + lngLine)),1) = "'" THEN
            ' got a description line
              strDescription = TRIM$(a_strFile(lngR + lngLine))
              EXIT FOR
            END IF
          NEXT lngLine
          '
          INCR lngCount  ' advance the counter
          ' and populated the grid
          PREFIX "a_strGrid(lngCount,"
            1) = strType
            2) = strName
            3) = FORMAT$(lngR+1)
            4) = strFilename
            5) = strDescription
          END PREFIX
          '
        END IF
        '
      NEXT lngR
      '
      ' prepare a grid of right size
      REDIM a_strGridOutput(lngCount,5)
      FOR lngR = 1 TO lngCount
      ' populate it with data
        FOR lngC = 1 TO 5
          a_strGridOutput(lngR,lngC) = a_strGrid(lngR,lngC)
        NEXT lngC
      NEXT lngR
      '
      ' put the data into the grid now
      MLG_PUTex(hGrid,a_strGridOutput(),-4,1)
      FOR lngR = 1 TO UBOUND(a_strGridOutput)
      ' word wrap the description
        SendMessage hGrid ,%MLG_SETFORMATOVERRIDEEX ,_
                    MAKLNG(lngR,5), _
                    MAKLNG(%MLG_TYPE_JUST,%MLG_JUST_WORDWRAP)
      NEXT lngR
      '
    END IF
  NEXT lngX
  '
  ' colour alternate rows for readability
  funColourBankGridRows(hGrid1,%RGB_LIGHTGREEN)
  ' and refresh the grid on screen
  funGridRefresh(hGrid1)
'
END FUNCTION

'------------------------------------------------------------------------------
'   ** Dialogs **
'------------------------------------------------------------------------------
FUNCTION ShowdlgMLG_lite(BYVAL hParent AS DWORD) AS LONG
  LOCAL lRslt AS LONG

#PBFORMS BEGIN DIALOG %IDD_dlgMLG_lite->->
  LOCAL hDlg  AS DWORD

  DIALOG NEW hParent, "MLG Lite Code Library", 202, 260, 720, 360, %WS_POPUP OR %WS_BORDER _
    OR %WS_DLGFRAME OR %WS_CAPTION OR %WS_SYSMENU OR %WS_MINIMIZEBOX OR _
    %WS_MAXIMIZEBOX OR %WS_CLIPSIBLINGS OR %WS_VISIBLE OR %DS_MODALFRAME OR _
    %DS_CENTER OR %DS_3DLOOK OR %DS_NOFAILCREATE OR %DS_SETFONT, _
    %WS_EX_CONTROLPARENT OR %WS_EX_LEFT OR %WS_EX_LTRREADING OR _
    %WS_EX_RIGHTSCROLLBAR, TO hDlg
  CONTROL ADD BUTTON, hDlg, %IDABORT, "Exit", 615, 330, 50, 15
#PBFORMS END DIALOG
  '
   CONTROL ADD TOOLBAR, hDlg, %MainToolbar, "", 0, 0, 0, 0, _
        %WS_CHILD OR %WS_VISIBLE OR %WS_TABSTOP OR %CCS_TOP OR _
        %TBSTYLE_FLAT
 ' add the icons and buttons to the blank toolbar
  CreateToolbar hDlg, %MainToolbar
  '

  ' Set the dimensions of the grid
  LOCAL lngGridX, lngGridY AS LONG
  LOCAL lngGridWidth, lngGridHeight AS LONG
  lngGridX = 10
  lngGridY = 45
  lngGridWidth = 700
  lngGridHeight = 280
  '
  ' Set the options in the right click menu for the grid
  LOCAL strMenu AS STRING
  strMenu = "/m1Sort column ascending," & _
             "Sort column descending," & _
             "-," & _
             "Copy cell to Clipboard"
  '
  ' add the grid control
  CONTROL ADD "MYLITTLEGRID", hDlg, %IDC_MLGGRID1, _
          $ColumnWidths & "/d-0/e1/r" & FORMAT$(%MaxGridRows) & _
          strMenu & "/c" & _
          FORMAT$(%MaxGridColumns) & "/a2/y3", _
          lngGridX, lngGridY, lngGridWidth, lngGridHeight, %MLG_STYLE
  '
  ' capture the windows handle to the grid
  CONTROL HANDLE hDlg, %IDC_MLGGRID1 TO hGrid1
  '
  ' prepare the grid with tab/sheet number 1 as Demo Grid
  mPrepGrid(hGrid1,%MaxGridRows,%MaxGridColumns," Demo grid ", 1)
  '
  ' set the names of each column
  funSetColumnNames(hGrid1,$ColumnNames)
  '
  ' Center and lock the Line column
  LOCAL lngColumn AS LONG
  lngColumn = funGetColumnNumber(hGrid1,"Line")
  funFormatColumn(hGrid1,lngColumn,"CENTER",%BLUE,"LOCK")
  '

  '
  DIALOG SET ICON hDlg, "TB_ID_Load"
  DIALOG SHOW MODAL hDlg, CALL ShowdlgMLG_liteProc TO lRslt

#PBFORMS BEGIN CLEANUP %IDD_dlgMLG_lite
#PBFORMS END CLEANUP

  FUNCTION = lRslt
END FUNCTION
'------------------------------------------------------------------------------
'FUNCTION funLoadTheData(hGrid AS DWORD) AS LONG
'  DIM a_strData() AS STRING
'  LOCAL lngRefresh AS LONG
'  LOCAL lngOption AS LONG
'  '
'  IF ISTRUE funReadTheCSVFileIntoAnArray(EXE.PATH$ & $DataFile, _
'                                         BYREF a_strData()) THEN
'    ' populate the grid with the contents of the array
'    lngRefresh = 1 ' refresh the grid once done
'    lngOption = -2
'    '1 then replace the grid with array data only if nothing
'    '  is out of bounds
'    '2 then do not write over column headers
'    '3 then do not write over row headers
'    '4 then do not write over row or column headers
'    'If op is negative then resize the grid to fit the array
'    MLG_PutEX(hGrid,a_strData(),lngOption,lngRefresh)
'  END IF
'  '
'END FUNCTION
