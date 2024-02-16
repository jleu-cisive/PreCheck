-- =============================================
-- Author:		Radhika Dereddy
-- Create date: 08/30/2018
-- Description:	 Q-Report that pulls a list of all clinical sites associated with StudentCheck accounts.  
-- =============================================
CREATE PROCEDURE [dbo].[ClinicalSitesAssociatedWithStudentCheckAccounts]
	-- Add the parameters for the stored procedure here

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT c.CLNO, c.Name, cs.CLNO_Hospital, (select Name from Client where CLNO =cs.CLNO_Hospital) as CLNO_HospitalName,(CASE WHEN IsActive = 0 THEN 'FALSE' ELSE 'TRUE' END) as IsActive
	FROM CLIENT c (NOLOCK)
	INNER JOIN  ClientSchoolHospital cs (nolock) ON c.CLNO = cs.CLNO_School 
	WHERE c.CLNO NOT IN (2135,3668)
	ORDER BY CLNO
END
