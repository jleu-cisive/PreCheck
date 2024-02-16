-- =============================================
-- Author:		Radhika Dereddy
-- Create date: 07/09/2021
-- Description:	Education verification Duplicate Billing
-- EXEC [Education_Verification_Duplicate_Billing] '07/01/2021', '07/12/2021'
-- =============================================
CREATE PROCEDURE [dbo].[QReport_EducationVerificationDuplicateBilling]
	-- Add the parameters for the stored procedure here
@StartDate datetime,
@EndDate datetime
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	   SELECT A.APNO AS 'Report Number',
           Edu.School AS 'School Name',
           Edu.Studies_V AS 'Studies',
           Edu.Degree_V AS 'Degree Type',
           Edu.SectStat AS 'Status',
           Edu.web_status AS 'Web Status',
           I.Description AS 'Billing Description',
           I.Amount AS 'Amount Billed',
           Edu.IsHidden AS 'IsHidden Report',
           Edu.IsOnReport AS 'IsOnReport',
           COUNT(A.APNO) AS 'Duplicate Count'
    FROM dbo.Appl A WITH (NOLOCK)
        INNER JOIN dbo.Educat Edu WITH (NOLOCK)
            ON (A.APNO = Edu.APNO)
        LEFT JOIN dbo.InvDetail I WITH (NOLOCK)
            ON A.APNO = I.APNO
    WHERE I.Description LIKE '%SYSTEM:Education:NCH%'
          AND (I.CreateDate
          BETWEEN @StartDate AND @EndDate
              )
    GROUP BY A.APNO,
             Edu.School,
             Edu.Studies_V,
             Edu.Degree_V,
             Edu.SectStat,
             Edu.web_status,
             I.Description,
             I.Amount,
             Edu.IsHidden,
             Edu.IsOnReport
    HAVING COUNT(A.APNO) > 1;
			
END
