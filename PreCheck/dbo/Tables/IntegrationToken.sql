CREATE TABLE [dbo].[IntegrationToken] (
    [IntegrationTokenId]          INT              IDENTITY (1, 1) NOT NULL,
    [Token]                       UNIQUEIDENTIFIER NOT NULL,
    [refIntegrationTokenSourceId] INT              NOT NULL,
    [ExpireDate]                  DATETIME         NOT NULL,
    [CreateDate]                  DATETIME         NULL,
    [CreateBy]                    VARCHAR (50)     NULL,
    [ModifyDate]                  DATETIME         NULL,
    [ModifyBy]                    VARCHAR (50)     NULL,
    [RequestId]                   INT              NULL,
    CONSTRAINT [PK_IntegrationToken] PRIMARY KEY CLUSTERED ([IntegrationTokenId] ASC) ON [PRIMARY]
) ON [PRIMARY];

