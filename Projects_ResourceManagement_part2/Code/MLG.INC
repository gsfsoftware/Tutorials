'********************************************************************
' MyLittleGrid.inc   by James E. Klutho  Copyright May,2006 by James E. Klutho
'********************************************************************
'CONSTANTS
'********************************************************************
'%MLG_STYLE             = 1353711616  '%WS_VISIBLE OR %WS_BORDER OR %WS_CHILD OR %WS_VSCROLL OR %WS_HSCROLL
%MLG_STYLE              = %WS_VISIBLE OR %WS_BORDER OR %WS_CHILD' or %WS_CLIPCHILDREN 'or %WS_CLIPSIBLINGS
%MLG_INCLUDE           = 20090115
%MLG_NULL              = 0
%MLG_MAXCELLLEN        = 1024
'Command Messages
%MLG_REFRESH           = %WM_USER + 1
%MLG_MAKEDEFHEADERS    = %WM_USER + 2
%MLG_INSERTCOLBEFORE   = %WM_USER + 3
%MLG_INSERTCOLAFTER    = %WM_USER + 4
%MLG_INSERTROWBEFORE   = %WM_USER + 5
%MLG_INSERTROWAFTER    = %WM_USER + 6
%MLG_DELETECOLS        = %WM_USER + 7
%MLG_DELETEROWS        = %WM_USER + 8
%MLG_REDIMARRAY        = %WM_USER + 9
%MLG_MAKELONG          = %WM_USER + 10
%MLG_CLEARGRID         = %WM_USER + 11
%MLG_UNDO              = %WM_USER + 12
%MLG_REDIMARRAYEX      = %WM_USER + 13
%MLG_HIDECOLUMN        = %WM_USER + 14
%MLG_SORT              = %WM_USER + 15
%MLG_HIDEROW           = %WM_USER + 16'*NEW
%MLG_PRINT             = %WM_USER + 17 '*NEW
%MLG_PAGESETUP         = %WM_USER + 18 '*NEW
%MLG_PRINTPREVIEW      = %WM_USER + 19 '*NEW
%MLG_SHOWSPLITTERS     = %WM_USER + 20'*NEW
%MLG_ROWCOLHILITE      = %WM_USER + 22
%MLG_SHOWFORMATCELLDIALOG = %WM_USER + 23'*NEW
%MLG_CHANGEFONTNAME    = %WM_USER + 24'*NEW  'Keep Arial
%MLG_CHANGEFONTSIZE    = %WM_USER + 25'*NEW
%MLG_ADDFORMATOVERRIDELIST = %WM_USER + 26'*NEW
%MLG_ALTERATTRIBUTE    = %WM_USER + 27'*NEW  'Hearder selection highligt,splitters,ShowFormatDialog
%MLG_BITMAPTODRAWRECT  = %WM_USER + 28'*NEW
%MLG_CELLDATA          = %WM_USER + 29'*NEW
%MLG_SHOWCELLFORMATDIALOG = %WM_USER + 30'*NEW
%MLG_REGISTERBITMAP    = %WM_USER + 31'*NEW
%MLG_ASSIGNCELLBITMAP  = %WM_USER + 32'*NEW
%MLG_INSERTRCLICKMENU  = %WM_USER + 33'*NEW
%MLG_FREEZE            = %WM_USER + 34 'deprecated
%MLG_CLEARBLOCKSEL     = %WM_USER + 35

'-----MLG System Message-----------------------------------------
%MLG_SIZEHANDLER       = %WM_USER + 70
%LBN_DISMISSESCAPE     = %WM_USER + 71
%MLG_INITCOLWIDTHS     = %WM_USER + 72
%MLG_NOTIFY            = %WM_USER + 73
%MLG_AUTOSCROLL        = %WM_USER + 74

'Worksheet Messages
%MLG_ADDSHEET          = %WM_USER + 80 'returns the sheet number
%MLG_DELETESHEET       = %WM_USER + 81
%MLG_NAMESHEET         = %WM_USER + 82
%MLG_SELECTSHEET       = %WM_USER + 83
%MLG_SWAPSHEET         = %WM_USER + 84
%MLG_SHOWSHEETTABS     = %WM_USER + 85
%MLG_COLORSHEETTAB     = %WM_USER + 86

'Format Override   '65000, by 65000 limit
%MLG_CREATEFORMATOVERRIDE  = %WM_USER + 90
%MLG_DELETEFORMATOVERRIDE  = %WM_USER + 91
%MLG_SETFORMATOVERRIDE     = %WM_USER + 92
%MLG_GETFORMATOVERRIDE     = %WM_USER + 93
%MLG_GETFORMATOVERRIDEROWCOL = %WM_USER + 94

'Set Data Messages
%MLG_SETNUMFORMATROW   = %WM_USER + 101
%MLG_SETNUMFORMATCOL   = %WM_USER + 102
%MLG_SETWORKBOOKPROP   = %WM_USER + 103
%MLG_SETSELECTED       = %WM_USER + 104
%MLG_SETROWFORMAT      = %WM_USER + 105
%MLG_SETTOPROW         = %WM_USER + 106
%MLG_SETCOLFORMAT      = %WM_USER + 107
%MLG_SETROWCOLTEMPLATE = %WM_USER + 108
%MLG_SETGRIDEXSTYLE    = %WM_USER + 109
%MLG_SETDIRTYFLAG      = %WM_USER + 110
%MLG_SETLEFTCOL        = %WM_USER + 111
%MLG_SETSKIPRECFLAG    = %WM_USER + 112
%MLG_SETROWEXTRA       = %WM_USER + 113
%MLG_SETCOLEXTRA       = %WM_USER + 114
%MLG_SETCOLWIDTH       = %WM_USER + 115
%MLG_SETCELL           = %WM_USER + 116 'SendMessage cntl, %MLG_SETCELL, MAKLNG(row,col),varptr(asciiz))
%MLG_SETCELLR          = %WM_USER + 117
%MLG_SETDIRTYFLAGZERO  = %WM_USER + 118
%MLG_SETNUMFORMATSTR   = %WM_USER + 119 'Not implemented yet
%MLG_SETCELLEX         = %WM_USER + 120 'zstring in zBuffer
%MLG_SETCELLREX        = %WM_USER + 121 'zstring in zBuffer
%MLG_SETBUFFER         = %WM_USER + 122 'zBuffer
%MLG_SETHEADERCOLOR    = %WM_USER + 123
%MLG_SETCALLBACK       = %WM_USER + 124'*NEW
%MLG_SETMULTICELLSELECTION = %WM_USER + 125'*NEW
%MLG_SETMENUHANDLE     = %WM_USER + 126'*NEW
%MLG_SETBKGNDCELLCOLOR = %WM_USER + 127'*NEW
%MLG_SETTEXTCELLCOLOR  = %WM_USER + 128 '*NEW
%MLG_SETFORMATOVERRIDEEX = %WM_USER + 129 '*NEW
%MLG_SETROWHEIGHT      = %WM_USER + 130'*NEW
%MLG_SETUSERCELLFONT   = %WM_USER + 131'*NEW  'slots 8 to 63 are open for the programmer to make his on font
%MLG_SETSHEETTYPE      = %WM_USER + 132'*NEW
%MLG_SETPRINTAREA      = %WM_USER + 133'*NEW
%MLG_SETDAYFORMATSTR   = %WM_USER + 134 '*NEW
%MLG_SETMONTHFORMATSTR = %WM_USER + 135'*NEW
%MLG_SETDEFAULTDATEFORMAT = %WM_USER + 136'*NEW
%MLG_SETMULTICELLBORDER = %WM_USER + 137'*NEW
%MLG_SETROWEXTRAQUAD   = %WM_USER + 138
%MLG_SETSHEETUSER      = %WM_USER + 139
%MLG_SETSHEETPROPERTY  = %WM_USER + 140

