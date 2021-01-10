'いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい
'    My Little Grid -- MLGDemo by James Klutho
'    Printing and Infobar Demo
'    Demo all the notifications and Cell types
'いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい
#COMPILE EXE

#INCLUDE "WIN32API.INC" 'PB's win API declares include file
#INCLUDE "MLG.INC"

%IDC_MLGGRID1 = 101
%IDC_MLGLIST1 = 500

%ID_PAGESETUP = 100
%ID_PREVIEW = 200
%ID_PRINTAREA = 300
%ID_PRINT = 400
%ID_EXIT  = 500
%ID_SHOWINFOBAR = 600
%ID_HIDEINFOBAR = 700

GLOBAL hGrid1 AS DWORD
GLOBAL hList1 AS DWORD
GLOBAL sheet1,sheet2,sheet3 AS LONG
GLOBAL MyCountFlag,MySumFlag,MyAverageFlag AS LONG
GLOBAL PrintAreaRect,RepeatRowsColsRect AS RECT

'--------------------------------------------------------------------
DECLARE CALLBACK FUNCTION ShowOneGridProc()
DECLARE FUNCTION ShowOneGrid(hDlg AS LONG) AS LONG


'いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい
' PBMAIN - load and show a dialog
'いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい

FUNCTION PBMAIN() AS LONG
     LOCAL result AS LONG
     result=ShowOneGrid(0)
END FUNCTION


'いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい
' Routine to post notifications in a listbox
'いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい


SUB list(s AS STRING)
  LOCAL test AS ASCIIZ * 256
  STATIC COUNT AS LONG
  LOCAL s5 AS STRING * 5

  INCR COUNT
  s5 = STR$(COUNT)
  test="Notification # "+ s5 + ":" + s
  SendMessage(hList1,%LB_INSERTSTRING,0,VARPTR(test))
END SUB


'いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい
' Dialog for 1 Grid  Resizeable
'いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい


