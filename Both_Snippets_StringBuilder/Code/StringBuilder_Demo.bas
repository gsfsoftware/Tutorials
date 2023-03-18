#COMPILE EXE
#DIM ALL
#DEBUG ERROR ON
#TOOLS OFF
'
' include the common display library
#INCLUDE "win32api.inc"
#INCLUDE "CommonDisplay.inc"
'
FUNCTION PBMAIN () AS LONG
' the main PB function that is the first to be executed
  funPrepOutput("StringBuilder Demo",0,0,40,120)
  '
  funLog("StringBuilder Demo")
  '
  funAddToString()           ' add to string variable
  funLog("")                 ' output a blank line
  '
  ' manipulate the string built
  LOCAL stbData AS ISTRINGBUILDERA   ' variable to hold built up data
  stbData = CLASS "StringBuilderA"
  '
  ' build a string and return the string builder from the function
  stbData = funAddToStringBuilder()    ' add to string Builder
  funLog("")                 ' output a blank line
  '
  ' manipulate the data within the string builder object
  LOCAL lngI AS LONG
  lngI = INSTR(stbData.string,"13") ' find the position of 13
  stbData.Insert("99 ",lngI)        ' insert 99 before it
  stbData.Delete(lngI+3,3)          ' delete characters
  '
  funLog(stbData.string)            ' display whole object on log
  '
  funBuildArray()                   ' build an array of stringbuilder
  '                                 ' objects
  funWait()
  '
END FUNCTION
'
FUNCTION funBuildArray() AS LONG
' build an array of string builder
' variable to hold built up data
  DIM a_stbData(1 TO 10) AS ISTRINGBUILDERA
  LOCAL strData AS STRING
  LOCAL lngR,lngC AS LONG
  '
  ' define each element
  FOR lngR = 1 TO 10
    a_stbData(lngR) = CLASS "StringBuilderA"
  NEXT lngR
  '
  FOR lngR = 1 TO 10
  ' for each element in the array
    FOR lngC = 1 TO 10
      ' add ten random numbers
      a_stbData(lngR).Add FORMAT$(RND(1,5*lngC)) & " "
    NEXT lngC
  NEXT lngR
  '
  FOR lngR = 1 TO 10
  ' output each element
    strData = a_stbData(lngR).String
    funLog(strData)
  NEXT lngR
  '
END FUNCTION
'
FUNCTION funAddToString() AS LONG
' add to a standard string variable
  LOCAL lngR AS LONG        ' loop counter
  LOCAL strData AS STRING   ' string to hold built up data
  LOCAL qDuration AS QUAD   ' quad used to hold CPU cycle count
  '
  ' start to count CPU cycles
  TIX qDuration
  '
  FOR lngR = 1 TO 50
  ' run through 50 iterations
    ' adding to the Data variable
    strData = strData & FORMAT$(lngR) & " "
    IF lngR MOD 10 = 0 THEN
    ' add a CRLF every ten
      strData = strData & $CRLF
    END IF
  NEXT lngR
  '
  TIX END qDuration          ' stop counting
  '
  funLog(strData)            ' print out the data
  funLog(FORMAT$(qDuration,"#,") & " CPU cycles") ' print out the CPU cycles
  '
END FUNCTION
'
FUNCTION funAddToStringBuilder() AS ISTRINGBUILDERA
' add to a standard string variable
  LOCAL lngR AS LONG        ' loop counter
  LOCAL qDuration AS QUAD   ' quad used to hold CPU cycle count
  LOCAL stbData AS ISTRINGBUILDERA   ' variable to hold built up data
  stbData = CLASS "StringBuilderA"
  '
  stbData.Capacity = 5000
  funlog("Capacity = " & FORMAT$(stbData.capacity))  ' display the capacity
  ' start to count CPU cycles
  TIX qDuration
  '
  FOR lngR = 1 TO 50
  ' run through 50 iterations
    ' adding to the Data variable
    stbData.add FORMAT$(lngR) & " "
    IF lngR MOD 10 = 0 THEN
    ' add a CRLF every ten
      stbData.add $CRLF
    END IF
  NEXT lngR
  '
  TIX END qDuration          ' stop counting
  funLog(stbData.String)     ' print out the data
  funLog(FORMAT$(qDuration,"#,") & " CPU cycles") ' print out the CPU cycles
  '
  ' return the stb variable
  FUNCTION = stbData
  '
END FUNCTION
