#COMPILE EXE
#DIM ALL
#DEBUG ERROR ON
'
#TOOLS OFF
'
' include the common display library
#INCLUDE "win32api.inc"
#INCLUDE "CommonDisplay.inc"
#INCLUDE "Macro_Library.inc"
'

' set the Build and version number
mReleasePackage BuildVersion = "Release Build"
mReleasePackage VerNumber = "2.0.0.10"
'
FUNCTION PBMAIN () AS LONG
' the main PB function that is the first to be executed
  funPrepOutput("Macro functions",0,0,40,120)
  '
  funLog("Macro functions")
  '
  ' Output the constants stored
  funLog("Release Build Version = " & BuildVersion)
  funLog("Version number = " & VerNumber)
  '
  LOCAL strData1, strData2 AS STRING
  LOCAL strOutput1,strOutput2 AS STRING
  ' set up variables to be interleaved
  strData1 = "ABCD"
  strData2 = "1234"
  '
  ' interleave strings and store in Output variables
  strOutput1 = mFoldString(strData1,strData2)
  strOutput2 = mFoldString(strData2,strData1)
  ' output to the log
  funLog("Output = " & strOutput1)
  funLog("Output = " & strOutput2)
  '
  ' write the output of RandomSeed macro to the log
  funLog("Seed = " & FORMAT$(mRandomseed))
  '
  ' seed the Random number generator
  RANDOMIZE mRandomseed
  ' get a random number between 1 and 20
  LOCAL lngValue AS LONG
  lngValue = RND(1,20)
  ' output the value to the log
  funlog("Value = " & FORMAT$(lngValue))
  '
  ' get another random number between 1 and 20
  lngValue = RND(1,20)
  ' output the value to the log
  funlog("Value = " & FORMAT$(lngValue))
  '
  funWait()
  '
END FUNCTION
'
