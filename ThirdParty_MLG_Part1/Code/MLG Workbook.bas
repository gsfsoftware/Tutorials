'==============================================================================
'   MLG SDK Workbook Demo Test by James Klutho
'   Use only Windows API call and Messages
'   Use Format Overrides and Multisheet
'==============================================================================

#COMPILE EXE
#DIM ALL

%USEMACROS = 1
#INCLUDE "Win32API.inc"
#INCLUDE "MLG.INC"

%IDC_MLGGRID=100
GLOBAL hGrid AS DWORD
GLOBAL sheetID2006,sheetID2007,sheetIDTotal AS LONG


'==============================================================================
FUNCTION WINMAIN (BYVAL hInstance     AS DWORD, _
                  BYVAL hPrevInstance AS DWORD, _
                  BYVAL lpCmdLine     AS ASCIIZ PTR, _
                  BYVAL iCmdShow      AS LONG) AS LONG

    LOCAL Msg       AS tagMsg
    LOCAL wce       AS WndClassEx
    LOCAL szAppName AS ASCIIZ * 80
    LOCAL hWnd      AS DWORD
    LOCAL s         AS STRING
    LOCAL a         AS ASCIIZ * 255
    LOCAL x         AS LONG
    LOCAL y         AS LONG
    LOCAL z         AS LONG
    LOCAL counter   AS LONG
    LOCAL fo        AS FormatOverride
    LOCAL fotest    AS FormatOverride

    szAppName         = "MLGDemo"
    wce.cbSize        = SIZEOF(wce)
    wce.STYLE         = %CS_DBLCLKS
    wce.lpfnWndProc   = CODEPTR(WndProc)
    wce.cbClsExtra    = 0
    wce.cbWndExtra    = 0
    wce.hInstance     = hInstance
    wce.hIcon         = 0
    wce.hCursor       = LoadCursor(%NULL, BYVAL %IDC_ARROW)
    wce.hbrBackground = GetStockObject(%WHITE_BRUSH)
    wce.lpszMenuName  = %NULL
    wce.lpszClassName = VARPTR(szAppName)
    wce.hIconSm       = LoadIcon(hInstance, BYVAL %IDI_APPLICATION)

    RegisterClassEx wce

    ' Create a window using the registered class
    hWnd = CreateWindow(szAppName, _               ' window class name
                        "MLG Workbook Demo - Right-click for cell content", _          ' window caption
                        %WS_OVERLAPPEDWINDOW, _    ' window style
                        %CW_USEDEFAULT, _          ' initial x position
                        %CW_USEDEFAULT, _          ' initial y position
                        %CW_USEDEFAULT, _          ' initial x size
                        %CW_USEDEFAULT, _          ' initial y size
                        %NULL, _                   ' parent window handle
                        %NULL, _                   ' window menu handle
                        hInstance, _               ' program instance handle
                        BYVAL %NULL)               ' creation parameters

    IF hWnd = 0 THEN  ' exit on failure
        MSGBOX "Unable to create window"
        EXIT FUNCTION
    END IF

    MLG_Init

    'The grid should be registered and can be accessed with messages

    'Switches
    'r35   35 rows
    'c6    6 columns
    'b2    allow column highlighting
    'e1    enter key will return to top row when going past bottom row
    't2    tab key will return to column 1 and down 1 row when going past right column
    'm2    use right click tab menu
    'm1    use right click menu
    'x     use the following column widths starting with the row header (this is column 0) in this case the row header is 50 wide

    hGrid = CreateWindow("MYLITTLEGRID", "d-0/r35/c6/e1/t2/b2/x60,80,80,80,80,5,80/m2Move Left,Move Right,-,Color Default,Color Cyan,-,Info", _
    %MLG_STYLE,4, 4, 765, 555,hWnd, %IDC_MLGGRID, GetWindowLong(hWnd, %GWL_HINSTANCE), BYVAL 0)

    SendMessage hGrid, %MLG_SETHEADERCOLOR , %LTGRAY,0

    FOR counter=2 TO 5
        MLG_FormatColNumber hGrid,counter,8.0,%MLG_JUST_RIGHT 'max 8 integer digits and max 2 decimal digits
    NEXT counter

    MLG_FormatColEdit hGrid,1,30,0,0,0,1

     a="Lease" : SendMessage hGrid, %MLG_SETCELLR ,MAKLNG(0,1),VARPTR(a)
     a="Oil" : SendMessage hGrid, %MLG_SETCELLR ,MAKLNG(0,2),VARPTR(a)
     a="Gas" : SendMessage hGrid, %MLG_SETCELLR ,MAKLNG(0,3),VARPTR(a)
     a="Water" : SendMessage hGrid, %MLG_SETCELLR ,MAKLNG(0,4),VARPTR(a)

    FOR counter = 1 TO 2
      z=SendMessage(hGrid, %MLG_ADDSHEET, 0,0)
      IF z=0 THEN EXIT FOR
    NEXT counter

    'Get the sheetID for the three sheets
     sheetID2006=SendMessage(hGrid, %MLG_GETSHEETINFO, %MLG_SHEET_GETID,1)
     sheetID2007=SendMessage(hGrid, %MLG_GETSHEETINFO, %MLG_SHEET_GETID,2)
     sheetIDTotal=SendMessage(hGrid, %MLG_GETSHEETINFO, %MLG_SHEET_GETID,3)



     a="Year 2006" : SendMessage hGrid, %MLG_NAMESHEET , 1,VARPTR(a)
     a="Year 2007" : SendMessage hGrid, %MLG_NAMESHEET , 2,VARPTR(a)
     a="Total Both Years" : SendMessage hGrid, %MLG_NAMESHEET , 3,VARPTR(a)

     a="Revenue" : MLG_Put(hGrid,0,6,TRIM$(a),0,3)  'Make col 6 on the sheet 3 = Total

    FOR counter = 1 TO 30
       a="Fed Unit " + STR$(counter)
       MLG_Put(hGrid,counter,1,TRIM$(a),0)   'Selected sheet does not use the optional sheet slot number
       MLG_Put(hGrid,counter,1,TRIM$(a),0,2)
       MLG_Put(hGrid,counter,1,TRIM$(a),0,3)
       FOR y= 2 TO 4
         z=y*3000/y
         x=RND(1,z): MLG_Put(hGrid,counter,y,FORMAT$(x),0)
         x=RND(1,z): MLG_Put(hGrid,counter,y,FORMAT$(x),0,2)
       NEXT y

    NEXT counter

     SendMessage(hGrid, %MLG_COLORSHEETTAB, 3,%CYAN) 'Color the Totals tab
     SendMessage hGrid, %MLG_SHOWSHEETTABS,300,0

     SendMessage hGrid, %MLG_SELECTSHEET, 3,0 'Select the Totals sheet  to lock the calculated columns
         FOR counter=2 TO 5
            MLG_FormatColNumber hGrid,counter,8.0,%MLG_JUST_RIGHT,0,1 'Reformat the numbers columns to Lock them
         NEXT counter
         MLG_FormatColNumber hGrid,6,12.2,%MLG_JUST_RIGHT,0,1 'Reformat the numbers columns to Lock them

         SendMessage hGrid ,%MLG_CREATEFORMATOVERRIDE,35,6  'Do some formatting of the Total sheet
         MLG_SetFormatOverrideRange hGrid,1,6,30,6,%CELLCOLORYELLOW,%CELLCOLORRED,MLG_MAKEFONT(1,1,0,1,0),0,%MLG_CURRENCY,%MLG_TYPE_NUMBER
         MLG_SetFormatOverrideRange hGrid,33,3,34,4,0,0,MLG_MAKEFONT(1,1,0,1,0),8,0
         MLG_SetFormatOverrideRange hGrid,31,2,31,4,0,0,MLG_MAKEFONT(1,1,0,1,0),%MLG_TOP,%MLG_COMMAS,%MLG_TYPE_NUMBER
         MLG_SetFormatOverrideRange hGrid,31,1,31,1,0,0,MLG_MAKEFONT(1,1,0,1,0),0,0
     SendMessage hGrid, %MLG_SELECTSHEET, 1,0 'Reselect the original 2006 tab

     MLG_Put(hGrid,31,1,"Total",0,3)
     MLG_Put(hGrid,33,3,"Oil Price=",0,3)
     MLG_Put(hGrid,34,3,"Gas Price=",0,3)
     'The revenue per well for 2006 and 2007 is the oil volume * oil price + gas volume * gas price
     MLG_Put(hGrid,33,4,"100.00",0,3) 'Oil price used
     MLG_Put(hGrid,34,4,"7.50",0,3)   'Gas price used

     a="Test,One,Two,Three"
     SendMessage hGrid, %MLG_ADDFORMATOVERRIDELIST, 1,VARPTR(a)

     SendMessage hGrid, %MLG_SETWORKBOOKPROP, %MLG_USERTABEDIT,%TRUE 'Allow user editing of the tabs
     SendMessage hGrid, %MLG_SETWORKBOOKPROP, %MLG_USERTABMOVE,%TRUE

    ShowWindow hWnd, iCmdShow
    UpdateWindow hWnd

    DO WHILE GetMessage(Msg, %NULL, 0, 0)
        TranslateMessage Msg
        DispatchMessage Msg
    LOOP

    FUNCTION = msg.wParam

