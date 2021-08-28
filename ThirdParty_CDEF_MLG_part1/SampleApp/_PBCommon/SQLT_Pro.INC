'================================================================================== SQLT_PRO.INC
'
'SQLT_PRO.INC Copyright (C) 1999-2003, Perfect Sync, Inc. All Rights Reserved.
'SQL Tools    Copyright (C) 1999-2003, Perfect Sync, Inc. All Rights Reserved.
'
'This file contains function declarations, constants, and User Defined Types for
'SQL Tools (version 2.x) and the PowerBASIC PB/WIN, PB/DLL, and PB/CC compilers.
'
'THIS FILE MAY BE USED TO CREATE PROGRAMS, BUT YOU MAY NOT REDISTRIBUTE THIS
'FILE OR ANY PORTION THEREOF IN HUMAN-READABLE FORM.  SEE THE SQL TOOLS
'DOCUMENTATION FOR COMPLETE LICENSING AND COPYRIGHT INFORMATION, INCLUDING
'YOUR LEGAL RIGHTS AND RESPONSIBILITIES UNDER THE SQL TOOLS LICENSE AGREEMENT.
'
'Contact: support@perfectsync.com
'
'----------------------------------------------------------------------------

'TODO: BEFORE YOU CAN USE SQL TOOLS FOR THE FIRST TIME YOU WILL NEED TO
'ENTER YOUR SQL TOOLS AUTHORIZATION CODE WHERE YOU SEE THE 8 DOTS:
%MY_SQLT_AUTHCODE = &h54B83DC3

'----------------------------------------------------------------------------

'CONFIGURATION FAMILY

DECLARE Function SQL_Authorize                  LIB "SQLT_Pro.DLL" ALIAS "SQL_Authorize" _
                                                (BYVAL lAuthCode AS LONG)  _
                                                AS LONG

DECLARE FUNCTION SQL_Init                       LIB "SQLT_Pro.DLL" ALIAS "SQL_Init" _
                                                AS LONG

DECLARE FUNCTION SQL_Initialize                 LIB "SQLT_Pro.DLL" ALIAS "SQL_Initialize" _
                                                (BYVAL lMaxDatabaseNumber AS LONG, _
                                                 BYVAL lMaxStatementNumber AS LONG, _
                                                 BYVAL lMaxColumnNumber AS LONG, _
                                                 BYVAL lMaxParameterNumber AS LONG, _
                                                 BYVAL lODBCVersion AS LONG, _
                                                 BYVAL lConnPooling AS LONG, _
                                                 BYVAL lPoolMatching AS LONG, _
                                                 BYVAL hEXEInstance AS LONG) _
                                                AS LONG

DECLARE FUNCTION SQL_Shutdown                   LIB "SQLT_Pro.DLL" ALIAS "SQL_Shutdown" _
                                                AS LONG


DECLARE FUNCTION SQL_OptionSInt                 LIB "SQLT_Pro.DLL" ALIAS "SQL_OptionSInt" _
                                                (BYVAL lOption AS LONG) _
                                                AS LONG

DECLARE FUNCTION SQL_OptionStr                  LIB "SQLT_Pro.DLL" ALIAS "SQL_OptionStr" _
                                                (BYVAL lOption AS LONG) _
                                                AS STRING

DECLARE FUNCTION SQL_SetOptionSInt              LIB "SQLT_Pro.DLL" ALIAS "SQL_SetOptionSInt" _
                                                (BYVAL lOption AS LONG, _
                                                 BYVAL lValue AS LONG) _
                                                AS LONG

DECLARE FUNCTION SQL_SetOptionStr               LIB "SQLT_Pro.DLL" ALIAS "SQL_SetOptionStr" _
                                                (BYVAL lOption AS LONG, _
                                                 BYVAL sValue AS STRING) _
                                                AS LONG

DECLARE FUNCTION SQL_OptionResetAll             LIB "SQLT_Pro.DLL" ALIAS "SQL_OptionResetAll" _
                                                AS LONG

'PRO DLL ONLY:

DECLARE FUNCTION SQL_InfoExport                 LIB "SQLT_Pro.DLL" ALIAS "SQL_InfoExport" _
                                                (BYVAL lDatabaseNumber AS LONG, _
                                                 BYVAL sFileName AS STRING) _
                                                AS LONG

DECLARE FUNCTION SQL_InfoImport                 LIB "SQLT_Pro.DLL" ALIAS "SQL_InfoImport" _
                                                (BYVAL lDatabaseNumber AS LONG, _
                                                 BYVAL sInfoSource AS STRING) _
                                                AS LONG

DECLARE FUNCTION SQL_Thread                     LIB "SQLT_Pro.DLL" ALIAS "SQL_Thread" _
                                                (BYVAL lStatus AS LONG, _
                                                 BYVAL lThreadNumber AS LONG) _
                                                AS LONG



'----------------------------------------------------------------------------

'ENVIRONMENT FAMILY

DECLARE FUNCTION SQL_EnvironAttribSInt          LIB "SQLT_Pro.DLL" ALIAS "SQL_EnvironAttribSInt" _
                                                (BYVAL lInfoType AS LONG) _
                                                AS LONG

DECLARE FUNCTION SQL_SetEnvironAttribSInt       LIB "SQLT_Pro.DLL" ALIAS "SQL_SetEnvironAttribSInt" _
                                                (BYVAL lAttribute AS LONG, _
                                                 BYVAL lValue AS LONG) _
                                                AS LONG

'PRO DLL ONLY:

DECLARE FUNCTION SQL_DriverCount                LIB "SQLT_Pro.DLL" ALIAS "SQL_DriverCount" _
                                                AS LONG

DECLARE FUNCTION SQL_DriverInfoStr              LIB "SQLT_Pro.DLL" ALIAS "SQL_DriverInfoStr" _
                                                (BYVAL lDriverNumber AS LONG, _
                                                 BYVAL lInfoType AS LONG) _
                                                AS STRING

DECLARE FUNCTION SQL_DriverNumber               LIB "SQLT_Pro.DLL" ALIAS "SQL_DriverNumber" _
                                                (BYVAL sDriverName AS STRING) _
                                                AS LONG

DECLARE FUNCTION SQL_DataSourceCount            LIB "SQLT_Pro.DLL" ALIAS "SQL_DataSourceCount" _
                                                AS LONG

DECLARE FUNCTION SQL_DataSourceInfoStr          LIB "SQLT_Pro.DLL" ALIAS "SQL_DataSourceInfoStr" _
                                                (BYVAL lDataSourceNumber AS LONG, _
                                                 BYVAL lInfoType AS LONG) _
                                                AS STRING

DECLARE FUNCTION SQL_DataSourceNumber           LIB "SQLT_Pro.DLL" ALIAS "SQL_DataSourceNumber" _
                                                (BYVAL sDataSourceName AS STRING) _
                                                AS LONG

DECLARE FUNCTION SQL_DataSourceAdmin            LIB "SQLT_Pro.DLL"  ALIAS "SQL_DataSourceAdmin" _
                                                AS LONG

DECLARE FUNCTION SQL_DataSourceModify           LIB "SQLT_Pro.DLL"  ALIAS "SQL_DataSourceModify" _
                                                (BYVAL lRequestType AS LONG, _
                                                 BYVAL sDriverName AS STRING, _
                                                 BYVAL sAttributes AS STRING, _
                                                 BYVAL lPrompt AS LONG) _
                                                AS LONG

DECLARE FUNCTION SQL_DataSourceAdd              LIB "SQLT_Pro.DLL"  ALIAS "SQL_DataSourceAdd" _
                                                (BYVAL sDataSourceName AS STRING) _
                                                AS LONG

'----------------------------------------------------------------------------

'USE FAMILY

DECLARE FUNCTION SQL_UseDB                      LIB "SQLT_Pro.DLL" ALIAS "SQL_UseDB" _
                                                (BYVAL lDBNumber AS LONG) _
                                                AS LONG

DECLARE FUNCTION SQL_UseDBStmt                  LIB "SQLT_Pro.DLL" ALIAS "SQL_UseDBStmt" _
                                                (BYVAL lDBNumber AS LONG, _
                                                 BYVAL lStmtNumber AS LONG) _
                                                AS LONG

DECLARE FUNCTION SQL_UseStmt                    LIB "SQLT_Pro.DLL" ALIAS "SQL_UseStmt" _
                                                (BYVAL lStmtNumber AS LONG) _
                                                AS LONG

DECLARE FUNCTION SQL_CurrentDB                  LIB "SQLT_Pro.DLL" ALIAS "SQL_CurrentDB" _
                                                AS LONG

DECLARE FUNCTION SQL_CurrentStmt                LIB "SQLT_Pro.DLL" ALIAS "SQL_CurrentStmt" _
                                                AS LONG

'----------------------------------------------------------------------------

'DATABASE OPEN/CLOSE FAMILY

DECLARE FUNCTION SQL_NewDBNumber                LIB "SQLT_Pro.DLL" ALIAS "SQL_NewDBNumber" _
                                                AS LONG

DECLARE FUNCTION SQL_NewDatabaseNumber          LIB "SQLT_Pro.DLL" ALIAS "SQL_NewDatabaseNumber" _
                                                AS LONG

DECLARE FUNCTION SQL_OpenDB                     LIB "SQLT_Pro.DLL" ALIAS "SQL_OpenDB" _
                                                (BYVAL sConnectionString AS STRING) _
                                                AS LONG

DECLARE FUNCTION SQL_OpenDatabase               LIB "SQLT_Pro.DLL" ALIAS "SQL_OpenDatabase" _
                                                (BYVAL lDatabaseNumber AS LONG, _
                                                 BYVAL sConnectionString AS STRING, _
                                                 BYVAL lPrompt AS LONG) _
                                                AS LONG

DECLARE FUNCTION SQL_OpenDatabase1              LIB "SQLT_Pro.DLL" ALIAS "SQL_OpenDatabase1" _
                                                (BYVAL lDatabaseNumber AS LONG) _
                                                AS LONG

DECLARE FUNCTION SQL_OpenDatabase2              LIB "SQLT_Pro.DLL" ALIAS "SQL_OpenDatabase2" _
                                                (BYVAL lDatabaseNumber AS LONG, _
                                                 BYVAL sConnectionString AS STRING, _
                                                 BYVAL lPrompt AS LONG) _
                                                AS LONG

DECLARE FUNCTION SQL_DBIsOpen                   LIB "SQLT_Pro.DLL" ALIAS "SQL_DBIsOpen" _
                                                AS LONG

DECLARE FUNCTION SQL_DatabaseIsOpen             LIB "SQLT_Pro.DLL" ALIAS "SQL_DatabaseIsOpen" _
                                                (BYVAL lDatabaseNumber AS LONG) _
                                                AS LONG

DECLARE FUNCTION SQL_CloseDB                    LIB "SQLT_Pro.DLL" ALIAS "SQL_CloseDB" _
                                                AS LONG

DECLARE FUNCTION SQL_CloseDatabase              LIB "SQLT_Pro.DLL" ALIAS "SQL_CloseDatabase" _
                                                (BYVAL lDatabaseNumber AS LONG) _
                                                AS LONG

'----------------------------------------------------------------------------

'DATABASE INFO/ATTRIB FAMILY

DECLARE FUNCTION SQL_DBInfoStr                  LIB "SQLT_Pro.DLL" ALIAS "SQL_DBInfoStr" _
                                                (BYVAL lInfoType AS LONG) _
                                                AS STRING

DECLARE FUNCTION SQL_DatabaseInfoStr            LIB "SQLT_Pro.DLL" ALIAS "SQL_DatabaseInfoStr" _
                                                (BYVAL lDatabaseNumber AS LONG, _
                                                 BYVAL lInfoType AS LONG) _
                                                AS STRING

DECLARE FUNCTION SQL_DBInfoUInt                 LIB "SQLT_Pro.DLL" ALIAS "SQL_DBInfoUInt" _
                                                (BYVAL lInfoType AS LONG) _
                                                AS DWORD

DECLARE FUNCTION SQL_DatabaseInfoUInt           LIB "SQLT_Pro.DLL" ALIAS "SQL_DatabaseInfoUInt" _
                                                (BYVAL lDatabaseNumber AS LONG, _
                                                 BYVAL lInfoType AS LONG) _
                                                AS DWORD

DECLARE FUNCTION SQL_FuncAvail                  LIB "SQLT_Pro.DLL" ALIAS "SQL_FuncAvail" _
                                                (BYVAL lFunctionID AS LONG) _
                                                AS LONG

DECLARE FUNCTION SQL_FunctionAvailable          LIB "SQLT_Pro.DLL" ALIAS "SQL_FunctionAvailable" _
                                                (BYVAL lDatabaseNumber AS LONG, _
                                                 BYVAL lFunctionID AS LONG) _
                                                AS LONG

DECLARE FUNCTION SQL_DBAttribStr                LIB "SQLT_Pro.DLL" ALIAS "SQL_DBAttribStr" _
                                                (BYVAL lAttribute AS LONG) _
                                                AS STRING

DECLARE FUNCTION SQL_DatabaseAttribStr          LIB "SQLT_Pro.DLL" ALIAS "SQL_DatabaseAttribStr" _
                                                (BYVAL lDatabaseNumber AS LONG, _
                                                 BYVAL lAttribute AS LONG) _
                                                AS STRING

DECLARE FUNCTION SQL_DBAttribUInt               LIB "SQLT_Pro.DLL" ALIAS "SQL_DBAttribUInt" _
                                                (BYVAL lAttribute AS LONG) _
                                                AS DWORD

DECLARE FUNCTION SQL_DatabaseAttribUInt         LIB "SQLT_Pro.DLL" ALIAS "SQL_DatabaseAttribUInt" _
                                                (BYVAL lDatabaseNumber AS LONG, _
                                                 BYVAL lAttribute AS LONG) _
                                                AS DWORD

DECLARE FUNCTION SQL_SetDBAttribUInt            LIB "SQLT_Pro.DLL" ALIAS "SQL_SetDBAttribUInt" _
                                                (BYVAL lAttribute AS LONG, _
                                                 BYVAL dwValue AS DWORD) _
                                                AS LONG

DECLARE FUNCTION SQL_SetDatabaseAttribUInt      LIB "SQLT_Pro.DLL" ALIAS "SQL_SetDatabaseAttribUInt" _
                                                (BYVAL lDatabaseNumber AS LONG, _
                                                 BYVAL lAttribute AS LONG, _
                                                 BYVAL dwValue AS DWORD) _
                                                AS LONG

'PRO DLL ONLY:

DECLARE FUNCTION SQL_DBDataTypeCount            LIB "SQLT_Pro.DLL" ALIAS "SQL_DBDataTypeCount" _
                                                AS LONG

DECLARE FUNCTION SQL_DatabaseDataTypeCount      LIB "SQLT_Pro.DLL" ALIAS "SQL_DatabaseDataTypeCount" _
                                                (BYVAL lDatabaseNumber AS LONG) _
                                                AS LONG

DECLARE FUNCTION SQL_DBDataTypeInfoSInt         LIB "SQLT_Pro.DLL" ALIAS "SQL_DBDataTypeInfoSInt" _
                                                (BYVAL lDataTypeNumber AS LONG, _
                                                 BYVAL lInfoType AS LONG) _
                                                AS LONG

DECLARE FUNCTION SQL_DatabaseDataTypeInfoSInt   LIB "SQLT_Pro.DLL" ALIAS "SQL_DatabaseDataTypeInfoSInt" _
                                                (BYVAL lDatabaseNumber AS LONG, _
                                                 BYVAL lDataTypeNumber AS LONG, _
                                                 BYVAL lInfoType AS LONG) _
                                                AS LONG

DECLARE FUNCTION SQL_DBDataTypeInfoStr          LIB "SQLT_Pro.DLL" ALIAS "SQL_DBDataTypeInfoStr" _
                                                (BYVAL lDataTypeNumber AS LONG, _
                                                 BYVAL lInfoType AS LONG) _
                                                AS STRING

DECLARE FUNCTION SQL_DatabaseDataTypeInfoStr    LIB "SQLT_Pro.DLL" ALIAS "SQL_DatabaseDataTypeInfoStr" _
                                                (BYVAL lDatabaseNumber AS LONG, _
                                                 BYVAL lDataTypeNumber AS LONG, _
                                                 BYVAL lInfoType AS LONG) _
                                                AS STRING

DECLARE FUNCTION SQL_DBDataTypeNumber           LIB "SQLT_Pro.DLL" ALIAS "SQL_DBDataTypeNumber" _
                                                (BYVAL sTypeName AS STRING) _
                                                AS LONG

DECLARE FUNCTION SQL_DatabaseDataTypeNumber     LIB "SQLT_Pro.DLL" ALIAS "SQL_DatabaseDataTypeNumber" _
                                                (BYVAL lDatabaseNumber AS LONG, _
                                                 BYVAL sTypeName AS STRING) _
                                                AS LONG

DECLARE FUNCTION SQL_DBAutoCommit               LIB "SQLT_Pro.DLL" ALIAS "SQL_DBAutoCommit" _
                                                (BYVAL lOnOff AS LONG) _
                                                AS LONG

DECLARE FUNCTION SQL_DatabaseAutoCommit         LIB "SQLT_Pro.DLL" ALIAS "SQL_DatabaseAutoCommit" _
                                                (BYVAL lDatabaseNumber AS LONG, _
                                                 BYVAL lOnOff AS LONG) _
                                                AS LONG

DECLARE FUNCTION SQL_EndTrans                   LIB "SQLT_Pro.DLL" ALIAS "SQL_EndTrans" _
                                                (BYVAL lOperation AS LONG) _
                                                AS LONG

DECLARE FUNCTION SQL_EndTransaction             LIB "SQLT_Pro.DLL" ALIAS "SQL_EndTransaction" _
                                                (BYVAL lDatabaseNumber AS LONG, _
                                                 BYVAL lOperation AS LONG) _
                                                AS LONG

DECLARE FUNCTION SQL_SetDBAttribStr             LIB "SQLT_Pro.DLL" ALIAS "SQL_SetDBAttribStr" _
                                                (BYVAL lAttribute AS LONG, _
                                                 BYVAL sValue AS STRING) _
                                                AS LONG

DECLARE FUNCTION SQL_SetDatabaseAttribStr       LIB "SQLT_Pro.DLL" ALIAS "SQL_SetDatabaseAttribStr" _
                                                (BYVAL lDatabaseNumber AS LONG, _
                                                 BYVAL lAttribute AS LONG, _
                                                 BYVAL sValue AS STRING) _
                                                AS LONG

'----------------------------------------------------------------------------

'TABLE INFO FAMILY

DECLARE FUNCTION SQL_TblCount                   LIB "SQLT_Pro.DLL" ALIAS "SQL_TblCount" _
                                                AS LONG

DECLARE FUNCTION SQL_TableCount                 LIB "SQLT_Pro.DLL" ALIAS "SQL_TableCount" _
                                                (BYVAL lDatabaseNumber AS LONG) _
                                                AS LONG

DECLARE FUNCTION SQL_TblInfoSInt                LIB "SQLT_Pro.DLL" ALIAS "SQL_TblInfoSInt" _
                                                (BYVAL lTableNumber AS LONG, _
                                                 BYVAL lInfoType AS LONG) _
                                                AS LONG

DECLARE FUNCTION SQL_TableInfoSInt              LIB "SQLT_Pro.DLL" ALIAS "SQL_TableInfoSInt" _
                                                (BYVAL lDatabaseNumber AS LONG, _
                                                 BYVAL lTableNumber AS LONG, _
                                                 BYVAL lInfoType AS LONG) _
                                                AS LONG

DECLARE FUNCTION SQL_TblInfoStr                 LIB "SQLT_Pro.DLL" ALIAS "SQL_TblInfoStr" _
                                                (BYVAL lTableNumber AS LONG, _
                                                 BYVAL lInfoType AS LONG) _
                                                AS STRING

DECLARE FUNCTION SQL_TableInfoStr               LIB "SQLT_Pro.DLL" ALIAS "SQL_TableInfoStr" _
                                                (BYVAL lDatabaseNumber AS LONG, _
                                                 BYVAL lTableNumber AS LONG, _
                                                 BYVAL lInfoType AS LONG) _
                                                AS STRING

DECLARE FUNCTION SQL_TblNumber                  LIB "SQLT_Pro.DLL" ALIAS "SQL_TblNumber" _
                                                (BYVAL sTableName AS STRING, _
                                                 BYVAL sTableType AS STRING) _
                                                AS LONG

DECLARE FUNCTION SQL_TableNumber                LIB "SQLT_Pro.DLL" ALIAS "SQL_TableNumber" _
                                                (BYVAL lDatabaseNumber AS LONG, _
                                                 BYVAL sTableName AS STRING, _
                                                 BYVAL sTableType AS STRING) _
                                                AS LONG

'PRO DLL ONLY:

DECLARE FUNCTION SQL_TblStatSInt                LIB "SQLT_Pro.DLL" ALIAS "SQL_TblStatSInt" _
                                                (BYVAL lTableNumber AS LONG, _
                                                 BYVAL lInfoType AS LONG) _
                                                AS LONG

DECLARE FUNCTION SQL_TableStatisticSInt         LIB "SQLT_Pro.DLL" ALIAS "SQL_TableStatisticSInt" _
                                                (BYVAL lDatabaseNumber AS LONG, _
                                                 BYVAL lTableNumber AS LONG, _
                                                 BYVAL lInfoType AS LONG) _
                                                AS LONG

DECLARE FUNCTION SQL_TblPrivCount               LIB "SQLT_Pro.DLL" ALIAS "SQL_TblPrivCount" _
                                                (BYVAL lTableNumber AS LONG) _
                                                AS LONG


DECLARE FUNCTION SQL_TablePrivilegeCount        LIB "SQLT_Pro.DLL" ALIAS "SQL_TablePrivilegeCount" _
                                                (BYVAL lDatabaseNumber AS LONG, _
                                                 BYVAL lTableNumber AS LONG) _
                                                AS LONG

DECLARE FUNCTION SQL_TblPrivInfoStr             LIB "SQLT_Pro.DLL" ALIAS "SQL_TblPrivInfoStr" _
                                                (BYVAL lTableNumber AS LONG, _
                                                 BYVAL lPrivilegeNumber AS LONG, _
                                                 BYVAL lInfoType AS LONG) _
                                                AS STRING

DECLARE FUNCTION SQL_TablePrivilegeInfoStr      LIB "SQLT_Pro.DLL" ALIAS "SQL_TablePrivilegeInfoStr" _
                                                (BYVAL lDatabaseNumber AS LONG, _
                                                 BYVAL lTableNumber AS LONG, _
                                                 BYVAL lPrivilegeNumber AS LONG, _
                                                 BYVAL lInfoType AS LONG) _
                                                AS STRING

'----------------------------------------------------------------------------

'TABLE COLUMN INFO FAMILY


DECLARE FUNCTION SQL_TblColCount                LIB "SQLT_Pro.DLL" ALIAS "SQL_TblColCount" _
                                                (BYVAL lTableNumber AS LONG) _
                                                AS LONG

DECLARE FUNCTION SQL_TableColumnCount           LIB "SQLT_Pro.DLL" ALIAS "SQL_TableColumnCount" _
                                                (BYVAL lDatabaseNumber AS LONG, _
                                                 BYVAL lTableNumber AS LONG) _
                                                AS LONG

DECLARE FUNCTION SQL_TblColInfoSInt             LIB "SQLT_Pro.DLL" ALIAS "SQL_TblColInfoSInt" _
                                                (BYVAL lTableNumber AS LONG, _
                                                 BYVAL lColumnNumber AS LONG, _
                                                 BYVAL lInfoType AS LONG) _
                                                AS LONG

DECLARE FUNCTION SQL_TableColumnInfoSInt        LIB "SQLT_Pro.DLL" ALIAS "SQL_TableColumnInfoSInt" _
                                                (BYVAL lDatabaseNumber AS LONG, _
                                                 BYVAL lTableNumber AS LONG, _
                                                 BYVAL lColumnNumber AS LONG, _
                                                 BYVAL lInfoType AS LONG) _
                                                AS LONG