FUNCTION ShowOneGrid(hDlg AS LONG) AS LONG
  LOCAL myrow,mycol,x,y,z,counter AS LONG
  LOCAL hMenu,hPopup1 AS LONG
  LOCAL MyNum AS DOUBLE
  LOCAL zstr AS ASCIIZ * 260
  LOCAL a AS ASCIIZ * 255
  LOCAL szBuffer AS ASCIIZ * 260

  MLG_Init
  DIALOG NEW 0, "Printing Example",,, 520, 370, %WS_SYSMENU OR %WS_THICKFRAME TO hDlg

  MENU NEW BAR TO hMenu
  MENU NEW POPUP TO hPopup1
  MENU ADD POPUP, hMenu, "File", hPopup1, %MF_ENABLED


  MENU ADD STRING, hPopup1, "Show Info Bar", %ID_SHOWINFOBAR, %MF_ENABLED
  MENU ADD STRING, hPopup1, "Hide Info Bar", %ID_HIDEINFOBAR, %MF_ENABLED
  MENU ADD STRING, hPopup1, "-", 0, 0
  MENU ADD STRING, hPopup1, "Set Print Area", %ID_PRINTAREA, %MF_ENABLED
  MENU ADD STRING, hPopup1, "Page Setup ...", %ID_PAGESETUP, %MF_ENABLED
  MENU ADD STRING, hPopup1, "Print ...", %ID_PRINT, %MF_ENABLED
  MENU ADD STRING, hPopup1, "Print Preview", %ID_PREVIEW, %MF_ENABLED
  MENU ADD STRING, hPopup1, "-", 0, 0
  MENU ADD STRING, hPopup1, "Exit", %ID_EXIT, %MF_ENABLED
  MENU ATTACH hMenu, hDlg
  'Switches
  'e3 means tell MLG to auto append a row if needed providing something is in the cell
  'r50 calls for 50 rows total
  'c8 calls for 8 columns
  'b3 means block selecting of rows, columns, and the entire grid is activated
  'm1 active the right click menu with the following comma delimited menu items

  'v2 is new to 2.07 is the vertical justification with 2 being vcentered

  CONTROL ADD "MYLITTLEGRID", hDlg, %IDC_MLGGRID1, "v2/y3/z1/f3/s10/r500/c18/b3/m1First,Second,Third/m3Count,Sum,Average", 4, 4, 510, 348, %MLG_STYLE
  CONTROL HANDLE hDlg, %IDC_MLGGRID1 TO hGrid1

  CONTROL ADD LISTBOX, hDlg, %IDC_MLGLIST1, , 4, 175, 250, 150,%WS_VSCROLL OR %LBS_NOTIFY ,%WS_EX_CLIENTEDGE
  CONTROL HANDLE hDlg, %IDC_MLGLIST1 TO hList1

   MLG_SetDefaultGridFont hGrid1,"Tahoma",12,2         'Default

   FOR counter = 1 TO 2
          z=SendMessage(hGrid1, %MLG_ADDSHEET, 0,0)
          IF z=0 THEN EXIT FOR
   NEXT counter

   SendMessage hGrid1, %MLG_SELECTSHEET, 2,0 'Second Sheet

     SendMessage hGrid1 ,%MLG_SETFORMATOVERRIDEEX ,MAKLNG(6,1),MAKLNG(%MLG_TYPE_USING,%MLGSYSFONTNORMVERT)
     SendMessage hGrid1 ,%MLG_SETFORMATOVERRIDEEX ,MAKLNG(6,2),MAKLNG(%MLG_TYPE_USING,%MLGSYSFONTNORMVERT)
     MLG_Put(hGrid1,6,1,"Chris",0,0)
     MLG_Put(hGrid1,6,2,"Crystal",0,0)
     SendMessage hGrid1 ,%MLG_SETROWHEIGHT ,6,70

     szBuffer="MyTest,Test1,Test2,Test3,Test4"
     SendMessage hGrid1 ,%MLG_ADDFORMATOVERRIDELIST,1,VARPTR(szBuffer)
     SendMessage hGrid1 ,%MLG_SETFORMATOVERRIDEEX ,MAKLNG(14,3),MAKLNG(%MLG_TYPE_CELLTYPE,%MLG_TYPE_COMBOSTATIC)
     SendMessage hGrid1 ,%MLG_SETFORMATOVERRIDEEX ,MAKLNG(14,3),MAKLNG(%MLG_TYPE_USING,1)
     MLG_Put(hGrid1,14,3,"Test4",0,0)

     SendMessage hGrid1 ,%MLG_SETFORMATOVERRIDEEX ,MAKLNG(14,4),MAKLNG(%MLG_TYPE_CELLTYPE,%MLG_TYPE_CHECKBOX)

   SendMessage hGrid1 ,%MLG_SETFORMATOVERRIDEEX ,MAKLNG(4,4),MAKLNG(%MLG_TYPE_BKGCOLOR,%CELLCOLORLIGHTBLUE)
   SendMessage hGrid1, %MLG_SETMERGECELLS, MAKLNG(4,4),MAKLNG(4,5)
   SendMessage hGrid1 ,%MLG_SETFORMATOVERRIDEEX ,MAKLNG(4,4),MAKLNG(%MLG_TYPE_JUST,%MLG_JUST_CENTER)
   MLG_Put(hGrid1,4,4,"Merge",0,0)

   SendMessage hGrid1, %MLG_SETMERGECELLS, MAKLNG(1,1),MAKLNG(5,2)
   SendMessage hGrid1 ,%MLG_SETFORMATOVERRIDEEX ,MAKLNG(1,1),MAKLNG(%MLG_TYPE_JUST,%MLG_JUST_WORDWRAP)
   MLG_PUT hGrid1,1,1,"This is a demo of MLG 3.0 merged wrapped cells.",0

   PrintAreaRect.nTop=1
   PrintAreaRect.nLeft=1
   PrintAreaRect.nBottom=15
   PrintAreaRect.nRight=6
   SendMessage hGrid1, %MLG_SETPRINTAREA,VARPTR(PrintAreaRect),0
  '--------------------------------------------------------------------------------------------


   SendMessage hGrid1, %MLG_SELECTSHEET, 3,0 'Third Sheet

   PrintAreaRect.nTop=2
   PrintAreaRect.nLeft=3
   PrintAreaRect.nBottom=150
   PrintAreaRect.nRight=5
   'User can alter Repeat Rows and Cols (up to 4 each) by 1) selecting entire row block, 2) selecting the menu item "Set Print Area" while holding down shift key
   RepeatRowsColsRect.nTop=1
   RepeatRowsColsRect.nLeft=0
   RepeatRowsColsRect.nBottom=1
   RepeatRowsColsRect.nRight=0
   SendMessage hGrid1, %MLG_SETPRINTAREA,VARPTR(PrintAreaRect),VARPTR(RepeatRowsColsRect)

   MLG_Put(hGrid1,1,3,"Column 1",0,0)
   MLG_Put(hGrid1,1,4,"Column 2",0,0)
   MLG_Put(hGrid1,1,5,"Column 3",0,0)

   FOR y = 2 TO 150
     FOR x = 3 TO 5
        MyNum = RND(1,2000)
        MLG_PUT hGrid1,y,x,FORMAT$(MyNum,"0.00"),0
     NEXT x
  NEXT y


   '-------------------------------------------------------------------------------------------------------------
   SendMessage hGrid1, %MLG_SELECTSHEET, 1,0 'Reselect the original tab
   SendMessage hGrid1, %MLG_SHOWSHEETTABS,300,0

   SendMessage hGrid1, %MLG_SETCOLWIDTH, 1, 70
   SendMessage hGrid1, %MLG_SETCOLWIDTH, 2, 120
   SendMessage hGrid1, %MLG_SETCOLWIDTH, 3, 100
   SendMessage hGrid1, %MLG_SETCOLWIDTH, 4, 130

   MLG_FormatColEdit hGrid1,7,%MLG_NULL,%MLG_NULL,%MLG_NULL,%RED,%MLG_LOCK

   SendMessage hGrid1, %MLG_REFRESH, 0,0

   MLG_FormatCellFont hGrid1,2,2,2,4,4
   MLG_FormatCellFont hGrid1,5,5,7
   MLG_FormatCellBgndColor hGrid1,0,3,%CELLCOLORLIGHTBLUE
   MLG_FormatCellBgndColor hGrid1,145,2,%CELLCOLORLIGHTBLUE
   MLG_FormatCellTextColor hGrid1,5,5,%CELLCOLORRED
   MLG_FormatCellBorder hGrid1,8,2,%MLG_OUTLINE,12,4


     'Get the sheetID for the three sheets
     sheet1=SendMessage(hGrid1, %MLG_GETSHEETINFO, %MLG_SHEET_GETID,1)
     sheet2=SendMessage(hGrid1, %MLG_GETSHEETINFO, %MLG_SHEET_GETID,2)
     sheet3=SendMessage(hGrid1, %MLG_GETSHEETINFO, %MLG_SHEET_GETID,3)



     a="Main" : SendMessage hGrid1, %MLG_NAMESHEET , 1,VARPTR(a)
     a="Stuff" : SendMessage hGrid1, %MLG_NAMESHEET , 2,VARPTR(a)
     a="Repeat Rows" : SendMessage hGrid1, %MLG_NAMESHEET , 3,VARPTR(a)



    '-------------------------------

   MLG_SetGridFont hGrid1,"Tahoma",12,7,"b"   'facename,fontsize,slot,style
   SendMessage hGrid1 ,%MLG_SETCALLBACK,%MLG_INFOBARCALLBACK,CODEPTR(InfoBarCallback)
   SendMessage hGrid1 ,%MLG_SETROWHEIGHT,0,100   ' move height of row and col header text vertically
   MLG_SetPrintOptions(hGrid1,%MLG_PRINT_SHOWNOROWANDCOLHEADERS,%MLG_PRINT_DOWNTHENACROSS,%MLG_PRINTNOCENTERING,%MLG_PRINT_SHOWGRIDLINES)
   MLG_SetPrintHeaderFooter(hGrid1,"[PAGE]" + $TAB + "My Report" + $TAB + "[TIME]","ABC Corp" + $TAB + "Acme Div" + $TAB + "[DATE]")


   'Set the Print Area of the Main tab.  Print Area can be altered by user selecting a block of wells and selecting the menu item "Set Print Area"
   PrintAreaRect.nTop=1
   PrintAreaRect.nLeft=1
   PrintAreaRect.nBottom=300
   PrintAreaRect.nRight=15
   SendMessage hGrid1, %MLG_SETPRINTAREA,VARPTR(PrintAreaRect),0

   '-------------------------------

  FOR y = 1 TO 500
     FOR x = 1 TO 18
        MyNum = RND(1,2000)
        MLG_PUT hGrid1,y,x,FORMAT$(MyNum,"0.00"),0
     NEXT x
  NEXT y

  '-------------------------------------
  SendMessage hGrid1, %MLG_ALTERATTRIBUTE, %MLG_PRINTMILLIMETERS,1
  SendMessage hGrid1, %MLG_ALTERATTRIBUTE, %MLG_TOPINFOBAR,1
  zstr = ""
  SendMessage hGrid1, %MLG_SETINFOBARTEXT,VARPTR(zstr) ,MAKLNG(MAKWRD(%MLG_JUST_RIGHT,%MLGSYSFONTTABBOLD),MAKWRD(1,1))


   DIALOG SHOW MODAL hDlg CALL ShowOneGridProc

