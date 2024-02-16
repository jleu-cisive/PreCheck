-- ============================================================================================================  
-- Author:  Suchitra Yellapantula  
-- Create date: 11/08/2016  
-- Description: Gets all the pending reports by CAM, with percentage completed and Duration in that percentage  
--              For QReport requested by Brian Silver  
-- Modified: Radhika Dereddy on 06/06/2017 to include another column called InProgressReviewed for Brian Silver  
-- Execution:   exec PendingReportsWithPercentages_ByCAM 'Mmallory'  
-- Modified: Radhika Dereddy on 02/04/2019 to include another column called ReopenDate for Brian Silver  
-- Modified : Humera Ahmed on 04/12/2019 to include column called Report TAT. (HDT # 50567)  
-- Modified : Humera Ahmed on 05/11/2020 to add columns Client Number, Client Name for HDT #72612.  
-- Modified : Doug DeGenaro on 10/20/2020 to move clientid column and add self disclosed column for HDT - #80002 
-- EXEC [dbo].[PendingReportsWithPercentages_ByCAM] null 
  
-- ============================================================================================================  
CREATE PROCEDURE [dbo].[PendingReportsWithPercentages_ByCAM_02112021]  
	-- Add the parameters for the stored procedure here
    @CAM varchar(8)
AS  
BEGIN  
 -- SET NOCOUNT ON added to prevent extra result sets from  
 -- interfering with SELECT statements.  
 SET NOCOUNT ON;  
  
--Get all the Pending Apps for this CAM  
select * into #Temp_AppInfo from Appl where (@CAM is null or @CAM = '' or UserID = @CAM) and UserID is not null and ApStatus = 'P'  
  
  
--Calculate the number of Employment components added for each of the APNOs above  
SELECT T.APNO,  
(select COUNT(*) from Empl E1 inner join #Temp_AppInfo T1 on T1.APNO = E1.APNO where (E1.SectStat <> '0' and E1.SectStat <> '9' and E1.APNO = T.APNO)) as 'Completed',  
(select COUNT(*) from Empl E1 inner join #Temp_AppInfo T1 on T1.APNO = E1.APNO where E1.APNO = T.APNO) as 'Total',  
MAX(case when E.SectStat not in ('0','9','A') then E.Last_Updated end) as 'MaxCompletedDate'  
INTO #Temp_CountEmpl  
FROM #Temp_AppInfo T  
LEFT JOIN Empl E on T.APNO = E.Apno  
GROUP BY T.APNO  
  
  
  
--Calculate the number of Education Components added for each of the APNOs above  
SELECT T.APNO,  
(select COUNT(*) from Educat Ed1 inner join #Temp_AppInfo T1 on T1.APNO = Ed1.APNO where (Ed1.SectStat <> '0' and Ed1.SectStat <> '9' and Ed1.APNO = T.APNO)) as 'Completed',  
(select COUNT(*) from Educat Ed1 inner join #Temp_AppInfo T1 on T1.APNO = Ed1.APNO where Ed1.APNO = T.APNO) as 'Total',  
--COUNT(Case when (Ed.SectStat='0' or Ed.SectStat='9' or Ed.SectStat='A') then 0 else 1 end) as 'Completed', COUNT(1) as 'Total',   
MAX(case when Ed.SectStat not in ('0','9','A') then Ed.Last_Updated end) as 'MaxCompletedDate'  
INTO #Temp_CountEducat  
FROM #Temp_AppInfo T  
LEFT JOIN Educat Ed ON T.APNO=Ed.APNO   
GROUP BY T.APNO  
  
  
--Calculate the number of License components added for each of the APNOs above  
SELECT T.APNO,  
(select COUNT(*) from ProfLic P1 inner join #Temp_AppInfo T1 on T1.APNO = P1.APNO where (P1.SectStat <> '0' and P1.SectStat <> '9' and P1.APNO = T.APNO)) as 'Completed',  
(select COUNT(*) from ProfLic P1 inner join #Temp_AppInfo T1 on T1.APNO = P1.APNO where P1.APNO = T.APNO) as 'Total',  
MAX(case when P.SectStat not in ('0','9','A') then P.Last_Updated end) as 'MaxCompletedDate'  
INTO #Temp_CountLicense  
FROM #Temp_AppInfo T  
LEFT JOIN ProfLic P ON T.APNO=P.APNO  
GROUP BY T.APNO  
  
  
--Calculate the number of Reference components added for each of the APNOs above  
SELECT T.APNO,   
(select COUNT(*) from PersRef P1 inner join #Temp_AppInfo T1 on T1.APNO = P1.APNO where (P1.SectStat <> '0' and P1.SectStat <> '9' and P1.APNO = T.APNO)) as 'Completed',  
(select COUNT(*) from PersRef P1 inner join #Temp_AppInfo T1 on T1.APNO = P1.APNO where P1.APNO = T.APNO) as 'Total',  
MAX(case when Pr.SectStat not in ('0','9','A') then Pr.Last_Updated end) as 'MaxCompletedDate'   
INTO #Temp_CountRef  
FROM #Temp_AppInfo T  
LEFT JOIN PersRef Pr ON T.APNO=Pr.APNO   
GROUP BY T.APNO  
  
--Calculate the number of Criminal Components added for each of the APNOs above  
SELECT T.APNO,   
(select COUNT(*) from Crim C1 inner join #Temp_AppInfo T1 on T1.APNO = C1.APNO where (C1.Clear='T' and C1.APNO = T.APNO)) as 'Completed',  
(select COUNT(*) from Crim C1 inner join #Temp_AppInfo T1 on T1.APNO = C1.APNO where C1.APNO = T.APNO) as 'Total',  
MAX(case when C.Clear = 'T' then C.Last_Updated end) as 'MaxCompletedDate'   
INTO #Temp_CountCrim  
FROM #Temp_AppInfo T  
LEFT JOIN Crim C ON T.APNO=C.APNO  
GROUP BY T.APNO  
  
--Calculate the number of Sanction Check components for each of the APNOs above  
SELECT T.APNO,  
(select COUNT(*) from MedInteg M1 inner join #Temp_AppInfo T1 on T1.APNO = M1.APNO where (M1.SectStat <> '0' and M1.SectStat <> '9' and M1.APNO = T.APNO)) as 'Completed',  
(select COUNT(*) from MedInteg M1 inner join #Temp_AppInfo T1 on T1.APNO = M1.APNO where M1.APNO = T.APNO) as 'Total',   
MAX(case when M.SectStat not in ('0','9','A') then M.Last_Updated end) as 'MaxCompletedDate'  
INTO #Temp_CountSC  
FROM #Temp_AppInfo T  
LEFT JOIN MedInteg M ON T.APNO=M.APNO   
GROUP BY T.APNO  
  
--Calculate the number of MVR components for each of the APNOs above  
SELECT T.APNO,   
(select COUNT(*) from DL D1 inner join #Temp_AppInfo T1 on T1.APNO = D1.APNO where (D1.SectStat <> '0' and D1.SectStat <> '9' and D1.APNO = T.APNO)) as 'Completed',  
(select COUNT(*) from DL D1 inner join #Temp_AppInfo T1 on T1.APNO = D1.APNO where D1.APNO = T.APNO) as 'Total',   
MAX(case when D.SectStat not in ('0','9','A') then D.Last_Updated end) as 'MaxCompletedDate'  
INTO #Temp_CountMVR  
FROM #Temp_AppInfo T  
LEFT JOIN DL D ON T.APNO=D.APNO   
GROUP BY T.APNO;  
  
--Calculate the number of Credit components for each of the APNOs above  
SELECT T.APNO,   
(select COUNT(*) from Credit C1 inner join #Temp_AppInfo T1 on T1.APNO = C1.APNO where (C1.SectStat <> '0' and C1.SectStat <> '9' and C1.APNO = T.APNO)) as 'Completed',  
(select COUNT(*) from Credit C1 inner join #Temp_AppInfo T1 on T1.APNO = C1.APNO where C1.APNO = T.APNO) as 'Total',   
MAX(case when Ct.SectStat not in ('0','9','A') then Ct.Last_Updated end) as 'MaxCompletedDate'   
INTO #Temp_CountCredit   
FROM #Temp_AppInfo T  
LEFT JOIN Credit Ct ON T.APNO=Ct.APNO   
GROUP BY T.APNO  
  
  
--Calculate the number of Civil components for each of the APNOs above  
SELECT T.APNO,   
(select COUNT(*) from Civil C1 inner join #Temp_AppInfo T1 on T1.APNO = C1.APNO where (C1.Clear='T' and C1.APNO = T.APNO)) as 'Completed',  
(select COUNT(*) from Civil C1 inner join #Temp_AppInfo T1 on T1.APNO = C1.APNO where C1.APNO = T.APNO) as 'Total',   
MAX(case when C.Clear = 'T' then C.Last_Updated end) as 'MaxCompletedDate'   
INTO #Temp_CountCivil  
FROM #Temp_AppInfo T  
LEFT JOIN Civil C ON T.APNO=C.APNO   
GROUP BY T.APNO  
  
  
  
select T1.UserID,T1.APNO, c.CLNO, c.Name,T1.Attn as [Recruiter Name],T1.ReopenDate,T1.InProgressReviewed, --Added columns Client Number ,Client Name for HDt#72612 by Humera Ahmed on 5/11/2020  
--Added by Humera Ahmed on 4/12/2019 for HDT - #50567  
dbo.elapsedbusinessdays_2(CAST(T1.ApDate AS DATE), getdate()) AS 'TurnAroundTime',  
  
'Percentage Completed' =   
CASE WHEN (CE.Total+Ed.Total+L.Total+Cr.Total+Ct.Total+Crf.Total+SC.Total+cvl.Total+Mvr.Total) =0 then 0  
else  
((CE.Completed + Ed.Completed+L.Completed+Cr.Completed+Ct.Completed+Crf.Completed+SC.Completed+Cvl.Completed+mvr.Completed )*100)/(CE.Total+Ed.Total+L.Total+Cr.Total+Ct.Total+Crf.Total+SC.Total+cvl.Total+Mvr.Total)  
end,   
(  
  SELECT MAX(v)   
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
  
  
  
select distinct T.UserID as 'CAM',T.APNO, T.CLNO [Client ID#], T.Name [Client Name],T.[Recruiter Name], (CASE WHEN (T.reopendate) IS NULL THEN 'False' ELSE 'True' End) AS Reopened, --Added columns Client ID# ,Client Name for HDt#72612 by Humera Ahmed on 5/11/2020
case when IsNull(applData.Crim_SelfDisclosed,0) = 0 then 'False' else 'True' end as AdmittedRecord, --Added by Doug DeGenaro on 10/20/2020 for HDT - #80002  
(case when T.InProgressReviewed = 0 then 'False' else 'True' end) as InProgressReviewed, T.[Percentage Completed], (CASE WHEN (T.MaxCompletedDate) IS NULL THEN '' ELSE ([dbo].ElapsedBusinessDays(T.MaxCompletedDate, GetDate())) end) as 'BusinessDaysInThisPercentage'  
--Added by Humera Ahmed on 4/12/2019 for HDT - #50567  
, T.TurnAroundTime [Report TAT]  
from #Temp_Results T
--Added by Doug DeGenaro on 10/20/2020 for HDT - #80002  
left join [dbo].[ApplAdditionalData] appldata on T.APNO  = applData.APNO  
order by 1  
  
  
  
  
Drop table #Temp_AppInfo  
Drop table #Temp_CountEmpl  
Drop table #Temp_CountEducat  
Drop table #Temp_CountLicense  
Drop table #Temp_CountRef  
Drop table #Temp_CountCrim  
Drop table #Temp_CountSC  
Drop table #Temp_CountMVR  
Drop table #Temp_CountCredit  
Drop table #Temp_CountCivil  
drop table #Temp_Results  
  
  
END 
