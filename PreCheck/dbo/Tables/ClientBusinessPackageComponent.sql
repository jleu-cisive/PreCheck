CREATE TABLE [dbo].[ClientBusinessPackageComponent] (
    [ClientBusinessPackageComponent] INT          IDENTITY (1, 1) NOT NULL,
    [ClientBusinessPackageId]        INT          NOT NULL,
    [BusinessServiceId]              INT          NOT NULL,
    [PackageId]                      INT          NOT NULL,
    [ClientPackageId]                INT          NOT NULL,
    [CreateDate]                     DATETIME     CONSTRAINT [DF_ClientBusinessPackageComponent_CreateDate] DEFAULT (getdate()) NOT NULL,
    [CreateBy]                       VARCHAR (50) CONSTRAINT [DF_ClientBusinessPackageComponent_CreateBy] DEFAULT (suser_sname()) NOT NULL,
    [ModifyDate]                     DATETIME     CONSTRAINT [DF_ClientBusinessPackageComponent_ModifyDate] DEFAULT (getdate()) NOT NULL,
    [ModifyBy]                       VARCHAR (50) CONSTRAINT [DF_ClientBusinessPackageComponent_ModifyBy] DEFAULT (suser_sname()) NOT NULL,
    CONSTRAINT [PK_ClientBusinessPackageComponent] PRIMARY KEY CLUSTERED ([ClientBusinessPackageComponent] ASC) WITH (FILLFACTOR = 70) ON [PRIMARY],
    CONSTRAINT [FK_ClientBusinessPackageComponent_ClientBusinessPackage] FOREIGN KEY ([ClientBusinessPackageId]) REFERENCES [dbo].[ClientBusinessPackage] ([ClientBusinessPackageId]),
    CONSTRAINT [FK_ClientBusinessPackageComponent_ClientPackages] FOREIGN KEY ([ClientPackageId]) REFERENCES [dbo].[ClientPackages] ([ClientPackagesID]),
    CONSTRAINT [FK_ClientBusinessPackageComponent_PackageMain] FOREIGN KEY ([PackageId]) REFERENCES [dbo].[PackageMain] ([PackageID])
) ON [PRIMARY];

