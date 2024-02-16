CREATE TABLE [dbo].[refTaskType] (
    [refTaskTypeID] INT          NOT NULL,
    [TaskType]      VARCHAR (50) NULL,
    [IsActive]      BIT          NOT NULL,
    CONSTRAINT [PK_refTaskType] PRIMARY KEY CLUSTERED ([refTaskTypeID] ASC) WITH (FILLFACTOR = 50)
);

