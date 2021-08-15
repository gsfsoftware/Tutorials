'
' DBServer functions and variables

GLOBAL g_strSQLServer AS STRING       ' name of the SQL server
GLOBAL g_strDBDatabase AS STRING      ' name of the database to access
GLOBAL g_strWebServer AS STRING       ' name of the web server e.g. "csa2002:8000/PI"
GLOBAL g_strLiveSQLServerName AS STRING    ' the name of the live SQL server machine - used to determine if we are
                                           ' to the live or test environments
GLOBAL g_strEnc_ComputerOwnersAdminPSW AS STRING
GLOBAL g_lngSystemActive AS LONG
GLOBAL g_strPublishLocation AS STRING  ' string to which the projects htm file is published to

FUNCTION funGetXMLValues() AS LONG
' get the xml values from the xml config file
  LOCAL strSection AS STRING
  LOCAL strXMLFile AS STRING
  '
  g_lngSystemActive = %TRUE
  '
  strXMLFile = EXE.PATH$ & "DBServer.xml"
  '
  strSection = "\DBServer\LiveSQLServerName"
  g_strLiveSQLServerName = LCASE$(funGetXML(strXMLFile,strSection))
  '
  strSection = "\DBServer\PublishLocation"
  g_strPublishLocation = funGetXML(strXMLFile,strSection)
  '
  strSection = "\DBServer\SQLServer"
  g_strSQLServer = funGetXML(strXMLFile,strSection)
  '
  strSection = "\DBServer\SQLDBDatabase"
  g_strDBDatabase = funGetXML(strXMLFile,strSection)
  '
  strSection = "\DBServer\WebServer"
  g_strWebServer = funGetXML(strXMLFile,strSection)
  '
  strSection = "\DBServer\UserAccess\ComputerOwnersAdmin"
  g_strEnc_ComputerOwnersAdminPSW = funGetXML(strXMLFile,strSection)
  '
  IF g_strSQLServer <>"" AND g_strDBDatabase <>"" AND g_strWebServer <>"" THEN
  ' check mandatory fields are not blank
    FUNCTION = %TRUE
  END IF
  '
END FUNCTION
