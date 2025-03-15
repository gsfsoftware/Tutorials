' DriveInfo.inc
'
TYPE VolInfoType
  VolName       AS ASCIIZ * %MAX_PATH
  VolSerial     AS DWORD
  FileLength    AS DWORD
  FileSysFlags  AS DWORD
  FileSysName   AS ASCIIZ * %MAX_PATH
  DriveType     AS ASCIIZ * %MAX_PATH
  lZ            AS ASCIIZ * %MAX_PATH
END TYPE
'
DECLARE FUNCTION GetLogicalDriveStringsFix LIB _
                "KERNEL32.DLL" ALIAS "GetLogicalDriveStringsA" _
                (BYVAL nBufferLength AS DWORD, lpBuffer AS ANY) AS DWORD
                 '
FUNCTION funGetDriveSpace() AS STRING
  LOCAL Temp AS STRING, lString AS STRING, lRet AS LONG, lCnt AS LONG, lZ AS ASCIIZ * %MAX_PATH
  DIM strDriveInfo AS STRING
  DIM lZStr    AS STRING * 1024
  DIM VolInf(100) AS GLOBAL VolInfoType

  STATIC i&,OldPause&,AboutOn&, OldPlay&
      lZStr = STRING$(1024,0)
      lRet = GetLogicalDriveStringsFix (SIZEOF(lzStr), lZStr)
      lZStr = LEFT$(lzStr, lRet)
      FOR lCnt = 1 TO PARSECOUNT (lZStr, CHR$(0)) -1
        lZ = PARSE$(lzStr, CHR$(0), lCnt)
        'COMBOBOX ADD hDlg, %CMB_DRIVES, lZ
        lRet = GetDriveType (lZ)
        SELECT CASE lRet
          CASE %DRIVE_UNKNOWN     : Temp$ = "Cannot be determined"
          CASE %DRIVE_NO_ROOT_DIR : Temp$ = "Path does not exist"
          CASE %DRIVE_REMOVABLE   : Temp$ = "Removable disk"
          CASE %DRIVE_FIXED       : Temp$ = "Fixed"
          CASE %DRIVE_REMOTE      : Temp$ = "Remote(Network)"
          CASE %DRIVE_CDROM       : Temp$ = "CD-Rom"
          CASE %DRIVE_RAMDISK     : Temp$ = "RAM Drive"
          CASE ELSE               : Temp$ = "Unknown"
        END SELECT
        VolInf(lCnt).DriveType = Temp$
        GetVolumeInformation lZ, _
                             VolInf(lCnt).VolName, _
                             SIZEOF (VolInf(lCnt).VolName), _
                             VolInf(lCnt).VolSerial, _
                             VolInf(lCnt).FileLength, _
                             VolInf(lCnt).FileSysFlags, _
                             VolInf(lCnt).FileSysName, _
                             SIZEOF(VolInf(lCnt).FileSysName)
         VolInf(lCnt).lZ = lZ
         'Ignore any CD drives or network drives
         IF  VolInf(lCnt).DriveType = "Fixed" THEN
           strDriveInfo =  strDriveInfo & lZ & " " & _
            STR$(DISKFREE(LEFT$(VolInf(lCnt).lZ,2))\(1024 * 1024 * 1024)) & "; "
         END IF
      NEXT

      FUNCTION = strDriveInfo

 END FUNCTION
'
FUNCTION funGetDriveSize() AS STRING
  ' return the size of a Drive
  LOCAL Temp AS STRING, lString AS STRING
  LOCAL lRet AS LONG, lCnt AS LONG, lZ AS ASCIIZ * %MAX_PATH
  LOCAL strDriveInfo AS STRING
  LOCAL lZStr    AS STRING * 1024
  DIM VolInf(100) AS GLOBAL VolInfoType
  '
  STATIC i&,OldPause&,AboutOn&, OldPlay&
  lZStr = STRING$(1024,0)
  lRet = GetLogicalDriveStringsFix (SIZEOF(lzStr), lZStr)
  lZStr = LEFT$(lzStr, lRet)
  '
  FOR lCnt = 1 TO PARSECOUNT (lZStr, CHR$(0)) -1
    lZ = PARSE$(lzStr, CHR$(0), lCnt)
    '
    lRet = GetDriveType (lZ)
    SELECT CASE lRet
      CASE %DRIVE_UNKNOWN     : Temp$ = "Cannot be determined"
      CASE %DRIVE_NO_ROOT_DIR : Temp$ = "Path does not exist"
      CASE %DRIVE_REMOVABLE   : Temp$ = "Removable disk"
      CASE %DRIVE_FIXED       : Temp$ = "Fixed"
      CASE %DRIVE_REMOTE      : Temp$ = "Remote(Network)"
      CASE %DRIVE_CDROM       : Temp$ = "CD-Rom"
      CASE %DRIVE_RAMDISK     : Temp$ = "RAM Drive"
      CASE ELSE               : Temp$ = "Unknown"
    END SELECT
    VolInf(lCnt).DriveType = Temp$
    GetVolumeInformation lZ, _
                         VolInf(lCnt).VolName, _
                         SIZEOF (VolInf(lCnt).VolName), _
                         VolInf(lCnt).VolSerial, _
                         VolInf(lCnt).FileLength, _
                         VolInf(lCnt).FileSysFlags, _
                         VolInf(lCnt).FileSysName, _
                         SIZEOF(VolInf(lCnt).FileSysName)
    VolInf(lCnt).lZ = lZ
    'Ignore any CD drives or network drives
    SELECT CASE VolInf(lCnt).DriveType
      CASE "Fixed","Removable disk"
        strDriveInfo =  strDriveInfo & lZ & " " & _
         FORMAT$(DISKSIZE(LEFT$(VolInf(lCnt).lZ,2))\(1024*1024*1024)) & "; "
    END SELECT
  NEXT lCnt
  '
  FUNCTION = strDriveInfo
END FUNCTION

 FUNCTION funHowBigisFolder (BYVAL sFolder AS STRING) AS QUAD
    FUNCTION = -1
    LOCAL Q AS QUAD
    sFolder = RTRIM$(sFolder, "\")
    LOCAL L AS LONG
    ERRCLEAR
    L = ((GETATTR(sFolder) AND %SUBDIR) = %SUBDIR)
    IF ERRCLEAR THEN EXIT FUNCTION
    IF ISFALSE L THEN EXIT FUNCTION
    LOCAL DMode AS DWORD
    DMode = SetErrorMode(%SEM_FAILCRITICALERRORS)
    CALL zHowBigFolder(sFolder, Q)
    SetErrorMode DMode
    FUNCTION = Q
END FUNCTION
'
SUB zHowBigFolder (BYVAL A AS STRING, B AS QUAD)
    LOCAL x AS WIN32_FIND_DATA, DHandle AS DWORD
    DHandle = FindFirstFile(A + "\*.*", x)
    IF DHandle <> %INVALID_HANDLE_VALUE THEN
        DO
            IF ASC(x.cFileName) <> 46 THEN
                IF BIT(x.dwFileAttributes, 4) = 0 THEN
                    B = B + ((x.nFileSizeHigh * &H100000000) + x.nFileSizeLow)
                ELSE
                    CALL zHowBigFolder(A + "\" + x.cFileName, B)
                END IF
            END IF
        LOOP WHILE FindNextFile(DHandle, x)
        FindClose DHandle
    END IF
END SUB