END FUNCTION

'==============================================================================
FUNCTION WndProc (BYVAL hWnd AS DWORD, BYVAL wMsg AS DWORD, _
                  BYVAL wParam AS DWORD, BYVAL lParam AS LONG) EXPORT AS LONG
'------------------------------------------------------------------------------

    LOCAL hDC    AS DWORD
    LOCAL pPaint AS PAINTSTRUCT
    LOCAL tRect  AS RECT
    LOCAL myrow  AS LONG
    LOCAL mycol  AS LONG
    LOCAL mytab  AS LONG
    LOCAL myitem AS LONG
    LOCAL a      AS ASCIIZ * 255
    LOCAL MLGN   AS MyGridData PTR
    LOCAL mystr AS STRING
    LOCAL temp AS LONG
    LOCAL I AS LONG
    LOCAL skey AS LONG
    LOCAL x,y,z AS LONG
    LOCAL oilprice,gasprice,revenue AS SINGLE
    LOCAL sheetnum2006,sheetnum2007,sheetnumTotal AS LONG

    SELECT CASE wMsg

        CASE %WM_CREATE
             'Nothing for now
        CASE %WM_SIZE
             GetClientRect hWnd, tRect
             SetWindowPos hGrid, %HWND_TOP, 4 , 4, tRect.nRight-8,tRect.nBottom-8,%SWP_NOZORDER
             'SendMessage hGrid, %MLG_SHOWSHEETTABS,300,0

        CASE %WM_PAINT
            hDC = BeginPaint(hWnd, pPaint)
                 SendMessage hGrid,%MLG_REFRESH,0,0
            EndPaint hWnd, pPaint
            FUNCTION = 1
            EXIT FUNCTION


        CASE %WM_DESTROY
            PostQuitMessage 0
            EXIT FUNCTION

       CASE %WM_NOTIFY
           MLGN=lParam
           IF @MLGN.NMHeader.idFrom = %IDC_MLGGRID THEN
             SELECT CASE @MLGN.NMHeader.code

                 CASE %MLGN_ESCAPEPRESSED
                        ' beep
                         SendMessage hGrid, %MLG_UNDO,1,0

                  CASE %MLGN_RCLICKMENU
                         myitem=@MLGN.Param3  ' Menu Item
                         mycol=@MLGN.Param2   ' Column of Mouse
                         myrow=@MLGN.Param1   ' Row of Mouse
                         skey = @MLGN.Param4  'Shiftkey

                         IF myitem=1 THEN
                           '
                            SendMessage hGrid, %MLG_REFRESH,0,0
                            SetFocus hGrid 'after MessageBox is dismissed give focus back to grid
                         END IF

                         IF myitem=2 THEN
                           '
                            SendMessage hGrid, %MLG_REFRESH,0,0
                            SetFocus hGrid 'after MessageBox is dismissed give focus back to grid
                         END IF

                          IF myitem=3 THEN
                           '
                            SendMessage hGrid, %MLG_REFRESH,0,0
                            SetFocus hGrid 'after MessageBox is dismissed give focus back to grid
                         END IF

                   CASE %MLGN_SHEETSELECT
                       'When the Totals Sheet is selected - recalculate
                       'Since the user may move tabs around - get their current position
                        sheetnum2006=SendMessage(hGrid, %MLG_GETSHEETINFO, %MLG_SHEET_GETNUMFROMID,sheetid2006)
                        sheetnum2007=SendMessage(hGrid, %MLG_GETSHEETINFO, %MLG_SHEET_GETNUMFROMID,sheetid2007)
                        sheetnumTotal=SendMessage(hGrid, %MLG_GETSHEETINFO, %MLG_SHEET_GETNUMFROMID,sheetidTotal)

                       IF @MLGN.Param1 = sheetnumTotal THEN
                          oilprice =VAL(MLG_Get(hGrid,33,4))
                          gasprice =VAL(MLG_Get(hGrid,34,4))
                          FOR y= 1 TO 30
                             FOR x=2 TO 4
                                 z=VAL(MLG_Get(hGrid,y,x,sheetnum2006)) + VAL(MLG_Get(hGrid,y,x,sheetnum2007))
                                 MLG_Put(hGrid,y,x,FORMAT$(z),0)  'Since the total sheet is selected use this form of MLG_PUT
                             NEXT x
                          NEXT y

                          FOR y=1 TO 30
                              revenue=VAL(MLG_Get(hGrid,y,2)) * oilprice + VAL(MLG_Get(hGrid,y,3)) * gasprice
                              MLG_Put(hGrid,y,6,FORMAT$(revenue),0)
                          NEXT y

                          FOR x=2 TO 4
                              z=0
                              FOR y=1 TO 30
                                  z=z+VAL(MLG_Get(hGrid,y,x))
                              NEXT y
                              MLG_Put(hGrid,31,x,FORMAT$(z),0)
                          NEXT x

                          SendMessage hGrid, %MLG_REFRESH,0,0
                       END IF

                   CASE %MLGN_RCLICKTABMENU
                       myitem=@MLGN.Param1   ' Menu Item
                       mytab=@MLGN.Param2    ' Tab Number

                      IF myitem = 1 THEN
                         temp=SendMessage(hGrid, %MLG_GETSHEETINFO, %MLG_SHEET_GETLEFT,mytab)

                         IF temp <> 0 THEN
                            SendMessage hGrid, %MLG_SWAPSHEET,temp,mytab
                         END IF
                         SendMessage hGrid, %MLG_REFRESH,0,0

                      END IF

                      IF myitem = 2 THEN
                         temp=SendMessage(hGrid, %MLG_GETSHEETINFO, %MLG_SHEET_GETRIGHT,mytab)
                         IF temp <> 0 THEN
                            SendMessage hGrid, %MLG_SWAPSHEET,temp,mytab
                         END IF
                         SendMessage hGrid, %MLG_REFRESH,0,0
                      END IF

                      IF myitem = 4 THEN
                           SendMessage(hGrid, %MLG_COLORSHEETTAB, mytab,0)
                           SendMessage hGrid, %MLG_REFRESH,0,0
                      END IF

                      IF myitem = 5 THEN
                           SendMessage(hGrid, %MLG_COLORSHEETTAB, mytab,%CYAN)
                           SendMessage hGrid, %MLG_REFRESH,0,0
                      END IF

                      IF myitem = 7 THEN
                           BEEP
                      END IF
             END SELECT
          END IF


    END SELECT

    FUNCTION = DefWindowProc(hWnd, wMsg, wParam, lParam)

END FUNCTION
