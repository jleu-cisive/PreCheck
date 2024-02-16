




-- =============================================
-- Name:		Ddegenaro
-- Create date: 1/3/2011
-- Description:	Returns 0 or 1 based on if a release is found 
--				for the applicant based on SSN, I94 or ClientApplication Number (Unique Client identifier)
-- =============================================
CREATE PROCEDURE [dbo].[Release_GetExistsStatus]
	@CLNO Int,
	@ClientAppNo Varchar(50) = '',
	@SSN varchar(11) = '' 
AS
BEGIN
	declare @releaseExists bit
	declare @releaseFormId int

	set @releaseExists = 0
	set @releaseFormId = 0
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	Select clno into #tmpclients from DBO.ClientHierarchyByService (NoLock)
	where parentclno in (select parentclno from Dbo.ClientHierarchyByService  (NoLock)
													where clno = @CLNO and refHierarchyServiceID=2 )

	set @releaseFormId = (SELECT top 1 ReleaseFormID 	
							FROM   DBO.ReleaseForm (NoLock)
							WHERE  (CLNO = @CLNO OR CLNO in (Select clno From #tmpclients))
							AND    (SSN = Isnull(@SSN,'') OR ClientAppNo = Isnull(@ClientAppNo,'') OR I94 = Isnull(@SSN,''))
							AND    [date] > DateAdd(d,-90,current_timestamp)
							ORDER BY [Date] desc)


	DROP TABLE #tmpclients

	if (@releaseFormId <> 0)
	begin
		set @releaseExists = 1
	end

	select @releaseExists
END