DECLARE FUNCTION SQL_TblColInfoStr              LIB "SQLT_Pro.DLL" ALIAS "SQL_TblColInfoStr" _
                                                (BYVAL lTableNumber AS LONG, _
                                                 BYVAL lColumnNumber AS LONG, _
                                                 BYVAL lInfoType AS LONG) _
                                                AS STRING

DECLARE FUNCTION SQL_TableColumnInfoStr         LIB "SQLT_Pro.DLL" ALIAS "SQL_TableColumnInfoStr" _
                                                (BYVAL lDatabaseNumber AS LONG, _
                                                 BYVAL lTableNumber AS LONG, _
                                                 BYVAL lColumnNumber AS LONG, _
                                                 BYVAL lInfoType AS LONG) _
                                                AS STRING

DECLARE FUNCTION SQL_TblColNumber               LIB "SQLT_Pro.DLL" ALIAS "SQL_TblColNumber" _
                                                (BYVAL lTableNumber AS LONG, _
                                                 BYVAL sColumnName AS STRING) _
                                                AS LONG

DECLARE FUNCTION SQL_TableColumnNumber          LIB "SQLT_Pro.DLL" ALIAS "SQL_TableColumnNumber" _
                                                (BYVAL lDatabaseNumber AS LONG, _
                                                 BYVAL lTableNumber AS LONG, _
                                                 BYVAL sColumnName AS STRING) _
                                                AS LONG

'PRO DLL ONLY:

DECLARE FUNCTION SQL_ColPrivCount               LIB "SQLT_Pro.DLL" ALIAS "SQL_ColPrivCount" _
                                                (BYVAL lTableNumber AS LONG, _
                                                 BYVAL lColumnNumber AS LONG) _
                                                AS LONG

DECLARE FUNCTION SQL_ColumnPrivilegeCount       LIB "SQLT_Pro.DLL" ALIAS "SQL_ColumnPrivilegeCount" _
                                                (BYVAL lDatabaseNumber AS LONG, _
                                                 BYVAL lTableNumber AS LONG, _
                                                 BYVAL lColumnNumber AS LONG) _
                                                AS LONG

DECLARE FUNCTION SQL_ColPrivInfoStr             LIB "SQLT_Pro.DLL" ALIAS "SQL_ColPrivInfoStr" _
                                                (BYVAL lTableNumber AS LONG, _
                                                 BYVAL lColumnNumber AS LONG, _
                                                 BYVAL lPrivilegeNumber AS LONG, _
                                                 BYVAL lInfoType AS LONG) _
                                                AS STRING

DECLARE FUNCTION SQL_ColumnPrivilegeInfoStr     LIB "SQLT_Pro.DLL" ALIAS "SQL_ColumnPrivilegeInfoStr" _
                                                (BYVAL lDatabaseNumber AS LONG, _
                                                 BYVAL lTableNumber AS LONG, _
                                                 BYVAL lColumnNumber AS LONG, _
                                                 BYVAL lPrivilegeNumber AS LONG, _
                                                 BYVAL lInfoType AS LONG) _
                                                AS STRING

DECLARE FUNCTION SQL_UniqColCount               LIB "SQLT_Pro.DLL" ALIAS "SQL_UniqColCount" _
                                                (BYVAL lTableNumber AS LONG) _
                                                AS LONG

DECLARE FUNCTION SQL_UniqueColumnCount          LIB "SQLT_Pro.DLL" ALIAS "SQL_UniqueColumnCount" _
                                                (BYVAL lDatabaseNumber AS LONG, _
                                                 BYVAL lTableNumber AS LONG) _
                                                AS LONG


DECLARE FUNCTION SQL_UniqColInfoStr             LIB "SQLT_Pro.DLL" ALIAS "SQL_UniqColInfoStr" _
                                                (BYVAL lTableNumber AS LONG, _
                                                 BYVAL lColumnNumber AS LONG, _
                                                 BYVAL lInfoType AS LONG) _
                                                AS STRING

DECLARE FUNCTION SQL_UniqueColumnInfoStr        LIB "SQLT_Pro.DLL" ALIAS "SQL_UniqueColumnInfoStr" _
                                                (BYVAL lDatabaseNumber AS LONG, _
                                                 BYVAL lTableNumber AS LONG, _
                                                 BYVAL lColumnNumber AS LONG, _
                                                 BYVAL lInfoType AS LONG) _
                                                AS STRING

DECLARE FUNCTION SQL_UniqColInfoSInt            LIB "SQLT_Pro.DLL" ALIAS "SQL_UniqColInfoSInt" _
                                                (BYVAL lTableNumber AS LONG, _
                                                 BYVAL lColumnNumber AS LONG, _
                                                 BYVAL lInfoType AS LONG) _
                                                AS LONG

DECLARE FUNCTION SQL_UniqueColumnInfoSInt       LIB "SQLT_Pro.DLL" ALIAS "SQL_UniqueColumnInfoSInt" _
                                                (BYVAL lDatabaseNumber AS LONG, _
                                                 BYVAL lTableNumber AS LONG, _
                                                 BYVAL lColumnNumber AS LONG, _
                                                 BYVAL lInfoType AS LONG) _
                                                AS LONG

DECLARE FUNCTION SQL_AutoColCount               LIB "SQLT_Pro.DLL" ALIAS "SQL_AutoColCount" _
                                                (BYVAL lTableNumber AS LONG) _
                                                AS LONG

DECLARE FUNCTION SQL_AutoColumnCount            LIB "SQLT_Pro.DLL" ALIAS "SQL_AutoColumnCount" _
                                                (BYVAL lDatabaseNumber AS LONG, _
                                                 BYVAL lTableNumber AS LONG) _
                                                AS LONG

DECLARE FUNCTION SQL_AutoColInfoStr             LIB "SQLT_Pro.DLL" ALIAS "SQL_AutoColInfoStr" _
                                                (BYVAL lTableNumber AS LONG, _
                                                 BYVAL lColumnNumber AS LONG, _
                                                 BYVAL lInfoType AS LONG) _
                                                AS STRING

DECLARE FUNCTION SQL_AutoColumnInfoStr          LIB "SQLT_Pro.DLL" ALIAS "SQL_AutoColumnInfoStr" _
                                                (BYVAL lDatabaseNumber AS LONG, _
                                                 BYVAL lTableNumber AS LONG, _
                                                 BYVAL lColumnNumber AS LONG, _
                                                 BYVAL lInfoType AS LONG) _
                                                AS STRING

DECLARE FUNCTION SQL_AutoColInfoSInt            LIB "SQLT_Pro.DLL" ALIAS "SQL_AutoColInfoSInt" _
                                                (BYVAL lTableNumber AS LONG, _
                                                 BYVAL lColumnNumber AS LONG, _
                                                 BYVAL lInfoType AS LONG) _
                                                AS LONG

DECLARE FUNCTION SQL_AutoColumnInfoSInt         LIB "SQLT_Pro.DLL" ALIAS "SQL_AutoColumnInfoSInt" _
                                                (BYVAL lDatabaseNumber AS LONG, _
                                                 BYVAL lTableNumber AS LONG, _
                                                 BYVAL lColumnNumber AS LONG, _
                                                 BYVAL lInfoType AS LONG) _
                                                AS LONG

DECLARE FUNCTION SQL_IndxCount                  LIB "SQLT_Pro.DLL" ALIAS "SQL_IndxCount" _
                                                (BYVAL lTableNumber AS LONG) _
                                                AS LONG

DECLARE FUNCTION SQL_IndexCount                 LIB "SQLT_Pro.DLL" ALIAS "SQL_IndexCount" _
                                                (BYVAL lDatabaseNumber AS LONG, _
                                                 BYVAL lTableNumber AS LONG) _
                                                AS LONG

DECLARE FUNCTION SQL_IndxInfoSInt               LIB "SQLT_Pro.DLL" ALIAS "SQL_IndxInfoSInt" _
                                                (BYVAL lTableNumber AS LONG, _
                                                 BYVAL lIndexNumber AS LONG, _
                                                 BYVAL lInfoType AS LONG) _
                                                AS LONG

DECLARE FUNCTION SQL_IndexInfoSInt              LIB "SQLT_Pro.DLL" ALIAS "SQL_IndexInfoSInt" _
                                                (BYVAL lDatabaseNumber AS LONG, _
                                                 BYVAL lTableNumber AS LONG, _
                                                 BYVAL lIndexNumber AS LONG, _
                                                 BYVAL lInfoType AS LONG) _
                                                AS LONG

DECLARE FUNCTION SQL_IndxInfoStr                LIB "SQLT_Pro.DLL" ALIAS "SQL_IndxInfoStr" _
                                                (BYVAL lTableNumber AS LONG, _
                                                 BYVAL lIndexNumber AS LONG, _
                                                 BYVAL lInfoType AS LONG) _
                                                AS STRING

DECLARE FUNCTION SQL_IndexInfoStr               LIB "SQLT_Pro.DLL" ALIAS "SQL_IndexInfoStr" _
                                                (BYVAL lDatabaseNumber AS LONG, _
                                                 BYVAL lTableNumber AS LONG, _
                                                 BYVAL lIndexNumber AS LONG, _
                                                 BYVAL lInfoType AS LONG) _
                                                AS STRING

DECLARE FUNCTION SQL_PrimKeyCount               LIB "SQLT_Pro.DLL" ALIAS "SQL_PrimKeyCount" _
                                                (BYVAL lTableNumber AS LONG) _
                                                AS LONG

DECLARE FUNCTION SQL_PrimaryKeyCount            LIB "SQLT_Pro.DLL" ALIAS "SQL_PrimaryKeyCount" _
                                                (BYVAL lDatabaseNumber AS LONG, _
                                                 BYVAL lTableNumber AS LONG) _
                                                AS LONG

DECLARE FUNCTION SQL_PrimKeyInfoStr             LIB "SQLT_Pro.DLL" ALIAS "SQL_PrimKeyInfoStr" _
                                                (BYVAL lTableNumber AS LONG, _
                                                 BYVAL lKeyNumber AS LONG, _
                                                 BYVAL lInfoType AS LONG) _
                                                AS STRING

DECLARE FUNCTION SQL_PrimaryKeyInfoStr          LIB "SQLT_Pro.DLL" ALIAS "SQL_PrimaryKeyInfoStr" _
                                                (BYVAL lDatabaseNumber AS LONG, _
                                                 BYVAL lTableNumber AS LONG, _
                                                 BYVAL lKeyNumber AS LONG, _
                                                 BYVAL lInfoType AS LONG) _
                                                AS STRING

DECLARE FUNCTION SQL_PrimKeyInfoSInt            LIB "SQLT_Pro.DLL" ALIAS "SQL_PrimKeyInfoSInt" _
                                                (BYVAL lTableNumber AS LONG, _
                                                 BYVAL lKeyNumber AS LONG, _
                                                 BYVAL lInfoType AS LONG) _
                                                AS LONG

DECLARE FUNCTION SQL_PrimaryKeyInfoSInt         LIB "SQLT_Pro.DLL" ALIAS "SQL_PrimaryKeyInfoSInt" _
                                                (BYVAL lDatabaseNumber AS LONG, _
                                                 BYVAL lTableNumber AS LONG, _
                                                 BYVAL lKeyNumber AS LONG, _
                                                 BYVAL lInfoType AS LONG) _
                                                AS LONG

DECLARE FUNCTION SQL_FornKeyCount               LIB "SQLT_Pro.DLL" ALIAS "SQL_FornKeyCount" _
                                                (BYVAL lTableNumber AS LONG) _
                                                AS LONG

DECLARE FUNCTION SQL_ForeignKeyCount            LIB "SQLT_Pro.DLL" ALIAS "SQL_ForeignKeyCount" _
                                                (BYVAL lDatabaseNumber AS LONG, _
                                                 BYVAL lTableNumber AS LONG) _
                                                AS LONG

DECLARE FUNCTION SQL_FornKeyInfoStr             LIB "SQLT_Pro.DLL" ALIAS "SQL_FornKeyInfoStr" _
                                                (BYVAL lTableNumber AS LONG, _
                                                 BYVAL lKeyNumber AS LONG, _
                                                 BYVAL lInfoType AS LONG) _
                                                AS STRING

DECLARE FUNCTION SQL_ForeignKeyInfoStr          LIB "SQLT_Pro.DLL" ALIAS "SQL_ForeignKeyInfoStr" _
                                                (BYVAL lDatabaseNumber AS LONG, _
                                                 BYVAL lTableNumber AS LONG, _
                                                 BYVAL lKeyNumber AS LONG, _
                                                 BYVAL lInfoType AS LONG) _
                                                AS STRING

DECLARE FUNCTION SQL_FornKeyInfoSInt            LIB "SQLT_Pro.DLL" ALIAS "SQL_FornKeyInfoSInt" _
                                                (BYVAL lTableNumber AS LONG, _
                                                 BYVAL lKeyNumber AS LONG, _
                                                 BYVAL lInfoType AS LONG) _
                                                AS LONG

DECLARE FUNCTION SQL_ForeignKeyInfoSInt         LIB "SQLT_Pro.DLL" ALIAS "SQL_ForeignKeyInfoSInt" _
                                                (BYVAL lDatabaseNumber AS LONG, _
                                                 BYVAL lTableNumber AS LONG, _
                                                 BYVAL lKeyNumber AS LONG, _
                                                 BYVAL lInfoType AS LONG) _
                                                AS LONG

'----------------------------------------------------------------------------

'STATEMENT OPEN/CLOSE FAMILY


DECLARE FUNCTION SQL_NewStmtNumber              LIB "SQLT_Pro.DLL" ALIAS "SQL_NewStmtNumber" _
                                                AS LONG

DECLARE FUNCTION SQL_NewStatementNumber         LIB "SQLT_Pro.DLL" ALIAS "SQL_NewStatementNumber" _
                                                (BYVAL lDatabaseNumber AS LONG) _
                                                AS LONG

DECLARE FUNCTION SQL_OpenStmt                   LIB "SQLT_Pro.DLL" ALIAS "SQL_OpenStmt" _
                                                AS LONG

DECLARE FUNCTION SQL_OpenStatement              LIB "SQLT_Pro.DLL" ALIAS "SQL_OpenStatement" _
                                                (BYVAL lDatabaseNumber AS LONG, _
                                                 BYVAL lStatementNumber AS LONG) _
                                                AS LONG

DECLARE FUNCTION SQL_StmtIsOpen                 LIB "SQLT_Pro.DLL" ALIAS "SQL_StmtIsOpen" _
                                                AS LONG

DECLARE FUNCTION SQL_StatementIsOpen            LIB "SQLT_Pro.DLL" ALIAS "SQL_StatementIsOpen" _
                                                (BYVAL lDatabaseNumber AS LONG, _
                                                 BYVAL lStatementNumber AS LONG) _
                                                AS LONG

DECLARE FUNCTION SQL_CloseStmt                  LIB "SQLT_Pro.DLL" ALIAS "SQL_CloseStmt" _
                                                AS LONG

DECLARE FUNCTION SQL_CloseStatement             LIB "SQLT_Pro.DLL" ALIAS "SQL_CloseStatement" _
                                                (BYVAL lDatabaseNumber AS LONG, _
                                                 BYVAL lStatementNumber AS LONG) _
                                                AS LONG

'----------------------------------------------------------------------------

'STATEMENT FAMILY

DECLARE FUNCTION SQL_Stmt                       LIB "SQLT_Pro.DLL" ALIAS "SQL_Stmt" _
                                                (BYVAL lAction AS LONG, _
                                                 BYVAL sStatement AS STRING) _
                                                AS LONG

DECLARE FUNCTION SQL_Statement                  LIB "SQLT_Pro.DLL" ALIAS "SQL_Statement" _
                                                (BYVAL lDatabaseNumber AS LONG, _
                                                 BYVAL lStatementNumber AS LONG, _
                                                 BYVAL lAction AS LONG, _
                                                 BYVAL sStatement AS STRING) _
                                                AS LONG

DECLARE FUNCTION SQL_Fetch                      LIB "SQLT_Pro.DLL" ALIAS "SQL_Fetch" _
                                                (BYVAL lRowNumber AS LONG) _
                                                AS LONG

DECLARE FUNCTION SQL_FetchResult                LIB "SQLT_Pro.DLL" ALIAS "SQL_FetchResult" _
                                                (BYVAL lDatabaseNumber AS LONG, _
                                                 BYVAL lStatementNumber AS LONG, _
                                                 BYVAL lRowNumber AS LONG) _
                                                AS LONG

DECLARE FUNCTION SQL_EOD                        LIB "SQLT_Pro.DLL" ALIAS "SQL_Eod" _
                                                AS LONG

DECLARE FUNCTION SQL_EndOfData                  LIB "SQLT_Pro.DLL" ALIAS "SQL_EndOfData" _
                                                (BYVAL lDatabaseNumber AS LONG, _
                                                 BYVAL lStatementNumber AS LONG) _
                                                AS LONG

'PRO DLL ONLY:

DECLARE FUNCTION SQL_FetchRel                   LIB "SQLT_Pro.DLL" ALIAS "SQL_FetchRel" _
                                                (BYREF sBookMark AS STRING, _
                                                 BYVAL lOffset AS LONG) _
                                                AS LONG

DECLARE FUNCTION SQL_FetchRelative              LIB "SQLT_Pro.DLL" ALIAS "SQL_FetchRelative" _
                                                (BYVAL lDatabaseNumber AS LONG, _
                                                 BYVAL lStatementNumber AS LONG, _
                                                 BYREF sBookMark AS STRING, _
                                                 BYVAL lOffset AS LONG) _
                                                AS LONG

DECLARE FUNCTION SQL_Bkmk                       LIB "SQLT_Pro.DLL" ALIAS "SQL_Bkmk" _
                                                AS STRING

DECLARE FUNCTION SQL_Bookmark                   LIB "SQLT_Pro.DLL" ALIAS "SQL_Bookmark" _
                                                (BYVAL lDatabaseNumber AS LONG, _
                                                 BYVAL lStatementNumber AS LONG) _
                                                AS STRING

DECLARE FUNCTION SQL_StmtCancel                 LIB "SQLT_Pro.DLL" ALIAS "SQL_StmtCancel" _
                                                AS LONG

DECLARE FUNCTION SQL_StatementCancel            LIB "SQLT_Pro.DLL" ALIAS "SQL_StatementCancel" _
                                                (BYVAL lDatabaseNumber AS LONG, _
                                                 BYVAL lStatementNumber AS LONG) _
                                                AS LONG

DECLARE FUNCTION SQL_MoreRes                    LIB "SQLT_Pro.DLL" ALIAS "SQL_MoreRes" _
                                                AS LONG

DECLARE FUNCTION SQL_MoreResults                LIB "SQLT_Pro.DLL" ALIAS "SQL_MoreResults" _
                                                (BYVAL lDatabaseNumber AS LONG, _
                                                 BYVAL lStatementNumber AS LONG) _
                                                AS LONG

DECLARE FUNCTION SQL_BulkOp                     LIB "SQLT_Pro.DLL" ALIAS "SQL_BulkOp" _
                                                (BYVAL lOperation AS LONG) _
                                                AS LONG

DECLARE FUNCTION SQL_BulkOperation              LIB "SQLT_Pro.DLL" ALIAS "SQL_BulkOperation" _
                                                (BYVAL lDatabaseNumber AS LONG, _
                                                 BYVAL lStatementNumber AS LONG, _
                                                 BYVAL lOperation AS LONG) _
                                                AS LONG

DECLARE FUNCTION SQL_SetPos                     LIB "SQLT_Pro.DLL" ALIAS "SQL_SetPos" _
                                                (BYVAL lOperation AS LONG, _
                                                 BYVAL lRowNumber AS LONG, _
                                                 BYVAL lLockType AS LONG) _
                                                AS LONG

DECLARE FUNCTION SQL_SetPosition                LIB "SQLT_Pro.DLL" ALIAS "SQL_SetPosition" _
                                                (BYVAL lDatabaseNumber AS LONG, _
                                                 BYVAL lStatementNumber AS LONG, _
                                                 BYVAL lOperation AS LONG, _
                                                 BYVAL lRowNumber AS LONG, _
                                                 BYVAL lLockType AS LONG) _
                                                AS LONG

DECLARE FUNCTION SQL_FetchPosition              LIB "SQLT_Pro.DLL" ALIAS "SQL_FetchPosition" _
                                                (BYVAL lDatabaseNumber AS LONG, _
                                                 BYVAL lStatementNumber AS LONG) _
                                                AS LONG

DECLARE FUNCTION SQL_FetchPos                   LIB "SQLT_Pro.DLL" ALIAS "SQL_FetchPos" _
                                                AS LONG

DECLARE FUNCTION SQL_SyncFetchPosition          LIB "SQLT_Pro.DLL" ALIAS "SQL_SyncFetchPosition" _
                                                (BYVAL lDatabaseNumber AS LONG, _
                                                 BYVAL lStatementNumber AS LONG, _
                                                 BYVAL lPosition AS LONG) _
                                                AS LONG

DECLARE FUNCTION SQL_SyncFetchPos               LIB "SQLT_Pro.DLL" ALIAS "SQL_SyncFetchPos" _
                                                (BYVAL lPosition AS LONG) _
                                                AS LONG

DECLARE FUNCTION SQL_AsyncStatement             LIB "SQLT_PRO.DLL" ALIAS "SQL_AsyncStatement" _
                                                (BYVAL lDatabaseNumber AS LONG, _
                                                 BYVAL lStatementNumber AS LONG, _
                                                 BYVAL lAction AS LONG, _
                                                 BYVAL sStatement AS STRING, _
                                                 BYVAL lThreadNumber AS LONG) _
                                                AS LONG

DECLARE FUNCTION SQL_AsyncStmt                  LIB "SQLT_PRO.DLL" ALIAS "SQL_AsyncStmt" _
                                                (BYVAL lAction AS LONG, _
                                                 BYVAL sStatement AS STRING, _
                                                 BYVAL lThreadNumber AS LONG) _
                                                AS LONG

DECLARE FUNCTION SQL_AsyncStatus                LIB "SQLT_PRO.DLL" ALIAS "SQL_AsyncStatus" _
                                                (BYVAL lThreadNumber AS LONG) _
                                                AS LONG

'----------------------------------------------------------------------------

'STATEMENT INFO/ATTRIB FAMILY

DECLARE FUNCTION SQL_StmtInfoStr                LIB "SQLT_Pro.DLL" ALIAS "SQL_StmtInfoStr" _
                                                (BYVAL lInfoType AS LONG) _
                                                AS STRING

DECLARE FUNCTION SQL_StatementInfoStr           LIB "SQLT_Pro.DLL" ALIAS "SQL_StatementInfoStr" _
                                                (BYVAL lDatabaseNumber AS LONG, _
                                                 BYVAL lStatementNumber AS LONG, _
                                                 BYVAL lInfoType AS LONG) _
                                                AS STRING

DECLARE FUNCTION SQL_StmtNativeSyntax           LIB "SQLT_Pro.DLL" ALIAS "SQL_StmtNativeSyntax" _
                                                (BYVAL sStatement AS STRING) _
                                                AS STRING

DECLARE FUNCTION SQL_StatementNativeSyntax      LIB "SQLT_Pro.DLL" ALIAS "SQL_StatementNativeSyntax" _
                                                (BYVAL lDatabaseNumber AS LONG, _
                                                 BYVAL sStatement AS STRING) _
                                                AS STRING

DECLARE FUNCTION SQL_StmtMode                   LIB "SQLT_Pro.DLL" ALIAS "SQL_StmtMode" _
                                                (BYVAL lMode AS LONG, _
                                                 BYVAL dwValue AS DWORD) _
                                                AS LONG

DECLARE FUNCTION SQL_StatementMode              LIB "SQLT_Pro.DLL" ALIAS "SQL_StatementMode" _
                                                (BYVAL lDatabaseNumber AS LONG, _
                                                 BYVAL lStatementNumber AS LONG, _
                                                 BYVAL lMode AS LONG, _
                                                 BYVAL dwValue AS DWORD) _
                                                AS LONG

