'MLG 2.00 Demo
#COMPILE EXE
#DIM ALL

#RESOURCE "MLGBitMaps.pbr"
#INCLUDE ONCE "Win32API.inc"

'%MLGSLL = 1
#INCLUDE "MLG.INC"
'#LINK "MLG.SLL"

'Equates
%IDC_GRID1   = 1001
%IDC_LIST1   = 1002
%IDD_DIALOG1 =  101

%IDTEXT     = 100
%ID_OPEN    = 401
%ID_EXIT    = 402

%ID_COPY    = 407
%ID_CUT     = 408
%ID_PASTE   = 409

%ID_FORMAT     = 414

'Globals
GLOBAL hgrid1,hlist1,postno AS LONG
GLOBAL hbmp AS LONG
GLOBAL CD AS CellData
GLOBAL sheet1,sheet2,sheet3 AS LONG

'Functions

FUNCTION PBMAIN()
    ShowDIALOG1 %HWND_DESKTOP
END FUNCTION

SUB list(s AS STRING)
  LOCAL test AS ASCIIZ * 256
  STATIC count1 AS LONG
  LOCAL s5 AS STRING * 5

  INCR count1
  s5 = STR$(count1)

  test="Notification # "+ s5 + ":" + s
  SendMessage(hlist1,%LB_INSERTSTRING,0,VARPTR(test))
END SUB

FUNCTION AddMenu (hDlg AS LONG) AS LONG
    LOCAL Result  AS LONG
    LOCAL hMenu   AS DWORD
    LOCAL hPopup1 AS DWORD

    '----------------------------------------------------------------
    ' Create a top-level menu:
    MENU NEW BAR TO hMenu

    ' Add a top-level menu item with a popup menu:
    MENU NEW POPUP TO hPopup1
    MENU ADD POPUP, hMenu, "&File", hPopup1, %MF_ENABLED
    MENU ADD STRING, hPopup1, "&Open", %ID_OPEN, %MF_ENABLED
    MENU ADD STRING, hPopup1, "-",      0, 0
    MENU ADD STRING, hPopup1, "&Exit", %ID_EXIT, %MF_ENABLED

    MENU NEW POPUP TO hPopup1
    MENU ADD POPUP,  hMenu, "&Edit", hPopup1, %MF_ENABLED
    MENU ADD STRING, hPopup1, "Copy", %ID_COPY, %MF_ENABLED
    MENU ADD STRING, hPopup1, "Cut", %ID_CUT, %MF_ENABLED
    MENU ADD STRING, hPopup1, "Paste", %ID_PASTE, %MF_ENABLED
    MENU ADD STRING, hPopup1, "-",      0, 0
    MENU ADD STRING, hPopup1, "Format", %ID_FORMAT, %MF_ENABLED

    MENU ATTACH hMenu, hDlg

END FUNCTION


