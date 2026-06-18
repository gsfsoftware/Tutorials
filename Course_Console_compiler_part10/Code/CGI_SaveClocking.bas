#COMPILE EXE
#DIM ALL
'
#INCLUDE "Win32api.inc"
#INCLUDE "PBCGI.INC"
#INCLUDE "PB_FileHandlingRoutines.inc"
#INCLUDE "DateFunctions.inc"
'
$WebServer = "mini001"           ' name of web server
'
FUNCTION PBMAIN () AS LONG
  LOCAL strParams  AS STRING     ' parameter string
  LOCAL lngP AS LONG             ' parameter count
  DIM a_strParams(1) AS STRING   ' array for parameters
  DIM a_strOutput() AS STRING    ' parameters output
  LOCAL strData AS STRING        ' data string
  LOCAL strDataFile AS STRING    ' name of saved file
  LOCAL lngR AS LONG             ' parameter number
  LOCAL strTime AS STRING        ' time in hh_mm_ss format
  '
  LOCAL strUsername AS STRING    ' users name
  LOCAL strPayroll AS STRING     ' payroll id
  '
  ' Read from STDIN
  strParams = ReadCGI
  '
  ' Count and parse the parameters into an array
  lngP = ParseParams(strParams, a_strParams())
  '
  IF lngP THEN
  ' we have some parameters
    REDIM a_strOutput(UBOUND(a_strParams)) AS STRING
    '
    FOR lngR = 1 TO UBOUND(a_strParams)
    ' get the user details
      a_strOutput(lngR) = DecodeCGI(a_strParams(lngR) )
      '
      SELECT CASE PARSE$(a_strOutput(lngR),"=",1)
        CASE "username"
          strUsername = PARSE$(a_strOutput(lngR),"=",2)
        CASE "payroll"
          strPayroll = PARSE$(a_strOutput(lngR),"=",2)
      END SELECT
      '
      IF TRIM$(a_strOutput(lngR))<>"" THEN
      ' exclude blank lines
        strData = strData & a_strOutput(lngR) & $CRLF
      END IF
    NEXT lngR
    '
    IF TRIM$(strUsername) = "" OR TRIM$(strPayroll) = "" THEN
    ' data is missing - reject submission
      STDOUT "LOCATION: " & "http://" & $WebServer & _
                        "/CGI_BIN/Data/Incomplete.htm" & $CRLF
      EXIT FUNCTION
    END IF
    ' add on the date and time
    strData = strData & "Date=" & funUKDate() & $CRLF
    strData = strData & "Time=" & TIME$
    '
    ' replace the : in time with _
    strTime = TIME$
    REPLACE ":" WITH "_" IN strTime
    '
    strDataFile = EXE.PATH$ & "Data\" & _
                  funReverseUKDateAsNumber(funUKDate()) & "_" & _
                  strTime & ".txt"
    ' save the data to disk
    funSaveStringAsFile(strDataFile, strData)
    '
    STDOUT "LOCATION: " & "http://" & $WebServer & _
                        "/CGI_BIN/Data/Confirmed.htm" & $CRLF
  ELSE
    STDOUT "LOCATION: " & "http://" & $WebServer & _
                        "/CGI_BIN/Data/Incomplete.htm" & $CRLF
  END IF
  '
END FUNCTION
