CREATE TABLE [dbo].[PackageService] (
    [PackageServiceID] INT      IDENTITY (1, 1) NOT NULL,
    [PackageID]        INT      NOT NULL,
    [ServiceType]      TINYINT  NOT NULL,
    [ServiceID]        INT      NULL,
    [IncludedCount]    SMALLINT NOT NULL,
    [MaxCount]         SMALLINT NOT NULL,
    CONSTRAINT [PK_PackageService] PRIMARY KEY CLUSTERED ([PackageServiceID] ASC) WITH (FILLFACTOR = 50),
    CONSTRAINT [FK_PackageService_DefaultRates] FOREIGN KEY ([ServiceID]) REFERENCES [dbo].[DefaultRates] ([ServiceID]),
    CONSTRAINT [FK_PackageService_PackageMain] FOREIGN KEY ([PackageID]) REFERENCES [dbo].[PackageMain] ([PackageID])
);


GO
CREATE NONCLUSTERED INDEX [IDX_PackageService_PackageID]
    ON [dbo].[PackageService]([PackageID] ASC)
    INCLUDE([ServiceID], [IncludedCount]) WITH (FILLFACTOR = 70);

