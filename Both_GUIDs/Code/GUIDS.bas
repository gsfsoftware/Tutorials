#COMPILE EXE
#DIM ALL
#DEBUG ERROR ON
'
#TOOLS OFF
'
' include the common display library
#INCLUDE "win32api.inc"
#INCLUDE "..\Libraries\CommonDisplay.inc"
'
FUNCTION PBMAIN () AS LONG
' the main PB function that is the first to be executed
  funPrepOutput("GUIDs",0,0,40,120)
  '
  ' A GUID is a "Globally Unique Identifier", a very large
  ' number which is used to uniquely identify every interface,
  ' every class, and every COM application or library which
  ' exists anywhere in the world.
  '
  ' GUID is basically windows terminology
  ' UUID Universal unique identifier is used everywhere else
  ' but they are basically the same thing
  '
  ' There are historically five versions of GUID/UUID
  ' version 1 used date-time and MAC address
  ' version 4 is random
  ' generating 1 thousand million GUID/UUIDs per second for about 85 years.
  ' to get 50% probability of at least one collision
  '
  ' A GUID is a 16-byte (128-bit) value
  LOCAL oID_1 AS GUID   ' GUID is a 16 byte binary string
  LOCAL oID_2 AS GUID
  LOCAL oID_3 AS GUID
  LOCAL oID_4 AS GUID
  '
  ' calling GUID with no parameters generates a new GUID value
  oID_1 = GUID$()
  oID_2 = GUID$()

  ' you can set your own value 32 digits with optional space or hyphens
  oID_3 = GUID$("{09322F3F-2902-42B2-9DA5-B5579A4583FE}")
  oID_4 = GUID$("{9B22F457-2EB6-4ADE-A155-81D2293C849F}")
  '
  ' and use the GUIDTXT to output it in readable form
  funLog GUIDTXT$(oID_1)
  funLog GUIDTXT$(oID_2)
  funlog GUIDTXT$(oID_4)
  '
  ' when creating objects for use inside your own applications
  ' you don't need to specify a GUID as PowerBasic will create
  ' these for you. However if you plan on creating objects in
  ' the Windows compiler for external use through a COM service
  ' you need to generate an explicit GUID to identify them.
  '
  funWait()
  '
END FUNCTION
'
