
-- =============================================
-- Author:		Larry Ouch
-- Create date: 03/01/2022
-- Description:	MA CORI SEARCH Ordering for Specific APNO
--              and also ensure MA county searches are set to unused
-- Modified By: Gaurav Bangia/Dongmei
-- Modify Date: 5/5/2022
-- Modify Purpose: Handled validation to avoid creating duplicate CORI CRIM record
-- =============================================
-- =============================================
CREATE PROCEDURE [dbo].[Create_MA_CORI_Search]
	-- Add the parameters for the stored procedure here
	@APNO INT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @crimid INT;
	Declare @CNTY_NO INT = 3629
	DECLARE @NewLineChar AS CHAR(2) = CHAR(13) + CHAR(10)
	
	-- CRIM CORI MA CRIM RECORD
	IF((SELECT COUNT(*) FROM Crim WITH (NOLOCK) WHERE apno=@APNO AND CNTY_NO=@CNTY_NO)=0)
	begin
		EXEC  Dbo.createcrim  @apno, @CNTY_NO, @crimid OUTPUT
      
		UPDATE Precheck.dbo.Crim  
		SET    CLEAR = 'R' ,Priv_Notes = 'System created CORI search based on configuration' + CASE WHEN Priv_Notes IS NULL THEN '' ELSE ('; ' + Priv_Notes) END  
		WHERE  CrimId = 
		(
			SELECT TOP 1 CrimId 
			FROM Precheck.dbo.Crim   WITH (UPDLOCK) --this makes it thread safe
			WHERE CNTY_NO = @CNTY_NO AND APNO	= @APNO
			ORDER  BY CreatedDate DESC 
		)
	end

END