'Get Data Messages
%MLG_GETWORKBOOKPROP   = %WM_USER + 201
%MLG_GETSELECTED       = %WM_USER + 202
%MLG_GETROWFORMAT      = %WM_USER + 203
%MLG_GETTOPROW         = %WM_USER + 204
%MLG_GETCOLFORMAT      = %WM_USER + 205
%MLG_GETDIRTYFLAG      = %WM_USER + 206
%MLG_GETROWCOLTOT      = %WM_USER + 207
%MLG_GETROWCOLDIM      = %WM_USER + 208
%MLG_GETLEFTCOL        = %WM_USER + 209
%MLG_GETOLDCELL        = %WM_USER + 210
%MLG_GETUNDO           = %WM_USER + 211
%MLG_GETCELLTYPE       = %WM_USER + 212
%MLG_GETROWEXTRA       = %WM_USER + 213
%MLG_GETCOLEXTRA       = %WM_USER + 214
%MLG_GETCOLWIDTH       = %WM_USER + 215
%MLG_GETCELL           = %WM_USER + 216
%MLG_GETBUILD          = %WM_USER + 217
%MLG_GETROWCOLALLBLOCKSEL   = %WM_USER + 218
%MLG_GETROWBLOCKSEL    = %WM_USER + 219
%MLG_GETCOLBLOCKSEL    = %WM_USER + 220
%MLG_GETMENUHANDLE     = %WM_USER + 221
%MLG_GETROWCOLDIMEX    = %WM_USER + 222
%MLG_GETROWCOLTOTEX    = %WM_USER + 223
%MLG_GETROWBLOCKSELEX  = %WM_USER + 224
%MLG_GETCOLBLOCKSELEX  = %WM_USER + 225
%MLG_GETOLDCELLEX      = %WM_USER + 226
%MLG_GETCELLEX         = %WM_USER + 227   'string in buffer
%MLG_GETSELECTEDEX     = %WM_USER + 228
%MLG_GETBUFFER         = %WM_USER + 229
%MLG_GETARRAYPTR       = %WM_USER + 230
%MLG_GETEDITHANDLE     = %WM_USER + 231
%MLG_GETNOTIFYPARAM    = %WM_USER + 232 'NEW sort of
%MLG_GETGRIDDC         = %WM_USER + 233 '*NEW
%MLG_GETLISTHANDLE     = %WM_USER + 234 '*NEW
%MLG_GETFORMATOVERRIDEEX = %WM_USER + 235'*NEW
%MLG_GETMULTICELLSELECTION = %WM_USER + 236'*NEW  'store is a rect
%MLG_GETCELLFONTHANDLE = %WM_USER + 237'*NEW
%MLG_GETPRINTAREA      = %WM_USER + 238'*NEW
%MLG_GETROWEXTRAQUAD   = %WM_USER + 239
%MLG_GETROWHEIGHT      = %WM_USER + 240
%MLG_GETSHEETINFO      = %WM_USER + 241
%MLG_GETSHEETUSER      = %WM_USER + 242

'Notifications
%MLGN_RETURN           = %WM_USER + 301
%MLGN_DELETE           = %WM_USER + 302
%MLGN_TAB              = %WM_USER + 303
%MLGN_CHARPRESSED      = %WM_USER + 304
%MLGN_ESCAPEPRESSED    = %WM_USER + 305
%MLGN_ROWDIRTY         = %WM_USER + 306
%MLGN_CELLDIRTY        = %WM_USER + 307
%MLGN_ROWALTERED       = %WM_USER + 308
%MLGN_CELLALTERED      = %WM_USER + 309
%MLGN_DATEPROBLEM      = %WM_USER + 310
%MLGN_CHECKCHANGED     = %WM_USER + 311
%MLGN_COMBOCHANGED     = %WM_USER + 312
%MLGN_COLWIDTHCHANGED  = %WM_USER + 313
%MLGN_SELCHANGE        = %WM_USER + 314
%MLGN_ROWSELCHANGE     = %WM_USER + 315
%MLGN_COLSELCHANGE     = %WM_USER + 316
%MLGN_ROWCOLALLBLOCKSEL= %WM_USER + 317
%MLGN_ROWCHANGE        = %WM_USER + 318
%MLGN_REDIMFAILED      = %WM_USER + 319
%MLGN_WANTNEWREC       = %WM_USER + 320
%MLGN_MADENEWREC       = %WM_USER + 321
%MLGN_RCLICKMENU       = %WM_USER + 322
%MLGN_RIGHTCLICK       = %WM_USER + 323
%MLGN_PASTE            = %WM_USER + 324
%MLGN_SHEETRCLICK      = %WM_USER + 325
%MLGN_SHEETSELECT      = %WM_USER + 326
%MLGN_RCLICKTABMENU    = %WM_USER + 327
%MLGN_SHEETNAMECHANGE  = %WM_USER + 328
%MLGN_SHEETPOSCHANGE   = %WM_USER + 329
%MLGN_SHEETCOLORCHANGE = %WM_USER + 330
%MLGN_SHEETADDED       = %WM_USER + 331
%MLGN_SHEETDELETED     = %WM_USER + 332
%MLGN_COLSIZEDOUBLECLICK  = %WM_USER + 333
%MLGN_THEMECHANGED     = %WM_USER + 334
%MLGN_COLDOUBLECLICK   = %WM_USER + 335
%MLGN_ROWDOUBLECLICK   = %WM_USER + 336
%MLGN_SETFOCUS         = %WM_USER + 337
%MLGN_KILLFOCUS        = %WM_USER + 338
%MLGN_ROWINSERT        = %WM_USER + 339
%MLGN_ROWDELETE        = %WM_USER + 340
%MLGN_COLINSERT        = %WM_USER + 341
%MLGN_COLDELETE        = %WM_USER + 342
%MLGN_SHEETSELECTCHANGING  = %WM_USER + 343
%MLGN_ROWHEIGHTCHANGED = %WM_USER + 344 '*NEW
%MLGN_USERBUTTON       = %WM_USER + 345 '*NEW
%MLGN_COMBOBUTTON      = %WM_USER + 346 '*NEW
%MLGN_MULTICELLCHANGE  = %WM_USER + 347'*NEW
%MLGN_SPLITTERCHANGE   = %WM_USER + 348
'End of Messages and Notifications