CALLBACK FUNCTION ShowDIALOG1Proc()
      LOCAL nwide&,nhigh&
      LOCAL I AS LONG
      LOCAL J AS LONG
      LOCAL K AS LONG
      LOCAL totrows AS LONG
      LOCAL totcols AS LONG
      LOCAL mytotalrows AS LONG
      LOCAL mytotalcols AS LONG
      LOCAL myrow,mycol,startrow,endrow,startcol,endcol AS LONG
      LOCAL s AS STRING
      LOCAL test AS ASCIIZ PTR
      LOCAL result,hEdit,hMenu AS LONG
      LOCAL myget AS STRING
      LOCAL mychar AS LONG
      LOCAL RecNo AS LONG
      LOCAL oldrow AS LONG
      LOCAL mystart AS LONG
      LOCAL myend AS LONG
      LOCAL myitem AS LONG
      LOCAL mytype AS LONG
      LOCAL MLGN AS MyGridData PTR
      LOCAL szBuffer AS ASCIIZ * 64
      LOCAL myPrintArea AS RECT

    SELECT CASE AS LONG CBMSG
        CASE %WM_INITDIALOG

        CASE %WM_NCACTIVATE
            STATIC hWndSaveFocus AS DWORD
            IF ISFALSE CBWPARAM THEN
                hWndSaveFocus = GetFocus()
            ELSEIF hWndSaveFocus THEN
                SetFocus(hWndSaveFocus)
                hWndSaveFocus = 0
            END IF

        CASE %WM_SIZE
           DIALOG GET SIZE CBHNDL TO nwide&, nhigh&
           CONTROL SET SIZE CBHNDL, %IDC_GRID1 , nwide&-20, nhigh&-140
           CONTROL SET LOC CBHNDL, %IDC_LIST1 , 5, nhigh&-130
           CONTROL SET SIZE CBHNDL, %IDC_LIST1 , nwide&-20, 80

       CASE %WM_NOTIFY
         MLGN=CBLPARAM
         IF @MLGN.NMHeader.idFrom = %IDC_GRID1 THEN
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

                    CASE %MLGN_RIGHTCLICK      'sent after a right click has occur.  Make Menu modifications if necessary
                         myrow=@MLGN.Param1 ' row
                         mycol=@MLGN.Param1 ' col
                         s="Current Column " + STR$(mycol) + " Current Row " + STR$(myrow) + " Right click has occured. " : list s

                    CASE %MLGN_RCLICKMENU
                         myitem=@MLGN.Param3  ' Menu Item
                         mycol=@MLGN.Param2   ' Column of Mouse
                         myrow=@MLGN.Param1   ' Row of Mouse

                         hMenu=SendMessage(hGrid1, %MLG_GETMENUHANDLE, 0, 0)
                         IF myitem=1 AND hMenu > 0 THEN
                           MENU GET STATE hMenu, 1 TO I
                           IF I= %MF_CHECKED THEN
                             MENU SET STATE hMenu, 1, %MF_UNCHECKED
                            ELSE
                             MENU SET STATE hMenu, 1, %MF_CHECKED
                           END IF
                         END IF

                 CASE %MLGN_MULTICELLCHANGE 'cell selection change
                     startrow=@MLGN.Param1 '
                     startcol=@MLGN.Param2 '
                     endrow=@MLGN.Param3 '
                     endcol=@MLGN.Param4 '
                     s="Multi Cell Hilite : Start Row= " + STR$(startrow) + " : Start Column= " + STR$(startcol) + " : End Row= " + STR$(endrow)+ " : End Column= " + STR$(endcol)
                     list s

                 CASE %MLGN_SPLITTERCHANGE 'cell selection change
                     Myitem=@MLGN.Param1 '

                     s="Splitter Event : VSplitter = 1 HSplitter = 2 This Splitter= " + STR$(Myitem)
                     list s

                 CASE %MLGN_USERBUTTON
                     mycol=@MLGN.Param2
                     myrow=@MLGN.Param1

                     s="User Button Event : Row = " + STR$(MyRow )  + " : Column= " + STR$(mycol)
                     list s

                     IF Myrow = 15 AND MyCol = 3 THEN
                        MSGBOX "Do an Option"
                     END IF
           END SELECT
          END IF

        'case %WM_TOUCH

        CASE %WM_COMMAND
            SELECT CASE AS LONG CBCTL
                CASE %ID_OPEN
                      MSGBOX "Open"
                CASE %ID_COPY
                       MSGBOX "Copy"
                CASE %ID_CUT
                        MSGBOX "Cut"
                CASE %ID_PASTE
                       MSGBOX "Paste"
                CASE %ID_FORMAT
                  SendMessage(hGrid1,%MLG_SHOWFORMATCELLDIALOG,0,0)

                CASE %ID_EXIT
                  DIALOG END CBHNDL,0

            END SELECT
    END SELECT
END FUNCTION

FUNCTION ShowDIALOG1(BYVAL hParent AS DWORD) AS LONG
    LOCAL lRslt AS LONG
    LOCAL szBuffer AS ASCIIZ * 64
    LOCAL s         AS STRING
    LOCAL a         AS ASCIIZ * 255
    LOCAL x         AS LONG
    LOCAL y         AS LONG
    LOCAL z         AS LONG
    LOCAL myrow,mycol AS LONG
    LOCAL counter   AS LONG
    LOCAL fo        AS FormatOverride
    LOCAL fotest    AS FormatOverride
    LOCAL myPrintArea AS RECT
    LOCAL myBorderArea AS RECT