DECLARE FUNCTION SQL_ResetStmtMode              LIB "SQLT_Pro.DLL" ALIAS "SQL_ResetStmtMode"_
                                                AS LONG

DECLARE FUNCTION SQL_ResetStatementMode         LIB "SQLT_Pro.DLL" ALIAS "SQL_ResetStatementMode"_
                                                (BYVAL lDatabaseNumber AS LONG, _
                                                 BYVAL sStatement AS STRING) _
                                                AS LONG

DECLARE FUNCTION SQL_StmtAttrib                 LIB "SQLT_Pro.DLL" ALIAS "SQL_StmtAttrib" _
                                                (BYVAL lAttribute AS LONG) _
                                                AS DWORD

DECLARE FUNCTION SQL_StatementAttrib            LIB "SQLT_Pro.DLL" ALIAS "SQL_StatementAttrib" _
                                                (BYVAL lDatabaseNumber AS LONG, _
                                                 BYVAL lStatementNumber AS LONG, _
                                                 BYVAL lAttribute AS LONG) _
                                                AS DWORD

'PRO DLL ONLY:

DECLARE FUNCTION SQL_SetStmtAttrib              LIB "SQLT_Pro.DLL" ALIAS "SQL_SetStmtAttrib" _
                                                (BYVAL lAttribute AS LONG, BYVAL dwValue AS DWORD) _
                                                AS LONG

DECLARE FUNCTION SQL_SetStatementAttrib         LIB "SQLT_Pro.DLL" ALIAS "SQL_SetStatementAttrib" _
                                                (BYVAL lDatabaseNumber AS LONG, _
                                                 BYVAL lStatementNumber AS LONG, _
                                                 BYVAL lAttribute AS LONG, _
                                                 BYVAL dwValue AS DWORD) _
                                                AS LONG

DECLARE FUNCTION SQL_NameCur                    LIB "SQLT_Pro.DLL" ALIAS "SQL_NameCur" _
                                                (BYVAL sName AS STRING) _
                                                AS LONG

DECLARE FUNCTION SQL_NameCursor                 LIB "SQLT_Pro.DLL" ALIAS "SQL_NameCursor" _
                                                (BYVAL lDatabaseNumber AS LONG, _
                                                 BYVAL lStatementNumber AS LONG, _
                                                 BYVAL sName AS STRING) _
                                                AS LONG

DECLARE FUNCTION SQL_CurName                    LIB "SQLT_Pro.DLL" ALIAS "SQL_CurName" _
                                                AS STRING

DECLARE FUNCTION SQL_CursorName                 LIB "SQLT_Pro.DLL" ALIAS "SQL_CursorName" _
                                                (BYVAL lDatabaseNumber AS LONG, _
                                                 BYVAL lStatementNumber AS LONG) _
                                                AS STRING

'----------------------------------------------------------------------------

'STATEMENT BINDING FAMILY

DECLARE FUNCTION SQL_StmtParamCount             LIB "SQLT_Pro.DLL" ALIAS "SQL_StmtParamCount" _
                                                AS LONG

DECLARE FUNCTION SQL_StatementParameterCount    LIB "SQLT_Pro.DLL" ALIAS "SQL_StatementParameterCount" _
                                                (BYVAL lDatabaseNumber AS LONG, _
                                                 BYVAL lStatementNumber AS LONG) _
                                                AS LONG

DECLARE FUNCTION SQL_BindParam                  LIB "SQLT_Pro.DLL" ALIAS "SQL_BindParam" _
                                                (BYVAL lParameterNumber AS LONG, _
                                                 BYVAL lParamType AS LONG, _
                                                 BYVAL lBasType AS LONG, _
                                                 BYVAL lSQLType AS LONG, _
                                                 BYVAL lDisplaySize AS LONG, _
                                                 BYVAL lDigits AS LONG, _
                                                 BYVAL lPointerToBuffer AS LONG, _
                                                 BYVAL lBufferLen AS LONG, _
                                                 BYREF lIndicator AS LONG) _
                                                AS LONG

DECLARE FUNCTION SQL_BindParameter              LIB "SQLT_Pro.DLL" ALIAS "SQL_BindParameter" _
                                                (BYVAL lDatabaseNumber AS LONG, _
                                                 BYVAL lStatementNumber AS LONG, _
                                                 BYVAL lParameterNumber AS LONG, _
                                                 BYVAL lParamType AS LONG, _
                                                 BYVAL lBasType AS LONG, _
                                                 BYVAL lSQLType AS LONG, _
                                                 BYVAL lDisplaySize AS LONG, _
                                                 BYVAL lDigits AS LONG, _
                                                 BYVAL lPointerToBuffer AS LONG, _
                                                 BYVAL lBufferLen AS LONG, _
                                                 BYREF lIndicator AS LONG) _
                                                AS LONG

DECLARE FUNCTION SQL_ParamInfoUInt              LIB "SQLT_Pro.DLL" ALIAS "SQL_ParamInfoUInt"_
                                                (BYVAL lParameterNumber AS LONG, _
                                                 BYVAL lInfoType AS LONG) _
                                                AS LONG

DECLARE FUNCTION SQL_ParameterInfoUInt          LIB "SQLT_Pro.DLL" ALIAS "SQL_ParameterInfoUInt" _
                                                (BYVAL lDatabaseNumber AS LONG, _
                                                 BYVAL lStatementNumber AS LONG, _
                                                 BYVAL lParameterNumber AS LONG, _
                                                 BYVAL lInfoType AS LONG) _
                                                AS LONG

DECLARE FUNCTION SQL_NextParam                  LIB "SQLT_Pro.DLL" ALIAS "SQL_NextParam" _
                                                AS LONG

DECLARE FUNCTION SQL_NextParameter              LIB "SQLT_Pro.DLL" ALIAS "SQL_NextParameter" _
                                                (BYVAL lDatabaseNumber AS LONG, _
                                                 BYVAL lStatementNumber AS LONG) _
                                                AS LONG

DECLARE FUNCTION SQL_LongParam                  LIB "SQLT_Pro.DLL" ALIAS "SQL_LongParam" _
                                                (BYVAL sValue AS STRING, _
                                                 BYVAL lIndicator AS LONG) _
                                                AS LONG

DECLARE FUNCTION SQL_LongParameter              LIB "SQLT_Pro.DLL" ALIAS "SQL_LongParameter" _
                                                (BYVAL lDatabaseNumber AS LONG, _
                                                 BYVAL lStatementNumber AS LONG, _
                                                 BYVAL sValue AS STRING, _
                                                 BYVAL lIndicator AS LONG) _
                                                AS LONG

'----------------------------------------------------------------------------

'STORED PROCEDURE FAMILY

DECLARE FUNCTION SQL_ProcCount                  LIB "SQLT_Pro.DLL" ALIAS "SQL_ProcCount" _
                                                AS LONG

DECLARE FUNCTION SQL_ProcedureCount             LIB "SQLT_Pro.DLL" ALIAS "SQL_ProcedureCount" _
                                                (BYVAL lDatabaseNumber AS LONG) _
                                                AS LONG

DECLARE FUNCTION SQL_ProcInfoSInt               LIB "SQLT_Pro.DLL" ALIAS "SQL_ProcInfoSInt" _
                                                (BYVAL lProcedureNumber AS LONG, _
                                                 BYVAL lInfoType AS LONG) _
                                                AS LONG

DECLARE FUNCTION SQL_ProcedureInfoSInt          LIB "SQLT_Pro.DLL" ALIAS "SQL_ProcedureInfoSInt" _
                                                (BYVAL lDatabaseNumber AS LONG, _
                                                 BYVAL lProcedureNumber AS LONG, _
                                                 BYVAL lInfoType AS LONG) _
                                                AS LONG

DECLARE FUNCTION SQL_ProcInfoStr                LIB "SQLT_Pro.DLL" ALIAS "SQL_ProcInfoStr" _
                                                (BYVAL lProcedureNumber AS LONG, _
                                                 BYVAL lInfoType AS LONG) _
                                                AS STRING

DECLARE FUNCTION SQL_ProcedureInfoStr           LIB "SQLT_Pro.DLL" ALIAS "SQL_ProcedureInfoStr" _
                                                (BYVAL lDatabaseNumber AS LONG, _
                                                 BYVAL lProcedureNumber AS LONG, _
                                                 BYVAL lInfoType AS LONG) _
                                                AS STRING

DECLARE FUNCTION SQL_ProcColCount               LIB "SQLT_Pro.DLL" ALIAS "SQL_ProcColCount" _
                                                (BYVAL lProcedureNumber AS LONG) _
                                                AS LONG

DECLARE FUNCTION SQL_ProcedureColumnCount       LIB "SQLT_Pro.DLL" ALIAS "SQL_ProcedureColumnCount" _
                                                (BYVAL lDatabaseNumber AS LONG, _
                                                 BYVAL lProcedureNumber AS LONG) _
                                                AS LONG

DECLARE FUNCTION SQL_ProcColInfoSInt            LIB "SQLT_Pro.DLL" ALIAS "SQL_ProcColInfoSInt" _
                                                (BYVAL lProcedureNumber AS LONG, _
                                                 BYVAL lProcColumnNumber AS LONG, _
                                                 BYVAL lInfoType AS LONG) _
                                                AS LONG

DECLARE FUNCTION SQL_ProcedureColumnInfoSInt    LIB "SQLT_Pro.DLL" ALIAS "SQL_ProcedureColumnInfoSInt" _
                                                (BYVAL lDatabaseNumber AS LONG, _
                                                 BYVAL lProcedureNumber AS LONG, _
                                                 BYVAL lProcColumnNumber AS LONG, _
                                                 BYVAL lInfoType AS LONG) _
                                                AS LONG

DECLARE FUNCTION SQL_ProcColInfoStr             LIB "SQLT_Pro.DLL" ALIAS "SQL_ProcColInfoStr" _
                                                (BYVAL lProcedureNumber AS LONG, _
                                                 BYVAL lProcColumnNumber AS LONG, _
                                                 BYVAL lInfoType AS LONG) _
                                                 AS STRING

DECLARE FUNCTION SQL_ProcedureColumnInfoStr     LIB "SQLT_Pro.DLL" ALIAS "SQL_ProcedureColumnInfoStr" _
                                                (BYVAL lDatabaseNumber AS LONG, _
                                                 BYVAL lProcedureNumber AS LONG, _
                                                 BYVAL lProcColumnNumber AS LONG, _
                                                 BYVAL lInfoType AS LONG) _
                                                AS STRING

'----------------------------------------------------------------------------

'RESULT COLUMN BINDING FAMILY

DECLARE FUNCTION SQL_AutoBindCol                LIB "SQLT_Pro.DLL" ALIAS "SQL_AutoBindCol" _
                                                (BYVAL lColumnNumber AS LONG) _
                                                AS LONG

DECLARE FUNCTION SQL_AutoBindColumn             LIB "SQLT_Pro.DLL" ALIAS "SQL_AutoBindColumn" _
                                                (BYVAL lDatabaseNumber AS LONG, _
                                                 BYVAL lStatementNumber AS LONG, _
                                                 BYVAL lColumnNumber AS LONG) _
                                                AS LONG

DECLARE FUNCTION SQL_ManualBindCol              LIB "SQLT_Pro.DLL" ALIAS "SQL_ManualBindCol" _
                                                (BYVAL lColumnNumber AS LONG, _
                                                 BYVAL lDataType AS LONG, _
                                                 BYVAL lPointerToBuffer AS LONG, _
                                                 BYVAL lBufferLength AS LONG, _
                                                 BYREF lIndicator AS LONG) _
                                                AS LONG

DECLARE FUNCTION SQL_ManualBindColumn           LIB "SQLT_Pro.DLL" ALIAS "SQL_ManualBindColumn" _
                                                (BYVAL lDatabaseNumber AS LONG, _
                                                 BYVAL lStatementNumber AS LONG, _
                                                 BYVAL lColumnNumber AS LONG, _
                                                 BYVAL lDataType AS LONG, _
                                                 BYVAL lPointerToBuffer AS LONG, _
                                                 BYVAL lBufferLength AS LONG, _
                                                 BYREF lIndicator AS LONG) _
                                                AS LONG

DECLARE FUNCTION SQL_UnbindCol                  LIB "SQLT_Pro.DLL" ALIAS "SQL_UnbindCol" _
                                                (BYVAL lColumnNumber AS LONG) _
                                                AS LONG

DECLARE FUNCTION SQL_UnbindColumn               LIB "SQLT_Pro.DLL" ALIAS "SQL_UnbindColumn" _
                                                (BYVAL lDatabaseNumber AS LONG, _
                                                 BYVAL lStatementNumber AS LONG, _
                                                 BYVAL lColumnNumber AS LONG) _
                                                AS LONG

'PRO DLL ONLY:

DECLARE FUNCTION SQL_DirectBindCol              LIB "SQLT_Pro.DLL" ALIAS "SQL_DirectBindCol" _
                                                (BYVAL lColumnNumber AS LONG, _
                                                 BYVAL lDataType AS LONG, _
                                                 BYVAL lPointerToBuffer AS LONG, _
                                                 BYVAL lBufferLength AS LONG) _
                                                AS LONG

DECLARE FUNCTION SQL_DirectBindColumn           LIB "SQLT_Pro.DLL" ALIAS "SQL_DirectBindColumn" _
                                                (BYVAL lDatabaseNumber AS LONG, _
                                                 BYVAL lStatementNumber AS LONG, _
                                                 BYVAL lColumnNumber AS LONG, _
                                                 BYVAL lDataType AS LONG, _
                                                 BYVAL lPointerToBuffer AS LONG, _
                                                 BYVAL lBufferLength AS LONG) _
                                                AS LONG

DECLARE FUNCTION SQL_ResColBufferPtr            LIB "SQLT_Pro.DLL" ALIAS "SQL_ResColBufferPtr" _
                                                (BYVAL lColumnNumber AS LONG) _
                                                AS DWORD

DECLARE FUNCTION SQL_ResultColumnBufferPtr      LIB "SQLT_Pro.DLL" ALIAS "SQL_ResultColumnBufferPtr" _
                                                (BYVAL lDatabaseNumber AS LONG, _
                                                 BYVAL lStatementNumber AS LONG, _
                                                 BYVAL lColumnNumber AS LONG) _
                                                AS DWORD

DECLARE FUNCTION SQL_ResColIndPtr               LIB "SQLT_Pro.DLL" ALIAS "SQL_ResColIndPtr" _
                                                (BYVAL lColumnNumber AS LONG) _
                                                AS DWORD

DECLARE FUNCTION SQL_ResultColumnIndPtr         LIB "SQLT_Pro.DLL" ALIAS "SQL_ResultColumnIndPtr" _
                                                (BYVAL lDatabaseNumber AS LONG, _
                                                 BYVAL lStatementNumber AS LONG, _
                                                 BYVAL lColumnNumber AS LONG) _
                                                AS DWORD

'----------------------------------------------------------------------------

'RESULT COUNT FAMILY

DECLARE FUNCTION SQL_ResRowCount                LIB "SQLT_Pro.DLL" ALIAS "SQL_ResRowCount" _
                                                AS LONG

DECLARE FUNCTION SQL_ResultRowCount             LIB "SQLT_Pro.DLL" ALIAS "SQL_ResultRowCount" _
                                                (BYVAL lDatabaseNumber AS LONG, _
                                                 BYVAL lStatementNumber AS LONG) _
                                                AS LONG

DECLARE FUNCTION SQL_ResColCount                LIB "SQLT_Pro.DLL" ALIAS "SQL_ResColCount" _
                                                AS LONG

DECLARE FUNCTION SQL_ResultColumnCount          LIB "SQLT_Pro.DLL" ALIAS "SQL_ResultColumnCount" _
                                                (BYVAL lDatabaseNumber AS LONG, _
                                                 BYVAL lStatementNumber AS LONG) _
                                                AS LONG

'----------------------------------------------------------------------------

'RESULT COLUMN FAMILY

DECLARE FUNCTION SQL_ResColSInt                 LIB "SQLT_Pro.DLL" ALIAS "SQL_ResColSInt" _
                                                (BYVAL lColumnNumber AS LONG) _
                                                AS LONG

DECLARE FUNCTION SQL_ResultColumnSInt           LIB "SQLT_Pro.DLL" ALIAS "SQL_ResultColumnSInt" _
                                                (BYVAL lDatabaseNumber AS LONG, _
                                                 BYVAL lStatementNumber AS LONG, _
                                                 BYVAL lColumnNumber AS LONG) _
                                                AS LONG

DECLARE FUNCTION SQL_ResColUInt                 LIB "SQLT_Pro.DLL" ALIAS "SQL_ResColUInt" _
                                                (BYVAL lColumnNumber AS LONG) _
                                                AS DWORD

DECLARE FUNCTION SQL_ResultColumnUInt           LIB "SQLT_Pro.DLL" ALIAS "SQL_ResultColumnUInt" _
                                                (BYVAL lDatabaseNumber AS LONG, _
                                                 BYVAL lStatementNumber AS LONG, _
                                                 BYVAL lColumnNumber AS LONG) _
                                                AS DWORD

DECLARE FUNCTION SQL_ResColBInt                 LIB "SQLT_Pro.DLL" ALIAS "SQL_ResColBInt" _
                                                (BYVAL lColumnNumber AS LONG) _
                                                AS STRING

DECLARE FUNCTION SQL_ResultColumnBInt           LIB "SQLT_Pro.DLL" ALIAS "SQL_ResultColumnBInt" _
                                                (BYVAL lDatabaseNumber AS LONG, _
                                                 BYVAL lStatementNumber AS LONG, _
                                                 BYVAL lColumnNumber AS LONG) _
                                                AS STRING

DECLARE FUNCTION SQL_ResColFloat                LIB "SQLT_Pro.DLL" ALIAS "SQL_ResColFloat" _
                                                (BYVAL lColumnNumber AS LONG) _
                                                AS DOUBLE

DECLARE FUNCTION SQL_ResultColumnFloat          LIB "SQLT_Pro.DLL" ALIAS "SQL_ResultColumnFloat" _
                                                (BYVAL lDatabaseNumber AS LONG, _
                                                 BYVAL lStatementNumber AS LONG, _
                                                 BYVAL lColumnNumber AS LONG) _
                                                AS DOUBLE


DECLARE FUNCTION SQL_ResColDate                 LIB "SQLT_Pro.DLL" ALIAS "SQL_ResColDate" _
                                                (BYVAL lColumnNumber AS LONG, _
                                                 BYVAL sFormat AS STRING) _
                                                AS STRING

DECLARE FUNCTION SQL_ResultColumnDate           LIB "SQLT_Pro.DLL" ALIAS "SQL_ResultColumnDate" _
                                                (BYVAL lDatabaseNumber AS LONG, _
                                                 BYVAL lStatementNumber AS LONG, _
                                                 BYVAL lColumnNumber AS LONG, _
                                                 BYVAL sFormat AS STRING) _
                                                AS STRING

DECLARE FUNCTION SQL_ResColTime                 LIB "SQLT_Pro.DLL" ALIAS "SQL_ResColTime" _
                                                (BYVAL lColumnNumber AS LONG, _
                                                 BYVAL sFormat AS STRING) _
                                                AS STRING

DECLARE FUNCTION SQL_ResultColumnTime           LIB "SQLT_Pro.DLL" ALIAS "SQL_ResultColumnTime" _
                                                (BYVAL lDatabaseNumber AS LONG, _
                                                 BYVAL lStatementNumber AS LONG, _
                                                 BYVAL lColumnNumber AS LONG, _
                                                 BYVAL sFormat AS STRING) _
                                                AS STRING

DECLARE FUNCTION SQL_ResColDateTime             LIB "SQLT_Pro.DLL" ALIAS "SQL_ResColDateTime" _
                                                (BYVAL lColumnNumber AS LONG) _
                                                AS STRING

DECLARE FUNCTION SQL_ResultColumnDateTime       LIB "SQLT_Pro.DLL" ALIAS "SQL_ResultColumnDateTime" _
                                                (BYVAL lDatabaseNumber AS LONG, _
                                                 BYVAL lStatementNumber AS LONG, _
                                                 BYVAL lColumnNumber AS LONG) _
                                                AS STRING

DECLARE FUNCTION SQL_ResColStr                  LIB "SQLT_Pro.DLL" ALIAS "SQL_ResColStr" _
                                                (BYVAL lColumnNumber AS LONG) _
                                                AS STRING

DECLARE FUNCTION SQL_ResultColumnStr            LIB "SQLT_Pro.DLL" ALIAS "SQL_ResultColumnStr" _
                                                (BYVAL lDatabaseNumber AS LONG, _
                                                 BYVAL lStatementNumber AS LONG, _
                                                 BYVAL lColumnNumber AS LONG) _
                                                AS STRING

DECLARE FUNCTION SQL_ResColText                 LIB "SQLT_Pro.DLL" ALIAS "SQL_ResColText" _
                                                (BYVAL lColumnNumber AS LONG) _
                                                AS STRING

DECLARE FUNCTION SQL_ResultColumnText           LIB "SQLT_Pro.DLL" ALIAS "SQL_ResultColumnText" _
                                                (BYVAL lDatabaseNumber AS LONG, _
                                                 BYVAL lStatementNumber AS LONG, _
                                                 BYVAL lColumnNumber AS LONG) _
                                                AS STRING

DECLARE FUNCTION SQL_LongResCol                 LIB "SQLT_Pro.DLL" ALIAS "SQL_LongResCol" _
                                                (BYVAL lColumnNumber AS LONG) _
                                                AS STRING

DECLARE FUNCTION SQL_LongResultColumn           LIB "SQLT_Pro.DLL" ALIAS "SQL_LongResultColumn" _
                                                (BYVAL lDatabaseNumber AS LONG, _
                                                 BYVAL lStatementNumber AS LONG, _
                                                 BYVAL lColumnNumber AS LONG) _
                                                AS STRING

DECLARE FUNCTION SQL_ResColInfoSInt             LIB "SQLT_Pro.DLL" ALIAS "SQL_ResColInfoSInt" _
                                                (BYVAL lColumnNumber AS LONG, _
                                                 BYVAL lInfoType AS LONG) _
                                                AS LONG

DECLARE FUNCTION SQL_ResultColumnInfoSInt       LIB "SQLT_Pro.DLL" ALIAS "SQL_ResultColumnInfoSInt" _
                                                (BYVAL lDatabaseNumber AS LONG, _
                                                 BYVAL lStatementNumber AS LONG, _
                                                 BYVAL lColumnNumber AS LONG, _
                                                 BYVAL lInfoType AS LONG) _
                                                AS LONG

DECLARE FUNCTION SQL_ResColInfoStr              LIB "SQLT_Pro.DLL" ALIAS "SQL_ResColInfoStr" _
                                                (BYVAL lColumnNumber AS LONG, _
                                                 BYVAL lInfoType AS LONG) _
                                                AS STRING

DECLARE FUNCTION SQL_ResultColumnInfoStr        LIB "SQLT_Pro.DLL" ALIAS "SQL_ResultColumnInfoStr" _
                                                (BYVAL lDatabaseNumber AS LONG, _
                                                 BYVAL lStatementNumber AS LONG, _
                                                 BYVAL lColumnNumber AS LONG, _
                                                 BYVAL lInfoType AS LONG) _
                                                AS STRING

DECLARE FUNCTION SQL_ResColType                 LIB "SQLT_Pro.DLL" ALIAS "SQL_ResColType" _
                                                (BYVAL lColumnNumber AS LONG) _
                                                AS LONG

DECLARE FUNCTION SQL_ResultColumnType           LIB "SQLT_Pro.DLL" ALIAS "SQL_ResultColumnType" _
                                                (BYVAL lDatabaseNumber AS LONG, _
                                                 BYVAL lStatementNumber AS LONG, _
                                                 BYVAL lColumnNumber AS LONG) _
                                                AS LONG

