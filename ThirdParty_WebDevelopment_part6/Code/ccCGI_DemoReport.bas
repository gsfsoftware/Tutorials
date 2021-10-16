' ccCGI_DemoReport.bas
' display HTML inside an existing web page

#COMPILE EXE
#DIM ALL
#DEBUG ERROR ON
'
#INCLUDE "Win32api.inc"
#INCLUDE "../Libraries/PBCGI.INC"
#INCLUDE "../Libraries/PB_FileHandlingRoutines.inc"

FUNCTION PBMAIN () AS LONG
  LOCAL strInput AS STRING  ' incoming URL
  DIM strParam(1) AS STRING ' array for parameters
  LOCAL lngPcount AS LONG   ' parameter count
  LOCAL strFile AS STRING   ' file to display
  LOCAL lngR AS LONG        ' row counter
  '
   ' Read from STDIN
  strInput = ReadCGI
  'WriteCGI "here"
  ' Count and parse the parameters into an array
  lngPcount = ParseParams(strInput, strParam())
  '
  IF lngPcount > 0 THEN
  ' pick up each parameter
    FOR lngR = 1 TO UBOUND(strParam)
      SELECT CASE lngR
        CASE 1
        ' random number to ensure no caching = ignore this
        CASE 2
          strFile = DecodeCGI(strParam(lngR))
          strFile = PARSE$(strFile,"=",2)
          WriteCGI  funGetUserList_v3(strFile)
      END SELECT
      '
    NEXT lngR
  ELSE
  ' give nothing back
    WriteCGI "no data"
  END IF
  '
END FUNCTION
'
FUNCTION funGetUserList_v3(strFile AS STRING) AS STRING
  LOCAL strHTML AS STRING
  LOCAL lngR AS LONG
  LOCAL lngC AS LONG
  LOCAL strFilename AS STRING
  DIM a_strWork() AS STRING
  '
  '
  LOCAL strTableDef AS STRING
  LOCAL strTableRowHeader AS STRING
  LOCAL strBackColour AS STRING
  '
  strTableDef = "<table class=""TableList TableWidth"">"
  strTableRowHeader = "<tr class=""TableListHeader"">
  '
  strFilename = EXE.PATH$ & "Data\" & strFile
  '
  IF ISTRUE funReadTheCSVFileIntoAnArray(strFilename, _
                               BYREF a_strWork()) THEN
  ' start a table
    strHTML = strHTML & strTableDef
    FOR lngR = 0 TO UBOUND(a_strWork,1)
      ' start a new row within the table
      IF lngR = 0 THEN
      ' this is the header row so set the colour scheme
        strHTML = strHTML & strTableRowHeader
      ELSE
        IF (lngR MOD 2) = 0 THEN
        ' set the colour banding
          strBackColour = " class=""NewBandingEven"" "
        ELSE
          strBackColour = " class=""NewBandingOdd"" "
        END IF
        ' start the row with a background colour for all
        ' cells
        strHTML = strHTML & "<tr" & strBackColour & ">"
        '
      END IF
      '
      FOR lngC = 1 TO UBOUND(a_strWork,2)
        ' enter a table data element
        strHTML = strHTML & "<td>" & a_strWork(lngR,lngC) & "</td>"
      NEXT lngC
      ' close off a row in the table
      strHTML = strHTML & "</tr>"
      '
    NEXT lngR
    ' close off the table and html document
    strHTML = strHTML & "</table>
    FUNCTION = strHTML
  ELSE
    FUNCTION = "No data"
  END IF
  '
END FUNCTION