%MLG_UNFREEZEALL       = 0
%MLG_FREEZEROW         = 1
%MLG_UNFREEZEROW       = 2
%MLG_FREEZECOL         = 3
%MLG_UNFREEZECOL       = 4

'Cell Types
%MLG_TYPE_EDIT         = 0 'default - may be overridden
%MLG_TYPE_DRAW         = 1 '
%MLG_TYPE_CHECKBOX     = 2
%MLG_TYPE_COMBOSTATIC  = 3
%MLG_TYPE_COMBOEDIT    = 4
%MLG_TYPE_USERBUTTON   = 5
%MLG_TYPE_DATE         = 6
%MLG_TYPE_NUMBER       = 7

'Attributes
 %MLG_SUPRESSROWCOLHILITE = 1
 %MLG_SUPPRESSGRIDLINES = 2
 %MLG_SHOWTHESPLITTERS = 3
 %MLG_SHOWCROSSCURSOR = 4
 %MLG_SUPRESSROWCOLRESIZE = 5
 %MLG_SETMYSHEETTYPE = 6
 %MLG_SETCELLLINECOLORRGB =7
 %MLG_SETCELLBKCOLORRGB = 8
 %MLG_SETWINDOWBKCOLORRGB = 9
 %MLG_SETRCHILITERGB = 10
 %MLG_SETUSERDATA = 11
 %MLG_SETHEADERSELECTRGB =12
 %MLG_KEEPCELLBUTTONSVISIBLE =13

'Callbacks
%MLG_DRAWCALLBACK          = 1
%MLG_FORMULACALLBACK       = 2
%MLG_NUMBERCALLBACK        = 3
%MLG_LISTBOXCALLBACK       = 4
%MLG_DATECALLBACK          = 5
%MLG_SHEETTYPECALLBACK     = 6

'Format Override Items
%MLG_TYPE_CELLTYPE         = 0
%MLG_TYPE_WRITELOCK        = 1
%MLG_TYPE_USING            = 2
%MLG_TYPE_FONT             = 3
%MLG_TYPE_BKGCOLOR         = 4
%MLG_TYPE_FGCOLOR          = 5
%MLG_TYPE_BORDER           = 6
%MLG_TYPE_CASE             = 7
%MLG_TYPE_JUST             = 8

'System Fonts
%MLGSYSFONTNORM = 0
%MLGSYSFONTBOLD = 1
%MLGSYSFONTITAL = 2
%MLGSYSFONTTABNORM = 3
%MLGSYSFONTTABBOLD = 4
%MLGSYSFONTNORMVERT = 5
%MLGSYSFONTBOLDVERT = 6
%MLGSYSFONTRES = 7

'Write Lock
%MLG_NOLOCK            = 0
%MLG_LOCK              = 1
%MLG_LOCK_SKIPROW      = 2 'Will not allow a locked row to be selected
'High Light a row
%MLG_NOHILITE          = 0
%MLG_HILITE            = -1
'Case Formats
%MLG_NOCASE            = 0
%MLG_UCASE             = 1
%MLG_LCASE             = 2
%MLG_MCASE             = 3
'Justification formats
%MLG_JUST_LEFT         = 0
%MLG_JUST_RIGHT        = 1
%MLG_JUST_CENTER       = 2
%MLG_JUST_WORDWRAP     = 3
'Date formats
%MMDDYYYY              = 1
%MMDDYYYYH             = 2  'Dot instead of a slash
%DDMMYYYY              = 3
%DDMMYYYYH             = 4  'Dot instead of a slash
%MMYYYY                = 5
%MMYYYYH               = 6  'Dot instead of a slash
%YYYYMMDD              = 7
%YYYYMMDDH             = 8  'Dot instead of a slash
%YYYYMM                = 9
%YYYYMMH               = 10  'Dot instead of a slash


'Column Hide
%MLG_HIDECOL           = 0
%MLG_UNHIDECOL         = 1
%MLG_UNHIDEALLCOLS     = 2
'Sorting
%MLG_ASCEND            = 0
%MLG_DESCEND           = 1

'Redimensioning Error Codes

