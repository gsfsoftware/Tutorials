#COMPILE EXE
#DIM ALL

TYPE uNames
  lngNumber AS LONG
  strName AS STRING * 20
END TYPE

FUNCTION PBMAIN () AS LONG
' create the two arrays
  '

  CON.CAPTION$= "Array Testing"
  CON.COLOR 6,0
  CON.SCREEN = 30,60

  DIM a_strDate(1 TO 100,1 TO 2) AS STRING
  DIM a_lngProgs(1 TO 100) AS LONG
  LOCAL lngR AS LONG
  '
  ARRAY ASSIGN a_strDate() = "First","Second", "Third"
  '
  FOR lngR = 1 TO 4
    a_strDate(lngR,1) = FORMAT$(lngR) & " " & a_strDate(lngR)
    a_strDate(lngR,2) = FORMAT$(RND(1,10))
    con.stdout a_strDate(lngR,1) & ":" & a_strDate(lngR,2)
  NEXT lngR
  '
  REDIM PRESERVE a_strDate(1 TO 4,1 TO 2) AS STRING
  '
  FOR lngR = 1 TO 4
    a_strDate(lngR,1) = FORMAT$(lngR) & " " & a_strDate(lngR)
    a_strDate(lngR,2) = FORMAT$(RND(1,10))
    CON.STDOUT a_strDate(lngR,1) & ":" & a_strDate(lngR,2)
  NEXT lngR
  '
  DIM a_strName(0 TO 6) AS uNames
  FOR lngR = 0 TO 6
    a_strName(lngR).lngNumber = lngR
    a_strName(lngR).strName = DAYNAME$(lngR)
  NEXT lngR
  '
  FOR lngR = 0 TO 6
    CON.STDOUT FORMAT$(a_strName(lngR).lngNumber) & _
                     " " & a_strName(lngR).strName
  NEXT lngR
  '
  CON.STDOUT ""
  LOCAL days AS uNames PTR
  FOR lngR = 0 TO 6
    days = VARPTR(a_strName(lngR))
    CON.STDOUT FORMAT$(@days.lngNumber) & _
               " " & @days.strName
  NEXT lngR
  '
  CON.STDOUT "Press any key to exit"
  WAITKEY$
  '
END FUNCTION
