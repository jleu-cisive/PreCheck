/***************************************************************************
* Created By: Pradip Adhikari
* Created On: 6/23/2022
*****************************************************************************/
-- drop proc Verification_GetAdditionalItems

CREATE procedure [dbo].[Verification_GetAdditionalItems] 
(
	@vendor varchar(30)
)
AS
BEGIN
	SET NOCOUNT ON;  
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
	
	DECLARE @tmpOrders TABLE(	
		EmplID INT, 
		APNO INT,
		ApplicantEmail VARCHAR(155),
		CLNO INT,	
		ClientEmail VARCHAR(155),
		CC_Client VARCHAR(20),
		MaxAttempt VARCHAR(20),
		ClientPriority VARCHAR(20),
		DocumentType VARCHAR(20),
		TALXOrdered VARCHAR(20),
		ClientType VARCHAR(20),
		INDEX IX_tmpOrders_01 CLUSTERED (EmplID)
	)

		
	insert into @tmpOrders
	select  e.EmplID,a.APNO,ISNULL(a.Email,'') as ApplicantEmail, c.CLNO, ISNULL(c.Email,'') AS ClientEmail, '','3','','','',''
	FROM dbo.empl e  WITH (NOLOCK) 
	INNER JOIN dbo.appl a WITH (NOLOCK) ON a.apno = e.apno
	INNER JOIN dbo.client c on c.CLNO = a.CLNO
	WHERE e.sectstat in ('9') and IsNull(web_status,0) = 0 
	and dateordered is null 
	and orderId is null 
	and a.apstatus in ('p','w')
	and e.Investigator =IsNull(@vendor,'REFPRO')
	--and c.affiliateid not in (4, 294)
	and IsNull(e.IsOnReport,0) = 1


	UPDATE tt
	SET tt.CC_Client = cc.Value
	FROM @tmpOrders tt
	INNER JOIN dbo.ClientConfiguration cc ON tt.CLNO = cc.CLNO
	WHERE cc.ConfigurationKey IN ('CC_Client_On_Applicant_Contact')
	
	UPDATE tt
	SET tt.MaxAttempt = cc.Value
	FROM @tmpOrders tt
	INNER JOIN dbo.ClientConfiguration cc ON tt.CLNO = cc.CLNO
	WHERE cc.ConfigurationKey IN ('Max_Attempt')

	UPDATE tt
	SET tt.ClientPriority = cc.Value
	FROM @tmpOrders tt
	INNER JOIN dbo.ClientConfiguration cc ON tt.CLNO = cc.CLNO
	WHERE cc.ConfigurationKey IN ('Priority')

	UPDATE tt
	SET tt.TALXOrdered = CONVERT(VARCHAR(20),t.TALXOrderedDate,105)
	FROM @tmpOrders tt
	INNER JOIN dbo.TALXINFO t  ON tt.APNO = t.APNO

	UPDATE tt
	SET tt.ClientType = CASE WHEN cc.Value = 'True' THEN 'Proof' ELSE '' END
	FROM @tmpOrders tt
	INNER JOIN dbo.ClientConfiguration cc ON tt.CLNO = cc.CLNO
	WHERE cc.ConfigurationKey IN ('ProofClient')



	select * from @tmpOrders t order by t.EmplID

	

END

