 
--[Verification_UpdateFromStaging] 'Employment'  
  
-- =============================================  
-- Author:  Douglas DeGeanro  
-- Create date: 07/29/2012  
-- Description: This procedure is used in the reference pro integration.  It updates the empl  
-- table from using a staging table  
-- =============================================  
    
  -- =============================================  
-- Edited By:  Douglas DeGeanro  
-- Edit date: 08/01/2012  
-- Description: Updated procedure to use a variable for the retrieving of the date   
-- =============================================  
  
 -- =============================================  
-- Edited By:  Douglas DeGeanro  
-- Edit date: 08/03/2012  
-- Description: Added education update information in and changed stored proc name to make more sense  
-- Edited By:  Balaji Sankar  
-- Edit date: 08/13/2012  
-- Description: Optimized Query
-- =============================================  
    
CREATE PROCEDURE [dbo].[Verification_UpdateFromStaging_New]
@section varchar(30) = null
AS    
BEGIN
SET NOCOUNT ON;    
declare @insertDate datetime  
--CREATE TABLE #temp1  
--(   
--    apno INT       
--)  
if (@section = 'Employment')  
BEGIN  
  
  
  
--  
--Update Appl  
--set InUse = 'REFPro'  
--where Apno in  
--(Select Apno from dbo.[Verification_Staging_Empl])  
--and InUse is null  
--  
--  
--insert into #temp1  
--Select APNO from Appl where InUse =  'REFPro'  
  
 -- updates the appl table from Final to Pending if     
 update A
 set A.apstatus ='P'
