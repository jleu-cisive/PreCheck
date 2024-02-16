



--select * from [dbo].[vwIntegrationDetails_ClientIDOverride] where RequestID = 6288
CREATE VIEW [dbo].[vwIntegrationDetails]
AS
SELECT    
	r.RequestId,
	CLNO = IsNull([dbo].[GetXMLNodeValue] (cci.ConfigSettings,'ClientConfigSettings','TransformedCLNO'),r.CLNO)
	
FROM            
	dbo.ClientConfig_Integration cci 
INNER JOIN
	dbo.Integration_OrderMgmt_Request r 
ON 
	r.CLNO = cci.CLNO



