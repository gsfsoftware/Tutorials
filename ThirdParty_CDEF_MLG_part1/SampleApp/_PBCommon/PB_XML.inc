' ---------------------------------------------------------
' XML Array parser   PB_XML.inc
'
' ParseXMLFile is a simple XML parser that take an XMLFile and
' parse it elements to pairs of element_name & value, stored on
' two arrays passed as parameters.
' This way ARRAY SCAN can used to quickly locate a particular key of
' of interest, for example.
' Return the number of elements in the arrays, or 0 if some errors occured.
' Don't parse attributes (but this could be added with ease if needed).
' Speed around 80,000 lines per second on a XP/2200.
'
' Example. Parsing an XML file like the ones generated for Generic Builder:
'
' <Generic_Builder>
'   <Version>"1.1"</Version>
'   <PVCS>
'     <PVCS_Codebase_Location>"\\pvcs\pvcsdata$\vm\Projects\GenericBuilder"</PVCS_Codebase_Location>
'     <PVCS_Users_Location>"\\pvcs\pvcsdata$\Scripts\_Users"</PVCS_Users_Location>
'     <Current_Label>"Current"</Current_Label>
'     <User_Build_Folder_name>"BuildFiles"</User_Build_Folder_name>
'     <JSCRIPT_PATH>"<JSCRIPT_ROOT_PATH#~,,>"</JSCRIPT_PATH>
'     <WIN_ROOT_PATH>"<WIN_ROOT_PATH#~,,>"</WIN_ROOT_PATH>
'   </PVCS>
' </Generic_Builder>
'
' The arrays will look as:
'
' #   Element Name                     Value
' -------------------------------------------------------------------
'  1  "\TrID\Info\FileType"            "Direct3D Object"
'  2  "\TrID\Info\Ext                  "X"
'  3  "\TrID\Info\User                 "Marco Pontello"
'  4  "\TrID\Info\E-Mail               "marcopon@nospam@myrealbox.com"
'  5  "\TrID\Info\Home                 "http://mark0.ngi.it"
'  6  "\TrID\General\FileNum           "12"
'  7  "\TrID\General\Date\Year         "2003"
'  8  "\TrID\General\Date\Month        "6"
'  9  "\TrID\General\Date\Day          "2"
' 10  "\TrID\General\Time\Hour         "0"
' 11  "\TrID\General\Time\Min          "51"
' 12  "\TrID\General\Time\Sec          "13"
' 13  "\TrID\General\Creator           "TrIDScan v0.52b"
' 14  "\TrID\FrontBlock\Pattern\Bytes  "786F6620303330"
' 15  "\TrID\FrontBlock\Pattern\Pos=   "0"
' 16  "\TrID\FrontBlock\Pattern\Bytes  "203030"
' 17  "\TrID\FrontBlock\Pattern\Pos    "11"
'

#IF NOT %DEF(%PB_XML_INC)
' only load if not loaded already
%PB_XML_INC = 1

GLOBAL g_strXMLFile AS STRING       ' Global string to hold name of XML File in memory
GLOBAL g_a_Elements() AS STRING     ' Global elements parsed
GLOBAL g_a_Values() AS STRING       ' Global values parsed


DECLARE FUNCTION funParseXMLFile(pFileName$, pEleName$(), pEleValu$()) AS LONG
DECLARE FUNCTION funGetXMLvalue(strXMLfile AS STRING, strSection AS STRING, strValue AS STRING) AS LONG
DECLARE FUNCTION funParseXMLFile(pFileName$, BYREF pEleName$(), BYREF pEleValu$()) AS LONG
DECLARE FUNCTION funGetXMLvalueFromArray(BYREF a_strElements() AS STRING, _
                 BYREF a_strValues() AS STRING, BYVAL strSection AS STRING, BYREF o_strValue AS STRING)AS LONG
DECLARE FUNCTION funLoadXMLToArrays(BYVAL strXMLFile AS STRING, BYREF a_strElements() AS STRING, _
                 BYREF a_strValues() AS STRING) AS LONG

'
'function pbmain
'  DIM Elements$(1), Value$(1)
'  t! = TIMER
'  Res = ParseXMLFile(XMLFile$, Elements$(), Value$())
'end function
'
FUNCTION funGetXML(strXMLfile AS STRING, strSection AS STRING) AS STRING
' get the xml value and return it
  LOCAL strValue AS STRING
  '
  IF ISTRUE funGetXMLvalue(strXMLfile, strSection, strValue) THEN
    FUNCTION = strValue
  ELSE
    FUNCTION = ""
  END IF
  '
