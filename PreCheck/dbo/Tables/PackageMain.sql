CREATE TABLE [dbo].[PackageMain] (
    [PackageID]          INT           IDENTITY (1, 1) NOT NULL,
    [PackageDesc]        VARCHAR (100) NOT NULL,
    [DefaultPrice]       SMALLMONEY    NULL,
    [refPackageTypeID]   INT           NULL,
    [IsAutoCloseEnabled] BIT           CONSTRAINT [DF_PackageMain_IsAutoCloseEnabled] DEFAULT ((0)) NULL,
    [IsActive]           BIT           CONSTRAINT [DF_PackageMain_IsActive] DEFAULT ((1)) NULL,
    [CreateDate]         DATETIME2 (7) CONSTRAINT [DF_PackageMain_CreateDate] DEFAULT (getdate()) NULL,
    [ModifyDate]         DATETIME2 (7) CONSTRAINT [DF_PackageMain_ModifyDate] DEFAULT (getdate()) NULL,
    [CreateBy]           VARCHAR (10)  NULL,
    [ModifyBy]           VARCHAR (10)  NULL,
    CONSTRAINT [PK_PackageMain] PRIMARY KEY CLUSTERED ([PackageID] ASC) WITH (FILLFACTOR = 50)
);

