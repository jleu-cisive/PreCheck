-- =============================================
-- Author:		<Amy Liui>
-- Create date: <02/17/2020>
-- Description:	<Get the module Sect status and SectSubStatus>
-- exec [dbo].[GetSectStatusSectSubStatusBlurb] 1, 4516521,5585562
-- exec [dbo].[GetSectStatusSectSubStatusBlurb] 1, 4516555,5585587
/*
exec [dbo].[GetSectStatusSectSubStatusBlurb] 1, 172058,172058
exec [dbo].[GetSectStatusSectSubStatusBlurb] 1, 4516555,5585582
exec [dbo].[GetSectStatusSectSubStatusBlurb] 2, 3407339,2314251     --education
exec [dbo].[GetSectStatusSectSubStatusBlurb] 3, 3432909,690452     --PersonalReference
exec [dbo].[GetSectStatusSectSubStatusBlurb] 8, 4516684 ,1        --Credit/Search:  0 for credit(C) and 1 for SSNSearch (S)
select e.SectStat, e.SectSubStatusID, e.SubStatusID, e.* 
--update e set e.sectstat='U', e.sectSubStatusID=3
from empl e 
inner join appl a on e.apno= a.apno
where a.apno = 4516555  --5585562
and e.IsOnReport=1
--and EmplID=5585582
select * from SectStat
*/
/*****************************************************************************************************
Modified Date	: 03/14/2023
Modified By		: Jenitta Frederik
Description		: For HDT 82197 Remove Proof Attached Sub Status for Alert Status
                  We have Disabled the Proof Attached Sub Status for Alert Status from the Sub Status DropDown for the 
				  reports that doesnot have this sub status

**************************************************************************************************/

-- =============================================
CREATE PROCEDURE [dbo].[GetSectStatusSectSubStatusBlurb] 
	@ApplSectionID int=0,
	@apno int=0,
	@empid int=0
AS
BEGIN
	SET NOCOUNT ON;
	--declare 	@ApplSectionID int=1,
	--@apno int=181370,
	--@empid int=172058
declare @SectStatSubStatus table (Code char(1), Description varchar(25), SelectedCode char(1),ApplSectionID int null,SectSubStatusID int null,SectSubStatus varchar(100),SelectedSectSubStatusID int null , Blurb varchar(max)) 
	insert into  @SectStatSubStatus(Code,   Description,	SelectedCode,  ApplSectionID,								SectSubStatusID,			SectSubStatus,					SelectedSectSubStatusID,		      Blurb )  
							select ss.Code, ss.Description, '',				isnull(sss.ApplSectionID,@ApplSectionID), isnull(sss.SectSubStatusID,0), isnull(sss.SectSubStatus,''),			0,	              	isnull(sss.Blurb,'')   
							from dbo.SectStat ss
							left join dbo.SectSubStatus sss on ss.Code= sss.SectStatusCode and sss.IsActive=1 and (isnull(@ApplSectionID,0)=0 or sss.ApplSectionID=@ApplSectionID)
							where ss.IsActive=1   and isnull(ss.Department,'')<>'Education'

	declare @SectStat char(1)='', @SectSubStatusID int =0

	If (@ApplSectionID=1)  --Empl section
			select  @SectStat=isnull(e.SectStat,''), @SectSubStatusID=isnull(e.SectSubStatusID,0)  
			from appl a
			inner join empl e on a.APNO= e.Apno 
			left join SectStat ss on e.SectStat= ss.Code 
			where a.APNO= @apno        
			and (isnull(@empid, 0)=0 or e.emplid =@empid )        			

	If (@ApplSectionID=2)  --Educat section
	Begin
		insert into  @SectStatSubStatus(Code,   Description,	SelectedCode,  ApplSectionID,								SectSubStatusID,			SectSubStatus,					SelectedSectSubStatusID,		      Blurb )  
							select ss.Code, ss.Description, '',				isnull(sss.ApplSectionID,@ApplSectionID), isnull(sss.SectSubStatusID,0), isnull(sss.SectSubStatus,''),			0,	              	isnull(sss.Blurb,'')   
							from dbo.SectStat ss
							left join dbo.SectSubStatus sss on ss.Code= sss.SectStatusCode and sss.IsActive=1 and (isnull(@ApplSectionID,0)=0 or sss.ApplSectionID=@ApplSectionID)
							where ss.IsActive=1 and isnull(ss.Department,'')='Education'
			select  @SectStat=isnull(e.SectStat,''), @SectSubStatusID=isnull(e.SectSubStatusID,0)  
			from appl a
			inner join dbo.Educat e on a.APNO= e.Apno 
			left join SectStat ss on e.SectStat= ss.Code 
			where a.APNO = @apno  
			and  e.EducatID = @empid
	End

		If (@ApplSectionID=3)  --PersRef section
			select  @SectStat=isnull(p.SectStat,''), @SectSubStatusID=isnull(p.SectSubStatusID,0)  
			from appl a
			inner join PersRef p on a.APNO= p.Apno 
			left join SectStat ss on p.SectStat= ss.Code 
			where a.APNO= @apno  
			and p.PersRefID = @empid

		If (@ApplSectionID=4)  --ProfLic section
			select  @SectStat=isnull(p.SectStat,''), @SectSubStatusID=isnull(p.SectSubStatusID,0) 
			from appl a
			inner join ProfLic p on a.APNO= p.Apno 
			left join SectStat ss on p.SectStat= ss.Code 
			where a.APNO= @apno 
			and  p.ProfLicID =@empid  

		--If (@ApplSectionID=8)  ---Credit section
		--	select  @SectStat=isnull(d.SectStat,''), @SectSubStatusID=0
		--	from appl a
		--	inner join Credit d on a.APNO= d.Apno 
		--	left join SectStat ss on d.SectStat= ss.Code 
		--	where a.APNO= @apno   
		--	and case when isnull(@empid,0) =0 then 'C' else 'S' end =d.RepType
		
	---add it into drop down if it's not in the active dropdown list  ---these don't have sectSubStatus as it is old status
	if( @SectStat<>'' and not exists(select 1 from @SectStatSubStatus ssss where ssss.Code=@SectStat) )
		insert into @SectStatSubStatus(Code,	 Description, SelectedCode,			ApplSectionID,	SectSubStatusID,SectSubStatus,SelectedSectSubStatusID, Blurb )  
								select ss.code, ss.Description,isnull(ss.code,''),   @ApplSectionID,		0,				'',					0,			''  
								from dbo.SectStat ss
								where ss.Code=@SectStat
	if (@SectStat<>'')
	Begin
			--select *    ----below update selected status in active(new) status list
		update ssss set ssss.SelectedCode=@SectStat 
		from @SectStatSubStatus ssss where ssss.Code=@SectStat 
	End
	if (@SectStat<>'' and @SectSubStatusID<>0)
		--select * 
		update ssss set ssss.SelectedSectSubStatusID=isnull(@SectSubStatusID,0)
		from @SectStatSubStatus ssss where ssss.Code=@SectStat and ssss.SectSubStatusID=@SectSubStatusID
			
	select * from @SectStatSubStatus where (SelectedSectSubStatusID=93 AND SectSubStatus='Proof Attached' OR SectSubStatus<>'Proof Attached') OR [Description]<>'ALERT'  order by Description, SectSubStatus  
	--Modified by Jenitta on 03/14/2023 for HDT 82197
   
END
