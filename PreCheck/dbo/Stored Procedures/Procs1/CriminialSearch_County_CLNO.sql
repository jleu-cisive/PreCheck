-- Alter Procedure CriminialSearch_County_CLNO
-- =============================================
-- Author:		Radhika Dereddy
-- Create date: 06/04/2018
-- Description:	Ryan Trevino - identifying which criminal searches we have run for our clients
-- EXEC [CriminialSearch_County_CLNO] '01/01/2018', '02/28/2018'
-- =============================================
CREATE PROCEDURE [dbo].[CriminialSearch_County_CLNO]
	-- Add the parameters for the stored procedure here
	@StartDate datetime,
	@EndDate datetime
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;


DECLARE @CrimSearchbyCLNO TABLE
(
	Clno int,
	ClientName varchar(100),
	State varchar(20),
	Affiliate varchar(50),
	AffiliateID int,
	County varchar(40),
	CNTY_NO int,
	CrimCount int
)

    INSERT INTO  @CrimSearchbyCLNO
	SELECT c.clno, c.name, c.State, rf.Affiliate, rf.affiliateid, cr.County, cc.CNTY_NO, COUNT(cr.CrimId) 
	FROM Appl a
	INNER JOIN Crim cr WITH(NOLOCK) ON a.apno = cr.apno
	INNER JOIN Client c WITH(NOLOCK) ON a.clno = c.clno
	INNER JOIN refAffiliate rf WITH(NOLOCK) ON c.Affiliateid = rf.affiliateid
	INNER JOIN dbo.TblCounties cc WITH(NOLOCK) ON cr.CNTY_NO = cc.CNTY_NO
	WHERE (Apdate BETWEEN @StartDate AND DATEADD(s,-1,DATEADD(d,1,@EndDate)))
	AND C.ClientTypeID NOT IN (4)
	AND c.IsInactive = 0
	AND cc.CNTY_NO in (5,6,18,1254,3502,3860,3903,4568)
	GROUP BY c.clno, c.name, c.State, rf.Affiliate, rf.affiliateid, cr.County, cc.CNTY_NO
	ORDER BY CLNO ASC

--select * from @CrimSearchbyCLNO


DECLARE @tempPivot TABLE 
( 
	Clno int,
	ClientName varchar(100),
	State varchar(20),
	Affiliate varchar(50),
	AffiliateID int,
	StatewideGCICStamp int,
	StatewideMI int,
	StatewideWA int,
	StatewideIN int,
	StatewideCaregiver int,
	StatePolicePA int,
	StatewideNH int,
	StatePoliceIN int
) 

Insert into @temppivot
select * from 
(
	select clno,ClientName,State,Affiliate,AffiliateID,CNTY_NO,CrimCount from @CrimSearchbyCLNO
)src
PIVOT
(
	sum(CrimCount) for CNTY_NO in ([5],[6],[18],[1254],[3502],[3860],[3903],[4568])
)pvt

select 	Clno,
	ClientName,
	State,
	Affiliate,
	AffiliateID,
	isnull(StatewideGCICStamp,0)StatewideGCICStamp,
	isnull(StatewideMI,0)StatewideMI,
	isnull(StatewideWA,0)StatewideWA,
	isnull(StatewideIN,0)StatewideIN,
	isnull(StatewideCaregiver,0)StatewideCaregiver,
	isnull(StatePolicePA,0)StatePolicePA,
	isnull(StatewideNH,0)StatewideNH,
	isnull(StatePoliceIN,0)StatePoliceIN from @temppivot order by Clno
END
