#COMPILE EXE
#DIM ALL        ' ensure all variables are declared
#DEBUG ERROR ON ' turn on error trapping for array bounding
#UNIQUE VAR ON  ' ensure all variable names are unique
'
#OPTION LARGEMEM32  ' increase the memory available to
                    ' this program to ~3GB
#TOOLS OFF          ' disable integrated development
                    ' tool code in compiled code
'
' include the common display library
#INCLUDE "win32api.inc"
#INCLUDE "..\Libraries\CommonDisplay.inc"
'
'deflng A-D  ' legacy method to auto declare
             ' variables A,B,C & D as long
             '
'global strA as string   '
GLOBAL g_strA AS STRING  ' declaring strA as global
                         ' using naming convention
                         ' to make it obvious later in code
GLOBAL g_astrData() AS STRING  ' declare array as global
                               ' string array
'
FUNCTION PBMAIN () AS LONG
' the main PB function that is the first to be executed
  funPrepOutput("Compile options",0,0,40,120)
  '
  funLog("Compile options")
  '
  REDIM g_astrData(100) ' redimension array size
                        ' no need to use 'AS STRING'
  '
  ' strA = "Test"
  g_strA = "Test"
  funProcess()    ' call function, again using naming
                  ' convention
  '
  funWait()
  '
END FUNCTION
'
FUNCTION funProcess() AS LONG
  LOCAL strA AS STRING     ' local variable only
  funLog("Value = " & strA)

END FUNCTION