DECLARE FUNCTION SQL_ResColSize                 LIB "SQLT_Pro.DLL" ALIAS "SQL_ResColSize" _
                                                (BYVAL lColumnNumber AS LONG) _
                                                AS LONG

DECLARE FUNCTION SQL_ResultColumnSize           LIB "SQLT_Pro.DLL" ALIAS "SQL_ResultColumnSize" _
                                                (BYVAL lDatabaseNumber AS LONG, _
                                                 BYVAL lStatementNumber AS LONG, _
                                                 BYVAL lColumnNumber AS LONG) _
                                                AS LONG

DECLARE FUNCTION SQL_ResColLen                  LIB "SQLT_Pro.DLL" ALIAS "SQL_ResColLen" _
                                                (BYVAL lColumnNumber AS LONG) _
                                                AS LONG

DECLARE FUNCTION SQL_ResultColumnLen            LIB "SQLT_Pro.DLL" ALIAS "SQL_ResultColumnLen" _
                                                (BYVAL lDatabaseNumber AS LONG, _
                                                 BYVAL lStatementNumber AS LONG, _
                                                 BYVAL lColumnNumber AS LONG) _
                                                AS LONG
DECLARE FUNCTION SQL_ResColNumber               LIB "SQLT_Pro.DLL" ALIAS "SQL_ResColNumber" _
                                                (BYVAL sColumnName AS STRING) _
                                                AS LONG

DECLARE FUNCTION SQL_ResultColumnNumber         LIB "SQLT_Pro.DLL" ALIAS "SQL_ResultColumnNumber" _
                                                (BYVAL lDatabaseNumber AS LONG, _
                                                 BYVAL lStatementNumber AS LONG, _
                                                 BYVAL sColumnName AS STRING) _
                                                AS LONG

DECLARE FUNCTION SQL_ResColNull                 LIB "SQLT_Pro.DLL" ALIAS "SQL_ResColNull" _
                                                (BYVAL lColumnNumber AS LONG) _
                                                AS LONG

DECLARE FUNCTION SQL_ResultColumnNull           LIB "SQLT_Pro.DLL" ALIAS "SQL_ResultColumnNull" _
                                                (BYVAL lDatabaseNumber AS LONG, _
                                                 BYVAL lStatementNumber AS LONG, _
                                                 BYVAL lColumnNumber AS LONG) _
                                                AS LONG

DECLARE FUNCTION SQL_ResColMore                 LIB "SQLT_Pro.DLL" ALIAS "SQL_ResColMore" _
                                                (BYVAL lColumnNumber AS LONG) _
                                                AS LONG

DECLARE FUNCTION SQL_ResultColumnMore           LIB "SQLT_Pro.DLL" ALIAS "SQL_ResultColumnMore" _
                                                (BYVAL lDatabaseNumber AS LONG, _
                                                 BYVAL lStatementNumber AS LONG, _
                                                 BYVAL lColumnNumber AS LONG) _
                                                AS LONG

DECLARE FUNCTION SQL_ResColInd                  LIB "SQLT_Pro.DLL" ALIAS "SQL_ResColInd" _
                                                (BYVAL lColumnNumber AS LONG) _
                                                AS LONG

DECLARE FUNCTION SQL_ResultColumnInd            LIB "SQLT_Pro.DLL" ALIAS "SQL_ResultColumnInd" _
                                                (BYVAL lDatabaseNumber AS LONG, _
                                                 BYVAL lStatementNumber AS LONG, _
                                                 BYVAL lColumnNumber AS LONG) _
                                                AS LONG

'PRO DLL ONLY;

DECLARE FUNCTION SQL_ResultColumnDateTimePart   LIB "SQLT_Pro.DLL" ALIAS "SQL_ResultColumnDateTimePart" _
                                                (BYVAL lDatabaseNumber AS LONG, _
                                                 BYVAL lStatementNumber AS LONG, _
                                                 BYVAL lColumnNumber AS LONG, _
                                                 BYVAL lPart AS LONG) _
                                                AS LONG

DECLARE FUNCTION SQL_ResColDateTimePart         LIB "SQLT_Pro.DLL" ALIAS "SQL_ResColDateTimePart" _
                                                (BYVAL lColumnNumber AS LONG, _
                                                 BYVAL lPart AS LONG) _
                                                AS LONG

'----------------------------------------------------------------------------

'ERROR/TRACE FAMILY

DECLARE FUNCTION SQL_ErrorPending               LIB "SQLT_Pro.DLL" ALIAS "SQL_ErrorPending" _
                                                AS LONG

DECLARE FUNCTION SQL_ErrorClearOne              LIB "SQLT_Pro.DLL" ALIAS "SQL_ErrorClearOne" _
                                                AS LONG

DECLARE FUNCTION SQL_ErrorClearAll              LIB "SQLT_Pro.DLL" ALIAS "SQL_ErrorClearAll" _
                                                AS LONG

DECLARE FUNCTION SQL_ErrorColumnNumber          LIB "SQLT_Pro.DLL" ALIAS "SQL_ErrorColumnNumber" _
                                                AS LONG

DECLARE FUNCTION SQL_ErrorDatabaseNumber        LIB "SQLT_Pro.DLL" ALIAS "SQL_ErrorDatabaseNumber" _
                                                AS LONG

DECLARE FUNCTION SQL_ErrorCount                 LIB "SQLT_Pro.DLL" ALIAS "SQL_ErrorCount" _
                                                AS LONG

DECLARE FUNCTION SQL_ErrorFuncName              LIB "SQLT_Pro.DLL" ALIAS "SQL_ErrorFuncName" _
                                                AS STRING

DECLARE FUNCTION SQL_ErrorFunction              LIB "SQLT_Pro.DLL" ALIAS "SQL_ErrorFunction" _
                                                AS LONG

DECLARE FUNCTION SQL_ErrorIgnore                LIB "SQLT_Pro.DLL" ALIAS "SQL_ErrorIgnore" _
                                                (BYVAL lDatabaseNumber AS LONG, _
                                                 BYVAL lStatementNumber AS LONG, _
                                                 BYVAL sSQLStates AS STRING) _
                                                AS STRING

DECLARE FUNCTION SQL_ErrorText                  LIB "SQLT_Pro.DLL" ALIAS "SQL_ErrorText" _
                                                AS STRING

DECLARE FUNCTION SQL_ErrorNativeCode            LIB "SQLT_Pro.DLL" ALIAS "SQL_ErrorNativeCode" _
                                                AS LONG

DECLARE FUNCTION SQL_ErrorNumber                LIB "SQLT_Pro.DLL" ALIAS "SQL_ErrorNumber" _
                                                AS LONG

DECLARE FUNCTION SQL_ErrorQuickAll              LIB "SQLT_Pro.DLL" ALIAS "SQL_ErrorQuickAll" _
                                                AS STRING

DECLARE FUNCTION SQL_ErrorQuickOne              LIB "SQLT_Pro.DLL" ALIAS "SQL_ErrorQuickOne" _
                                                AS STRING

DECLARE FUNCTION SQL_ErrorSimulate              LIB "SQLT_Pro.DLL" ALIAS "SQL_ErrorSimulate" _
                                                (BYVAL lDatabaseNumber AS LONG, _
                                                 BYVAL lStatementNumber AS LONG, _
                                                 BYVAL lColumnNumber AS LONG, _
                                                 BYVAL sFunctionName AS STRING, _
                                                 BYVAL lErrorNumber AS LONG, _
                                                 BYVAL sSQLState AS STRING, _
                                                 BYVAL lNativeError AS LONG, _
                                                 BYVAL sErrorMessage AS STRING) _
                                                AS LONG

DECLARE FUNCTION SQL_ErrorStatementNumber       LIB "SQLT_Pro.DLL" ALIAS "SQL_ErrorStatementNumber" _
                                                AS LONG

DECLARE FUNCTION SQL_ErrorTime                  LIB "SQLT_Pro.DLL" ALIAS "SQL_ErrorTime" _
                                                AS STRING

DECLARE FUNCTION SQL_State                      LIB "SQLT_Pro.DLL" ALIAS "SQL_State" _
                                                AS STRING

DECLARE FUNCTION SQL_Trace                      LIB "SQLT_Pro.DLL" ALIAS "SQL_Trace" _
                                                (BYVAL lOnOff AS LONG) _
                                                AS LONG

DECLARE FUNCTION SQL_TraceSInt                  LIB "SQLT_Pro.DLL" ALIAS "SQL_TraceSInt" _
                                                (BYVAL lNumber AS LONG) _
                                                AS LONG

DECLARE FUNCTION SQL_TraceStr                   LIB "SQLT_Pro.DLL" ALIAS "SQL_TraceStr" _
                                                (BYVAL sString AS STRING) _
                                                AS LONG

DECLARE FUNCTION SQL_TraceStrOLE                LIB "SQLT_Pro.DLL" ALIAS "SQL_TraceStrOLE" _
                                                (BYREF sString AS STRING) _
                                                AS LONG

'PRO DLL ONLY:

DECLARE FUNCTION SQL_ErrorStr                   LIB "SQLT_Pro.DLL" ALIAS "SQL_ErrorStr" _
                                                (BYVAL lRecordNumber AS LONG, _
                                                 BYVAL lInfoType AS LONG) _
                                                AS STRING

DECLARE FUNCTION SQL_Diagnostic                 LIB "SQLT_Pro.DLL" ALIAS "SQL_Diagnostic" _
                                                (BYVAL lInfoType AS LONG) _
                                                AS STRING

DECLARE FUNCTION SQL_OnErrorCall                LIB "SQLT_Pro.DLL" ALIAS "SQL_OnErrorCall" _
                                                (BYVAL dwCodePtr AS DWORD) _
                                                AS LONG

DECLARE FUNCTION SQL_AsyncErrors                LIB "SQLT_Pro.DLL" ALIAS "SQL_AsyncErrors" _
                                                (BYVAL lThreadNumber AS LONG) _
                                                AS LONG

'----------------------------------------------------------------------------

'UTILITY FAMILY

DECLARE FUNCTION SQL_BinaryStr                  LIB "SQLT_Pro.DLL" ALIAS "SQL_BinaryStr" _
                                                (BYVAL sString AS STRING) _
                                                AS STRING

DECLARE FUNCTION SQL_TextStr                    LIB "SQLT_Pro.DLL" ALIAS "SQL_TextStr" _
                                                (BYVAL sString AS STRING) _
                                                AS STRING

DECLARE FUNCTION SQL_TextStrOLE                 LIB "SQLT_Pro.DLL" ALIAS "SQL_TextStrOLE" _
                                                (BYREF sString AS STRING) _
                                                AS STRING

DECLARE FUNCTION SQL_TextDateTime               LIB "SQLT_Pro.DLL" ALIAS "SQL_TextDateTime" _
                                                (BYVAL sString AS STRING, _
                                                 BYVAL lFrom AS LONG, _
                                                 BYVAL lTo AS LONG) _
                                                AS STRING

DECLARE FUNCTION SQL_TextDate                   LIB "SQLT_Pro.DLL" ALIAS "SQL_TextDate" _
                                                (BYVAL sDate AS STRING) _
                                                AS STRING

DECLARE FUNCTION SQL_TextTime                   LIB "SQLT_Pro.DLL" ALIAS "SQL_TextTime" _
                                                (BYVAL sTime AS STRING) _
                                                AS STRING

DECLARE FUNCTION SQL_MsgBox                     LIB "SQLT_Pro.DLL" ALIAS "SQL_MsgBox" _
                                                (BYVAL sMessage AS STRING, _
                                                 BYVAL lStyle AS LONG) _
                                                AS LONG

DECLARE FUNCTION SQL_MsgBoxButton               LIB "SQLT_Pro.DLL" ALIAS "SQL_MsgBoxButton" _
                                                AS LONG

DECLARE FUNCTION SQL_IString                    LIB "SQLT_Pro.DLL" ALIAS "SQL_IString" _
                                                (BYVAL sString AS STRING) _
                                                AS STRING

DECLARE FUNCTION SQL_LimitTextLength            LIB "SQLT_Pro.DLL" ALIAS "SQL_LimitTextLength" _
                                                (BYVAL sString AS STRING) _
                                                AS STRING

DECLARE FUNCTION SQL_Okay                       LIB "SQLT_Pro.DLL" ALIAS "SQL_Okay" _
                                                (BYVAL lResult AS LONG) _
                                                AS LONG

DECLARE FUNCTION SQL_SelectFile                 LIB "SQLT_Pro.DLL" ALIAS "SQL_SelectFile" _
                                                (BYVAL sTitle AS STRING, _
                                                 BYREF sFileSpec AS STRING, _
                                                 BYVAL sInitialDir AS STRING, _
                                                 BYVAL sFilter AS STRING, _
                                                 BYVAL sDefExtension AS STRING, _
                                                 BYREF lFlags AS LONG) _
                                                AS LONG

DECLARE FUNCTION SQL_ToolsVersion               LIB "SQLT_Pro.DLL" ALIAS "SQL_ToolsVersion" _
                                                AS LONG

DECLARE FUNCTION SQL_StringToType               LIB "SQLT_Pro.DLL" ALIAS "SQL_StringToType" _
                                                (BYREF sString AS STRING, _
                                                 BYVAL dwPointer AS DWORD, _
                                                 BYVAL lLength AS LONG) _
                                                AS LONG

'----------------------------------------------------------------------------

'GET INFO FAMILY


DECLARE FUNCTION SQL_GetTblCols                 LIB "SQLT_Pro.DLL" ALIAS "SQL_GetTblCols" _
                                                (BYVAL lTableNumber AS LONG) _
                                                AS LONG

DECLARE FUNCTION SQL_GetTableColumns            LIB "SQLT_Pro.DLL" ALIAS "SQL_GetTableColumns" _
                                                (BYVAL lDatabaseNumber AS LONG, _
                                                 BYVAL lTableNumber AS LONG) _
                                                AS LONG

DECLARE FUNCTION SQL_GetTblInfo                 LIB "SQLT_Pro.DLL" ALIAS "SQL_GetTblInfo" _
                                                AS LONG

DECLARE FUNCTION SQL_GetTableInfo               LIB "SQLT_Pro.DLL" ALIAS "SQL_GetTableInfo" _
                                                (BYVAL lDatabaseNumber AS LONG) _
                                                AS LONG

'PRO DLL ONLY:

DECLARE FUNCTION SQL_GetDataSources             LIB "SQLT_Pro.DLL" ALIAS "SQL_GetDataSources" _
                                                AS LONG

DECLARE FUNCTION SQL_GetDrivers                 LIB "SQLT_Pro.DLL" ALIAS "SQL_GetDrivers" _
                                                AS LONG

DECLARE FUNCTION SQL_GetAutoCols                LIB "SQLT_Pro.DLL" ALIAS "SQL_GetAutoCols" _
                                                (BYVAL lTableNumber AS LONG) _
                                                AS LONG

DECLARE FUNCTION SQL_GetAutoColumns             LIB "SQLT_Pro.DLL" ALIAS "SQL_GetAutoColumns" _
                                                (BYVAL lDatabaseNumber AS LONG, _
                                                 BYVAL lTableNumber AS LONG) _
                                                AS LONG

DECLARE FUNCTION SQL_GetColPrivs                LIB "SQLT_Pro.DLL" ALIAS "SQL_GetColPrivs" _
                                                (BYVAL lTableNumber AS LONG, _
                                                 BYVAL lColumnNumber AS LONG) _
                                                AS LONG

DECLARE FUNCTION SQL_GetColumnPrivileges        LIB "SQLT_Pro.DLL" ALIAS "SQL_GetColumnPrivileges"      _
                                                (BYVAL lDatabaseNumber AS LONG, _
                                                 BYVAL lTableNumber AS LONG, _
                                                 BYVAL lColumnNumber AS LONG) _
                                                AS LONG

DECLARE FUNCTION SQL_GetDBDataTypes             LIB "SQLT_Pro.DLL" ALIAS "SQL_GetDBDataTypes" _
                                                AS LONG

DECLARE FUNCTION SQL_GetDatabaseDataTypes       LIB "SQLT_Pro.DLL" ALIAS "SQL_GetDatabaseDataTypes" _
                                                (BYVAL lDatabaseNumber AS LONG) _
                                                AS LONG

DECLARE FUNCTION SQL_GetFornKeys                LIB "SQLT_Pro.DLL" ALIAS "SQL_GetFornKeys" _
                                                (BYVAL lTableNumber AS LONG) _
                                                AS LONG

DECLARE FUNCTION SQL_GetForeignKeys             LIB "SQLT_Pro.DLL" ALIAS "SQL_GetForeignKeys" _
                                                (BYVAL lDatabaseNumber AS LONG, _
                                                 BYVAL lTableNumber AS LONG) _
                                                AS LONG

DECLARE FUNCTION SQL_GetIndxes                  LIB "SQLT_Pro.DLL" ALIAS "SQL_GetIndxes" _
                                                (BYVAL lTableNumber AS LONG) _
                                                AS LONG

DECLARE FUNCTION SQL_GetIndexes                 LIB "SQLT_Pro.DLL" ALIAS "SQL_GetIndexes" _
                                                (BYVAL lDatabaseNumber AS LONG, _
                                                 BYVAL lTableNumber AS LONG) _
                                                AS LONG

DECLARE FUNCTION SQL_GetPrimKeys                LIB "SQLT_Pro.DLL" ALIAS "SQL_GetPrimKeys" _
                                                (BYVAL lTableNumber AS LONG) _
                                                AS LONG


DECLARE FUNCTION SQL_GetPrimaryKeys             LIB "SQLT_Pro.DLL" ALIAS "SQL_GetPrimaryKeys" _
                                                (BYVAL lDatabaseNumber AS LONG, _
                                                 BYVAL lTableNumber AS LONG) _
                                                AS LONG

DECLARE FUNCTION SQL_GetProcCols                LIB "SQLT_Pro.DLL" ALIAS "SQL_GetProcCols" _
                                                (BYVAL lProcedureNumber AS LONG) _
                                                AS LONG

DECLARE FUNCTION SQL_GetProcedureColumns        LIB "SQLT_Pro.DLL" ALIAS "SQL_GetProcedureColumns" _
                                                (BYVAL lDatabaseNumber AS LONG, _
                                                 BYVAL lProcedureNumber AS LONG) _
                                                AS LONG

DECLARE FUNCTION SQL_GetProcs                   LIB "SQLT_Pro.DLL" ALIAS "SQL_GetProcs" _
                                                AS LONG

DECLARE FUNCTION SQL_GetProcedures              LIB "SQLT_Pro.DLL" ALIAS "SQL_GetProcedures" _
                                                (BYVAL lDatabaseNumber AS LONG) _
                                                AS LONG

DECLARE FUNCTION SQL_GetTblPrivs                LIB "SQLT_Pro.DLL" ALIAS "SQL_GetTblPrivs" _
                                                (BYVAL lTableNumber AS LONG) _
                                                AS LONG

DECLARE FUNCTION SQL_GetTablePrivileges         LIB "SQLT_Pro.DLL" ALIAS "SQL_GetTablePrivileges" _
                                                (BYVAL lDatabaseNumber AS LONG, _
                                                 BYVAL lTableNumber AS LONG) _
                                                AS LONG

DECLARE FUNCTION SQL_GetUniqCols                LIB "SQLT_Pro.DLL" ALIAS "SQL_GetUniqCols" _
                                                (BYVAL lTableNumber AS LONG) _
                                                AS LONG

DECLARE FUNCTION SQL_GetUniqueColumns           LIB "SQLT_Pro.DLL" ALIAS "SQL_GetUniqueColumns" _
                                                (BYVAL lDatabaseNumber AS LONG, _
                                                 BYVAL lTableNumber AS LONG) _
                                                AS LONG


'----------------------------------------------------------------------------

'HANDLE FAMILY

DECLARE FUNCTION SQL_hParentWindow              LIB "SQLT_Pro.DLL" ALIAS "SQL_hParentWindow" _
                                                AS LONG

'PRO DLL ONLY:

DECLARE FUNCTION SQL_hEnvironment               LIB "SQLT_Pro.DLL" ALIAS "SQL_hEnvironment" _
                                                AS LONG

DECLARE FUNCTION SQL_hDB                        LIB "SQLT_Pro.DLL" ALIAS "SQL_hDB" _
                                                AS LONG

DECLARE FUNCTION SQL_hDatabase                  LIB "SQLT_Pro.DLL" ALIAS "SQL_hDatabase" _
                                                (BYVAL lDatabaseNumber AS LONG) _
                                                AS LONG

DECLARE FUNCTION SQL_hStmt                      LIB "SQLT_Pro.DLL" ALIAS "SQL_hStmt" _
                                                AS LONG

DECLARE FUNCTION SQL_hStatement                 LIB "SQLT_Pro.DLL" ALIAS "SQL_hStatement" _
                                                (BYVAL lDatabaseNumber AS LONG, _
                                                 BYVAL lStatementNumber AS LONG) _
                                                AS LONG

'This function should be included in all PowerBASIC programs that use SQL Tools:
FUNCTION SQL_OleStringParams ALIAS "SQL_OleStringParams" EXPORT AS LONG
    ASM nop
END FUNCTION

