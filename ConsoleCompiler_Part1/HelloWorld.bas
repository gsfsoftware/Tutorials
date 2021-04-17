#COMPILE EXE
#DIM ALL

%TRUE = -1
%FALSE = 0

$MyFile = "MyFile.txt"


FUNCTION PBMAIN () AS LONG
  CON.CAPTION$= "Our Console"
  '
  IF ISTRUE funReadTheFile($MyFile) THEN
  ' the function worked
    CON.STDOUT "IT worked"
  ELSE
  ' it didn't work
    CON.STDOUT "IT didn't work"

  END IF
  '
  WAITKEY$

END FUNCTION
'
FUNCTION funReadTheFile(strFilename AS STRING) AS LONG
  '
  LOCAL lngFile AS LONG
  LOCAL strData AS STRING
  LOCAL strHeaders AS STRING
  LOCAL strSurname AS STRING
  LOCAL strForeName AS STRING
  LOCAL strAddress AS STRING
  '
  IF ISFALSE ISFILE(EXE.PATH$ & strFileName) THEN
    FUNCTION = %FALSE
  ELSE
  ' now open the file
    lngFile = FREEFILE
    TRY
      OPEN EXE.PATH$ & strFileName FOR INPUT AS #lngFile
      LINE INPUT #lngFile, strHeaders
      '
      WHILE NOT EOF(#lngFile)
        LINE INPUT #lngFile, strData
        '
        strForeName = PARSE$(strData,",",1)
        strSurname = PARSE$(strData,",",2)
        strAddress = PARSE$(strData,",",3)
        '
        CON.STDOUT strSurname & ";" & strForename
      WEND
      '
      FUNCTION = %TRUE
    CATCH
      CON.STDOUT ERROR$
      FUNCTION = %FALSE
    FINALLY
      CLOSE #lngFile
    END TRY
    '
  END IF

END FUNCTION
