
-- =============================================
-- Author:		Simenc, Jeff
-- Create date: 09/11/2019
-- Description:	Trigger will insert object data and ddl event data to the DDLEvents table 
--
-- =============================================

CREATE TRIGGER [DDLTrigger_DDLEvents]
    ON DATABASE
    FOR DDL_DATABASE_LEVEL_EVENTS
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE
        @EventData XML = EVENTDATA();
 
    DECLARE @ip VARCHAR(48) = CONVERT(VARCHAR(48), 
        CONNECTIONPROPERTY('client_net_address'));
	
	DECLARE @obid INT, @obname NVARCHAR(255), @obtype VARCHAR(5), @prevobdef NVARCHAR(MAX), @eventtype NVARCHAR(64);

	SET @obname = @EventData.value('(/EVENT_INSTANCE/ObjectName)[1]',  'NVARCHAR(255)');
	SELECT @obid = object_id FROM sys.objects WHERE name = @obname;
	SELECT @obtype = @EventData.value('(/EVENT_INSTANCE/ObjectType)[1]',  'NVARCHAR(255)');
	SET @prevobdef = (SELECT TOP (1) CurrObjectDef FROM dbo.DDLEvents WHERE ObjectName = @obname ORDER BY EventDate DESC)
	SET @eventtype = @EventData.value('(/EVENT_INSTANCE/EventType)[1]',   'NVARCHAR(100)')
	
	IF @eventtype <> 'UPDATE_STATISTICS' AND @obname <> 'Stg_PreEmpl_AutomationResults'
		INSERT dbo.DDLEvents
		(
			PrevObjectDef,
			CurrObjectDef,
			EventType,
			EventDDL,
			EventXML,
			DatabaseName,
			SchemaName,
			ObjectName,
			HostName,
			IPAddress,
			ProgramName,
			LoginName
		)
		SELECT
			@prevobdef,
			CASE	@obtype
				WHEN 'TABLE' THEN [dbo].[udf_GetTableDefinition] (@obid)
				WHEN 'INDEX' THEN [dbo].[udf_GetIndexDefinition] (@obname)
				ELSE	OBJECT_DEFINITION(@obid)
			END,
			@EventData.value('(/EVENT_INSTANCE/EventType)[1]',   'NVARCHAR(100)'), 
			@EventData.value('(/EVENT_INSTANCE/TSQLCommand)[1]', 'NVARCHAR(MAX)'),
			@EventData,
			DB_NAME(),
			@EventData.value('(/EVENT_INSTANCE/SchemaName)[1]',  'NVARCHAR(255)'), 
			@EventData.value('(/EVENT_INSTANCE/ObjectName)[1]',  'NVARCHAR(255)'),
			HOST_NAME(),
			@ip,
			PROGRAM_NAME(),
			SUSER_SNAME();
END

