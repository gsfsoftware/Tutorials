#COMPILE EXE
#DIM ALL
'
#INCLUDE "PB_commandLine.inc"
'
FUNCTION PBMAIN () AS LONG
' this is the called application
  COLOR 10,-1
  CON.STDOUT "Application called " & TIME$
  '
  ' pick up basic parameters
  'funBasicParameters()
  '
  ' pick up advanced parameters
  funAdvancedParameters()
  '
  CON.STDOUT "Press any key to exit"
  '
  WAITKEY$
  '
END FUNCTION
'
FUNCTION funAdvancedParameters() AS LONG
' pick up advanced parameters
  LOCAL strParameters AS STRING
  strParameters = COMMAND$
  '
  LOCAL strFilepath AS STRING
  LOCAL strLegend AS STRING
  LOCAL strData AS STRING
  LOCAL strTitle AS STRING
  '
  strFilepath = funReturnNamedParameterEXP("/FileNamePath#", _
                                           strParameters)
                                           '
  strLegend = funReturnNamedParameterEXP("/LEGEND#", _
                                           strParameters)
                                           '
  strData = funReturnNamedParameterEXP("/DATA#", _
                                         strParameters)
  strTitle = funReturnNamedParameterEXP("/TITLE#", _
                                         strParameters)                                       '
                                         '
  CON.STDOUT "Filepath = " & strFilepath
  CON.STDOUT "Legend   = " & strLegend
  CON.STDOUT "Data     = " & strData
  CON.STDOUT "Title    = " & strTitle
  '
END FUNCTION
'
FUNCTION funBasicParameters() AS LONG
' pick up basic parameters
  LOCAL strParameters AS STRING
  strParameters = COMMAND$
  '
  CON.STDOUT strParameters
  CON.STDOUT "Tally of Blocks = " & _
             FORMAT$(TALLY(strParameters,"."))
END FUNCTION
