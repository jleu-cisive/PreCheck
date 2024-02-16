CREATE TABLE [dbo].[refAdverseContactType] (
    [AdverseContactTypeID] INT           IDENTITY (1, 1) NOT NULL,
    [AdverseContactType]   NVARCHAR (50) NULL,
    CONSTRAINT [PK_refAdverseContactType] PRIMARY KEY CLUSTERED ([AdverseContactTypeID] ASC) WITH (FILLFACTOR = 50)
);

