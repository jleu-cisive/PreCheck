--[dbo].[AIMS_FindLicenseRecordByLicenseNumber] 'RN109691','01/01/2017','08/01/2017'


CREATE procedure [dbo].[AIMS_FindLicenseRecordByLicenseNumber](@ln varchar(20),@datefrom datetime,@dateto datetime)
as
declare @licenseid int

select top 1 @licenseid = licenseid from HEVN..License where number = @ln
select top 1  DataXtract_LoggingId,cast(Request as xml) Request,cast(Response as xml) Response,DateLogRequest,DateLogResponse from dbo.DataXtract_Logging lg (nolock)
--where Section='Crim' 
where 
charindex(cast(@licenseid as varchar(20)),Request) > 0
and 
DateLogRequest between @datefrom and @dateto 
and Section in ('SBM','CC')and Response is not null
order by DateLogRequest desc
 