END FUNCTION
'
FUNCTION funGetXMLvalue(strXMLfile AS STRING, strSection AS STRING, strValue AS STRING) AS LONG
' get a value from an xml file

  DIM lngI AS LONG     ' index for array scan

  'determine if array is already loaded
  IF TRIM$(LCASE$(strXMLfile)) <> LCASE$(g_strXMLFile) THEN
    ' not loaded so load the array
    DIM g_a_Elements(0 TO 1) AS STRING
    DIM g_a_Values(0 TO 1) AS STRING
    'STDOUT "Loading array"

    IF ISTRUE funParseXMLFile(strXMLFile, g_a_Elements(),g_a_Values()) THEN
      ' array loaded ok
    ELSE
      'problem loading array
      FUNCTION = %FALSE
      EXIT FUNCTION
    END IF
    ' set global variable
    g_strXMLFile = TRIM$(LCASE$(strXMLfile))
  ELSE
    'already loaded
  END IF

  ' get data from array
  strValue = ""
  ARRAY SCAN g_a_Elements(), COLLATE UCASE, = strSection, TO lngI
  '
  IF lngI > 0 THEN
    strValue = g_a_Values(lngI-1)
    REPLACE "&lt;" WITH "<" IN strValue
    REPLACE "&gt;" WITH ">" IN strValue
    FUNCTION = %TRUE
  ELSE
    strValue = ""
    FUNCTION = %FALSE
  END IF
    '
'
END FUNCTION
'

FUNCTION funLoadXMLToArrays(BYVAL strXMLFile AS STRING, BYREF a_strElements() AS STRING, BYREF a_strValues() AS STRING) AS LONG
' load an xml file into two global arrays
'
  IF ISTRUE funParseXMLFile(strXMLFile,a_strElements(),a_strValues()) THEN
    FUNCTION = %TRUE
  ELSE
    FUNCTION = %FALSE
  END IF
  '
END FUNCTION
'
FUNCTION funGetXMLvalueFromArray(BYREF a_strElements() AS STRING, BYREF a_strValues() AS STRING, BYVAL strSection AS STRING, _
                                BYREF o_strValue AS STRING)AS LONG
' get a value from an XML array in memory - returning the value in o_strValue and True or False to the function
' where a_strElements is the preloaded XML Element paths and a_strValues are the preloaded Values
'
    DIM lngI AS LONG
    '
    o_strValue = ""
    ARRAY SCAN a_strElements(), COLLATE UCASE, = strSection, TO lngI
    '
    IF lngI > 0 THEN
      o_strValue = a_strValues(lngI-1)
      REPLACE "&lt;" WITH "<" IN o_strValue
      REPLACE "&gt;" WITH ">" IN o_strValue
      FUNCTION = %TRUE
    ELSE
      o_strValue = ""
      FUNCTION = %FALSE
    END IF
    '
