CREATE TABLE [dbo].[I9PrimaryCompanyMapping] (
    [I9PrimaryCompanyMappingId]  BIGINT         IDENTITY (1, 1) NOT NULL,
    [ClNo]                       INT            NOT NULL,
    [CompanyName]                NVARCHAR (256) NULL,
    [PrimaryCompanyId]           BIGINT         NOT NULL,
    [IsActive]                   BIT            NOT NULL,
    [CreateDate]                 DATETIME       NOT NULL,
    [CreateBy]                   NVARCHAR (50)  NULL,
    [ModifyDate]                 DATETIME       NULL,
    [ModifyBy]                   NVARCHAR (50)  NULL,
    [ClientConfig_IntegrationId] INT            DEFAULT (NULL) NULL,
    CONSTRAINT [PK_dbo.I9PrimaryCompanyMapping] PRIMARY KEY CLUSTERED ([I9PrimaryCompanyMappingId] ASC)
);

