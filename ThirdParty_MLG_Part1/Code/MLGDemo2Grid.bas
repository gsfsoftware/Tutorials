'いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい
'    MLG 2 Grid Demo Test by James Klutho
'    Grid 1 has some formatted colors
'    Grid 2 simulates adding records in a database and some validation
'いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい
#COMPILE EXE

#INCLUDE "WIN32API.INC" 'PB's win API declares include file
#INCLUDE "MLG.INC"

%IDC_LABEL1 = 101
%IDC_LABEL2 = 102

%IDC_TEXT1  = 201
%IDC_TEXT2  = 202

%IDC_MLGGRID1 = 301
%IDC_MLGGRID2 = 302

%IDC_LIST1 = 500
%IDC_LIST2 = 501


GLOBAL hGrid1 AS DWORD
GLOBAL hGrid2 AS DWORD
GLOBAL hList1 AS LONG
GLOBAL hList2 AS LONG

'--------------------------------------------------------------------

DECLARE CALLBACK FUNCTION ShowTwoGridsProc()
DECLARE FUNCTION ShowTwoGrids(hDlg AS LONG) AS LONG


'いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい
' PBMAIN - load and show a dialog
'いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい

FUNCTION PBMAIN() AS LONG
     LOCAL result AS LONG
     result=ShowTwoGrids(0)
END FUNCTION

SUB list(s AS STRING,which AS LONG)
  LOCAL test AS ASCIIZ * 256
  STATIC count1 AS LONG
  STATIC count2 AS LONG
  LOCAL s5 AS STRING * 5

  IF which=hList1 THEN
        INCR count1
        s5 = STR$(count1)
      ELSE 'hList2
        INCR count2
        s5 = STR$(count2)
  END IF

  test="Notification # "+ s5 + ":" + s
  SendMessage(which,%LB_INSERTSTRING,0,VARPTR(test))
END SUB



FUNCTION ShowTwoGrids(hDlg AS LONG) AS LONG
  LOCAL RC AS RowColDataType
  LOCAL gi AS GridInit
  LOCAL mylist AS ASCIIZ * 256
  LOCAL COUNT AS LONG


  DIALOG NEW 0, "MyLittleGrid Example test",,, 520, 350, %WS_SYSMENU TO hDlg
  CONTROL ADD LABEL,  hDlg, %IDC_LABEL1, "Grid 1", 125, 2, 50, 10
  CONTROL ADD LABEL,  hDlg, %IDC_LABEL2, "Grid 2", 365, 2, 50, 10
  CONTROL ADD TEXTBOX,hDlg, %IDC_TEXT1, "2/25", 220, 2, 30, 10,%ES_READONLY
  CONTROL ADD TEXTBOX,hDlg, %IDC_TEXT2, "1/2", 476, 2, 30, 10,%ES_READONLY
  CONTROL ADD LISTBOX, hDlg, %IDC_LIST1, , 4, 175, 250, 150,%WS_VSCROLL OR %LBS_NOTIFY ,%WS_EX_CLIENTEDGE
  CONTROL ADD LISTBOX, hDlg, %IDC_LIST2, , 260, 175, 250, 150,%WS_VSCROLL OR %LBS_NOTIFY,%WS_EX_CLIENTEDGE
  CONTROL HANDLE hDlg, %IDC_LIST1 TO hList1
  CONTROL HANDLE hDlg, %IDC_LIST2 TO hList2

  MLG_Init
   CONTROL ADD "MYLITTLEGRID", hDlg, %IDC_MLGGRID1, "r25,5/c3/a1/i1/t2/m1First,Second,-,Third/j1CustNo,Product,Comment", 4, 14, 250, 150, %MLG_STYLE
   CONTROL HANDLE hDlg, %IDC_MLGGRID1 TO hGrid1
   CONTROL ADD "MYLITTLEGRID", hDlg, %IDC_MLGGRID2, "f1/s8/r2,2/c5/i1/e3,30", 260, 14, 250, 150, %MLG_STYLE
   CONTROL HANDLE hDlg, %IDC_MLGGRID2 TO hGrid2
   'Format Grid 2
   DIM b(2,1 TO 5) AS STRING
   b(0,1)="CustID"
   b(0,2)="Lastname"
   b(0,3)="FirstName"
   b(0,4)="Dept"
   b(0,5)="Function"
   b(1,1)="1234"
   b(1,2)="John"
   b(1,3)="Doe"
   b(1,4)="Production"
   b(1,5)="Engineer"
   MLG_PutEx hGrid2,b(),1,1
   SendMessage hGrid2, %MLG_SETDIRTYFLAG ,0,0
   SendMessage(hGrid2,%MLG_SETROWEXTRA ,1 ,566)  ' Create a record number and store it in the rowextra

   'Format Grid 1 Change some colors
   RC.CellType = %MLG_TYPE_COMBOSTATIC
   mylist= "Full Service, Econ Service, Special"
   RC.List=VARPTR(mylist)
   SendMessage hGrid1, %MLG_SETCOLFORMAT,2,VARPTR(RC)
   GI.CellBkColorRGB=RGB(255,255,200)
   GI.WindowBkColorRGB=RGB(255,200,150)
   SendMessage hGrid1, %MLG_SETGRIDEXSTYLE, VARPTR(GI), 0
   SendMessage hGrid1,%MLG_SETSELECTED,2,2
   MLG_FormatColNumber hGrid1,1,8.0

   FOR COUNT=2 TO 24 STEP 2
     MLG_FormatRowHighLight hGrid1,COUNT,%MLG_HILITE
   NEXT COUNT


   DIALOG SHOW MODAL hDlg CALL ShowTwoGridsProc

