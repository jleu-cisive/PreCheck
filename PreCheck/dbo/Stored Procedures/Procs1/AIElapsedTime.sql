-- =============================================
-- Author:		Radhika Dereddy	
-- Create date: 10/23/2019
-- Description:	AI Elapsed time Qreport for Jennifer Cordova (add an investigator as parameter and Elapsed DateTime (hh:mm)
-- EXEC AIElapsedTime '10/01/2019','10/24/2019',4
-- Modified by Humera Ahmed on 3/9/2021 - updated the logic of Elapsed time in Hours column.
/* Modified By: Vairavan A
-- Modified Date: 07/06/2022
-- Description: Ticketno-53763 
Modify existing q-reports that have affiliate ids in their search parameters
Details: 
Change search parameters for the Affiliate Id field
     * search by multiple affiliate ids (ex 4:297)
     * want to also be able to search all affiliates by putting zero - meaning 0 to search all affiliates
     * multiple affiliates to be separated by a colon  
Under Parameter Names - after Affiliate ID include this wording (separate by colon, default 0)

Child ticket id -54481 Update AffiliateID Parameters 971-1053
*/
---Testing
/*
EXEC [dbo].[AIElapsedTime] '10/01/2019','10/24/2019','4'
EXEC [dbo].[AIElapsedTime] '10/01/2019','10/24/2019','0'
EXEC [dbo].[AIElapsedTime] '10/01/2019','10/24/2019','4:8'
*/
-- =============================================
CREATE PROCEDURE [dbo].[AIElapsedTime]
	-- Add the parameters for the stored procedure here
	@StartDate datetime,
	@EndDate Datetime,
	--@AffiliateID int,--code commented by vairavan for ticket id -53763(54481)
    @AffiliateIDs varchar(MAX) = '0',--code added by vairavan for ticket id -53763(54481)
	@Investigator varchar(8) =''
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

	CREATE TABLE #TempAI(
		[APNO] [int] NOT NULL,
		[CLNO] [int] NOT NULL,
		[ClientName] [varchar](100) NULL,
		[Affiliate][varchar](100) NULL,
		[AffiliateID][int] NOT NULL,
		[Applicant First Name] [varchar](50) NOT NULL,
		[Applicant Last Name] [varchar](50) NOT NULL,
		[CAM] [varchar](8) NULL,
		[Investigator][varchar](8) NULL,
		[EnteredVia] [varchar](8) NULL,
		[CreatedDate] [datetime] NULL,
		[Report DateTime] [datetime] NULL,
		--[Review Start DateTime] [datetime] NULL,
		[Review Completion DateTime] [datetime] NULL
		)

	CREATE CLUSTERED INDEX IX_TempAI ON #TempAI(APNO)

    INSERT INTO #TempAI
	SELECT a.APNO, c.CLNO, c.Name as CLientName, rf.Affiliate, rf.AffiliateId, a.First as 'Applicant First Name', a.Last as 'Applicant Last Name',
	c.CAM, a.Investigator, a.EnteredVia, a.CreatedDate, Case when UPPER(cc.ClientCertReceived) = 'YES' then cc.CLientCertUpdated else a.ApDate end as 'Report DateTime'
	--ag.CreatedDate as 'Review Start DateTime'
	, o.AIMICreatedDate as 'Review Completion DateTime'	
	FROM APPL a with(nolock)
	INNER JOIN Client c  with(nolock) on a.CLNO = c.CLNO
	INNER JOIN refAffiliate rf with(nolock)  on c.AffiliateID = rf.AffiliateID
	--LEFT JOIN ApplGetNextLog ag on a.APNO = ag.APNO
	INNER JOIN Metastorm9_2.dbo.Oasis AS O  with(nolock)  ON a.APNO = O.apno
	LEFT JOIN ClientCertification cc  with(nolock) on a.APNO = cc.APNO	
	WHERE a.Apdate between @StartDate and DateAdd(d,1, @EndDate)
	--AND C.AffiliateID = IIF(@AffiliateID =0, c.AffiliateID, @AffiliateID)--code commented by vairavan for ticket id -53763(54481)
	and (@AffiliateIDs IS NULL OR c.AffiliateID IN (SELECT value FROM fn_Split(@AffiliateIDs,':')))--code added by vairavan for ticket id -53763(54481)


	--Select *, [dbo].[ElapsedBusinessHours_2]([Report DateTime], [Review Start DateTime]) [ElapsedTime in HH]
	Select *, [dbo].[ElapsedBusinessHours_2]([Report DateTime], [Review Completion DateTime]) [ElapsedTime in HH]
	from #TempAI
	Where Investigator = IIF(@Investigator ='', Investigator, @Investigator)
	AND [dbo].[ElapsedBusinessHours_2]([Report DateTime], [Review Completion DateTime]) IS NOT null
END

