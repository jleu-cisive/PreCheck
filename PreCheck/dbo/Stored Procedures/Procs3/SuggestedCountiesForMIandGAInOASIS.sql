-- =============================================
-- Author:		Radhika Dereddy
-- Create date: 08/23/2018
-- Description: Requester Ryan trevino- I am requesting a report that could pull the number of suggested Georgia and Michigan county searches since 01/01/2018.  
-- For example, when an applicant has had any sort of history in these states, our system looks up the cities, towns, and zip codes
-- to determine the corresponding county level searches.  These are listed in OASIS.  AIMI automatically converts these to 
-- the statewide (GA and MI) respectively, so wherever the county level searches from OASIS are housed/stored, then that is probably
-- where you would pull from.  Preferably I would like the report to have a column for Report Number, GA Counties, and MI counties. 

-- EXEC CrimSearchesByCounty '01/01/2008','08/23/2018' 
-- =============================================
CREATE PROCEDURE [dbo].[SuggestedCountiesForMIandGAInOASIS]
	-- Add the parameters for the stored procedure here
	@StartDate datetime,
	@EndDate datetime
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	
CREATE TABLE #CountySearchByState
(
	APNO int,
	CLNO int,
	State varchar(2),
	City varchar(50),
	Zip varchar(5)
)


    INSERT INTO  #CountySearchByState
	SELECT A.APNO, A.clno, a.State, a.City, a.Zip
	FROM Appl a	
	WHERE (a.Apdate between @StartDate AND @EndDate	)
	AND (a.State ='MI') OR (a.State ='GA')
	ORDER BY APNO DESC

	--SELECT * FROM #CountySearchByState 

	SELECT DISTINCT t.COUNTY as 'SuggestedCounty', t.STATE 'SuggestedState', c.APNO, c.CLNO, c.City as 'ResidentialCity', C.State as 'ResidentialState'
	FROM [County].dbo.tblCountyLookup t (NOLOCK)
	INNER JOIN #CountySearchByState c (NOLOCK) ON t.place = c.City and t.State = c.State
	ORDER BY c.APNO DESC
	
	DROP TABLE #CountySearchByState

END
