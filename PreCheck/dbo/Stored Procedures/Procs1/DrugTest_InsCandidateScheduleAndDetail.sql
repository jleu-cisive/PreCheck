/*
Created By : Doug DeGenaro
Description : insert a candidate schedule record and candidate result detail record with status of 'Donor Email Expired'

Modified: Schapyala on 03/03/2020 to get default expiration date for parent client if facility level configuration is missing
Nodified: schapyala on 10/20/2023 to support expiration date based on calendar days for HCA and also fine tuned the query 
		  Also modified a jobmaster SP which was duplicated and was incomplete to call this same SP - centralizing
*/
--exec dbo.DrugTest_InsCandidateScheduleAndDetail '10/20/2023','10/21/2023'
CREATE procedure [dbo].[DrugTest_InsCandidateScheduleAndDetail](@starttime datetime = null,@endtime datetime= null)
as
BEGIN
declare @defaultDrugTestExpirationDays int = 7 -- 7 days is the default defined in the OrderOCHSService web.config
declare @configurationKeyName varchar(50) = 'DrugTestLinkExpirationInDays'
declare @calendarDayConfiguration varchar(50) = 'UseCalendarDaysForDrugTestExpiration'
declare @currentDatetime datetime = CURRENT_TIMESTAMP

--updated by schapyala to deal with a smaller subset. only 60 days as expiration date is less than 7 days usually - 10/20/2023
declare @cutoffDate datetime = Dateadd(day,-30,@currentDatetime) --'02/01/2020'
--drop table if exists #tempCS

-- Add the candidate schedule record if not exists
insert into dbo.OCHS_CandidateSchedule 
select 
	ci.OCHS_CandidateInfoID as OCHS_CandidateId,
	--Fixed incorrect figuring of business days and end of day with holiday	
	--Added ParentCLNO default expiration in days when facility level configuration is missing - schapyala 03/03/2020
	--Added logic to calculate expiration date based on calendar days or default business days based on new config key - schapyala 10/20/2023
	case when COALESCE(cci1.Value,cci3.Value)='True' then DateAdd(day,cast(COALESCE(cci.Value,cci2.value,@defaultDrugTestExpirationDays) as int)+1,CONVERT(date, CI.CreatedDate)) 
		 ELSE
			case when IsNumeric(RTRIM(LTRIM(COALESCE(cci.Value,cci2.value)))) = 0 then [dbo].[fnGetNthBusinessEndDateWithHolidays](CONVERT(date, CI.CreatedDate),@defaultDrugTestExpirationDays) else[dbo].[fnGetNthBusinessEndDateWithHolidays](CONVERT(date,CI.CreatedDate),cast(COALESCE(cci.Value,cci2.value) as int)) end 
		 END as ExpirationDate, 
	@currentDatetime as CreatedDate,
	'JobMaster' as CreatedBy,
	IsNull(os.BusinessServiceBehaviorId,2) as ScheduleById,  -- 2 is Candidate self scheduling
	1 as IsValidLink, 
	@currentDatetime as LastModifiedDate 
from  dbo.OCHS_CandidateInfo ci (nolock) left join dbo.OCHS_CandidateSchedule cs (nolock)  on cs.OCHS_CandidateID = ci.OCHS_CandidateInfoID
	--Start: Added join to figure out weborderParentCLNO to get default expiration in days when facility level configuration is missing - schapyala 03/03/2020
	inner join dbo.Client c (nolock)  on ci.CLNO = c.CLNO 
	left join dbo.ClientConfiguration cci2 (nolock)  on c.WebOrderParentCLNO = cci2.CLNO and cci2.ConfigurationKey= @configurationKeyName
	left join dbo.ClientConfiguration cci3 (nolock)  on c.WebOrderParentCLNO = cci3.CLNO and cci3.ConfigurationKey= @calendarDayConfiguration
	--End:   Added join to figure out weborderParentCLNO to get default expiration in days when facility level configuration is missing - schapyala 03/03/2020
	left join dbo.ClientConfiguration cci (nolock)  on ci.CLNO = cci.CLNO and cci.ConfigurationKey= @configurationKeyName
	left join dbo.ClientConfiguration cci1 (nolock)  on ci.CLNO = cci1.CLNO and cci1.ConfigurationKey= @calendarDayConfiguration
	left join Enterprise.dbo.OrderService os on cast(os.OrderServiceNumber as int) = ci.OCHS_CandidateInfoID	
where 	
	 cs.OCHS_CandidateID is null  
	 and ci.CreatedDate > @cutoffDate	 
	 and ((ci.CreatedDate BETWEEN @StartTime AND @EndTime) or (@starttime is  null and @endtime is  null))

---- Add the candidate schedule record if not exists
--insert into dbo.OCHS_CandidateSchedule 
--select * from #tempCS

-- Insert OCHS_ResultDetails record with a Donor Email Sent status if doesnt exist
insert into dbo.OCHS_ResultDetails
select
	'' as ProviderID,
	COALESCE(os.DrugTestServiceNumber,ci.OCHS_CandidateInfoID) as OrderIDOrApno,
	ci.SSN as SSNorOtherID,
	'drug' as ScreeningType,
	ci.FirstName,
	ci.LastName,
	null as FullName,
	'Donor Email Sent' as OrderStatus,
	null as DateReceived,
	'' as TestResult,
	null as TestResultDate,
	 ci.CreatedDate as LastUpdate,
	null as CoC,
	'Pre Employment' as ReasonForTest,
	ci.CLNO as CLNO 
from dbo.OCHS_CandidateInfo ci (nolock)
left join Enterprise.Staging.vwStageOrder os (nolock) on cast(os.DrugTestServiceNumber as int) = IsNull(ci.OCHS_CandidateInfoID,0)
left join dbo.OCHS_ResultDetails rd (nolock) ON CONVERT(VARCHAR(25),ci.OCHS_CandidateInfoID) = rd.OrderIDOrApno-- = os.OrderServiceNumber
where 
	rd.OrderIDOrApno is null 
 and ci.CreatedDate > @cutoffDate 
 and os.[CreateDate] > @cutoffDate --added this to reduce the load on the view as ci is the driver limiting the date range anyways
	 and ((ci.CreatedDate BETWEEN @StartTime AND @EndTime) or (@starttime is  null and @endtime is  null))

END


