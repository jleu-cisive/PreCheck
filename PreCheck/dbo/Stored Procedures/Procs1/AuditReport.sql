-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- Modified by Humera Ahmed on 3/13/2020 to resolve HDT#69475 and show descriptions of webstatus, sectstatus and crimclear codes.
-- Exec [dbo].[AuditReport] 5087948
-- Modified by Doug DeGenaro to show the Mozenda processed records for Crim.Status to resolve HDT#75447
-- Modified by Prasanna to not to show notes that are not related to the Report HDT#84123 Audit Q Report errors
-- Modified by Humera Ahmed on 10/12/2022 for HDT #59392 Audit Report - to add new User Name column
-- =============================================


CREATE PROCEDURE [dbo].[AuditReport] --4701432 
@Apno int 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;


    /*-- Insert statements for procedure here
		--Select A.Apno,'Appl' Section, Null, l.* from changelog l with (nolock) inner join Appl A on A.Apno = l.Id where Tablename like 'Appl%' and  A.Apno = @Apno
		--UNION
	 --   Select p.Apno,'ProfLic' Section, p.Lic_Type, l.* from changelog l with (nolock) inner join ProfLic p on p.ProflicID = l.Id where Tablename like 'ProfLic%' and  p.Apno = @Apno
		--UNION
		--Select ed.Apno, 'Educat' Section,ed.School, l.* from changelog l with (nolock) inner join Educat ed on Ed.EducatID = l.ID where Tablename like 'Educat%' and ed.Apno = @Apno
		--UNION
		--Select e.Apno,'Empl' Section, e.Employer, l.* from changelog l with (nolock) inner join Empl E on E.EmplID = l.ID where Tablename like 'Empl%' and  E.Apno = @Apno
		--UNION
		--Select c.Apno,'Crim' Section, c.County, l.* from changelog l with (nolock) inner join Crim c on c.CrimID = l.ID where Tablename like 'Crim%' and  c.Apno = @Apno
		--UNION
		--Select l.Apno, 'MedInteg' Section,l.Status, l.MedIntegLogID, tablename ='MedInteg', l.MedIntegApplReviewId, NULL, NULL, l.ChangeDate, l.UserName from MedInteglog l with (nolock) where l.Apno = @Apno
		--UNION
		--Select dl.Apno,'MVR' Section, NULL, l.* from changelog l with (nolock) inner join DL dl on dl.APNO = l.Id where Tablename like 'DL%' and  dl.Apno = @Apno
		--UNION
		--Select PR.Apno,'PersRef' Section, PR.Name, l.* from changelog l with (nolock) inner join PersRef PR on PR.PersRefId = l.Id where Tablename like 'PersRef%' and  PR.Apno = @Apno
		--UNION
		--Select CR.Apno,'Credit' Section, NULL, l.* from changelog l with (nolock) inner join Credit CR on CR.APNO = l.Id where Tablename like 'Credit%' and  CR.Apno = @Apno
		--UNION
		--Select A.Apno,'CloneApp' Section, NULL, l.* from changelog l with (nolock) inner join Appl A on A.APNO = l.Id where Tablename like '%Clone%' and  A.Apno = @Apno
		*/

		Select A.Apno,'Appl' Section, Null, l.HEVNMgmtChangeLogID, l.TableName, l.ID
				, CASE WHEN l.TableName = 'Appl.ApStatus' THEN (SELECT asd.AppStatusItem+' ('+asd.AppStatusValue+')' FROM dbo.AppStatusDetail asd WHERE asd.AppStatusItem = l.OldValue) 
					   WHEN l.TableName = 'Appl.SubStatusID' THEN (select cast(ss.SubStatusID AS varchar(20))+' ('+ss.SubStatus+')'  from dbo.SubStatus ss WHERE ss.SubStatusID = l.OldValue) 
					   WHEN l.TableName = 'Appl.PackageID' THEN (select cast(pm.PackageID AS varchar(20))+' ('+pm.PackageDesc+')'  FROM dbo.PackageMain pm WHERE pm.PackageID = l.OldValue) ELSE l.OldValue 
				  END [Old Value]
				, CASE WHEN l.TableName = 'Appl.ApStatus' THEN (SELECT asd.AppStatusItem+' ('+asd.AppStatusValue+')' FROM dbo.AppStatusDetail asd WHERE asd.AppStatusItem = l.NewValue) 
					   WHEN l.TableName = 'Appl.SubStatusID' THEN (select cast(ss.SubStatusID AS varchar(20))+' ('+ss.SubStatus+')'  from dbo.SubStatus ss WHERE ss.SubStatusID = l.NewValue) 
					   WHEN l.TableName = 'Appl.PackageID' THEN (select cast(pm.PackageID AS varchar(20))+' ('+pm.PackageDesc+')'  FROM dbo.PackageMain pm WHERE pm.PackageID = l.NewValue) ELSE l.NewValue
				  END [New Value]
		, l.ChangeDate, l.UserID, u.Name [User Name]
		from changelog l with (nolock) 
		inner join Appl A on A.Apno = l.Id 
		left join Users u on l.UserID = u.UserID
		where Tablename like 'Appl.%' and  A.Apno = @Apno

		UNION

		Select p.Apno,'ProfLic' Section, p.Lic_Type, l.HEVNMgmtChangeLogID, l.TableName, l.ID
		, CASE WHEN l.TableName = 'ProfLic.SectStat' THEN (SELECT ss.code +' ('+ ss.Description + ')' FROM dbo.SectStat ss WHERE ss.code = l.OldValue) 
			   WHEN l.TableName = 'ProfLic.Web_status' THEN (SELECT cast(w.code as nvarchar(100))+ ' ('+w.description+')' FROM dbo.Websectstat w WHERE w.code = l.OldValue) ELSE l.OldValue  
		  END [Old Value]
		,  CASE WHEN l.TableName = 'ProfLic.SectStat' THEN (SELECT ss.code +' ('+ ss.Description + ')'FROM dbo.SectStat ss WHERE ss.code = l.NewValue) 
		        WHEN l.TableName = 'ProfLic.Web_status' THEN (SELECT cast(w.code as nvarchar(100))+ ' ('+w.description+')' FROM dbo.Websectstat w WHERE w.code = l.NewValue) ELSE l.NewValue 
		   END [New Value]
		, l.ChangeDate, l.UserID, u.Name [User Name] 
		from changelog l with (nolock) 
		inner join ProfLic p on p.ProflicID = l.Id 
		left join Users u on l.UserID = u.UserID
		where Tablename like 'ProfLic%' and  p.Apno = @Apno

		UNION

		Select ed.Apno, 'Educat' Section,ed.School,
		l.HEVNMgmtChangeLogID, l.TableName, l.ID
		, CASE WHEN l.TableName = 'Educat.SectStat' THEN (SELECT ss.code +' ('+ ss.Description + ')' FROM dbo.SectStat ss WHERE ss.code = l.OldValue) 
			   WHEN l.TableName = 'Educat.web_status' THEN (SELECT cast(w.code as nvarchar(100))+ ' ('+w.description+')' FROM dbo.Websectstat w WHERE w.code = l.OldValue) ELSE l.OldValue  
		  END [Old Value]
		,  CASE WHEN l.TableName = 'Educat.SectStat' THEN (SELECT ss.code +' ('+ ss.Description + ')'FROM dbo.SectStat ss WHERE ss.code = l.NewValue) 
		        WHEN l.TableName = 'Educat.web_status' THEN (SELECT cast(w.code as nvarchar(100))+ ' ('+w.description+')' FROM dbo.Websectstat w WHERE w.code = l.NewValue) ELSE l.NewValue 
		   END [New Value]
		, l.ChangeDate, l.UserID, u.Name [User Name]
		from changelog l with (nolock) 
		inner join Educat ed on Ed.EducatID = l.ID
		left join Users u on l.UserID = u.UserID
		where Tablename like 'Educat%' and ed.Apno = @Apno

		UNION

		SELECT e.Apno,'Empl' Section, e.Employer,l.HEVNMgmtChangeLogID, l.TableName, l.ID
			, CASE WHEN l.TableName = 'Empl.SectStat' THEN (SELECT ss.code +' ('+ ss.Description + ')' FROM dbo.SectStat ss WHERE ss.code = l.OldValue) 
				   WHEN l.TableName = 'Empl.web_status' THEN (SELECT cast(w.code as nvarchar(100))+ ' ('+w.description+')' FROM dbo.Websectstat w WHERE w.code = l.OldValue) ELSE l.OldValue  
			  END [Old Value]
			,  CASE WHEN l.TableName = 'Empl.SectStat' THEN (SELECT ss.code +' ('+ ss.Description + ')'FROM dbo.SectStat ss WHERE ss.code = l.NewValue) 
					WHEN l.TableName = 'Empl.web_status' THEN (SELECT cast(w.code as nvarchar(100))+ ' ('+w.description+')' FROM dbo.Websectstat w WHERE w.code = l.NewValue) ELSE l.NewValue 
			   END [New Value]
			, l.ChangeDate, l.UserID, u.Name [User Name]
		from changelog l with (nolock) 
		inner join Empl E on E.EmplID = l.ID
		left join Users u on l.UserID = u.UserID 
		where Tablename like 'Empl%' and  E.Apno = @Apno

		UNION
		
		SELECT c.Apno,'Crim' Section, c.County,l.HEVNMgmtChangeLogID, l.TableName, l.ID
			, CASE WHEN l.TableName in ('Crim.Clear','Crim.Status') THEN (SELECT c.crimsect+' ('+ c.crimdescription + ')' FROM dbo.Crimsectstat c WHERE c.crimsect = l.OldValue) ELSE l.OldValue  
			  END [Old Value]
			,  CASE WHEN l.TableName in ('Crim.Clear','Crim.Status') THEN (SELECT c.crimsect+' ('+ c.crimdescription + ')' FROM dbo.Crimsectstat c WHERE c.crimsect = l.NewValue) ELSE l.NewValue 
			   END [New Value]
			, l.ChangeDate, l.UserID, u.Name [User Name]
		from changelog l with (nolock) 
		inner join Crim c on c.CrimID = l.ID
		left join Users u on l.UserID = u.UserID 
		where Tablename like 'Crim%' and  c.Apno = @Apno

		UNION
		Select l.Apno, 'MedInteg' Section,l.Status, l.MedIntegLogID, tablename ='MedInteg', l.MedIntegApplReviewId, NULL, NULL, l.ChangeDate, l.UserName [UserID], u.Name [User Name] 
		from MedInteglog l with (nolock) 
		left join Users u on l.UserName = u.UserID 
		where l.Apno = @Apno

		UNION
		
		Select dl.Apno,'MVR' Section, NULL,l.HEVNMgmtChangeLogID, l.TableName, l.ID
			, CASE WHEN l.TableName = 'DL.SectStat' THEN (SELECT ss.code +' ('+ ss.Description + ')' FROM dbo.SectStat ss WHERE ss.code = l.OldValue) 
				   WHEN l.TableName = 'DL.web_status' THEN (SELECT cast(w.code as nvarchar(100))+ ' ('+w.description+')' FROM dbo.Websectstat w WHERE w.code = l.OldValue) ELSE l.OldValue  
			  END [Old Value]
			,  CASE WHEN l.TableName = 'DL.SectStat' THEN (SELECT ss.code +' ('+ ss.Description + ')'FROM dbo.SectStat ss WHERE ss.code = l.NewValue) 
					WHEN l.TableName = 'DL.web_status' THEN (SELECT cast(w.code as nvarchar(100))+ ' ('+w.description+')' FROM dbo.Websectstat w WHERE w.code = l.NewValue) ELSE l.NewValue 
			   END [New Value]
			, l.ChangeDate, l.UserID, u.Name [User Name]
		from changelog l with (nolock) 
		inner join DL dl on dl.APNO = l.Id
		left join Users u on l.UserID = u.UserID 
		where Tablename like 'DL%' and  dl.Apno = @Apno

		UNION

		Select PR.Apno,'PersRef' Section, PR.Name, l.HEVNMgmtChangeLogID, l.TableName, l.ID
			, CASE WHEN l.TableName = 'PersRef.SectStat' THEN (SELECT ss.code +' ('+ ss.Description + ')' FROM dbo.SectStat ss WHERE ss.code = l.OldValue) 
				   WHEN l.TableName = 'PersRef.Web_status' THEN (SELECT cast(w.code as nvarchar(100))+ ' ('+w.description+')' FROM dbo.Websectstat w WHERE w.code = l.OldValue) ELSE l.OldValue  
			  END [Old Value]
			,  CASE WHEN l.TableName = 'PersRef.SectStat' THEN (SELECT ss.code +' ('+ ss.Description + ')'FROM dbo.SectStat ss WHERE ss.code = l.NewValue) 
					WHEN l.TableName = 'PersRef.Web_status' THEN (SELECT cast(w.code as nvarchar(100))+ ' ('+w.description+')' FROM dbo.Websectstat w WHERE w.code = l.NewValue) ELSE l.NewValue 
			   END [New Value]
			, l.ChangeDate, l.UserID, u.Name [User Name]
		from changelog l with (nolock) 
		inner join PersRef PR on PR.PersRefId = l.Id
		left join Users u on l.UserID = u.UserID  
		where Tablename like 'PersRef%' and  PR.Apno = @Apno

		UNION
		Select CR.Apno,'Credit' Section, NULL, l.HEVNMgmtChangeLogID, l.TableName,l.ID
			, CASE WHEN l.TableName = 'Credit.SectStat' THEN (SELECT ss.code +' ('+ ss.Description + ')' FROM dbo.SectStat ss WHERE ss.code = l.OldValue) ELSE l.OldValue  
			  END [Old Value]
			,  CASE WHEN l.TableName = 'Credit.SectStat' THEN (SELECT ss.code +' ('+ ss.Description + ')'FROM dbo.SectStat ss WHERE ss.code = l.NewValue) ELSE l.NewValue 
			   END [New Value]
			, l.ChangeDate, l.UserID, u.Name [User Name]
		from changelog l with (nolock) 
		inner join Credit CR on CR.APNO = l.Id
		left join Users u on l.UserID = u.UserID 
		where Tablename like 'Credit%' and  CR.Apno = @Apno
		UNION
		Select A.Apno,'CloneApp' Section, NULL, l.*, u.Name [User Name] from changelog l with (nolock) 
		inner join Appl A on A.APNO = l.Id
		left join Users u on l.UserID = u.UserID 
		where Tablename like '%Clone%' and  A.Apno = @Apno

END

