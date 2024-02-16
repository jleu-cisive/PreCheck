
  --select * from [EAPI].[ReportPercentagesByAPNO](6324429) 
  
 -- =============================================  
-- Author:  Nikhil Vairat  
-- Create date: 08/22/2023  
-- Description: Function to receive report perstages by apno   
-- =============================================  
-- Author:  Doug DeGenaro/Dongmei He  
-- Create date: 09/01/2023  
-- Description: Fixed percentage to match with what client access shows
-- Modifed by Lalit on 01/29/2024 for #123894
-- ============================================= 

--declare @apno  int = 7607040-- 7605715-- 7605636 --7607561 --7605636 --7605715-- 7606093 --7605715 --7605636 --7607040 --7606749 --7567384
CREATE FUNCTION [EAPI].[ReportPercentagesByAPNO2](@APNO int) 
returns @PercentagesResult table   
(  
          [CAM] varchar(8),              
          [Report Number] int,               
          [Client ID] int,                     
          [Client Name] varchar(100),               
          [Recruiter Name] varchar(100),              
          [Reopened] varchar(20),               
          [Admitted] varchar(10),              
          [InProgressReviewed] varchar(20),
		  [Credit] int,               
          [Percentage Completed] int,              
          [BusinessDaysInThisPercentage] varchar(10),               
          [Report TAT] int              
)  

AS   
  
begin
DECLARE @Temp_AppInfo TABLE(    
[APNO] INT        
,[ApStatus] char       
,[UserID] varchar(8)       
,[Billed] bit       
,[ApDate] datetime       
,[CompDate] datetime        
,[CLNO] smallint       
,[PC_Time_Stamp]  datetime      
,[Pc_Time_Out] datetime       
,[ReopenDate] datetime       
,[OrigCompDate] datetime        
,[InUse] varchar(8)       
,Attn varchar(100)       
,[Last_Updated] datetime       
,[StartDate] datetime       
,[RecruiterID] int       
,[IsAutoSent] bit       
,[AutoSentDate] datetime       
,[CreatedDate] datetime       
,[ClientProgramID] int       
,[Recruiter_Email] varchar(50)      
,[CAM]  varchar(8)      
,[SubStatusID] int       
,[GetNextDate] datetime       
,[IsDrugTestFileFound_bit] bit       
,[IsDrugTestFileFound] int        
,[InProgressReviewed] bit       
,[LastModifiedDate] datetime       
,[LastModifiedBy] varchar(20)       
)  

Insert into @Temp_AppInfo(  
[APNO]        
,[ApStatus]        
,[UserID]        
,[Billed]        
,[ApDate]        
,[CompDate]        
,[CLNO]        
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
,[CreatedDate]        
,[ClientProgramID]        
,[Recruiter_Email]        
,[CAM]        
,[SubStatusID]        
,[GetNextDate]        
,[IsDrugTestFileFound_bit]        
,[IsDrugTestFileFound]        
,[InProgressReviewed]        
,[LastModifiedDate]        
,[LastModifiedBy]        
)  
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
FROM        
dbo.Appl A WITH(NOLOCK)        
Inner join dbo.client C (nolock) on a.clno = c.clno        
WHERE         
ApStatus in ('P','F') And
(A.Apno = @Apno) --changed asper the code Review on 08.22.2023 by Nikhil HDT:106629


--Calculate the number of Employment components added for each of the APNOs above ja02102021        

DECLARE @Temp_CountEmpl TABLE(  
APNO INT  
,Completed int  -- Modified by Dongmei and Doug to use int instead of char 09/01/2023
,Total INT  
,MaxCompletedDate datetime  
);  

Insert INTO @Temp_CountEmpl(APNO,Completed,Total,MaxCompletedDate)          

SELECT  T.APNO,         
   sum(case when E.SectStat not in ('0','9', 'A' ) then 1 else 0 end) Completed ,          
      count(*)  Total,         
   MAX(case when E.SectStat not in ('0','9', 'A') then E.Last_Updated end) as 'MaxCompletedDate'        
FROM  @Temp_AppInfo T          
inner JOIN  dbo.Empl E WITH(NOLOCK) ON T.APNO = E.Apno  and E.IsOnReport = 1 -- Modified by Dongmei and Doug to use IsOnReport 09/01/2023
GROUP BY T.APNO        


 

--select 'Empl', * from   @Temp_CountEmpl



--Calculate the number of Education Components added for each of the APNOs above ja02102021        

