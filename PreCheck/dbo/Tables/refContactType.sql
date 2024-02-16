CREATE TABLE [dbo].[refContactType] (
    [ContactTypeID] INT           IDENTITY (1, 1) NOT NULL,
    [ContactType]   NVARCHAR (50) NULL,
    CONSTRAINT [PK_refContactType] PRIMARY KEY CLUSTERED ([ContactTypeID] ASC) WITH (FILLFACTOR = 50)
);

