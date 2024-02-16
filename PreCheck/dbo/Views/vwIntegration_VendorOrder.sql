


--select * from [dbo].[vwIntegration_VendorOrder]
CREATE VIEW [dbo].[vwIntegration_VendorOrder]
AS
       SELECT  
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

                SELECT  
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
                  and ISNULL(ol.ErrorCount, 0) < 3 
             
                ) s
        WHERE s.DuplicateCount = 1 
