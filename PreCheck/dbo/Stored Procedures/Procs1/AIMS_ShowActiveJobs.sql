-- Alter Procedure AIMS_ShowActiveJobs
--[dbo].[AIMS_ShowActiveJobs] 'L'
CREATE procedure [dbo].[AIMS_ShowActiveJobs]
(@type char(1) =  null)
as

select * into #temp from 
(
select 
	AIMS_JobID,
	case 
		when aj.VendorAccountId = 4 then 'Nursys' 
		when aj.VendorAccountId = 5 then 'Mozenda' 
		when aj.VendorAccountId = 7 then 'Baxter' 
	end as Vendor,
case Section when 'Crim' then 'Public Records' when 'CC' then 'Monthly' when 'SBM' then 'State Board' end as Section,
IsNull(c.County,aj.SectionKeyId) as SectionKeyID,case when IsNumeric(aj.SectionKeyID) = 1 then aj.SectionKeyId else null end as CountyNumber,
case aj.AIMS_JobStatus 
	when 'A' then 'Active' 
	when 'C' then 'Completed' 
	when 'D' then 'Disabled'
	when 'Z' then 'No Records'
	when 'E' then 'Errored'
	when 'U' then 'UnResolved' 
end as AIMSStatus,aj.AgentStatus as VendorStatus, aj.CreatedDate,aj.Last_Updated
 from dbo.AIMS_Jobs aj left join dbo.TblCounties c  on  cast(aj.SectionKeyID as varchar) = cast(c.CNTY_NO as varchar)  where AIMS_jobStatus='A') tbl

 if (@type = 'L')	
	select * from #temp where Section in ('Monthly','State Board') order by Last_Updated desc
if (@type in ('C','P'))
	select * from #temp where Section in ('Public Records')  order by Last_Updated desc
if (IsNull(@type,'') = '')
    select * from #temp  order by Last_Updated desc
drop table #temp
