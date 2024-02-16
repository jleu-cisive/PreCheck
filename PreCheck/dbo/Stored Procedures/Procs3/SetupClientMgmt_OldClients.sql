
CREATE PROCEDURE SetupClientMgmt_OldClients AS

UPDATE Client Set TaxRateID = (SELECT TaxRateID FROM refTaxRate a WHERE a.TaxRate=Client.TaxRate) WHERE TaxRateID is null

UPDATE Client Set Status='I' WHERE Status='N' and BillingStatusID is null  --'N' is not a valid code, should be 'I' for Inactive
UPDATE Client Set BillingStatusID = (SELECT BillingStatusID FROM refBillingStatus a WHERE a.BillingStatusCode=Client.Status) WHERE BillingStatusID is null

UPDATE Client Set BillingCycleID = (SELECT BillingCycleID FROM refBillingCycle a WHERE a.BillingCycle=Client.BillCycle) WHERE BillingCycleID is null
