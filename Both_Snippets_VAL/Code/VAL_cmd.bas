#COMPILE EXE
#DIM ALL
#DEBUG ERROR ON
'
#TOOLS OFF
'
' include the common display library
#INCLUDE "win32api.inc"
#INCLUDE "..\Libraries\CommonDisplay.inc"
#INCLUDE "..\Libraries\PB_commandLine.inc"
'
FUNCTION PBMAIN () AS LONG
' the main PB function that is the first to be executed
  funPrepOutput("VAL command",0,0,40,120)
  '
  funLog("VAL")
  '
  ' two ways of using VAL - as Function or statement
  LOCAL lngValue AS LONG
  LOCAL strData AS STRING
  ' string to Long
  strData = "500.8"
  lngValue = VAL(strData)
  '
  funLog FORMAT$(lngValue) & " long"
  '
  LOCAL sngValue AS SINGLE
  sngValue = VAL(strData)
  funLog FORMAT$(sngValue) & " single"
  '
  ' combined with other data
  strData = "Result = 500.8"
  sngValue = VAL(strData)
  funLog FORMAT$(sngValue) & " single"
  ' using offset
  sngValue = VAL(strData,10)
  funLog FORMAT$(sngValue) & " single offset"
  '
  ' exponential notation
  strData = "12.6014e3"
  sngValue = VAL(strData)
  funLog FORMAT$(sngValue) & " single exponential
  '
  ' scientific notation
  strData = "2D3"
  lngValue = VAL(strData)
  funLog FORMAT$(lngValue) & " long scientific notation"
  '
   ' hex values
  strData = "&H42"
  lngValue = VAL(strData)
  funLog FORMAT$(lngValue) & " long hex notation"
  '
  ' VAL used as a statement
  VAL strData TO lngValue
  funLog FORMAT$(lngValue) & " long hex notation as statement"
  '
  '
  ' currency
  LOCAL curValue AS CURRENCY
  strData = "Cost is $45.78 today"
  funLog strData
  '
  ' pick out the value
  VAL strData, INSTR(strData, "$")+1 TO curValue
  funLog FORMAT$(curValue) & " currency format"
  '
  ' determine Significant digits
  ' and unused characters
  '
  LOCAL lngSignificantDigits AS LONG
  LOCAL lngUnusedCharacters AS LONG
  '
  VAL strData, INSTR(strData, "$")+1 TO curValue, _
                     lngSignificantDigits, _
                     lngUnusedCharacters
                     '
  funLog FORMAT$(curValue) & " currency format"
  funLog "significant digits = " & FORMAT$(lngSignificantDigits)
  funLog "unused characters  = " & FORMAT$(lngUnusedCharacters)
  '
  funWait()
  '
END FUNCTION
'
