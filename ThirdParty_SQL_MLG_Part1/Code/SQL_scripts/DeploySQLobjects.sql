/*
Run this script on:

        (local)\SQLEXPRESS.MLG_Demo    -  This database will be modified

to synchronize it with:

        (local)\SQLEXPRESS.A_YouTubeProjects

You are recommended to back up your database before running this script

Script created by SQL Compare version 14.5.1.18536 from Red Gate Software Ltd at 05/05/2021 20:00:35

*/
SET NUMERIC_ROUNDABORT OFF
GO
SET ANSI_PADDING, ANSI_WARNINGS, CONCAT_NULL_YIELDS_NULL, ARITHABORT, QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
SET XACT_ABORT ON
GO
SET TRANSACTION ISOLATION LEVEL Serializable
GO
BEGIN TRANSACTION
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating [dbo].[CDEF_tbl_TabRef]'
GO
CREATE TABLE [dbo].[CDEF_tbl_TabRef]
(
[idxCDEFTabRef] [int] NOT NULL IDENTITY(1, 1),
[ApplicationID] [int] NULL,
[Form] [int] NULL,
[Grid] [int] NULL,
[TabPos] [int] NULL,
[TabRef] [int] NULL,
[GridPos] [int] NULL,
[ColumnName] [varchar] (50) NULL,
[ResultPos] [int] NULL,
[ResultName] [varchar] (100) NULL,
[ColumnLock] [int] NULL,
[ColumnJustify] [int] NULL,
[ColumnCheckBox] [int] NULL,
[ColumnUserButtonID] [int] NULL,
[ColumnHide] [int] NULL,
[Columnwidth] [int] NULL,
[ColumnColour] [int] NULL,
[ColumnCheckBoxCounterLimit] [int] NULL,
[ColumnDropdown] [int] NULL,
[ColumnDropdownSPR] [varchar] (100) NULL,
[ColumnPrimary] [int] NULL,
[ColumnDateTime] [int] NULL,
[ColumnSupressTime] [int] NULL,
[ColumnNotesField] [int] NULL
)
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating primary key [PK_CDEF_tbl_TabRef] on [dbo].[CDEF_tbl_TabRef]'
GO
ALTER TABLE [dbo].[CDEF_tbl_TabRef] ADD CONSTRAINT [PK_CDEF_tbl_TabRef] PRIMARY KEY CLUSTERED ([idxCDEFTabRef])
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating [dbo].[CDEF_sprAddHiddenColumn]'
GO


CREATE PROCEDURE [dbo].[CDEF_sprAddHiddenColumn]
	-- Add the parameters for the stored procedure here
	(@AppID int,
	 @FormID int,
	 @GridID int,
	 @TabID int,
	 @Column int,
	 @ColumnName varchar(50))
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	insert into [dbo].[CDEF_tbl_TabRef]
	([ApplicationID],[Form],[Grid],[TabRef],[GridPos],[ColumnName],[ResultPos],[ResultName],
     [ColumnLock],[ColumnJustify],[ColumnHide],[Columnwidth])
	 values(@AppID, @FormID, @GridID, @TabID, @Column,@ColumnName,@Column,@ColumnName,
	 1,0,1,100)

END


GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating [dbo].[CDEF_sprCountTabRefs]'
GO


CREATE PROCEDURE [dbo].[CDEF_sprCountTabRefs]
	-- Add the parameters for the stored procedure here
	(@AppID int,
	 @FormID int,
	 @GridID int,
	 @TabID int)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT max(GridPos) as [Total]
    FROM [CDEF_tbl_TabRef]
    where ApplicationID = @AppID
    and Form = @FormID
	and Grid = @GridID
    and TabRef = @TabID
END

GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating [dbo].[CDEF_tbl_Application]'
GO
CREATE TABLE [dbo].[CDEF_tbl_Application]
(
[idxCDEFApplication] [int] NOT NULL IDENTITY(1, 1),
[Application] [varchar] (100) NULL
)
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating primary key [PK_CDEF_tbl_Application] on [dbo].[CDEF_tbl_Application]'
GO
ALTER TABLE [dbo].[CDEF_tbl_Application] ADD CONSTRAINT [PK_CDEF_tbl_Application] PRIMARY KEY CLUSTERED ([idxCDEFApplication])
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating [dbo].[CDEF_sprGetAllApplications]'
GO


