CREATE TABLE [dbo].[refTaskPriorityLevel] (
    [TaskPriorityLevelID] INT          IDENTITY (1, 1) NOT NULL,
    [TaskPriorityLevel]   VARCHAR (50) NULL,
    [IsActive]            BIT          CONSTRAINT [DF_refTaskPriorityLevel_IsActive] DEFAULT (1) NOT NULL,
    CONSTRAINT [PK_refTaskPriorityLevel] PRIMARY KEY CLUSTERED ([TaskPriorityLevelID] ASC) WITH (FILLFACTOR = 50)
);