%MLG_ERR_TOTROWS1       =  1 'Requested Total Rows is less than 1
%MLG_ERR_TOTROWS65000   =  2 'Requested Total Rows is more than allowable total rows (65000)
%MLG_ERR_TOTCOLS1       =  3 'Requested Total Columns is less than 1
%MLG_ERR_TOTCOLS255     =  4 'Requested Total Columns is more than allowable total columns (255)
%MLG_ERR_DIMROWS1       =  5 'Requested Dimensioned Rows is less than 1
%MLG_ERR_DIMROWS65000   =  6 'Requested Dimensioned Rows is more than allowable total rows (65000)
%MLG_ERR_DIMCOLS1       =  7 'Requested Dimensioned Columns is less than 1
%MLG_ERR_DIMCOLS255     =  8 'Requested Dimensioned Columns is more than allowable total columns (255)
%MLG_ERR_TOTROWSDIMROWS =  9 'Requested Total Rows is greater than Dimensioned Rows
%MLG_ERR_TOTCOLSDIMCOLS =  10 'Requested Total Columns is greater than Dimensioned Columns
%MLG_ERR_GRIDMEM        =  11 'Access to the grid memory block failed
%MLG_ERR_STRMEMREALLOCATION =  12 'ReAllocation of string memory failed
%MLG_ERR_ROWMEMREALLOCATION =  13 'ReAllocation of row formatting memory failed
%MLG_ERR_EXPARAMCOUNT   =  14 'The string passed did not have enough parameters

 'Parameter Block Constants
%MLG_GETCELLARRAY      = -1
%MLG_GETPARAMBLOCK     = -2
%MLG_CREATEGRID        = -3
%MLG_CREATEGRID_DDT    = -4
%MLG_INIT              = -5

'WorkSheet Information
%MLG_SHEET_GETNUM   = 1
%MLG_SHEET_GETNAME  = 2
%MLG_SHEET_GETTOT   = 3
%MLG_SHEET_GETRIGHT = 4
%MLG_SHEET_GETLEFT  = 5
%MLG_SHEET_GETFIRST = 6
%MLG_SHEET_GETLAST  = 7
%MLG_SHEET_GETID = 8
%MLG_SHEET_GETNUMFROMID = 9
%MLG_SHEET_GETCURRENT = 10

'Workbook Properties
%MLG_USERTABMOVE = 1
%MLG_USERTABEDIT = 2

'Format Override Borders
%MLG_TOP = 8
%MLG_LEFT = 4
%MLG_BOTTOM = 2
%MLG_RIGHT = 1

'Number Format Overriding predefined masks
%MLG_NODECIMAL     = 1  '"#"
%MLG_COMMAS        = 2  '"#,"
%MLG_COMMASDECIMAL = 3  '"#,.00"
%MLG_CURRENCY      = 4  '"$* #,.00"
%MLG_PERCENT       = 5  '"0.0%

'Font
%MLG_FONT_USER = 0
%MLG_FONT_ARIAL = 3
%MLG_FONT_COURIERNEW = 1
%MLG_FONT_TIMESNEWROMAN = 2

%MLG_FONT_SIZE8 = 0
%MLG_FONT_SIZE10 = 1
%MLG_FONT_SIZE12 = 2
%MLG_FONT_SIZE14 = 3
%MLG_FONT_SIZE16 = 4
%MLG_FONT_SIZE20 = 5
%MLG_FONT_SIZE24 = 6
%MLG_FONT_SIZE36 = 7

'CellColors
%CELLCOLORWHITE = 0
%CELLCOLORBLACK = 1
%CELLCOLORRED   = 2
%CELLCOLORSALMON = 3
%CELLCOLORGREEN = 4
%CELLCOLORLIGHTGREEN = 5
%CELLCOLORBLUE = 6
%CELLCOLORLIGHTBLUE = 7
%CELLCOLORMAGENTA = 8
%CELLCOLORDARKMAGENTA = 9
%CELLCOLORCYAN = 10
%CELLCOLORAQUAMARINE = 11
%CELLCOLORKHAKI = 12
%CELLCOLORBROWN = 13
%CELLCOLORYELLOW = 14
%CELLCOLORORANGE = 15

'Toggles
%MLG_TOGGLEHEADERHILGE = 1
%MLG_TOGGLEGRIDLINES = 2
%MLG_TOGGLESPLITTERS = 3


'********************************************************************
' User Define Types
'********************************************************************
TYPE RowColDataType            'A Row Format is superior to a Column Format
    CellType        AS LONG    'Default(text) = 0 , text= 1,checkbox=2,dropdownlist=3,editable dropdownlist=4
    VisWidth        AS LONG    'if column, this is the width in pixels (zero is hidden). if row, (not used)
    FormatExtra     AS LONG    'various (not used)
    WriteLock       AS LONG    'locked <> -1 , unlocked = 0
    FormatColor     AS LONG    'RGB of the text (foreground color) of the cell  - zero is black
    FormatCase      AS LONG    'No case formatting = 0 , upper case > 0 , lower case < 0
    FormatLength    AS LONG    'No Length restriction (%MLG_MAXCELLLEN max) = 0 or max characters
    FormatJustify   AS LONG    'Left = 0 (default), Right = 1, Center = 2
    FormatNumber    AS SINGLE  'Integer portion is count left of decimal point, decimal is portion right of decimal point ie "8.3"
    Extra           AS LONG    'Anything you want, could be used as Record Number in Row
    Extra2          AS LONG
    List            AS ASCIIZ PTR    'Used for the list box.
    FormatDate      AS LONG     ' 0=mm/dd/yyyy  etc.
    TempHide        AS LONG
    PrintUsing      AS LONG
    RowColDirty     AS LONG
END TYPE

TYPE CellData
    MyAction    AS LONG   'non zero is put   0 is get
    MyRow       AS LONG
    MyCol       AS LONG
    MySheet     AS LONG
    RefreshFlag AS LONG   'non zero is refreh
END TYPE

TYPE FormatOverRide
    ' Padding AS LONG
     CellFont AS BYTE   '255  bits 1 2 3  size   4 5 font name  6 7 8 Bold Italic Underline   zero is automatic
     CellType AS BYTE   'bits 1 2 3 is cell type
                        'bit 4 is writelock
                        'bits 5 6 7 8 list pointers  1 to 15
                            'Cell Type 0 automatic = Justify Case
                            'Cell Type 1 text = Justify Case
                            'Cell Type 2 checkbox = not used
                            'Cell Type 3 combo static = 1 to 15 lists
                            'Cell Type 4 combo edit = 1 to 15 lists
                            'Cell Type 5 user button = not used
                            'Cell Type 6 date = 1 to 15 date formats
                            'Cell Type 7 number = 1 to 15 number formats
     CellFormatExtra AS BYTE   'bit 1 2 3 4  border  bit 5 6 case   bit 7 8 justify
     CellColor AS BYTE    '16 Background colors, 16 text colors