CREATE PROCEDURE [dbo].[CDEF_sprGetAllApplications]
	-- Add the parameters for the stored procedure here
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT idxCDEFApplication, [Application]
	from dbo.CDEF_tbl_Application
	order by [Application]
	
END

GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating [dbo].[CDEF_tbl_Forms]'
GO
CREATE TABLE [dbo].[CDEF_tbl_Forms]
(
[idxCDEFform] [int] NOT NULL IDENTITY(1, 1),
[Formname] [varchar] (100) NULL,
[ApplicationID] [int] NULL
)
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating primary key [PK_CDEF_tbl_Forms] on [dbo].[CDEF_tbl_Forms]'
GO
ALTER TABLE [dbo].[CDEF_tbl_Forms] ADD CONSTRAINT [PK_CDEF_tbl_Forms] PRIMARY KEY CLUSTERED ([idxCDEFform])
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating [dbo].[CDEF_sprGetAllFormsInApp]'
GO


CREATE PROCEDURE [dbo].[CDEF_sprGetAllFormsInApp]  
	-- Add the parameters for the stored procedure here
	(@APPID int)
AS	
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	select idxCDEFform, Formname
    from dbo.CDEF_tbl_Forms
    where ApplicationID = @APPID
END

GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating [dbo].[CDEF_tbl_Grids]'
GO
CREATE TABLE [dbo].[CDEF_tbl_Grids]
(
[idxCDEFgrid] [int] NOT NULL IDENTITY(1, 1),
[Gridname] [varchar] (100) NULL,
[FormID] [int] NULL,
[ApplicationID] [int] NULL
)
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating primary key [PK_CDEF_tbl_Grids] on [dbo].[CDEF_tbl_Grids]'
GO
ALTER TABLE [dbo].[CDEF_tbl_Grids] ADD CONSTRAINT [PK_CDEF_tbl_Grids] PRIMARY KEY CLUSTERED ([idxCDEFgrid])
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating [dbo].[CDEF_sprGetAllGridsInForm]'
GO


CREATE PROCEDURE [dbo].[CDEF_sprGetAllGridsInForm]
	-- Add the parameters for the stored procedure here
	(@APPID int, @FormID int)
AS	
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	select idxCDEFgrid, Gridname
    from dbo.CDEF_tbl_Grids
    where ApplicationID = @APPID
    and FormID = @FormID
END

GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating [dbo].[CDEF_tbl_Tabs]'
GO
CREATE TABLE [dbo].[CDEF_tbl_Tabs]
(
[idxCDEFtabs] [int] NOT NULL IDENTITY(1, 1),
[TabName] [varchar] (50) NULL,
[GridID] [int] NULL,
[FormID] [int] NULL,
[ApplicationID] [int] NULL
)
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating primary key [PK_CDEF_tbl_Tabs] on [dbo].[CDEF_tbl_Tabs]'
GO
ALTER TABLE [dbo].[CDEF_tbl_Tabs] ADD CONSTRAINT [PK_CDEF_tbl_Tabs] PRIMARY KEY CLUSTERED ([idxCDEFtabs])
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating [dbo].[CDEF_sprGetAllTabsInGrid]'
GO


CREATE PROCEDURE [dbo].[CDEF_sprGetAllTabsInGrid]
	-- Add the parameters for the stored procedure here
	(@APPID int, @FormID int, @GridID int)
AS	
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	select idxCDEFtabs, Tabname
    from dbo.CDEF_tbl_Tabs
    where ApplicationID = @APPID
    and FormID = @FormID
    and GridID = @GridID
END

GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating [dbo].[CDEF_sprGetApplicationID]'
GO


CREATE PROCEDURE [dbo].[CDEF_sprGetApplicationID]
	-- Add the parameters for the stored procedure here
	(@Application varchar(100))
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	declare @AppID int
    
    select @AppID =  count(*) from [dbo].[CDEF_tbl_Application] where [Application] = @Application

    if @AppID = 0 
      BEGIN
        insert into [dbo].[CDEF_tbl_Application]  ([Application]) values(@Application)
	    select SCOPE_IDENTITY()
      END
    ELSE
      BEGIN
        select [idxCDEFApplication]
        from [dbo].[CDEF_tbl_Application]
        where [Application] = @Application
      END
    END

GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating [dbo].[CDEF_tbl_Colours]'
GO
CREATE TABLE [dbo].[CDEF_tbl_Colours]
(
[idxCDEFColours] [int] NOT NULL IDENTITY(1, 1),
[ColourValue] [int] NULL,
[ColourText] [varchar] (50) NULL
)
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating primary key [PK_CDEF_tbl_Colours] on [dbo].[CDEF_tbl_Colours]'
GO
ALTER TABLE [dbo].[CDEF_tbl_Colours] ADD CONSTRAINT [PK_CDEF_tbl_Colours] PRIMARY KEY CLUSTERED ([idxCDEFColours])
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating [dbo].[CDEF_sprGetColours]'
GO


CREATE PROCEDURE [dbo].[CDEF_sprGetColours]
	-- Add the parameters for the stored procedure here
AS	
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT ColourText
	from dbo.CDEF_tbl_Colours
	order by ColourText
END

GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating [dbo].[CDEF_sprGetFormID]'
GO




CREATE PROCEDURE [dbo].[CDEF_sprGetFormID]
	-- Add the parameters for the stored procedure here
	(@FormName varchar(100),@Application int)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	declare @ID int
    
    select @ID =  count(*) from [dbo].[CDEF_tbl_Forms] 
	where [Formname] = @FormName 
	and [ApplicationID] = @Application

    if @ID = 0 
      BEGIN
        insert into [dbo].[CDEF_tbl_Forms]  
		([ApplicationID], [FormName]) 
		values(@Application,@FormName)
	    select SCOPE_IDENTITY()
      END
    ELSE
      BEGIN
        select [idxCDEFForm]
        from [dbo].[CDEF_tbl_Forms]
        where [Formname] = @FormName 
	    and [ApplicationID] = @Application
      END
    END



GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating [dbo].[CDEF_sprGetGridID]'
GO




CREATE PROCEDURE [dbo].[CDEF_sprGetGridID]
	-- Add the parameters for the stored procedure here
	(@GridName varchar(100),
	 @Application int,
	 @FormID int)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	declare @ID int
    
    select @ID =  count(*) from [dbo].[CDEF_tbl_Grids] 
	where [Gridname] = @GridName 
	and [ApplicationID] = @Application
	and [FormID] = @FormID

    if @ID = 0 
      BEGIN
        insert into [dbo].[CDEF_tbl_Grids]  
		([ApplicationID], [FormID], [GridName]) 
		values(@Application, @FormID, @GridName)
	    select SCOPE_IDENTITY()
      END
    ELSE
      BEGIN
        select [idxCDEFGrid]
        from [dbo].[CDEF_tbl_Grids]
        where [Gridname] = @GridName 
	    and [ApplicationID] = @Application
	    and [FormID] = @FormID
      END
    END


GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating [dbo].[CDEF_tbl_Justify]'
GO
CREATE TABLE [dbo].[CDEF_tbl_Justify]
(
[idxCDEF_Justify] [int] NOT NULL IDENTITY(1, 1),
[JustifyValue] [int] NULL,
[JustifyText] [varchar] (50) NULL
)
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating primary key [PK_CDEF_tbl_Justify] on [dbo].[CDEF_tbl_Justify]'
GO
ALTER TABLE [dbo].[CDEF_tbl_Justify] ADD CONSTRAINT [PK_CDEF_tbl_Justify] PRIMARY KEY CLUSTERED ([idxCDEF_Justify])
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating [dbo].[CDEF_sprGetJustifications]'
GO


CREATE PROCEDURE [dbo].[CDEF_sprGetJustifications] 
	-- Add the parameters for the stored procedure here
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT JustifyText from dbo.CDEF_tbl_Justify
	order by JustifyText
END

GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating [dbo].[CDEF_sprGetTabID]'
GO



