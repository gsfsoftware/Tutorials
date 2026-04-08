#COMPILE EXE
#DIM ALL
' Demo_3.bas
' using the console
'
#INCLUDE "win32api.inc"
#INCLUDE "PB_CommonConsoleFunctions.inc"
'
' set up constants
$Header = "Company             |Price|Change| Today|"
%MaxCompanies = 10  ' number of companies
%MaxCycles    = 15  ' number of processing cycles
'
TYPE udtCompanies
  Name AS STRING * 20
  CurrentPrice AS LONG
  LastPrice AS LONG
  DayStart AS LONG
END TYPE
'
GLOBAL g_aCompanies() AS udtCompanies
'
FUNCTION PBMAIN () AS LONG
'
  LOCAL strInput AS STRING
  '
  RANDOMIZE TIMER  ' Prep the random numbers
  '
  REDIM g_aCompanies(1 TO %MaxCompanies) AS udtCompanies
  '
  PREFIX "con."
    CAPTION$ = "Console Demo"
    COLOR %Colour.Light_Green,-1 ' set forground colour to light green
    VIRTUAL = 80, 120  ' set the columns and rows for the console
    LOC = 0,0          ' set the screen location of the console
  END PREFIX
  '
  funPrepCompanies()
  '
  funStartProcessing()
  '
  PREFIX "CON."
    COLOR %Colour.Green,%Colour.Black
    CELL = %MaxCompanies + 5, 1
    STDOUT "Press any key to continue"
    WAITKEY$ TO strInput
  END PREFIX
  '
  ' exiting app
  funExitApp(3)
  '
END FUNCTION
'
FUNCTION funPrepCompanies() AS LONG
  LOCAL lngC AS LONG
  DIM a_strName1(1 TO 10) AS STRING
  DIM a_strName2(1 TO 10) AS STRING
  LOCAL strName AS STRING
  '
  LOCAL lngRnd1,lngRnd2 AS LONG
  ARRAY ASSIGN a_strName1() = "RED","BLUE","GREEN","BLACK","YELLOW", _
                              "BROWN","PURPLE","CYAN","GREY","WHITE"
                              '
  ARRAY ASSIGN a_strName2() = "Mining","Banking","Food","Shipping","Travel", _
                              "Construction","Software","Finance","Retail","Engineering"
                              '
  ' populate the global array
  FOR lngC = 1 TO %MaxCompanies
    strName = ""
    WHILE strName = ""
      lngRnd1 = RND(1,%MaxCompanies)
      lngRnd2 = RND(1,%MaxCompanies)
      strName = a_strName1(lngRnd1) & " " & a_strName2(lngRnd1)
      '
      IF ISTRUE funDuplicate(strName) THEN
        strName = ""
      END IF
      '
    WEND
    '
    g_aCompanies(lngC).Name = strName
    '
    ' initialise price
    PREFIX "g_aCompanies(lngC)."
      CurrentPrice = 1000
      LastPrice    = g_aCompanies(lngC).CurrentPrice
      DayStart     = g_aCompanies(lngC).CurrentPrice
    END PREFIX
    '
  NEXT lngC
  '
END FUNCTION
'
FUNCTION funDuplicate(strName AS STRING) AS LONG
' is this company name a duplicate?
  LOCAL lngC AS LONG
  '
  IF strName = "" THEN
    FUNCTION = %TRUE
  ELSE
  ' look for a match
    FOR lngC = 1 TO %MaxCompanies
      IF TRIM$(g_aCompanies(lngC).Name) = TRIM$(strName) THEN
        FUNCTION = %TRUE
        EXIT FUNCTION
      END IF
    NEXT lngC
    '
  END IF
END FUNCTION
'
FUNCTION funStartProcessing() AS LONG
' start the processing
  LOCAL lngR AS LONG ' number of loops
  '
  funPrepareScreen()
  '
  FOR lngR = 1 TO %MaxCycles
    funDisplayPrices()
    SLEEP 1000
  NEXT lngR
  '
END FUNCTION
'
FUNCTION funPrepareScreen() AS LONG
  LOCAL lngRow, lngColumn AS LONG
  '
  ' set to page 2
  CON.PAGE.ACTIVE = 2
  CON.CLS   ' clear the console
  '
  lngRow = 1: lngColumn = 1
  CON.CELL = lngRow, lngColumn
  ' print the header row
  CON.PRINT $Header
  CON.PRINT STRING$(LEN($Header),"_")
  '
  ' now copy over page 1
  CON.PCOPY(2, 1)
  CON.PAGE.VISIBLE = 1
  CON.PAGE.ACTIVE = 1
  '
END FUNCTION
'
FUNCTION funDisplayPrices() AS LONG
' display the current prices
  LOCAL lngC AS LONG
  LOCAL lngRow, lngColumn AS LONG
  LOCAL lngDiff AS LONG
  LOCAL strDifference AS STRING
  '
  lngRow = 3: lngColumn = 1
  CON.CELL = lngRow, lngColumn
  '
  FOR lngC = 1 TO %MaxCompanies
    ' change background display colour
    IF lngC MOD 2 = 0 THEN
      CON.COLOR %Colour.Black,%Colour.Gray
    ELSE
      CON.COLOR %Colour.Green,%Colour.Black
    END IF
    '  position the cursor
    INCR lngRow
    lngColumn = 1
    CON.CELL = lngRow, lngColumn
    '  print company details
    CON.PRINT g_aCompanies(lngC).Name;
    CON.PRINT g_aCompanies(lngC).CurrentPrice;
    ' get the difference in price
    lngDiff = g_aCompanies(lngC).CurrentPrice - _
              g_aCompanies(lngC).LastPrice
              '
    ' format the difference value
    strDifference = SPACE$(7)
    RSET strDifference = FORMAT$(lngDiff,"+####;-####")
    '
    ' set the colours
    IF lngDiff < 0 THEN
      CON.COLOR %Colour.Red,%Colour.Black
    ELSEIF lngDiff = 0 THEN
      CON.COLOR %Colour.White,%Colour.Black
    ELSE
      CON.COLOR %Colour.Green,%Colour.Black
    END IF
    '
    lngColumn = 27 ' set the column
    CON.CELL = lngRow, lngColumn
    '
    CON.PRINT strDifference;
    CON.COLOR %Colour.Green,-1
    '
    ' now report since start of day
    lngDiff = g_aCompanies(lngC).CurrentPrice - _
              g_aCompanies(lngC).DayStart
              '
    strDifference = SPACE$(7)
    RSET strDifference = FORMAT$(lngDiff,"+####;-####")
    '
    ' set the colours
    IF lngDiff < 0 THEN
      CON.COLOR %Colour.Red,%Colour.Black
    ELSEIF lngDiff = 0 THEN
      CON.COLOR %Colour.White,%Colour.Black
    ELSE
      CON.COLOR %Colour.Green,%Colour.Black
    END IF
    '
    lngColumn = 34 ' set the column
    CON.CELL = lngRow, lngColumn
    '
    CON.PRINT strDifference;
    CON.COLOR %Colour.Green,-1
    '
    ' advance prices
    g_aCompanies(lngC).LastPrice = g_aCompanies(lngC).CurrentPrice
    g_aCompanies(lngC).CurrentPrice = g_aCompanies(lngC).CurrentPrice + _
                                      RND(1,5) - RND(1,5)
                                      '
  NEXT lngC
  '
END FUNCTION
