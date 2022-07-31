' DriveInfo.inc
'
' Index to functions
' funGetDriveSize - return the size of each drive in system
' funGetDriveType - return the type of specified drive

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
                (BYVAL nBufferLength AS DWORD, _
                 lpBuffer AS ANY) AS DWORD

FUNCTION funGetDriveType(strDrive AS STRING) AS STRING
' get the drive type
  LOCAL lZ AS ASCIIZ * %MAX_PATH
  LOCAL lRet AS LONG
  LOCAL strType AS STRING
  '
  lZ = strDrive
  lRet = GetDriveType(lZ)
  '
  SELECT CASE lRet
    CASE %DRIVE_UNKNOWN
      strType = "Cannot be determined"
    CASE %DRIVE_NO_ROOT_DIR
      strType = "Path does not exist"
    CASE %DRIVE_REMOVABLE
      strType = "Removable disk"
    CASE %DRIVE_FIXED
      strType = "Fixed"
    CASE %DRIVE_REMOTE
      strType = "Remote(Network)"
    CASE %DRIVE_CDROM
      strType = "CD-Rom"
    CASE %DRIVE_RAMDISK
      strType = "RAM Drive"
    CASE ELSE
      strType = "Unknown"
  END SELECT
  '
  FUNCTION = strType
  '
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
