-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[IWS_FindOnlineApplicantInfo_test]
	-- Add the parameters for the stored procedure here
	@APNO int=0,@CLNO int = 0,@SSN varchar(20)= ''

AS
BEGIN

	DECLARE @social varchar(20),@id int,@clientid int;

	if(@APNO=0 or @APNO is null)
	begin
	 select top 1 @apno=apno from Appl where clno=@clno and ssn=@ssn order by ApDate desc;
	end
	
if(@apno is not null)
	Begin  
			SELECT @social = ssn, @clientid = clno from appl where apno = @APNO;

			SET @id = (select top 1 releaseformid from releaseform where ssn = @social 
		and (ReleaseForm.clno = @clientid
		or ReleaseForm.clno in
		(Select clno from ClientHierarchyByService where
		 parentclno=(select parentclno from ClientHierarchyByService where clno =@clientid and					 refHierarchyServiceID=2)))
		 order by date desc);	

		  SET @id =( SELECT top 1 releaseformid
							from releaseform where ssn=@social and applicantinfo_pdf is not null);

		if(@id is not null)
		SELECT applicantinfo_pdf as pdf from releaseform where releaseformid = @id;
		ELSE
		SELECT NULL as pdf;

	End
else
      SELECT NULL as pdf;

END