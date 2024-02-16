-- =============================================
-- Author:		Douglas DeGenaro
-- Create date: 05/03/2016
-- Description:	Pulls ApplClientData for BackgroundCheck Saves
-- =============================================

--dbo.Integration_GetBackgroundCheckResult 3323746,null
CREATE PROCEDURE [dbo].[Integration_GetBackgroundCheckResult] 
	-- Add the parameters for the stored procedure here
	@apno int,
	@clientApno varchar(100) = null
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	
	declare @xml xml	


	--Select top 1 @xml = XMLD from dbo.ApplClientData (nolock) where apno = @apno and ClientAPNO = COALESCE(@ClientApno,ClientAPNO) order by CreatedDate desc;	
	Select top 1 @xml = XMLD from dbo.ApplClientData (nolock) where apno = @apno and IsNull(ClientAPNO,'') = IsNull(COALESCE(@ClientApno,ClientApno),'') order by CreatedDate desc;
	
	WITH XMLNAMESPACES ('http://schemas.datacontract.org/2004/07/Precheck.InternalService.Integration.DataContracts' as dc)
	SELECT
		Tab.Col.value('dc:CLNO[1]','int') AS CLNO,
		Tab.Col.value('dc:APNO[1]','varchar(30)') AS APNO,
		Tab.Col.value('dc:BackgroundCheckID[1]','varchar(30)') AS BackgroundCheckID,
		Tab.Col.value('dc:IsOnHold[1]','bit') AS IsOnHold,
		Tab.Col.value('dc:CandidateId[1]','varchar(100)') AS CandidateId,
		Tab.Col.value('dc:ShowSSNDOB[1]','bit') AS ShowSSNDOB,
		Tab.Col.value('dc:SSN[1]','varchar(11)') AS SSN,
		Tab.Col.value('dc:DOB[1]','varchar(11)') AS DOB,
		Tab.Col.value('dc:Error[1]','varchar(1000)') as Error,
		Tab.Col.value('dc:ApStatus[1]','varchar(10)') as ApStatus,
		Tab.Col.value('dc:RequestID[1]','varchar(50)') as RequestID,
		Tab.Col.value('dc:IsDuplicate[1]','bit') as IsDuplicate,
		Tab.Col.value('dc:ReturnURL[1]','varchar(100)') as ReturnURL,
		Tab.Col.value('dc:CandidateName[1]','varchar(1000)') as CandidateName
	FROM   @xml.nodes('/dc:BackgroundCheckResult') Tab(Col)

    -- Insert statements for procedure here
	
END
