CREATE TABLE [dbo].[refTaskBugStatus] (
    [refTaskBugStatusID] INT          IDENTITY (1, 1) NOT NULL,
    [TaskBugStatus]      VARCHAR (50) NULL,
    [IsActive]           BIT          NULL,
    CONSTRAINT [PK_refTaskBugStatus] PRIMARY KEY CLUSTERED ([refTaskBugStatusID] ASC) WITH (FILLFACTOR = 50)
);

