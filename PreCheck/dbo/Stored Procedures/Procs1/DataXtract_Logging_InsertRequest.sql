CREATE Procedure [dbo].[DataXtract_Logging_InsertRequest]

(

   @SectionKeyId varchar(50),

   @Section varchar(50),

   @Request varchar(MAX) = null,

   @UserId varchar(20)

) 



as





Insert into dbo.DataXtract_Logging(SectionKeyId,Section,Request,DateLogRequest,LogUser)

values (@SectionKeyId,@Section,@Request,getdate(),@UserId)



select scope_identity() as DataXtract_LoggingId
