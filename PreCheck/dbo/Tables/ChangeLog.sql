CREATE TABLE [dbo].[ChangeLog] (
    [HEVNMgmtChangeLogID] BIGINT         IDENTITY (227863436, 1) NOT NULL,
    [TableName]           VARCHAR (150)  NULL,
    [ID]                  INT            NULL,
    [OldValue]            VARCHAR (8000) NULL,
    [NewValue]            VARCHAR (8000) NULL,
    [ChangeDate]          DATETIME       CONSTRAINT [DF_ChangeLogNew_ChangeDate] DEFAULT (getdate()) NOT NULL,
    [UserID]              VARCHAR (50)   NULL,
    CONSTRAINT [PK_ChangeLog_2018] PRIMARY KEY CLUSTERED ([HEVNMgmtChangeLogID] ASC, [ChangeDate] ASC) WITH (FILLFACTOR = 90) ON [PS1_Changelog] ([ChangeDate])
) ON [PS1_Changelog] ([ChangeDate]);


GO
CREATE NONCLUSTERED INDEX [IX_ChangeLog_ChangeDate]
    ON [dbo].[ChangeLog]([ChangeDate] ASC)
    INCLUDE([HEVNMgmtChangeLogID]) WITH (FILLFACTOR = 90)
    ON [FG_INDEX];


GO
CREATE NONCLUSTERED INDEX [IDX_ChangeLog_TableName]
    ON [dbo].[ChangeLog]([TableName] ASC)
    INCLUDE([ID], [ChangeDate], [UserID]) WITH (FILLFACTOR = 70)
    ON [PS1_Changelog] ([ChangeDate]);


GO
CREATE NONCLUSTERED INDEX [idx_ChangeLog_UserID_id]
    ON [dbo].[ChangeLog]([UserID] ASC, [ChangeDate] ASC, [TableName] ASC, [ID] ASC) WITH (FILLFACTOR = 70)
    ON [PS1_Changelog] ([ChangeDate]);


GO
CREATE NONCLUSTERED INDEX [idx_ChangeLog_UserID_Changedate]
    ON [dbo].[ChangeLog]([ChangeDate] ASC, [TableName] ASC, [ID] ASC) WITH (FILLFACTOR = 70)
    ON [PS1_Changelog] ([ChangeDate]);


GO
CREATE NONCLUSTERED INDEX [IX_ChangeLog_ID]
    ON [dbo].[ChangeLog]([ID] ASC, [TableName] ASC)
    INCLUDE([NewValue], [UserID]) WHERE ([newvalue]='z')
    ON [FG_DATA];


GO
CREATE NONCLUSTERED INDEX [IX_ChangeLog_ID_Filtered]
    ON [dbo].[ChangeLog]([ID] ASC)
    INCLUDE([NewValue], [ChangeDate], [UserID]) WHERE ([NewValue] IN ('2', '3', '4', '5', 'z'))
    ON [FG_INDEX];


GO
CREATE NONCLUSTERED INDEX [IDX_Changelog_ID_ChangeDate]
    ON [dbo].[ChangeLog]([ID] ASC, [ChangeDate] ASC)
    INCLUDE([UserID])
    ON [FG_INDEX];

