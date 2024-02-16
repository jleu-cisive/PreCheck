
CREATE PROCEDURE [dbo].[GetUnprocessedDataFromDataXtractLogging]
	@Section VARCHAR(100)
AS 
BEGIN

	DECLARE @LoggingList TABLE (idx INT PRIMARY KEY IDENTITY(1,1),
		[DataXtract_LoggingId] [INT],
		[SectionKeyId] VARCHAR(100),
		[Response] [XML])

	DECLARE @FinalData TABLE
	(
		DataXtract_LoggingId [INT],
		FileName VARCHAR(500),
		FileLocation VARCHAR(5000),
		FileFormat VARCHAR(500),
		ErrorStatus VARCHAR(500),
		ErrorMessage VARCHAR(2000),
		SectionKeyId VARCHAR(100)
	)

	INSERT INTO @LoggingList
	SELECT DataXtract_LoggingId,SectionKeyId,Response from [dbo].[DataXtract_Logging] WHERE Section=@Section and ProcessFlag=1

	DECLARE @i INT;
	DECLARE @numrows INT;
	DECLARE @request xml;
	DECLARE @DataXtract_LoggingId INT
	DECLARE @SectionKeyId VARCHAR(100)
	SET @i = 1
	SET @numrows = (SELECT COUNT(*) FROM @LoggingList)
		IF @numrows > 0
			WHILE (@i <= (SELECT MAX(idx) FROM @LoggingList))
		BEGIN
		SET @request=(SELECT Response FROM @LoggingList WHERE idx = @i)
		SET @DataXtract_LoggingId=(SELECT TOP 1 DataXtract_LoggingId FROM @LoggingList WHERE idx = @i)
		SET @SectionKeyId=(select top 1 sectionkeyid FROM @LoggingList WHERE idx = @i)
		if CHARINDEX('-' , @SectionKeyId) > 0   
        begin  
       SET @SectionKeyId=(SELECT TOP 1 RIGHT(sectionkeyid,CHARINDEX('-',REVERSE(sectionkeyid))-1)as sectionkeyid FROM @LoggingList WHERE idx = @i)
       end  
       

	INSERT INTO @FinalData 
	SELECT @DataXtract_LoggingId,
		Node.Data.value('(FileName)[1]', 'VARCHAR(500)'),
		Node.Data.value('(FileLocation)[1]', 'VARCHAR(500)'),
		Node.Data.value('(FileFormat)[1]', 'VARCHAR(500)'),
		Node.Data.value('(ErrorStatus)[1]', 'VARCHAR(500)'),
		Node.Data.value('(ErrorMessage)[1]', 'VARCHAR(2000)'),
		@SectionKeyId
		FROM @request.nodes('/DocumentElement/Item') Node(Data)

	SET @i = @i + 1
	END
	SELECT * FROM @FinalData
END
