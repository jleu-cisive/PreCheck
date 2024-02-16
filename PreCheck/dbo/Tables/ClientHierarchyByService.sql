CREATE TABLE [dbo].[ClientHierarchyByService] (
    [ClientHierarchyByServiceID] INT IDENTITY (1, 1) NOT NULL,
    [CLNO]                       INT NOT NULL,
    [ParentCLNO]                 INT NOT NULL,
    [refHierarchyServiceID]      INT NOT NULL,
    CONSTRAINT [PK_ClientHierarchyByService] PRIMARY KEY CLUSTERED ([ClientHierarchyByServiceID] ASC) WITH (FILLFACTOR = 50),
    CONSTRAINT [FK_ClientHierarchyByService_refHierarchyService] FOREIGN KEY ([refHierarchyServiceID]) REFERENCES [dbo].[refHierarchyService] ([refHierarchyServiceID]),
    CONSTRAINT [U_CLNO_SERVICE] UNIQUE NONCLUSTERED ([CLNO] ASC, [refHierarchyServiceID] ASC) WITH (FILLFACTOR = 50) ON [PRIMARY]
);


GO
CREATE NONCLUSTERED INDEX [IX_ClientHierarchyByService_CLNO]
    ON [dbo].[ClientHierarchyByService]([CLNO] ASC)
    INCLUDE([ParentCLNO], [refHierarchyServiceID]);

