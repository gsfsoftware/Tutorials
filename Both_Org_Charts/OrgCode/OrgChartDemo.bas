#COMPILE EXE
#DIM ALL
#DEBUG ERROR ON
'
#TOOLS OFF
'
' include the common display library
#INCLUDE "win32api.inc"
#INCLUDE "CommonDisplay.inc"
#INCLUDE "PB_FileHandlingRoutines.inc"
'
$CompanyName = "GsfSoftware"
'
$Header = "<!DOCTYPE html> " & $CRLF & _
          "<html lang=""en"" > " & $CRLF & _
          "<head>" & $CRLF & _
          "<meta charset=""UTF-8""> " & $CRLF & _
          "<title>Org Chart</title>" & $CRLF & _
          "<link rel=""stylesheet"" href=""./style.css""> " & $CRLF & _
          "</head><body><figure>" & $CRLF
          '
$Footer = "</figure></body></html>" & $CRLF
'
$HTMLOutput = "OrgChart.html"
'
FUNCTION PBMAIN () AS LONG
' the main PB function that is the first to be executed
  funPrepOutput("Org chart demo",0,0,40,120)
  '
  funLog("Org chart demo")
  '
  funGenerateOrgChart(EXE.PATH$ & "StaffList.txt", _
                      EXE.PATH$ & $HTMLOutput )
  '
  funWait()
  '
END FUNCTION
'
FUNCTION funGenerateOrgChart(strFile AS STRING, _
                             strOutput AS STRING) AS LONG
' generate an Organisation chart from the strFile
  TRY
  ' wipe any previous output
    KILL strOutput
  CATCH
  FINALLY
  END TRY
  '
  ' save the html to file
  funAddToHTML($Header & _
            "<figcaption><h2>" & $CompanyName & " Hierarchy<h2></figcaption>" & _
            "<ul class=""tree"">" & $CRLF)
            '
  ' build the tree into the web page
  funBuildTree(strFile)
            '
  funAddToHTML($Footer)
  '
  funLog("Building Tree completed")
  '
END FUNCTION
'
FUNCTION funAddToHTML(strHTML AS STRING) AS LONG
' add this string to html file
  funAppendToFile(EXE.PATH$ & $HTMLOutput,strHTML)
END FUNCTION
'
FUNCTION funBuildTree(strFile AS STRING) AS LONG
' send HTML data to the output file
  DIM a_strData() AS STRING  ' staff data array
  LOCAL lngS AS LONG         ' staff counter
  LOCAL lngElements AS LONG  ' number of elements
  LOCAL lngPrevElements AS LONG ' prev record element count
  LOCAL strName AS STRING    ' name of staff member
  '
  IF ISTRUE funReadTheFileIntoAnArray(strFile, _
                                    a_strData()) THEN
  ' file loaded
     FOR lngS = 0 TO UBOUND(a_strData)
     ' save the html to file
       SELECT CASE lngS
         CASE 0
           strName = PARSE$(a_strData(lngS),"\",-1)
           funAddToHTML("<li><span>CEO -" & strName & "</span>" )
         CASE ELSE
           ' get staff name
          strName = PARSE$(a_strData(lngS),"\",-1)
          '
          IF strName = "" THEN ITERATE
          '
          ' count elements
          lngElements = PARSECOUNT(a_strData(lngS),"\")
          lngPrevElements = PARSECOUNT(a_strData(lngS-1),"\")
          '
          SELECT CASE lngElements - lngPrevElements
            CASE >0
            ' element count going up
              funAddToHTML("<UL>")
            CASE <0
            ' element count going down
              funAddToHTML("</UL></LI>")
          END SELECT
          '
          funAddToHTML("<li><span>" & strName & "</span>" )
          '
       END SELECT
     '
     NEXT lngS
     '
     funAddToHTML("</li></ul>")
  '
  ELSE
    funLog("unable to load staff list")
  END IF
  '
END FUNCTION