#PBFORMS BEGIN DIALOG %IDD_DIALOG1->->
    LOCAL hDlg  AS DWORD

    DIALOG NEW PIXELS ,hParent, "MLG Test", 20, 20, 800, 680, %WS_POPUP OR %WS_BORDER _
        OR %WS_DLGFRAME OR %WS_SYSMENU OR %WS_CLIPSIBLINGS OR %WS_VISIBLE OR _
        %DS_MODALFRAME OR %DS_3DLOOK OR %DS_NOFAILCREATE OR %DS_SETFONT, _
        %WS_EX_CONTROLPARENT OR %WS_EX_LEFT OR %WS_EX_LTRREADING OR _
        %WS_EX_RIGHTSCROLLBAR, TO hDlg

        MLG_Init

    CONTROL ADD "MYLITTLEGRID", hDlg, %IDC_GRID1, "f3/s10/r100/c300/z1/b3/e3", 5, 5, 590, _
        390, %WS_CHILD OR %WS_VISIBLE OR %WS_BORDER, %WS_EX_LEFT OR _
        %WS_EX_LTRREADING

        CONTROL ADD LISTBOX, hDlg, %IDC_LIST1, , 5, 570, 170, 100,%WS_VSCROLL OR %LBS_NOTIFY,%WS_EX_CLIENTEDGE
        CONTROL HANDLE hDlg, %IDC_LIST1 TO hList1




    CONTROL HANDLE hDlg,%IDC_GRID1 TO hgrid1


     FOR counter = 1 TO 2
          z=SendMessage(hGrid1, %MLG_ADDSHEET, 0,0)
          IF z=0 THEN EXIT FOR
     NEXT counter

     'Get the sheetID for the three sheets
     sheet1=SendMessage(hGrid1, %MLG_GETSHEETINFO, %MLG_SHEET_GETID,1)
     sheet2=SendMessage(hGrid1, %MLG_GETSHEETINFO, %MLG_SHEET_GETID,2)
     sheet3=SendMessage(hGrid1, %MLG_GETSHEETINFO, %MLG_SHEET_GETID,3)



     a="Pictures" : SendMessage hGrid1, %MLG_NAMESHEET , 1,VARPTR(a)
     a="Splitters" : SendMessage hGrid1, %MLG_NAMESHEET , 2,VARPTR(a)
     a="Chart" : SendMessage hGrid1, %MLG_NAMESHEET , 3,VARPTR(a)
     SendMessage hGrid1, %MLG_SELECTSHEET, 1,0 'Reselect the original tab

     SendMessage hGrid1, %MLG_SHOWSHEETTABS,300,0

     SendMessage hGrid1 ,%MLG_SETROWHEIGHT ,0,36
     MLG_Put(hGrid1,0,3,"Premium" + $CRLF + "Gallery",0,0)
     MLG_Put(hGrid1,6,0,"Best of" + $CRLF + "Current Pics",0,0)
     MLG_Put(hGrid1,3,5,"MLG",0,0)

     SendMessage hGrid1 ,%MLG_SETWORKBOOKPROP ,%MLG_USERTABEDIT,%TRUE
     SendMessage hGrid1 ,%MLG_SETWORKBOOKPROP ,%MLG_USERTABMOVE,%TRUE

     LOCAL MyFont AS LONG
     Myfont = CreateFont(0 - 24, 0, 0, 0, %FW_NORMAL, 0, 0, 0, _
                          %ANSI_CHARSET, %OUT_TT_PRECIS, %CLIP_DEFAULT_PRECIS, _
                          %DEFAULT_QUALITY, 0, "Arial")

     SendMessage hGrid1 ,%MLG_MAKENEWFONT ,7,MyFont
     SendMessage hGrid1 ,%MLG_SETFORMATOVERRIDEEX ,MAKLNG(3,5),MAKLNG(%MLG_TYPE_FONT,7)
     SendMessage hGrid1 ,%MLG_SETFORMATOVERRIDEEX ,MAKLNG(3,5),MAKLNG(%MLG_TYPE_JUST,%MLG_JUST_CENTER)

     SendMessage hGrid1 ,%MLG_SETFORMATOVERRIDEEX ,MAKLNG(7,1),MAKLNG(%MLG_TYPE_CELLTYPE,%MLG_TYPE_CHECKBOX)
     SendMessage hGrid1 ,%MLG_SETFORMATOVERRIDEEX ,MAKLNG(7,2),MAKLNG(%MLG_TYPE_CELLTYPE,%MLG_TYPE_CHECKBOX)
     SendMessage hGrid1 ,%MLG_SETFORMATOVERRIDEEX ,MAKLNG(8,1),MAKLNG(%MLG_TYPE_CELLTYPE,%MLG_TYPE_CHECKBOX)
     SendMessage hGrid1 ,%MLG_SETFORMATOVERRIDEEX ,MAKLNG(8,2),MAKLNG(%MLG_TYPE_CELLTYPE,%MLG_TYPE_CHECKBOX)
     SendMessage hGrid1 ,%MLG_SETFORMATOVERRIDEEX ,MAKLNG(9,1),MAKLNG(%MLG_TYPE_CELLTYPE,%MLG_TYPE_CHECKBOX)
     SendMessage hGrid1 ,%MLG_SETFORMATOVERRIDEEX ,MAKLNG(9,2),MAKLNG(%MLG_TYPE_CELLTYPE,%MLG_TYPE_CHECKBOX)
     MLG_Put(hGrid1,7,1,"1",0,0)
     MLG_Put(hGrid1,8,2,"1",0,0)

     SendMessage hGrid1 ,%MLG_SETFORMATOVERRIDEEX ,MAKLNG(6,1),MAKLNG(%MLG_TYPE_WRITELOCK,1)
     SendMessage hGrid1 ,%MLG_SETFORMATOVERRIDEEX ,MAKLNG(6,2),MAKLNG(%MLG_TYPE_WRITELOCK,1)
     SendMessage hGrid1 ,%MLG_SETFORMATOVERRIDEEX ,MAKLNG(6,1),MAKLNG(%MLG_TYPE_USING,%MLGSYSFONTBOLDVERT)
     SendMessage hGrid1 ,%MLG_SETFORMATOVERRIDEEX ,MAKLNG(6,2),MAKLNG(%MLG_TYPE_USING,%MLGSYSFONTBOLDVERT)
     MLG_Put(hGrid1,6,1,"Puchase",0,0)
     MLG_Put(hGrid1,6,2,"Frame",0,0)
     MLG_Put(hGrid1,6,5,"Data",0,0)

     SendMessage hGrid1 ,%MLG_SETFORMATOVERRIDEEX ,MAKLNG(7,5),MAKLNG(%MLG_TYPE_JUST,%MLG_JUST_WORDWRAP)
     SendMessage hGrid1 ,%MLG_SETFORMATOVERRIDEEX ,MAKLNG(8,5),MAKLNG(%MLG_TYPE_JUST,%MLG_JUST_WORDWRAP)
     SendMessage hGrid1 ,%MLG_SETFORMATOVERRIDEEX ,MAKLNG(9,5),MAKLNG(%MLG_TYPE_JUST,%MLG_JUST_WORDWRAP)

     MLG_Put(hGrid1,7,5,"Great looking picture to hang on your wall",0,0)
     MLG_Put(hGrid1,8,5,"By a new artist from New York",0,0)
     MLG_Put(hGrid1,9,5,"Simple but nice at a good price",0,0)
     MLG_Put(hGrid1,12,3,"#Clicks=",0,0)
     MLG_Put(hGrid1,12,5,"=GetClicks",0,0)

     SendMessage hGrid1 ,%MLG_SETFORMATOVERRIDEEX ,MAKLNG(6,3),MAKLNG(%MLG_TYPE_CELLTYPE,%MLG_TYPE_DRAW)
     SendMessage hGrid1 ,%MLG_SETFORMATOVERRIDEEX ,MAKLNG(6,5),MAKLNG(%MLG_TYPE_CELLTYPE,%MLG_TYPE_DRAW)
     SendMessage hGrid1 ,%MLG_SETCALLBACK,%MLG_DRAWCALLBACK,CODEPTR(DrawCallback)
     SendMessage hGrid1 ,%MLG_SETCALLBACK,%MLG_FORMULACALLBACK,CODEPTR(MacroCallback)
     szBuffer="MyTest,Test1,Test2,Test3,Test4"
     SendMessage hGrid1 ,%MLG_ADDFORMATOVERRIDELIST,1,VARPTR(szBuffer)
     SendMessage hGrid1 ,%MLG_SETFORMATOVERRIDEEX ,MAKLNG(14,3),MAKLNG(%MLG_TYPE_CELLTYPE,%MLG_TYPE_COMBOSTATIC)
     SendMessage hGrid1 ,%MLG_SETFORMATOVERRIDEEX ,MAKLNG(14,3),MAKLNG(%MLG_TYPE_USING,1)
     MLG_Put(hGrid1,14,3,"Test4",0,0)

     SendMessage hGrid1 ,%MLG_SETFORMATOVERRIDEEX ,MAKLNG(15,3),MAKLNG(%MLG_TYPE_CELLTYPE,%MLG_TYPE_USERBUTTON)
     MLG_Put(hGrid1,15,3,"Option",0,0)

     SendMessage hGrid1 ,%MLG_SETCOLWIDTH ,1,25
     SendMessage hGrid1 ,%MLG_SETCOLWIDTH ,2,25
     SendMessage hGrid1 ,%MLG_SETCOLWIDTH ,3,80
     SendMessage hGrid1 ,%MLG_SETCOLWIDTH ,4,10
     SendMessage hGrid1 ,%MLG_SETCOLWIDTH ,5,150
     SendMessage hGrid1 ,%MLG_SETCOLWIDTH ,6,10
     SendMessage hGrid1 ,%MLG_SETFORMATOVERRIDEEX ,MAKLNG(6,1),MAKLNG(%MLG_TYPE_JUST,%MLG_JUST_CENTER)
     SendMessage hGrid1 ,%MLG_SETFORMATOVERRIDEEX ,MAKLNG(6,2),MAKLNG(%MLG_TYPE_JUST,%MLG_JUST_CENTER)
     SendMessage hGrid1 ,%MLG_SETROWHEIGHT ,6,70
     SendMessage hGrid1 ,%MLG_REGISTERBITMAP ,1,LoadBitmap(GetModuleHandle(BYVAL %NULL), "BM1")
     SendMessage hGrid1 ,%MLG_ASSIGNCELLBITMAP ,MAKLNG(7,3),1
     SendMessage hGrid1 ,%MLG_SETROWHEIGHT ,7,60
     SendMessage hGrid1 ,%MLG_REGISTERBITMAP ,2,LoadBitmap(GetModuleHandle(BYVAL %NULL), "BM2")
     SendMessage hGrid1 ,%MLG_ASSIGNCELLBITMAP ,MAKLNG(8,3),2
     SendMessage hGrid1 ,%MLG_SETROWHEIGHT ,8,60
     SendMessage hGrid1 ,%MLG_REGISTERBITMAP ,3,LoadBitmap(GetModuleHandle(BYVAL %NULL), "BM3")
     SendMessage hGrid1 ,%MLG_ASSIGNCELLBITMAP ,MAKLNG(9,3),3
     SendMessage hGrid1 ,%MLG_SETROWHEIGHT ,9,60

      myBorderArea.nTop = 7
      myBorderArea.nBottom = 9
      myBorderArea.nLeft = 3
      myBorderArea.nRight = 6
      SendMessage hGrid1 , %MLG_SETMULTICELLBORDER , VARPTR(myBorderArea),0

      SendMessage hGrid1 ,%MLG_SETCOLWIDTH  ,0,100
      SendMessage hGrid1 ,%MLG_SETROWHEIGHT  ,3,35
      SendMessage hGrid1 ,%MLG_ALTERATTRIBUTE , %MLG_SHOWTHESPLITTERS,1
      SendMessage hGrid1 ,%MLG_ALTERATTRIBUTE , %MLG_KEEPCELLBUTTONSVISIBLE,1

      'Splitter tab
      FOR myrow = 1 TO 100
         FOR mycol= 1 TO 10
             szBuffer = "R=" & FORMAT$(myrow) & " C=" & FORMAT$(mycol)
             CD.MyAction = 1 : CD.MyRow=myrow : CD.MyCol = mycol : CD.MySheet = sheet2 : CD.Refreshflag = 0
             SendMessage hGrid1 ,%MLG_CELLDATA ,VARPTR(CD),VARPTR(szBuffer)
         NEXT mycol
      NEXT myrow

      SendMessage hGrid1, %MLG_SELECTSHEET, 3,0 'select the Chart tab
         SendMessage hGrid1 ,%MLG_SETCALLBACK,%MLG_SHEETTYPECALLBACK,CODEPTR(SheetCallback)
         SendMessage hGrid1 ,%MLG_ALTERATTRIBUTE ,%MLG_SETMYSHEETTYPE,3 'SheetType
         SendMessage hGrid1 ,%MLG_ALTERATTRIBUTE ,%MLG_SHOWTHESPLITTERS,1 'No Splitters
        ' SendMessage hGrid1 ,%MLG_ALTERATTRIBUTE ,%MLG_SUPRESSROWCOLHILITE,1 'No Row Col Hilites
         SendMessage hGrid1 ,%MLG_SETCOLWIDTH  ,0,0
         SendMessage hGrid1 ,%MLG_SETROWHEIGHT  ,0,0
      SendMessage hGrid1, %MLG_SELECTSHEET, 1,0 'Reselect the original tab

      szBuffer = "First,Second,Third"
      SendMessage hGrid1, %MLG_INSERTRCLICKMENU, VARPTR(szBuffer),1 'Tab Menu

      szBuffer = "Fourth,Fifth,Sixth"
      SendMessage hGrid1, %MLG_INSERTRCLICKMENU, VARPTR(szBuffer),0 'Grid Menu

      szBuffer = "ddd MM/dd/yyyy"
      SendMessage hGrid1, %MLG_SETDATEFORMATSTR,1, VARPTR(szBuffer)
      szBuffer = "1,2,3,4,5,1,2,3,4"
      SendMessage hGrid1, %MLG_SETFOMATMENUDATENUMITEMS,VARPTR(szBuffer),0

      SendMessage hGrid1 ,%MLG_ALTERATTRIBUTE ,%MLG_SHOWFORMATMENU,1 'RClickRightMenu

      AddMenu(hDlg)

    DIALOG SHOW MODAL hDlg, CALL ShowDIALOG1Proc TO lRslt

    FUNCTION = lRslt