DECLARE @Temp_CountEducat TABLE(  
APNO INT  
,Completed int  -- Modified by Dongmei and Doug to use int instead of char 09/01/2023
,Total INT  
,MaxCompletedDate datetime  
);        

Insert INTO @Temp_CountEducat(APNO,Completed,Total,MaxCompletedDate)          

  SELECT T.APNO,sum(case when Ed.SectStat not in ('0','9', 'A') then 1 else 0 end) Completed ,
    count(*)  Total,   
    MAX(case when Ed.SectStat not in ('0','9', 'A') then Ed.Last_Updated end) AS MaxCompletedDate        
  FROM @Temp_AppInfo T          
  INNER JOIN dbo.Educat Ed  WITH(NOLOCK) ON T.APNO=Ed.APNO  and Ed.IsOnReport = 1    -- Modified by Dongmei and Doug to use IsOnReport 09/01/2023     
  GROUP BY T.APNO          
  order by T.APNO        

--   select 'Educat', * from   @Temp_CountEducat
--           
--Calculate the number of License components added for each of the APNOs above ja02102021        
  DECLARE @Temp_CountLicense TABLE(  
APNO INT  
,Completed int  -- Modified by Dongmei and Doug to use int instead of char 09/01/2023
,Total INT  
,MaxCompletedDate datetime  
)       
Insert INTO @Temp_CountLicense(APNO,Completed,Total,MaxCompletedDate)          

  SELECT T.APNO,        
  Sum(case when P.SectStat not in ('0','9', 'A') then 1 else 0 end) Completed ,          
  count(*)  Total,          
  MAX(case when P.SectStat not in ('0','9', 'A') then P.Last_Updated end) AS MaxCompletedDate        
  FROM @Temp_AppInfo T          
  INNER JOIN dbo.ProfLic P WITH(NOLOCK) ON T.APNO=P.APNO    and P.IsOnReport = 1    -- Modified by Dongmei and Doug to use IsOnReport 09/01/2023   
  GROUP BY T.APNO          
  order by T.APNO        
 --   select 'License', * from  @Temp_CountLicense  

--            

--Calculate the number of Reference components added for each of the APNOs above ja02102021        
  DECLARE @Temp_CountRef TABLE(  
APNO INT  
,Completed int  -- Modified by Dongmei and Doug to use int instead of char 09/01/2023
,Total INT  
,MaxCompletedDate datetime  
)      
Insert INTO @Temp_CountRef(APNO,Completed,Total,MaxCompletedDate)          


  SELECT T.APNO,        
  Sum(case when Pr.SectStat not in ('0','9', 'A') then 1 else 0 end) Completed ,          
  count(*)  Total,          
  MAX(case when Pr.SectStat not in ('0','9', 'A') then Pr.Last_Updated end) AS MaxCompletedDate        
  FROM @Temp_AppInfo T  --WITH(NOLOCK)        
  INNER JOIN  PersRef Pr WITH(NOLOCK) ON T.APNO=Pr.APNO   and Pr.IsOnReport = 1     -- Modified by Dongmei and Doug to use IsOnReport 09/01/2023  
  GROUP BY T.APNO          
  order by T.APNO        
--   select 'ref',* from  @Temp_CountRef     
--          
--Calculate the number of Criminal Components added for each of the APNOs above ja02102021        

DECLARE @Temp_CountCrim TABLE(  
APNO INT  
,Completed int  -- Modified by Dongmei and Doug to use int instead of char 09/01/2023
,Total INT  
,MaxCompletedDate datetime  
)  
Insert INTO @Temp_CountCrim(APNO,Completed,Total,MaxCompletedDate)          


  SELECT T.APNO,        
  Sum(case when C.Clear = 'T'  then 1 else 0 end) Completed ,          
  count(*)  Total,          
  MAX(case when C.Clear = 'T' then C.Last_Updated end) AS MaxCompletedDate        
  FROM @Temp_AppInfo T  --WITH(NOLOCK)        
  inner JOIN  dbo.Crim C WITH(NOLOCK) ON T.APNO=C.APNO and  C.ishidden   = 0   
  GROUP BY T.APNO          
  order by T.APNO        
 --    select  'crim', * from    @Temp_CountCrim
--         

--Calculate the number of Sanction Check components for each of the APNOs above ja02102021         

