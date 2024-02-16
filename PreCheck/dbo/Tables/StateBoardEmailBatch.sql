CREATE TABLE [dbo].[StateBoardEmailBatch] (
    [StateBoardEmailBatchID] UNIQUEIDENTIFIER NOT NULL,
    [StateBoardMatchID]      INT              NOT NULL,
    CONSTRAINT [PK_StateBoardEmailBatch] PRIMARY KEY CLUSTERED ([StateBoardEmailBatchID] ASC, [StateBoardMatchID] ASC) WITH (FILLFACTOR = 50)
);

