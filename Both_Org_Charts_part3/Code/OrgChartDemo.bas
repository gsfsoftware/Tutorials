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
$CSVInput = "HR_staff_list.csv"  ' name of the input HR CSV file
$StaffList = "StaffList.txt"     ' name of the formatted staff list
'
FUNCTION PBMAIN () AS LONG
' the main PB function that is the first to be executed
  funPrepOutput("Org chart demo",0,0,40,120)
  '
  funLog("Org chart demo")
  '
  ' convert the hr file to formatted staff list
  funConvertHRFile(EXE.PATH$ & $CSVInput, _
                   EXE.PATH$ & $StaffList)
  '
  funGenerateOrgChart(EXE.PATH$ & "StaffList.txt", _
                      EXE.PATH$ & $HTMLOutput )
  '
  ' now generate a department file
  LOCAL strDept AS STRING
  strDept = "Marketing"
  '
  funConvertHRFile(EXE.PATH$ & $CSVInput, _
                   EXE.PATH$ & "Marketing.txt", _
                   strDept)
                   '
  funGenerateOrgChart(EXE.PATH$ & "Marketing.txt", _
                      EXE.PATH$ & "Marketing.html" )
  funWait()
  '
END FUNCTION
'
FUNCTION funConvertHRFile(strInput AS STRING, _
                          strOutput AS STRING, _
                          OPTIONAL strDept AS STRING) AS LONG
' convert the HR file
  DIM a_strInput() AS STRING
  DIM a_strOutput AS STRING
  LOCAL strFilteredDept AS STRING
  '
  TRY
  ' wipe any previous output
    KILL strOutput
  CATCH
  FINALLY
  END TRY
  '
  IF ISMISSING(strDept) THEN
  ' take all departments
    strFilteredDept = ""
  ELSE
  ' filter by this dept
    strFilteredDept = strDept
  END IF
  '
  IF ISTRUE funReadTheFileIntoAnArray(strInput, _
                                      a_strInput()) THEN
  ' file loaded
  '
  ' prepare the Output array
    REDIM a_strOutput(0 TO UBOUND(a_strInput)-1) AS STRING
    '
    LOCAL lngR AS LONG            ' loop counter
    LOCAL strName AS STRING       ' staff name
    LOCAL strManagerUID AS STRING ' managers UID
    LOCAL strHierarchy AS STRING  ' Hierarchy string
    LOCAL lngCounter AS LONG      ' place counter in output array
    LOCAL strDepartment AS STRING ' name of department
    '
    FOR lngR = 1 TO UBOUND(a_strInput)
    '  for each record in input file
      strDepartment = PARSE$(a_strInput(lngR),"",5)
      '
      ' test for dept filter
      IF strFilteredDept <> "" THEN
      ' are we filtering by dept?
        IF strFilteredDept <> strDepartment THEN
          ITERATE
        END IF
        '
      END IF
      ' get name
      strName = PARSE$(a_strInput(lngR),"",2) & "~" & strDepartment
      '
      ' get managers UID
      strManagerUID = PARSE$(a_strInput(lngR),"",4)
      '
      IF strManagerUID <> "" THEN
      ' only if they have a manager
        strHierarchy = funGetHierarchy(a_strInput(),strManagerUID ) & _
                                       "\" & strName
      ELSE
        strHierarchy = strName
      END IF
      '
       ' now add hierarchy string to output array
      a_strOutput(lngCounter) = strHierarchy
      INCR lngCounter
      '
    NEXT lngR
    '
    ' now sort the output array
    ARRAY SORT a_strOutput(), COLLATE UCASE, ASCEND
    '
    ' now save array to disk
    FUNCTION = funArrayDump(strOutput,a_strOutput(),%TRUE)
    '
  ELSE
  ' file cannot be loaded
    funLog("unable to load HR file list")
  END IF
  '
END FUNCTION
'
FUNCTION funGetHierarchy(BYREF a_strInput() AS STRING, _
                         strManagerUID AS STRING ) AS STRING
