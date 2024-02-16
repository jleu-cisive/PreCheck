-- Alter Procedure QReport_CourtFeeAuditReport
-- =============================================
-- Author:		Humera Ahmed
-- Create date: 3/22/2019
-- Description:	Court Fee Audit Report
-- =============================================
--Exec [dbo].[QReport_CourtFeeAuditReport]
CREATE PROCEDURE [dbo].[QReport_CourtFeeAuditReport]
	-- Add the parameters for the stored procedure here
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT 
		c.A_County [County Name]
		, c.[State]
		, c.CNTY_NO [County ID]
		, c.PassThroughCharge [OASIS Pass Through Charge]
		,irc.Researcher_CourtFees [IRIS Court Fee]
		, irc.Researcher_other [IRIS Other Fee]
		, irc.Researcher_combo [IRIS Combo Fee]
		, ir.R_Name [Vendor Name]
		, irc.Researcher_Default [Preferred Vendor]
		
	FROM dbo.TblCounties c 
		INNER JOIN dbo.Iris_Researcher_Charges irc ON c.CNTY_NO=irc.cnty_no AND c.[State]=irc.Researcher_state AND c.A_County=irc.Researcher_county
		INNER JOIN dbo.Iris_Researchers ir ON irc.Researcher_id = ir.R_id
	WHERE irc.Researcher_Default='Yes'

END
