' PB_Common_Strings.inc

' index to functions
'
' funEndRangeParse(strString , strDelimiter, _
'                  lngStartElement) - return an end section
'                  of a string for a number of elements
'
' funParseFind(strString,strDelimiter , _
'              strSearchCriteria)  - return the column number
'              that the searched for string exists in, counting
'              from the left
'
' funParseFindReverse(strString,strDelimiter, _
'                     strSearchCriteria) - return the column number
'                     that the searched for string exists in, counting
'                     from the right
'
' funParsePut(strString,strDelimiter,lngElement, _
'                     strValue) - slot a replacement value into a string
'                     at a specified column position
'
' funStartRangeParse(strString,strDelimiter, _
'                    lngEndElement) - return a beginning section
'                    of a string for a number of elements

%CommonStrings = 1  ' PB common strings in use flag

'
FUNCTION funStartRangeParse(strString AS STRING, _
                            strDelimiter AS STRING, _
                            lngEndElement AS LONG) AS STRING
' return the range of elements in strString
' starting from the first element up to and
' including the last element
'
  LOCAL strData AS STRING
  LOCAL lngR AS LONG
  LOCAL strLocalDelimiter AS STRING
  LOCAL strValue AS STRING
  '
  strLocalDelimiter = strDelimiter
  IF strDelimiter = "," THEN
  ' handle special case for comma delimited
    strLocalDelimiter = ""
  END IF
  '
  strData = ""
  FOR lngR = 1 TO lngEndElement
    strValue = PARSE$(strString,strLocalDelimiter,lngR)
    '
    IF INSTR(strValue,",") AND strDelimiter = "," THEN
    ' wrap in double quotes
      strValue = WRAP$(strValue, $DQ,$DQ)
    END IF
    '
    strData = strData & _
              strValue & _
              strDelimiter
  NEXT lngR
  '
  FUNCTION = strData
END FUNCTION
'
FUNCTION funEndRangeParse(strString AS STRING, _
                          strDelimiter AS STRING, _
                          lngStartElement AS LONG) AS STRING
' return the range of elements
  LOCAL strData AS STRING
  LOCAL lngR AS LONG
  LOCAL strLocalDelimiter AS STRING
  LOCAL strValue AS STRING
  '
  strLocalDelimiter = strDelimiter
  IF strDelimiter = "," THEN
  ' handle special case for comma delimited
    strLocalDelimiter = ""
  END IF
  '
  strData = strDelimiter
  '
  FOR lngR = lngStartElement TO _
             PARSECOUNT(strString, strLocalDelimiter)
    '
    strValue = PARSE$(strString,strLocalDelimiter,lngR)
    IF INSTR(strValue,",") AND strDelimiter = "," THEN
    ' wrap in double quotes
      strValue = WRAP$(strValue, $DQ,$DQ)
    END IF
    '
    strData = strData & _
              strValue & _
              strDelimiter
  NEXT lngR
  '
  strData = RTRIM$(strData,strDelimiter)
  FUNCTION = strData
  '
END FUNCTION
'
FUNCTION funParseFind(strString AS STRING, _
                      strDelimiter AS STRING, _
                      strSearchCriteria AS STRING) AS LONG
' return the position in a delimeted string that a
' target exists in - returning 0 if not in the string
  LOCAL lngR AS LONG
  LOCAL strLocalDelimiter AS STRING
  '
  strLocalDelimiter = strDelimiter
  IF strDelimiter = "," THEN
  ' handle special case for comma delimited
    strLocalDelimiter = ""
  END IF
  '
  TRY
    FOR lngR = 1 TO PARSECOUNT(strString, strLocalDelimiter)
      IF PARSE$(strString,strLocalDelimiter,lngR) = strSearchCriteria THEN
        FUNCTION = lngR
        EXIT FUNCTION
      END IF
    NEXT lngR
    '
    FUNCTION = 0
  CATCH
    FUNCTION = 0
  FINALLY
  END TRY
'
END FUNCTION
'
FUNCTION funParseFindReverse(strString AS STRING, _
                             strDelimiter AS STRING, _
                             strSearchCriteria AS STRING) AS LONG
' return the position in a delimeted string that a target
' exists in - returning 0 if not in the string
' but working from the right of the string
  LOCAL lngR AS LONG
  LOCAL strLocalDelimiter AS STRING
  '
  strLocalDelimiter = strDelimiter
  IF strDelimiter = "," THEN
  ' handle special case for comma delimited
    strLocalDelimiter = ""
  END IF
  '
  TRY
    FOR lngR = 1 TO PARSECOUNT(strString, strLocalDelimiter)
      IF PARSE$(strString,strLocalDelimiter,(-1 * lngR)) = strSearchCriteria THEN
        FUNCTION = (-1 * lngR)
        EXIT FUNCTION
      END IF
    NEXT lngR
    '
    FUNCTION = 0
  CATCH
    FUNCTION = 0
  FINALLY
  END TRY
'
END FUNCTION
'
FUNCTION funParsePut(strString AS STRING, _
                     strDelimiter AS STRING, _
                     lngElement AS LONG, _
                     strValue AS STRING) AS STRING
' attempt to slot strValue into strString at the element location
' returning updated value of strString
'
  LOCAL strBefore AS STRING
  LOCAL strAfter AS STRING
  LOCAL strLocalDelimiter AS STRING
  '
  strLocalDelimiter = strDelimiter
  IF strDelimiter = "," THEN
  ' handle special case for comma delimited
    strLocalDelimiter = ""
  END IF
  '
  IF PARSECOUNT(strString,strLocalDelimiter)< lngElement THEN
    FUNCTION = strString
    EXIT FUNCTION
  END IF
  '
  strBefore = funStartRangeParse(strString,strDelimiter,lngElement - 1)
  strAfter = funEndRangeParse(strString,strDelimiter,lngElement + 1)
  '
  FUNCTION = strBefore & strValue & strAfter
  '
END FUNCTION