DECLARE @Temp_CountSC TABLE(  
APNO INT  
,Completed int  -- Modified by Dongmei and Doug to use int instead of char 09/01/2023
,Total INT  
,MaxCompletedDate datetime  
)        

Insert INTO @Temp_CountSC(APNO,Completed,Total,MaxCompletedDate)          

  SELECT T.APNO,        
  Sum(case when D.SectStat not in ('0','9', 'A') then 1 else 0 end) Completed , -- Modified by Dongmei and Doug to include A  09/01/2023              
  count(*)  Total,          
  MAX(case when D.SectStat not in ('0','9', 'A') then D.Last_Updated end) AS MaxCompletedDate     -- Modified by Dongmei and Doug to include A  09/01/2023    
  FROM @Temp_AppInfo T  --WITH(NOLOCK)        
  inner JOIN  dbo.MedInteg D WITH(NOLOCK) ON T.APNO=D.APNO  and d.ishidden = 0       
  GROUP BY T.APNO          
  order by T.APNO        


 --     select 'san', * from  @Temp_CountSC

--          
--Calculate the number of MVR components for each of the APNOs above  ja02102021        

   DECLARE @Temp_CountMVR TABLE(  
APNO INT  
,Completed int  -- Modified by Dongmei and Doug to use int instead of char 09/01/2023
,Total INT  
,MaxCompletedDate datetime  
)  
Insert INTO @Temp_CountMVR(APNO,Completed,Total,MaxCompletedDate)          

  SELECT T.APNO,        
  Sum(case when D.SectStat not in ('0','9', 'A') then 1 else 0 end) Completed ,  -- Modified by Dongmei and Doug to include A  09/01/2023        
  count(*)  Total,          
  MAX(case when D.SectStat not in ('0','9', 'A') then D.Last_Updated end) AS MaxCompletedDate   -- Modified by Dongmei and Doug to include A  09/01/2023      
  FROM @Temp_AppInfo T  --WITH(NOLOCK)        
  inner JOIN dbo.DL D WITH(NOLOCK) ON T.APNO=D.APNO  and D.IsHidden = 0      
  GROUP BY T.APNO          
  order by T.APNO        


 --  select 'mvr', * from @Temp_CountMVR
--          
--Calculate the number of Credit components for each of the APNOs above ja02102021
-- Modified by Dongmei and Doug to include PID  09/01/2023        

  DECLARE @Temp_CountSocial TABLE(  
APNO INT  
,Completed int  -- Modified by Dongmei and Doug to use int instead of char 09/01/2023
,Total INT  
,MaxCompletedDate datetime  
)        
Insert INTO @Temp_CountSocial(APNO,Completed,Total,MaxCompletedDate)          

  SELECT T.APNO,        
  Sum(case when Ct.SectStat not in ('0','9', 'A') then 1 else 0 end) Completed ,   -- Modified by Dongmei and Doug to include A  09/01/2023        
  count(*)  Total,          
  MAX(case when Ct.SectStat not in ('0','9', 'A') then Ct.Last_Updated end) AS MaxCompletedDate    -- Modified by Dongmei and Doug to include A  09/01/2023    
  FROM @Temp_AppInfo T  --WITH(NOLOCK)        
  inner JOIN  dbo.Credit Ct ON T.APNO=Ct.APNO and ct.IsHidden = 0  and ct.RepType = 'S'
  GROUP BY T.APNO          
  order by T.APNO        
 --    select 'soc', * from @Temp_CountSocial   

-- Modified by Dongmei and Doug to include Credit the correct way  09/01/2023     
DECLARE @Temp_CountCredit TABLE(  
APNO INT  
,Completed int  -- Modified by Dongmei and Doug to use int instead of char 09/01/2023
,Total INT  
,MaxCompletedDate datetime  
)        
Insert INTO @Temp_CountCredit(APNO,Completed,Total,MaxCompletedDate)          

  SELECT T.APNO,        
  Sum(case when Ct.SectStat not in ('0','9', 'A') then 1 else 0 end) Completed ,    -- Modified by Dongmei and Doug to include A  09/01/2023      
  count(*)  Total,          
  MAX(case when Ct.SectStat not in ('0','9', 'A') then Ct.Last_Updated end) AS MaxCompletedDate   -- Modified by Dongmei and Doug to include A  09/01/2023     
  FROM @Temp_AppInfo T  --WITH(NOLOCK)        
  inner JOIN  dbo.Credit Ct ON T.APNO=Ct.APNO and ct.IsHidden = 0  and ct.RepType = 'C'
  GROUP BY T.APNO          
  order by T.APNO        
 --    select 'cre', * from @Temp_CountCredit   
       
