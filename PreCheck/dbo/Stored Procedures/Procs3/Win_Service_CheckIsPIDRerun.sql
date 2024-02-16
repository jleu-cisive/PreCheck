
-- =============================================
-- Author:		Najma Begum	
-- Create date: 03/2013
-- Description:	Check if it is a rerun of PID/Autoorder.
-- =============================================
CREATE PROCEDURE [dbo].[Win_Service_CheckIsPIDRerun] 
	-- Add the parameters for the stored procedure here
	@Apno int, @ReturnValue bit = 0 output
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	IF (EXISTS (SELECT * FROM dbo.ApplCounties WHERE Apno=@Apno))
BEGIN
	Update dbo.ApplCounties set IsActive =  0 where apno = @Apno
	--comment this as this needs to be handled in code - workaround on 07/03/2014;
	--excluding the Client WebOrdered counties as these should always be ordered based on client request
	and SourceID <> 11 --Client WebOrdered 

	SET @ReturnValue = 1;
END	
RETURN @ReturnValue;
END
