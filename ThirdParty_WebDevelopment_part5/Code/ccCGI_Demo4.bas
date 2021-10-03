' ccCGI_Demo4.bas
' CGI demo application
'
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
  ' debug the app by displaying a variable
  'WriteCGI "<html>" & strInput & "</html>"
  'exit function
  '
  ' Count and parse the parameters into an array
  lngPcount = ParseParams(strInput, strParam())
  '
  IF lngPcount > 0 THEN
  ' pick up each parameter
    FOR lngR = 1 TO UBOUND(strParam)
       SELECT CASE lngR
        CASE 1
        ' extract the first parameter
          strFile = DecodeCGI(strParam(lngR))
          IF PARSE$(strFile,"=",1) = "report" THEN
          ' set the name of the file to load and display
            strFile = PARSE$(strFile,"=",2)
          END IF
          '
        CASE ELSE
        ' ignore any other parameters
      END SELECT

    NEXT lngR
    'display the file on the web page
    funCreateWebPage_v4(strFile)
    ' debug code
    'WriteCGI "<html>" & strFile & "</html>"
    'exit function
  ELSE
  ' get user to select the page needed
    funCreateIndexPage_v1()
  END IF
  '
END FUNCTION
'
FUNCTION funCreateIndexPage_v1() AS LONG
  LOCAL strHTML AS STRING
  LOCAL strTemplate AS STRING
  ' set the template to load
  strTemplate = EXE.PATH$ & "Page_Templates\Index.txt"
  ' read the template file into a variable
  strHTML = funBinaryFileAsString(strTemplate)
  '
  REPLACE "@@@DATA@@@" WITH funGetPages_v1() IN strHTML
  '
  ' dump out html to debug file
  'funAppendToFile "debug.txt",strHTML
  '
  ' write the HTML back to the browser
  WriteCGI strHTML
  '
END FUNCTION
'
FUNCTION funGetPages_v1() AS STRING
' return a form with the pages the user can select
  LOCAL strHTML AS STRING
  ' build up the HTML form
  strHTML = "<form name=" & $DQ & "Pick page" & $DQ & " " & _
            "method=" & $DQ & "post" & $DQ & " " & _
            "action=" & $DQ & "http://quad003/CGI_BIN/ccCGI_Demo4.exe" & $DQ & "> "
            ' add on the drop down list
  strHTML = strHTML & $CRLF & _
            "<p>Please Select which report you require " & $CRLF & _
            "<select name=" & $DQ & "report" & $DQ & "> " & $CRLF & _
            "<option value=" & $DQ & "MyFile.csv" & $DQ & ">No Balances</option>" & " " & $CRLF & _
            "<option value=" & $DQ & "MyFile2.csv" & $DQ & ">With Balances</option>" & " " & $CRLF & _
            "</select></p>"
            ' add on the Submit button
  strHTML = strHTML & "<input type=" & $DQ & "submit" & $DQ & " " & _
            "title=" & $DQ & "Click here to request your report" & $DQ & " " & _
            "value=" & $DQ & "Get Report" & $DQ & "/>"
            ' finish the form
  strHTML = strHTML & "</form>"
  '  pass back the form html code to the calling function
  FUNCTION = strHTML
  '
END FUNCTION
'
FUNCTION funCreateWebPage_v4(strFile AS STRING) AS STRING
  LOCAL strHTML AS STRING
  LOCAL strTemplate AS STRING
  '
  strTemplate = EXE.PATH$ & "Page_Templates\UserList.txt"
  '
  strHTML = funBinaryFileAsString(strTemplate)
  '
  REPLACE "@@@DATA@@@" WITH funGetUserList_v3(strFile) IN strHTML
  WriteCGI strHTML
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
'
FUNCTION funGetUserList_v2() AS STRING
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
  strFilename = EXE.PATH$ & "Data\MyFile.csv"
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
'
FUNCTION funGetUserList() AS STRING
  LOCAL strHTML AS STRING
  LOCAL lngR AS LONG
  LOCAL lngC AS LONG
  LOCAL strFilename AS STRING
  DIM a_strWork() AS STRING
  '
  strFilename = EXE.PATH$ & "Data\MyFile.csv"
  '
  IF ISTRUE funReadTheCSVFileIntoAnArray(strFilename, _
                               BYREF a_strWork()) THEN
  ' start a table
    strHTML = strHTML & "<table border=1>"
    FOR lngR = 0 TO UBOUND(a_strWork,1)
      ' start a new row within the table
      strHTML = strHTML & "<tr>"
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
'
FUNCTION funCreateWebPage() AS LONG
  LOCAL strHTML AS STRING
  '
  strHTML = "<html><body>" & _
            "<h2><p>Welcome to our CGI generated webpage</p></h2>" & _
            "</body></html>"
            '
  writeCGI strHTML

END FUNCTION
'
FUNCTION funCreateWebPage_v2() AS LONG
  LOCAL strHTML AS STRING
  '
  strHTML = "<html><body>" & _
            "<h2><p>Welcome to our CGI generated webpage " & _
            "generated at " & TIME$ & "</p></h2>" & _
            "</body></html>"
            '
  writeCGI strHTML
  '
END FUNCTION
'
FUNCTION funCreateWebPage_v3() AS LONG
' read a file and display on the web page
'
  DIM a_strWork() AS STRING
  LOCAL lngR AS LONG
  LOCAL lngC AS LONG
  LOCAL strFilename AS STRING
  LOCAL strHTML AS STRING
  '
  strFilename = EXE.PATH$ & "Data\MyFile.csv"
  '
  strHTML = "<html><body>" & _
            "<h2><p>Output of data table</p></h2>"
  '
  IF ISTRUE funReadTheCSVFileIntoAnArray(strFilename, _
                               BYREF a_strWork()) THEN
  ' start a table
    strHTML = strHTML & "<table border=1>"
    FOR lngR = 0 TO UBOUND(a_strWork,1)
      ' start a new row within the table
      strHTML = strHTML & "<tr>"
      FOR lngC = 1 TO UBOUND(a_strWork,2)
        ' enter a table data element
        strHTML = strHTML & "<td>" & a_strWork(lngR,lngC) & "</td>"
      NEXT lngC
      ' close off a row in the table
      strHTML = strHTML & "</tr>"
      '
    NEXT lngR
    ' close off the table and html document
    strHTML = strHTML & "</table></body></html>"
    ' now sent the document back to the web server
    writeCGI strHTML
  '
  ELSE
  ' write and error document
    writeCGI "<html><body><h2><p>" & _
             "Unable to read the data file" & _
             "</h2></p></body></html>"
  END IF
'
END FUNCTION
