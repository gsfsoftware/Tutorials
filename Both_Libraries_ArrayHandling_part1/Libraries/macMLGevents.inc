' macMLGevents.inc
'
' index to macros
'
' mGridEventsBody - used to start the select block in the %WM_NOTIFY
'                   section
'
' mGridEventsHeader - adds in all the common variables for MLG
'
MACRO mGridEventsHeader
' set up pointer variable for grid events
  LOCAL MLGN AS MyGridData PTR ' pointers for MLG and similar events
  LOCAL ptnmhdr AS NMHDR PTR   '
  LOCAL myitem, myrow, mycol AS LONG  ' vars for selected items
  LOCAL strText AS STRING      ' text copied from grid
  LOCAL lngClipResult AS LONG  ' result of copy to clipboard
END MACRO
'
MACRO mGridEventsBody
' set up Grid events body
  MLGN=CB.LPARAM
  ptnmhdr = CB.LPARAM
  '
  SELECT CASE @MLGN.NMHeader.idFrom
  '
END MACRO
