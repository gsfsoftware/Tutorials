'いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい
'    My Little Grid -- MLGDemo by James Klutho
'    Demo all the notifications and Cell types
'いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい
#COMPILE EXE

#INCLUDE "WIN32API.INC" 'PB's win API declares include file
#INCLUDE "MLG.INC"

%IDC_MLGGRID1 = 101
%IDC_MLGLIST1 = 500

%ID_EXIT          = 500
%ID_FREEZEPANES   = 600
%ID_UNFREEZEPANES = 700
%ID_SAVEFILE      =701
%ID_LOADFILE      =702


GLOBAL hGrid1 AS DWORD
GLOBAL hList1 AS DWORD
GLOBAL sheet1,sheet2,sheet3 AS LONG
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

FUNCTION FigureTotal(MyGrid AS LONG) AS STRING
  LOCAL tot AS DOUBLE
  LOCAL x,y AS LONG

  tot = 0

  FOR x = 6 TO 7
     FOR y = 6 TO 36

      tot = tot + VAL(MLG_Get(myGrid,y,x))
     NEXT y
  NEXT x


  FUNCTION = FORMAT$(tot)
END FUNCTION


'いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい
' Dialog for 1 Grid  Resizeable
'いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい


FUNCTION ShowOneGrid(hDlg AS LONG) AS LONG
  LOCAL myrow,mycol,x,y AS LONG
  LOCAL hMenu,hPopup1,counter,z AS LONG
  LOCAL a AS ASCIIZ * 255
  LOCAL szBuffer AS ASCIIZ * 1024
  LOCAL mystr AS STRING

  MLG_Init
  DIALOG NEW 0, "Freeze Panes Example",,, 520, 370, %WS_SYSMENU OR %WS_THICKFRAME TO hDlg

  MENU NEW BAR TO hMenu
  MENU NEW POPUP TO hPopup1
  MENU ADD POPUP, hMenu, "File", hPopup1, %MF_ENABLED

  MENU ADD STRING, hPopup1, "Freeze Panes", %ID_FREEZEPANES, %MF_ENABLED
  MENU ADD STRING, hPopup1, "UnFreeze Panes", %ID_UNFREEZEPANES, %MF_ENABLED
  MENU ADD STRING, hPopup1, "-", 0, 0
  MENU ADD STRING, hPopup1, "Open", %ID_LOADFILE, %MF_ENABLED
  MENU ADD STRING, hPopup1, "Save", %ID_SAVEFILE, %MF_ENABLED
  MENU ADD STRING, hPopup1, "-", 0, 0
  MENU ADD STRING, hPopup1, "Exit", %ID_EXIT, %MF_ENABLED
  MENU ATTACH hMenu, hDlg
  'Switches
  'e3 means tell MLG to auto append a row if needed providing something is in the cell
  'r50 calls for 50 rows total
  'c8 calls for 8 columns
  'b3 means block selecting of rows, columns, and the entire grid is activated
  'm1 active the right click menu with the following comma delimited menu items

  CONTROL ADD "MYLITTLEGRID", hDlg, %IDC_MLGGRID1, "z1/f3/s8/r500/c18/b3/m1Print,Page Setup,Third", 4, 4, 510, 348, %MLG_STYLE
  CONTROL HANDLE hDlg, %IDC_MLGGRID1 TO hGrid1

  CONTROL ADD LISTBOX, hDlg, %IDC_MLGLIST1, , 4, 175, 250, 150,%WS_VSCROLL OR %LBS_NOTIFY ,%WS_EX_CLIENTEDGE
  CONTROL HANDLE hDlg, %IDC_MLGLIST1 TO hList1


  FOR counter = 1 TO 2
          z=SendMessage(hGrid1, %MLG_ADDSHEET, 0,0)
          IF z=0 THEN EXIT FOR
  NEXT counter

     'Get the sheetID for the three sheets
     sheet1=SendMessage(hGrid1, %MLG_GETSHEETINFO, %MLG_SHEET_GETID,1)
     sheet2=SendMessage(hGrid1, %MLG_GETSHEETINFO, %MLG_SHEET_GETID,2)
     sheet3=SendMessage(hGrid1, %MLG_GETSHEETINFO, %MLG_SHEET_GETID,3)



     a="Main" : SendMessage hGrid1, %MLG_NAMESHEET , 1,VARPTR(a)
     a="Blank1" : SendMessage hGrid1, %MLG_NAMESHEET , 2,VARPTR(a)
     a="Blank2" : SendMessage hGrid1, %MLG_NAMESHEET , 3,VARPTR(a)
     SendMessage hGrid1, %MLG_SELECTSHEET, 1,0 'Reselect the original tab

     SendMessage hGrid1, %MLG_SHOWSHEETTABS,300,0

   SendMessage hGrid1, %MLG_INITCOLWIDTHS, 0, 0
   SendMessage hGrid1, %MLG_MAKEDEFHEADERS, 0, 0
   SendMessage hGrid1, %MLG_SETCOLWIDTH, 1, 70
   SendMessage hGrid1, %MLG_SETCOLWIDTH, 2, 100
   SendMessage hGrid1, %MLG_SETCOLWIDTH, 3, 100
   SendMessage hGrid1, %MLG_SETCOLWIDTH, 4, 100
   SendMessage hGrid1, %MLG_SETCOLWIDTH, 8, 50

   szBuffer = "ddd MM/dd/yyyy"
   SendMessage hGrid1, %MLG_SETDATEFORMATSTR,1, VARPTR(szBuffer)

   'SendMessage hGrid1 ,%MLG_SETFORMATOVERRIDEEX ,MAKLNG(0,3),MAKLNG(%MLG_TYPE_BKGCOLOR,%CELLCOLORLIGHTBLUE)
   FOR x = 6 TO 36
     SendMessage hGrid1 ,%MLG_SETFORMATOVERRIDEEX ,MAKLNG(x,3),MAKLNG(%MLG_TYPE_CELLTYPE,%MLG_TYPE_DATE)
     SendMessage hGrid1 ,%MLG_SETFORMATOVERRIDEEX ,MAKLNG(x,3),MAKLNG(%MLG_TYPE_USING,%MMDDYYYY)
     SendMessage hGrid1 ,%MLG_SETFORMATOVERRIDEEX ,MAKLNG(x,6),MAKLNG(%MLG_TYPE_CELLTYPE,%MLG_TYPE_NUMBER)
     SendMessage hGrid1 ,%MLG_SETFORMATOVERRIDEEX ,MAKLNG(x,6),MAKLNG(%MLG_TYPE_USING,%MLG_CURRENCY)
     SendMessage hGrid1 ,%MLG_SETFORMATOVERRIDEEX ,MAKLNG(x,7),MAKLNG(%MLG_TYPE_CELLTYPE,%MLG_TYPE_NUMBER)
     SendMessage hGrid1 ,%MLG_SETFORMATOVERRIDEEX ,MAKLNG(x,7),MAKLNG(%MLG_TYPE_USING,%MLG_CURRENCY)
     MLG_PUT hGrid1,x,6,STR$(RND(50,600)),0
     MLG_PUT hGrid1,x,7,STR$(RND(500,6000)),0
     MLG_PUT hGrid1,x,3,"10/" + FORMAT$(x-5) + "/2012",0
   NEXT x

    SendMessage hGrid1 ,%MLG_SETFORMATOVERRIDEEX ,MAKLNG(1,7),MAKLNG(%MLG_TYPE_CELLTYPE,%MLG_TYPE_NUMBER)
    SendMessage hGrid1 ,%MLG_SETFORMATOVERRIDEEX ,MAKLNG(1,7),MAKLNG(%MLG_TYPE_USING,%MLG_CURRENCY)

   szBuffer="MyTest,Test1,Test2,Test3,Test4"
   SendMessage hGrid1 ,%MLG_ADDFORMATOVERRIDELIST,1,VARPTR(szBuffer)

   SendMessage hGrid1, %MLG_SETMERGECELLS, MAKLNG(1,1),MAKLNG(5,2)
   SendMessage hGrid1 ,%MLG_SETFORMATOVERRIDEEX ,MAKLNG(1,1),MAKLNG(%MLG_TYPE_JUST,%MLG_JUST_WORDWRAP)
   MLG_PUT hGrid1,1,1,"This is a demo of MLG 2.06.  Control Right-Click to change format on selected cells.  Save and then reload file blank sheet.  Merges are not saved.",0

   SendMessage hGrid1 ,%MLG_SETFORMATOVERRIDEEX ,MAKLNG(4,6),MAKLNG(%MLG_TYPE_BKGCOLOR,%CELLCOLORLIGHTBLUE)
   SendMessage hGrid1, %MLG_SETMERGECELLS, MAKLNG(4,6),MAKLNG(4,7)
   SendMessage hGrid1 ,%MLG_SETFORMATOVERRIDEEX ,MAKLNG(4,6),MAKLNG(%MLG_TYPE_JUST,%MLG_JUST_CENTER)
   MLG_PUT hGrid1,4,6,"Costs",0
   MLG_PUT hGrid1,5,6,"Setup",0
   MLG_PUT hGrid1,5,7,"Hardware",0

   SendMessage hGrid1 ,%MLG_ALTERATTRIBUTE ,%MLG_SHOWFORMATMENU,1 'RClickFormatMenu

   szBuffer="Option1,Option2,Option3,Option4,Option5"
   SendMessage hGrid1 ,%MLG_ADDFORMATOVERRIDELIST,1,VARPTR(szBuffer)
   szBuffer="Benson Corp,Ajax,Conan LLC,XYZ,Bullseye Inc.,Ellis and Son"
   SendMessage hGrid1 ,%MLG_ADDFORMATOVERRIDELIST,2,VARPTR(szBuffer)

   SendMessage hGrid1 ,%MLG_SETFORMATOVERRIDEEX ,MAKLNG(1,4),MAKLNG(%MLG_TYPE_CELLTYPE,%MLG_TYPE_COMBOSTATIC)
   SendMessage hGrid1 ,%MLG_SETFORMATOVERRIDEEX ,MAKLNG(1,4),MAKLNG(%MLG_TYPE_USING,1)

    MLG_PUT hGrid1,1,6,"Total Cost=",0
    MLG_PUT hGrid1,5,4,"Customer",0
    MLG_PUT hGrid1,5,5,"Comments",0
    MLG_PUT hGrid1,1,3,"Option=",0
    MLG_PUT hGrid1,1,4,"Option1",0

  FOR y = 6 TO 36
    MLG_PUT hGrid1,y,4,PARSE$(TRIM$(szBuffer),RND(1,5)),0
    SendMessage hGrid1 ,%MLG_SETFORMATOVERRIDEEX ,MAKLNG(y,4),MAKLNG(%MLG_TYPE_CELLTYPE,%MLG_TYPE_COMBOSTATIC)
    SendMessage hGrid1 ,%MLG_SETFORMATOVERRIDEEX ,MAKLNG(y,4),MAKLNG(%MLG_TYPE_USING,2)
  NEXT y

  SendMessage hGrid1, %MLG_COLORSHEETTAB, 1,%CYAN 'Reselect the original tab
   MLG_PUT hGrid1,5,3,"Date",0

  SendMessage hGrid1, %MLG_SETSELECTED,1,4
  SendMessage hGrid1, %MLG_SETTOPROW,1,0
  SendMessage hGrid1, %MLG_FREEZE, %MLG_FREEZEPANES,MAK(LONG,5,0) 'Put on a initial freeze

  MLG_PUT hGrid1,1,7,FigureTotal(hGrid1),0

   DIALOG SHOW MODAL hDlg CALL ShowOneGridProc

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
  LOCAL folder, filter, start, defaultext ,filevar AS STRING
  LOCAL flags AS LONG

  SELECT CASE CBMSG
     CASE %WM_PAINT
        CONTROL REDRAW CBHNDL, %IDC_MLGGRID1

     CASE %WM_SIZE
        DIALOG GET SIZE CBHNDL TO I, J
        CONTROL SET SIZE CBHNDL,%IDC_MLGGRID1, I-14, J - 112 'J-96
        CONTROL SET SIZE CBHNDL,%IDC_MLGLIST1, I-20, 65
        CONTROL SET LOC CBHNDL,%IDC_MLGLIST1, 4, J-100

     CASE %WM_COMMAND
         SELECT CASE CB.CTL

           CASE %ID_FREEZEPANES
               SendMessage hGrid1, %MLG_FREEZE, %MLG_FREEZEPANES,0

           CASE %ID_UNFREEZEPANES
               SendMessage hGrid1, %MLG_FREEZE,%MLG_UNFREEZEALL,0

           CASE %ID_SAVEFILE

               title$ = "Save File As"
               folder$ = "c:\data"
               filter$ = CHR$("MLG Sheet (*.mlg)", 0)
               start$ = ""
               defaultext$ = "mlg"
               flags = %OFN_PATHMUSTEXIST OR %OFN_EXPLORER OR %OFN_OVERWRITEPROMPT
               DISPLAY SAVEFILE ,,,"Save File", folder, filter, start, defaultext, flags TO filevar
               IF LEN(filevar) THEN
                   zstr = TRIM$(filevar)
                   SendMessage hGrid1,%MLG_SAVESHEET,0,VARPTR(zstr)
               ELSE
                  'no action  'ESC or Cancel
               END IF

            CASE %ID_LOADFILE

               title$ = "Open File"
               folder$ = "c:\data"
               filter$ = CHR$("MLG Sheet (*.mlg)", 0)
               start$ = ""
               defaultext$ = "mlg"
               flags = %OFN_PATHMUSTEXIST OR %OFN_EXPLORER OR %OFN_OVERWRITEPROMPT
               DISPLAY OPENFILE ,,,"Save File", folder, filter, start, defaultext, flags TO filevar
               IF LEN(filevar) THEN
                   zstr = TRIM$(filevar)
                   I=SendMessage (hGrid1,%MLG_LOADSHEET,0,VARPTR(zstr))
               ELSE
                  'no action  'ESC or Cancel
               END IF


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
                         MLG_PUT hGrid1,1,7,FigureTotal(hGrid1),0

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
                         mycol=@MLGN.Param2 ' col
                         s="Current Column " + STR$(mycol) + " Current Row " + STR$(myrow) + " Right click has occured. " : list s

                    CASE  %MLGN_SELECTEDCELLLOCKED 'allows user to take action if a locked cell is selected
                         oldrow=@MLGN.Param1  '
                         oldcol=@MLGN.Param2  '
                         myrow=@MLGN.Param3   ' current row
                         mycol=@MLGN.Param4   ' current col

                         s="Current Column " + STR$(mycol) + " Current Row " + STR$(myrow) + " is locked. " : list s
                       '  IF mycol = 7 THEN
                       '    SendMessage hGrid1, %MLG_SETSELECTED, myrow,6
                       '  END IF


                    CASE %MLGN_RCLICKMENU
                         myitem=@MLGN.Param3  ' Menu Item
                         mycol=@MLGN.Param2   ' Column of Mouse
                         myrow=@MLGN.Param1   ' Row of Mouse

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
