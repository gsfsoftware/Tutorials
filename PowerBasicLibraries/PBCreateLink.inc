' CreateLink.inc

'
FUNCTION funGetKnownFolder(guFolder AS GUID) AS STRING
' return the know folder
' e.g.
' $FOLDERID_Desktop
' $FOLDERID_Documents
' $FOLDERID_SendTo
' $FOLDERID_UserProgramFiles
' $FOLDERID_RoamingAppData
'
  LOCAL pwstrPath AS WSTRINGZ PTR * %MAX_PATH
  LOCAL lngResult AS LONG
  lngResult =  ShGetKnownFolderPath (guFolder, 0, 0, pwstrPath)
  '
  IF (lngResult = %S_OK) THEN
    FUNCTION = @pwstrPath & "\"
  END IF
  '
END FUNCTION
'
DECLARE FUNCTION IShellLink_Call_1(BYVAL pUnk AS LONG) AS LONG
DECLARE FUNCTION IShellLink_Call_2(BYVAL pUnk AS LONG, _
                                   BYVAL p1 AS LONG ) AS LONG
DECLARE FUNCTION IShellLink_Call_3(BYVAL pUnk AS LONG, _
                                   BYVAL p1 AS LONG, _
                                   BYVAL p2 AS LONG ) AS LONG

' =======================================================================================
' Creates a shortcut
' =======================================================================================
#IF %DEF(%UNICODE)
  FUNCTION CreateLink ( BYVAL sLinkFile AS WSTRING, _
                        BYVAL sSourceFile AS WSTRING, _
                        BYVAL sArgs AS WSTRING, _
                        BYVAL sWorkDir AS WSTRING, _
                        BYVAL sComment AS WSTRING, _
                        BYVAL sIconFile AS WSTRING, _
                        BYVAL nIconIndex AS LONG, _
                        BYVAL nShowCmd AS DWORD) COMMON AS LONG
#ELSE
  FUNCTION CreateLink ( BYVAL sLinkFile AS STRING, _
                        BYVAL sSourceFile AS STRING, _
                        BYVAL sArgs AS STRING, _
                        BYVAL sWorkDir AS STRING, _
                        BYVAL sComment AS STRING, _
                        BYVAL sIconFile AS STRING, _
                        BYVAL nIconIndex AS LONG, _
                        BYVAL nShowCmd AS DWORD) COMMON AS LONG
#ENDIF

  LOCAL lngResult        AS LONG        ' // Function result %TRUE or %FALSE
  LOCAL hr               AS LONG        ' // HRESULT
  LOCAL sem              AS DWORD       ' // SetErrorMode
  LOCAL psl              AS DWORD PTR   ' // IShellLink interface reference
  LOCAL ppf              AS DWORD PTR   ' // IPersistFile interrace reference
  LOCAL CLSID_ShellLink  AS GUID        ' // ShellLink class identifier
  LOCAL IID_IShellLink   AS GUID        ' // IShellLink interface identifier
  LOCAL IID_Persist      AS GUID        ' // IPersistFile interface identifier
  '
  lngResult = %FALSE
  '
  ' // Fills the guids
  CLSID_ShellLink  = GUID$("{00021401-0000-0000-C000-000000000046}")
  IID_Persist      = GUID$("{0000010B-0000-0000-C000-000000000046}")
  #IF %DEF(%UNICODE)
      IID_IShellLink  = GUID$("{000214F9-0000-0000-C000-000000000046}")
  #ELSE
      IID_IShellLink  = GUID$("{000214EE-0000-0000-C000-000000000046}")
      sLinkFile       = UCODE$(sLinkFile)    ' --> :)
  #ENDIF
  '
  CALL CoInitialize(BYVAL 0&)
  '
  ' // Creates an instance of the IShellLink interface
  IF CoCreateInstance( BYVAL VARPTR( CLSID_ShellLink ), _
                       BYVAL 0&, 1, _
                       BYVAL VARPTR( IID_IShellLink ), psl ) = 0 THEN
    ' // Sets the properties of the shortcut
    ' IShellLink::SetPath
    CALL DWORD @@psl[20] USING IShellLink_Call_2( psl, _
                         STRPTR( sSourceFile ) )
    ' IShellLink::SetsArguments
    CALL DWORD @@psl[11] USING IShellLink_Call_2( psl, _
                         STRPTR( sArgs ) )
    ' IShellLink::SetWorkingDirectory
    CALL DWORD @@psl[9]  USING IShellLink_Call_2( psl, _
                         STRPTR( sWorkDir ) )
    ' IShellLink::SetnShowCmd
    CALL DWORD @@psl[15] USING IShellLink_Call_2( psl, nShowCmd )
    ' IShellLink::SetDescription
    CALL DWORD @@psl[7]  USING IShellLink_Call_2( psl, _
                         STRPTR( sComment ) )
    ' IShellLink::SetIconLocation
    CALL DWORD @@psl[17] USING IShellLink_Call_3( psl, _
                         STRPTR( sIconFile ), nIconIndex )
    ' // Obtain persist interface (QueryInterface)
    CALL DWORD @@psl[0] USING IShellLink_Call_3( psl, _
                        VARPTR( IID_Persist ), VARPTR( ppf ) ) TO hr
    IF hr = 0 THEN
      sem = SetErrorMode(%SEM_FAILCRITICALERRORS)
      ' // IPersistFile::Save
      CALL DWORD @@ppf[6] USING IShellLink_Call_3( ppf, _
                          STRPTR( sLinkFile ), 1 ) TO hr
      IF hr = 0 THEN lngResult = %TRUE
      SetErrorMode sem
      ' // Releases the IPersistFile interface
      CALL DWORD @@ppf[2] USING IShellLink_Call_1( ppf )
    END IF
    ' // Releases the IShellLink interface
    CALL DWORD @@psl[2] USING IShellLink_Call_1( psl )
  END IF
  '
  CALL CoUninitialize()
  '
  FUNCTION = lngResult
  '
END FUNCTION
