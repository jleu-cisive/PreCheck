
CREATE PROCEDURE [dbo].[QReport_AuditInDemi_Report] 
/************************************************************************************************************
*************************************************************************************************************
Author:  Arindam Mitra
Date:  08/24/2023
Purpose:  QReport for audit in DEMI.

***************************************************************************************************************
***************************************************************************************************************/
--[dbo].[QReport_AuditInDemi_Report]  '7549601'

@Apno int

AS
BEGIN

SET NOCOUNT ON

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

DECLARE @name as varchar(100),
	  @Firsrname as varchar(100),
	  @Lastname as varchar(100),
	  @State as varchar(100),
	  @Degree as varchar(100),
	  @Studies as varchar(100)

	   SELECT @Lastname=Last, @Firsrname=First, @State=State FROM Appl WHERE APNO=@Apno
	  set @name = @Lastname +', ' + @Firsrname
	  
	  SELECT @Degree=Degree_V, @Studies=Studies_V FROM Educat WHERE APNO=@Apno
	  
	  Select A.Apno,'Appl' Section, CL.Name as Type, @name as Name,  @State as State, @Studies as Studies, @Degree as Degree,
	  l.HEVNMgmtChangeLogID, l.TableName, l.ID  
		, CASE WHEN l.TableName = 'Appl.ApStatus' THEN (SELECT asd.AppStatusItem+' ('+asd.AppStatusValue+')' FROM dbo.AppStatusDetail asd WHERE asd.AppStatusItem = l.OldValue)   
			WHEN l.TableName = 'Appl.SubStatusID' THEN (select cast(ss.SubStatusID AS varchar(20))+' ('+ss.SubStatus+')'  from dbo.SubStatus ss WHERE ss.SubStatusID = l.OldValue)   
			WHEN l.TableName = 'Appl.PackageID' THEN (select cast(pm.PackageID AS varchar(20))+' ('+pm.PackageDesc+')'  FROM dbo.PackageMain pm WHERE pm.PackageID = l.OldValue) ELSE l.OldValue   
		  END [Old Value]  
		, CASE WHEN l.TableName = 'Appl.ApStatus' THEN (SELECT asd.AppStatusItem+' ('+asd.AppStatusValue+')' FROM dbo.AppStatusDetail asd WHERE asd.AppStatusItem = l.NewValue)   
			WHEN l.TableName = 'Appl.SubStatusID' THEN (select cast(ss.SubStatusID AS varchar(20))+' ('+ss.SubStatus+')'  from dbo.SubStatus ss WHERE ss.SubStatusID = l.NewValue)   
			WHEN l.TableName = 'Appl.PackageID' THEN (select cast(pm.PackageID AS varchar(20))+' ('+pm.PackageDesc+')'  FROM dbo.PackageMain pm WHERE pm.PackageID = l.NewValue) ELSE l.NewValue  
		  END [New Value]  
	  , l.ChangeDate, a.Investigator 'Investigated by', l.UserID, u.Name [User Name]
	  from changelog l with (nolock)   
	  inner join Appl A with (nolock) on A.Apno = l.Id   
	  inner join ApplAdditionalData AS D(NOLOCK) ON D.APNO = A.APNO 
	  inner join Client CL with (nolock) on A.CLNO = CL.CLNO   
	  left join Users u on u.UserID = l.UserID 
	  where l.Tablename like 'Appl.%' and D.DataSource = 'DEMI' and  A.Apno = @Apno 

	  UNION  
  
	  Select p.Apno,'ProfLic' Section, p.Lic_Type, @name as Name, @State as State, @Studies as Studies, @Degree as Degree,
	  l.HEVNMgmtChangeLogID, l.TableName, l.ID  
	  , CASE WHEN l.TableName = 'ProfLic.SectStat' THEN (SELECT ss.code +' ('+ ss.Description + ')' FROM dbo.SectStat ss WHERE ss.code = l.OldValue)   
		  WHEN l.TableName = 'ProfLic.Web_status' THEN (SELECT cast(w.code as nvarchar(100))+ ' ('+w.description+')' FROM dbo.Websectstat w WHERE w.code = l.OldValue) ELSE l.OldValue    
		END [Old Value]  
	  ,  CASE WHEN l.TableName = 'ProfLic.SectStat' THEN (SELECT ss.code +' ('+ ss.Description + ')'FROM dbo.SectStat ss WHERE ss.code = l.NewValue)   
			  WHEN l.TableName = 'ProfLic.Web_status' THEN (SELECT cast(w.code as nvarchar(100))+ ' ('+w.description+')' FROM dbo.Websectstat w WHERE w.code = l.NewValue) ELSE l.NewValue   
		 END [New Value]  
	  , l.ChangeDate, a.Investigator 'Investigated by', l.UserID, u.Name [User Name]   
	  from changelog l WITH (NOLOCK)   
	  inner join ProfLic p WITH (NOLOCK)  on p.ProflicID = l.Id 
	  inner join Appl A with (nolock) on A.Apno = l.Id
	  inner join ApplAdditionalData AS D WITH (NOLOCK) ON D.APNO = p.APNO 	  
	  left join Users u on u.UserID  = l.UserID
	  where l.Tablename like 'ProfLic%' and D.DataSource = 'DEMI' and p.Apno = @Apno  
  
	  UNION  
  
	  Select ed.Apno, 'Educat' Section,ed.School,  @name as Name, @State as State, @Studies as Studies, @Degree as Degree,
	  l.HEVNMgmtChangeLogID, l.TableName, l.ID  
	  , CASE WHEN l.TableName = 'Educat.SectStat' THEN (SELECT ss.code +' ('+ ss.Description + ')' FROM dbo.SectStat ss WHERE ss.code = l.OldValue)   
		  WHEN l.TableName = 'Educat.web_status' THEN (SELECT cast(w.code as nvarchar(100))+ ' ('+w.description+')' FROM dbo.Websectstat w WHERE w.code = l.OldValue) ELSE l.OldValue    
		END [Old Value]  
	  ,  CASE WHEN l.TableName = 'Educat.SectStat' THEN (SELECT ss.code +' ('+ ss.Description + ')'FROM dbo.SectStat ss WHERE ss.code = l.NewValue)   
			  WHEN l.TableName = 'Educat.web_status' THEN (SELECT cast(w.code as nvarchar(100))+ ' ('+w.description+')' FROM dbo.Websectstat w WHERE w.code = l.NewValue) ELSE l.NewValue   
		 END [New Value]  
	  , l.ChangeDate, a.Investigator 'Investigated by', l.UserID, u.Name [User Name]  
	  from changelog l 
	  inner join Educat ed WITH (NOLOCK)  on Ed.EducatID = l.ID  
	  inner join Appl A with (nolock) on A.Apno = l.Id
	  inner join ApplAdditionalData AS D WITH (NOLOCK) ON D.APNO = ed.APNO 
	  left join Users u on u.UserID  = l.UserID
	  where l.Tablename like 'Educat%' and D.DataSource = 'DEMI' and ed.Apno = @Apno  
  
	  UNION  
  
	  SELECT e.Apno,'Empl' Section, e.Employer, @name as Name, @State as State, @Studies as Studies, @Degree as Degree,
	  l.HEVNMgmtChangeLogID, l.TableName, l.ID  
	   , CASE WHEN l.TableName = 'Empl.SectStat' THEN (SELECT ss.code +' ('+ ss.Description + ')' FROM dbo.SectStat ss WHERE ss.code = l.OldValue)   
		   WHEN l.TableName = 'Empl.web_status' THEN (SELECT cast(w.code as nvarchar(100))+ ' ('+w.description+')' FROM dbo.Websectstat w WHERE w.code = l.OldValue) ELSE l.OldValue    
		 END [Old Value]  
	   ,  CASE WHEN l.TableName = 'Empl.SectStat' THEN (SELECT ss.code +' ('+ ss.Description + ')'FROM dbo.SectStat ss WHERE ss.code = l.NewValue)   
		 WHEN l.TableName = 'Empl.web_status' THEN (SELECT cast(w.code as nvarchar(100))+ ' ('+w.description+')' FROM dbo.Websectstat w WHERE w.code = l.NewValue) ELSE l.NewValue   
		  END [New Value]  
	   , l.ChangeDate, e.Investigator AS 'Investigated by', l.UserID, u.Name [User Name]  
	  from changelog l WITH (NOLOCK) 
	  inner join Empl E WITH (NOLOCK) on E.EmplID = l.ID  
	  inner join ApplAdditionalData AS D WITH (NOLOCK)  ON D.APNO = e.APNO 
	  left join Users u on u.UserID  = l.UserID  
	  where l.Tablename like 'Empl%' and  D.DataSource = 'DEMI' and E.Apno = @Apno  
  
	  UNION  
    
	  SELECT c.Apno,'Crim' Section, c.County, @name as Name, @State as State, @Studies as Studies, @Degree as Degree,
	  l.HEVNMgmtChangeLogID,  l.TableName, l.ID  
	   , CASE WHEN l.TableName in ('Crim.Clear','Crim.Status') THEN (SELECT c.crimsect+' ('+ c.crimdescription + ')' FROM dbo.Crimsectstat c WHERE c.crimsect = l.OldValue) ELSE l.OldValue    
		 END [Old Value]  
	   ,  CASE WHEN l.TableName in ('Crim.Clear','Crim.Status') THEN (SELECT c.crimsect+' ('+ c.crimdescription + ')' FROM dbo.Crimsectstat c WHERE c.crimsect = l.NewValue) ELSE l.NewValue   
		  END [New Value]  
	   , l.ChangeDate, 'PVyas' AS 'Investigated by', l.UserID, u.Name [User Name]  
	  from changelog l WITH (NOLOCK)  
	  inner join Crim c WITH (NOLOCK)  on c.CrimID = l.ID 
	  inner join ApplAdditionalData AS D WITH (NOLOCK)  ON D.APNO = c.APNO 
	  left join Users u on u.UserID  = l.UserID  
	  where l.Tablename like 'Crim%' and D.DataSource = 'DEMI' and c.Apno = @Apno  
  
	  UNION  
	  Select l.Apno, 'MedInteg' Section,l.Status, @name as Name, @State as State, @Studies as Studies, @Degree as Degree,
	  l.MedIntegLogID, tablename ='MedInteg', l.MedIntegApplReviewId, NULL, NULL, l.ChangeDate, '' 'Investigated by', l.UserName [UserID], u.Name [User Name]   
	  from MedInteglog l WITH (NOLOCK)  
	  inner join ApplAdditionalData AS D WITH (NOLOCK) ON D.APNO = l.APNO 
	  left join Users u on u.UserID  = l.UserName
	  where D.DataSource = 'DEMI' and l.Apno = @Apno  
  
	  UNION  
    
	  Select dl.Apno,'MVR' Section, sec.Description as Type, @name as Name, @State as State, @Studies as Studies, @Degree as Degree,
	  l.HEVNMgmtChangeLogID, l.TableName, l.ID  
	   , CASE WHEN l.TableName = 'DL.SectStat' THEN (SELECT ss.code +' ('+ ss.Description + ')' FROM dbo.SectStat ss WHERE ss.code = l.OldValue)   
		   WHEN l.TableName = 'DL.web_status' THEN (SELECT cast(w.code as nvarchar(100))+ ' ('+w.description+')' FROM dbo.Websectstat w WHERE w.code = l.OldValue) ELSE l.OldValue    
		 END [Old Value]  
	   ,  CASE WHEN l.TableName = 'DL.SectStat' THEN (SELECT ss.code +' ('+ ss.Description + ')'FROM dbo.SectStat ss WHERE ss.code = l.NewValue)   
		 WHEN l.TableName = 'DL.web_status' THEN (SELECT cast(w.code as nvarchar(100))+ ' ('+w.description+')' FROM dbo.Websectstat w WHERE w.code = l.NewValue) ELSE l.NewValue   
		  END [New Value]  
	   , l.ChangeDate, a.Investigator 'Investigated by', l.UserID, u.Name [User Name]  
	  from changelog l WITH (NOLOCK)  
	  inner join DL dl WITH (NOLOCK) on dl.APNO = l.Id  
	  inner join ApplAdditionalData AS D WITH (NOLOCK) ON D.APNO = DL.APNO 
	  inner join [dbo].[SectStat] AS sec WITH (NOLOCK) ON DL.SectStat = sec.CODE 
	  left join Users u on u.UserID  = l.UserID 
	  left join Appl a on dl.APNO  = a.APNO 
	  where l.Tablename like 'DL%' and D.DataSource = 'DEMI' and dl.Apno = @Apno  
  
	  UNION  
  
	  Select PR.Apno,'PersRef' Section, PR.Name, @name as Name, @State as State, @Studies as Studies, @Degree as Degree,
	  l.HEVNMgmtChangeLogID, l.TableName, l.ID  
	   , CASE WHEN l.TableName = 'PersRef.SectStat' THEN (SELECT ss.code +' ('+ ss.Description + ')' FROM dbo.SectStat ss WHERE ss.code = l.OldValue)   
		   WHEN l.TableName = 'PersRef.Web_status' THEN (SELECT cast(w.code as nvarchar(100))+ ' ('+w.description+')' FROM dbo.Websectstat w WHERE w.code = l.OldValue) ELSE l.OldValue    
		 END [Old Value]  
	   ,  CASE WHEN l.TableName = 'PersRef.SectStat' THEN (SELECT ss.code +' ('+ ss.Description + ')'FROM dbo.SectStat ss WHERE ss.code = l.NewValue)   
		 WHEN l.TableName = 'PersRef.Web_status' THEN (SELECT cast(w.code as nvarchar(100))+ ' ('+w.description+')' FROM dbo.Websectstat w WHERE w.code = l.NewValue) ELSE l.NewValue   
		  END [New Value]  
	   , l.ChangeDate, '' 'Investigated by', l.UserID, u.Name [User Name]  
	  from changelog l WITH (NOLOCK)    
	  inner join PersRef PR WITH (NOLOCK) on PR.PersRefId = l.Id  
	  inner join ApplAdditionalData AS D WITH (NOLOCK)   ON D.APNO = PR.APNO
	  left join Users u on u.UserID  = l.UserID    
	  where l.Tablename like 'PersRef%' and D.DataSource = 'DEMI' and  PR.Apno = @Apno  
  
	  UNION  

	  Select CR.Apno,'Credit' Section, sec.Description as Type, @name as Name, @State as State, @Studies as Studies, @Degree as Degree,
	  l.HEVNMgmtChangeLogID, l.TableName,l.ID  
	   , CASE WHEN l.TableName = 'Credit.SectStat' THEN (SELECT ss.code +' ('+ ss.Description + ')' FROM dbo.SectStat ss WHERE ss.code = l.OldValue) ELSE l.OldValue    
		 END [Old Value]  
	   ,  CASE WHEN l.TableName = 'Credit.SectStat' THEN (SELECT ss.code +' ('+ ss.Description + ')'FROM dbo.SectStat ss WHERE ss.code = l.NewValue) ELSE l.NewValue   
		  END [New Value]  
	   , l.ChangeDate, a.Investigator 'Investigated by', l.UserID, u.Name [User Name]  
	  from changelog l WITH (NOLOCK)  
	  inner join Credit CR WITH (NOLOCK) on CR.APNO = l.Id  
	  inner join ApplAdditionalData AS D WITH (NOLOCK) ON D.APNO = CR.APNO
	  inner join [dbo].[SectStat] AS sec WITH (NOLOCK) ON CR.SectStat = sec.CODE 
	  left join Users u on u.UserID  = l.UserID
	  left join Appl a on CR.APNO  = a.APNO 
	  where l.Tablename like 'Credit%' and D.DataSource = 'DEMI' and CR.Apno = @Apno  

	  UNION  

	  Select A.Apno,'CloneApp' Section, NULL as Type, @name as Name, @State as State, @Studies as Studies, @Degree as Degree,
	  l.*, '' 'Investigated by', u.Name [User Name] 
	  from changelog l WITH (NOLOCK)   
	  inner join Appl A WITH (NOLOCK) on A.APNO = l.Id  
	  inner join ApplAdditionalData AS D WITH (NOLOCK) ON D.APNO = A.APNO
	  left join Users u on u.UserID  = l.UserID 
	  where l.Tablename like '%Clone%' and D.DataSource = 'DEMI' and A.Apno = @Apno  


SET TRANSACTION ISOLATION LEVEL READ COMMITTED		 

SET NOCOUNT OFF	

END

