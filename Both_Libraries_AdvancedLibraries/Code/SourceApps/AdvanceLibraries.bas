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
' link the SLL files individually
'#link "..\SLLS\TaxLib\vat.sll"
'#link "..\SLLS\RandomLib\PB_RandomRoutines_SLL.sll"
'#link "..\SLLS\FileHandleLib\PB_FileHandlingRoutines.sll"
'
' link in the Power Library containing all the SLLs
#LINK "..\PBlibs\FirstLibrary.PBlib"
'
FUNCTION PBMAIN () AS LONG
' the main PB function that is the first to be executed
  funPrepOutput("Advanced Libraries",0,0,40,120)
  '
  funLog("Advanced Libraries")
  '
  ' access a function in the VAT.sll
  PRINT "Value Added Tax on £120.45 = £"; funReturnVATtax(120.45)
  ' access a function in the PB_RandomRoutines_SLL.sll
  PRINT "Random Telephone = "; funGetTelephone()
  '
  LOCAL strHeaders AS STRING
  LOCAL strDelimeter AS STRING
  LOCAL strColumnName AS STRING
  '
  strHeaders = "UniqueID,Name,Address,Telephone"
  strDelimeter = ","
  strColumnName = "Telephone"
  '
  ' access a function in the PB_FileHandlingRoutines.sll
  PRINT "Column number for " & strColumnName & " is " _
        ;funParseFind(strHeaders,strDelimeter,strColumnName)
  '
  funWait()
  '
END FUNCTION
'
