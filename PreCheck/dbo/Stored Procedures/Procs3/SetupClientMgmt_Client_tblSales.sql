
-- Purpose to put correct index value in ClientSales for 

-- Created 7/18/2003 by Steve Krenek


CREATE PROCEDURE SetupClientMgmt_Client_tblSales AS

Update Client Set SalesPersonUserID=a.UserID FROM Client c
        join tblClient tc on tc.ClientNumber = c.CLNO 
	JOIN tblSales ts ON tc.ClientID=ts.ClientID
	JOIN refEmployees a ON a.Employee=ts.SalesPerson

Update Client Set CustomerRatingID=a.CustomerRatingID FROM Client c
        join tblClient tc on tc.ClientNumber = c.CLNO 
	JOIN tblSales ts ON tc.ClientID=ts.ClientID
	JOIN refCustomerRating a ON a.CustomerRating=ts.CustomerRating

Update Client Set HolidayGift=tb.HolidayGift FROM Client c
        join tblClient tc on tc.ClientNumber = c.CLNO 
	JOIN tblSales tb ON tc.ClientID=tb.ClientID
