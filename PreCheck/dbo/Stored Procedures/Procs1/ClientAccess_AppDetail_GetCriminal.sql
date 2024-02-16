
-- =============================================
-- Author:		Kiran Miryala
-- Create date: 07-21-2008
-- Description:	 Gets criminal Details for the client in Check Reports
-- Modified by schapyala on 04/25/2014
-- [dbo].[ClientAccess_AppDetail_GetCriminal] 3993283, 0, 12771
-- Modified By : Radhika Dereddy on 12/20/2018
-- Modified reason: When ETA project went Live the Adjudication Process was impacted(broken), so now making the changes to the Stored procedure to accommodate the functionality of the
-- Adjudication clients, Non adjudicatio clients and the ETA (Estimated Time Aggregate)process so all the statuses are displayed as intended.
-- Remove the fucntionality specific to AffiliateID 10 (which is 12444 - Tenet) -- this fucntionality is across the clients and not just for one client.
-- Remove the bit field for @HasETA, this is a varchar value
--Modified by Schapyala on 03/27/2020 to add crimdescription (status) as well as support for C,A,S statuses
-- =============================================

CREATE PROCEDURE [dbo].[ClientAccess_AppDetail_GetCriminal]
@apno int ,
@AdjudicationProcess bit = 0,
@clno int = 0

AS
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

 Declare @HasETA varchar(10)
 SET @HasETA = (Select ISNULL((Select Value from ClientConfiguration where CLNO = @clno AND ConfigurationKey = 'Report_&_Component_ETA_Display_In_Client_Access'), 'false'))

DECLARE @tmpCrim table(  
    CrimID int NOT NULL,  
    Degree varchar(1), 
	Description varchar(50), 
    Clear varchar(1),  
    Apno int,
	County varchar(50),
	ManagerReviewed int,
	ClientAdjudicationStatus varchar(50),
	Disp_Date DateTime,
	Date_Filed DateTime,
	ETADate varchar(20)

	)

	INSERT INTO @tmpCrim
	(
	    CrimID,
	    Degree,
		Description,
	    Clear,
	    Apno,
	    County,
	    ManagerReviewed,
	    ClientAdjudicationStatus,
	    Disp_Date,
	    Date_Filed,
	    ETADate
	)
	
SELECT distinct
Crim.CrimID,
Crim.Degree, ISNULL(rf.Description, '') as 'Description',
Case when [Clear] in ('T','F','P','C','A','S','1') then [Clear] else 'V' end [Clear],
Crim.APNO, Counties.A_County + ', ' + Counties.State AS county,
(CASE WHEN (Adj.ReviewDate_MGR is null ) THEN (case when ISNULL(AdjStatus.DisplayName, '' )='' then 0 else 1 end )ELSE 1 END) ManagerReviewed,
CASE when AdjStatusCustom.DisplayName is not null then AdjStatusCustom.DisplayName else ISNULL(AdjStatus.DisplayName, '' ) end as ClientAdjudicationStatus 
,Disp_Date,Date_Filed,
CASE WHEN LOWER(@HasETA) = 'true' THEN
	CASE WHEN CAST(eta.ETADate AS DATE) < CAST(CURRENT_TIMESTAMP AS DATE) THEN 'ETA Unavailable' 
		 ELSE 'ETA: ' + LEFT(CONVERT(VARCHAR, eta.ETADate, 101), 10) 
	END
ELSE '' end AS ETADate
FROM dbo.Crim (NOLOCK)
INNER JOIN dbo.Counties(NOLOCK) ON Crim.CNTY_NO = Counties.CNTY_NO 
LEFT JOIN refCrimDegree rf(NOLOCK) ON Crim.Degree = rf.refCrimDegree
INNER JOIN APPL A(NOLOCK) on a.apno  = crim.apno
LEFT JOIN dbo.ClientAdjudicationStatus AdjStatus(NOLOCK) ON Crim.ClientAdjudicationStatus = AdjStatus.ClientAdjudicationStatusID
LEFT JOIN dbo.ClientAdjudicationStatusCustom AdjStatusCustom(NOLOCK) ON AdjStatusCustom.clno = a.clno and Crim.ClientAdjudicationStatus = AdjStatusCustom.ClientAdjudicationStatusID
LEFT JOIN  dbo.ApplAdjudicationAuditTrail Adj(NOLOCK) ON Crim.APNO = Adj.APNO AND Crim.CrimID = Adj.SectionID  AND ApplSectionID = 5 
LEFT JOIN dbo.ApplSectionsETA eta(NOLOCK) ON eta.Apno = A.APNO AND eta.SectionKeyID = crim.CrimID AND eta.ApplSectionID = 5
WHERE 
ishidden = 0 AND Crim.APNO = @apno
AND ISNULL(Crim.Clear,'zz') <> 'I'


DECLARE @Apstatus varchar(1) , @AffiliateID int
Select @Apstatus = Apstatus From Appl where APNO = @apno
SELECT @AffiliateID = AffiliateID FROM  dbo.Client WHERE CLNO = @clno

If @Apstatus <> 'F' and @AffiliateID = 4
Begin
	update @tmpCrim set Clear = 'V' where Clear = 'F' and 
	((Degree = 'O'or degree= 'U' or isnull(degree,'') = '' or  Degree in ('1','2','3','4','5','6','7','8','9','M') ) and (( (isnull(Disp_Date,'') = '' ) and (isnull(Date_Filed,'') = '' ))
	 or ((isnull(Disp_Date,'') = '' ) and (CONVERT (date, Date_Filed) <  DATEADD(yyyy,-7,CONVERT (date, CURRENT_TIMESTAMP))))
	 or ((CONVERT (date, Disp_Date)) <  DATEADD(yyyy,-7,CONVERT (date, CURRENT_TIMESTAMP)) and (CONVERT (date, Date_Filed) <  DATEADD(yyyy,-7,CONVERT (date, CURRENT_TIMESTAMP))))
	 ))
	and CrimID not in (select Crimid from dbo.[Crim_ReviewReportabilityLog] where Apno = @apno)

End

Update @tmpCrim set Degree = Null,Description = '' where  Clear = 'V'


--Modified by Schapyala on 03/27/2020 to add crimdescription (status) as well as support for C,A,S statuses
Select CrimID, Degree, Description, Clear,APNO,County,ManagerReviewed,ClientAdjudicationStatus,ETADate,crimdescription--,ReportedStatus_Integration
From (
SELECT min(CrimID) CrimID,Degree, Description, [Clear],APNO,county,ManagerReviewed,ClientAdjudicationStatus, ETADate
FROM @tmpCrim 
Group By Degree,[Clear],Description,APNO,county,ManagerReviewed,ClientAdjudicationStatus, ETADate
Having Clear not in ('F','P','C','A','S','1')
UNION ALL
SELECT CrimID,Degree,Description, [Clear],APNO,county,ManagerReviewed,ClientAdjudicationStatus, ETADate
FROM @tmpCrim
WHERE Clear in ('F','P','C','A','S','1')
) Qry  inner join dbo.crimsectstat cs on isnull(Qry.Clear,'') = isnull(crimsect,'')

--Drop table @tmpCrim

SET TRANSACTION ISOLATION LEVEL READ COMMITTED
SET NOCOUNT OFF