END FUNCTION

CALLBACK FUNCTION DrawCallBack()
    LOCAL MyRow,MyCol,DimRows,DimCols AS LONG
    LOCAL CurrentSheet AS LONG
    LOCAL a AS LONG
    LOCAL DrawRect AS RECT
    LOCAL RectPtr,temp4  AS LONG
    LOCAL fo AS FormatOverRide
    LOCAL CellCT,CellFont,CellColor,CellBorder,CellCase,CellJust,CellWriteLock,CellUsing AS BYTE
    LOCAL hDC,hDCBmp,fonthndl AS DWORD
    LOCAL tempstr AS STRING
    LOCAL nHeight,nWidth AS SINGLE
    LOCAL MyStr AS STRING * %MLG_MAXCELLLEN
    LOCAL MyStrPtr AS LONG
    LOCAL temp AS LONG

    MyRow=LOWRD(CBLPARAM)
    MyCol=HIWRD(CBLPARAM)
    hDC=SendMessage(CBHNDL,%MLG_GETGRIDDC,0,0)

    RectPtr=VARPTR(DrawRect)
    temp4=SIZEOF(DrawRect)
    CopyMemory RectPtr,CBWPARAM,temp4

    MyStrPtr = VARPTR(MyStr)

    SendMessage(CBHNDL,%MLG_GETFORMATOVERRIDE,MAKLNG(MyRow,MyCol),VARPTR(fo))

    CellCT = (fo.CellType AND &B11100000)\32
    CellWriteLock = (fo.CellType AND &B00010000)\16
    CellUsing = (fo.CellType AND &B00001111)
    CellCase = (fo.CellFormatExtra AND &B00001100)\4
    CellJust = (fo.CellFormatExtra AND &B00000011)
    CellBorder = (fo.CellFormatExtra AND &B11110000)\16
    CellFont = fo.CellFont

    CurrentSheet = SendMessage(CBHNDL,%MLG_GETSHEETINFO,%MLG_SHEET_GETCURRENT,0)
    a=SendMessage(CBHNDL,%MLG_GETARRAYPTR,VARPTR(DimRows),VARPTR(DimCols))
    DIM GridData(DimRows,DimCols) AS STRING AT a

    IF MyRow = 6 AND MyCol=3 AND CurrentSheet = 1 THEN 'insert a bitmap
      SendMessage(CBHNDL,%MLG_BITMAPTODRAWRECT,LoadBitmap(GetModuleHandle(BYVAL %NULL), "BM4") ,RectPtr)
      MyStr = "SAMPLE"
      CopyMemory CBMSG,MyStrPtr,%MLG_MAXCELLLEN
    END IF

    IF MyRow = 6 AND MyCol=5 AND CurrentSheet = 1 THEN 'draw a vertical font
       tempstr = GridData(MyRow,MyCol)
       MyStr = ""  'do not print anything back to the cell
       CopyMemory CBMSG,MyStrPtr,%MLG_MAXCELLLEN
       IF LEN(TRIM$(tempstr)) > 0 THEN
          GRAPHIC BITMAP NEW DrawRect.nRight-DrawRect.nLeft, DrawRect.nBottom-DrawRect.nTop TO hBmp
          GRAPHIC ATTACH hBmp,0
          GRAPHIC GET DC TO hDCBmp
          FONT NEW "Courier New",18,0,0,0,900 TO fonthndl
          IF fonthndl <> 0 THEN
             GRAPHIC SET FONT fonthndl
             GRAPHIC TEXT SIZE tempstr TO nWidth, nHeight
             GRAPHIC CLEAR %WHITE
             GRAPHIC COLOR %BLACK ,%WHITE
             GRAPHIC SET POS (((DrawRect.nRight-DrawRect.nLeft-(nWidth\2))\2),(DrawRect.nBottom-DrawRect.nTop)-2)
             GRAPHIC PRINT tempstr
             BitBlt hDC, DrawRect.nLeft, DrawRect.nTop, DrawRect.nRight-DrawRect.nLeft,DrawRect.nBottom-DrawRect.nTop,hDCBmp, 0, 0, %SRCCOPY '
          END IF
          GRAPHIC BITMAP END
          GRAPHIC DETACH
          FONT END fonthndl
       END IF
    END IF

