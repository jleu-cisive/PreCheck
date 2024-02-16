CREATE TABLE [dbo].[refTaskStatus] (
    [refTaskStatusID] INT          IDENTITY (1, 1) NOT NULL,
    [TaskStatus]      VARCHAR (50) NOT NULL,
    [DisplayOrder]    INT          NULL,
    [IsActive]        BIT          NULL,
    CONSTRAINT [PK_refTaskStatus] PRIMARY KEY CLUSTERED ([refTaskStatusID] ASC) WITH (FILLFACTOR = 50)
);

