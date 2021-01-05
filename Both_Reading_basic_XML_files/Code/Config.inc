' config.inc

' set up the global variable to contain the
' values defined in the XML file
GLOBAL g_strServerName AS STRING
GLOBAL g_strDiskDrive AS STRING
'
'
FUNCTION funGetXMLValues() AS LONG
' get the xml values from the xml config file
  LOCAL strSection AS STRING
  LOCAL strXMLFile AS STRING
  '
  strXMLFile = EXE.PATH$ & "Config.xml"
  '
  ' define the section you are wanting the value for
  strSection = "\Cluster\ServerName"
  g_strServerName = funGetXML(strXMLFile,strSection)
  '
  ' repeat for each item of information
  strSection = "\Cluster\DiskDetails\Drive"
  g_strDiskDrive = funGetXML(strXMLFile,strSection)
  '
  ' optionally test to determine that you have successfully
  ' read the XML and have populated enough of the global
  ' variables
  IF g_strServerName <> "" AND g_strDiskDrive <> "" THEN
  ' everything seems ok
    FUNCTION = %TRUE
  ELSE
  ' unable to find the xml file or either of the
  ' items have no value
    FUNCTION = %FALSE
  END IF
  '
END FUNCTION
