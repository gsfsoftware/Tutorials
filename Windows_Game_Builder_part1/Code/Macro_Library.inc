' Macro_Library.inc


' single line macro
MACRO mReleasePackage = MACRO
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
'
MACRO FUNCTION mFoldString(strData1,strData2)
' macro function
  MACROTEMP lngR, strOutput
  LOCAL lngR AS LONG
  LOCAL strOutPut AS STRING
  '
  FOR lngR = 1 TO LEN(strData1)
    strOutPut = strOutPut & MID$(strData1,lngR,1) & MID$(strData2,lngR,1)
  NEXT lngR
  '
END MACRO = strOutput
'
MACRO FUNCTION mRandomseed
' generate a random seed
' code originally created by Steve Hutchesson
  MACROTEMP dwVar
  LOCAL dwVar AS DWORD
  '
  ' Reads the current value of the processor's time-stamp
  ' counter (a 64-bit MSR) into the EDX:EAX registers.
  ! rdtsc
  ' Reverses the byte order of the EAX register
  ! bswap eax
  ' copy data in EAX register to dwVar variable
  ! mov dwVar, eax
  '
END MACRO = dwVar
