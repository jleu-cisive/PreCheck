CREATE TABLE [dbo].[CisiveIntegrationAPI] (
    [CisiveIntegrationAPIId] INT            IDENTITY (1, 1) NOT NULL,
    [APIName]                VARCHAR (100)  NOT NULL,
    [Url]                    VARCHAR (500)  NOT NULL,
    [Header]                 VARCHAR (1000) NULL,
    [PostBody]               VARCHAR (MAX)  NULL,
    [Response]               VARCHAR (MAX)  NULL,
    CONSTRAINT [PK_CisiveIntegrationAPI] PRIMARY KEY CLUSTERED ([CisiveIntegrationAPIId] ASC) WITH (FILLFACTOR = 70)
);

