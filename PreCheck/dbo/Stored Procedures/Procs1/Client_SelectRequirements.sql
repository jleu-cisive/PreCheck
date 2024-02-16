


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Client_SelectRequirements]
	-- Add the parameters for the stored procedure her
AS
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
    -- Insert statements for procedure here
	SELECT [Name], dbo.Client.CLNO AS CLNO, ClientCrimRate.County, dbo.ClientCrimRate.Rate AS CrimRate, 
	ExcludeFromRules, MVR, Social,Adverse, CountyCrim, EducationNotes, LicenseNotes, StateCrimNotes, 
	CountyCrimNotes, DeliveryMethod, CreditNotes, Employment, EmploymentNotes, [Medicaid/Medicare],
	NoteDate, NoteText, NoteType
	FROM dbo.Client
	LEFT OUTER JOIN dbo.refLicenseNotes ON dbo.Client.LicenseNotesID = dbo.refLicenseNotes.LicenseNotesID 
	LEFT OUTER JOIN dbo.refStateCrimNotes ON dbo.Client.StateCrimNotesID = dbo.refStateCrimNotes.StateCrimNotesID 
	LEFT OUTER JOIN dbo.refCountyCrimNotes ON dbo.Client.CountyCrimNotesID = dbo.refCountyCrimNotes.CountyCrimNotesID 
	LEFT OUTER JOIN dbo.refDeliveryMethod ON dbo.Client.DeliveryMethodID = dbo.refDeliveryMethod.DeliveryMethodID 
	LEFT OUTER JOIN dbo.refCreditNotes ON dbo.Client.CreditNotesID = dbo.refCreditNotes.CreditNotesID 
	LEFT OUTER JOIN dbo.refEmployment ON dbo.Client.EmploymentID = dbo.refEmployment.EmploymentID 
	LEFT OUTER JOIN dbo.refEmploymentNotes ON (dbo.Client.EmploymentNotes1ID = dbo.refEmploymentNotes.EmploymentNotesID) AND (dbo.Client.EmploymentNotes2ID = dbo.refEmploymentNotes.EmploymentNotesID)  
	LEFT OUTER JOIN dbo.ClientCrimRate ON dbo.Client.CLNO = dbo.ClientCrimRate.CLNO 
	LEFT OUTER JOIN refCountyCrim ON dbo.Client.CountyCrimID = refCountyCrim.CountyCrimID 
	LEFT OUTER JOIN dbo.refAdverse ON dbo.Client.Adverse = dbo.refAdverse.AdverseID 
	LEFT OUTER JOIN dbo.refEducationNotes ON dbo.Client.EducationNotesID = dbo.refEducationNotes.EducationNotesID 
	LEFT OUTER JOIN dbo.ClientNotes ON dbo.ClientNotes.CLNO = dbo.Client.CLNO	
	ORDER BY [Name]


	SET TRANSACTION ISOLATION LEVEL READ COMMITTED
	SET NOCOUNT OFF



