#COMPILE EXE
#DIM ALL
#DEBUG ERROR ON
'
#TOOLS OFF
'
' include the common display library
#INCLUDE "win32api.inc"
#INCLUDE "..\Libraries\CommonDisplay.inc"
#INCLUDE "..\Libraries\PB_FileHandlingRoutines.inc"
'
FUNCTION PBMAIN () AS LONG
' the main PB function that is the first to be executed
  funPrepOutput("Join Command",0,0,40,120)
  '
  funLog("Join Command")
  'prepare an array to hold some string values
  DIM a_strBoxSizes(1 TO 4) AS STRING
  ARRAY ASSIGN a_strBoxSizes() = "Small","Medium","Large", "Extra large"
  '
  ' display what has arrived in the array
  LOCAL lngR AS LONG
  FOR lngR = 1 TO 4
    funLog a_strBoxSizes(lngR)
  NEXT lngR
  funlog $CRLF
  '
  ' turn the array into a delimited string with
  ' double quotes and commas
  LOCAL strList AS STRING
  strList = JOIN$(a_strBoxSizes(),$DQ & "," & $DQ)
  funLog strList & $CRLF
  '
  ' prepare a SQL query with data from a text file
  LOCAL strSQL AS STRING
  DIM a_strSQL() AS STRING
  '
  ' read the file into an array
  IF ISTRUE funReadTheFileIntoAnArray(EXE.PATH$ & "SearchFor.txt", _
                                      a_strSQL()) THEN
  ' and use the join command to populate your Where clause
    strSQL = "Select * " & $CRLF & _
             "From tbl_Tablename " & $CRLF & _
             "Where [Size] in ('" & JOIN$(a_strSQL(), _
                                    $SQ & "," & $SQ) & "')"
    funLog strSQL
  END IF
  '
  funWait()
  '
END FUNCTION
'
