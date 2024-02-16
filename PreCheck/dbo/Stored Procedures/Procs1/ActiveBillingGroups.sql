-- =============================================
-- Author:		Deepak Vodethela
-- Create date: 12/13/2019
-- Description:	To assist Accounting with ensuring the StudentCheck accounts are associated to the correct billing groups in our system
-- Execution: EXEC ActiveBillingGroups
-- =============================================
CREATE PROCEDURE [dbo].[ActiveBillingGroups] 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT	c.CLNO, c.Name, 
			CASE c.SchoolWillPay
				WHEN 0 THEN 'False'
				WHEN 1 THEN 'True'
			END AS SchoolWillPay,
			c.BillCycle
	FROM dbo.Client c
	WHERE c.IsInactive = 0
	  AND c.ClientTypeID IN (6,7,8,9,11,12,13)
END
