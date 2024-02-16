CREATE TABLE [dbo].[refTaskProjectType] (
    [refProjectTypeID] INT          IDENTITY (1, 1) NOT NULL,
    [ProjectType]      VARCHAR (20) NULL,
    CONSTRAINT [PK_refTaskProjectType] PRIMARY KEY CLUSTERED ([refProjectTypeID] ASC) WITH (FILLFACTOR = 50)
);