END FUNCTION
'
FUNCTION funParseXMLFile(pFileName$, BYREF pEleName$(), BYREF pEleValu$()) AS LONG
  ' initial & increment size for the elements arrays
  ' can be adjusted as needed for big/small files,
  ' or passed as a parameter
  DIM DimLines AS LONG
  DIM IncrLines AS LONG
  DIM TopNestLevel AS LONG
  DIM IncrNestLevel AS LONG
  DIM XF AS LONG
  DIM XML$,Tok$, c$
  DIM KeyStr$
  DIM CheckRem AS LONG
  DIM NestLevel AS LONG
  DIM CurLine AS LONG
  DIM InTag AS LONG
  DIM InRem AS LONG
  DIM p AS LONG, i AS LONG
  DIM CPtr AS LONG
  DIM Section$()
  '
  '
  DimLines = 100
  IncrLines = 1000
  ' idem for the XML nest level
  TopNestLevel = 20
  IncrNestLevel = 50
  ' check if the XML file exist and load it as a (big) string
  IF DIR$(pFileName$) = "" THEN
    EXIT FUNCTION
  END IF
  XF = FREEFILE
  OPEN pFileName$ FOR BINARY ACCESS READ LOCK SHARED AS XF
  IF ERRCLEAR <> 0 THEN
    EXIT FUNCTION
  END IF
  XML$ = SPACE$(LOF(XF))
  GET XF, , XML$
  CLOSE XF
  ' strip CRLF from XML stream
  REPLACE CHR$(13,10) WITH "" IN XML$
  ' strip TAB from XML stream
  REPLACE CHR$(9) WITH " " IN XML$

  ' check if there's need to parse remarks
  IF INSTR(XML$, "!--") THEN
    CheckRem = %TRUE
  ELSE
    CheckRem = %FALSE
  END IF

  ' prepare the arrays and start the main loop
  REDIM pEleName$(DimLines)
  REDIM pEleValu$(Dimlines)
  RESET pEleName$()
  RESET pEleValu$()
  REDIM Section$(TopNestLevel)
  NestLevel = 0
  CurLine = 0
  CPtr = 1
  InTag = %FALSE
  InRem = %FALSE   '     search inside Remarks

  DO
    ' scan the XML stream for an <element> or text between elements
    Tok$ = ""
    p = INSTR(CPtr, XML$, ANY "<>")

    IF p = 0 THEN
      EXIT DO
    END IF

    C$ = MID$(XML$, p, 1)

    Tok$ = MID$(XML$, CPtr, p - CPtr)
    CPtr = p + 1
    Tok$ = TRIM$(Tok$)

    ' check for comments
    IF CheckRem = %TRUE THEN
      IF LEFT$(Tok$, 3) = "!--" THEN
        InRem = %TRUE
      END IF
      IF InRem = %TRUE THEN
        IF RIGHT$(Tok$, 2) = "--" THEN
          InRem = %FALSE
        END IF
        Tok$ = ""
      END IF
    END IF

    IF Tok$ <> "" THEN
      ' some text found. parse it...

      IF C$ = ">" THEN
        ' tok$ is an element name

        ' check that it isn't a special element/directive, etc.
        IF NOT (LEFT$(Tok$, 1) = "?" AND RIGHT$(Tok$, 1) = "?") THEN
          IF NOT (LEFT$(Tok$, 1) = "!") THEN
            ' take only the first token = element name
            ' (can be easyly modified to parse attributes, if needed)
            IF RIGHT$(Tok$, 1) <> "/" THEN
              Tok$ = PARSE$(Tok$, CHR$(32), 1)
              IF LEFT$(Tok$, 1) = "/" THEN
                DECR NestLevel
              ELSE
                INCR NestLevel
                ' check if more levels are needed
                IF NestLevel > TopNestLevel THEN
                  TopNestLevel = TopNestLevel + IncrNestLevel
                  REDIM PRESERVE Section$(TopNestLevel)
                END IF
                Section$(NestLevel) = Tok$
              END IF
            END IF
          END IF
        END IF

      ELSE
        ' tok$ is text

        ' prepare the element name. can start from 2 if the first element/
        ' container is not needed...
        KeyStr$ = ""
        FOR i = 1 TO NestLevel
          KeyStr$ = KeyStr$ & "\" & Section$(i)
        NEXT i
        ' check if more elements are needed
        INCR CurLine
        IF CurLine > DimLines THEN
          DimLines = DimLines + IncrLines
          REDIM PRESERVE pEleName$(DimLines)
          REDIM PRESERVE pEleValu$(Dimlines)
        END IF
        ' store element name & value in the arrays
        pEleName$(CurLine) = KeyStr$
        pEleValu$(CurLine) = Tok$
      END IF

      ' check if the end of the stream is reached
      IF CPtr >= LEN(XML$) THEN
        EXIT DO
      END IF
    END IF
  LOOP
  ' resize the array to reflect the number of items found
  IF DimLines > CurLine THEN
    REDIM PRESERVE pEleName$(CurLine)
    REDIM PRESERVE pEleValu$(CurLine)
  END IF
  ' return the number of items
  FUNCTION = CurLine

END FUNCTION

FUNCTION funParseXMLFileFromResource(pFileName$, BYREF pEleName$(), BYREF pEleValu$(), XML$) AS LONG
  ' initial & increment size for the elements arrays
  ' can be adjusted as needed for big/small files,
  ' or passed as a parameter
  DIM DimLines AS LONG
  DIM IncrLines AS LONG
  DIM TopNestLevel AS LONG
  DIM IncrNestLevel AS LONG
  DIM XF AS LONG
  DIM Tok$, c$
  DIM KeyStr$
  DIM CheckRem AS LONG
  DIM NestLevel AS LONG
  DIM CurLine AS LONG
  DIM InTag AS LONG
  DIM InRem AS LONG
  DIM p AS LONG, i AS LONG
  DIM CPtr AS LONG
  DIM Section$()
  '
  '
  DimLines = 100
  IncrLines = 1000
  ' idem for the XML nest level
  TopNestLevel = 20
  IncrNestLevel = 50

