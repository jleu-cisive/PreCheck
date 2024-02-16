CREATE TABLE [Security].[ResourceType] (
    [ResourceTypeId]      INT           IDENTITY (1, 1) NOT NULL,
    [ResourceTypeName]    VARCHAR (50)  NULL,
    [ShortName]           VARCHAR (10)  NULL,
    [EntityName]          VARCHAR (100) NULL,
    [ResourceDescription] VARCHAR (200) NULL,
    [CreateDate]          DATETIME      CONSTRAINT [DF_ResourceType_CreateDate] DEFAULT (getdate()) NOT NULL,
    [CreateBy]            INT           CONSTRAINT [DF_ResourceType_CreateBy] DEFAULT ((0)) NOT NULL,
    [ModifyDate]          DATETIME      CONSTRAINT [DF_ResourceType_ModifyDate] DEFAULT (getdate()) NOT NULL,
    [ModifyBy]            INT           CONSTRAINT [DF_ResourceType_ModifyBy] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_ResourceType] PRIMARY KEY CLUSTERED ([ResourceTypeId] ASC) WITH (FILLFACTOR = 70) ON [PRIMARY]
) ON [PRIMARY];

