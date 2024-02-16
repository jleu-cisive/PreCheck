
--drop procedure if exists [dbo].[AIMS_GetAIMSchedule]
--go
create  PROCEDURE [dbo].[AIMS_GetAIMSchedule]
(@Section VARCHAR(100),
@VendorAccountName VARCHAR(100))
AS
BEGIN

DECLARE @VendorAccountId INT

DECLARE @LatestDataXtract_RequestMapping TABLE (
    DataXtract_RequestMappingXMLID int,
	SectionKeyId varchar(50)
--[Section] varchar(50)
); 

DECLARE @LatestDataXtract_Logging TABLE (
DataXtractLoggingId int,
    [SectionKeyID] varchar(50),
	Responsestatus varchar(50)
--[Section] varchar(50)
); 
insert into @LatestDataXtract_Logging select t.DataXtract_LoggingId, t.[SectionKeyID],t.Responsestatus from (
    select
       [SectionKeyID],Responsestatus,DataXtract_LoggingId,
        row_number() over(partition by [SectionKeyID] order by DataXtract_LoggingId desc) as rn
    from
        [DataXtract_Logging]
) t
where t.rn = 1

insert into @LatestDataXtract_RequestMapping  SELECT max(DataXtract_RequestMappingXMLID),[SectionKeyID]
from [dbo].[DataXtract_RequestMapping]
WHERE section=@Section
group by [SectionKeyID]


SET  @VendorAccountId =  (SELECT VendorAccountId FROM [dbo].[VendorAccounts] WHERE VendorAccountName=@VendorAccountName AND IsActive=1)

SELECT  distinct DL.DataXtractLoggingId,  DAS.DataXtract_AIMS_ScheduleID,DRM.SectionKeyID as SectionKeyID,DAS.NextRunTime ,DAS.Interval,DAS.Timevalue,DAS.IsActive,DL.ResponseStatus
FROM [dbo].[DataXtract_AIMS_Schedule] DAS
 JOIN @LatestDataXtract_RequestMapping DRM ON DAS.DataXtract_RequestMappingXMLID=DRM.DataXtract_RequestMappingXMLID 
left JOIN @LatestDataXtract_Logging DL ON  DRM.SectionKeyID=DL.SectionKeyId
WHERE  DAS.VendorAccountId=@VendorAccountId

END



