' PB_Common_Strings

FUNCTION funStartRangeParse(strString AS STRING, _
                            strDelimeter AS STRING, _
                            lngEndElement AS LONG) AS STRING
' return the range of elements in strString
' starting from the first element up to and
' including the last element
'
  LOCAL strData AS STRING
  LOCAL lngR AS LONG
  '
  strData = ""
  FOR lngR = 1 TO lngEndElement
    strData = strData & PARSE$(strString,strDelimeter,lngR) & strDelimeter
  NEXT lngR
  '
  FUNCTION = strData
END FUNCTION
'
