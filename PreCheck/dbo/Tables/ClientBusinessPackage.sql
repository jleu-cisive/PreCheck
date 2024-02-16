CREATE TABLE [dbo].[ClientBusinessPackage] (
    [ClientBusinessPackageId] INT           IDENTITY (1, 1) NOT NULL,
    [PackageName]             VARCHAR (100) NOT NULL,
    [PackageDescription]      VARCHAR (250) NULL,
    [PackageCode]             VARCHAR (15)  NULL,
    [ClientId]                INT           NULL,
    [IsActive]                BIT           NULL,
    [CreateDate]              DATETIME      CONSTRAINT [DF_ClientBusinessPackage_CreateDate] DEFAULT (getdate()) NOT NULL,
    [CreateBy]                VARCHAR (50)  CONSTRAINT [DF_ClientBusinessPackage_CreateBy] DEFAULT (suser_sname()) NOT NULL,
    [ModifyDate]              DATETIME      CONSTRAINT [DF_ClientBusinessPackage_ModifyDate] DEFAULT (getdate()) NOT NULL,
    [ModifyBy]                VARCHAR (50)  CONSTRAINT [DF_ClientBusinessPackage_ModifyBy] DEFAULT (suser_sname()) NOT NULL,
    CONSTRAINT [PK_ClientBusinessPackage] PRIMARY KEY CLUSTERED ([ClientBusinessPackageId] ASC) WITH (FILLFACTOR = 70) ON [PRIMARY]
) ON [PRIMARY];

