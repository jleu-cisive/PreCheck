CREATE TABLE [dbo].[refAdverseChangeType] (
    [AdverseChangeTypeID] INT       IDENTITY (1, 1) NOT NULL,
    [AdverseChangeType]   CHAR (50) NULL,
    CONSTRAINT [PK_refAdverseChangeType] PRIMARY KEY CLUSTERED ([AdverseChangeTypeID] ASC) WITH (FILLFACTOR = 50)
);

