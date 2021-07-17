USE [MLG_demo]
GO

/****** Object:  StoredProcedure [dbo].[spr_GetUserlist]    Script Date: 17/07/2021 14:42:42 ******/
DROP PROCEDURE [dbo].[spr_GetUserlist]
GO

/****** Object:  StoredProcedure [dbo].[spr_GetUserlist]    Script Date: 17/07/2021 14:42:42 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[spr_GetUserlist]
	-- Add the parameters for the stored procedure here
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT [idxID]
      ,[Active]
      ,[FirstName]
      ,[Surname]
      ,[DOB]
      ,[JobTitle]
      ,[Department]
      ,[Street]
      ,[City]
      ,[Postcode]
      ,[Telephone]
      ,[Email]
      ,[Age]
  FROM [MLG_demo].[dbo].[tbl_UserList]
END
GO


