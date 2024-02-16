CREATE TABLE [dbo].[ApplActivity] (
    [ApplActivityID] INT          IDENTITY (1, 1) NOT NULL,
    [APNO]           INT          NOT NULL,
    [ActivityCode]   INT          NOT NULL,
    [userid]         VARCHAR (25) NOT NULL,
    [ActivityDate]   DATETIME     CONSTRAINT [DF_ApplActivity_ActivityDate] DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_ApplActivity] PRIMARY KEY CLUSTERED ([ApplActivityID] ASC) WITH (FILLFACTOR = 50)
);


GO
CREATE NONCLUSTERED INDEX [IX_ApplActivity_ActivityCode]
    ON [dbo].[ApplActivity]([ActivityCode] ASC)
    INCLUDE([APNO], [ActivityDate]);

