CREATE PROCEDURE [dbo].[PendingCrims_GetAppDetails]
	-- Add the parameters for the stored procedure here
@Apno int
AS
BEGIN
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED


select a.apno,a.apdate,a.SSN,a.last,a.first,
cl.clno, cl.name + ', <b>' + cl.state + '</b>' as 'name', a.DOB, a.pos_sought as 'position', 
(isnull(a.Addr_Street,'-') + ', ' + isnull(a.City,'-') + ', ' + isnull(a.State,'-') + ', Zipcode: ' + isnull(a.Zip, '-')) as 'address',
isnull(nullif(a.DL_Number,''), '-') + ', State:' + isnull(nullif(a.DL_State, ''), '-') as 'dl',
0 TrasferredRecordCount, ra.Affiliate, rct.ClientType, a.Priv_Notes PrivateNotes
from appl a 
inner join client cl on a.clno = cl.clno
LEFT JOIN dbo.refAffiliate ra ON ra.AffiliateID = cl.AffiliateID
LEFT JOIN dbo.refClientType rct ON cl.ClientTypeID = rct.ClientTypeID
where a.apno = @Apno


SET TRANSACTION ISOLATION LEVEL READ COMMITTED
SET NOCOUNT OFF
END