-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[IWS_FindOnlineRelease]
	-- Add the parameters for the stored procedure here
	@APNO int
AS
BEGIN

	DECLARE @social varchar(20),@id int,@clientid int,@apdate datetime;

	
	SELECT @social = ssn, @clientid = clno,@apdate = dateadd(month,2,apdate) from appl where apno = @APNO;

	SET @id = (select top 1 releaseformid from releaseform where ssn = @social and [date]<=@apdate
and (ReleaseForm.clno = @clientid
or ReleaseForm.clno in
(Select clno from ClientHierarchyByService where
 parentclno=(select parentclno from ClientHierarchyByService where clno =@clientid and refHierarchyServiceID=2)
 and refHierarchyServiceID=2))
 order by date desc);

if(@id is not null)
	SELECT pdf from releaseform where releaseformid = @id;

ELSE
	BEGIN
			SET @id = (select top 1 releaseformid from Precheck_MainArchive.dbo.ReleaseForm_Archive R where ssn = @social  and [date]<=@apdate
		and (R.clno = @clientid
		or R.clno in
		(Select clno from ClientHierarchyByService where
			parentclno=(select parentclno from ClientHierarchyByService where clno =@clientid and					 refHierarchyServiceID=2)))
			order by date desc);	

				if(@id is not null)
					SELECT pdf from Precheck_MainArchive.dbo.ReleaseForm_Archive where releaseformid = @id;
				ELSE
					SELECT NULL as pdf;
	END


END