END FUNCTION

CALLBACK FUNCTION Infobarcallback()

    LOCAL MyStr AS ASCIIZ * 256
    LOCAL MyStrPtr AS LONG
    LOCAL rc,pa,prc AS RECT
    LOCAL NonBlankCount,x,y,a,DimRows,DimCols AS LONG
    LOCAL MySum,MyAve AS DOUBLE

    MyStrPtr = VARPTR(MyStr)

    SendMessage (CBHNDL,%MLG_GETMULTICELLSELECTION,VARPTR(rc),0)

    FOR x=Rc.nLeft TO Rc.nRight
       FOR y=Rc.nTop TO rc.nBottom
         IF LEN(MLG_GET(CBHNDL,y,x)) > 0 THEN INCR NonBlankCount
         MySum = MySum + VAL(MLG_GET(CBHNDL,y,x))
         IF NonBlankCount > 0 THEN MyAve = MySum/NonBlankCount
       NEXT y
    NEXT x
   '
    MyStr = ""
    IF MyCountFlag <> 0 THEN MyStr = MyStr + "   Count = " + STR$(NonBlankCount) + "    "
    IF MySumFlag <> 0 THEN  MyStr = MyStr + "   Sum = " + FORMAT$(MySum,"0.00")  + "    "
    IF MyAverageFlag <> 0 THEN MyStr = MyStr + "  Average = " + FORMAT$(MyAve,"0.000")
    MyStrPtr = VARPTR(MyStr)
    CopyMemory CBLPARAM,MyStrPtr,256