--Calculate the number of Civil components for each of the APNOs above  ja02102021        

DECLARE @Temp_CountCivil TABLE(  
APNO INT  
,Completed int  -- Modified by Dongmei and Doug to use int instead of char 09/01/2023
,Total INT  
,MaxCompletedDate datetime  
)        
Insert INTO @Temp_CountCivil(APNO,Completed,Total,MaxCompletedDate)          

  SELECT T.APNO,        
  Sum(case when C.Clear='T'  then 1 else 0 end) Completed ,          
  count(*)  Total,          
  MAX(case when C.Clear = 'T' then C.Last_Updated end) AS MaxCompletedDate        
  FROM @Temp_AppInfo T  --WITH(NOLOCK)        
  inner JOIN  dbo.Civil C WITH(NOLOCK) ON T.APNO=C.APNO       
  GROUP BY T.APNO          
  order by T.APNO        
 --      select 'civ', * from @Temp_CountCivil 

Declare @Temp_Results table (  
    [UserID] varchar(8)   
    ,[APNO] int  
    ,[CLNO] int  
    ,[Name] varchar(300)  
    ,[Recruiter Name] varchar(300)  
    ,[ReopenDate] datetime  
    ,[InProgressReviewed] int   
    ,[TurnAroundTime] int
	,[Credit] int  
    ,[Percentage Completed] bigint  
    ,[MaxCompletedDate] datetime  
    )  

 Insert into @Temp_Results(  
    [UserID]   
    ,[APNO]   
    ,[CLNO]  
    ,[Name]   
    ,[Recruiter Name]  
    ,[ReopenDate]  
    ,[InProgressReviewed]  
    ,[TurnAroundTime]
	,[Credit]  
    ,[Percentage Completed]  
    ,[MaxCompletedDate]  
    )  
 
    select T1.UserID,T1.APNO,         
        c.CLNO,         
  c.Name, 
   T1.Attn as [Recruiter Name],        
  T1.ReopenDate,        
  T1.InProgressReviewed, --Added columns Client Number ,Client Name for HDt#72612 by Humera Ahmed on 5/11/2020          
  --Added by Humera Ahmed on 4/12/2019 for HDT - #50567          
        dbo.elapsedbusinessdays_2(CAST(T1.ApDate AS DATE), getdate()) AS 'TurnAroundTime',
 -- Modified by Dongmei and Doug to reflect correct percentage 09/01/2023 lines 380-398
 isnull(Ct.Total,0) as [Credit],
               CASE WHEN (isnull(CE.Total, 0)+isnull(Ed.Total, 0)+ISNULL(L.Total,0)
       +isnull(Cr.Total,0)+isnull(Ct.Total,0)+isnull(Crf.Total, 0)+isnull(SC.Total, 0)+isnull(cvl.Total, 0)+
       isnull(Mvr.Total, 0) + isnull(soc.Total,0)) =0 then 0          
         else          
       cast(round(
	   (((cast(isnull(CE.Completed,0) as int) + cast(isnull(Ed.Completed,0) as int)+ cast(isnull(L.Completed,0) as int)
        +cast(isnull(Cr.Completed,0) as int)+cast(isnull(Ct.Completed,0) as int)
        +cast(isnull(Crf.Completed,0) as int)+ cast(isnull(SC.Completed,0) as int)
        + cast(isnull(Cvl.Completed,0) as int)+ cast(isnull(mvr.Completed,0) as int)
		+ cast(isnull(soc.Completed,0) as int)) * 1.00
        /cast((isnull(CE.Total,0)+isnull(Ed.Total,0)+isnull(L.Total,0)+isnull(Cr.Total,0)+isnull(Ct.Total,0)
     +isnull(Crf.Total,0)+isnull(SC.Total,0)+isnull(cvl.Total,0)+isnull(Mvr.Total,0)  + isnull(soc.Total,0))as int)) * 100), -1) --Removed +1 on 31.10.2023 HDT:115329
	 as int)
     end 
	 as 'Percentage Completed',
     (SELECT MAX(v)           
       FROM (VALUES (CE.MaxCompletedDate), (Ed.MaxCompletedDate), (L.MaxCompletedDate), (Cr.MaxCompletedDate), (Ct.MaxCompletedDate), (Crf.MaxCompletedDate), (SC.MaxCompletedDate), (Cvl.MaxCompletedDate), (Mvr.MaxCompletedDate),(soc.MaxCompletedDate)) as value(v)          
        ) as 'MaxCompletedDate' 
