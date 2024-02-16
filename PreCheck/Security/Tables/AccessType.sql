CREATE TABLE [Security].[AccessType] (
    [AccessTypeId]      INT           IDENTITY (1, 1) NOT NULL,
    [AccessTypeName]    VARCHAR (50)  NULL,
    [ShortName]         VARCHAR (10)  NULL,
    [EntityName]        VARCHAR (100) NULL,
    [AccessDescription] VARCHAR (200) NULL,
    [CreateDate]        DATETIME      NOT NULL,
    [CreateBy]          INT           CONSTRAINT [DF_AccessType_CreateBy] DEFAULT ((0)) NOT NULL,
    [ModifyDate]        DATETIME      CONSTRAINT [DF_AccessType_ModifyDate] DEFAULT (getdate()) NOT NULL,
    [ModifyBy]          INT           CONSTRAINT [DF_AccessType_ModifyBy] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_AccessType] PRIMARY KEY CLUSTERED ([AccessTypeId] ASC) WITH (FILLFACTOR = 70) ON [PRIMARY]
) ON [PRIMARY];

