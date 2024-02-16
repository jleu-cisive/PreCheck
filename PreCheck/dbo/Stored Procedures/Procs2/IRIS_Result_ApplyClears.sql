-- =============================================
-- Author:		Santosh Chapyala
-- Create date: 06/11/2013
-- Description:	Replaced the inline queries with this stored procedure on \\ala-iis-03\c$\Webs\Intranet\iris\Results\Iris_ResultsUpdate.asp
--				to fix the update issue.
-- =============================================
CREATE PROCEDURE DBO.IRIS_Result_ApplyClears
	-- Add the parameters for the stored procedure here
	@CrimID Int,
	@Apno Int,
	@user varchar(20),
	@Inuse varchar(20)
AS
BEGIN

	if (Select count(1) from dbo.appl (nolock) where apno = @Apno and inuse is null)>0
	BEGIN
		update dbo.appl set inuse = @Inuse ,apstatus = 'P' where apno = @Apno and inuse is null

		update dbo.crim set clear = 'T' from dbo.crim c inner join dbo.appl a on a.apno=c.apno where a.inuse = @Inuse and isnull(c.clear,'') <> 'T' and c.crimid = @CrimID

		IF @@ROWCOUNT > 0
		BEGIN
			EXEC dbo.IRIS_ResultLog_Insert @CrimID, @user, 'T'

			EXEC dbo.AppendBlurbToAppl @CrimID			

		END

		update dbo.appl set inuse = null where apno = @Apno and inuse = @Inuse

	END
	
END
