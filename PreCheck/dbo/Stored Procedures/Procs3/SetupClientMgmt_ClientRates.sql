
CREATE PROCEDURE SetupClientMgmt_ClientRates AS

Update ClientRates SET ClientRates.ServiceID=d.ServiceID 
From ClientRates
Join DefaultRates d ON ClientRates.RateType = d.RateType
