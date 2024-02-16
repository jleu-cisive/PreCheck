-- =============================================
-- Author:		Radhika Dereddy
-- Create date: 07/18/2017
-- Description:	Removed inline query and created a stored procedure
-- Modified By: Amy Liu on 03/20/2019 HDT48390 Add Field User's email address
-- =============================================
CREATE PROCEDURE [dbo].[Client_Security_Privileges]

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	    Select PrincipalID as ClientContactId, ResourceID as CLNO, c.Name as 'ClientName', c.WeborderParentCLNO as 'ParentCLNO', cc.FirstName, CC.LastName, cc.Email, ra.Affiliate
		from [Security].[Privilege] p
		inner join CLientContacts cc on cc.ContactID = p.PrincipalId
		inner join Client C on P.ResourceId = c.CLNO 
		Inner join Client On cc.CLNO = Client.CLNO
		inner join refAffiliate ra on ra.AffiliateID = c.AffiliateID
		WHERE p.IsActive=1 ORDER BY cc.FirstName -- HAhmed 1/3/2019 - Only display active priviliges
END
