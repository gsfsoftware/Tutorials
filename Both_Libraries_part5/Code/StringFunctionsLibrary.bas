#COMPILE EXE
#DIM ALL
#DEBUG ERROR ON
'
#TOOLS OFF
'
' include the common display library
#INCLUDE "win32api.inc"
#INCLUDE "..\Libraries\CommonDisplay.inc"
#INCLUDE "..\Libraries\PB_Common_Strings.inc"
#INCLUDE "..\Libraries\PB_FileHandlingRoutines.inc"

'

FUNCTION PBMAIN () AS LONG
' the main PB function that is the first to be executed
  funPrepOutput("String functions library",0,0,40,120)
  '
  funLog("String functions library")
  '
  LOCAL strFilename AS STRING
  DIM a_strWork() AS STRING
  LOCAL strHeaders AS STRING
  '
  strFilename = EXE.PATH$ & "MyFile.csv"
  '
  ' read the file into an array
  IF ISTRUE funReadTheFileIntoAnArray(strFilename, _
                                      BYREF a_strWork()) THEN
    ' pick up the headers
    strHeaders = a_strWork(0)
    funLog strHeaders
    '
    ' determine the column positions
    LOCAL lngFirstName AS LONG
    LOCAL lngSurname AS LONG
    LOCAL lngAddress AS LONG
    LOCAL lngTelephone AS LONG
    LOCAL lngAccount AS LONG
    '
    ' store the column positions
    lngFirstName = funParseFind(strHeaders,",","FirstName")
    lngSurname   = funParseFind(strHeaders,",","Surname")
    lngAddress   = funParseFind(strHeaders,",","Address")
    lngTelephone = funParseFind(strHeaders,",","Telephone")
    lngAccount   = funParseFind(strHeaders,",","Account Number")
    '
     ' display the column positions
    funlog "FirstName col = " & FORMAT$(lngFirstName)
    funlog "Telephone col = " & FORMAT$(lngTelephone)
    '
    ' display all the telephone records
    LOCAL lngR AS LONG
    '
    FOR lngR = 1 TO UBOUND(a_strWork)
      funlog "Record " & FORMAT$(lngR) & " Telephone = " & _
             PARSE$(a_strWork(lngR),"",lngTelephone)
    NEXT lngR
    '
    ' update the telephone value for one record
    LOCAL strTelephone AS STRING
    strTelephone = "0555 0145 7010"
    lngR = 1
    ' and store back in the array
    a_strWork(lngR) = funParsePut(a_strWork(lngR),",", _
                                  lngTelephone,strTelephone)
    ' display the updated record
    funlog "Record " & FORMAT$(lngR) & " Telephone = " & _
             PARSE$(a_strWork(lngR),"",lngTelephone)
    funLog a_strWork(lngR)
    '
    ' store values in a delimited string
    LOCAL strCounts AS STRING
    strCounts = "0|0|0|0"
    '
    funLog strCounts
    strCounts = funParsePut(strCounts,"|",3,"44")
    funLog strCounts
    strCounts = funParsePut(strCounts,"|",4,"Rabbit")
    funLog strCounts
    '
  END IF
  '
  funWait()
  '
END FUNCTION
'