END FUNCTION

CALLBACK FUNCTION MacroCallBack()
    LOCAL MyRow,MyCol AS LONG
    LOCAL MyStr AS STRING * %MLG_MAXCELLLEN
    LOCAL MyStrPtr,a,DimRows,DimCols,MyClicks AS LONG
    LOCAL InputString AS STRING

    MyStrPtr = VARPTR(MyStr)

    MyRow=LOWRD(CBLPARAM)
    MyCol=HIWRD(CBLPARAM)

    MyStrPtr = VARPTR(MyStr)
    CopyMemory MyStrPtr,CBWPARAM,%MLG_MAXCELLLEN
    InputString = MID$(TRIM$(MyStr),2) 'get past the equal siqn

    a=SendMessage(CBHNDL,%MLG_GETARRAYPTR,VARPTR(DimRows),VARPTR(DimCols))
    DIM GridData(DimRows,DimCols) AS STRING AT a

    IF TRIM$(UCASE$(InputString)) = "GETCLICKS" THEN
        IF GridData(7,1) <> "" THEN INCR MyClicks
        IF GridData(8,1) <> "" THEN INCR MyClicks
        IF GridData(9,1) <> "" THEN INCR MyClicks
        IF GridData(7,2) <> "" THEN INCR MyClicks
        IF GridData(8,2) <> "" THEN INCR MyClicks
        IF GridData(9,2) <> "" THEN INCR MyClicks

        MyStr = FORMAT$(MyClicks)
        CopyMemory CBWPARAM,MyStrPtr,%MLG_MAXCELLLEN
    END IF
