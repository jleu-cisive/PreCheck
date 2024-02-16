CREATE TABLE [dbo].[refHierarchyService] (
    [refHierarchyServiceID] INT           IDENTITY (1, 1) NOT NULL,
    [Description]           VARCHAR (100) NULL,
    CONSTRAINT [PK_refHierarchyService] PRIMARY KEY CLUSTERED ([refHierarchyServiceID] ASC) WITH (FILLFACTOR = 50)
);

