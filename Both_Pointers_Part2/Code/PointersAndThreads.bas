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
#INCLUDE "..\Libraries\PB_ThreadFunctions.inc"
'
%StartSection  = 1
%TotalSections = 5
%MaxBlockSize = 20000
'
TYPE udtSearchParams
  strFieldToSearch AS STRING * 50
  strValueWanted   AS STRING * 50
  strOutputFile    AS STRING * 50
  strTargetFile    AS STRING * 50
  lngStartRow      AS LONG
  lngEndRow        AS LONG
  lngSection       AS LONG
END TYPE
'
FUNCTION PBMAIN () AS LONG
' the main PB function that is the first to be executed
  funPrepOutput("Pointers and Threads",0,0,40,120)
  '
  funLog("Pointers and Threads")
  '
  DIM idThread(1 TO %TotalSections) AS LONG
  DIM idThreadStatus(1 TO %TotalSections) AS LONG
  '
  LOCAL lngSection AS LONG
  LOCAL uSearchInfo AS udtSearchParams
  LOCAL lngStartRow AS LONG
  LOCAL lngEndRow   AS LONG
  '
  funLog("Running threaded")
  FOR lngSection = %StartSection TO %TotalSections
    ' work out the start and end rows to process
    lngStartRow = (lngSection * %MaxBlockSize) - (%MaxBlockSize -1)
    lngEndRow = lngStartRow + %MaxBlockSize - 1
    '
    PREFIX "uSearchInfo."
      strFieldToSearch = "Eye Colour"
      strValueWanted   = "Amber"
      strOutputFile    = "Data\SearchOutput_" & FORMAT$(lngSection) & ".txt"
      strTargetFile    = "Data\MyLargeFile.txt"
      lngStartRow      = lngStartRow
      lngEndRow        = lngEndRow
      lngSection       = lngSection
    END PREFIX
    '
    THREAD CREATE funProcessFileSection(BYVAL VARPTR(uSearchInfo)) _
                    TO idThread(lngSection)
                    '
    SLEEP 5
  NEXT lngSection
  '
  funWaitForThreads(%TotalSections, idThread(), 1)
  funWait()
  '
END FUNCTION
'
FUNCTION funGetParameters(uSearchInfo AS udtSearchParams, _
                          strFieldToSearch AS STRING, _
                          strValueWanted AS STRING, _
                          strOutputFile AS STRING, _
                          strTargetFile AS STRING, _
                          lngStartRow AS LONG, _
                          lngEndRow AS LONG, _
                          lngSection AS LONG) THREADSAFE AS LONG
                          '
  ' pause the other threads while the search parameters are picked
' up by this thread
  strFieldToSearch = TRIM$(uSearchInfo.strFieldToSearch)
  strValueWanted   = TRIM$(uSearchInfo.strValueWanted)
  strOutputFile    = TRIM$(uSearchInfo.strOutputFile)
  strTargetFile    = TRIM$(uSearchInfo.strTargetFile)
  lngStartRow      = uSearchInfo.lngStartRow
  lngEndRow        = uSearchInfo.lngEndRow
  lngSection       = uSearchInfo.lngSection
END FUNCTION
'
THREAD FUNCTION funProcessFileSection _
                (BYVAL pType AS udtSearchParams PTR) AS LONG
  LOCAL uSearchInfo AS udtSearchParams ' set up a local type
  uSearchInfo = @pType
  '
  LOCAL lngStartRow AS LONG        ' the row to start at
  LOCAL lngEndRow AS LONG          ' the row to end at
  LOCAL lngSection AS LONG         ' the section number
  LOCAL strFieldToSearch AS STRING ' field to search
  LOCAL strValueWanted   AS STRING ' value looked for
  LOCAL strOutputFile    AS STRING ' name/path of output file
  LOCAL strTargetFile    AS STRING ' file to read
  '
  ' get the parameters to use
  funGetParameters(uSearchInfo, _
                   strFieldToSearch, _
                   strValueWanted, _
                   strOutputFile, _
                   strTargetFile, _
                   lngStartRow, _
                   lngEndRow, _
                   lngSection)
                   '
  funLog("Thread " & FORMAT$(lngSection) & " reading rows " & _
                     FORMAT$(lngStartRow) & " to " & _
                     FORMAT$(lngEndRow) & " Output to " & _
                     strOutputFile)                   '

'
END FUNCTION