END TYPE


TYPE GridInit
  hFont               AS DWORD   'Cell Font
  hFontBold           AS DWORD   'For column and row headers
  hFontItalic         AS DWORD   'For Italic Font
  cyCharEx            AS LONG    'Added to pixel height of the font for more room in the cell
  CellBkColorRGB      AS LONG    'Cells Background Color
  CellLineColorRGB    AS LONG    'Cell Line Color
  WindowBkColorRGB    AS LONG    'Window Background Color outside of cell area
  RCHiLiteRGB         AS LONG    'If user wishes to high as row or column
  UserData            AS LONG    'Use for anything you wish
END TYPE


TYPE MyGridData
   NMHeader AS NMHDR
   Param1 AS LONG
   Param2 AS LONG
   Param3 AS LONG
   Param4 AS LONG
END TYPE

TYPE ParamBlock                    'Main block for individual grid data
  s                   AS STRING * %MLG_MAXCELLLEN
  r                   AS LONG
  c                   AS LONG
  a                   AS LONG
  p1                  AS LONG
  p2                  AS LONG
  p3                  AS LONG
  p4                  AS LONG
  p5                  AS LONG
  p6                  AS LONG
END TYPE

'Macros

MACRO MLG_MakeFont(FontName,FontSize,FontUnderline,FontBold,FontItalics) = FontName * 64 + FontSize * 8 + FontUnderline * 4 + FontBold * 2 + FontItalics
#IF NOT %DEF(%MLGSLL)
 DECLARE FUNCTION MLG LIB "MLG.DLL" ALIAS "MLG" (BYVAL hGrid AS LONG,OPT BYVAL op AS LONG,OPT BYVAL tp AS ParamBlock) AS LONG
 DECLARE FUNCTION MLG_Get LIB "MLG.DLL" ALIAS "MLG_GET" (hGrid AS DWORD,ROW AS LONG,COL AS LONG,OPT BYVAL sheetnum AS LONG) AS STRING
 DECLARE SUB MLG_Put LIB "MLG.DLL" ALIAS "MLG_PUT" (hGrid AS DWORD,ROW AS LONG,COL AS LONG, mystr AS STRING,refresh AS LONG,OPT BYVAL sheetnum AS LONG)
 DECLARE FUNCTION MLG_ArrayRedim LIB "MLG.DLL" ALIAS "MLG_ARRAYREDIM" (BYVAL hGrid AS DWORD, ROW AS LONG, COL AS LONG, rowdim AS LONG, coldim AS LONG)AS LONG
 DECLARE SUB MLG_Init LIB "MLG.DLL" ALIAS "MLG_INIT"
 DECLARE SUB MLG_GetEx LIB "MLG.DLL" ALIAS "MLG_GETEX" (hGrid AS DWORD,s() AS STRING)
 DECLARE SUB MLG_PutEx LIB "MLG.DLL" ALIAS "MLG_PUTEX" (hGrid AS DWORD,s()AS STRING,op AS LONG, refresh AS LONG)
 DECLARE FUNCTION MLG_SetProperty LIB "MLG.DLL" ALIAS "MLG_SETPROPERTY" (BYVAL hGrid AS LONG, BYVAL PROPERTY AS STRING, BYVAL thevalue1 AS LONG, BYVAL thevalue2 AS LONG, BYVAL thestr AS STRING)AS LONG
#ENDIF
SUB MLG_FormatColCheck(BYVAL hGrid AS DWORD,BYVAL COL AS LONG)
   LOCAL totals AS LONG
   LOCAL totcols AS LONG
   LOCAL RC AS RowColDataType

   totals=SendMessage(hGrid,%MLG_GETROWCOLTOT,0,0)
   totcols=HIWRD(totals)
   IF COL < 1 OR COL > totcols THEN EXIT SUB
   SendMessage hGrid, %MLG_GETCOLFORMAT,COL,VARPTR(RC)
   RC.CellType = %MLG_TYPE_CHECKBOX
   SendMessage hGrid, %MLG_SETCOLFORMAT,COL,VARPTR(RC)
END SUB

SUB MLG_FormatColUserButton(BYVAL hGrid AS DWORD,BYVAL COL AS LONG)
   LOCAL totals AS LONG
   LOCAL totcols AS LONG
   LOCAL RC AS RowColDataType

   totals=SendMessage(hGrid,%MLG_GETROWCOLTOT,0,0)
   totcols=HIWRD(totals)
   IF COL < 1 OR COL > totcols THEN EXIT SUB
   SendMessage hGrid, %MLG_GETCOLFORMAT,COL,VARPTR(RC)
   RC.CellType = %MLG_TYPE_USERBUTTON
   SendMessage hGrid, %MLG_SETCOLFORMAT,COL,VARPTR(RC)
END SUB

SUB MLG_FormatColCombo(BYVAL hGrid AS DWORD,BYVAL COL AS LONG,liststr AS STRING,OPT BYVAL op AS LONG)
   LOCAL totals AS LONG
   LOCAL totcols AS LONG
   LOCAL RC AS RowColDataType
   LOCAL zlist AS ASCIIZ * 25600

   totals=SendMessage(hGrid,%MLG_GETROWCOLTOT,0,0)
   totcols=HIWRD(totals)
   IF COL < 1 OR COL > totcols THEN EXIT SUB
   SendMessage hGrid, %MLG_GETCOLFORMAT,COL,VARPTR(RC)
   IF op<>0 THEN RC.CellType = %MLG_TYPE_COMBOSTATIC ELSE RC.CellType = %MLG_TYPE_COMBOEDIT
   zlist= liststr
   RC.List=VARPTR(zlist)
   SendMessage hGrid, %MLG_SETCOLFORMAT,COL,VARPTR(RC)
END SUB

SUB MLG_FormatColDate(BYVAL hGrid AS DWORD,BYVAL COL AS LONG,BYVAL datetype AS LONG,OPT BYVAL justify AS LONG,OPT BYVAL mycolor AS LONG,OPT BYVAL writelock AS LONG)
   LOCAL totals AS LONG
   LOCAL totcols AS LONG
   LOCAL RC AS RowColDataType


   totals=SendMessage(hGrid,%MLG_GETROWCOLTOT,0,0)
   totcols=HIWRD(totals)
   IF COL < 1 OR COL > totcols THEN EXIT SUB
   SendMessage hGrid, %MLG_GETCOLFORMAT,COL,VARPTR(RC)
   RC.CellType = %MLG_TYPE_EDIT
   RC.FormatDate=datetype
   RC.FormatJustify=justify
   RC.FormatColor=mycolor
   RC.WriteLock=writelock
   SendMessage hGrid, %MLG_SETCOLFORMAT,COL,VARPTR(RC)
