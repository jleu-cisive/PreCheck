CREATE TABLE [dbo].[WinServiceConfig] (
    [ServiceConfigId] INT            IDENTITY (1, 1) NOT NULL,
    [WinServiceId]    INT            NULL,
    [KeyName]         VARCHAR (100)  NULL,
    [KeyValue]        VARCHAR (1000) NULL,
    [CreateDate]      DATETIME       CONSTRAINT [DF_WinServiceConfig_CreateDate] DEFAULT (getdate()) NOT NULL,
    [CreateUser]      VARCHAR (50)   CONSTRAINT [DF_WinServiceConfig_CreateUser] DEFAULT (suser_name()) NOT NULL,
    [ModifyDate]      DATETIME       CONSTRAINT [DF_WinServiceConfig_ModifyDate] DEFAULT (getdate()) NOT NULL,
    [ModifyUser]      VARCHAR (50)   CONSTRAINT [DF_WinServiceConfig_ModifyUser] DEFAULT (suser_name()) NOT NULL,
    CONSTRAINT [PK_WinServiceConfig] PRIMARY KEY CLUSTERED ([ServiceConfigId] ASC)
);

