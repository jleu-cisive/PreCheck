-- =============================================
-- Author:		Suchitra Yellapantula
-- Create date: 03/31/2017
-- Description:	Pulls details of User/Date who checked the Rush Box for Apps in Oasis, per HDT 11413 from Valerie K. Salazar
-- Execution: exec OASISRushBoxDetail '03/01/2017','03/02/2017','',''
-- =============================================
CREATE PROCEDURE OASISRushBoxDetail 
	-- Add the parameters for the stored procedure here
	@StartDate date, @EndDate date,
	@CAM varchar(max),  @Affiliate varchar(50)
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

if(LTRIM(RTRIM(LOWER(@CAM)))='null')
begin
set @CAM=''
end

if(LTRIM(RTRIM(LOWER(@Affiliate)))='null')
begin
set @Affiliate=''
end

select A.APNO, A.CLNO,A.CreatedDate,A.Rush,A.UserID,'F' as [Found]
into #tempRushAppls
from Appl A 
inner join Client C on C.CLNO = A.CLNO
inner join refAffiliate RA on C.AffiliateID = RA.AffiliateID
where A.CreatedDate>=@StartDate and A.CreatedDate<dateadd(day,1,@EndDate) and A.Rush=1
and (isnull(@Affiliate,'')='' or RA.Affiliate=@Affiliate)
and (isnull(@CAM,'')='' or C.CAM in (SELECT * from [dbo].[Split](':',@CAM)))

--First get the Rush details available from the ChangeLog
select CL.ID as 'APNO',CL.ChangeDate,CL.UserID 
into #tempChangeLogData
from ChangeLog CL(nolock) inner join #tempRushAppls A on A.APNO = CL.ID 
where  TableName='Appl.Rush' and OldValue='False' and NewValue='True'

--Flag those apps in #tempRushAppls which have the required data available in the ChangeLog
update #tempRushAppls set Found='T' where APNO in (select APNO from #tempChangeLogData)

--Now look for the remaining data in the PrecheckServiceLog
select * 
into #tempServiceLog
from PrecheckServiceLog where Apno in (select APNO from #tempRushAppls where Found='F') 


;WITH XMLNAMESPACES (
						N'http://schemas.datacontract.org/2004/07/PreCheckBPMServiceHelper' as A
					)
select isnull(cast(Request as xml).value('(//A:NewApplicants/A:NewApplicant/A:EnteredBy)[1]','varchar(100)'),cast(Request as xml).value('(//A:NewApplicants/A:NewApplicant/A:UserId)[1]','varchar(100)')) as 'UserID',APNO,ServiceDate
into #tempServiceLogData
from #tempServiceLog PL 
where cast(Request as xml).value('(//A:NewApplicants/A:NewApplicant/A:Rush)[1]','varchar(100)') = 1 
	  

update #tempRushAppls set Found='T' where APNO in (select APNO from #tempServiceLogData)

delete from #tempRushAppls where Found='T'


(select TR.CLNO,TR.APNO [Report Number],TR.CreatedDate, TR.Rush,'' as [Rush Date],'' as [UserID],TR.UserID [CAM], RA.Affiliate 
from #tempRushAppls TR 
inner join Client C on C.CLNO = TR.CLNO
inner join refAffiliate RA on C.AffiliateID = RA.AffiliateID)
union
(select A.CLNO,TL.APNO [Report Number],A.CreatedDate,A.Rush,TL.ChangeDate as [Rush Date],TL.UserID as [UserID],A.UserID as [CAM], RA.Affiliate
from #tempChangeLogData TL
inner join Appl A on A.APNO = TL.APNO
inner join Client C on C.CLNO = A.CLNO
inner join refAffiliate RA on C.AffiliateID = RA.AffiliateID)
union
(select A.CLNO,A.APNO [Report Number],A.CreatedDate,A.Rush,TD.ServiceDate [Rush Date],TD.UserID,A.UserID as [CAM], RA.Affiliate
from #tempServiceLogData TD inner join Appl A on A.APNO = TD.apno
inner join Client C on C.CLNO = A.CLNO
inner join refAffiliate RA on C.AffiliateID = RA.AffiliateID)
union 
(select A.CLNO, A.APNO [Report Number],A.CreatedDate,A.Rush,null [Rush Date],'' UserID, A.UserID as [CAM], RA.Affiliate
from Appl A 
inner join Client C on C.CLNO = A.CLNO
inner join refAffiliate RA on C.AffiliateID = RA.AffiliateID
where A.CreatedDate>=@StartDate and A.CreatedDate<dateadd(day,1,@EndDate) and A.Rush=0
and (isnull(@Affiliate,'')='' or RA.Affiliate=@Affiliate)
and (isnull(@CAM,'')='' or C.CAM in (SELECT * from [dbo].[Split](':',@CAM)))
) 

drop table #tempRushAppls
drop table #tempChangeLogData
drop table #tempServiceLog
drop table #tempServiceLogData

END
