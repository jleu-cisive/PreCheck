

-- =============================================
-- Author:		Larry Ouch
-- Create date: 10/7/2021
-- Description:	Updates the dbo.ProfLic.Is_Investigator_Qualified field
-- =============================================
CREATE PROCEDURE [dbo].[LMP_UpdateProfLicEligibility]
	@ProfLicID INT,
	@IsInvestigatorQualified BIT
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
	
	--UPDATE Is_Investigator_Qualified to TRUE 
	UPDATE [Precheck].[dbo].[ProfLic]
	SET Is_Investigator_Qualified = @IsInvestigatorQualified, Last_Updated = CURRENT_TIMESTAMP
	WHERE [Precheck].[dbo].[ProfLic].[ProfLicID] = @ProfLicID

    END TRY
    BEGIN CATCH
		PRINT ''			
    END CATCH
END

