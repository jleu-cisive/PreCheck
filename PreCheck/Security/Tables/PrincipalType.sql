CREATE TABLE [Security].[PrincipalType] (
    [PrincipalTypeId]      INT           IDENTITY (1, 1) NOT NULL,
    [PrincipalTypeName]    VARCHAR (50)  NULL,
    [ShortName]            VARCHAR (10)  NULL,
    [EntityName]           VARCHAR (100) NULL,
    [PrincipalDescription] VARCHAR (200) NULL,
    [CreateDate]           DATETIME      CONSTRAINT [DF_PrincipalType_CreateDate] DEFAULT (getdate()) NOT NULL,
    [CreateBy]             INT           CONSTRAINT [DF_PrincipalType_CreateBy] DEFAULT ((0)) NOT NULL,
    [ModifyDate]           DATETIME      CONSTRAINT [DF_PrincipalType_ModifyDate] DEFAULT (getdate()) NOT NULL,
    [ModifyBy]             INT           CONSTRAINT [DF_PrincipalType_ModifyBy] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_PrincipalType] PRIMARY KEY CLUSTERED ([PrincipalTypeId] ASC) WITH (FILLFACTOR = 70) ON [PRIMARY]
) ON [PRIMARY];

