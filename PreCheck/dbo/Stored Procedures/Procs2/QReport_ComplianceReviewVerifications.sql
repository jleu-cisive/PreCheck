-- =============================================
-- Author:		<Amy Qing Liu>
-- Create date: <05/01/2020>
-- Description:	<ONLY retrieve report components with a primary status of Compliance Reinvestigation 
-- for project: IntranetModule-Status-SubStatus phase2 >
-- exec [dbo].[QReport_ComplianceReviewVerifications] @StartDate='04/23/2020',@EndDate= '05/02/2020'
-- Modified by Amy Liu on 09/14/2020 to get the correct orders in the time range
-- =============================================
CREATE PROCEDURE [dbo].[QReport_ComplianceReviewVerifications]
@StartDate datetime,
@EndDate datetime
AS
BEGIN

	SET NOCOUNT ON;


	--declare @StartDate datetime,
	--	@EndDate datetime
	--	set @StartDate='08/01/2020'; set @EndDate= '08/31/2020'
	Declare @ComplianceReinvestigationList table (APNO int, Service varchar(20), ComponentID int, ComponentName varchar(max),Description varchar(50), [Sub-Status] varchar(100) , UserID varchar(50),ChangeDate datetime)
	insert into @ComplianceReinvestigationList( APNO, Service,ComponentID, ComponentName, Description, [Sub-Status], UserID,ChangeDate)
	select APNO, Service,emplrows.EmplID, emplrows.Employer, Description, [Sub-Status], UserID,ChangeDate 
	from
	(
	Select e.apno as APNO,'Employment' as Service,e.EmplID, e.Employer,  ss.Description,  sss.SectSubStatus as 'Sub-Status', lg.UserID, lg.ChangeDate 
	,row_number() over (partition by lg.id order by lg.id, lg.changedate DESC) lgrow
	from dbo.Empl e with(nolock)
	inner join dbo.appl a with(nolock) on e.apno = a.apno
	inner join dbo.SectStat ss with(nolock) on e.SectStat = ss.Code
	inner join dbo.ChangeLog lg with(nolock) on lg.ID = e.EmplID
	left join dbo.SectSubStatus sss with(nolock) on isnull(e.SectSubStatusID,0) = sss.SectSubStatusID
	where e.SectStat='R' 
	and lg.tableName in('Empl.SectStat','Empl.SectSubStatus','Empl.SectSubStatusID') 
	and e.last_updated >=@StartDate and e.last_updated<@EndDate +1
	--and e.apno =5301426
	--and ChangeDate >=@StartDate and lg.ChangeDate<=@EndDate

	) emplrows where emplrows.lgrow=1

	--select * from @ComplianceReinvestigationList 	order by service, ChangeDate

	insert into @ComplianceReinvestigationList( APNO, Service,ComponentID, ComponentName, Description,[Sub-Status], UserID,ChangeDate)
	select APNO,Service, educatrows.educatID, educatrows.School, Description,[Sub-Status], UserID,ChangeDate 
	from
	(
	Select e.apno as APNO, e.EducatID as ServiceID,'Educat' as Service,e.educatID, e.School,  e.SectStat as PrimaryStatus, ss.Description, e.SectSubStatusID, sss.SectSubStatus as 'Sub-Status', lg.UserID, lg.ChangeDate 
	,row_number() over (partition by lg.id order by lg.id, lg.changedate DESC) lgrow
	from dbo.Educat e with(nolock)
	inner join dbo.appl a with(nolock) on e.apno = a.apno
	inner join dbo.SectStat ss with(nolock) on e.SectStat = ss.Code
	inner join dbo.ChangeLog lg with(nolock) on lg.ID = e.EducatID
	left join dbo.SectSubStatus sss with(nolock) on isnull(e.SectSubStatusID,0) = sss.SectSubStatusID
	where e.SectStat='R'
	and lg.tableName in('Educat.SectStat','Educat.SectSubStatus','Educat.SectSubStatusID') 
	and e.last_updated >=@StartDate and e.last_updated<@EndDate +1
	--and lg.ChangeDate >=@StartDate and lg.ChangeDate<=@EndDate
	) educatrows where educatrows.lgrow=1

	insert into @ComplianceReinvestigationList( APNO, Service,ComponentID, ComponentName, Description, [Sub-Status], UserID,ChangeDate)
	select APNO, Service,persRefrows.PersRefID, persRefrows.name, Description,[Sub-Status], UserID,ChangeDate 
	from
	(
	Select p.apno as APNO, p.PersRefID as ServiceID,'PersRef' as Service,p.PersRefID, p.name,  p.SectStat as PrimaryStatus, ss.Description, p.SectSubStatusID, sss.SectSubStatus as 'Sub-Status', lg.UserID, lg.ChangeDate 
	,row_number() over (partition by lg.id order by lg.id, lg.changedate DESC) lgrow
	from dbo.PersRef p with(nolock)
	inner join dbo.appl a with(nolock) on p.apno = a.apno
	inner join dbo.SectStat ss with(nolock) on p.SectStat = ss.Code
	inner join dbo.ChangeLog lg with(nolock) on lg.ID = p.PersRefID
	left join dbo.SectSubStatus sss with(nolock) on isnull(p.SectSubStatusID,0) = sss.SectSubStatusID
	where p.SectStat='R'
	and lg.tableName in('PersRef.SectStat','PersRef.SectSubStatus','PersRef.SectSubStatusID') 
	and p.last_updated >=@StartDate and p.last_updated<@EndDate +1
	--and lg.ChangeDate >=@StartDate and lg.ChangeDate<=@EndDate
	) persRefrows where persRefrows.lgrow=1

	insert into @ComplianceReinvestigationList( APNO, Service,ComponentID, ComponentName, Description, [Sub-Status], UserID,ChangeDate)
	select APNO, Service, persRefrows.ProfLicID, persRefrows.Lic_Type, Description, [Sub-Status], UserID,ChangeDate  
	from
	(
	Select p.apno as APNO, 'ProfLic' as Service, p.ProfLicID, p.Lic_Type,  ss.Description, sss.SectSubStatus as 'Sub-Status', lg.UserID, lg.ChangeDate 
	,row_number() over (partition by lg.id order by lg.id, lg.changedate DESC) lgrow
	from dbo.ProfLic p with(nolock)
	inner join dbo.appl a with(nolock) on p.apno = a.apno
	inner join dbo.SectStat ss with(nolock) on p.SectStat = ss.Code
	inner join dbo.ChangeLog lg with(nolock) on lg.ID = p.ProfLicID
	left join dbo.SectSubStatus sss with(nolock) on isnull(p.SectSubStatusID,0) = sss.SectSubStatusID
	where p.SectStat='R'
	and lg.tableName in('ProfLic.SectStat','ProfLic.SectSubStatus','ProfLic.SectSubStatusID') 
	and p.last_updated >=@StartDate and p.last_updated<@EndDate +1
	--and lg.ChangeDate >=@StartDate and lg.ChangeDate<=@EndDate
	) persRefrows where persRefrows.lgrow=1

	select * from @ComplianceReinvestigationList
	order by service, ChangeDate

END
