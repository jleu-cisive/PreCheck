

--select * from [dbo].[vwIntegration_VendorOrder_Educat]

CREATE VIEW [dbo].[vwIntegration_VendorOrder_Educat]
AS
       SELECT  top 1000
                        s.Integration_VendorOrder_LogId,
                        s.Integration_VendorOrderId,
                        s.IsProcessed,
                        s.OrderId,
                        s.ProcessedDate,
                        s.StatusReceived,
                        s.CreatedDate,
                        s.ErrorCount,
                        s.VerificationType
        FROM (
                SELECT  --TOP 500
                        ol.Integration_VendorOrder_LogId,
                        ol.Integration_VendorOrderId,
                        ol.IsProcessed,
                        ol.OrderId,
                        ol.ProcessedDate,
                        ol.StatusReceived,
                        ol.CreatedDate,
                        ol.ErrorCount,
                        os.SubmittedTo AS VerificationType,
                        ROW_NUMBER() OVER(PARTITION BY ol.OrderId,ol.StatusReceived, ol.IsProcessed, os.SubmittedTo 
                                            ORDER BY ol.CreatedDate desc) AS DuplicateCount
                     FROM dbo.Integration_VendorOrder_Log ol WITH (NOLOCK)
                  INNER JOIN dbo.Integration_VendorOrder_Submitted os WITH (NOLOCK) ON ol.OrderId = os.OrderID
                  WHERE ol.IsProcessed = 0 
                  and ISNULL(ol.ErrorCount, 0) < 3 --and ol.ProcessedDate is null
                  AND os.SubmittedTo = 'EnterpriseNSCH' 
				  --and os.OrderID in
				  --( 
				  --39847225
				  --)
				  --Order By ol.CreatedDate
                ) s
        WHERE s.DuplicateCount = 1  
        Order By s.CreatedDate
