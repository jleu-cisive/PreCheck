CREATE PROCEDURE [dbo].[AIMS_UpdateAIMSchedule] (@SchedulerId Int,  
                                          @Frequency    VARCHAR(10),  
                                          @FrequencyValue     Int,                                          
                                          @Status          BIT,  
                                          @NextRunDate datetime,
										  @UserName varchar(100))  
AS  
BEGIN
	
UPDATE  [dbo].[DataXtract_AIMS_Schedule]  
            SET    Interval = @Frequency,  
                   TimeValue = @FrequencyValue,
                   NextRunTime=@NextRunDate,
				   IsActive=@Status
            WHERE  DataXtract_AIMS_ScheduleID = @SchedulerId
			

INSERT INTO DataXtract_AIMS_Schedule_Logging( [DataXtract_AIMS_ScheduleID],
	[DataXtract_RequestMappingXMLID],
	[refAIMS_SectionTypeCode],
	[NextRunTime],
	[Interval],
	[TimeValue],
	[IsActive] ,
	[VendorAccountId],
	[CreatedBy],
	[CreatedDate],
	[ModifiedBy],
	[ModifiedDate])
	select DataXtract_AIMS_ScheduleID,
	DataXtract_RequestMappingXMLID,
	refAIMS_SectionTypeCode,
	[NextRunTime],
	[Interval],
	[TimeValue],
	[IsActive] ,
	VendorAccountId,@UserName,getdate(),@UserName,getdate() from [DataXtract_AIMS_Schedule] WHERE DataXtract_AIMS_ScheduleID=@SchedulerId
END


