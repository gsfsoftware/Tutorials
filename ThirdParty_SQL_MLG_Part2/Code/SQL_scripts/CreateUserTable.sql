USE [MLG_demo]
GO

/****** Object:  Table [dbo].[tbl_UserList]    Script Date: 17/07/2021 14:44:04 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tbl_UserList]') AND type in (N'U'))
DROP TABLE [dbo].[tbl_UserList]
GO

/****** Object:  Table [dbo].[tbl_UserList]    Script Date: 17/07/2021 14:44:04 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[tbl_UserList](
	[idxID] [int] IDENTITY(1,1) NOT NULL,
	[Active] [int] NULL,
	[FirstName] [varchar](100) NULL,
	[Surname] [varchar](100) NULL,
	[DOB] [date] NULL,
	[JobTitle] [varchar](100) NULL,
	[Department] [varchar](100) NULL,
	[Street] [varchar](150) NULL,
	[City] [varchar](100) NULL,
	[Postcode] [varchar](50) NULL,
	[Telephone] [varchar](100) NULL,
	[Email] [varchar](200) NULL,
	[Age] [int] NULL,
 CONSTRAINT [PK_tbl_UserList] PRIMARY KEY CLUSTERED 
(
	[idxID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
