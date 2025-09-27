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
' single line macro
MACRO mReleasePackage = MACRO
mReleasePackage BuildVersion = "Alpha Build"
mReleasePackage VerNumber = "1.0.0.34"
'
' sample UDT
TYPE uStorage
  strDate AS STRING * 10
  strValue AS STRING * 50
  strOtherValue AS STRING * 50
END TYPE
'
FUNCTION PBMAIN () AS LONG
' the main PB function that is the first to be executed
  funPrepOutput("Macros",0,0,40,120)
  '
  funLog("Macros")
  ' display value of PI with 18 significant digits
  funLog("PI = " & STR$(mPI,18))
  '
  ' Output the constants stored
  funLog("Release Build Version = " & BuildVersion)
  funLog("Version number = " & VerNumber)
  '
  ' declare variable
  'local strData as string
  ' set the default value
  'strData = "1,2,3,4,5"
  '
  ' declare and set default value of variables
  mPrepFormat(strData)
  mPrepFormat(strData2)
  mPrepFormat(strData3)
  mPrepFormatData(strData4,"A,B,C")
  '
  funLog("strData = " & strData)
  funLog("strData2 = " & strData2)
  funLog("strData3 = " & strData3)
  funLog("strData4 = " & strData4)
  '
  ' prep and populate a UDT in a macro
  mPrepUDT(uToday,"FirstData")
  funLog("UDT = " & uToday.strDate)
  funLog("UDT = " & uToday.strValue)
  '
  mPrepUDT(uTomorrow,"NewData")
  funLog("UDT = " & uTomorrow.strDate)
  funLog("UDT = " & uTomorrow.strValue)
  '
  funWait()
  '
END FUNCTION
'
' single line macro
MACRO mPi = 3.14159265358979323846##
 '
MACRO mPrepFormat(strVariable)
' multi line macro
  LOCAL strVariable AS STRING
  strVariable = "1,2,3,4,5"
END MACRO
'
MACRO mPrepFormatData(strVariable, strData)
' multi line macro
  LOCAL strVariable AS STRING
  strVariable = strData
END MACRO
'
MACRO mPrepUDT(uUDT,strInputValue)
' prepare a UDT
  LOCAL uUDT AS uStorage
  uUDT.strDate = DATE$
  uUDT.strValue = strInputValue
  uUDT.strOtherValue = ""
  '
END MACRO
