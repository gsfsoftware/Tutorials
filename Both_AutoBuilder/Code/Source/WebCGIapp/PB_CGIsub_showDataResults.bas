#COMPILE EXE
#DIM ALL

#INCLUDE "Win32api.inc"

#INCLUDE "../../Libraries/PBCGI.inc"
#INCLUDE "../../Libraries/PB_FileHandlingRoutines.inc"

FUNCTION PBMAIN () AS LONG
  LOCAL strInfo AS STRING
  LOCAL x AS STRING
  LOCAL p AS LONG
  DIM strParam(1) AS STRING
  LOCAL lngR AS LONG
  LOCAL strHTML AS STRING
  '
  ' read from stdIN
  x = ReadCGI
  ' count the parameters and put in an array
  p = ParseParams(x,strParam())
  '
  IF p THEN
    FOR lngR = 1 TO UBOUND(strParam)
      SELECT CASE lngR
        CASE 1
        ' random number to ensure no caching
        ' -> ignore this parameter
        CASE 2
        ' parameter comes in as N=value
          strInfo = DecodeCGI(strParam(lngR))
        ' so trim of the name of the parameter
          strInfo = PARSE$(strInfo,"=",2)
      END SELECT
    NEXT lngR
  END IF

  WriteCGI funReturnHTMLSection(strInfo)

END FUNCTION
'
FUNCTION funReturnHTMLSection(strInfo AS STRING ) AS STRING
  LOCAL strFilename AS STRING
  LOCAL strHTML AS STRING
  DIM a_strWork() AS STRING
  LOCAL lngR AS LONG
  LOCAL strData AS STRING
  LOCAL strEyeColour AS STRING
  LOCAL lngCounter AS LONG

  strFilename = EXE.PATH$ & "MyLargeFile.txt"
  strInfo = TRIM$(strInfo) ' trim any leading or trailing spaces
  '
  IF ISTRUE funReadTheFileIntoAnArray(strFilename, _
                                      BYREF a_strWork()) THEN
  ' data has been loaded
    strHTML = "<table border=1>"
    FOR lngR = 0 TO UBOUND(a_strWork)
      strData = a_strWork(lngR)
      '
      IF lngR = 0 THEN
      ' handle the header line
        REPLACE $TAB WITH "</td><td>" IN strData
        strHTML = strHTML & "<tr class=""AListHeader""><td>" & _
                  strData & "</td></tr>"
      ELSE
      ' handle all the other data lines
      ' pick up the eye colour column
      strEyeColour = TRIM$(PARSE$(strData,$TAB,5))
      IF LCASE$(strInfo) = LCASE$(strEyeColour) THEN
      ' eye colour matches
        INCR lngCounter
        REPLACE $TAB WITH "</td><td>" IN strData
        strHTML = strHTML & "<tr " & funBanding & "><td>" & strData & "</td></tr>"
      '
      END IF
      '
      END IF
      '
    NEXT lngR
  '
  ELSE
  ' data can't be loaded
    strHTML = "<p>Unable to load the data</p>"
  '
  END IF
  '
  FUNCTION = "<p>Data searched for where eye colour = " & strInfo & _
             " returned " & FORMAT$(lngCounter) & " records</p>" & _
              strHTML

END FUNCTION
'
FUNCTION funBanding() AS STRING
  STATIC lngValue AS LONG
  '
  IF lngValue = 1 THEN
    FUNCTION = "class=""NewBandingEven"""
    lngValue = 0
  ELSE
    FUNCTION = "class=""NewBandingOdd"""
    lngValue = 1
  END IF
  '
END FUNCTION
