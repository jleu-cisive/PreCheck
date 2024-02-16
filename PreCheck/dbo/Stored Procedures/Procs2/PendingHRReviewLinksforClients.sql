-- =============================================
-- Author:		Radhika Dereddy
-- Create date: 10/01/2020
-- Description:	UHS Hr Review Links which are pending
-- EXEC [PendingHRReviewLinksforClients] '09/01/2020', '09/30/2020',13126,177
-- =============================================
CREATE PROCEDURE [dbo].[PendingHRReviewLinksforClients]
	-- Add the parameters for the stored procedure here
@StartDate datetime,
@EndDate datetime,
@ParentCLNO int,
@AffiliateID int

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT [as].LastName, [as].FirstName, [as].MIddleName, [as].ClientCandidateID, [as].CreateDate as 'CIC Invite Date', o.ClientID as 'ParentCLNO', c.Name as 'ClientName', O.FacilityId, rf.Affiliate,
	CONCAT('https://hrservices.precheck.com/ReviewProcess/Authenticate?token=', rr.SecurityTokenID) as 'HRReviewLink', t.ExpireDate
	FROM Enterprise.Staging.ApplicantStage [as]
	INNER join Enterprise.[Staging].[OrderStage] O  on [as].StagingOrderId=O.StagingOrderId 
	LEFT JOIN Enterprise.Staging.ReviewRequest rr ON [as].StagingApplicantId = rr.StagingApplicantId 
	INNER JOIN SecureBridge..Token t on rr.SecurityTokenID = t.TokenID
	INNER JOIN PreCheck..Client c on o.FacilityID = c.CLNO and O.ClientId = c.weborderparentclno
	INNER JOIN Precheck..refAffiliate rf on C.Affiliateid =rf.AffiliateId
	WHERE  RR.CreateDate between @Startdate and @EndDate
	AND RR.ClosingReviewStatusId = 1  
	AND RR.IsComplete = 0  
	AND O.ClientID = @ParentCLNO
	AND (ISNULL(O.IsConfirmed,0)=0  )
	AND O.IsReviewRequired = 1  
	AND c.AffiliateId = @AffiliateID
END
