#COMPILE EXE
#DIM ALL

#INCLUDE "..\Libraries\Macros.inc"

$Constant = "This value never changes"
GLOBAL strBigString AS STRING
GLOBAL strBiggerString AS WSTRING
'
GLOBAL strSmallerString AS STRING * 10

FUNCTION PBMAIN () AS LONG
  LOCAL strResult AS STRING
  LOCAL strNumbers AS STRING
  LOCAL strValues AS STRING
  '
  mPrepConsole("Demo string Handling")
  '

  strBigString = "<This is a big    string: containg $100 / information>"
  strSmallerString = "this/"
  CON.STDOUT strBigstring
  '
  CON.STDOUT RETAIN$(strBigstring, ANY "100i")
  CON.STDOUT strBigstring
  '
  mConsoleWait
  '
END FUNCTION
