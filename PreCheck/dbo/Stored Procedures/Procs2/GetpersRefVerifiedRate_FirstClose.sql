-- =============================================
-- Author:		Deepak Vodethela
-- Create date: 01/10/2018
-- Description:	Need to create report similar to "Client Verified Rate - Education Verifications" but to have the formulas and associated Status Percentages 
--				be based off of the status of the verifications at time of initial close of the report (Original Close Date).  
-- Execution :	EXEC [dbo].[GetPersRefVerifiedRate_FirstClose] 13237, '03/01/2018', '03/31/2018','HCA'
--				EXEC [dbo].[GetPersRefVerifiedRate_FirstClose] 0, '12/01/2017', '12/31/2017','HCA'
/* Modified By: Vairavan A
-- Modified Date: 07/05/2022
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
EXEC [dbo].[GetPersRefVerifiedRate_FirstClose] 0, '12/01/2017', '12/31/2017','0'
EXEC [dbo].[GetPersRefVerifiedRate_FirstClose] 0, '12/01/2017', '12/31/2017','4'
EXEC [dbo].[GetPersRefVerifiedRate_FirstClose] 0, '12/01/2017', '12/31/2017','4:8'
*/
-- =============================================
CREATE PROCEDURE [dbo].[GetpersRefVerifiedRate_FirstClose]
	-- Add the parameters for the stored procedure here
@clno int,
@Startdate date,
@Enddate date,
	-- @AffiliateID int--code commented by vairavan for ticket id -53763
  @AffiliateIDs varchar(MAX) = '0'--code added by vairavan for ticket id -53763
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

			--code added by vairavan for ticket id -53763 starts
	IF @AffiliateIDs = '0' 
	BEGIN  
		SET @AffiliateIDs = NULL  
	END
	--code added by vairavan for ticket id -53763 ends

    -- Insert statements for procedure here
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
		SELECT [t1].[SectStat]
		FROM [Appl] AS [t0] with(NOLOCK)
		INNER JOIN [PersRef] AS [t1] with(NOLOCK) ON [t0].APNO = [t1].APNO
		INNER JOIN Client AS C WITH (NOLOCK) on [t0].CLNO =	C.clno
		INNER JOIN refAffiliate ra with (Nolock) on ra.AffiliateID = c.AffiliateID
		WHERE ([t1].IsOnReport = 1)
		  AND ([t1].[IsHidden] = 0)
		  AND ([t0].ApStatus = 'F')
		  AND (CONVERT(DATE,[t1].[Last_Worked]) >= @Startdate) AND (CONVERT(DATE,[t1].[Last_Worked]) <= @Enddate)
		  AND (CONVERT(DATE,[t0].[OrigCompDate]) >= @Startdate) AND (CONVERT(DATE,[t0].[OrigCompDate]) <= @Enddate) 
		  --AND RA.AffiliateID = IIF(@AffiliateID = 0, RA.AffiliateID, @AffiliateID)--code commented by vairavan for ticket id -53763
		  and (@AffiliateIDs IS NULL OR RA.AffiliateID IN (SELECT value FROM fn_Split(@AffiliateIDs,':')))--code added by vairavan for ticket id -53763
		  AND [t0].[CLNO] = IIF(@CLNO = 0, [t0].[CLNO], @CLNO)

	--SELECT * FROM @sects

	SET @totalcount = (SELECT COUNT(*) FROM @sects)

	--SELECT @totalcount

	INSERT INTO @results (statustype, COUNT, percentage)
		SELECT s.Description, COUNT(*),  (CONVERT(DECIMAL, COUNT(*))/ CONVERT(DECIMAL, @totalcount)) * 100
		FROM SectStat s with(nolock)
		JOIN @sects x on x.status = s.code
		GROUP BY s.Description

	INSERT INTO @results (statustype, COUNT, percentage) SELECT 'Total', @totalcount, 0

	SELECT * FROM @results
END


