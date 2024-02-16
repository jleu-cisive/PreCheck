-- =============================================
-- Author:		Joshua Ates
-- Create date: 9/20/2021
-- Description:	Crimninal counts by Affiliates
-- EXEC [QReport_CriminalComponentCountByDateAndAffiliate] NULL, '01/12/2012', '01/12/2012'
-- =============================================


CREATE PROCEDURE dbo.[QReport_CriminalComponentCountByDateAndAffiliate]
 @StartDate DateTime			--= '01/12/2012'
,@EndDate DateTime				--= '01/12/2012'
,@AffiliateID VARCHAR(MAX)		= null

as
BEGIN

if(@AffiliateID = '' OR LOWER(@AffiliateID) = 'null') Begin  SET @AffiliateID = NULL  END

	 Select APNO  into #temp1 from APPL where 
	 --clno = @AffiliateID  --commented by Radhika
	 (@AffiliateID IS NULL OR clno IN (SELECT * from [dbo].[Split](',',@AffiliateID))) and apdate between @StartDate and DateAdd(d,1,@EndDate)
 
    SELECT DISTINCT 
		 Crim.Apno
		,CNTY_NO 
	INTO #temp2 
	FROM Crim (NOLOCK) 
	INNER JOIN
		 #temp1 AS ApNos
		 ON Crim.APNO = ApNos.APNO
	WHERE 
		 ishidden = 0 

	select
		 refAffiliate.Affiliate
		,refAffiliate.AffiliateID
		,isnull(crimcount,0) as[Criminal Searches]
		,isnull(Emplcount,0) as [Employment Verifications]
		,isnull(Educatcount,0) as [Education Verifications]
		,isnull(Licensecount,0) as [License Verifications]
		,isnull(Socialcount,0) as PID
		,isnull(MedicareCount,0) as SanctionCheck
		,isnull(MVRcount,0) as MVR
		,isnull(Creditcount,0) as [Credit Report]
		,isnull(Referencecount,0) as [Personal References]
		,isnull(Civilcount,0) as [Civil Searches]
	INTO #temp3
	FROM client c (NOLOCK) 
	INNER JOIN
		refAffiliate
		ON C.AffiliateID = refAffiliate.AffiliateID
	INNER JOIN 
		appl a (NOLOCK) 
		on c.clno=a.clno 
	LEFT JOIN 
		(select apno,count(1) crimcount from #temp2 group by apno) crim 
		on a.apno = crim.apno
	LEFT JOIN 
		(select apno,count(1) Emplcount from Empl (NOLOCK) where Empl.IsOnReport = 1 and empl.ishidden = 0 group by apno) Empl 
		on a.apno = Empl.apno
	LEFT JOIN 
		(select apno,count(1) Educatcount from Educat (NOLOCK) where Educat.IsOnReport = 1 and educat.ishidden = 0 group by apno) Educat 
		on a.apno = Educat.apno
	LEFT JOIN 
		(select apno,count(1) Licensecount from ProfLic (NOLOCK) where ProfLic.IsOnReport = 1 and proflic.ishidden = 0 group by apno) ProfLic 
		on a.apno = ProfLic.apno
	LEFT JOIN 
		(select apno,count(1) Socialcount from Credit (NOLOCK) where  Credit.reptype = 'S' group by apno) Social 
		on a.apno = Social.apno
	LEFT JOIN 
		(select apno,count(1) MVRcount from DL (NOLOCK) group by apno) DL 
		on a.apno = DL.apno
	LEFT JOIN 
		(select apno,count(1) MedicareCount from MedInteg (NOLOCK) group by apno) MedInteg 
		on a.apno = MedInteg.apno
	LEFT JOIN 
		(select apno,count(1) Creditcount from Credit (NOLOCK) where  reptype = 'C' group by apno) Credit 
		on a.apno = Credit.apno
	LEFT JOIN 
		(select apno,count(1) Referencecount from PersRef (NOLOCK) where PersRef.IsOnReport = 1 and persref.ishidden = 0 group by apno) PersRef 
		on a.apno = PersRef.apno 
	LEFT JOIN 
		(select apno,count(1) Civilcount from Civil (NOLOCK) group by apno) Civil 
		on a.apno = Civil.apno 
	LEFT JOIN 
		InvDetail Inv (NOLOCK) 
		on Inv.APNO = a.APNO 
		and type=0
	LEFT JOIN 
		packagemain p (NOLOCK) 
		on a.PackageID = P.PackageID
	WHERE
		(@AffiliateID IS NULL OR refAffiliate.AffiliateID IN (SELECT * from [dbo].[Split](':',@AffiliateID)))
		 and apdate between @StartDate and DateAdd(d,1,@EndDate) --(--3041--) and apdate between --'01/01/06'-- and DateAdd(d,1,--'12/31/06'--)
	ORDER BY 
		 refAffiliate.Affiliate
		,refAffiliate.AffiliateID

	
	SELECT 
		 Affiliate
		,AffiliateID
		,[MVR]						=	SUM([MVR])
		,[Criminal Searches]		=	SUM([Criminal Searches])
		,[Employment Verifications]	=	SUM([Employment Verifications])
		,[Education Verifications]	=	SUM([Education Verifications])
		,[License Verifications]	=	SUM([License Verifications])
		,[PID]						=	SUM([PID])
		,[SanctionCheck]			=	SUM([SanctionCheck])
		,[Credit Report]			=	SUM([Credit Report])
		,[Personal References]		=	SUM([Personal References])
		,[Civil Searches]			=	SUM([Civil Searches])
	 FROM 
		#temp3
	 GROUP BY 
		 Affiliate
		,AffiliateID
	 ORDER BY 
		Affiliate ASC

drop table #temp1
drop table #temp2
drop table #temp3


END
