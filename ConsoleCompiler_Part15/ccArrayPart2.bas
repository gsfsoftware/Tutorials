#COMPILE EXE
#DIM ALL

TYPE uNames
  lngNumber AS LONG
  strName AS STRING * 20
  lngValue AS LONG
END TYPE

FUNCTION PBMAIN () AS LONG
  mPrepConsole("Array Testing Part 2")
  '
  DIM a_strName(0 TO 6) AS uNames
  funBuildTheArray(BYREF a_strName())
  funPrintTheArray(BYREF a_strName())
  '
  ' Delete a day
  CON.STDOUT ""
  ARRAY DELETE a_strName(1)
  funPrintTheArray(BYREF a_strName())
  '
  'insert a day
  CON.STDOUT ""
  ARRAY INSERT a_strName(1)
  '
  LOCAL arr AS uNames POINTER
  arr = VARPTR(a_strName(0))
  subFill_Name(arr,1,"My Day",42)
  '
  funPrintTheArray(BYREF a_strName())
  '
  CON.STDOUT ""
  REDIM PRESERVE a_strName(UBOUND(a_strName)+1)
  arr = VARPTR(a_strName(0))
  ARRAY INSERT a_strName(1)
  subFill_Name(arr,1,"My New Day",999)
  funPrintTheArray(BYREF a_strName())
  '
  CON.STDOUT "Press any key to exit"
  WAITKEY$
  '
END FUNCTION
'
SUB subFill_Name(BYVAL arr AS uNames POINTER, _
                 Number AS LONG, _
                 Day AS STRING, _
                 Value AS LONG )
  @arr[Number].lngNumber = Number
  @arr[Number].strName = Day
  @arr[Number].lngValue = Value
  '
END SUB
'
MACRO mPrepConsole(Title)
  CON.CAPTION$ = Title
  CON.COLOR 6,0
  CON.SCREEN = 30,60
END MACRO
'
FUNCTION funBuildTheArray(BYREF a_strName() AS uNames) AS LONG
' populate the array
  LOCAL lngR AS LONG
  '
  FOR lngR = LBOUND(a_strName) TO UBOUND(a_strName)
    PREFIX "a_strName(lngR)."
      lngNumber = lngR
      strName = DAYNAME$(lngR)
      lngValue = RND(1,10)
    END PREFIX
  NEXT lngR
  '
END FUNCTION
'
FUNCTION funPrintTheArray(BYREF a_strName() AS uNames) AS LONG
' print the array to the console
  LOCAL lngR AS LONG
  '
  FOR lngR = LBOUND(a_strName) TO UBOUND(a_strName)
    CON.STDOUT FORMAT$(a_strName(lngR).lngNumber) & " " ;
    CON.STDOUT a_strName(lngR).strName & " " ;
    CON.STDOUT FORMAT$(a_strName(lngR).lngValue)
  NEXT lngR
'
END FUNCTION