FROM dbo.Appl A  INNER JOIN 
(select distinct apno from dbo.[Verification_Staging_Empl] )  V
ON A.APNO = V.apno
WHERE A.apstatus ='F'  
     
 -- update aliases from reference pro    
 UPDATE A
 set     
 Alias1_First = isnull(Ref.Alias1_First,A.Alias1_First),    
 Alias1_Middle = isnull(Ref.Alias1_Middle,A.Alias1_Middle),    
 Alias1_Last = isnull(Ref.Alias1_Last,A.Alias1_Last),    
 Alias2_First = isnull(Ref.Alias2_First,A.Alias2_First),    
 Alias2_Middle = isnull(Ref.Alias2_Middle,A.Alias2_Middle),    
 Alias2_Last = isnull(Ref.Alias2_Last,A.Alias2_Last),    
 Alias3_First = isnull(Ref.Alias3_First,A.Alias3_First),    
 Alias3_Middle = isnull(Ref.Alias3_Middle,A.Alias3_Middle),    
 Alias3_Last = isnull(Ref.Alias3_Last,A.Alias3_Last)    
 FROM   
	dbo.Appl   A INNER JOIN 
 (select distinct apno,    
  Alias1_First,    
 Alias1_Middle,    
 Alias1_Last,    
 Alias2_First,    
 Alias2_Middle,    
 Alias2_Last,    
 Alias3_First,    
 Alias3_Middle,    
 Alias3_Last    
  FROM dbo.[Verification_Staging_Empl]) Ref    
 ON A.APNO = ref.Apno    
     
 --DISABLE TRIGGER pendingUpdate ON Empl    
 --ALTER TABLE dbo.empl DISABLE TRIGGER All   
     
 -- update the empl table from the empl staging table    
 update e
 set From_V = IsNull(t.FromDate,e.From_V) ,    
  To_V = IsNull(t.ToDate,e.To_V),    
  Position_V = IsNull(t.Position,e.Position_V),    
  Salary_V = IsNull(t.Salary,e.Salary_V),    
  RFL = IsNull(t.RFL,e.RFL),    
  Ver_By = IsNull(t.Ver_By,e.Ver_By),    
  Title = IsNull(t.Title,e.Title),    
  Pub_Notes = IsNull(t.Public_Notes,e.Pub_Notes),    
  Web_Status = t.Web_Status,    
  SectStat = t.SectStat,    
  Priv_Notes = cast(Priv_Notes as varchar(max)) + '\r\n' + IsNull(t.Private_Notes,e.Priv_Notes),    
  IsOnReport = IsNull(t.IsOnReport,e.IsOnReport),  
  web_updated = t.CreatedDate--@insertDate--getdate()        
 FROM    
 dbo.empl e inner join dbo.[Verification_Staging_Empl] t on e.emplid = t.emplid

   --ENABLE TRIGGER pendingUpdate ON Empl     
 --ALTER TABLE dbo.empl ENABLE TRIGGER All  
     
 set @insertDate = getdate();  
     
 -- log from staging table  
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
--where Apno in (Select APNO from #temp1)  
  -- empty out staging table if succesful  
  if ((Select Count(*) from [Verification_RP_Logging_Empl] where CreatedDate = @insertDate)= (Select Count(*) from [Verification_Staging_Empl]))  
   Truncate table [Verification_Staging_Empl]  
  
--delete [Verification_Staging_Empl] where APNO in (Select APNO from #temp1)  
--  
--Update Appl  
--set InUse = NULL  
--where InUse = 'REFPro'  
  
  
END  
  
------------Education---------------------  
if (@section = 'Education')  
BEGIN  
  
--  
--  
--  
--  
--Update Appl  
--set InUse = 'REFPro'  
--where Apno in  
--(Select Apno from dbo.[Verification_Staging_Educat])  
--and InUse is null  
--  
--  
--insert into #temp1  
--Select APNO from Appl where InUse =  'REFPro'  
  
  
  -- updates the appl table from Final to Pending if     
 update A
 set A.apstatus ='P'
FROM dbo.Appl A  INNER JOIN 
(select distinct apno from dbo.[Verification_Staging_Educat] )  V
ON A.APNO = V.apno
WHERE A.apstatus ='F'  
     
-- update aliases from reference pro    
update A    
set     
Alias1_First = isnull(Ref.Alias1_First,A.Alias1_First),    
Alias1_Middle = isnull(Ref.Alias1_Middle,A.Alias1_Middle),    
Alias1_Last = isnull(Ref.Alias1_Last,A.Alias1_Last),    
Alias2_First = isnull(Ref.Alias2_First,A.Alias2_First),    
Alias2_Middle = isnull(Ref.Alias2_Middle,A.Alias2_Middle),    
Alias2_Last = isnull(Ref.Alias2_Last,A.Alias2_Last),    
Alias3_First = isnull(Ref.Alias3_First,A.Alias3_First),    
Alias3_Middle = isnull(Ref.Alias3_Middle,A.Alias3_Middle),    
Alias3_Last = isnull(Ref.Alias3_Last,A.Alias3_Last)    
FROM dbo.Appl A INNER JOIN 
(select distinct apno,    
 Alias1_First,    
 Alias1_Middle,    
 Alias1_Last,    
 Alias2_First,    
 Alias2_Middle,    
 Alias2_Last,    
 Alias3_First,    
 Alias3_Middle,    
 Alias3_Last    
 FROM dbo.[Verification_Staging_Educat]) Ref 
 ON A.Apno = Ref.apno

--DISABLE TRIGGER pendingUpdate ON Educat    
--ALTER TABLE dbo.educat DISABLE TRIGGER All   
  
update e
set From_V = IsNull(t.FromDate,e.From_V),    
 To_V = IsNull(t.ToDate,e.To_V) ,   
 Degree_V = IsNull(t.Degree,e.Degree_V),  
 Studies_V = IsNull(t.Studies,e.Studies_V),  
 city = IsNull(t.City,e.City),  
 Phone = IsNull(t.Phone,e.Phone),  
 State = IsNull(t.State,e.State),  
 School = IsNull(t.School,e.School),    
 Contact_Name = IsNull(t.Ver_By,e.Contact_Name),    
 Contact_Title = IsNull(t.Title,e.Contact_Title),    
 Pub_Notes = IsNull(t.Public_Notes,e.Pub_Notes),    
 Web_Status = t.Web_Status,    
 SectStat = t.SectStat,    
 Priv_Notes = cast(Priv_Notes as varchar(max)) + '\r\n' + IsNull(t.Private_Notes,e.Priv_Notes),    
 IsOnReport = IsNull(t.IsOnReport,e.IsOnReport) ,  
 web_updated = t.CreatedDate    
 FROM dbo.Educat e inner join dbo.[Verification_Staging_Educat] t on e.educatid = t.educatid
  
  --ENABLE TRIGGER pendingUpdate ON Educat     
--ALTER TABLE dbo.educat ENABLE TRIGGER All  
  
  
INSERT INTO [dbo].[Verification_RP_Logging_Educat]  
           ([EducatId]  
           ,[FromDate]  
           ,[ToDate]  
           ,[Degree]  
           ,[Studies]  
           ,[City]  
           ,[Phone]  
           ,[School]  
           ,[State]  
           ,[SectStat]  
           ,[Web_Status]  
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
           ,[CreatedDate]  
           ,[Ver_By]  
           ,[Title])  
           SELECT [EducatId]  
      ,[FromDate]  
      ,[ToDate]  
      ,[Degree]  
      ,[Studies]  
      ,[City]  
      ,[Phone]  
      ,[School]  
      ,[State]  
      ,[SectStat]  
      ,[Web_Status]  
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
      ,[CreatedDate]  
      ,[Ver_By]  
      ,[Title]  
  FROM [dbo].[Verification_Staging_Educat]  
    
  if ((Select Count(*) from [Verification_RP_Logging_Educat] where CreatedDate = @insertDate)= (Select Count(*) from [Verification_Staging_Educat]))  
       Truncate table [Verification_Staging_Educat]  
  
--  
--delete [Verification_Staging_Educat] where APNO in (Select APNO from #temp1)  
--  
--Update Appl  
--set InUse = NULL  
--where InUse = 'REFPro'  
--  
  
  
END  
END
