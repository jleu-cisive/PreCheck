








-- =============================================
-- Author:		<Veena Ayyagari>
-- Create date: <11/21/2008>
-- Description:	<To update the table with a success or failure for both CAM and MGR Reviews>
-- =============================================
CREATE PROCEDURE [dbo].[UpdateApplAdjudicationAuditTrial]
	(
@apno int,
@sectionID int,
@module varchar(30),
@Succeded bit,
@UpdateManager bit

)
AS
declare @section int
declare @UserID_Cam varchar(50)
declare @USerID_MGR varchar(50)
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;


		IF(@UpdateManager=0)
		BEGIN
			IF(@Succeded=0)
				UPDATE ApplAdjudicationAuditTrail set notifieddate_CAM=null where apno=@apno and applsectionid=(select applsectionid from applsections where section=@module) and sectionid=@sectionid
			ELSE
				UPDATE ApplAdjudicationAuditTrail set notifieddate_CAM=getdate() where apno=@apno and applsectionid=(select applsectionid from applsections where section=@module)and sectionid=@sectionid
		END
		Else
		BEGIN
			IF(@Succeded=0)
				UPDATE ApplAdjudicationAuditTrail set notifieddate_MGR=null where apno=@apno and applsectionid=(select applsectionid from applsections where section=@module)
			ELSE
				UPDATE ApplAdjudicationAuditTrail set notifieddate_MGR=getdate() where apno=@apno and applsectionid=(select applsectionid from applsections where section=@module)
		END
		
	END












