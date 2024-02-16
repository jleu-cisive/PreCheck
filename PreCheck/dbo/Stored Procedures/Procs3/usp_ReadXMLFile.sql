

CREATE PROCEDURE [dbo].[usp_ReadXMLFile]
--@XMLSourceFile		nvarchar(1000),
@XMLFile		nvarchar(1000)
AS
BEGIN
SET NOCOUNT ON;

Declare @xml as XML

--DECLARE @Sql AS nvarchar(MAX);
--SET @SQL = 'SELECT @xmldataOUT = BULKCOLUMN FROM OPENROWSET(BULK ''' + @XMLSourceFile + ''', SINGLE_BLOB) as X;';
--EXECUTE dbo.sp_executesql @SQL, N'@xmldataOUT XML OUTPUT', @xmldataOUT=@xml OUTPUT;

SELECT  @xml = [XMLFileContent] FROM dbo.[Load XML Table] WHERE [XMLFileName] = @XMLFile

INSERT INTO [dbo].[DataXtract_Logging]
           ([SectionKeyId]
           ,[Section]
           ,[Request]
           ,[Response] 
           ,[ResponseError]
           ,[ResponseStatus]
           ,[DateLogRequest]
           ,[DateLogResponse]
           ,[LogUser]
           ,[ProcessDate]
           ,[ProcessFlag]
           ,[Total_Records]
           ,[Total_Clears]
           ,[Total_Exceptions])
     VALUES
          (@XMLFile
           ,'CredentCheck2'
           ,Null
           ,CONVERT(nvarchar(max),@xml)
           ,Null
           ,'ProcessCompleted'
           ,GetDate()
           ,GetDate()
           ,'Mozanda'
           ,Null
           ,'True'
           ,Null
           ,Null
           ,Null);


DELETE FROM [dbo].[Load XML Table] WHERE [XMLFileName] = @XMLFile;
END;
    
