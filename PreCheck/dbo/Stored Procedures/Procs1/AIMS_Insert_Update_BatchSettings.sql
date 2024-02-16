
-- =============================================
-- Author:		An Vo
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[AIMS_Insert_Update_BatchSettings] 
@SectionKeyId varchar(50),
@IsBatchRetryEnabled bit
AS
BEGIN
BEGIN TRY
declare @RequestMappingId int 
declare @output_message varchar(50)
declare @batchSetting varchar(8)

if(@IsBatchRetryEnabled = 1)
set @batchSetting = 'enabled'

if(@IsBatchRetryEnabled = 0)
set @batchSetting = 'disabled'

set @RequestMappingId = (select Dataxtract_RequestMappingXMLID from [Precheck].[dbo].[DataXtract_RequestMapping] where SectionKeyID = @SectionKeyId)

	   IF (select count([AIMS_BatchSettings].BatchSettingId) from [Precheck].[dbo].[AIMS_BatchSettings] where Dataxtract_RequestMappingXMLId =
		(select Dataxtract_RequestMappingXMLId from [Precheck].[dbo].[DataXtract_RequestMapping] where [DataXtract_RequestMapping].SectionKeyID = @SectionKeyId)) = 0
		BEGIN	   
		INSERT INTO [Precheck].[dbo].[AIMS_BatchSettings](
		[Dataxtract_RequestMappingXMLId],
		[BatchType],
		[IsBatchRetryEnabled]
		)
		VALUES(
		@RequestMappingId,
		null,
		@IsBatchRetryEnabled
		)		
		END
		ELSE
		BEGIN
		UPDATE [Precheck].[dbo].[AIMS_BatchSettings] set IsBatchRetryEnabled = @IsBatchRetryEnabled where Dataxtract_RequestMappingXMLId = @RequestMappingId
		END
		set @output_message = @SectionKeyId + ' successfully ' + @batchSetting
		select @output_message
END TRY

BEGIN CATCH
	SELECT
	 ERROR_NUMBER() AS ErrorNumber  
    ,ERROR_SEVERITY() AS ErrorSeverity  
    ,ERROR_STATE() AS ErrorState  
    ,ERROR_PROCEDURE() AS ErrorProcedure  
    ,ERROR_LINE() AS ErrorLine  
    ,ERROR_MESSAGE() AS ErrorMessage;  
END CATCH			

END
