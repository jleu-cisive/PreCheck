-- =============================================
-- Author:		Johnny Keller
-- Create date: 12/12/2019
-- Description:	Reports all agents that are enabled 
--              to monitor their respective license types
-- =============================================
CREATE PROCEDURE [dbo].[LMP_ReportEnabledAgents] 

AS
BEGIN

	SET NOCOUNT ON;

	SELECT DISTINCT [SectionKeyId] AS Agents
	FROM DataXtract_Logging  
	WHERE [SectionKeyId] LIKE 'tn%' AND DATEDIFF(DAY, [DateLogResponse], GETDATE()) = 1 AND [Response] IS NOT NULL AND [BatchId] IS NULL --[BatchId] is null to pull only agents that are ran through TN Integrations
		UNION
	SELECT [SectionKeyID] AS Agents
	FROM DataXtract_RequestMapping 
	WHERE [Section] = 'License' AND [isAutomationEnabled] = 1

	--declare @text varchar(max)
	--set @text = 'List of Active Agents as of: '+convert(varchar(12),getdate(),107);

	--DECLARE @EmailTable table(
	--						  [Id] int identity(1,1),
	--						  [Client] nvarchar(50),
	--						  [ClientID] int,
	--						  [FileType] nvarchar(50),
	--						  [CurrentReceivedDate] dateTime,
	--						  [LastLoggedReceive] dateTime
	--						  )

	--insert into @EmailTable([Client], [ClientID], [FileType], [CurrentReceivedDate], [LastLoggedReceive])
	--	select *
	--	from #notReceived 

	--if exists (select top 1 1 from @EmailTable)
	--begin
	--	 declare @html nvarchar(max);
	--	 declare @id int;
	--	 declare @max int;
	--	 declare @client nvarchar(500);
	--	 declare @clientId nvarchar(500);
	--	 declare @fileType nvarchar(500);
	--	 declare @currentReceivedDate nvarchar(510);
	--	 declare @lastLoggedReceive nvarchar(510);

	--	 set @html = '<body> <table border ="1">
	--					<tr>
	--						<td>Client</td>
	--						<td>ClientID</td>
	--						<td>FileType</td>
	--						<td>"Most Recent" Reception</td>
	--						<td>Last Time Reception was Noted and Logged in </td>
	--					</tr>';

	--	select @max = count (*) from @EmailTable;

	--	if(@max > 0)
	--	begin
	--		set @id = 1;

	--		while(@id <= @max)
	--		begin
	--			select
	--			@client = cast(isnull([Client], '') as nvarchar(500)),
	--			@clientId = cast(isnull([ClientID], '') as nvarchar(500)),
	--			@fileType = cast(isnull([FileType], '') as nvarchar(500)),
	--			@currentReceivedDate = cast(isnull([CurrentReceivedDate], '') as nvarchar(510)),
	--			@lastLoggedReceive = cast(isnull([LastLoggedReceive], '') as nvarchar(510))
	--			from @EmailTable
	--			where [Id] = @id;

	--			set @html = @html + 
	--							'<tr>
	--								<td>'+@client+'</td>
	--								<td>'+@clientId+'</td>
	--								<td>'+@fileType+'</td>
	--								<td>'+@currentReceivedDate+'</td>
	--								<td>'+@lastLoggedReceive+'</td>
	--							</tr>';
	--			set @id = @id + 1;
	--		end

	--		set @html = @html + '</table></body>';

	--			exec msdb.dbo.sp_send_dbmail
	--				@from_address = 'ALA-DB-01 SQL Service <SQLService@precheck.com>',
	--				@subject = @text,
	--				@recipients=N'JohnnyKeller@precheck.com',
	--				@body = @html,
	--				@body_format = 'html';


	--	end

	--end

	--delete from @EmailTable

END
