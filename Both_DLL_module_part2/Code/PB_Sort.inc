' PB_Sort.inc
' documentation
'
' This Function takes 6 parameters and returns a %True if the
' function succeeds and %False if it does not
' Should if fail the Error should be in the strError parameter
'
' Purpose
' The purpose of this function is to accept an single dimension
' array and give the option to sort the array based on a column
' delimited within the row.
'
' Parameters
' BYREF a_strWork() AS STRING - Input and Output
' This array holds the data in a single dimesion string array
'
' strSortType AS STRING - Input
' the variable type of the column you are sorting on which can be
' SINGLE, DOUBLE, CURRENCY, LONG, STRING
'
' lngField as long - Input
' the field number to sort on
'
' strDelimiter AS STRING  - Input
' the column separator e.g. , $TAB or any character string
'
' strSortOrder AS STRING - Input
' ASCEND or DESCEND - {default to DESCEND if not "ASCEND"}
'
' strError AS STRING - Output
' In the event of an error the error description will be
' in this variable
'
' define the DLL function and its parameters
DECLARE FUNCTION funArraySort IMPORT "DLLs\PB_Sort.DLL" _
                         ALIAS "funDLLArraysort" _
                        (BYREF a_strWork() AS STRING, _
                         strSortType AS STRING, _
                         lngField AS LONG, _
                         strDelimiter AS STRING, _
                         strSortOrder AS STRING, _
                         strError AS STRING) AS LONG
