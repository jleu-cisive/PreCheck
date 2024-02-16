CREATE TABLE [dbo].[Sync_Config] (
    [SyncID]       INT           IDENTITY (1, 1) NOT NULL,
    [TableName]    VARCHAR (255) NOT NULL,
    [LastSyncDate] DATETIME      NULL,
    [ColumnName]   VARCHAR (200) NULL,
    PRIMARY KEY CLUSTERED ([SyncID] ASC) WITH (FILLFACTOR = 70)
);