END SUB


SUB MLG_FormatColNumber(BYVAL hGrid AS DWORD,BYVAL COL AS LONG,BYVAL n AS SINGLE,OPT BYVAL justify AS LONG,OPT BYVAL mycolor AS LONG,OPT BYVAL writelock AS LONG)
   LOCAL totals AS LONG
   LOCAL totcols AS LONG
   LOCAL RC AS RowColDataType


   totals=SendMessage(hGrid,%MLG_GETROWCOLTOT,0,0)
   totcols=HIWRD(totals)
   IF COL < 1 OR COL > totcols THEN EXIT SUB
   SendMessage hGrid, %MLG_GETCOLFORMAT,COL,VARPTR(RC)
   RC.CellType = %MLG_TYPE_EDIT
   RC.FormatNumber=n
   RC.FormatJustify=justify
   RC.FormatColor=mycolor
   RC.WriteLock=writelock
   SendMessage hGrid, %MLG_SETCOLFORMAT,COL,VARPTR(RC)
END SUB

SUB MLG_FormatColEdit(BYVAL hGrid AS DWORD,BYVAL COL AS LONG,BYVAL mylength AS LONG,BYVAL mycase AS LONG,OPT BYVAL justify AS LONG,OPT BYVAL mycolor AS LONG,OPT BYVAL writelock AS LONG)
   LOCAL totals AS LONG
   LOCAL totcols AS LONG
   LOCAL RC AS RowColDataType

   totals=SendMessage(hGrid,%MLG_GETROWCOLTOT,0,0)
   totcols=HIWRD(totals)
   IF COL < 1 OR COL > totcols THEN EXIT SUB
   SendMessage hGrid, %MLG_GETCOLFORMAT,COL,VARPTR(RC)
   RC.CellType = 0
   RC.FormatLength=mylength
   RC.FormatCase=mycase
   RC.FormatJustify=justify
   RC.FormatColor=mycolor
   RC.WriteLock=writelock
   SendMessage hGrid, %MLG_SETCOLFORMAT,COL,VARPTR(RC)
END SUB

SUB MLG_FormatColTitles(BYVAL hGrid AS DWORD,liststr AS STRING)
   LOCAL totals AS LONG
   LOCAL totcols AS LONG
   LOCAL COUNT AS LONG
   LOCAL x AS LONG
   LOCAL zlist AS ASCIIZ * 255

   totals=SendMessage(hGrid,%MLG_GETROWCOLTOT,0,0)
   totcols=HIWRD(totals)

   COUNT=PARSECOUNT(liststr)
   COUNT=MIN&(COUNT,totcols)
   FOR x=1 TO COUNT
      zlist=PARSE$(liststr,x)
      SendMessage hGrid,%MLG_SETCELL,MAKLNG(0,x),VARPTR(zlist)
   NEXT x
END SUB

SUB MLG_SetRowRecNo(BYVAL hGrid AS DWORD,BYVAL ROW AS LONG,BYVAL RecNo AS LONG)
   LOCAL totals AS LONG
   LOCAL totrows AS LONG

   totals=SendMessage(hGrid,%MLG_GETROWCOLTOT,0,0)
   totrows=LOWRD(totals)
   IF ROW < 1 OR ROW > totrows THEN EXIT SUB

   SendMessage hGrid, %MLG_SETROWEXTRA,ROW,RecNo
END SUB

FUNCTION MLG_GetRowRecNo(BYVAL hGrid AS DWORD,BYVAL ROW AS LONG)AS LONG
   LOCAL totals AS LONG
   LOCAL totrows AS LONG

   FUNCTION=0
   totals=SendMessage(hGrid,%MLG_GETROWCOLTOT,0,0)
   totrows=LOWRD(totals)
   IF ROW < 1 OR ROW > totrows THEN EXIT FUNCTION

   FUNCTION=SendMessage(hGrid,%MLG_GETROWEXTRA,ROW,0)
END FUNCTION

SUB MLG_FormatRowHighLight(BYVAL hGrid AS DWORD,BYVAL ROW AS LONG,OPT BYVAL hilite AS LONG)
   LOCAL totals AS LONG
   LOCAL totrows AS LONG
   LOCAL RC AS RowColDataType

   totals=SendMessage(hGrid,%MLG_GETROWCOLTOT,0,0)
   totrows=LOWRD(totals)
   IF ROW < 1 OR ROW > totrows THEN EXIT SUB
   SendMessage hGrid, %MLG_GETROWFORMAT,ROW,VARPTR(RC)
   RC.FormatExtra = hilite
   SendMessage hGrid, %MLG_SETROWFORMAT,ROW,VARPTR(RC)
END SUB

SUB MLG_FormatColHighLight(BYVAL hGrid AS DWORD,BYVAL COL AS LONG,OPT BYVAL hilite AS LONG)
   LOCAL totals AS LONG
   LOCAL totcols AS LONG
   LOCAL RC AS RowColDataType

   totals=SendMessage(hGrid,%MLG_GETROWCOLTOT,0,0)
   totcols=HIWRD(totals)
   IF COL < 1 OR COL > totcols THEN EXIT SUB
   SendMessage hGrid, %MLG_GETCOLFORMAT,COL,VARPTR(RC)
   RC.FormatExtra = hilite
   SendMessage hGrid, %MLG_SETCOLFORMAT,COL,VARPTR(RC)
END SUB