' return the hierarchy string for this member of staff
  ' take the manager UID, find the name and recurse through
  ' the a_strInput() array
  LOCAL strManagersName AS STRING
  LOCAL strHierarchy AS STRING
  '
  strManagersName = funGetManagerName(strManagerUID, _
                                      a_strInput() )
  '
  strHierarchy = strManagersName
  '
  WHILE strManagersName <> ""
  ' first find name of manager and get back their manager
    strManagersName = funGetManagerName(strManagerUID, _
                                        a_strInput() )
    IF strManagersName <> "" THEN
    ' add to hierarchy if not blank
      strHierarchy = strManagersName & "\" & strHierarchy
    END IF
    '
  WEND
  '
  ' return the build up hierarchy
  FUNCTION = RTRIM$(strHierarchy,"\")
  '
END FUNCTION
'
FUNCTION funGetManagerName(strManagerUID AS STRING, _
                           BYREF a_strInput() AS STRING) AS STRING
' return the managers name if found
  LOCAL lngR AS LONG
  LOCAL strDepartment AS STRING
  '
  FOR lngR = LBOUND(a_strInput) TO UBOUND(a_strInput)
    IF PARSE$(a_strInput(lngR),"",1) = strManagerUID THEN
    ' found the UID
      ' get the manager of this staff member
      strManagerUID = PARSE$(a_strInput(lngR),"",4)
      ' get the name of this staff member
      strDepartment = PARSE$(a_strInput(lngR),"",5)
      FUNCTION = PARSE$(a_strInput(lngR),"",2) & "~" & strDepartment
      EXIT FOR
    END IF
  NEXT lngR
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
            "<ul class=""tree"">" & $CRLF,strOutput)
            '
  ' build the tree into the web page
  funBuildTree(strFile,strOutput)
            '
  funAddToHTML($Footer,strOutput)
  '
  funLog("Building Tree completed")
  '
END FUNCTION
'
FUNCTION funAddToHTML(strHTML AS STRING, _
                      strOutput AS STRING) AS LONG
' add this string to html file
  funAppendToFile(strOutput,strHTML)
END FUNCTION
'
FUNCTION funBuildTree(strFile AS STRING, _
                      strOutput AS STRING) AS LONG
' send HTML data to the output file
  DIM a_strData() AS STRING  ' staff data array
  LOCAL lngS AS LONG         ' staff counter
  LOCAL lngElements AS LONG  ' number of elements
  LOCAL lngPrevElements AS LONG ' prev record element count
  LOCAL strName AS STRING    ' name of staff member
  LOCAL strColour AS STRING     ' colour of cell
  LOCAL strDepartment AS STRING ' department name
  LOCAL strOldDepartment AS STRING ' previous department
  LOCAL strDepartmentHeader AS STRING ' department header (if needed)
  '
  IF ISTRUE funReadTheFileIntoAnArray(strFile, _
                                    a_strData()) THEN
  ' file loaded
     FOR lngS = 0 TO UBOUND(a_strData)
     ' save the html to file
       SELECT CASE lngS
         CASE 0
           strName = PARSE$(a_strData(lngS),"\",-1)
           strDepartment = PARSE$(strName,"~",2)
           strName = PARSE$(strName,"~",1)
           funAddToHTML("<li><span>" & strDepartment & _
                        "<BR>" & strName & "</span>",strOutput )
         CASE ELSE
           '
          strOldDepartment = PARSE$(a_strData(lngS),"\",-2)
          strOldDepartment = PARSE$(strOldDepartment,"~",2)
           ' get staff name
          strName = PARSE$(a_strData(lngS),"\",-1)
          strDepartment = PARSE$(strName,"~",2)
          '
          IF strDepartment <> strOldDepartment THEN
          ' change of department
            strDepartmentHeader = strDepartment & "<BR>"
          ELSE
            strDepartmentHeader = ""
          END IF
          '
          ' add dept header to front of name
          strName = strDepartmentHeader & PARSE$(strName,"~",1)
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
              funAddToHTML("<UL>",strOutput)
            CASE <0
            ' element count going down
              funAddToHTML(REPEAT$(lngPrevElements-lngElements, _
                           "</LI></UL>"),strOutput)
              '
          END SELECT
          '
          strColour = " style=""background-color:" & _
                      funGetDeptColour(strDepartment, strName) & ";"""
                      '
          funAddToHTML("<li><span" & strColour & ">" & _
                       strName & "</span>",strOutput )
          '
       END SELECT
     '
     NEXT lngS
     '
     funAddToHTML("</li></ul>",strOutput)
  '
  ELSE
    funLog("unable to load staff list")
  END IF
  '
END FUNCTION
'
FUNCTION funGetDeptColour(strDepartment AS STRING, _
                          strName AS STRING) AS STRING
' return a colour for the department
  LOCAL strColour AS STRING
  '
  IF MCASE$(strName) = "Vacancy" THEN
  ' handle vacancies
    strColour = "#fcfc03"
  ELSE
  ' set colour based on department
    SELECT CASE UCASE$(strDepartment)
      CASE "IT"
        strColour = "#cefa66"
      CASE "MARKETING"
        strColour = "#75e2fa"
      CASE "HR"
        strColour = "#fab4e0"
      CASE "NETWORKS"
        strColour = "#b85e73"
      CASE ELSE
        strColour = "#f5d889"
    END SELECT
    '
  END IF
  '
  FUNCTION = strColour
  '
END FUNCTION