'  ' check if the XML file exist and load it as a (big) string
'  IF DIR$(pFileName$) = "" THEN
'    EXIT FUNCTION
'  END IF
'  XF = FREEFILE
'  OPEN pFileName$ FOR BINARY ACCESS READ LOCK SHARED AS XF
'  IF ERRCLEAR <> 0 THEN
'    EXIT FUNCTION
'  END IF
'  XML$ = SPACE$(LOF(XF))
'  GET XF, , XML$
'  CLOSE XF

  'XML$ = Resource_Contents(pFileName$)

  g_strXMLFile = TRIM$(LCASE$(pFileName$)) ' store the resource name

  ' strip CRLF from XML stream
  REPLACE CHR$(13,10) WITH "" IN XML$
  ' strip TAB from XML stream
  REPLACE CHR$(9) WITH " " IN XML$

  ' check if there's need to parse remarks
  IF INSTR(XML$, "!--") THEN
    CheckRem = %TRUE
  ELSE
    CheckRem = %FALSE
  END IF

  ' prepare the arrays and start the main loop
  REDIM pEleName$(DimLines)
  REDIM pEleValu$(Dimlines)
  RESET pEleName$()
  RESET pEleValu$()
  REDIM Section$(TopNestLevel)
  NestLevel = 0
  CurLine = 0
  CPtr = 1
  InTag = %FALSE
  InRem = %FALSE   '     search inside Remarks

  DO
    ' scan the XML stream for an <element> or text between elements
    Tok$ = ""
    p = INSTR(CPtr, XML$, ANY "<>")

    IF p = 0 THEN
      EXIT DO
    END IF

    C$ = MID$(XML$, p, 1)

    Tok$ = MID$(XML$, CPtr, p - CPtr)
    CPtr = p + 1
    Tok$ = TRIM$(Tok$)

    ' check for comments
    IF CheckRem = %TRUE THEN
      IF LEFT$(Tok$, 3) = "!--" THEN
        InRem = %TRUE
      END IF
      IF InRem = %TRUE THEN
        IF RIGHT$(Tok$, 2) = "--" THEN
          InRem = %FALSE
        END IF
        Tok$ = ""
      END IF
    END IF

    IF Tok$ <> "" THEN
      ' some text found. parse it...

      IF C$ = ">" THEN
        ' tok$ is an element name

        ' check that it isn't a special element/directive, etc.
        IF NOT (LEFT$(Tok$, 1) = "?" AND RIGHT$(Tok$, 1) = "?") THEN
          IF NOT (LEFT$(Tok$, 1) = "!") THEN
            ' take only the first token = element name
            ' (can be easyly modified to parse attributes, if needed)
            IF RIGHT$(Tok$, 1) <> "/" THEN
              Tok$ = PARSE$(Tok$, CHR$(32), 1)
              IF LEFT$(Tok$, 1) = "/" THEN
                DECR NestLevel
              ELSE
                INCR NestLevel
                ' check if more levels are needed
                IF NestLevel > TopNestLevel THEN
                  TopNestLevel = TopNestLevel + IncrNestLevel
                  REDIM PRESERVE Section$(TopNestLevel)
                END IF
                Section$(NestLevel) = Tok$
              END IF
            END IF
          END IF
        END IF

      ELSE
        ' tok$ is text

        ' prepare the element name. can start from 2 if the first element/
        ' container is not needed...
        KeyStr$ = ""
        FOR i = 1 TO NestLevel
          KeyStr$ = KeyStr$ & "\" & Section$(i)
        NEXT i
        ' check if more elements are needed
        INCR CurLine
        IF CurLine > DimLines THEN
          DimLines = DimLines + IncrLines
          REDIM PRESERVE pEleName$(DimLines)
          REDIM PRESERVE pEleValu$(Dimlines)
        END IF
        ' store element name & value in the arrays
        pEleName$(CurLine) = KeyStr$
        pEleValu$(CurLine) = Tok$
      END IF

      ' check if the end of the stream is reached
      IF CPtr >= LEN(XML$) THEN
        EXIT DO
      END IF
    END IF
  LOOP
  ' resize the array to reflect the number of items found
  IF DimLines > CurLine THEN
    REDIM PRESERVE pEleName$(CurLine)
    REDIM PRESERVE pEleValu$(CurLine)
  END IF
  ' return the number of items
  FUNCTION = CurLine

END FUNCTION


' example function to read XML
'FUNCTION ReadXMLFile(strKey AS STRING) AS LONG
'  DIM strXMLFile AS STRING
'  DIM strValue AS STRING
'  '
'  strXMLFile = GetAppPath & GetAppName
'  '
'  REPLACE ".exe" WITH ".xml" IN strXMLFile
'  '
'  strKey = "\GenericSetup\mainEntryPoint\Processing\Metrics\totalRunTime"
'  IF ISTRUE funGetXMLvalue(strXMLFile, strKey, strValue) THEN
'    g_lngXMLTotalRunTime = VAL(strValue)
'    FUNCTION = %TRUE
'  ELSE
'    FUNCTION = %FALSE
'    EXIT FUNCTION
'  END IF

'  strKey = "\GenericSetup\mainEntryPoint\Processing\sql\TrustedConnection"
'  IF ISTRUE funGetXMLvalue(strXMLFile,strKey , strValue) THEN
'    IF UCASE$(strValue) = "TRUE" THEN
'      g_lngXMLTrustedConnection   = %TRUE
'    ELSE
'      g_lngXMLTrustedConnection   = %FALSE
'    END IF
'    FUNCTION = %TRUE
'  ELSE
'    FUNCTION = %FALSE
'    EXIT FUNCTION
'  END IF
'
#ENDIF