SUB MLG_FormatGridex(BYVAL hGrid AS DWORD,BYVAL CellBkColorRGB AS LONG,BYVAL WindowBkColorRGB AS LONG, BYVAL CellLineColorRGB AS LONG, BYVAL hFont AS LONG, BYVAL hFontBold AS LONG, _
     BYVAL hFontItalic AS LONG,BYVAL cyCharEx AS LONG,BYVAL RCHighLightRGB AS LONG,BYVAL UserData AS LONG)
   LOCAL GI AS GridInit

   GI.hFont=hFont
   GI.hFontBold=hFontBold
   GI.hFontItalic=hFontItalic
   GI.cyCharEx=cyCharEx
   GI.CellBkColorRGB=CellBkColorRGB
   GI.CellLineColorRGB=CellLineColorRGB
   GI.WindowBkColorRGB=WindowBkColorRGB
   GI.RCHiLiteRGB=RCHighLightRGB
   GI.UserData=UserData
   SendMessage hGrid, %MLG_SETGRIDEXSTYLE, VARPTR(GI), 0
END SUB

SUB MLG_SetFormatOverrideRange(BYVAL hGrid AS DWORD,BYVAL row1 AS LONG,BYVAL col1 AS LONG,BYVAL row2 AS LONG, BYVAL col2 AS LONG, _
    BYVAL MyRGB_B AS LONG,BYVAL MyRGB_T AS LONG,BYVAL MyFont AS BYTE,BYVAL MyBorder AS BYTE,OPT MyUsing AS BYTE,OPT CellType AS BYTE, _
    OPT MyCase AS BYTE,OPT MyJustify AS BYTE,OPT WriteLock AS BYTE)

   LOCAL y1,x1,y2,x2,x,y AS LONG
   LOCAL fo AS FormatOverride
   LOCAL totrows, totcols,totals,c,doBox,doGrid,t AS LONG
   LOCAL f,b,u,tempxborder,ct,wl,cs,jt AS BYTE

   x1=MIN(col1,col2)
   y1=MIN(row1,row2)
   x2=MAX(col1,col2)
   y2=MAX(row1,row2)

   b=MyBorder
   IF b < 0 THEN b = 0
   IF b > 14 THEN b = 14  'slot 15 is unused at this time

   c=MyRGB_B
   IF c < 0 THEN c = 0
   IF c > 15 THEN c = 15

   t=MyRGB_T
   IF t < 0 THEN t = 0
   IF t > 15 THEN t = 15

   f=MyFont
   'msgbox str$(f)
   IF f < 0 THEN f = 0
   IF f > 255 THEN f = 0

   IF ISMISSING(MyUsing)=0 THEN
       u=MyUsing
       IF u < 0 THEN u = 0
       IF u > 15 THEN u = 15
   END IF

   IF ISMISSING(CellType)=0 THEN
       ct=CellType
       IF ct < 0 THEN ct = 0
       IF ct > 7 THEN ct = 7
   END IF

   IF ISMISSING(WriteLock)=0 THEN
       wl=WriteLock
       IF  wl > 0 THEN wl = 1 ELSE wl = 0
   END IF

   IF ISMISSING(MyJustify)=0 THEN
       jt=MyJustify
       IF jt < 0 THEN jt = 0
       IF jt > 2 THEN jt = 2
   END IF

   IF ISMISSING(MyCase)=0 THEN
       cs=MyCase
       IF cs < 0 THEN cs = 0
       IF cs > 2 THEN cs = 2
   END IF

   totals=SendMessage(hGrid,%MLG_GETFORMATOVERRIDEROWCOL,0,0)

   totcols=HIWRD(totals)
   IF x1 < 1 OR x2 > totcols THEN EXIT SUB
   totrows=LOWRD(totals)
   IF y1 < 1 OR y2 > totrows THEN EXIT SUB

   fo.CellColor = c + t * 16
   fo.CellFont=f
   fo.CellType= ct * 32 + wl * 16 + u
   fo.CellFormatExtra=b * 16 + cs * 4 + jt


   FOR x=x1 TO x2
       FOR y=y1 TO y2
            SendMessage hGrid, %MLG_SETFORMATOVERRIDE,MAKLNG(y,x),VARPTR(fo)
       NEXT y
   NEXT x

END SUB


SUB MLG_CopyRowBlockToClipBoard(BYVAL hGrid AS LONG,OPT BYVAL CopyColHeader AS LONG,OPT BYVAL AllowAllRowsCols AS LONG)
    LOCAL startblock,endblock AS LONG
    LOCAL totrows,totcols AS LONG
    LOCAL flag,I,x,y,rowlimit,skey AS LONG
    LOCAL mystr AS STRING
    LOCAL stLen AS LONG, hData AS LONG, hGlob AS LONG, mg AS LONG

   #IF %DEF(%WINAPI) 'This sub require WINAPI
    rowlimit = 5000   'Adjust to suit.  This prevents accidently trying to copy 2,000,000,000,000 rows

    SendMessage hGrid ,%MLG_GETROWCOLTOTEX,VARPTR(totrows),VARPTR(totcols)
    flag = SendMessage (hGrid, %MLG_GETROWCOLALLBLOCKSEL, 0 ,0)
    IF flag = 1 AND AllowAllRowsCols <> 0 THEN 'The whole grid has been selected - this could be a problem with selecting many NULL rows
       startblock = 1
       endblock = totrows
      ELSE   'The whole grid is not selected so check for a row block being selected
        SendMessage hGrid ,%MLG_GETROWBLOCKSELEX,VARPTR(startblock),VARPTR(endblock)
    END IF

    IF startblock > 0 AND endblock > 0 AND (endblock - startblock) < rowlimit THEN
       'Only copy visible columns
       DIM widths(totcols) AS LONG
       mystr=""
       FOR I = 0 TO totcols
         widths(I)=SendMessage(hGrid,%MLG_GETCOLWIDTH,I,0)
       NEXT I

       IF CopyColHeader > 0 THEN
          FOR x= 0 TO totcols
             IF widths(x) > 0 THEN
                 mystr=mystr & MLG_Get(hGrid,y,x)& $TAB
             END IF
           NEXT x
           mystr=mystr & $CRLF
       END IF
       MOUSEPTR 11 'Hourglass - this needs a progress bar like MS Access
       FOR y = startblock TO endblock
           skey=GetKeyState(%VK_ESCAPE) AND &H8000
           IF skey<>0 THEN EXIT SUB
           FOR x= 0 TO totcols
             IF widths(x) > 0 THEN
                 mystr=mystr & MLG_Get(hGrid,y,x)& $TAB
             END IF
           NEXT x
           mystr=mystr & $CRLF
       NEXT y
       MOUSEPTR 1 'Arrow
    END IF


    stLen = LEN(mystr)
    ' Create a global memory object and copy the data into it
    hData = GlobalAlloc(%GMEM_MOVEABLE OR %GMEM_DDESHARE, stLen + 1)
    hGlob = GlobalLock(hData)
    mg = STRPTR(mystr)
    MoveMemory BYVAL hGlob, BYVAL mg, BYVAL stLen
    GlobalUnlock hData

     ' Open the clipboard
    IF ISFALSE (OpenClipboard(%NULL)) THEN
        GlobalFree hData
        EXIT SUB
    END IF

    ' Paste the data into the clipboard
    EmptyClipboard
    SetClipboardData %CF_TEXT, hData
    CloseClipboard
 #ENDIF

