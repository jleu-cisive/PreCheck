-- =============================================
-- Author:		Humera Ahmed
-- Create date: 5/21/2019
-- Description:	1. Please create a new Q report which will be titled Verified Enrollment Only Education Reverification Report. 
			 -- 2. The initial search parameters should include CLNO, Affiliate ID, Start Date and End Date.  
			 -- 3. The report should be filtered so that it only provides results where an education component was closed in a Verified/Enrollment Only status.
-- EXEC Qreport_VerifiedEnrollmentOnlyEducationReverificationReport '','','1/1/2019','5/21/2019'
-- =============================================
CREATE PROCEDURE [dbo].[Qreport_VerifiedEnrollmentOnlyEducationReverificationReport] 
	-- Add the parameters for the stored procedure here
	@CLNO varchar(MAX) = NULL, 
	@AffiliateID varchar(50), 
	@StartDate datetime, 
	@EndDate datetime
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here

	IF(@CLNO = '' OR @CLNO = 'null' OR @CLNO = '0') 
	Begin  
		SET @CLNO = NULL  
	END

	if(@AffiliateID ='' or @AffiliateID='null' or @AffiliateID='0')
	begin
	set @AffiliateID=NULL
	END

	SELECT 
		ra.Affiliate [Affiliate Name]
		, a.CLNO [ Client Number]
		, c.Name [Client Name]
		, f.FacilityNum [Process Level]
		, f.FacilityName [Process Name]
		, a.APNO [Report Number]
		, a.First+' '+a.Last [Applicant Name]
		, format(a.ApDate, 'MM/dd/yyyy hh:mm tt') [Report Start Date]
		, format(a.OrigCompDate, 'MM/dd/yyyy hh:mm tt') [Report Close Date]
		, e.School [Education]
		, e.Degree_V [Degree Type]
		, ss.Description [Status]
	FROM appl a 
		INNER JOIN dbo.Educat e ON a.APNO = e.APNO
		INNER JOIN client c ON a.CLNO = c.CLNO
		INNER JOIN dbo.refAffiliate ra ON c.AffiliateID = ra.AffiliateID
		INNER JOIN dbo.SectStat ss ON e.SectStat = ss.Code
		LEFT JOIN HEVN.dbo.Facility f ON a.CLNO = f.FacilityCLNO and isnull(deptCode,'') = Facilitynum
	WHERE 
		e.SectStat IN ('E')
		AND a.ApDate >=@StartDate AND a.ApDate<=dateadd(d,1,@EndDate)
		AND A.CLNO NOT IN (3468,2135)
		AND (@CLNO IS NULL OR A.CLNO in (SELECT value FROM fn_Split(@CLNO,':'))) 
		AND (@AffiliateID IS NULL or c.AffiliateID in (SELECT value FROM fn_Split(@AffiliateID,':')) )
	ORDER BY a.APNO

END
