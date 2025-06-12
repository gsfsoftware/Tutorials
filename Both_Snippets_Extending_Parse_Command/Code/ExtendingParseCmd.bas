#COMPILE EXE
#DIM ALL
#DEBUG ERROR ON
'
#TOOLS OFF
'
' include the common display library
#INCLUDE "win32api.inc"
#INCLUDE "CommonDisplay.inc"
#INCLUDE "PB_Common_Strings.inc"
'
FUNCTION PBMAIN () AS LONG
' the main PB function that is the first to be executed
  funPrepOutput("Extending the Parse command",0,0,40,120)
  '
  funLog("Extending the Parse command")
  '
  ' insert a string into a delimited template
  funLog("Target = " & funInsertString() & $CRLF)
  '
  ' find the first instance of a string in a template
  ' and return the element number - reading from the left
  funLog("Target = " & FORMAT$(funFindString()) & $CRLF)
  '
  ' find the first instance of a string in a template
  ' and return the element number - reading from the right
  funLog("Target = " & FORMAT$(funFindString_Right()) & $CRLF)
  '
  ' print the first few elements of a string
  funLog("Target = " & funPrintLeftData() & $CRLF)
  '
  funWait()
  '
END FUNCTION
'
FUNCTION funPrintLeftData() AS STRING
' print data up until the Department
  LOCAL strDataTemplate AS STRING   ' string to hold the template
  LOCAL strSearchCriteria AS STRING ' string to hold the Search Criteria
  LOCAL lngEndElement AS LONG       ' ending element number
  LOCAL strDelimiter AS STRING      ' delimiter of the string
  '
  'strDataTemplate = "ID,Name,Department,Division"
  strDataTemplate = "ID,Name,Department,""Division,Organisation"""
  funLog("Template = " & strDataTemplate)
  '
  strDelimiter = ","
  strSearchCriteria = "Department"
  '
  funlog("Searching for data up until " & strSearchCriteria)
  ' first find the element number of the search criteria
  lngEndElement = funParseFind(strDataTemplate, _
                               strDelimiter, _
                               strSearchCriteria)
                               '
  ' now return the data in the template up until
  ' and including the search criteria
  FUNCTION = funStartRangeParse(strDataTemplate, _
                                strDelimiter, _
                                lngEndElement)
  '
END FUNCTION
'
FUNCTION funFindString_Right() AS LONG
' find the element number of a string in a template
  LOCAL strDataTemplate AS STRING   ' string to hold the template
  LOCAL strSearchCriteria AS STRING ' string to hold the Search Criteria
  LOCAL strDelimiter AS STRING      ' delimiter of the string
  '
  'strDataTemplate = "ID,Name,Department,Division"
  strDataTemplate = "ID,Name,Department,""Division,Organisation"""
  '
  '
  funLog("Template = " & strDataTemplate)
  '
  strDelimiter = ","
  strSearchCriteria = "Department"
  '
  funlog("Searching for " & strSearchCriteria & " from right")
  '
  FUNCTION = funParseFindReverse(strDataTemplate, _
                                 strDelimiter, _
                                 strSearchCriteria)
  '
END FUNCTION
'
FUNCTION funFindString() AS LONG
' find the element number of a string in a template
  LOCAL strDataTemplate AS STRING   ' string to hold the template
  LOCAL strSearchCriteria AS STRING ' string to hold the Search Criteria
  LOCAL strDelimiter AS STRING      ' delimiter of the string
  '
  strDataTemplate = "ID,Name,Department,Division"
  '
  funLog("Template = " & strDataTemplate)
  '
  strDelimiter = ","
  strSearchCriteria = "Department"
  '
  funlog("Searching for " & strSearchCriteria)
  '
  FUNCTION = funParseFind(strDataTemplate, _
                          strDelimiter, _
                          strSearchCriteria)
                          '
END FUNCTION
'
FUNCTION funInsertString() AS STRING
' insert a string into a specific position
  ' in a delimeted string template
  LOCAL strDataTemplate AS STRING   ' string to hold the template
  LOCAL strTarget AS STRING         ' string to hold the target data
  LOCAL strDelimiter AS STRING      ' delimiter of the string
  LOCAL lngElement AS LONG          ' element to update
  LOCAL strValue AS STRING          ' value to insert
  '
  strDataTemplate = "a|b|c|d"
  '
  funLog("Template = " & strDataTemplate)
  '
  strDelimiter = "|"
  lngElement = 2
  strValue = "New Value"
  '
  strTarget = funParsePut(strDataTemplate, _
                          strDelimiter, _
                          lngElement, _
                          strValue)
                          '
  FUNCTION = strTarget
  '
END FUNCTION
