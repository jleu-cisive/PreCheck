CREATE TABLE [dbo].[ClientPackages] (
    [ClientPackagesID]          INT           IDENTITY (1, 1) NOT NULL,
    [CLNO]                      SMALLINT      NOT NULL,
    [PackageID]                 INT           NOT NULL,
    [Rate]                      SMALLMONEY    NULL,
    [ClientPackageDesc]         VARCHAR (100) NULL,
    [ClientPackageCode]         VARCHAR (50)  NULL,
    [IsActive]                  BIT           CONSTRAINT [DF_ClientPackages_IsActive] DEFAULT ((1)) NOT NULL,
    [BusinessServiceBehaviorId] INT           NULL,
    [CreateDate]                DATETIME      CONSTRAINT [DF_ClientPackages_CreateDate] DEFAULT (getdate()) NULL,
    [CreateBy]                  VARCHAR (50)  NULL,
    [ModifyDate]                DATETIME      CONSTRAINT [DF_ClientPackages_ModifyDate] DEFAULT (getdate()) NULL,
    [ModifyBy]                  VARCHAR (50)  NULL,
    [ZipCrimClientPackageID]    VARCHAR (6)   NULL,
    CONSTRAINT [PK_ClientPackages] PRIMARY KEY CLUSTERED ([ClientPackagesID] ASC) WITH (FILLFACTOR = 50),
    CONSTRAINT [FK_ClientPackages_Client] FOREIGN KEY ([CLNO]) REFERENCES [dbo].[Client] ([CLNO]),
    CONSTRAINT [FK_ClientPackages_PackageMain] FOREIGN KEY ([PackageID]) REFERENCES [dbo].[PackageMain] ([PackageID])
);


GO
CREATE NONCLUSTERED INDEX [IDX_ClientPackages_CLNO]
    ON [dbo].[ClientPackages]([CLNO] ASC) WITH (FILLFACTOR = 70);