CREATE PROCEDURE [dbo].[CDEF_sprGetTabID]
	-- Add the parameters for the stored procedure here
	(@TabName varchar(100),
	 @Application int,
	 @FormID int,
	 @GridID int)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	declare @ID int
    
    select @ID =  count(*) from [dbo].[CDEF_tbl_Tabs] 
	where [Tabname] = @TabName 
	and [ApplicationID] = @Application
	and [FormID] = @FormID
	and [GridID] = @GridID

    if @ID = 0 
      BEGIN
        insert into [dbo].[CDEF_tbl_Tabs]  
		([ApplicationID], [FormID], [GridID], [TabName]) 
		values(@Application, @FormID, @GridID, @TabName)
	    select SCOPE_IDENTITY()
      END
    ELSE
      BEGIN
        select [idxCDEFTabs]
        from [dbo].[CDEF_tbl_Tabs]
        where [Tabname] = @TabName 
	    and [ApplicationID] = @Application
	    and [FormID] = @FormID
	    and [GridID] = @GridID
      END
    END

GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating [dbo].[CDEF_sprGetTabRefs]'
GO



CREATE PROCEDURE [dbo].[CDEF_sprGetTabRefs]
-- Add the parameters for the stored procedure here
(@AppID int, @FormID int, @GridID int, @TabID int)
AS
BEGIN
-- SET NOCOUNT ON added to prevent extra result sets from
-- interfering with SELECT statements.
SET NOCOUNT ON;

-- Insert statements for procedure here
select t.idxCDEFTabRef, t.TabPos,t.GridPos,t.ColumnName,t.ResultName,t.Columnwidth,
t.ColumnHide,c.ColourText as ColumnColour,t.ColumnPrimary,t.ColumnLock,j.JustifyText,t.ColumnCheckBox,
t.ColumnUserButtonID,t.ColumnCheckBoxCounterLimit,t.ColumnDropdown,t.ColumnDropdownSPR,
t.ColumnDateTime,t.ColumnSupressTime, t.ColumnNotesField
from dbo.CDEF_tbl_TabRef t
left join dbo.CDEF_tbl_Justify j
on j.JustifyValue = t.ColumnJustify
left join dbo.CDEF_tbl_Colours c
on c.ColourValue = t.ColumnColour
where t.ApplicationID = @AppID
and t.Form = @FormID
and t.Grid = @GridID
and t.TabRef = @TabID
order by GridPos
END





GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating [dbo].[CDEF_sprGetTabRefsByRef]'
GO



CREATE PROCEDURE [dbo].[CDEF_sprGetTabRefsByRef]
-- Add the parameters for the stored procedure here
(@RefID int)
AS
BEGIN
-- SET NOCOUNT ON added to prevent extra result sets from
-- interfering with SELECT statements.
SET NOCOUNT ON;

-- Insert statements for procedure here
select t.idxCDEFTabRef, t.TabPos,t.GridPos,t.ColumnName,t.ResultName,t.Columnwidth,
t.ColumnHide,c.ColourText as ColumnColour,t.ColumnPrimary,t.ColumnLock,j.JustifyText,t.ColumnCheckBox,
t.ColumnUserButtonID,t.ColumnCheckBoxCounterLimit,t.ColumnDropdown,t.ColumnDropdownSPR,
t.ColumnDateTime,t.ColumnSupressTime, t.ColumnNotesField
from dbo.CDEF_tbl_TabRef t
left join dbo.CDEF_tbl_Justify j
on j.JustifyValue = t.ColumnJustify
left join dbo.CDEF_tbl_Colours c
on c.ColourValue = t.ColumnColour
where t.idxCDEFTabRef = @RefID
order by GridPos
END






GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating [dbo].[CDEF_sprReadAppFormGridDefinitions]'
GO





CREATE PROCEDURE [dbo].[CDEF_sprReadAppFormGridDefinitions]
-- Add the parameters for the stored procedure here
(@Application as varchar(255))
AS
BEGIN
-- SET NOCOUNT ON added to prevent extra result sets from
-- interfering with SELECT statements.
SET NOCOUNT ON;

