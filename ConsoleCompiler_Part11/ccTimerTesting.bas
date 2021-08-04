' Timer testing
#COMPILE EXE
#DIM ALL

FUNCTION PBMAIN() AS LONG
  LOCAL qCount AS QUAD
  LOCAL lngValue AS LONG
  LOCAL lngOutput AS LONG
  '
  CON.CAPTION$= "Timer Testing"
  CON.COLOR 10,0
  CON.LOC = 20, 20
  '
  TIX qCount
  lngValue = 0
  lngOutput = funCalc_1(lngValue)
  TIX END qCount
  CON.STDOUT FORMAT$(lngOutput) & " in " & FORMAT$(qCount,"#,") & " CPU cycles"
  '
  TIX qCount
  lngValue = 0
  lngOutput = funCalc_2(lngValue)
  TIX END qCount
  CON.STDOUT FORMAT$(lngOutput) & " in " & FORMAT$(qCount,"#,") & " CPU cycles"
  '
  TIX qCount
  lngValue = 0
  lngOutput = funCalc_3(lngValue)
  TIX END qCount
  CON.STDOUT FORMAT$(lngOutput) & " in " & FORMAT$(qCount,"#,") & " CPU cycles"
  '
  TIX qCount
  lngValue = 0
  lngOutput = funCalc_4(lngValue)
  TIX END qCount
  CON.STDOUT FORMAT$(lngOutput) & " in " & FORMAT$(qCount,"#,") & " CPU cycles"
  '
  TIX qCount
  lngValue = 0
  lngOutput = funCalc_5(lngValue)
  TIX END qCount
  CON.STDOUT FORMAT$(lngOutput) & " in " & FORMAT$(qCount,"#,") & " CPU cycles"
  '
  CON.STDOUT "Press any key to exit"
  WAITKEY$
  '
END FUNCTION
'
FUNCTION funCalc_1(lngValue AS LONG) AS LONG
  LOCAL lngR AS LONG
  '
  FOR lngR = 1 TO 100000
    lngValue = lngValue + 1
  NEXT lngR
  '
  FUNCTION = lngValue
  '
END FUNCTION
'
FUNCTION funCalc_2(lngValue AS LONG) AS LONG
  LOCAL lngR AS LONG
  '
  FOR lngR = 1 TO 100000
    lngValue += 1
  NEXT lngR
  '
  FUNCTION = lngValue
  '
END FUNCTION
'
FUNCTION funCalc_3(lngValue AS LONG) AS LONG
  LOCAL lngR AS LONG
  '
  FOR lngR = 1 TO 100000
    INCR lngValue
  NEXT lngR
  '
  FUNCTION = lngValue
  '
END FUNCTION
'
FASTPROC funCalc_4(BYVAL lngValue AS LONG) AS LONG
  STATIC lngR AS LONG
  '
  FOR lngR = 1 TO 100000
    INCR lngValue
  NEXT lngR
  '
END FASTPROC = lngValue
'
FUNCTION funCalc_5(BYVAL lngValue AS LONG) AS LONG
' asm
  #REGISTER NONE
  LOCAL lngR AS LONG
  '
  lngR = 100000
    !mov esi, lngR   ' set the loop counter
    !sub edi, edi    ' set edi to zero
  #ALIGN 4
  lbl_1:
    !add edi , 1     ' add one to the count
    !sub esi , 1     ' decrement the loop counter
    !jnz lbl_1       ' loop if non zero
    !mov FUNCTION, edi ' get the result and return it
END FUNCTION
