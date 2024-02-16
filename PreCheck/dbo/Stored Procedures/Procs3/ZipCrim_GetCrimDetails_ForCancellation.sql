-- =============================================
-- Author:		Deepak Vodethela
-- Create date: 03/19/2020
-- Description:	Get related Crim for Cancellation
-- Execution: EXEC ZipCrim_GetCrimDetails_ForCancellation 'B62ABC0A-47AE-4BBC-89D5-ECD62E9C70D0','10060894','08'
-- Execution: EXEC ZipCrim_GetCrimDetails_ForCancellation '17819464','06'
-- =============================================
CREATE PROCEDURE [dbo].[ZipCrim_GetCrimDetails_ForCancellation] 
	-- Add the parameters for the stored procedure here
@PartnerReference VARCHAR(20),
@LeadNum VARCHAR(50)
--@ConfirmationCode VARCHAR(50),
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT c.APNO, c.CrimID, c.CNTY_NO, c.County, z.PartnerReference, p.ExternalID AS [LeadNum]
	FROM dbo.ZipCrimWorkOrdersStaging z
	INNER JOIN dbo.ZipCrimWorkOrders w ON w.WorkOrderID = z.WorkOrderID
	INNER JOIN dbo.PreCheckZipCrimComponentMap p ON p.APNO = w.APNO AND p.IsActive = 1 AND P.IsCancelled = 0
	INNER JOIN dbo.Crim c ON c.CrimID = p.SectionUniqueID AND c.IsHidden = 0
	INNER JOIN dbo.Appl a ON a.APNO = c.APNO --AND a.ApStatus = 'P'
	WHERE z.PartnerReference = @PartnerReference
	  AND p.ExternalID = @LeadNum
	  --AND z.ConfirmationCode = @ConfirmationCode
	   
END
