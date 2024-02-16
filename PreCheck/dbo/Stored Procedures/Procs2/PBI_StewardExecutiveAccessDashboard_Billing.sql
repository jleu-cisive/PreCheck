-- =============================================
/*
-- Author      : Vairavan  A
-- Create date : 11/22/2022
-- Description : To get data for Applications dataset of StewardExecutiveAccessDashboard Power Bi report
EXEC [PBI_StewardExecutiveAccessDashboard_Billing] 2019,228,15382 --30sec
*/
-- =============================================
CREATE PROCEDURE dbo.PBI_StewardExecutiveAccessDashboard_Billing
-- Add the parameters for the stored procedure here
@Year int,
@AffiliateID int,
@weborderparentclno smallint
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	SET NOCOUNT ON;
	;WITH cteApplIds AS
(
	SELECT a.APNO
	FROM dbo.Appl a WITH (nolock)
	INNER JOIN client c WITH (nolock)
		ON c.clno = a.clno
	INNER JOIN dbo.ClientCertification cer WITH (nolock)
		ON cer.APNO = a.APNO AND cer.ClientCertReceived='Yes'
	WHERE year(a.OrigCompDate) >= @Year-- 2019
	AND c.AffiliateID IN (@AffiliateID)--(228)
	AND c.weborderparentclno = @weborderparentclno --15382
	AND a.OrigCompDate IS NOT NULL
)
SELECT inv.InvDetID, inv.InvoiceNumber, inv.CreateDate, inv.APNO, inv.Type, inv.Description, Inv.Amount 
FROM dbo.InvDetail inv WITH (nolock)
INNER JOIN cteApplIds a ON inv.APNO = a.APNO
WHERE inv.Billed=1
    
END

