
-- Created 7/18/2003 by Steve Krenek


CREATE PROCEDURE SetupClientMgmt_Client_tblClient AS

--Update Client Set AffiliateID = (SELECT a.AffiliateID from refAffiliate a
--	join tblClient tc on tc.Affiliate = a.Affiliate where tc.ClientNumber = Client.CLNO)
Update Client Set AffiliateID=a.AffiliateID FROM Client c
        join tblClient tc on tc.ClientNumber = c.CLNO 
	JOIN refAffiliate a ON a.Affiliate=tc.Affiliate
Update Client Set TeamID=a.TeamID FROM Client c
        join tblClient tc on tc.ClientNumber = c.CLNO 
	JOIN refTeam a ON a.Team=tc.Team

Update Client SET Client.Name=tc.CompanyName from Client c
  join tblClient tc on c.CLNO=tc.ClientNumber 
Update Client SET Client.Addr1=tc.Address1 from Client c
  join tblClient tc on c.CLNO=tc.ClientNumber 
Update Client SET Client.Addr2=tc.Address2 from Client c
  join tblClient tc on c.CLNO=tc.ClientNumber 


Update Client SET Client.City=tc.City from Client c
  join tblClient tc on c.CLNO=tc.ClientNumber 
Update Client SET Client.State=tc.State from Client c
  join tblClient tc on c.CLNO=tc.ClientNumber 
Update Client SET Client.Zip=tc.Zip from Client c
  join tblClient tc on c.CLNO=tc.ClientNumber