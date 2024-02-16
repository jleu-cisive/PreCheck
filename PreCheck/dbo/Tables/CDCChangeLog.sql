CREATE TABLE [dbo].[CDCChangeLog] (
    [ChangeLogId]     INT           IDENTITY (1, 1) NOT NULL,
    [DatabaseName]    VARCHAR (150) NULL,
    [TableName]       VARCHAR (150) NULL,
    [ColumnName]      VARCHAR (255) NULL,
    [CreateDate]      DATETIME      CONSTRAINT [DF_Changelog_CreatedBy] DEFAULT (getdate()) NULL,
    [CreateBy]        VARCHAR (50)  CONSTRAINT [DF_Changelog_CreatedDt] DEFAULT (suser_name()) NULL,
    [ModifyDate]      DATETIME      NULL,
    [ModifyUser]      VARCHAR (50)  NULL,
    [AuditUserColumn] VARCHAR (200) NULL,
    [PKColumnName]    VARCHAR (200) NULL,
    CONSTRAINT [PK_Changelog] PRIMARY KEY CLUSTERED ([ChangeLogId] ASC) WITH (FILLFACTOR = 70)
);


GO
-- =============================================
-- Author:		Balaji Sankar
-- Create date: April 2, 2018
-- Description:	To capture Audit log
-- =============================================
CREATE  TRIGGER[dbo].[Trg_IU_CDCChangeLog] ON [dbo].[CDCChangeLog]
   AFTER INSERT, UPDATE
AS 
BEGIN
	SET NOCOUNT ON;
	DECLARE @Inserted TABLE (LogID int)
	DECLARE @Cnt int, @LogID int

	INSERT INTO @Inserted
	SELECT ChangeLogID FROM Inserted
	SET @Cnt = @@ROWCOUNT
	WHILE @Cnt >0
	BEGIN
		SELECT TOP 1 @LogID = LogID FROM @Inserted
		EXEC dbo.usp_CDC_Audit_Log @LogID;

		DELETE FROM @Inserted WHERE LogID = @LogID
		SET @Cnt = @Cnt -1;
	END
   
END
