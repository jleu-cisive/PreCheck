



-- =============================================
-- Author:		Najma Begum
-- Create date: 11/14/2012
-- Description:	Log raw xml response from pembrroke website
-- =============================================
CREATE PROCEDURE [dbo].[OccHealthServices_LogRawResponse]
	-- Add the parameters for the stored procedure here
	@Response text
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	INSERT INTO [dbo].[OccHealthServicesResultsLog]
           ([XMLResponse])
     VALUES
           (@Response);
   
   SELECT CAST(scope_identity() AS int);

    -- Insert statements for procedure here
	
	
END

/*****************************************************************************************************/

/****** Object:  StoredProcedure [dbo].[OccHealthServices_LogResults]    Script Date: 11/19/2012 16:59:21 ******/
SET ANSI_NULLS ON