from @Temp_AppInfo T1          
INNER JOIN client c ON T1.CLNO = C.CLNO  --Added columns Client Number ,Client Name for HDt#72612 by Humera Ahmed on 5/11/2020          
-- Modified by Dongmei and Doug to use left joins instead of inner joins 
left join @Temp_CountEmpl CE on t1.APNO = CE.APNO          
left join @Temp_CountEducat Ed on t1.APNO = Ed.APNO          
left join @Temp_CountLicense L on t1.APNO = L.APNO          
left join @Temp_CountCrim Cr on Cr.APNO = T1.APNO          
left join @Temp_CountCredit Ct on Ct.APNO = t1.APNO          
left join @Temp_CountRef Crf on Crf.APNO = T1.APNO          
left join @Temp_CountSC SC on SC.APNO = T1.APNO          
left join @Temp_CountCivil Cvl on cvl.APNO = T1.APNO           
left join @Temp_CountMVR mvr on mvr.APNO = T1.APNO 
left join @Temp_CountSocial soc on soc.APNO = T1.APNO

      ;with per_cte(            
    [CAM] ,              
    [APNO],  
          [Client ID] ,                     
          [Client Name],               
          [Recruiter Name] ,              
          [Reopened],               
          [AdmittedRecord],              
          [InProgressReviewed] ,
		   [Credit],               
          [Percentage Completed] ,              
          [BusinessDaysInThisPercentage] ,               
          [Report TAT]              
    )  
AS(  
select distinct         
 T.UserID as 'CAM',        
 T.APNO,         
 T.CLNO AS [Client ID],         
 T.Name AS [Client Name],        
 T.[Recruiter Name],        
 (CASE WHEN (T.reopendate) IS NULL THEN 'False' ELSE 'True' End) AS Reopened, --Added columns Client ID# ,Client Name for HDt#72612 by Humera Ahmed on 5/11/2020        
 --case when IsNull(applData.Crim_SelfDisclosed,0) = 0 then 'False' else 'True' end as AdmittedRecord, --Added by Doug DeGenaro on 10/20/2020 for HDT - #80002        
  case when sum(isnull(cast(applData.Crim_SelfDisclosed as int),0) )=0 then 0 else 1  end as AdmittedRecord,  --Modified by Amy Liu on 08/13/2021 for removing duplicate apno caused by this for #13503        
 (case when T.InProgressReviewed = 0 then 'False' else 'True' end) as InProgressReviewed,
  T.[Credit],   
 T.[Percentage Completed],      
 (CASE WHEN (T.MaxCompletedDate) IS NULL THEN '' ELSE ([dbo].ElapsedBusinessDays(T.MaxCompletedDate, GetDate())) end) as 'BusinessDaysInThisPercentage' ,--Added by Humera Ahmed on 4/12/2019 for HDT - #50567           
 T.TurnAroundTime as [Report TAT]          
from @Temp_Results T        
left join [dbo].[ApplAdditionalData] appldata on T.APNO  = applData.APNO  --Added by Doug DeGenaro on 10/20/2020 for HDT - #80002          
group by T.UserID ,T.APNO, T.CLNO, T.Name,T.[Recruiter Name],T.reopendate ,T.InProgressReviewed,T.[Credit],T.[Percentage Completed],T.MaxCompletedDate,T.TurnAroundTime        
--order by 1          
)  
  
INSERT into @PercentagesResult([CAM] ,              
          [Report Number] ,               
          [Client ID] ,                     
          [Client Name],               
          [Recruiter Name] ,              
          [Reopened],               
          [Admitted],              
          [InProgressReviewed] ,
		  [Credit],               
          [Percentage Completed] ,              
          [BusinessDaysInThisPercentage] ,               
          [Report TAT]  
    )   
 SELECT   
    [CAM] ,              
          [APNO] AS [Report Number] ,               
          [Client ID] ,                     
          [Client Name],               
          [Recruiter Name] ,              
          [Reopened],               
          [AdmittedRecord] AS [Admitted],              
          [InProgressReviewed] ,
		  [Credit],               
          [Percentage Completed] ,              
          [BusinessDaysInThisPercentage] ,               
          [Report TAT]              
  FROM per_cte  
RETURN    
 END 
