#COMPILE EXE
#DIM ALL
#DEBUG ERROR ON
'
#TOOLS OFF
'
' include the common display library
#INCLUDE "win32api.inc"
#INCLUDE "..\Libraries\CommonDisplay.inc"
#INCLUDE "..\Libraries\PB_FileHandlingRoutines.inc"
'
' define a user defined type for each of the columns
TYPE udtRecord
  strForename AS STRING * 20
  strSurname AS STRING * 20
  strDOB AS STRING * 10
  strEyeColour AS STRING * 5
END TYPE
'
FUNCTION PBMAIN () AS LONG
' the main PB function that is the first to be executed
  funPrepOutput("Field command",0,0,40,120)
  '
  funLog("Field command")
  '
  'funUseFields()  ' call the Use Fields function
  funTypeSet() ' call the UDT type set function
  '
  funWait()
  '
END FUNCTION
'
FUNCTION funUseFields() AS LONG
' read the data in and slice using Field variables
  LOCAL lngFile AS LONG
  LOCAL strFile AS STRING
  '
  LOCAL strRecord AS STRING
  '
  ' define the field variables
  LOCAL strForename AS FIELD
  LOCAL strSurname AS FIELD
  LOCAL strDOB AS FIELD
  LOCAL strEyeColour AS FIELD
  '
  ' define the record Field by Field
  FIELD strRecord, 20 AS strForename , _
                   20 AS strSurname  , _
                   10 AS strDOB , _
                   5 AS strEyeColour
                   '
  strFile = EXE.PATH$ & "Data.txt"
  lngFile = FREEFILE
  '
  OPEN strFile FOR INPUT AS #lngFile
  WHILE NOT EOF(#lngFile)
  ' while not at the end of a file
    LINE INPUT #lngFile , strRecord
    ' output the field variables to the log
    funLog "Forname = " & TRIM$(strForename) & "."
    funLog "Surname = " & strSurname
    funLog "DOB     = " & strDOB
    funLog "Eye colour = " & strEyeColour
    funLog ""
  WEND
  CLOSE #lngFile
END FUNCTION
'
FUNCTION funTypeSet() AS LONG
' read the data in and slice using a UDT
  LOCAL lngFile AS LONG
  LOCAL strFile AS STRING
  LOCAL strRecord AS STRING
  '
  LOCAL uRecord AS udtRecord
  '
  strFile = EXE.PATH$ & "Data.txt"
  lngFile = FREEFILE
  '
  '
  OPEN strFile FOR INPUT AS #lngFile
  WHILE NOT EOF(#lngFile)
    LINE INPUT #lngFile , strRecord
    ' use type set to populate the UDT from the string
    TYPE SET uRecord = strRecord
    ' output the UDT elements to the log
    funLog "Forname = " & TRIM$(uRecord.strForename) & "."
    funLog "Surname = " & uRecord.strSurname
    funLog "DOB     = " & uRecord.strDOB
    funLog "Eye colour = " & uRecord.strEyeColour
    funLog ""
    '
  WEND
  CLOSE #lngFile
END FUNCTION
