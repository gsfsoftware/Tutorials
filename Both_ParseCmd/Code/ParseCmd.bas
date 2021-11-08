#COMPILE EXE
#DIM ALL

' include the common display library
#INCLUDE "win32api.inc"
#INCLUDE "..\Libraries\CommonDisplay.inc"
#INCLUDE "..\Libraries\PB_FileHandlingRoutines.inc"
'
FUNCTION PBMAIN () AS LONG
' the main PB function that is the first to be executed
  funPrepOutput("Parameters",0,0,40,80)
  '
  funLog("Walk through on Parse Command ")
  '
  DIM a_strData() AS STRING
  LOCAL lngColumns AS LONG
  '
  LOCAL lngFirstName AS LONG
  LOCAL strFirstName AS STRING
  '
  LOCAL lngSurname AS LONG
  LOCAL strSurname AS STRING
  '
  LOCAL lngAddress AS LONG
  LOCAL strAddress AS STRING
  '
  LOCAL lngR AS LONG
  LOCAL strData AS STRING
  '
  IF ISTRUE funReadTheFileIntoAnArray(EXE.PATH$ & "MyLargeFile.csv", _
                            a_strData()) THEN
  ' file is now read into the array
    lngColumns = PARSECOUNT(a_strData(0),$QCQ)
    '
    ' column number isnt equal to what you expect?
    lngFirstName = funParseFind(a_strData(0), _
                                $QCQ,$DQ & "FirstName")
    lngSurname = funParseFind(a_strData(0), _
                              $QCQ,"Surname")
                              '
    lngAddress = funParseFind(a_strData(0), _
                              $QCQ,"Address,City")
                              '
    FOR lngR = 1 TO 5  ' ubound(a_strData)
      strData = a_strData(lngR)
      '
      strFirstname = PARSE$(strData,"", lngFirstName)
      funlog "FirstName -> " & strFirstName
      '
      strSurname = PARSE$(strData,"", lngSurname)
      funlog "Surname -> " & strSurname
      '
      strAddress = PARSE$(strData,"", lngAddress)
      funlog "Address -> " & strAddress
      '
    NEXT lngR

  '
  END IF
  '
  funWait()
'
END FUNCTION
