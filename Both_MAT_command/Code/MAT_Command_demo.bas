#COMPILE EXE
#DIM ALL
#DEBUG ERROR ON
'
#TOOLS OFF
'
' include the common display library
#INCLUDE "win32api.inc"
#INCLUDE "..\Libraries\CommonDisplay.inc"
'
%Matrix = %TRUE
'
FUNCTION PBMAIN () AS LONG
' the main PB function that is the first to be executed
  funPrepOutput("The Matrix command",0,0,40,120)
  '
  funLog("Matrices")
  '
  DIM a_sngInput(1 TO 3) AS SINGLE             ' Input vector matrix
  DIM a_sngTransMat(1 TO 4, 1 TO 3) AS SINGLE  ' Transformation matrix
  DIM a_sngOutput(1 TO 4) AS SINGLE            ' Output vector matrix
  '
  ' [4,0,1]
  ARRAY ASSIGN a_sngInput()= 4,0,1  ' populate input vector
  '
  ' [1,-3,0,2]
  ' [2,5,3,-1]
  ' [4,6,1,8 ]
  ARRAY ASSIGN a_sngTransMat() = 1,-3,0,2,2,5,3,-1,4,6,1,8
  '
  ' Do normal calculation first
  LOCAL strOutput AS STRING
  LOCAL lngColumn AS LONG
  LOCAL lngRow AS LONG
  LOCAL qTimer AS QUAD
  '
  IF ISFALSE %Matrix THEN
  ' normal calculation
    TIX qTimer
    RESET a_sngOutput()
    ' perform the calculation
    FOR lngColumn = 1 TO 4 ' Column
      FOR lngRow = 1 TO 3 ' Row
        a_sngOutput(lngColumn) = a_sngOutput(lngColumn) + _
                                 a_sngInput(lngRow) * _
                                 a_sngTransMat(lngColumn,lngRow)
      NEXT lngRow
    NEXT lngColumn
    ' output the results
    strOutput = "Output() = a_sngTransMat() * a_sngInput() by normal calculation:" & $CRLF
    FOR lngColumn = 1 TO 4
        strOutput=strOutput & FORMAT$(a_sngOutput(lngColumn)) & " "
    NEXT lngColumn
    '
    TIX END qTimer
    '
    strOutput = strOutput & $CRLF & FORMAT$(qTimer) & _
                           " CPU cycles" & $CRLF & $CRLF
    funLog(strOutput)
  '
  ELSE
     ' now do the same using MAT command
    TIX qTimer
    RESET a_sngOutput()
    ' perform the matrix calculation
    MAT a_sngOutput() = a_sngTransMat() * a_sngInput()
    ' output the results
    strOutput = "Output() = a_sngTransMat() * a_sngInput() by MAT calculation:" & $CRLF
    FOR lngColumn = 1 TO 4
        strOutput=strOutput & FORMAT$(a_sngOutput(lngColumn)) & " "
    NEXT lngColumn
    '
    TIX END qTimer
    '
    strOutput = strOutput & $CRLF & FORMAT$(qTimer) & _
                           " CPU cycles" & $CRLF & $CRLF
    funLog(strOutput)

  END IF
  '
  funWait()
  '
END FUNCTION
'
