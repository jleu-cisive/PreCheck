CREATE TABLE [dbo].[I9StatusCodeMapping] (
    [I9StatusCodeMappingId] INT           IDENTITY (1, 1) NOT NULL,
    [ClientId]              INT           NOT NULL,
    [I9StatusCode]          INT           NOT NULL,
    [EVerifyStatusCode]     INT           NOT NULL,
    [EVerifyStatusCodeDesc] VARCHAR (100) NOT NULL,
    [CreateDate]            DATETIME      NULL,
    CONSTRAINT [PK_I9StatusCodeMapping] PRIMARY KEY CLUSTERED ([I9StatusCodeMappingId] ASC) ON [PRIMARY]
) ON [PRIMARY];

