
-- =============================================
-- Author:		Paul A. Jones, Jr.
-- Create date: 8/23/2022
-- Description:	Get configuration settings by partner id
-- =============================================
CREATE PROCEDURE [dbo].[GetConfigSettingsByPartnerGroupingId]
	-- Add the parameters for the stored procedure here
	@PartnerGroupingId INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	select PC.PartnerConfigId, PC.ConfigSettings, P.PartnerId 
	from Partner P 
	inner join PartnerConfig PC ON P.PartnerId = PC.PartnerId
	Where P.PartnerGroupingId = @PartnerGroupingId;

END
