-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Modified by:	DEEPAK VODETHELA
-- Modified date: 07/29/2016
-- Description:	Count the number of Aliases for a given date range
-- execution: Exec [dbo].[AliasAveragingOnBGChecks]  '07/29/2016','07/29/2016'
-- =============================================
CREATE PROCEDURE [dbo].[AliasAveragingOnBGChecks]
	-- Add the parameters for the stored procedure here
	 @StartDate DateTime,
	 @EndDate DateTime
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	Select a.Apno, iif(rtrim(ltrim(Concat(a.last,a.middle,a.first)))='' ,0,1) +
		iif(rtrim(ltrim(Concat( alias1_last, alias1_middle, alias1_first)))='',0,1) +
		iif(rtrim(ltrim(Concat( alias2_last, alias2_middle, alias2_first)))='',0,1) +
		iif(rtrim(ltrim(Concat( alias3_last, alias3_middle, alias3_first)))='',0,1) +
		iif(rtrim(ltrim(Concat( alias4_last, alias4_middle, alias4_first)))='',0,1) As AliasCount_With_Primary,
		iif(rtrim(ltrim(Concat( alias1_last, alias1_middle, alias1_first)))='',0,1) +
		iif(rtrim(ltrim(Concat( alias2_last, alias2_middle, alias2_first)))='',0,1) +
		iif(rtrim(ltrim(Concat( alias3_last, alias3_middle, alias3_first)))='',0,1) +
		iif(rtrim(ltrim(Concat( alias4_last, alias4_middle, alias4_first)))='',0,1) As AliasCount_Without_Primary,
		iif(rtrim(ltrim(Concat(aa.first, aa.middle, aa.last)))='',0,1) As Overflow
	into #tmpAlias
	from appl as a
	left join ApplAlias as aa on a.APNO = aa.APNO
	where apDate >=@StartDate  AND  ApDate < DATEADD(day, 1,@EndDate)


	--select * from #tmpAlias


	-- Add all the Overflow aliases for a report
	select APNO, AliasCount_With_Primary , AliasCount_Without_Primary , SUM(Overflow) AS Overflow 
		into #tmpAplias1
	from #tmpAlias
	group by APNO, AliasCount_With_Primary, AliasCount_Without_Primary


	-- Add Overflow aliases to the original count
	select APNO, (AliasCount_With_Primary + Overflow) AS AliasCount_With_Primary , (AliasCount_Without_Primary + Overflow) AliasCount_Without_Primary from #tmpAplias1 ORDER BY APNO

	drop table #tmpAlias
	drop table #tmpAplias1
	

	
	 -- OLD QUERY
	 /*
	Select Apno, iif(rtrim(ltrim(Concat(last,middle,first)))='' ,0,1) +
	iif(rtrim(ltrim(Concat( alias1_last, alias1_middle, alias1_first)))='',0,1) +
	iif(rtrim(ltrim(Concat( alias2_last, alias2_middle, alias2_first)))='',0,1) +
	iif(rtrim(ltrim(Concat( alias3_last, alias3_middle, alias3_first)))='',0,1) +
	iif(rtrim(ltrim(Concat( alias4_last, alias4_middle, alias4_first)))='',0,1) As AliasCount_With_Primary,
	iif(rtrim(ltrim(Concat( alias1_last, alias1_middle, alias1_first)))='',0,1) +
	iif(rtrim(ltrim(Concat( alias2_last, alias2_middle, alias2_first)))='',0,1) +
	iif(rtrim(ltrim(Concat( alias3_last, alias3_middle, alias3_first)))='',0,1) +
	iif(rtrim(ltrim(Concat( alias4_last, alias4_middle, alias4_first)))='',0,1) As AliasCount_Without_Primary
	from appl
	where apDate >=@StartDate  AND  ApDate < DATEADD(day, 1,@EndDate)
	ORDER BY APNO
	*/
END
