-- =============================================
-- Author:		Larry Ouch
-- Create date: 03/01/2022
-- Description:	MA CORI SEARCH Ordering for Specific APNO
--              and also ensure MA county searches are set to unused
-- Modify By: Dongmei He
-- Modify Date: 5/5/2022
-- Modify Purpose: Project enhancement for special case handling
	--: Reopen the report if it is closed when CORI is certified
-- =============================================
-- exec [dbo].[Create_MA_CORI_Search] 6257305
CREATE PROCEDURE [dbo].[Create_MA_CORI_Search_New] 
	-- Add the parameters for the stored procedure here
	@APNO INT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @crimid INT;
	Declare @CNTY_NO INT = 3629;
	Declare @Application VARCHAR(20) = 'CORI';
	Declare @ApplTable VARCHAR(20) = 'Appl';
	DECLARE @NewLineChar AS CHAR(2) = CHAR(13) + CHAR(10)
	-- CRIM CORI MA CRIM RECORD
	BEGIN TRY
		IF(NOT EXISTS (SELECT 1 FROM dbo.Crim WHERE APNO=@APNO AND CNTY_NO=@CNTY_NO))
		BEGIN
		    EXEC  Dbo.createcrim  @apno, @CNTY_NO, @crimid OUTPUT
			 			       
			UPDATE dbo.Crim  
			SET    CLEAR = 'R' ,Priv_Notes = 'System created CORI search based on configuration' + CASE WHEN Priv_Notes IS NULL THEN '' ELSE ('; ' + Priv_Notes) END  
			WHERE  CrimId = 
			(
				SELECT TOP 1 CrimId 
				FROM dbo.Crim   WITH (UPDLOCK) --this makes it thread safe
				WHERE CNTY_NO = @CNTY_NO AND APNO	= @APNO
				ORDER  BY CreatedDate DESC 
			)
	        IF(EXISTS (SELECT 1 FROM dbo.Appl WHERE APNO=@APNO AND ApStatus = 'F')) -- reopen the app
		    BEGIN
				UPDATE A
						SET ApStatus = 'P', CompDate = NULL, ReopenDate = GETDATE(),
						Priv_Notes = CONCAT('CORI has been certified [', CURRENT_TIMESTAMP, ']', ' ', @NewLineChar + Priv_Notes)
						FROM dbo.Appl a
						INNER JOIN dbo.CoriCertification CC ON CC.APNO = a.APNO
						WHERE A.apno=@APNO 

				Insert Into dbo.changelog (TableName, ID, OldValue, NewValue, ChangeDate, UserID)
				Select @ApplTable, @Apno, 'F', 'P', GETDATE(), @Application
		
				INSERT INTO [dbo].[Appl_StatusLog]([Apno], [HostName], [login_name], [client_net_address], [ProgramName], [Prev_apstatus], [Curr_apstatus], [ChangeDate])
				SELECT @Apno, null, null, null, @Application, 'F', 'P', GETDATE() -- Not sure if this is ok
		    END
    		ELSE 
			BEGIN
			    UPDATE A
				SET Priv_Notes = CONCAT('CORI has been certified [', CURRENT_TIMESTAMP, ']', ' ', @NewLineChar + Priv_Notes)
				FROM dbo.Appl a
				INNER JOIN dbo.CoriCertification CC ON CC.APNO = a.APNO
				WHERE A.apno=@APNO
			END
     END
	END TRY
	BEGIN CATCH
	END CATCH
END