END SUB

SUB MLG_HideColBlock(BYVAL hGrid AS LONG)
    LOCAL startblock,endblock AS LONG
    LOCAL totrows,totcols AS LONG
    LOCAL flag,I,K AS LONG

    SendMessage hGrid ,%MLG_GETROWCOLTOTEX,VARPTR(totrows),VARPTR(totcols)
    flag = SendMessage (hGrid, %MLG_GETROWCOLALLBLOCKSEL, 0 ,0)
    IF flag = 1 THEN 'The whole grid has been selected - this not allowed
       startblock = 0
       endblock = 0
      ELSE   'The whole grid is not selected so check for a column block being selected
        SendMessage hGrid ,%MLG_GETCOLBLOCKSELEX,VARPTR(startblock),VARPTR(endblock)
        IF startblock > 0 AND endblock > 0 THEN

           FOR I = startblock TO endblock 'Do not temporarily hide a column already at zero width
             K = SendMessage(hGrid,%MLG_GETCOLWIDTH,I,0)
             IF K <> 0 THEN SendMessage hGrid,%MLG_HIDECOLUMN ,%MLG_HIDECOL,I
           NEXT I

        END IF
    END IF
END SUB

SUB MLG_SetColMaxLen(BYVAL hGrid AS LONG,BYVAL COL AS LONG,OPT BYVAL ConsiderHeader AS LONG )
    LOCAL hDC AS LONG
    LOCAL mysize AS SIZEL
    LOCAL result AS LONG
    LOCAL s AS ASCIIZ * 255
    LOCAL TotRows AS LONG
    LOCAL TotCols AS LONG
    LOCAL maxlen AS LONG
    LOCAL myrow,mycol AS LONG
    LOCAL mycount AS LONG
    LOCAL startRow, endRow AS LONG
    maxlen = 0

    SendMessage (hGrid,%MLG_GETROWCOLTOTEX,VARPTR(TotRows),VARPTR(TotCols))
    endRow=TotRows : StartRow = 1
    IF ConsiderHeader <> 0 THEN
         StartRow = 0
        ELSE
         StartRow = 1
    END IF
    IF COL < 1 OR COL > TotCols THEN EXIT SUB

    hDC=GetDC(hGrid)

    FOR mycount = StartRow TO EndRow
      s=MLG_Get(hGrid,mycount,COL)
      result=GetTextExtentPoint32(hDC,s,LEN(s),mysize)
      maxlen = MAX(maxLen,mysize.cx)
    NEXT mycount
    maxlen = MIN(maxlen,255)
    IF maxlen > 5 THEN
        SendMessage hGrid,%MLG_SETCOLWIDTH,COL,maxlen
        SendMessage hGrid,%MLG_REFRESH,0,0
    END IF
    ReleaseDC(hGrid,hDC)
END SUB

#IF %DEF(%SQLITE)
DECLARE FUNCTION    sqlite3_open CDECL LIB "sqlite3.dll" ALIAS "sqlite3_open" (zFilename AS ASCIIZ, hSQLite AS LONG) AS LONG
DECLARE SUB         sqlite3_close CDECL LIB "sqlite3.dll" ALIAS "sqlite3_close" (BYVAL hSQLite AS LONG)
DECLARE FUNCTION    sqlite_get_table CDECL LIB "sqlite3.dll" ALIAS "sqlite3_get_table" (BYVAL hSQLite AS LONG, szSql AS ASCIIZ, lpTable AS LONG, nRow AS LONG, nColumn AS LONG, lpErrMsg AS LONG) AS LONG
DECLARE FUNCTION    sqlite_free_table CDECL LIB "sqlite3.dll" ALIAS "sqlite3_free_table" (BYVAL lpTable AS LONG) AS LONG
DECLARE FUNCTION    sqlite3_exec CDECL LIB "sqlite3.dll" ALIAS "sqlite3_exec" (BYVAL hSQLite AS LONG, szSql AS ASCIIZ, BYVAL sqlite_callback AS LONG, cbParam AS LONG, lpErrMsg AS LONG) AS LONG

'==============================================================================
FUNCTION pbQuery(hDB AS LONG, sSql AS STRING, arrResults() AS STRING) AS LONG
    REGISTER i AS LONG
    LOCAL lpTable    AS LONG PTR     ' Array of fields returned from get_table (starts with column names)
    LOCAL nRows      AS LONG         ' Number of rows in returned recordset
    LOCAL nColumns   AS LONG         ' Number of columns in returned recordset
    LOCAL lpErrorSz  AS LONG         ' Error msg
    LOCAL zField     AS ASCIIZ PTR   ' Field return from get_table (element in lpTable array)
    LOCAL iFields    AS LONG         ' Number of fields returned by get table
    LOCAL iRow       AS LONG
    LOCAL iCol       AS LONG
    LOCAL iResult    AS LONG         ' Number of rows or error returned by my function

    IF sqlite_get_table(hDB, BYVAL STRPTR(sSQL), lpTable, nRows, nColumns, lpErrorSz) = 0 THEN 'Succeeded
        IF nRows = 0 THEN GOTO Bail

        iFields = ((nRows+1) * nColumns)-1
        REDIM arrResults(nRows, nColumns-1)

        FOR i = 0 TO iFields
            zField = @lpTable[i]
            arrResults(iRow, iCol) = @zField
            INCR iCol : IF iCol = nColumns THEN iCol = 0
            IF (i+1) MOD nColumns = 0 THEN INCR iRow
        NEXT i
    ELSE
        iResult = -1 : GOTO Bail
    END IF

    FUNCTION = nRows

Bail:
    sqlite_free_table lpTable

END FUNCTION

#ENDIF
