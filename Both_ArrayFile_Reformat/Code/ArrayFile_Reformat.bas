#COMPILE EXE
#DIM ALL
#DEBUG ERROR ON
'
#TOOLS OFF
'
' include the common display library
#INCLUDE "win32api.inc"
#INCLUDE "..\Libraries\CommonDisplay.inc"
#INCLUDE ONCE "..\Libraries\PB_Common_Strings.inc
#INCLUDE ONCE "..\Libraries\PB_FileHandlingRoutines.inc"
'
' add the Array functions library
%IndexedSearch = %FALSE  ' these constants are needed
%IndexStart = 0          ' within this library
%IndexEnd = 0            ' and only need populated
'                          if you are doing Indexed searches
#INCLUDE ONCE "..\Libraries\PB_ArrayFunctions.inc"
'
' name the input and output files
$InputFile = "Test_DataFile.csv"
$OutputFile = "Test_output.csv"
'
FUNCTION PBMAIN () AS LONG
' the main PB function that is the first to be executed
  funPrepOutput("Reformat Array/File",0,0,40,120)
  '
  funLog("Reformat Array/File")
  '
  DIM a_strSourceData() AS STRING
  DIM a_strTargetData() AS STRING
  LOCAL strDelimiter AS STRING
  LOCAL strHeaders AS STRING
  LOCAL strError AS STRING
  LOCAL lngDimensions AS LONG
  '
  strDelimiter = ","
  strHeaders = "FirstName,Surname,Blood type,Email,Address,City," & _
               "Region,Postcode,Home Telephone,Age"
  '
  IF ISTRUE funReadTheCSVFileIntoAnArray(EXE.PATH$ & $InputFile, _
                                         a_strSourceData()) THEN
  ' load the CSV file into a 2 dimensional array
    funLog("Input file loaded")
    '
    IF ISTRUE funReformatArray(a_strSourceData(), _
                               a_strTargetData(), _
                               strDelimiter, _
                               strHeaders, _
                               strError) THEN
      funLog("Array Reformatted")
      '
      ' dump the array?
      lngDimensions = ARRAYATTR(a_strTargetData(),3)
      '
      SELECT CASE lngDimensions
        CASE 1
          funArraySave_1D(EXE.PATH$ & $OutputFile, _
                         BYREF a_strTargetData(), _
                         strDelimiter, _
                         strDelimiter)
        CASE 2
          funArraySave_2D(EXE.PATH$ & $OutputFile, _
                          BYREF a_strTargetData(), _
                          strDelimiter)
      END SELECT
      '
    ELSE
      funLog("Array failed to reformat" & $CRLF & strError)
    END IF
  ELSE
    funLog("Unable to load the input file")
  END IF


  funWait()
  '
END FUNCTION
'
