#COMPILE EXE
#DIM ALL
' task 001 builder
' create the input file
#INCLUDE "win32api.inc"
#INCLUDE "PB_FileHandlingRoutines.inc"
'
$InputFile = "Input.csv"
%MaxRows = 1000000
%MinRange = 1
%MaxRange = 5000
'
FUNCTION PBMAIN () AS LONG
  '
  DIM a_strData(%MaxRows) AS STRING
  CON.STDOUT "Creating Input file"
  IF ISTRUE funCreateInputFile(BYREF a_strData()) THEN
    CON.STDOUT "Completed Input file"
  ELSE
    CON.STDOUT "Unable to complete"
  END IF
  '
  SLEEP 2000
  '
END FUNCTION
'
FUNCTION funCreateInputFile(BYREF a_strData() AS STRING) AS LONG
' create and populate the array with data
'
  LOCAL lngR AS LONG
  LOCAL x,y,z AS LONG
  LOCAL lngTop AS LONG
  LOCAL lngStep AS LONG
  '
  lngTop = UBOUND(a_strData)
  '
  lngStep = lngTop \ 10
  '
  ' set the header
  a_strData(0) = $DQ & "X" & $QCQ & _
                       "Y" & $QCQ & _
                       "Z" & $DQ
                            '
  RANDOMIZE TIMER
  '
   FOR lngR = 1 TO lngTop
    x = RND(%MinRange,%MaxRange)
    y = RND(%MinRange,%MaxRange)
    z = RND(%MinRange,%MaxRange)
   '
    IF lngR MOD lngStep = 0 THEN
      CON.STDOUT "Row " & FORMAT$(lngR)
    END IF
    ' add to array
    a_strData(lngR) = $DQ & FORMAT$(x) & $QCQ & _
                            FORMAT$(y) & $QCQ & _
                            FORMAT$(z) & $DQ
                            '
  NEXT lngR
  '
  ' save the array
  IF ISTRUE funArrayDump(EXE.PATH$ & $InputFile, _
                         BYREF a_strData()) THEN
    CON.STDOUT "Data Saved"
    FUNCTION = %TRUE
  ELSE
    CON.STDOUT "Data Not Saved"
    FUNCTION = %FALSE
  END IF
  '
END FUNCTION
'
