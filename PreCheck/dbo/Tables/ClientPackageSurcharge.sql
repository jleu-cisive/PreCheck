CREATE TABLE [dbo].[ClientPackageSurcharge] (
    [ClientPackageSurchargeID] INT           IDENTITY (1, 1) NOT NULL,
    [Description]              VARCHAR (100) NOT NULL,
    [Amount]                   SMALLMONEY    NOT NULL,
    [ClientPackagesID]         INT           NOT NULL,
    CONSTRAINT [PK_ClientPackageSurcharge] PRIMARY KEY CLUSTERED ([ClientPackageSurchargeID] ASC) WITH (FILLFACTOR = 50),
    CONSTRAINT [FK_ClientPackageSurcharge_ClientPackages] FOREIGN KEY ([ClientPackagesID]) REFERENCES [dbo].[ClientPackages] ([ClientPackagesID])
);

