
-- ============================================================================================================  
-- Author:  Suchitra Yellapantula  
-- Create date: 11/08/2016  
-- Description: Gets all the pending reports by CAM, with percentage completed and Duration in that percentage  
--              For QReport requested by Brian Silver  
-- Modified:  Radhika Dereddy on 06/06/2017 to include another column called InProgressReviewed for Brian Silver  
-- Execution:   exec PendingReportsWithPercentages_ByCAM 'Mmallory'  
-- Modified:  Radhika Dereddy on 02/04/2019 to include another column called ReopenDate for Brian Silver  
-- Modified : Humera Ahmed on 04/12/2019 to include column called Report TAT. (HDT # 50567)  
-- Modified : Humera Ahmed on 05/11/2020 to add columns Client Number, Client Name for HDT #72612.  
-- Modified : Doug DeGenaro on 10/20/2020 to move clientid column and add self disclosed column for HDT - #80002 
-- Modified	: Joshua Ates on 2/10/2021 Massive change to improve performance and reduce server load ja02102021
-- Modified : Amy Liu on 08/13/2021 for removing duplicate apno caused by this for #13503
-- Modified : James Norton on 08/23/2021 for refactoring for optimization 
-- EXEC [dbo].[PendingReportsWithPercentages_ByCAM] null ,4
  
-- ============================================================================================================  
CREATE PROCEDURE [dbo].[PendingReportsWithPercentages_ByCAM]  
	-- Add the parameters for the stored procedure here
@CAM varchar(8) = NULL,
@affiliateID Int = null
AS  
BEGIN  
 -- SET NOCOUNT ON added to prevent extra result sets from  
 -- interfering with SELECT statements.

SET NOCOUNT ON;  

BEGIN --Drop All Temp tables ja02102021

	DROP TABLE IF EXISTS #Temp_AppInfo  
	DROP TABLE IF EXISTS #Temp_CountEmpl  
	DROP TABLE IF EXISTS #Temp_CountEducat  
	DROP TABLE IF EXISTS #Temp_CountLicense  
	DROP TABLE IF EXISTS #Temp_CountRef  
	DROP TABLE IF EXISTS #Temp_CountCrim  
	DROP TABLE IF EXISTS #Temp_CountSC  
	DROP TABLE IF EXISTS #Temp_CountMVR  
	DROP TABLE IF EXISTS #Temp_CountCredit  
	DROP TABLE IF EXISTS #Temp_CountCivil  
	DROP TABLE IF EXISTS #Temp_Results  
	--DROP TABLE IF EXISTS #CompletedCount
	--DROP TABLE IF EXISTS #TotalCount
	--DROP TABLE IF EXISTS #MaxCompletedDate
	--DROP TABLE IF EXISTS #EducationCompletedCount
	--DROP TABLE IF EXISTS #EducationTotalCount
	--DROP TABLE IF EXISTS #EducationMaxCompletedDate
	--DROP TABLE IF EXISTS #LicenseCompletedCount
	--DROP TABLE IF EXISTS #LicenseTotalCount
	--DROP TABLE IF EXISTS #LicenseMaxCompletedDateCount
	--DROP TABLE IF EXISTS #ReferenceCompletedCount
	--DROP TABLE IF EXISTS #ReferenceTotalCount
	--DROP TABLE IF EXISTS #ReferenceMaxCompletedDateCount
	--DROP TABLE IF EXISTS #CriminalCompletedCount
	--DROP TABLE IF EXISTS #CriminalTotalCount
	--DROP TABLE IF EXISTS #CriminalMaxCompletedDateCount
	--DROP TABLE IF EXISTS #SanctionCompletedCount
	--DROP TABLE IF EXISTS #SanctionTotalCount
	--DROP TABLE IF EXISTS #SanctionMaxCompletedDateCount
	--DROP TABLE IF EXISTS #MVRCompletedCount
	--DROP TABLE IF EXISTS #MVRTotalCount
	--DROP TABLE IF EXISTS #MVRMaxCompletedDateCount
	--DROP TABLE IF EXISTS #CreditCompletedCount
	--DROP TABLE IF EXISTS #CreditTotalCount
	--DROP TABLE IF EXISTS #CreditMaxCompletedDateCount
	--DROP TABLE IF EXISTS #CivilCompletedCount
	--DROP TABLE IF EXISTS #CivilTotalCount
	--DROP TABLE IF EXISTS #CivilMaxCompletedDateCount

END


SELECT --Get all the Pending Apps for this CAM  Note:COLUMNS NEED TO BE LIMITED DOWN, IT WAS SELECT * NEVER DO SELECT * INTO A TEMP TABLE ja02102021 
	 [APNO]
	,[ApStatus]
	,[UserID]
	,[Billed]
	,[ApDate]
	,[CompDate]
	,a.[CLNO]
	,[PC_Time_Stamp]
	,[Pc_Time_Out]
	,[ReopenDate]
	,[OrigCompDate]
	,[InUse]
	,Attn
	,[Last_Updated]
	,[StartDate]
	,[RecruiterID]
	,[IsAutoSent]
	,[AutoSentDate]
	,a.[CreatedDate]
	,[ClientProgramID]
	,[Recruiter_Email]
	,a.[CAM]
	,[SubStatusID]
	,[GetNextDate]
	,[IsDrugTestFileFound_bit]
	,[IsDrugTestFileFound]
	,[InProgressReviewed]
	,[LastModifiedDate]
	,[LastModifiedBy]
INTO 
	#Temp_AppInfo 
FROM
	dbo.Appl A WITH(NOLOCK)
	Inner join dbo.client C (nolock) on a.clno = c.clno
WHERE 
	(@CAM is null or @CAM = '' or UserID = @CAM) and UserID is not null and ApStatus = 'P' 
	And (AffiliateID = @affiliateID or @affiliateID is null)
 
 
 BEGIN--Calculate the number of Employment components added for each of the APNOs above ja02102021

	SELECT 	T.APNO,	
			sum(case when E.SectStat not in ('0','9') then 1 else 0 end) Completed , 	
		    count(*)  Total, 
			MAX(case when E.SectStat not in ('0','9','A') then E.Last_Updated end) as 'MaxCompletedDate'
	INTO #Temp_CountEmpl  
	FROM 	#Temp_AppInfo T  
	LEFT JOIN 	dbo.Empl E WITH(NOLOCK) ON T.APNO = E.Apno
	GROUP BY T.APNO

END  
--   
BEGIN--Calculate the number of Education Components added for each of the APNOs above ja02102021



		
		SELECT T.APNO,sum(case when Ed.SectStat not in ('0','9') then 1 else 0 end) Completed , 	count(*)  Total,   MAX(case when Ed.SectStat not in ('0','9','A') then Ed.Last_Updated end) AS MaxCompletedDate
		INTO #Temp_CountEducat
		FROM #Temp_AppInfo T  WITH(NOLOCK)
		LEFT JOIN dbo.Educat Ed  WITH(NOLOCK) ON T.APNO=Ed.APNO   
		GROUP BY T.APNO  
		order by T.APNO

END 

 --   
BEGIN--Calculate the number of License components added for each of the APNOs above ja02102021
	
		SELECT T.APNO,
		Sum(case when P.SectStat not in ('0','9') then 1 else 0 end) Completed , 	
		count(*)  Total,  
		MAX(case when P.SectStat not in ('0','9','A') then P.Last_Updated end) AS MaxCompletedDate
		INTO #Temp_CountLicense  
		FROM #Temp_AppInfo T  WITH(NOLOCK)
		LEFT JOIN dbo.ProfLic P WITH(NOLOCK)	ON T.APNO=P.APNO   
		GROUP BY T.APNO  
		order by T.APNO

END

--    
  
BEGIN--Calculate the number of Reference components added for each of the APNOs above ja02102021

		SELECT T.APNO,
		Sum(case when Pr.SectStat not in ('0','9') then 1 else 0 end) Completed , 	
		count(*)  Total,  
		MAX(case when Pr.SectStat not in ('0','9','A') then Pr.Last_Updated end) AS MaxCompletedDate
		INTO #Temp_CountRef 
		FROM #Temp_AppInfo T  WITH(NOLOCK)
		LEFT JOIN 	PersRef Pr WITH(NOLOCK)	ON T.APNO=Pr.APNO  
		GROUP BY T.APNO  
		order by T.APNO

END  
--  
BEGIN--Calculate the number of Criminal Components added for each of the APNOs above ja02102021
	
		SELECT T.APNO,
		Sum(case when C.Clear='T'  then 1 else 0 end) Completed , 	
		count(*)  Total,  
		MAX(case when C.Clear = 'T' then C.Last_Updated end) AS MaxCompletedDate
		INTO #Temp_CountCrim  
		FROM #Temp_AppInfo T  WITH(NOLOCK)
		LEFT JOIN 	dbo.Crim C WITH(NOLOCK) ON T.APNO=C.APNO  
		GROUP BY T.APNO  
		order by T.APNO

END 
-- 
BEGIN--Calculate the number of Sanction Check components for each of the APNOs above ja02102021 


		SELECT T.APNO,
		Sum(case when D.SectStat not in ('0','9') then 1 else 0 end) Completed , 	
		count(*)  Total,  
		MAX(case when D.SectStat not in ('0','9','A') then D.Last_Updated end) AS MaxCompletedDate
		INTO #Temp_CountSC 
		FROM #Temp_AppInfo T  WITH(NOLOCK)
		LEFT JOIN 	dbo.MedInteg D WITH(NOLOCK) ON T.APNO=D.APNO 
		GROUP BY T.APNO  
		order by T.APNO


END
--  
BEGIN --Calculate the number of MVR components for each of the APNOs above  ja02102021

  
		SELECT T.APNO,
		Sum(case when D.SectStat not in ('0','9') then 1 else 0 end) Completed , 	
		count(*)  Total,  
		MAX(case when D.SectStat not in ('0','9','A') then D.Last_Updated end) AS MaxCompletedDate
		INTO #Temp_CountMVR
		FROM #Temp_AppInfo T  WITH(NOLOCK)
		LEFT JOIN dbo.DL D WITH(NOLOCK)	ON T.APNO=D.APNO 
		GROUP BY T.APNO  
		order by T.APNO

END
--  
BEGIN --Calculate the number of Credit components for each of the APNOs above ja02102021

  
  
		SELECT T.APNO,
		Sum(case when Ct.SectStat not in ('0','9') then 1 else 0 end) Completed , 	
		count(*)  Total,  
		MAX(case when Ct.SectStat not in ('0','9','A') then Ct.Last_Updated end) AS MaxCompletedDate
		INTO #Temp_CountCredit  
		FROM #Temp_AppInfo T  WITH(NOLOCK)
		LEFT JOIN 	dbo.Credit Ct ON T.APNO=Ct.APNO 
		GROUP BY T.APNO  
		order by T.APNO

 END
 --  
BEGIN--Calculate the number of Civil components for each of the APNOs above  ja02102021

		SELECT T.APNO,
		Sum(case when C.Clear='T'  then 1 else 0 end) Completed , 	
		count(*)  Total,  
		MAX(case when C.Clear = 'T' then C.Last_Updated end) AS MaxCompletedDate
		INTO #Temp_CountCivil  
		FROM #Temp_AppInfo T  WITH(NOLOCK)
		LEFT JOIN 	dbo.Civil C WITH(NOLOCK) ON T.APNO=C.APNO  
		GROUP BY T.APNO  
		order by T.APNO

END
  
 --   
  
select T1.UserID,T1.APNO, 
        c.CLNO, 
		c.Name,
		T1.Attn as [Recruiter Name],
		T1.ReopenDate,
		T1.InProgressReviewed, --Added columns Client Number ,Client Name for HDt#72612 by Humera Ahmed on 5/11/2020  
		--Added by Humera Ahmed on 4/12/2019 for HDT - #50567  
        dbo.elapsedbusinessdays_2(CAST(T1.ApDate AS DATE), getdate()) AS 'TurnAroundTime',  
  
       CASE WHEN (CE.Total+Ed.Total+L.Total+Cr.Total+Ct.Total+Crf.Total+SC.Total+cvl.Total+Mvr.Total) =0 then 0  
	        else  
        ((CE.Completed + Ed.Completed+L.Completed+Cr.Completed+Ct.Completed+Crf.Completed+SC.Completed+Cvl.Completed+mvr.Completed )*100)
		   /(CE.Total+Ed.Total+L.Total+Cr.Total+Ct.Total+Crf.Total+SC.Total+cvl.Total+Mvr.Total)  end  as 'Percentage Completed', 
	  (SELECT MAX(v)   
	      FROM (VALUES (CE.MaxCompletedDate), (Ed.MaxCompletedDate), (L.MaxCompletedDate), (Cr.MaxCompletedDate), (Ct.MaxCompletedDate), (Crf.MaxCompletedDate), (SC.MaxCompletedDate), (Cvl.MaxCompletedDate), (Mvr.MaxCompletedDate)) as value(v)  
	       ) as 'MaxCompletedDate'  
	into #Temp_Results  
	from #Temp_AppInfo T1  
	INNER JOIN client c ON T1.CLNO = C.CLNO  --Added columns Client Number ,Client Name for HDt#72612 by Humera Ahmed on 5/11/2020  
	inner join #Temp_CountEmpl CE on t1.APNO = CE.APNO  
	inner join #Temp_CountEducat Ed on t1.APNO = Ed.APNO  
	inner join #Temp_CountLicense L on t1.APNO = L.APNO  
	inner join #Temp_CountCrim Cr on Cr.APNO = T1.APNO  
	inner join #Temp_CountCredit Ct on Ct.APNO = t1.APNO  
	inner join #Temp_CountRef Crf on Crf.APNO = T1.APNO  
	inner join #Temp_CountSC SC on SC.APNO = T1.APNO  
	inner join #Temp_CountCivil Cvl on cvl.APNO = T1.APNO  
	inner join #Temp_CountMVR mvr on mvr.APNO = T1.APNO  
  
 --  
  
select distinct 
	T.UserID as 'CAM',
	T.APNO, 
	T.CLNO [Client ID#], 
	T.Name [Client Name],
	T.[Recruiter Name],
	(CASE WHEN (T.reopendate) IS NULL THEN 'False' ELSE 'True' End) AS Reopened, --Added columns Client ID# ,Client Name for HDt#72612 by Humera Ahmed on 5/11/2020
	--case when IsNull(applData.Crim_SelfDisclosed,0) = 0 then 'False' else 'True' end as AdmittedRecord, --Added by Doug DeGenaro on 10/20/2020 for HDT - #80002
	 case when sum(isnull(cast(applData.Crim_SelfDisclosed as int),0) )=0 then 0 else 1  end as AdmittedRecord,  --Modified by Amy Liu on 08/13/2021 for removing duplicate apno caused by this for #13503
	(case when T.InProgressReviewed = 0 then 'False' else 'True' end) as InProgressReviewed,
	T.[Percentage Completed], 
	(CASE WHEN (T.MaxCompletedDate) IS NULL THEN '' ELSE ([dbo].ElapsedBusinessDays(T.MaxCompletedDate, GetDate())) end) as 'BusinessDaysInThisPercentage' ,--Added by Humera Ahmed on 4/12/2019 for HDT - #50567   
	T.TurnAroundTime [Report TAT]  
from #Temp_Results T
left join [dbo].[ApplAdditionalData] appldata on T.APNO  = applData.APNO  --Added by Doug DeGenaro on 10/20/2020 for HDT - #80002  
group by T.UserID ,T.APNO, T.CLNO, T.Name,T.[Recruiter Name],T.reopendate ,T.InProgressReviewed,T.[Percentage Completed],T.MaxCompletedDate,T.TurnAroundTime
order by 1  
  
   
END 