-- Insert statements for procedure here
select a.Application , f.Formname, g.Gridname, t.TabName,
c.TabPos,c.GridPos,c.ColumnName,c.ResultPos,c.ColumnLock,c.ColumnJustify,
c.ColumnCheckBox, c.ColumnUserButtonID, c.ColumnHide, c.Columnwidth,
c.ColumnColour, c.ColumnCheckBoxCounterLimit, c.ColumnDropdown, c.ColumnDropdownSPR,
c.ResultName, c.ColumnPrimary, isnull(c.ColumnDateTime,'') as [ColumnDateTime],
c.ColumnSupressTime, c.ColumnNotesField
from dbo.CDEF_tbl_Application a
left join dbo.CDEF_tbl_Forms f
on a.idxCDEFApplication = f.ApplicationID
left join dbo.CDEF_tbl_Grids g
on a.idxCDEFApplication = f.ApplicationID
and f.idxCDEFform = g.FormID
left join dbo.CDEF_tbl_Tabs t
on a.idxCDEFApplication = t.ApplicationID
and f.idxCDEFform = t.FormID
and g.idxCDEFgrid = t.GridID
left join dbo.CDEF_tbl_TabRef c
on a.idxCDEFApplication = c.ApplicationID
and f.idxCDEFform = c.Form
and g.idxCDEFgrid = c.Grid
and t.idxCDEFtabs = c.TabRef
where a.Application = @Application
order by f.Formname, g.Gridname, t.TabName,  c.TabPos, c.GridPos
END









GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating [dbo].[CDEF_sprUpdateTabRefs]'
GO





CREATE PROCEDURE [dbo].[CDEF_sprUpdateTabRefs]
-- Add the parameters for the stored procedure here
(@idxCDEFTabRef int,
@TabPos int,
@GridPos int,
@ColumnName varchar(50),
@ResultName varchar(50),
@ColumnWidth int,
@ColumnHide int,
@ColumnColour varchar(50),
@ColumnPrimary int,
@ColumnLock int,
@JustifyText varchar(50),
@ColumnCheckbox int,
@ColumnCheckBoxCounterLimit int,
@ColumnUserButtonID int,
@ColumnDropdown int,
@ColumnDropdownSPR varchar(100),
@ColumnDateTime int,
@ColumnSupressTime int)
AS
BEGIN
-- SET NOCOUNT ON added to prevent extra result sets from
-- interfering with SELECT statements.
SET NOCOUNT ON;

-- Insert statements for procedure here
update dbo.CDEF_tbl_TabRef
set TabPos = @TabPos,
GridPos = @GridPos,
ColumnName = @ColumnName,
ResultName = @ResultName,
Columnwidth = @ColumnWidth,
ColumnHide = @ColumnHide,
ColumnColour =
(Select ColourValue from dbo.CDEF_tbl_Colours where ColourText = @ColumnColour ),
ColumnPrimary = @ColumnPrimary,
ColumnLock = @ColumnLock,
ColumnJustify =
(Select JustifyValue from dbo.CDEF_tbl_Justify where JustifyText = @JustifyText),
ColumnCheckBox = @ColumnCheckbox,
ColumnCheckBoxCounterLimit = @ColumnCheckBoxCounterLimit,
ColumnUserButtonID = @ColumnUserButtonID,
ColumnDropdown = @ColumnDropdown,
ColumnDropdownSPR = @ColumnDropdownSPR,
ColumnDateTime = @ColumnDateTime,
ColumnSupressTime = @ColumnSupressTime
where idxCDEFTabRef = @idxCDEFTabRef

END





GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
COMMIT TRANSACTION
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
-- This statement writes to the SQL Server Log so SQL Monitor can show this deployment.
IF HAS_PERMS_BY_NAME(N'sys.xp_logevent', N'OBJECT', N'EXECUTE') = 1
BEGIN
    DECLARE @databaseName AS nvarchar(2048), @eventMessage AS nvarchar(2048)
    SET @databaseName = REPLACE(REPLACE(DB_NAME(), N'\', N'\\'), N'"', N'\"')
    SET @eventMessage = N'Redgate SQL Compare: { "deployment": { "description": "Redgate SQL Compare deployed to ' + @databaseName + N'", "database": "' + @databaseName + N'" }}'
    EXECUTE sys.xp_logevent 55000, @eventMessage
END
GO
DECLARE @Success AS BIT
SET @Success = 1
SET NOEXEC OFF
IF (@Success = 1) PRINT 'The database update succeeded'
ELSE BEGIN
	IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
	PRINT 'The database update failed'
END
GO
