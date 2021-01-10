'==============================================================================
'   MLG SDK Demo Test by James Klutho
'   Use only Windows API call and Messages
'   Use only switches to format
'==============================================================================

#COMPILE EXE
#DIM ALL

%USEMACROS = 1
#INCLUDE "Win32API.inc"
#INCLUDE "MLG.INC"

%IDC_MLGGRID=100
GLOBAL hGrid AS DWORD
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
                        "MLG Header,Hide and Sort Demo - Right-click for cell content", _          ' window caption
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

   ' MLG_Init 'Perhaps a case in a developing system where MLG_Init can not be called

    'If the MLG.DLL needs to be loaded dynamically then the following should work
    LOCAL hLib AS DWORD
    LOCAL hProc AS DWORD
    hLib = LoadLibrary("MLG.DLL")
    IF hLib <> 0 THEN
        hProc = GetProcAddress(hLib, "MLG_INIT")
        IF hProc <> 0 THEN CALL DWORD hProc USING MLG_INIT()
        FreeLibrary hLib
    END IF

    'The grid should be registered and can be accessed with messages

    'Switches
    'r50   50 rows
    'c6    6 columns
    'e2    enter key will return to top row when going past bottom row
    't2    tab key will return to column 1 and down 1 row when going past right column
    'i1    if a row is dirtied then post a small line indicator in the row header
    'm1    use right click menu
    'x     use the following column widths starting with the row header (this is column 0) in this case the row header is 50 wide

    hGrid = CreateWindow("MYLITTLEGRID", "r20000/c5/b3/e1/t2/m1Sort This Column,-,Hide This Column,Unhide All,-,Copy Rows,-,Col Resize/x50,90,70,80,90,200,110",%MLG_STYLE,4, 4, 765, 555,hWnd, %IDC_MLGGRID, GetWindowLong(hWnd, %GWL_HINSTANCE), BYVAL 0)

    MLG_FormatColNumber hGrid,3,8.2,%MLG_JUST_RIGHT 'max 8 integer digits and max 2 decimal digits
    MLG_FormatColDate hGrid,4,%MMDDYYYY 'MM/DD/YYYY date format

    a="Number" : SendMessage hGrid, %MLG_SETCELLR ,MAKLNG(0,3),VARPTR(a)
    a="Date" : SendMessage hGrid, %MLG_SETCELLR ,MAKLNG(0,4),VARPTR(a)

    FOR x= 1 TO 20000
     FOR y= 1 TO 5
            z=RND(1,1000)
            a="MLG" + STR$(z)
            IF y=3 THEN a=STR$(z)
            IF y=4 THEN a=FORMAT$(RND(1,12)) & "/" & FORMAT$(RND(1,28)) & "/" & FORMAT$(RND(1970,2008))
            SendMessage hGrid, %MLG_SETCELLR ,MAKLNG(x,y),VARPTR(a)
            SendMessage hGrid, %MLG_SETROWEXTRA ,x,x
     NEXT y
    NEXT x
   ' GetSysColor(%COLOR_3DFACE)
   'IF SendMessage(hGrid, %MLG_SETHEADERCOLOR ,RGB(255,0,0),0)>0 THEN

    IF SendMessage(hGrid, %MLG_SETHEADERCOLOR ,GetSysColor(%COLOR_3DFACE),0)>0 THEN
       MSGBOX "fail"
    END IF

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
    LOCAL myitem AS LONG
    LOCAL a      AS ASCIIZ * 255
    LOCAL MLGN   AS MyGridData PTR
    LOCAL mystr  AS STRING
    LOCAL Recno  AS LONG
    LOCAL I      AS LONG
    LOCAL startblock, endblock AS LONG

    SELECT CASE wMsg

        CASE %WM_CREATE
             'Nothing for now
        CASE %WM_SIZE
             GetClientRect hWnd, tRect
             SetWindowPos hGrid, %HWND_TOP, 4 , 4, tRect.nRight-8,tRect.nBottom-8,%SWP_NOZORDER

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
                  CASE %MLGN_COLSIZEDOUBLECLICK 'Hold shift key to include column header title in mix
                       mycol=@MLGN.Param1
                       MLG_SetColMaxLen(hGrid,mycol,@MLGN.Param2)

                  CASE %MLGN_THEMECHANGED
                     ' msgbox "Theme Changed"

                  CASE %MLGN_RCLICKMENU
                         myitem=@MLGN.Param3  ' Menu Item
                         mycol=@MLGN.Param2   ' Column of Mouse
                         myrow=@MLGN.Param1   ' Row of Mouse

                         IF myitem=1 THEN
                            SendMessage hGrid,%MLG_SORT ,%MLG_ASCEND,mycol
                            SendMessage hGrid,%MLG_REFRESH ,0,0

                         END IF

                           IF myitem=3 THEN
                            SendMessage hGrid ,%MLG_GETCOLBLOCKSELEX,VARPTR(startblock),VARPTR(endblock)
                            IF (endblock - startblock) > 0 THEN
                                 MLG_HideColBlock hGrid
                               ELSE
                                 SendMessage hGrid,%MLG_HIDECOLUMN ,%MLG_HIDECOL,mycol
                            END IF
                            SendMessage hGrid,%MLG_REFRESH ,0,0
                         END IF

                         IF myitem=4 THEN
                            SendMessage hGrid,%MLG_HIDECOLUMN ,%MLG_UNHIDEALLCOLS,2
                            SendMessage hGrid,%MLG_REFRESH ,0,0
                         END IF

                         IF myitem=6 THEN
                            MLG_CopyRowBlockToClipBoard(hGrid,1)
                         END IF

                         IF myitem=6 THEN
                            MLG_CopyRowBlockToClipBoard(hGrid,1)
                         END IF

                          IF myitem=8 THEN
                               MLG_SetColMaxLen(hGrid,mycol,0)
                         END IF

                 END SELECT
          END IF

    END SELECT

    FUNCTION = DefWindowProc(hWnd, wMsg, wParam, lParam)

END FUNCTION
