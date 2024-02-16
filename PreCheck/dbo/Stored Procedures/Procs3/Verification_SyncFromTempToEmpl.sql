

-- =============================================
-- Author:		Douglas DeGeanro
-- Create date: 07/29/2012
-- Description:	This procedure is used in the reference pro integration.  It updates the empl
-- table from using a staging table
-- =============================================
  
  -- =============================================
-- Edited By:		Douglas DeGeanro
-- Edit date: 08/01/2012
-- Description:	Updated procedure to use a variable for the retrieving of the date 
-- =============================================
  
  
CREATE procedure [dbo].[Verification_SyncFromTempToEmpl]  
as  
  
CREATE TABLE #temp1
( 
    apno INT     
)


Update Appl
set InUse = 'REFPro'
where Apno in
(Select Apno from dbo.[Verification_Staging_Empl])
and InUse is null


insert into #temp1
Select APNO from Appl where InUse =  'REFPro'

-- updates the appl table from Final to Pending if   
update appl  
set apstatus ='P'   
where apno in  
(select distinct A.apno from Appl a inner join dbo.[Verification_Staging_Empl] t on a.Apno = t.apno  
where a.apstatus ='F')  
  
-- update aliases from reference pro  
update dbo.appl  
set   
Alias1_First = Ref.Alias1_First,  
Alias1_Middle = Ref.Alias1_Middle,  
Alias1_Last = Ref.Alias1_Last,  
Alias2_First = Ref.Alias2_First,  
Alias2_Middle = Ref.Alias2_Middle,  
Alias2_Last = Ref.Alias2_Last,  
Alias3_First = Ref.Alias3_First,  
Alias3_Middle = Ref.Alias3_Middle,  
Alias3_Last = Ref.Alias3_Last  
  
from   
(select distinct A.apno,  
 isnull(t.Alias1_First,a.Alias1_First) as Alias1_First,  
 isnull(t.Alias1_Middle,a.Alias1_Middle) as Alias1_Middle,  
 isnull(t.Alias1_Last,a.Alias1_Last) as Alias1_Last,  
 isnull(t.Alias2_First,a.Alias2_First) as Alias2_First,  
 isnull(t.Alias2_Middle,a.Alias2_Middle) as Alias2_Middle,  
 isnull(t.Alias2_Last,a.Alias2_Last) as Alias2_Last,  
 isnull(t.Alias3_First,a.Alias3_First) as Alias3_First,  
 isnull(t.Alias3_Middle,a.Alias3_Middle) as Alias3_Middle,  
 isnull(t.Alias3_Last,a.Alias3_Last) as Alias3_Last  
  
 from dbo.Appl a inner join dbo.[Verification_Staging_Empl] t on a.Apno = t.apno) Ref  