END FUNCTION

'いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい
' Dialog procedure for 2 Grid Demo
'いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい
CALLBACK FUNCTION ShowTwoGridsProc()
  LOCAL I AS LONG
  LOCAL J AS LONG
  LOCAL K AS LONG
  LOCAL totrows AS LONG
  LOCAL totcols AS LONG
  LOCAL myrow AS LONG, mycol AS LONG
  LOCAL s AS STRING
  LOCAL test AS ASCIIZ PTR
  LOCAL result AS LONG
  LOCAL myget AS STRING
  LOCAL RecNo AS LONG
  LOCAL MLGN AS MyGridData PTR

  SELECT CASE CBMSG
     CASE %WM_PAINT
        CONTROL REDRAW CBHNDL, %IDC_MLGGRID1
        CONTROL REDRAW CBHNDL, %IDC_MLGGRID2

     CASE %WM_NOTIFY
         MLGN=CBLPARAM
         IF @MLGN.NMHeader.idFrom = %IDC_MLGGRID1 THEN
             SELECT CASE @MLGN.NMHeader.code

                 CASE %MLGN_RCLICKMENU
                     K=@MLGN.Param3  ' Menu Item
                     I=@MLGN.Param2  ' Column of Mouse
                     J=@MLGN.Param1  ' Row of Mouse
                     s= "Menu item " + STR$(K)+"; Column= " +STR$(I)+" Row= "+STR$(J)
                     list s,hList1

                 CASE %MLGN_COLWIDTHCHANGED
                      I=@MLGN.Param1     ' New Width
                      J=@MLGN.Param2     ' Column of Mouse
                      s="Column " + STR$(J) + " has Change Width"
                      list s,hList1

                 CASE %MLGN_ROWDIRTY
                     s="Row is Dirty : Old Row= " + STR$(@MLGN.Param1)
                     list s,hList1

                 CASE %MLGN_CELLDIRTY 'cell selection change and old cell is dirty
                     myrow=@MLGN.Param1 'previous row
                     mycol=@MLGN.Param2 'previous col
                     s="Old Cell is Dirty : Old Row= " + STR$(myrow) + " : Old Column= " + STR$(mycol)
                     list s,hList1

                 CASE %MLGN_SELCHANGE 'cell selection change
                     myrow=@MLGN.Param1 'previous row
                     mycol=@MLGN.Param2 'previous col
                     SendMessage(hGrid1,%MLG_GETSELECTEDEX,VARPTR(I),VARPTR(J))
                     SendMessage(hGrid1,%MLG_GETROWCOLTOTEX,VARPTR(totrows),VARPTR(totcols))
                     s= FORMAT$(I)+"/"+FORMAT$(totrows)
                     CONTROL SET TEXT CBHNDL,%IDC_TEXT1,s

           END SELECT
          END IF

          IF @MLGN.NMHeader.idFrom = %IDC_MLGGRID2 THEN
             SELECT CASE @MLGN.NMHeader.code

                 CASE %MLGN_ROWDIRTY
                     s="Row is Dirty : Old Row= " + STR$(@MLGN.Param1)
                     list s,hList2
                     RecNo=SendMessage(hGrid2,%MLG_GETROWEXTRA ,@MLGN.Param1,0)
                     IF RecNo=0 THEN
                        'add a record
                        RANDOMIZE(TIMER)
                        RecNo=RND(1,1000)
                        SendMessage(hGrid2,%MLG_SETROWEXTRA ,@MLGN.Param1 ,RecNo)
                        s="Created new record " + STR$(RecNo) + " on row " + STR$(@MLGN.Param1)
                        list s,hList2
                       ELSE
                        'update a record
                        s="Updated record " + STR$(RecNo) + " on row " + STR$(@MLGN.Param1)
                        list s,hList2
                     END IF


                 CASE %MLGN_WANTNEWREC
                     SendMessage(hGrid2,%MLG_GETSELECTEDEX ,VARPTR(myrow),VARPTR(mycol))
                     'Validate a new record on a minimum of a valid CustID number entry
                     s=MLG_Get(hGrid2,myrow,1)
                     IF VAL(s)=0 THEN
                        s="The CustId is not a positive number. It is required to append a record"
                        MessageBox CBHNDL, s & CHR$(0),"My Little Grid Message" & CHR$(0), %MB_OK
                        SendMessage hGrid2,%MLG_SETSKIPRECFLAG,1,0
                     END IF
                 CASE %MLGN_MADENEWREC


                 CASE %MLGN_CELLDIRTY 'cell selection change and old cell is dirty
                     myrow=@MLGN.Param1 'previous row
                     mycol=@MLGN.Param2 'previous col
                     s="Old Cell is Dirty : Old Row= " + STR$(myrow) + " : Old Column= " + STR$(mycol)
                     list s,hList2

                 CASE %MLGN_SELCHANGE 'cell selection change
                     myrow=@MLGN.Param1 'previous row
                     mycol=@MLGN.Param2 'previous col
                     SendMessage(hGrid2,%MLG_GETSELECTEDEX ,VARPTR(I),VARPTR(J))
                     SendMessage(hGrid2,%MLG_GETROWCOLTOTEX,VARPTR(totrows),VARPTR(totcols))
                     s= FORMAT$(I)+"/"+FORMAT$(totrows)
                     CONTROL SET TEXT CBHNDL,%IDC_TEXT2,s
           END SELECT
        END IF
  END SELECT

END FUNCTION
