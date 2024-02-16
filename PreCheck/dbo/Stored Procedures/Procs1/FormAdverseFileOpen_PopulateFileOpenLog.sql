
CREATE PROCEDURE [dbo].[FormAdverseFileOpen_PopulateFileOpenLog] 
@userId char(10)

AS
insert into AdverseFileOpenLog (AdverseActionID,Type,TypeID,TypeName,UserID)
select aa.adverseactionid,'Credit',rtrim(convert(char(10),cd.apno))+'-'+cd.reptype,cd.reptype,@userId  
from adverseaction aa inner join credit cd on aa.apno=cd.apno
where (aa.statusid=8 and rtrim(convert(char(10),cd.apno))+'-'+cd.reptype not in 
	                 (SELECT typeid FROM AdverseFileOpenLog afo 
		           WHERE aa.adverseactionid=afo.adverseactionid))

insert into AdverseFileOpenLog (AdverseActionID,Type,TypeID,TypeName,UserID)
select aa.adverseactionid,'Crim',cr.crimID,cr.County,@userId 
from adverseaction aa inner join crim cr on aa.apno=cr.apno
where (aa.statusid=8 and convert(char(20),cr.crimID) not in 
			 (SELECT typeid FROM AdverseFileOpenLog afo 
		           WHERE aa.adverseactionid=afo.adverseactionid))

insert into AdverseFileOpenLog (AdverseActionID,Type,TypeID,TypeName,UserID)
select aa.adverseactionid,'DL',d.apno,'',@userId  
from adverseaction aa inner join dl d on aa.apno=d.apno
where (aa.statusid=8 and convert(char(20),d.apno) not in 
			 (SELECT typeid FROM AdverseFileOpenLog afo 
		           WHERE aa.adverseactionid=afo.adverseactionid))

insert into AdverseFileOpenLog (AdverseActionID,Type,TypeID,TypeName,UserID)
select aa.adverseactionid,'Educat',edu.EducatID,edu.School,@userId  
from adverseaction aa inner join Educat edu on aa.apno=edu.apno
where (aa.statusid=8 and convert(char(20),edu.EducatID) not in 
			 (SELECT typeid FROM AdverseFileOpenLog afo 
		           WHERE aa.adverseactionid=afo.adverseactionid))

insert into AdverseFileOpenLog (AdverseActionID,Type,TypeID,TypeName,UserID)
select aa.adverseactionid,'Empl',emp.EmplID,emp.Employer,@userId  
from adverseaction aa inner join empl emp on aa.apno=emp.apno
where (aa.statusid=8 and convert(char(20),emp.EmplID) not in 
			 (SELECT typeid FROM AdverseFileOpenLog afo 
		           WHERE aa.adverseactionid=afo.adverseactionid))

insert into AdverseFileOpenLog (AdverseActionID,Type,TypeID,TypeName,UserID)
select aa.adverseactionid,'PersRef',pr.PersRefID,pr.Name,@userId 
from adverseaction aa inner join persref pr on aa.apno=pr.apno
where (aa.statusid=8 and convert(char(20),pr.PersRefID) not in 
			 (SELECT typeid FROM AdverseFileOpenLog afo 
		           WHERE aa.adverseactionid=afo.adverseactionid))

insert into AdverseFileOpenLog (AdverseActionID,Type,TypeID,TypeName,UserID)
select aa.adverseactionid,'ProfLic',pf.ProfLicID,pf.Lic_Type,@userId  
from adverseaction aa inner join proflic pf on aa.apno=pf.apno
where (aa.statusid=8 and convert(char(20),pf.ProfLicID) not in 
			 (SELECT typeid FROM AdverseFileOpenLog afo 
		           WHERE aa.adverseactionid=afo.adverseactionid))