END FUNCTION

'いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい
' Dialog procedure for 1 Grid  Resizeable
'いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい
CALLBACK FUNCTION ShowOneGridProc()
  LOCAL I AS LONG
  LOCAL J AS LONG
  LOCAL K AS LONG
  LOCAL myrow AS LONG
  LOCAL oldrow AS LONG
  LOCAL mycol AS LONG
  LOCAL oldcol AS LONG
  LOCAL myitem AS LONG
  LOCAL mytype AS LONG
  LOCAL mystart AS LONG
  LOCAL myend AS LONG
  LOCAL mychar AS LONG
  LOCAL mytotalrows AS LONG
  LOCAL mytotalcols AS LONG
  LOCAL s AS STRING
  LOCAL result AS LONG
  LOCAL myget AS STRING
  LOCAL hMenu AS LONG
  LOCAL hEdit AS LONG
  LOCAL MLGN AS MyGridData PTR
  LOCAL zstr AS ASCIIZ * 260

  SELECT CASE CBMSG
      CASE %WM_INITDIALOG
        hMenu=SendMessage(hGrid1, %MLG_GETMENUHANDLE, 2, 0)
        MENU SET STATE hMenu, 1, %MF_CHECKED : MyCountFlag = 1
        MENU SET STATE hMenu, 2, %MF_CHECKED : MySumFlag = 1
        MENU SET STATE hMenu, 3, %MF_CHECKED : MyAverageFlag = 1

     CASE %WM_PAINT
        CONTROL REDRAW CBHNDL, %IDC_MLGGRID1

     CASE %WM_SIZE
        DIALOG GET SIZE CBHNDL TO I, J
        CONTROL SET SIZE CBHNDL,%IDC_MLGGRID1, I-14, J - 112 'J-96
        CONTROL SET SIZE CBHNDL,%IDC_MLGLIST1, I-20, 65
        CONTROL SET LOC CBHNDL,%IDC_MLGLIST1, 4, J-100

     CASE %WM_COMMAND
         SELECT CASE CB.CTL
            CASE %ID_PRINT
                SendMessage hGrid1, %MLG_PRINT, 1,0 ' Print Dialog

            CASE %ID_PAGESETUP
                SendMessage hGrid1, %MLG_PAGESETUP, 0,0

            CASE %ID_PREVIEW
               SendMessage hGrid1, %MLG_PRINTPREVIEW, 0,0

            CASE %ID_PRINTAREA
               SendMessage hGrid1, %MLG_SETPRINTAREA, 0,0

           CASE %ID_SHOWINFOBAR
               SendMessage hGrid1, %MLG_ALTERATTRIBUTE, %MLG_TOPINFOBAR,1
               zstr = ""
               SendMessage hGrid1, %MLG_SETINFOBARTEXT,VARPTR(zstr) ,MAKLNG(MAKWRD(%MLG_JUST_RIGHT,%MLGSYSFONTTABBOLD),MAKWRD(1,1))
               SendMessage hGrid1, %MLG_REFRESH, 0,0

           CASE %ID_HIDEINFOBAR
               SendMessage hGrid1, %MLG_ALTERATTRIBUTE,%MLG_TOPINFOBAR,0
               SendMessage hGrid1, %MLG_REFRESH, 0,0

           CASE %ID_EXIT
               DIALOG END CB.HNDL, 0
         END SELECT

     CASE %WM_NOTIFY
         MLGN=CBLPARAM
         IF @MLGN.NMHeader.idFrom = %IDC_MLGGRID1 THEN
             SELECT CASE @MLGN.NMHeader.code

                    CASE %MLGN_RETURN
                         myrow=@MLGN.Param1 'current row
                         mycol=@MLGN.Param2 'current col
                         s="Column " + STR$(mycol) + " Row " + STR$(myrow) + " Return key was pressed. " : list s

                    CASE %MLGN_DELETE
                         myrow=@MLGN.Param1 'current row
                         mycol=@MLGN.Param2 'current col
                         s="Column " + STR$(mycol) + " Row " + STR$(myrow) + " Delete key was pressed. " : list s

                    CASE %MLGN_TAB
                         myrow=@MLGN.Param1 'current row
                         mycol=@MLGN.Param2 'current col
                         s="Column " + STR$(mycol) + " Row " + STR$(myrow) + " Tab key was pressed. " : list s

                    CASE %MLGN_CHARPRESSED ' FUNCTION=1 to abort inserting character
                         hEdit=@MLGN.Param4   ' the edit box handle - for inserting char and testing result string
                         mychar=@MLGN.Param3  ' Char
                         mycol=@MLGN.Param2   ' current col
                         myrow=@MLGN.Param1   'current row
                         s="Column " + STR$(mycol) + " Row " + STR$(myrow) + " Character " + CHR$(mychar) + " was pressed." : list s

                    CASE %MLGN_ESCAPEPRESSED
                         myrow=@MLGN.Param1 'current row
                         mycol=@MLGN.Param2 'current col
                         s="Column " + STR$(mycol) + " Row " + STR$(myrow) + " Escape key was pressed. " : list s

                    CASE %MLGN_ROWDIRTY
                         myrow=@MLGN.Param1        'previous row
                         s=" Row " + STR$(myrow) + " This previous row may need to be saved. " : list s

                    CASE %MLGN_CELLDIRTY
                         myrow=@MLGN.Param1 'previous row
                         mycol=@MLGN.Param2 'previous col
                         s="Column " + STR$(mycol) + " Row " + STR$(myrow) + " This previous cell may need to be saved. " : list s

                    CASE %MLGN_ROWALTERED
                         myrow=@MLGN.Param1 'current row
                         mycol=@MLGN.Param2 'current col
                         s="Column " + STR$(mycol) + " Row " + STR$(myrow) + " row was altered by this cell. " : list s

                    CASE %MLGN_CELLALTERED
                         myrow=@MLGN.Param1 'current row
                         mycol=@MLGN.Param2 'current col
                         s="Column " + STR$(mycol) + " Row " + STR$(myrow) + " cell was altered. " : list s

                    CASE %MLGN_DATEPROBLEM
                         myrow=@MLGN.Param1 'previous row where the problem occured
                         mycol=@MLGN.Param2 'previous col where the problem occured
                         s="Column " + STR$(mycol) + " Row " + STR$(myrow) + "; MLG made some alterations to the date. " : list s

                    CASE %MLGN_CHECKCHANGED
                          mychar=@MLGN.Param3  'before toggle - if contained 255 then was unselected else should have contained 1 which was previously selected
                          mycol=@MLGN.Param2   ' Column of check change
                          myrow=@MLGN.Param1          ' Row of check change
                          s="Column " + STR$(mycol) + " Row " + STR$(myrow) + " checkbox toggled from " + STR$(mychar) : list s

                    CASE %MLGN_COMBOCHANGED    'this message is sent on both a dropdown and dismiss of the list
                         myrow=@MLGN.Param1 'current col
                         mycol=@MLGN.Param2 'current col
                         s="Column " + STR$(mycol) + " Row " + STR$(myrow) + "; had combobox activity" : list s

                    CASE %MLGN_COLWIDTHCHANGED
                         I=@MLGN.Param1     ' New Width
                         mycol=@MLGN.Param2 ' Column of Mouse
                         s="Column " + STR$(mycol) + " has Change Width to " + STR$(I) : list s

                    CASE %MLGN_SELCHANGE       'sent after a cell has moved
                         myrow=@MLGN.Param1 'previous row
                         mycol=@MLGN.Param2 'previous col
                         s="Previous Column " + STR$(mycol) + " Previous Row " + STR$(myrow) + " Cell selection has changed. " : list s

                    CASE %MLGN_ROWCHANGE       'sent after a cell has moved
                         myrow=@MLGN.Param1 ' row
                         oldrow=@MLGN.Param2'previous row
                         s="Current Row " + STR$(myrow) + " Previous Row " + STR$(oldrow) + " Row selection has changed. Load Record?" : list s

                    CASE %MLGN_ROWSELCHANGE      'sent after buttonup if whole row/rows selected
                         mystart=@MLGN.Param1 'start row
                         myend=@MLGN.Param2   'end row
                         s="Start Row " + STR$(mystart) + " End Row " + STR$(myend) + " Block selection of rows has changed. " : list s

                    CASE %MLGN_COLSELCHANGE      'sent after buttonup if whole col/cols selected
                         mystart=@MLGN.Param1 'start col
                         myend=@MLGN.Param2   'end col
                         s="Start Column " + STR$(mystart) + " End Column " + STR$(myend) + " Block selection of columns has changed. " : list s

                    CASE %MLGN_ROWCOLALLBLOCKSEL
                         mytotalrows=@MLGN.Param1 'total rows
                         mytotalcols=@MLGN.Param2 'total cols
                         s="Total grid has been block selected.  Total columns= " + STR$(mytotalcols) + " and total rows= " + STR$(mytotalrows) + ". " : list s

                    CASE %MLGN_REDIMFAILED
                        'An automatic append fail
                         I=@MLGN.Param1 'What was the calling point for the problem 1 = PutEX, 2=auto row append, remainder are insert messages
                         J=@MLGN.Param2 'Error codes 1 to 13; Check include file for detail
                         s="A redimensioning of the data memory has failed." : list s

                    CASE %MLGN_WANTNEWREC
                         mytotalrows=@MLGN.Param1   'current total rows before record is append to bottom
                                                 'after a validation can elect to skip append with the %MLG_SETSKIPRECFLAG message
                         s="A row has just been asked to be auto-appended. Total rows are currently " + STR$(mytotalrows) : list s

                    CASE %MLGN_MADENEWREC
                         mytotalrows=@MLGN.Param1    'current total rows after record is append to bottom
                         s="A row has just been auto-appended.  Total rows now are " + STR$(mytotalrows) : list s

                    CASE %MLGN_REPEATROWSSET
                         mystart=@MLGN.Param1    '
                         myend=@MLGN.Param3      '
                         s="User has just set print repeating rows" + STR$(mystart) + " to" + STR$(myend) : list s

                    CASE %MLGN_REPEATCOLUMNSSET
                         mystart=@MLGN.Param2    '
                         myend=@MLGN.Param4      '
                         s="User has just set print repeating columns " + STR$(mystart) + " to" + STR$(myend) : list s

                    CASE %MLGN_PRINTAREASET
                         oldrow=@MLGN.Param1  ' top
                         oldcol=@MLGN.Param2  ' left
                         myrow=@MLGN.Param3   ' bottom
                         mycol=@MLGN.Param4   ' right
                         s="User has just set the print area" : list s

                    CASE %MLGN_PRINTPREVIEWMESSAGE
                         s="Hello from the Print Preview DLL" : list s

                    CASE %MLGN_RIGHTCLICK      'sent after a right click has occur.  Make Menu modifications if necessary
                         myrow=@MLGN.Param1 ' row
                         mycol=@MLGN.Param2 ' col
                         s="Current Column " + STR$(mycol) + " Current Row " + STR$(myrow) + " Right click has occured. " : list s

                    CASE  %MLGN_SELECTEDCELLLOCKED 'allows user to take action if a locked cell is selected
                         oldrow=@MLGN.Param1  '
                         oldcol=@MLGN.Param2  '
                         myrow=@MLGN.Param3   ' current row
                         mycol=@MLGN.Param4   ' current col

                         s="Current Column " + STR$(mycol) + " Current Row " + STR$(myrow) + " is locked. " : list s
                         IF mycol = 7 THEN
                           SendMessage hGrid1, %MLG_SETSELECTED, myrow,6
                         END IF

                    CASE %MLGN_RCLICKINFOBARMENU
                         myitem=@MLGN.Param3  ' Menu Item
                         mycol=@MLGN.Param2   ' Column of Mouse
                         myrow=@MLGN.Param1   ' Row of Mouse
                         s="Item " + STR$(myitem) + " On the Infobar Menu. " : list s

                         hMenu=SendMessage(hGrid1, %MLG_GETMENUHANDLE, 2, 0)
                         IF myitem=1 AND hMenu > 0 THEN
                           MENU GET STATE hMenu, 1 TO I
                           IF I= %MF_CHECKED THEN
                             MENU SET STATE hMenu, 1, %MF_UNCHECKED  : MyCountFlag = 0
                            ELSE
                             MENU SET STATE hMenu, 1, %MF_CHECKED    : MyCountFlag = 1
                           END IF
                         END IF

                         IF myitem=2 AND hMenu > 0 THEN
                           MENU GET STATE hMenu, 2 TO I
                           IF I= %MF_CHECKED THEN
                             MENU SET STATE hMenu, 2, %MF_UNCHECKED  : MySumFlag = 0
                            ELSE
                             MENU SET STATE hMenu, 2, %MF_CHECKED  : MySumFlag = 1
                           END IF
                         END IF

                         IF myitem=3 AND hMenu > 0 THEN
                           MENU GET STATE hMenu, 3 TO I
                           IF I= %MF_CHECKED THEN
                             MENU SET STATE hMenu, 3, %MF_UNCHECKED : MyAverageFlag = 0
                            ELSE
                             MENU SET STATE hMenu, 3, %MF_CHECKED  : MyAverageFlag = 1
                           END IF
                         END IF

                         'SendMessage CBHNDL,%MLG_Refresh,0,0

                    CASE %MLGN_RCLICKMENU
                         myitem=@MLGN.Param3  ' Menu Item
                         mycol=@MLGN.Param2   ' Column of Mouse
                         myrow=@MLGN.Param1   ' Row of Mouse
                          s="Item " + STR$(myitem) + " On the Right Click Menu. " : list s
                          IF myitem=1 THEN
                          '  SendMessage hGrid1, %MLG_PRINTPREVIEW, 0,0
                            SendMessage hGrid1, %MLG_SETSELECTED, 3,3
                            SendMessage hGrid1, %MLG_REFRESH, 0,0
                          END IF

                          IF myitem=2 THEN
                           ' SendMessage hGrid1, %MLG_PAGESETUP, 0,0
                          END IF

                          IF myitem=3 THEN
                            'zstr = "dpt/Jimmy Klutho"
                            'SendMessage hGrid1, %MLG_PAGESETUP, 7,VARPTR(zstr)
                          END IF

                         hMenu=SendMessage(hGrid1, %MLG_GETMENUHANDLE, 0, 0)
                         IF myitem=1 AND hMenu > 0 THEN
                           MENU GET STATE hMenu, 1 TO I
                           IF I= %MF_CHECKED THEN
                             MENU SET STATE hMenu, 1, %MF_UNCHECKED
                            ELSE
                             MENU SET STATE hMenu, 1, %MF_CHECKED
                           END IF
                         END IF
           END SELECT
        END IF
  END SELECT

END FUNCTION
