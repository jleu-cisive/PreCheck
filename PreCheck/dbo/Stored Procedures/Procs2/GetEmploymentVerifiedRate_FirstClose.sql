
-- =============================================
-- Author:		Radhika Dereddy
-- Create date: 02/27/2018
-- Description:	Need to create report similar to "Client Verified Rate - Employment Verifications" but to have the formulas and associated Status Percentages 
--				be based off of the status of the verifications at time of initial close of the report (Original Close Date).  
-- to include parameters of Affiliate ID, and Is One HR
-- Execution : EXEC [dbo].[GetEmploymentVerifiedRate_FirstClose] '0','02/01/2020','02/29/2020',4
-- =============================================

/* Modified By: Sunil Mandal A
-- Modified Date: 07/01/2022
-- Description: Ticketno-53763 
Modify existing q-reports that have affiliate ids in their search parameters
Details: 
Change search parameters for the Affiliate Id field
     * search by multiple affiliate ids (ex 4:297)
     * want to also be able to search all affiliates by putting zero - meaning 0 to search all affiliates
     * multiple affiliates to be separated by a colon  
Under Parameter Names - after Affiliate ID include this wording (separate by colon, default 0)
*/
---Testing
/*


Execution : EXEC [dbo].[GetEmploymentVerifiedRate_FirstClose] '0','02/01/2020','02/29/2020',4
Execution : EXEC [dbo].[GetEmploymentVerifiedRate_FirstClose] '0','02/01/2020','02/29/2020','4:30:177'
*/

CREATE PROCEDURE [dbo].[GetEmploymentVerifiedRate_FirstClose]
	-- Add the parameters for the stored procedure here
@clno int,
@Startdate date,
@Enddate date,
--@AffiliateID int --code added by Sunil Mandal for ticket id -53763
@AffiliateIDs varchar(MAX) = '0'--code added by Sunil Mandal for ticket id -53763
--@IsOneHr bit =1
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.

	--code added by Sunil Mandal for ticket id -53763 starts
	IF @AffiliateIDs = '0' 
	BEGIN  
		SET @AffiliateIDs = NULL  
	END
     --code added by Sunil Mandal for ticket id -53763 Ends	


	IF(@CLNO = 0 OR @CLNO IS NULL OR LOWER(@CLNO) = 'null' OR @CLNO='')
		BEGIN
		  SET @Clno = 0
		END

		DECLARE @sects TABLE
		(
		 status varchar(1)
		)

		DECLARE @results TABLE
		(
			StatusType varchar(100),
			Count int,
			Percentage decimal(12,2)
		)

		DECLARE @totalcount int

		INSERT INTO @sects 
			SELECT E.SectStat From Empl E
			inner join Appl a on E.APNO = A.APNO
			Inner join Client C on a.CLNO = c.CLNO
			LEFT JOIN HEVN.dbo.Facility F (NOLOCK) ON isnull(A.DeptCode,0) = F.FacilityNum
			WHERE (A.CLNO = @CLNO or @CLNO = 0)
			  AND (CONVERT(DATE,a.[OrigCompDate]) >= @Startdate) 
			  AND (CONVERT(DATE,a.[OrigCompDate]) < dateadd(d,1,@EndDate)) 
	    	  AND (E.IsOnReport = 1)
			  AND (E.[IsHidden] = 0)
			  -- AND C.AffiliateID = IIF(@AffiliateID=0,C.AffiliateID,@AffiliateID) --code added by Sunil Mandal for ticket id -53763
			  AND (@AffiliateIDs IS NULL OR c.AffiliateID IN (SELECT value FROM fn_Split(@AffiliateIDs,':'))) --code added by Sunil Mandal for ticket id -53763
			  --AND (ISNULL(F.IsOneHR,0) = @IsOneHR)

		--SELECT * FROM @sects

		SET @totalcount = (SELECT COUNT(*) FROM @sects)

		INSERT INTO @results (statustype, COUNT, percentage)
			SELECT s.Description, COUNT(*),  (CONVERT(DECIMAL, COUNT(*))/ CONVERT(DECIMAL, @totalcount)) * 100
			FROM SectStat s
			JOIN @sects x on x.status = s.code
			GROUP BY s.Description

		INSERT INTO @results (statustype, COUNT, percentage) SELECT 'Total', @totalcount, 100

		SELECT * FROM @results

END