END FUNCTION

CALLBACK FUNCTION SheetCallBack()
    LOCAL hDC,CurrentSheet,SheetType AS LONG
    LOCAL rc AS RECT
    LOCAL MyClicks,MyWidth,MyHeight,MyTop,MyLeft,MyStrPtr,Slen,x AS LONG
    LOCAL MyStr AS STRING

     MyStr = "Picture and Frame Clicks"
     MyStrPtr = STRPTR(MyStr)
     Slen = LEN(MyStr)

    SheetType = CBWPARAM
    hDC=SendMessage(CBHNDL,%MLG_GETGRIDDC,0,0)

    CurrentSheet = SendMessage(CBHNDL,%MLG_GETSHEETINFO,%MLG_SHEET_GETCURRENT,0)

    IF SheetType = 3 THEN
      'Fill with desired background brush
       SelectObject(hDC, GetStockObject(%WHITE_BRUSH))
       SelectObject(hDC, GetStockObject(%BLACK_PEN))
       CALL GetClientRect(CBHNDL, rc)
       PatBlt hDC,rc.nLeft,rc.nTop, rc.nRight, rc.nBottom,%PATCOPY

       SetBkColor hDC, %WHITE
       TextOut(hDC, 150, 50, BYVAL MyStrPtr, slen)

       MoveTo(hDC,70,70)
       LineTo(hDC,70,400)
       LineTo(hDC,400,400)
       MoveTo(hDC,70,350) : LineTo(hDC,400,350)
       MoveTo(hDC,70,300) : LineTo(hDC,400,300)
       MoveTo(hDC,70,250) : LineTo(hDC,400,250)
       MoveTo(hDC,70,200) : LineTo(hDC,400,200)
       MoveTo(hDC,70,150) : LineTo(hDC,400,150)
       MoveTo(hDC,70,100) : LineTo(hDC,400,100)

       FOR x = 1 TO 6
        MyStr = FORMAT$(x)
        MyStrPtr = STRPTR(MyStr)
        Slen = LEN(MyStr)
        TextOut(hDC, 60, 390 -(x * 50), BYVAL MyStrPtr, slen)
       NEXT x



        MyClicks =0

        IF LEN(MLG_Get(CBHNDL,7,1,1))> 0  THEN INCR MyClicks
        IF LEN(MLG_Get(CBHNDL,8,1,1))> 0  THEN INCR MyClicks
        IF LEN(MLG_Get(CBHNDL,9,1,1))> 0  THEN INCR MyClicks
        IF LEN(MLG_Get(CBHNDL,7,2,1))> 0  THEN INCR MyClicks
        IF LEN(MLG_Get(CBHNDL,8,2,1))> 0  THEN INCR MyClicks
        IF LEN(MLG_Get(CBHNDL,9,2,1))> 0  THEN INCR MyClicks

       ' MyClicks = 3

       SelectObject(hDC, GetStockObject(%BLACK_BRUSH))
       MyWidth = 50
       MyHeight = 50 * MyClicks
       MyTop = 400 - MyHeight
       MyLeft = 200

       PatBlt hDC,MyLeft,MyTop,MyWidth,MyHeight,%PATCOPY
    END IF


END FUNCTION
