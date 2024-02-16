
CREATE PROCEDURE SetupClientMgmt_Client_tblBilling AS



Update Client Set TaxStatusID=a.TaxStatusID FROM Client c
        join tblClient tc on tc.ClientNumber = c.CLNO 
	JOIN tblBilling ts ON tc.ClientID=ts.ClientID
	JOIN refTaxStatus a ON a.TaxStatus=ts.TaxStatus
Update Client Set TaxRateID=a.TaxRateID FROM Client c
        join tblClient tc on tc.ClientNumber = c.CLNO 
	JOIN tblBilling ts ON tc.ClientID=ts.ClientID
	JOIN refTaxRate a ON a.TaxRate=ts.TaxRate
Update Client Set BillingStatusID=a.BillingStatusID FROM Client c
        join tblClient tc on tc.ClientNumber = c.CLNO 
	JOIN tblBilling ts ON tc.ClientID=ts.ClientID
	JOIN refBillingStatus a ON a.BillingStatus=ts.BillingStatus
Update Client Set BillingCycleID=a.BillingCycleID FROM Client c
        join tblClient tc on tc.ClientNumber = c.CLNO 
	JOIN tblBilling ts ON tc.ClientID=ts.ClientID
	JOIN refBillingCycle a ON a.BillingCycle=ts.BillingCycle

Update Client Set BillingAddress1=tb.BillingAddress1 FROM Client c
        join tblClient tc on tc.ClientNumber = c.CLNO 
	JOIN tblBilling tb ON tc.ClientID=tb.ClientID
Update Client Set BillingAddress2=tb.BillingAddress2 FROM Client c
        join tblClient tc on tc.ClientNumber = c.CLNO 
	JOIN tblBilling tb ON tc.ClientID=tb.ClientID
Update Client Set AttnTo=tb.AttnTo FROM Client c
        join tblClient tc on tc.ClientNumber = c.CLNO 
	JOIN tblBilling tb ON tc.ClientID=tb.ClientID

Update Client Set BillingCity=tb.BillingCity FROM Client c
        join tblClient tc on tc.ClientNumber = c.CLNO 
	JOIN tblBilling tb ON tc.ClientID=tb.ClientID
Update Client Set BillingState=tb.BillingState FROM Client c
        join tblClient tc on tc.ClientNumber = c.CLNO 
	JOIN tblBilling tb ON tc.ClientID=tb.ClientID
Update Client Set BillingZip=tb.BillingZip FROM Client c
        join tblClient tc on tc.ClientNumber = c.CLNO 
	JOIN tblBilling tb ON tc.ClientID=tb.ClientID

Update Client Set PrintLabel=tb.PrintLable FROM Client c
        join tblClient tc on tc.ClientNumber = c.CLNO 
	JOIN tblBilling tb ON tc.ClientID=tb.ClientID
