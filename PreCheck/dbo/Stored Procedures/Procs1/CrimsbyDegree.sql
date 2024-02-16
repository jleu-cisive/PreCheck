-- =============================================
-- Author:		Radhika Dereddy
-- Create date: 12/09/2020
-- Description:	Crims by Degree 
-- EXEC [CrimsbyDegree] '12/01/2020', '12/09/2020', '1'
-- =============================================
CREATE PROCEDURE dbo.[CrimsbyDegree]
	-- Add the parameters for the stored procedure here
@StartDate datetime,
@EndDate datetime,
@Degree varchar(1)

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

  IF(@Degree='' or @Degree=null OR @Degree=' ')
  Set @Degree = null

	   SELECT a.APNO ReportNumber,a.Apdate, a.First ApplicantFirstName, a.Last  ApplicantLastName, c.CLNO, c.Name, ra.Affiliate,
	    cr.CrimID, cr.County, d.a_county ApplicantCounty
	   , d.state State
	   , d.country Country
       , cr.Clear, css.crimdescription RecordStatus
       , RecordFound = CASE WHEN css.CrimDescription <> 'Clear' THEN 1 ELSE 0 END
       , Degree = CASE 
              WHEN cr.Degree = '1' THEN 'Petty Misdemeanor'
              WHEN cr.Degree = '2' THEN 'Traffic Misdemeanor'
              WHEN cr.Degree = '3' THEN 'Criminal Traffic'
              WHEN cr.Degree = '4' THEN 'Traffic'
              WHEN cr.Degree = '5' THEN 'Ordinance Violation'
              WHEN cr.Degree = '6' THEN 'Infraction'
              WHEN cr.Degree = '7' THEN 'Disorderly Persons'
              WHEN cr.Degree = '8' THEN 'Summary Offense'
              WHEN cr.Degree = '9' THEN 'Indictable Crime'
              WHEN cr.Degree = 'F' THEN 'Felony'
              WHEN cr.Degree = 'M' THEN 'Misdemeanor'
              WHEN cr.Degree = 'O' THEN 'Other'
              WHEN cr.Degree = 'U' THEN 'Unknown'
       END
       ,cr.CaseNo, 
	   cr.Date_Filed, cr.Offense,cr.Sentence ,
       cr.Fine, 
       cr.Disp_Date ,
       cr.Disposition,
	   cr.Crimenteredtime
	   FROM Crim cr WITH (nolock)
       INNER JOIN Appl a ON cr.APNO = a.APNO
	   INNER JOIN client c WITH (nolock) ON c.clno = a.clno
	   INNER JOIN refAffiliate ra on c.AffiliateID =ra.AffiliateID
       INNER JOIN TblCounties d (NOLOCK) ON cr.CNTY_NO = d.CNTY_NO 
       INNER JOIN Crimsectstat css  ON cr.Clear = css.crimsect
	   WHERE cr.IsHidden = 0 
	   AND (cr.Crimenteredtime between @StartDate and @EndDate )
	   AND cr.Degree = IIF(@Degree=null,cr.Degree, @Degree) 



END