where dbo.Appl.APno= ref.Apno  
and dbo.Appl.APNO in (Select APNO from #temp1)

  
  
--DISABLE TRIGGER pendingUpdate ON Empl  
ALTER TABLE dbo.empl DISABLE TRIGGER PendingUpdate 
ALTER TABLE dbo.empl DISABLE TRIGGER web_empl_history 
ALTER TABLE dbo.empl DISABLE TRIGGER WebUpdate  
  
  
-- update the empl table from the temp table  
update dbo.empl  
set From_V = Refempl.FromDate,  
 To_V = Refempl.ToDate,  
 Position_V = Refempl.Position,  
 Salary_V = Refempl.Salary,  
 RFL = Refempl.RFL,  
 Ver_By = Refempl.Ver_By,  
 Title = Refempl.Title,  
 Pub_Notes = Refempl.Public_Notes,  
 Web_Status = Refempl.Web_Status,  
 SectStat = Refempl.SectStat,  
 Priv_Notes = cast(Priv_Notes as varchar(max)) + '\r\n' + RefEmpl.Private_Notes,  
 IsOnReport = Refempl.IsOnReport,
 web_updated = RefEmpl.CreatedDate--@insertDate--getdate()
   
from  
(select e.emplid as EmplId,  
 IsNull(t.FromDate,e.From_V) as FromDate,  
 IsNull(t.ToDate,e.To_V) as ToDate,  
 IsNull(t.Position,e.Position_V) as Position,  
 IsNull(t.Salary,e.Salary_V) as Salary,  
 IsNull(t.RFL,e.RFL) as RFL,  
 IsNull(t.Ver_By,e.Ver_By) as Ver_By,  
 IsNull(t.Title,e.Title) as Title,  
 IsNull(t.Public_Notes,e.Pub_Notes) as Public_Notes,  
 t.Web_Status,  
 t.SectStat,  
 IsNull(t.Private_Notes,e.Priv_Notes) as Private_Notes,  
 IsNull(t.IsOnReport,e.IsOnReport) as IsOnReport,
   t.CreatedDate,
t.APNO
 from dbo.empl e inner join dbo.[Verification_Staging_Empl] t on e.emplid = t.emplid) Refempl  
where dbo.empl.emplid= Refempl.emplid  
and Refempl.APNO in (Select APNO from #temp1)

  --ENABLE TRIGGER pendingUpdate ON Empl   
ALTER TABLE dbo.empl ENABLE TRIGGER PendingUpdate 
ALTER TABLE dbo.empl ENABLE TRIGGER web_empl_history 
ALTER TABLE dbo.empl ENABLE TRIGGER WebUpdate 
  
declare @insertDate datetime

set @insertDate = getdate();
  
 INSERT INTO [dbo].[Verification_RP_Logging_Empl]
           ([EmplId]
           ,[FromDate]
           ,[ToDate]
           ,[Position]
           ,[Salary]
           ,[RFL]
           ,[Ver_By]
           ,[Title]
           ,[Web_Status]
           ,[SectStat]
           ,[Private_Notes]
           ,[Public_Notes]
           ,[Alias1_First]
           ,[Alias1_Middle]
           ,[Alias1_Last]
           ,[Alias2_First]
           ,[Alias2_Middle]
           ,[Alias2_Last]
           ,[Alias3_First]
           ,[Alias3_Middle]
           ,[Alias3_Last]
           ,[APNO]
           ,[IsOnReport]
           ,[CreatedDate])
SELECT [EmplId]
      ,[FromDate]
      ,[ToDate]
      ,[Position]
      ,[Salary]
      ,[RFL]
      ,[Ver_By]
      ,[Title]
      ,[Web_Status]
      ,[SectStat]
      ,[Private_Notes]
      ,[Public_Notes]
      ,[Alias1_First]
      ,[Alias1_Middle]
      ,[Alias1_Last]
      ,[Alias2_First]
      ,[Alias2_Middle]
      ,[Alias2_Last]
      ,[Alias3_First]
      ,[Alias3_Middle]
      ,[Alias3_Last]
      ,[APNO]
      ,[IsOnReport]
      ,@insertDate
  FROM [dbo].[Verification_Staging_Empl]
where Apno in (Select APNO from #temp1)

-- 	select e.emplid as EmplId,  
-- IsNull(t.FromDate,e.From_V) as FromDate,  
-- IsNull(t.ToDate,e.To_V) as ToDate,  
-- IsNull(t.Position,e.Position_V) as Position,  
-- IsNull(t.Salary,e.Salary_V) as Salary,  
-- IsNull(t.RFL,e.RFL) as RFL,  
-- IsNull(t.Ver_By,e.Ver_By) as Ver_By,  
-- IsNull(t.Title,e.Title) as Title,  
-- IsNull(t.Public_Notes,e.Pub_Notes) as Public_Notes,  
-- t.Web_Status as Web_Status,  
-- t.SectStat as SectStat,  
-- IsNull(t.Private_Notes,e.Priv_Notes) as Private_Notes,  
-- IsNull(t.IsOnReport,e.IsOnReport) as IsOnReport  ,
-- @insertDate
-- from dbo.empl e inner join dbo.[Verification_Staging_Empl] t on e.emplid = t.emplid

--if ((Select Count(*) from [Verification_RP_Logging_Empl] where CreatedDate = @insertDate)= (Select Count(*) from [Verification_RP_Logging_Empl]))
--begin
--Truncate table [Verification_Staging_Empl]
--end

delete [Verification_Staging_Empl] where APNo in (Select APNO from #temp1)

Update Appl
set InUse = NULL
where InUse = 'REFPro'

drop table #temp1


 
  
     

  

