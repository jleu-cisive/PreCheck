--[dbo].[AIMS_FindLicenseRecordByLicenseId] 1750764,'05/01/2017','07/01/2017'

CREATE procedure [dbo].[AIMS_FindLicenseRecordByLicenseId](@licenseid int,@datefrom datetime,@dateto datetime)
as
select DataXtract_LoggingId,Request,Response from dbo.DataXtract_Logging lg (nolock)
--where Section='Crim' 
where 
charindex(cast(@licenseid as varchar(20)),Request) > 0
and 
DateLogRequest between @datefrom and @dateto
and Section in ('SBM','CC')
 
 order by 1 desc
