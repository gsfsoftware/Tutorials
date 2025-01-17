#COMPILE EXE
#DIM ALL
#DEBUG ERROR ON
'
#TOOLS OFF
'
' load a file into the Resource 'CarData'
#RESOURCE RCDATA CarData "NewData.txt"

' include the common display library
#INCLUDE "win32api.inc"
#INCLUDE "CommonDisplay.inc"
'
' Storing numeric constants
%MAX_users = 30
'
' Storing String constants
$Deparment = "Finance"
'
' using a macro to hold a constant
MACRO mPi = 3.141592653589793##


'
FUNCTION PBMAIN () AS LONG
' the main PB function that is the first to be executed
  funPrepOutput("Data embedding",0,0,40,120)
  '
  funLog("Data embedding")
  '
  funLog("Max users = " & FORMAT$(%MAX_USERS))
  '
  funLog("Department = " & $Deparment)
  '
  LOCAL lngDiameter AS LONG
  lngDiameter = 10
  funLog("Circle circumference = " & _
         funGetCircleCircumference(lngDiameter))
  '
  funLog("Data = " & funGetDepartments())
  '
  funLog("List of Cars" & $CRLF & _
         funGetCarListFromFile("Data.txt") & _
         $CRLF)
  '
  funLog("New list of Cars" & $CRLF & _
         funGetCarListFromResource("CarData") & _
         $CRLF)
  funWait()
  '
END FUNCTION
'
FUNCTION funGetCarListFromResource(strResourceID AS STRING) AS STRING
' return the resource string
  LOCAL strList AS STRING
  '
  ' extract data from the Resource using Resource ID
  strList = RESOURCE$(RCDATA,strResourceID)
  ' replace carriage return/line feeds with Pipe character
  REPLACE $CRLF WITH "|" IN strList
  ' return data to the calling routine
  FUNCTION = strList
  '
END FUNCTION
'
FUNCTION funGetCarListFromFile(strFile AS STRING) AS STRING
' return a list of cars from the file
  LOCAL lngFile AS LONG        ' file handle
  LOCAL lngRecordCount AS LONG ' count of records in the file
  LOCAL strList AS STRING      ' list of cars returned
  LOCAL lngItem AS LONG        ' item number being read
  LOCAL strItem AS STRING      ' text of item being read
  '
  lngFile = FREEFILE
  TRY
  ' try to open the file
    OPEN EXE.PATH$ & strFile FOR INPUT AS #lngFile
    ' count the records in the file
    FILESCAN #lngFile, RECORDS TO lngRecordCount
    ' read in data line by line
    FOR lngItem = 1 TO lngRecordCount
      ' populate the Item string variable
      LINE INPUT #lngFile, strItem
      ' add to the List variable with a pipe "|" delimiter
      strList = strList & strItem & "|"
    NEXT lngItem
    ' trim off last | character and return to calling function
    FUNCTION = TRIM$(strList,"|")
    '
  CATCH
  ' trap any errors here
  '
  FINALLY
  ' close down the file access
    CLOSE #lngFile
  END TRY
  '
END FUNCTION
'
FUNCTION funGetCircleCircumference(lngDiameter AS LONG) AS STRING
' return circle Circumference
  FUNCTION = FORMAT$(mPI * lngDiameter)
END FUNCTION
'
FUNCTION funGetDepartments() AS STRING
' return a list of departments
  DATA "Finance","Marketing","HR","IT"
  DATA "Facilities"
  '
  LOCAL lngItem AS LONG     ' item in data
  LOCAL strList AS STRING   ' list to be returned
  '
  ' read each entry in the data statements
  FOR lngItem = 1 TO DATACOUNT
    ' append to the List variable using a ; delimiter
    ' $crlf or any other delimiter can be used
  NEXT lngItem
    strList = strList & READ$(lngItem) & ";"
  ' return data to the calling function
  FUNCTION = strList
  '
END FUNCTION
