' ccCGI_Demo1.bas
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

  funCreateWebPage_v3()

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