'----------------------------------------------------------------------------
'                                 OPTIONS
'----------------------------------------------------------------------------

        '----------------------------------------
        'SQL_SETOPTIONSINT VALUES (NUMBERS)
        '----------------------------------------

        'TRUE/FALSE SETTINGS... (1-24)
        '----------------------------------------
        %OPT_AUTOAUTO_BIND              = 1

        %OPT_SOFT_SUCCESS               = 5

        %OPT_USE_FETCHSCROLL            = 7

        %OPT_AUTOOPEN_DB                = 10
        %OPT_AUTOCLOSE_DB               = 11

        %OPT_AUTOOPEN_STMT              = 15
        %OPT_AUTOCLOSE_STMT             = 16

        %OPT_OLE_STRING_PARAMS          = 18

        %OPT_TRACE_TIMES                = 20
        %OPT_TRACE_INDENT               = 21
        %OPT_TRACE_APPEND               = 22

        %OPT_NO_SHUTDOWN                = 23
        %OPT_EXIT_CHECK                 = 24

        'ASCII VALUE SETTINGS... (25-32)
        '----------------------------------------
        %OPT_MIN_TEXTCHAR               = 25
        %OPT_MAX_TEXTCHAR               = 26
        %OPT_SQLSTATE_PREFIX            = 30

        'NONZERO POSITIVE VALUES... (33-48)
        '----------------------------------------
        %OPT_DATALEN_CHAR               = 33
        %OPT_DATALEN_VARCHAR            = 34
        %OPT_DATALEN_LONGVARCHAR        = 35
        %OPT_DATALEN_BINARY             = 36
        %OPT_DATALEN_VARBINARY          = 37
        %OPT_DATALEN_LONGVARBINARY      = 38
        %OPT_DATALEN_UNKNOWN            = 39
        %OPT_DATALEN_CHUNK              = 40
        %OPT_DATALEN_WCHAR              = 41
        %OPT_DATALEN_WVARCHAR           = 42
        %OPT_DATALEN_WLONGVARCHAR       = 43

        %OPT_MAX_ERRORS                 = 48

        'NONZERO SIGNED VALUES... (49-59)
        '----------------------------------------
        %OPT_ICON_ID                    = 49
        %OPT_h_EXE_INSTANCE             = 50
        %OPT_h_PARENT_WINDOW            = 51

        %OPT_LONGRES_COLTYPE            = 55

        'SPECIFIC LEGAL RANGES... (60-99)
        '----------------------------------------
        %OPT_TEXT_MAXLENGTH             = 60
        %OPT_MAX_CONN_STRING_LEN        = 61    '=>1024 and <= 65,535

        %OPT_ERROR_SOUNDTYPE            = 63    'See %SOUND_ equates
        %OPT_ERROR_MSGBOXTYPE           = 64    'See %MSGBOX_ equates

        %OPT_MAX_DB_NUMBER              = 65    '=> 1 and <= value set by SQL_Initialize
        %OPT_MAX_STMT_NUMBER            = 66    '=> 0 and <= value set by SQL_Initialize
        %OPT_MAX_ITEM_NUMBER            = 47    '=> 64 and <= 64k (default 9,999)

        %OPT_OPENDB_PROMPT              = 68
        %OPT_ODBC_CURSORS               = 69
        %OPT_CURSOR_SENSITIVITY         = 70
        %OPT_CURSOR_SCROLLABLE          = 71
        %OPT_QUERY_TIMEOUT              = 72
        %OPT_MAX_RESULT_ROWS            = 73
        %OPT_SCANFORESCAPES             = 74
        %OPT_MAX_COLUMN_LENGTH          = 75
        %OPT_BIND_TYPE                  = 77
        %OPT_CURSOR_TYPE                = 78
        %OPT_CONCURRENCY                = 79
        %OPT_KEYSET_SIZE                = 80
        %OPT_SIMULATE_CURSOR            = 82
        %OPT_RETRIEVE_DATA              = 83
        %OPT_USE_BOOKMARKS              = 84

        %OPT_DATE_LOCALE                = 90
        %LOCALE_USER_DEFAULT            = &h0400
        %LOCALE_SYSTEM_DEFAULT          = &h0800&

        %OPT_DATE_FLAGS                 = 91
        %OPT_TIME_LOCALE                = 95
        %OPT_TIME_FLAGS                 = 96

        %OPT_STAT_ENSURE                = 98
        %OPT_UNIQUE_SCOPE               = 99

        '----------------------------------------
        'SQL_SETOPTIONSTR VALUES (STRINGS)
        '----------------------------------------

        %OPT_MY_COMPANY         = -1
        %OPT_MY_PROGRAM         = -2
        %OPT_MY_MODULE          = -3
        %OPT_MY_FUNCTION        = -4

        %OPT_TABLE_NAME         = -5
        %OPT_TABLE_TYPES        = -6
        %OPT_TABLE_SCHEMA       = -7
        %OPT_TABLE_CATALOG      = -8

        %OPT_TEXT_DELIMITER     = -9
        %OPT_ROW_DELIMITER      = -10
        %OPT_COL_DELIMITER      = -11

        %OPT_TEXT_TRUE          = -12
        %OPT_TEXT_FALSE         = -13
        %OPT_TEXT_NULL          = -14
        %OPT_TEXT_UNBOUND       = -15
        %OPT_TEXT_QUOTE         = -16

        %OPT_TRACE_FILE         = -19

        'VARIOUS TEXT MESSAGES...
        '----------------------------------------
        %OPT_SELECTDSN          = -20

        %OPT_ERRMSGBOX1         = -28
        %OPT_ERRMSGBOX2         = -29
        %OPT_ERR999000030       = -30
        %OPT_ERR999000031       = -31
        %OPT_ERR999000032       = -32
        %OPT_ERR999000033       = -33
        %OPT_ERR999000034       = -34
        %OPT_ERR999000035       = -35
        %OPT_ERR999000036       = -36
        %OPT_ERR999000037       = -37
        %OPT_ERR999000038       = -38
        %OPT_ERR999000039       = -39
        %OPT_ERR999000040       = -40
        %OPT_ERR999000041       = -41
        %OPT_ERR999000042       = -42
        %OPT_ERR999000043       = -43
        %OPT_ERR999000044       = -44
        %OPT_ERR999000045       = -45
        %OPT_ERR999000046       = -46
        %OPT_ERR999000047       = -47
        %OPT_ERR999000048       = -48
        %OPT_ERR999000049       = -49

        %OPT_DATE_FORMAT        = -80
        %OPT_TIME_FORMAT        = -81
        %OPT_DATETIME_SEPARATOR = -82

        %OPT_ISTRING_PREFIX     = -90
        %OPT_ISTRING_SUFFIX     = -91
        %OPT_ISTRING_CR         = -92
        %OPT_ISTRING_LF         = -93
        %OPT_ISTRING_TAB        = -94
        %OPT_ISTRING_QUOTE      = -95
        %OPT_ISTRING_ENTER      = -96
        %OPT_ISTRING_ASCII      = -97
        %OPT_ISTRING_SEARCH     = -98
        %OPT_ISTRING_REPLACE    = -99


        'SQL, ODBC, and SQL TOOLS ERROR NUMBERS

        'Defined by ODBC...

        $IF NOT %DEF(%SUCCESS)
                %SUCCESS                =   0           'ZERO ERRORS
        $ENDIF

        %SUCCESS_WITH_INFO              =   1           'SUCCESS; GET INFO FROM SQL_Error FUNCTION
        %SQL_STILL_EXECUTING            =   2
        %SQL_ERROR                      =  -1           'SQL REPORTED AN ERROR
        %SQL_INVALID_HANDLE             =  -2           'HANDLE PASSED TO API FUNCTION IS INVALID
        %SQL_IGNORE                     =  -6
        %SQL_NEED_DATA                  =  99
        %SQL_NO_DATA                    = 100           'END OF DATA (i.e. LAST ROW) REACHED

        'Note: The Windows SQLInstallerError API function returns errors 2-22, so these numbers are reserved.

        'Defined by SQL Tools...

        %ERROR_FIRST_SQLT_ERROR         = 999000000

        %ERROR_DLL_NOT_AUTHORIZED       = 999000000

        %ERROR_BAD_PARAM_VALUE          = 999000030

        %ERROR_DB_NOT_OPEN              = 999000031
        %ERROR_DB_NOT_CLOSED            = 999000032

        %ERROR_STMT_NOT_OPEN            = 999000034
        %ERROR_STMT_NOT_CLOSED          = 999000035
        %ERROR_STMT_NOT_PREPARED        = 999000036

        %ERROR_COL_NOT_BOUND            = 999000038

        %ERROR_USER_CANCEL              = 999000045

        %ERROR_TOO_MANY                 = 999000047
        %ERROR_CANT_BE_DONE             = 999000048
        %ERROR_ADVISORY                 = 999000049

        'ERROR RANGES (999 each)...
        %ERROR_FIRST_BAS_ERROR          = 999001000
        %ERROR_LAST_BAS_ERROR           = 999001999

        %ERROR_UNKNOWN_ERROR            = 999999999
        %ERROR_LAST_SQLT_ERROR          = 999999999

        '---------------------------------------------

        %TRACE_OFF                      = 0
        %TRACE_SINGLE                   = 1
        %TRACE_ON                       = 2

        '---------------------------------------------

        'SQL Error Table Columns

        %ERROR_DB                       = 1
        %ERROR_STMT                     = 2
        %ERROR_COL                      = 3
        %ERROR_FUNCTION                 = 4
        %ERROR_NUMBER                   = 5
        %ERROR_SQL_STATE                = 6
        %ERROR_NATIVE_CODE              = 7
        %ERROR_TEXT                     = 8
        %ERROR_TIME                     = 9

        '---------------------------------------------

        'SQL_Diagnostic Info Types:

        %DIAG_RETURNCODE                = 1
        %DIAG_NUMBER                    = 2
        %DIAG_ROW_COUNT                 = 3
        %DIAG_SQLSTATE                  = 4
        %DIAG_NATIVE                    = 5
        %DIAG_MESSAGE_TEXT              = 6
        %DIAG_DYNAMIC_FUNCTION          = 7
        %DIAG_CLASS_ORIGIN              = 8
        %DIAG_SUBCLASS_ORIGIN           = 9
        %DIAG_CONNECTION_NAME           = 10
        %DIAG_SERVER_NAME               = 11
        %DIAG_DYNAMIC_FUNCTION_CODE     = 12

        'This file contains equates that are related to the Graphical
        'User Interface (dialog boxes, message boxes, sounds, icons,
        'buttons, etc.)

        %PROMPT_TYPE_NOPROMPT           =  0
        %PROMPT_TYPE_COMPLETE           =  1
        %PROMPT_TYPE_PROMPT             =  2
        %PROMPT_TYPE_REQUIRED           =  3

        '--------------------------------------------------------------------

        %ICON_SQLTOOLS                  = 32500&
        %ICON_APPLICATION               = 32512&
        %ICON_HAND                      = 32513&
        %ICON_ERROR                     = 32513&
        %ICON_QUESTION                  = 32514&
        %ICON_EXCLAMATION               = 32515&
        %ICON_WARNING                   = 32515&
        %ICON_ASTERISK                  = 32516&
        %ICON_INFORMATION               = 32516&
        %ICON_WINLOGO                   = 32517&

        '--------------------------------------------------------------------

        %SOUND_NONE                     = -1
        %SOUND_OK                       = 0
        %SOUND_HAND                     = 16
        %SOUND_QUESTION                 = 32
        %SOUND_EXCLAMATION              = 48
        %SOUND_ASTERISK                 = 64

        '--------------------------------------------------------------------

        %MSGBOX_NONE                    = -1
        %MSGBOX_OK                      = 0
        %MSGBOX_OKCANCEL                = 1
        %MSGBOX_ABORTRETRYIGNORE        = 2
        %MSGBOX_YESNOCANCEL             = 3
        %MSGBOX_YESNO                   = 4
        %MSGBOX_RETRYCANCEL             = 5

        '--------------------------------------------------------------------

        %BUTTON_NOT_SELECTED            = -1
        %OK_BUTTON                      = 1
        %OPEN_BUTTON                    = 1
        %CANCEL_BUTTON                  = 2
        %ABORT_BUTTON                   = 3
        %RETRY_BUTTON                   = 4
        %IGNORE_BUTTON                  = 5
        %YES_BUTTON                     = 6
        %NO_BUTTON                      = 7

        '--------------------------------------------------------------------

        'SQL_SelectFile lFlags& values:

        'Input flags:
        %OFN_ALLOWMULTISELECT           = &h000200
        %OFN_CREATEPROMPT               = &h002000
        %OFN_FILEMUSTEXIST              = &h001000
        %OFN_HIDEREADONLY               = &h000004
        %OFN_NOCHANGEDIR                = &h000008
        %OFN_NODEREFERENCELINKS         = &h100000
        %OFN_NONETWORKBUTTON            = &h020000
        %OFN_NOTESTFILECREATE           = &h010000
        %OFN_NOVALIDATE                 = &h000100
        %OFN_PATHMUSTEXIST              = &h000800
        %OFN_READONLY                   = &h000001

        'Output flags
        %OFN_EXTENSIONDIFFERENT         = &h000400
        %OFN_NOREADONLYRETURN           = &h008000


        'Miscellaneous SQL Tools equates...


        %SQL_STMT_PREPARE               = 1
        %PREP                           = 1

        %SQL_STMT_EXECUTE               = 2
        %EXEC                           = 2

        %SQL_STMT_IMMEDIATE             = 3
        %SQL_STMT_IMMED                 = 3
        %SQL_STMT_EXECDIRECT            = 3
        %DIRECT                         = 3

        '--------------------------------------------------------------

        %SET_POSITION                   = 0
        %SET_REFRESH                    = 1
        %SET_UPDATE                     = 2
        %SET_DELETE                     = 3

        '--------------------------------------------------------------

        %NEXT_ROW                       = 0
        %FIRST_ROW                      = -1
        %PREV_ROW                       = -2
        %LAST_ROW                       = -3
        %FETCH_SIMPLE                   = -4

        '--------------------------------------------------------------

        %BULK_ADD                       = 4
        %BULK_UPDATE                    = 5
        %BULK_DELETE                    = 6
        %BULK_FETCH                     = 7

        '--------------------------------------------------------------

        %TRANS_COMMIT                   = 0
        %TRANS_ROLLBACK                 = 1

        '--------------------------------------------------------------

        %LOCK_NO_CHANGE                 = 0
        %LOCK_ON                        = 1
        %LOCK_OFF                       = 2

        '--------------------------------------------------------------

        %SQL_QUICK                      = 0
        %SQL_ENSURE                     = 1

        '--------------------------------------------------------------

        %SQL_NUMERIC_DATA               = 0
        %SQL_NULL_DATA                  = -1
        %SQL_LONG_DATA                  = -2  'ALSO KNOWN AS SQL_DATA_AT_EXEC (EXECution)
        %SQL_LENGTH_UNKNOWN             = -4

        '--------------------------------------------------------------

        %SQL_PARAM_INPUT                = 1
        %SQL_PARAM_INPUT_OUTPUT         = 2
        %SQL_PARAM_OUTPUT               = 4

        '--------------------------------------------------------------

        $IF NOT %DEF(%ON)
                %ON                     = -1
        $ENDIF

        $IF NOT %DEF(%OFF)
                %OFF                    =  0
        $ENDIF

        '--------------------------------------------------------------

        %ALL_DBs                        = -1
        %ALL_STMTs                      = -1
        %ALL_COLs                       = -1
        %ALL_LONG_COLs                  = -2

        '--------------------------------------------------------------

        %THREAD_STOP                    = 0
        %THREAD_START                   = 1
        %THREAD_MAX                     = 2

        '--------------------------------------------------------------


        'These equates are used for the first parameter of the
        'SQL_FuncAvail function, or the second parameter of the
        'SQL_FunctionAvailable function...

        'ODBC CORE COMPLIANCE...
        %API_SQLALLOCCONNECT             =    1
        %API_SQLALLOCENV                 =    2
        %API_SQLALLOCSTMT                =    3
        %API_SQLBINDCOL                  =    4
        %API_SQLCANCEL                   =    5
        %API_SQLCOLATTRIBUTE             =    6
        %API_SQLCONNECT                  =    7
        %API_SQLDESCRIBECOL              =    8
        %API_SQLDISCONNECT               =    9
        %API_SQLERROR                    =   10
        %API_SQLEXECDIRECT               =   11
        %API_SQLEXECUTE                  =   12
        %API_SQLFETCH                    =   13
        %API_SQLFREECONNECT              =   14
        %API_SQLFREEENV                  =   15
        %API_SQLFREESTMT                 =   16
        %API_SQLGETCURSORNAME            =   17
        %API_SQLNUMRESULTCOLS            =   18
        %API_SQLPREPARE                  =   19
        %API_SQLROWCOUNT                 =   20
        %API_SQLSETCURSORNAME            =   21
        %API_SQLSETPARAM                 =   22
        %API_SQLTRANSACT                 =   23
        %API_SQLBULKOPERATIONS           =   24
        'OBDC COMPLIANCE LEVEL 1 AND ABOVE...
        %API_SQLCOLUMNS                  =   40
        %API_SQLDRIVERCONNECT            =   41
        %API_SQLGETCONNECTOPTION         =   42
        %API_SQLGETDATA                  =   43
        %API_SQLGETFUNCTIONS             =   44
        %API_SQLGETINFO                  =   45
        %API_SQLGETSTMTOPTION            =   46
        %API_SQLGETTYPEINFO              =   47
        %API_SQLPARAMDATA                =   48
        %API_SQLPUTDATA                  =   49
        %API_SQLSETCONNECTOPTION         =   50
        %API_SQLSETSTMTOPTION            =   51
        %API_SQLSPECIALCOLUMNS           =   52
        %API_SQLSTATISTICS               =   53
        %API_SQLTABLES                   =   54
        'ODBC COMPLIANCE LEVEL 2 AND ABOVE...
        %API_SQLBROWSECONNECT            =   55
        %API_SQLCOLUMNPRIVILEGES         =   56
        %API_SQLDATASOURCES              =   57
        %API_SQLDESCRIBEPARAM            =   58
        %API_SQLEXTENDEDFETCH            =   59
        %API_SQLFOREIGNKEYS              =   60
        %API_SQLMORERESULTS              =   61
        %API_SQLNATIVESQL                =   62
        %API_SQLNUMPARAMS                =   63
        %API_SQLPARAMOPTIONS             =   64
        %API_SQLPRIMARYKEYS              =   65
        %API_SQLPROCEDURECOLUMNS         =   66
        %API_SQLPROCEDURES               =   67
        %API_SQLSETPOS                   =   68
        %API_SQLSETSCROLLOPTIONS         =   69
        %API_SQLTABLEPRIVILEGES          =   70
        %API_SQLDRIVERS                  =   71
        %API_SQLBINDPARAMETER            =   72
        %API_SQLALLOCHANDLESTD           =   73
        %API_LOADBYORDINAL               =  199     'NOT SUPPORTED BY ODBC 3.0 AND ABOVE
        %API_SQLALLOCHANDLE              = 1001
        %API_SQLBINDPARAM                = 1002
        %API_SQLCLOSECURSOR              = 1003
        %API_SQLCOPYDESC                 = 1004
        %API_SQLENDTRAN                  = 1005
        %API_SQLFREEHANDLE               = 1006
        %API_SQLGETCONNECTATTR           = 1007
        %API_SQLGETDESCFIELD             = 1008
        %API_SQLGETDESCREC               = 1009
        %API_SQLGETDIAGFIELD             = 1010
        %API_SQLGETDIAGREC               = 1011
        %API_SQLGETENVATTR               = 1012
        %API_SQLGETSTMTATTR              = 1014
        %API_SQLSETCONNECTATTR           = 1016
        %API_SQLSETDESCFIELD             = 1017
        %API_SQLSETDESCREC               = 1018
        %API_SQLSETENVATTR               = 1019
        %API_SQLSETSTMTATTR              = 1020
        %API_SQLFETCHSCROLL              = 1021

        %SQL_DEFAULT_PARAM              = -5




        'This file contains equates that are related to the
        'various SQL Tools Attrib and Mode functions.

        %DB_ATTR_ACCESS_MODE                    = 101   'ODBC 3.0 (Core)      (numeric) (some drivers require this to be set between OpenConnection1 and OpenConnection2; all drivers allow it to be set then.)
                %SQL_MODE_READ_WRITE   = 0              '(ODBC AND SQL TOOLS DEFAULT)
                %SQL_MODE_READ_ONLY    = 1

        %DB_ATTR_AUTOCOMMIT                     = 102   'ODBC 1.0 (Level 1)   (numeric)
                %SQL_AUTOCOMMIT_OFF     = 0
                %SQL_AUTOCOMMIT_ON      = 1             '(ODBC AND SQL TOOLS DEFAULT)

        %DB_ATTR_LOGIN_TIMEOUT                  = 103   'ODBC 1.0 (Level 2)   (numeric) (must always be set between OpenConnection1 and OpenConnection2)

        %DB_ATTR_TRACE                          = 104   'ODBC 1.0 (Core)      (numeric)
                %SQL_TRACE_OFF          = 0
                %SQL_TRACE_ON           = 1

        %DB_ATTR_TRACEFILE                      = 105   'ODBC 1.0 (Core)      (string)

        %DB_ATTR_TRANSLATE_LIB                  = 106   'ODBC 1.0 (Core)      (string)  (can NOT be set between OpenConnection1 and OpenConnection2)

        %DB_ATTR_TRANSLATE_OPTION               = 107   'ODBC 1.0 (Core)      (numeric) (can NOT be set between OpenConnection1 and OpenConnection2)

        %DB_ATTR_TXN_ISOLATION                  = 108   'ODBC 1.0 (Level 1/2) (numeric) (can only be set when there are no open transactions on the connection.)  (see note in Help File)

        %DB_ATTR_CURRENT_CATALOG                = 109   'ODBC 2.0 (Level 2)   (string)  (some drivers require this to be set between OpenConnection1 and OpenConnection2; all drivers allow it to be set then.)

        %DB_ATTR_ODBC_CURSORS                   = 110   'ODBC 2.0 (Core)      (numeric) (must always be set between OpenConnection1 and OpenConnection2)
                %SQL_CUR_USE_IF_NEEDED  = 0
                %SQL_CUR_USE_ODBC       = 1
                %SQL_CUR_USE_DRIVER     = 2

        %DB_ATTR_QUIET_MODE                     = 111   'ODBC 2.0 (numeric)

        %DB_ATTR_PACKET_SIZE                    = 112   'ODBC 2.0 (Level 2)   (numeric) (must always be set between OpenConnection1 and OpenConnection2)

        %DB_ATTR_CONNECTION_TIMEOUT             = 113   'ODBC 3.0 (Level 2)   (numeric)

        %DB_ATTR_DISCONNECT_BEHAVIOR            = 114   'ODBC 3.0
                %SQL_DB_RETURN_TO_POOL  = 0
                %SQL_DB_DISCONNECT      = 1

        %DB_ATTR_CONNECTION_DEAD                = 1209  'ODBC 3.5

        %DB_ATTR_METADATA_ID                    = 10014 'ODBC 3.0 (Core)

        '--------------------------------------------------------------------

        %STMT_ATTR_CURSOR_SENSITIVITY           = -2    'ODBC 3.0 (Level 2)
                %SENS_NONE              = 0             '(ODBC AND SQL TOOLS DEFAULT VALUE)
                %SENS_INSENSITIVE       = 1
                %SENS_SENSITIVE         = 2

        %STMT_ATTR_CURSOR_SCROLLABLE            = -1    'ODBC 3.0 (Level 1)
                %SCRL_OFF               = 0             '(ODBC DEFAULT)
                %SCRL_ON                = 1             '(SQL TOOLS DEFAULT)

        %STMT_ATTR_QUERY_TIMEOUT                = 0     'ODBC 1.0 (Level 2)

        %STMT_ATTR_MAX_RESULT_ROWS              = 1     'ODBC 1.0 (Level 1)

        %STMT_ATTR_SCANFORESCAPES               = 2     'ODBC 1.0 (Core)
                %DO_SCAN                = 0             '(DEFAULT)
                %DONT_SCAN              = 1

        %STMT_ATTR_MAX_COLUMN_LENGTH            = 3     'ODBC 1.0 (Level 1)

        '%STMT_ATTR_ASYNC_ENABLE                = 4     (Asynchronous execution is not supported by SQL TOols)

        %STMT_ATTR_ROW_BIND_TYPE                = 5     'ODBC 1.0 (Core)
                %COLUMN_WISE            = 0             '(DEFAULT)

        %STMT_ATTR_CURSOR_TYPE                  = 6     'ODBC 2.0 (Core/Level 2)
                %CUR_FORWARDONLY        = 0             '(ODBC AND SQL TOOLS DEFAULT)
                %CUR_KEYSET             = 1
                %CUR_DYNAMIC            = 2
                %CUR_STATIC             = 3

        %STMT_ATTR_CONCURRENCY                  = 7     'ODBC 2.0 )Level 1/Level 2)
                %CONC_READONLY          = 1             '(ODBC default)
                %CONC_LOCK              = 2
                %CONC_ROWVER            = 3             '(not supported by many drivers)
                %CONC_VALUES            = 4             '(DEFAULT: NOTE DIFFERENCE BETWEEN ODBC DEFAULT (1) AND SQL TOOLS DEFAULT)

        %STMT_ATTR_KEYSET_SIZE                  = 8     'ODBC 2.0 (Level 2)
                %KEYSET_FULL            = 0             '(DEFAULT)

        '%STMT_ATTR_ROWSET_SIZE                 = 9     NOT DOCUMENTED BY MICROSOFT AS AN ATTRIB VALUE THAT CAN BE USED HERE.

        %STMT_ATTR_SIMULATE_CURSOR              = 10    'ODBC 2.0 (Level 2)
                %SIMC_NONUNIQUE         = 0             '(DEFAULT)
                %SIMC_TRYUNIQUE         = 1
                %SIMC_UNIQUE            = 2

        %STMT_ATTR_RETRIEVE_DATA                = 11    'ODBC 2.0 (Level 1)
                %RD_SEEKONLY            = 0
                %RD_NORMAL              = 1             '(DEFAULT: NOTE NONZERO DEFAULT)

        %STMT_ATTR_USE_BOOKMARKS                = 12    'ODBC 2.0 (Level 2)
                %BMARKS_OFF             = 0             '(DEFAULT)
                %BMARKS_ON              = 1
                %BMARKS_VARIABLE        = 2

        'The following %STMT_ATTR function can be accessed with
        'the SQL_StmtAttrib and SQL_SetStmtAttrib functions, but
        'they cannot be pre-set with the SQL_StmtMode function.

        %STMT_ATTR_ROW_NUMBER                   = 14    'ODBC 2.0 (Level 1)  *READ-ONLY*

        %STMT_ATTR_PARAM_BIND_OFFSET_PTR        = 17    'ODBC 3.0 (Core)

        %STMT_ATTR_PARAM_BIND_TYPE              = 18    'ODBC 3.0 (Core)

        %STMT_ATTR_PARAM_OPERATION_PTR          = 19    'ODBC 3.0

        %STMT_ATTR_PARAM_STATUS_PTR             = 20    'ODBC 3.0
                %SQL_PARAM_SUCCESS          =0
                %SQL_PARAM_DIAG_UNAVAILABLE =1
                %SQL_PARAM_ERROR            =5
                %SQL_PARAM_SUCCESS_WITH_INFO=6
                %SQL_PARAM_UNUSED           =7

        %STMT_ATTR_PARAMS_PROCESSED_PTR         = 21    'ODBC 3.0 (Core)

        %STMT_ATTR_PARAMSET_SIZE                = 22    'ODBC 3.0 (Core)

        %STMT_ATTR_ROW_BIND_OFFSET_PTR          = 23    'ODBC 3.0 (Core)

        %STMT_ATTR_ROW_OPERATION_PTR            = 24    'ODBC 3.0

        %STMT_ATTR_ROW_STATUS_PTR               = 25    'ODBC 3.0

        %STMT_ATTR_ROWS_FETCHED_PTR             = 26    'ODBC 2.0 (Core)

        %STMT_ATTR_ROW_ARRAY_SIZE               = 27    'ODBC 3.0 (Core)

        '--------------------------------------------------------------------

        %ENV_ODBC_VERSION                       = 200

        %ENV_CONNECTION_POOLING                 = 201
                %SQL_CP_OFF             = 0
                %SQL_CP_ONE_PER_DRIVER  = 1
                %SQL_CP_ONE_PER_HENV    = 2

        %ENV_CP_MATCH                           = 202
                %SQL_CP_STRICT_MATCH    = 0
                %SQL_CP_RELAXED_MATCH   = 1

        %ENV_OUTPUT_NTS                         = 10001

        'This file contains SQL-related User Defined Types...

        TYPE TIMESTAMP_STRUCT           '16 BYTES
                Year     AS INTEGER
                Month    AS WORD
                Day      AS WORD
                Hour     AS WORD
                Minute   AS WORD
                Second   AS WORD
                Fraction AS DWORD
        END TYPE

        TYPE DATE_STRUCT                '6 BYTES
                Year     AS INTEGER
                Month    AS WORD
                Day      AS WORD
        END TYPE


        TYPE TIME_STRUCT                '6 BYTES (does not include 4 bytes for Fraction)
                Hour     AS WORD
                Minute   AS WORD
                Second   AS WORD
        END TYPE


        TYPE SQL_YEAR_MONTH             '8 BYTES
                Year     AS DWORD
                Month    AS DWORD
        END TYPE

        TYPE SQL_DAY_SECOND
                Day      AS DWORD       '20 BYTES
                Hour     AS DWORD
                Minute   AS DWORD
                Second   AS DWORD
                Fraction AS DWORD
        END TYPE


        UNION SQL_Interval              '20 BYTES, 16 OF WHICH ARE NOT USED BY YEARMONTH.
                YearMonth AS SQL_YEAR_MONTH
                DaySecond AS SQL_DAY_SECOND
        END UNION


        TYPE SQL_INTERVAL_STRUCT        '26 BYTES
                IntervalType AS LONG
                IntervalSign AS INTEGER
                Inerval      AS SQL_INTERVAL
        END TYPE



        'This file contains equates that are related to the
        'various SQL Tools "Info" functions...

        %TABLE_COLUMN_COUNT                                             = 1
        %TABLE_PRIVILEGE_COUNT                                          = 2
        %TABLE_FOREIGNKEY_COUNT                                         = 3
        %TABLE_PRIMARYKEY_COUNT                                         = 4
        %TABLE_INDEX_COUNT                                              = 5
        %TABLE_STATISTIC_COUNT                                          = 6
        %TABLE_UNIQUECOLUMN_COUNT                                       = 7
        %TABLE_AUTOCOLUMN_COUNT                                         = 8
        %TABLE_CATALOG_NAME                                             = 21
        %TABLE_SCHEMA_NAME                                              = 22
        %TABLE_NAME                                                     = 23
        %TABLE_TYPE                                                     = 24
        %TABLE_REMARKS                                                  = 25

        '------------------------------------------------------------------------------------

        %TBLCOL_FIRST                                                   = 103
        %TBLCOL_CATALOG_NAME                                            = 103
        %TBLCOL_SCHEMA_NAME                                             = 104
        %TBLCOL_TABLE_NAME                                              = 105
        %TBLCOL_COLUMN_NAME                                             = 106
        %TBLCOL_DATA_TYPE                                               = 107
        %TBLCOL_TYPE_NAME                                               = 108
        %TBLCOL_DISPLAY_SIZE                                            = 109
        %TBLCOL_BUFFER_LENGTH                                           = 110
        %TBLCOL_DECIMAL_DIGITS                                          = 111
        %TBLCOL_NUM_PREC_RADIX                                          = 112
        %TBLCOL_NULLABLE                                                = 113
        %TBLCOL_REMARKS                                                 = 114
        %TBLCOL_DEFAULT_VALUE                                           = 115   'ODBC 3.0 and above
        %TBLCOL_SQL_DATA_TYPE                                           = 116   'ODBC 3.0 and above
        %TBLCOL_DATETIME_SUB                                            = 117   'ODBC 3.0 and above
        %TBLCOL_CHAR_OCTET_LENGTH                                       = 118   'ODBC 3.0 and above
        %TBLCOL_ORDINAL_POSITION                                        = 119   'ODBC 3.0 and above
        %TBLCOL_IS_NULLABLE                                             = 120   'ODBC 3.0 and above
        'SQL Tools supports driver-defined info types from 121 to 134, if
        'an ODBC driver provides them...
        %TBLCOL_DRIVERDEF_FIRST                                         = 121
        'If your driver's documentation lists a driver-specific info
        'by number, add 102 to get the SQL Tools info number.  For example, all
        'ODBC drivers are supposed to provide 18 info types (1-08), which SQL
        'Tools accesses as 103 through 120.  If a certain driver provides two
        'driver-specific types of info and documents them as #19 and #20, you
        'would access them with SQL Tools #121 and #122.
        %TBLCOL_DRIVERDEF_LAST                                          = 134
        %TBLCOL_LAST                                                    = 134

        '------------------------------------------------------------------------------------

        %RESCOL_CONCISE_TYPE                                            =    2  'ODBC 3.0       Num
        %RESCOL_DISPLAY_SIZE                                            =    6  'ODBC 1.0       Num
        %RESCOL_UNSIGNED                                                =    8  'ODBC 1.0       Num
        %RESCOL_FIXED_PREC_SCALE                                        =    9  'ODBC 1.0       Num
        %RESCOL_UPDATABLE                                               =   10  'ODBC 1.0       Num
             %SQL_ATTR_READONLY           = 0
             %SQL_ATTR_WRITE              = 1
             %SQL_ATTR_READWRITE_UNKNOWN  = 2
        %RESCOL_AUTO_UNIQUE_VALUE                                       =   11  'ODBC 1.0       Num
        %RESCOL_CASE_SENSITIVE                                          =   12  'ODBC 1.0       Num
        %RESCOL_SEARCHABLE                                              =   13  'ODBC 1.0       Num
        %RESCOL_TYPE_NAME                                               =   14  'ODBC 1.0       Str
        %RESCOL_TABLE_NAME                                              =   15  'ODBC 2.0       Str
        %RESCOL_SCHEMA_NAME                                             =   16  'ODBC 2.0       Str
        %RESCOL_CATALOG_NAME                                            =   17  'ODBC 2.0       Str
        %RESCOL_LABEL                                                   =   18  'ODBC 2.0       Str
        %RESCOL_BASE_COLUMN_NAME                                        =   22  'ODBC 3.0       Str
        %RESCOL_BASE_TABLE_NAME                                         =   23  'ODBC 3.0       Str
        %RESCOL_LITERAL_PREFIX                                          =   27  'ODBC 3.0       Str
        %RESCOL_LITERAL_SUFFIX                                          =   28  'ODBC 3.0       Str
        %RESCOL_LOCAL_TYPE_NAME                                         =   29  'ODBC 3.0       Str
        %RESCOL_NUM_PREX_RADIX                                          =   32  'ODBC 3.0       Num
        %RESCOL_COUNT                                                   = 1001  'ODBC 1.0       Num
        %RESCOL_TYPE                                                    = 1002  'ODBC 1.0       Num (if this doesn't work, try %RESCOL_CONCISE_TYPE)
        %RESCOL_LENGTH                                                  = 1003  'ODBC 3.0       Num
        %RESCOL_PRECISION                                               = 1005  'ODBC 3.0       Num
        %RESCOL_SCALE                                                   = 1006  'ODBC 3.0       Num
        %RESCOL_NULLABLE                                                = 1008  'ODBC 3.0       Num
        %RESCOL_NAME                                                    = 1011  'ODBC 3.0       Str
        %RESCOL_UNNAMED                                                 = 1012  'ODBC 3.0       Num
        %RESCOL_OCTET_LENGTH                                            = 1013  'ODBC 3.0       Num

        '------------------------------------------------------------------------------------

        %PROC_CATALOG                                                           = 3
        %PROC_SCHEMA                                                            = 4
        %PROC_NAME                                                              = 5
        %PROC_INPUT_PARAM_COUNT                                                 = 6
        %PROC_OUTPUT_PARAM_COUNT                                                = 7
        %PROC_RESULT_COLUMN_COUNT                                               = 8
        %PROC_REMARKS                                                           = 9

        %PROC_TYPE                                                              = 10
                %SQL_PT_UNKNOWN                         = 0
                %SQL_PT_PROCEDURE                       = 1
                %SQL_PT_FUNCTION                        = 2

        '------------------------------------------------------------------------------------

        %PROC_COLUMN_CATALOG                                                    = 1     'ODBC 2.0
        %PROC_COLUMN_SCHEMA                                                     = 2     'ODBC 2.0
        %PROC_COLUMN_PROC_NAME                                                  = 3     'ODBC 2.0
        %PROC_COLUMN_NAME                                                       = 4     'ODBC 2.0

        %PROC_COLUMN_TYPE                                                       = 5     'ODBC 2.0
                %PROC_UNKNOWN_TYPE_PARAM                = 0
                %PROC_INPUT_PARAM                       = 1
                %PROC_INPUT_OUTPUT_PARAM                = 2
                %PROC_RESULT_COLUMN                     = 3
                %PROC_OUTPUT_PARAM                      = 4
                %PROC_RETURN_VALUE                      = 5

        %PROC_COLUMN_DATA_TYPE                                                  = 6     'ODBC 2.0
        %PROC_COLUMN_DATA_TYPE_NAME                                             = 7     'ODBC 2.0
        %PROC_COLUMN_SIZE                                                       = 8     'ODBC 2.0
        %PROC_COLUMN_BUFFER_LENGTH                                              = 9     'ODBC 2.0
        %PROC_COLUMN_DECIMAL_DIGITS                                             = 10    'ODBC 2.0
        %PROC_COLUMN_NUM_PREC_RADIX                                             = 11    'ODBC 2.0
        %PROC_COLUMN_NULLABLE                                                   = 12    'ODBC 2.0 (see %DTYPE_NULLABLE below for legal values)
        %PROC_COLUMN_REMARKS                                                    = 13    'ODBC 2.0
        %PROC_COLUMN_DEFAULT_VALUE                                              = 14    'ODBC 3.0
        %PROC_COLUMN_SQL_DATA_TYPE                                              = 15    'ODBC 3.0
        %PROC_COLUMN_SQL_DATETIME_SUB                                           = 16    'ODBC 3.0
        %PROC_COLUMN_CHAR_OCTET_LENGTH                                          = 17    'ODBC 3.0
        %PROC_COLUMN_ORDINAL_POSITION                                           = 18    'ODBC 3.0
        %PROC_COLUMN_IS_NULLABLE                                                = 19    'ODBC 3.0

        '------------------------------------------------------------------------------------

        %DRIVER_NAME                                                            = 1
        %DRIVER_DESCRIPTION                                                     = 2

        '------------------------------------------------------------------------------------

        %DATASOURCE_NAME                                                        = 1
        %DATASOURCE_DESCRIPTION                                                 = 2

        '------------------------------------------------------------------------------------

        %DTYPE_NAME                                                             = 1
        %DTYPE_TYPE                                                             = 2
        %DTYPE_COLUMN_SIZE                                                      = 3
        %DTYPE_LITERAL_PREFIX                                                   = 4
        %DTYPE_LITERAL_SUFFIX                                                   = 5
        %DTYPE_CREATE_PARAMS                                                    = 6

        %DTYPE_NULLABLE                                                         = 7
                %SQL_NO_NULLS                           = 0
                %SQL_NULLABLE                           = 1
                %SQL_NULLABLE_UNKNOWN                   = 2

        %DTYPE_CASE_SENSITIVE                                                   = 8
        %DTYPE_SEARCHABLE                                                       = 9
                %SQL_PRED_NONE                          = 0
                %SQL_PRED_CHAR                          = 1
                %SQL_PRED_BASIC                         = 2

        %DTYPE_UNSIGNED_ATTRIBUTE                                               = 10
        %DTYPE_FIXED_PREC_SCALE                                                 = 11
        %DTYPE_AUTO_UNIQUE_VALUE                                                = 12
        %DTYPE_LOCAL_TYPE_NAME                                                  = 13
        %DTYPE_MINIMUM_SCALE                                                    = 14
        %DTYPE_MAXIMUM_SCALE                                                    = 15
        %DTYPE_SQL_DATA_TYPE                                                    = 16    'ODBC 3.0 and above
        %DTYPE_SQL_DATETIME_SUB                                                 = 17    'ODBC 3.0 and above
        %DTYPE_NUM_PREC_RADIX                                                   = 18    'ODBC 3.0 and above
        %DTYPE_INTERVAL_PRECISION                                               = 19    'ODBC 3.0 and above

        '------------------------------------------------------------------------------------

        %PRED_NONE                                                              =  0
        %PRED_CHAR                                                              =  1
        %PRED_BASIC                                                             =  2
        %SEARCHABLE                                                             =  3

        '------------------------------------------------------------------------------------

        %DB_INFO_VOLUME                                                         = -4    'SQL Tools extension
        %DB_DSN_FILENAME                                                        = -3    'SQL Tools extension
        %DB_TABLE_COUNT                                                         = -2    'SQL Tools extension
        %DB_CONNECTION_STRING                                                   = -1    'SQL Tools extension
        %DB_ACTIVE_CONNECTIONS                                                  =  0    'ODBC 2.00 terminology
        %DB_MAX_DRIVER_CONNECTIONS                                              =  0    'ODBC 3.00 terminology
        %DB_ACTIVE_STATEMENTS                                                   =  1    'ODBC 2.00 terminology
        %DB_MAX_CONCURRENT_ACTIVITIES                                           =  1    'ODBC 3.00 terminology
        %DB_DATA_SOURCE_NAME                                                    =  2
        %DB_DRIVER_NAME                                                         =  6
        %DB_DRIVER_VER                                                          =  7
        %DB_FETCH_DIRECTION                                                     =  8    'deprecated in 3.0
        %DB_ODBC_API_CONFORMANCE                                                =  9    'deprecated in 3.0
        %DB_ODBC_VER                                                            = 10
        %DB_ROW_UPDATES                                                         = 11
        %DB_ODBC_STANDARD_CLI_CONFORMANCE                                       = 12
        %DB_SERVER_NAME                                                         = 13
        %DB_SEARCH_PATTERN_ESCAPE                                               = 14
        %DB_ODBC_SQL_CONFORMANCE                                                = 15    'deprecated in 3.0
        %DB_DATABASE_NAME                                                       = 16
        %DB_DBMS_NAME                                                           = 17
        %DB_DBMS_VER                                                            = 18
        %DB_ACCESSIBLE_TABLES                                                   = 19
        %DB_ACCESSIBLE_PROCEDURES                                               = 20
        %DB_PROCEDURES                                                          = 21

        %DB_CONCAT_NULL_BEHAVIOR                                                = 22
                %SQL_CB_NULL                            = 0
                %SQL_CB_NON_NULL                        = 1

        %DB_CURSOR_COMMIT_BEHAVIOR                                              = 23
                %SQL_CB_DELETE                          = 0
                %SQL_CB_CLOSE                           = 1
                %SQL_CB_PRESERVE                        = 2

        %DB_CURSOR_ROLLBACK_BEHAVIOR                                            = 24
        %DB_DATA_SOURCE_READ_ONLY                                               = 25

        %DB_DEFAULT_TXN_ISOLATION                                               = 26
                %SQL_TXN_READ_UNCOMMITTED               = 1
                %SQL_TXN_READ_COMMITTED                 = 2
                %SQL_TXN_REPEATABLE_READ                = 4
                %SQL_TXN_SERIALIZABLE                   = 8

        %DB_EXPRESSIONS_IN_ORDERBY                                              = 27

        %DB_IDENTIFIER_CASE                                                     = 28
                %SQL_IC_UPPER                           = 1
                %SQL_IC_LOWER                           = 2
                %SQL_IC_SENSITIVE                       = 3
                %SQL_IC_MIXED                           = 4

        %DB_IDENTIFIER_QUOTE_CHAR                                               = 29
        %DB_MAX_COLUMN_NAME_LEN                                                 = 30
        %DB_MAX_CURSOR_NAME_LEN                                                 = 31
        %DB_MAX_OWNER_NAME_LEN                                                  = 32    'ODBC 2.0 name
        %DB_MAX_SCHEMA_NAME_LEN                                                 = 32    'ODBC 3.0 name
        %DB_MAX_PROCEDURE_NAME_LEN                                              = 33
        %DB_MAX_QUALIFIER_NAME_LEN                                              = 34    'ODBC 2.0 name
        %DB_MAX_CATALOG_NAME_LEN                                                = 34    'ODBC 3.0 name
        %DB_MAX_TABLE_NAME_LEN                                                  = 35
        %DB_MULT_RESULT_SETS                                                    = 36
        %DB_MULTIPLE_ACTIVE_TXN                                                 = 37

        %DB_OUTER_JOINS                                                         = 38
                %SQL_OJ_LEFT                            = &h1&
                %SQL_OJ_RIGHT                           = &h2&
                %SQL_OJ_FULL                            = &h4&
                %SQL_OJ_NESTED                          = &h8&
                %SQL_OJ_NOT_ORDERED                     = &h10&
                %SQL_OJ_INNER                           = &h20&
                %SQL_OJ_ALL_COMPARISON_OPS              = &h40&

        %DB_OWNER_TERM                                                          = 39    '2.0 terminology
        %DB_SCHEMA_TERM                                                         = 39    '3.0 terminology
        %DB_PROCEDURE_TERM                                                      = 40
        %DB_QUALIFIER_NAME_SEPARATOR                                            = 41    '2.0 terminology
        %DB_CATALOG_NAME_SEPARATOR                                              = 41    '3.0 terminology
        %DB_QUALIFIER_TERM                                                      = 42    '2.0 terminology
        %DB_CATALOG_TERM                                                        = 42    '3.0 terminology
        %DB_SCROLL_CONCURRENCY                                                  = 43    'deprecated in 3.0

        %DB_SCROLL_OPTIONS                                                      = 44
                %SQL_SO_FORWARD_ONLY                    = &h01&
                %SQL_SO_KEYSET_DRIVEN                   = &h02&
                %SQL_SO_DYNAMIC                         = &h04&
                %SQL_SO_MIXED                           = &h08&
                %SQL_SO_STATIC                          = &h10&

        %DB_TABLE_TERM                                                          = 45

        %DB_TXN_CAPABLE                                                         = 46
                %SQL_TC_NONE                            = 0
                %SQL_TC_DML                             = 1
                %SQL_TC_ALL                             = 2
                %SQL_TC_DDL_COMMIT                      = 3
                %SQL_TC_DDL_IGNORE                      = 4

        %DB_USER_NAME                                                           = 47

        %DB_CONVERT_FUNCTIONS                                                   = 48
                %SQL_FN_CVT_CONVERT                     = 1
                %SQL_FN_CVT_CAST                        = 2

        %DB_NUMERIC_FUNCTIONS                                                   = 49
                %SQL_FN_NUM_ABS                         = &h1&
                %SQL_FN_NUM_ACOS                        = &h2&
                %SQL_FN_NUM_ASIN                        = &h4&
                %SQL_FN_NUM_ATAN                        = &h8&
                %SQL_FN_NUM_ATAN2                       = &h10&
                %SQL_FN_NUM_CEILING                     = &h20&
                %SQL_FN_NUM_COS                         = &h40&
                %SQL_FN_NUM_COT                         = &h80&
                %SQL_FN_NUM_EXP                         = &h100&
                %SQL_FN_NUM_FLOOR                       = &h200&
                %SQL_FN_NUM_LOG                         = &h400&
                %SQL_FN_NUM_MOD                         = &h800&
                %SQL_FN_NUM_SIGN                        = &h1000&
                %SQL_FN_NUM_SIN                         = &h2000&
                %SQL_FN_NUM_SQRT                        = &h4000&
                %SQL_FN_NUM_TAN                         = &h8000&
                %SQL_FN_NUM_PI                          = &h10000&
                %SQL_FN_NUM_RAND                        = &h20000&
                %SQL_FN_NUM_DEGREES                     = &h40000&
                %SQL_FN_NUM_LOG10                       = &h80000&
                %SQL_FN_NUM_POWER                       = &h100000&
                %SQL_FN_NUM_RADIANS                     = &h200000&
                %SQL_FN_NUM_ROUND                       = &h400000&
                %SQL_FN_NUM_TRUNCATE                    = &h800000&

        %DB_STRING_FUNCTIONS                                                    = 50
                %SQL_FN_STR_CONCAT                      = &h1&
                %SQL_FN_STR_INSERT                      = &h2&
                %SQL_FN_STR_LEFT                        = &h4&
                %SQL_FN_STR_LTRIM                       = &h8&
                %SQL_FN_STR_LENGTH                      = &h10&
                %SQL_FN_STR_LOCATE                      = &h20&
                %SQL_FN_STR_LCASE                       = &h40&
                %SQL_FN_STR_REPEAT                      = &h80&
                %SQL_FN_STR_REPLACE                     = &h100&
                %SQL_FN_STR_RIGHT                       = &h200&
                %SQL_FN_STR_RTRIM                       = &h400&
                %SQL_FN_STR_SUBSTRING                   = &h800&
                %SQL_FN_STR_UCASE                       = &h1000&
                %SQL_FN_STR_ASCII                       = &h2000&
                %SQL_FN_STR_CHAR                        = &h4000&
                %SQL_FN_STR_DIFFERENCE                  = &h8000&
                %SQL_FN_STR_LOCATE_2                    = &h10000&
                %SQL_FN_STR_SOUNDEX                     = &h20000&
                %SQL_FN_STR_SPACE                       = &h40000&
                %SQL_FN_STR_BIT_LENGTH                  = &h80000&
                %SQL_FN_STR_CHAR_LENGTH                 = &h100000&
                %SQL_FN_STR_CHARACTER_LENGTH            = &h200000&
                %SQL_FN_STR_OCTET_LENGTH                = &h400000&
                %SQL_FN_STR_POSITION                    = &h800000&

        %DB_SYSTEM_FUNCTIONS                                                    = 51
                %SQL_FN_SYS_USERNAME                    = &h1&
                %SQL_FN_SYS_DBNAME                      = &h2&
                %SQL_FN_SYS_IFNULL                      = &h4&

        %DB_TIMEDATE_FUNCTIONS                                                  = 52
                %SQL_FN_TD_NOW                          = &h1&
                %SQL_FN_TD_CURDATE                      = &h2&
                %SQL_FN_TD_DAYOFMONTH                   = &h4&
                %SQL_FN_TD_DAYOFWEEK                    = &h8&
                %SQL_FN_TD_DAYOFYEAR                    = &h10&
                %SQL_FN_TD_MONTH                        = &h20&
                %SQL_FN_TD_QUARTER                      = &h40&
                %SQL_FN_TD_WEEK                         = &h80&
                %SQL_FN_TD_YEAR                         = &h100&
                %SQL_FN_TD_CURTIME                      = &h200&
                %SQL_FN_TD_HOUR                         = &h400&
                %SQL_FN_TD_MINUTE                       = &h800&
                %SQL_FN_TD_SECOND                       = &h1000&
                %SQL_FN_TD_TIMESTAMPADD                 = &h2000&
                %SQL_FN_TD_TIMESTAMPDIFF                = &h4000&
                %SQL_FN_TD_DAYNAME                      = &h8000&
                %SQL_FN_TD_MONTHNAME                    = &h10000&
                %SQL_FN_TD_CURRENT_DATE                 = &h20000&
                %SQL_FN_TD_CURRENT_TIME                 = &h40000&
                %SQL_FN_TD_CURRENT_TIMESTAMP            = &h80000&
                %SQL_FN_TD_EXTRACT                      = &h100000&

        %DB_CONVERT_BIGINT                                                      = 53
        %DB_CONVERT_BINARY                                                      = 54
        %DB_CONVERT_BIT                                                         = 55
        %DB_CONVERT_CHAR                                                        = 56
        %DB_CONVERT_DATE                                                        = 57
        %DB_CONVERT_DECIMAL                                                     = 58
        %DB_CONVERT_DOUBLE                                                      = 59
        %DB_CONVERT_FLOAT                                                       = 60
        %DB_CONVERT_INTEGER                                                     = 61
        %DB_CONVERT_LONGVARCHAR                                                 = 62
        %DB_CONVERT_NUMERIC                                                     = 63
        %DB_CONVERT_REAL                                                        = 64
        %DB_CONVERT_SMALLINT                                                    = 65
        %DB_CONVERT_TIME                                                        = 66
        %DB_CONVERT_TIMESTAMP                                                   = 67
        %DB_CONVERT_TINYINT                                                     = 68
        %DB_CONVERT_VARBINARY                                                   = 69
        %DB_CONVERT_VARCHAR                                                     = 70

        %DB_CONVERT_LONGVARBINARY                                               = 71
                %SQL_CVT_CHAR                           = &h1&
                %SQL_CVT_NUMERIC                        = &h2&
                %SQL_CVT_DECIMAL                        = &h4&
                %SQL_CVT_INTEGER                        = &h8&
                %SQL_CVT_SMALLINT                       = &h10&
                %SQL_CVT_FLOAT                          = &h20&
                %SQL_CVT_REAL                           = &h40&
                %SQL_CVT_DOUBLE                         = &h80&
                %SQL_CVT_VARCHAR                        = &h100&
                %SQL_CVT_LONGVARCHAR                    = &h200&
                %SQL_CVT_BINARY                         = &h400&
                %SQL_CVT_VARBINARY                      = &h800&
                %SQL_CVT_BIT                            = &h1000&
                %SQL_CVT_TINYINT                        = &h2000&
                %SQL_CVT_BIGINT                         = &h4000&
                %SQL_CVT_DATE                           = &h8000&
                %SQL_CVT_TIME                           = &h10000&
                %SQL_CVT_TIMESTAMP                      = &h20000&
                %SQL_CVT_LONGVARBINARY                  = &h40000&
                %SQL_CVT_INTERVAL_YEAR_MONTH            = &h80000&
                %SQL_CVT_INTERVAL_DAY_TIME              = &h100000&
                %SQL_CVT_WCHAR                          = &h200000&
                %SQL_CVT_WLONGVARCHAR                   = &h400000&
                %SQL_CVT_WVARCHAR                       = &h800000&

        %DB_TXN_ISOLATION_OPTION                                                = 72
        %DB_ODBC_SQL_OPT_IEF                                                    = 73    '2.00 terminology
        %DB_INTEGRITY                                                           = 73    '3.00 terminology

        %DB_CORRELATION_NAME                                                    = 74
                %SQL_CN_NONE                            = 0
                %SQL_CN_DIFFERENT                       = 1
                %SQL_CN_ANY                             = 2

        %DB_NON_NULLABLE_COLUMNS                                                = 75
                %SQL_NNC_NULL                           = 0
                %SQL_NNC_NON_NULL                       = 1

        %DB_DRIVER_HLIB                                                         = 76
        %DB_DRIVER_ODBC_VER                                                     = 77
        %DB_LOCK_TYPES                                                          = 78    'deprecated in 3.0
        %DB_POS_OPERATIONS                                                      = 79    'deprecated in 3.0
        %DB_POSITIONED_STATEMENTS                                               = 80    'deprecated in 3.0
        %DB_GETDATA_EXTENSIONS                                                  = 81
                %SQL_GD_ANY_COLUMN                      = 1
                %SQL_GD_ANY_ORDER                       = 2
                %SQL_GD_BLOCK                           = 4
                %SQL_GD_BOUND                           = 8

        %DB_BOOKMARK_PERSISTENCE                                                = 82
                %SQL_BP_CLOSE                           = &h1&
                %SQL_BP_DELETE                          = &h2&
                %SQL_BP_DROP                            = &h4&
                %SQL_BP_TRANSACTION                     = &h8&
                %SQL_BP_UPDATE                          = &h10&
                %SQL_BP_OTHER_HSTMT                     = &h20&
                %SQL_BP_SCROLL                          = &h40&

        %DB_STATIC_SENSITIVITY                                                  = 83    'deprecated in 3.0

        %DB_FILE_USAGE                                                          = 84
                %SQL_FILE_NOT_SUPPORTED                 = 0
                %SQL_FILE_TABLE                         = 1
                %SQL_FILE_CATALOG                       = 2

        %DB_NULL_COLLATION                                                      = 85
                %SQL_NC_HIGH                            = 0
                %SQL_NC_LOW                             = 1
                %SQL_NC_START                           = 2
                %SQL_NC_END                             = 4

        %DB_ALTER_TABLE                                                         = 86
                %SQL_AT_ADD_COLUMN                      = &h1&
                %SQL_AT_DROP_COLUMN                     = &h2&
                %SQL_AT_ADD_CONSTRAINT                  = &h8&
                %SQL_AT_ADD_COLUMN_SINGLE               = &h20&
                %SQL_AT_ADD_COLUMN_DEFAULT              = &h40&
                %SQL_AT_ADD_COLUMN_COLLATION            = &h80&
                %SQL_AT_SET_COLUMN_DEFAULT              = &h100&
                %SQL_AT_DROP_COLUMN_DEFAULT             = &h200&
                %SQL_AT_DROP_COLUMN_CASCADE             = &h400&
                %SQL_AT_DROP_COLUMN_RESTRICT            = &h800&
                %SQL_AT_ADD_TABLE_CONSTRAINT            = &h1000&
                %SQL_AT_DROP_TABLE_CONSTRAINT_CASCADE   = &h2000&
                %SQL_AT_DROP_TABLE_CONSTRAINT_RESTRICT  = &h4000&
                %SQL_AT_CONSTRAINT_NAME_DEFINITION      = &h8000&
                %SQL_AT_CONSTRAINT_INITIALLY_DEFERRED   = &h10000&
                %SQL_AT_CONSTRAINT_INITIALLY_IMMEDIATE  = &h20000&
                %SQL_AT_CONSTRAINT_DEFERRABLE           = &h40000&
                %SQL_AT_CONSTRAINT_NON_DEFERRABLE       = &h80000&

        %DB_COLUMN_ALIAS                                                        = 87

        %DB_GROUP_BY                                                            = 88
                %SQL_GB_NOT_SUPPORTED                   = 0
                %SQL_GB_GROUP_BY_EQUALS_SELECT          = 1
                %SQL_GB_GROUP_BY_CONTAINS_SELECT        = 2
                %SQL_GB_NO_RELATION                     = 3
                %SQL_GB_COLLATE                         = 4

        %DB_KEYWORDS                                                            = 89
        %DB_ORDER_BY_COLUMNS_IN_SELECT                                          = 90

        %DB_OWNER_USAGE                                                         = 91    '2.0 terminology
        %DB_SCHEMA_USAGE                                                        = 91    '3.0 terminology
                %SQL_SU_DML_STATEMENTS                  = &h1&
                %SQL_SU_PROCEDURE_INVOCATION            = &h2&
                %SQL_SU_TABLE_DEFINITION                = &h4&
                %SQL_SU_INDEX_DEFINITION                = &h8&
                %SQL_SU_PRIVILEGE_DEFINITION            = &h10&

        %DB_QUALIFIER_USAGE                                                     = 92    '2.0 terminology

        %DB_CATALOG_USAGE                                                       = 92    '3.0 terminology
                %SQL_CU_DML_STATEMENTS                  = &h1&
                %SQL_CU_PROCEDURE_INVOCATION            = &h2&
                %SQL_CU_TABLE_DEFINITION                = &h4&
                %SQL_CU_INDEX_DEFINITION                = &h8&
                %SQL_CU_PRIVILEGE_DEFINITION            = &h10&

        %DB_QUOTED_IDENTIFIER_CASE                                              = 93
                'see %DB_IDENTIFIER_CASE for values

        %DB_SPECIAL_CHARACTERS                                                  = 94

        %DB_SUBQUERIES                                                          = 95
                %SQL_SQ_COMPARISON                      = &h1&
                %SQL_SQ_EXISTS                          = &h2&
                %SQL_SQ_IN                              = &h4&
                %SQL_SQ_QUANTIFIED                      = &h8&
                %SQL_SQ_CORRELATED_SUBQUERIES           = &h10&

        %DB_UNION                                                               = 96
                %SQL_U_UNION                            = 1
                %SQL_U_UNION_ALL                        = 2

        %DB_MAX_COLUMNS_IN_GROUP_BY                                             = 97
        %DB_MAX_COLUMNS_IN_INDEX                                                = 98
        %DB_MAX_COLUMNS_IN_ORDER_BY                                             = 99
        %DB_MAX_COLUMNS_IN_SELECT                                               = 100
        %DB_MAX_COLUMNS_IN_TABLE                                                = 101
        %DB_MAX_INDEX_SIZE                                                      = 102
        %DB_MAX_ROW_SIZE_INCLUDES_LONG                                          = 103
        %DB_MAX_ROW_SIZE                                                        = 104
        %DB_MAX_STATEMENT_LEN                                                   = 105
        %DB_MAX_TABLES_IN_SELECT                                                = 106
        %DB_MAX_USER_NAME_LEN                                                   = 107
        %DB_MAX_CHAR_LITERAL_LEN                                                = 108

        %DB_TIMEDATE_ADD_INTERVALS                                              = 109
        %DB_TIMEDATE_DIFF_INTERVALS                                             = 110
                %SQL_FN_TSI_FRAC_SECOND                 = &h1&
                %SQL_FN_TSI_SECOND                      = &h2&
                %SQL_FN_TSI_MINUTE                      = &h4&
                %SQL_FN_TSI_HOUR                        = &h8&
                %SQL_FN_TSI_DAY                         = &h10&
                %SQL_FN_TSI_WEEK                        = &h20&
                %SQL_FN_TSI_MONTH                       = &h40&
                %SQL_FN_TSI_QUARTER                     = &h80&
                %SQL_FN_TSI_YEAR                        = &h100&

        %DB_NEED_LONG_DATA_LEN                                                  = 111
        %DB_MAX_BINARY_LITERAL_LEN                                              = 112
        %DB_LIKE_ESCAPE_CLAUSE                                                  = 113
        %DB_QUALIFIER_LOCATION                                                  = 114   '2.0 terminology

        %DB_CATALOG_LOCATION                                                    = 114   '3.0 terminology
                %SQL_CL_START                           = 1
                %SQL_CL_END                             = 2

        %DB_INFO_LAST                                                           = 114   'ODBC 2.x *ONLY*; not "LAST" if ODBC version 3.0
        %DB_INFO_LAST_ODBC2                                                     = 114   'A more accurate name for SQL_INFO_LAST.

        '--------------------------------------------------------

        %DB_UNIDENTIFIED_115                                                    = 115   'ODBC 3.0
        %DB_ACTIVE_ENVIRONMENTS                                                 = 116   'ODBC 3.0

        %DB_ALTER_DOMAIN                                                        = 117   'ODBC 3.0
                %SQL_AD_CONSTRAINT_NAME_DEFINITION      = &h1&
                %SQL_AD_ADD_DOMAIN_CONSTRAINT           = &h2&
                %SQL_AD_DROP_DOMAIN_CONSTRAINT          = &h4&
                %SQL_AD_ADD_DOMAIN_DEFAULT              = &h8&
                %SQL_AD_DROP_DOMAIN_DEFAULT             = &h10&
                %SQL_AD_ADD_CONSTRAINT_INITIALLY_DEFERRED= &h20&
                %SQL_AD_ADD_CONSTRAINT_INITIALLY_IMMEDIATE= &h40&
                %SQL_AD_ADD_CONSTRAINT_DEFERRABLE       = &h80&
                %SQL_AD_ADD_CONSTRAINT_NON_DEFERRABLE   = &h100&

        %DB_SQL_CONFORMANCE                                                     = 118   'ODBC 3.0
                %SQL_SC_SQL92_ENTRY                     = 1
                %SQL_SC_FIPS127_2_TRANSITIONAL          = 2
                %SQL_SC_SQL92_INTERMEDIATE              = 4
                %SQL_SC_SQL92_FULL                      = 8

        %DB_DATETIME_LITERALS                                                   = 119   'ODBC 3.0
                %SQL_DL_SQL92_DATE                      = &h1&
                %SQL_DL_SQL92_TIME                      = &h2&
                %SQL_DL_SQL92_TIMESTAMP                 = &h4&
                %SQL_DL_SQL92_INTERVAL_YEAR             = &h8&
                %SQL_DL_SQL92_INTERVAL_MONTH            = &h10&
                %SQL_DL_SQL92_INTERVAL_DAY              = &h20&
                %SQL_DL_SQL92_INTERVAL_HOUR             = &h40&
                %SQL_DL_SQL92_INTERVAL_MINUTE           = &h80&
                %SQL_DL_SQL92_INTERVAL_SECOND           = &h100&
                %SQL_DL_SQL92_INTERVAL_YEAR_TO_MONTH    = &h200&
                %SQL_DL_SQL92_INTERVAL_DAY_TO_HOUR      = &h400&
                %SQL_DL_SQL92_INTERVAL_DAY_TO_MINUTE    = &h800&
                %SQL_DL_SQL92_INTERVAL_DAY_TO_SECOND    = &h1000&
                %SQL_DL_SQL92_INTERVAL_HOUR_TO_MINUTE   = &h2000&
                %SQL_DL_SQL92_INTERVAL_HOUR_TO_SECOND   = &h4000&
                %SQL_DL_SQL92_INTERVAL_MINUTE_TO_SECOND = &h8000&

        %DB_BATCH_ROW_COUNT                                                     = 120   'ODBC 3.0
                %SQL_BRC_PROCEDURES                     = 1
                %SQL_BRC_EXPLICIT                       = 2
                %SQL_BRC_ROLLED_UP                      = 4

        %DB_BATCH_SUPPORT                                                       = 121   'ODBC 3.0
                %SQL_BS_SELECT_EXPLICIT                 = 1
                %SQL_BS_ROW_COUNT_EXPLICIT              = 2
                %SQL_BS_SELECT_PROC                     = 4
                %SQL_BS_ROW_COUNT_PROC                  = 8

        %DB_CONVERT_WCHAR                                                       = 122   'ODBC 3.0

        %DB_CONVERT_INTERVAL_DAY_TIME                                           = 123   'ODBC 3.0

        %DB_CONVERT_INTERVAL_YEAR_MONTH                                         = 124   'ODBC 3.0

        %DB_CONVERT_WLONGVARCHAR                                                = 125   'ODBC 3.0

        %DB_CONVERT_WVARCHAR                                                    = 126   'ODBC 3.0

        %DB_CREATE_ASSERTION                                                    = 127   'ODBC 3.0
                %SQL_CA_CREATE_ASSERTION                = &h1&
                %SQL_CA_CONSTRAINT_INITIALLY_DEFERRED   = &h10&
                %SQL_CA_CONSTRAINT_INITIALLY_IMMEDIATE  = &h20&
                %SQL_CA_CONSTRAINT_DEFERRABLE           = &h40&
                %SQL_CA_CONSTRAINT_NON_DEFERRABLE       = &h80&

        %DB_CREATE_CHARACTER_SET                                                = 128   'ODBC 3.0
                %SQL_CCS_CREATE_CHARACTER_SET           = &h1&
                %SQL_CCS_COLLATE_CLAUSE                 = &h2&
                %SQL_CCS_LIMITED_COLLATION              = &h4&

        %DB_CREATE_COLLATION                                                    = 129   'ODBC 3.0
                %SQL_CCOL_CREATE_COLLATION              = &h1&

        %DB_CREATE_DOMAIN                                                       = 130   'ODBC 3.0
                %SQL_CDO_CREATE_DOMAIN                   = &h1&
                %SQL_CDO_DEFAULT                         = &h2&
                %SQL_CDO_CONSTRAINT                      = &h4&
                %SQL_CDO_COLLATION                       = &h8&
                %SQL_CDO_CONSTRAINT_NAME_DEFINITION      = &h10&
                %SQL_CDO_CONSTRAINT_INITIALLY_DEFERRED   = &h20&
                %SQL_CDO_CONSTRAINT_INITIALLY_IMMEDIATE  = &h40&
                %SQL_CDO_CONSTRAINT_DEFERRABLE           = &h80&
                %SQL_CDO_CONSTRAINT_NON_DEFERRABLE       = &h100&

        %DB_CREATE_SCHEMA                                                       = 131   'ODBC 3.0
                %SQL_CS_CREATE_SCHEMA                   = &h1&
                %SQL_CS_AUTHORIZATION                   = &h2&
                %SQL_CS_DEFAULT_CHARACTER_SET           = &h4&

        %DB_CREATE_TABLE                                                        = 132   'ODBC 3.0
                %SQL_CT_CREATE_TABLE                    = &h1&
                %SQL_CT_COMMIT_PRESERVE                 = &h2&
                %SQL_CT_COMMIT_DELETE                   = &h4&
                %SQL_CT_GLOBAL_TEMPORARY                = &h8&
                %SQL_CT_LOCAL_TEMPORARY                 = &h10&
                %SQL_CT_CONSTRAINT_INITIALLY_DEFERRED   = &h20&
                %SQL_CT_CONSTRAINT_INITIALLY_IMMEDIATE  = &h40&
                %SQL_CT_CONSTRAINT_DEFERRABLE           = &h80&
                %SQL_CT_CONSTRAINT_NON_DEFERRABLE       = &h100&
                %SQL_CT_COLUMN_CONSTRAINT               = &h200&
                %SQL_CT_COLUMN_DEFAULT                  = &h400&
                %SQL_CT_COLUMN_COLLATION                = &h800&
                %SQL_CT_TABLE_CONSTRAINT                = &h1000&
                %SQL_CT_CONSTRAINT_NAME_DEFINITION      = &h2000&

        %DB_CREATE_TRANSLATION                                                  = 133   'ODBC 3.0
                %SQL_CTR_CREATE_TRANSLATION             = &h1&

        %DB_CREATE_VIEW                                                         = 134   'ODBC 3.0
                %SQL_CV_CREATE_VIEW                     = &h1&
                %SQL_CV_CHECK_OPTION                    = &h2&
                %SQL_CV_CASCADED                        = &h4&
                %SQL_CV_LOCAL                           = &h8&

        %DB_DROP_ASSERTION                                                      = 136   'ODBC 3.0
                %SQL_DA_DROP_ASSERTION                  = 1

        %DB_DROP_CHARACTER_SET                                                  = 137   'ODBC 3.0
                %SQL_DCS_DROP_CHARACTER_SET             = 1

        %DB_DROP_COLLATION                                                      = 138   'ODBC 3.0
                %SQL_DC_DROP_COLLATION                  = 1

        %DB_DROP_DOMAIN                                                         = 139   'ODBC 3.0
                %SQL_DD_DROP_DOMAIN                     = &h1&
                %SQL_DD_RESTRICT                        = &h2&
                %SQL_DD_CASCADE                         = &h4&

        %DB_DROP_SCHEMA                                                         = 140   'ODBC 3.0
                %SQL_DS_DROP_SCHEMA                     = &h1&
                %SQL_DS_RESTRICT                        = &h2&
                %SQL_DS_CASCADE                         = &h4&

        %DB_DROP_TABLE                                                          = 141   'ODBC 3.0
                %SQL_DT_DROP_TABLE                      = &h1&
                %SQL_DT_RESTRICT                        = &h2&
                %SQL_DT_CASCADE                         = &h4&

        %DB_DROP_TRANSLATION                                                    = 142   'ODBC 3.0
                %SQL_DTR_DROP_TRANSLATION               = &h1&

        %DB_DROP_VIEW                                                           = 143   'ODBC 3.0
                %SQL_DV_DROP_VIEW                       = &h1&
                %SQL_DV_RESTRICT                        = &h2&
                %SQL_DV_CASCADE                         = &h4&

        %DB_DYNAMIC_CURSOR_ATTRIBUTES1                                          = 144   'ODBC 3.0
                %SQL_CA1_NEXT                           = &h1&
                %SQL_CA1_ABSOLUTE                       = &h2&
                %SQL_CA1_RELATIVE                       = &h4&
                %SQL_CA1_BOOKMARK                       = &h8&
                %SQL_CA1_LOCK_NO_CHANGE                 = &h40&
                %SQL_CA1_LOCK_EXCLUSIVE                 = &h80&
                %SQL_CA1_LOCK_UNLOCK                    = &h100&
                %SQL_CA1_POS_POSITION                   = &h200&
                %SQL_CA1_POS_UPDATE                     = &h400&
                %SQL_CA1_POS_DELETE                     = &h800&
                %SQL_CA1_POS_REFRESH                    = &h1000&
                %SQL_CA1_POSITIONED_UPDATE              = &h2000&
                %SQL_CA1_POSITIONED_DELETE              = &h4000&
                %SQL_CA1_SELECT_FOR_UPDATE              = &h8000&
                %SQL_CA1_BULK_ADD                       = &h10000&
                %SQL_CA1_BULK_UPDATE_BY_BOOKMARK        = &h20000&
                %SQL_CA1_BULK_DELETE_BY_BOOKMARK        = &h40000&
                %SQL_CA1_BULK_FETCH_BY_BOOKMARK         = &h80000&

        %DB_DYNAMIC_CURSOR_ATTRIBUTES2                                          = 145   'ODBC 3.0
                %SQL_CA2_READ_ONLY_CONCURRENCY          = &h1&
                %SQL_CA2_LOCK_CONCURRENCY               = &h2&
                %SQL_CA2_OPT_ROWVER_CONCURRENCY         = &h4&
                %SQL_CA2_OPT_VALUES_CONCURRENCY         = &h8&
                %SQL_CA2_SENSITIVITY_ADDITIONS          = &h10&
                %SQL_CA2_SENSITIVITY_DELETIONS          = &h20&
                %SQL_CA2_SENSITIVITY_UPDATES            = &h40&
                %SQL_CA2_MAX_ROWS_SELECT                = &h80&
                %SQL_CA2_MAX_ROWS_INSERT                = &h100&
                %SQL_CA2_MAX_ROWS_DELETE                = &h200&
                %SQL_CA2_MAX_ROWS_UPDATE                = &h400&
                %SQL_CA2_MAX_ROWS_CATALOG               = &h800&
                %SQL_CA2_MAX_ROWS_AFFECTS_ALL           = &hF80&
                %SQL_CA2_CRC_EXACT                      = &h1000&
                %SQL_CA2_CRC_APPROXIMATE                = &h2000&
                %SQL_CA2_SIMULATE_NON_UNIQUE            = &h4000&
                %SQL_CA2_SIMULATE_TRY_UNIQUE            = &h8000&
                %SQL_CA2_SIMULATE_UNIQUE                = &h10000&

        %DB_FORWARD_ONLY_CURSOR_ATTRIBUTES1                                     = 146   'ODBC 3.0
        %DB_FORWARD_ONLY_CURSOR_ATTRIBUTES2                                     = 147   'ODBC 3.0
        %DB_INDEX_KEYWORDS                                                      = 148   'ODBC 3.0
                %SQL_IK_NONE                            = &h0&
                %SQL_IK_ASC                             = &h1&
                %SQL_IK_DESC                            = &h2&
                %SQL_IK_ALL                             = &h3&

        %DB_INFO_SCHEMA_VIEWS                                                   = 149   'ODBC 3.0
                %SQL_ISV_ASSERTIONS                     = &h1&
                %SQL_ISV_CHARACTER_SETS                 = &h2&
                %SQL_ISV_CHECK_CONSTRAINTS              = &h4&
                %SQL_ISV_COLLATIONS                     = &h8&
                %SQL_ISV_COLUMN_DOMAIN_USAGE            = &h10&
                %SQL_ISV_COLUMN_PRIVILEGES              = &h20&
                %SQL_ISV_COLUMNS                        = &h40&
                %SQL_ISV_CONSTRAINT_COLUMN_USAGE        = &h80&
                %SQL_ISV_CONSTRAINT_TABLE_USAGE         = &h100&
                %SQL_ISV_DOMAIN_CONSTRAINTS             = &h200&
                %SQL_ISV_DOMAINS                        = &h400&
                %SQL_ISV_KEY_COLUMN_USAGE               = &h800&
                %SQL_ISV_REFERENTIAL_CONSTRAINTS        = &h1000&
                %SQL_ISV_SCHEMATA                       = &h2000&
                %SQL_ISV_SQL_LANGUAGES                  = &h4000&
                %SQL_ISV_TABLE_CONSTRAINTS              = &h8000&
                %SQL_ISV_TABLE_PRIVILEGES               = &h10000&
                %SQL_ISV_TABLES                         = &h20000&
                %SQL_ISV_TRANSLATIONS                   = &h40000&
                %SQL_ISV_USAGE_PRIVILEGES               = &h80000&
                %SQL_ISV_VIEW_COLUMN_USAGE              = &h100000&
                %SQL_ISV_VIEW_TABLE_USAGE               = &h200000&
                %SQL_ISV_VIEWS                          = &h400000&

        %DB_KEYSET_CURSOR_ATTRIBUTES1                                           = 150   'ODBC 3.0
        %DB_KEYSET_CURSOR_ATTRIBUTES2                                           = 151   'ODBC 3.0

        %DB_ODBC_INTERFACE_CONFORMANCE                                          = 152   'ODBC 3.0
                %SQL_OIC_CORE                           = 1
                %SQL_OIC_LEVEL1                         = 2
                %SQL_OIC_LEVEL2                         = 3

        %DB_PARAM_ARRAY_ROW_COUNTS                                              = 153   'ODBC 3.0
                %SQL_PARC_BATCH                         = 1
                %SQL_PARC_NO_BATCH                      = 2

        %DB_PARAM_ARRAY_SELECTS                                                 = 154   'ODBC 3.0
                %SQL_PAS_BATCH                          = 1
                %SQL_PAS_NO_BATCH                       = 2
                %SQL_PAS_NO_SELECT                      = 3

        %DB_SQL92_DATETIME_FUNCTIONS                                            = 155   'ODBC 3.0
                %SQL_SDF_CURRENT_DATE                   = &h1&
                %SQL_SDF_CURRENT_TIME                   = &h2&
                %SQL_SDF_CURRENT_TIMESTAMP              = &h4&

        %DB_SQL92_FOREIGN_KEY_DELETE_RULE                                       = 156   'ODBC 3.0
                %SQL_SFKD_CASCADE                       = &h1&
                %SQL_SFKD_NO_ACTION                     = &h2&
                %SQL_SFKD_SET_DEFAULT                   = &h4&
                %SQL_SFKD_SET_NULL                      = &h8&

        %DB_SQL92_FOREIGN_KEY_UPDATE_RULE                                       = 157   'ODBC 3.0
                %SQL_SFKU_CASCADE                       = &h1&
                %SQL_SFKU_NO_ACTION                     = &h2&
                %SQL_SFKU_SET_DEFAULT                   = &h4&
                %SQL_SFKU_SET_NULL                      = &h8&

        %DB_SQL92_GRANT                                                         = 158   'ODBC 3.0
                %SQL_SG_USAGE_ON_DOMAIN                 = &h1&
                %SQL_SG_USAGE_ON_CHARACTER_SET          = &h2&
                %SQL_SG_USAGE_ON_COLLATION              = &h4&
                %SQL_SG_USAGE_ON_TRANSLATION            = &h8&
                %SQL_SG_WITH_GRANT_OPTION               = &h10&
                %SQL_SG_DELETE_TABLE                    = &h20&
                %SQL_SG_INSERT_TABLE                    = &h40&
                %SQL_SG_INSERT_COLUMN                   = &h80&
                %SQL_SG_REFERENCES_TABLE                = &h100&
                %SQL_SG_REFERENCES_COLUMN               = &h200&
                %SQL_SG_SELECT_TABLE                    = &h400&
                %SQL_SG_UPDATE_TABLE                    = &h800&
                %SQL_SG_UPDATE_COLUMN                   = &h1000&

        %DB_SQL92_NUMERIC_VALUE_FUNCTIONS                                       = 159   'ODBC 3.0
                %SQL_SNVF_BIT_LENGTH                    = &h1&
                %SQL_SNVF_CHAR_LENGTH                   = &h2&
                %SQL_SNVF_CHARACTER_LENGTH              = &h4&
                %SQL_SNVF_EXTRACT                       = &h8&
                %SQL_SNVF_OCTET_LENGTH                  = &h10&
                %SQL_SNVF_POSITION                      = &h20&

        %DB_SQL92_PREDICATES                                                    = 160   'ODBC 3.0
                %SQL_SP_EXISTS                          = &h1&
                %SQL_SP_ISNOTNULL                       = &h2&
                %SQL_SP_ISNULL                          = &h4&
                %SQL_SP_MATCH_FULL                      = &h8&
                %SQL_SP_MATCH_PARTIAL                   = &h10&
                %SQL_SP_MATCH_UNIQUE_FULL               = &h20&
                %SQL_SP_MATCH_UNIQUE_PARTIAL            = &h40&
                %SQL_SP_OVERLAPS                        = &h80&
                %SQL_SP_UNIQUE                          = &h100&
                %SQL_SP_LIKE                            = &h200&
                %SQL_SP_IN                              = &h400&
                %SQL_SP_BETWEEN                         = &h800&
                %SQL_SP_COMPARISON                      = &h1000&
                %SQL_SP_QUANTIFIED_COMPARISON           = &h2000&

        %DB_SQL92_RELATIONAL_JOIN_OPERATORS                                     = 161   'ODBC 3.0
                %SQL_SRJO_CORRESPONDING_CLAUSE          = &h1&
                %SQL_SRJO_CROSS_JOIN                    = &h2&
                %SQL_SRJO_EXCEPT_JOIN                   = &h4&
                %SQL_SRJO_FULL_OUTER_JOIN               = &h8&
                %SQL_SRJO_INNER_JOIN                    = &h10&
                %SQL_SRJO_INTERSECT_JOIN                = &h20&
                %SQL_SRJO_LEFT_OUTER_JOIN               = &h40&
                %SQL_SRJO_NATURAL_JOIN                  = &h80&
                %SQL_SRJO_RIGHT_OUTER_JOIN              = &h100&
                %SQL_SRJO_UNION_JOIN                    = &h200&

        %DB_SQL92_REVOKE                                                        = 162   'ODBC 3.0
                %SQL_SR_USAGE_ON_DOMAIN                 = &h1&
                %SQL_SR_USAGE_ON_CHARACTER_SET          = &h2&
                %SQL_SR_USAGE_ON_COLLATION              = &h4&
                %SQL_SR_USAGE_ON_TRANSLATION            = &h8&
                %SQL_SR_GRANT_OPTION_FOR                = &h10&
                %SQL_SR_CASCADE                         = &h20&
                %SQL_SR_RESTRICT                        = &h40&
                %SQL_SR_DELETE_TABLE                    = &h80&
                %SQL_SR_INSERT_TABLE                    = &h100&
                %SQL_SR_INSERT_COLUMN                   = &h200&
                %SQL_SR_REFERENCES_TABLE                = &h400&
                %SQL_SR_REFERENCES_COLUMN               = &h800&
                %SQL_SR_SELECT_TABLE                    = &h1000&
                %SQL_SR_UPDATE_TABLE                    = &h2000&
                %SQL_SR_UPDATE_COLUMN                   = &h4000&

        %DB_SQL92_ROW_VALUE_CONSTRUCTOR                                         = 163   'ODBC 3.0
                %SQL_SRVC_VALUE_EXPRESSION              = &h1&
                %SQL_SRVC_NULL                          = &h2&
                %SQL_SRVC_DEFAULT                       = &h4&
                %SQL_SRVC_ROW_SUBQUERY                  = &h8&

        %DB_SQL92_STRING_FUNCTIONS                                              = 164   'ODBC 3.0
                %SQL_SSF_CONVERT                        = &h1&
                %SQL_SSF_LOWER                          = &h2&
                %SQL_SSF_UPPER                          = &h4&
                %SQL_SSF_SUBSTRING                      = &h8&
                %SQL_SSF_TRANSLATE                      = &h10&
                %SQL_SSF_TRIM_BOTH                      = &h20&
                %SQL_SSF_TRIM_LEADING                   = &h40&
                %SQL_SSF_TRIM_TRAILING                  = &h80&

        %DB_SQL92_VALUE_EXPRESSIONS                                             = 165   'ODBC 3.0
                %SQL_SVE_CASE                           = &h1&
                %SQL_SVE_CAST                           = &h2&
                %SQL_SVE_COALESCE                       = &h4&
                %SQL_SVE_NULLIF                         = &h8&

        %DB_STANDARD_CLI_CONFORMANCE                                            = 166   'ODBC 3.0
                %SQL_SCC_XOPEN_CLI_VERSION1             = &h1&
                %SQL_SCC_ISO92_CLI                      = &h2&

        %DB_STATIC_CURSOR_ATTRIBUTES1                                           = 167   'ODBC 3.0
        %DB_STATIC_CURSOR_ATTRIBUTES2                                           = 168   'ODBC 3.0

        %DB_AGGREGATE_FUNCTIONS                                                 = 169   'ODBC 3.0
                %SQL_AF_AVG                             = &h1&
                %SQL_AF_COUNT                           = &h2&
                %SQL_AF_MAX                             = &h4&
                %SQL_AF_MIN                             = &h8&
                %SQL_AF_SUM                             = &h10&
                %SQL_AF_DISTINCT                        = &h20&
                %SQL_AF_ALL                             = &h3F&

        %DB_DDL_INDEX                                                           = 170   'ODBC 3.0
                %SQL_DI_CREATE_INDEX                    = &h1&
                %SQL_DI_DROP_INDEX                      = &h2&

        %DB_DM_VER                                                              = 171   'ODBC 3.0

        %DB_INSERT_STATEMENT                                                    = 172   'ODBC 3.0
                %SQL_IS_INSERT_LITERALS                 = &h1
                %SQL_IS_INSERT_SEARCHED                 = &h2
                %SQL_IS_SELECT_INTO                     = &h4

        %DB_INFO_DRIVER_START                                                   = 1000  'ODBC 2.x *ONLY*

        %DB_XOPEN_CLI_YEAR                                                      = 10000

        %DB_CURSOR_SENSITIVITY                                                  = 10001
                %SQL_UNSPECIFIED                        = &h0&
                %SQL_INSENSITIVE                        = &h1&
                %SQL_SENSITIVE                          = &h2&

        %DB_DESCRIBE_PARAMETER                                                  = 10002
        %DB_CATALOG_NAME                                                        = 10003
        %DB_COLLATION_SEQ                                                       = 10004
        %DB_MAX_IDENTIFIER_LEN                                                  = 10005
        %DB_ASYNC_MODE                                                          = 10021 'new X/Open spec
        %DB_MAX_ASYNC_CONCURRENT_STATEMENTS                                     = 10022 'new X/Open spec
        %DB_OJ_CAPABILITIES                                                     = 65003 'ODBC 2.x *ONLY*


        'Statement Info

        %STMT_SUBMITTED                                                         = 1
        %STMT_TRANSLATED                                                        = 2

        'AutoColumn Info

        %AUTOCOL_NAME                                                           = 2
        %AUTOCOL_DATA_TYPE                                                      = 3
        %AUTOCOL_TYPE_NAME                                                      = 4
        %AUTOCOL_SIZE                                                           = 5
        %AUTOCOL_BUFFER_LENGTH                                                  = 6
        %AUTOCOL_DECIMAL_DIGITS                                                 = 7

        %AUTOCOL_PSEUDO_COLUMN                                                  = 8
                %SQL_PC_UNKNOWN                         = &h0&
                %SQL_PC_NOT_PSEUDO                      = &h1&
                %SQL_PC_PSEUDO                          = &h2&

        '------------------------------
        'Table Privilege Info

        %TBLPRIV_TABLE_CATALOG                                                  = 1
        %TBLPRIV_TABLE_SCHEMA                                                   = 2
        %TBLPRIV_TABLE_NAME                                                     = 3
        %TBLPRIV_GRANTOR                                                        = 4
        %TBLPRIV_GRANTEE                                                        = 5
        %TBLPRIV_PRIVILEGE                                                      = 6
        %TBLPRIV_IS_GRANTABLE                                                   = 7

        '------------------------------

        'Column Privilege Info

        %COLPRIV_TABLE_CATALOG                                                  = 1
        %COLPRIV_TABLE_SCHEMA                                                   = 2
        %COLPRIV_TABLE_NAME                                                     = 3
        %COLPRIV_COLUMN_NAME                                                    = 4
        %COLPRIV_GRANTOR                                                        = 5
        %COLPRIV_GRANTEE                                                        = 6
        %COLPRIV_PRIVILEGE                                                      = 7
        %COLPRIV_IS_GRANTABLE                                                   = 8

        '------------------------------
        'Primary Keys and Foreign Keys:

        %PKEY_TABLE_CATALOG                                                     = 1
        %PKEY_TABLE_SCHEMA                                                      = 2
        %PKEY_TABLE_NAME                                                        = 3
        %PKEY_COLUMN_NAME                                                       = 4
        %PKEY_SEQ                                                               = 5

        %FKEY_TABLE_CATALOG                                                     = 5
        %FKEY_TABLE_SCHEMA                                                      = 6
        %FKEY_TABLE_NAME                                                        = 7
        %FKEY_COLUMN_NAME                                                       = 8
        %FKEY_SEQ                                                               = 9

        %FKEY_UPDATE_RULE                                                       = 10
        %FKEY_DELETE_RULE                                                       = 11
                %SQL_CASCADE                                    = 0
                %SQL_NO_ACTION                                  = 3
                %SQL_SET_NULL                                   = 2
                %SQL_SET_DEFAULT                                = 4

        %FKEY_NAME                                                              = 12
        %PKEY_NAME                                                              = 13

        %FKEY_DEFERRABILITY                                                     = 14
                %SQL_INITIALLY_DEFERRED                         = 5
                %SQL_INITIALLY_IMMEDIATE                        = 6
                %SQL_NOT_DEFERRABLE                             = 7

        'Index Info

        %INDEX_CATALOG                                                          = 1
        %INDEX_SCHEMA                                                           = 2
        %INDEX_TABLE                                                            = 3
        %INDEX_NON_UNIQUE                                                       = 4
        %INDEX_QUALIFIER                                                        = 5
        %INDEX_NAME                                                             = 6

        %INDEX_TYPE                                                             = 7

                %SQL_INDEX_CLUSTERED                            = 1
                %SQL_INDEX_HASHED                               = 2
                %SQL_INDEX_OTHER                                = 3
                '%SQL_INDEX_BTREE                               = ?
                '%SQL_INDEX_CONTENT                             = ?

        %INDEX_ORDINAL_POSITION                                                 = 8
        %INDEX_COLUMN_NAME                                                      = 9
        %INDEX_ASC_OR_DESC                                                      = 10
        %INDEX_ROWCOUNT                                                         = 11
        %INDEX_PAGECOUNT                                                        = 12
        %INDEX_FILTER_CONDITION                                                 = 13


        'Table Statistics

        %TBLSTAT_ROWCOUNT                                                       = 11
        %TBLSTAT_PAGECOUNT                                                      = 12


        'Unique Columns:

        %UNIQCOL_SCOPE                                                          = 1
                %SQL_SCOPE_CURROW                               = 0
                %SQL_SCOPE_TRANSACTION                          = 1
                %SQL_SCOPE_SESSION                              = 2

        %UNIQCOL_COLUMN_NAME                                                    = 2
        %UNIQCOL_DATA_TYPE                                                      = 3
        %UNIQCOL_TYPE_NAME                                                      = 4
        %UNIQCOL_COLUMN_SIZE                                                    = 5
        %UNIQCOL_BUFFER_LENGTH                                                  = 6
        %UNIQCOL_DECIMAL_DIGITS                                                 = 7
        %UNIQCOL_PSEUDO_COLUMN                                                  = 8


        %PARAM_DATA_TYPE                                                        = 1
        %PARAM_SIZE                                                             = 2
        %PARAM_DIGITS                                                           = 3
        %PARAM_NULLABLE                                                         = 4

        'SQL Data Types...

        %SQL_UNKNOWN_TYPE               = 0
        '-----------------------------------
        %SQL_CHAR                       = 1
        '-----------------------------------
        %SQL_NUMERIC                    = 2
        '-----------------------------------
        %SQL_DECIMAL                    = 3
        '-----------------------------------
        %SQL_INTEGER                    = 4
        '-----------------------------------
        %SQL_SMALLINT                   = 5
        '-----------------------------------
        %SQL_FLOAT                      = 6
        '-----------------------------------
        %SQL_REAL                       = 7
        '-----------------------------------
        %SQL_DOUBLE                     = 8
        '-----------------------------------
        %SQL_DATE                       = 9
        %SQL_DATETIME                   = 9
        '-----------------------------------
        %SQL_TIME                       = 10
        %SQL_INTERVAL                   = 10
        '-----------------------------------
        %SQL_TIMESTAMP                  = 11
        '-----------------------------------
        %SQL_VARCHAR                    = 12
        '-----------------------------------
        %SQL_TYPE_DATE                  = 91
        %SQL_TYPE_TIME                  = 92
        %SQL_TYPE_TIMESTAMP             = 93
        '-----------------------------------
        %SQL_LONGVARCHAR                = -1
        '-----------------------------------
        %SQL_BINARY                     = -2
        '-----------------------------------
        %SQL_VARBINARY                  = -3
        '-----------------------------------
        %SQL_LONGVARBINARY              = -4
        '-----------------------------------
        %SQL_BIGINT                     = -5
        '-----------------------------------
        %SQL_TINYINT                    = -6
        '-----------------------------------
        %SQL_BIT                        = -7
        '-----------------------------------
        %SQL_WCHAR                      = -8
        '-----------------------------------
        %SQL_WVARCHAR                   = -9
        '-----------------------------------
        %SQL_WLONGVARCHAR               = -10
        '-----------------------------------
        %SQL_GUID                       = -11
        '-----------------------------------
        %ODBC2_INTERVAL_YEAR            = -80
        %ODBC2_INTERVAL_MONTH           = -81
        %ODBC2_INTERVAL_YEAR_TO_MONTH   = -82
        %ODBC2_INTERVAL_DAY             = -83
        %ODBC2_INTERVAL_HOUR            = -84
        %ODBC2_INTERVAL_MINUTE          = -85
        %ODBC2_INTERVAL_SECOND          = -86
        %ODBC2_INTERVAL_DAY_TO_HOUR     = -87
        %ODBC2_INTERVAL_DAY_TO_MINUTE   = -88
        %ODBC2_INTERVAL_DAY_TO_SECOND   = -89
        %ODBC2_INTERVAL_HOUR_TO_MINUTE  = -90
        %ODBC2_INTERVAL_HOUR_TO_SECOND  = -91
        %ODBC2_INTERVAL_MINUTE_TO_SECOND= -92
        '-----------------------------------
        'ODBC 2.0 UNICODE DATA TYPES
        %SQL_UNICODE                    = -95
        %SQL_UNICODE_CHAR               = -95
        %SQL_UNICODE_VARCHAR            = -96
        %SQL_UNICODE_LONGVARCHAR        = -97
        '-----------------------------------
        %ODBC3_INTERVAL_YEAR            = 101
        %ODBC3_INTERVAL_MONTH           = 102
        %ODBC3_INTERVAL_DAY             = 103
        %ODBC3_INTERVAL_HOUR            = 104
        %ODBC3_INTERVAL_MINUTE          = 105
        %ODBC3_INTERVAL_SECOND          = 106
        %ODBC3_INTERVAL_YEAR_TO_MONTH   = 107
        %ODBC3_INTERVAL_DAY_TO_HOUR     = 108
        %ODBC3_INTERVAL_DAY_TO_MINUTE   = 109
        %ODBC3_INTERVAL_DAY_TO_SECOND   = 110
        %ODBC3_INTERVAL_HOUR_TO_MINUTE  = 111
        %ODBC3_INTERVAL_HOUR_TO_SECOND  = 112
        %ODBC3_INTERVAL_MINUTE_TO_SECOND= 113
        '-----------------------------------
        %SQL_CODE_YEAR                  = 1
        %SQL_CODE_MONTH                 = 2
        %SQL_CODE_DAY                   = 3
        %SQL_CODE_HOUR                  = 4
        %SQL_CODE_MINUTE                = 5
        %SQL_CODE_SECOND                = 6
        %SQL_CODE_YEAR_TO_MONTH         = 7
        %SQL_CODE_DAY_TO_HOUR           = 8
        %SQL_CODE_DAY_TO_MINUTE         = 9
        %SQL_CODE_DAY_TO_SECOND         = 10
        %SQL_CODE_HOUR_TO_MINUTE        = 11
        %SQL_CODE_HOUR_TO_SECOND        = 12
        %SQL_CODE_MINUTE_TO_SECOND      = 13

        %SQL_DEFAULT                    = 99

        'BASIC Data Types...

        %BAS_ASCIIZ                     = 1
        %BAS_STRING                     = 1

        %BAS_INTEGER                    = -15   'SIGNED %SQL_SMALLINT
        %BAS_LONG                       = -16   'SIGNED %SQL_INTEGER
        %BAS_WORD                       = -17   'UNSIGNED %SQL_SMALLINT
        %BAS_DWORD                      = -18   'UNSIGNED %SQL_INTEGER
        %BAS_BYTE                       = -28   'UNSIGNED %SQL_TINYINT
        %BAS_SINGLE                     = 7
        %BAS_DOUBLE                     = 8
        %BAS_TIMESTAMP                  = 11

        'To use other data types (QUAD, CURRENCY, User Defined Types,
        'etc.) you should use %BAS_STRING to obtain a binary image of
        'the data.

        %ODBC_ADD_DSN                   = 1
        %ODBC_CONFIG_DSN                = 2
        %ODBC_REMOVE_DSN                = 3
        %ODBC_ADD_SYS_DSN               = 4
        %ODBC_CONFIG_SYS_DSN            = 5
        %ODBC_REMOVE_SYS_DSN            = 6
        %ODBC_REMOVE_DEFAULT_DSN        = 7

        %PART_YEAR      = &h1
        %PART_MONTH     = &h10
        %PART_DAY       = &h1000
        %PART_DOW       = &h2000
        %PART_HOUR      = &h10000
        %PART_MINUTE    = &h100000
        %PART_SECOND    = &h1000000
        %PART_NANOSEC   = &h10000000

        %DOW_SUN        = 1
        %DOW_MON        = 2
        %DOW_TUE        = 3
        %DOW_WED        = 4
        %DOW_THU        = 5
        %DOW_FRI        = 6
        %DOW_SAT        = 7

'=========================================================================== end of SQLT_PRO.INC
