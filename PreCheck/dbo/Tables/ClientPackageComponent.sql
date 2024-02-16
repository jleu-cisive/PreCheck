CREATE TABLE [dbo].[ClientPackageComponent] (
    [ClientPackageComponentID] INT        IDENTITY (1, 1) NOT NULL,
    [ClientPackagesID]         INT        NOT NULL,
    [PackageComponentID]       INT        NOT NULL,
    [refRescreeningPeriodID]   INT        NOT NULL,
    [Rate]                     SMALLMONEY NULL,
    [RescreeningRate]          SMALLMONEY NULL,
    [IsActive]                 BIT        NOT NULL,
    [Comment]                  TEXT       NULL,
    CONSTRAINT [PK_ClientPackageComponent] PRIMARY KEY CLUSTERED ([ClientPackageComponentID] ASC),
    CONSTRAINT [FK_ClientPackageComponent_ClientPackages] FOREIGN KEY ([ClientPackagesID]) REFERENCES [dbo].[ClientPackages] ([ClientPackagesID]),
    CONSTRAINT [FK_ClientPackageComponent_PackageComponent] FOREIGN KEY ([PackageComponentID]) REFERENCES [dbo].[PackageComponent] ([PackageComponentID]),
    CONSTRAINT [FK_ClientPackageComponent_refRescreeningPeriod] FOREIGN KEY ([refRescreeningPeriodID]) REFERENCES [dbo].[refRescreeningPeriod] ([refRescreeningPeriodID])
) TEXTIMAGE_ON [PRIMARY];

