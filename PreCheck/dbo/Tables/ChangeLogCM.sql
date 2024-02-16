CREATE TABLE [dbo].[ChangeLogCM] (
    [HEVNMgmtChangeLogID] INT           IDENTITY (1, 1) NOT NULL,
    [TableName]           VARCHAR (150) NULL,
    [ID]                  INT           NULL,
    [OldValue]            VARCHAR (MAX) NULL,
    [NewValue]            VARCHAR (MAX) NULL,
    [ChangeDate]          DATETIME      NULL,
    [UserID]              VARCHAR (50)  NULL,
    [CLNO]                INT           NULL,
    CONSTRAINT [PK_ChangeLog_newCM] PRIMARY KEY CLUSTERED ([HEVNMgmtChangeLogID] ASC) WITH (FILLFACTOR = 50)
);


GO
CREATE NONCLUSTERED INDEX [IX_ChangeLogCM_ChangeDate_CLNO]
    ON [dbo].[ChangeLogCM]([ChangeDate] ASC, [CLNO] ASC);

