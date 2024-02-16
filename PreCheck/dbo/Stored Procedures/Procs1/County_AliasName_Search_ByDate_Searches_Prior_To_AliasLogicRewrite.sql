-- Alter Procedure County_AliasName_Search_ByDate_Searches_Prior_To_AliasLogicRewrite

/*

Modified By: Deepak Vodethela
Modified Date: 05/19/2017
Description: Names sent to Vendor - based on Old structure
Execution:  EXEC [County_AliasName_Search_ByDate_Searches_Prior_To_AliasLogicRewrite] 'Henn','MN','05/01/2017','05/19/2017'
			EXEC [County_AliasName_Search_ByDate_Searches_Prior_To_AliasLogicRewrite] 'SEX OFFENDER','US','04/21/2017','04/21/2017'
*/

CREATE PROCEDURE [dbo].[County_AliasName_Search_ByDate_Searches_Prior_To_AliasLogicRewrite] 

@County varchar(50),
@State varchar(2),
@StartDate datetime,
@EndDate datetime

AS

Select Min(crimID)crimID,c.Apno,c.County 
		into #temp2 
from  crim c  WITH (NOLOCK) 
INNER JOIN dbo.TblCounties cc  WITH (NOLOCK) ON c.cnty_no = cc.cnty_no 
where  (IrisOrdered between @StartDate and dateadd(d,1,@EndDate ))
AND (cc.State like '%' + ISNULL(@State, '') + '%')
AND (cc.a_county like '%' + ISNULL(@County, '') + '%')
group by c.Apno,c.County

--Select * from #temp2

Select  a.APNO,  ApDate, CompDate,c.IrisOrdered,
		a.CLNO, client.Name, Last, First, Middle, 
		Alias1_Last, Alias1_First, Alias1_Middle, Alias1_Generation, 
		Alias2_Last, Alias2_First, Alias2_Middle, Alias2_Generation,
		Alias3_Last, Alias3_First, Alias3_Middle, Alias3_Generation,
		Alias4_Last, Alias4_First, Alias4_Middle, Alias4_Generation,
		txtalias, txtalias2, txtalias3, txtalias4, 
		txtlast, CRIM_SpecialInstr, CrimID,cc.County as A_County, r.R_Name AS Vendor_Name 
	into #temp1
from Appl a  WITH (NOLOCK) 
inner join crim c  WITH (NOLOCK) on a.apno = c.apno 
inner join client  WITH (NOLOCK) on a.clno = client.clno 
INNER JOIN dbo.TblCounties cc  WITH (NOLOCK) ON c.cnty_no = cc.cnty_no 
INNER JOIN Iris_Researchers r WITH (NOLOCK) ON c.vendorid = r.R_id
where Crimid in (Select Crimid from #temp2)
order by a.apno 

--select * from #temp1

Select  APNO,  ApDate, CompDate, IrisOrdered, CLNO, Name as 'Client Name', A_County, Vendor_Name, First, Middle, Last, CRIM_SpecialInstr from
(
	Select  APNO, ApDate, CompDate, IrisOrdered, CLNO, Name, A_County, Vendor_Name, First, isnull(Middle,'') Middle, Last, isnull(CRIM_SpecialInstr,'') CRIM_SpecialInstr from #temp1 where  txtlast = 1
		UNION ALL
	Select  APNO, ApDate, CompDate, IrisOrdered, CLNO, Name, A_County, Vendor_Name, Alias1_First First, isnull(Alias1_Middle,'') Middle, Alias1_Last Last, isnull(CRIM_SpecialInstr,'') CRIM_SpecialInstr from #temp1 where  txtalias = 1
		UNION ALL
	Select  APNO, ApDate, CompDate, IrisOrdered, CLNO, Name, A_County, Vendor_Name, Alias2_First First, isnull(Alias2_Middle,'') Middle, Alias2_Last Last, isnull(CRIM_SpecialInstr,'') CRIM_SpecialInstr from #temp1 where  txtalias2 = 1
		UNION ALL
	Select  APNO, ApDate, CompDate, IrisOrdered, CLNO, Name, A_County, Vendor_Name, Alias3_First First, isnull(Alias3_Middle,'') Middle, Alias3_Last Last, isnull(CRIM_SpecialInstr,'') CRIM_SpecialInstr from #temp1 where  txtalias3 = 1
		UNION ALL
	Select  APNO, ApDate, CompDate, IrisOrdered, CLNO, Name, A_County, Vendor_Name, Alias4_First First, isnull(Alias4_Middle,'') Middle, Alias4_Last Last, isnull(CRIM_SpecialInstr,'') CRIM_SpecialInstr from #temp1 where  txtalias4 = 1
)Z 
order by apno

drop table #temp1
drop Table #temp2

	/*
	SELECT Min(CrimID) crimID, c.Apno, c.County 
			INTO #temp2 
	FROM Crim AS c WITH (NOLOCK) 
	INNER JOIN counties AS cc WITH (NOLOCK) ON c.cnty_no = cc.cnty_no 
	WHERE (IrisOrdered BETWEEN @StartDate AND DATEADD(D,1,@EndDate ))
	  AND (cc.State like '%' + ISNULL(@State, '') + '%')
	  AND (cc.a_county like '%' + ISNULL(@County, '') + '%')
	GROUP BY c.Apno,c.County

	--Select * from #temp2

	SELECT  a.APNO,  ApDate, CompDate,c.IrisOrdered,
			a.CLNO, client.Name AS ClientName, cc.County as A_County, r.R_Name AS Vendor_Name,
			ISNULL(AA.Last,'') Last, ISNULL(AA.First,'') First,  ISNULL(AA.Middle,'') Middle,
			ISNULL(CRIM_SpecialInstr,'') CRIM_SpecialInstr
			INTO #temp1
	FROM Appl AS a WITH (NOLOCK) 
	INNER JOIN dbo.crim AS c  WITH (NOLOCK) on a.apno = c.apno 
	INNER JOIN dbo.ApplAlias_Sections AS S (NOLOCK) ON S.SectionKeyID = C.CrimID AND S.ApplSectionID = 5 AND S.IsActive = 1
	INNER JOIN ApplAlias AS AA(NOLOCK) ON AA.ApplAliasID = S.ApplAliasID
	INNER JOIN dbo.client WITH (NOLOCK) on a.clno = client.clno 
	INNER JOIN dbo.counties AS cc  WITH (NOLOCK) ON c.cnty_no = cc.cnty_no 
	INNER JOIN Iris_Researchers AS r WITH (NOLOCK) ON c.vendorid = r.R_id
	WHERE Crimid IN (SELECT Crimid FROM #temp2)

	SELECT * FROM #temp1 ORDER BY APNO
	*/

 -- VD-04/24/2017 - Old Structure


set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
