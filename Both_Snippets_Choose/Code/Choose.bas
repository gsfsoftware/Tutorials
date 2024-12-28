#COMPILE EXE
#DIM ALL
#DEBUG ERROR ON
'
#TOOLS OFF
'
' include the common display library
#INCLUDE "win32api.inc"
#INCLUDE "CommonDisplay.inc"
'
ENUM Departments BITS
  IT = 1        ' 1st bit
  Finance       ' 2
  HR            ' 4
  Marketing     ' 8
END ENUM
'
FUNCTION PBMAIN () AS LONG
' the main PB function that is the first to be executed
  funPrepOutput("Choose Command",0,0,40,120)
  '
  funLog("Choose Command")
  '
  funChooseStrings()
  funLog ""
  '
  funChooseIntegerNumbers()
  funLog ""
  '
  funChooseNumbers()
  funLog ""
  '
  funChooseDepartment()
  funLog ""
  '
  funWait()
  '
END FUNCTION
'
FUNCTION funChooseDepartment() AS LONG
' choose a department
  LOCAL lngSelected AS LONG
  '
  lngSelected = %Departments.Finance OR %Departments.IT
  '
  funLog CHOOSE$(BIT,lngSelected,"IT","Finance","HR","Marketing")
  '
  funLog CHOOSE$(BITS,lngSelected,"IT account ", _
                                  "Finance account ", _
                                  "HR account ", _
                                  "Marketing account ")
END FUNCTION
'
FUNCTION funChooseNumbers() AS LONG
' choose any number
  DIM a_sngNumbers(1 TO 4) AS SINGLE
  ARRAY ASSIGN a_sngNumbers() = 34.1,17.9,42.0,17.6
  '
  ' set selection made by user
  LOCAL sngSelection AS SINGLE
  sngSelection = 17.9
  '
  ' find the position in the array
  LOCAL lngIndex AS LONG
  ARRAY SCAN a_sngNumbers(), = sngSelection, _
                             TO lngIndex
                             '
  ' now use the Choose command
  funLog "CHOOSE NUMBERS -> " & FORMAT$(CHOOSE(lngIndex,10,20,30,40 _
                                               ELSE 0))
'
END FUNCTION
'
FUNCTION funChooseIntegerNumbers() AS LONG
' use the Choose& command
  DIM a_lngNumbers(1 TO 5) AS LONG
  ARRAY ASSIGN a_lngNumbers() = 34,576,42,17,9
  '
  ' set selection made by user
  LOCAL lngSelection AS LONG
  lngSelection = 42
  '
  ' find the position in the array
  LOCAL lngIndex AS LONG
  ARRAY SCAN a_lngNumbers(), = lngSelection, _
                             TO lngIndex
  '
  ' use an IF command to handle what's selected
  IF lngSelection = 34 THEN
    funLog "IF -> 34"
  ELSEIF lngSelection = 576 THEN
    funLog "IF -> 576"
  ELSEIF lngSelection = 42 THEN
    funLog "IF -> 42"
  ELSEIF lngSelection = 17 THEN
    funLog "IF -> 17"
  ELSEIF lngSelection = 9  THEN
    funLog "IF -> 9"
  ELSE
    funLog "IF -> 0"
  END IF
  '
  ' use a select command to handle what's selected
  SELECT CASE lngSelection
    CASE 34
      funLog "SELECT -> 34"
    CASE 576
      funLog "SELECT -> 576"
    CASE 42
      funLog "SELECT -> 42"
    CASE 17
      funLog "SELECT -> 17"
    CASE 9
      funLog "SELECT -> 9"
    CASE ELSE
      funLog "SELECT -> 0"
  END SELECT
  '
  ' now use the Choose command
  funLog "CHOOSE -> " & FORMAT$(CHOOSE&(lngIndex,34,576,42,17,9 _
                                ELSE 0))
                                '
END FUNCTION
'
FUNCTION funChooseStrings() AS LONG
' use the Choose$ command
  '
  DIM a_strColours(1 TO 3) AS STRING
  ARRAY ASSIGN a_strColours() = "Red","Green","Blue"
  '
  ' set selection made by user
  LOCAL strSelection AS STRING
  strSelection = "Blue"
  '
  ' find the position in the array
  LOCAL lngIndex AS LONG
  ARRAY SCAN a_strColours(), COLLATE UCASE, = strSelection, _
                             TO lngIndex
                             '
  ' use an IF command to handle what's selected
  IF strSelection = "Blue" THEN
  ' Blue selected
    funLog "IF -> Blue"
  ELSEIF strSelection = "Red" THEN
  ' Red selected
    funLog "IF -> Red"
  ELSEIF strSelection = "Green" THEN
  ' Green Selected
    funLog "IF -> Green"
  ELSE
  ' something else
    funLog "IF -> Something else"
  END IF
  '
  ' use a select command to handle what's selected
  SELECT CASE strSelection
    CASE "Blue"
      funLog "SELECT -> Blue"
    CASE "Red"
      funLog "SELECT -> Red"
    CASE "Green"
      funLog "SELECT -> Green"
    CASE ELSE
      funLog "SELECT -> Something else"
  END SELECT
  '
  ' now use the Choose command
  funLog "CHOOSE -> " & CHOOSE$(lngIndex,"Red","Green","Blue" _
                                ELSE "Something else")
                                '
END FUNCTION
