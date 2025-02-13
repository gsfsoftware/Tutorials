#COMPILE EXE
#DIM ALL

FUNCTION PBMAIN () AS LONG
  CON.COLOR 10,-1
  PRINT "Can you solve this?"
  PRINT "2x + y - z = 7"
  PRINT "3x + 2y + 4z = 17"
  PRINT "x + 3y + 2z = 11"
  PRINT
  '
  ' Declare matrices
  DIM aExtCoeff(1 TO 3, 1 TO 3) AS EXT  ' Coefficient matrix
  DIM aExtConstant(1 TO 3) AS EXT       ' Constant vector
  DIM aExtInverse(1 TO 3,1 TO 3) AS EXT ' Inverse of aExtCoeff
  DIM aExtSolution(1 TO 3) AS EXT       ' Solution vector
  LOCAL extDeterminant AS EXT           ' Determinant of the
                                        ' Coefficient matrix
  '
  '
  aExtCoeff(1, 1) = 2
  aExtCoeff(1, 2) = 1
  aExtCoeff(1, 3) = -1
  aExtCoeff(2, 1) = 3
  aExtCoeff(2, 2) = 2
  aExtCoeff(2, 3) = 4
  aExtCoeff(3, 1) = 1
  aExtCoeff(3, 2) = 3
  aExtCoeff(3, 3) = 2
  '
  ' print the matrix
  funPrint2DMatrix(aExtCoeff(), _
                 "Coefficient matrix")
                 '
  ' Initialize constant vector (aExtConstant)
  aExtConstant(1) = 7
  aExtConstant(2) = 17
  aExtConstant(3) = 11
  '
  ' print the matrix
  funPrint1DMatrix(aExtConstant(), _
                 "Constant vector matrix")
                 '
  ' Calculate the determinant (for error checking)
  ' A determinant can only be calculated for square matrices
  ' that is a matrix with the same number of rows and columns
  extDeterminant = aExtCoeff(1,1) * (aExtCoeff(2,2) * aExtCoeff(3,3) _
        - aExtCoeff(2,3) * aExtCoeff(3,2)) - aExtCoeff(1,2) _
        * (aExtCoeff(2,1) * aExtCoeff(3,3) - aExtCoeff(2,3) _
        * aExtCoeff(3,1)) + aExtCoeff(1,3) * (aExtCoeff(2,1) _
        * aExtCoeff(3,2) - aExtCoeff(2,2) * aExtCoeff(3,1))
        '
  IF ABS(extDeterminant) < 1e-6 THEN
  ' Use a small tolerance
    PRINT "Error: Matrix is singular (no inverse)."
    ' Or handle the error in another way
  ELSE
  ' Calculate the inverse of aExtCoeff
    MAT aExtInverse() = INV(aExtCoeff())
    ' print the matrix
    funPrint2DMatrix(aExtInverse(), _
                     "Inverse matrix")
                     '
    ' Multiply the inverse of aExtCoeff by aExtConstant
    ' to get the solution -> aExtSolution
    MAT aExtSolution() = aExtInverse() * aExtConstant()
    '
    ' Display the solution
    PRINT "Solution:"
    PRINT "x = " ; aExtSolution(1)
    PRINT "y = " ; aExtSolution(2)
    PRINT "z = " ; aExtSolution(3)
    '
    '--- Verification (Optional but highly recommended) ---
    DIM aExtCheck(1 TO 3) AS EXT
    MAT aExtCheck() = aExtCoeff() * aExtSolution()
    PRINT
    funPrint1DMatrix(aExtCheck(), _
                 "Verification check" & _
                 "(aExtCoeff * aExtSolution = aExtConstant):")
    '
    '
  END IF
  '
  WAITKEY$
END FUNCTION
'
FUNCTION funPrint2DMatrix(BYREF aMatrix() AS EXT, _
                          strMatrixName AS STRING) AS LONG
' print a two dimensional matrix
  LOCAL lngRow, lngColumn AS LONG
  CON.COLOR 3,-1
  PRINT strMatrixName
  CON.COLOR 10,-1
  FOR lngRow = 1 TO UBOUND(aMatrix,1)
    PRINT "[";
    FOR lngColumn = 1 TO UBOUND(aMatrix,2)
      PRINT aMatrix(lngRow,lngColumn);" ";
    NEXT lngColumn
    PRINT "]"
  NEXT lngR
  PRINT
  '
END FUNCTION
'
FUNCTION funPrint1DMatrix(BYREF aMatrix() AS EXT, _
                          strMatrixName AS STRING) AS LONG
' print a one dimensional matrix
  LOCAL lngRow AS LONG
  '
  CON.COLOR 3,-1
  PRINT strMatrixName
  CON.COLOR 10,-1
  FOR lngRow = 1 TO UBOUND(aMatrix,1)
    PRINT "[";aMatrix(lngRow);"]"
  NEXT lngRow
  PRINT
  '
END FUNCTION
